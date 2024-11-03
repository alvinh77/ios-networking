public enum NetworkError: Error, Equatable {
    case encoding
    case decoding
    case invalidURL
    case statusCode(Int)
    case internalFailure
}
