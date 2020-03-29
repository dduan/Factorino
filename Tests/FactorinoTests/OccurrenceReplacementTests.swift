@testable import Factorino
import XCTest

final class OccurrenceReplacementTests: XCTestCase {
    func testReplacingSingleOccurrences() {
        let source = "one four three"
        let result = replaceOccurences(inSource: source, occurrences: [(0, 4)], name: "four", newName: "two")
        XCTAssertEqual(result, "one two three")
    }

    func testReplacingMultilineOccurrences() {
        let source = """
            one four three
            four
            """
        let result = replaceOccurences(
            inSource: source,
            occurrences: [(0, 4), (1, 0)],
            name: "four",
            newName: "two")
        XCTAssertEqual(
            result,
            """
            one two three
            two
            """
        )
    }

    func testReplacingSingleLineMultipleOccurrences() {
        let source = "one four two four three"
        let result = replaceOccurences(
            inSource: source,
            occurrences: [(0, 4), (0, 13)],
            name: "four",
            newName: "two"
        )
        XCTAssertEqual(result, "one two two two three")
    }

    func testReplacingMultilineMultiOccurrences() {
        let source = """
            five
            one four three
            six
            seven
            four
            one four two four three
            eight
            """
        let result = replaceOccurences(
            inSource: source,
            occurrences: [
                (1, 4),
                (4, 0),
                (5, 4),
                (5, 13),
            ],
            name: "four",
            newName: "two")
        XCTAssertEqual(
            result,
            """
            five
            one two three
            six
            seven
            two
            one two two two three
            eight
            """
        )
    }
}
