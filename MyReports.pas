{$a-}
unit MyReports;

interface

uses
  System.SysUtils, Winapi.Windows,Vcl.Graphics,System.Classes,Vcl.Printers;

type
  TMyReportColumn= class;
  TMyCustomReport= class;

  PMyReportRow= ^TMyReportRow;
  TMyReportRow= record
    Index: integer;
    Rect: TRect;
    Color: TColor;
    Fill: boolean;
    Break: boolean;
  end;

  TMyReportPage= class
  private
    fReport: TMyCustomReport;
    fPrint: boolean;
    fFirstRow: integer;
    fRows: array of integer;
    fHeaderHeight,fFooterHeight: integer;
    fIndex: integer;
    fRect: TRect;
  public
    constructor Create (AReport: TMyCustomReport; AIndex: integer; AFirstRow: integer; ARect: TRect; AHeaderHeight,AFooterHeight: integer);
    destructor Destroy; override;
    property Print: boolean read fPrint write fPrint;
    property HeaderHeight: integer read fHeaderHeight write fHeaderHeight;
    property FooterHeight: integer read fFooterHeight write fFooterHeight;
    property FirstRow: integer read fFirstRow;
    function LastRow: integer;
    procedure AddRow (AIndex: integer; ARect: TRect);
    property Index: integer read fIndex;
    function RowCount: integer;
    function Rows (Index: integer): PMyReportRow;
    property PageRect: TRect read fRect;
  end;

  TMyReportColumn= class
  private
    fTitle: string;
    fSubs: array of TMyReportColumn;
    fOwner: TMyReportColumn;
    fWidth: integer;
    fData: Pointer;
    fAlignment: TAlignment;
    fIndex: integer;
    fId: integer;
    function get_Width: integer;
    procedure set_Width(const Value: integer);
  public
    constructor Create (AOwner: TMyReportColumn);
    destructor Destroy; override;
    procedure Clear;
    property Width: integer read get_Width write set_Width;
    function Count: integer;
    property Title: string read fTitle write fTitle;
    property Data: Pointer read fData write fData;
    function Cols (Index: integer): TMyReportColumn;
    function Left: integer;
    function Right: integer;
    function Prev: TMyReportColumn;
    function Add (Id: integer; const ATitle: string= ''; const AAlignment: TAlignment= taLeftJustify): TMyReportColumn;
    procedure AddSeparator (AWidth: integer);
    procedure Fit (TestWidth: integer);
    function Depth: integer;
    function Level: integer;
    property Parent: TMyReportColumn read fOwner;
    function TotalColumns: integer;
    property Alignment: TAlignment read fAlignment write fAlignment;
  end;

  TMyCustomReport= class
  private
    fPageIndex: integer;
    fPageRect: TRect;
    fHeaderHeight: integer;
    fFooterHeight: integer;
    fRowHeight: integer;
    fTableHead: boolean;
    fRows: array of TMyReportRow;
    fPages: array of TMyReportPage;
    fColumns: TMyReportColumn;
    fFont: TFont;
    fUseFont: boolean;
    fPrintTableHeader: boolean;
    fHeaderFont: TFont;
    fDrawGrid: boolean;
    fGridLineWidth: integer;
    fDrawHeaderGrid: boolean;
    fHeaderSpacer: integer;
    fHeaderBkColor: TColor;
    fFillHeaderBg: boolean;
    function get_RowCount: integer;
    procedure set_HeaderFont(const Value: TFont);
    procedure set_Font(const Value: TFont);
    procedure set_PageRect(const Value: TRect);
    procedure set_RowCount(const Value: integer);
  protected
    function GetCanvas (APageIndex: integer): TCanvas; virtual;
    function GetHeaderHeight (APageIndex: integer): integer; virtual;
    function GetFooterHeight (APageIndex: integer): integer; virtual;
    function GetRowHeight (ARowIndex: integer): integer; virtual;
    procedure NewPage (APageIndex: integer; AFirstPage: boolean); virtual;
    procedure PrintHeader (APageIndex: integer; ACanvas: TCanvas; ARect: TRect); virtual;
    procedure PrintFooter (APageIndex: integer; ACanvas: TCanvas; ARect: TRect); virtual;
    procedure PrintCell (ARow,ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect); virtual;
    procedure PrintRow (ARow: integer; ACanvas: TCanvas; ARect: TRect); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    property RowCount: integer read get_RowCount write set_RowCount;
    property PageRect: TRect read fPageRect write set_PageRect;
    procedure Generate;
    procedure Precalc;
    function PageCount: integer;
    function Pages (Index: integer): TMyReportPage;
    property HeaderHeight: integer read fHeaderHeight write fHeaderHeight;
    property FooterHeight: integer read fFooterHeight write fFooterHeight;
    property RowHeight: integer read fRowHeight write fRowHeight;
    property Columns: TMyReportColumn read fColumns;
    property Font: TFont read fFont write set_Font;
    property UseFont: boolean read fUseFont write fUseFont;
    property PrintTableHeader: boolean read fPrintTableHeader write fPrintTableHeader;
    property HeaderFont: TFont read fHeaderFont write set_HeaderFont;
    property DrawGrid: boolean read fDrawGrid write fDrawGrid;
    property GridLineWidth: integer read fGridLineWidth write fGridLineWidth;
    property DrawHeaderGrid: boolean read fDrawHeaderGrid write fDrawHeaderGrid;
    property HeaderSpacer: integer read fHeaderSpacer write fHeaderSpacer;
    property FillHeader: boolean read fFillHeaderBg write fFillHeaderBg;
    property HeaderBkColor: TColor read fHeaderBkColor write fHeaderBkColor;
    function Rows (Index: integer): PMyReportRow;
    function AddRow: PMyReportRow;
  end;

  TGetHeaderHeight= procedure (Sender: TMyCustomReport; Index: integer; var AHeight: integer) of object;
  TGetCanvas= procedure (Sender: TMyCustomReport; Index: integer; var ACanvas: TCanvas) of object;
  TGetFooterHeight= procedure (Sender: TMyCustomReport; Index: integer; var AHeight: integer) of object;
  TGetRowHeight= procedure (Sender: TMyCustomReport; Index: integer; var AHeight: integer) of object;
  TNewPage= procedure (Sender: TMyCustomReport; Index: integer; AFirst: boolean) of object;
  TPrintRow= procedure (Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect) of object;
  TPrintCell= procedure (Sender: TMyCustomReport; ARow,ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect) of object;
  TPrintHeader= procedure (Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect) of object;
  TPrintFooter= procedure (Sender: TMyCustomReport; Index: integer; ACanvas: TCanvas; ARect: TRect) of object;

  TMyUserReport= class (TMyCustomReport)
  private
    fGetCanvas: TGetCanvas;
    fGetHeaderHeight: TGetHeaderHeight;
    fGetFooterHeight: TGetFooterHeight;
    fGetRowHeight: TGetRowHeight;
    fNewPage: TNewPage;
    fPrintRow: TPrintRow;
    fPrintHeader: TPrintHeader;
    fPrintFooter: TPrintFooter;
    fPrintCell: TPrintCell;
  protected
    function GetCanvas (APageIndex: integer): TCanvas; override;
    function GetHeaderHeight (APageIndex: integer): integer; override;
    function GetFooterHeight (APageIndex: integer): integer; override;
    function GetRowHeight (ARowIndex: integer): integer; override;
    procedure NewPage (APageIndex: integer; AFirstPage: boolean); override;
    procedure PrintHeader (APageIndex: integer; ACanvas: TCanvas; ARect: TRect); override;
    procedure PrintFooter (APageIndex: integer; ACanvas: TCanvas; ARect: TRect); override;
    procedure PrintCell (ARow,ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect); override;
    procedure PrintRow (ARow: integer; ACanvas: TCanvas; ARect: TRect); override;
  public
    constructor Create;
    property OnGetCanvas: TGetCanvas read fGetCanvas write fGetCanvas;
    property OnGetHeaderHeight: TGetHeaderHeight read fGetHeaderHeight write fGetHeaderHeight;
    property OnGetFooterHeight: TGetFooterHeight read fGetFooterHeight write fGetFooterHeight;
    property OnGetRowHeight: TGetRowHeight read fGetRowHeight write fGetRowHeight;
    property OnNewPage: TNewPage read fNewPage write fNewPage;
    property OnPrintHeader: TPrintHeader read fPrintHeader write fPrintHeader;
    property OnPrintFooter: TPrintFooter read fPrintFooter write fPrintFooter;
    property OnPrintCell: TPrintCell read fPrintCell write fPrintCell;
    property OnPrintRow: TPrintRow read fPrintRow write fPrintRow;
  end;

