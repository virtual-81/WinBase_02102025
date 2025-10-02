# ����������� ������ ���������� WinBASE

## ��������� ������ � �����������

### 1. ������ � MyStrings.pas
**��������:** ������������� �������� `System.System.` � ������ uses
```pascal
// ���� (�����������):
uses
	System.System.Classes,
  System.System.StrUtils,
  System.System.SysUtils;

// ����� (���������):
uses
	System.Classes,
  System.StrUtils,
  System.SysUtils;
```

### 2. ������ � ctrl_language.pas
**��������:** 
- ���������� �������� ����� �������� � uses
- ������������� `Grids` ��� �������� `Vcl.`

```pascal
// ���� (�����������):
uses
  Winapi.Windows,System.Classes,Vcl.ComCtrls,Vcl.StdCtrls,Vcl.ExtCtrls,Vcl.Forms,Vcl.Controls,Vcl.Dialogs,
  MyLanguage,Vcl.Menus,System.SysUtils,Grids;

// ����� (���������):
uses
  Winapi.Windows, System.Classes, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, 
  Vcl.Forms, Vcl.Controls, Vcl.Dialogs, MyLanguage, Vcl.Menus, 
  System.SysUtils, Vcl.Grids;
```

### 3. ������ � ������� ��������
**��������:** ����������� ������ `System.SysUtils` ��� ������ � ������������

```pascal
// ���� (�����������):
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs;

// ����� (���������):
uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils;  // ��� Exception � ������ ��������� �����
```

## ��������� �����������

### ��� 0: �����-����������� ����
����: `step0_minimal.dpr`
- ������ ShowMessage ��� ��������� ����������
- ������� �������

### ��� 1: ������� ����
����: `step1_basic.dpr`
- ����������� VCL ������
- ������ ����������� ������ Delphi 12

### ��� 2: ���� CRC32
����: `step2_crc32.dpr` 
- ����������� ������ CRC32.pas
- �������� ���������� �������������� �������

### ��� 3: ���� MyStrings
����: `step3_mystrings.dpr`
- ����������� ������������ ������ MyStrings.pas
- �������� ��������� �������

### ��� 4: ����������� ���������� �������
��������� �� ������ ������ � ��������� ����������:
1. calceval.pas
2. wb_registry.pas  
3. MyLanguage.pas
4. ctrl_language.pas

## ������������ �� ���������� �������

1. **������ ���������� ��������** - ���������� ������ �� ������
2. **���������� ������ uses** - ���������� ������������ ���� ��� Delphi 12
3. **���������� ��������� ������** - ������ ���� UTF-8 ��� ANSI
4. **����� ���������� ���� ������** - AnsiString, PChar � �.�.

## ��������� ��������

1. �������� � Delphi 12: `step0_minimal.dpr` - ����� ������� ���� 
2. ���� ������������� - ���������� � `step1_basic.dpr` (� ������������ uses)
3. ���� ������������� - ���������� � `step2_crc32.dpr`
4. ���� ������������� - ���������� � `step3_mystrings.dpr`
5. � ��� ����� �� �������

��� ������� ����� ����������, ����� ������ ������ �������� ������ ����������.
