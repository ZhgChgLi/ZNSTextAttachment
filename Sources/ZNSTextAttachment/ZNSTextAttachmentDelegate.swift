//
//  ZNSTextAttachmentDelegate.swift
//
//
//  Created by zhgchgli on 2023/3/5.
//

import Foundation

/// Receives load lifecycle callbacks for a `ZNSTextAttachment`. Methods are
/// invoked on the main thread.
public protocol ZNSTextAttachmentDelegate: AnyObject {
    /// Called once the remote (or `data:`) image has been downloaded and a
    /// resized replacement attachment has been swapped into the registered
    /// targets.
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment, to: ZResizableNSTextAttachment)

    /// Called when downloading fails. Default implementation is a no-op so
    /// existing conformers stay source-compatible.
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, didFailWith error: Error)
}

public extension ZNSTextAttachmentDelegate {
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, didFailWith error: Error) {}
}
