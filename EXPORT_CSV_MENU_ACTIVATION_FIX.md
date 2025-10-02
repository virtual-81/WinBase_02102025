# ����������� ��������� ���� �������� CSV

## ��������
����� ���������� ����������� ������ ���� "�������..." ��� ����� ��������������� �������� �����������.

## ���������� �������

### 1. ������������ �������� ������ �������
� ������� `pmEventPopup` �������������� �������� `Length(fEventsData)` ������ `fStart.Events.Count`

### 2. ���������� ���������� ��������� ���� ��� �������������
��� ��������� ���������� �������� `lbEvents.ItemIndex:= 0` �� ���������� ���������� ��������� ����

### 3. ������� ������� ������� ���������
���� ���� ��������� � `lotsdrawn`, ��� ������� ������ ���������� ���� ��������

## ��������� �����������

### 1. ���������� �������� ������ � pmEventPopup

**����: form_managestart.pas**
```pascal
// ����:
if (idx< 0) or (idx>= Length (fEventsData)) then

// �����:
if (idx< 0) or (idx>= fStart.Events.Count) then
```

### 2. ��������� ���������� ������ ������� � lbEventsClick

**����: form_managestart.pas**
```pascal
procedure TManageStartForm.lbEventsClick(Sender: TObject);
var
  idx: integer;
  ev: TStartListEventItem;
begin
  // ��������� ������ ����� ����������� ����
  idx:= lbEvents.ItemIndex;
  if (idx >= 0) and (idx < fStart.Events.Count) then
    begin
      ev:= fStart.Events [idx];
      // ��������� ������ �������
      with fEventsData [idx] do
        begin
          started:= ev.IsStarted;
          lotsdrawn:= ev.IsLotsDrawn;
          rel_count:= ev.Relays.Count;
          pos_count:= ev.PositionsCount;
          comp_completed:= ev.IsCompleted;
          start_no:= ev.StartNumber;
          final_completed:= ev.IsFinalOk;
          saved:= ev.Saved;
          shoot_offs:= ev.Fights;
        end;
    end;
  
  // ��������� ��������� ���� ��� ����� �� ������� ������
  pmEventPopup(pmEvent);
end;
```

### 3. �������� ������ ��������� ���� ��������

**����: form_managestart.pas**
```pascal
// ����:
mnuCSV.Enabled:= fEventsData [idx].lotsdrawn;

// �����:
// ������� CSV �������� ���� ���� ������� ��� ��������
mnuCSV.Enabled:= (ev.Shooters.Count > 0);
```

### 4. ��������� ���������� ���� ��� �������������

**����: form_managestart.pas**
```pascal
// � ������� UpdateStartInfo ���������:
// ��������� ��������� ���� ����� ��������� ���������� ������
lbEventsClick(lbEvents);
```

### 5. ��������� ���������� ���� � UpdateStartListInfo

**����: form_managestart.pas**
```pascal
procedure TManageStartForm.UpdateStartListInfo;
begin
  lName.Caption:= fStart.Info.CaptionText;
  lChamp.Caption:= fStart.Info.ChampionshipName;
  // ... ��������� ��� ...
  Caption:= fStart.Info.CaptionText;
  
  // ��������� ��������� ����
  pmEventPopup(pmEvent);
end;
```

## ������ ������

������ ���� �������� CSV ������������ ��� ��������� ��������:

1. **������� �������** � ������ (idx >= 0 � idx < fStart.Events.Count)
2. **���� �������** ��� �������� (ev.Shooters.Count > 0)

��� ����� ������ ������, ������� ���������:
- �������������� ������ ���������� �� ���������� ����������
- �������������� ������������� ����������
- �������������� ��������� ����������

## �������

��� ������� �������� ��������� ���������� � ��������� ����:
```pascal
Caption:= 'DEBUG: shooters=' + IntToStr(ev.Shooters.Count) + ', lotsdrawn=' + BoolToStr(fEventsData [idx].lotsdrawn, True);
```

��� ������ ����� ������� ����� ������������� �����������������.

## ������������

1. �������� ���������� �������
2. �������� ����� ������� � ������
3. ���������, ��� ���� "������� ����������� � CSV..." ���������� ��������
4. ���������� ������� ��� ������ �������
5. ���������, ��� ��������� ���������� CSV �����