{$a-,j+}
unit MyTable;

interface

uses
  Winapi.Windows,System.Classes,System.SysUtils,Vcl.Graphics,Types;

type
  TMyTableColumnAlignment= (taLeft,taCenter,taRight,taTop,taBottom,taBaseLine,taDefault);

type
  TMyTable= class;
  TMyTableRow= class;

  TMyTableCell= class
  private
    fRow: TMyTableRow;
    fText: TStrings;
    fAlign: TMyTableColumnAlignment;
    fColor: TColor;
    fColSpan: integer;
    fRowSpan: integer;
    fFont: TFont;
    fVAlign: TMyTableColumnAlignment;
    function get_Text: string;
    function get_Valign: TMyTableColumnAlignment;
    procedure set_VAlign(const Value: TMyTableColumnAlignment);
    procedure set_RowSpan(const Value: integer);
    function get_Font: TFont;
    procedure set_Font(const Value: TFont);
    procedure set_Text(const Value: string);
    procedure set_ColSpan(const Value: integer);
    function get_Color: TColor;
    function get_Align: TMyTableColumnAlignment;
    procedure set_Align(const Value: TMyTableColumnAlignment);
    function GetFont: TFont;
    procedure OnFontChange (Sender: TObject);
    procedure CreateFont;
  protected
    fSpanned: TMyTableCell; // internal flag
  public
    constructor Create (ARow: TMyTableRow);
    destructor Destroy; override;
    property AsText: string read get_Text write set_Text;
    property Align: TMyTableColumnAlignment read get_Align write set_Align;
    property Color: TColor read get_Color write fColor;
    function Height: integer;
    function Width: integer;
    procedure Draw (C: TCanvas; R: TRect);
    property ColSpan: integer read fColSpan write set_ColSpan;
    property RowSpan: integer read fRowSpan write set_RowSpan;
    property Font: TFont read get_Font write set_Font;
    function GetBaseLine: integer;
    property VAlign: TMyTableColumnAlignment read get_Valign write set_VAlign;
  end;

  TMyTableRow= class
  private
    fTable: TMyTable;
    fCells: array of TMyTableCell;
    fAlign: TMyTableColumnAlignment;
    fVAlign: TMyTableColumnAlignment;
    fColor: TColor;
    fFont: TFont;
    function get_VAlign: TMyTableColumnAlignment;
    procedure set_VAlign(const Value: TMyTableColumnAlignment);
    function get_Font: TFont;
    procedure set_Font(const Value: TFont);
    procedure set_Color(const Value: TColor);
    function get_Color: TColor;
    function get_Align: TMyTableColumnAlignment;
    procedure set_Align(const Value: TMyTableColumnAlignment);
    function get_Cell(i: integer): TMyTableCell;
    function GetFont: TFont;
    procedure CreateFont;
    procedure OnFontChange (Sender: TObject);
  public
    constructor Create (ATable: TMyTable);
    destructor Destroy; override;
    procedure Clear;
    function Count: integer;
    property Cells[i: integer]: TMyTableCell read get_Cell;
    function AddCell: TMyTableCell;
    property Align: TMyTableColumnAlignment read get_Align write set_Align;
    property Color: TColor read get_Color write set_Color;
    function Height: integer; overload;
    property Font: TFont read get_Font write set_Font;
    function GetBaseLine: integer;
    property VAlign: TMyTableColumnAlignment read get_VAlign write set_VAlign;
  end;

  TMyTable= class
  private
    fColWidths: array of integer;
    fRowHeights: array of integer;
    fHeaderHeights: array of integer;
    fCanvas: TCanvas;
    fHeaderRows: array of TMyTableRow;
    fRows: array of TMyTableRow;
    fFont: TFont;
    fHGrid: integer;
    fVGrid: integer;
    fXPadding: integer;
    fYPadding: integer;
    fAlign: TMyTableColumnAlignment;
    fVAlign: TMyTableColumnAlignment;
    fColor: TColor;
    fHeaderGrid,fBodyGrid: boolean;
    fChanging: integer;
    procedure set_VAlign(const Value: TMyTableColumnAlignment);
    procedure set_Font(const Value: TFont);
    function get_Font: TFont;
    function get_Changing: boolean;
    function get_HeaderText(x, y: integer): string;
    procedure set_HeaderText(x, y: integer; const Value: string);
    procedure set_Changing(const Value: boolean);
    function get_ColWidth(x: integer): integer;
    procedure set_ColWidth(x: integer; const Value: integer);
    function get_ColCount: integer;
    function get_RowCount: integer;
    procedure set_RowCount(const Value: integer);
    function get_Row(i: integer): TMyTableRow;
    procedure set_Color(const Value: TColor);
    function get_Width: integer;
    procedure set_XPadding(const Value: integer);
    procedure set_Align(const Value: TMyTableColumnAlignment);
    function get_Text(x, y: integer): string;
    procedure set_Text(x, y: integer; const Value: string);
    function get_Header(x,y: integer): TMyTableCell;
    procedure set_Canvas(const Value: TCanvas);
    function get_Cell(x, y: integer): TMyTableCell;
    procedure OnFontChanged (Sender: TObject);
    procedure RecalcWidthsAndHeights;
    procedure ReSpan;
    function AddRow: TMyTableRow;
    function HeaderHeight: integer;
    function BodyHeight: integer; overload;
    function BodyHeight (StartRow,EndRow: integer): integer; overload;
    procedure FitCol (col: integer; width: integer); overload;
    procedure FitCol (col: integer; cell: TMyTableCell); overload;
    procedure FitRow (row: integer; height: integer); overload;
    procedure FitRow (row: integer; cell: TMyTableCell); overload;
    procedure FitHeaderRow (row: integer; height: integer); overload;
    procedure FitHeaderRow (row: integer; cell: TMyTableCell); overload;
    procedure AddColumn;
    function AddHeaderRow: TMyTableRow;
    function GetSpanWidth (col: integer; span: integer; AddGrid: boolean= true): integer;
    function GetSpanHeight (row: integer; span: integer; AddGrid: boolean= true): integer;
    procedure SetSpanHeight (row: integer; span: integer; height: integer);
    function GetHeaderSpanHeight (row: integer; span: integer; AddGrid: boolean= true): integer;
    procedure SetHeaderSpanHeight (row: integer; span: integer; height: integer);
    procedure SetSpanWidth (col: integer; span: integer; width: integer);
    procedure CreateFont;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property Text[x,y: integer]: string read get_Text write set_Text;
    property Cells[x,y: integer]: TMyTableCell read get_Cell;
    property HeaderText[x,y: integer]: string read get_HeaderText write set_HeaderText;
    property Header[x,y: integer]: TMyTableCell read get_Header;
    property Font: TFont read get_Font write set_Font;
    property Canvas: TCanvas read fCanvas write set_Canvas;
    procedure Draw (C: TCanvas; x,y: integer); overload;
    procedure Draw (C: TCanvas; x,y: integer; StartRow,EndRow: integer); overload;
    property Align: TMyTableColumnAlignment read fAlign write set_Align;
    property XPadding: integer read fXPadding write set_XPadding;
    property YPadding: integer read fYPadding write fYPadding;
    property VGrid: integer read fVGrid write fVGrid;
    property HGrid: integer read fHGrid write fHGrid;
    property Width: integer read get_Width;
    property Color: TColor read fColor write set_Color;
    procedure Recalculate;
    property HeaderGrid: boolean read fHeaderGrid write fHeaderGrid;
    property BodyGrid: boolean read fBodyGrid write fBodyGrid;
    function Height: integer; overload;
    function Height (StartRow,EndRow: integer): integer; overload;
    property ColCount: integer read get_ColCount;
    property RowCount: integer read get_RowCount write set_RowCount;
    property Rows[i: integer]: TMyTableRow read get_Row;
    property ColWidths[x: integer]: integer read get_ColWidth write set_ColWidth;
    property Changing: boolean read get_Changing write set_Changing;
    property VAlign: TMyTableColumnAlignment read fVAlign write set_VAlign;
    procedure DecreaseFontSize;
  end;

