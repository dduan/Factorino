import ArgumentParser
import Factorino

struct X: ParsableCommand {
    @Option()
    var filePath: String?
    @Option()
    var line: Int?
    @Option()
    var column: Int?
    @Argument()
    var symbol: String
    @Argument()
    var newSymbol: String
    @Option(help: "Path to index store")
    var indexStorePath: String?

    func run() throws {
        try findDefinition(
            fromFile: filePath,
            line: line,
            column: column,
            symbolName: symbol,
            newName: newSymbol,
            indexStorePath: indexStorePath
        )
    }
}

X.main()
