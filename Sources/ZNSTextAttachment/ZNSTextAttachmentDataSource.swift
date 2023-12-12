//
//  ZNSTextAttachmentDataSource.swift
//  
//
//  Created by zhgchgli on 2023/3/5.
//

import Foundation
public typealias ZNSTextAttachmentDownloadedDataMIMEType = String
public protocol ZNSTextAttachmentDataSource: AnyObject {
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data, ZNSTextAttachmentDownloadedDataMIMEType?) -> Void)
}
