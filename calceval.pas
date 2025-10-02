{$r-}
unit calceval;

interface

uses
  System.SysUtils,
  System.Math;

function Evaluate (s: string; var Value: Extended): boolean;

implementation

const
  Epsilon: Extended = 3.4e-4932;

function CountChars (const s: string; c: char): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 1 to Length (s) do
    if s [i]= c then
      inc (Result);
end;

function GetValue (s: string; var Value: Extended): boolean;

  function GetHex (S: String; var Value: Extended): boolean;
  var
    RR, RRR: Extended;
    j: byte;
    Invert: boolean;
    p: extended;
  begin
    GetHex:= false;
    if (Length (s)> 15) or (Length (s)< 1) then
      exit;
    if S[1] in ['-','+'] then
      begin
        Invert:=S[1]='-';
        Delete (s,1,1);
      end
    else
      Invert:=False;

    RR:=0;
    for j:=1 to Length (s) do
      Case S[j] of
        '0'..'9': RR:=RR*$10 + Ord(S[j])-48;
        'A'..'F': RR:=RR*$10 + Ord(S[j])-55;
        '.': break;
      else
        exit;
      end;
    Delete(S, 1, j);
    if (Length (s)<1) then
      begin
        GetHex:= true;
        If Invert then
          Value:= -RR
        else
          Value:= RR;
        exit;
      end;
    RRR:=RR;
    RR:=0;
    for j:=1 to Length (s) do
      Case S[j] of
        '0'..'9': RR:=RR*$10 + Ord(S[j])-48;
        'A'..'F': RR:=RR*$10 + Ord(S[j])-55;
      else
        exit;
      end;
    try
      p:= Power ($10,Length (s));
      If Invert then
        Value:=-(RRR + RR/p)
      else
        Value:=RRR + RR/p;
      GetHex:=True;
    except
    end;
  end;

  function GetOct(S: String; var Value: Extended): boolean;
  var
    RR, RRR: Extended;
    j: byte;
    Invert: boolean;
    p: extended;
  begin
    GetOct := false;
    if (Length (s)>21) or (Length (s)< 1) then
      exit;
    if S[1] in ['-','+'] then
      begin
        Invert:=S[1]='-';
        Delete (S,1,1);
      end
    else
      Invert:=False;

    RR:=0;
    for j:=1 to Length (s) do
      Case S[j] of
        '0'..'7': RR:=RR*8 + Ord(S[j])-48;
        '.': break;
      else
        exit;
      end;
    Delete(S, 1, j);
    if (Length (s)<1) then
      begin
        GetOct:=true;
        If Invert then
          Value:=-RR
        else
          Value:=RR;
        exit;
      end;
    RRR:=RR;
    RR:=0;
    for j:=1 to Length (s) do
      Case S[j] of
        '0'..'7': RR:=RR*8 + Ord(S[j])-48;
      else
        exit;
      end;
    try
      p:= Power (8,Length (s));
      If Invert then
        Value:=-(RRR + RR/p)
      else
        Value:=RRR + RR/p;
      GetOct:= True;
    except
    end;
  end;

  function GetBin(S: String; var Value: Extended): boolean;
  var
    RR, RRR: Extended;
    j: byte;
    Invert: boolean;
    p: extended;
  begin
    GetBin := false;
    if (Length (s)>64) or (Length (s)< 1) then
      exit;
    if S[1] in ['-','+'] then
      begin
        Invert:=S[1]='-';
        Delete (s,1,1);
      end
    else
      Invert:=False;

    RR:=0;
    for j:=1 to Length (s) do
      Case S[j] of
        '0': RR:=RR*2;
        '1': RR:=RR*2 + 1;
        '.': break;
      else
        exit;
      end;
    Delete(S, 1, j);
    if (Length (s)<1) then
      begin
        GetBin:=true;
        If Invert then
          Value:= -RR
        else
          Value:=RR;
        exit;
      end;
    RRR:=RR;
    RR:=0;
    for j:=1 to Length (s) do
      Case S[j] of
        '0': RR:=RR*2;
        '1': RR:=RR*2 + 1;
      else
        exit;
      end;
    try
      p:= Power (2,Length (s));
      If Invert then
        Value:= -(RRR + RR/p)
      else
        Value:=RRR + RR/p;
      GetBin:=True;
    except
    end;
  end;

  function GetDec(S: String; var Value: Extended): boolean;
  var
    R: Integer;
  begin
    Val(S, Value, R);
    GetDec:= (R=0);
  end;