implementation

{ TMyTable }

procedure TMyTable.AddColumn;
var
  l: integer;
begin
  l:= Length (fColWidths);
  SetLength (fColWidths,l+1);
  fColWidths[l]:= 0;
end;

function TMyTable.AddHeaderRow: TMyTableRow;
var
  idx: integer;
begin
  Changing:= true;
  idx:= Length (fHeaderRows);
  SetLength (fHeaderRows,idx+1);
  Result:= TMyTableRow.Create (self);
  fHeaderRows[idx]:= Result;
  SetLength (fHeaderHeights,idx+1);
  fHeaderHeights[idx]:= 0;
  Changing:= false;
end;

function TMyTable.AddRow: TMyTableRow;
var
  idx: integer;
begin
  Changing:= true;
  idx:= Length (fRows);
  SetLength (fRows,idx+1);
  Result:= TMyTableRow.Create (self);
  fRows[idx]:= Result;
  SetLength (fRowHeights,idx+1);
  fRowHeights[idx]:= 0;
  Changing:= false;
end;

function TMyTable.BodyHeight: integer;
var
  rh,i: integer;
begin
  Result:= 0;
  for i:= 0 to RowCount-1 do
    begin
//      rh:= fRows[i].Height;
      rh:= fRowHeights[i];
      if rh> 0 then
        Result:= Result+rh+abs (fHGrid);
    end;
  if RowCount> 0 then
    inc (Result,abs (fHGrid));
end;

function TMyTable.BodyHeight(StartRow, EndRow: integer): integer;
var
  i: integer;
  rh: integer;
begin
  if (StartRow>= RowCount) or (EndRow< StartRow) then
    begin
      Result:= 0;
      exit;
    end
  else if EndRow>= RowCount then
    StartRow:= RowCount-1;
  Result:= 0;
  for i:= StartRow to EndRow do
    begin
      //rh:= fRows[i].Height;
      rh:= fRowHeights[i];
      if rh> 0 then
        inc (Result,rh+abs (fHGrid));
    end;
  if Result> 0 then
    inc (Result,abs (fHGrid));
end;

procedure TMyTable.Clear;
var
  i: integer;
begin
  for i:= 0 to Length (fRows)-1 do
    fRows[i].Free;
  SetLength (fRows,0);
  SetLength (fRowHeights,0);
  for i:= 0 to Length (fHeaderRows)-1 do
    fHeaderRows[i].Free;
  SetLength (fHeaderRows,0);
  SetLength (fHeaderHeights,0);
  SetLength (fColWidths,0);
end;

constructor TMyTable.Create;
begin
  inherited;
  SetLength (fColWidths,0);
  SetLength (fRowHeights,0);
  SetLength (fHeaderRows,0);
  SetLength (fHeaderHeights,0);
  SetLength (fRows,0);
  fFont:= nil;
  fHGrid:= 1;
  fVGrid:= 1;
  fXPadding:= 0;
  fYPadding:= 0;
  fAlign:= taLeft;
  fVAlign:= taBaseLine;
  fColor:= clNone;
  fHeaderGrid:= true;
  fBodyGrid:= true;
  fChanging:= 0;
