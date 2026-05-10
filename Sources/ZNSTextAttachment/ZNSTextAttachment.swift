//
//  ZNSTextAttachment.swift
//
//
//  Created by https://zhgchg.li on 2023/3/5.
//

#if canImport(UIKit)
import UIKit
import MobileCoreServices
#elseif canImport(AppKit)
import AppKit
#endif

import UniformTypeIdentifiers

/// `NSTextAttachment` subclass that asynchronously loads an image from a remote
/// or `data:` URL and replaces itself with a `ZResizableNSTextAttachment` once
/// the data is available.
public class ZNSTextAttachment: NSTextAttachment {

    /// The URL the attachment will load. Supports `http(s)://`, custom schemes
    /// handled by an injected `dataSource`, and `data:image/...;base64,...` URLs.
    public let imageURL: URL

    /// Notified on the main thread when loading completes or fails.
    public weak var delegate: ZNSTextAttachmentDelegate?

    /// Optional custom loader. When set, `URLSession` is bypassed and the
    /// data source is asked to provide the data for `imageURL`.
    public weak var dataSource: ZNSTextAttachmentDataSource?

    private let origin: CGPoint?
    private let imageWidth: CGFloat?
    private let imageHeight: CGFloat?
    private let urlSession: URLSession

    private let stateLock = NSLock()
    private var isLoading: Bool = false
    private var sources: [WeakZNSTextAttachmentable] = []
    private var urlSessionDataTask: URLSessionDataTask?

    #if canImport(UIKit)
    /// Create an attachment that lazily downloads `imageURL` when laid out.
    /// - Parameters:
    ///   - imageURL: HTTP(S), custom-scheme, or `data:image/...;base64,` URL.
    ///   - imageWidth: If set, the loaded attachment is sized to this width.
    ///   - imageHeight: If set, the loaded attachment is sized to this height.
    ///   - placeholderImage: Image shown until loading completes.
    ///   - placeholderImageOrigin: Origin used while measuring the placeholder.
    ///   - urlSession: Session used for default downloads. Defaults to `.shared`.
    public init(imageURL: URL, imageWidth: CGFloat? = nil, imageHeight: CGFloat? = nil, placeholderImage: UIImage? = nil, placeholderImageOrigin: CGPoint? = nil, urlSession: URLSession = .shared) {
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.origin = placeholderImageOrigin
        self.urlSession = urlSession

        if let placeholderImageData = placeholderImage?.pngData() {
            super.init(data: placeholderImageData, ofType: "public.png")
        } else {
            super.init(data: nil, ofType: nil)
        }

        self.image = placeholderImage
    }
    #elseif canImport(AppKit)
    /// Create an attachment that lazily downloads `imageURL` when laid out.
    /// - Parameters:
    ///   - imageURL: HTTP(S), custom-scheme, or `data:image/...;base64,` URL.
    ///   - imageWidth: If set, the loaded attachment is sized to this width.
    ///   - imageHeight: If set, the loaded attachment is sized to this height.
    ///   - placeholderImage: Image shown until loading completes.
    ///   - placeholderImageOrigin: Origin used while measuring the placeholder.
    ///   - urlSession: Session used for default downloads. Defaults to `.shared`.
    public init(imageURL: URL, imageWidth: CGFloat? = nil, imageHeight: CGFloat? = nil, placeholderImage: NSImage? = nil, placeholderImageOrigin: CGPoint? = nil, urlSession: URLSession = .shared) {
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.origin = placeholderImageOrigin
        self.urlSession = urlSession

        if let placeholderImageData = placeholderImage?.tiffRepresentation {
            super.init(data: placeholderImageData, ofType: "public.png")
        } else {
            super.init(data: nil, ofType: nil)
        }

        self.image = placeholderImage
    }
    #endif

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Register a target that should have its `ZNSTextAttachment` instances
    /// replaced once loading completes. Calling this with the same source
    /// twice is safe — duplicates are ignored and dead weak refs are pruned.
    public func register(_ source: ZNSTextAttachmentable) {
        stateLock.lock()
        sources.removeAll { $0.value == nil }
        if !sources.contains(where: { $0.value === source }) {
            sources.append(WeakZNSTextAttachmentable(source))
        }
        stateLock.unlock()
    }

