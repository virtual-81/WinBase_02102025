# ?? ����-������ #14: form_startshooters.pas! ??

## ?? ������: form_startshooters.pas
**������:** ? ��������� ���������
**���������:** ������� (������������� ������)
**�����:** ~3 ������ ?

## ?? ��� ����������:

### **1. PDF ? MyPrint (��� ����):**
```pascal
uses PDF, ? uses MyPrint,
```

### **2. System.UITypes + System.Types:**
```pascal
uses
  System.UITypes, System.Types,
```

### **3. Parameter Name Conflicts:**
```pascal
// Interface:
procedure lbShootersDrawItem(...; Rect: TRect; ...);
?
procedure lbShootersDrawItem(...; ARect: TRect; ...);

// Implementation:
procedure TStartListShootersForm.lbShootersDrawItem(...; Rect: TRect; ...);
? 
procedure TStartListShootersForm.lbShootersDrawItem(...; ARect: TRect; ...);
```

### **4. Classes.Rect removal - 8 ����:**
```pascal
// ����:
r:= Classes.Rect (Rect.Left+s.Left+2+dx,Rect.Top,Rect.Left+s.Right-2+dx,Rect.Bottom);

// �����:
r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
```

### **5. Parameter usage - 15+ ����:**
```pascal
// ����:
FillRect (Rect);
TextRect (r,r.Left,Rect.Top+3,fNumSearchStr);

// �����:
FillRect (ARect);
TextRect (r,r.Left,ARect.Top+3,fNumSearchStr);
```

## ? ���������:
```
get_errors form_startshooters.pas = "No errors found" ?
```

## ?? ����������:
- **PDF dependency:** 1 ������ ?
- **System modules:** 2 ���������� ?
- **Parameter conflicts:** 2 declarations + 15+ usages ?
- **Classes.Rect removal:** 8 ���� ?
- **����� �����������:** 25+ ����! ??

---
**����� ������� ����������: 14/74** ??

**������ � 15-�� ������!** ���� �������� �������� ����������! ?
