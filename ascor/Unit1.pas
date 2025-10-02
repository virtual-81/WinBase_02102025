unit unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Sockets, Vcl.StdCtrls, WinSock, MyStrings,
  SiusData, Grids, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    sgLanes: TStringGrid;
    btnConnect: TButton;
    edtHost: TEdit;
    btnSave: TButton;
    cbFinal: TCheckBox;
    Timer1: TTimer;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure cbFinalClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnConnectClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fInvalidated: boolean;
    fAscor: TSiusDataCollector;
    fLastUdatedRow: integer;
    procedure OnConnect (Sender: TObject);
    procedure OnDisconnect (Sender: TObject);
    procedure OnUpdate (Sender: TObject; shooter,phase,group,shot: integer);
//    procedure OnError_Connect (Sender: TObject);
    procedure CheckRows;
    procedure UpdateShooter (shooter,phase,group,shot: integer);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnConnectClick(Sender: TObject);
begin
  if fAscor.SiusData.Active then
    begin
      fAscor.SiusData.Active:= false;
    end
  else
    begin
      fAscor.SiusData.Host:= edtHost.Text;
//      fAscor.OnError:= OnError_Connect;
      fAscor.SiusData.Active:= true;
    end;
end;

procedure TForm1.btnSaveClick(Sender: TObject);
var
  sd: TSaveDialog;
begin
  sd:= TSaveDialog.Create (self);
  try
    sd.DefaultExt:= '*.siusdata';
    sd.Filter:= '*.SiusData|*.siusdata';
    sd.FilterIndex:= 0;
    sd.Options:= [ofOverwritePrompt,ofPathMustExist,ofNoChangeDir,ofEnableSizing,ofDontAddToRecent];
    if sd.Execute then
      begin
        fAscor.Commands.SaveToFile (sd.FileName);
      end;
  finally
    sd.Free;
  end;
end;

procedure TForm1.cbFinalClick(Sender: TObject);
begin
  fInvalidated:= true;
end;

procedure TForm1.CheckRows;
var
  i,j,k: integer;
  sh: TLaneShooter;
  iw,nw,tw,rw: integer;
  sc: integer;
  ph,gr: integer;
  phase: TSiusPhase;
  group: TSiusGroup;
  idx: integer;
  sht: TSiusShotRec;
begin
  try
    j:= fAscor.Shooters.Count;
    k:= 5;
    nw:= 0;
    iw:= 0;
    rw:= 0;
    for i:= 0 to fAscor.Shooters.Count-1 do
      begin
        sh:= fAscor.Shooters.Shooters [i];
        if sh.ShotsCount> k then
          k:= sh.ShotsCount;
        tw:= sgLanes.Canvas.TextWidth (sh.Name);
        if tw> nw then
          nw:= tw;
        tw:= sgLanes.Canvas.TextWidth (sh.Issfid);
        if tw> iw then
          iw:= tw;
        tw:= sgLanes.Canvas.TextWidth (sh.Nation);
        if tw> rw then
          rw:= tw;
      end;
    if k< 1 then
      k:= 1;
    sgLanes.ColCount:= 6+k;
    sgLanes.FixedCols:= 6;
    sgLanes.RowCount:= j+1;
    if sgLanes.RowCount> 1 then
      sgLanes.FixedRows:= 1;
    for i:= 1 to sgLanes.RowCount-1 do
      for j:= 0 to sgLanes.ColCount-1 do
        sgLanes.Cells [j,i]:= '';
    for i:= sgLanes.FixedCols to sgLanes.ColCount-1 do
      sgLanes.Cells [i,0]:= IntToStr (i-sgLanes.FixedCols+1);
    sgLanes.ColWidths [3]:= nw+16;
    sgLanes.ColWidths [1]:= iw+16;
    sgLanes.ColWidths [2]:= sgLanes.Canvas.TextWidth ('00000')+16;
    sgLanes.ColWidths [4]:= rw+16;
    sgLanes.ColWidths [5]:= sgLanes.Canvas.TextWidth ('#999 (99.9)')+16;
    for i:= 0 to fAscor.Shooters.Count-1 do
      begin
        sh:= fAscor.Shooters.Shooters [i];
        sgLanes.Cells [0,i+1]:= IntToStr (sh.lane);
        sgLanes.Cells [1,i+1]:= sh.issfid;
        sgLanes.Cells [2,i+1]:= IntToStr (sh.startno);
        sgLanes.Cells [3,i+1]:= sh.name;
        sgLanes.Cells [4,i+1]:= sh.nation;
        if sh.sighters> 0 then
          begin
            sgLanes.Cells [5,i+1]:= format ('#%d (%d.%d)',[sh.sighters,sh.lastsighter div 10,sh.lastsighter mod 10]);
          end
        else
          begin
            sgLanes.Cells [5,i+1]:= '';
          end;
        idx:= 0;
        for ph:= 0 to sh.PhasesCount-1 do
          begin
            phase:= sh.Phases [ph];
            for gr:= 0 to phase.GroupsCount-1 do
              begin
                group:= phase.Groups [gr];
                for j:= 0 to group.ShotsCount-1 do
                  begin
                    sht:= group.Shots [j];
                    if (sht._secscore= 0) and (sht._priscore<> 0) then
                      sc:= sht._priscore
                    else
                      sc:= sht._secscore;
                    {if cbFinal.Checked then
                      sc:= group.Shots [j]._priscore
                    else
                      sc:= group.Shots [j]._secscore;}
                    sgLanes.Cells [idx+sgLanes.FixedCols,i+1]:= format ('%d.%d',[sc div 10,sc mod 10]);
                    inc (idx);
                  end;
              end;
          end;
      end;
  except
    on E: Exception do
      MessageDlg (e.Message,mtError,[mbOk],0);
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  fAscor.SiusData.Active:= false;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  HostName: Array[0..MAX_PATH] of Char;
begin
  fAscor:= TSiusDataCollector.Create;
  fAscor.OnConnect:= OnConnect;
  fAscor.OnDisconnect:= OnDisconnect;
