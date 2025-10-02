unit CRC32;

interface

uses
  System.SysUtils, System.Classes;

const
  Crc32Init = $FFFFFFFF;

function Crc32Next (Crc32Current: LongWord; const Data; Count: LongWord): LongWord; register;
function Crc32Done (Crc32: LongWord): LongWord; register;
function Crc32Stream (Source: TStream; Count: Longint): LongWord;
function Crc32Buffer (Buffer: pointer; BufSize: integer): LongWord;

implementation

const
  Crc32Polynomial = $EDB88320;

Var
  CRC32Table: array [Byte] of Cardinal;

function Crc32Next (Crc32Current: LongWord; const Data; Count: LongWord): LongWord; register;
Asm //EAX - CRC32Current; EDX - Data; ECX - Count
  test  ecx, ecx
  jz    @@EXIT
  PUSH  ESI
  MOV   ESI, EDX  //file://Data
@@Loop:
    MOV EDX, EAX                       // copy CRC into EDX
    LODSB                              // load next byte into AL
    XOR EDX, EAX                       // put array index into DL
    SHR EAX, 8                         // shift CRC one byte right
    SHL EDX, 2                         // correct EDX (*4 - index in array)
    XOR EAX, DWORD PTR CRC32Table[EDX] // calculate next CRC value
  dec   ECX
  JNZ   @@Loop                         // LOOP @@Loop
  POP   ESI
@@EXIT:
End;     //Crc32Next

function  Crc32Done   (Crc32: LongWord): LongWord; register;
Asm
  NOT   EAX
End;//Crc32Done

function  Crc32Initialization: Pointer;
Asm
  push    EDI
  STD
  mov     edi, OFFSET CRC32Table+ ($400-4)  // Last DWORD of the array
  mov     edx, $FF  // array size

@im0:
  mov     eax, edx  // array index
  mov     ecx, 8
@im1:
  shr     eax, 1
  jnc     @Bit0
  xor     eax, Crc32Polynomial  // <����������> ����� - ���� ��� � ZIP,ARJ,RAR,:
@Bit0:
  dec     ECX
  jnz     @im1

  stosd
  dec     edx
  jns     @im0

  CLD
  pop     EDI
  mov     eax, OFFSET CRC32Table
End;

function Crc32Stream (Source: TStream; Count: Longint): LongWord;
var
  BufSize, N: Integer;
  Buffer: PChar;
Begin
  Result:=Crc32Init;
  if Count = 0 then begin
    Source.Position:= 0;
    Count:= Source.Size;
  end;

  BufSize:= $10000;
  GetMem(Buffer, BufSize);
  try
    while Count <> 0 do begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      Result:= Crc32Next(Result,Buffer^,N);
      Dec(Count, N);
    end;
  finally
    Result:=Crc32Done(Result);
    FreeMem(Buffer);
  end;
End;  //Crc32Stream

function Crc32Buffer (Buffer: pointer; BufSize: integer): LongWord;
begin
    Result:= Crc32Init;
    try
        if BufSize> 0 then
            Result:= Crc32Next (Result,Buffer^,BufSize);
    finally
        Result:= Crc32Done (Result);
    end;
end;

initialization
  Crc32Initialization;

end.

