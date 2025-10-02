{$a-}
unit form_printprotocol;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.Printers, Vcl.ComCtrls,

  Data,
  SysFont,

  MyLanguage,
  PrinterSelector,
  ctrl_language;

type
  TProtocolType= (ptStart,ptResults,ptStartNumbers);
  TProtocolFormat= (pfRussian,pfInternational);

type
  TPrintProtocolDialog = class(TForm)
    btnOk: TButton;
    gbResults: TGroupBox;
    cbFinal: TCheckBox;
    cbReport: TCheckBox;
    cbTeams: TCheckBox;
    cbTeamPoints: TCheckBox;
    btnCancel: TButton;
    gbFormat: TGroupBox;
    rbRus: TRadioButton;
    rbInt: TRadioButton;
    cbRegionPoints: TCheckBox;
    cbDistrictPoints: TCheckBox;
    gbGroups: TGroupBox;
    cbGroups: TCheckBox;
    cbPrintJury: TCheckBox;
    cbPrintSecretery: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure rbRusClick(Sender: TObject);
    procedure rbIntClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
    fFinal,fFinalEnabled: boolean;
    fReport: boolean;
    fTeams,fTeamsEnabled: boolean;
    fTeamPoints,fTeamPointEnabled: boolean;
    fRegionPoints,fRegionPointsEnabled: boolean;
    fDistrictPoints,fDistrictPointsEnabled: boolean;
    fPrintJury,fPrintSecretery: boolean;
    gbPrinter: TPrinterSelector;
    procedure set_PrintJury(const Value: boolean);
    procedure set_PrintSecretery(const Value: boolean);
    function get_Groups: boolean;
    procedure set_Groups(const Value: boolean);
    function get_ShowGroups: boolean;
    procedure set_ShowGroups(const Value: boolean);
    function get_Pages: string;
    procedure set_Pages(const Value: string);
    function get_ShowPages: boolean;
    procedure set_ShowPages(const Value: boolean);
    procedure set_Final(const Value: boolean);
    procedure set_Report(const Value: boolean);
    procedure set_Teams(const Value: boolean);
    procedure set_TeamPoints(const Value: boolean);
    procedure set_ProtocolType(const Value: TProtocolType);
    procedure set_FinalEnabled(const Value: boolean);
    function get_ProtocolFormat: TProtocolFormat;
    procedure set_ProtocolFormat(const Value: TProtocolFormat);
    procedure set_TeamsEnabled(const Value: boolean);
    procedure set_TeamPointsEnabled(const Value: boolean);
    function get_SelectPrinter: boolean;
    procedure set_SelectPrinter(const Value: boolean);
    function get_Copies: integer;
    procedure set_Copies(const Value: integer);
    function get_ShowCopies: boolean;
    procedure set_ShowCopies(const Value: boolean);
    procedure ArrangeBoxes;
    procedure set_RegionPoints(const Value: boolean);
    procedure set_RegionPointsEnabled(const Value: boolean);
    procedure set_DistrictPoints(const Value: boolean);
    procedure set_DistrictPointsEnabled(const Value: boolean);
    procedure UpdateLanguage;
    procedure UpdateFonts;
  public
    { Public declarations }
    function Execute: boolean;
    property Final: boolean read fFinal write set_Final;
    property FinalEnabled: boolean read fFinalEnabled write set_FinalEnabled;
    property Report: boolean read fReport write set_Report;
    property Teams: boolean read fTeams write set_Teams;
    property TeamsEnabled: boolean read fTeamsEnabled write set_TeamsEnabled;
    property TeamPoints: boolean read fTeamPoints write set_TeamPoints;
    property TeamPointsEnabled: boolean read fTeamPointEnabled write set_TeamPointsEnabled;
    property RegionPoints: boolean read fRegionPoints write set_RegionPoints;
    property RegionPointsEnabled: boolean read fRegionPointsEnabled write set_RegionPointsEnabled;
    property DistrictPoints: boolean read fDistrictPoints write set_DistrictPoints;
    property DistrictPointsEnabled: boolean read fDistrictPointsEnabled write set_DistrictPointsEnabled;
    property ProtocolType: TProtocolType write set_ProtocolType;
    property ProtocolFormat: TProtocolFormat read get_ProtocolFormat write set_ProtocolFormat;
    property SelectPrinter: boolean read get_SelectPrinter write set_SelectPrinter;
    property Copies: integer read get_Copies write set_Copies;
    property ShowCopies: boolean read get_ShowCopies write set_ShowCopies;
    property ShowPages: boolean read get_ShowPages write set_ShowPages;
    property Pages: string read get_Pages write set_Pages;
    property ShowGroups: boolean read get_ShowGroups write set_ShowGroups;
    property Groups: boolean read get_Groups write set_Groups;
    property PrintJury: boolean read fPrintJury write set_PrintJury;
    property PrintSecretery: boolean read fPrintSecretery write set_PrintSecretery;
  end;

