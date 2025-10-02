# ��������� ����� �����������

## ��������
������� ��������� ���������� � �������� ������ � ������� � ������ (��������, 101.9). ������������ ������ ������� ���������� � ������ ��������:
- **101,9** - � ������� ��� ������������
- **101.9** - � ������ ��� ������������  
- **1019** - ��� ����������� (��������� ����� - �������)

## �������

### 1. �������� ������� `StrToFinal10` � `data.pas`

������� ������ ������������ ��� ��� ������� �����:

```pascal
function StrToFinal10 (s: string): DWORD;
var
  i,f,n: integer;
  s1, s2: string;
  dotPos, commaPos: integer;
begin
  Result:= 0;
  s:= Trim(s);
  if s = '' then
    Exit;
    
  // ���� ����������� (����� ��� �������)
  dotPos := pos('.', s);
  commaPos := pos(',', s);
  
  // ���� ���� ����� ��� ������� - ������ ��� ����� � ��������
  if (dotPos > 0) or (commaPos > 0) then
    begin
      // ���������� ��� �����������, ������� ������ ������
      if (dotPos > 0) and ((commaPos = 0) or (dotPos < commaPos)) then
        begin
          // ���������� ����� ��� �����������
          s1:= substr(s, '.', 1);
          s2:= substr(s, '.', 2);
        end
      else
        begin
          // ���������� ������� ��� �����������
          s1:= substr(s, ',', 1);
          s2:= substr(s, ',', 2);
        end;
        
      if (s1 <> '') and (s2 <> '') then
        begin
          val(s1, i, n);
          if n = 0 then
            begin
              val(s2, f, n);
              if n = 0 then
                begin
                  // ���� ������� ������ 9, ����� ������ ������ �����
                  if f > 9 then
                    f := f div 10;
                  Result:= i * 10 + f;
                end;
            end;
        end;
    end
  else
    begin
      // ��� ����������� - ��������� ����� �����
      val(s, i, n);
      if n = 0 then  // �������� ���������� ��������������
        begin
          // ���� ����� ������ 999, ������� ��� ��������� ����� - �������
          // ��������: 1019 = 101.9
          if i > 999 then
            Result := i
          else
            Result := i * 10;  // ������� ����� �����
        end;
    end;
end;
```

### 2. �������� ����� `GetCompetition` � `form_inputresult.pas`

����� ������ ��������� ����������, �������� �� ��������� ������� ����:

```pascal
// ��������� ������� ������������ (����� ��� �������) ��� ����� > 999
var text := Trim(edtComp.Text);
var hasDecimalSeparator := (pos('.', text) > 0) or (pos(',', text) > 0);
var isLargeNumber := false;

if not hasDecimalSeparator then
  begin
    var tempVal, tempErr: integer;
    val(text, tempVal, tempErr);
    isLargeNumber := (tempErr = 0) and (tempVal > 999);
  end;

ER.Competition10:= StrToFinal10(text);
ER.fCompetitionWithTens:= hasDecimalSeparator or isLargeNumber;
```

## ������� ������

| ���� ������������ | ��������� | �������� |
|------------------|-----------|----------|
| `101.9` | 1019 | ����� ��� ����������� |
| `101,9` | 1019 | ������� ��� ����������� |
| `1019` | 1019 | ��� ����������� (110-1090 = � ��������) |
| `853` | 853 | ��� ����������� (85.3) |
| `1090` | 1090 | ��� ����������� (109.0) |
| `101` | 1010 | ������� ����� ����� (< 110) |
| `95.8` | 958 | ����� ��� ����������� |
| `95,8` | 958 | ������� ��� ����������� |
| `95` | 950 | ������� ����� ����� (< 110) |

## ����� ��������
- `data.pas` - ������� `StrToFinal10`
- `form_inputresult.pas` - ����� `GetCompetition`

������ ������������ ����� ������� ���������� � ����� ������� �������!