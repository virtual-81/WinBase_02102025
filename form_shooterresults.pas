{$a-}
unit form_shooterresults;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Grids, Vcl.StdCtrls, Vcl.ComCtrls, System.Types,

  SysFont,
  Data,

  MyLanguage,
  wb_barcodes,
  wb_seriesedit,
  ctrl_language;

type
  TShooterSeriesDialog = class(TForm)
    lShooter: TLabel;
    lEventShort: TLabel;
    lEvent: TLabel;
    lRelayStr: TLabel;
    lRelay: TLabel;
    lPosStr: TLabel;
    lPos: TLabel;
    lTotal: TLabel;
    lNum: TLabel;
    cbDNS: TComboBox;
    cbOutOfRank: TCheckBox;
    cbForTeam: TCheckBox;
    cbTeamPoints: TCheckBox;
    cbRegionPoints: TCheckBox;
    cbDistrictPoints: TCheckBox;
    lRecordComment: TLabel;
    edtRecordComment: TEdit;
    edtCompShootOff: TEdit;
    lCompShootOff: TLabel;
    lCompPriority: TLabel;
    udCompPriority: TUpDown;
    edtCompPriority: TEdit;
    edtManualPoints: TEdit;
    lManualPoints: TLabel;
    sgFinal: TStringGrid;
    lFinalShootOff: TLabel;
    edtFinalShootOff: TEdit;
    lFinalPriority: TLabel;
    edtFinalPriority: TEdit;
    udFinalPriority: TUpDown;
    edtFinalResult: TEdit;
    cbTeamForPoints: TComboBox;
    cbTeamForResults: TComboBox;
    PageControl1: TPageControl;
    tsMain: TTabSheet;
    tsFinal: TTabSheet;
    tsPoints: TTabSheet;
    memDNSComment: TMemo;
    lDNSComment: TLabel;
    rbFinalShots: TRadioButton;
    rbFinalResult: TRadioButton;
    edtInnerTens: TEdit;
    lInnerTens: TLabel;
    udInnerTens: TUpDown;
    procedure FormCreate(Sender: TObject);
    procedure cbDNSChange(Sender: TObject);
    procedure edtRecordCommentChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure sgFinalClick(Sender: TObject);
    procedure sgFinalGetEditText(Sender: TObject; ACol, ARow: Integer; var Value: String);
    procedure sgFinalSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
    procedure sgFinalKeyPress(Sender: TObject; var Key: Char);
    procedure sgFinalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rbFinalShotsClick(Sender: TObject);
    procedure rbFinalResultClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    fShooter: TStartListEventShooterItem;
    fAttributesOn: boolean;
    fRecordCommentOn: boolean;
    fCompShootOffOn: boolean;
    fFinalOn: boolean;
    fFinalEdit: boolean;
    fFinalNewValue10: DWORD;
    fFinalCol: integer;
    fLargeSeriesFont: boolean;
    fSumStr: string;
    fSeriesEdit: TShooterSeriesEditor;
    procedure set_Shooter(const Value: TStartListEventShooterItem);
    procedure RearrangeControls;
    procedure SaveValues;
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure WMBCShooterCard (var M: TMessage); message WM_BC_SHOOTERCARD;
    procedure OnSeriesChange (Sender: TObject);
    procedure WmCloseSeriesOk(var M: TMessage); message WM_USER + 1201;
  protected
    procedure AdjustSize; override;
  public
    { Public declarations }
    property Shooter: TStartListEventShooterItem read fShooter write set_Shooter;
    function Execute: boolean;
    property AttributesOn: boolean read fAttributesOn write fAttributesOn;
    property RecordCommentOn: boolean read fRecordCommentOn write fRecordCommentOn;
    property CompShootOffOn: boolean read fCompShootOffOn write fCompShootOffOn;
    property FinalOn: boolean read fFinalOn write fFinalOn;
    property LargeSeriesFont: boolean read fLargeSeriesFont write fLargeSeriesFont;
  end;