end;

procedure TMyTable.CreateFont;
begin
  fFont:= TFont.Create;
  if fCanvas<> nil then
    fFont.Assign (fCanvas.Font);
  fFont.OnChange:= OnFontChanged;
end;

procedure TMyTable.DecreaseFontSize;
var
  row,col: integer;
  r: TMyTableRow;
  c: TMyTableCell;
begin
  Font.Height:= Font.Height+1;
  for row:= 0 to Length (fHeaderRows)-1 do
    begin
      r:= fHeaderRows[row];
      for col:= 0 to r.Count-1 do
        begin
          c:= r.Cells[col];
          if c.fFont<> nil then
            c.Font.Height:= c.Font.Height+1;
        end;
    end;
  for row:= 0 to RowCount-1 do
    begin
      r:= fRows[row];
      for col:= 0 to r.Count-1 do
        begin
          c:= r.Cells[col];
          if c.fFont<> nil then
            c.Font.Height:= c.Font.Height+1;
        end;
    end;
end;

destructor TMyTable.Destroy;
begin
  Clear;
  fRows:= nil;
  fColWidths:= nil;
  fRowHeights:= nil;
  fHeaderRows:= nil;
  fHeaderHeights:= nil;
  if fFont<> nil then
    FreeAndNil (fFont);
  inherited;
end;

procedure TMyTable.Draw(C: TCanvas; x, y, StartRow, EndRow: integer);
var
  th,tw,hh,cw,rh,bh: integer;
  i,j{,k}: integer;
  row: TMyTableRow;
  xx: integer;
  yy,yy1,yy2: integer;
  cell: TMyTableCell;
  first_row: boolean;
  ch: integer;
  //first_body_hline: boolean;
  _bs: TBrushStyle;
  _bc: TColor;
  _pw: integer;
begin
  if EndRow>= RowCount then
    EndRow:= RowCount-1;
  _pw:= C.Pen.Width;
  C.Pen.Width:= 0;
  _bs:= C.Brush.Style;
  C.Brush.Style:= bsSolid;
  _bc:= C.Brush.Color;
  C.Brush.Color:= clBlack;
  th:= Height (StartRow,EndRow);
  tw:= Width;
  hh:= HeaderHeight;
  bh:= BodyHeight (StartRow,EndRow);
  if fHeaderGrid then
    yy1:= y
  else
    yy1:= y+hh;
  if fBodyGrid then
    yy2:= y+th
  else
    yy2:= y+hh;

  // draw border
  if fVGrid> 0 then
    begin
      C.FillRect (Rect (x,yy1,x+fVGrid,yy2));
      C.FillRect (Rect (x+tw-fVGrid,yy1,x+tw,yy2));
    end;
  if fHGrid> 0 then
    begin
      if (hh> 0) and (fHeaderGrid) then
        begin
          C.FillRect (Rect (x,y,x+tw,y+fHGrid));
          C.FillRect (Rect (x,y+hh,x+tw,y+hh+fHGrid));
        end
      else if (bh> 0) and (fBodyGrid) then
        begin
          C.FillRect (Rect (x,y+hh,x+tw,y+hh+fHGrid));
        end;
      if (bh> 0) and (fBodyGrid) then
        begin
          C.FillRect (Rect (x,y+th-fHGrid,x+tw,y+th));
        end;
    end;
  // draw contents
  yy:= y;
  first_row:= true;
  for i:= 0 to Length (fHeaderRows)-1 do
    begin
      row:= fHeaderRows[i];
      //rh:= row.Height;
      rh:= fHeaderHeights[i];
      if rh= 0 then
        continue;
      if i= 0 then
        yy:= yy+abs (fHGrid);
      xx:= x+abs (fVGrid);
      j:= 0;
      while j< row.Count do
        begin
          cell:= row.Cells[j];
          if cell.fSpanned<> nil then
            begin
              cw:= GetSpanWidth (j,cell.fSpanned.ColSpan);
              inc (xx,cw+abs (fVGrid));
              inc (j,cell.fSpanned.ColSpan);
              continue;
            end;
          cw:= GetSpanWidth (j,cell.ColSpan);
          if cw= 0 then
            begin
              inc (j,cell.ColSpan);
              continue;
            end;
          ch:= GetHeaderSpanHeight (i,cell.RowSpan);
          // draw cell rect
          cell.Draw (C,Rect (xx,yy,xx+cw,yy+ch));
          // draw borders
          if (fVGrid> 0) and (fHeaderGrid) then
            begin
              C.Brush.Style:= bsSolid;
              C.Brush.Color:= clBlack;
              if j> 0 then
                C.FillRect (Rect (xx-fVGrid,yy-fVGrid,xx,yy+ch));
            end;
          if (fHGrid> 0) and (fHeaderGrid) then
            begin
              C.Brush.Style:= bsSolid;
              C.Brush.Color:= clBlack;
              if not first_row then
                C.FillRect (Rect (xx,yy-fVGrid,xx+cw,yy));
            end;
          inc (xx,cw+abs (fVGrid));
          inc (j,cell.ColSpan);
        end;
      inc (yy,rh+abs (fHGrid));
      first_row:= false;
    end;
  first_row:= true;
  for i:= StartRow to EndRow do
    begin
      row:= fRows[i];
      //rh:= row.Height;
      rh:= fRowHeights[i];
      if rh= 0 then
        continue;
      xx:= x+abs (fVGrid);
      j:= 0;
      while j< row.Count do
        begin
          cell:= row.Cells[j];
          // check if spanned
          if cell.fSpanned<> nil then
            begin
              cw:= GetSpanWidth (j,cell.fSpanned.ColSpan);
              inc (xx,cw+abs (fVGrid));
              inc (j,cell.fSpanned.ColSpan);
              continue;
            end;
          cw:= GetSpanWidth (j,cell.ColSpan);
          if cw= 0 then
            begin
              inc (j,cell.ColSpan);
              continue;
            end;
          ch:= GetSpanHeight (i,cell.RowSpan);
          cell.Draw (C,Rect (xx,yy,xx+cw,yy+ch));
          // draw borders
          if (fVGrid> 0) and (fBodyGrid) then
            begin
              C.Brush.Style:= bsSolid;
              C.Brush.Color:= clBlack;
              if j> 0 then
                C.FillRect (Rect (xx-fVGrid,yy-fVGrid,xx,yy+ch));
            end;
          if (fHGrid> 0) and (fBodyGrid) then
            begin
              C.Brush.Style:= bsSolid;
              C.Brush.Color:= clBlack;
              if not first_row then
                C.FillRect (Rect (xx-fVGrid,yy-fVGrid,xx+cw,yy));
            end;
          inc (xx,cw+abs (fVGrid));
          inc (j,cell.ColSpan);
        end;
      inc (yy,rh+abs(fHGrid));
      first_row:= false;
    end;
  C.Brush.Style:= _bs;
  C.Pen.Width:= _pw;
  C.Brush.Color:= _bc;
