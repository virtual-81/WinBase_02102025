unit form_printfinalnumbers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, CheckLst, PrinterSelector, Vcl.Printers,

  Data,
  MyLanguage,
  ctrl_language,
  Barcode,
  wb_barcodes,
  form_selectshooter,
  SysFont;

type
  TPrintFinalNumbersDialog = class(TForm)
    clbNumbers: TCheckListBox;
    btnOk: TButton;
    btnCancel: TButton;
    procedure clbNumbersKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    gbPrinter: TPrinterSelector;
    fEvent: TStartListEventItem;
    fShooters: array of TStartListEventShooterItem;
    function get_Shooter(index: integer): TStartListEventShooterItem;
    procedure UpdateLanguage;
    procedure UpdateFonts;
    function _Caption: string; virtual;
  public
    procedure SetEvent (AEvent: TStartListEventItem);
    function Execute: boolean;
    function ShootersCount: integer;
    property Shooters [index: integer]: TStartListEventShooterItem read get_Shooter;
  end;

  TPrintFinalCardsDialog= class (TPrintFinalNumbersDialog)
  private
    function _Caption: string; override;
  end;

  TFinalNumbersPrintOut= class
  private
    fEvent: TStartListEventItem;
    procedure PrintShooter (AShooter: TStartListEventShooterItem; ARank: integer);
    function get_Shooter(index: integer): TStartListEventShooterItem;
    procedure set_Shooter(index: integer; const Value: TStartListEventShooterItem);
  public
    fShooters: array of TStartListEventShooterItem;
    constructor Create (AEvent: TStartListEventItem);
    destructor Destroy; override;
    procedure Print;
    property Shooters [index: integer]: TStartListEventShooterItem read get_Shooter write set_Shooter;
  end;

  TFinalCardsPrintout= class
  private
    fEvent: TStartListEventItem;
    function get_Shooter(index: integer): TStartListEventShooterItem;
    procedure set_Shooter(index: integer; const Value: TStartListEventShooterItem);
  public
    fShooters: array of TStartListEventShooterItem;
    constructor Create (AEvent: TStartListEventItem);
    destructor Destroy; override;
    procedure Print;
    property Shooters [index: integer]: TStartListEventShooterItem read get_Shooter write set_Shooter;
  end;

implementation

uses System.Types;

{$R *.dfm}

procedure TPrintFinalNumbersDialog.clbNumbersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  sh: TStartListEventShooterItem;
  s: string;
begin
  case Key of
    VK_F4: begin
      Key:= 0;
      sh:= fShooters [clbNumbers.ItemIndex];
      sh:= SelectEventShooter (self,sh);
      fShooters [clbNumbers.ItemIndex]:= sh;
      s:= IntToStr (clbNumbers.ItemIndex+1)+'    '+#9;
      if fEvent.StartList.StartNumbers then
        s:= s+sh.StartNumberStr+'    '+#9;
  s:= s+sh.Shooter.SurnameAndNameAndStepName;
      clbNumbers.Items [clbNumbers.ItemIndex]:= s;
    end;
  end;
end;

function TPrintFinalNumbersDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TPrintFinalNumbersDialog.FormCreate(Sender: TObject);
begin
  gbPrinter:= TPrinterSelector.Create (self);
  gbPrinter.Name:= 'gbPrinter';
  gbPrinter.ShowCopies:= false;
  gbPrinter.ShowPages:= false;
  gbPrinter.Parent:= self;
  gbPrinter.TabOrder:= 0;
  gbPrinter.Left:= 16;
  gbPrinter.Top:= 16;
  Width:= Screen.Width div 2;
  clbNumbers.Left:= gbPrinter.Left;
  UpdateLanguage;
  UpdateFonts;
  Position:= poScreenCenter;
end;

procedure TPrintFinalNumbersDialog.FormResize(Sender: TObject);
begin
  btnCancel.Left:= ClientWidth-16-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-16-btnOk.Width;
  btnOk.Top:= ClientHeight-16-btnOk.Height;
  btnCancel.Top:= btnOk.Top;
  clbNumbers.Height:= btnOk.Top-8-clbNumbers.Top;
  clbNumbers.Width:= ClientWidth-clbNumbers.Left*2;
  gbPrinter.Width:= clbNumbers.Width;
