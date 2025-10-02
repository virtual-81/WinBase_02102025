unit print_results;

interface

uses
  System.SysUtils, Data,MyPrint,MyTables,MyReports,Vcl.Graphics,Winapi.Windows;

type
  TPrintResults= class
  private
    fEvent: TStartListEventItem;
    fReport: TMyUserReport;
    fPages: array of TMetafileCanvas;
    fHeaderFontSize: integer;
    fFooterFontSize: integer;
    fLargeFontSize,fSmallFontSize: integer;
    //fHeadetTH,fFooterTH,fLTH,fSTH: integer;
    fcFinal: TMyReportColumn;
    fcRank,fcNum,fcName,fcYear,fcQualification,fcRegion,fcDistrict,fcClub,fcResults: TMyReportColumn;
    fcSeries,fcStages,fcSum,fcDNF,fcQualified,fcShootoff,fcTeamPoints,fcQualPoints: TMyReportColumn;
    fcDistrictPoints,fcRegionPoints: TMyReportColumn;
    procedure OnGetHeaderHeight (Sender: TMyCustomReport; Index: integer; var AHeight: integer);
    procedure OnGetCanvas (Sender: TMyCustomReport; Index: integer; var ACanvas: TCanvas);
    procedure OnGetFooterHeight (Sender: TMyCustomReport; Index: integer; var AHeight: integer);
    procedure OnGetRowHeight (Sender: TMyCustomReport; Index: integer; var AHeight: integer);
    procedure OnNewPage (Sender: TMyCustomReport; Index: integer; AFirst: boolean);
    procedure OnPrintRow (Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect);
    procedure OnPrintCell (Sender: TMyCustomReport; ARow,ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect);
    procedure OnPrintHeader (Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect);
    procedure OnPrintFooter (Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect);
  public
    constructor Create (AEvent: TStartListEventItem);
    destructor Destroy; override;
    procedure Prepare;
  end;

implementation

{ TPrintResults }

const
  COL_FINAL = 100;
  COL_RANK = 0;
  COL_NUM = 1;
  COL_NAME = 2;
  COL_YEAR = 3;
  COL_QUALIFICATION = 4;
  COL_REGION = 5;
  COL_DISTRICT = 6;
  COL_CLUB = 7;

  COL_RESULTS = 8;
  COL_SERIES = 9;
  COL_STAGES = 10;
  COL_SUM = 11;
  COL_DNF = 12;
  COL_QUALIFIED = 13;
  COL_SHOOTOFF = 14;
  COL_TEAMPOINTS = 15;
  COL_QUALPOINTS = 16;
  COL_DISTRICTPOINTS = 17;
  COL_REGIONPOINTS = 18;

constructor TPrintResults.Create(AEvent: TStartListEventItem);
var
  i: integer;
begin
  inherited Create;
  fEvent:= AEvent;
  fReport:= TMyUserReport.Create;
  fReport.OnGetCanvas:= OnGetCanvas;
  fReport.OnGetHeaderHeight:= OnGetHeaderHeight;
  fReport.OnGetFooterHeight:= OnGetFooterHeight;
  fReport.OnGetRowHeight:= OnGetRowHeight;
  fReport.OnNewPage:= OnNewPage;
  fReport.OnPrintHeader:= OnPrintHeader;
  fReport.OnPrintFooter:= OnPrintFooter;
  fReport.OnPrintCell:= OnPrintCell;
  fReport.OnPrintRow:= OnPrintRow;
  SetLength (fPages,0);
  fHeaderFontSize:= 10;
  fFooterFontSize:= 10;
  fLargeFontSize:= 10;
  fSmallFontSize:= fLargeFontSize-1;
  fReport.PrintTableHeader:= false;
  fReport.DrawGrid:= false;

  fcFinal:= fReport.Columns.Add (COL_FINAL);
  for i:= 0 to 10 do
    fcFinal.Add (COL_FINAL+1+i);

  fcRank:= fReport.Columns.Add (COL_RANK);
  fcNum:= fReport.Columns.Add (COL_NUM);
  fcName:= fReport.Columns.Add (COL_NAME);
  fcYear:= fReport.Columns.Add (COL_YEAR);
  fcQualification:= fReport.Columns.Add (COL_QUALIFICATION);
  fcRegion:= fReport.Columns.Add (COL_REGION);
  fcDistrict:= fReport.Columns.Add (COL_DISTRICT);
  fcClub:= fReport.Columns.Add (COL_CLUB);
  fcResults:= fReport.Columns.Add (COL_RESULTS);
  fcSeries:= fcResults.Add (COL_SERIES);
  fcStages:= fcResults.Add (COL_STAGES);
  fcSum:= fcResults.Add (COL_SUM);
  fcDNF:= fcResults.Add (COL_DNF);
  fcQualified:= fcDNF.Add (COL_QUALIFIED);
  fcShootoff:= fcDNF.Add (COL_SHOOTOFF);
  fcTeamPoints:= fcDNF.Add (COL_TEAMPOINTS);
  fcQualPoints:= fcDNF.Add (COL_QUALPOINTS);
  fcDistrictPoints:= fcDNF.Add (COL_DISTRICTPOINTS);
  fcRegionPoints:= fcDNF.Add (COL_REGIONPOINTS);
end;

destructor TPrintResults.Destroy;
var
  i: integer;
begin
  fReport.Free;
  for i:= 0 to Length (fPages)-1 do
    fPages [i].Free;
  SetLength (fPages,0);
  fPages:= nil;
  inherited;
end;

procedure TPrintResults.OnGetCanvas(Sender: TMyCustomReport; Index: integer; var ACanvas: TCanvas);
begin
  ACanvas:= fPages [Index];
end;

procedure TPrintResults.OnGetFooterHeight (Sender: TMyCustomReport; Index: integer; var AHeight: integer);
begin

end;

procedure TPrintResults.OnGetHeaderHeight (Sender: TMyCustomReport; Index: integer; var AHeight: integer);
begin

end;

procedure TPrintResults.OnGetRowHeight(Sender: TMyCustomReport; Index: integer; var AHeight: integer);
begin

end;

procedure TPrintResults.OnNewPage(Sender: TMyCustomReport; Index: integer; AFirst: boolean);
begin

end;

procedure TPrintResults.OnPrintCell(Sender: TMyCustomReport; ARow,ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect);
begin

end;

procedure TPrintResults.OnPrintFooter(Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect);
begin

end;

procedure TPrintResults.OnPrintHeader(Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect);
begin

end;

procedure TPrintResults.OnPrintRow(Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect);
begin

end;

procedure TPrintResults.Prepare;
begin

end;

end.

