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

enum FactorinoError: Error {
    case couldNotFindStore
    case missingDefinition(Query)
    case multipleDefinitions([SymbolOccurrence])
    case unsupportedRefactor(String)
}

func createStore(query: Query, indexStorePath: String?) throws -> IndexStoreDB {
    let store: IndexStoreDB?
    if let explicitStorePath = indexStorePath {
        store = try? IndexStoreDB(
            storePath: explicitStorePath,
            databasePath: join(paths: createTemporaryDirectory(), "indexstore_db"),
            library: IndexStoreLibrary(dylibPath: libIndexStorePath))
    } else  {
        store = findStore(fromFilePath: query.path ?? "./")
    }

    guard let result = store else {
        throw FactorinoError.couldNotFindStore
    }

    return result
}

public func findDefinition(_ query: Query, indexStorePath: String?) throws -> [SymbolOccurrence] {
    return try DefinitionFinder(store: createStore(query: query, indexStorePath: indexStorePath))
        .find(query: query)
}

public func findOccurrences(_ query: Query, indexStorePath: String?) throws -> [SymbolOccurrence] {
    let store = try createStore(query: query, indexStorePath: indexStorePath)
    let definitions = try DefinitionFinder(store: store).find(query: query)

    guard definitions.count < 2 else {
        throw FactorinoError.multipleDefinitions(definitions)
    }

    guard let definition = definitions.first else {
        throw FactorinoError.missingDefinition(query)
    }

    return store.occurrences(ofUSR: definition.symbol.usr, roles: [.definition, .reference])
}

public func replace(_ occurrences: [SymbolOccurrence], withNewName newName: String) throws {
    guard let firstOccurrence = occurrences.first else {
        fatalError("Called \(#function) with no occurrences")
    }

    if firstOccurrence.symbol.kind == .function {
        throw FactorinoError.unsupportedRefactor("renaming functions")
    }

    let groupByFile: [String: [SymbolOccurrence]] = .init(grouping: occurrences) { $0.location.path }
    let name = firstOccurrence.symbol.name
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
