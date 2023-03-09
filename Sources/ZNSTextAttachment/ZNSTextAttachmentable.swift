//
//  ZNSTextAttachmentable.swift
//  
//
//  Created by zhgchgli on 2023/3/9.
//

import Foundation

public protocol ZNSTextAttachmentable: AnyObject {
    func replace(attachment: ZNSTextAttachment, to: ZResizableNSTextAttachment)
}