begin
  if (S[Length(S)] = 'H') and (S[1] in ['0'..'9','A'..'F']) then
    begin
      SetLength (s,Length (s)-1);
      Result:=GetHex(S, Value);
    end
  else if S[1] = '$' then
    begin
      Delete (s,1,1);
      Result:=GetHex(S, Value);
    end
  else if (Length (s)> 2) and (S[1] = '0') and (S[2] = 'X') then
    begin
      Delete (s,1,2);
      Result:= GetHex(S, Value);
    end
  else if (S[Length(S)] in ['O','Q']) then
    begin
      SetLength (s,Length (s)-1);
      Result:=GetOct(S, Value);
    end
  else if (Length (s)> 2) and (S[1] = '0') and (S[2] in ['O','Q']) then
    begin
      Delete (s,1,2);
      Result:=GetOct(S, Value);
    end
  else if (S[Length(S)] = 'B') then
    begin
      SetLength (s,Length (s)-1);
      Result:=GetBin(S, Value);
    end
  else if (Length (s)> 2) and (S[1] = '0') and (S[2] = 'B') then
    begin
      Delete (s,1,2);
      Result:=GetBin(S, Value);
    end
  else
    Result:=GetDec(S, Value);
end;

function GetConst (s: string; var Value: Extended): boolean;
begin
  Result:= false;
  if s= 'PI' then
    begin
      Value:= Pi;
      Result:= true;
    end
  else if s= 'E' then
    begin
      Value:= Exp (1);
      Result:= true;
    end;
end;

function Factorial (Arg: extended; out Value: extended): boolean;
var
  i,n: integer;
begin
  Result:= false;
  if Arg<> Trunc (Arg) then
    exit;
  n:= Trunc (Arg);
  if n> 0 then
    Value:= 1
  else if n= 0 then
    Value:= 0
  else
    exit;
  try
    for i:= 1 to n do
     Value:= Value*i;
    Result:= true;
  except
  end;
end;

function GetFunc (s: string; var Value: Extended): boolean;
var
  fn,arg: string;
  p: integer;
  argval: extended;
begin
  Result:= false;

  s:= Trim (s);
  if s= '' then
    exit;
  p:= pos ('(',s);
  if (p= 0) or (p>= Length (s)) or (s [Length (s)]<> ')') then
    exit;
  fn:= Trim (copy (s,1,p-1));
  arg:= Trim (copy (s,p+1,Length (s)-p-1));
  if arg= '' then
    exit;
  if not Evaluate (arg,argval) then
    exit;
  if fn= 'SIN' then
    begin
      Value:= Sin (argval);
      Result:= true;
    end
  else if fn= 'COS' then
    begin
      Value:= Cos (argval);
      Result:= true;
    end
  else if fn= 'SQR' then
    begin
      Value:= Sqr (argval);
      Result:= true;
    end
  else if fn= 'SQRT' then
    begin
      if argval>= 0 then
        begin
          Value:= Sqrt (argval);
          Result:= true;
        end;
    end
  else if fn= 'ABS' then
    begin
      Value:= Abs (argval);
      Result:= true;
    end
  else if fn= 'FACT' then
    begin
      Result:= Factorial (argval,Value);
    end
  else if fn= 'LN' then
    begin
      try
        Value:= Ln (argval);
        Result:= true;
      except
        Result:= false;
      end;
    end
  else if fn= 'LOG' then
    begin
      try
        Value:= Log10 (argval);
        Result:= true;
      except
        Result:= false;
      end;
    end
  else if fn= 'ARCSIN' then
    begin
      try
        Value:= ArcSin (argval);
        Result:= true;
      except
        Result:= false;
      end;
    end
  else if fn= 'ARCCOS' then
    begin
      try
        Value:= ArcCos (argval);
        Result:= true;
      except
        Result:= false;
      end;
    end
  else if fn= 'ARCTAN' then
    begin
      try
	Value:= ArcTan (argval);
	Result:= true;
      except
        Result:= false;
      end;
    end;
end;

const
  Signs1: set of char= ['+','-'];
  Signs2: set of char= ['*','/','%'];
  Signs3: set of char= ['^'];
  Signs4: set of char= ['!'];

