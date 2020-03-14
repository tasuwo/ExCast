//
//  Copyright © 2020 Tasuku Tozawa. All rights reserved.
//

import Foundation

class URLProtocolMock: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    // MARK: - URLProtocol (overrides)

    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = type(of: self).handler else {
            fatalError("URLProtocolMock handler is unavailable.")
        }

        do {
            let (response, data) = try handler(self.request)

            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }

            self.client?.urlProtocolDidFinishLoading(self)
        } catch {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