implementation

uses System.Types;

{ TMyCustomReport }

function TMyCustomReport.AddRow: PMyReportRow;
var
  idx: integer;
begin
  idx:= Length (fRows);
  SetLength (fRows,idx+1);
  Result:= @fRows [idx];
  Result^.Index:= idx;
  Result^.Color:= clWhite;
  Result^.Fill:= false;
  Result^.Break:= false;
end;

constructor TMyCustomReport.Create;
begin
  inherited Create;
  fPageRect:= Rect (0,0,0,0);
  fHeaderHeight:= 0;
  fFooterHeight:= 0;
  fPageIndex:= 0;
  SetLength (fRows,0);
  fRowHeight:= -1;
  fTableHead:= false;
  SetLength (fPages,0);
  fColumns:= TMyReportColumn.Create (nil);
  fFont:= TFont.Create;
  fFont.Name:= 'Arial';
  fFont.Size:= 12;
  fFont.Style:= [];
  fFont.Charset:= RUSSIAN_CHARSET;
  fUseFont:= true;
  fPrintTableHeader:= true;
  fHeaderFont:= TFont.Create;
  fHeaderFont.Assign (fFont);
  fDrawGrid:= false;
  fGridLineWidth:= 1;
  fDrawHeaderGrid:= true;
  fHeaderSpacer:= 1;
  fHeaderBkColor:= clWhite;
  fFillHeaderBg:= false;
