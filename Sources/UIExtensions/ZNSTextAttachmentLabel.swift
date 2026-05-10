//
//  ZNSTextAttachmentLabel.swift
//
//
//  Created by https://zhgchg.li on 2023/3/5.
//

import Foundation
#if canImport(UIKit)
import UIKit

/// `UILabel` subclass that automatically registers itself with every
/// `ZNSTextAttachment` it encounters when its `attributedText` is assigned —
/// no manual `attachment.register(label)` call required.
public class ZNSTextAttachmentLabel: UILabel {
    public override var attributedText: NSAttributedString? {
        didSet {
            attributedText?.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attributedText?.length ?? 0), options: []) { value, _, _ in
                guard let attachment = value as? ZNSTextAttachment else { return }
                attachment.register(self)
            }
        }
    }
}
#endif