end;

function TPrintFinalNumbersDialog.get_Shooter(index: integer): TStartListEventShooterItem;
begin
  if index< Length (fShooters) then
    Result:= fShooters [index]
  else
    Result:= nil;
end;

procedure TPrintFinalNumbersDialog.SetEvent(AEvent: TStartListEventItem);
var
  i: integer;
  sh: TStartListEventShooterItem;
  s: string;
  h: integer;
begin
  fEvent:= AEvent;
  Caption:= _Caption;
  SetLength (fShooters,fEvent.NumberOfFinalists);
  for i:= 0 to fEvent.NumberOfFinalists-1 do
    fShooters [i]:= fEvent.Shooters.Items [i];
  clbNumbers.Clear;
  for i:= 0 to fEvent.NumberOfFinalists-1 do
    begin
      sh:= fEvent.Shooters.Items [i];
      s:= IntToStr (i+1)+'    '+#9;
      if fEvent.StartList.StartNumbers then
        s:= s+sh.StartNumberStr+'    '+#9;
      s:= s+sh.Shooter.SurnameAndName;
      clbNumbers.Items.Add (s);
      clbNumbers.Checked [i]:= true;
    end;
  clbNumbers.ClientHeight:= clbNumbers.Canvas.TextHeight ('Mg')*clbNumbers.Count;
  h:= gbPrinter.Top+gbPrinter.Height+8+clbNumbers.Height+8+btnOk.Height+16;
  if h< ClientHeight then
    ClientHeight:= h;
  Position:= poScreenCenter;
end;

function TPrintFinalNumbersDialog.ShootersCount: integer;
begin
  Result:= Length (fShooters);
end;

procedure TPrintFinalNumbersDialog.UpdateFonts;
var
  bh: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnCancel.ClientWidth:= Canvas.TextWidth (btnCancel.Caption)+32;
  btnCancel.ClientHeight:= bh;
  btnOk.ClientWidth:= btnCancel.Width;
  btnOk.ClientHeight:= bh;
  gbPrinter.Font:= Font;
  clbNumbers.Font:= Font;
  clbNumbers.Canvas.Font:= Font;
  clbNumbers.Top:= gbPrinter.Top+gbPrinter.Height+8;
  Height:= Screen.Height div 2;
end;

procedure TPrintFinalNumbersDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

function TPrintFinalNumbersDialog._Caption: string;
begin
  Result:= format (Language ['PrintFinalNumbersDialog'],[fEvent.Event.ShortName]);
end;

{ TFinalNumbersPrintOut }

constructor TFinalNumbersPrintOut.Create(AEvent: TStartListEventItem);
begin
  inherited Create;
  fEvent:= AEvent;
  SetLength (fShooters,0);
end;

destructor TFinalNumbersPrintOut.Destroy;
begin
  SetLength (fShooters,0);
  fShooters:= nil;
  inherited;
end;

function TFinalNumbersPrintOut.get_Shooter(index: integer): TStartListEventShooterItem;
begin
  if index< Length (fShooters) then
    Result:= fShooters [index]
  else
    Result:= nil;
end;

procedure TFinalNumbersPrintOut.Print;
var
  i,n: integer;
begin
  n:= 0;
  for i:= 0 to Length (fShooters)-1 do
    if fShooters [i]<> nil then
      inc (n);
  if n= 0 then
    exit;
  Printer.Orientation:= poLandscape;
  Printer.Title:= FINAL_NUMBERS_PRINT_TITLE;
  Printer.Copies:= 1;
  Printer.BeginDoc;
  n:= 0;
  for i:= 0 to Length (fShooters)-1 do
    begin
      if fShooters [i]<> nil then
        begin
          if n> 0 then
            Printer.NewPage;
          PrintShooter (fShooters [i],i+1);
          inc (n);
        end;
    end;
  Printer.EndDoc;
end;

