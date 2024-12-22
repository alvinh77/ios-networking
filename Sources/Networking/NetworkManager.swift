import Foundation
import NetworkingInterfaces

public struct NetworkManager: Sendable {
    typealias DataProviding = @Sendable (URLRequest) async throws -> (Data, URLResponse)
    private let requestMapper: RequestMapping
    private let dataProvider: DataProviding
    private let responseHandler: ResponseHandling?

    init(
        dataProvider: @escaping DataProviding,
        requestMapper: @escaping RequestMapping,
        responseHandler: ResponseHandling? = nil
    ) {
        self.requestMapper = requestMapper
        self.dataProvider = dataProvider
        self.responseHandler = responseHandler
    }

    public func response<R: Request>(for request: R) async throws(NetworkError) -> R.Response {
        let urlRequest = try requestMapper(request)
        let data = try await getData(from: urlRequest)
        return try decode(data)
    }
}

extension NetworkManager {
    private func getData(
        from request: URLRequest
    ) async throws(NetworkError) -> Data {
        do {
            let (data, response) = try await dataProvider(request)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.internalFailure
            }
            guard (200...299).contains(response.statusCode) else {
                throw NetworkError.statusCode(response.statusCode)
            }
            if let responseHandler {
                responseHandler(response, data)
            }
            return data
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.internalFailure
        }
    }

    private func decode<Response: Decodable>(_ data: Data) throws(NetworkError) -> Response {
        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
}

extension NetworkManager {
    public init(
        urlSession: URLSession = .shared,
        requestMapper: RequestMapper = .init(),
        responseHandler: ResponseHandling? = nil
    ) {
        self.dataProvider = urlSession.data(for:)
        self.requestMapper = requestMapper.map(_:)
        self.responseHandler = responseHandler
    }
}
