
//
//  ZNSTextAttachmentLabel.swift
//
//
//  Created by https://zhgchg.li on 2023/3/5.
//

#if canImport(AppKit)
import AppKit
import UniformTypeIdentifiers

public class ZNSTextAttachment: NSTextAttachment {
    
    public let imageURL: URL
    public weak var delegate: ZNSTextAttachmentDelegate?
    public weak var dataSource: ZNSTextAttachmentDataSource?
    
    private let origin: CGPoint?
    private let imageWidth: CGFloat?
    private let imageHeight: CGFloat?
    
    private var isLoading: Bool = false
    private var textStorages: [WeakNSTextStorage] = []
    private var urlSessionDataTask: URLSessionDataTask?
    
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
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func register(textStorage: NSTextStorage) {
        self.appendToTextStorages(with: textStorage)
    }
    
    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> NSImage? {
        
        if let textStorage = textContainer?.layoutManager?.textStorage {
            appendToTextStorages(with: textStorage)
        }
        
        guard !isLoading else { return image }
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
        
        if let image = self.image {
            return image
        }
        
        return nil
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
        
        DispatchQueue.main.async {
            self.textStorages.forEach { value in
                value.rangesForAttachment(attachment: self)?.forEach({ range in
                    value.textStorage?.deleteCharacters(in: range)
                    value.textStorage?.insert(NSAttributedString(attachment: ZResizableNSTextAttachment(imageSize: image?.size, fixedWidth: self.imageWidth, fixedHeight: self.imageHeight, data: data, type: fileType)), at: range.location)
                })
            }
            self.delegate?.zNSTextAttachment(didLoad: self)
        }
    }
}

private extension ZNSTextAttachment {
    class WeakNSTextStorage {
        
        weak var textStorage: NSTextStorage?
        
        init(_ textStorage: NSTextStorage?) {
            self.textStorage = textStorage
        }
        
        func rangesForAttachment(attachment: ZNSTextAttachment) -> [NSRange]? {
            guard let attributedString = textStorage else {
                return nil
            }
            let range = NSRange(location: 0, length: attributedString.string.utf16.count)
            
            var ranges = [NSRange]()
            attributedString.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (value, effectiveRange, nil) in
                guard (value as? ZNSTextAttachment) == attachment else {
                    return
                }
                ranges.append(effectiveRange)
            }
            
            return (ranges.count == 0) ? (nil) : (ranges)
        }
    }
    
    func appendToTextStorages(with textStorage: NSTextStorage?) {
        guard let textStorage = textStorage else { return }
        if textStorages.contains(where: { value in
            return value.textStorage === textStorage
        }) {
            return
        }
        
        textStorages.append(WeakNSTextStorage(textStorage))
    }
}
#endif
