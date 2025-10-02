{$a-}
unit form_relaypos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

type
  TRelayPositionDialog = class(TForm)
    lEventShort: TLabel;
    lEvent: TLabel;
    lShooter: TLabel;
    lRelay: TLabel;
    lPos: TLabel;
    edtPos: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    edtRelay: TEdit;
    edtPos2: TEdit;
    lPos2: TLabel;
    cbTeamPoints: TCheckBox;
    cbRegionPoints: TCheckBox;
    cbDistrictPoints: TCheckBox;
    cbTeamForPoints: TComboBox;
    cbOutOfRank: TCheckBox;
    cbForTeam: TCheckBox;
    cbTeamForResults: TComboBox;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtRelayKeyPress(Sender: TObject; var Key: Char);
    procedure edtPosKeyPress(Sender: TObject; var Key: Char);
    procedure edtPos2KeyPress(Sender: TObject; var Key: Char);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbOutOfRankClick(Sender: TObject);
    procedure cbTeamPointsClick(Sender: TObject);
    procedure cbRegionPointsClick(Sender: TObject);
    procedure cbDistrictPointsClick(Sender: TObject);
    procedure cbTeamForPointsChange(Sender: TObject);
  private
    { Private declarations }
    fShooter: TStartListEventShooterItem;
    fRelay: TStartListEventRelayItem;
    fPosition1,fPosition2: integer;
    fModalResult: integer;
    procedure set_Shooter(const Value: TStartListEventShooterItem);
    function CheckValues: boolean;
    function get_DistrictPoints: boolean;
    function get_RegionPoints: boolean;
    function get_TeamForPoints: string;
    function get_TeamForResults: string;
    function get_OutOfRank: boolean;
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property Shooter: TStartListEventShooterItem read fShooter write set_Shooter;
    function Execute: boolean;
    procedure UpdateData;
    property Relay: TStartListEventRelayItem read fRelay;
    property Position1: integer read fPosition1;
    property Position2: integer read fPosition2;
    property TeamForPoints: string read get_TeamForPoints;
    property TeamForResults: string read get_TeamForResults;
    property GiveRegionPoints: boolean read get_RegionPoints;
    property GiveDistrictPoints: boolean read get_DistrictPoints;
    property OutOfRank: boolean read get_OutOfRank;
  end;

implementation

{$R *.dfm}

{ TRelayPositionDialog }

function TRelayPositionDialog.Execute: boolean;
begin
  fModalResult:= mrCancel;
  Result:= (ShowModal= mrOk);
end;

procedure TRelayPositionDialog.set_Shooter(
  const Value: TStartListEventShooterItem);
begin
  fShooter:= Value;
  UpdateData;
end;

procedure TRelayPositionDialog.UpdateData;
var
  y,w,i: integer;
  teams: TStrings;
  cw: integer;