procedure TFinalNumbersPrintOut.PrintShooter (AShooter: TStartListEventShooterItem; ARank: integer);
var
  lpx,lpy: integer;
  top_border,left_border,right_border,bottom_border: integer;

  function mm2px (mm: single): integer;
  begin
    Result:= round (mm*lpy/25.4);
  end;

  function mm2py (mm: integer): integer;
  begin
    Result:= round (mm*lpx/25.4);
  end;

var
  st: string;
  w,i: integer;
  x,y,cy: integer;
  ny_top,ny_bottom,nx_left: integer;
  LogFont: TLogFont;
  s: TStrings;
begin
  lpx:= GetDeviceCaps (Printer.Handle,LOGPIXELSX);
  lpy:= GetDeviceCaps (Printer.Handle,LOGPIXELSY);

  top_border:= mm2py (10);
  bottom_border:= Printer.PageHeight - mm2py (10);
  left_border:= mm2px (10);
  right_border:= Printer.PageWidth - mm2px (10);

  With Printer.Canvas do
    begin
      Pen.Color:= clBlack;
      Pen.Width:= 1;
      Brush.Style:= bsClear;
      Rectangle (left_border,top_border,right_border,bottom_border);
      // ������ �����
      Font.Name:= 'Times New Roman';
      // ���������
      Font.Size:= 32;
      Font.Style:= [];
      st:= RUSSIAN_SHOOTING_UNION;
      w:= TextWidth (st);
      x:= (right_border+left_border-w) div 2;
      y:= top_border+mm2py (5);
      TextOut (x,y,st);
      y:= y+TextHeight ('Mg')+mm2py (5);

      // ��������
      s:= TStringList.Create;
      s.Text:= AShooter.StartEvent.StartList.Info.TitleText;

      // ��������� ������ ������
      Font.Style:= [fsBold];
      Font.Size:= 40;
      for i:= 0 to s.Count-1 do
        begin
          st:= s [i];
          repeat
            w:= TextWidth (st);
            if w<= right_border-left_border-mm2px (10) then
              break;
            Font.Size:= Font.Size-1;
          until false;
        end;
      for i:= 0 to s.Count-1 do
        begin
          st:= s [i];
          w:= TextWidth (st);
          x:= (right_border+left_border-w) div 2;
          TextOut (x,y,st);
          inc (y,TextHeight ('Mg'));
        end;
      if s.Count> 0 then
        inc (y,mm2py (5));
      s.Free;
      MoveTo (left_border,y);
      LineTo (right_border,y);
      ny_top:= y;

      // "�����"
      Font.Size:= 48;
      Font.Name:= 'Arial';
      Font.Style:= [fsBold];
      Font.Color:= clGray;
      GetObject (Font.Handle,SizeOf(LogFont),@LogFont);
      LogFont.lfEscapement:= 900;
      LogFont.lfOrientation:= 900;
      Font.Handle:= CreateFontIndirect (LogFont);
      st:= FINAL_NUMBER_CAPTION;
      w:= TextWidth (st);
      y:= (ny_top+bottom_border+w) div 2;
      x:= left_border+1;
      TextOut (x,y,st);
      nx_left:= left_border+TextHeight (st);
      LogFont.lfEscapement:= 0;
      LogFont.lfOrientation:= 0;
      Font.Handle:= CreateFontIndirect (LogFont);

      // �����
      Font.Color:= clBlack;
      Font.Name:= 'Times New Roman';
      Font.Style:= [fsBold];
      Font.Height:= (bottom_border-ny_top)*3 div 5;
      st:= IntToStr ({AShooter.Index+1}ARank);
      w:= TextWidth (st);
      y:= (bottom_border+ny_top-TextHeight ('Mg')) div 2;
      TextOut (nx_left+mm2px (5),y,st);
      nx_left:= nx_left+w+mm2px (10);
      MoveTo (nx_left,ny_top);
      LineTo (nx_left,bottom_border);

      // ������
      Font.Style:= [fsBold];
      Font.Size:= 64;
      st:= AShooter.Shooter.RegionAbbr1;
      TextOut (nx_left+mm2px (15),bottom_border-TextHeight ('Mg')-mm2py (5),st);
      ny_bottom:= bottom_border-TextHeight ('Mg')-mm2py (10);
      // ����
{      if TruncatePrintedClubs then
        st:= substr (AShooter.Shooter.Society,' ',1)
      else
        st:= AShooter.Shooter.Society;}
      st:= AShooter.Shooter.SocietyName;
      w:= TextWidth (st);
      TextOut (right_border-w-mm2px (15),bottom_border-TextHeight ('Mg')-mm2py (5),st);

      // �������, ���
      cy:= (ny_bottom+ny_top) div 2;
      MoveTo (nx_left,ny_bottom);
      LineTo (right_border,ny_bottom);
      st:= AShooter.Shooter.Surname;
      Font.Size:= 64;
      repeat
        w:= TextWidth (st);
        if w<= right_border-nx_left-mm2px (20) then
          break;
        Font.Height:= abs (Font.Height)-1;
      until false;
      x:= (nx_left+right_border-w) div 2;
      y:= cy-mm2py (5)-TextHeight ('Mg');
      TextOut (x,y,st);
      st:= AShooter.Shooter.Name;
      Font.Size:= 64;
      Font.Style:= [];
      repeat
        w:= TextWidth (st);
        if w<= right_border-nx_left-mm2px (20) then
          break;
        Font.Height:= abs (Font.Height)-1;
      until false;
      x:= (nx_left+right_border-w) div 2;
      y:= cy+mm2py (5);
      TextOut (x,y,st);
    end;
