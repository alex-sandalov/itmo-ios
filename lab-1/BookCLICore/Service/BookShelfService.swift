import Foundation

public final class BookShelfService: BookShelfProtocol {

    private var books: [Book]
    private let storage: StorageProtocol

    public init(storage: StorageProtocol) {
        self.storage = storage
        self.books = (try? storage.load()) ?? []
    }

    public func add(_ book: Book) throws {
        let normalized = try BookValidation.normalizeAndValidate(book)

        if books.contains(where: { $0.id == normalized.id }) {
            throw LibraryError.duplicateId(normalized.id)
        }

        books.append(normalized)
        try storage.save(books)
    }

    public func delete(id: String) throws {
        guard let index = books.firstIndex(where: { $0.id == id }) else {
            throw LibraryError.notFound(id: id)
        }

        books.remove(at: index)
        try storage.save(books)
    }

    public func edit(id: String, patch: BookPatch) throws {
        guard let index = books.firstIndex(where: { $0.id == id }) else {
            throw LibraryError.notFound(id: id)
        }

        var updated = books[index]

        if let t = patch.title { updated.title = t }
        if let a = patch.author { updated.author = a }
        if let y = patch.publicationYear { updated.publicationYear = y }
        if let g = patch.genre { updated.genre = g }
        if let tags = patch.tags { updated.tags = tags }

        updated = try BookValidation.normalizeAndValidate(updated)
        books[index] = updated
        try storage.save(books)
    }

    public func list(options: ListOptions) -> [Book] {
        var result = books

        if let key = options.sortKey {
            result.sort { a, b in
                let ordered: Bool
                switch key {
                case .title:
                    ordered = a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
                case .author:
                    ordered = a.author.localizedCaseInsensitiveCompare(b.author) == .orderedAscending
                case .year:
                    ordered = (a.publicationYear ?? Int.min) < (b.publicationYear ?? Int.min)
                }
                return options.ascending ? ordered : !ordered
            }
        }

        return result
    }

    public func search(_ query: SearchQuery) -> [Book] {
        switch query {
        case .title(let value):
            let needle = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return books.filter { $0.title.lowercased().contains(needle) }
        case .author(let value):
            let needle = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return books.filter { $0.author.lowercased().contains(needle) }
        case .genre(let genre):
            return books.filter { $0.genre == genre }
        case .tag(let tag):
            let needle = BookValidation.normalizeTag(tag)
            return books.filter { $0.tags.contains(needle) }
        case .year(let year):
            return books.filter { $0.publicationYear == year }
        }
    }
}