end;

destructor TMyCustomReport.Destroy;
var
  i: integer;
begin
  fHeaderFont.Free;
  fFont.Free;
  fColumns.Free;
  for i:= 0 to Length (fPages)-1 do
    fPages [i].Free;
  SetLength (fPages,0);
  fPages:= nil;
  SetLength (fRows,0);
  fRows:= nil;
  inherited;
end;

procedure TMyCustomReport.Generate;
var
  c: TCanvas;
  first_page: boolean;
  page: TMyReportPage;
  fnt: TFont;

  procedure DoNewPage;
  var
    r: TRect;
    hr: TRect;

    procedure PrintColumnHeader (rc: TMyReportColumn; const pr: TRect);
    var
      cnt: integer;
      i: integer;
      x,y: integer;
      cr: TRect;
      _th: integer;
      d,l: integer;
    begin
      if rc.Level> 0 then
        begin
//          l:= rc.Level-1;
          l:= 0;
          d:= rc.Depth;
          _th:= c.TextHeight ('Mg');
          cr.Left:= hr.Left+rc.Left;
          cr.Right:= hr.Left+rc.Right;
          cr.Top:= pr.Top+round ((pr.Bottom-pr.Top)*l/d);
          cr.Bottom:= pr.Top+round ((pr.Bottom-pr.Top)*(l+1)/d);
          if fDrawHeaderGrid then
            begin
              if cr.Bottom< hr.Bottom then
                begin
                  c.MoveTo (cr.Left,cr.Bottom);
                  c.LineTo (cr.Right,cr.Bottom);
                end;
              if rc.fIndex> 0 then
                begin
                  c.MoveTo (cr.Left,cr.Top);
                  c.LineTo (cr.Left,hr.Bottom);
                end;
            end;
          case rc.Alignment of
            taRightJustify: x:= cr.Right-c.TextWidth (rc.Title)-fHeaderSpacer;
            taCenter: x:= (cr.Left+cr.Right-c.TextWidth (rc.Title)) div 2;
          else
            x:= cr.Left+fHeaderSpacer;
          end;
          y:= (cr.Top+cr.Bottom-_th) div 2;
          c.TextRect (cr,x,y,rc.Title);
        end
      else
        cr.Bottom:= hr.Top;
      cnt:= rc.Count;
      if cnt> 0 then
        begin
          for i:= 0 to cnt-1 do
            PrintColumnHeader (rc.Cols (i),Rect (hr.Left,cr.Bottom,hr.Right,hr.Bottom));
        end;
    end;

  var
    y,i,y0: integer;

    procedure DrawColumnRightVLine (ACol: TMyReportColumn);
    var
      cnt,i: integer;
      x: integer;
    begin
      cnt:= ACol.Count;
      if cnt> 0 then
        begin
          for i:= 0 to cnt-1 do
            DrawColumnRightVLine (ACol.Cols (i));
        end
      else
        begin
          x:= page.PageRect.Left+ACol.Right;
          c.MoveTo (x,y0);
          c.LineTo (x,y);
        end;
    end;

  var
    cnt: integer;
    ri: PMyReportRow;
  begin
    NewPage (page.Index,first_page);
    first_page:= false;
    c:= GetCanvas (page.Index);
{    if Assigned (fGetCanvas) then
      fGetCanvas (self,page.Index,c)
    else
      c:= Printer.Canvas;}
    if fUseFont then
      fnt.Assign (fFont)
    else
      fnt.Assign (c.Font);
    if page.HeaderHeight> 0 then
      begin
        c.Font:= fnt;
        r:= page.PageRect;
        r.Bottom:= r.Top+page.HeaderHeight;
        PrintHeader (page.Index,c,r);
      end;
    cnt:= fColumns.Count;
    if (fPrintTableHeader) and (cnt> 0) then
      begin
        c.Font:= fHeaderFont;
        hr:= PageRect;
        c.Brush.Style:= bsClear;
        inc (hr.Top,page.HeaderHeight);
        hr.Bottom:= hr.Top+(fColumns.Depth-1)*(c.TextHeight ('Mg')+fHeaderSpacer*2);
        if fFillHeaderBg then
          begin
            c.Brush.Color:= fHeaderBkColor;
            c.FillRect (hr);
          end;
        c.Brush.Style:= bsClear;
        if fDrawHeaderGrid then
          begin
            c.MoveTo (page.PageRect.Left+fColumns.Left,hr.Top);
            c.LineTo (page.PageRect.Left+fColumns.Right,hr.Top);
            c.LineTo (page.PageRect.Left+fColumns.Right,hr.Bottom);
            c.LineTo (page.PageRect.Left+fColumns.Left,hr.Bottom);
            c.LineTo (page.PageRect.Left+fColumns.Left,hr.Top);
          end;
        PrintColumnHeader (fColumns,hr);
      end;
    c.Font:= fnt;
    if page.FooterHeight> 0 then
      begin
        r:= page.PageRect;
        r.Top:= r.Bottom-page.FooterHeight;
        PrintFooter (page.Index,c,r);
      end;
    if (fDrawGrid) and (page.RowCount> 0) then
      begin
        y0:= 0;
        y:= 0;
        for i:= 0 to page.RowCount-1 do
          begin
            ri:= page.Rows (i);
            if i= 0 then
              begin
                y0:= ri^.Rect.Top;
                y:= y0;
                c.MoveTo (page.PageRect.Left,y);
                c.LineTo (page.PageRect.Right,y);
              end;
            y:= ri^.Rect.Bottom;
            c.MoveTo (page.PageRect.Left,y);
            c.LineTo (page.PageRect.Right,y);
          end;
        if fColumns.Count= 0 then
          begin
            c.MoveTo (page.PageRect.Left,y0);
            c.LineTo (page.PageRect.Left,y);
            c.MoveTo (page.PageRect.Right,y0);
            c.LineTo (page.PageRect.Right,y);
          end
        else
          begin
            c.MoveTo (page.PageRect.Left+fColumns.Left,y0);
            c.LineTo (page.PageRect.Left+fColumns.Left,y);
            DrawColumnRightVLine (fColumns);
          end;
      end;
  end;

