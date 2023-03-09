//
//  UILabel+Extenstion.swift
//  
//
//  Created by zhgchgli on 2023/3/9.
//

import Foundation
#if canImport(UIKit)
import UIKit

extension UILabel: ZNSTextAttachmentable {
    public func replace(attachment: ZNSTextAttachment, to: ZResizableNSTextAttachment) {
        guard let attributedString = attributedText else {
            return
        }
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let range = NSRange(location: 0, length: mutableAttributedString.string.utf16.count)
        mutableAttributedString.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (value, effectiveRange, nil) in
            guard (value as? ZNSTextAttachment) == attachment else {
                return
            }
            mutableAttributedString.deleteCharacters(in: effectiveRange)
            mutableAttributedString.insert(NSAttributedString(attachment: to), at: effectiveRange.location)
        }
        self.attributedText = mutableAttributedString
    }
}
#endif