begin
  case fShooter.Event.EventType of
    etRegular,etThreePosition2013: begin
      lRelay.Caption:= Language ['RelayPositionDialog.RegRelay'];
      lPos.Caption:= Language ['RelayPositionDialog.RegPos'];
      lPos2.Caption:= '';
      lPos2.Visible:= false;
      edtPos2.Visible:= false;
    end;
    etRapidFire: begin
      lRelay.Caption:= Language ['RelayPositionDialog.RFRelay'];
      lPos.Caption:= Language ['RelayPositionDialog.RFPos1'];
      lPos2.Caption:= Language ['RelayPositionDialog.RFPos2'];
      lPos2.Visible:= true;
      edtPos2.Visible:= true;
    end;
    etCenterFire,etCenterFire2013: begin
      lRelay.Caption:= Language ['RelayPositionDialog.CFRelay'];
      lPos.Caption:= Language ['RelayPositionDialog.CFPos'];
      lPos2.Caption:= '';
      lPos2.Visible:= false;
      edtPos2.Visible:= false;
    end;
    etMovingTarget,etMovingTarget2013: begin
      lRelay.Caption:= Language ['RelayPositionDialog.MTRelay'];
      lPos.Caption:= Language ['RelayPositionDialog.MTPos'];
      lPos2.Caption:= '';
      lPos2.Visible:= false;
      edtPos2.Visible:= false;
    end;
  end;

  lShooter.Caption:= fShooter.Shooter.Surname+', '+fShooter.Shooter.Name;
  lEventShort.Caption:= fShooter.Event.ShortName;
  lEvent.Caption:= fShooter.Event.Name;

  cw:= lShooter.Width;
  if lEventShort.Width> cw then
    cw:= lEventShort.Width;
  if lEvent.Width> cw then
    cw:= lEvent.Width;

  w:= lRelay.Width;
  if lPos.Width> w then
    w:= lPos.Width;
  if lPos2.Width> w then
    w:= lPos2.Width;
  lRelay.Left:= w-lRelay.Width;
  lPos.Left:= w-lPos.Width;
  lPos2.Left:= w-lPos2.Width;
  edtRelay.Left:= w+8;
  edtPos.Left:= w+8;
  edtPos2.Left:= w+8;
  edtRelay.Top:= lShooter.Top+lShooter.Height+16;
  lRelay.Top:= edtRelay.Top+(edtRelay.Height-lRelay.Height) div 2;
  edtPos.Top:= edtRelay.Top+edtRelay.Height+4;
  lPos.Top:= edtPos.Top+(edtPos.Height-lPos.Height) div 2;
  y:= edtPos.Top+edtPos.Height;
  if edtPos2.Visible then
    begin
      edtPos2.Top:= y+4;
      lPos2.Top:= edtPos2.Top+(edtPos2.Height-lPos2.Height) div 2;
      y:= y+4+edtPos2.Height+16;
    end
  else
    y:= y+16;
  if w+8+edtPos.Width> cw then
    cw:= w+8+edtPos.Width;

  teams:= fShooter.StartEvent.StartList.GetTeams (false,nil);
  cbTeamForPoints.Clear;
  cbTeamForResults.Clear;
  for i:= 0 to teams.Count-1 do
    begin
      cbTeamForPoints.Items.Add (teams [i]);
      cbTeamForResults.Items.Add (teams [i]);
    end;
  teams.Free;
  cbTeamForPoints.Text:= fShooter.TeamForPoints;
  cbTeamForResults.Text:= fShooter.TeamForResults;
  cbTeamForPoints.Top:= y;
  cbTeamForResults.Top:= cbTeamForPoints.Top+cbTeamForPoints.Height+4;
  w:= cbTeamPoints.Width;
  if cbForTeam.Width> w then
    w:= cbForTeam.Width;
  cbTeamForPoints.Left:= w+8;
  cbTeamForResults.Left:= w+8;
  cbTeamPoints.Top:= cbTeamForPoints.Top+(cbTeamForPoints.Height-cbTeamPoints.Height) div 2;
  cbForTeam.Top:= cbTeamForResults.Top+(cbTeamForResults.Height-cbForTeam.Height) div 2;
  if w+8+cbTeamForPoints.Width> cw then
    cw:= w+8+cbTeamForPoints.Width;

  if cbRegionPoints.Width> cw then
    cw:= cbRegionPoints.Width;
  if cbDistrictPoints.Width> cw then
    cw:= cbDistrictPoints.Width;
  if cbOutOfRank.Width> cw then
    cw:= cbOutOfRank.Width;

  if btnOk.Width+8+btnCancel.Width> cw then
    cw:= btnOk.Width+8+btnCancel.Width;

  cbTeamForPoints.Width:= cw-cbTeamForPoints.Left;
  cbTeamForResults.Width:= cw-cbTeamForResults.Left;

  ClientWidth:= cw;
  Constraints.MinWidth:= Width;

  cbTeamPoints.Checked:= fShooter.TeamForPoints<> '';
  cbRegionPoints.Checked:= fShooter.GiveRegionPoints;
  cbDistrictPoints.Checked:= fShooter.GiveDistrictPoints;
  cbForTeam.Checked:= fShooter.TeamForResults<> '';
  cbOutOfRank.Checked:= fShooter.OutOfRank;

  cbRegionPoints.Top:= cbTeamForResults.Top+cbTeamForResults.Height+4;
  cbDistrictPoints.Top:= cbRegionPoints.Top+cbRegionPoints.Height+4;
  cbOutOfRank.Top:= cbDistrictPoints.Top+cbDistrictPoints.Height+4;

  fRelay:= fShooter.Relay;
  fPosition1:= fShooter.Position;
  fPosition2:= fShooter.Position2;

  btnOk.Top:= cbOutOfRank.Top+cbOutOfRank.Height+16;
  btnCancel.Top:= btnOk.Top;
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;
  ClientHeight:= btnOk.Top+btnOk.Height;
  Constraints.MinHeight:= Height;
  Constraints.MaxHeight:= Height;

  if fShooter.Relay<> nil then
    begin
      edtRelay.Text:= IntToStr (fShooter.Relay.Index+1);
      if fShooter.Position> 0 then
        begin
          edtPos.Text:= IntToStr (fShooter.Position);
        end
      else
        edtPos.Text:= '';
      if fShooter.Position2> 0 then
        begin
          edtPos2.Text:= IntToStr (fShooter.Position2);
        end;
    end
  else
    begin
      edtRelay.Text:= '';
      edtPos.Text:= '';
      edtPos2.Text:= '';
    end;

  if fShooter.StartEvent.Relays.Count= 1 then
    begin
      fRelay:= fShooter.StartEvent.Relays [0];
      edtRelay.Text:= '1';
      ActiveControl:= edtPos;
      edtRelay.Enabled:= false;
    end;

  ClientHeight:= btnOk.Top+btnOk.Height;
  Position:= poScreenCenter;