implementation

{$R *.dfm}

{ TShooterSeriesDialog }

function TShooterSeriesDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TShooterSeriesDialog.set_Shooter(const Value: TStartListEventShooterItem);
var
  i,w,c: integer;
  th,tw: integer;
  e: TEdit;
//  fr: TFinalResult;
  teams: TStrings;
begin
  fShooter:= Value;

  if fShooter.StartList.StartNumbers then
    lNum.Caption:= fShooter.StartNumberStr
  else
    lNum.Caption:= '';
  lShooter.Caption:= fShooter.Shooter.SurnameAndName;
  lEventShort.Caption:= fShooter.Event.ShortName;
  lEvent.Caption:= fShooter.Event.Name;
  if fShooter.Relay<> nil then
    lRelay.Caption:= IntToStr (fShooter.Relay.Index+1)
  else
    lRelay.Caption:= Language ['ShooterSeriesDialog.NoRelay'];
  if fShooter.Position> 0 then
    lPos.Caption:= IntToStr (fShooter.Position)
  else
    lPos.Caption:= Language ['ShooterSeriesDialog.NoPos'];
  lTotal.Caption:= format (fSumStr,[fShooter.CompetitionStr]);

  // �������
  teams:= fShooter.StartEvent.StartList.GetTeams (false,nil);
  cbTeamForPoints.Clear;
  cbTeamForPoints.Items.AddStrings (teams);
  cbTeamForResults.Clear;
  cbTeamForResults.Items.AddStrings (teams);
  teams.Free;
  cbTeamForPoints.Text:= fShooter.TeamForPoints;
  cbTeamForResults.Text:= fShooter.TeamForResults;

  // DNS
  case fShooter.DNS of
    dnsCompletely: begin
      cbDNS.ItemIndex:= 1;
      memDNSComment.Visible:= true;
      lDNSComment.Visible:= true;
      fSeriesEdit.Visible:= false;
      lTotal.Visible:= false;
    end;
    dnsPartially: begin
      cbDNS.ItemIndex:= 2;
      memDNSComment.Visible:= true;
      lDNSComment.Visible:= true;
      fSeriesEdit.Visible:= true;
      lTotal.Visible:= true;
    end;
  else
    cbDNS.ItemIndex:= 0;
    memDNSComment.Visible:= false;
    lDNSComment.Visible:= false;
    fSeriesEdit.Visible:= true;
    lTotal.Visible:= true;
  end;
  memDNSComment.Text:= fShooter.DNSComment;

{  if fLargeSeriesFont then
    begin
      sgSeries.Font.Size:= 14;
      sgSeries.Font.Style:= [fsBold];
    end
  else
    begin
      sgSeries.Font.Size:= 10;
      sgSeries.Font.Style:= [fsBold];
    end;}

  fSeriesEdit.Font.Size:= 14;
  fSeriesEdit.Font.Style:= [fsBold];

  lTotal.Font:= fSeriesEdit.Font;
  lTotal.AutoSize:= false;
  lTotal.Canvas.Font:= lTotal.Font;
  lTotal.ClientWidth:= lTotal.Canvas.TextWidth (format (fSumStr,[fShooter.StartEvent.TotalTemplate+'-00x']));
  lTotal.ClientHeight:= lTotal.Canvas.TextHeight ('Mg');
  fSeriesEdit.SetShooter (fShooter);

  e:= TEdit.Create (self);
  e.Parent:= self;
  e.Font:= sgFinal.Font;
  th:= e.ClientHeight;
  e.Free;
  sgFinal.ScrollBars:= ssNone;
  sgFinal.RowCount:= 1;
  sgFinal.FixedRows:= 0;
  sgFinal.FixedCols:= 0;
  sgFinal.ColCount:= fShooter.Event.FinalShots;
  sgFinal.Canvas.Font:= sgFinal.Font;
  sgFinal.RowHeights [0]:= th;
  w:= 0;
  tw:= sgFinal.Canvas.TextWidth (fShooter.StartEvent.TotalTemplate);
  c:= sgFinal.ColCount;
  for i:= 0 to c-1 do
    begin
      sgFinal.ColWidths [i]:= tw;
      sgFinal.Cells [i,0]:= '';
    end;
  for i:= 0 to fShooter.FinalShotsCount-1 do
    begin
      sgFinal.Cells [i,0]:= fShooter.Event.FinalStr (fShooter.FinalShots10 [i]);
    end;
  if c> 10 then
    begin
      c:= 10;
      sgFinal.ScrollBars:= ssHorizontal;
    end;
  for i:= 0 to c-1 do
    w:= w+tw+sgFinal.GridLineWidth;
  sgFinal.ClientWidth:= w;
  sgFinal.ClientHeight:= sgFinal.GridLineWidth+th;
  fFinalCol:= 0;
  sgFinal.Col:= 0;
  fFinalEdit:= false;
  fFinalNewValue10:= 0;
