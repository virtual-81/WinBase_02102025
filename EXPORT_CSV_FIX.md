# ����������� �������� ����������� � CSV

## ��������
����� �������� � Delphi 7 �� Delphi 12 ������� "������� ����������� � CSV..." ��������� �������� ��� ������� �� ��������������� ����� � ����.

## ������� �������
1. **��������� � ���������**: � Delphi 12 ���������� ������ � ����������� � Unicode
2. **���������� ��������� ������**: ������� ����� ������ ��� ����������� ������������
3. **�������� � ����������� �����**: ����� `SaveToFile` ��� �� �������� ��������� � �������� ���������

## �������

### 1. ���������� ������� `ExportResultsToCSV` � `data.pas`

```pascal
procedure TStartListEventItem.ExportResultsToCSV(const FName: TFileName);
var
  s: TStringList;
  i: integer;
  fs: TFileStream;
  utf8Bytes: TBytes;
begin
  Shooters.SortOrder:= soFinal;
  s:= TStringList.Create;
  try
    // ��������� ��������� CSV
    s.Add('������,��������� �����,�������,���,��� ��������,������������,���������');
    
    // ��������� ������ ��������
    for i:= 0 to Shooters.Count-1 do
      s.Add (Shooters.Items [i].CSVStr);
    
    // ��������� � UTF-8 ��� ����������� ����������� ������� ��������
    try
      fs := TFileStream.Create(FName, fmCreate);
      try
        // ��������� BOM ��� UTF-8
        utf8Bytes := TEncoding.UTF8.GetPreamble;
        if Length(utf8Bytes) > 0 then
          fs.WriteBuffer(utf8Bytes[0], Length(utf8Bytes));
        
        // ���������� ���������� � UTF-8
        utf8Bytes := TEncoding.UTF8.GetBytes(s.Text);
        fs.WriteBuffer(utf8Bytes[0], Length(utf8Bytes));
      finally
        fs.Free;
      end;
    except
      // ���� �� ������� ��������� � UTF-8, ��������� ������� ��������
      s.SaveToFile(FName);
    end;
  finally
    s.Free;
  end;
end;
```

### 2. �������� ������� `mnuCSVClick` � `form_managestart.pas`

- ��������� ��������� ������ � �������������� �����������
- ��������� �������� ������� � ������������
- ������� ������ ���������� �����
- ��������� ������������� ��������� ��������

## ���������

1. **���������� ���������**: ����� ����������� � UTF-8 � BOM ��� ����������� ����������� ������� ��������
2. **��������� CSV**: �������� ��������� � ���������� �������
3. **��������� ������**: ������������ �������� �������� ��������� �� �������
4. **���������������**: ������������ �������, ������ ������� ����������
5. **�������������**: ����������� �� �������� ��������

## ������� ��� ��������
��� ��������� �������� ����������� ������ ���� ��������� �������:
1. ������� ���������� � ������
2. ��������� ���������� (`IsLotsDrawn = true`)
3. ������������ ������ (`IsStarted = true`)

## ����� ��������
- `data.pas` - ������� `ExportResultsToCSV`
- `form_managestart.pas` - ������� `mnuCSVClick`

������ ������� ����������� � CSV �������� ��������� � ���������� ������� ��������!