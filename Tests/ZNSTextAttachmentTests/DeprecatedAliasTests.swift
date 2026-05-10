import XCTest
@testable import ZNSTextAttachment

private final class CountingDataSource: ZNSTextAttachmentDataSource {
    private(set) var callCount = 0
    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data, ZNSTextAttachmentDownloadedDataMIMEType?) -> Void) {
        callCount += 1
    }
}

final class DeprecatedAliasTests: XCTestCase {

    @available(*, deprecated, message: "Intentionally exercises the deprecated alias.")
    func testStartDownlaodAliasDelegatesToStartDownload() {
        let attachment = ZNSTextAttachment(imageURL: URL(string: "https://example.com/x.png")!)
        let dataSource = CountingDataSource()
        attachment.dataSource = dataSource

        attachment.startDownlaod()

        XCTAssertEqual(dataSource.callCount, 1)
    }
}
