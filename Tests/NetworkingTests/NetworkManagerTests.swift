@testable import Networking
import Foundation
import NetworkingInterfaces
import Testing

struct NetworkingTests {
    @Test
    func response() async throws {
        let request = MockRequest(
            parameters: ["query": "keyword"]
        )
        let expectedData = try JSONEncoder().encode(MockResponse(identifier: "123"))
        let url = try #require(URL(string: "https://www.test.com.au"))
        let expectedResponse = try #require(
            HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
        )
        let networkManager = NetworkManager(
            dataProvider: { request in
                #expect(request.url == url)
                return (expectedData, expectedResponse)
            },
            requestMapper: { request throws(NetworkError) in
                guard let request = request as? MockRequest,
                      let url = URL(string: "https://www.test.com.au")
                else {
                    throw NetworkError.internalFailure
                }
                #expect(request.parameters == ["query": "keyword"])
                return .init(url: url)
            },
            responseHandler: { (response, data) in
                #expect(response == expectedResponse)
                #expect(data == expectedData)
            }
        )
        let response: MockResponse = try await networkManager.response(for: request)
        #expect(response.identifier == "123")
    }

    @Test
    func invalidURL() async throws {
        let networkManager = NetworkManager(
            dataProvider: { _ in
                throw NetworkError.internalFailure
            },
            requestMapper: { _ throws(NetworkError) in
                throw NetworkError.invalidURL
            }
        )
        await #expect(
            throws: NetworkError.invalidURL,
            performing: {
                let _: MockResponse = try await networkManager.response(for: MockRequest())
            }
        )
    }

    @Test
    func dataProviderFailure() async throws {
        let networkManager = NetworkManager(
            dataProvider: { _ in
                throw NSError(domain: "domain", code: 500)
            },
            requestMapper: { _ throws(NetworkError) in
                guard let url = URL(string: "https://www.test.com.au") else {
                    throw NetworkError.internalFailure
                }
                return .init(url: url)
            }
        )
        await #expect(
            throws: NetworkError.internalFailure,
            performing: {
                let _: MockResponse = try await networkManager.response(for: MockRequest())
            }
        )
    }

    @Test
    func invalidResponseFailure() async throws {
        let networkManager = NetworkManager(
            dataProvider: { _ in
                let data = try JSONEncoder().encode(MockResponse(identifier: "123"))
                return (data, URLResponse())
            },
            requestMapper: { _ throws(NetworkError) in
                guard let url = URL(string: "https://www.test.com.au") else {
                    throw NetworkError.invalidURL
                }
                return .init(url: url)
            }
        )
        await #expect(
            throws: NetworkError.internalFailure,
            performing: {
                let _: MockResponse = try await networkManager.response(for: MockRequest())
            }
        )
    }

    @Test
    func statusCodeFailure() async throws {
        let networkManager = NetworkManager(
            dataProvider: { request in
                #expect(request.url?.absoluteString == "https://www.test.com.au")
                let data = try JSONEncoder().encode(MockResponse(identifier: "123"))
                let response = try HTTPURLResponse(
                    url: #require(.init(string: "https://www.test.com")),
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )
                let httpResponse = try #require(response)
                return (data, httpResponse)
            },
            requestMapper: { _ throws(NetworkError) in
                guard let url = URL(string: "https://www.test.com.au") else {
                    throw NetworkError.internalFailure
                }
                return .init(url: url)
            }
        )
        await #expect(
            throws: NetworkError.statusCode(500),
            performing: {
                let _: MockResponse = try await networkManager.response(for: MockRequest())
            }
        )
    }

    @Test
    func decodingFailure() async throws {
        let networkManager = NetworkManager(
            dataProvider: { _ in
                let response = try HTTPURLResponse(
                    url: #require(.init(string: "https://www.test.com")),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )
                let httpResponse = try #require(response)
                return (Data(), httpResponse)
            },
            requestMapper: { _ throws(NetworkError) in
                guard let url = URL(string: "https://www.test.com.au") else {
                    throw NetworkError.internalFailure
                }
                return .init(url: url)
            }
        )
        await #expect(
            throws: NetworkError.decoding,
            performing: {
                let _: MockResponse = try await networkManager.response(for: MockRequest())
            }
        )
    }
}
