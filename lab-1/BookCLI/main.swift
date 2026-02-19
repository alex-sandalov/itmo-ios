import Foundation

let storage = JSONFileStorage()
let service = BookShelfService(storage: storage)
let view = ConsoleView()
let controller = ConsoleController(shelf: service, view: view)
controller.run()
