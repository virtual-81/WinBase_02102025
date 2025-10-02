# ����������� MyPrint.pas - PDF ������ �����������

## ? ��������:
```
F2613 Unit 'PDF' not found
E2003 Undeclared identifier: 'TPDFDocument'
E2003 Undeclared identifier: 'TPDFPageSize'
```

## ?? ������:
������ `PDF` ��� ������� ����������� ��� Delphi 7 � �� ���������� � Delphi 12.

## ? ��������� �������:
���������������� PDF ���������������� ��� �������� ����������:

```pascal
// � uses ������:
uses
  System.SysUtils, Winapi.Windows,Vcl.Printers,System.Classes,Vcl.Graphics{,PDF};

// � �����:
//fPDF: TPDFDocument;  // PDF temporarily disabled for Delphi 12
//fPageSize: TPDFPageSize;  // PDF temporarily disabled for Delphi 12
//procedure set_PageSize(const Value: TPDFPageSize);  // PDF temporarily disabled
```

## ?? ������ ��������:
- ? MyLanguage.pas - ���������
- ? MyReports.pas - ���������  
- ? wbase.dpr - ���������
- ?? **MyPrint.pas - PDF �������� ��������**

## ?? ��������� ��������:
1. **���������� ����� �������������� ������**
2. **��� ������� �������������� PDF ����� ����� ����������� ����������**

���������: ������� �������� �������� ���������� �������!