function Evaluate (s: string; var Value: Extended): boolean;
var
  leftbrackets,rightbrackets,bb: integer;
  i: integer;
  left,right: string;
  leftval,rightval: extended;
  leftempty,rightempty: boolean;

  procedure skipbrackets (var idx: integer);
  var
    bb,j: integer;
  begin
    bb:= 1;
    for j:= idx-1 downto 1 do
      begin
        case s [j] of
          ')': inc (bb);
          '(': begin
            dec (bb);
            if bb= 0 then
              begin
                idx:= j-1;
                break;
              end;
          end;
        end;
      end;
  end;

  function split (idx,l,r: integer): boolean;
  var
    bleft,bright: boolean;
  begin
    left:= Trim (copy (s,1,idx-l));
    leftempty:= left= '';
    right:= Trim (copy (s,idx+r,length (s)));
    rightempty:= right= '';
    bleft:= evaluate (left,leftval);
    bright:= evaluate (right,rightval);
    Result:= bleft and bright;
  end;

begin
  Result:= false;
  Value:= 0;
  s:= Trim (s);
  if s= '' then
    begin
      Result:= true;
      exit;
    end;
  s:= UpperCase (s);
  while (Length (s)> 0) and (s[1]= '+') do
    delete (s,1,1);

  // ����������� �� ������ ������� ������
  while (Length (s)>= 2) and (s [1]= '(') and (s [length (s)]= ')') do
    begin
      bb:= 1;
      for i:= 2 to Length (s) do
        case s [i] of
          '(': inc (bb);
          ')': begin
            dec (bb);
            if (bb= 0) and (i< Length (s)) then
              break;
          end;
        end;
      if i< Length (s) then
        break
      else
        s:= copy (s,2,length (s)-2);
    end;

  s:= Trim (s);
  if s= '' then
    exit;
  leftbrackets:= CountChars (s,'(');
  rightbrackets:= CountChars (s,')');
  if leftbrackets<> rightbrackets then
    exit;

  i:= length (s);
  while i>= 1 do
    begin
      // ���� ���������� �� ������, ���������� ���, ��� ������ �����
      if s [i]= ')' then
        skipbrackets (i);
      if s [i] in Signs1 then
        begin
          if not split (i,1,1) then
            exit;
          case s [i] of
            '+': begin
              if (rightempty) then
                exit;
              Value:= leftval+rightval;
            end;
            '-': begin
              if (rightempty) then
                exit;
              Value:= leftval-rightval;
            end;
          end;
          Result:= true;
          exit;
        end;
      dec (i);
    end;

  i:= length (s);
  while i>= 1 do
    begin
      // ���� ���������� �� ������, ���������� ���, ��� ������ �����
      if s [i]= ')' then
        skipbrackets (i);
      if s [i] in Signs2 then
        begin
          if not split (i,1,1) then
            exit;
          case s [i] of
            '*': begin
              if (leftempty) or (rightempty) then
                exit;
              Value:= leftval*rightval;
            end;
            '/': begin
              if (leftempty) or (rightempty) or (abs (rightval)< Epsilon) then
                exit
              else
                Value:= leftval/rightval;
            end;
            '%': begin
              if (leftempty) or (rightempty) or (abs (rightval)< Epsilon) then
                exit
              else
                Value:= Int (leftval/rightval);
            end;
          end;
          Result:= true;
          exit;
        end;
      dec (i);
    end;

  i:= length (s);
  while i>= 1 do
    begin
      // ���� ���������� �� ������, ���������� ���, ��� ������ �����
      if s [i]= ')' then
        skipbrackets (i);
      if s [i] in Signs3 then
        begin
          if not split (i,1,1) then
            exit;
          case s [i] of
            '^': begin
              try
                if (not rightempty) and (not leftempty) then
                  Value:= Power (leftval,rightval)
                else
                  exit;
              except
                exit;
              end;
            end;
          end;
          Result:= true;
          exit;
        end;
      dec (i);
    end;

  i:= length (s);
  while i>= 1 do
    begin
      // ���� ���������� �� ������, ���������� ���, ��� ������ �����
      if s [i]= ')' then
        skipbrackets (i);
      if s [i] in Signs4 then
        begin
          if not split (i,1,1) then
            exit;
          case s [i] of
            '!': begin
              if rightempty then
                begin
                  if not Factorial (leftval,Value) then
                    exit;
                end
              else
                exit;
            end;
          end;
          Result:= true;
          exit;
        end;
      dec (i);
    end;

  if GetConst (s,Value) then
    Result:= true
  else if GetFunc (s,Value) then
    Result:= true
  else
    Result:= GetValue (s,Value);
end;

end.

