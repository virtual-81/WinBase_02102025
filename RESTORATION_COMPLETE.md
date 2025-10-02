# ?? �������������� ������������ ���������������� ??

## ? **��� �������������:**

### 1. **������� OpenData ���������� � ���������:**
```pascal
// ? ������������� - ������������ ���������:
if not FileExists (FileName) then
  begin
    m:= format (Language ['MainForm.DataFileNotFound'],[AnsiUpperCase (filename)]);
    MessageDlg (m,mtError,[mbOk],0);
    exit;
  end;
```

### 2. **������� ������� CreateNewRussianDatabase:**
- ? ������� ��������� ������� �� Main.pas
- ? ���������� ������� �� private ������
- ? ������������ ���������������� �������������

### 3. **������������ ���� ������ �������������:**
- ? `russia.wbd.korean_backup` ? `russia.wbd`
- ? ��������� ������ �������������

## ?? **��� ��������� ��� �����������:**

### 1. **����������� ��������� � data.pas:**
```pascal
// ? ��������� - ������� ���������:
NEW_DATA_NAME: string= '����� ����';
PROTOCOL_MAKER_SIGN: string= '���������: _________________ (�������, ������)';
DNS_MARK: string= '������';
START_LIST_PAGE_TITLE: string= '��������� ��������';
// ... � ��� ��������� 16 ��������
```

### 2. **�������������� ��������� �������� �����:**
```pascal
// ? ��������� � Main.pas ������ 692-694:
fLanguage := lRussian;
mnuRussian.Checked := true;
mnuEnglish.Checked := false;
```

### 3. **�������� russian.wbl:**
```pascal
// ? ��������� � Main.pas:
if fLanguage = lRussian then
  Language.LoadFromTextFile('russian.wbl')
else
  Language.LoadFromTextFile('english.wbl');
```

## ?? **��������� ������� ���������� �������� �����:**

### 1. **���� russian.wbl �� ������:**
- ��������� ������� ����� � ������� �����
- ��������� ����� ������� � �����

### 2. **�������� ������� MyLanguage �������� �����������:**
- ��������, Language.LoadFromTextFile �� �����������
- ��������, UpdateLanguage �� ����������

### 3. **��������� ���� ������ �������������� ���������:**
- ���� ����� ��������� �������� ���������
- ��� �������� ��������� ���� ���� ����� ������������

## ?? **����������� ��������:**

### ���������:
1. ���������� �� ���� `russian.wbl`
2. ���������� �� `UpdateLanguage` ����� ��������� `fLanguage := lRussian`
3. ����������� �� ���������� �� `russian.wbl` � ������ `Language`
4. ����������� �� �������� � ��������� ����������

---
**? ������������ ���������������� �������������, ����������� ��������� ���������**
