{$j+}
unit form_ascor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Winapi.Winsock2, System.Win.Registry, System.UITypes,

  Data,
  SysFont,
  MyLanguage,
  ctrl_language,
  SiusData, Vcl.StdCtrls, Grids, Vcl.ExtCtrls;

type
  TSiusForm = class(TForm)
    lHost: TLabel;
    btnConnect: TButton;
    sgShooters: TStringGrid;
    btnSave: TButton;
    cbHost: TComboBox;
    Timer1: TTimer;
    btnLoad: TButton;
    procedure btnLoadClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbHostKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnSaveClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fAscor: TSiusDataCollector;
    fEvent: TStartListEventItem;
    fFinal: boolean;
    fInvalidated: boolean;
    fShooterIdx: integer;
    procedure set_FinalMode(const Value: boolean);
    procedure set_Event(const Value: TStartListEventItem);
    procedure OnSiusConnect (Sender: TObject);
    procedure OnSiusDisconnect (Sender: TObject);
    procedure OnSiusUpdate (Sender: TObject; idx,phase,group,shot: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure Clear;
    procedure OnRequestShooter (Sender: TObject; startno: integer; out Shooter: TObject);
//    procedure ClearTable;
//    procedure InitFinalTable;
    procedure LoadSiusDataFromFile;
    procedure UpdateTable;
    procedure UpdateFinalTable;
    procedure UpdateCompetitionTable;
    procedure SaveFinal;
    procedure SaveCompetition;
  public
    property StartEvent: TStartListEventItem read fEvent write set_Event;
    property FinalMode: boolean read fFinal write set_FinalMode;
    function Execute: boolean;
  end;

const
  Global_GetInnerTensFromAscor: boolean= true;

implementation

{$R *.dfm}

{ TSiusForm }

procedure TSiusForm.btnConnectClick(Sender: TObject);
begin
  fAscor.SiusData.Host:= cbHost.Text;
  fAscor.SiusData.Active:= true;
  btnConnect.Enabled:= false;
  cbHost.Enabled:= false;
end;

procedure TSiusForm.btnLoadClick(Sender: TObject);
begin
  LoadSiusDataFromFile;
end;

procedure TSiusForm.btnSaveClick(Sender: TObject);
begin
  if fFinal then
    SaveFinal
  else
    SaveCompetition;
  btnSave.Enabled:= false;
end;

procedure TSiusForm.cbHostKeyPress(Sender: TObject; var Key: Char);
begin
  if Key= #13 then
    begin
      btnConnect.Click;
      Key:= #0;
    end;
end;

procedure TSiusForm.Clear;
var
  i: integer;
begin
  for i:= 0 to fAscor.Shooters.Count-1 do
    fAscor.Shooters.Shooters [i].Clear;
  fInvalidated:= true;
  fShooterIdx:= -1;
  UpdateTable;
end;

function TSiusForm.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TSiusForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Reg: TRegistry;
begin
  fAscor.SiusData.Active:= false;
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey ('\Software\007Soft\WinBASE',true) then
      begin
        Reg.WriteString ('SiusHosts',cbHost.Items.Text);
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure TSiusForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  res: integer;
begin
  if btnSave.Enabled then
    begin
      res:= MessageDlg (Language ['SAVE_SIUS_DATA_PROMPT'],mtConfirmation,[mbYes,mbNo,mbCancel],0);
      case res of
        idYes: begin
          btnSaveClick (btnSave);
          CanClose:= true;
        end;
        idNo: CanClose:= true;
        idCancel: CanClose:= false;
      end;
    end
  else
    CanClose:= true;
end;

procedure TSiusForm.FormCreate(Sender: TObject);
var
  HostName: Array[0..MAX_PATH] of AnsiChar;
  Reg: TRegistry;
begin
  fAscor:= TSiusDataCollector.Create;
  fAscor.Shooters.OnRequestData:= OnRequestShooter;
  fAscor.OnConnect:= OnSiusConnect;
  fAscor.OnDisconnect:= OnSiusDisconnect;
  fAscor.OnUpdate:= OnSiusUpdate;
  cbHost.Clear;
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey ('\Software\007Soft\WinBASE',false) then
      begin
        if Reg.ValueExists ('SiusHosts') then
          cbHost.Items.Text:= Reg.ReadString ('SiusHosts');
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
  if cbHost.Items.Count> 0 then
    cbHost.ItemIndex:= 0
  else
    begin
      if gethostname (HostName,MAX_PATH)= 0 then
        cbHost.Text:= string(HostName);
    end;
  UpdateLanguage;
  UpdateFonts;
  Width:= round (Screen.Width * 0.75);
  Height:= round (Screen.Height * 0.75);
  Position:= poScreenCenter;
  fInvalidated:= true;
  fShooterIdx:= -1;
end;

procedure TSiusForm.FormDestroy(Sender: TObject);
begin
  fAscor.Free;
end;

procedure TSiusForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F3: begin
      Key:= 0;
      LoadSiusDataFromFile;
    end;
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
  end;
end;

procedure TSiusForm.FormResize(Sender: TObject);
begin
  sgShooters.Height:= ClientHeight-4-sgShooters.Top;
  sgShooters.Width:= ClientWidth-4-sgShooters.Left;
  btnSave.Left:= ClientWidth-4-btnSave.Width;
end;

procedure TSiusForm.LoadSiusDataFromFile;
var
  od: TOpenDialog;
  s: TStringList;
begin
  if fAscor.SiusData.Connected then
    exit;
  od:= TOpenDialog.Create (self);
  try
    od.Title:= Language ['Open_SiusData_From_File'];
    od.DefaultExt:= '*.siusdata';
    od.Filter:= '*.siusdata|*.siusdata';
    od.FilterIndex:= 0;
    od.Options:= [ofPathMustExist,ofNoChangeDir,ofFileMustExist,ofEnableSizing,ofDontAddToRecent];
    if od.Execute then
      begin
        s:= TStringList.Create;
        try
          s.LoadFromFile (od.FileName);
//          Clear;
          fAscor.SiusData.Simulate (s);
          fInvalidated:= true;
          fShooterIdx:= -1;
          UpdateTable;
        finally
          s.Free;
        end;
      end;
  finally
    od.Free;
  end;
end;

procedure TSiusForm.OnRequestShooter(Sender: TObject; startno: integer; out Shooter: TObject);
begin
  Shooter:= fEvent.FindShooter (startno);
end;

procedure TSiusForm.OnSiusConnect(Sender: TObject);
var
  i: integer;
  found: boolean;
begin
  found:= false;
  for i:= 0 to cbHost.Items.Count-1 do
    if AnsiSameText (cbHost.Items [i],cbHost.Text) then
      begin
        found:= true;
        break;
      end;
  if not found then
    begin
      cbHost.Items.Insert (0,cbHost.Text);
      cbHost.ItemIndex:= 0;
    end;
  Clear;
  Timer1.Enabled:= true;
  fInvalidated:= true;
  fShooterIdx:= -1;
end;

procedure TSiusForm.OnSiusDisconnect(Sender: TObject);
begin
  btnConnect.Enabled:= true;
  cbHost.Enabled:= true;
end;

procedure TSiusForm.OnSiusUpdate(Sender: TObject; idx,phase,group,shot: integer);
begin
  btnSave.Enabled:= true;
  fInvalidated:= true;
  fShooterIdx:= idx;
end;

procedure TSiusForm.SaveCompetition;
var
  i: integer;
  ssh: TStartListEventShooterItem;
  sh: TLaneShooter;
  phase: TSiusPhase;
  sc: DWORD;
  se: integer;
  gr1,gr2: TSiusGroup;
  phase_idx: integer;
  stage_idx: integer;
begin
  for i:= 0 to fAscor.Shooters.Count-1 do
    begin
      sh:= fAscor.Shooters.Shooters [i];
      if not sh.Changed then
        continue;
      ssh:= sh.DataObject as TStartListEventShooterItem;
      if ssh= nil then
        continue;
      ssh.CompShootOffStr:= '';
      if not Global_GetInnerTensFromAscor then
        ssh.InnerTens:= 0;
      phase_idx:= 0;
      stage_idx:= 0;
      while phase_idx< sh.PhasesCount do
        begin
          phase:= nil;
          while (phase= nil) and (phase_idx< sh.PhasesCount) do
            begin
              phase:= sh.Phases [phase_idx];
              if phase.GroupsCount> 0 then
                break;
              phase:= nil;
              inc (phase_idx);
            end;
          for se:= 0 to fEvent.Event.SeriesPerStage-1 do
            begin
              if phase<> nil then
                begin
                  case fEvent.Event.EventType of
                    etRegular,etThreePosition2013: begin
                      gr1:= phase.Groups [se];
                      if (gr1<> nil) and (gr1.ShotsCount> 0) then
                        begin
                          if Global_GetInnerTensFromAscor then
                            begin
                              if ssh.Series10 [stage_idx+1,se+1]= 0 then
                                ssh.InnerTens:= ssh.InnerTens+gr1.InnerTens;
                            end;
                          if fEvent.CompetitionWithTens then
                            ssh.Series10 [stage_idx+1,se+1]:= gr1.PriSum
                          else
                            ssh.Series10 [stage_idx+1,se+1]:= gr1.PriSum * 10;
                        end;
                    end;
                    etRapidFire,etCenterFire,etCenterFire2013: begin
                      gr1:= phase.Groups [se*2];
                      gr2:= phase.Groups [se*2+1];
                      if ((gr1<> nil) and (gr1.ShotsCount> 0)) or
                        ((gr2<> nil) and (gr2.ShotsCount> 0)) then
                        begin
                          sc:= 0;
                          if gr1<> nil then
                            sc:= sc+gr1.PriSum;
                          if gr2<> nil then
                            sc:= sc+gr2.PriSum;
                          if Global_GetInnerTensFromAscor then
                            begin
                              if ssh.Series10 [stage_idx+1,se+1]= 0 then
                                begin
                                  if gr1<> nil then
                                    ssh.InnerTens:= ssh.InnerTens+gr1.InnerTens;
                                  if gr2<> nil then
                                    ssh.InnerTens:= ssh.InnerTens+gr2.InnerTens;
                                end;
                            end;
                          if fEvent.CompetitionWithTens then
                            ssh.Series10 [stage_idx+1,se+1]:= sc
                          else
                            ssh.Series10 [stage_idx+1,se+1]:= sc * 10;
                        end;
                    end;
                  end;
                end;
            end;
          inc (phase_idx);
          inc (stage_idx);
        end;
    end;
end;

procedure TSiusForm.SaveFinal;
var
  i,j: integer;
  ssh: TStartListEventShooterItem;
  sh: TLaneShooter;
  sidx: integer;
  s: string;
  ph,gr: integer;
  phase: TSiusPhase;
  group: TSiusGroup;
  sc: integer;
begin
  for i:= 0 to fAscor.Shooters.Count-1 do
    begin
      sh:= fAscor.Shooters.Shooters [i];
      ssh:= sh.DataObject as TStartListEventShooterItem;
      if ssh= nil then
        continue;
      ssh.ResetFinal;
      ssh.FinalShootOffStr:= '';
      sidx:= 0;
      for ph:= 0 to sh.PhasesCount-1 do
        begin
          phase:= sh.Phases [ph];
          for gr:= 0 to phase.GroupsCount-1 do
            begin
              group:= phase.Groups [gr];
              for j:= 0 to group.ShotsCount-1 do
                begin
                  sc:= group.Shots [j]._priscore;
                  if sidx< fEvent.Event.FinalShots then
                    begin
                      ssh.FinalShots10 [sidx]:= sc;
                    end
                  else
                    begin
                      if ssh.FinalShootOffStr<> '' then
                        ssh.FinalShootOffStr:= ssh.FinalShootOffStr+'+';
                      if fEvent.Event.FinalFracs then
                        s:= format ('%d.%d',[sc div 10,sc mod 10])
                      else
                        s:= format ('%d',[sc]);
                      ssh.FinalShootOffStr:= ssh.FinalShootOffStr+s;
                    end;
                  inc (sidx);
                end;
            end;
        end;
    end;
end;

procedure TSiusForm.set_Event(const Value: TStartListEventItem);
var
  i,fc: integer;
  sh: TStartListEventShooterItem;
begin
  fEvent:= Value;
  Clear;
  if fFinal then
    begin
      fc:= fEvent.Event.FinalPlaces;
      if fEvent.Shooters.Count< fc then
        fc:= fEvent.Shooters.Count;
      fAscor.Shooters.AutoAdd:= false;
      fEvent.Shooters.SortOrder:= soSeries;
      for i:= 0 to fc-1 do
        begin
          sh:= fEvent.Shooters.Items [i];
          fAscor.Shooters.Add (sh.StartNumber);
        end;
    end
  else
    begin
      fAscor.Shooters.AutoAdd:= false;
      fEvent.Shooters.SortOrder:= soPosition;
      for i:= 0 to fEvent.Shooters.Count-1 do
        begin
          sh:= fEvent.Shooters.Items [i];
          fAscor.Shooters.Add (sh.StartNumber);
        end;
    end;
  fInvalidated:= true;
  fShooterIdx:= -1;
  UpdateTable;
  btnSave.Enabled:= false;
end;

procedure TSiusForm.set_FinalMode(const Value: boolean);
begin
  fFinal:= Value;
  if fEvent<> nil then
    set_Event (fEvent);
end;

procedure TSiusForm.Timer1Timer(Sender: TObject);
begin
  if fInvalidated then
    UpdateTable;
end;

procedure TSiusForm.UpdateCompetitionTable;
var
  i,j: integer;
  maxshots: integer;
  sc: integer;
  nw,tw: integer;
  sh: TLaneShooter;
  ssh: TStartListEventShooterItem;
  s: string;
  sidx,gr,ph: integer;
  phase: TSiusPhase;
  group: TSiusGroup;
  rs: string;
begin
  if fAscor.Shooters.Count= 0 then
    begin
      sgShooters.RowCount:= 2;
      sgShooters.FixedRows:= 1;
      sgShooters.ColCount:= 4;
      sgShooters.FixedCols:= 3;
      for i:= 0 to sgShooters.ColCount-1 do
        for j:= 0 to sgShooters.RowCount-1 do
          sgShooters.Cells [i,j]:= '';
      exit;
    end;
  sgShooters.RowCount:= fAscor.Shooters.Count+1;
  maxshots:= 0;
  for i:= 0 to fAscor.Shooters.Count-1 do
    begin
      sc:= fAscor.Shooters.Shooters [i].ShotsCount;
      if sc> maxshots then
        maxshots:= sc;
    end;
  if maxshots= 0 then
    sgShooters.ColCount:= sgShooters.FixedCols+1
  else
    sgShooters.ColCount:= sgShooters.FixedCols+maxshots;
  for i:= sgShooters.FixedCols to sgShooters.ColCount-1 do
    begin
      sgShooters.ColWidths [i]:= sgShooters.Canvas.TextWidth (fEvent.SerieTemplate)+sgShooters.GridLineWidth+8;
      sgShooters.Cells [i,0]:= IntToStr (i-sgShooters.FixedCols+1);
    end;
  nw:= 0;
  for i:= 0 to fAscor.Shooters.Count-1 do
    begin
      sh:= fAscor.Shooters.Shooters [i];
      ssh:= sh.DataObject as TStartListEventShooterItem;
      // header
      if ssh<> nil then
        begin
          // start number
          sgShooters.Cells [0,i+1]:= ssh.StartNumberStr;
          // surname and name
          s:= ssh.Shooter.SurnameAndName;
          tw:= sgShooters.Canvas.TextWidth (s);
          if tw> nw then
            nw:= tw;
          sgShooters.Cells [1,i+1]:= s;
        end
      else
        begin
          // start number
          sgShooters.Cells [0,i+1]:= IntToStr (sh.StartNo);
          // surname and name
          s:= sh.Name;
          tw:= sgShooters.Canvas.TextWidth (s);
          if tw> nw then
            nw:= tw;
          sgShooters.Cells [1,i+1]:= s;
        end;
      // sum
      if fEvent.CompetitionWithTens then
        sc:= sh.PriSum
      else
        sc:= sh.PriSum*10;
      sgShooters.Cells [2,i+1]:= fEvent.CompetitionStr (sc);
      sidx:= 0;
      for ph:= 0 to sh.PhasesCount-1 do
        begin
          phase:= sh.Phases [ph];
          for gr:= 0 to phase.GroupsCount-1 do
            begin
              group:= phase.Groups [gr];
              for j:= 0 to group.ShotsCount-1 do
                begin
                  sc:= group.Shots [j]._priscore;
                  if not fEvent.CompetitionWithTens then
                    sc:= sc * 10;
                  rs:= fEvent.CompetitionStr (sc);
                  if group.Shots [j]._innerten then
                    rs:= rs+'*';
                  sgShooters.Cells [sgShooters.FixedCols+sidx,i+1]:= rs;
                  inc (sidx);
                end;
            end;
        end;
    end;
  sgShooters.ColWidths [0]:= sgShooters.Canvas.TextWidth ('00000')+sgShooters.GridLineWidth+8;
  sgShooters.ColWidths [1]:= nw+sgShooters.GridLineWidth+8;
  sgShooters.ColWidths [2]:= sgShooters.Canvas.TextWidth (fEvent.CompTemplate)+sgShooters.GridLineWidth+8;
end;

procedure TSiusForm.UpdateFinalTable;
var
  i,j,ph,gr,sidx,maxshots,sc: integer;
  sh: TLaneShooter;
  ssh: TStartListEventShooterItem;
  s: string;
  tw,nw: integer;
  phase: TSiusPhase;
  group: TSiusGroup;
begin
  if fAscor.Shooters.Count= 0 then
    begin
      sgShooters.RowCount:= 2;
      sgShooters.FixedRows:= 1;
      sgShooters.ColCount:= 6;
      sgShooters.FixedCols:= 5;
      for i:= 0 to sgShooters.ColCount-1 do
        for j:= 0 to sgShooters.RowCount-1 do
          sgShooters.Cells [i,j]:= '';
      exit;
    end;
  sgShooters.RowCount:= fAscor.Shooters.Count+1;
  maxshots:= 0;
  for i:= 0 to fAscor.Shooters.Count-1 do
    begin
      sc:= fAscor.Shooters.Shooters [i].ShotsCount;
      if sc> maxshots then
        maxshots:= sc;
    end;
  if maxshots= 0 then
    sgShooters.ColCount:= 5+1
  else
    sgShooters.ColCount:= 5+maxshots;
  for i:= sgShooters.FixedCols to sgShooters.ColCount-1 do
    begin
      sgShooters.ColWidths [i]:= sgShooters.Canvas.TextWidth (fEvent.Event.FinalShotTemplate)+sgShooters.GridLineWidth+8;
      sgShooters.Cells [i,0]:= IntToStr (i-sgShooters.FixedCols+1);
    end;
  nw:= 0;
  for i:= 0 to fAscor.Shooters.Count-1 do
    begin
      sh:= fAscor.Shooters.Shooters [i];
      ssh:= sh.DataObject as TStartListEventShooterItem;
      // header
      if ssh<> nil then
        begin
          // start number
          sgShooters.Cells [0,i+1]:= ssh.StartNumberStr;
          // surname and name
          s:= ssh.Shooter.SurnameAndName;
          tw:= sgShooters.Canvas.TextWidth (s);
          if tw> nw then
            nw:= tw;
          sgShooters.Cells [1,i+1]:= s;
          // competition
          sgShooters.Cells [2,i+1]:= ssh.CompetitionStr;
          // final sum
          sc:= sh.PriSum;
          //sgShooters.Cells [3,i+1]:= fEvent.Event.FinalStr (sc);
          if fEvent.Event.FinalFracs then
            sgShooters.Cells [3,i+1]:= fEvent.Event.FinalStr(sc)
          else
            sgShooters.Cells [3,i+1]:= format ('%d',[sc]);
          // total sum
          if fEvent.Event.FinalFracs then
            begin
              sc:= sh.PriSum+ssh.Competition10;
              sgShooters.Cells [4,i+1]:= fEvent.Event.FinalStr(sc);
            end
          else
            begin
              sc:= sh.PriSum+ssh.Competition10 div 10;
              sgShooters.Cells [4,i+1]:= format ('%d',[sc]);
            end;
        end
      else
        begin
          // start number
          sgShooters.Cells [0,i+1]:= IntToStr (sh.StartNo);
          // surname and name
          s:= sh.Name;
          tw:= sgShooters.Canvas.TextWidth (s);
          if tw> nw then
            nw:= tw;
          sgShooters.Cells [1,i+1]:= s;
          // competition
          sgShooters.Cells [2,i+1]:= '';
          // final sum
          sc:= sh.PriSum;
          if fEvent.Event.FinalFracs then
            sgShooters.Cells [3,i+1]:= fEvent.Event.FinalStr(sc)
          else
            sgShooters.Cells [3,i+1]:= format ('%d',[sc]);
          // total sum
          sgShooters.Cells [4,i+1]:= '';
        end;
      sidx:= 0;
      for ph:= 0 to sh.PhasesCount-1 do
        begin
          phase:= sh.Phases [ph];
          for gr:= 0 to phase.GroupsCount-1 do
            begin
              group:= phase.Groups [gr];
              for j:= 0 to group.ShotsCount-1 do
                begin
                  sc:= group.Shots [j]._priscore;
                  if fEvent.Event.FinalFracs then
                    sgShooters.Cells [5+sidx,i+1]:= fEvent.Event.FinalStr(sc)
                  else
                    sgShooters.Cells [5+sidx,i+1]:= format ('%d',[sc]);
                  inc (sidx);
                end;
            end;
        end;
    end;
  sgShooters.ColWidths [0]:= sgShooters.Canvas.TextWidth ('00000')+sgShooters.GridLineWidth+8;
  sgShooters.ColWidths [1]:= nw+sgShooters.GridLineWidth+8;
  sgShooters.ColWidths [2]:= sgShooters.Canvas.TextWidth (fEvent.CompTemplate)+sgShooters.GridLineWidth+8;
  sgShooters.ColWidths [3]:= sgShooters.Canvas.TextWidth (fEvent.SerieTemplate)+sgShooters.GridLineWidth+8;
  sgShooters.ColWidths [4]:= sgShooters.Canvas.TextWidth (fEvent.CompTemplate)+sgShooters.GridLineWidth+8;
end;

procedure TSiusForm.UpdateFonts;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  sgShooters.Canvas.Font:= sgShooters.Font;

  btnConnect.Top:= 4;
  btnConnect.ClientWidth:= Canvas.TextWidth (btnConnect.Caption)+32;
  btnConnect.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnLoad.Top:= btnConnect.Top;
  btnLoad.ClientWidth:= Canvas.TextWidth (btnLoad.Caption)+32;
  btnLoad.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnSave.Top:= 4;
  btnSave.ClientWidth:= Canvas.TextWidth (btnSave.Caption)+32;
  btnSave.ClientHeight:= Canvas.TextHeight ('Mg')+12;

  sgShooters.Left:= 4;
  lHost.Left:= 4;
  cbHost.Left:= lHost.Left+lHost.Width+4;
  btnConnect.Left:= cbHost.Left+cbHost.Width+32;
  btnLoad.Left:= btnConnect.Left+btnConnect.Width+16;

  sgShooters.Top:= btnConnect.Top+btnConnect.Height+4;
  cbHost.Top:= btnConnect.Top+(btnConnect.Height-cbHost.Height) div 2;
  lHost.Top:= cbHost.Top+(cbHost.Height-lHost.Height) div 2;
  cbHost.ClientWidth:= Canvas.TextWidth ('255.255.255.255.255.255')+cbHost.Height;
end;

procedure TSiusForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TSiusForm.UpdateTable;
var
  sh: TLaneShooter;
  sc: integer;
begin
  if fFinal then
    UpdateFinalTable
  else
    UpdateCompetitionTable;
  if fShooterIdx>= 0 then
    begin
      sgShooters.Row:= fShooterIdx+1;
      sh:= fAscor.Shooters.Shooters [fShooterIdx];
      sc:= sh.ShotsCount;
      if sc> 0 then
        sgShooters.Col:= sgShooters.FixedCols+sc-1
      else
        sgShooters.Col:= sgShooters.FixedCols;
      fShooterIdx:= -1;
    end;
  fInvalidated:= false;
end;

end.