//  cbFinalShots.OnClick:= nil;
//  cbFinalResult.OnClick:= nil;
  if fShooter.FinalShotsCount> 0 then
    begin
      rbFinalShots.Checked:= true;
//      cbFinalResult.Checked:= false;
    end
  else
    begin
      rbFinalResult.Checked:= true;
//      cbFinalShots.Checked:= false;
    end;
//  cbFinalShots.OnClick:= rbFinalShotsClick;
//  cbFinalResult.OnClick:= rbFinalResultClick;
  edtFinalResult.Text:= fShooter.FinalResultStr;

  edtFinalShootOff.Text:= fShooter.FinalShootOffStr;
  udFinalPriority.Position:= fShooter.FinalPriority;

  udInnerTens.Position:= fShooter.InnerTens;
  edtCompShootOff.Text:= fShooter.CompShootOffStr;
  udCompPriority.Position:= fShooter.CompPriority;
  edtRecordComment.Text:= fShooter.RecordComment;

  cbOutOfRank.Checked:= fShooter.OutOfRank;
  cbForTeam.Checked:= fShooter.TeamForResults<> '';
  cbTeamPoints.Checked:= fShooter.TeamForPoints<> '';
  cbRegionPoints.Checked:= fShooter.GiveRegionPoints;
  cbDistrictPoints.Checked:= fShooter.GiveDistrictPoints;
  edtManualPoints.Text:= IntToStr (fShooter.ManualPoints);

  RearrangeControls;
end;

procedure TShooterSeriesDialog.UpdateFonts;
var
  th: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  th:= Canvas.TextHeight ('Mg');
  cbDNS.Canvas.Font:= cbDNS.Font;
  cbDNS.ItemHeight:= cbDNS.Canvas.TextHeight ('Mg');
  cbOutOfRank.ClientHeight:= th;
  cbOutOfRank.ClientWidth:= cbOutOfRank.Height+8+Canvas.TextWidth (cbOutOfRank.Caption);
  cbForTeam.ClientHeight:= th;
  cbForTeam.ClientWidth:= cbForTeam.Height+8+Canvas.TextWidth (cbForTeam.Caption);
  cbTeamPoints.ClientHeight:= th;
  cbTeamPoints.ClientWidth:= cbTeamPoints.Height+8+Canvas.TextWidth (cbTeamPoints.Caption);
  cbRegionPoints.ClientHeight:= th;
  cbRegionPoints.ClientWidth:= cbRegionPoints.Height+8+Canvas.TextWidth (cbRegionPoints.Caption);
  cbDistrictPoints.ClientHeight:= th;
  cbDistrictPoints.ClientWidth:= cbDistrictPoints.Height+8+Canvas.TextWidth (cbDistrictPoints.Caption);
  rbFinalShots.ClientHeight:= th;
  rbFinalShots.ClientWidth:= rbFinalShots.Height+8+Canvas.TextWidth (rbFinalShots.Caption);
  rbFinalResult.ClientHeight:= th;
  rbFinalResult.ClientWidth:= rbFinalResult.Height+8+Canvas.TextWidth (rbFinalResult.Caption);
  lShooter.Font.Style:= [fsBold];
  lNum.Font.Size:= lNum.Font.Size+8;
  lRelay.Font.Style:= [fsBold];
  lPos.Font.Style:= [fsBold];
