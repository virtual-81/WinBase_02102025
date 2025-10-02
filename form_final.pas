{$a-}
unit form_final;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Grids, Vcl.StdCtrls, Vcl.ExtCtrls, System.Win.Registry,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

// TODO: пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ

type
  TMovementMode= (mmUnknown,mmVert,mmHorz);

  TFinalDialog = class(TForm)
    sgShooters: TStringGrid;
    btnClose: TButton;
    cbShortForm: TCheckBox;
    sgSeries: TStringGrid;
    cbSmart: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgShootersSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    procedure sgShootersKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sgShootersKeyPress(Sender: TObject; var Key: Char);
    procedure cbShortFormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgSeriesKeyPress(Sender: TObject; var Key: Char);
    procedure sgSeriesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    fEvent: TStartListEventItem;
    cw: array [0..4] of integer;
    fFullWidth,fShortWidth: integer;
    fWaitForMove: boolean;
    fMovementMode: TMovementMode;
    fSumStr,fFinalStr: string;
    procedure set_Event(const Value: TStartListEventItem);
    procedure UpdateValues;
    procedure CheckMode;
    procedure UpdateFonts;
    procedure MakeMove;
    procedure SetupNewFinalFormat;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property Event: TStartListEventItem read fEvent write set_Event;
    function Execute: boolean;
    procedure Paint; override;
  end;

implementation

{$R *.dfm}

{ TFinalDialog }

function TFinalDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TFinalDialog.set_Event(const Value: TStartListEventItem);
begin
  fEvent:= Value;
  if fEvent<> nil then
    begin
      fEvent.Shooters.SortOrder:= soSeries;
      // Проверяем, используется ли новый формат финала
      if fEvent.NewFinalFormat then
        begin
          Caption:= Caption + ' - Новый формат (Стадия выбывания + Матч за золото)';
          SetupNewFinalFormat;
        end;
    end;
  UpdateValues;
end;

procedure TFinalDialog.UpdateFonts;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  cbShortForm.ClientHeight:= Canvas.TextHeight ('Mg');
  cbShortForm.ClientWidth:= cbShortForm.Height+8+Canvas.TextWidth (cbShortForm.Caption);
  cbSmart.ClientHeight:= Canvas.TextHeight ('Mg');
  cbSmart.ClientWidth:= cbSmart.Height+8+Canvas.TextWidth (cbSmart.Caption);
  btnClose.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnClose.ClientWidth:= Canvas.TextWidth (btnClose.Caption)+32;
end;

procedure TFinalDialog.UpdateLanguage;
begin
  LoadControlLanguage (Self);
  fSumStr:= Language ['FinalDialog.Sum'];
  fFinalStr:= Language ['FinalDialog.Final'];
end;

procedure TFinalDialog.UpdateValues;
var
  i,j: integer;
  stt: string;
  w,w0,h,h0: integer;
  sh: TStartListEventShooterItem;
