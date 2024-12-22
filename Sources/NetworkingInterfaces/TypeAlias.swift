import Foundation

public typealias RequestMapping = @Sendable (any Request) throws(NetworkError) -> URLRequest
public typealias ResponseHandling = @Sendable (HTTPURLResponse, Data) -> Void