end;

procedure TMyTable.FitCol(col: integer; cell: TMyTableCell);
var
  cw,sw: integer;
begin
  if cell<> nil then
    begin
      if cell.ColSpan= 1 then
        FitCol (col,cell.Width)
      else
        begin
          // SPAN width
          sw:= GetSpanWidth (col,cell.ColSpan);
          cw:= cell.Width;
          if cw> sw then
            SetSpanWidth (col,cell.ColSpan,cw);
        end;
    end;
end;

procedure TMyTable.FitHeaderRow(row, height: integer);
begin
  if fHeaderHeights[row]< height then
    fHeaderHeights[row]:= height;
end;

procedure TMyTable.FitHeaderRow(row: integer; cell: TMyTableCell);
var
  ch,sh: integer;
begin
  if cell<> nil then
    begin
      if cell.RowSpan= 1 then
        FitHeaderRow (row,cell.Height)
      else
        begin
          // SPAN height
          sh:= GetHeaderSpanHeight (row,cell.RowSpan);
          ch:= cell.Height;
          if ch> sh then
            SetHeaderSpanHeight (row,cell.RowSpan,ch);
        end;
    end;
end;

procedure TMyTable.FitRow(row, height: integer);
begin
  if fRowHeights[row]< height then
    fRowHeights[row]:= height;
end;

procedure TMyTable.FitRow(row: integer; cell: TMyTableCell);
var
  ch,sh: integer;
begin
  if cell<> nil then
    begin
      if cell.RowSpan= 1 then
        FitRow (row,cell.Height)
      else
        begin
          // SPAN height
          sh:= GetSpanHeight (row,cell.RowSpan);
          ch:= cell.Height;
          if ch> sh then
            SetSpanHeight (row,cell.RowSpan,ch);
        end;
    end;
end;

function TMyTable.GetHeaderSpanHeight(row, span: integer; AddGrid: boolean): integer;
var
  i: integer;
begin
  i:= row;
  Result:= 0;
  while (i< row+span) and (i< Length(fHeaderRows)) do
    begin
      Result:= Result+fHeaderHeights[i];  //fHeaderRows[i].Height;
      inc (i);
    end;
  if AddGrid then
    Result:= Result+abs (fHGrid)*(span-1);
end;

function TMyTable.GetSpanHeight(row, span: integer; AddGrid: boolean): integer;
var
  i: integer;
begin
  i:= row;
  Result:= 0;
  while (i< row+span) and (i< RowCount) do
    begin
      Result:= Result+fRowHeights[i];  //Rows[i].Height;
      inc (i);
    end;
  if AddGrid then
    Result:= Result+abs (fHGrid)*(span-1);
end;

function TMyTable.GetSpanWidth(col, span: integer; AddGrid: boolean= true): integer;
var
  i: integer;
begin
  i:= col;
  Result:= 0;
  while (i< col+span) and (i< Length (fColWidths)) do
    begin
      Result:= Result+fColWidths[i];
      inc (i);
    end;
  if AddGrid then
    Result:= Result+abs (fVGrid)*(span-1);
end;

procedure TMyTable.FitCol(col, width: integer);
begin
  if fColWidths[col]< width then
    fColWidths[col]:= width;
end;

procedure TMyTable.Draw(C: TCanvas; x, y: integer);
begin
  Draw (C,x,y,0,Length(fRows)-1);
end;

function TMyTable.get_Cell(x, y: integer): TMyTableCell;
begin
  while x>= ColCount do
    AddColumn;
  while y>= RowCount do
    AddRow;
  Result:= fRows[y].Cells[x];
end;

function TMyTable.get_Changing: boolean;
begin
  Result:= fChanging<> 0;
end;

function TMyTable.get_ColCount: integer;
begin
  Result:= Length (fColWidths);
end;

