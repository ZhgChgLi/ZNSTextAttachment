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
        attributedString.append(NSAttributedString(string: "- 使用純 Swift 開發，透過 Regex 剖析出 HTML Tag 並經過 Tokenization，分析修正 Tag 正確性(修正沒有 end 的 tag & 錯位 tag)，再轉換成 abstract syntax tree，最終使用 Visitor Pattern 將 HTML Tag 與抽象樣式對應，得到最終 NSAttributedString 結果；其中不依賴任何 Parser Lib。\n"))
        attributedString.append(NSAttributedString(string: "- 支援 HTML Render (to NSAttributedString) / Stripper (剝離 HTML Tag) / Selector 功能\n"))
        
        attributedString.append(NSAttributedString(attachment: attachment))
        
        attributedString.append(NSAttributedString(string: "- 自動分析修正 Tag 正確性(修正沒有 end 的 tag & 錯位 tag) <br> -> <br/> <b>Bold<i>Bold+Italic</b>Italic</i> -> <b>Bold<i>Bold+Italic</i></b><i>Italic</i> <Congratulation!> -> <Congratulation!> (treat as String)\n"))
        attributedString.append(NSAttributedString(string: "- 支援客製化樣式指定 e.g. <b></b> -> weight: .semilbold & underline: 1\n"))
        
        return attributedString
    }
}
