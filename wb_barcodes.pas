unit wb_barcodes;

interface

uses
  Winapi.Windows,Winapi.Messages,System.Classes,Data,System.SysUtils,Vcl.Forms,
  MyStrings;

const
  WM_BC_SHOOTERCARD= WM_BARCODEBASE+0;

type
  PWBC_ShooterCard= ^TWBC_ShooterCard;
  TWBC_ShooterCard= record
    EventIndex: integer;
    ProtocolNumber: integer;
    StartNumber: integer;
    Relay: integer;
    Lane: integer;
  end;

  TWBaseBarcodes= class
  private
    fKBLayout: HKL;
    fStr: String;
    fTick: DWORD;
    fHandles: array of TComponent;
    fProcessing: boolean;
    procedure ProceedBarcode;
    procedure ProceedShooterCardBarcode (const code: String);
  public
    constructor Create;
    destructor Destroy; override;
    function ProceedKeyDown (var Key: word): boolean;
    procedure RegisterWindow (wnd: TComponent);
    procedure ReleaseWindow (wnd: TComponent);
    property KBLayout: HKL read fKBLayout;
  end;

const
  BARCODE_KEY_TIMEOUT: DWORD= 5000;
  BARCODE_START_CHAR: CHAR= #28;

var
  WBC: TWBaseBarcodes;

implementation

{ TWBaseBarcodes }

constructor TWBaseBarcodes.Create;
begin
  inherited;
  fTick:= GetTickCount;
  fStr:= '';
  SetLength (fHandles,0);
  {
    Ищем уже установленную в системе US?раскладку (LANGID = $0409) среди текущих,
    чтобы не добавлять/не выгружать раскладки и не влиять на языковую панель.
  }
  var count: UINT;
  var dummyHKL: HKL;
  count := GetKeyboardLayoutList(0, dummyHKL);
  if count > 0 then
  begin
    var layouts: array of HKL;
    SetLength(layouts, count);
  if GetKeyboardLayoutList(count, layouts[0]) = count then
    begin
      fKBLayout := 0;
      for var i := 0 to count - 1 do
      begin
        if (LOWORD(NativeUInt(layouts[i])) = $0409) then
        begin
          fKBLayout := layouts[i];
          break;
        end;
      end;
      if fKBLayout = 0 then
      begin
        // Тихо подгружаем US раскладку только для процесса (без информирования оболочки)
        fKBLayout := LoadKeyboardLayout('00000409', KLF_NOTELLSHELL or KLF_SUBSTITUTE_OK);
        if fKBLayout = 0 then
          fKBLayout := GetKeyboardLayout(0);
      end;
    end
    else
      fKBLayout := GetKeyboardLayout(0);
  end
  else
    fKBLayout := GetKeyboardLayout(0);
  fProcessing:= false;
end;

destructor TWBaseBarcodes.Destroy;
begin
  // Никаких операций с раскладками: ничего не выгружаем.
  SetLength (fHandles,0);
  fHandles:= nil;
  inherited;
end;

procedure TWBaseBarcodes.ProceedBarcode;
var
  cmd,param: String;
  p: integer;
begin
  OutputDebugStringA (PAnsiChar(AnsiString('CMD: '+fStr)));
  fStr:= Trim (fStr);
  if fStr= '' then
    exit;
  p:= pos (':',fStr);
  if p= 0 then
    exit;
  cmd:= AnsiUpperCase (copy (fStr,1,p));
  param:= fStr;
  Delete (param,1,p);
  fStr:= '';
  if cmd= 'SC:' then
    begin
      // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
      ProceedShooterCardBarcode (param);
    end;
end;

function TWBaseBarcodes.ProceedKeyDown(var Key: word): boolean;
var
  t: DWORD;
  ks: TKeyboardState;
  lpChar: String;
  n: integer;
begin
  Result:= false;
  case Key of
    VK_F11: begin       // пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ-пїЅпїЅпїЅпїЅ
      fProcessing:= true;
      fStr:= BARCODE_START_CHAR;
      Result:= true;
      fTick:= GetTickCount;
    end;
    VK_RETURN: begin
      if (fProcessing) and (fStr<> '') then
        begin
          t:= GetTickCount;
          if t-fTick< BARCODE_KEY_TIMEOUT then
            begin
              Result:= true;
              ProceedBarcode;
              fStr:= '';
              fProcessing:= false;
            end
          else
            begin
              fStr:= '';
              fProcessing:= false;
            end;
        end;
    end;
  else
    if fProcessing then
      begin
        GetKeyboardState (ks);
        SetLength (lpChar,8);
        n:= ToAsciiEx (Key,0,ks,pchar (lpChar),0,fKBLayout);
        if n= 1 then
          begin
            case lpChar [1] of
              #32..#95: begin
                t:= GetTickCount;
                if t-fTick< BARCODE_KEY_TIMEOUT then
                  begin
                    fTick:= t;
                    fStr:= fStr+lpChar [1];
                    Result:= true;
                  end
                else
                  begin
                    fStr:= '';
                    fProcessing:= false;
                  end;
              end;
            end;
          end;
      end;
  end;
end;

procedure TWBaseBarcodes.ProceedShooterCardBarcode(const code: String);
var
  sc: TWBC_ShooterCard;
  i: integer;
  s: String;
  wnd: TComponent;
  M: TMessage;
begin
  s:= substr (code,',',1); // event index
  val (s,sc.EventIndex,i);
  if i<> 0 then
    exit;
  s:= substr (code,',',2); // protocol number
  val (s,sc.ProtocolNumber,i);
  if i<> 0 then
    exit;
  s:= substr (code,',',3); // start number
  if s<> '' then
    begin
      val (s,sc.StartNumber,i);
      if i<> 0 then
        exit;
    end
  else
    sc.StartNumber:= 0;
  s:= substr (code,',',4);  // relay
  val (s,sc.Relay,i);
  if i<> 0 then
    exit;
  s:= substr (code,',',5);
  val (s,sc.Lane,i);
  if i<> 0 then
    exit;
  if Length (fHandles)> 0 then
    begin
      wnd:= fHandles [Length (fHandles)-1];
      M.Msg:= WM_BC_SHOOTERCARD;
      M.WParam:= 0;
      M.LParam:= LPARAM (@sc);
      wnd.Dispatch (M);
    end;
end;

procedure TWBaseBarcodes.RegisterWindow (wnd: TComponent);
var
  idx: integer;
begin
  idx:= Length (fHandles);
  SetLength (fHandles,idx+1);
  fHandles [idx]:= wnd;
end;

procedure TWBaseBarcodes.ReleaseWindow (wnd: TComponent);
var
  i,idx: integer;
begin
  idx:= -1;
  for i:= Length (fHandles)-1 downto 0 do
    if fHandles [i]= wnd then
      begin
        idx:= i;
        break;
      end;
  if idx< 0 then
    exit;
  for i:= idx to Length (fHandles)-2 do
    fHandles [i]:= fHandles [i+1];
  SetLength (fHandles,Length (fHandles)-1);
end;

initialization
  WBC:= TWBaseBarcodes.Create;

finalization
  WBC.Free;
  WBC:= nil;

end.


