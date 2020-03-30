public enum Query {
    case cursor(Cursor)
    case usr(String)

    public struct Cursor {
        let symbol: String
        let pathPrefix: String?
        let line: Int?
        let column: Int?

        public init(
            symbol: String,
            pathPrefix: String?,
            line: Int?,
            column: Int?
        ) {
            self.symbol = symbol
            self.pathPrefix = pathPrefix
            self.line = line
            self.column = column
        }
    }

    public var path: String? {
        switch self {
        case .cursor(let cursor):
            return cursor.pathPrefix
        case .usr:
            return nil
        }
    }
}
