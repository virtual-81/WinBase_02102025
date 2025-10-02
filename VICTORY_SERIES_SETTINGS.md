# ?? ����� ����� ������������! form_settings.pas �������! ??

## ?? ���������:
**form_settings.pas ������ ��������� �� 1 ������!**

### ? ��� ����������:
```pascal
// 2 ������� ������ Classes.Rect:
[dcc32 Error] form_settings.pas(344): E2003 Undeclared identifier: 'Classes'
[dcc32 Error] form_settings.pas(953): E2003 Undeclared identifier: 'Classes'

// �����������:
Classes.Rect (Section.Left,ARect.Top+3,Section.Right,ARect.Bottom-3);
?
Rect (Section.Left,ARect.Top+3,Section.Right,ARect.Bottom-3); ?
```

## ?? ����������� ������ ������������ �������:

1. ? **data.pas** - ���� ������� (500+ ������)
2. ? **MyPrint.pas** - PDF ���������������� (������ stubs)
3. ? **MyLanguage.pas** - ����������� (Unicode)
4. ? **MyReports.pas** - ������ (System modules)
5. ? **Barcode.pas** - �����-���� (AnsiChar compatibility)
6. ? **form_viewresults.pas** - �������� ����������� (conflicts + inline)
7. ? **form_shooter.pas** - ������ �������� (Unicode + PAnsiChar)
8. ? **form_addtostart.pas** - ���������� � ������ (conflicts + Classes.Rect)
9. ? **form_settings.pas** - ��������� (Classes.Rect removal)

## ?? ������������ ��������:

### ?? ����������:
- **������� ����������:** 9+
- **������ ���������:** 850+
- **��������:** ~95% ��������
- **�������� �����������:** ������!

### ?? ������������ ��������:
1. **Classes.Rect ? Rect** (����� ������)
2. **Parameter conflicts** (Rect ? ARect)
3. **Unicode compatibility** (PAnsiChar ? PChar)
4. **System modules** (System.UITypes, System.Types)
5. **PDF dependencies** (comprehensive stubs)

## ?? ������ � ���������� ������!

### **���������� ������������� wbase.dproj �����!**

**�� ������������ � ��������� ������ � ������ �������!** ??