end;

procedure TShooterSeriesDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
  fSumStr:= Language ['ShooterSeriesDialog.Sum'];
end;

procedure TShooterSeriesDialog.WMBCShooterCard(var M: TMessage);
var
  sc: PWBC_ShooterCard;
  ev: TStartListEventItem;
  sh: TStartListEventShooterItem;
begin
  if fShooter= nil then
    exit;
  sc:= PWBC_ShooterCard (M.LPARAM);
  ev:= fShooter.StartList.Events.FindByProtocolNumber (sc^.ProtocolNumber);
  if ev= nil then
    exit;
{
  ev:= fShooter.StartList.Events [sc^.EventIndex];
  if ev= nil then
    exit;
  if ev.ProtocolNumber<> sc^.ProtocolNumber then
    exit;
}
  if sc^.Relay>= ev.Relays.Count then
    exit;
  if sc^.StartNumber> 0 then
    sh:= ev.FindShooter (sc^.StartNumber)
  else
    sh:= ev.FindShooter (ev.Relays [sc^.Relay],sc^.Lane);
  if sh= nil then
    exit;
  SaveValues;
  Shooter:= sh;
end;

procedure TShooterSeriesDialog.AdjustSize;
begin
  inherited;
end;

procedure TShooterSeriesDialog.cbDNSChange(Sender: TObject);
begin
  if cbDNS.ItemIndex= 0 then
    begin
      fSeriesEdit.Visible:= true;
      lTotal.Visible:= true;
      fSeriesEdit.SetFocus;
      memDNSComment.Visible:= false;
      lDNSComment.Visible:= false;
    end
  else if cbDNS.ItemIndex= 1 then
    begin
      fSeriesEdit.Visible:= false;
      lTotal.Visible:= false;
      memDNSComment.Visible:= true;
      lDNSComment.Visible:= true;
      memDNSComment.SetFocus;
    end
  else if cbDNS.ItemIndex= 2 then
    begin
      fSeriesEdit.Visible:= true;
      lTotal.Visible:= true;
      memDNSComment.Visible:= true;
      lDNSComment.Visible:= true;
      memDNSComment.SetFocus;
    end;
end;

procedure TShooterSeriesDialog.edtRecordCommentChange(Sender: TObject);
begin
  fShooter.RecordComment:= edtRecordComment.Text;
end;

procedure TShooterSeriesDialog.RearrangeControls;
const
  BRD= 16;
