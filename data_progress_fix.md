# �������� ����������� data.pas

## ? ��������� �����������:

### 1. E2030 Duplicate case label (������ 2190)
- **����������:** �������� ������� ���������� � case statement:
  ```pascal
  #128..#175: stt [j]:= chr (ord (stt [j])+64);
  #176..#223: stt [j]:= chr (ord (stt [j])-48);  
  #224..#239: stt [j]:= chr (ord (stt [j])+16);
  ```

### 2. PDF Properties ��������� � TPDFDocument
- `DefaultCharset: Integer`
- `FileName: string` 
- `AutoLaunch: Boolean`
- ����������� ������� �� `Create(AOwner: TObject = nil)`

### 3. PDF ������� �������� �� ��������
- `SaveResultsPDF` - �������� ������ PrintResults
- `SaveResultsPDFInternational` - �������� ������ PrintInternationalResults

## ?? ������ ������:
- ? PageSize/psA4 errors - ����������
- ? PDF property access - ����������  
- ? Duplicate case label - ����������
- ? DefaultCharset/FileName/AutoLaunch - ����������
- ?? PrintPointsTable - �������� ��������
- ?? Declaration differs - �������� ��������

## ?? ��������� ���:
**���������� �������������� wbase.dproj �����!**

����������� ����������� ������ ������ ���� ����������.
