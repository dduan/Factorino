import IndexStoreDB
import Pathos

func replaceOccurences(inSource source: String, occurrences: [(Int, Int)], name: String, newName: String)
    -> String
{
    let source = source.split(separator: "\n", omittingEmptySubsequences: false)
    var result = [Substring]()
    var previousLine = -1
    var previousColumn = 0
    var currentLine: Substring = "" // accumulate changes from a line
    for occur in occurrences {
        let (line, column) = occur
        if previousLine != line {
            if previousLine >= 0 {
                // finish up the old line
                currentLine += source[previousLine].dropFirst(previousColumn + name.count)
                result.append(currentLine)
            }
            result += source[(previousLine + 1) ..< line]

            // reset the line buffer
            previousColumn = 0
            currentLine = ""
            let original = source[line]
            currentLine += original.dropLast(original.count - column)
        } else {
            let original = source[line]
            currentLine += original.dropFirst(previousColumn + name.count).dropLast(original.count - column)
        }

        currentLine += newName[...]

        previousLine = line
        previousColumn = column
    }

    currentLine += source[previousLine].dropFirst(previousColumn + name.count)
    result.append(currentLine)
    result += source[(previousLine + 1)...]
    return result.joined(separator: "\n")
}


func replaceSymbolOccurrences(occurrences: [SymbolOccurrence], newName: String) throws {
    let groupByFile: [String: [SymbolOccurrence]] = .init(grouping: occurrences) { $0.location.path }
    let name = occurrences.first?.symbol.name ?? ""
    for (filePath, occurrences) in groupByFile {
        try write(
            replaceOccurences(
                inSource: try readString(atPath: filePath),
                occurrences: occurrences.map { ($0.location.line - 1, $0.location.utf8Column - 1) },
                name: name,
                newName: newName
            ),
            atPath: filePath
        )
    }
}

func findStore(fromFilePath path: String) -> IndexStoreDB? {
    var path = path

    while path != "/" {
        path = directory(ofPath: path)
        if let store = try? IndexStoreDB(
            storePath: join(paths: path, ".build/debug/index/store"),
            databasePath: join(paths: createTemporaryDirectory(), "indexstore_db"),
            library: IndexStoreLibrary(dylibPath: libIndexStorePath)
        )
        {
            return store
        }
    }

    return nil
}

enum Factorino: Error {
    case couldNotFindStore
}

//public func renameSymbol(fromFile filePath: String?, line: Int?, column: Int?, symbolName: String, newName: String, indexStorePath: String?) throws {
//    func createStore() -> IndexStoreDB? {
//        if let explicitStorePath = indexStorePath {
//            return try? IndexStoreDB(
//                storePath: explicitStorePath,
//                databasePath: join(paths: createTemporaryDirectory(), "indexstore_db"),
//                library: IndexStoreLibrary(dylibPath: libIndexStorePath))
//        } else {
//            return findStore(fromFilePath: filePath)
//        }
//    }
//
//    guard let store = createStore() else {
//        throw Factorino.couldNotFindStore
//    }
//
//    let
//    let finder = OccurrenceFinder(store: store)
//    let occurs = try finder.find(sourcePath: absolutePath(ofPath: filePath), line: line, column: column, symbolName: symbolName)
//    try replaceSymbolOccurrences(occurrences: occurs, newName: newName)
//}

public func findDefinition(_ query: Query, indexStorePath: String?) throws {
    func createStore() -> IndexStoreDB? {
        if let explicitStorePath = indexStorePath {
            return try? IndexStoreDB(
                storePath: explicitStorePath,
                databasePath: join(paths: createTemporaryDirectory(), "indexstore_db"),
                library: IndexStoreLibrary(dylibPath: libIndexStorePath))
        } else  {
            return findStore(fromFilePath: query.path ?? "./")
        }
    }

    guard let store = createStore() else {
        throw Factorino.couldNotFindStore
    }

    let finder = DefinitionFinder(store: store)
    let occurs = try finder.find(query: query)
    print(occurs.count)
    for o in occurs {
        print(o)
    }
}
