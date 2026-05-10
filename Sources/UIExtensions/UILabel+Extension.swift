//
//  UILabel+Extension.swift
//
//
//  Created by zhgchgli on 2023/3/9.
//

import Foundation
#if canImport(UIKit)
import UIKit

extension UILabel: ZNSTextAttachmentable {
    public func replace(attachment: ZNSTextAttachment, to: ZResizableNSTextAttachment) {
        guard let attributedString = attributedText else { return }
        let replaced = AttachmentReplacer.replacing(attributedString, from: attachment, to: to)
        self.attributedText = replaced
    }
}
#endif