function TMyTable.get_ColWidth(x: integer): integer;
begin
  if x< Length (fColWidths) then
    Result:= fColWidths[x]
  else
    Result:= 0;
end;

function TMyTable.get_Font: TFont;
begin
  if fFont= nil then
    CreateFont;
  Result:= fFont;
end;

function TMyTable.get_Header(x,y: integer): TMyTableCell;
var
  hr: TMyTableRow;
begin
  while x>= ColCount do
    AddColumn;
  while y>= Length(fHeaderRows) do
    AddHeaderRow;
  hr:= fHeaderRows[y];
  Result:= hr.Cells[x];
end;

function TMyTable.get_HeaderText(x, y: integer): string;
var
  cell: TMyTableCell;
begin
  cell:= Header[x,y];
  if cell<> nil then
    Result:= cell.AsText
  else
    Result:= '';
end;

function TMyTable.get_Row(i: integer): TMyTableRow;
begin
  if i< RowCount then
    Result:= fRows[i]
  else
    Result:= nil;
end;

function TMyTable.get_RowCount: integer;
begin
  Result:= Length (fRows);
end;

function TMyTable.get_Text(x, y: integer): string;
var
  c: TMyTableCell;
begin
  c:= Cells[x,y];
  if c<> nil then
    Result:= c.AsText
  else
    Result:= '';
end;

function TMyTable.get_Width: integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Length (fColWidths)-1 do
    Result:= Result+fColWidths[i]+abs (fVGrid);
  if Length (fColWidths)> 0 then
    Result:= Result+abs (fVGrid);
end;

function TMyTable.HeaderHeight: integer;
var
  rh,i: integer;
begin
  Result:= 0;
  if fCanvas= nil then
    exit;
  for i:= 0 to Length (fHeaderRows)-1 do
    begin
      rh:= fHeaderHeights[i]; //fHeaderRows[i].Height;
      if rh> 0 then
        Result:= Result+rh+abs (fHGrid);
    end;
  //if Result> 0 then
  //  Result:= Result+abs (fHGrid);
end;

function TMyTable.Height: integer;
var
  h,b: integer;
begin
  h:= HeaderHeight;
  b:= BodyHeight;
  Result:= h+b;
  if (h= 0) or (b= 0) then
    Result:= Result+abs (fHGrid);
end;

function TMyTable.Height(StartRow, EndRow: integer): integer;
var
  h,b: integer;
begin
  h:= HeaderHeight;
  b:= BodyHeight (StartRow,EndRow);
  Result:= h+b;
  if (h= 0) or (b= 0) then
    Result:= Result+abs (fHGrid);
end;

procedure TMyTable.OnFontChanged(Sender: TObject);
begin
  ReSpan;
  RecalcWidthsAndHeights;
end;

procedure TMyTable.Recalculate;
begin
  ReSpan;
  RecalcWidthsAndHeights;
end;

procedure TMyTable.RecalcWidthsAndHeights;
var
  row,col: integer;
  r: TMyTableRow;
  cell: TMyTableCell;
begin
  if fCanvas= nil then
    exit;
  for col:= 0 to Length (fColWidths)-1 do
    fColWidths[col]:= 0;
  for row:= 0 to RowCount-1 do
    fRowHeights[row]:= 0;
  for row:= 0 to Length (fHeaderHeights)-1 do
    fHeaderHeights[row]:= 0;
  // 1 - without span
  for row:= 0 to Length (fHeaderRows)-1 do
    begin
      r:= fHeaderRows[row];
      col:= 0;
      while col< r.Count do
        begin
          cell:= r.Cells[col];
          FitCol (col,cell);
          if (cell.fSpanned= nil) and (cell.RowSpan= 1) then
            FitHeaderRow (row,cell);
          inc (col,cell.ColSpan);
        end;
    end;
  // 2 - span only
  for row:= 0 to Length (fHeaderRows)-1 do
    begin
      r:= fHeaderRows[row];
      col:= 0;
      while col< r.Count do
        begin
          cell:= r.Cells[col];
          if (cell.fSpanned= nil) and (cell.RowSpan> 1) then
            FitHeaderRow (row,cell);
          inc (col,cell.ColSpan);
        end;
    end;
  // 1 - without span
  for row:= 0 to RowCount-1 do
    begin
      r:= fRows[row];
      col:= 0;
      while col< r.Count do
        begin
          cell:= r.Cells[col];
          FitCol (col,cell);
          if (cell.fSpanned= nil) and (cell.RowSpan= 1) then
            FitRow (row,cell);
          inc (col,cell.ColSpan);
        end;
    end;
  // 2 - span only
  for row:= 0 to RowCount-1 do
    begin
      r:= fRows[row];
      col:= 0;
      while col< r.Count do
        begin
          cell:= r.Cells[col];
          if (cell.fSpanned= nil) and (cell.RowSpan> 1) then
            FitRow (row,cell);
          inc (col,cell.ColSpan);
        end;
    end;
end;

procedure TMyTable.ReSpan;
var
  i,j: integer;
  k,n: integer;
  row: TMyTableRow;
  cell: TMyTableCell;
