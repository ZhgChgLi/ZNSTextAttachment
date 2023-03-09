//
//  ZNSTextAttachmentDelegate.swift
//  
//
//  Created by zhgchgli on 2023/3/5.
//

import Foundation

public protocol ZNSTextAttachmentDelegate: AnyObject {
    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment, to: ZResizableNSTextAttachment)
}
