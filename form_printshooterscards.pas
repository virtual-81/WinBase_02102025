unit form_printshooterscards;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, CheckLst, Vcl.Printers,

  Data,
  ctrl_language,
  Barcode,
  wb_barcodes,
  PrinterSelector, SysFont;

type
  TPrintShootersCardsDialog = class(TForm)
    clbShooters: TCheckListBox;
    btnOk: TButton;
    btnCancel: TButton;
    cbAnonymous: TCheckBox;
    btnSelectAll: TButton;
    btnDeselectAll: TButton;
    cbEventTitle: TCheckBox;
    procedure clbShootersClick(Sender: TObject);
    procedure clbShootersKeyPress(Sender: TObject; var Key: Char);
    procedure btnDeselectAllClick(Sender: TObject);
    procedure btnSelectAllClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    gbPrinter: TPrinterSelector;
    fEvent: TStartListEventItem;
    fSearchStr: string;
    procedure UpdateLanguage;
    procedure UpdateFonts;
    function DoSearch (const s: string; searchfrom: integer): integer;
  public
    { Public declarations }
    procedure SetEvent (AEvent: TStartListEventItem);
    function Execute: boolean;
  end;

  TShootersCardsPrintout= class
  private
    fEvent: TStartListEventItem;
  public
    Checked: array of boolean;
    Anonimous: boolean;
    PrintEventTitle: boolean;
    constructor Create (AEvent: TStartListEventItem);
    destructor Destroy; override;
    procedure Print;
  end;

implementation

{$R *.dfm}

procedure TPrintShootersCardsDialog.btnDeselectAllClick(Sender: TObject);
var
  i: integer;
begin
  for i:= 0 to clbShooters.Count-1 do
    clbShooters.Checked [i]:= false;
end;

procedure TPrintShootersCardsDialog.btnSelectAllClick(Sender: TObject);
var
  i: integer;
begin
  for i:= 0 to clbShooters.Count-1 do
    clbShooters.Checked [i]:= true;
end;

procedure TPrintShootersCardsDialog.clbShootersClick(Sender: TObject);
begin
  fSearchStr:= '';
end;

procedure TPrintShootersCardsDialog.clbShootersKeyPress(Sender: TObject; var Key: Char);
var
  idx: integer;
begin
  case Key of
    #8: begin
      Key:= #0;
      if fSearchStr<> '' then
        begin
          fSearchStr:= copy (fSearchStr,1,Length (fSearchStr)-1);
          idx:= DoSearch (fSearchStr,0);
          clbShooters.ItemIndex:= idx;
        end;
    end
  else
    if fSearchStr= '' then
      idx:= 0
    else
      idx:= clbShooters.ItemIndex;
    idx:= DoSearch (fSearchStr+Key,idx);
    if idx>= 0 then
      begin
        clbShooters.ItemIndex:= idx;
        fSearchStr:= fSearchStr+Key;
      end;
    Key:= #0;
  end;
end;

function TPrintShootersCardsDialog.DoSearch(const s: string; searchfrom: integer): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= -1;
  for i:= searchfrom to clbShooters.Count-1 do
    begin
      sh:= fEvent.Shooters.Items [i];
      if AnsiSameText (copy (sh.Shooter.SurnameAndName,1,Length (s)),s) then
        begin
          Result:= i;
          break;
        end;
    end;
end;

function TPrintShootersCardsDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TPrintShootersCardsDialog.FormCreate(Sender: TObject);
begin
  gbPrinter:= TPrinterSelector.Create (self);
  gbPrinter.Name:= 'gbPrinter';
  gbPrinter.ShowCopies:= false;
  gbPrinter.ShowPages:= false;
  gbPrinter.Parent:= self;
  gbPrinter.TabOrder:= 0;
  gbPrinter.Left:= 16;
  gbPrinter.Top:= 16;
  btnSelectAll.Left:= gbPrinter.Left;
  Width:= Screen.Width div 2;
  Height:= Screen.Height * 2 div 3;
  cbAnonymous.Left:= gbPrinter.Left;
  cbEventTitle.Left:= gbPrinter.Left;
  clbShooters.Left:= gbPrinter.Left;
  UpdateLanguage;
  UpdateFonts;
  Position:= poScreenCenter;
