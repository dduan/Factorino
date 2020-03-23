import IndexStoreDB
import Pathos

let libIndexStorePath = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"

enum OccurrenceFinderError: Error {
    case invalidSymbol
}

final class OccurrenceFinder {
    let store: IndexStoreDB

    init(store: IndexStoreDB) {
        self.store = store
        self.store.pollForUnitChangesAndWait()
    }

    func find(sourcePath: String, line: Int, column: Int, symbolName: String) throws -> [SymbolOccurrence] {
        var result = [SymbolOccurrence]()
        self.store.forEachCanonicalSymbolOccurrence(
            containing: symbolName,
            anchorStart: true,
            anchorEnd: true,
            subsequence: false,
            ignoreCase: false)
        { finding in
            guard !finding.location.isSystem else {
                return true
            }

            let allOccurrences = self.store.occurrences(
                ofUSR: finding.symbol.usr, roles: [.reference, .definition]
            )

            let found = allOccurrences.contains { occur in
                occur.location.path == sourcePath &&
                    occur.location.line - 1 == line &&
                    occur.location.utf8Column <= column &&
                    occur.location.utf8Column + symbolName.count > column
            }

            if found {
                result = allOccurrences
                return false
            }

            return true
        }

        if result.isEmpty {
            throw OccurrenceFinderError.invalidSymbol
        }

        return result
    }
}