var
  y: integer;
  h,y_1,y_2,y_3: integer;
  w,w_1,w_2: integer;
  p: TPoint;

  procedure RearrangeMain;
  begin
    y_1:= BRD;
    cbDNS.Left:= BRD;
    cbDNS.Top:= y_1;
    y_1:= y_1+cbDNS.Height+8;
    lDNSComment.Top:= y_1;
    lDNSComment.Left:= BRD;
    memDNSComment.Top:= y_1;
    memDNSComment.Left:= lDNSComment.Left+lDNSComment.Width+8;
    y_1:= y_1+memDNSComment.Height+8;
    fSeriesEdit.Left:= BRD;
    memDNSComment.Width:= tsMain.ClientWidth-memDNSComment.Left-BRD;
    fSeriesEdit.Top:= y_1;
    lTotal.Left:= fSeriesEdit.Left+fSeriesEdit.Width+8;
    p:= fSeriesEdit.ClientToParent (Point (0,fSeriesEdit.ClientHeight));
    lTotal.Top:= p.Y-lTotal.Height;
    y_1:= y_1+fSeriesEdit.Height;
    if fCompShootOffOn then
      begin
        y_1:= y_1+8;
        lInnerTens.Visible:= true;
        edtInnerTens.Visible:= true;
        udInnerTens.Visible:= true;
        edtInnerTens.Top:= y_1;
        y_1:= y_1+edtInnerTens.Height+4;
        lInnerTens.Left:= cbDNS.Left;
        edtInnerTens.Left:= lInnerTens.Left+lInnerTens.Width+8;
        udInnerTens.Left:= edtInnerTens.Left+edtInnerTens.Width;
        udInnerTens.Top:= edtInnerTens.Top;
        udInnerTens.Height:= edtInnerTens.Height;
        lInnerTens.Top:= edtInnerTens.Top+(edtInnerTens.Height-lInnerTens.Height) div 2;
        lCompShootOff.Visible:= true;
        edtCompShootOff.Visible:= true;
        lCompPriority.Visible:= true;
        edtCompPriority.Visible:= true;
        udCompPriority.Visible:= true;
        edtCompPriority.Top:= y_1;
        lCompShootOff.Left:= cbDNS.Left;
        edtCompPriority.Left:= tsMain.ClientWidth-edtCompPriority.Width-udCompPriority.Width-BRD;
        lCompPriority.Left:= edtCompPriority.Left-8-lCompPriority.Width;
        edtCompShootOff.Left:= lCompShootOff.Left+lCompShootOff.Width+8;
        edtCompShootOff.Top:= y_1;
        edtCompShootOff.Width:= lCompPriority.Left-8-edtCompShootOff.Left;
        lCompShootOff.Top:= y_1+(edtCompShootOff.Height-lCompShootOff.Height) div 2;
        lCompPriority.Top:= lCompShootOff.Top;
        y_1:= y_1+edtCompShootOff.Height;
      end
    else
      begin
        lInnerTens.Visible:= false;
        edtInnerTens.Visible:= false;
        udInnerTens.Visible:= false;
        lCompShootOff.Visible:= false;
        edtCompShootOff.Visible:= false;
        lCompPriority.Visible:= false;
        edtCompPriority.Visible:= false;
        udCompPriority.Visible:= false;
      end;
    y_1:= y_1+BRD;
  end;

  procedure RearrangeFinal;
  begin
    y_2:= BRD;
    if fFinalOn then
      begin
        tsFinal.TabVisible:= true;
        sgFinal.Visible:= rbFinalShots.Checked;
        rbFinalShots.Left:= BRD;
        sgFinal.Left:= rbFinalShots.Left+rbFinalShots.Width+8;
        sgFinal.Top:= y_2;
        rbFinalShots.Top:= y_2+(sgFinal.Height-rbFinalShots.Height) div 2;
        y_2:= y_2+sgFinal.Height+8;
        rbFinalResult.Left:= rbFinalShots.Left;
        edtFinalResult.Top:= y_2;
        edtFinalResult.Left:= rbFinalResult.Left+rbFinalResult.Width+8;
        rbFinalResult.Top:= y_2+(edtFinalResult.Height-rbFinalResult.Height) div 2;
        y_2:= y_2+edtFinalResult.Height+8;
        edtFinalPriority.Top:= y_2;
        edtFinalPriority.Left:= tsFinal.ClientWidth-edtFinalPriority.Width-udFinalPriority.Width-BRD;
        lFinalPriority.Left:= edtFinalPriority.Left-8-lFinalPriority.Width;
        lFinalPriority.Top:= y_2+(edtFinalPriority.Height-lFinalPriority.Height) div 2;
        lFinalShootOff.Left:= rbFinalShots.Left;
        lFinalShootOff.Top:= lFinalPriority.Top;
        edtFinalShootOff.Top:= y_2;
        edtFinalShootOff.Left:= lFinalShootOff.Left+lFinalShootOff.Width+8;
        edtFinalShootOff.Width:= lFinalPriority.Left-8-edtFinalShootOff.Left;
        y_2:= y_2+edtFinalShootOff.Height+BRD;
      end
    else
      begin
        tsFinal.TabVisible:= false;
        y_2:= 0;
      end;
  end;

  procedure RearrangePoints;
  begin
    if fAttributesOn then
      begin
        tsPoints.TabVisible:= true;
        y_3:= BRD;
        cbTeamPoints.Left:= BRD;
        cbTeamForPoints.Top:= y_3;
        cbTeamForPoints.Left:= cbTeamPoints.Left+cbTeamPoints.Width+8;
        cbTeamForPoints.Width:= tsPoints.ClientWidth-cbTeamForPoints.Left-BRD;
        cbTeamPoints.Top:= y_3+(cbTeamForPoints.Height-cbTeamPoints.Height) div 2;
        y_3:= y_3+cbTeamForPoints.Height+8;
        lManualPoints.Left:= cbTeamPoints.Left;
        edtManualPoints.Top:= y_3;
        edtManualPoints.Left:= lManualPoints.Left+lManualPoints.Width+8;
        lManualPoints.Top:= y_3+(edtManualPoints.Height-lManualPoints.Height) div 2;
        y_3:= y_3+edtManualPoints.Height+8;
        cbForTeam.Left:= cbTeamPoints.Left;
        cbTeamForResults.Top:= y_3;
        cbTeamForResults.Left:= cbForTeam.Left+cbForTeam.Width+8;
        cbTeamForResults.Width:= tsPoints.ClientWidth-cbTeamForResults.Left-BRD;
        cbForTeam.Top:= y_3+(cbTeamForResults.Height-cbForTeam.Height) div 2;
        y_3:= y_3+cbTeamForResults.Height+8;
        cbRegionPoints.Top:= y_3;
        cbRegionPoints.Left:= cbTeamPoints.Left;
        y_3:= y_3+cbRegionPoints.Height+8;
        cbDistrictPoints.Left:= cbTeamPoints.Left;
        cbDistrictPoints.Top:= y_3;
        y_3:= y_3+cbDistrictPoints.Height+8;
        cbOutOfRank.Left:= cbTeamPoints.Left;
        cbOutOfRank.Top:= y_3;
        y_3:= y_3+cbOutOfRank.Height+BRD;
      end
    else
      begin
        tsPoints.TabVisible:= false;
        y_3:= 0;
      end;
  end;

