import Foundation

public final class JSONFileStorage: StorageProtocol {

    private let url: URL

    public init(filename: String = "books.json") {
        let fm = FileManager.default
        if let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            self.url = docs.appendingPathComponent(filename)
        } else {
            self.url = fm.temporaryDirectory.appendingPathComponent(filename)
        }
    }

    public func load() throws -> [Book] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Book].self, from: data)
        } catch {
            throw LibraryError.storageError(error.localizedDescription)
        }
    }

    public func save(_ books: [Book]) throws {
        do {
            let data = try JSONEncoder().encode(books)
            try data.write(to: url, options: .atomic)
        } catch {
            throw LibraryError.storageError(error.localizedDescription)
        }
    }

    public var filePath: String { url.path }
}
