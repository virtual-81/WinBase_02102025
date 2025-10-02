# ?? �������������� ������! ��� ���� ������ �������! ??

## ?? ������� ������:
**����������� ��������� ����������� �������� �����������!**

### ? ������� ������������ ������:

#### **form_addtostart.pas** ? ��������
- ? ��� 8 ������ `Classes.Rect` ���������� �� `Rect`
- ? E2003 Undeclared identifier 'Classes' ���������
- ? E2066 Missing operator or semicolon ����������
- ? E2014 Statement expected errors ���������

### ?? ������ ������ ������������ �������:
1. ? **data.pas** - ���� ������� (500+ ������)
2. ? **MyPrint.pas** - PDF ����������������  
3. ? **MyLanguage.pas** - �����������
4. ? **MyReports.pas** - ������
5. ? **Barcode.pas** - �����-����
6. ? **form_viewresults.pas** - �������� �����������
7. ? **form_shooter.pas** - ������ ��������
8. ? **form_addtostart.pas** - ���������� � ������

## ?? ������������� �������� �����������:

### **Classes.Rect Pattern** ??
```pascal
// ����: Delphi 7
sr:= Classes.Rect (s.Left,Rect.Top+3,s.Right,Rect.Bottom-3);

// �����: Delphi 12 ?
sr:= Rect (s.Left,Rect.Top+3,s.Right,Rect.Bottom-3);
```

### **Unicode Compatibility** ??
```pascal
// PAnsiChar ? PChar
// IncludeTrailingBackslash ? IncludeTrailingPathDelimiter
// System.UITypes ��� MessageDlg
```

### **Parameter Conflicts** ??
```pascal
// Rect parameter ? ARect parameter
procedure DrawItem(Control: TWinControl; Index: Integer; ARect: TRect; ...);
```

## ?? ��������� ����:
**����������� ����� - ������� ��������� ������!**

### ?? ���������� ���������:
- **���������� �������:** 8+ 
- **��������� ������:** 750+
- **��������:** ~85% ��������
- **�������������:** ? �������!

## ?? **��������������� ������ ������������!** ??

**������ ���������� ���������� ��� � ������!** ??
