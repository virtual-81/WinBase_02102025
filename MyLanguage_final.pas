{$a-}
unit MyLanguage;

{$define log_misses}

interface

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  mystrings;

type
  PMyString= ^TMyString;
  TMyString= record
    tag: String;
    st: String;
  end;

  TMyLanguage= class
  private
    fStrings: array of TMyString;
    fTags: array of PMyString;
    function get_ByTag(Tag: String): String;
    function get_String(Index: integer): String;
    procedure SortTags;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property Idx [Index: integer]: String read get_String;
    property ByTag [Tag: String]: String read get_ByTag; default;
    function LoadFromTextFile (FName: TFileName): boolean;
    function SaveToTextFile (FName: TFileName): boolean;
    function LoadFromResourceID (Instance: cardinal; ResID: integer): boolean;
    function LoadFromResourceName (Instance: cardinal; const ResName: String): boolean;
    function LoadFromString (AStr: String): boolean;
  end;

var
  Language: TMyLanguage;

implementation

{ TMyLanguage }

procedure TMyLanguage.Clear;
var
  i: integer;
begin
  for i:= 0 to length (fStrings)-1 do
    begin
      fStrings [i].tag:= '';
      fStrings [i].st:= '';
    end;
  SetLength (fStrings,0);
  SetLength (fTags,0);
end;

constructor TMyLanguage.Create;
begin
  inherited;
  SetLength (fStrings,0);
  SetLength (fTags,0);
end;

destructor TMyLanguage.Destroy;
begin
  Clear;
  inherited;
end;

function TMyLanguage.get_ByTag(Tag: String): String;
var
  idxlo,idxhi,idx: integer;
  res: integer;
  {$ifdef log_misses}
  mf: textfile;
  {$endif}
begin
  idxlo:= 0;
  idxhi:= length (fTags)-1;
  while idxlo<= idxhi do
    begin
      idx:= (idxhi+idxlo) div 2;
      res:= AnsiCompareText (Tag,fTags [idx]^.tag);
      case res of
        0: begin
          Result:= fTags [idx]^.st;
          exit;
        end;
        -1: begin
          idxhi:= idx-1;
        end;
        1: begin
          idxlo:= idx+1;
        end;
      end;
    end;
  Result:= '['+Tag+']';
  {$ifdef log_misses}
  {$i-}
  AssignFile (mf,'mylanguage_miss.log.txt');
  Append (mf);
  if ioresult<> 0 then
    Rewrite (mf);
  Writeln (mf,Tag);
  Closefile (mf);
  {$i+}
  {$endif}
end;

function TMyLanguage.get_String(Index: integer): String;
{$ifdef log_misses}
var
  mf: textfile;
{$endif}
begin
  if (Index>= 0) and (Index< Length (fStrings)) then
    Result:= fStrings [Index].st
  else
    begin
      Result:= '[NOT_FOUND_'+IntToStr (Index)+']';
      {$ifdef log_misses}
      {$i-}
      AssignFile (mf,'mylanguage_miss.log.txt');
      Append (mf);
      if ioresult<> 0 then
        Rewrite (mf);
      Writeln (mf,'INDEX_',Index);
      Closefile (mf);
      {$i+}
      {$endif}
    end;
end;

function TMyLanguage.LoadFromResourceID(Instance: cardinal; ResID: integer): boolean;
var
  hres: HRSRC;
  s: String;
  size: DWORD;
  hgl: HGLOBAL;
  p: pointer;
begin
  Result:= false;
  hres:= FindResourceA (Instance,PAnsiChar(AnsiString(ResId)),'MYLANGUAGE');
  if hres<> 0 then
    begin
      size:= SizeofResource (Instance,hres);
      if size > 0 then
        begin
          hgl:= LoadResource (Instance,hres);
          if hgl <> 0 then
            begin
              p:= LockResource (hgl);
              if p <> nil then
                begin
                  SetLength (s,size);
                  move (p^,s [1],size);
                  LoadFromString (s);
                  Result:= true;
                end;
            end;
        end;
    end;
end;

function TMyLanguage.LoadFromResourceName(Instance: cardinal; const ResName: String): boolean;
var
  hres: HRSRC;
  s: String;
  size: DWORD;
  hgl: HGLOBAL;
  p: pointer;
begin
  Result:= false;
  hres:= FindResource (Instance,PChar (ResName),RT_RCDATA);
  if hres<> 0 then
    begin
      size:= SizeofResource (Instance,hres);
      if size > 0 then
        begin
          hgl:= LoadResource (Instance,hres);
          if hgl <> 0 then
            begin
              p:= LockResource (hgl);
              if p <> nil then
                begin
                  SetLength (s,size);
                  move (p^,s [1],size);
                  LoadFromString (s);
                  Result:= true;
                end;
            end;
        end;
    end;
end;

function TMyLanguage.LoadFromString(AStr: String): boolean;
var
  ta: array of TMyString;

  function ProceedLine (s: String): boolean;
  var
    j,l: integer;
    p1,p2,c: integer;
    idx: integer;
    tag,st: String;
  begin
    Result:= false;
    p1:= pos (',',s);
    if p1= 0 then
      exit;
    val (copy (s,1,p1-1),idx,c);
    if (c<> 0) or (idx< 0) then
      exit;
    p2:= pos ('=',s);
    if p2<= p1+1 then
      exit;
    tag:= copy (s,p1+1,p2-p1-1);
    st:= copy (s,p2+1,length (s)-p2);
    if idx>= length (ta) then
      begin
        l:= Length (ta);
        SetLength (ta,idx+1);
        for j:= l to idx-1 do
          begin
            ta [j].tag:= '';
            ta [j].st:= '';
          end;
      end;
    ta [idx].tag:= tag;
    ta [idx].st:= EscapesToChars (st);
    Result:= true;
  end;