begin
  // reset all spans
  for i:= 0 to Length (fHeaderRows)-1 do
    begin
      row:= fHeaderRows[i];
      for j:= 0 to row.Count-1 do
        begin
          cell:= row.Cells[j];
          cell.fSpanned:= nil;
        end;
    end;
  for i:= 0 to Length (fRows)-1 do
    begin
      row:= fRows[i];
      for j:= 0 to row.Count-1 do
        begin
          cell:= row.Cells[j];
          cell.fSpanned:= nil;
        end;
    end;
  // set SPANNED mark
  for i:= 0 to Length (fHeaderRows)-1 do
    begin
      row:= fHeaderRows[i];
      for j:= 0 to row.Count-1 do
        begin
          cell:= row.Cells[j];
          if (cell.fSpanned<> nil) or ((cell.RowSpan= 1) and (cell.ColSpan= 1)) then
            continue;
          k:= j+1;
          while (k< j+cell.ColSpan) and (k< row.Count) do
            begin
              row.Cells[k].fSpanned:= cell;
              inc (k);
            end;
          n:= i+1;
          while (n< i+cell.RowSpan) and (n< Length (fHeaderRows)) do
            begin
              k:= j;
              while (k< j+cell.ColSpan) and (k< fHeaderRows[n].Count) do
                begin
                  fHeaderRows[n].Cells[k].fSpanned:= cell;
                  inc (k);
                end;
              inc (n);
            end;
        end;
    end;
  for i:= 0 to Length (fRows)-1 do
    begin
      row:= fRows[i];
      for j:= 0 to row.Count-1 do
        begin
          cell:= row.Cells[j];
          if (cell.fSpanned<> nil) or ((cell.RowSpan= 1) and (cell.ColSpan= 1)) then
            continue;
          k:= j+1;
          while (k< j+cell.ColSpan) and (k< row.Count) do
            begin
              row.Cells[k].fSpanned:= cell;
              inc (k);
            end;
          n:= i+1;
          while (n< i+cell.RowSpan) and (n< Length (fRows)) do
            begin
              k:= j;
              while (k< j+cell.ColSpan) and (k< fRows[n].Count) do
                begin
                  fRows[n].Cells[k].fSpanned:= cell;
                  inc (k);
                end;
              inc (n);
            end;
        end;
    end;
end;

procedure TMyTable.SetHeaderSpanHeight(row, span, height: integer);
var
  i: integer;
  factor: double;
begin
  if GetHeaderSpanHeight (row,span,false)> 0 then
    begin
      for i:= row to row+span-1 do
        begin
          factor:= height/GetHeaderSpanHeight (i,span);
          fHeaderHeights[i]:= round (fHeaderHeights[i]*factor);
          dec (span);
          dec (height,fHeaderHeights[i]);
          if height= 0 then
            break;
        end;
    end
  else
    begin
      for i:= row to row+span-1 do
        begin
          fHeaderHeights[i]:= round (height/span);
          dec (span);
          dec (height,fHeaderHeights[i]);
        end;
    end;
end;

procedure TMyTable.SetSpanHeight(row, span, height: integer);
var
  i: integer;
  factor: double;
begin
  if GetSpanHeight (row,span,false)> 0 then
    begin
      for i:= row to row+span-1 do
        begin
          factor:= height/GetSpanHeight (i,span);
          fRowHeights[i]:= round (fRowHeights[i]*factor);
          dec (span);
          dec (height,fRowHeights[i]);
          if height= 0 then
            break;
        end;
    end
  else
    begin
      for i:= row to row+span-1 do
        begin
          fRowHeights[i]:= round (height/span);
          dec (span);
          dec (height,fRowHeights[i]);
        end;
    end;
end;

procedure TMyTable.SetSpanWidth(col, span, width: integer);
var
  i: integer;
  factor: double;
begin
  if GetSpanWidth (col,span,false)> 0 then
    begin
      for i:= col to col+span-1 do
        begin
          factor:= width/GetSpanWidth (i,span);
          fColWidths[i]:= round (fColWidths[i]*factor);
          dec (span);
          dec (width,fColWidths[i]);
          if width= 0 then
            break;
        end;
    end
  else
    begin
      for i:= col to col+span-1 do
        begin
          fColWidths[i]:= round (width/span);
          dec (span);
          dec (width,fColWidths[i]);
        end;
    end;
end;

procedure TMyTable.set_Align(const Value: TMyTableColumnAlignment);
var
  i: integer;
begin
  fAlign:= Value;
  for i:= 0 to RowCount-1 do
    fRows[i].Align:= taDefault;
end;

procedure TMyTable.set_Canvas(const Value: TCanvas);
begin
  fCanvas:= Value;
  if fFont= nil then
    Font:= fCanvas.Font;
  ReSpan;
  RecalcWidthsAndHeights;
end;

procedure TMyTable.set_Changing(const Value: boolean);
begin
  if Value then
    inc (fChanging)
  else if fChanging> 0 then
    begin
      dec (fChanging);
      if fChanging= 0 then
        begin
          ReSpan;
          RecalcWidthsAndHeights;
        end;
    end;
end;

procedure TMyTable.set_Color(const Value: TColor);
var
  i: integer;
begin
  fColor:= Value;
  for i:= 0 to RowCount-1 do
    fRows[i].Color:= clDefault;
end;

procedure TMyTable.set_ColWidth(x: integer; const Value: integer);
begin
  if x< Length (fColWidths) then
    begin
      if Value> fColWidths[x] then
        fColWidths[x]:= Value;
    end;
end;

procedure TMyTable.set_Font(const Value: TFont);
begin
  if fFont= nil then
    CreateFont;
  fFont.Assign (Value);
end;

procedure TMyTable.set_HeaderText(x,y: integer; const Value: string);
var
  cell: TMyTableCell;
begin
  Changing:= true;
  cell:= Header[x,y];
  if cell<> nil then
    cell.AsText:= Value;
  Changing:= false;
end;

procedure TMyTable.set_RowCount(const Value: integer);
var
  i: integer;
