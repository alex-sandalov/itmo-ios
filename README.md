# BookShelf — Лабораторная №1

## Как запустить

### Playground
1. Открыть файл в Xcode
2. Нажать Run
3. Вводить команды в консоли

### Command Line Tool
1. Создать проект типа Command Line Tool
2. Вставить код в `main.swift`
3. Запустить проект

Завершение работы: `exit`.

---

## Команды

- `add` — добавить книгу
- `delete` — удалить по id
- `list` — показать список
- `search` — поиск
- `help` — справка
- `exit`— завершить

---

## Пример сценария

1. `add`
2. `add`
3. `list`
4. `search` → `author`
5. `delete`
6. `exit`

---

## Что реализовано

### Обязательная часть
- Add / Delete / List / Search
- Поиск минимум по title и author
- Несколько действий за запуск
- Архитектура через `BookShelfProtocol`
- Бизнес-логика вынесена в `BookShelfService`
- Обработка ошибок без падений

### D1 — Валидация
- title и author не пустые
- год 1400…текущий
- нормализация тегов

### D2 — Ошибки
- `LibraryError`
- понятные сообщения

### D8 — Тесты
Unit-тесты на:
- add
- delete
- search
- validation
- ошибки