end;

procedure TFinalNumbersPrintOut.set_Shooter(index: integer;
  const Value: TStartListEventShooterItem);
var
  l,i: integer;
begin
  l:= Length (fShooters);
  if index>= l then
    begin
      SetLength (fShooters,index+1);
      for i:= l to index-1 do
        fShooters [i]:= nil;
    end;
  fShooters [index]:= Value;
end;

{ TPrintFinalCardsDialog }

function TPrintFinalCardsDialog._Caption: string;
begin
  Result:= format (Language ['PrintFinalCardsDialog'],[fEvent.Event.ShortName]);
end;

{ TFinalCardsPrintout }

constructor TFinalCardsPrintout.Create(AEvent: TStartListEventItem);
begin
  inherited Create;
  fEvent:= AEvent;
  SetLength (fShooters,0);
end;

destructor TFinalCardsPrintout.Destroy;
begin
  SetLength (fShooters,0);
  fShooters:= nil;
  inherited;
end;

function TFinalCardsPrintout.get_Shooter(index: integer): TStartListEventShooterItem;
begin
  if index< Length (fShooters) then
    Result:= fShooters [index]
  else
    Result:= nil;
end;

procedure TFinalCardsPrintout.Print;
var
  last_height: integer;
  y: integer;
  X_BRD: integer;

  function MM2PixelX (Hdl: THandle; mm: double): integer;
  var
    indx: integer;
  begin
    indx:= GetDeviceCaps (Hdl,LOGPIXELSX);
    Result:= round (mm*indx/25.4);
  end;

  function MM2PixelY (Hdl: THandle; mm: double): integer;
  var
    indx: integer;
  begin
    indx:= GetDeviceCaps (Hdl,LOGPIXELSY);
    Result:= round (mm*indx/25.4);
  end;

  procedure PrintShooterCard (sh: TStartListEventShooterItem);

    procedure PrintRegularTables;
    var
      n: integer;
      xx: array of integer;
      i,x,h: integer;
      st: string;
    begin
      n:= fEvent.Event.FinalShots;
      SetLength (xx,n+2);
      xx [n+1]:= Printer.PageWidth-X_BRD;
      xx [n]:= xx [n+1]-MM2PixelX (Printer.Handle,25);
      for i:= 0 to n-1 do
        xx [i]:= X_BRD+round ((xx [n]-X_BRD)*i/n);
      with Printer.Canvas do
        begin
          Font.Size:= 8;
          Font.Style:= [];
          st:= '��������� �����:';
          TextOut (X_BRD,y,st);
          inc (y,TextHeight (st));
          Font.Size:= 6;
          for i:= 0 to n-1 do
            begin
              st:= IntToStr (i+1);
              x:= (xx [i]+xx [i+1]-TextWidth (st)) div 2;
              TextOut (x,y,st);
            end;
          st:= '�����';
          x:= (xx [n]+xx [n+1]-TextWidth (st)) div 2;
          TextOut (x,y,st);
          inc (y,TextHeight ('Mg'));
          Pen.Width:= 1;
          MoveTo (xx [0],y);
          LineTo (xx [n+1],y);
          h:= MM2PixelY (Printer.Handle,10);
          MoveTo (xx [0],y+h);
          LineTo (xx [n+1],y+h);
          for i:= 0 to n-1 do
            begin
              MoveTo (xx [i],y);
              LineTo (xx [i],y+h);
            end;
          for i:= n to n+1 do
            begin
              MoveTo (xx [i],y);
              LineTo (xx [i],y+h+h);
            end;
          MoveTo (xx [n],y+h+h);
          LineTo (xx [n+1],y+h+h);
          Font.Size:= 10;
          st:= '����� � �������:';
          x:= xx [n]-MM2PixelX (Printer.Handle,1)-TextWidth (st);
          TextOut (x,y+h+(h-TextHeight (st)) div 2,st);
          inc (y,h+h+MM2PixelY (Printer.Handle,2));
          // �����������
          Font.Size:= 8;
          Font.Style:= [];
          st:= '�����������:';
          TextOut (X_BRD,y,st);
          inc (y,TextHeight (st));
          MoveTo (xx [0],y);
          LineTo (xx [n+1],y);
          MoveTo (xx [0],y+h);
          LineTo (xx [n+1],y+h);
          for i:= 0 to n+1 do
            begin
              MoveTo (xx [i],y);
              LineTo (xx [i],y+h);
            end;
          inc (y,h);
        end;
      SetLength (xx,0);
      xx:= nil;
    end;

    procedure PrintRapidFireTables;
    var
      cn,rn: integer;
      xx: array of integer;
      i,x,h,y1: integer;
      st: string;
    begin
      // ���������� ����� �� 5 ���������
      cn:= 5;
      SetLength (xx,cn+2);
      rn:= fEvent.Event.FinalShots div 5+byte ((fEvent.Event.FinalShots mod 5)<> 0);
      with Printer.Canvas do
        begin
          Font.Size:= 8;
          Font.Style:= [];
          xx [cn+1]:= Printer.PageWidth-X_BRD;
          xx [0]:= X_BRD+TextWidth ('����� 00:');
          for i:= 1 to cn do
            xx [i]:= xx [0]+round ((xx [cn+1]-xx [0])*i/(cn+1));
          h:= MM2PixelY (Printer.Handle,10);
          st:= '��������� �����:';
          TextOut (X_BRD,y,st);
          inc (y,TextHeight ('Mg'));
          Font.Size:= 6;
          st:= '�����';
          x:= (xx [cn]+xx [cn+1]-TextWidth (st)) div 2;
          TextOut (x,y,st);
          for i:= 0 to cn-1 do
            begin
              st:= IntToStr (i+1);
              x:= (xx [i]+xx [i+1]-TextWidth (st)) div 2;
              TextOut (x,y,st);
            end;
          inc (y,TextHeight ('Mg'));
          for i:= 0 to rn-1 do
            begin
              st:= '����� '+IntToStr (i+1)+':';
              y1:= y+h*i+(h-TextHeight (st)) div 2;
              TextOut (X_BRD,y1,st);
            end;
          Pen.Width:= 1;
          for i:= 0 to rn do
            begin
              MoveTo (xx [0],y+i*h);
              LineTo (xx [6],y+i*h);
            end;
          for i:= rn+1 to rn+2 do
            begin
              MoveTo (xx [5],y+i*h);
              LineTo (xx [6],y+i*h);
            end;
          for i:= 0 to cn-1 do
            begin
              MoveTo (xx [i],y);
              LineTo (xx [i],y+h*rn);
            end;
          Pen.Width:= MM2PixelX (Printer.Handle,0.3);
          for i:= cn to cn+1 do
            begin
              MoveTo (xx [i],y);
              LineTo (xx [i],y+h*(rn+2));
            end;
          Pen.Width:= 1;
          Font.Size:= 10;
          Font.Style:= [];
          st:= '�����:';
          x:= xx [5]-MM2PixelX (Printer.Handle,2)-TextWidth (st);
          TextOut (x,y+h*rn+(h-TextHeight (st)) div 2,st);
          st:= '��������� � �������:';
          x:= xx [5]-MM2PixelX (Printer.Handle,2)-TextWidth (st);
          TextOut (x,y+h*(rn+1)+(h-TextHeight (st)) div 2,st);
          inc (y,h*(rn+2)+MM2PixelX (Printer.Handle,2));
          // �����������
          st:= '�����������:';
          TextOut (X_BRD,y,st);
          inc (y,TextHeight (st));

          rn:= 2;
          Font.Size:= 6;
          st:= '�����';
          x:= (xx [cn]+xx [cn+1]-TextWidth (st)) div 2;
          TextOut (x,y,st);
          for i:= 0 to cn-1 do
            begin
              st:= IntToStr (i+1);
              x:= (xx [i]+xx [i+1]-TextWidth (st)) div 2;
              TextOut (x,y,st);
            end;
          inc (y,TextHeight ('Mg'));
          for i:= 0 to rn-1 do
            begin
              st:= '����� '+IntToStr (i+1)+':';
              y1:= y+h*i+(h-TextHeight (st)) div 2;
              TextOut (X_BRD,y1,st);
            end;
          Pen.Width:= 1;
          for i:= 0 to rn do
            begin
              MoveTo (xx [0],y+i*h);
              LineTo (xx [6],y+i*h);
            end;
          for i:= 0 to cn-1 do
            begin
              MoveTo (xx [i],y);
              LineTo (xx [i],y+h*rn);
            end;
          Pen.Width:= MM2PixelX (Printer.Handle,0.3);
          for i:= cn to cn+1 do
            begin
              MoveTo (xx [i],y);
              LineTo (xx [i],y+h*rn);
            end;
          inc (y,h*rn);
        end;
      SetLength (xx,0);
      xx:= nil;
    end;

  var
    x,y1,by: integer;
    s: TStrings;
    st,st1,st2: string;
    i: integer;
    h: integer;
    tm: TTextMetric;
    bc: TAsBarcode;
    bcst: string;
    rct: TRect;
    w,w1: integer;
  begin
    y:= y+MM2PixelY (Printer.Handle,10);
    with Printer.Canvas do
      begin
        Pen.Width:= 1;
        Pen.Color:= clBlack;
        Pen.Style:= psSolid;
        Brush.Style:= bsClear;
        Font.Name:= 'Arial';
        Font.Size:= 10;
        Font.Style:= [];

        // ���������
        s:= TStringList.Create;
        s.Text:= fEvent.Info.TitleText;
        for i:= 0 to s.Count-1 do
          begin
            st:= s [i];
            x:= (Printer.PageWidth-TextWidth (st)) div 2;
            TextOut (x,y,st);
            inc (y,TextHeight (st));
          end;
        s.Free;
        inc (y,MM2PixelY (Printer.Handle,2));
        // �����
        Font.Size:= 14;
        Font.Style:= [fsBold];
        st:= '�����';
        x:= (Printer.PageWidth-TextWidth (st)) div 2;
        TextOut (x,y,st);
        inc (y,TextHeight (st));
        // ���������� � ����
        Font.Size:= 12;
        Font.Style:= [];
        st:= DateToStr (fEvent.FinalTime);
        x:= Printer.PageWidth-X_BRD-TextWidth (st);
        TextOut (x,y,st);
        x:= X_BRD;
        Font.Style:= [fsBold];
        st:= fEvent.Event.ShortName;
        TextOut (x,y,st);
        GetTextMetrics (Printer.Canvas.Handle,tm);
        by:= y+tm.tmAscent;
        h:= TextHeight (st);
        inc (x,TextWidth (st)+MM2PixelX (Printer.Handle,3));
        Font.Size:= 8;
        Font.Style:= [];
        GetTextMetrics (Printer.Canvas.Handle,tm);
        st:= fEvent.Event.Name;
        if fEvent.Event.Name<> '' then
          TextOut (x,by-tm.tmAscent,st);
        inc (y,h+MM2PixelY (Printer.Handle,2));
        // ���������� �����
        Font.Size:= 38;
        Font.Style:= [fsBold];
        st:= IntToStr (sh.Index+1);
        h:= TextHeight (st);
        x:= Printer.PageWidth-X_BRD-TextWidth (st);
        TextOut (x,y,st);
        GetTextMetrics (Printer.Canvas.Handle,tm);
        by:= y+tm.tmAscent;
        Font.Size:= 10;
        Font.Style:= [];
        st:= '���������� �����: ';
        GetTextMetrics (Printer.Canvas.Handle,tm);
        y1:= by-tm.tmAscent;
        x:= x-TextWidth (st);
        TextOut (x,y1,st);
        // ��������� �����
        x:= X_BRD;
        if fEvent.StartList.StartNumbers then
          begin
            Font.Size:= 38;
            Font.Style:= [fsBold];
            st:= sh.StartNumberStr;
            TextOut (x,y,st);
            inc (x,TextWidth (st)+MM2PixelX (Printer.Handle,3));
          end;
        // ������ �������
        y1:= y;
        Font.Size:= 18;
        Font.Style:= [];
        st:= sh.Shooter.SurnameAndName;
        TextOut (x,y1,st);
        inc (y1,TextHeight (st));
  st:= sh.Shooter.BirthFullStr;
        if sh.Shooter.QualificationName<> '' then
          begin
            if st<> '' then
              st:= st+', ';
            st:= st+sh.Shooter.QualificationName;
          end;
        if sh.Shooter.Town<> '' then
          st:= st+', '+sh.Shooter.Town;
        Font.Size:= 10;
        TextOut (x,y1,st);
        inc (y1,TextHeight (st));
        st:= sh.Shooter.SocietyName;
        if sh.Shooter.RegionAbbr1<> '' then
          begin
            if st<> '' then
              st:= st+', ';
            st:= st+sh.Shooter.RegionAbbr1;
          end;
        TextOut (x,y1,st);
        y:= y+h+MM2PixelY (Printer.Handle,2);
        // ��������� ������������
        Font.Size:= 18;
        Font.Style:= [fsBold];
        GetTextMetrics (Printer.Canvas.Handle,tm);
        by:= y+tm.tmAscent;
        Font.Size:= 10;
        Font.Style:= [];
        x:= X_BRD;
        GetTextMetrics (Printer.Canvas.Handle,tm);
        st:= '��������� ������������: ';
        TextOut (x,by-tm.tmAscent,st);
        x:= x+TextWidth (st);
        st:= sh.CompetitionStr;
        Font.Size:= 18;
        Font.Style:= [fsBold];
        TextOut (x,y,st);
        h:= TextHeight (st);
        // barcode
        // FC:1,1,007,1,586
        bcst:= BARCODE_START_CHAR+'FC:'+IntToStr (sh.Event.Index)+','+
          IntToStr (sh.StartEvent.ProtocolNumber)+','+sh.StartNumberStr+','+
          IntToStr (sh.Index)+','+sh.CompetitionStr;
        bc:= TAsBarcode.Create (nil);
        bc.Typ:= bcCode128A;
        bc.Top:= y;
        bc.Height:= h;
        bc.Modul:= MM2PixelX (Printer.Handle,0.254);
        bc.Text:= bcst;
        bc.Left:= Printer.PageWidth-X_BRD-bc.Width;
        bc.DrawBarcode (Printer.Canvas);
        bc.Free;
        y:= y+h+MM2PixelY (Printer.Handle,2);
        // �������
        case fEvent.Event.EventType of
          etRegular,etMovingTarget,etThreePosition2013,etMovingTarget2013: PrintRegularTables;
          etRapidFire,etCenterFire,etCenterFire2013: PrintRapidFireTables;
        end;

        // ������� �����
        inc (y,MM2PixelY (Printer.Handle,2));
        Brush.Style:= bsSolid;
        Brush.Color:= RGB (224,224,224);
        rct.Top:= y;
        rct.Bottom:= y+MM2PixelY (Printer.Handle,3+10+3);
        rct.Left:= X_BRD;
        rct.Right:= Printer.PageWidth-X_BRD;
        FillRect (rct);
        Pen.Width:= MM2PixelX (Printer.Handle,0.2);
        Font.Size:= 10;
        Font.Style:= [];
        st:= '������� �����:';
        w:= TextWidth (st)+MM2PixelX (Printer.Handle,2+20);
        x:= (Printer.PageWidth-w) div 2;
        rct.Left:= x+TextWidth (st)+MM2PixelX (Printer.Handle,2);
        rct.Right:= rct.Left+MM2PixelX (Printer.Handle,20);
        rct.Top:= rct.Top+MM2PixelY (Printer.Handle,3);
        rct.Bottom:= rct.Top+MM2PixelY (Printer.Handle,10);
        Brush.Color:= clWhite;
        Rectangle (rct);
        Brush.Style:= bsClear;
        TextOut (x,(rct.Top+rct.Bottom-TextHeight (st)) div 2,st);
        y:= y+MM2PixelY (Printer.Handle,3+10+3);

        // �������
        Pen.Width:= 1;
        Font.Size:= 10;
        Font.Style:= [];
        st:= '������� ����� ���';
        st1:= '����� ���';
        st2:= '�������� ������';
        y:= y+MM2PixelY (Printer.Handle,10)-TextHeight (st);
        w:= TextWidth (st)+TextWidth (st1)+TextWidth (st2);
        w1:= (Printer.PageWidth-X_BRD*2-w) div 3-MM2PixelX (Printer.Handle,3);
        x:= X_BRD;
        TextOut (x,y,st);
        y1:= y+TextHeight (st);
        inc (x,TextWidth (st));
        MoveTo (x,y1);
        LineTo (x+w1,y1);
        inc (x,w1+MM2PixelX (Printer.Handle,3));
        TextOut (x,y,st1);
        inc (x,TextWidth (st1));
        MoveTo (x,y1);
        LineTo (x+w1,y1);
        inc (x,w1+MM2PixelX (Printer.Handle,3));
        TextOut (x,y,st2);
        inc (x,TextWidth (st2));
        MoveTo (x,y1);
        LineTo (Printer.PageWidth-X_BRD,y1);
        y:= y1;
      end;
  end;