begin
  if fSeriesEdit.Width+lTotal.Width+8> tsMain.ClientWidth then
    PageControl1.ClientWidth:= PageControl1.ClientWidth+fSeriesEdit.Width+lTotal.Width+8 - tsMain.ClientWidth;

  lNum.Top:= 0;
  lShooter.Top:= 0;
  lShooter.Width:= lNum.Left;

  lRelay.Left:= lRelayStr.Left+lRelayStr.Width+8;
  lPosStr.Left:= lRelay.Left+lRelay.Width+16;
  lPos.Left:= lPosStr.Left+lPosStr.Width+8;
  y:= lPos.Top+lPos.Height+8;

  w_1:= BRD+fSeriesEdit.Width+8+lTotal.Width+BRD;
  w_2:= BRD+rbFinalShots.Width+8+sgFinal.Width+BRD;
  if w_1> w_2 then
    w:= w_1
  else
    w:= w_2;
  PageControl1.ClientWidth:= w;

  RearrangeMain;
  RearrangeFinal;
  RearrangePoints;

  if y_1> y_2 then
    h:= y_1
  else
    h:= y_2;
  if y_3> h then
    h:= y_3;

  PageControl1.Height:= PageControl1.Height+h-tsMain.ClientHeight;

  PageControl1.Top:= y;
  PageControl1.Left:= 0;
  ClientWidth:= PageControl1.Width;
  lNum.Left:= ClientWidth-lNum.Width;

  y:= y+PageControl1.Height;

  if fRecordCommentOn then
    begin
      y:= y+8;
      lRecordComment.Visible:= true;
      edtRecordComment.Visible:= true;
      edtRecordComment.Top:= y;
      edtRecordComment.Left:= lRecordComment.Width+8;
      edtRecordComment.Width:= ClientWidth-edtRecordComment.Left;
      lRecordComment.Left:= 0;
      lRecordComment.Top:= y+(edtRecordComment.Height-lRecordComment.Height) div 2;
      y:= y+edtRecordComment.Height;
    end
  else
    begin
      lRecordComment.Visible:= false;
      edtRecordComment.Visible:= false;
    end;

  ClientHeight:= y;

  PageControl1.ActivePage:= tsMain;
  if fSeriesEdit.Visible then
    begin
      ActiveControl:= fSeriesEdit;
    end
  else if memDNSComment.Visible then
    ActiveControl:= memDNSComment
  else
    ActiveControl:= cbDNS;

  Position:= poDesktopCenter;
