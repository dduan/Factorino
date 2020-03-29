import ArgumentParser
import Factorino

struct FactorinoCommand: ParsableCommand {
    @Argument()
    var filePath: String
    @Argument()
    var line: Int
    @Argument()
    var column: Int
    @Argument()
    var symbol: String
    @Argument()
    var newSymbol: String
    @Option(help: "Path to index store")
    var indexStorePath: String?

    func run() throws {
        try renameSymbol(
            fromFile: filePath,
            line: line,
            column: column,
            symbolName: symbol,
            newName: newSymbol,
            indexStorePath: indexStorePath
        )
    }
}

FactorinoCommand.main()
