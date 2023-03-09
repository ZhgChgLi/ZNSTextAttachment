//
//  TestData.swift
//  ZNSTextAttachment-Demo
//
//  Created by https://zhgchg.li on 2023/3/5.
//

import Foundation
import ZNSTextAttachment

struct TestData {
    static func generate(with attachment: ZNSTextAttachment) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        attributedString.append(NSAttributedString(string: "ZMarkupParser is a pure-Swift library that helps you to convert HTML strings to NSAttributedString with customized style and tags.\n"))
        attributedString.append(NSAttributedString(string: "-  Parse HTML strings using pure-Swift and regular expressions.\n"))
        
        attributedString.append(NSAttributedString(attachment: attachment))
        
        attributedString.append(NSAttributedString(string: "ZMarkupParser is a pure-Swift library that helps you to convert HTML strings to NSAttributedString with customized style and tags.\n"))
        attributedString.append(NSAttributedString(string: "-  Parse HTML strings using pure-Swift and regular expressions.\n"))
        
        attributedString.append(NSAttributedString(attachment: attachment))
        
        attributedString.append(NSAttributedString(string: "ZMarkupParser is a pure-Swift library that helps you to convert HTML strings to NSAttributedString with customized style and tags.\n"))
        attributedString.append(NSAttributedString(string: "-  Parse HTML strings using pure-Swift and regular expressions.\n"))
        
        return attributedString
    }
}
