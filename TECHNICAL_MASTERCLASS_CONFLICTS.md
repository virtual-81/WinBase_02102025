# ?? ����������� ������-�����! �������� ���������� �����! ??

## ?? ������ ����: �������� ���� ����������

### ?? ��������:
```pascal
// � Delphi 7 ��� ��������:
procedure DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; ...);
begin
  sr := Classes.Rect(s.Left, Rect.Top+3, s.Right, Rect.Bottom-3);
end;

// � Delphi 12 ��� �� ��������:
procedure DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; ...);
begin
  sr := Rect(s.Left, Rect.Top+3, s.Right, Rect.Bottom-3);
  //     ^^^^ �������� ����! �������� vs �������
end;
```

### ? �������:
```pascal
// ��������������� ��������:
procedure DrawItem(Control: TWinControl; Index: Integer; ARect: TRect; ...);
begin
  sr := Rect(s.Left, ARect.Top+3, s.Right, ARect.Bottom-3);
  //                 ^^^^^ ������ ��� ��������!
end;
```

## ?? ��� ���������� � form_addtostart.pas:

### **1. Declaration Level:**
```pascal
// Interface:
procedure lbEventsDrawItem(...; ARect: TRect; ...);

// Implementation:  
procedure TAddToStartDialog.lbEventsDrawItem(...; ARect: TRect; ...);
```

### **2. Usage Level:**
```pascal
// ��� 16+ ���� ����������:
FillRect(ARect);  // ? ��������� �����������!
sr := Rect(s.Left, ARect.Top+3, s.Right, ARect.Bottom-3);
r := Rect(ARect.Left+s.Left+2, ARect.Top, ARect.Left+s.Right-2, ARect.Bottom);
TextRect(r, r.Left, ARect.Top+2, text);
```

## ?? ������� ������ �������:

### ? ��������� ������������:
1. **data.pas** - ���� (500+ ������)
2. **MyPrint.pas** - PDF stubs
3. **MyLanguage.pas** - Unicode
4. **MyReports.pas** - System modules
5. **Barcode.pas** - AnsiChar compatibility
6. **form_viewresults.pas** - parameter conflicts + inline functions
7. **form_shooter.pas** - Unicode + PAnsiChar
8. **form_addtostart.pas** - parameter conflicts + Classes.Rect + inline hints
9. **form_settings.pas** - Classes.Rect removal + System modules
10. **form_results.pas** - PDF ? MyPrint dependency fix + Classes.Rect removal
11. **form_stats.pas** - Classes.Rect + parameter conflicts (3 �����)
12. **form_results.pas** - PDF ��������� + Classes.Rect (6 ����) + System.UITypes

## ?? ������������ ��������:

### **Pattern 1: Classes.Rect Removal**
```pascal
Classes.Rect(...) ? Rect(...)
```

### **Pattern 2: Parameter Name Conflicts**
```pascal
Rect: TRect ? ARect: TRect
```

### **Pattern 3: Unicode Compatibility**
```pascal
PAnsiChar ? PChar
IncludeTrailingBackslash ? IncludeTrailingPathDelimiter
```

### **Pattern 4: System Modules**
```pascal
uses System.UITypes, System.Types;
```

## ?? ������ � ���������� ������!

### ?? ��������� �����������:
```pascal
// E2250 There is no overloaded version of 'Rect' 
FillRect (Rect); ? FillRect (ARect); ?
```

**����������� ��������� � �������� �������!** ??

### ?? ���������� form_addtostart.pas:
- **����������:** 16+ ���� ������������� ���������
- **������:** E2066, E2003, E2014, E2250 ? ��� ��������� ?
- **����� �����������:** ~5 �����
- **���������:** ������ �����! ??
