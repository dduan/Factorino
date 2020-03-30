import ArgumentParser
import Factorino

struct Fact: ParsableCommand {
    @Option()
    var filePath: String?
    @Option()
    var line: Int?
    @Option()
    var column: Int?
    @Option()
    var usr: String?
    @Option(help: "Path to index store")
    var indexStorePath: String?
    @Argument()
    var symbol: String

    func run() throws {
        let query: Query
        if let usr = self.usr {
            query = .usr(usr)
        } else {
            query = .cursor(
                .init(
                    symbol: self.symbol,
                    pathPrefix: self.filePath,
                    line: self.line,
                    column: self.column
                )
            )
        }

        try findDefinition(query, indexStorePath: self.indexStorePath)
    }
}

Fact.main()
