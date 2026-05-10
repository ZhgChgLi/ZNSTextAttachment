//
//  ZNSTextAttachmentDataSource.swift
//
//
//  Created by zhgchgli on 2023/3/5.
//

import Foundation

/// MIME type string returned alongside downloaded image data.
public typealias ZNSTextAttachmentDownloadedDataMIMEType = String

/// Provides a custom loader for `ZNSTextAttachment`. When a data source is
/// assigned, the attachment skips its built-in `URLSession` path and asks the
/// data source to deliver the bytes for `imageURL`.
public protocol ZNSTextAttachmentDataSource: AnyObject {
    /// Load the image bytes for `imageURL` and call `completion` exactly once.
    /// The completion handler may be invoked on any thread; downstream work is
    /// dispatched to the main thread by the attachment.
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data, ZNSTextAttachmentDownloadedDataMIMEType?) -> Void)
}
