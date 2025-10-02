unit wb_seriesedit;

interface

uses
  Winapi.Windows,System.Classes,Vcl.Controls,System.SysUtils,Winapi.Messages,Vcl.StdCtrls,
  Vcl.Dialogs,Vcl.Forms,
  Data;

type
  TShooterSeriesEditor= class (TCustomControl)
  private
    fEvent: TEventItem;
    fSeries10: array of DWORD;
    fRow,fCol: integer;
    fCellWidth,fCellHeight: integer;
    fEdit: TEdit;
    fOnChange: TNotifyEvent;
    fWithTens: boolean;
    fTemplate: string;
    fPendingMoveNext: boolean;  // ���� ��� ����������� ��������
    function get_Serie(index: integer): DWORD;
    procedure set_Event(const Value: TEventItem);
    procedure OnFontChange (Sender: TObject);
    procedure UpdateSize;
    function GetCellRect (ACol,ARow: integer): TRect;
    procedure CreateEditor;
    procedure KillEditor (Store: boolean; CallOnChange: boolean = true);
    procedure OnEditKeyPress (Sender: TObject; var Key: Char);
    procedure OnEditExit (Sender: TObject);
    procedure MoveNext;
    procedure DoMoveNext;  // ���������� �������
  protected
    procedure CreateParams (var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;  // ��� ��������� ����������� ��������
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    property Event: TEventItem read fEvent write set_Event;
    procedure SetShooter (AShooter: TStartListEventShooterItem);
    procedure Paint; override;
    property Font;
    function EditorMode: boolean;
    // �������� ������� �������������� (���� �������)
    procedure CommitEditing;
    // ���������� True, ���� �������� ��������� ������ ������� �����
    function IsLastCell: Boolean;
    procedure KeyDown (var Key: word; Shift: TShiftState); override;
    procedure KeyPress (var Key: char); override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure MouseDown (Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;
    procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
    property Series10 [index: integer]: DWORD read get_Serie;
    function Total10: DWORD;
    function TotalStr: string;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

implementation

uses Vcl.Graphics;

const
  WM_CLOSE_SERIES_OK = WM_USER + 1201; // ��������� �����: ������� ������ � mrOk

{ TShooterSeriesEditor }

procedure TShooterSeriesEditor.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
begin
  inherited;
  case Msg.CharCode of
    VK_TAB, VK_RETURN, VK_ESCAPE: Msg.Result:= 0;
  else
    Msg.Result:= 1;
  end;
end;

constructor TShooterSeriesEditor.Create(AOwner: TComponent);
begin
  inherited;
  fEvent:= nil;
  fEdit:= nil;
  SetLength (fSeries10,0);
  TabStop:= true;
  Font.OnChange:= OnFontChange;
  fOnChange:= nil;
  fWithTens:= false;
  fTemplate:= '000.0';
  fPendingMoveNext:= false;  // ������������� �����
end;

procedure TShooterSeriesEditor.CreateEditor;
var
  s: DWORD;
  idx: integer;
begin
  fEdit:= TEdit.Create (self);
  fEdit.Parent:= self;
  fEdit.BoundsRect:= GetCellRect (fCol,fRow);
  fEdit.SetFocus;
  
  // ���������� ���������� ������� � ��������� ������
  if (Event <> nil) and (Event.SeriesPerStage > 0) then
  begin
    idx:= fRow*Event.SeriesPerStage+fCol;
    if (idx >= 0) and (idx < Length(fSeries10)) then
      s:= fSeries10[idx]
    else
      s:= 0;
  end
  else
    s:= 0;
    
  fEdit.Text:= ResultToStr (s,fWithTens);
  fEdit.SelLength:= Length (fEdit.Text);
  fEdit.OnKeyPress:= OnEditKeyPress;
  fEdit.OnExit:= OnEditExit;
end;

procedure TShooterSeriesEditor.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style:= Params.Style or WS_BORDER;
end;

procedure TShooterSeriesEditor.WndProc(var Message: TMessage);
begin
  if Message.Msg = WM_USER + 1 then
  begin
    // ������������ ���������� ������� �� ��������� ������
    try
      // ��������� ������� ��������
      if fEdit <> nil then
        FreeAndNil(fEdit);
      
      // ��������� ��������� �������
      if (Event <> nil) and (Event.SeriesPerStage > 0) and (Event.Stages > 0) then
      begin
        if fCol < Event.SeriesPerStage - 1 then
          fCol := fCol + 1
        else if fRow < Event.Stages - 1 then
        begin
          fCol := 0;
          fRow := fRow + 1;
        end;
        
        // ������� �������� � ����� �������
        CreateEditor;
        
        // ��������������
        Repaint;
      end;
      
    except
      // � ������ ������ �� ������ ������
    end;
    
    Message.Result := 0;
  end
  else
    inherited WndProc(Message);
end;

destructor TShooterSeriesEditor.Destroy;
begin
  try
    if fEdit <> nil then
      FreeAndNil(fEdit);
    SetLength (fSeries10,0);
    fSeries10:= nil;
  except
    on E: Exception do
      ShowMessage('ERROR in Destroy: ' + E.Message);
  end;
  inherited;
end;

procedure TShooterSeriesEditor.DoEnter;
begin
  inherited;
  Invalidate;
end;

procedure TShooterSeriesEditor.DoExit;
begin
  inherited;
  Invalidate;
end;

function TShooterSeriesEditor.EditorMode: boolean;
begin
  Result:= fEdit<> nil;
end;

function TShooterSeriesEditor.GetCellRect(ACol, ARow: integer): TRect;
begin
  Result:= Rect (ACol*(fCellWidth+1),ARow*(fCellHeight+1),(ACol+1)*(fCellWidth+1),(ARow+1)*(fCellHeight+1));
end;

function TShooterSeriesEditor.get_Serie(index: integer): DWORD;
begin
  if (index>= 0) and (index< Length (fSeries10)) then
    Result:= fSeries10 [index]
  else
    Result:= 0;
end;

procedure TShooterSeriesEditor.KeyDown(var Key: word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT: begin
      try
        if EditorMode then
          KillEditor(true, true);
        if (Event <> nil) then
        begin
          if fCol> 0 then
            begin
              fCol:= fCol-1;
              Invalidate;
            end
          else if fRow> 0 then
            begin
              fRow:= fRow-1;
              if Event.SeriesPerStage > 0 then
                fCol:= Event.SeriesPerStage-1;
              Invalidate;
            end;
        end;
      except
        on E: Exception do
          ShowMessage('������ ��� ������� �����: ' + E.Message);
      end;
      Key:= 0;
    end;
    VK_RIGHT, VK_TAB: begin
      try
        if EditorMode then
          KillEditor(true, true);
        // ���������� ������� ������ ��� �� Tab
        if (Event <> nil) and (Event.SeriesPerStage > 0) and (Event.Stages > 0) then
        begin
          if fCol < Event.SeriesPerStage-1 then
            begin
              fCol:= fCol+1;
              Invalidate;
            end
          else if fRow < Event.Stages-1 then
            begin
              fCol:= 0;
              fRow:= fRow+1;
              Invalidate;
            end;
        end;
      except
        on E: Exception do
          ShowMessage('������ ��� ������� ������/Tab: ' + E.Message);
      end;
      Key:= 0;
    end;
    VK_UP: begin
      try
        if EditorMode then
          KillEditor(true, true);
        if (Event <> nil) and (fRow > 0) then
          begin
            fRow:= fRow-1;
            Invalidate;
          end;
      except
        // ���������� ������ ���������
      end;
      Key:= 0;
    end;
    VK_DOWN: begin
      try
        if EditorMode then
          KillEditor(true, true);
        if (Event <> nil) and (Event.Stages > 0) and (fRow < Event.Stages-1) then
          begin
            fRow:= fRow+1;
            Invalidate;
          end;
      except
        // ���������� ������ ���������
      end;
      Key:= 0;
    end;
    VK_HOME: begin
      try
        if EditorMode then
          KillEditor(true, true);
        fRow:= 0;
        fCol:= 0;
        Invalidate;
      except
        // ���������� ������ ���������
      end;
      Key:= 0;
    end;
    VK_END: begin
      try
        if EditorMode then
          KillEditor(true, true);
        if (Event <> nil) and (Event.Stages > 0) and (Event.SeriesPerStage > 0) then
        begin
          fRow:= Event.Stages-1;
          fCol:= Event.SeriesPerStage-1;
          Invalidate;
        end;
      except
        // ���������� ������ ���������
      end;
      Key:= 0;
    end;
    VK_F2: begin
      try
        CreateEditor;
      except
        // ���������� ������ �������� ���������
      end;
      Key:= 0;
    end;
    VK_ESCAPE: begin
      // Esc: ��������� ������� �������������� �, ���� ����� �� ��������� ������, ������� �� �������
      CommitEditing;
      if IsLastCell then
      begin
        var frm := GetParentForm(Self);
        if Assigned(frm) then
          frm.ModalResult := mrOk;
      end;
      Key := 0; // ��������� ���
    end;
  end;
  if Key<> 0 then
    inherited;
end;

procedure TShooterSeriesEditor.KeyPress(var Key: char);
begin
  case Key of
    #13: begin
      // ��� Enter, ���� ��������� ��� ��� � ������ ���, � ��������� ��������� ���
      if not EditorMode then
      begin
        CreateEditor;
        Key := #0;
      end
      else
        Key:= #0; // ��� � ������ �������������� � ������� ����������
    end;
    '0'..'9': begin
      if not EditorMode then
        begin
          CreateEditor;
          fEdit.Text:= Key;
          fEdit.SelStart:= 1;
          fEdit.SelLength:= 0;
        end;
    end;
  end;
  if Key<> #0 then
    inherited;
end;

procedure TShooterSeriesEditor.KillEditor (Store: boolean; CallOnChange: boolean = true);
var
  idx: integer;
  s: DWORD;
begin
  if (fEdit = nil) then Exit;
  
  if Store then
  begin
    try
      if (Event <> nil) and (Event.SeriesPerStage > 0) then
      begin
        idx:= fRow*Event.SeriesPerStage+fCol;
        if (idx >= 0) and (idx < Length(fSeries10)) then
        begin
          s:= StrToFinal10(fEdit.Text);
          if not fWithTens then
            s:= (s div 10)*10;
          fSeries10[idx]:= s;
          
          if CallOnChange and Assigned(fOnChange) then
            fOnChange(self);
        end;
      end;
    except
      // Игнорируем ошибки сохранения
    end;
  end;
  
  FreeAndNil(fEdit);
end;

procedure TShooterSeriesEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if EditorMode then
    KillEditor (true);
    
  // ���������� ���������� ������� � ����������
  if (fCellWidth > 0) and (fCellHeight > 0) then
  begin
    fCol:= X div (fCellWidth+1);
    fRow:= Y div (fCellHeight+1);
    
    // �������� ������
    if (Event <> nil) then
    begin
      if fCol >= Event.SeriesPerStage then
        fCol:= Event.SeriesPerStage - 1;
      if fRow >= Event.Stages then
        fRow:= Event.Stages - 1;
    end;
    
    if fCol < 0 then fCol:= 0;
    if fRow < 0 then fRow:= 0;
  end;
  
  if not Focused then
    SetFocus
  else
    Invalidate;
end;

procedure TShooterSeriesEditor.MoveNext;
var
  localEvent: TEventItem;
begin
  try
    localEvent := Event;  // ��������� ������ ��� ��������� race condition
    if (localEvent <> nil) and (localEvent.SeriesPerStage > 0) and (localEvent.Stages > 0) then
    begin
      if fCol < localEvent.SeriesPerStage-1 then
        begin
          fCol:= fCol+1;
          Invalidate;
        end
      else if fRow < localEvent.Stages-1 then
        begin
          fCol:= 0;
          fRow:= fRow+1;
          Invalidate;
        end;
    end;
  except
    // � ������ ������ �� ������������
  end;
end;

procedure TShooterSeriesEditor.DoMoveNext;
begin
  // ���������� ���������� ������� �� ��������� ������
  if fPendingMoveNext then
  begin
    fPendingMoveNext:= false;
    try
      MoveNext;
      // �� �������� fOnChange ��� �������������� ��������
    except
      // ���������� ������ ��� ��������
    end;
  end;
end;

procedure TShooterSeriesEditor.OnEditExit(Sender: TObject);
begin
  KillEditor (true);
end;

procedure TShooterSeriesEditor.OnEditKeyPress (Sender: TObject; var Key: Char);
begin
  case Key of
    #13, #27: begin
      try
        // ��������� ������� �������� �� ���������
        if (fEdit <> nil) and (Event <> nil) and (Event.SeriesPerStage > 0) then
        begin
          var idx := fRow * Event.SeriesPerStage + fCol;
          if (idx >= 0) and (idx < Length(fSeries10)) then
          begin
            var s := StrToFinal10(fEdit.Text);
            if not fWithTens then
              s := (s div 10) * 10;
            fSeries10[idx] := s;
            if Assigned(fOnChange) then
              fOnChange(self);
          end;
        end;

        // ���� ��������� ������ � ������ ����� ��������� (���������)
        if IsLastCell then
        begin
          var frm := GetParentForm(Self);
          if Assigned(frm) then
            PostMessage(frm.Handle, WM_CLOSE_SERIES_OK, 0, 0);
          Key := #0;
          Exit;
        end;

        // �� ��������� � ������� ������ ����� PostMessage
        PostMessage(Self.Handle, WM_USER + 1, 0, 0);
      except
        // ���������� ������ �������� �����
      end;
      Key := #0; // ��������� ���
    end;
  end;
end;

procedure TShooterSeriesEditor.OnFontChange(Sender: TObject);
begin
  UpdateSize;
end;

function TShooterSeriesEditor.IsLastCell: Boolean;
begin
  Result := False;
  if (Event <> nil) and (Event.SeriesPerStage > 0) and (Event.Stages > 0) then
    Result := (fRow = Event.Stages - 1) and (fCol = Event.SeriesPerStage - 1);
end;

procedure TShooterSeriesEditor.CommitEditing;
begin
  // �������� ������� ��������������, ���� �������
  if EditorMode then
    KillEditor(True, True);
end;

procedure TShooterSeriesEditor.Paint;
var
  i: integer;
  c,r: integer;
  s: string;
  fr,rct: TRect;
begin
  Canvas.Pen.Color:= clGray;
  for i:= 1 to Event.SeriesPerStage-1 do
    begin
      Canvas.MoveTo (i*(fCellWidth+1),0);
      Canvas.LineTo (i*(fCellWidth+1),ClientHeight);
    end;
  for i:= 1 to Event.Stages-1 do
    begin
      Canvas.MoveTo (0,i*(fCellHeight+1));
      Canvas.LineTo (ClientWidth,i*(fCellHeight+1));
    end;
  Canvas.Brush.Style:= bsClear;
  for i:= 0 to Event.TotalSeries-1 do
    begin
      c:= i mod Event.SeriesPerStage;
      r:= i div Event.SeriesPerStage;
      rct:= GetCellRect (c,r);
      if (c= fCol) and (r= fRow) then
        begin
          Canvas.Brush.Style:= bsSolid;
          Canvas.Brush.Color:= clHighlight;
          Canvas.FillRect (rct);
          if Focused then
            begin
              fr:= rct;
              Canvas.DrawFocusRect (fr);
            end;
          Canvas.Brush.Style:= bsClear;
          Canvas.Font.Color:= clHighlightText;
        end
      else
        Canvas.Font.Color:= Font.Color;
      s:= ResultToStr (fSeries10 [i],fWithTens);
      Canvas.TextOut (rct.Left+2,rct.Top+2,s);
    end;
end;

procedure TShooterSeriesEditor.SetShooter(AShooter: TStartListEventShooterItem);
var
  i: integer;
begin
  Event:= AShooter.Event;
  for i:= 0 to Event.TotalSeries-1 do
    fSeries10 [i]:= AShooter.AllSeries10 [i];
  fWithTens:= AShooter.StartEvent.CompetitionWithTens;
  //fTemplate:= AShooter.StartEvent.SerieTemplate;
  fTemplate:= '000.0';
end;

procedure TShooterSeriesEditor.set_Event(const Value: TEventItem);
begin
  try
    fEvent:= Value;
    if (fEvent <> nil) and (fEvent.TotalSeries >= 0) then
      begin
        SetLength (fSeries10,fEvent.TotalSeries);
      end
    else
      begin
        SetLength (fSeries10,0);
      end;
    fCol:= 0;
    fRow:= 0;
    UpdateSize;
  except
    // В случае ошибки устанавливаем безопасные значения
    SetLength (fSeries10,0);
    fCol:= 0;
    fRow:= 0;
  end;
end;

function TShooterSeriesEditor.Total10: DWORD;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Length (fSeries10)-1 do
    Result:= Result+fSeries10 [i];
end;

function TShooterSeriesEditor.TotalStr: string;
var
  t: DWORD;
begin
  t:= Total10;
  if t mod 10= 0 then
    Result:= IntToStr (t div 10)
  else
    Result:= IntToStr (t div 10)+'.'+IntToStr (t mod 10);
end;

procedure TShooterSeriesEditor.UpdateSize;
var
  h,w: integer;
begin
  Canvas.Font:= Font;
  if fEvent<> nil then
    fCellWidth:= Canvas.TextWidth (' '+fTemplate)+4
  else
    fCellWidth:= Canvas.TextWidth (' 000.0')+4;
  fCellHeight:= Canvas.TextHeight ('Mg')+4;
  if Event<> nil then
    begin
      h:= Event.Stages*(fCellHeight+1)-1;
      Height:= h+3;
      w:= Event.SeriesPerStage*(fCellWidth+1)-1;
      Width:= w+3;
    end
  else
    begin
      ClientWidth:= 0;
      ClientHeight:= 0;
    end;
  if Visible then
    Invalidate;
end;

end.

