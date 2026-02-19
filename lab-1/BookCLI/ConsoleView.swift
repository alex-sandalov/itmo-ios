import Foundation

public protocol ConsoleViewProtocol {
    func show(_ text: String)
    func prompt(_ label: String) -> String
    func showBooks(_ books: [Book])
    func showError(_ error: Error)
}

public final class ConsoleView: ConsoleViewProtocol {

    public init() {}

    public func show(_ text: String) {
        print(text)
    }

    public func prompt(_ label: String) -> String {
        print("\(label): ", terminator: "")
        return readLine() ?? ""
    }

    public func showBooks(_ books: [Book]) {
        if books.isEmpty {
            print("Список пуст.")
            return
        }

        for (i, b) in books.enumerated() {
            let year = b.publicationYear.map(String.init) ?? "—"
            let tags = b.tags.isEmpty ? "—" : b.tags.joined(separator: ", ")
            print("\(i + 1). \(b.title) | \(b.author) | \(year) | \(b.genre.rawValue)")
            print("   id: \(b.id)")
            print("   tags: \(tags)")
        }
    }

    public func showError(_ error: Error) {
        if let le = error as? LocalizedError, let msg = le.errorDescription {
            print("Ошибка: \(msg)")
        } else {
            print("Ошибка: \(error.localizedDescription)")
        }
    }
}
