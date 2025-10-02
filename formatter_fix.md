# Решение проблемы с Pascal Formatter

## ?? Проблема
Сообщения "Running Pascal Formatter" и "Skip" в правом углу VSCode указывают на проблемы с расширением **Pascal Formatter**.

## ? Решения

### Вариант 1: Отключить автоформатирование
1. Откройте VSCode настройки (Ctrl+,)
2. Найдите "Format On Save"
3. Снимите галочку
4. Найдите "Format On Type" 
5. Снимите галочку

### Вариант 2: Временно отключить расширение
1. Ctrl+Shift+X (Extensions)
2. Найдите "Pascal Formatter"
3. Нажмите "Disable"
4. Перезагрузите VSCode

### Вариант 3: Изменить настройки через JSON
Замените содержимое `.vscode/settings.json`:

```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "editor.formatOnSave": false,
  "editor.formatOnType": false,
  "files.encoding": "windows1251",
  "files.defaultLanguage": "pascal",
  "files.associations": {
    "*.pas": "pascal",
    "*.dpr": "pascal",
    "*.dpk": "pascal",
    "*.dfm": "pascal"
  },
  "search.exclude": {
    "**/*.dcu": true,
    "**/*.~*": true,
    "**/*.identcache": true,
    "**/*.local": true
  }
}
```

## ?? Почему это происходит?

Pascal Formatter пытается использовать утилиту `ptop` (Pascal Pretty Printer), которая:
1. Может быть не установлена
2. Не может обрабатывать некоторые современные конструкции Delphi
3. Имеет проблемы с кодировкой файлов

## ?? Рекомендация

**Для текущей миграции лучше отключить автоформатирование** и сосредоточиться на компиляции проекта. Форматирование можно настроить позже, когда проект заработает.

## ?? Альтернативы Pascal Formatter

1. **Встроенный Delphi formatter** - в самой IDE
2. **OmniPascal** - более стабильная альтернатива
3. **Ручное форматирование** - пока проект не стабилизирован

---
**После применения любого решения перезагрузите VSCode (Ctrl+Shift+P ? "Developer: Reload Window")**
