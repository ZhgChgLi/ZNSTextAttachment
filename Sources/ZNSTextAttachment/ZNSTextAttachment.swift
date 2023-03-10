
//
//  ZNSTextAttachmentLabel.swift
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

public class ZNSTextAttachment: NSTextAttachment {

    public let imageURL: URL
    public weak var delegate: ZNSTextAttachmentDelegate?
    public weak var dataSource: ZNSTextAttachmentDataSource?
    
    private let origin: CGPoint?
    private let imageWidth: CGFloat?
    private let imageHeight: CGFloat?
    
    private var isLoading: Bool = false
    private var sources: [WeakZNSTextAttachmentable] = []
    private var urlSessionDataTask: URLSessionDataTask?
    
    #if canImport(UIKit)
    public init(imageURL: URL, imageWidth: CGFloat? = nil, imageHeight: CGFloat? = nil, placeholderImage: UIImage? = nil, placeholderImageOrigin: CGPoint? = nil) {
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.origin = placeholderImageOrigin
        
        if let placeholderImageData = placeholderImage?.pngData() {
            super.init(data: placeholderImageData, ofType: "public.png")
        } else {
            super.init(data: nil, ofType: nil)
        }
        
        self.image = placeholderImage
    }
    #elseif canImport(AppKit)
    public init(imageURL: URL, imageWidth: CGFloat? = nil, imageHeight: CGFloat? = nil, placeholderImage: NSImage? = nil, placeholderImageOrigin: CGPoint? = nil) {
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.origin = placeholderImageOrigin
        
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
    
    public func register(_ source: ZNSTextAttachmentable) {
        self.sources.append(WeakZNSTextAttachmentable(source))
    }
    
    public func startDownlaod() {
        guard !isLoading else { return }
        isLoading = true
        
        if let dataSource = self.dataSource {
            dataSource.zNSTextAttachment(self, loadImageURL: imageURL, completion: { data in
                self.dataDownloaded(data)
                self.isLoading = false
            })
        } else {
            let urlSessionDataTask = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                self.dataDownloaded(data)
                self.isLoading = false
                self.urlSessionDataTask = nil
            }
            self.urlSessionDataTask = urlSessionDataTask
            urlSessionDataTask.resume()
        }
    }
    
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        if let image = self.image {
            return CGRect(origin: origin ?? .zero, size: image.size)
        }
        
        return .zero
    }
    
    func dataDownloaded(_ data: Data) {
        let fileType: String
        let pathExtension = self.imageURL.pathExtension
        
        #if canImport(UIKit)
        if #available(iOS 14.0, *) {
            if let utType = UTType(filenameExtension: pathExtension) {
                fileType = utType.identifier
            } else {
                fileType = pathExtension
            }
        } else {
            if let utType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil) {
                fileType = utType.takeRetainedValue() as String
            } else {
                fileType = pathExtension
            }
        }
        let image = UIImage(data: data)
        #elseif canImport(AppKit)
        if #available(macOS 11.0, *) {
            if let utType = UTType(filenameExtension: pathExtension) {
                fileType = utType.identifier
            } else {
                fileType = pathExtension
            }
        } else {
            if let utType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil) {
                fileType = utType.takeRetainedValue() as String
            } else {
                fileType = pathExtension
            }
        }
        let image = NSImage(data: data)
        #endif

        DispatchQueue.main.async {
            let loaded = ZResizableNSTextAttachment(imageSize: image?.size, fixedWidth: self.imageWidth, fixedHeight: self.imageHeight, data: data, type: fileType)
            self.sources.forEach { source in
                source.value?.replace(attachment: self, to: loaded)
            }
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
        
        startDownlaod()
        
        if let image = self.image {
            return image
        }
        
        return nil
    }
}
#elseif canImport(AppKit)
extension ZNSTextAttachment {
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> NSImage? {

        if let textStorage = textContainer?.layoutManager?.textStorage {
            register(textStorage)
        }
        
        startDownlaod()
        
        if let image = self.image {
            return image
        }
        
        return nil
    }
}

#endif
