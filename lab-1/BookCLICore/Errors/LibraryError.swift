import Foundation

public enum LibraryError: Error, LocalizedError {
    case emptyTitle
    case emptyAuthor
    case invalidYear(Int)
    case notFound(id: String)
    case duplicateId(String)
    case invalidGenre(String)
    case invalidSort(String)
    case invalidCommand(String)
    case storageError(String)

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Название не может быть пустым"
        case .emptyAuthor:
            return "Автор не может быть пустым"
        case .invalidYear(let y):
            let current = Calendar.current.component(.year, from: Date())
            return "Некорректный год: \(y). Допустимо 1400...\(current)"
        case .notFound(let id):
            return "Книга с id \(id) не найдена"
        case .duplicateId(let id):
            return "Книга с id \(id) уже существует"
        case .invalidGenre(let g):
            return "Некорректный жанр: \(g). Доступно: \(Genre.allCases.map { $0.rawValue }.joined(separator: ", "))"
        case .invalidSort(let s):
            return "Некорректная сортировка: \(s). Доступно: title, author, year"
        case .invalidCommand(let c):
            return "Некорректная команда/ввод: \(c)"
        case .storageError(let msg):
            return "Ошибка хранилища: \(msg)"
        }
    }
}
