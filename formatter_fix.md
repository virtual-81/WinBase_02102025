# ������� �������� � Pascal Formatter

## ?? ��������
��������� "Running Pascal Formatter" � "Skip" � ������ ���� VSCode ��������� �� �������� � ����������� **Pascal Formatter**.

## ? �������

### ������� 1: ��������� ������������������
1. �������� VSCode ��������� (Ctrl+,)
2. ������� "Format On Save"
3. ������� �������
4. ������� "Format On Type" 
5. ������� �������

### ������� 2: �������� ��������� ����������
1. Ctrl+Shift+X (Extensions)
2. ������� "Pascal Formatter"
3. ������� "Disable"
4. ������������� VSCode

### ������� 3: �������� ��������� ����� JSON
�������� ���������� `.vscode/settings.json`:

```json
{
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.detectIndentation": false,
  "editor.formatOnSave": false,
  "editor.formatOnType": false,
  "files.encoding": "windows1251",
  "files.defaultLanguage": "pascal",
  "files.associations": {
    "*.pas": "pascal",
    "*.dpr": "pascal",
    "*.dpk": "pascal",
    "*.dfm": "pascal"
  },
  "search.exclude": {
    "**/*.dcu": true,
    "**/*.~*": true,
    "**/*.identcache": true,
    "**/*.local": true
  }
}
```

## ?? ������ ��� ����������?

Pascal Formatter �������� ������������ ������� `ptop` (Pascal Pretty Printer), �������:
1. ����� ���� �� �����������
2. �� ����� ������������ ��������� ����������� ����������� Delphi
3. ����� �������� � ���������� ������

## ?? ������������

**��� ������� �������� ����� ��������� ������������������** � ��������������� �� ���������� �������. �������������� ����� ��������� �����, ����� ������ ����������.

## ?? ������������ Pascal Formatter

1. **���������� Delphi formatter** - � ����� IDE
2. **OmniPascal** - ����� ���������� ������������
3. **������ ��������������** - ���� ������ �� ��������������

---
**����� ���������� ������ ������� ������������� VSCode (Ctrl+Shift+P ? "Developer: Reload Window")**
