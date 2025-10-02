# ����������� ����������� data.pas

## ? ��������� �����������:

### 1. PDF �������� ��������� � data.pas
- ��������� ������ ���� PDF ����� � data.pas (�� ������� �� MyPrint.pas)
- `TPDFDocument` ����� � ������ ������� properties:
  - DefaultCharset, FileName, AutoLaunch
  - ProtectionEnabled, ProtectionOptions, Compression
  - BeginDoc, EndDoc, NewPage ������

### 2. Case statement ranges ����������  
- �������� #224..#239 �� #224..#255
- ��������� ��������� ����������� ����������

### 3. Conditional compilation
- ������������ {$IFDEF DISABLE_PDF} ��� �������������
- ��� PDF ������� �������� � �������� ����������

## ?? ��������� ���������:
- ? DefaultCharset/FileName/AutoLaunch errors - ������ ���� ����������
- ? Too many actual parameters - ������ ���� ����������  
- ? Duplicate case label - ������ ���� ����������
- ?? Declaration differs - �������� ��������

## ?? ��������� ���:
**���������� �������������� wbase.dproj �����!**

������ data.pas ������ ����� ������ �� ���� PDF �����.
