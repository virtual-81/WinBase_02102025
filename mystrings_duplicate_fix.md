# ����������� ������������� ������� � MyStrings.pas

## ? ��������� ��������:
1. `E2004 Identifier redeclared: 'HexToByte'` - ������� ��������� ������
2. ������������ � interface � implementation �������

## ?? �����������:

### � interface ������:
**����:**
```pascal
function HexToByte (const Hex: string): byte; overload;
function HexToByte (const Hex: String): byte; overload;
```

**�����:**
```pascal
function HexToByte (const Hex: string): byte;
```

### � implementation ������:
**����:**
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

**�����:**
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

## ?? ����������:
� Delphi `string` � `String` - ��� ���� � ��� �� ���. ������� ��� ������� � ����������� `(const Hex: string)` � `(const Hex: String)` ��������� ��������������.

## ? ���������:
������ `step3_mystrings.dproj` ������ ��������������� ��� ������!
