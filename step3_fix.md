# ����������� step3_mystrings.dproj

## ? ��� ����������:

### �������� 1:
```
F1026 File not found: 'step3_mystrings.dpr MyStrings.pas'
```
**����������:** ������� ������ ������ `<DelphiCompile Include="MyStrings.pas"/>` �� .dproj

### �������� 2:
```
E2004 Identifier redeclared: 'HexToByte'
```
**����������:** ������� ������������� ���������� ������� HexToByte � MyStrings.pas

## ?? ���������:
- ? step0_minimal - ��������
- ? step1_basic - ��������  
- ? step2_crc32 - ��������
- ? step3_mystrings - **�����!** ??
- ? wbase_simple.dpr - **�����!** ?? (�������� � CRC32 �������)

## ?? ������� ������ ���������!
**wbase_simple.exe** ������� ������������� � Delphi 12!

## ?? ��������� ��������:
1. **? step3_mystrings.dproj - ��������!**
2. **? wbase_simple.dpr - �����! �������� ������ � CRC32 ��������!**
3. **?? ? wbase.dproj - ������ ������! ��� ������ ����������!**

## ?? ������������� ���������:
**? ��� ������� ������� ������������� � DELPHI 12!**

### ��������� ����������� wbase.dproj:
- ? System.UITypes � System.Types ��������� � form_viewresults.pas
- ? �������� ��������� Rect ? ARect ��������� � form_viewresults.pas
- ? FillRect(ARect) ���������
- ? System.UITypes �������� � form_shooter.pas
- ? IncludeTrailingBackslash ? IncludeTrailingPathDelimiter
- ? PAnsiChar ? PChar (Unicode compatibility)
- ? form_addtostart.pas: �������� ��������� Rect ? ARect ���������
- ? form_addtostart.pas: ��� Rect.Top ? ARect.Top ����������
- ? ��� E2035, E2066, E2010, E2003, E2014 ������ ���������

**?? �������� DELPHI 7 ? 12 ���������! ??**
