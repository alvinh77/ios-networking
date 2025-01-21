import Networking
import NetworkingInterfaces

public struct MockRequest: Request {
    public let baseURL: String
    public let path: String
    public let method: Method
    public let headers: [HeaderField]?
    public let parameters: [String: String]?
    public let body: [String: Sendable]?

    public init(
        baseURL: String = "https://www.test.com",
        path: String = "/mock",
        method: Method = .get,
        headers: [HeaderField]? = nil,
        parameters: [String: String]? = nil,
        body: [String: Sendable]? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.parameters = parameters
        self.body = body
    }
}

public struct MockResponse: Codable, Sendable {
    public let identifier: String

    public init(identifier: String) {
        self.identifier = identifier
    }
}
