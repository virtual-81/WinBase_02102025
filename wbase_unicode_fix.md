# ����������� ��������� ������� - ���� 2

## ? ��������� ��������:

### 1. E2010 Incompatible types: 'PAnsiChar' and 'PWideChar'
**����:** MyLanguage.pas, ������ 168
**��������:** ������������� ANSI ������� � Unicode �������
```pascal
// ����:
hres:= FindResourceA (Instance,PAnsiChar (ResName),RT_RCDATA);

// �����:
hres:= FindResource (Instance,PChar (ResName),RT_RCDATA);
```

### 2. H2443 Inline function not expanded - 'System.Classes' missing
**����:** wbase.dpr
**��������:** ����������� System.Classes � uses
```pascal
uses
  System.SysUtils,
  System.Classes,    // <- ���������
  Winapi.Windows,
  Vcl.Forms,
```

## ? ������ �����������:
- ? �������� System.SysUtils � wbase.dpr
- ? �������� System.Classes � wbase.dpr  
- ? ��������� FindResourceA -> FindResource � MyLanguage.pas

## ?? ��������� ��������:
1. **���������� ����� �������������� ������**
2. **�������� ����������� �������������� ����������� Unicode �������**

��������� ��������� ������ � �������� Unicode!