var
  ri: PMyReportRow;
  pageindex,row: integer;
  col_idx: integer;

  procedure ProceedColumn (ACol: TMyReportColumn);
  var
    i: integer;
    cnt: integer;
    r: TRect;
  begin
    cnt:= ACol.Count;
    if cnt> 0 then
      begin
        for i:= 0 to cnt-1 do
          ProceedColumn (ACol.Cols (i));
      end
    else if ACol.Width> 0 then
      begin
        r:= Rect (ri^.Rect.Left+ACol.Left,ri^.Rect.Top,ri^.Rect.Left+ACol.Right,ri^.Rect.Bottom);
        PrintCell (ri^.Index,col_idx,ACol,c,r);
        inc (col_idx);
      end;
  end;

begin
  first_page:= true;
  fnt:= TFont.Create;
  for pageindex:= 0 to Length (fPages)-1 do
    begin
      page:= fPages [pageindex];
      if not page.Print then
        continue;
      DoNewPage;
      for row:= 0 to page.RowCount-1 do
        begin
          ri:= page.Rows (row);
          // ������ ������
          if fColumns.Count> 0 then
            begin
              col_idx:= 0;
              ProceedColumn (fColumns);
            end
          else
            begin
              PrintRow (ri^.Index,c,ri^.Rect);
            end;
        end;
    end;
  fnt.Free;
