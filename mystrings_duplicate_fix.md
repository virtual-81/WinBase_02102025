# Исправление дублированных функций в MyStrings.pas

## ? Найденные проблемы:
1. `E2004 Identifier redeclared: 'HexToByte'` - функция объявлена дважды
2. Дублирование в interface и implementation секциях

## ?? Исправления:

### В interface секции:
**БЫЛО:**
```pascal
function HexToByte (const Hex: string): byte; overload;
function HexToByte (const Hex: String): byte; overload;
```

**СТАЛО:**
```pascal
function HexToByte (const Hex: string): byte;
```

### В implementation секции:
**БЫЛО:**
```pascal
function HexToByte (const Hex: string): byte;
var
	i: integer;
	b: byte;
begin
	Val ('$'+Hex,b,i);
	HexToByte:= b;
end;

function HexToByte (const Hex: String): byte; overload;
begin
  Result:= HexToByte (string (Hex));
end;
```

**СТАЛО:**
```pascal
function HexToByte (const Hex: string): byte;
var
	i: integer;
	b: byte;
begin
	Val ('$'+Hex,b,i);
	HexToByte:= b;
end;
```

## ?? Объяснение:
В Delphi `string` и `String` - это один и тот же тип. Поэтому две функции с параметрами `(const Hex: string)` и `(const Hex: String)` считаются дублированными.

## ? Результат:
Теперь `step3_mystrings.dproj` должен компилироваться без ошибок!
