public protocol Request: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: String]? { get }
    var method: Method { get }
    var headers: [HeaderField]? { get }
    var body: [String: Sendable]? { get }
}

public enum Method: String, Sendable {
    case delete = "DELETE"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}