end;

procedure TPrintShootersCardsDialog.FormResize(Sender: TObject);
begin
  btnCancel.Left:= ClientWidth-16-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-16-btnOk.Width;
  btnOk.Top:= ClientHeight-16-btnOk.Height;
  btnCancel.Top:= btnOk.Top;
  btnSelectAll.Top:= btnOk.Top;
  btnDeselectAll.Top:= btnSelectAll.Top;
  clbShooters.Height:= btnOk.Top-8-clbShooters.Top;
  clbShooters.Width:= ClientWidth-clbShooters.Left*2;
  cbAnonymous.Width:= clbShooters.Width;
  cbEventTitle.Width:= clbShooters.Width;
  gbPrinter.Width:= clbShooters.Width;
end;

procedure TPrintShootersCardsDialog.SetEvent(AEvent: TStartListEventItem);
var
  i: integer;
  s: string;
  sh: TStartListEventShooterItem;
begin
  fEvent:= AEvent;
  cbAnonymous.Checked:= false;
  clbShooters.Clear;
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      sh:= fEvent.Shooters.Items [i];
      if fEvent.StartList.StartNumbers then
        s:= sh.StartNumberStr+'    '+#9
      else
        s:= '';
  s:= s+sh.Shooter.SurnameAndNameAndStepName;
      clbShooters.Items.Add (s);
      clbShooters.Checked [i]:= true;
    end;
  fSearchStr:= '';
end;

procedure TPrintShootersCardsDialog.UpdateFonts;
var
  bh: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  cbAnonymous.ClientHeight:= Canvas.TextHeight ('Mg');
  cbEventTitle.ClientHeight:= Canvas.TextHeight ('Mg');
  bh:= Canvas.TextHeight ('Mg')+12;
  btnCancel.ClientWidth:= Canvas.TextWidth (btnCancel.Caption)+32;
  btnCancel.ClientHeight:= bh;
  btnOk.ClientWidth:= btnCancel.Width;
  btnOk.ClientHeight:= bh;
  btnSelectAll.ClientHeight:= bh;
  btnDeselectAll.ClientHeight:= bh;
  btnSelectAll.ClientWidth:= Canvas.TextWidth (btnSelectAll.Caption)+32;
  btnDeselectAll.ClientWidth:= Canvas.TextWidth (btnDeselectAll.Caption)+32;
  btnDeselectAll.Left:= btnSelectAll.Left+btnSelectAll.Width+16;
  gbPrinter.Font:= Font;
  cbAnonymous.Top:= gbPrinter.Top+gbPrinter.Height+8;
  cbEventTitle.Top:= cbAnonymous.Top+cbAnonymous.Height+8;
  clbShooters.Top:= cbEventTitle.Top+cbEventTitle.Height+8;
end;

procedure TPrintShootersCardsDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

{ TShootersCardsPrintout }

constructor TShootersCardsPrintout.Create(AEvent: TStartListEventItem);
var
  i: integer;
begin
  inherited Create;
  fEvent:= AEvent;
  SetLength (Checked,fEvent.Shooters.Count);
  for i:= 0 to Length (Checked)-1 do
    Checked [i]:= true;
  Anonimous:= false;
  PrintEventTitle:= false;
end;

destructor TShootersCardsPrintout.Destroy;
begin
  SetLength (Checked,0);
  Checked:= nil;
  inherited;
end;

