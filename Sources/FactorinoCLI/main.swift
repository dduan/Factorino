import ArgumentParser
import Factorino

struct QueryOptions: ParsableArguments {
    @Option(name: [.short, .long])
    var path: String?
    @Option(name: [.short, .long])
    var line: Int?
    @Option(name: [.short, .long])
    var column: Int?
    @Option(name: [.short, .long])
    var usr: String?
    @Argument(default: "")
    var symbol: String

    mutating func validate() throws {
        if symbol == "" && usr == nil {
            throw ValidationError("Please specify either a symbol name or a USR.")
        }
    }
}

extension Query {
    init(_ options: QueryOptions) {
        if let usr = options.usr {
            self = .usr(usr)
        } else {
            self = .cursor(
                .init(
                    symbol: options.symbol,
                    pathPrefix: options.path,
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
        let occurs = try findDefinition(Query(self.queryOptions), indexStorePath: self.indexStorePath)
        for o in occurs {
            print(o)
        }
    }
}

struct Occur: ParsableCommand {
    @OptionGroup()
    var queryOptions: QueryOptions

    @Option(help: "Path to index store")
    var indexStorePath: String?

    func run() throws {
        let occurs = try findOccurrences(Query(self.queryOptions), indexStorePath: self.indexStorePath)
        for o in occurs {
            print(o)
        }
    }
}

struct Rename: ParsableCommand {
    @OptionGroup()
    var queryOptions: QueryOptions

    @Option(help: "Path to index store")
    var indexStorePath: String?

    @Argument()
    var newSymbol: String

    func run() throws {
        let occurs = try findOccurrences(Query(self.queryOptions), indexStorePath: self.indexStorePath)
        try replace(occurs, withNewName: newSymbol)
    }
}

struct Fact: ParsableCommand {
    static var configuration = CommandConfiguration(
        subcommands: [
            Define.self,
            Occur.self,
            Rename.self,
        ]
    )
}

Fact.main()
