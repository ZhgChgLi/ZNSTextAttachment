//
//  ZNSTextAttachmentHandler.swift
//
//
//  Created by zhgchgli on 2023/3/5.
//

import Foundation

/// Convenience composition of `ZNSTextAttachmentDataSource` and
/// `ZNSTextAttachmentDelegate` for objects that play both roles.
public typealias ZNSTextAttachmentHandler = (ZNSTextAttachmentDataSource & ZNSTextAttachmentDelegate)
