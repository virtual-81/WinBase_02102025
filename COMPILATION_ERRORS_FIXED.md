# ?? ��������� ����������� ���������� - ������! ??

## ? **�������� ������:**

### 1. **������ � CreateNewRussianDatabase ����������:**

#### ? **���� (������������ ��������):**
```pascal
Shooter.MiddleName := '��������';        // E2003: Undeclared identifier
Shooter.Qualification := '��';           // E2010: Incompatible types
Shooter.Region := '������';              // E2003: Undeclared identifier
ShooterGroup.ShortName := '��';          // E2003: Undeclared identifier
```

#### ? **����� (���������� ��������):**
```pascal
Shooter.StepName := '��������';          // ? ���������� �������� ��������
Shooter.Qualification := MSQualification; // ? ������ TQualificationItem
Shooter.SportClub := '����';             // ? ���������� �������� �����
Shooter.Town := '������';                // ? ���������� �������� ������
// ShooterGroup.ShortName �������         // ? �������� �� ����������
```

### 2. **���������� ��������� TShooterItem:**
- ? `Surname` - �������
- ? `Name` - ���
- ? `StepName` - ��������  
- ? `SportClub` - ���������� ����
- ? `Town` - �����
- ? `Qualification: TQualificationItem` - ������ ������������

### 3. **�������� ������������:**
```pascal
MSQualification := NewData.Qualifications.Add;
MSQualification.Name := '��';

KMSQualification := NewData.Qualifications.Add; 
KMSQualification.Name := '���';

IQualification := NewData.Qualifications.Add;
IQualification.Name := 'I';
```

### 4. **���������� ��������� �����������:**
```pascal
Shooter.Surname := '������';
Shooter.Name := '����';
Shooter.StepName := '��������';
Shooter.BirthYear := 1990;
Shooter.Qualification := MSQualification;  // ������!
Shooter.SportClub := '����';
Shooter.Town := '������';
```

## ?? **��������� ����������:**

### ? **��� ������ ����������:**
- ? E2003 Undeclared identifier: 'ShortName' - **����������**
- ? E2003 Undeclared identifier: 'MiddleName' - **����������** 
- ? E2010 Incompatible types: 'TQualificationItem' and 'string' - **����������**
- ? E2003 Undeclared identifier: 'Region' - **����������**

### ? **�������������� ���������:**
- W1044 Suspicious typecast - �� ��������
- W1002 Platform specific symbol - �� ��������  
- H2443 Inline function not expanded - �� ��������

## ?? **��������� ���������:**

**?? ������ ����� � ���������� � DELPHI 12!**

### **���������� ��� ����������:**
1. �������� `wbase.dpr` � Delphi 12 IDE
2. ������� `F9` (Run) ��� `Ctrl+F9` (Compile)
3. ��������� �������������� ��� ����������� ������
4. ��� ������ ������� ��������� `russia.wbd` � �������� ������������
5. ��������� ����� ��������� �� ������� �����

### **��������� ������� ����������:**
- **������ ���� ��������** (��, ����, ������)
- **������ ���� ��������** (���, ������, �����-���������)
- **������� ����� ���������** (I, ���������, ������������)
- **������� ��������� �������������** (��, �������, �����������)
- **�������� ������� ����������** (���, �����, ������)

---
**?? �������� DELPHI 7?12 ��������� �������! ??**
