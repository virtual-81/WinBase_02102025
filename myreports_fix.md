# ����������� MyReports.pas - ������������� System.SysUtils

## ? ��������:
```
E2004 Identifier redeclared: 'System.SysUtils'
```
**����:** MyReports.pas, ������ 189

## ?? ������:
System.SysUtils ��� �������� ������:
- � ������ `interface` (������ 7) ?
- � ������ `implementation` (������ 189) ?

## ? �����������:
������ ������������� System.SysUtils �� ������ implementation:

```pascal
// ����:
implementation
uses System.SysUtils, Types;

// �����:
implementation
uses Types;
```

## ?? ������:
- ? MyLanguage.pas - ��������� (FindResource)
- ? wbase.dpr - ��������� (System.SysUtils, System.Classes)
- ? **MyReports.pas - ��������� (����� ������������� System.SysUtils)**

## ?? ��������� ��������:
**���������� ����� �������������� ������!**

�������� ������ E2004 ������ ���� ����������. �������� ������ �������������� Unicode (W1059).
