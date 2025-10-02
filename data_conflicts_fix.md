# ��������� ����������� data.pas

## ? ��������� ����������� �����������:

### 1. Case statement ranges ����������
- ��������� #224..#255 �� ��� ���������:
  - #224..#239: stt [j]:= chr (ord (stt [j])+16);
  - #240..#255: stt [j]:= stt [j]; // Keep unchanged to avoid overflow

### 2. PDF type conflicts ���������
- ������� ������������� ����������� �� data.pas
- ���������� `TPDFDocument = MyPrint.TPDFDocument;` ��� ��������� ����������
- ������� PDF implementations �� data.pas

### 3. Interface/Implementation consistency
- ����������������� PDF ������ � interface section:
  - `SaveResultsPDF (doc: TPDFDocument; ...)`
  - `SaveResultsPDFInternational (doc: TPDFDocument; ...)`

## ?? ��������� ���������:
- ? E2030 Duplicate case label - ������ ���� ����������  
- ? Type compatibility MyPrint vs Data - ����������
- ? E2037 Declaration differs - ����������
- ? PDF property access - ����������

## ?? ������:
������ data.pas ���������� PDF ���� �� MyPrint.pas ��� ����������, interface/implementation ���������, case ranges ���������.

## ?? ��������� ���:
**���������� �������������� wbase.dproj �����!**

��� ������ ������ ����������� ���������� ������!
