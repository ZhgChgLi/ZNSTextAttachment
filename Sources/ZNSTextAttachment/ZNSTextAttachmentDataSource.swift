//
//  ZNSTextAttachmentDataSource.swift
//  
//
//  Created by zhgchgli on 2023/3/5.
//

import Foundation

public protocol ZNSTextAttachmentDataSource: AnyObject {
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data) -> Void)
}
