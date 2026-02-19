import XCTest
@testable import lab1

final class BookShelfServiceTests: XCTestCase {

    private func makeSUT(initial: [Book] = []) -> BookShelfService {
        BookShelfService(storage: InMemoryStorage(initial: initial))
    }

    private func book(
        id: String = UUID().uuidString,
        title: String = "Dune",
        author: String = "Frank Herbert",
        year: Int? = 1965,
        genre: Genre = .sciFi,
        tags: [String] = ["classic"]
    ) -> Book {
        Book(id: id, title: title, author: author, publicationYear: year, genre: genre, tags: tags)
    }

    func test_add_increasesCount() throws {
        let sut = makeSUT()
        try sut.add(book(title: "Book 1"))

        let all = sut.list(options: ListOptions())
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.title, "Book 1")
    }

    func test_add_duplicateId_throws() throws {
        let id = "same-id"
        let sut = makeSUT()
        try sut.add(book(id: id, title: "A"))

        XCTAssertThrowsError(try sut.add(book(id: id, title: "B"))) { error in
            guard case LibraryError.duplicateId(let dup) = error else {
                return XCTFail("Expected duplicateId, got \(error)")
            }
            XCTAssertEqual(dup, id)
        }
    }

    func test_delete_existing_removesBook() throws {
        let id = "to-delete"
        let sut = makeSUT()
        try sut.add(book(id: id))

        try sut.delete(id: id)

        let all = sut.list(options: ListOptions())
        XCTAssertTrue(all.isEmpty)
    }

    func test_delete_missing_throwsNotFound() throws {
        let sut = makeSUT()

        XCTAssertThrowsError(try sut.delete(id: "nope")) { error in
            guard case LibraryError.notFound(let id) = error else {
                return XCTFail("Expected notFound, got \(error)")
            }
            XCTAssertEqual(id, "nope")
        }
    }

    func test_search_byTitle_findsCaseInsensitiveSubstring() throws {
        let sut = makeSUT()
        try sut.add(book(title: "The Swift Programming Language"))
        try sut.add(book(title: "Clean Code"))

        let result = sut.search(.title("swift"))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "The Swift Programming Language")
    }

    func test_search_byAuthor_findsCaseInsensitiveSubstring() throws {
        let sut = makeSUT()
        try sut.add(book(title: "Clean Code", author: "Robert Martin"))
        try sut.add(book(title: "Pragmatic Programmer", author: "Andrew Hunt"))

        let result = sut.search(.author("martin"))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "Clean Code")
    }

    func test_search_byYear_matchesExactly() throws {
        let sut = makeSUT()
        try sut.add(book(title: "Old", year: 1999))
        try sut.add(book(title: "New", year: 2020))

        let result = sut.search(.year(2020))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "New")
    }

    func test_search_byTag_normalizedLowercasedAndTrimmed() throws {
        let sut = makeSUT()
        try sut.add(book(title: "A", tags: ["  Swift  ", "iOS"]))
        try sut.add(book(title: "B", tags: ["backend"]))

        let result = sut.search(.tag("swift"))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "A")
    }

    func test_add_emptyTitle_throws() throws {
        let sut = makeSUT()

        XCTAssertThrowsError(try sut.add(book(title: "   "))) { error in
            guard case LibraryError.emptyTitle = error else {
                return XCTFail("Expected emptyTitle, got \(error)")
            }
        }
    }

    func test_add_emptyAuthor_throws() throws {
        let sut = makeSUT()

        XCTAssertThrowsError(try sut.add(book(author: ""))) { error in
            guard case LibraryError.emptyAuthor = error else {
                return XCTFail("Expected emptyAuthor, got \(error)")
            }
        }
    }

    func test_add_invalidYear_throws() throws {
        let sut = makeSUT()
        XCTAssertThrowsError(try sut.add(book(year: 1200))) { error in
            guard case LibraryError.invalidYear(let y) = error else {
                return XCTFail("Expected invalidYear, got \(error)")
            }
            XCTAssertEqual(y, 1200)
        }
    }

    func test_add_normalizesTags_trimLowercaseUniqueAndDropsEmpty() throws {
        let sut = makeSUT()
        try sut.add(book(tags: ["  Swift ", "swift", "", "  ", "iOS", "IOS"]))

        let saved = sut.list(options: ListOptions()).first
        XCTAssertEqual(saved?.tags, ["swift", "ios"])
    }

    func test_add_trimsTitleAndAuthor() throws {
        let sut = makeSUT()
        try sut.add(book(title: "  Dune  ", author: "  Frank Herbert  "))

        let saved = sut.list(options: ListOptions()).first
        XCTAssertEqual(saved?.title, "Dune")
        XCTAssertEqual(saved?.author, "Frank Herbert")
    }
}
