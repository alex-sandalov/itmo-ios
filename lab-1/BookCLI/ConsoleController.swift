import Foundation

public final class ConsoleController {

    private let shelf: BookShelfProtocol
    private let view: ConsoleViewProtocol

    public init(shelf: BookShelfProtocol, view: ConsoleViewProtocol) {
        self.shelf = shelf
        self.view = view
    }

    public func run() {
        view.show("Book CLI. Команды: help, add, delete, edit, list, search, exit")

        while true {
            view.show("\n> ")
            let input = (readLine() ?? "").trimmed()
            if input.isEmpty { continue }

            do {
                switch input {
                case "help":
                    printHelp()
                case "add":
                    try addFlow()
                case "delete":
                    try deleteFlow()
                case "edit":
                    try editFlow()
                case "list":
                    try listFlow()
                case "search":
                    try searchFlow()
                case "exit":
                    return
                default:
                    throw LibraryError.invalidCommand(input)
                }
            } catch {
                view.showError(error)
            }
        }
    }

    private func printHelp() {
        view.show("""
        help
        add
        delete
        edit
        list
        search
        exit
        """)
    }

    private func addFlow() throws {
        let id = UUID().uuidString
        let title = view.prompt("Название")
        let author = view.prompt("Автор")
        let yearInput = view.prompt("Год (пусто если нет)").trimmed()
        let genreInput = view.prompt("Жанр (\(Genre.allCases.map { $0.rawValue }.joined(separator: ", ")))").trimmed()
        let tagsInput = view.prompt("Теги через запятую").trimmed()

        let year: Int?
        if yearInput.isEmpty {
            year = nil
        } else if let y = Int(yearInput) {
            year = y
        } else {
            throw LibraryError.invalidYear(Int.min)
        }

        guard let genre = Genre(rawValue: genreInput) else {
            throw LibraryError.invalidGenre(genreInput)
        }

        let tags = tagsInput.isEmpty ? [] : tagsInput.split(separator: ",").map { String($0) }

        let book = Book(
            id: id,
            title: title,
            author: author,
            publicationYear: year,
            genre: genre,
            tags: tags
        )

        try shelf.add(book)
        view.show("Добавлено. id=\(id)")
    }

    private func deleteFlow() throws {
        let id = view.prompt("Введите id").trimmed()
        try shelf.delete(id: id)
        view.show("Удалено.")
    }

    private func editFlow() throws {
        let id = view.prompt("Введите id").trimmed()
        let title = view.prompt("Новое название (пусто не менять)")
        let author = view.prompt("Новый автор (пусто не менять)")
        let yearInput = view.prompt("Новый год (пусто не менять, '-' удалить)").trimmed()
        let genreInput = view.prompt("Новый жанр (пусто не менять)").trimmed()
        let tagsInput = view.prompt("Новые теги через запятую (пусто не менять)")

        var patch = BookPatch()

        if !title.trimmed().isEmpty { patch.title = title }
        if !author.trimmed().isEmpty { patch.author = author }

        if yearInput == "-" {
            patch.publicationYear = .some(nil)
        } else if !yearInput.isEmpty {
            guard let y = Int(yearInput) else { throw LibraryError.invalidYear(Int.min) }
            patch.publicationYear = .some(.some(y))
        }

        if !genreInput.isEmpty {
            guard let genre = Genre(rawValue: genreInput) else { throw LibraryError.invalidGenre(genreInput) }
            patch.genre = genre
        }

        if !tagsInput.trimmed().isEmpty {
            patch.tags = tagsInput.split(separator: ",").map { String($0) }
        }

        try shelf.edit(id: id, patch: patch)
        view.show("Изменено.")
    }

    private func listFlow() throws {
        let sortInput = view.prompt("Сортировка (title/author/year/пусто)").trimmed().lowercased()
        let orderInput = view.prompt("Порядок (asc/desc/пусто=asc)").trimmed().lowercased()

        let sortKey: SortKey?
        if sortInput.isEmpty {
            sortKey = nil
        } else {
            switch sortInput {
            case "title": sortKey = .title
            case "author": sortKey = .author
            case "year": sortKey = .year
            default: throw LibraryError.invalidSort(sortInput)
            }
        }

        let ascending = orderInput != "desc"
        let books = shelf.list(options: ListOptions(sortKey: sortKey, ascending: ascending))
        view.showBooks(books)
    }

    private func searchFlow() throws {
        view.show("""
        1 title
        2 author
        3 genre
        4 tag
        5 year
        """)
        let choice = view.prompt("Выбор").trimmed()

        switch choice {
        case "1":
            let value = view.prompt("title")
            view.showBooks(shelf.search(.title(value)))
        case "2":
            let value = view.prompt("author")
            view.showBooks(shelf.search(.author(value)))
        case "3":
            let value = view.prompt("genre").trimmed()
            guard let g = Genre(rawValue: value) else { throw LibraryError.invalidGenre(value) }
            view.showBooks(shelf.search(.genre(g)))
        case "4":
            let value = view.prompt("tag")
            view.showBooks(shelf.search(.tag(value)))
        case "5":
            let value = view.prompt("year").trimmed()
            guard let y = Int(value) else { throw LibraryError.invalidYear(Int.min) }
            view.showBooks(shelf.search(.year(y)))
        default:
            throw LibraryError.invalidCommand(choice)
        }
    }
}

private extension String {
    func trimmed() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
