# ?? ����������� ��������� RUSSIAN.WBL - ������! ??

## ?? **��������� ��������:**

### ? **�������� ���������:**
- ���� `russian.wbl` ��� � ��������� **Windows-1251** (CP1251)
- ��������� �������� ������ ��� ��� **UTF-8**
- ���������: ���������� ������� ������ �������� ������

### ?? **�����������:**
```powershell
# ? ����������� (UTF-8):
Get-Content "russian.wbl" -Encoding UTF8
4,MainForm.pnlGroup.pnlGroupInfo.lEvent=����������:
5,MainForm.pnlGroup.GroupHC.[0]=����

# ? ��������� (CP1251):
[System.IO.File]::ReadAllLines("russian.wbl", [System.Text.Encoding]::GetEncoding(1251))
4,MainForm.pnlGroup.pnlGroupInfo.lEvent=����������:
5,MainForm.pnlGroup.GroupHC.[0]=����
```

## ? **����������� �����������:**

### 1. **������������� ������ ������:**
```powershell
# ������������� russian.wbl: CP1251 ? UTF-8
$content = [System.IO.File]::ReadAllText("russian.wbl", [System.Text.Encoding]::GetEncoding(1251))
[System.IO.File]::WriteAllText("russian.wbl", $content, [System.Text.Encoding]::UTF8)

# ������������� english.wbl: CP1251 ? UTF-8  
$content = [System.IO.File]::ReadAllText("english.wbl", [System.Text.Encoding]::GetEncoding(1251))
[System.IO.File]::WriteAllText("english.wbl", $content, [System.Text.Encoding]::UTF8)
```

### 2. **������������ MyLanguage.pas:**
```pascal
// ? ���� - ������ TextFile:
AssignFile (tf,FName);
Reset (tf);
while not eof (tf) do
  readln (tf,s);

// ? ����� - ����������� TStringList � UTF-8:
sl := TStringList.Create;
sl.LoadFromFile(FName, TEncoding.UTF8);
for i := 0 to sl.Count - 1 do
  s := sl[i];
```

### 3. **���������� ��������� ������:**
```pascal
// ? ������ CloseFile(tf) �� sl.Free
// ? ������������� try-finally ������
// ? ����� �������� ��������� UTF-8
```

## ?? **���������:**

### ? **��� ����������:**
- ?? **russian.wbl** - ������������� � UTF-8 � ���������� ������� �������
- ?? **english.wbl** - ������������� � UTF-8 ��� ���������������  
- ?? **MyLanguage.pas** - �������������� ��� ������ UTF-8
- ?? **���������** - ������ UTF-8 ��� ����� �������

### ? **��������� ���������:**
����� ���������� ��������� ������:
1. ? **���������** ������� �������� �� `russian.wbl`
2. ? **����������** ������� ��������� ���������
3. ? **��������** ���� �� �������: "������", "����������", "����������"
4. ? **���������** ������� �������� �������: "�������, ���", "��� ��������", "������������"

## ?? **���������� ��� ��������:**
1. ������������� ������ � Delphi 12
2. ��������� ���������
3. ��������� ���� - ������ ���� �� ������� �����
4. ��������� ��������� ������� - ������ ���� ��������

---
**?? �������� ��������� ������! ������� ���� ������ ���������! ??**