implementation

{$R *.dfm}

function TPrintProtocolDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TPrintProtocolDialog.FormCreate(Sender: TObject);
begin
  gbPrinter:= TPrinterSelector.Create (self);
  gbPrinter.Name:= 'gbPrinter';
  gbPrinter.Parent:= Self;
  UpdateLanguage;
  rbRus.Checked:= true;
  ShowPages:= false;
  ShowGroups:= false;
  UpdateFonts;
end;

procedure TPrintProtocolDialog.set_Final(const Value: boolean);
begin
  fFinal:= Value;
  cbFinal.Checked:= Value;
end;

procedure TPrintProtocolDialog.set_Report(const Value: boolean);
begin
  fReport:= Value;
  cbReport.Checked:= Value;
end;

procedure TPrintProtocolDialog.set_Teams(const Value: boolean);
begin
  fTeams:= Value;
  cbTeams.Checked:= Value;
end;

procedure TPrintProtocolDialog.set_TeamPoints(const Value: boolean);
begin
  fTeamPoints:= Value;
  cbTeamPoints.Checked:= Value;
end;

procedure TPrintProtocolDialog.set_ProtocolType(
  const Value: TProtocolType);
begin
  case Value of
    ptStart: begin
      gbResults.Visible:= false;
      gbFormat.Visible:= false;
      ArrangeBoxes;
    end;
    ptResults: begin
      gbFormat.Visible:= true;
      gbResults.Visible:= true;
      ArrangeBoxes;
    end;
    ptStartNumbers: begin
      gbResults.Visible:= false;
      gbFormat.Visible:= false;
      ArrangeBoxes;
    end;
  end;
end;

procedure TPrintProtocolDialog.set_FinalEnabled(const Value: boolean);
begin
  fFinalEnabled:= Value;
  cbFinal.Enabled:= Value;
  if not Value then
    Final:= false;
end;

procedure TPrintProtocolDialog.set_Groups(const Value: boolean);
begin
  cbGroups.Checked:= Value;
end;

function TPrintProtocolDialog.get_Pages: string;
begin
  Result:= gbPrinter.Pages;
end;

function TPrintProtocolDialog.get_ProtocolFormat: TProtocolFormat;
begin
  if rbRus.Checked then
    Result:= pfRussian
  else if rbInt.Checked then
    Result:= pfInternational
  else
    Result:= pfRussian;
end;

procedure TPrintProtocolDialog.set_Pages(const Value: string);
begin
  gbPrinter.Pages:= Value;
end;

procedure TPrintProtocolDialog.set_PrintJury(const Value: boolean);
begin
  fPrintJury:= Value;
  cbPrintJury.Checked:= Value;
end;

procedure TPrintProtocolDialog.set_PrintSecretery(const Value: boolean);
begin
  fPrintSecretery := Value;
  cbPrintSecretery.Checked:= Value;
end;

procedure TPrintProtocolDialog.set_ProtocolFormat(
  const Value: TProtocolFormat);
begin
  case Value of
    pfRussian: begin
      rbRus.Checked:= true;
      rbRusClick (self);
    end;
    pfInternational: begin
      rbInt.Checked:= true;
      rbIntClick (self);
    end;
  end;
