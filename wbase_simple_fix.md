# Исправление wbase_simple.dpr - System.SysUtils

## ? Найденные проблемы:
1. `E2003 Undeclared identifier: 'IntToStr'`
2. `E2250 There is no overloaded version of 'ShowMessage'`
3. `E2003 Undeclared identifier: 'Exception'`
4. `E2029 '; expected but ':' found`

## ?? Исправление:

### БЫЛО:
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  CRC32 in 'CRC32.pas';
```

### СТАЛО:
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,    // ? ДОБАВЛЕНО для IntToStr, Exception
  CRC32 in 'CRC32.pas';
```

## ?? Объяснение:
Та же проблема, что была в step2 и step3 - в Delphi 12 нужно явно подключать `System.SysUtils` для:
- `IntToStr()` - преобразование числа в строку
- `Exception` - тип для обработки исключений
- Правильные перегрузки `ShowMessage()`

## ?? Результат:
Теперь `wbase_simple.dproj` должен компилироваться без ошибок!

## ?? Полный статус миграции:
- ? step0_minimal - успех
- ? step1_basic - успех  
- ? step2_crc32 - успех
- ? step3_mystrings - успех
- ?? wbase_simple - исправлен, готов к тестированию

## ?? Следующие действия:
**Попробуйте снова скомпилировать wbase_simple.dproj - это будет ГЛАВНЫЙ ПРОРЫВ!**