begin
  Caption:= format (Language ['FinalDialog'],[fEvent.Event.ShortName,fEvent.Event.Name]);
  if fEvent.Shooters.Count>= fEvent.Event.FinalPlaces then
    sgShooters.RowCount:= fEvent.Event.FinalPlaces
  else
    sgShooters.RowCount:= fEvent.Shooters.Count;
  sgShooters.FixedRows:= 0;
  sgShooters.ColCount:= fEvent.Event.FinalShots;
  sgShooters.FixedCols:= 0;
  for i:= 0 to sgShooters.RowCount-1 do
    begin
      for j:= 0 to fEvent.Event.FinalShots-1 do
        begin
          if j< fEvent.Shooters.Items [i].FinalShotsCount then
            begin
              stt:= fEvent.Event.FinalStr (fEvent.Shooters.Items [i].FinalShots10 [j]);
            end
          else
            stt:= '';
          sgShooters.Cells [j,i]:= stt;
        end;
      sgSeries.Cells [0,i]:= fEvent.Event.FinalStr (fEvent.Shooters.Items [i].FinalResult10);
    end;

  sgSeries.ScrollBars:= ssNone;
  sgSeries.FixedCols:= 0;
  sgSeries.ColCount:= 1;
  sgSeries.FixedRows:= 0;
  sgSeries.RowCount:= sgShooters.RowCount;

  sgShooters.ScrollBars:= ssNone;
  repeat
    sgShooters.Canvas.Font:= sgShooters.Font;
    sgShooters.DefaultRowHeight:= sgShooters.Canvas.TextHeight ('Mg')+4;

    sgSeries.Font:= sgShooters.Font;
    sgSeries.Canvas.Font:= sgSeries.Font;
    sgSeries.DefaultRowHeight:= sgSeries.Canvas.TextHeight ('Mg')+4;
    sgSeries.ColWidths [0]:= sgSeries.Canvas.TextWidth (' 000.0 ');
    sgSeries.ClientWidth:= sgSeries.ColWidths [0]+sgSeries.GridLineWidth;

    Canvas.Font:= sgShooters.Font;
    Canvas.Font.Style:= [];
    sgShooters.Top:= Canvas.TextHeight ('Mg')+8;
    sgSeries.Top:= sgShooters.Top;
    cw [0]:= 0; // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅ
    cw [1]:= 0; // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
    for i:= 0 to sgShooters.RowCount-1 do
      begin
        sh:= fEvent.Shooters.Items [i];
        w:= Canvas.TextWidth (sh.Shooter.SurnameAndName);
        if w> cw [0] then
          cw [0]:= w;
        w:= Canvas.TextWidth (sh.CompetitionStr);
        if w> cw [1] then
          cw [1]:= w;
      end;
    cw [0]:= cw [0]+16;
    cw [1]:= cw [1]+8;
    for i:= 0 to fEvent.Event.FinalShots-1 do
      begin
        sgShooters.ColWidths [i]:= sgShooters.Canvas.TextWidth (' '+fEvent.Event.FinalShotTemplate);
      end;
    if fEvent.Event.EventType<> etRapidFire then
      begin
        cw [2]:= Canvas.TextWidth (fEvent.Event.FinalTemplate)+16;
        if fEvent.Event.CompareByFinal then
          cw [3]:= 0
        else
          cw [3]:= Canvas.TextWidth (fEvent.TotalTemplate)+16;
      end
    else
      begin
        cw [2]:= Canvas.TextWidth (fEvent.Event.FinalTemplate)+16;
        cw [3]:= 0;
      end;

    cw [4]:= 0;
    for i:= 0 to sgShooters.ColCount-1 do
      inc (cw [4],sgShooters.ColWidths [i]+sgShooters.GridLineWidth);
    w0:= Width-ClientWidth+sgShooters.Width-sgShooters.ClientWidth+cw [0]+cw [1]+cw [2]+cw [3]+cw [4]+8;
    if (w0<= Screen.Width-8) or (sgShooters.Font.Size<= 6) then
      begin
        Width:= w0;
        fFullWidth:= w0;
        sgShooters.Left:= cw [0]+cw [1];
        sgSeries.Left:= sgShooters.Left;
        sgShooters.ClientWidth:= cw [4];
      end
    else
      begin
        sgShooters.Font.Size:= sgShooters.Font.Size-1;
        continue;
      end;
    h:= 0;
    for i:= 0 to sgShooters.RowCount-1 do
      inc (h,sgShooters.RowHeights [i]+sgShooters.GridLineWidth);
    h0:= Height-ClientHeight+sgShooters.Height-sgShooters.ClientHeight+h+btnClose.Height+16+
      cbShortForm.Height+2+cbSmart.Height+8+sgShooters.Top;
    if (h0<= Screen.Height) or (sgShooters.Font.Size<= 6) then
      begin
        sgShooters.ClientHeight:= h;
        sgSeries.ClientHeight:= h;
        Height:= h0;
      end
    else
      begin
        sgShooters.Font.Size:= sgShooters.Font.Size-1;
        continue;
      end;
    break;
  until false;

  fShortWidth:= fFullWidth-(sgShooters.Width-sgSeries.Width)-cw [2];

  btnClose.Left:= ClientWidth-btnClose.Width-16;
  btnClose.Top:= ClientHeight-btnClose.Height-8;
  cbSmart.Left:= 16;
  cbSmart.Top:= btnClose.Top-cbSmart.Height-8;
  cbShortForm.Left:= 16;
  cbShortForm.Top:= cbSmart.Top-cbShortForm.Height-2;

  if cbShortForm.Checked then
    Left:= (Screen.Width-fShortWidth) div 2
  else
    Left:= (Screen.Width-fFullWidth) div 2;
  Top:= (Screen.Height - Height) div 2;

  CheckMode;

  if cbShortForm.Checked then
    begin
      sgSeries.Col:= 0;
      sgSeries.Row:= 0;
    end
  else
    begin
      sgShooters.Col:= 0;
      sgShooters.Row:= 0;
    end;

  fMovementMode:= mmUnknown;
  fWaitForMove:= false;