end;

function TMyCustomReport.GetCanvas(APageIndex: integer): TCanvas;
begin
  Result:= Printer.Canvas;
end;

function TMyCustomReport.GetFooterHeight(APageIndex: integer): integer;
begin
  Result:= fFooterHeight;
end;

function TMyCustomReport.GetHeaderHeight(APageIndex: integer): integer;
begin
  Result:= fHeaderHeight;
end;

function TMyCustomReport.GetRowHeight(ARowIndex: integer): integer;
begin
  Result:= fRowHeight;
end;

function TMyCustomReport.get_RowCount: integer;
begin
  Result:= Length (fRows);
end;

procedure TMyCustomReport.NewPage(APageIndex: integer; AFirstPage: boolean);
begin
  if not AFirstPage then
    Printer.NewPage;
end;

function TMyCustomReport.PageCount: integer;
begin
  Result:= Length (fPages);
end;

function TMyCustomReport.Pages(Index: integer): TMyReportPage;
begin
  Result:= fPages [Index];
end;

procedure TMyCustomReport.Precalc;
var
  r_idx: integer;
  page: TMyReportPage;
  y: integer;
  r: TRect;
  rh,hh,fh: integer;
  canv: TCanvas;
  fnt: TFont;

  function NewPage: TMyReportPage;
  var
    idx: integer;
    thh: integer;
  begin
    idx:= Length (fPages);
    canv:= GetCanvas (idx);
    if fUseFont then
      fnt.Assign (fFont)
    else
      fnt.Assign (canv.Font);
    canv.Font:= fnt;
    hh:= GetHeaderHeight (idx);
    fh:= GetFooterHeight (idx);
    r:= fPageRect;
    inc (r.Top,hh);
    if (fPrintTableHeader) and (fColumns.Count> 0) then
      begin
        canv.Font:= fHeaderFont;
        thh:= (fColumns.Depth-1)*(canv.TextHeight ('Mg')+fHeaderSpacer*2);
        inc (r.Top,thh);
      end;
    dec (r.Bottom,fh);
    y:= r.Top;
    SetLength (fPages,idx+1);
    Result:= TMyReportPage.Create (self,idx,r_idx,fPageRect,hh,fh);
    fPages [idx]:= Result;
    canv.Font:= fnt;
  end;

