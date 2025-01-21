import Foundation

public protocol Request: Sendable {
    var baseURL: String { get }
    var path: String { get }
    var parameters: [String: String]? { get }
    var method: RequestMethod { get }
    var headers: [HeaderField]? { get }
    var body: RequestBody? { get }
}

public enum RequestMethod: String, Sendable {
    case delete = "DELETE"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public enum RequestBody: Sendable {
    case data(Data)
    case json([String: Sendable])

    public var data: Data {
        get throws {
            return switch self {
            case .data(let data): data
            case .json(let json): try JSONSerialization.data(withJSONObject: json, options: [])
            }
        }
    }
}