end;

procedure TShooterSeriesDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WBC.ReleaseWindow (self);
  SaveValues;
end;

procedure TShooterSeriesDialog.FormCreate(Sender: TObject);
begin
  fSeriesEdit:= TShooterSeriesEditor.Create (tsMain);
  fSeriesEdit.Parent:= tsMain;
  fSeriesEdit.OnChange:= OnSeriesChange;
  KeyPreview := True; // будем перехватывать Enter/Esc на уровне формы
  UpdateLanguage;
  UpdateFonts;
  WBC.RegisterWindow (self);
end;

procedure TShooterSeriesDialog.SaveValues;
var
  i,c: integer;
begin
  for i:= 0 to fShooter.Event.TotalSeries-1 do
    fShooter.AllSeries10 [i]:= fSeriesEdit.Series10 [i];
  if fCompShootOffOn then
    begin
      fShooter.InnerTens:= udInnerTens.Position;
      fShooter.CompPriority:= udCompPriority.Position;
      fShooter.CompShootOffStr:= edtCompShootOff.Text;
    end;
  fShooter.DNSComment:= memDNSComment.Text;
  case cbDNS.ItemIndex of
    0: fShooter.DNS:= dnsNone;
    1: fShooter.DNS:= dnsCompletely;
    2: fShooter.DNS:= dnsPartially;
  end;
  if fFinalOn then
    begin
      fShooter.FinalPriority:= udFinalPriority.Position;
      fShooter.FinalShootOffStr:= edtFinalShootOff.Text;
      if rbFinalResult.Checked then
        fShooter.FinalResult10:= StrToFinal10 (edtFinalResult.Text);
    end;
  if fAttributesOn then
    begin
      fShooter.GiveDistrictPoints:= cbDistrictPoints.Checked;
      fShooter.GiveRegionPoints:= cbRegionPoints.Checked;
      if cbTeamPoints.Checked then
        fShooter.TeamForPoints:= cbTeamForPoints.Text
      else
        fShooter.TeamForPoints:= '';
      if cbForTeam.Checked then
        fShooter.TeamForResults:= cbTeamForResults.Text
      else
        fShooter.TeamForResults:= '';
      fShooter.OutOfRank:= cbOutOfRank.Checked;
      val (edtManualPoints.Text,i,c);
      fShooter.ManualPoints:= i;
    end;
  fShooter.StartList.Notify (WM_STARTLISTSHOOTERSCHANGED,0,0);
end;

procedure TShooterSeriesDialog.sgFinalClick(Sender: TObject);
begin
  if fFinalEdit then
    begin
      fShooter.FinalShots10 [fFinalCol]:= fFinalNewValue10;
      fFinalEdit:= false;
    end;
  fFinalCol:= sgFinal.Col;
end;

