//
//  NSTextStorage+Extension.swift
//
//
//  Created by zhgchgli on 2023/3/9.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension NSTextStorage: ZNSTextAttachmentable {
    public func replace(attachment: ZNSTextAttachment, to: ZResizableNSTextAttachment) {
        let replaced = AttachmentReplacer.replacing(self, from: attachment, to: to)
        self.setAttributedString(replaced)
    }
}
