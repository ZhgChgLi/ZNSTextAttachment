//
//  AttachmentReplacer.swift
//
//
//  Internal helper shared by NSTextStorage / UILabel extensions.
//

import Foundation

enum AttachmentReplacer {
    /// Build a new attributed string in which every occurrence of `old` is
    /// replaced by an attachment-attributed string wrapping `new`. Ranges are
    /// applied in reverse order so earlier replacements don't shift later
    /// ones.
    static func replacing(_ source: NSAttributedString, from old: ZNSTextAttachment, to new: ZResizableNSTextAttachment) -> NSAttributedString {
        let mutable = NSMutableAttributedString(attributedString: source)
        let fullRange = NSRange(location: 0, length: mutable.length)
        var matches: [NSRange] = []
        mutable.enumerateAttribute(.attachment, in: fullRange, options: []) { value, range, _ in
            guard (value as? ZNSTextAttachment) === old else { return }
            matches.append(range)
        }
        for range in matches.reversed() {
            mutable.deleteCharacters(in: range)
            mutable.insert(NSAttributedString(attachment: new), at: range.location)
        }
        return mutable
    }
}