end;

procedure TFinalDialog.sgShootersKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  stt: string;
  i: integer;
  sh: TStartListEventShooterItem;
begin
  case Key of
    VK_ESCAPE: begin
      Key:= 0;
      if sgShooters.EditorMode then
        begin
          sgShooters.EditorMode:= false;
          if sgShooters.Col< fEvent.Shooters.Items [sgShooters.Row].FinalShotsCount then
            begin
              stt:= fEvent.Event.FinalStr (fEvent.Shooters.Items [sgShooters.Row].FinalShots10 [sgShooters.Col]);
            end
          else
            stt:= '';
          sgShooters.Cells [sgShooters.Col,sgShooters.Row]:= stt;
        end
      else
        btnClose.Click;
    end;
    VK_DOWN: begin
      if fWaitForMove then
        begin
          fWaitForMove:= false;
          fMovementMode:= mmVert;
        end;
    end;
    VK_RIGHT: begin
      if fWaitForMove then
        begin
          fWaitForMove:= false;
          fMovementMode:= mmHorz;
        end;
    end;
    VK_DELETE: begin
      if not sgShooters.EditorMode then
        begin
          Key:= 0;
          sh:= fEvent.Shooters.Items [sgShooters.Row];
          if sgShooters.Col< sh.FinalShotsCount then
            begin
              sh.SetFinalShotsCount (sgShooters.Col);
              for i:= sgShooters.Col to sgShooters.ColCount-1 do
                sgShooters.Cells [i,sgShooters.Row]:= '';
              sgSeries.Cells [0,sgShooters.Row]:= fEvent.Event.FinalStr (sh.FinalResult10);
              Invalidate;
            end;
        end;
    end;
  end;
end;

procedure TFinalDialog.sgShootersKeyPress(Sender: TObject; var Key: Char);
var
//  s: TFinalResult;
  s: DWORD;
  stt: string;
  sh: TStartListEventShooterItem;
begin
  case Key of
    #13: begin
      if sgShooters.EditorMode then
        begin
          Key:= #0;
          stt:= Trim (sgShooters.Cells [sgShooters.Col,sgShooters.Row]);
          if (stt<> '') then
            begin
              s:= StrToFinal10 (stt);
              if (s> 109) and (cbSmart.Checked) then
                s:= s div 10;
              if not fEvent.Event.FinalFracs then
                s:= (s div 10)*10;
              sh:= fEvent.Shooters.Items [sgShooters.Row];
              sh.FinalShots10 [sgShooters.Col]:= s;
              stt:= fEvent.Event.FinalStr (s);
              sgSeries.Cells [0,sgShooters.Row]:= fEvent.Event.FinalStr (sh.FinalResult10);
              sgShooters.Cells [sgShooters.Col,sgShooters.Row]:= stt;
              sgShooters.EditorMode:= false;
              MakeMove;
              Invalidate;
            end;
        end;
    end;
  end;
end;

procedure TFinalDialog.sgShootersSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: string);
var
  v: string;
  s: DWORD;
  sh: TStartListEventShooterItem;
