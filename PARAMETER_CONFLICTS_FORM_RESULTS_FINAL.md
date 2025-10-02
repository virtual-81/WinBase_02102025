# ?? ����������� ����������: Parameter Conflicts � form_results.pas! ??

## ?? ��������: �������� ���� ���������� �����!

### ?? ��������:
����� ��������� ����������� **Classes.Rect** � ���������� **PDF ��������**, ���������� **�����** ������� ������ � form_results.pas!

```
[dcc32 Error] form_results.pas(263): E2066 Missing operator or semicolon
[dcc32 Error] form_results.pas(268): E2066 Missing operator or semicolon
[dcc32 Error] form_results.pas(288): E2066 Missing operator or semicolon
[dcc32 Error] form_results.pas(293): E2066 Missing operator or semicolon
[dcc32 Error] form_results.pas(302): E2066 Missing operator or semicolon
[dcc32 Error] form_results.pas(308): E2066 Missing operator or semicolon
```

### ??? �����������:
���������, ��� � ��� **�������� ���� ����������** ����� ����� �� ��� � ������ �������!

```pascal
// ��������:
procedure lbResultsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; ...);
begin
  sr:= Rect (Rect.Left+Section.Left+2,Rect.Top,Rect.Left+Section.Right-2,Rect.Bottom);
  //        ^^^^ ��������! �������� Rect vs ������� Rect()
end;
```

## ? �������: Pattern 2 ��������!

### **1. Declaration Level:**
```pascal
// ����:
procedure lbResultsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; ...);

// �����:
procedure lbResultsDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; ...);
```

### **2. Implementation Level:**
```pascal
// ����:
procedure TShooterResultsForm.lbResultsDrawItem(Control: TWinControl;
	Index: Integer; Rect: TRect; State: TOwnerDrawState);

// �����:
procedure TShooterResultsForm.lbResultsDrawItem(Control: TWinControl;
	Index: Integer; ARect: TRect; State: TOwnerDrawState);
```

### **3. Usage Level - 8 ����:**
```pascal
// ����:
sr:= Rect (Rect.Left+Section.Left+2,Rect.Top,Rect.Left+Section.Right-2,Rect.Bottom);
FillRect (Rect);

// �����:
sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
FillRect (ARect);
```

## ?? ���������� �����������:

### **����� ���������� � lbResultsDrawItem:**
1. Interface declaration: **Rect ? ARect**
2. Implementation declaration: **Rect ? ARect**  
3. Rect function calls: **6 ����** (Rect.Left ? ARect.Left, � �.�.)
4. FillRect calls: **2 �����** (FillRect(Rect) ? FillRect(ARect))

**�����: 10 ���� ����������!**

## ?? ���������:
```
get_errors form_results.pas = "No errors found" ?
```

## ?? ����:
**����������� ���������** - ��� **��������� ��������** � �������� Delphi 7?12! 

**Pattern 2: Parameter Name Conflicts** ������� ���������� � **������** ������ � **DrawItem** �����������!

---
**form_results.pas ������ ������������� 100% ���������!** ??
