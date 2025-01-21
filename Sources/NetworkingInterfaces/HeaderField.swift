public struct HeaderField: Sendable {
    public let key: String
    public let value: String

    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

extension HeaderField {
    public static func contentType(_ value: String) -> Self {
        .init(key: "Content-Type", value: value)
    }
}
