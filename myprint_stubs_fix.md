# ��������� ���������� PDF �������� � MyPrint.pas

## ? ���������:

### 1. PDF stub types
- `TPDFPageSize` - �������� ��� �������� ������� PDF
- `TPDFProtectionOption` - �������� ��� ����� ������  
- `TPDFProtectionOptions` - ����� ����� ������
- `TPDFCompressionType` - �������� ��� ����� ������
- `TPDFDocument` - �������� ������ PDF ���������

### 2. Properties �������������
- `PageSize: TPDFPageSize` - ������ ��������
- `PDF: TPDFDocument` - ������ ��������

### 3. ���������� ��������
- `TPDFDocument.Create` - ����������� ��������
- `TMyPrinter.set_PageSize` - ��������� ������� �������� (��������)
- `TMyPrinter.SetPDFOrientation` - ���������� PDF (��������)

### 4. �������������
- `fPDF:= TPDFDocument.Create` � ������������ TMyPrinter
- `fPageSize:= psA4` �������������

## ?? ���������:
������ data.pas ������ ���������������� ��� ������ ��������� � PDF ���������!

## ?? ��������� ���:
**���������� �������������� wbase.dproj �����!**
