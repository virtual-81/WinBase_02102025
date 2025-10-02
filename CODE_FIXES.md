# ����������� ���� WinBASE

## wb_seriesedit.pas - �������� �����������

### 1. ����� OnEditKeyPress (������ ~323)
```pascal
procedure TShooterSeriesEditor.OnEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    // ������� ��������� ������
    KillEditor(true);
    
    // ��������� ��������� ����� ���������
    if (Event <> nil) and (Event.SeriesPerStage > 0) and (Event.Stages > 0) then
      MoveNext
    else
      CreateEditor; // ����������� �������� ���� ���-�� �� ���
  end;
end;
```

### 2. ����� MoveNext (������ 285)
```pascal
procedure TShooterSeriesEditor.MoveNext;
var
  LocalEvent: TEvent;
begin
  // ��������� ����� ��� ������������
  LocalEvent := Event;
  if (LocalEvent = nil) or (LocalEvent.SeriesPerStage <= 0) or (LocalEvent.Stages <= 0) then
    exit;
    
  try
    inc(fCol);
    if fCol >= LocalEvent.SeriesPerStage then
    begin
      fCol := 0;
      inc(fRow);
      if fRow >= LocalEvent.Stages then
        fRow := 0;
    end;
    CreateEditor;
  except
    // ��� ������ ������������ � ����������� ���������
    fCol := 0;
    fRow := 0;
    CreateEditor;
  end;
end;
```

### 3. ����� KillEditor (������ 219-235)
```pascal
procedure TShooterSeriesEditor.KillEditor(DoCallback: boolean);
var
  idx: integer;
  LocalEvent: TEvent;
begin
  if fEdit = nil then exit;
  
  LocalEvent := Event;
  if (LocalEvent <> nil) and (LocalEvent.SeriesPerStage > 0) and (LocalEvent.Stages > 0) then
  begin
    idx := fRow * LocalEvent.SeriesPerStage + fCol;
    if (idx >= 0) and (idx < Length(fSeries10)) then
    begin
      try
        fSeries10[idx] := StrToFinal10(fEdit.Text);
        if DoCallback and Assigned(fOnChange) then
        begin
          try
            fOnChange(self);
          except
            // ���������� ������ � callback
          end;
        end;
      except
        // ��� ������ ����������� ��������� ������ ��������
      end;
    end;
  end;
  
  fEdit.Free;
  fEdit := nil;
end;
```

## MyLanguage.pas - �����������

### ����� get_ByTag
```pascal
function TMyLanguage.get_ByTag(tag: ansistring): ansistring;
begin
  result := tag; // �� ��������� ���������� ��� ���
  
  if not Assigned(fDictionary) then
    exit;
    
  try
    if fDictionary.ContainsKey(tag) then
      result := fDictionary[tag]
    else
      result := tag; // ���� �� ������, ���������� �������� ���
  except
    result := tag; // ��� ����� ������ ���������� �������� ���
  end;
end;
```

## data.pas - �����������

### ������� StrToFinal10
```pascal
function StrToFinal10(s: string): DWORD;
var
  s1, s2: string;
  v1, v2, n: integer;
  p: integer;
begin
  result := 0;
  
  // ������� �������
  s := trim(s);
  if s = '' then exit;
  
  try
    p := pos('.', s);
    if p = 0 then
    begin
      // ��� ����� - ����� �����
      val(s, v1, n);
      if n = 0 then
        result := v1 * 10;
    end
    else
    begin
      // ���� ����� - ������� �����
      s1 := copy(s, 1, p - 1);
      if s1 = '' then s1 := '0';
      
      s2 := copy(s, p + 1, length(s));
      if length(s2) > 1 then
        s2 := copy(s2, 1, 1); // ������ ������ ����� ����� �����
      if s2 = '' then s2 := '0';
      
      val(s1, v1, n);
      if n = 0 then
      begin
        val(s2, v2, n);
        if n = 0 then
          result := v1 * 10 + v2;
      end;
    end;
  except
    result := 0; // ��� ����� ������ ���������� 0
  end;
end;
```

## �������������� ������������

1. **������������:** ����������� �������������� ���� ��������� �������� (77, 88, 99, 10.5, 9.9)
2. **�����������:** ��� ������������� �������� ����������� � ����������� �����
3. **�����:** ��������� ��������� ����� ����� ����������� �����������
4. **����������:** ��������� ��� ������ ������������� ��� ��������������
