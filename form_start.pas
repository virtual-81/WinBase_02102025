{$a-}
unit form_start;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls,

  SysFont,
  Data,
  MyStrings,

  MyLanguage,
  ctrl_language,

  SiusData,

  wb_barcodes,
  form_shooterresults;

type
  TStartForm = class(TForm)
    HeaderControl1: THeaderControl;
    lbShooters: TListBox;
    tcRelays: TTabControl;
    procedure HeaderControl1SectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
    procedure FormDestroy(Sender: TObject);
    procedure HeaderControl1Resize(Sender: TObject);
    procedure lbShootersDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure lbShootersDblClick(Sender: TObject);
    procedure lbShootersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbShootersKeyPress(Sender: TObject; var Key: Char);
    procedure lbShootersClick(Sender: TObject);
    procedure tcRelaysChange(Sender: TObject);
  private
    fEvent: TStartListEventItem;
    fRelay: TStartListEventRelayItem;
    fShooters: array of TStartListEventShooterItem;
    fTextY1,fTextY2: integer;
    fSearchStr,fSearchNum: string;
    fDNS1Str: string;
    fSiusData: TSiusDataMonitor;
    procedure UpdateInfo;
    procedure set_Event(const Value: TStartListEventItem);
    procedure FindListShooter (AShooter: TStartListEventShooterItem);
    procedure DoSearchNum (SearchFrom: integer);
    procedure DoSearchStr (SearchFrom: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure WM_StartShootersChanged (var M: TMessage); message WM_STARTLISTSHOOTERSCHANGED;
  public
    property StartEvent: TStartListEventItem read fEvent write set_Event;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

{ TStartForm }

function TStartForm.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TStartForm.set_Event(const Value: TStartListEventItem);
var
  i: integer;
begin
  if fEvent<> nil then
    fEvent.StartList.RemoveNotifier (Handle);
  fEvent:= Value;
  if fEvent<> nil then
    fEvent.StartList.AddNotifier (Handle);
  tcRelays.Tabs.Clear;
  for i:= 0 to fEvent.Relays.Count-1 do
    tcRelays.Tabs.Add (format (RELAY_NO,[i+1]));

  for i:= 0 to fEvent.Relays.Count-1 do
    begin
      fRelay:= fEvent.Relays [i];
      if not fRelay.IsCompleted then
        break;
    end;

  if not fEvent.StartList.StartNumbers then
    HeaderControl1.Sections [1].Free;

  tcRelays.TabIndex:= fRelay.Index;
  UpdateInfo;
end;

procedure TStartForm.UpdateFonts;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbShooters.Canvas.Font:= lbShooters.Font;
  lbShooters.ItemHeight:= lbShooters.Canvas.TextHeight ('Mg')+4;
  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
end;

procedure TStartForm.UpdateInfo;
var
  i: integer;
  sh: TStartListEventShooterItem;
  h1,h2: integer;
begin
  Caption:= format ('%s | %s (%s)',[fEvent.StartList.Info.CaptionText,fEvent.Event.ShortName,fEvent.Event.Name]);
  lbShooters.Clear;
  fEvent.Shooters.SortOrder:= soSeries;
  SetLength (fShooters,0);
  if fRelay<> nil then
    begin
      for i:= 0 to fEvent.Shooters.Count-1 do
        begin
          sh:= fEvent.Shooters.Items [i];
          if sh.Relay= fRelay then
            begin
              SetLength (fShooters,Length (fShooters)+1);
              fShooters [Length (fShooters)-1]:= sh;
              lbShooters.Items.Add (sh.Shooter.Surname+', '+sh.Shooter.Name);
            end;
        end;
    end;
  lbShooters.Canvas.Font:= lbShooters.Font;
  h1:= lbShooters.Canvas.TextHeight ('Mg')+4;
  h2:= (lbShooters.Canvas.TextHeight ('Mg')+2) * fEvent.Event.Stages + 4;
  if h1> h2 then
    begin
      lbShooters.ItemHeight:= h1;
      fTextY2:= 2+((h1-h2) div 2);
      fTextY1:= 2;
    end
  else
    begin
      lbShooters.ItemHeight:= h2;
      fTextY2:= 2;
      fTextY1:= 2+((h2-h1) div 2);
    end;
  if lbShooters.Count> 0 then
    lbShooters.ItemIndex:= 0;
  fSearchStr:= '';
  fSearchNum:= '';
  if Visible then
    lbShooters.SetFocus;
end;

procedure TStartForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
  fDNS1Str:= Language ['DNSPartiallyDefaultStr'];
  LoadControlLanguage (HeaderControl1);
end;

procedure TStartForm.WM_StartShootersChanged(var M: TMessage);
begin
  lbShooters.Refresh;
  M.Result:= LRESULT (true);
end;

procedure TStartForm.FormDestroy(Sender: TObject);
begin
  if fEvent<> nil then
    begin
      fEvent.StartList.RemoveNotifier (Handle);
    end;
  SetLength (fShooters,0);
  fSiusData.Free;
end;

procedure TStartForm.HeaderControl1Resize(Sender: TObject);
begin
  with HeaderControl1 do
    Sections [Sections.Count-1].Width:= HeaderControl1.ClientWidth-
      Sections [Sections.Count-2].Right;
end;

procedure TStartForm.HeaderControl1SectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  lbShooters.Invalidate;
end;

procedure TStartForm.lbShootersDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  sh: TStartListEventShooterItem;
  s: THeaderSection;
  x,h,y,i,j: integer;
  st: string;
  idx: integer;
  font_color: TColor;
  s_idx: integer;
begin
  with lbShooters.Canvas do
    begin
      FillRect (Rect);
      font_color:= Font.Color;
      sh:= fShooters [Index];

      s_idx:= 0;

      s:= HeaderControl1.Sections [s_idx];
      if (fSearchStr<> '') and (odSelected in State) then
        begin
          st:= sh.Shooter.SurnameAndName;
          Font.Style:= [fsBold,fsUnderline];
          Font.Color:= clYellow;
          x:= Rect.Left+s.Left+2;
          TextOut (x,Rect.Top+fTextY1,fSearchStr);
          inc (x,TextWidth (fSearchStr));
          Font.Color:= font_color;
          Font.Style:= [];
          st:= copy (st,Length (fSearchStr)+1,Length (st));
          TextOut (x,Rect.Top+fTextY1,st);
        end
      else
        TextOut (Rect.Left+s.Left+2,Rect.Top+fTextY1,sh.Shooter.SurnameAndName);
      inc (s_idx);

      if fEvent.StartList.StartNumbers then
        begin
          s:= HeaderControl1.Sections [s_idx];
          if (fSearchNum<> '') and (odSelected in State) then
            begin
              st:= sh.StartNumberStr;
              Font.Style:= [fsBold,fsUnderline];
              Font.Color:= clYellow;
              x:= Rect.Left+s.Left+2;
              TextOut (x,Rect.Top+fTextY1,fSearchNum);
              inc (x,TextWidth (fSearchNum));
              Font.Color:= font_color;
              Font.Style:= [];
              st:= copy (st,Length (fSearchNum)+1,Length (st));
              TextOut (x,Rect.Top+fTextY1,st);
            end
          else
            TextOut (Rect.Left+s.Left+2,Rect.Top+fTextY1,sh.StartNumberStr);
          inc (s_idx);
        end;

      s:= HeaderControl1.Sections [s_idx];
      if (not fEvent.StartList.StartNumbers) and (fSearchNum<> '') and (odSelected in State) then
        begin
          st:= IntToStr (sh.Position);
          Font.Style:= [fsBold,fsUnderline];
          Font.Color:= clYellow;
          x:= Rect.Left+s.Left+2;
          TextOut (x,Rect.Top+fTextY1,fSearchNum);
          inc (x,TextWidth (fSearchNum));
          Font.Color:= font_color;
          Font.Style:= [];
          st:= copy (st,Length (fSearchNum)+1,Length (st));
          TextOut (x,Rect.Top+fTextY1,st);
        end
      else
        TextOut (Rect.Left+s.Left+2,Rect.Top+fTextY1,IntToStr (sh.Position));
      inc (s_idx);

      case sh.DNS of
        dnsNone: begin
          s:= HeaderControl1.Sections [s_idx];
          x:= Rect.Left+s.Left+2;
          if sh.SeriesCount> 0 then
            begin
              idx:= 0;
              y:= fTextY2;
//              Font.Size:= Font.Size-2;
              h:= TextHeight ('Mg');
              for i:= 1 to fEvent.Event.Stages do
                begin
                  x:= Rect.Left+s.Left+2;
                  st:= '';
                  Font.Style:= [];
                  for j:= 1 to fEvent.Event.SeriesPerStage do
                    begin
                      inc (idx);
                      if idx> sh.SeriesCount then
                        Font.Color:= clLtGray;
                      st:= sh.SerieStr(i,j);
                      TextOut (x,Rect.Top+y,st);
                      inc (x,TextWidth (fEvent.SerieTemplate+' '));
                    end;
                  Font.Style:= [fsBold];
                  Font.Color:= font_color;
                  if fEvent.Event.Stages> 1 then
                    begin
                      st:= sh.StageResultStr(i);
                      TextOut (x,Rect.Top+y,st);
                      inc (x,TextWidth (fEvent.CompTemplate+' '));
                      if i< fEvent.Event.Stages then
                        inc (y,h);
                    end;
                end;
              st:= sh.TotalResultStr;
              TextOut (x,Rect.Top+fTextY1,st);
            end;
        end;
        dnsCompletely: begin
          s:= HeaderControl1.Sections [s_idx];
          Font.Style:= [];
          x:= Rect.Left+s.Left+2;
          if sh.DNSComment<> '' then
            st:= sh.DNSComment
          else
            st:= DNS_MARK;
          TextOut (x,Rect.Top+fTextY1,st);
        end;
        dnsPartially: begin
          s:= HeaderControl1.Sections [s_idx];
          Font.Style:= [];
          x:= Rect.Left+s.Left+2;

          if sh.SeriesCount> 0 then
            begin
              idx:= 0;
              y:= fTextY2;
              h:= TextHeight ('Mg');
              for i:= 1 to fEvent.Event.Stages do
                begin
                  x:= Rect.Left+s.Left+2;
                  st:= '';
                  Font.Style:= [];
                  for j:= 1 to fEvent.Event.SeriesPerStage do
                    begin
                      inc (idx);
                      if idx> sh.SeriesCount then
                        Font.Color:= clLtGray;
                      st:= sh.SerieStr(i,j);
                      TextOut (x,Rect.Top+y,st);
                      inc (x,TextWidth (fEvent.SerieTemplate+' '));
                    end;
                  Font.Style:= [fsBold];
                  Font.Color:= font_color;
                  if fEvent.Event.Stages> 1 then
                    begin
                      st:= sh.StageResultStr(i);
                      TextOut (x,Rect.Top+y,st);
                      inc (x,TextWidth (fEvent.CompTemplate+' '));
                      if i< fEvent.Event.Stages then
                        inc (y,h);
                    end;
                end;
              st:= sh.TotalResultStr;
              TextOut (x,Rect.Top+fTextY1,st);
              x:= x+TextWidth (st)+10;
            end;

          Font.Style:= [];
          if sh.DNSComment<> '' then
            st:= sh.DNSComment
          else
            st:= fDNS1Str;
          TextOut (x,Rect.Top+fTextY1,st);
        end;
      end;

    end;
end;

procedure TStartForm.FormCreate(Sender: TObject);
begin
  fTextY1:= 2;
  fTextY2:= 2;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TStartForm.lbShootersDblClick(Sender: TObject);
var
  sh: TStartListEventShooterItem;
  sr: TShooterSeriesDialog;
  ti: integer;
begin
  if lbShooters.ItemIndex>= 0 then
    begin
      sh:= fShooters [lbShooters.ItemIndex];
      sr:= TShooterSeriesDialog.Create (self);
      sr.AttributesOn:= false;
      sr.RecordCommentOn:= false;
      sr.CompShootOffOn:= false;
      sr.FinalOn:= false;
      sr.LargeSeriesFont:= true;
      sr.Shooter:= sh;
      sr.Execute;
      sr.Free;
      ti:= lbShooters.TopIndex;
      UpdateInfo;
      lbShooters.TopIndex:= ti;
      FindListShooter (sh);
    end;
end;

procedure TStartForm.lbShootersKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
      Key:= 0;
      if Shift= [] then
        lbShootersDblClick (lbShooters)
      else if Shift= [ssCtrl] then
        begin
          if fSearchStr<> '' then
            DoSearchStr (lbShooters.ItemIndex+1)
          else if fSearchNum<> '' then
            DoSearchNum (lbShooters.ItemIndex+1);
        end;
    end;
    VK_LEFT: begin
      if tcRelays.TabIndex> 0 then
        begin
          tcRelays.TabIndex:= tcRelays.TabIndex-1;
          fRelay:= fEvent.Relays [tcRelays.TabIndex];
          UpdateInfo;
        end;
      Key:= 0;
    end;
    VK_RIGHT: begin
      if tcRelays.TabIndex< fEvent.Relays.Count-1 then
        begin
          tcRelays.TabIndex:= tcRelays.TabIndex+1;
          fRelay:= fEvent.Relays [tcRelays.TabIndex];
          UpdateInfo;
        end;
      Key:= 0;
    end;
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
  end;
end;

procedure TStartForm.FindListShooter(AShooter: TStartListEventShooterItem);
var
  i: integer;
begin
  for i:= 0 to Length (fShooters)-1 do
    if fShooters [i]= AShooter then
      begin
        lbShooters.ItemIndex:= i;
        break;
      end;
end;

procedure TStartForm.lbShootersKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    '0'..'9': begin      // ����� �� �������
      fSearchStr:= '';
      fSearchNum:= fSearchNum+Key;
      DoSearchNum (0);
      Key:= #0;
    end;
    ' ',',','a'..'z','A'..'Z': begin  // ����� �� ��������
      fSearchNum:= '';
      fSearchStr:= fSearchStr+Key;
      DoSearchStr (0);
      Key:= #0;
    end;
    #8: begin
      if fSearchStr<> '' then
        begin
          SetLength (fSearchStr,Length (fSearchStr)-1);
          DoSearchStr (0);
          lbShooters.Invalidate;
        end
      else if fSearchNum<> '' then
        begin
          SetLength (fSearchNum,Length (fSearchNum)-1);
          DoSearchNum (0);
          lbShooters.Invalidate;
        end;
      Key:= #0;
    end;
    '-': begin
      if tcRelays.TabIndex> 0 then
        begin
          tcRelays.TabIndex:= tcRelays.TabIndex-1;
          tcRelaysChange (tcRelays);
        end;
    end;
    '+','=': begin
      if tcRelays.TabIndex< tcRelays.Tabs.Count-1 then
        begin
          tcRelays.TabIndex:= tcRelays.TabIndex+1;
          tcRelaysChange (tcRelays);
        end;
    end;
  end;
end;

procedure TStartForm.lbShootersClick(Sender: TObject);
begin
  if (fSearchStr<> '') or (fSearchNum<> '') then
    begin
      fSearchStr:= '';
      fSearchNum:= '';
      lbShooters.Invalidate;
    end;
end;

procedure TStartForm.DoSearchNum (SearchFrom: integer);
var
  i: integer;
  sh: TStartListEventShooterItem;
  found: integer;
begin
  if fSearchNum= '' then
    exit;
  found:= -1;
  for i:= SearchFrom to Length (fShooters)-1 do
    begin
      sh:= fShooters [i];
      if (fEvent.StartList.StartNumbers) and (copy (sh.StartNumberStr,1,Length (fSearchNum))= fSearchNum) or
         (not fEvent.StartList.StartNumbers) and (copy (IntToStr (sh.Position),1,Length (fSearchNum))= fSearchNum) then
        begin
          found:= i;
          lbShooters.ItemIndex:= i;
          lbShooters.Invalidate;
          break;
        end;
    end;
  if found= -1 then
    SetLength (fSearchNum,Length (fSearchNum)-1);
end;

procedure TStartForm.DoSearchStr (SearchFrom: integer);
var
  i: integer;
  sh: TStartListEventShooterItem;
  found: integer;
begin
  if fSearchStr= '' then
    exit;
  found:= -1;
  for i:= SearchFrom to Length (fShooters)-1 do
    begin
      sh:= fShooters [i];
      if AnsiSameText (copy (sh.Shooter.SurnameAndName,1,Length (fSearchStr)),fSearchStr) then
        begin
          found:= i;
          lbShooters.ItemIndex:= i;
          lbShooters.Invalidate;
          break;
        end;
    end;
  if (SearchFrom> 0) and (found= -1) then
    begin
      for i:= 0 to SearchFrom-1 do
        begin
          sh:= fShooters [i];
          if AnsiSameText (copy (sh.Shooter.SurnameAndName,1,Length (fSearchStr)),fSearchStr) then
            begin
              found:= i;
              lbShooters.ItemIndex:= i;
              lbShooters.Invalidate;
              break;
            end;
        end;
    end;
  if found= -1 then
    SetLength (fSearchStr,Length (fSearchStr)-1);
end;

procedure TStartForm.tcRelaysChange(Sender: TObject);
begin
  fRelay:= fEvent.Relays [tcRelays.TabIndex];
  UpdateInfo;
end;

end.

