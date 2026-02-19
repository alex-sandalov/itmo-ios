import Foundation

public enum BookValidation {

    public static func normalizeAndValidate(_ book: Book) throws -> Book {
        var b = book

        b.title = b.title.trimmingCharacters(in: .whitespacesAndNewlines)
        b.author = b.author.trimmingCharacters(in: .whitespacesAndNewlines)

        if b.title.isEmpty { throw LibraryError.emptyTitle }
        if b.author.isEmpty { throw LibraryError.emptyAuthor }

        if let y = b.publicationYear {
            let current = Calendar.current.component(.year, from: Date())
            guard (1400...current).contains(y) else { throw LibraryError.invalidYear(y) }
        }

        let normalizedTags = b.tags
            .map(normalizeTag)
            .filter { !$0.isEmpty }

        let unique = Array(NSOrderedSet(array: normalizedTags)) as? [String] ?? normalizedTags
        b.tags = unique

        return b
    }

    public static func normalizeTag(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
