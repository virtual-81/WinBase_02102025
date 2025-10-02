unit MyStrings;

interface

uses
	System.Classes,
  System.StrUtils,
  System.SysUtils;

function SubStrCount (stt: string; sc: string): integer;
function SubStr (stt: string; sc: string; num: integer): string;

function HexToByte (const Hex: string): byte;
function ByteToHex (b: byte): string;
function HexToWord (const Hex: string): word;
function WordToHex (w: word): string;
function HexToInt64 (const Hex: string): Int64;
function ByteToBin (b: byte): string;

//type
	//tcharset= set of AnsiChar;

function FillStr (stt: string; len: integer; c: char= #32): string;
function LeftFillStr (stt: string; len: integer; c: char= #32): string;
//function FilterStr (stt: String; chars: tcharset): String;
function FilterStr (stt: string; chars: string): string;

//function DOSToAnsi (const s: String): String;

function EscapesToChars (s: string): string;
function CharsToEscapes (s: string): string;

function CheckNumberInStr (s: string; n: integer): boolean;

function StrToCSV (const s: string): string;

function ReadStringFromStreamA (Stream: TStream): string;
procedure WriteStringToStreamA (Stream: TStream; const S: string);

implementation

function ByteToBin (b: byte): string;
var
  i: integer;
begin
  Result:= '';
  for i:= 0 to 7 do
    if b and ($80 shr i)<> 0 then
      Result:= Result+'1'
    else
      Result:= Result+'0';
end;

function StrToCSV (const s: string): string;
var
  i: integer;
  quote: boolean;
begin
  Result:= '';
  if s= '' then
    exit;
  quote:= false;
  if pos (',',s)<> 0 then
    quote:= true
  else if pos ('"',s)<> 0 then
    quote:= true
  else if pos (' ',s)<> 0 then
    quote:= true
  else if pos (':',s)<> 0 then
    quote:= true;
  if quote then
    Result:= '"';
  for i:= 1 to Length (s) do
    if s [i]= '"' then
      Result:= Result+'""'
    else
      Result:= Result+s [i];
  if quote then
    Result:= Result+'"';
end;

function substrcount;
var
  c,p: integer;
begin
  c:= 1;
  repeat
    p:= pos (sc,stt);
    if p= 0 then
      break;
    delete (stt,1,p-1+length (sc));
    inc (c);
  until false;
  substrcount:= c;
end;

function substr;
var
  j,p: integer;
begin
  for j:= 1 to num-1 do
    begin
      p:= pos (sc,stt);
      if p> 0 then
        delete (stt,1,p-1+length(sc))
      else
        begin
          stt:= '';
          break;
        end;
    end;
  p:= pos (sc,stt);
  if p> 0 then
    dec (p)
  else
    p:= Length (stt);
  substr:= copy (stt,1,p);
end;

function HexToByte (const Hex: string): byte;
var
	i: integer;
	b: byte;
begin
	Val ('$'+Hex,b,i);
	HexToByte:= b;
end;

const
	hexchars: array [0..15] of char= '0123456789ABCDEF';

function ByteToHex (b: byte): string;
begin
	Result:= hexchars [(b and $f0) shr 4]+hexchars [b and $0f];
end;

function WordToHex (w: word): string;
begin
  Result:= ByteToHex (hi (w))+ByteToHex (lo (w));
end;

function HexToWord (const Hex: string): word;
var
	i: integer;
	w: word;
begin
	Val ('$'+Hex,w,i);
	Result:= w;
end;

function HexToInt64 (const Hex: string): Int64;
var
  i64: Int64;
  i: integer;
begin
  Val ('$'+Hex,i64,i);
  Result:= i64;
end;

function FillStr (stt: string; len: integer; c: char= #32): string;
begin
  Result:= stt;
  while Length (Result)< len do
    Result:= Result+c;
end;

function LeftFillStr (stt: string; len: integer; c: char= #32): string;
begin
	Result:= stt;
	if Length (Result)> len then
		Result:= RightStr (Result,len)
	else
		begin
			while Length (Result)< len do
				Result:= c+Result;
		end;
end;

{function FilterStr (stt: String; chars: tcharset): String;
var
	j: byte;
begin
	j:= 1;
	Result:= stt;
	while j<= Length (Result) do
		if Result [j] in chars then
			delete (Result,j,1)
		else
			inc (j);
end;}


function FilterStr (stt: string; chars: string): string;
var
  j: integer;
begin
  j:= 1;
  Result:= stt;
  while j<= Length (Result) do
    begin
      if pos (Result[j],chars)> 0 then
        delete (Result,j,1)
      else
        inc (j);
    end;
end;

{function DOSToWinChar (ch: AnsiChar): AnsiChar;
begin
  case ch of
    #128..#175: result:= AnsiChar (byte (ch)+64);
    #224..#239: result:= AnsiChar (byte (ch)+16);
    #176..#223: result:= ' '; // ���������     char (byte (ch)-48);
    #240..#255: result:= AnsiChar (byte (ch)-32);
  else
    result:= ch;
  end;
end;}

{function win2ascchar;
begin
  case ch of
    #192..#239: win2ascchar:= char (byte (ch)-64);
    #240..#255: win2ascchar:= char (byte (ch)-16);
    #128..#175: win2ascchar:= char (byte (ch)+48);
    #176..#191: win2ascchar:= char (byte (ch)+32);
  else
    win2ascchar:= ch;
  end;
end;

function stasc2win (stt: string): string;
var
  j: byte;
  l: byte absolute stt;
begin
  for j:= 1 to l do
    stt [j]:= asc2winchar (stt [j]);
  stasc2win:= stt;
end;

function stwin2asc (stt: string): string;
var
  j: byte;
  l: byte absolute stt;
begin
  for j:= 1 to l do
    stt [j]:= win2ascchar (stt [j]);
  stwin2asc:= stt;
end;}


{function DOSToAnsi (const s: String): String;
var
  i: integer;
begin
  Result:= '';
  for i:= 1 to Length (s) do
    Result:= Result+DOSToWinChar (s [i]);
end;}

function EscapesToChars (s: string): string;
begin
  Result:= '';
  while s<> '' do
    begin
      if copy (s,1,2)= '\a' then
        begin
          Result:= Result+#7;
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\b' then
        begin
          Result:= Result+#8;
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\f' then
        begin
          Result:= Result+#12;
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\n' then
        begin
          Result:= Result+#10;
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\r' then
        begin
          Result:= Result+#13;
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\t' then
        begin
          Result:= Result+#9;
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\v' then
        begin
          Result:= Result+#11;
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\\' then
        begin
          Result:= Result+'\+';
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\''' then
        begin
          Result:= Result+'''';
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\"' then
        begin
          Result:= Result+'"';
          delete (s,1,2);
        end
      else if copy (s,1,2)= '\?' then
        begin
          Result:= Result+'?';
          delete (s,1,2);
        end
      else
        begin
          Result:= Result+s [1];
          Delete (s,1,1);
        end;
    end;
end;

function CharsToEscapes (s: string): string;
begin
  Result:= '';
  while s<> '' do
    begin
      case s [1] of
        #7: Result:= Result+'\a';
        #8: Result:= Result+'\b';
        #9: Result:= Result+'\t';
        #10: Result:= Result+'\n';
        #11: Result:= Result+'\v';
        #12: Result:= Result+'\f';
        #13: Result:= Result+'\r';
        '\': Result:= Result+'\\';
        '''': Result:= Result+'\''';
        '?': Result:= Result+'\?';
      else
        Result:= Result+s [1];
      end;
      delete (s,1,1);
      if s [1]= #10 then
        begin
          Result:= Result+'\n';
          delete (s,1,1);
        end
      else if s [1]= #7 then
        begin
          Result:= Result+'\a';
          delete (s,1,1);
        end
      else if s [1]= #8 then
        begin
          Result:= Result+'\b';
          delete (s,1,1);
        end
      else
        begin
          Result:= Result+s [1];
          delete (s,1,1);
        end;
    end;
end;

function CheckNumberInStr (s: string; n: integer): boolean;

  function CheckSeg (a: string): boolean;
  var
    p: integer;
    n1,n2,c: integer;
    t1,t2: string;
  begin
    Result:= false;
    a:= Trim (a);
    if a= '' then
      exit;
    p:= pos ('-',a);
    if p<> 0 then
      begin
        // ��������
        t1:= copy (a,1,p-1);
        t2:= copy (a,p+1,Length (a)-p);
        val (t1,n1,c);
        if c<> 0 then
          exit;
        val (t2,n2,c);
        if c<> 0 then
          exit;
        if (n1<= n) and (n<= n2) then
          Result:= true;
      end
    else
      begin
        // �����
        val (a,n1,c);
        if c= 0 then
          begin
            if n1= n then
              Result:= true;
          end;
      end;
  end;

var
  p: integer;
begin
  Result:= false;
  s:= Trim (s);
  while s<> '' do
    begin
      p:= pos (',',s);
      if p<> 0 then
        begin
          if CheckSeg (copy (s,1,p-1)) then
            begin
              Result:= true;
              break;
            end;
          delete (s,1,p);
        end
      else
        begin
          // ��������� �������� ��� �����
          Result:= CheckSeg (s);
          break;
        end;
    end;
end;


function ReadStringFromStreamA (Stream: TStream): string;
var
  l: integer;
  bs: RawByteString;
begin
  Stream.Read (l,sizeof (l));
  SetLength (bs,l);
  Stream.Read (bs[1],l);
  Result:= string(bs);
end;


procedure WriteStringToStreamA (Stream: TStream; const S: string);
var
  l: integer;
  bs: RawByteString;
begin
  bs:= RawByteString(S);
  l:= Length (bs);
  Stream.Write (l,sizeof (l));
  Stream.Write (bs[1],l);
end;

end.


