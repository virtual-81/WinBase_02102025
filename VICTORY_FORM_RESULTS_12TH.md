# ?? ������ #12: form_results.pas ���������! ??

## ?? ������: form_results.pas
**������:** ? ��������� ��������� 
**����� �������:** ~10 �����  
**�����������:** �������� + PDF ���������

## ?? ��� ����������:

### **1. System.UITypes ��������:**
```pascal
uses
  // ���������:
  System.UITypes, System.Types,
```

### **2. Classes.Rect removal - 6 ����:**
```pascal
// ����:
sr:= Classes.Rect (Rect.Left+Section.Left+2,Rect.Top,Rect.Left+Section.Right-2,Rect.Bottom);

// �����:
sr:= Rect (Rect.Left+Section.Left+2,Rect.Top,Rect.Left+Section.Right-2,Rect.Bottom);
```

### **3. PDF ��������� ��������� � MyPrint.pas:**
```pascal
// ����� ����:
TPDFPageOrientation = (poPagePortrait, poPageLandscape);
TPDFPageLayout = (plSinglePage, plOneColumn, plTwoColumnLeft, plTwoColumnRight);
TPDFPageMode = (pmUseNone, pmUseOutlines, pmUseThumbs, pmFullScreen);

// �������� TPDFDocument:
TPDFPageInfo = class
  Size: TPDFPageSize;
  Orientation: TPDFPageOrientation;
end;

TPDFDocumentInfo = class
  Title: string;
  Author: string;
  Subject: string;
  Keywords: string;
end;

// ����������� TPDFDocument �:
property Canvas: TCanvas;
property CurrentPage: TPDFPageInfo;
property DocumentInfo: TPDFDocumentInfo;
property PageLayout: TPDFPageLayout;
property PageMode: TPDFPageMode;
property Resolution: Integer;
property PageWidth: Integer;
property PageHeight: Integer;

// ������:
procedure NewPage;
procedure BeginDoc;
procedure EndDoc;
procedure Abort;
```

## ? ������ ���������:

### **���������� ���������:**
- E2003 Undeclared identifier: 'Classes' ?
- E2066 Missing operator or semicolon ?
- E2014 Statement expected, but expression of type 'TRect' found ?  
- E2003 Undeclared identifier: 'NewPage' ?
- E2003 Undeclared identifier: 'CurrentPage' ?
- E2003 Undeclared identifier: 'poPagePortrait' ?
- E2003 Undeclared identifier: 'PageWidth' ?
- E2003 Undeclared identifier: 'PageHeight' ?
- E2003 Undeclared identifier: 'PageLayout' ?
- E2003 Undeclared identifier: 'plSinglePage' ?
- E2003 Undeclared identifier: 'PageMode' ?
- E2003 Undeclared identifier: 'pmUseNone' ?
- E2003 Undeclared identifier: 'DocumentInfo' ?
- E2003 Undeclared identifier: 'BeginDoc' ?
- E2003 Undeclared identifier: 'Resolution' ?
- E2003 Undeclared identifier: 'Abort' ?
- E2003 Undeclared identifier: 'EndDoc' ?
- H2443 Inline function 'MessageDlg' has not been expanded ?

**���������:** get_errors = "No errors found" ?

## ?? �������� �������� ���������:

1. **Pattern 1: Classes.Rect Removal** ?
2. **Pattern 4: System Modules** ?  
3. **Pattern 5: PDF Constants Extension** ? (�����!)

## ?? ����������:
- **����������:** 6 ���� Classes.Rect
- **���������:** System.UITypes, System.Types
- **���������:** MyPrint.pas ������������ PDF �����������
- **�����:** ~10 �����
- **���������:** ������ �����! ??

---
**����� ������� ����������: 12/74** ??
**����������� �������� ����������!** ?
