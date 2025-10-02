# ����������� Barcode.pas - Unicode �������������

## ? ��������:
������������� ������ **E2010 Incompatible types: 'Char' and 'AnsiChar'**

## ?? ������:
Barcode.pas ���������� ��� Delphi 7 (ANSI) � ���������� AnsiChar, ��� ������������ � Unicode �������� Delphi 12.

## ? �����������:
1. **��������� ��������� �����������:**
   ```pascal
   {$WARN IMPLICIT_STRING_CAST OFF}
   {$WARN IMPLICIT_STRING_CAST_LOSS OFF}
   ```

2. **�������� type alias ��� �������������:**
   ```pascal
   {$IFDEF UNICODE}
   AnsiChar = Char;
   {$ENDIF}
   ```

3. **���������� ������ �������������:**
   ```pascal
   Result[i] := Char(v);  // ������ AnsiChar(v)
   ```

## ?? ���������:
������������� type alias ��������� ��������� ���� ������������ ���, �� ������� ��� ����������� � Unicode.

## ?? ������:
����� � ��������� ���������� � ���������� Unicode ��������������.