var
  rr: TRect;
  page_break: boolean;
  row: PMyReportRow;

begin
  // ��������������� ����������� ������
  Columns.Width:= 0;
  SetLength (fPages,0);
  if RowCount< 1 then
    exit;
  // ������ ������ �������
  // ��������� �� ��������
  fnt:= TFont.Create;
  page_break:= false;
  page:= nil;
  for r_idx:= 0 to RowCount-1 do
    begin
      row:= Rows (r_idx);
      if page= nil then
        page:= NewPage;
      rh:= GetRowHeight (r_idx);
      if rh< 0 then
        rh:= canv.TextHeight ('Mg');
      if (y+rh> r.Bottom) or (page_break) then
        begin
          page:= NewPage;
        end;
      rr:= Rect (r.Left,y,r.Right,y+rh);
      page.AddRow (r_idx,rr);
      inc (y,rh);
      page_break:= row^.Break;
    end;
  fnt.Free;
end;

procedure TMyCustomReport.PrintCell(ARow, ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect);
begin
end;

procedure TMyCustomReport.PrintFooter(APageIndex: integer; ACanvas: TCanvas; ARect: TRect);
begin
end;

procedure TMyCustomReport.PrintHeader(APageIndex: integer; ACanvas: TCanvas; ARect: TRect);
begin
end;

procedure TMyCustomReport.PrintRow(ARow: integer; ACanvas: TCanvas; ARect: TRect);
begin
end;

function TMyCustomReport.Rows(Index: integer): PMyReportRow;
begin
  Result:= @fRows [Index];
end;

procedure TMyCustomReport.set_Font(const Value: TFont);
begin
  fFont.Assign (Value);
end;

procedure TMyCustomReport.set_HeaderFont(const Value: TFont);
begin
  fHeaderFont.Assign (Value);
end;

procedure TMyCustomReport.set_PageRect(const Value: TRect);
begin
  fPageRect:= Value;
end;

procedure TMyCustomReport.set_RowCount(const Value: integer);
var
  i: integer;
begin
  SetLength (fRows,Value);
  for i:= 0 to Length (fRows)-1 do
    begin
      fRows [i].Index:= i;
      fRows [i].Color:= clWhite;
      fRows [i].Fill:= false;
      fRows [i].Break:= false;
    end;
end;

{ TMyReportPageInfo }

procedure TMyReportPage.AddRow(AIndex: integer; ARect: TRect);
var
  idx: integer;
begin
  idx:= Length (fRows);
  SetLength (fRows,idx+1);
  fRows [idx]:= AIndex;
  fReport.fRows [AIndex].Rect:= ARect;
end;

constructor TMyReportPage.Create(AReport: TMyCustomReport; AIndex, AFirstRow: integer;
  ARect: TRect; AHeaderHeight, AFooterHeight: integer);
begin
  inherited Create;
  fReport:= AReport;
  fPrint:= true;
  fFirstRow:= AFirstRow;
  SetLength (fRows,0);
  fHeaderHeight:= AHeaderHeight;
  fFooterHeight:= AFooterHeight;
  fIndex:= AIndex;
  fRect:= ARect;
end;

destructor TMyReportPage.Destroy;
begin
  SetLength (fRows,0);
  fRows:= nil;
  inherited;
