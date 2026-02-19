import Foundation

public final class InMemoryStorage: StorageProtocol {
    private var data: [Book]

    public init(initial: [Book] = []) {
        self.data = initial
    }

    public func load() throws -> [Book] {
        data
    }

    public func save(_ books: [Book]) throws {
        self.data = books
    }
}
