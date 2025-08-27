//
//  NSTextStorage+Extension.swift
//  
//
//  Created by zhgchgli on 2023/3/9.
//

import Foundation
import UIKit
import MobileCoreServices

extension NSTextStorage: ZNSTextAttachmentable {
    public func replace(attachment: ZNSTextAttachmentCore, to: ZResizableNSTextAttachment) {
        let attributedString = self
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
        let range = NSRange(location: 0, length: mutableAttributedString.string.utf16.count)
        mutableAttributedString.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (value, effectiveRange, nil) in
            guard (value as? ZNSTextAttachmentCore) == attachment else {
                return
            }
            mutableAttributedString.deleteCharacters(in: effectiveRange)
            mutableAttributedString.insert(NSAttributedString(attachment: to), at: effectiveRange.location)
        }
        self.setAttributedString(mutableAttributedString)
    }
}