end;

function TMyReportPage.LastRow: integer;
begin
  Result:= fFirstRow+Length (fRows)-1;
end;

function TMyReportPage.RowCount: integer;
begin
  Result:= Length (fRows);
end;

function TMyReportPage.Rows(Index: integer): PMyReportRow;
begin
  Result:= @fReport.fRows [fRows [Index]];
end;

{ TMyReportColumn }

function TMyReportColumn.Add (Id: integer; const ATitle: string= ''; const AAlignment: TAlignment= taLeftJustify): TMyReportColumn;
var
  idx: integer;
  tc: TMyReportColumn;
begin
  idx:= Count;
  SetLength (fSubs,idx+1);
  tc:= TMyReportColumn.Create (self);
  tc.fIndex:= idx;
  tc.Title:= ATitle;
  tc.Alignment:= AAlignment;
  fSubs [idx]:= tc;
  fWidth:= 0;
  fId:= Id;
  Result:= tc;
end;

procedure TMyReportColumn.AddSeparator(AWidth: integer);
var
  c,i: integer;
begin
  if Width= 0 then
    exit;
  c:= Count;
  if c= 0 then
    fWidth:= fWidth+AWidth
  else
    begin
      for i:= 0 to c-1 do
        fSubs [i].AddSeparator (AWidth);
    end;
end;

procedure TMyReportColumn.Clear;
var
  i: integer;
begin
  for i:= 0 to Length (fSubs)-1 do
    fSubs [i].Free;
  SetLength (fSubs,0);
end;

function TMyReportColumn.Cols(Index: integer): TMyReportColumn;
begin
  Result:= fSubs [Index];
end;

function TMyReportColumn.Count: integer;
begin
  Result:= Length (fSubs);
end;

constructor TMyReportColumn.Create(AOwner: TMyReportColumn);
begin
  inherited Create;
  fOwner:= AOwner;
  fTitle:= '';
  fWidth:= 0;
  SetLength (fSubs,0);
  fData:= nil;
  fIndex:= 0;
  fAlignment:= taLeftJustify;
end;

function TMyReportColumn.Depth: integer;
var
  i,c,d: integer;
begin
  Result:= 1;
  c:= Count;
  for i:= 0 to c-1 do
    begin
      d:= fSubs [i].Depth+1;
      if d> Result then
        Result:= d;
    end;
end;

destructor TMyReportColumn.Destroy;
begin
  Clear;
  fSubs:= nil;
  inherited;
end;

procedure TMyReportColumn.Fit(TestWidth: integer);
begin
  if TestWidth> Width then
    Width:= TestWidth;
end;

function TMyReportColumn.get_Width: integer;
var
  c,i: integer;
begin
  c:= Count;
  if c= 0 then
    Result:= fWidth
  else
    begin
      Result:= 0;
      for i:= 0 to c-1 do
        Result:= Result+fSubs [i].Width;
    end;
end;

function TMyReportColumn.Left: integer;
var
  p: TMyReportColumn;
begin
  if fOwner= nil then
    Result:= 0
  else
    begin
      if fIndex= 0 then
        Result:= fOwner.Left
      else
        begin
          p:= Prev;
          Result:= p.Left+p.Width;
        end;
    end;
end;

function TMyReportColumn.Level: integer;
begin
  if fOwner= nil then
    Result:= 0
  else
    Result:= fOwner.Level+1;
end;

function TMyReportColumn.Prev: TMyReportColumn;
begin
  if fOwner= nil then
    Result:= nil
  else
    begin
      if fIndex= 0 then
        Result:= nil
      else
        Result:= fOwner.fSubs [fIndex-1];
    end;
end;

function TMyReportColumn.Right: integer;
begin
  Result:= Left+Width;
end;

procedure TMyReportColumn.set_Width(const Value: integer);
var
  ow,w,cw,sw: integer;
  i,c,c1: integer;
