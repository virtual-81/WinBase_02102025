unit MyTables;

interface

type
  TMyTableColumn= class
  private
    fTitle: string;
    fOwner: TMyTableColumn;
    fSubs: array of TMyTableColumn;
    fWidth: integer;
    fObject: TObject;
    fIndex: integer;
    function get_Column(Index: integer): TMyTableColumn;
    function get_Width: integer;
    procedure set_Width(const Value: integer);
  public
    constructor Create (AOwner: TMyTableColumn);
    destructor Destroy; override;
    procedure Clear;
    property Width: integer read get_Width write set_Width;
    procedure Fit (w: integer); overload;
    property Title: string read fTitle write fTitle;
    function Add: TMyTableColumn;
    property Obj: TObject read fObject write fObject;
    property Subs [Index: integer]: TMyTableColumn read get_Column;
    procedure AddSeparator (sep: integer);
    function Left: integer;
    function Prev: TMyTableColumn;
    function ColCount: integer;
    function Right: integer;
    function First: TMyTableColumn;
    function Next: TMyTableColumn;
    function TotalColumns: integer;
    function Columns (i: integer): TMyTableColumn;
    function Level: integer;
  end;

  TMyTableColumns= class (TMyTableColumn)
  private
  public
    constructor Create;
  end;

implementation

{ TMyTableColumn }

function TMyTableColumn.Add: TMyTableColumn;
var
  idx: integer;
  tc: TMyTableColumn;
begin
  idx:= Length (fSubs);
  SetLength (fSubs,idx+1);
  tc:= TMyTableColumn.Create (self);
  tc.fIndex:= idx;
  fSubs [idx]:= tc;
  fWidth:= 0;
  Result:= tc;
end;

procedure TMyTableColumn.AddSeparator(sep: integer);
var
  i: integer;
begin
  if Width= 0 then
    exit;
  if Length (fSubs)= 0 then
    fWidth:= fWidth+sep
  else
    begin
      for i:= 0 to Length (fSubs)-1 do
        fSubs [i].AddSeparator (sep);
    end;
end;

procedure TMyTableColumn.Clear;
var
  i: integer;
begin
  for i:= 0 to Length (fSubs)-1 do
    fSubs [i].Free;
  SetLength (fSubs,0);
  fSubs:= nil;
  fWidth:= 0;
  fTitle:= '';
end;

function TMyTableColumn.ColCount: integer;
begin
  Result:= Length (fSubs);
end;

function TMyTableColumn.Columns(i: integer): TMyTableColumn;
var
  j: integer;
begin
  Result:= First;
  j:= 0;
  while (j< i) and (Result<> nil) do
    begin
      Result:= Result.Next;
      inc (j);
    end;
end;

constructor TMyTableColumn.Create(AOwner: TMyTableColumn);
begin
  inherited Create;
  fOwner:= AOwner;
  fTitle:= '';
  fWidth:= 0;
  SetLength (fSubs,0);
end;

destructor TMyTableColumn.Destroy;
begin
  Clear;
  inherited;
end;

function TMyTableColumn.First: TMyTableColumn;
begin
  if Length (fSubs)> 0 then
    Result:= fSubs[0].First
  else
    Result:= self;
end;

procedure TMyTableColumn.Fit(w: integer);
begin
  if w> Width then
    Width:= w;
end;

function TMyTableColumn.get_Column(Index: integer): TMyTableColumn;
begin
  Result:= fSubs [Index];
end;

function TMyTableColumn.get_Width: integer;
var
  i: integer;
begin
  if Length (fSubs)> 0 then
    begin
      Result:= 0;
      for i:= 0 to Length (fSubs)-1 do
        Result:= Result+fSubs [i].Width;
    end
  else
    Result:= fWidth;
end;

function TMyTableColumn.Left: integer;
var
  p: TMyTableColumn;
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

function TMyTableColumn.Level: integer;
begin
  if fOwner= nil then
    Result:= 0
  else if fOwner is TMyTableColumns then
    Result:= 0
  else
    Result:= fOwner.Level+1;
end;

function TMyTableColumn.Next: TMyTableColumn;
begin
  if fOwner= nil then
    Result:= nil
  else
    begin
      if fIndex< fOwner.ColCount-1 then
        Result:= fOwner.fSubs[fIndex+1].First
      else
        Result:= fOwner.Next;
    end;
end;

function TMyTableColumn.Prev: TMyTableColumn;
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

function TMyTableColumn.Right: integer;
begin
  Result:= Left+Width;
end;

procedure TMyTableColumn.set_Width(const Value: integer);
var
  i: integer;
  cw,w,c: integer;
  ow: integer;
begin
  if Length (fSubs)> 0 then
    begin
      ow:= Width;
      w:= Value;
      c:= Length (fSubs);
      if ow> 0 then
        begin
          // растягиваем пропорционально старым размерам
          for i:= 0 to Length (fSubs)-1 do
            begin
              if ow> 0 then
                cw:= round (fSubs [i].Width*w/ow)
              else
                cw:= 0;
              dec (w,cw);
              dec (ow,fSubs [i].Width);
              fSubs [i].Width:= cw;
            end;
        end
      else
        begin
          // всем равные ширины
          for i:= 0 to Length (fSubs)-1 do
            begin
              cw:= round (w/c);
              fSubs [i].Width:= cw;
              dec (w,cw);
              dec (c);
            end;
        end;
      fWidth:= 0;
    end
  else
    fWidth:= Value;
end;

function TMyTableColumn.TotalColumns: integer;
var
  i: integer;
begin
  if Length (fSubs)> 0 then
    begin
      Result:= 0;
      for i:= 0 to Length (fSubs)-1 do
        inc (Result,fSubs[i].TotalColumns);
    end
  else
    begin
      if fOwner= nil then
        Result:= 0
      else
        Result:= 1;
    end;
end;

{ TMyTableColumns }

constructor TMyTableColumns.Create;
begin
  inherited Create (nil);
end;

end.