var
  s: String;
  si: integer;
  i: integer;
  sl: TStrings;
begin
  Result:= false;
  SetLength (ta,0);
  sl:= TStringList.Create;
  sl.Text:= AStr;
  for si:= 0 to sl.Count-1 do
    begin
      s:= trim (sl [si]);
      if trim (s)= '' then
        continue;
      if not ProceedLine (s) then
        begin
          for i:= 0 to length (ta)-1 do
            begin
              ta [i].tag:= '';
              ta [i].st:= '';
            end;
          SetLength (ta,0);
          sl.Free;
          exit;
        end;
    end;
  sl.Free;
  Clear;
  SetLength (fStrings,length (ta));
  for i:= 0 to length (fStrings)-1 do
    fStrings [i]:= ta [i];
  for i:= 0 to length (ta)-1 do
    begin
      ta [i].tag:= '';
      ta [i].st:= '';
    end;
  SetLength (ta,0);
  SortTags;
  Result:= true;
end;

function TMyLanguage.LoadFromTextFile(FName: TFileName): boolean;
var
  sl: TStringList;
  s: String;
  ta: array of TMyString;
  i, j: integer;
  p1,p2,c: integer;
  idx,l: integer;
  tag,st: String;
begin
  Result:= false;
  if not FileExists(FName) then
    exit;
    
  sl := TStringList.Create;
  try
    sl.LoadFromFile(FName, TEncoding.UTF8);
    SetLength (ta,0);
    
    for i := 0 to sl.Count - 1 do
    begin
      s := sl[i];
      if trim (s)= '' then
        continue;
      p1:= pos (',',s);
      if p1= 0 then
        begin
          for j:= 0 to length (ta)-1 do
            begin
              ta [j].tag:= '';
              ta [j].st:= '';
            end;
          SetLength (ta,0);
          sl.Free;
          exit;
        end;
      val (copy (s,1,p1-1),idx,c);
      if (c<> 0) or (idx< 0) then
        begin
          for j:= 0 to length (ta)-1 do
            begin
              ta [j].tag:= '';
              ta [j].st:= '';
            end;
          SetLength (ta,0);
          sl.Free;
          exit;
        end;
      p2:= pos ('=',s);
      if p2<= p1+1 then
        begin
          for j:= 0 to length (ta)-1 do
            begin
              ta [j].tag:= '';
              ta [j].st:= '';
            end;
          SetLength (ta,0);
          sl.Free;
          exit;
        end;
      tag:= copy (s,p1+1,p2-p1-1);
      st:= copy (s,p2+1,length (s)-p2);
      if idx>= length (ta) then
        begin
          l:= length (ta);
          SetLength (ta,idx+1);
          for j:= l to idx-1 do
            begin
              ta [j].tag:= '';
              ta [j].st:= '';
            end;
        end;
      ta [idx].tag:= tag;
      ta [idx].st:= EscapesToChars (st);
    end;
  finally
    sl.Free;
  end;
  Clear;
  SetLength (fStrings,length (ta));
  for j:= 0 to length (fStrings)-1 do
    fStrings [j]:= ta [j];
  for j:= 0 to length (ta)-1 do
    begin
      ta [j].tag:= '';
      ta [j].st:= '';
    end;
  SetLength (ta,0);
  SortTags;
  Result:= true;
end;

function TMyLanguage.SaveToTextFile(FName: TFileName): boolean;
var
  tf: TextFile;
  i: integer;
begin
  Result:= false;
  {$i-}
  AssignFile (tf,FName);
  Rewrite (tf);
  if ioresult<> 0 then
    exit;
  for i:= 0 to Length (fStrings)-1 do
    begin
      Writeln (tf,i,',',fStrings [i].tag,'=',CharsToEscapes (fStrings [i].st));
      if ioresult<> 0 then
        begin
          CloseFile (tf);
          exit;
        end;
    end;
  CloseFile (tf);
  {$i+}
  Result:= true;
end;

procedure TMyLanguage.SortTags;
var
  i,j,idx: integer;
  ps: PMyString;
begin
  SetLength (fTags,length (fStrings));
  for i:= 0 to Length (fStrings)-1 do
    fTags [i]:= @fStrings [i];
  for i:= 0 to length (fTags)-2 do
    begin
      idx:= i;
      for j:= i+1 to length (fTags)-1 do
        if AnsiCompareText (fTags [j]^.tag,fTags [idx]^.tag)< 0 then
          idx:= j;
      if idx<> i then
        begin
          ps:= fTags [idx];
          fTags [idx]:= fTags [i];
          fTags [i]:= ps;
        end;
    end;
end;

var
  DefaultLanguage: TMyLanguage;

initialization
  DefaultLanguage:= TMyLanguage.Create;
  Language:= DefaultLanguage;

finalization
  if Language= DefaultLanguage then
    Language:= nil;
  DefaultLanguage.Free;
  DefaultLanguage:= nil;

end.