procedure TShootersCardsPrintout.Print;
var
  sh: TStartListEventShooterItem;
  X_BRD,y,Y_PADDING: integer;

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

  procedure PrintRegularTable;
  var
    j: integer;
    byy,y1: integer;
    st: string;
    xx: array of integer;
    x: integer;
  begin
    with Printer.Canvas do
      begin
        y:= y+MM2PixelY (Printer.Handle,2);
        Brush.Style:= bsClear;
        Font.Style:= [];
        Font.Size:= 6;
        if fEvent.Event.Stages> 1 then
          begin
            SetLength (xx,fEvent.Event.SeriesPerStage+2);
            xx [0]:= X_BRD+MM2PixelX (Printer.Handle,10);
            for j:= 1 to fEvent.Event.SeriesPerStage+1 do
              xx [j]:= xx [0]+round (j/(fEvent.Event.SeriesPerStage+1)*(Printer.PageWidth-X_BRD-xx [0]));
            for j:= 0 to fEvent.Event.SeriesPerStage-1 do
              begin
                st:= IntToStr (j+1);
                x:= (xx [j]+xx [j+1]-TextWidth (st)) div 2;
                TextOut (x,y,st);
              end;
            st:= '�����';
            x:= (xx [fEvent.Event.SeriesPerStage]+xx [fEvent.Event.SeriesPerStage+1]-TextWidth (st)) div 2;
            TextOut (x,y,st);
            inc (y,TextHeight ('Mg'));
            for j:= 0 to fEvent.Event.Stages do
              begin
                y1:= y+j*MM2PixelY (Printer.Handle,10);
                MoveTo (xx [0],y1);
                LineTo (Printer.PageWidth-X_BRD,y1);
                if j< fEvent.Event.Stages then
                  begin
                    st:= IntToStr (j+1);
                    y1:= y1+(MM2PixelY (Printer.Handle,10)-TextHeight (st)) div 2;
                    TextOut ((X_BRD+xx [0]-TextWidth (st)) div 2,y1,st);
                  end;
              end;
            byy:= y+MM2PixelY (Printer.Handle,10)*fEvent.Event.Stages;
            Pen.Width:= 1;
            for j:= 0 to fEvent.Event.SeriesPerStage-1 do
              begin
                MoveTo (xx [j],y);
                LineTo (xx [j],byy);
              end;
            Pen.Width:= MM2PixelX (Printer.Handle,0.3);
            for j:= fEvent.Event.SeriesPerStage to fEvent.Event.SeriesPerStage+1 do
              begin
                MoveTo (xx [j],y);
                LineTo (xx [j],byy);
              end;
            Pen.Width:= 1;
            Brush.Style:= bsSolid;
          end
        else
          begin
            SetLength (xx,fEvent.Event.SeriesPerStage+1);
            xx [0]:= X_BRD;
            xx [fEvent.Event.SeriesPerStage]:= Printer.PageWidth-X_BRD;
            for j:= 1 to fEvent.Event.SeriesPerStage-1 do
              xx [j]:= xx [0]+round (j/fEvent.Event.SeriesPerStage*(xx [fEvent.Event.SeriesPerStage]-xx [0]));
            for j:= 0 to fEvent.Event.SeriesPerStage-1 do
              begin
                st:= IntToStr (j+1);
                x:= (xx [j]+xx [j+1]-TextWidth (st)) div 2;
                TextOut (x,y,st);
              end;
            inc (y,TextHeight ('Mg'));
            Pen.Width:= 1;
            byy:= y+MM2PixelY (Printer.Handle,10);
            for j:= 0 to fEvent.Event.SeriesPerStage do
              begin
                MoveTo (xx [j],y);
                LineTo (xx [j],byy);
              end;
            MoveTo (X_BRD,y);
            LineTo (Printer.PageWidth-X_BRD,y);
            MoveTo (X_BRD,byy);
            LineTo (Printer.PageWidth-X_BRD,byy);
          end;
        y:= byy;
        SetLength (xx,0);
        xx:= nil;
      end;
  end;

  procedure PrintRapidFireTable;
  var
    i,j: integer;
    xx: array of integer;
    st: string;
    x,yy,y1: integer;
    h1,h2: integer;
    p: integer;
    tm: TTextMetricA;
    by: integer;
  begin
    with Printer.Canvas do
      begin
        y:= y+MM2PixelY (Printer.Handle,2);
        Brush.Style:= bsClear;
        Font.Style:= [];

        for j:= 0 to fEvent.Event.Stages-1 do
          begin
            Font.Size:= 8;
            case j of
              0: begin
                st:= '������ ��������';
                p:= sh.Position;
              end;
              1: begin
                st:= '������ ��������';
                p:= sh.Position2;
              end;
            else
              st:= '';
              p:= 0;
            end;
            Font.Size:= 14;
            Font.Style:= [];
            GetTextMetricsA (Printer.Canvas.Handle,tm);
            by:= y+tm.tmAscent;
            Font.Size:= 10;
            GetTextMetricsA (Printer.Canvas.Handle,tm);
            x:= X_BRD;
            TextOut (x,by-tm.tmAscent,st);
            x:= x+TextWidth (st)+MM2PixelX (Printer.Handle,10);
            st:= '�����: ';
            TextOut (x,by-tm.tmAscent,st);
            x:= x+TextWidth (st);
            Font.Size:= 14;
            Font.Style:= [fsBold];
            st:= IntToStr (sh.Relay.Index+1);
            TextOut (x,y,st);
            x:= x+TextWidth (st)+MM2PixelX (Printer.Handle,10);
            Font.Size:= 10;
            Font.Style:= [];
            st:= '���������: ';
            TextOut (x,by-tm.tmAscent,st);
            x:= x+TextWidth (st);
            Font.Size:= 14;
            Font.Style:= [fsBold];
            st:= IntToStr (p);
            TextOut (x,y,st);
            y:= y+TextHeight (st);
            Font.Style:= [];
            Font.Size:= 6;
            SetLength (xx,9);
            xx [0]:= X_BRD+TextWidth ('00 ���');
            xx [8]:= Printer.PageWidth-X_BRD;
            for i:= 1 to Length (xx)-2 do
              xx [i]:= xx [0]+round ((xx [Length (xx)-1]-xx [0])*i/(Length (xx)-1));
            for i:= 0 to 4 do
              begin
                st:= IntToStr (i+1);
                x:= (xx [i]+xx [i+1]-TextWidth (st)) div 2;
                TextOut (x,y,st);
              end;
            y:= y+TextHeight ('0');
            h1:= MM2PixelY (Printer.Handle,5);
            h2:= h1+h1;
            for i:= 0 to fEvent.Event.SeriesPerStage-1 do
              begin
                Pen.Style:= psDot;
                MoveTo (xx [0],y+h2*i+h1);
                LineTo (xx [6],y+h2*i+h1);
                Pen.Style:= psSolid;
                if i= fEvent.Event.SeriesPerStage-1 then
                  x:= xx [8]
                else
                  x:= xx [7];
                MoveTo (xx [0],y+h2*i);
                LineTo (x,y+h2*i);
                case i of
                  0: st:= '8 ���';
                  1: st:= '6 ���';
                  2: st:= '4 ���';
                else
                  st:= '�'+IntToStr (i+1);
                end;
                x:= X_BRD;
                y1:= y+h2*i+(h2-TextHeight (st)) div 2;
                TextOut (x,y1,st);
              end;
            i:= fEvent.Event.SeriesPerStage-1;
            MoveTo (xx [0],y+h2*i+h2);
            LineTo (xx [8],y+h2*i+h2);
            yy:= y+h2*i+h2;
            for i:= 0 to 4 do
              begin
                MoveTo (xx [i],y);
                LineTo (xx [i],yy);
              end;
            Pen.Width:= MM2PixelX (Printer.Handle,0.3);
            for i:= 5 to 7 do
              begin
                MoveTo (xx [i],y);
                LineTo (xx [i],yy);
              end;
            MoveTo (xx [8],yy-h2);
            LineTo (xx [8],yy);
            Pen.Width:= 1;
            y:= yy+MM2PixelY (Printer.Handle,2);
          end;
        SetLength (xx,0);
        xx:= nil;
      end;
  end;

  procedure PrintCenterFireTable;
  var
    xx: array of integer;
    i: integer;
    x,yy,y1: integer;
    st: string;
    h1,h2: integer;
  begin
    with Printer.Canvas do
      begin
        y:= y+MM2PixelY (Printer.Handle,2);
        Brush.Style:= bsClear;
        Font.Style:= [];

        if fEvent.Event.Stages> 1 then
          begin
            // ��� ��������, ��� ���������� ��� �������� ����������
            // ������ ���� ���������� ������ �������� �� ������, � ������ �� ������
            SetLength (xx,fEvent.Event.SeriesPerStage+2);
            xx [0]:= X_BRD;
            xx [fEvent.Event.SeriesPerStage+1]:= Printer.PageWidth-X_BRD;
            for i:= 1 to fEvent.Event.SeriesPerStage do
              xx [i]:= xx [0]+round ((xx [Length (xx)-1]-xx [0])*i/(Length (xx)-1));
            Font.Size:= 6;
            for i:= 0 to fEvent.Event.SeriesPerStage-1 do
              begin
                st:= IntToStr (i+1);
                x:= (xx [i]+xx [i+1]-TextWidth (st)) div 2;
                TextOut (x,y,st);
              end;
            st:= '�����';
            x:= (xx [fEvent.Event.SeriesPerStage]+xx [fEvent.Event.SeriesPerStage+1]-TextWidth (st)) div 2;
            TextOut (x,y,st);
            inc (y,TextHeight (st));
            Pen.Width:= 1;
            MoveTo (xx [0],y);
            LineTo (xx [fEvent.Event.SeriesPerStage+1],y);
            yy:= y+MM2PixelY (Printer.Handle,9);
            MoveTo (xx [0],yy);
            LineTo (xx [fEvent.Event.SeriesPerStage+1],yy);
            for i:= 0 to fEvent.Event.SeriesPerStage+1 do
              begin
                if i= fEvent.Event.SeriesPerStage then
                  Pen.Width:= MM2PixelX (Printer.Handle,0.3);
                MoveTo (xx [i],y);
                LineTo (xx [i],yy);
              end;
            Pen.Width:= 1;
            y:= yy+MM2PixelY (Printer.Handle,2);
            SetLength (xx,0);
            xx:= nil;
          end;
        // �������� ������ �������� ����������
        Font.Size:= 6;
        SetLength (xx,9);
        xx [0]:= X_BRD+TextWidth ('����� 000');
        xx [8]:= Printer.PageWidth-X_BRD;
        for i:= 1 to Length (xx)-2 do
          xx [i]:= xx [0]+round ((xx [Length (xx)-1]-xx [0])*i/(Length (xx)-1));
        for i:= 0 to 4 do
          begin
            st:= IntToStr (i+1);
            x:= (xx [i]+xx [i+1]-TextWidth (st)) div 2;
            TextOut (x,y,st);
          end;
        y:= y+TextHeight ('0');
        h1:= MM2PixelY (Printer.Handle,5);
        h2:= h1+h1;
        for i:= 0 to fEvent.Event.SeriesPerStage-1 do
          begin
            Pen.Style:= psDot;
            MoveTo (xx [0],y+h2*i+h1);
            LineTo (xx [6],y+h2*i+h1);
            Pen.Style:= psSolid;
            if i= fEvent.Event.SeriesPerStage-1 then
              x:= xx [8]
            else
              x:= xx [7];
            MoveTo (xx [0],y+h2*i);
            LineTo (x,y+h2*i);
            st:= '����� '+IntToStr (i+1);
            x:= X_BRD;
            y1:= y+h2*i+(h2-TextHeight (st)) div 2;
            TextOut (x,y1,st);
          end;
        i:= fEvent.Event.SeriesPerStage-1;
        MoveTo (xx [0],y+h2*i+h2);
        LineTo (xx [8],y+h2*i+h2);
        yy:= y+h2*i+h2;
        for i:= 0 to 4 do
          begin
            MoveTo (xx [i],y);
            LineTo (xx [i],yy);
          end;
        Pen.Width:= MM2PixelX (Printer.Handle,0.3);
        for i:= 5 to 7 do
          begin
            MoveTo (xx [i],y);
            LineTo (xx [i],yy);
          end;
        MoveTo (xx [8],yy-h2);
        LineTo (xx [8],yy);
        Pen.Width:= 1;
        y:= yy+MM2PixelY (Printer.Handle,2);
        SetLength (xx,0);
        xx:= nil;
      end;
  end;

