import Foundation

public struct RequestMapper: Sendable {
    private let mapping: @Sendable (any Request) throws(NetworkError) -> URLRequest

    public init(mapping: @escaping @Sendable (any Request) throws(NetworkError) -> URLRequest) {
        self.mapping = mapping
    }

    public func map(_ request: any Request) throws(NetworkError) -> URLRequest {
        try mapping(request)
    }
}

extension RequestMapper {
    public init() {
        self.mapping = { @Sendable (request) throws(NetworkError) in
            guard var urlComponents = URLComponents(
                string: "\(request.baseURL)\(request.path)"
            ) else {
                throw NetworkError.invalidURL
            }
            if request.method == .get {
                urlComponents.queryItems = request.parameters?.map {
                    URLQueryItem(name: $0, value: $1)
                }
            }
            guard let url = urlComponents.url else {
                throw NetworkError.invalidURL
            }
            var urlRequest = URLRequest(url: url)
            if let body = request.body {
                guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
                    throw NetworkError.encoding
                }
                urlRequest.httpBody = bodyData
            }
            urlRequest.httpMethod = request.method.rawValue
            if let headers = request.headers, headers.count > 0 {
                var allHTTPHeaderFields = urlRequest.allHTTPHeaderFields ?? [:]
                headers.forEach {
                    allHTTPHeaderFields[$0.key.rawValue] = $0.value
                }
                urlRequest.allHTTPHeaderFields = allHTTPHeaderFields
            }
            return urlRequest
        }
    }
}
