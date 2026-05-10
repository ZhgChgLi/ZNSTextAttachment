import XCTest
@testable import ZNSTextAttachment

final class ZResizableNSTextAttachmentBoundsTests: XCTestCase {

    private let dummyData = Data([0x00])
    private let dummyType = "public.png"

    func testFixedWidthAndHeightUsesBoth() {
        let attachment = ZResizableNSTextAttachment(imageSize: CGSize(width: 800, height: 400), fixedWidth: 100, fixedHeight: 50, data: dummyData, type: dummyType)
        let bounds = attachment.attachmentBounds(for: nil, proposedLineFragment: .zero, glyphPosition: .zero, characterIndex: 0)
        XCTAssertEqual(bounds, CGRect(x: 0, y: 0, width: 100, height: 50))
    }

    func testFixedWidthScalesHeight() {
        let attachment = ZResizableNSTextAttachment(imageSize: CGSize(width: 200, height: 100), fixedWidth: 100, fixedHeight: nil, data: dummyData, type: dummyType)
        let bounds = attachment.attachmentBounds(for: nil, proposedLineFragment: .zero, glyphPosition: .zero, characterIndex: 0)
        XCTAssertEqual(bounds, CGRect(x: 0, y: 0, width: 100, height: 50))
    }

    func testFixedHeightScalesWidth() {
        let attachment = ZResizableNSTextAttachment(imageSize: CGSize(width: 200, height: 100), fixedWidth: nil, fixedHeight: 50, data: dummyData, type: dummyType)
        let bounds = attachment.attachmentBounds(for: nil, proposedLineFragment: .zero, glyphPosition: .zero, characterIndex: 0)
        XCTAssertEqual(bounds, CGRect(x: 0, y: 0, width: 100, height: 50))
    }

    func testNoFixedSizeFitsLineFragmentWidth() {
        let attachment = ZResizableNSTextAttachment(imageSize: CGSize(width: 400, height: 200), fixedWidth: nil, fixedHeight: nil, data: dummyData, type: dummyType)
        let lineFrag = CGRect(x: 0, y: 0, width: 200, height: 999)
        let bounds = attachment.attachmentBounds(for: nil, proposedLineFragment: lineFrag, glyphPosition: .zero, characterIndex: 0)
        XCTAssertEqual(bounds, CGRect(x: 0, y: 0, width: 200, height: 100))
    }

    func testMissingImageSizeReturnsZero() {
        let attachment = ZResizableNSTextAttachment(imageSize: nil, fixedWidth: nil, fixedHeight: nil, data: dummyData, type: dummyType)
        let bounds = attachment.attachmentBounds(for: nil, proposedLineFragment: .zero, glyphPosition: .zero, characterIndex: 0)
        XCTAssertEqual(bounds, .zero)
    }
}