begin
  v:= Trim(Value);
  if (v= '') or (not cbSmart.Checked) then
    exit;
  s:= StrToFinal10 (v);
  case fEvent.Event.EventType of
    etRapidFire: begin
      if (s> 0) or (v= '0') then
        begin
          s:= (s div 10)*10;
          sh:= fEvent.Shooters.Items [ARow];
          sh.FinalShots10 [ACol]:= s;
          sgSeries.Cells [0,ARow]:= fEvent.Event.FinalStr (sh.FinalResult10);
          sgShooters.OnSetEditText:= nil;
          sgShooters.Cells [ACol,ARow]:= fEvent.Event.FinalStr (s);
          sgShooters.EditorMode:= false;
          sgShooters.OnSetEditText:= sgShootersSetEditText;
          if fMovementMode= mmUnknown then
            begin
              fMovementMode:= mmHorz;
              fWaitForMove:= false;
            end;
          MakeMove;
          Invalidate;
        end;
    end;
  else
    if fEvent.Event.FinalFracs then
      begin
        if (s> 109) or (v= '00') or (v= '0.0') then
          begin
            s:= s div 10;
            sh:= fEvent.Shooters.Items [ARow];
            sh.FinalShots10 [ACol]:= s;
            sgSeries.Cells [0,ARow]:= fEvent.Event.FinalStr (sh.FinalResult10);
            sgShooters.OnSetEditText:= nil;
            sgShooters.Cells [ACol,ARow]:= fEvent.Event.FinalStr (s);
            sgShooters.EditorMode:= false;
            sgShooters.OnSetEditText:= sgShootersSetEditText;
            if fMovementMode= mmUnknown then
              begin
                fMovementMode:= mmHorz;
                fWaitForMove:= false;
              end;
            MakeMove;
            Invalidate;
          end
        else if (s> 0) and ((v[1]= '0') or (v[1]= '.')) then
          begin
            if v[1]= '0' then
              s:= s div 10;
            sh:= fEvent.Shooters.Items [ARow];
            sh.FinalShots10 [ACol]:= s;
            sgSeries.Cells [0,ARow]:= fEvent.Event.FinalStr (sh.FinalResult10);
            sgShooters.OnSetEditText:= nil;
            sgShooters.Cells [ACol,ARow]:= fEvent.Event.FinalStr (s);
            sgShooters.EditorMode:= false;
            sgShooters.OnSetEditText:= sgShootersSetEditText;
            if fMovementMode= mmUnknown then
              begin
                fMovementMode:= mmHorz;
                fWaitForMove:= false;
              end;
            MakeMove;
            Invalidate;
          end;
      end
    else
      begin
        if (s> 10) or (v= '0') then
          begin
            s:= (s div 10) * 10;
            sh:= fEvent.Shooters.Items [ARow];
            sh.FinalShots10 [ACol]:= s;
            sgSeries.Cells [0,ARow]:= fEvent.Event.FinalStr (sh.FinalResult10);
            sgShooters.OnSetEditText:= nil;
            sgShooters.Cells [ACol,ARow]:= fEvent.Event.FinalStr (s);
            sgShooters.EditorMode:= false;
            sgShooters.OnSetEditText:= sgShootersSetEditText;
            if fMovementMode= mmUnknown then
              begin
                fMovementMode:= mmHorz;
                fWaitForMove:= false;
              end;
            MakeMove;
            Invalidate;
          end;
      end;
  end;
end;

procedure TFinalDialog.Paint;
var
  i: integer;
  stt: string;
  sh: TStartListEventShooterItem;
  y,w,x: integer;
begin
  with Canvas do
    begin
      Font:= sgShooters.Font;
      Font.Style:= [];
      if cbShortForm.Checked then
        begin
          for i:= 0 to sgShooters.RowCount-1 do
            begin
              sh:= fEvent.Shooters.Items [i];
              y:= sgShooters.Top+sgShooters.GridLineWidth+i*(sgShooters.DefaultRowHeight+sgShooters.GridLineWidth)+2;
              stt:= sh.Shooter.SurnameAndName;
              TextOut (8,y,stt);
              stt:= sh.CompetitionStr;
              TextOut (cw [0],y,stt);
              stt:= sh.TotalResultStr;
              w:= TextWidth (stt);
              TextOut (ClientWidth-8-w,y,stt);
            end;
          Font.Size:= 8;
          y:= sgShooters.Top-TextHeight ('Mg')-4;
          if (fEvent.Event.EventType<> etRapidFire) and (not fEvent.Event.CompareByFinal) then
            begin
              TextOut (ClientWidth-8-TextWidth (fSumStr),y,fSumStr);
              TextOut (sgSeries.Left+sgSeries.Width-TextWidth (fFinalStr)-sgSeries.GridLineWidth,y,fFinalStr);
            end
          else
            begin
              TextOut (sgSeries.Left+sgSeries.Width-TextWidth (fFinalStr)-sgSeries.GridLineWidth,y,fFinalStr);
            end;
        end
      else
        begin
          for i:= 0 to sgShooters.RowCount-1 do
            begin
              sh:= fEvent.Shooters.Items [i];
              y:= sgShooters.Top+sgShooters.GridLineWidth+i*(sgShooters.DefaultRowHeight+sgShooters.GridLineWidth)+2;
              stt:= sh.Shooter.SurnameAndName;
              TextOut (8,y,stt);
              stt:= sh.CompetitionStr;
              TextOut (cw [0],y,stt);
              if (fEvent.Event.EventType= etRapidFire) or (fEvent.Event.CompareByFinal) then
                begin
                  stt:= fEvent.Event.FinalStr (sh.FinalResult10);
                  w:= TextWidth (stt);
                  TextOut (ClientWidth-8-w,y,stt);
                end
              else
                begin
                  stt:= fEvent.Event.FinalStr (sh.FinalResult10);
                  w:= TextWidth (stt);
                  TextOut (ClientWidth-cw [3]-w,y,stt);
                  stt:= sh.TotalResultStr;
                  w:= TextWidth (stt);
                  TextOut (ClientWidth-8-w,y,stt);
                end;
            end;
          Font.Size:= 8;
          x:= sgShooters.Left+sgShooters.GridLineWidth;
          y:= sgShooters.Top-TextHeight ('Mg')-4;
          for i:= 0 to sgShooters.ColCount-1 do
            begin
              stt:= IntToStr (i+1);
              w:= TextWidth (stt);
              TextOut (x+(sgShooters.ColWidths [i]-w) div 2,y,stt);
              inc (x,sgShooters.ColWidths [i]+sgShooters.GridLineWidth);
            end;
          if (fEvent.Event.EventType<> etRapidFire) and (not fEvent.Event.CompareByFinal) then
            begin
              TextOut (ClientWidth-8-TextWidth (fSumStr),y,fSumStr);
              TextOut (ClientWidth-cw [3]-TextWidth (fFinalStr),y,fFinalStr);
            end
          else
            begin
              TextOut (ClientWidth-8-TextWidth (fFinalStr),y,fFinalStr);
            end;
        end;
    end;
end;

procedure TFinalDialog.cbShortFormClick(Sender: TObject);
begin
  CheckMode;
end;

procedure TFinalDialog.CheckMode;
begin
  if cbShortForm.Checked then
    begin
      Width:= fShortWidth;
      sgSeries.Visible:= true;
      sgShooters.Visible:= false;
    end
  else
    begin
      if Left+fFullWidth>= Screen.Width then
        Left:= (Screen.Width-fFullWidth) div 2;
      Width:= fFullWidth;
      sgSeries.Visible:= false;
      sgShooters.Visible:= true;
    end;
  btnClose.Left:= ClientWidth-16-btnClose.Width;
  Invalidate;
end;

