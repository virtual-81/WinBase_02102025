unit report_startlist;

interface

uses
  System.SysUtils, Winapi.Windows,
  System.Classes,
  Vcl.Graphics,
  MyReports,
  Data;

type
  TStartListReport= class
  private
    fEvent: TStartListEventItem;
    fReport: TMyCustomReport;
//    fPrinter: TObject;
//    fCopies: integer;
    procedure InitReport; virtual; abstract;
    procedure PrintCell (Sender: TMyCustomReport; ARow,ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect); virtual; abstract;
    procedure GetFooterHeight (Sender: TMyCustomReport; Index: integer; var AHeight: integer); virtual; abstract;
    procedure GetHeaderHeight (Sender: TMyCustomReport; Index: integer; var AHeight: integer); virtual; abstract;
    procedure GetCanvas (Sender: TMyCustomReport; Index: integer; var ACanvas: TCanvas); virtual; abstract;
    procedure NewPage (Sender: TMyCustomReport; Index: integer; AFirst: boolean); virtual; abstract;
    procedure PrintHeader (Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect); virtual; abstract;
    procedure PrintFooter (Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect); virtual; abstract;
  public
    constructor Create (AEvent: TStartListEventItem);
    destructor Destroy; override;
    function PageCount: integer;
  end;

  TStartListRegularReport= class (TStartListReport)
  private
    procedure InitReport; override;
  public
  end;

  TStartListRegularReportPrint= class (TStartListRegularReport)
  private
  end;

  TStartListRapidFireReport= class (TStartListReport)
  end;

implementation

{ TStartListReport }

constructor TStartListReport.Create(AEvent: TStartListEventItem);
begin
  inherited Create;
  fEvent:= AEvent;
  fReport:= TMyCustomReport.Create;
  fReport.OnPrintCell:= PrintCell;
  fReport.OnPrintHeader:= PrintHeader;
  fReport.OnPrintFooter:= PrintFooter;
  fReport.OnGetCanvas:= GetCanvas;
  fReport.OnGetHeaderHeight:= GetHeaderHeight;
  fReport.OnGetFooterHeight:= GetFooterHeight;
  fReport.OnNewPage:= NewPage;
  InitReport;
end;

destructor TStartListReport.Destroy;
begin
  fReport.Free;
  inherited;
end;

function TStartListReport.PageCount: integer;
begin
  Result:= fReport.PageCount;
end;

{ TStartListRegularPrint }

procedure TStartListRegularReport.InitReport;
var
  c: TMyReportColumn;
begin
  c:= fReport.Columns;
  c.Add (1,'No',taRightJustify);
  c.Add (2,'StartNo');
  c.Add (3,'Name');
  c.Add (4,'Year');
  c.Add (5,'Qual');
  c.Add (6,'RegTown');
  c.Add (7,'Club');
  c.Add (8,'Pos');
  c.Add (9,'Marks');
  fReport.PrintTableHeader:= true;
  fReport.FillHeader:= false;
  fReport.DrawHeaderGrid:= true;
  fReport.DrawGrid:= false;
end;

end.

