import XCTest
@testable import ZNSTextAttachment

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private final class ImmediateDataSource: ZNSTextAttachmentDataSource {
    let payload: Data
    let mime: String?
    private(set) var callCount = 0

    init(payload: Data, mime: String?) {
        self.payload = payload
        self.mime = mime
    }

    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data, ZNSTextAttachmentDownloadedDataMIMEType?) -> Void) {
        callCount += 1
        completion(payload, mime)
    }
}

private final class DeferredDataSource: ZNSTextAttachmentDataSource {
    let payload: Data
    let mime: String?
    private(set) var callCount = 0
    private var pending: [() -> Void] = []

    init(payload: Data, mime: String?) {
        self.payload = payload
        self.mime = mime
    }

    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, loadImageURL imageURL: URL, completion: @escaping (Data, ZNSTextAttachmentDownloadedDataMIMEType?) -> Void) {
        callCount += 1
        let payload = self.payload
        let mime = self.mime
        pending.append { completion(payload, mime) }
    }

    func deliverAll() {
        let toDeliver = pending
        pending.removeAll()
        toDeliver.forEach { $0() }
    }
}

private final class RecordingDelegate: ZNSTextAttachmentDelegate {
    var didLoadCount = 0
    var didFailCount = 0
    var lastError: Error?
    var loadExpectation: XCTestExpectation?
    var failExpectation: XCTestExpectation?

    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment, to: ZResizableNSTextAttachment) {
        didLoadCount += 1
        loadExpectation?.fulfill()
    }

    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, didFailWith error: Error) {
        didFailCount += 1
        lastError = error
        failExpectation?.fulfill()
    }
}

final class RegisterAndReplaceTests: XCTestCase {

    private static let onePixelPNG = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkAAIAAAoAAv/lxKUAAAAASUVORK5CYII=")!

    func testReplaceSwapsAttachmentInTextStorage() {
        let attachment = ZNSTextAttachment(imageURL: URL(string: "https://example.com/x.png")!)
        let dataSource = ImmediateDataSource(payload: Self.onePixelPNG, mime: "image/png")
        attachment.dataSource = dataSource

        let delegate = RecordingDelegate()
        let exp = expectation(description: "didLoad fires")
        delegate.loadExpectation = exp
        attachment.delegate = delegate

        let storage = NSTextStorage(attributedString: NSAttributedString(attachment: attachment))
        attachment.register(storage)
        attachment.startDownload()

        wait(for: [exp], timeout: 2.0)

        XCTAssertEqual(delegate.didLoadCount, 1)
        XCTAssertEqual(dataSource.callCount, 1)

        var foundResizable = false
        storage.enumerateAttribute(.attachment, in: NSRange(location: 0, length: storage.length), options: []) { value, _, _ in
            if value is ZResizableNSTextAttachment { foundResizable = true }
            XCTAssertFalse(value is ZNSTextAttachment && !(value is ZResizableNSTextAttachment),
                           "Original ZNSTextAttachment should have been removed")
        }
        XCTAssertTrue(foundResizable)
    }

    func testRegisterDeduplicatesSameSource() {
        let attachment = ZNSTextAttachment(imageURL: URL(string: "https://example.com/x.png")!)
        let dataSource = ImmediateDataSource(payload: Self.onePixelPNG, mime: "image/png")
        attachment.dataSource = dataSource

        let delegate = RecordingDelegate()
        let exp = expectation(description: "didLoad fires once")
        delegate.loadExpectation = exp
        attachment.delegate = delegate

        let storage = NSTextStorage(attributedString: NSAttributedString(attachment: attachment))
        attachment.register(storage)
        attachment.register(storage)
        attachment.register(storage)
        attachment.startDownload()

        wait(for: [exp], timeout: 2.0)

        var resizableCount = 0
        storage.enumerateAttribute(.attachment, in: NSRange(location: 0, length: storage.length), options: []) { value, _, _ in
            if value is ZResizableNSTextAttachment { resizableCount += 1 }
        }
        XCTAssertEqual(resizableCount, 1, "register dedup should result in exactly one swapped attachment")
    }

    func testStartDownloadIsIdempotentWhileLoading() {
        let attachment = ZNSTextAttachment(imageURL: URL(string: "https://example.com/x.png")!)
        let dataSource = DeferredDataSource(payload: Self.onePixelPNG, mime: "image/png")
        attachment.dataSource = dataSource

        let delegate = RecordingDelegate()
        let exp = expectation(description: "didLoad fires once")
        delegate.loadExpectation = exp
        attachment.delegate = delegate

        let storage = NSTextStorage(attributedString: NSAttributedString(attachment: attachment))
        attachment.register(storage)

        attachment.startDownload()
        attachment.startDownload()
        attachment.startDownload()
        XCTAssertEqual(dataSource.callCount, 1, "subsequent calls while loading must be no-ops")

        dataSource.deliverAll()

        wait(for: [exp], timeout: 2.0)
        XCTAssertEqual(delegate.didLoadCount, 1)
    }
}