//  fAscor.OnError:= nil;
  fAscor.OnUpdate:= OnUpdate;

  sgLanes.Canvas.Font:= sgLanes.Font;
  sgLanes.DefaultColWidth:= sgLanes.Canvas.TextWidth ('99.9')+16;
  sgLanes.ColCount:= 8;
  sgLanes.FixedCols:= 7;
  sgLanes.RowCount:= 2;
  sgLanes.FixedRows:= 1;
  sgLanes.Cells [0,0]:= '#';
  sgLanes.Cells [1,0]:= 'Name';
  sgLanes.Cells [2,0]:= 'ISSF ID';
  sgLanes.Cells [3,0]:= 'StartNo';
  sgLanes.Cells [4,0]:= 'Nation';
  sgLanes.Cells [5,0]:= 'Sighters';
  sgLanes.Cells [sgLanes.FixedCols,0]:= '1';
  fLastUdatedRow:= -1;

  btnConnect.Caption:= 'Connect';
  edtHost.Enabled:= true;
  if gethostname (HostName,MAX_PATH)= 0 then
    edtHost.Text:= HostName
  else
    edtHost.Text:= '';

//  btnSave.Enabled:= false;

  WindowState:= wsMaximized;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fAscor.Free;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_F8: begin
      fAscor.Reset;
      fInvalidated:= true;
    end;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  btnConnect.Top:= 8;
  edtHost.Left:= 8;
  edtHost.Top:= btnConnect.Top+(btnConnect.Height-edtHost.Height) div 2;
  btnConnect.Left:= edtHost.Left+edtHost.Width+16;
  btnSave.Top:= btnConnect.Top;
  btnSave.Left:= btnConnect.Left+btnConnect.Width+16;
  sgLanes.Left:= 8;
  sgLanes.Top:= btnConnect.Top+btnConnect.Height+8;
  sgLanes.Width:= ClientWidth-16;
  sgLanes.Height:= ClientHeight-8-sgLanes.Top;
  cbFinal.Left:= btnSave.Left+btnSave.Width+16;
  cbFinal.Top:= btnSave.Top+(btnSave.Height-cbFinal.Height) div 2;
end;

procedure TForm1.OnConnect(Sender: TObject);
begin
  btnConnect.Caption:= 'Disconnect';
  edtHost.Enabled:= false;
  fLastUdatedRow:= -1;
end;

procedure TForm1.OnDisconnect(Sender: TObject);
begin
  btnConnect.Caption:= 'Connect';
  edtHost.Enabled:= true;
  Timer1.Enabled:= false;
end;

