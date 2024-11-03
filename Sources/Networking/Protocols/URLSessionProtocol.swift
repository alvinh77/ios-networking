import Foundation

public typealias DataProviding = @Sendable (URLRequest) async throws -> (Data, URLResponse)

public typealias RequestMapping = @Sendable (any Request) throws(NetworkError) -> URLRequest

public typealias ResponseHandling = @Sendable (HTTPURLResponse, Data) -> Void

public protocol URLSessionProtocol: Sendable {
    func data(for: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
