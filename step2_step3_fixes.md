# Исправление ошибок в step2_crc32 и step3_mystrings

## ? Найденная проблема:
В `step2_crc32.dpr` и `step3_mystrings.dpr` отсутствовал модуль `System.SysUtils`

## ?? Исправления:

### step2_crc32.dpr
**БЫЛО:**
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  CRC32 in 'CRC32.pas';
```

**СТАЛО:**
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,    // ? ДОБАВЛЕНО для IntToStr и Exception
  CRC32 in 'CRC32.pas';
```

### step3_mystrings.dpr
**БЫЛО:**
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  MyStrings in 'MyStrings.pas';
```

**СТАЛО:**
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,    // ? ДОБАВЛЕНО для Exception
  MyStrings in 'MyStrings.pas';
```

## ? Дополнительно:
- Создан файл `step3_mystrings.dproj` для корректного открытия в Delphi 12

## ?? Следующие действия:
1. **Попробуйте снова скомпилировать step2_crc32.dproj**
2. Если успешно - переходите к step3_mystrings.dproj
3. Затем можно тестировать основной проект wbase_simple.dproj

## ?? Вывод:
Основная проблема была в отсутствии `System.SysUtils` - это системный модуль, необходимый для:
- `IntToStr()` - преобразование числа в строку
- `Exception` - тип для обработки исключений
- `ShowMessage()` с правильными перегрузками