end;

procedure TPrintProtocolDialog.set_TeamsEnabled(const Value: boolean);
begin
  fTeamsEnabled:= Value;
  cbTeams.Enabled:= fTeamsEnabled;
  if not Value then
    Teams:= false;
end;

procedure TPrintProtocolDialog.UpdateFonts;
var
  th,w,w1: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;

  th:= Canvas.TextHeight ('Mg');

  w:= Canvas.TextWidth (btnOk.Caption);
  w1:= Canvas.TextWidth (btnCancel.Caption);
  if w1> w then
    w:= w1;
  btnOk.ClientWidth:= w+32;
  btnCancel.ClientWidth:= w+32;
  btnOk.ClientHeight:= th+12;
  btnCancel.ClientHeight:= btnOk.ClientHeight;

  rbRus.ClientHeight:= th;
  rbRus.ClientWidth:= rbRus.Height+8+Canvas.TextWidth (rbRus.Caption);
  rbInt.ClientHeight:= th;
  rbInt.ClientWidth:= rbInt.Height+8+Canvas.TextWidth (rbInt.Caption);
  rbRus.Top:= 8+Canvas.TextHeight (gbFormat.Caption);
  rbInt.Top:= rbRus.Top;
  gbFormat.ClientHeight:= rbRus.Top+rbRus.Height+8;
  gbFormat.ClientWidth:= 16+rbRus.Width+8+rbInt.Width+16;

  cbFinal.Left:= 16;
  cbFinal.ClientHeight:= th;
  cbFinal.ClientWidth:= cbFinal.Height+8+Canvas.TextWidth (cbFinal.Caption);
  cbFinal.Top:= 8+Canvas.TextHeight (gbResults.Caption);
  cbTeamPoints.Top:= cbFinal.Top;
  cbTeamPoints.ClientHeight:= th;
  cbTeamPoints.ClientWidth:= cbTeamPoints.Height+8+Canvas.TextWidth (cbTeamPoints.Caption);
  cbReport.Left:= 16;
  cbReport.Top:= cbFinal.Top+cbFinal.Height+8;
  cbReport.ClientHeight:= th;
  cbReport.ClientWidth:= cbReport.Height+8+Canvas.TextWidth (cbReport.Caption);
  cbRegionPoints.Top:= cbReport.Top;
  cbRegionPoints.ClientHeight:= th;
  cbRegionPoints.ClientWidth:= cbRegionPoints.Height+8+Canvas.TextWidth (cbRegionPoints.Caption);
  cbTeams.Left:= 16;
  cbTeams.Top:= cbReport.Top+cbReport.Height+8;
  cbTeams.ClientHeight:= th;
  cbTeams.ClientWidth:= cbTeams.Height+8+Canvas.TextWidth (cbTeams.Caption);
  cbDistrictPoints.Top:= cbTeams.Top;
  cbDistrictPoints.ClientHeight:= th;
  cbDistrictPoints.ClientWidth:= cbDistrictPoints.Height+8+Canvas.TextWidth (cbDistrictPoints.Caption);
  cbPrintJury.Top:= cbTeams.Top+cbTeams.Height+8;
  cbPrintJury.Left:= 16;
  cbPrintJury.ClientHeight:= th;
  cbPrintJury.ClientWidth:= cbPrintJury.Height+8+Canvas.TextWidth (cbPrintJury.Caption);
  cbPrintSecretery.Top:= cbPrintJury.Top;
  cbPrintSecretery.ClientHeight:= th;
  cbPrintSecretery.ClientWidth:= cbPrintSecretery.Height+8+Canvas.TextWidth (cbPrintSecretery.Caption);
  w:= cbFinal.Width;
  if cbReport.Width> w then
    w:= cbReport.Width;
  if cbTeams.Width> w then
    w:= cbTeams.Width;
  if cbPrintJury.Width> w then
    w:= cbPrintJury.Width;
  w1:= cbTeamPoints.Width;
  if cbRegionPoints.Width> w1 then
    w1:= cbRegionPoints.Width;
  if cbDistrictPoints.Width> w1 then
    w1:= cbDistrictPoints.Width;
  if cbPrintSecretery.Width> w1 then
    w1:= cbPrintSecretery.Width;
  gbResults.ClientWidth:= 16+w+8+w1+16+16;
  gbResults.ClientHeight:= cbPrintJury.Top+cbPrintJury.Height+8;

  cbGroups.ClientHeight:= th;
  cbGroups.ClientWidth:= cbGroups.Height+8+Canvas.TextWidth (cbGroups.Caption);
  gbGroups.ClientWidth:= cbGroups.Left+cbGroups.Width+8;
  gbGroups.ClientHeight:= cbGroups.Top+cbGroups.Height+8;
