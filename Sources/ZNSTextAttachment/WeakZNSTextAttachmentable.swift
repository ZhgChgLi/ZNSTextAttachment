//
//  WeakZNSTextAttachmentable.swift
//  
//
//  Created by zhgchgli on 2023/3/9.
//

import Foundation

class WeakZNSTextAttachmentable {
    
    weak var value: ZNSTextAttachmentable?
    
    init(_ value: ZNSTextAttachmentable?) {
        self.value = value
    }
}
