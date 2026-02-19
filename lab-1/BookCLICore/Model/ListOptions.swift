import Foundation

public enum SortKey {
    case title, author, year
}

public struct ListOptions {
    public var sortKey: SortKey?
    public var ascending: Bool

    public init(sortKey: SortKey? = nil, ascending: Bool = true) {
        self.sortKey = sortKey
        self.ascending = ascending
    }
}

public struct BookPatch {
    public var title: String?
    public var author: String?
    public var publicationYear: Int??
    public var genre: Genre?
    public var tags: [String]?

    public init(
        title: String? = nil,
        author: String? = nil,
        publicationYear: Int?? = nil,
        genre: Genre? = nil,
        tags: [String]? = nil
    ) {
        self.title = title
        self.author = author
        self.publicationYear = publicationYear
        self.genre = genre
        self.tags = tags
    }
}