end;

procedure TPrintProtocolDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TPrintProtocolDialog.set_TeamPointsEnabled(const Value: boolean);
begin
  fTeamPointEnabled:= Value;
  cbTeamPoints.Enabled:= Value;
  if not Value then
    TeamPoints:= false;
end;

procedure TPrintProtocolDialog.rbRusClick(Sender: TObject);
begin
  gbResults.Enabled:= true;
  cbFinal.Enabled:= fFinalEnabled;
  cbFinal.Checked:= fFinal;
  cbReport.Enabled:= true;
  cbReport.Checked:= fReport;
  cbTeams.Enabled:= fTeamsEnabled;
  cbTeams.Checked:= fTeams;
  cbTeamPoints.Enabled:= fTeamPointEnabled;
  cbTeamPoints.Checked:= fTeamPoints;
  cbRegionPoints.Enabled:= fRegionPointsEnabled;
  cbRegionPoints.Checked:= fRegionPoints;
  cbDistrictPoints.Enabled:= fDistrictPointsEnabled;
  cbDistrictPoints.Checked:= fDistrictPoints;
  cbPrintJury.Enabled:= true;
  cbPrintJury.Checked:= fPrintJury;
  cbPrintSecretery.Enabled:= true;
  cbPrintSecretery.Checked:= fPrintSecretery;
end;

procedure TPrintProtocolDialog.rbIntClick(Sender: TObject);
begin
  gbResults.Enabled:= false;
  cbFinal.Enabled:= fFinalEnabled;
  cbFinal.Checked:= fFinal;
  cbReport.Enabled:= false;
  cbReport.Checked:= false;
  cbTeams.Enabled:= fTeamsEnabled;
  cbTeams.Checked:= fTeams;
//  cbTeams.Enabled:= false;
//  cbTeams.Checked:= false;
  cbTeamPoints.Enabled:= false;
  cbTeamPoints.Checked:= false;
  cbDistrictPoints.Checked:= false;
  cbDistrictPoints.Enabled:= false;
  cbRegionPoints.Checked:= false;
  cbRegionPoints.Enabled:= false;
  cbPrintJury.Enabled:= false;
  cbPrintSecretery.Enabled:= false;
end;

procedure TPrintProtocolDialog.btnOkClick(Sender: TObject);
begin
  fFinal:= cbFinal.Checked;
  fReport:= cbReport.Checked;
  fTeams:= cbTeams.Checked;
  fTeamPoints:= cbTeamPoints.Checked;
  fRegionPoints:= cbRegionPoints.Checked;
  fDistrictPoints:= cbDistrictPoints.Checked;
  fPrintJury:= cbPrintJury.Checked;
  fPrintSecretery:= cbPrintSecretery.Checked;
end;

function TPrintProtocolDialog.get_SelectPrinter: boolean;
begin
  Result:= gbPrinter.Visible;
end;

procedure TPrintProtocolDialog.set_SelectPrinter(const Value: boolean);
begin
  gbPrinter.Visible:= Value;
  ArrangeBoxes;
end;

function TPrintProtocolDialog.get_Copies: integer;
begin
  Result:= gbPrinter.Copies;
end;

function TPrintProtocolDialog.get_Groups: boolean;
begin
  Result:= (gbGroups.Visible) and (cbGroups.Checked);