begin
  Changing:= true;
  if Value< Length (fRows) then
    begin
      for i:= Value to Length (fRows)-1 do
        fRows[i].Free;
      SetLength (fRows,Value);
    end
  else
    begin
      while Value> Length (fRows) do
        AddRow;
    end;
  Changing:= false;
end;

procedure TMyTable.set_Text(x, y: integer; const Value: string);
var
  cell: TMyTableCell;
begin
  Changing:= true;
  cell:= Cells[x,y];
  if cell<> nil then
    cell.AsText:= Value;
  Changing:= false;
end;

procedure TMyTable.set_VAlign(const Value: TMyTableColumnAlignment);
var
  i: integer;
begin
  fVAlign:= Value;
  for i:= 0 to RowCount-1 do
    fRows[i].VAlign:= taDefault;
end;

procedure TMyTable.set_XPadding(const Value: integer);
begin
  Changing:= true;
  fXPadding:= Value;
  Changing:= false;
end;

{ TMyTableRow }

function TMyTableRow.AddCell: TMyTableCell;
var
  idx: integer;
begin
  idx:= Length (fCells);
  SetLength (fCells,idx+1);
  Result:= TMyTableCell.Create (self);
  fCells[idx]:= Result;
end;

procedure TMyTableRow.Clear;
var
  i: integer;
begin
  for i:= 0 to Length (fCells)-1 do
    fCells[i].Free;
  SetLength (fCells,0);
end;

function TMyTableRow.Count: integer;
begin
  Result:= Length (fCells);
end;

constructor TMyTableRow.Create(ATable: TMyTable);
begin
  inherited Create;
  fTable:= ATable;
  SetLength (fCells,0);
  fAlign:= taDefault;
  fVAlign:= taDefault;
  fColor:= clDefault;
  fFont:= nil;
end;

procedure TMyTableRow.CreateFont;
begin
  fFont:= TFont.Create;
  fFont.Assign (fTable.Font);
  fFont.OnChange:= OnFontChange;
end;

destructor TMyTableRow.Destroy;
begin
  Clear;
  if fFont<> nil then
    FreeAndNil (fFont);
  inherited;
end;

function TMyTableRow.GetBaseLine: integer;
var
  bl,i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    begin
      bl:= Cells[i].GetBaseLine;
      if bl> Result then
        Result:= bl;
    end;
end;

function TMyTableRow.GetFont: TFont;
begin
  if fFont<> nil then
    Result:= fFont
  else
    Result:= fTable.Font;
end;

function TMyTableRow.get_Align: TMyTableColumnAlignment;
begin
  if fAlign= taDefault then
    Result:= fTable.Align
  else
    Result:= fAlign;
end;

function TMyTableRow.get_Cell(i: integer): TMyTableCell;
begin
  while i>= fTable.ColCount do
    fTable.AddColumn;
  while i>= Length (fCells) do
    AddCell;
  Result:= fCells[i];
end;

function TMyTableRow.get_Color: TColor;
begin
  if fColor= clDefault then
    Result:= fTable.Color
  else
    Result:= fColor;
end;

function TMyTableRow.get_Font: TFont;
begin
  if fFont= nil then
    CreateFont;
  Result:= fFont;
end;

function TMyTableRow.get_VAlign: TMyTableColumnAlignment;
begin
  if fVAlign= taDefault then
    Result:= fTable.VAlign
  else
    Result:= fVAlign;
end;

function TMyTableRow.Height: integer;
var
  i,h: integer;
begin
  Result:= 0;
  i:= 0;
  while i< Count do
    begin
      h:= fCells[i].Height;
      if h> 0 then
        h:= h + fTable.fYPadding*2;
      if h> Result then
        Result:= h;
      inc (i,fCells[i].ColSpan);
    end;
end;

procedure TMyTableRow.OnFontChange(Sender: TObject);
begin
  fTable.Changing:= true;
  fTable.Changing:= false;
end;

procedure TMyTableRow.set_Align(const Value: TMyTableColumnAlignment);
var
  i: integer;
begin
  fAlign:= Value;
  for i:= 0 to Length (fCells)-1 do
    fCells[i].Align:= taDefault;
end;

procedure TMyTableRow.set_Color(const Value: TColor);
var
  i: integer;
begin
  fColor:= Value;
  for i:= 0 to Length (fCells)-1 do
    fCells[i].Color:= clDefault;
end;

procedure TMyTableRow.set_Font(const Value: TFont);
var
  i: integer;
begin
  fTable.Changing:= true;
  if Value<> nil then
    begin
      CreateFont;
      fFont.Assign (Value);
      for i:= 0 to Count-1 do
        Cells[i].Font:= nil;
    end
  else
    begin
      if fFont<> nil then
        FreeAndNil (fFont);
      for i:= 0 to Count-1 do
        Cells[i].Font:= nil;
    end;
  fTable.Changing:= false;
end;

procedure TMyTableRow.set_VAlign(const Value: TMyTableColumnAlignment);
var
  i: integer;
begin
  fVAlign:= Value;
  for i:= 0 to Length (fCells)-1 do
    fCells[i].VAlign:= taDefault;
end;

{ TMyTableCell }

constructor TMyTableCell.Create(ARow: TMyTableRow);
begin
  inherited Create;
  fRow:= ARow;
  fAlign:= taDefault;
  fColor:= clDefault;
  fColSpan:= 1;
  fRowSpan:= 1;
  fFont:= nil;
  fVAlign:= taDefault;
  fText:= TStringList.Create;