begin
  c:= Count;
  if c= 0 then
    fWidth:= Value
  else
    begin
      ow:= Width;
      w:= Value;
      if ow> 0 then
        begin
          // ����������� ��������������� ������ ��������
          for i:= 0 to c-1 do
            begin
              sw:= fSubs [i].Width;
              if ow> 0 then
                cw:= round (sw*w/ow)
              else
                cw:= 0;
              dec (w,cw);
              dec (ow,sw);
              fSubs [i].Width:= cw;
            end;
        end
      else
        begin
          // ���� ������ ������
          c1:= c;
          for i:= 0 to c-1 do
            begin
              cw:= round (w/c1);
              fSubs [i].Width:= cw;
              dec (w,cw);
              dec (c1);
            end;
        end;
    end;
end;

function TMyReportColumn.TotalColumns: integer;
var
  i,c: integer;
begin
  c:= Count;
  if c> 0 then
    begin
      Result:= 0;
      for i:= 0 to c-1 do
        Result:= Result+fSubs [i].TotalColumns;
    end
  else
    Result:= 1;
end;

{ TMyUserReport }

constructor TMyUserReport.Create;
begin
  inherited;
  fGetCanvas:= nil;
  fGetHeaderHeight:= nil;
  fGetFooterHeight:= nil;
  fGetRowHeight:= nil;
  fNewPage:= nil;
  fPrintRow:= nil;
  fPrintHeader:= nil;
  fPrintFooter:= nil;
  fPrintCell:= nil;
end;

function TMyUserReport.GetCanvas(APageIndex: integer): TCanvas;
begin
  if Assigned (fGetCanvas) then
    fGetCanvas (self,APageIndex,Result)
  else
    Result:= inherited GetCanvas (APageIndex);
end;

function TMyUserReport.GetFooterHeight(APageIndex: integer): integer;
begin
  if Assigned (fGetFooterHeight) then
    fGetFooterHeight (self,APageIndex,Result)
  else
    Result:= inherited GetFooterHeight (APageIndex);
end;

function TMyUserReport.GetHeaderHeight(APageIndex: integer): integer;
begin
  if Assigned (fGetHeaderHeight) then
    fGetHeaderHeight (self,APageIndex,Result)
  else
    Result:= inherited GetHeaderHeight (APageIndex);
end;

function TMyUserReport.GetRowHeight(ARowIndex: integer): integer;
begin
  if Assigned (fGetRowHeight) then
    fGetRowHeight (self,ARowIndex,Result)
  else
    Result:= inherited GetRowHeight (ARowIndex);
end;

procedure TMyUserReport.NewPage(APageIndex: integer; AFirstPage: boolean);
begin
  if Assigned (fNewPage) then
    fNewPage (self,APageIndex,AFirstPage)
  else
    inherited;
end;

procedure TMyUserReport.PrintCell(ARow, ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect);
begin
  if Assigned (fPrintCell) then
    fPrintCell (self,ARow,ACol,AColObj,ACanvas,ARect)
  else
    inherited;
end;

procedure TMyUserReport.PrintFooter(APageIndex: integer; ACanvas: TCanvas; ARect: TRect);
begin
  if Assigned (fPrintFooter) then
    fPrintFooter (self,APageIndex,ACanvas,ARect)
  else
    inherited;
end;

procedure TMyUserReport.PrintHeader(APageIndex: integer; ACanvas: TCanvas; ARect: TRect);
begin
  if Assigned (fPrintHeader) then
    fPrintHeader (self,APageIndex,ACanvas,ARect)
  else
    inherited;
end;

procedure TMyUserReport.PrintRow(ARow: integer; ACanvas: TCanvas; ARect: TRect);
begin
  if Assigned (fPrintRow) then
    fPrintRow (Self,ARow,ACanvas,ARect)
  else
    inherited;
end;

end.

