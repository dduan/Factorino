import ArgumentParser
import Factorino

struct QueryOptions: ParsableArguments {
    @Option()
    var filePath: String?
    @Option()
    var line: Int?
    @Option()
    var column: Int?
    @Option()
    var usr: String?
    @Argument()
    var symbol: String
}

extension Query {
    init(_ options: QueryOptions) {
        if let usr = options.usr {
            self = .usr(usr)
        } else {
            self = .cursor(
                .init(
                    symbol: options.symbol,
                    pathPrefix: options.filePath,
                    line: options.line,
                    column: options.column
                )
            )
        }
    }
}

struct Define: ParsableCommand {
    @OptionGroup()
    var queryOptions: QueryOptions

    @Option(help: "Path to index store")
    var indexStorePath: String?

    func run() throws {
        try findDefinition(Query(self.queryOptions), indexStorePath: self.indexStorePath)
    }
}

struct Fact: ParsableCommand {
    static var configuration = CommandConfiguration(
        subcommands: [Define.self]
    )
}

Fact.main()
