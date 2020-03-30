import IndexStoreDB
import Pathos

let libIndexStorePath = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"

enum OccurrenceFinderError: Error {
    case invalidSymbol
}

final class DefinitionFinder {
    let store: IndexStoreDB

    init(store: IndexStoreDB) {
        self.store = store
    }


    func find(query: Query) throws -> [SymbolOccurrence] {
        self.store.pollForUnitChangesAndWait()
        switch query {
        case .cursor(let cursor):
            return try self.find(sourcePath: cursor.pathPrefix, line: cursor.line, column: cursor.column,
                             symbolName: cursor.symbol)
        case .usr(let usr):
            return self.store.occurrences(ofUSR: usr, roles: .definition)
        }
    }

    private func find(sourcePath: String?, line: Int?, column: Int?, symbolName: String) throws -> [SymbolOccurrence] {
        let sourcePath = try sourcePath.map(absolutePath(ofPath: ))
        var result = [SymbolOccurrence]()
        self.store.forEachCanonicalSymbolOccurrence(
            containing: symbolName,
            anchorStart: true,
            anchorEnd: false,
            subsequence: false,
            ignoreCase: false)
        { finding in
            guard !finding.location.isSystem else {
                return true
            }

            let allOccurrences = self.store.occurrences(
                ofUSR: finding.symbol.usr, roles: .definition
            )

            let found = allOccurrences.contains { occur in
                if let sourcePath = sourcePath, !occur.location.path.hasPrefix(sourcePath) {
                    return false
                }

                if let line = line, occur.location.line != line {
                    return false
                }

                if let column = column,
                    (occur.location.utf8Column > column ||
                    occur.location.utf8Column + symbolName.count <= column)
                {
                    return false
                }

                return true
            }

            if found && !result.contains(finding) {
                result.append(finding)
            }

            return true
        }

        return result
    }
}
