# ����������� Barcode.pas - ������������� System ��������

## ? ��������:
```
F2613 Unit 'System.System.SysUtils' not found.
```

## ?? ������:
� uses ������ Barcode.pas ���� ������������� `System.` ��������:
- `System.System.SysUtils` ? `System.SysUtils`
- `System.System.Classes` ? `System.Classes`  
- `WinApi.Winapi.Windows` ? `Winapi.Windows`
- `Vcl.Vcl.Graphics` ? `Vcl.Graphics`

## ? �����������:
������ ������������� �������� � uses ������.

## ?? �������� ��������:
- ? MyLanguage.pas - ��������� (FindResource)
- ? MyReports.pas - ��������� (System.SysUtils ��������)
- ? MyPrint.pas - ��������� (PDF ��������)
- ? **Barcode.pas - ��������� (������������� ��������)**
- ? wbase.dpr - ��������� (System.SysUtils, System.Classes)

## ?? ������:
**���������� ��������� ������� ������������!** ??
