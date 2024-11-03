public enum NetworkError: Error {
    case encoding
    case decoding
    case invalidURL
    case statusCode(Int)
    case internalFailure
}
