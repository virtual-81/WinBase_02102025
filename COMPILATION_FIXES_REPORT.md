# ����� �� ����������� ������ ����������

## ��������
��� ���������� ������� `wbase_synpdf.dproj` ��������� ��������� ������:

```
[dcc32 Error] data.pas(1593): E2029 Identifier expected but 'ARRAY' found
[dcc32 Error] data.pas(1593): E2010 Incompatible types: 'Word' and 'Dynamic array'
[dcc32 Error] data.pas(1594): E2029 Identifier expected but 'ARRAY' found
[dcc32 Error] data.pas(1594): E2010 Incompatible types: 'Word' and 'Dynamic array'
[dcc32 Fatal Error] data.pas(2051): F2063 Could not compile used unit 'wb_barcodes.pas'
```

## ������� ������
������ ��������� ��-�� ������������� ���������� ���������� ������� ��� ������������ �������� � ������ `TStartListEventItem`.

### ������������ ���:
```pascal
property GoldShots1: array of word read fgGoldShots1;
property GoldShots2: array of word read fgGoldShots2;
```

## �������
������� ������������ ���������� ������� �� ���������� � �������������� ���� `TArray<Word>` � �������-��������:

### ������������ ���:
```pascal
// � ���������� ������:
function GetGoldShots1: TArray<Word>;
function GetGoldShots2: TArray<Word>;
property GoldShots1: TArray<Word> read GetGoldShots1;
property GoldShots2: TArray<Word> read GetGoldShots2;

// � ����������:
function TStartListEventItem.GetGoldShots1: TArray<Word>;
begin
  Result := fgGoldShots1;
end;

function TStartListEventItem.GetGoldShots2: TArray<Word>;
begin
  Result := fgGoldShots2;
end;
```

## ���������
- ? �������������� ������ � `data.pas` ����������
- ? ������ ������� �������� ���� ���������� ��� ������
- ? MSBuild �������� "���������� ������� ���������"

## ����������
����������� ���� �� ��������� ��-�� ����������� Community Edition Delphi, ������� �� ������������ ���������� �� ��������� ������. ��� �������� ������������ ����� ����������:
1. ������� ������ � IDE Delphi
2. �������������� ����� ���� Build ��� F9

## ����� ��������
- `data.pas` - ���������� ���������� ������� GoldShots1 � GoldShots2

��� ������ ���������� ������� ���������!