var
  i,j: integer;
  ty,x,h1,by,w1,y1: integer;
  _title: TStrings;
  st,st1,st2: string;
  TM: TTextMetric;
  bcy,bcy1: integer;
  bcst: string;
  bc: TAsBarcode;
  x1: integer;
  last_height: integer;
  rct: TRect;
begin
  if fEvent.Shooters.Count= 0 then
    exit;
  // ���������, ���� �� ���������� ��� ������ �������
  x1:= 0;
  for i:= 0 to Length (Checked)-1 do
    if Checked [i] then
      inc (x1);
  if x1= 0 then
    exit;
  Printer.Copies:= 1;
  Printer.Orientation:= poPortrait;
  Printer.Title:= '������� �������� - '+fEvent.Event.ShortName;
  Printer.BeginDoc;
  X_BRD:= MM2PixelX (Printer.Handle,10);
  Y_PADDING:= MM2PixelY (Printer.Handle,5);
  y:= Y_PADDING;
  last_height:= 0;
  _title:= TStringList.Create;
  _title.Text:= fEvent.Info.TitleText;
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      if not Checked [i] then
        continue;
      if y+last_height> Printer.PageHeight-MM2PixelY (Printer.Handle,2) then
        begin
          Printer.NewPage;
          y:= Y_PADDING;
          last_height:= 0;
        end;
      ty:= y;
      sh:= fEvent.Shooters.Items [i];
      with Printer.Canvas do
        begin
          if last_height> 0 then
            begin
              Pen.Style:= psDash;
              MoveTo (MM2PixelX (Printer.Handle,2),y);
              LineTo (Printer.PageWidth-MM2PixelX (Printer.Handle,2),y);
              Pen.Style:= psSolid;
              y:= y+Y_PADDING;
            end;
          Font.Name:= 'Arial';
          if (PrintEventTitle) and (_title.Count> 0) then
            begin
              Font.Size:= 8;
              Font.Style:= [];
              for j:= 0 to _title.Count-1 do
                begin
                  st:= _title [j];
                  x:= X_BRD;
                  TextOut (x,y,st);
                  inc (y,TextHeight (st));
                end;
            end;
          Font.Size:= 14;
          Font.Style:= [fsBold];
          h1:= TextHeight ('Mg');
          GetTextMetrics (Handle,TM);
          by:= y+TM.tmAscent;
          x:= X_BRD;
          TextOut (x,y,fEvent.Event.ShortName);
          case fEvent.Event.EventType of
            etRegular,etCenterFire,etMovingTarget,etCenterFire2013,etThreePosition2013,etMovingTarget2013: begin
              x:= x+TextWidth (fEvent.Event.ShortName)+MM2PixelX (Printer.Handle,10);
              Font.Style:= [];
              Font.Size:= 10;
              GetTextMetrics (Handle,TM);
              st:= '�����: ';
              TextOut (x,by-TM.tmAscent,st);
              inc (x,TextWidth (st));
              Font.Size:= 14;
              Font.Style:= [fsBold];
              st:= IntToStr (sh.Relay.Index+1);
              TextOut (x,y,st);
              x:= x+TextWidth (st)+MM2PixelX (Printer.Handle,10);
              Font.Style:= [];
              Font.Size:= 10;
              st:= '���: ';
              TextOut (x,by-TM.tmAscent,st);
              inc (x,TextWidth (st));
              Font.Size:= 14;
              Font.Style:= [fsBold];
              st:= IntToStr (sh.Position);
              TextOut (x,y,st);
            end;
            etRapidFire: begin
            end;
          end;

          // date
          Font.Size:= 12;
          Font.Style:= [];
          GetTextMetrics (Handle,TM);
          st:= DateToStr (sh.Relay.StartTime);
          x:= Printer.PageWidth-X_BRD-TextWidth (st);
          TextOut (x,by-TM.tmAscent,st);
          inc (y,h1);

          bcy:= y;

          x1:= X_BRD;
          bcy1:= y;
          if fEvent.StartList.StartNumbers then
            begin
              Font.Style:= [fsBold];
              if Anonimous then
                Font.Height:= 26
              else
                Font.Size:= 32;
              st:= sh.StartNumberStr;
              TextOut (x1,y,st);
              inc (x1,TextWidth (st)+MM2PixelX (Printer.Handle,10));
              bcy1:= y+TextHeight (st);
            end;

          if not Anonimous then
            begin
              Font.Style:= [fsBold];
              Font.Size:= 12;
              st:= sh.Shooter.SurnameAndName;
              TextOut (x1,y,st);
              inc (y,TextHeight (st));
              Font.Size:= 10;
              Font.Style:= [];
              st:= sh.Shooter.BirthFullStr;
              if sh.Shooter.QualificationName<> '' then
                st:= st+', '+sh.Shooter.QualificationName;
              if sh.Shooter.Town<> '' then
                st:= st+', '+sh.Shooter.Town;
              TextOut (x1,y,st);
              inc (y,TextHeight ('Mg'));
              st:= sh.Shooter.SocietyName;
              if sh.Shooter.RegionAbbr1<> '' then
                begin
                  if st<> '' then
                    st:= st+', ';
                  st:= st+sh.Shooter.RegionAbbr1;
                end;
              TextOut (x1,y,st);
              inc (y,TextHeight ('Mg'));
              bcy1:= y;
            end;

          // barcode
          // SC:1,1,007,2,3
          bcst:= BARCODE_START_CHAR+'SC:'+IntToStr (sh.Event.Index)+','+
            IntToStr (sh.StartEvent.ProtocolNumber)+','+sh.StartNumberStr+','+
            IntToStr (sh.Relay.Index)+','+IntToStr (sh.Position);
          bc:= TAsBarcode.Create (nil);
          bc.Typ:= bcCode128A;
          bc.Top:= bcy;
          bc.Height:= MM2PixelX (Printer.Handle,8);// bcy1-bcy;
