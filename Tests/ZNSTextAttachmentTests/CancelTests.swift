import XCTest
@testable import ZNSTextAttachment

final class HangingURLProtocol: URLProtocol {
    static var didStart = false
    static var didStop = false

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func startLoading() { HangingURLProtocol.didStart = true }
    override func stopLoading() { HangingURLProtocol.didStop = true }

    static func reset() {
        didStart = false
        didStop = false
    }
}

private final class FailingDelegate: ZNSTextAttachmentDelegate {
    var didLoadCount = 0
    var didFailCount = 0

    func zNSTextAttachment(didLoad textAttachment: ZNSTextAttachment, to: ZResizableNSTextAttachment) {
        didLoadCount += 1
    }

    func zNSTextAttachment(_ textAttachment: ZNSTextAttachment, didFailWith error: Error) {
        didFailCount += 1
    }
}

final class CancelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        HangingURLProtocol.reset()
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [HangingURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    func testCancelStopsLoadingTask() {
        let session = makeSession()
        let attachment = ZNSTextAttachment(imageURL: URL(string: "https://example.invalid/foo.png")!, urlSession: session)
        let delegate = FailingDelegate()
        attachment.delegate = delegate

        attachment.startDownload()

        let started = expectation(description: "URLProtocol startLoading fires")
        DispatchQueue.global().async {
            while !HangingURLProtocol.didStart { Thread.sleep(forTimeInterval: 0.01) }
            started.fulfill()
        }
        wait(for: [started], timeout: 2.0)

        attachment.cancel()

        let waited = expectation(description: "wait for any late delegate calls")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { waited.fulfill() }
        wait(for: [waited], timeout: 1.0)

        XCTAssertTrue(HangingURLProtocol.didStop, "cancel() should stop the URLSession task")
        XCTAssertEqual(delegate.didLoadCount, 0, "cancellation should not trigger didLoad")
        XCTAssertEqual(delegate.didFailCount, 0, "cancellation should not be reported as failure")
    }
}
