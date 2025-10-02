# Исправления основного проекта - Этап 2

## ? Найденные проблемы:

### 1. E2010 Incompatible types: 'PAnsiChar' and 'PWideChar'
**Файл:** MyLanguage.pas, строка 168
**Проблема:** Использование ANSI функций в Unicode проекте
```pascal
// БЫЛО:
hres:= FindResourceA (Instance,PAnsiChar (ResName),RT_RCDATA);

// СТАЛО:
hres:= FindResource (Instance,PChar (ResName),RT_RCDATA);
```

### 2. H2443 Inline function not expanded - 'System.Classes' missing
**Файл:** wbase.dpr
**Проблема:** Отсутствует System.Classes в uses
```pascal
uses
  System.SysUtils,
  System.Classes,    // <- ДОБАВЛЕНО
  Winapi.Windows,
  Vcl.Forms,
```

## ? Статус исправлений:
- ? Добавлен System.SysUtils в wbase.dpr
- ? Добавлен System.Classes в wbase.dpr  
- ? Исправлен FindResourceA -> FindResource в MyLanguage.pas

## ?? Следующие действия:
1. **Попробуйте снова скомпилировать проект**
2. **Возможно потребуются дополнительные исправления Unicode проблем**

Применяем системный подход к миграции Unicode!