//          bcy1:= bcy+bc.Height;
          bc.Modul:= MM2PixelX (Printer.Handle,0.254);
          bc.Text:= bcst;
          bc.Left:= Printer.PageWidth-X_BRD-bc.Width;
          bc.DrawBarcode (Printer.Canvas);
          bc.Free;
          if bc.Top+bc.Height> bcy1 then
            y:= bc.Top+bc.Height
          else
            y:= bcy1;

          // �������
          case fEvent.Event.EventType of
            etRegular,etMovingTarget,etThreePosition2013,etMovingTarget2013: PrintRegularTable;
            etRapidFire: PrintRapidFireTable;
            etCenterFire,etCenterFire2013: PrintCenterFireTable;
          end;

          y:= y+MM2PixelY (Printer.Handle,2);

          // ���������, ����� � ��������
          Font.Size:= 9;
          Font.Style:= [];
          rct:= Rect (X_BRD,y,Printer.PageWidth-X_BRD,y+MM2PixelY (Printer.Handle,9+2+2));
          Brush.Color:= RGB (224,224,224);
          Brush.Style:= bsSolid;
          FillRect (rct);
          Brush.Color:= clWhite;
          st:= '���������:';
          st1:= '������� �����:';
          st2:= '��������: ';
          w1:= MM2PixelX (Printer.Handle,30+20+30+2+2+2+10+10)+TextWidth (st1)+TextWidth (st2)+TextWidth (st);
          x:= (Printer.PageWidth-w1) div 2;

          Brush.Style:= bsClear;
          y1:= y+(MM2PixelY (Printer.Handle,9+2+2)-TextHeight (st)) div 2;
          TextOut (x,y1,st);
          inc (x,TextWidth (st)+MM2PixelX (Printer.Handle,2));
          rct:= Rect (x,y+MM2PixelY (Printer.Handle,2),x+MM2PixelX (Printer.Handle,30),y+MM2PixelY (Printer.Handle,2+9));
          Brush.Style:= bsSolid;
          Rectangle (rct);
          inc (x,MM2PixelX (Printer.Handle,30)+MM2PixelX (Printer.Handle,10));

          Brush.Style:= bsClear;
          y1:= y+(MM2PixelY (Printer.Handle,9+2+2)-TextHeight (st1)) div 2;
          TextOut (x,y1,st1);
          inc (x,TextWidth (st1)+MM2PixelX (Printer.Handle,2));
          rct:= Rect (x,y+MM2PixelY (Printer.Handle,2),x+MM2PixelX (Printer.Handle,20),y+MM2PixelY (Printer.Handle,2+9));
          Brush.Style:= bsSolid;
          Rectangle (rct);
          inc (x,MM2PixelX (Printer.Handle,20)+MM2PixelX (Printer.Handle,10));

          Brush.Style:= bsClear;
          y1:= y+(MM2PixelY (Printer.Handle,9+2+2)-TextHeight (st2)) div 2;
          TextOut (x,y1,st2);
          inc (x,TextWidth (st2)+MM2PixelX (Printer.Handle,2));
          rct:= Rect (x,y+MM2PixelY (Printer.Handle,2),x+MM2PixelX (Printer.Handle,30),y+MM2PixelY (Printer.Handle,2+9));
          Brush.Style:= bsSolid;
          Rectangle (rct);
          y:= y+MM2PixelY (Printer.Handle,9+2+2+2);

          // �������
          x1:= Printer.PageWidth-X_BRD;

          st:= '������� ����� ���';
          st1:= '����� ���';
          st2:= '��������';
          w1:= ((x1-X_BRD-TextWidth (st)-TextWidth (st1)-TextWidth (st2)) div 3) - MM2PixelX (Printer.Handle,2);

          x:= X_BRD;
          y1:= y+MM2PixelY (Printer.Handle,10)-TextHeight (st);
          TextOut (x,y1,st);
          x:= x+TextWidth (st)+MM2PixelX (Printer.Handle,1);
          MoveTo (x,y+MM2PixelY (Printer.Handle,10));
          LineTo (x+w1,y+MM2PixelY (Printer.Handle,10));
          x:= x+w1+MM2PixelX (Printer.Handle,1);
          TextOut (x,y1,st1);
          x:= x+TextWidth (st1)+MM2PixelX (Printer.Handle,1);
          MoveTo (x,y+MM2PixelY (Printer.Handle,10));
          LineTo (x+w1,y+MM2PixelY (Printer.Handle,10));
          x:= x+w1+MM2PixelX (Printer.Handle,1);
          TextOut (x,y1,st2);
          x:= x+TextWidth (st2)+MM2PixelX (Printer.Handle,1);
          MoveTo (x,y+MM2PixelY (Printer.Handle,10));
          LineTo (x1,y+MM2PixelY (Printer.Handle,10));
          y:= y+MM2PixelY (Printer.Handle,10);
          y:= y+Y_PADDING;
          Brush.Style:= bsSolid;
          last_height:= y-ty;
        end;
    end;
  Printer.EndDoc;
end;

end.

