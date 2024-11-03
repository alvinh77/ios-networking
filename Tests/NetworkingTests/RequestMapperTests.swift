import Foundation
import Testing

@testable import Networking

struct RequestMapperTests {
    @Test
    func getMethodRequest() throws {
        let request = MockRequest<MockResponse>(
            headers: [.contentType: "abc"],
            parameters: ["query": "keyword"]
        )
        let urlRequest = try RequestMapper.default.map(request)
        #expect(urlRequest.url?.absoluteString == "https://www.test.com/mock?query=keyword")
        #expect(urlRequest.allHTTPHeaderFields == ["Content-Type": "abc"])
        #expect(urlRequest.httpMethod == "GET")
    }

    @Test
    func postMethodRequest() throws {
        let request = MockRequest<MockResponse>(
            method: .post,
            body: ["body": "value"]
        )
        let urlRequest = try RequestMapper.default.map(request)
        #expect(urlRequest.url?.absoluteString == "https://www.test.com/mock")
        #expect(urlRequest.httpMethod == "POST")
        #expect(try urlRequest.httpBody == JSONEncoder().encode(["body": "value"]))
    }
}