end;

procedure TMyTableCell.CreateFont;
begin
  fFont:= TFont.Create;
  fFont.Assign (fRow.GetFont);
  fFont.OnChange:= OnFontChange;
end;

destructor TMyTableCell.Destroy;
begin
  if fFont<> nil then
    FreeAndNil (fFont);
  fText.Free;
  inherited;
end;

procedure TMyTableCell.Draw(C: TCanvas; R: TRect);
var
  xp,yp,y: integer;
  th,tw: integer;
  tm: TTextMetricA;
  s: string;
  i: integer;
begin
  xp:= fRow.fTable.fXPadding;
  yp:= fRow.fTable.fYPadding;
  if Color<> clNone then
    begin
      C.Brush.Color:= Color;
      C.FillRect (R);
    end;
  C.Brush.Style:= bsClear;
  C.Font:= GetFont;
  GetTextMetricsA (C.Handle,tm);
  th:= tm.tmHeight * fText.Count;
  case VAlign of
    taBottom: y:= R.Bottom-yp-th;
    taCenter: y:= (R.Top+R.Bottom-th) div 2;
    taBaseLine: begin
      y:= R.Top+yp+fRow.GetBaseLine-tm.tmAscent;
    end;
  else
    {taTop:} y:= R.Top+yp;
  end;
  C.Font:= GetFont;
  for i:= 0 to fText.Count-1 do
    begin
      s:= fText[i];
      tw:= C.TextWidth (s);
      case Align of
        taLeft: C.TextOut (R.Left+xp,y,s);
        taCenter: C.TextOut ((R.Left+R.Right-tw) div 2,y,s);
        taRight: C.TextOut (R.Right-xp-tw,y,s);
      end;
      inc (y,tm.tmHeight);
    end;
end;

function TMyTableCell.GetBaseLine: integer;
var
  tm: TTextMetricA;
begin
  if fRow.fTable.fCanvas<> nil then
    begin
      fRow.fTable.fCanvas.Font:= GetFont;
      GetTextMetricsA (fRow.fTable.fCanvas.Handle,tm);
      Result:= tm.tmAscent;
    end
  else
    Result:= 0;
end;

function TMyTableCell.GetFont: TFont;
begin
  if fFont= nil then
    Result:= fRow.GetFont
  else
    Result:= fFont;
end;

function TMyTableCell.get_Align: TMyTableColumnAlignment;
begin
  if fAlign= taDefault then
    Result:= fRow.Align
  else
    Result:= fAlign;
end;

function TMyTableCell.get_Color: TColor;
begin
  if fColor= clDefault then
    Result:= fRow.Color
  else
    Result:= fColor;
end;

function TMyTableCell.get_Font: TFont;
begin
  if fFont= nil then
    CreateFont;
  Result:= fFont;
end;

function TMyTableCell.get_Text: string;
begin
  Result:= fText.Text;
end;

function TMyTableCell.get_Valign: TMyTableColumnAlignment;
begin
  if fVAlign= taDefault then
    Result:= fRow.VAlign
  else
    Result:= fVAlign;
end;

function TMyTableCell.Height: integer;
var
  tm: TTextMetricA;
begin
  if fRow.fTable.Canvas<> nil then
    begin
      fRow.fTable.Canvas.Font:= GetFont;
      GetTextMetricsA (fRow.fTable.Canvas.Handle,tm);
      Result:= tm.tmHeight * fText.Count;
      if Result> 0 then
        Result:= Result+fRow.fTable.YPadding * 2;
    end
  else
    Result:= 0;
end;

procedure TMyTableCell.OnFontChange(Sender: TObject);
begin
  fRow.fTable.Changing:= true;
  fRow.fTable.Changing:= false;
end;

procedure TMyTableCell.set_Align(const Value: TMyTableColumnAlignment);
begin
  fAlign:= Value;
end;

procedure TMyTableCell.set_Font(const Value: TFont);
begin
  fRow.fTable.Changing:= true;
  if Value<> nil then
    begin
      if fFont= nil then
        CreateFont;
      fFont.Assign (Value);
    end
  else
    begin
      if fFont<> nil then
        FreeAndNil (fFont);
    end;
  fRow.fTable.Changing:= false;
end;

procedure TMyTableCell.set_RowSpan(const Value: integer);
begin
  fRow.fTable.Changing:= true;
  fRowSpan:= Value;
  fRow.fTable.Changing:= false;
end;

procedure TMyTableCell.set_ColSpan(const Value: integer);
begin
  fRow.fTable.Changing:= true;
  fColSpan:= Value;
  fRow.fTable.Changing:= false;
end;

procedure TMyTableCell.set_Text(const Value: string);
begin
  fRow.fTable.Changing:= true;
  fText.Text:= Value;
  fRow.fTable.Changing:= false;
end;

procedure TMyTableCell.set_VAlign(const Value: TMyTableColumnAlignment);
begin
  fVAlign:= Value;
end;

function TMyTableCell.Width: integer;
var
  i,tw: integer;
  f: TFont;
begin
  Result:= 0;
  if (fText.Count> 0) and (fRow.fTable.fCanvas<> nil) then
    begin
      with fRow.fTable do
        begin
          f:= GetFont;
          fCanvas.Font:= f;
          for i:= 0 to fText.Count-1 do
            begin
              tw:= fCanvas.TextWidth (fText[i]);
              if tw> Result then
                Result:= tw;
            end;
          if Result> 0 then
            Result:= Result+fXPadding*2;
        end;
    end;
end;

end.

