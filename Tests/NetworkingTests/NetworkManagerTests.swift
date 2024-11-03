import Foundation
import Testing

@testable import Networking

struct NetworkingTests {
    @Test
    func response() async throws {
        let request = MockRequest<MockResponse>(
            parameters: ["query": "keyword"]
        )
        let networkManager = NetworkManager(
            requestMapper: { request throws(NetworkError) in
                guard let request = request as? MockRequest<MockResponse>,
                      let url = URL(string: "https://www.test.com.au")
                else {
                    throw NetworkError.internalFailure
                }
                #expect(request.parameters == ["query": "keyword"])
                return .init(url: url)
            },
            dataProvider: { request in
                #expect(request.url?.absoluteString == "https://www.test.com.au")
                let data = try JSONEncoder().encode(MockResponse(identifier: "123"))
                let response = try HTTPURLResponse(
                    url: #require(.init(string: "https://www.test.com")),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )
                let httpResponse = try #require(response)
                return (data, httpResponse)
            }
        )
        let response = try await networkManager.response(for: request)
        #expect(response.identifier == "123")
    }

    @Test
    func invalidURL() async throws {
        let networkManager = NetworkManager(
            requestMapper: { _ throws(NetworkError) in
                throw NetworkError.invalidURL
            },
            dataProvider: { _ in
                throw NetworkError.internalFailure
            }
        )
        await #expect(
            throws: NetworkError.invalidURL,
            performing: {
                _ = try await networkManager.response(for: MockRequest<MockResponse>())
            }
        )
    }

    @Test
    func dataProviderFailure() async throws {
        let networkManager = NetworkManager(
            requestMapper: { _ throws(NetworkError) in
                guard let url = URL(string: "https://www.test.com.au") else {
                    throw NetworkError.internalFailure
                }
                return .init(url: url)
            },
            dataProvider: { _ in
                throw NSError(domain: "domain", code: 500)
            }
        )
        await #expect(
            throws: NetworkError.internalFailure,
            performing: {
                _ = try await networkManager.response(for: MockRequest<MockResponse>())
            }
        )
    }

    @Test
    func invalidResponseFailure() async throws {
        let networkManager = NetworkManager(
            requestMapper: { _ throws(NetworkError) in
                guard let url = URL(string: "https://www.test.com.au") else {
                    throw NetworkError.invalidURL
                }
                return .init(url: url)
            },
            dataProvider: { _ in
                let data = try JSONEncoder().encode(MockResponse(identifier: "123"))
                return (data, URLResponse())
            }
        )
        await #expect(
            throws: NetworkError.internalFailure,
            performing: {
                _ = try await networkManager.response(for: MockRequest<MockResponse>())
            }
        )
    }

    @Test
    func statusCodeFailure() async throws {
        let networkManager = NetworkManager(
            requestMapper: { _ throws(NetworkError) in
                guard let url = URL(string: "https://www.test.com.au") else {
                    throw NetworkError.internalFailure
                }
                return .init(url: url)
            },
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
            }
        )
        await #expect(
            throws: NetworkError.statusCode(500),
            performing: {
                _ = try await networkManager.response(for: MockRequest<MockResponse>())
            }
        )
    }

    @Test
    func decodingFailure() async throws {
        let networkManager = NetworkManager(
            requestMapper: { _ throws(NetworkError) in
                guard let url = URL(string: "https://www.test.com.au") else {
                    throw NetworkError.internalFailure
                }
                return .init(url: url)
            },
            dataProvider: { _ in
                let response = try HTTPURLResponse(
                    url: #require(.init(string: "https://www.test.com")),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )
                let httpResponse = try #require(response)
                return (Data(), httpResponse)
            }
        )
        await #expect(
            throws: NetworkError.decoding,
            performing: {
                _ = try await networkManager.response(for: MockRequest<MockResponse>())
            }
        )
    }
}
