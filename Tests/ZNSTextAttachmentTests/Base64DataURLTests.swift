import XCTest
@testable import ZNSTextAttachment

final class Base64DataURLTests: XCTestCase {

    private let onePixelPNGBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkAAIAAAoAAv/lxKUAAAAASUVORK5CYII="

    func testDecodesPNGDataURL() {
        let url = URL(string: "data:image/png;base64,\(onePixelPNGBase64)")!
        let result = ZNSTextAttachment.decodeBase64DataURL(url)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.mime, "image/png")
        XCTAssertGreaterThan(result?.data.count ?? 0, 0)
    }

    func testDecodesJPEGDataURL() {
        let url = URL(string: "data:image/jpeg;base64,\(onePixelPNGBase64)")!
        let result = ZNSTextAttachment.decodeBase64DataURL(url)
        XCTAssertEqual(result?.mime, "image/jpeg")
    }

    func testRejectsHTTPURL() {
        let url = URL(string: "https://example.com/image.png")!
        XCTAssertNil(ZNSTextAttachment.decodeBase64DataURL(url))
    }

    func testRejectsUnsupportedMIME() {
        let url = URL(string: "data:image/gif;base64,\(onePixelPNGBase64)")!
        XCTAssertNil(ZNSTextAttachment.decodeBase64DataURL(url))
    }

    func testRejectsMalformedBase64() {
        let url = URL(string: "data:image/png;base64,@@@@@@")!
        XCTAssertNil(ZNSTextAttachment.decodeBase64DataURL(url))
    }
}
