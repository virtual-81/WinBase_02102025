# ����������� ������ � step2_crc32 � step3_mystrings

## ? ��������� ��������:
� `step2_crc32.dpr` � `step3_mystrings.dpr` ������������ ������ `System.SysUtils`

## ?? �����������:

### step2_crc32.dpr
**����:**
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  CRC32 in 'CRC32.pas';
```

**�����:**
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,    // ? ��������� ��� IntToStr � Exception
  CRC32 in 'CRC32.pas';
```

### step3_mystrings.dpr
**����:**
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  MyStrings in 'MyStrings.pas';
```

**�����:**
```pascal
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,    // ? ��������� ��� Exception
  MyStrings in 'MyStrings.pas';
```

## ? �������������:
- ������ ���� `step3_mystrings.dproj` ��� ����������� �������� � Delphi 12

## ?? ��������� ��������:
1. **���������� ����� �������������� step2_crc32.dproj**
2. ���� ������� - ���������� � step3_mystrings.dproj
3. ����� ����� ����������� �������� ������ wbase_simple.dproj

## ?? �����:
�������� �������� ���� � ���������� `System.SysUtils` - ��� ��������� ������, ����������� ���:
- `IntToStr()` - �������������� ����� � ������
- `Exception` - ��� ��� ��������� ����������
- `ShowMessage()` � ����������� ������������
