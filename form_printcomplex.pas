unit form_printcomplex;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.Printers, Vcl.StdCtrls, CheckLst,

  SysFont,
  MyLanguage,
  ctrl_language,
  form_printprotocol,
  Data;

type
  TPrintComplexDialogResult= (pcdPrint,pcdSave,pcdCancel);

  TPrintComplexDialog = class (TForm)
    cblEvents: TCheckListBox;
    gbPointsFor: TGroupBox;
    gbType: TGroupBox;
    btnPrint: TButton;
    btnSave: TButton;
    btnCancel: TButton;
    rbTeams: TRadioButton;
    rbRegions: TRadioButton;
    rbDistricts: TRadioButton;
    rbGroups: TRadioButton;
    rbEvents: TRadioButton;
    gbAgeGroup: TGroupBox;
    rbYouths: TRadioButton;
    rbJuniors: TRadioButton;
    rbAdults: TRadioButton;
    memoTitle: TMemo;
    lTitle: TLabel;
    btnHTML: TButton;
    procedure btnHTMLClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fStart: TStartList;
    procedure UpdateLanguage;
    procedure UpdateFonts;
    procedure StoreChecks;
    procedure RestoreChecks;
  public
    { Public declarations }
    function Execute: TPrintComplexDialogResult;
    procedure SetStartList (AStart: TStartList);
  end;

implementation

var
  LastAgeGroup: TAgeGroup;

{$R *.dfm}

procedure TPrintComplexDialog.btnHTMLClick(Sender: TObject);
var
  sd: TSaveDialog;
  pf: TPointsFor;
  tt: TPointsTableType;
  ag: TAgeGroup;
begin
  if rbTeams.Checked then
    pf:= pfTeam
  else if rbRegions.Checked then
    pf:= pfRegion
  else
    pf:= pfDistrict;
  if rbGroups.Checked then
    tt:= pttEventTypes
  else
    tt:= pttEvents;
  if rbYouths.Checked then
    ag:= agYouths
  else if rbJuniors.Checked then
    ag:= agJuniors
  else
    ag:= agAdults;
  sd:= TSaveDialog.Create (self);
  try
    sd.DefaultExt:= '*.htm';
    sd.Filter:= 'HTML files (*.htm)|*.htm';
    sd.FilterIndex:= 0;
    case pf of
      pfTeam: sd.Title:= Language ['SaveTeamsPointsTableHTMLCaption'];
      pfRegion: sd.Title:= Language ['SaveRegionsPointsTableHTMLCaption'];
      pfDistrict: sd.Title:= Language ['SaveDistrictsPointsTableHTMLCaption'];
    end;
    sd.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing,ofNoChangeDir];
    if sd.Execute then
      begin
        LastAgeGroup:= ag;
        StoreChecks;
        fStart.SavePointsTableHTML (sd.FileName,ag,pf,tt,(fStart.TeamsGroups.Count> 0) and (pf= pfTeam),memoTitle.Lines.Text);
//        fStart.SavePointsTable (sd.FileName,ag,pf,tt,(fStart.TeamsGroups.Count> 0) and (pf= pfTeam),memoTitle.Lines.Text);
        RestoreChecks;
        sd.Free;
        Close;
      end
    else
      sd.Free;
  except
    sd.Free;
  end;
end;

procedure TPrintComplexDialog.btnPrintClick(Sender: TObject);
var
  pd: TPrintProtocolDialog;
  pf: TPointsFor;
  tt: TPointsTableType;
  ag: TAgeGroup;
begin
  pd:= TPrintProtocolDialog.Create (self);
  if rbTeams.Checked then
    pf:= pfTeam
  else if rbRegions.Checked then
    pf:= pfRegion
  else
    pf:= pfDistrict;
  if rbGroups.Checked then
    tt:= pttEventTypes
  else
    tt:= pttEvents;
  if rbYouths.Checked then
    ag:= agYouths
  else if rbJuniors.Checked then
    ag:= agJuniors
  else
    ag:= agAdults;
  case pf of
    pfTeam: pd.Caption:= Language ['PrintTeamsPointsTableCaption'];
    pfRegion: pd.Caption:= Language ['PrintRegionsPointsTableCaption'];
    pfDistrict: pd.Caption:= Language ['PrintDistrictsPointsTableCaption'];
  end;
  pd.ProtocolType:= ptStartNumbers;
//  pd.ShowAgeGroups:= false;
  pd.ShowCopies:= true;
  pd.ShowGroups:= (fStart.TeamsGroups.Count> 0) and (pf= pfTeam);
  pd.Groups:= pd.ShowGroups;
  if pd.Execute then
    begin
      LastAgeGroup:= ag;
      StoreChecks;
      fStart.PrintPointsTable (Printer,ag,pd.Copies,pf,tt,pd.Groups,memoTitle.Lines.Text);
      RestoreChecks;
      pd.Free;
      Close;
    end
  else
    pd.Free;
end;

procedure TPrintComplexDialog.btnSaveClick(Sender: TObject);
var
  sd: TSaveDialog;
  pf: TPointsFor;
  tt: TPointsTableType;
  ag: TAgeGroup;
begin
  if rbTeams.Checked then
    pf:= pfTeam
  else if rbRegions.Checked then
    pf:= pfRegion
  else
    pf:= pfDistrict;
  if rbGroups.Checked then
    tt:= pttEventTypes
  else
    tt:= pttEvents;
  if rbYouths.Checked then
    ag:= agYouths
  else if rbJuniors.Checked then
    ag:= agJuniors
  else
    ag:= agAdults;
  sd:= TSaveDialog.Create (self);
  try
    sd.DefaultExt:= '*.pdf';
    sd.Filter:= 'Acrobat PDF (*.pdf)|*.pdf';
    sd.FilterIndex:= 0;
    case pf of
      pfTeam: sd.Title:= Language ['SaveTeamsPointsTableCaption'];
      pfRegion: sd.Title:= Language ['SaveRegionsPointsTableCaption'];
      pfDistrict: sd.Title:= Language ['SaveDistrictsPointsTableCaption'];
    end;
    sd.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing,ofNoChangeDir];
    if sd.Execute then
      begin
        LastAgeGroup:= ag;
        StoreChecks;
        fStart.SavePointsTable (sd.FileName,ag,pf,tt,(fStart.TeamsGroups.Count> 0) and (pf= pfTeam),memoTitle.Lines.Text);
        RestoreChecks;
        sd.Free;
        Close;
      end
    else
      sd.Free;
  except
    sd.Free;
  end;
end;

function TPrintComplexDialog.Execute: TPrintComplexDialogResult;
var
  pf: TPointsFor;
begin
  rbTeams.Checked:= true;
  rbGroups.Checked:= true;
  case LastAgeGroup of
    agYouths: rbYouths.Checked:= true;
    agJuniors: rbJuniors.Checked:= true;
    agAdults: rbAdults.Checked:= true;
  end;
  if rbTeams.Checked then
    pf:= pfTeam
  else if rbRegions.Checked then
    pf:= pfRegion
  else
    pf:= pfDistrict;
  case pf of
    pfTeam: memoTitle.Lines.Text:= TOTAL_TEAM_CHAMPIONSHIP_TITLE;
    pfRegion: memoTitle.Lines.Text:= TOTAL_REGION_CHAMPIONSHIP_TITLE;
    pfDistrict: memoTitle.Lines.Text:= TOTAL_DISTRICT_CHAMPIONSHIP_TITLE;
  end;
  ShowModal;
  Result:= pcdCancel;
end;

procedure TPrintComplexDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
  fStart:= nil;
end;

procedure TPrintComplexDialog.RestoreChecks;
var
  i: integer;
begin
  for i:= 0 to fStart.Events.Count-1 do
    fStart.Events [i].InPointsTable:= true;
end;

procedure TPrintComplexDialog.SetStartList(AStart: TStartList);
var
  i: integer;
  ev: TStartListEventItem;
begin
  fStart:= AStart;
  cblEvents.Clear;
  for i:= 0 to fStart.Events.Count-1 do
    begin
      ev:= fStart.Events [i];
      cblEvents.Items.Add (ev.Event.CompleteName);
      cblEvents.Checked [i]:= ev.InPointsTable;
    end;
//  cblEvents.Enabled:= false;
end;

procedure TPrintComplexDialog.StoreChecks;
var
  i: integer;
begin
  for i:= 0 to fStart.Events.Count-1 do
    fStart.Events [i].InPointsTable:= cblEvents.Checked [i];
end;

procedure TPrintComplexDialog.UpdateFonts;
var
  w,y,bh: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  cblEvents.Font:= Font;
  cblEvents.Canvas.Font:= cblEvents.Font;
  cblEvents.ItemHeight:= cblEvents.Canvas.TextHeight ('Mg')+4;

  // gbPointsFor
  if gbPointsFor.Caption<> '' then
    y:= Canvas.TextHeight ('Mg')+4
  else
    y:= 8;
  rbTeams.Left:= 8;
  rbTeams.Top:= y;
  rbTeams.ClientHeight:= Canvas.TextHeight ('Mg');
  rbTeams.ClientWidth:= rbTeams.ClientHeight*2+Canvas.TextWidth (rbTeams.Caption);
  inc (y,rbTeams.Height+4);
  w:= rbTeams.Width;
  rbRegions.Left:= rbTeams.Left;
  rbRegions.Top:= y;
  rbRegions.ClientHeight:= Canvas.TextHeight ('Mg');
  rbRegions.ClientWidth:= rbRegions.ClientHeight*2+Canvas.TextWidth (rbRegions.Caption);
  inc (y,rbRegions.Height+4);
  if rbRegions.Width> w then
    w:= rbRegions.Width;
  rbDistricts.Left:= rbTeams.Left;
  rbDistricts.Top:= y;
  rbDistricts.ClientHeight:= Canvas.TextHeight ('Mg');
  rbDistricts.ClientWidth:= rbDistricts.ClientHeight*2+Canvas.TextWidth (rbDistricts.Caption);
  inc (y,rbDistricts.Height+8);
  if rbDistricts.Width> w then
    w:= rbDistricts.Width;
  gbPointsFor.Left:= 8;
  gbPointsFor.Top:= 8;
  gbPointsFor.ClientWidth:= w+16;
  gbPointsFor.ClientHeight:= y;

  // gbType
  if gbType.Caption<> '' then
    y:= Canvas.TextHeight ('Mg')+4
  else
    y:= 8;
  rbGroups.Left:= 8;
  rbGroups.Top:= y;
  rbGroups.ClientHeight:= Canvas.TextHeight ('Mg');
  rbGroups.ClientWidth:= rbGroups.ClientHeight*2+Canvas.TextWidth (rbGroups.Caption);
  inc (y,rbGroups.Height+4);
  w:= rbGroups.Width;
  rbEvents.Left:= rbGroups.Left;
  rbEvents.Top:= y;
  rbEvents.ClientHeight:= Canvas.TextHeight ('Mg');
  rbEvents.ClientWidth:= rbEvents.ClientHeight*2+Canvas.TextWidth (rbEvents.Caption);
  inc (y,rbEvents.Height+8);
  if rbEvents.Width> w then
    w:= rbEvents.Width;
  gbType.Left:= gbPointsFor.Left+gbPointsFor.Width+8;
  gbType.ClientWidth:= w+16;
  gbType.ClientHeight:= y;
  gbType.Top:= gbPointsFor.Top+gbPointsFor.Height-gbType.Height;

  // gbAgeGroup
  if gbAgeGroup.Caption<> '' then
    y:= Canvas.TextHeight ('Mg')+4
  else
    y:= 8;
  rbYouths.Left:= 8;
  rbYouths.Top:= y;
  rbYouths.ClientHeight:= Canvas.TextHeight ('Mg');
  rbYouths.ClientWidth:= rbYouths.ClientHeight*2+Canvas.TextWidth (rbYouths.Caption);
  inc (y,rbYouths.Height+4);
  w:= rbYouths.Width;
  rbJuniors.Left:= rbYouths.Left;
  rbJuniors.Top:= y;
  rbJuniors.ClientHeight:= Canvas.TextHeight ('Mg');
  rbJuniors.ClientWidth:= rbJuniors.ClientHeight*2+Canvas.TextWidth (rbJuniors.Caption);
  inc (y,rbJuniors.Height+4);
  if rbJuniors.Width> w then
    w:= rbJuniors.Width;
  rbAdults.Left:= rbYouths.Left;
  rbAdults.Top:= y;
  rbAdults.ClientHeight:= Canvas.TextHeight ('Mg');
  rbAdults.ClientWidth:= rbAdults.ClientHeight*2+Canvas.TextWidth (rbAdults.Caption);
  inc (y,rbAdults.Height+8);
  if rbAdults.Width> w then
    w:= rbAdults.Width;
  gbAgeGroup.Left:= gbType.Left+gbType.Width+8;
  gbAgeGroup.Top:= gbPointsFor.Top;
  gbAgeGroup.ClientWidth:= w+16;
  gbAgeGroup.ClientHeight:= y;

  ClientWidth:= Screen.Width div 2;

  if gbPointsFor.Width+gbType.Width+gbAgeGroup.Width+32> ClientWidth then
    ClientWidth:= gbPointsFor.Width+gbType.Width+gbAgeGroup.Width+32
  else
    begin
      w:= ClientWidth;
      gbPointsFor.Width:= round (gbPointsFor.Width*w/(gbPointsFor.Width+gbType.Width+gbAgeGroup.Width+32));
      gbType.Left:= gbPointsFor.Left+gbPointsFor.Width+8;
      dec (w,gbPointsFor.Width+8);
      gbType.Width:= round (gbType.Width*w/(gbType.Width+gbAgeGroup.Width+24));
      gbAgeGroup.Left:= gbType.Left+gbType.Width+8;
      dec (w,gbType.Width+8);
      gbAgeGroup.Width:= w-16;
    end;

  y:= gbPointsFor.Top+gbPointsFor.Height;
  if gbType.Top+gbType.Height> y then
    y:= gbType.Top+gbType.Height;
  if gbAgeGroup.Top+gbAgeGroup.Height> y then
    y:= gbAgeGroup.Top+gbAgeGroup.Height;
  y:= y+8;

  lTitle.Left:= 8;
  lTitle.Top:= y;
  y:= y+lTitle.Height+2;
  memoTitle.Top:= y;
  memoTitle.Left:= 8;
  memoTitle.ClientHeight:= Canvas.TextHeight ('Mg')*4;
  y:= y+memoTitle.Height+8;
  memoTitle.Width:= ClientWidth-16;

  cblEvents.Left:= 8;
  cblEvents.Top:= y;
  cblEvents.Width:= ClientWidth-16;
  cblEvents.ClientHeight:= cblEvents.ItemHeight*10;
  y:= y+cblEvents.Height+8;

  bh:= Canvas.TextHeight ('Mg')+12;
  btnPrint.Left:= 8;
  btnPrint.Top:= y;
  btnPrint.ClientWidth:= Canvas.TextWidth (btnPrint.Caption)+32;
  btnPrint.ClientHeight:= bh;
  btnSave.Left:= btnPrint.Left+btnPrint.Width+16;
  btnSave.Top:= y;
  btnSave.ClientWidth:= Canvas.TextWidth (btnSave.Caption)+32;
  btnSave.ClientHeight:= bh;
  btnHTML.Left:= btnSave.Left+btnSave.Width+16;
  btnHTML.Top:= y;
  btnHTML.ClientWidth:= Canvas.TextWidth (btnHTML.Caption)+32;
  btnHTML.ClientHeight:= bh;
  btnCancel.Top:= y;
  btnCancel.ClientWidth:= Canvas.TextWidth (btnCancel.Caption)+32;
  btnCancel.ClientHeight:= bh;
  btnCancel.Left:= ClientWidth-8-btnCancel.Width;

  ClientHeight:= btnPrint.Top+btnPrint.Height+8;
end;

procedure TPrintComplexDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

initialization
  LastAgeGroup:= agAdults;
end.