procedure TShooterSeriesDialog.sgFinalGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: String);
begin
  Value:= sgFinal.Cells [ACol,ARow];
  fFinalNewValue10:= StrToFinal10 (Value);
end;

procedure TShooterSeriesDialog.sgFinalSetEditText(Sender: TObject; ACol,
  ARow: Integer; const Value: String);
begin
  fFinalEdit:= true;
  fFinalNewValue10:= StrToFinal10 (sgFinal.Cells [ACol,ARow]);
end;

procedure TShooterSeriesDialog.sgFinalKeyPress(Sender: TObject; var Key: Char);
var
  idx: integer;
begin
  case Key of
    #13: if sgFinal.EditorMode then
      begin
        fShooter.FinalShots10 [sgFinal.Col]:= fFinalNewValue10;
        // если на последней колонке — закрываем форму с сохранением
        if sgFinal.Col = sgFinal.ColCount - 1 then
        begin
          fFinalEdit := false;
          edtFinalResult.Text := fShooter.FinalResultStr;
          // отложенное закрытие, чтоб избежать AV в процессе KeyPress
          PostMessage(Handle, WM_USER + 1201, 0, 0);
        end
        else
        begin
          idx:= sgFinal.Col;
          idx:= (idx+1) mod sgFinal.ColCount;
          sgFinal.Col:= idx;
          fFinalEdit:= false;
          edtFinalResult.Text:= fShooter.FinalResultStr;
        end;
        Key := #0; // подавляем бип
      end;
  end;
end;

procedure TShooterSeriesDialog.sgFinalKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  i: integer;
//  fr: TFinalResult;
begin
  case Key of
    VK_ESCAPE: begin
      // Esc: если редактируем — просто выходим из режима редактирования (без очистки),
      // если стоим на последней колонке и не редактируем — закрываем форму
      if sgFinal.EditorMode then
      begin
        sgFinal.EditorMode:= false;
        fFinalEdit:= false;
        Key := 0;
        Exit;
      end;
      if sgFinal.Col = sgFinal.ColCount - 1 then
      begin
        ModalResult := mrOk;
        Key:= 0;
      end;
    end;
    VK_DELETE: begin
      if not sgFinal.EditorMode then
        begin
          fShooter.SetFinalShotsCount (sgFinal.Col);
          for i:= 0 to sgFinal.ColCount-1 do
            begin
              if i< fShooter.FinalShotsCount then
                begin
                  sgFinal.Cells [i,0]:= fShooter.Event.FinalStr (fShooter.FinalShots10 [i]);
                end
              else
                sgFinal.Cells [i,0]:= '';
            end;
          edtFinalResult.Text:= fShooter.FinalResultStr;
          Key:= 0;
        end;
    end;
  end;
end;

procedure TShooterSeriesDialog.WmCloseSeriesOk(var M: TMessage);
begin
  // централизованное безопасное закрытие
  ModalResult := mrOk; // FormClose вызовет SaveValues
end;

procedure TShooterSeriesDialog.rbFinalShotsClick(Sender: TObject);
begin
  sgFinal.Visible:= rbFinalShots.Checked;
  if rbFinalShots.Checked then
    rbFinalResultClick (self);
end;

procedure TShooterSeriesDialog.rbFinalResultClick(Sender: TObject);
begin
  edtFinalResult.Enabled:= rbFinalResult.Checked;;
  if rbFinalResult.Checked then
    rbFinalShotsClick (self);
end;

procedure TShooterSeriesDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      // На форме: если не идёт редактирование ни в одном контроле — можно закрывать
      if (not fSeriesEdit.EditorMode) and (not sgFinal.EditorMode) then
      begin
        Key:= 0;
        ModalResult := mrOk; // FormClose вызовет SaveValues
      end;
    end;
  end;
end;

procedure TShooterSeriesDialog.OnSeriesChange(Sender: TObject);
begin
  lTotal.Caption:= format (fSumStr,[fSeriesEdit.TotalStr]);
//  RearrangeControls;
end;

end.