end;

procedure TRelayPositionDialog.UpdateFonts;
var
  w,i: integer;
  th: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w;
  btnCancel.ClientWidth:= w;
  btnOk.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnCancel.ClientHeight:= btnOk.ClientHeight;
  lEventShort.Font.Style:= [fsBold];
  lShooter.Font.Style:= [fsBold];
  lEvent.Top:= lEventShort.Top+lEventShort.Height;
  lShooter.Top:= lEvent.Top+lEvent.Height+4;

  th:= Canvas.TextHeight ('Mg');
  cbTeamPoints.ClientHeight:= th;
  cbTeamPoints.ClientWidth:= cbTeamPoints.Height+Canvas.TextWidth (cbTeamPoints.Caption)+8;
  cbForTeam.ClientHeight:= th;
  cbForTeam.ClientWidth:= cbForTeam.Height+Canvas.TextWidth (cbForTeam.Caption)+8;
  cbRegionPoints.ClientHeight:= th;
  cbRegionPoints.ClientWidth:= cbRegionPoints.Height+Canvas.TextWidth (cbRegionPoints.Caption)+8;
  cbDistrictPoints.ClientHeight:= th;
  cbDistrictPoints.ClientWidth:= cbDistrictPoints.Height+Canvas.TextWidth (cbDistrictPoints.Caption)+8;
  cbOutOfRank.ClientHeight:= th;
  cbOutOfRank.ClientWidth:= cbOutOfRank.Height+Canvas.TextWidth (cbOutOfRank.Caption)+8;

  cbTeamForPoints.Canvas.Font:= cbTeamForPoints.Font;
  cbTeamForPoints.ItemHeight:= cbTeamForPoints.Canvas.TextHeight ('Mg');
  cbTeamForResults.Canvas.Font:= cbTeamForResults.Font;
  cbTeamForResults.ItemHeight:= cbTeamForResults.Canvas.TextHeight ('Mg');

  btnOk.Top:= cbOutOfRank.Top+cbOutOfRank.Height+16;
  btnCancel.Top:= btnOk.Top;
  ClientHeight:= btnOk.Top+btnOk.Height;
end;

procedure TRelayPositionDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TRelayPositionDialog.edtRelayKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      edtPos.SetFocus;
      Key:= #0;
    end;
  end;
end;

procedure TRelayPositionDialog.edtPosKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      if edtPos2.Visible then
        edtPos2.SetFocus
      else
        btnOk.SetFocus;
      Key:= #0;
    end;
  end;
end;

procedure TRelayPositionDialog.edtPos2KeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      btnOk.SetFocus;
      Key:= #0;
    end;
  end;
end;

function TRelayPositionDialog.CheckValues: boolean;
var
  i,n: integer;