var
  i,n: integer;
begin
  if fEvent.NumberOfFinalists= 0 then
    exit;
  // ���������, ���� �� ���������� ��� ������
  n:= 0;
  for i:= 0 to Length (fShooters)-1 do
    if fShooters [i]<> nil then
      inc (n);
  if n= 0 then
    exit;
  Printer.Copies:= 1;
  Printer.Orientation:= poPortrait;
  Printer.Title:= '��������� �������� - '+fEvent.Event.ShortName;
  Printer.BeginDoc;
  n:= 0;
  last_height:= 0;
  X_BRD:= MM2PixelX (Printer.Handle,10);
  y:= 0;
  for i:= 0 to Length (fShooters)-1 do
    begin
      if fShooters [i]= nil then
        continue;
      if n> 0 then
        begin
          if y+MM2PixelY (Printer.Handle,10)+last_height>= Printer.PageHeight then
            begin
              Printer.NewPage;
              y:= 0;
            end
          else
            begin
              with Printer.Canvas do
                begin
                  inc (y,MM2PixelY (Printer.Handle,10));
                  Pen.Style:= psDash;
                  MoveTo (MM2PixelX (Printer.Handle,2),y);
                  LineTo (Printer.PageWidth-MM2PixelX (Printer.Handle,2),y);
                end;
            end;
        end;
      inc (n);
      PrintShooterCard (fShooters [i]);
      if n= 1 then
        last_height:= y;
    end;
  Printer.EndDoc;
end;

procedure TFinalCardsPrintout.set_Shooter(index: integer; const Value: TStartListEventShooterItem);
var
  l,i: integer;
begin
  l:= Length (fShooters);
  if index>= l then
    begin
      SetLength (fShooters,index+1);
      for i:= l to index-1 do
        fShooters [i]:= nil;
    end;
  fShooters [index]:= Value;
end;

end.