procedure TFinalDialog.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  try
		Reg.RootKey:= HKEY_CURRENT_USER;
		if Reg.OpenKey ('\Software\007Soft\WinBASE', true) then
      begin
        Reg.WriteBool ('SmartFinal',cbSmart.Checked);
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure TFinalDialog.FormCreate(Sender: TObject);
var
  Reg: TRegistry;
begin
  fFullWidth:= Width;
  fShortWidth:= Width;
  Color:= clBtnFace;
  UpdateLanguage;
  UpdateFonts;
  Reg:= TRegistry.Create;
  try
		Reg.RootKey:= HKEY_CURRENT_USER;
		if Reg.OpenKey ('\Software\007Soft\WinBASE', true) then
      begin
        if Reg.ValueExists ('SmartFinal') then
          cbSmart.Checked:= Reg.ReadBool ('SmartFinal');
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure TFinalDialog.MakeMove;
begin
  case fMovementMode of
    mmUnknown: begin
      fWaitForMove:= true;
    end;
    mmVert: begin
      if sgShooters.Row< sgShooters.RowCount-1 then
        sgShooters.Row:= sgShooters.Row+1
      else
        begin
          if sgShooters.Col< sgShooters.ColCount-1 then
            begin
              sgShooters.Row:= 0;
              sgShooters.Col:= sgShooters.Col+1;
            end;
        end;
    end;
    mmHorz: begin
      if sgShooters.Col< sgShooters.ColCount-1 then
        sgShooters.Col:= sgShooters.Col+1
      else
        begin
          if sgShooters.Row< sgShooters.RowCount-1 then
            begin
              sgShooters.Col:= 0;
              sgShooters.Row:= sgShooters.Row+1;
            end;
        end;
    end;
  end;
end;

procedure TFinalDialog.sgSeriesKeyPress(Sender: TObject; var Key: Char);
var
  stt: string;
  s: DWORD;
  i: integer;
  sh: TStartListEventShooterItem;
begin
  case Key of
    #13: begin
      if sgSeries.EditorMode then
        begin
          Key:= #0;
          stt:= Trim (sgSeries.Cells [0,sgSeries.Row]);
          s:= StrToFinal10 (stt);
          if stt<> '' then
            begin
              if not fEvent.Event.FinalFracs then
                s:= (s div 10)*10;
              sh:= fEvent.Shooters.Items [sgSeries.Row];
              sh.FinalResult10:= s;
              stt:= fEvent.Event.FinalStr (s);
              sgSeries.Cells [0,sgSeries.Row]:= stt;
              sgSeries.EditorMode:= false;
              for i:= 0 to sgShooters.ColCount-1 do
                sgShooters.Cells [i,sgSeries.Row]:= '';
              if sgSeries.Row< sgSeries.RowCount-1 then
                sgSeries.Row:= sgSeries.Row+1;
              Invalidate;
            end;
        end;
    end;
  end;
end;

procedure TFinalDialog.sgSeriesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  stt: string;
begin
  case Key of
    VK_ESCAPE: begin
      Key:= 0;
      if sgSeries.EditorMode then
        begin
          sgSeries.EditorMode:= false;
          stt:= fEvent.Event.FinalStr (fEvent.Shooters.Items [sgSeries.Row].FinalResult10);
          sgSeries.Cells [0,sgSeries.Row]:= stt;
        end
      else
        btnClose.Click;
    end;
  end;
end;

procedure TFinalDialog.SetupNewFinalFormat;
begin
  // Настройка интерфейса для нового формата финала
  // Добавляем колонки для стадии выбывания и матча за золото
  
  // Пока что просто показываем сообщение
  ShowMessage('Новый формат финала активирован!' + #13#10 + 
              'Структура:' + #13#10 +
              '1. Стадия выбывания: 8 участников, 5 серий по 5 выстрелов' + #13#10 +
              '2. Матч за золото: 2 лидера до 16 очков' + #13#10 +
              'Функция в разработке.');
  
  // TODO: Реализовать полный интерфейс нового формата
  // - Стадия выбывания (5 серий по 5 выстрелов)
  // - Матч за золотую медаль (система очков)
end;

end.