end;

procedure TPrintProtocolDialog.set_Copies(const Value: integer);
begin
  gbPrinter.Copies:= Value;
end;

function TPrintProtocolDialog.get_ShowCopies: boolean;
begin
  Result:= gbPrinter.ShowCopies;
end;

function TPrintProtocolDialog.get_ShowGroups: boolean;
begin
  Result:= gbGroups.Visible;
end;

function TPrintProtocolDialog.get_ShowPages: boolean;
begin
  Result:= gbPrinter.ShowPages;
end;

procedure TPrintProtocolDialog.set_ShowCopies(const Value: boolean);
begin
  gbPrinter.ShowCopies:= Value;
  ArrangeBoxes;
end;

procedure TPrintProtocolDialog.set_ShowGroups(const Value: boolean);
begin
  gbGroups.Visible:= Value;
  ArrangeBoxes;
end;

procedure TPrintProtocolDialog.set_ShowPages(const Value: boolean);
begin
  gbPrinter.ShowPages:= Value;
  ArrangeBoxes;
end;

procedure TPrintProtocolDialog.ArrangeBoxes;
var
  w,y: integer;
begin
  y:= 0;
  gbPrinter.Top:= y;
  if gbPrinter.Visible then
    begin
      gbPrinter.Width:= ClientWidth;
      inc (y,gbPrinter.Height+16);
    end;
  gbFormat.Top:= y;
  if gbFormat.Visible then
    begin
      inc (y,gbFormat.Height+16);
    end;
  gbResults.Top:= y;
  if gbResults.Visible then
    begin
      inc (y,gbResults.Height+16);
    end;
  gbGroups.Top:= y;
  if gbGroups.Visible then
    begin
      inc (y,gbResults.Height+16);
    end;
  btnOk.Top:= y;
  btnCancel.Top:= y;
  ClientHeight:= btnOk.Top+btnOk.Height;

  w:= gbPrinter.Width;
  if (gbFormat.Visible) and (gbFormat.Width> w) then
    w:= gbFormat.Width;
  if (gbResults.Visible) and (gbResults.Width> w) then
    w:= gbResults.Width;
  if (gbGroups.Visible) and (gbGroups.Width> w) then
    w:= gbGroups.Width;
  if btnOk.Width+8+btnCancel.Width> w then
    w:= btnOk.Width+8+btnCancel.Width;
  ClientWidth:= w;

  if gbFormat.Visible then
    begin
      gbFormat.Width:= ClientWidth;
      rbInt.Left:= gbFormat.ClientWidth div 2+4;
    end;

  if gbResults.Visible then
    begin
      gbResults.Width:= ClientWidth;
      cbTeamPoints.Left:= gbResults.ClientWidth div 2+4;
      cbRegionPoints.Left:= cbTeamPoints.Left;
      cbDistrictPoints.Left:= cbTeamPoints.Left;
      cbPrintSecretery.Left:= cbTeamPoints.Left;
    end;

  if gbGroups.Visible then
    begin
      gbGroups.Width:= ClientWidth;
    end;

  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;

  Position:= poScreenCenter;
end;

procedure TPrintProtocolDialog.set_RegionPoints(const Value: boolean);
begin
  fRegionPoints:= Value;
  cbRegionPoints.Checked:= Value;
end;

procedure TPrintProtocolDialog.set_RegionPointsEnabled(
  const Value: boolean);
begin
  fRegionPointsEnabled:= Value;
  cbRegionPoints.Enabled:= Value;
  if not Value then
    RegionPoints:= false;
end;

procedure TPrintProtocolDialog.set_DistrictPoints(const Value: boolean);
begin
  fDistrictPoints:= Value;
  cbDistrictPoints.Checked:= Value;
end;

procedure TPrintProtocolDialog.set_DistrictPointsEnabled (const Value: boolean);
begin
  fDistrictPointsEnabled:= Value;
  cbDistrictPoints.Enabled:= Value;
  if not Value then
    DistrictPoints:= false;
end;

end.