    /// Begin loading. Calls are idempotent: a second call while a load is in
    /// flight is a no-op. Loading is performed off the main thread; delegate
    /// callbacks fire on the main thread.
    public func startDownload() {
        stateLock.lock()
        guard !isLoading else {
            stateLock.unlock()
            return
        }
        isLoading = true
        stateLock.unlock()

        if let dataSource = self.dataSource {
            dataSource.zNSTextAttachment(self, loadImageURL: imageURL, completion: { [weak self] data, mimeType in
                guard let self = self else { return }
                self.dataDownloaded(data, mimeType: mimeType)
                self.finishLoading()
            })
            return
        }

        if let decoded = Self.decodeBase64DataURL(imageURL) {
            dataDownloaded(decoded.data, mimeType: decoded.mime)
            finishLoading()
            return
        }

        let task = urlSession.dataTask(with: imageURL) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    self.finishLoading()
                    return
                }
                self.notifyFailure(error)
                self.finishLoading()
                return
            }

            guard let data = data else {
                self.notifyFailure(NSError(domain: NSURLErrorDomain, code: NSURLErrorZeroByteResource, userInfo: nil))
                self.finishLoading()
                return
            }

            self.dataDownloaded(data, mimeType: response?.mimeType)
            self.finishLoading()
        }

        stateLock.lock()
        urlSessionDataTask = task
        stateLock.unlock()
        task.resume()
    }

    /// Backward-compatible alias for `startDownload()`. Kept to preserve the
    /// original (typo'd) public symbol.
    @available(*, deprecated, renamed: "startDownload()")
    public func startDownlaod() {
        startDownload()
    }

    /// Cancel the in-flight `URLSession` request, if any. Safe to call when no
    /// request is active.
    public func cancel() {
        stateLock.lock()
        urlSessionDataTask?.cancel()
        urlSessionDataTask = nil
        isLoading = false
        stateLock.unlock()
    }

    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        if let image = self.image {
            return CGRect(origin: origin ?? .zero, size: image.size)
        }
        return .zero
    }

    private func finishLoading() {
        stateLock.lock()
        isLoading = false
        urlSessionDataTask = nil
        stateLock.unlock()
    }

    private func notifyFailure(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.zNSTextAttachment(self, didFailWith: error)
        }
    }

    static func decodeBase64DataURL(_ url: URL) -> (data: Data, mime: String)? {
        let absolute = url.absoluteString
        guard let regex = try? NSRegularExpression(pattern: #"^data:image/(jpeg|jpg|png);base64,\s*(([A-Za-z0-9+/]*={0,2})+)$"#),
              let match = regex.firstMatch(in: absolute, options: [], range: NSRange(location: 0, length: absolute.utf16.count)),
              match.range(at: 1).location != NSNotFound,
              match.range(at: 2).location != NSNotFound,
              let typeRange = Range(match.range(at: 1), in: absolute),
              let base64Range = Range(match.range(at: 2), in: absolute),
              let data = Data(base64Encoded: String(absolute[base64Range]), options: .ignoreUnknownCharacters) else {
            return nil
        }
        return (data, "image/" + String(absolute[typeRange]))
    }

    func dataDownloaded(_ data: Data, mimeType: String?) {
        let fileType: String
        let pathExtension = self.imageURL.pathExtension
        #if canImport(UIKit)
        if #available(iOS 14.0, *) {
            if let mimeType = mimeType, let utType = UTType(mimeType: mimeType) {
                fileType = utType.identifier
            } else if let utType = UTType(filenameExtension: pathExtension) {
                fileType = utType.identifier
            } else {
                fileType = "public.\(pathExtension)"
            }
        } else {
            if let mimeType = mimeType, let utTypeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() as? String {
                fileType = utTypeIdentifier
            } else if let utTypeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() as? String {
                fileType = utTypeIdentifier
            } else {
                fileType = "public.\(pathExtension)"
            }
        }
        let image = UIImage(data: data)
        #elseif canImport(AppKit)
        if #available(macOS 11.0, *) {
            if let mimeType = mimeType, let utType = UTType(mimeType: mimeType) {
                fileType = utType.identifier
            } else if let utType = UTType(filenameExtension: pathExtension) {
                fileType = utType.identifier
            } else {
                fileType = "public.\(pathExtension)"
            }
        } else {
            if let mimeType = mimeType, let utTypeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, mimeType as CFString, nil)?.takeRetainedValue() as? String {
                fileType = utTypeIdentifier
            } else if let utTypeIdentifier = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue() as? String {
                fileType = utTypeIdentifier
            } else {
                fileType = "public.\(pathExtension)"
            }
        }
        let image = NSImage(data: data)
        #endif

        stateLock.lock()
        sources.removeAll { $0.value == nil }
        let snapshot = sources.compactMap { $0.value }
        stateLock.unlock()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let loaded = ZResizableNSTextAttachment(imageSize: image?.size, fixedWidth: self.imageWidth, fixedHeight: self.imageHeight, data: data, type: fileType)
            snapshot.forEach { $0.replace(attachment: self, to: loaded) }
            self.delegate?.zNSTextAttachment(didLoad: self, to: loaded)
        }
    }
}

#if canImport(UIKit)
extension ZNSTextAttachment {
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        if let textStorage = textContainer?.layoutManager?.textStorage {
            register(textStorage)
        }
        startDownload()
        return self.image
    }
}
#elseif canImport(AppKit)
extension ZNSTextAttachment {
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> NSImage? {
        if let textStorage = textContainer?.layoutManager?.textStorage {
            register(textStorage)
        }
        startDownload()
        return self.image
    }
}
#endif
