//
//  ZNSTextAttachmentForMacOS.swift
//  
//
//  Created by zhgchgli on 2023/3/5.
//

import Foundation
#if canImport(AppKit)
import AppKit
import UniformTypeIdentifiers

public protocol ZNSTextAttachmentDataSource: AnyObject {
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachmentPlaceholder, loadImageURL imageURL: URL, completion: @escaping (Data) -> Void)
}

public protocol ZNSTextAttachmentDelegate: AnyObject {
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachmentPlaceholder)
}

public class ZNSTextAttachment: NSTextAttachment {
    
    public let imageSize: CGSize?

    public init(imageSize: CGSize?, data: Data, type: String) {
        self.imageSize = imageSize
        
        super.init(data: data, ofType: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        guard let imageWidth = imageSize?.width,
              let imageHeight = imageSize?.height else {
            return .zero
        }
        
        let maxWidth = lineFrag.size.width - ((textContainer?.lineFragmentPadding ?? 0) * 2)
        let factor = maxWidth / imageWidth
        
        return CGRect(origin: CGPoint.zero, size:CGSize(width: Int(imageWidth * factor), height: Int(imageHeight * factor)))
    }
}

public class ZNSTextAttachmentPlaceholder: NSTextAttachment {

    public let imageURL: URL
    public weak var delegate: ZNSTextAttachmentDelegate?
    public weak var dataSource: ZNSTextAttachmentDataSource?
    
    private let origin: CGPoint?
    
    private var isLoading: Bool = false
    private var textStorages: [WeakNSTextStorage] = []
    
    public init(imageURL: URL, placeholderImage: NSImage? = nil, placeholderImageOrigin: CGPoint? = nil) {
        self.imageURL = imageURL
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
        
        dataSource?.zNSTextAttachment(self, loadImageURL: imageURL, completion: { data in
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
                        value.textStorage?.insert(NSAttributedString(attachment: ZNSTextAttachment(imageSize: image?.size, data: data, type: fileType)), at: range.location)
                    })
                }
                self.delegate?.zNSTextAttachment(didLoad: self)
            }

            self.isLoading = false
        })
        
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
}

private extension ZNSTextAttachmentPlaceholder {
    class WeakNSTextStorage {
        
        weak var textStorage: NSTextStorage?
        
        init(_ textStorage: NSTextStorage?) {
            self.textStorage = textStorage
        }
        
        func rangesForAttachment(attachment: ZNSTextAttachmentPlaceholder) -> [NSRange]? {
            guard let attributedString = textStorage else {
                return nil
            }
            let range = NSRange(location: 0, length: attributedString.string.utf16.count)
            
            var ranges = [NSRange]()
            attributedString.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (value, effectiveRange, nil) in
                guard (value as? ZNSTextAttachmentPlaceholder) == attachment else {
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