begin
  Result:= false;

  val (edtRelay.Text,i,n);
  if i< 1 then
    begin
      MessageDlg (Language ['InvalidRelayValue'],mtError,[mbOk],0);
      edtRelay.SetFocus;
      exit;
    end;
  if i> fShooter.StartEvent.Relays.Count then
    begin
      MessageDlg (Language ['NoSuchRelay'],mtError,[mbOk],0);
      edtRelay.SetFocus;
      exit;
    end;
  fRelay:= fShooter.StartEvent.Relays [i-1];

  val (edtPos.Text,i,n);
  if i< 1 then
    begin
      MessageDlg (Language ['InvalidPosValue'],mtError,[mbOk],0);
      edtPos.SetFocus;
      exit;
    end;
  if not fRelay.CheckPosition (i) then
    begin
      MessageDlg (Language ['NoSuchPos'],mtError,[mbOk],0);
      edtPos.SetFocus;
      exit;
    end;
  fPosition1:= i;

  case fShooter.Event.EventType of
    etRegular,etCenterFire,etMovingTarget,etCenterFire2013,etThreePosition2013,etMovingTarget2013: {};
    etRapidFire: begin
      val (edtPos2.Text,i,n);
      if i< 1 then
        begin
          MessageDlg (Language ['InvalidPosValue'],mtError,[mbOk],0);
          edtPos2.SetFocus;
          exit;
        end;
      if not fRelay.CheckPosition (i) then
        begin
          MessageDlg (Language ['NoSuchPos'],mtError,[mbOk],0);
          edtPos2.SetFocus;
          exit;
        end;
      fPosition2:= i;
    end;
  end;

  Result:= true;
end;

procedure TRelayPositionDialog.btnOkClick(Sender: TObject);
begin
  if CheckValues then
    begin
      fModalResult:= mrOk;
      Close;
    end;
end;

procedure TRelayPositionDialog.btnCancelClick(Sender: TObject);
begin
  fModalResult:= mrCancel;
end;

procedure TRelayPositionDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ModalResult:= fModalResult;
end;

procedure TRelayPositionDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
  Position:= poScreenCenter;
end;

procedure TRelayPositionDialog.FormResize(Sender: TObject);
begin
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;
  cbTeamForPoints.Width:= ClientWidth-cbTeamForPoints.Left;
  cbTeamForResults.Width:= ClientWidth-cbTeamForResults.Left;
end;

function TRelayPositionDialog.get_DistrictPoints: boolean;
begin
  Result:= cbDistrictPoints.Checked;
end;

function TRelayPositionDialog.get_RegionPoints: boolean;
begin
  Result:= cbRegionPoints.Checked;
end;

function TRelayPositionDialog.get_TeamForPoints: string;
begin
  Result:= cbTeamForPoints.Text;
end;

function TRelayPositionDialog.get_OutOfRank: boolean;
begin
  Result:= cbOutOfRank.Checked;
end;

procedure TRelayPositionDialog.cbOutOfRankClick(Sender: TObject);
begin
  if cbOutOfRank.Checked then
    begin
      cbTeamPoints.Checked:= false;
      cbRegionPoints.Checked:= false;
      cbDistrictPoints.Checked:= false;
    end;
end;

procedure TRelayPositionDialog.cbTeamPointsClick(Sender: TObject);
begin
  if cbTeamPoints.Checked then
    cbOutOfRank.Checked:= false;
end;

procedure TRelayPositionDialog.cbRegionPointsClick(Sender: TObject);
begin
  if cbRegionPoints.Checked then
    cbOutOfRank.Checked:= false;
end;

procedure TRelayPositionDialog.cbDistrictPointsClick(Sender: TObject);
begin
  if cbDistrictPoints.Checked then
    cbOutOfRank.Checked:= false;
end;

procedure TRelayPositionDialog.cbTeamForPointsChange(Sender: TObject);
begin
  if cbTeamForPoints.Text<> '' then
    begin
      cbForTeam.Enabled:= true;
      cbForTeam.Checked:= cbForTeam.Checked;
      cbTeamPoints.Enabled:= true;
      cbTeamPoints.Checked:= cbTeamPoints.Checked;
    end
  else
    begin
      cbForTeam.State:= cbGrayed;
      cbForTeam.Enabled:= false;
      cbTeamPoints.State:= cbGrayed;
      cbTeamPoints.Enabled:= false;
    end;
end;

function TRelayPositionDialog.get_TeamForResults: string;
begin
  Result:= cbTeamForResults.Text;
end;

end.


