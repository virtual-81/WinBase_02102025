# ����������� ��������� ������� wbase.dpr

## ? ������������ ��������:
� �������� ������� `wbase.dpr` ����������� ������ `System.SysUtils`, ������� ���������� ��� Delphi 12.

## ? �����������:
�������� `System.SysUtils` � uses ������ wbase.dpr:

```pascal
uses
  System.SysUtils,  // <- ��������� ��� Delphi 12
  Winapi.Windows,
  Vcl.Forms,
  wb_registry in 'wb_registry.pas',
  data in 'data.pas',
  // ... ��������� ������
```

## ?? ������ ��������:
- ? step0_minimal - ��������
- ? step1_basic - ��������  
- ? step2_crc32 - ��������
- ? step3_mystrings - ��������
- ? wbase_simple - ��������
- ?? **wbase.dpr - ���������! �������� System.SysUtils**

## ?? ��������� ��������:
1. **�������� ������ EULA � Delphi IDE (������� OK)**
2. **���������� ����� �������������� wbase.dproj**
3. **�������� ����������� �������������� ����������� � ������� �������**

�������� ��� �� ������� �����������, ������� ������� ������� ��� ���� �������� ��������!
