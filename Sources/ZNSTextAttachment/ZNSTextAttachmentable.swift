//
//  ZNSTextAttachmentable.swift
//
//
//  Created by zhgchgli on 2023/3/9.
//

import Foundation

/// A target (e.g. an `NSTextStorage` or `UILabel`) that knows how to swap an
/// in-flight `ZNSTextAttachment` for its loaded `ZResizableNSTextAttachment`.
/// Conformers are referenced weakly by the attachment.
public protocol ZNSTextAttachmentable: AnyObject {
    func replace(attachment: ZNSTextAttachment, to: ZResizableNSTextAttachment)
}
