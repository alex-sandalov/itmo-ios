import Foundation

public protocol StorageProtocol {
    func load() throws -> [Book]
    func save(_ books: [Book]) throws
}
