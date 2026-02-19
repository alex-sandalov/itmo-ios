import Foundation

public protocol BookShelfProtocol {
    func add(_ book: Book) throws
    func delete(id: String) throws
    func edit(id: String, patch: BookPatch) throws
    func list(options: ListOptions) -> [Book]
    func search(_ query: SearchQuery) -> [Book]
}
