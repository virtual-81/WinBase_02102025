{$a-}
unit form_eventparams;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Grids, Vcl.ComCtrls, System.DateUtils,

  Data,
  SysFont,

  MyLanguage,
  ctrl_language;

type
	TEventParamsDialog = class(TForm)
		cbFinalFracs: TCheckBox;
    btnOk: TButton;
    btnCancel: TButton;
    dtRelayTime: TDateTimePicker;
    lRelayTime: TLabel;
    gbType: TGroupBox;
    rbRegular: TRadioButton;
    rbRapidFire: TRadioButton;
    rbCenterFire: TRadioButton;
    rbMovingTarget: TRadioButton;
    gbWeaponType: TGroupBox;
    rbRifle: TRadioButton;
    rbPistol: TRadioButton;
    rbMoving: TRadioButton;
    cbCompareBySeries: TCheckBox;
    btnDeleteResults: TButton;
    edtCode: TEdit;
    lCode: TLabel;
    lName: TLabel;
    edtName: TEdit;
    lShortName: TLabel;
    edtShortName: TEdit;
    lMQSResult: TLabel;
    edtMQSResult: TEdit;
    lMinRatedResult: TLabel;
    edtMinRatedResult: TEdit;
    lFinalPlaces: TLabel;
    edtFinalPlaces: TEdit;
    lFinalShots: TLabel;
    edtFinalShots: TEdit;
    lStages: TLabel;
    edtStages: TEdit;
    lSeries: TLabel;
    edtSeries: TEdit;
    sgQualifications: TStringGrid;
    lQResults: TLabel;
    cbCompareByFinal: TCheckBox;
    rbCFP2013: TRadioButton;
    rb3P2013: TRadioButton;
    rbMT2013: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnDeleteResultsClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
	private
		fEvent: TEventItem;
    fModalResult: integer;
		procedure set_Event(const Value: TEventItem);
		procedure LoadQualifications;
		procedure SaveQualifications;
    procedure UpdateFonts;
    procedure UpdateLanguage;
	public
		{ Public declarations }
		property Event: TEventItem read fEvent write set_Event;
		function Execute: boolean;
	end;

implementation

{$R *.dfm}

{ TEventParamsDialog }

function TEventParamsDialog.Execute: boolean;
begin
  fModalResult:= mrCancel;
	Result:= (ShowModal= mrOk);
end;

procedure TEventParamsDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ModalResult:= fModalResult;
  Action:= caHide;
end;

procedure TEventParamsDialog.FormCreate(Sender: TObject);
begin
  edtCode.Top:= 0;
  rbRegular.Left:= 16;
  rbCenterFire.Left:= 16;
  rbRifle.Left:= 16;
  rbMoving.Left:= 16;
  gbType.Left:= 0;
  gbWeaponType.Left:= 0;
  btnDeleteResults.Left:= 0;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TEventParamsDialog.LoadQualifications;
var
	i: integer;
begin
	sgQualifications.RowCount:= fEvent.Data.Qualifications.Count;
	sgQualifications.Canvas.Font:= sgQualifications.Font;
	for i:= 0 to fEvent.Data.Qualifications.Count-1 do
		begin
			sgQualifications.Cells [0,i]:= fEvent.Data.Qualifications.Items [i].Name;
			sgQualifications.Cells [1,i]:= IntToStr (fEvent.Qualifications10 [i].Competition10 div 10);
      //sgQualifications.Cells [2,i]:= fEvent.FinalStr (fEvent.Qualifications10 [i].Total10);
      sgQualifications.Cells [2,i]:= fEvent.FinalStr (fEvent.Qualifications10 [i].CompetitionTens10);
		end;
end;

procedure TEventParamsDialog.set_Event(const Value: TEventItem);
begin
	fEvent:= Value;
	LoadQualifications;
	if fEvent.Tag<> '' then
    begin
  		Caption:= format (Language ['EventParamsDialog'],[fEvent.ShortName,fEvent.Name]);
      edtShortName.Enabled:= false;
    end
	else
    begin
  		Caption:= Language ['NewEventCaption'];
      edtShortName.Enabled:= true;
    end;
	edtShortName.Text:= fEvent.ShortName;
	edtName.Text:= fEvent.Name;
	edtMQSResult.Text:= IntToStr (fEvent.MQSResult10 div 10);
	edtMinRatedResult.Text:= IntToStr (fEvent.MinRatedResult10 div 10);
	edtFinalPlaces.Text:= IntToStr (fEvent.FinalPlaces);
  edtFinalShots.Text:= IntToStr (fEvent.FinalShots);
	cbFinalFracs.Checked:= fEvent.FinalFracs;
  //cbCompFracs.Checked:= fEvent.CompFracs;
	edtStages.Text:= IntToStr (fEvent.Stages);
	edtSeries.Text:= IntToStr (fEvent.SeriesPerStage);
  edtCode.TexT:= fEvent.Code;
  dtRelayTime.Time:= TimeOf (fEvent.RelayTime);
  case fEvent.EventType of
    etRegular: rbRegular.Checked:= true;
    etRapidFire: rbRapidFire.Checked:= true;
    etCenterFire: rbCenterFire.Checked:= true;
    etMovingTarget: rbMovingTarget.Checked:= true;
    etCenterFire2013: rbCFP2013.Checked:= true;
    etThreePosition2013: rb3P2013.Checked:= true;
    etMovingTarget2013: rbMT2013.Checked:= true;
  end;
  case fEvent.WeaponType of
    wtRifle: rbRifle.Checked:= true;
    wtPistol: rbPistol.Checked:= true;
    wtMoving: rbMoving.Checked:= true;
  end;
  cbCompareBySeries.Checked:= fEvent.CompareBySeries;
  cbCompareByFinal.Checked:= fEvent.CompareByFinal;
  btnDeleteResults.Enabled:= fEvent.HaveResults;
end;

procedure TEventParamsDialog.UpdateFonts;
var
  w,i: integer;
  x,ew,lw,bh: integer;
  th: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;

  w:= lName.Width;
  i:= lShortName.Width;
  if i> w then
    w:= i;
  i:= lCode.Width;
  if i> w then
    w:= i;

  lCode.Left:= w-lCode.Width;
  lName.Left:= w-lName.Width;
  lShortName.Left:= w-lShortName.Width;
  lCode.Top:= edtCode.Top+(edtCode.Height-lCode.Height) div 2;
  edtCode.Left:= w+8;
  edtName.Top:= edtCode.Top+edtCode.Height+4;
  edtName.Left:= w+8;
  lName.Top:= edtName.Top+(edtName.Height-lName.Height) div 2;
  edtShortName.Left:= w+8;
  edtShortName.Top:= edtName.Top+edtName.Height+4;
  lShortName.Top:= edtShortName.Top+(edtShortName.Height-lShortName.Height) div 2;

  th:= Canvas.TextHeight ('Mg');
  rbRegular.ClientHeight:= th;
  rbRapidFire.ClientHeight:= th;
  rbCenterFire.ClientHeight:= th;
  rbMovingTarget.ClientHeight:= th;
  rbCFP2013.ClientHeight:= th;
  rb3P2013.ClientHeight:= th;
  rbMT2013.ClientHeight:= th;
  rbRifle.ClientHeight:= th;
  rbPistol.ClientHeight:= th;
  rbMoving.ClientHeight:= th;
  cbFinalFracs.ClientHeight:= th;
  //cbCompFracs.ClientHeight:= th;
  cbCompareBySeries.ClientHeight:= th;
  cbCompareByFinal.ClientHeight:= th;

  if gbType.Caption= '' then
    rbRegular.Top:= 8
  else
    rbRegular.Top:= 8+Canvas.TextHeight (gbType.Caption);
  rbRegular.ClientWidth:= Canvas.TextWidth (rbRegular.Caption)+rbRegular.Height+8;
  rbCenterFire.ClientWidth:= Canvas.TextWidth (rbCenterFire.Caption)+rbCenterFire.Height+8;
  rbRapidFire.ClientWidth:= Canvas.TextWidth (rbRapidFire.Caption)+rbRapidFire.Height+8;
  rbMovingTarget.ClientWidth:= Canvas.TextWidth (rbMovingTarget.Caption)+rbMovingTarget.Height+8;
  rbCFP2013.ClientWidth:= Canvas.TextWidth (rbCFP2013.Caption)+rbCFP2013.Height+8;
  rb3P2013.ClientWidth:= Canvas.TextWidth (rb3P2013.Caption)+rb3P2013.Height+8;
  rbMT2013.ClientWidth:= Canvas.TextWidth (rbMT2013.Caption)+rbMT2013.Height+8;
  rbRapidFire.Top:= rbRegular.Top;
  rbCenterFire.Top:= rbRegular.Top+rbRegular.Height+4;
  rbMovingTarget.Top:= rbCenterFire.Top;
  rbCFP2013.Top:= rbCenterFire.Top+rbCenterFire.Height+4;
  rb3P2013.Top:= rbCFP2013.Top;
  rbMT2013.Top:= rbCFP2013.Top+rbCFP2013.Height+4;
  gbType.ClientHeight:= rbMT2013.Top+rbMT2013.Height+8;
  w:= rbRegular.Width;
  i:= rbCenterFire.Width;
  if i> w then
    w:= i;
  i:= rbCFP2013.Width;
  if i> w then
    w:= i;
  i:= rbMT2013.Width;
  if i> w then
    w:= i;
  rbRapidFire.Left:= rbRegular.Left+16+w;
  rbMovingTarget.Left:= rbRapidFire.Left;
  rb3P2013.Left:= rbRapidFire.Left;
  w:= rbRapidFire.Width;
  i:= rbMovingTarget.Width;
  if i> w then
    w:= i;
  i:= rb3P2013.Width;
  if i> w then
    w:= i;
  gbType.ClientWidth:= rbRapidFire.Left+w+16;
  gbType.Top:= edtShortName.Top+edtShortName.Height+8;

  if gbWeaponType.Caption= '' then
    rbRifle.Top:= 8
  else
    rbRifle.Top:= 8+Canvas.TextHeight (gbWeaponType.Caption);
  rbRifle.ClientWidth:= Canvas.TextWidth (rbRifle.Caption)+rbRifle.Height+8;
  rbPistol.ClientWidth:= Canvas.TextWidth (rbPistol.Caption)+rbPistol.Height+8;
  rbMoving.ClientWidth:= Canvas.TextWidth (rbMoving.Caption)+rbMoving.Height+8;
  rbPistol.Top:= rbRifle.Top;
  rbMoving.Top:= rbRifle.Top+rbRifle.Height+4;
  gbWeaponType.ClientHeight:= rbMoving.Top+rbMoving.Height+8;
  rbPistol.Left:= rbRifle.Left+rbRifle.Width+16;
  w:= rbMoving.Width+32;
  i:= rbPistol.Left+rbPistol.Width+16;
  if i> w then
    w:= i;
  gbWeaponType.ClientWidth:= w;
  gbWeaponType.Top:= gbType.Top+gbType.Height+8;

  lw:= lMQSResult.Width;
  if lMinRatedResult.Width> lw then
    lw:= lMinRatedResult.Width;
  if lFinalPlaces.Width> lw then
    lw:= lFinalPlaces.Width;
  if lFinalShots.Width> lw then
    lw:= lFinalShots.Width;
  if lStages.Width> lw then
    lw:= lStages.Width;
  if lSeries.Width> lw then
    lw:= lSeries.Width;
  if lRelayTime.Width> lw then
    lw:= lRelayTime.Width;

  ew:= dtRelayTime.ClientHeight+Canvas.TextWidth (FormatDateTime (' hh:nn:ss ',0));
  x:= lw+8+ew+16;
  if gbType.Width+16> x then
    x:= gbType.Width+16;
  if gbWeaponType.Width+16> x then
    x:= gbWeaponType.Width;

  gbType.Width:= x-16;
  gbWeaponType.Width:= x-16;

  lw:= x-16-ew-8;

  edtMQSResult.ClientWidth:= ew;
  edtMQSResult.Top:= gbWeaponType.Top+gbWeaponType.Height+8;
  edtMQSResult.Left:= lw+8;
  lMQSResult.Top:= edtMQSResult.Top+(edtMQSResult.Height-lMQSResult.Height) div 2;
  lMQSResult.Left:= lw-lMQSResult.Width;
  edtMinRatedResult.ClientWidth:= ew;
  edtMinRatedResult.Top:= edtMQSResult.Top+edtMQSResult.Height+4;
  edtMinRatedResult.Left:= lw+8;
  lMinRatedResult.Top:= edtMinRatedResult.Top+(edtMinRatedResult.Height-lMinRatedResult.Height) div 2;
  lMinRatedResult.Left:= lw-lMinRatedResult.Width;
  edtFinalPlaces.ClientWidth:= ew;
  edtFinalPlaces.Top:= edtMinRatedResult.Top+edtMinRatedResult.Height+4;
  edtFinalPlaces.Left:= lw+8;
  lFinalPlaces.Top:= edtFinalPlaces.Top+(edtFinalPlaces.Height-lFinalPlaces.Height) div 2;
  lFinalPlaces.Left:= lw-lFinalPlaces.Width;
  edtFinalShots.ClientWidth:= ew;
  edtFinalShots.Top:= edtFinalPlaces.Top+edtFinalPlaces.Height+4;
  edtFinalShots.Left:= lw+8;
  lFinalShots.Top:= edtFinalShots.Top+(edtFinalShots.Height-lFinalShots.Height) div 2;
  lFinalShots.Left:= lw-lFinalShots.Width;
  edtStages.ClientWidth:= ew;
  edtStages.Top:= edtFinalShots.Top+edtFinalShots.Height+4;
  edtStages.Left:= lw+8;
  lStages.Top:= edtStages.Top+(edtStages.Height-lStages.Height) div 2;
  lStages.Left:= lw-lStages.Width;
  edtSeries.ClientWidth:= ew;
  edtSeries.Top:= edtStages.Top+edtStages.Height+4;
  edtSeries.Left:= lw+8;
  lSeries.Top:= edtSeries.Top+(edtSeries.Height-lSeries.Height) div 2;
  lSeries.Left:= lw-lSeries.Width;
  dtRelayTime.ClientWidth:= ew;
  dtRelayTime.Top:= edtSeries.Top+edtSeries.Height+4;
  dtRelayTime.Left:= lw+8;
  lRelayTime.Top:= dtRelayTime.Top+(dtRelayTime.Height-lRelayTime.Height) div 2;
  lRelayTime.Left:= lw-lRelayTime.Width;

  bh:= Canvas.TextHeight ('Mg')+12;
  btnDeleteResults.ClientWidth:= Canvas.TextWidth (btnDeleteResults.Caption)+32;
  btnDeleteResults.ClientHeight:= bh;
  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w;
  btnOk.ClientHeight:= bh;
  btnCancel.ClientWidth:= w;
  btnCancel.ClientHeight:= bh;
  btnDeleteResults.Top:= dtRelayTime.Top+dtRelayTime.Height+16;
  btnOk.Top:= btnDeleteResults.Top;
  btnCancel.Top:= btnOk.Top;
  ClientHeight:= btnOk.Top+btnOk.Height;

  w:= Canvas.TextWidth (cbFinalFracs.Caption)+cbFinalFracs.Height+8;
  //i:= Canvas.TextWidth (cbCompFracs.Caption)+cbCompFracs.Height+8;
  //if i> w then
    //w:= i;
  i:= Canvas.TextWidth (cbCompareBySeries.Caption)+cbCompareBySeries.Height+8;
  if i> w then
    w:= i;
  i:= Canvas.TextWidth (cbCompareByFinal.Caption)+cbCompareByFinal.Height+8;
  if i> w then
    w:= i;
  cbFinalFracs.ClientWidth:= w;
  //cbCompFracs.ClientWidth:= w;
  cbCompareBySeries.ClientWidth:= w;
  cbCompareByFinal.ClientWidth:= w;
  cbFinalFracs.Left:= x;
  //cbCompFracs.Left:= x;
  cbCompareBySeries.Left:= x;
  cbCompareByFinal.Left:= x;
  //cbCompFracs.Top:= btnOk.Top-16-cbCompFracs.Height;
  cbFinalFracs.Top:= btnOk.Top-16-cbFinalFracs.Height;
  cbCompareBySeries.Top:= cbFinalFracs.Top-4-cbCompareBySeries.Height;
  cbCompareByFinal.Top:= cbCompareBySeries.Top-4-cbCompareByFinal.Height;
  lQResults.Left:= x;
  lQResults.Top:= gbType.Top;
  sgQualifications.Left:= x;
  sgQualifications.Top:= lQResults.Top+lQResults.Height+2;
  sgQualifications.Height:= cbCompareByFinal.Top-8-sgQualifications.Top;
  sgQualifications.Canvas.Font:= sgQualifications.Font;
  sgQualifications.ColWidths [1]:= sgQualifications.Canvas.TextWidth ('0000000');
  sgQualifications.ColWidths [2]:= sgQualifications.Canvas.TextWidth ('0000.0')+8;
  sgQualifications.ColWidths [0]:= sgQualifications.Canvas.TextWidth ('AAAAAAAAA');
  sgQualifications.ClientWidth:= sgQualifications.ColWidths [0]+sgQualifications.ColWidths [1]+
    sgQualifications.ColWidths [2]+sgQualifications.GridLineWidth*3;
  if sgQualifications.Width> w then
    w:= sgQualifications.Width
  else
    begin
      sgQualifications.Width:= w;
      sgQualifications.ColWidths [0]:= sgQualifications.ClientWidth-sgQualifications.ColWidths [2]-
        sgQualifications.ColWidths [1]-sgQualifications.GridLineWidth*3;
    end;
  ClientWidth:= x+w;

  edtCode.Width:= ClientWidth-edtCode.Left;
  edtName.Width:= ClientWidth-edtName.Left;
  edtShortName.Width:= ClientWidth-edtShortName.Left;
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;
end;

procedure TEventParamsDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TEventParamsDialog.btnDeleteResultsClick(Sender: TObject);
begin
  if MessageDlg (Language ['DeleteEventResultsPrompt'],mtConfirmation,[mbYes,mbNo],0)<> idYes then
    exit;
  fEvent.Data.DeleteResults (fEvent);
  btnDeleteResults.Enabled:= false;
end;

procedure TEventParamsDialog.btnOkClick(Sender: TObject);
var
	v,i: integer;
  w: word;
begin
  if edtShortName.Text= '' then
    begin
      MessageDlg (Language ['EventShortNameEmpty'],mtError,[mbOk],0);
      exit;
    end;
	SaveQualifications;
	fEvent.ShortName:= edtShortName.Text;
	if fEvent.Tag= '' then
		fEvent.CreateTag;
	fEvent.Name:= edtName.Text;
	fEvent.MQSResult10:= StrToFinal10 (edtMQSResult.Text);
	fEvent.MinRatedResult10:= StrToFinal10 (edtMinRatedResult.Text);
	val (edtFinalPlaces.Text,v,i);
	fEvent.FinalPlaces:= v;
  val (edtFinalShots.Text,w,i);
  fEvent.FinalShots:= w;
	fEvent.FinalFracs:= cbFinalFracs.Checked;
  //fEvent.CompFracs:= cbCompFracs.Checked;
	val (edtStages.Text,v,i);
	fEvent.Stages:= v;
	val (edtSeries.Text,v,i);
	fEvent.SeriesPerStage:= v;
  fEvent.Code:= edtCode.Text;
  fEvent.RelayTime:= TimeOf (dtRelayTime.Time);
  if rbRegular.Checked then
    fEvent.EventType:= etRegular
  else if rbRapidFire.Checked then
    fEvent.EventType:= etRapidFire
  else if rbCenterFire.Checked then
    fEvent.EventType:= etCenterFire
  else if rbMovingTarget.Checked then
    fEvent.EventType:= etMovingTarget
  else if rbCFP2013.Checked then
    fEvent.EventType:= etCenterFire2013
  else if rb3P2013.Checked then
    fEvent.EventType:= etThreePosition2013
  else if rbMT2013.Checked then
    fEvent.EventType:= etMovingTarget2013;
  if rbRifle.Checked then
    fEvent.WeaponType:= wtRifle
  else if rbPistol.Checked then
    fEvent.WeaponType:= wtPistol
  else if rbMoving.Checked then
    fEvent.WeaponType:= wtMoving
  else
    fEvent.WeaponType:= wtNone;
  fEvent.CompareBySeries:= cbCompareBySeries.Checked;
  fEvent.CompareByFinal:= cbCompareByFinal.Checked;
  fModalResult:= mrOk;
  Close;
end;

procedure TEventParamsDialog.SaveQualifications;
var
	i: integer;
  qr: TQualificationResult10;
begin
	for i:= 0 to fEvent.Data.Qualifications.Count-1 do
		begin
			qr.Competition10:= StrToFinal10 (sgQualifications.Cells [1,i]);
			//qr.Total10:= StrToFinal10 (sgQualifications.Cells [2,i]);
			qr.CompetitionTens10:= StrToFinal10 (sgQualifications.Cells [2,i]);
      {if not fEvent.FinalFracs then
        qr.Total10:= (qr.Total10 div 10) * 10;}
      fEvent.Qualifications10 [i]:= qr;
		end;
end;

end.