procedure TForm1.OnUpdate (Sender: TObject; shooter,phase,group,shot: integer);
begin
  if shooter< 0 then
    begin
    end
  else
    begin
      UpdateShooter (shooter,phase,group,shot);
    end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if fInvalidated then
    begin
      CheckRows;
      fInvalidated:= false;
    end;
end;

procedure TForm1.UpdateShooter(shooter, phase, group, shot: integer);
var
  sh: TLaneShooter;
  c,j,i,sc: integer;
  idx,ph,gr: integer;
  _phase: TSiusPhase;
  _group: TSiusGroup;
  w: integer;
  st: string;
  sht: TSiusShotRec;
begin
  sh:= fAscor.Shooters.Shooters [shooter];
  if sgLanes.RowCount< shooter+2 then
    begin
      sgLanes.RowCount:= shooter+2;
    end;

  sgLanes.Cells [0,shooter+1]:= IntToStr (sh.Lane);

  w:= sgLanes.Canvas.TextWidth (sh.Name);
  if w+16> sgLanes.ColWidths [1] then
    sgLanes.ColWidths [1]:= w+16;
  sgLanes.Cells [1,shooter+1]:= sh.Name;

  w:= sgLanes.Canvas.TextWidth (sh.IssfId);
  if w+16> sgLanes.ColWidths [2] then
    sgLanes.ColWidths [2]:= w+16;
  sgLanes.Cells [2,shooter+1]:= sh.IssfId;

  w:= sgLanes.Canvas.TextWidth (IntToStr (sh.StartNo));
  if w+16> sgLanes.ColWidths [3] then
    sgLanes.ColWidths [3]:= w+16;
  sgLanes.Cells [3,shooter+1]:= IntToStr (sh.StartNo);

  w:= sgLanes.Canvas.TextWidth (sh.Nation);
  if w+16> sgLanes.ColWidths [4] then
    sgLanes.ColWidths [4]:= w+16;
  sgLanes.Cells [4,shooter+1]:= sh.Nation;

  if sh.sighters> 0 then
    st:= format ('#%d (%d.%d)',[sh.sighters,sh.lastsighter div 10,sh.lastsighter mod 10])
  else
    st:= '';
  w:= sgLanes.Canvas.TextWidth (st);
  if w+16> sgLanes.ColWidths [5] then
    sgLanes.ColWidths [5]:= w+16;
  sgLanes.Cells [5,shooter+1]:= st;

  st:= '';
  if sh.PhasesCount> 1 then
    begin
      for i:= 0 to sh.PhasesCount-1 do
        begin
          _phase:= sh.Phases [i];
          if st<> '' then
            st:= st+' + ';
          st:= st+IntToStr (_phase.PriSum);
        end;
      st:= st+' = ';
    end;
  st:= st+IntToStr (sh.PriSum)+' ('+IntToStr (sh.PriSum-sh.ShotsCount*10)+')';
  w:= sgLanes.Canvas.TextWidth (st);
  if w+16> sgLanes.ColWidths [6] then
    sgLanes.ColWidths [6]:= w+16;
  sgLanes.Cells [6,shooter+1]:= st;

  c:= sgLanes.ColCount;
  if c< sh.ShotsCount+sgLanes.FixedCols then
    begin
      sgLanes.ColCount:= sh.ShotsCount+sgLanes.FixedCols;
      for j:= c to sgLanes.ColCount-1 do
        begin
          for i:= 1 to sgLanes.RowCount-1 do
            begin
              sgLanes.Cells [j,i]:= '';
            end;
          sgLanes.Cells [j,0]:= IntToStr (j+1-sgLanes.FixedCols);
        end;
    end;
  idx:= 0;
  for ph:= 0 to sh.PhasesCount-1 do
    begin
      _phase:= sh.Phases [ph];
      for gr:= 0 to _phase.GroupsCount-1 do
        begin
          _group:= _phase.Groups [gr];
          for j:= 0 to _group.ShotsCount-1 do
            begin
              sht:= _group.Shots [j];
              if (sht._secscore= 0) and (sht._priscore<> 0) then
                sc:= sht._priscore
              else
                sc:= sht._secscore;
              {if cbFinal.Checked then
                sc:= ._priscore
              else
                sc:= _group.Shots [j]._secscore;}
              sgLanes.Cells [idx+sgLanes.FixedCols,shooter+1]:= format ('%d.%d',[sc div 10,sc mod 10]);
              inc (idx);
            end;
        end;
    end;

  fLastUdatedRow:= shooter+1;
end;

end.

