//
//  ZResizableNSTextAttachment.swift
//  
//
//  Created by zhgchgli on 2023/3/5.
//

import Foundation

#if canImport(AppKit)
import AppKit

public class ZResizableNSTextAttachment: NSTextAttachment {
    
    public let imageSize: CGSize?
    public let fixedWidth: CGFloat?
    public let fixedHeight: CGFloat?
    
    public init(imageSize: CGSize?, fixedWidth: CGFloat?, fixedHeight: CGFloat?, data: Data, type: String) {
        self.imageSize = imageSize
        self.fixedWidth = fixedWidth
        self.fixedHeight = fixedHeight
        
        super.init(data: data, ofType: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        
        if let fixedWidth = self.fixedWidth,
           let fixedHeight = self.fixedHeight {
            return CGRect(origin: .zero, size: CGSize(width: fixedWidth, height: fixedHeight))
        }
        
        guard let imageWidth = imageSize?.width,
              let imageHeight = imageSize?.height else {
            return .zero
        }
        
        if let fixedWidth = self.fixedWidth {
            let factor = fixedWidth / imageWidth
            return CGRect(origin: .zero, size:CGSize(width: Int(fixedWidth), height: Int(imageHeight * factor)))
        } else if let fixedHeight = self.fixedHeight {
            let factor = fixedHeight / imageHeight
            return CGRect(origin: .zero, size:CGSize(width: Int(imageWidth * factor), height: Int(fixedHeight)))
        } else {
            let maxWidth = lineFrag.size.width - ((textContainer?.lineFragmentPadding ?? 0) * 2)
            let factor = maxWidth / imageWidth
            
            return CGRect(origin: .zero, size:CGSize(width: Int(imageWidth * factor), height: Int(imageHeight * factor)))
        }
    }
}
#endif
