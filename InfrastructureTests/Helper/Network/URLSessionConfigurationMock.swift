//
//  Copyright © 2020 Tasuku Tozawa. All rights reserved.
//

import Foundation

class URLSessionMock {
    static var mock: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [URLProtocolMock.self]
        return URLSession(configuration: configuration)
    }
}
