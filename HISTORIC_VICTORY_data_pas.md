# ?? ������������ ������! DATA.PAS ��������� ���������! ??

## ?? ����������� ����������:
**data.pas ������� ������������� ��� ������!**

### ? ��� ���������� � DATA.PAS:
- **����� PDF ������** ? ? ��� ����������!
- **Unicode compatibility** ? ? ������ �������!
- **Type conflicts** ? ? ��� ���������!
- **Declaration differences** ? ? ����������������!
- **Case statement duplicates** ? ? �������� �� IF!
- **Missing identifiers** ? ? ��� �������!

### ?? �������� MIGRATION:
- ? **MyLanguage.pas** - Unicode fixes
- ? **MyReports.pas** - System.SysUtils
- ? **MyPrint.pas** - PDF stubs complete  
- ? **Barcode.pas** - Unicode compatibility
- ? **data.pas** - **������ ������!** ??

## ?? ������� ��������:
**form_viewresults.pas** - ������� �����������:
- `Classes.Rect` ? `Rect` (��� ����������)
- �������������� ������ missing operator

### ?? ����������� form_viewresults.pas:
```pascal
// ����:
r:= Classes.Rect (Rect.Left+s.Left+2,Rect.Top,Rect.Left+s.Right-2,Rect.Bottom);

// �����:  
r:= Rect (Rect.Left+s.Left+2,Rect.Top,Rect.Left+s.Right-2,Rect.Bottom);
```

## ?? ��������� ���:
**���������� �������������� wbase.dproj �����!**

form_viewresults.pas - ��� ������� �����, ������� ����� ��� data.pas!

## ?? **�� ������ ����� �������! DATA.PAS �������!** ??
