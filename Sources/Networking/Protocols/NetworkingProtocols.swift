import Foundation

typealias DataProviding = @Sendable (URLRequest) async throws -> (Data, URLResponse)
public typealias RequestMapping = @Sendable (any Request) throws(NetworkError) -> URLRequest
public typealias ResponseHandling = @Sendable (HTTPURLResponse, Data) -> Void
