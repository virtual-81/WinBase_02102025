# Диагностика ошибок компиляции WinBASE

## Найденные ошибки и исправления

### 1. Ошибка в MyStrings.pas
**Проблема:** Дублированные префиксы `System.System.` в секции uses
```pascal
// БЫЛО (неправильно):
uses
	System.System.Classes,
  System.System.StrUtils,
  System.System.SysUtils;

// СТАЛО (правильно):
uses
	System.Classes,
  System.StrUtils,
  System.SysUtils;
```

### 2. Ошибка в ctrl_language.pas
**Проблема:** 
- Отсутствие пробелов между модулями в uses
- Использование `Grids` без префикса `Vcl.`

```pascal
// БЫЛО (неправильно):
uses
  Winapi.Windows,System.Classes,Vcl.ComCtrls,Vcl.StdCtrls,Vcl.ExtCtrls,Vcl.Forms,Vcl.Controls,Vcl.Dialogs,
  MyLanguage,Vcl.Menus,System.SysUtils,Grids;

// СТАЛО (правильно):
uses
  Winapi.Windows, System.Classes, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, 
  Vcl.Forms, Vcl.Controls, Vcl.Dialogs, MyLanguage, Vcl.Menus, 
  System.SysUtils, Vcl.Grids;
```

### 3. Ошибка в базовых проектах
**Проблема:** Отсутствует модуль `System.SysUtils` для работы с исключениями

```pascal
// БЫЛО (неправильно):
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs;

// СТАЛО (правильно):
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils;  // Для Exception и других системных типов
```

## Пошаговая диагностика

### Шаг 0: Сверх-минимальный тест
Файл: `step0_minimal.dpr`
- Только ShowMessage без обработки исключений
- Минимум модулей

### Шаг 1: Базовый тест
Файл: `step1_basic.dpr`
- Минимальный VCL проект
- Только стандартные модули Delphi 12

### Шаг 2: Тест CRC32
Файл: `step2_crc32.dpr` 
- Добавляется модуль CRC32.pas
- Проверка компиляции математических функций

### Шаг 3: Тест MyStrings
Файл: `step3_mystrings.dpr`
- Добавляется исправленный модуль MyStrings.pas
- Проверка строковых функций

### Шаг 4: Постепенное добавление модулей
Добавлять по одному модулю и проверять компиляцию:
1. calceval.pas
2. wb_registry.pas  
3. MyLanguage.pas
4. ctrl_language.pas

## Рекомендации по дальнейшей отладке

1. **Всегда тестируйте пошагово** - добавляйте модули по одному
2. **Проверяйте секции uses** - корректные пространства имен для Delphi 12
3. **Проверяйте кодировку файлов** - должна быть UTF-8 или ANSI
4. **Ищите устаревшие типы данных** - AnsiString, PChar и т.д.

## Следующие действия

1. Откройте в Delphi 12: `step0_minimal.dpr` - самый простой тест 
2. Если компилируется - переходите к `step1_basic.dpr` (с исправленным uses)
3. Если компилируется - переходите к `step2_crc32.dpr`
4. Если компилируется - переходите к `step3_mystrings.dpr`
5. И так далее по порядку

Это поможет точно определить, какой именно модуль вызывает ошибку компиляции.
