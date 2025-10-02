# ����������� wbase_simple.dpr - System.SysUtils

## ? ��������� ��������:
1. `E2003 Undeclared identifier: 'IntToStr'`
2. `E2250 There is no overloaded version of 'ShowMessage'`
3. `E2003 Undeclared identifier: 'Exception'`
4. `E2029 '; expected but ':' found`

## ?? �����������:

### ����:
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  CRC32 in 'CRC32.pas';
```

### �����:
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,    // ? ��������� ��� IntToStr, Exception
  CRC32 in 'CRC32.pas';
```

## ?? ����������:
�� �� ��������, ��� ���� � step2 � step3 - � Delphi 12 ����� ���� ���������� `System.SysUtils` ���:
- `IntToStr()` - �������������� ����� � ������
- `Exception` - ��� ��� ��������� ����������
- ���������� ���������� `ShowMessage()`

## ?? ���������:
������ `wbase_simple.dproj` ������ ��������������� ��� ������!

## ?? ������ ������ ��������:
- ? step0_minimal - �����
- ? step1_basic - �����  
- ? step2_crc32 - �����
- ? step3_mystrings - �����
- ?? wbase_simple - ���������, ����� � ������������

## ?? ��������� ��������:
**���������� ����� �������������� wbase_simple.dproj - ��� ����� ������� ������!**
