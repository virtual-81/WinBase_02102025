unit MyPrint;

{.$DEFINE DISABLE_PDF}  // можно включить для временного отключения PDF
{$DEFINE USE_SYNPDF}

interface

uses
  System.SysUtils, System.Types, Winapi.Windows, Winapi.ShellAPI, Vcl.Printers, System.Classes, Vcl.Graphics, Vcl.Dialogs
  {$IFDEF USE_SYNPDF}
  , SynPdf
  , SynGdiPlus
  , SynCrypto
  {$ENDIF}
  ;

type
  // PDF stub types for Delphi 12 migration compatibility
  TPDFPageSize = (psA4, psA3, psLetter); // Dummy PDF page sizes
  TPDFPageOrientation = (poPagePortrait, poPageLandscape); // PDF page orientations
  TPDFPageLayout = (plSinglePage, plOneColumn, plTwoColumnLeft, plTwoColumnRight); // PDF page layouts
  TPDFPageMode = (pmUseNone, pmUseOutlines, pmUseThumbs, pmFullScreen); // PDF page modes
  TPDFProtectionOption = (coPrint, coCopy, coEdit); // Dummy PDF protection options  
  TPDFProtectionOptions = set of TPDFProtectionOption;
  TPDFCompressionType = (ctNone, ctFlate, ctJPEG); // Dummy PDF compression types
  
  // Forward declarations
  TPDFOutlineNode = class;
  TPDFGoToPageAction = class;
  TPDFOutlines = class;
  
  // PDF Outline classes
  TPDFGoToPageAction = class
  public
    PageIndex: Integer;
    constructor Create;
  end;
  
  TPDFOutlineNode = class
  public
    Action: TObject;
  end;
  
  TPDFOutlines = class
  public
    function Add(Parent: TPDFOutlineNode; const Title: string; Action: TPDFGoToPageAction; Charset: Integer): TPDFOutlineNode;
  end;
  
  // PDF Page info class for compatibility
  TPDFPageInfo = class
  public
    Size: TPDFPageSize;
    Orientation: TPDFPageOrientation;
  end;
  
  // PDF Document info class for compatibility  
  TPDFDocumentInfo = class
  public
    Title: string;
    Author: string;
    Subject: string;
    Keywords: string;
  end;
  
  TPDFDocument = class // Абстракция PDF (SynPDF адаптер)
  private
    fCanvas: TCanvas;
    fCurrentPage: TPDFPageInfo;
    fDocumentInfo: TPDFDocumentInfo;
    fOutlines: TPDFOutlines;
    fPageLayout: TPDFPageLayout;
    fPageMode: TPDFPageMode;
    fResolution: Integer;
    fPageWidth: Integer;
    fPageHeight: Integer;
    {$IFDEF USE_SYNPDF}
    fPdf: TPdfDocumentGDI;
    {$ENDIF}
  public
    DefaultCharset: Integer;
    FileName: string;
    AutoLaunch: Boolean;
    ProtectionEnabled: Boolean;
    ProtectionOptions: TPDFProtectionOptions;
    Compression: TPDFCompressionType;
    Printing: Boolean;
    constructor Create(AOwner: TObject = nil);
    destructor Destroy; override;
    
    // PDF methods for compatibility
  procedure NewPage;
    procedure BeginDoc;
    procedure EndDoc;
    procedure Abort;
    
    // PDF properties for compatibility
    property Canvas: TCanvas read fCanvas;
    property CurrentPage: TPDFPageInfo read fCurrentPage;
    property DocumentInfo: TPDFDocumentInfo read fDocumentInfo;
    property Outlines: TPDFOutlines read fOutlines;
    property PageLayout: TPDFPageLayout read fPageLayout write fPageLayout;
    property PageMode: TPDFPageMode read fPageMode write fPageMode;
    property Resolution: Integer read fResolution write fResolution;
    property PageWidth: Integer read fPageWidth;
    property PageHeight: Integer read fPageHeight;
  end;
  TMyPrinter= class
  private
    fPrinter: TPrinter;
  fPDF: TPDFDocument;  // PDF документ
    fLPX,fLPY: integer;
    fPageWidth,fPageHeight: integer;
    fCanvas: TCanvas;
    fOrientation: TPrinterOrientation;
    fPageSize: TPDFPageSize;  // PDF stub for compatibility
    fLeftBorder,fTopBorder,fRightBorder,fBottomBorder: integer;
    fLeft,fTop,fRight,fBottom: integer;
    fWidth,fHeight: integer;
    procedure set_PageSize(const Value: TPDFPageSize);  // PDF stub for compatibility
    function get_Title: string;
    procedure set_Title(const Value: string);
    function get_Copies: integer;
    procedure set_Copies(const Value: integer);
    procedure set_Orientation(const Value: TPrinterOrientation);
    procedure GetCaps;
    procedure SetPDFOrientation;  // PDF stub for compatibility
  public
    constructor Create (APrinter: TObject= nil);
    property Canvas: TCanvas read fCanvas;
//    procedure SetPrinter (APrinter: TObject);
    property Printer: TPrinter read fPrinter;
    property PDF: TPDFDocument read fPDF;  // PDF stub for compatibility
    function MM2PX (mm: double): integer;
    function MM2PY (mm: double): integer;
    property PageWidth: integer read fPageWidth;
    property PageHeight: Integer read fPageHeight;
    procedure NewPage;
    property Orientation: TPrinterOrientation read fOrientation write set_Orientation;
    property Copies: integer read get_Copies write set_Copies;
    property Title: string read get_Title write set_Title;
    procedure BeginDoc;
    procedure Abort;
    procedure EndDoc;
    property PageSize: TPDFPageSize read fPageSize write set_PageSize;  // PDF stub for compatibility
    procedure SetBorders (ALeft,ATop,ARight,ABottom: integer);
    procedure SetBordersMM (ALeft,ATop,ARight,ABottom: double);
    property Width: integer read fWidth;
    property Height: integer read fHeight;
    property Left: integer read fLeft;
    property Top: integer read fTop;
    property Right: integer read fRight;
    property Bottom: integer read fBottom;
  end;

implementation

{ TMyPrinter }

procedure TMyPrinter.Abort;
begin
  if (fPrinter<> nil) and (fPrinter.Printing) then
    fPrinter.Abort;
  if (fPDF<> nil) and (fPDF.Printing) then
    fPDF.Abort;
end;

procedure TMyPrinter.BeginDoc;
begin
  if fPrinter<> nil then
    begin
      if not fPrinter.Printing then
        fPrinter.BeginDoc;
      fCanvas:= fPrinter.Canvas;
      GetCaps;
    end;
  // PDF (SynPDF)
  if fPDF<> nil then
  begin
    if not fPDF.Printing then
      fPDF.BeginDoc;
    fPDF.CurrentPage.Size:= fPageSize;
    SetPDFOrientation;
    GetCaps;
    fCanvas:= fPDF.Canvas;
  end;
end;

constructor TMyPrinter.Create;
begin
  inherited Create;
  fLPX:= 1;
  fLPY:= 1;
  fPageWidth:= 1000;
  fPageHeight:= 1000;
  fCanvas:= nil;
  fOrientation:= poPortrait;
  fPageSize:= psA4;
  // Не создаём PDF-документ по умолчанию: он должен передаваться явно,
  // иначе при обычной печати будет выполняться лишний EndDoc по PDF без имени файла
  fPDF:= nil;
  fLeftBorder:= 0;
  fTopBorder:= 0;
  fRightBorder:= 0;
  fBottomBorder:= 0;
  fLeft:= 0;
  fRight:= fPageWidth;
  fTop:= 0;
  fBottom:= fPageHeight;
  fWidth:= fPageWidth;
  fHeight:= fPageHeight;
  if APrinter= nil then
    APrinter:= Vcl.Printers.Printer;
  if APrinter<> nil then
    begin
      if APrinter is TPrinter then
        begin
          fPrinter:= APrinter as TPrinter;
          //fPDF:= nil;  // PDF temporarily disabled for Delphi 12
          fPrinter.Orientation:= fOrientation;
          fCanvas:= fPrinter.Canvas;
        end
      else if APrinter is TPDFDocument then
        begin
          // Поддержка сценария, когда TMyPrinter используют с готовым TPDFDocument
          fPrinter:= nil;
          fPDF:= APrinter as TPDFDocument;
          fPDF.PageLayout:= plSinglePage;
          fPDF.PageMode:= pmUseNone;
          SetPDFOrientation;
          if fPDF.Printing then
            fCanvas:= fPDF.Canvas;
        end
    end
  else
    begin
      fPrinter:= nil;
      //fPDF:= nil;  // PDF temporarily disabled for Delphi 12
      raise Exception.Create('Invalid printer object');
    end;
end;

procedure TMyPrinter.EndDoc;
begin
  if (fPrinter<> nil) and (fPrinter.Printing) then
    fPrinter.EndDoc;
  if (fPDF<> nil) and (fPDF.Printing) then
    fPDF.EndDoc;
end;

procedure TMyPrinter.GetCaps;
begin
  if (fPrinter<> nil) and (fPrinter.Printing) then
  begin
    fLPX:= GetDeviceCaps (fCanvas.Handle,LOGPIXELSX);
    fLPY:= GetDeviceCaps (fCanvas.Handle,LOGPIXELSY);
    fPageWidth:= fPrinter.PageWidth;
    fPageHeight:= fPrinter.PageHeight;
  end
  else if fPDF<> nil then
  begin
    fLPX:= fPDF.Resolution;
    fLPY:= fPDF.Resolution;
    if fPDF.Printing then
    begin
      fPageWidth:= fPDF.PageWidth;
      fPageHeight:= fPDF.PageHeight;
    end;
  end;
  fLeft:= fLeftBorder;
  fRight:= fPageWidth-fRightBorder;
  fTop:= fTopBorder;
  fBottom:= fPageHeight-fBottomBorder;
  fWidth:= fRight-fLeft;
  fHeight:= fBottom-fTop;
end;

function TMyPrinter.get_Copies: integer;
begin
  if fPrinter<> nil then
    Result:= fPrinter.Copies
  else
    Result:= 1;
end;

function TMyPrinter.get_Title: string;
begin
  if fPrinter<> nil then
    Result:= fPrinter.Title
  else if fPDF<> nil then
    Result:= fPDF.DocumentInfo.Title
  else
    Result:= '';
end;

function TMyPrinter.MM2PX(mm: double): integer;
begin
  Result:= round (mm*fLPX/25.4);
end;

function TMyPrinter.MM2PY(mm: double): integer;
begin
  Result:= round (mm*fLPY/25.4);
end;

procedure TMyPrinter.NewPage;
var
  _ps: TPDFPageSize;
  _or: TPDFPageOrientation;
  _fnt: TFont;
begin
  if fPrinter<> nil then
    fPrinter.NewPage;
  if fPDF<> nil then
    begin
      _ps:= fPDF.CurrentPage.Size;
      _or:= fPDF.CurrentPage.Orientation;
      _fnt:= TFont.Create;
      _fnt.Assign (fPDF.Canvas.Font);
      fPDF.NewPage;
      fPDF.CurrentPage.Size:= _ps;
      fPDF.CurrentPage.Orientation:= _or;
      fPDF.Canvas.Font.Assign (_fnt);
      fCanvas:= fPDF.Canvas;
      GetCaps;
      _fnt.Free;
    end;
end;

procedure TMyPrinter.SetBorders(ALeft, ATop, ARight, ABottom: integer);
begin
  fLeftBorder:= ALeft;
  fTopBorder:= ATop;
  fRightBorder:= ARight;
  fBottomBorder:= ABottom;
  fLeft:= fLeftBorder;
  fRight:= fPageWidth-fRightBorder;
  fTop:= fTopBorder;
  fBottom:= fPageHeight-fBottomBorder;
  fWidth:= fRight-fLeft;
  fHeight:= fBottom-fTop;
end;

procedure TMyPrinter.SetBordersMM(ALeft, ATop, ARight, ABottom: double);
begin
  SetBorders (MM2PX (ALeft),MM2PY (ATop),MM2PX (ARight),MM2PY (ABottom));
end;

procedure TMyPrinter.SetPDFOrientation;
begin
  if (fPDF<> nil) and (fPDF.Printing) then
  begin
    case fOrientation of
      poPortrait: fPDF.CurrentPage.Orientation:= poPagePortrait;
      poLandscape: fPDF.CurrentPage.Orientation:= poPageLandscape;
    end;
  end;
end;

procedure TMyPrinter.set_Copies(const Value: integer);
begin
  if fPrinter<> nil then
    fPrinter.Copies:= Value;
end;

procedure TMyPrinter.set_Orientation(const Value: TPrinterOrientation);
begin
  fOrientation:= Value;
  if fPrinter<> nil then
    fPrinter.Orientation:= fOrientation;
  //SetPDFOrientation;  // PDF temporarily disabled for Delphi 12
  GetCaps;
end;

// Реализация PDF (SynPDF)
constructor TPDFDocument.Create(AOwner: TObject = nil);
begin
  inherited Create;
  DefaultCharset := 0;
  FileName := '';
  AutoLaunch := False;
  ProtectionEnabled := False;
  ProtectionOptions := [];
  Compression := ctFlate;
  Printing := False;
  
  // Initialize PDF objects
  fCurrentPage := TPDFPageInfo.Create;
  fDocumentInfo := TPDFDocumentInfo.Create;
  fOutlines := TPDFOutlines.Create;
  {$IFDEF USE_SYNPDF}
  fPdf := nil;
  {$ENDIF}
  fPageLayout := plSinglePage;
  fPageMode := pmUseNone;
  fResolution := 72; // PDF points
  fPageWidth := 595; // A4 width at 72 DPI
  fPageHeight := 842; // A4 height at 72 DPI
end;

destructor TPDFDocument.Destroy;
begin
  fCurrentPage.Free;
  fDocumentInfo.Free;
  fOutlines.Free;
  {$IFDEF USE_SYNPDF}
  fPdf.Free;
  {$ENDIF}
  inherited;
end;

procedure TPDFDocument.NewPage;
begin
  {$IFDEF USE_SYNPDF}
  if fPdf = nil then
    Exit;
  fPdf.AddPage;
  fCanvas := fPdf.VCLCanvas;
  // обновим размеры страницы
  var sz: TSize;
  sz := fPdf.VCLCanvasSize;
  fPageWidth := sz.cx;
  fPageHeight := sz.cy;
  {$ENDIF}
end;

procedure TPDFDocument.BeginDoc;
begin
  {$IFDEF USE_SYNPDF}
  if fPdf = nil then
  begin
    // Create SynPDF document with outlines and Uniscribe for Unicode
    fPdf := TPdfDocumentGDI.Create(True, 0);
    fPdf.UseUniscribe := True;
    // propagate basic document info if provided
    try
      if Assigned(fDocumentInfo) then
      begin
        if fDocumentInfo.Title <> '' then
          fPdf.Info.Title := fDocumentInfo.Title;
        if fDocumentInfo.Author <> '' then
          fPdf.Info.Author := fDocumentInfo.Author;
        if fDocumentInfo.Subject <> '' then
          fPdf.Info.Subject := fDocumentInfo.Subject;
        if fDocumentInfo.Keywords <> '' then
          fPdf.Info.Keywords := fDocumentInfo.Keywords;
      end;
    except
      // ignore metadata assignment errors
    end;
    // первая страница
  fPdf.AddPage;
  fCanvas := fPdf.VCLCanvas;
  var sz: TSize;
  sz := fPdf.VCLCanvasSize;
  fPageWidth := sz.cx;
  fPageHeight := sz.cy;
  end;
  {$ENDIF}
  Printing := True;
end;

procedure TPDFDocument.EndDoc;
var
  PDFFileName: string;
begin
  Printing := False;
  {$IFDEF USE_SYNPDF}
  if fPdf <> nil then
  begin
    if FileName = '' then
    begin
      // nothing to save to: inform the caller for visibility
      ShowMessage('Не задано имя файла для сохранения PDF. Операция отменена.');
      Exit;
    end;

    PDFFileName := ChangeFileExt(FileName, '.pdf');
    // try saving; SaveToFile returns false on failure without raising
    if not fPdf.SaveToFile(PDFFileName) then
    begin
      ShowMessage('Не удалось сохранить PDF в файл: ' + PDFFileName + sLineBreak +
                  'Возможные причины: нет прав на запись или файл уже открыт в другой программе.');
      Exit;
    end;
    if AutoLaunch then
      ShellExecute(0, 'open', PChar(PDFFileName), nil, nil, SW_SHOWNORMAL);
  end;
  {$ENDIF}
end;

procedure TPDFDocument.Abort;
begin
  Printing := False;
end;

procedure TMyPrinter.set_PageSize(const Value: TPDFPageSize);
begin
  fPageSize:= Value;
end;

// Удалено дублирование SetPDFOrientation: рабочая реализация находится выше

procedure TMyPrinter.set_Title(const Value: string);
begin
  if fPrinter<> nil then
    fPrinter.Title:= Value;
  // можно дополнить установкой заголовка в PDF при необходимости
end;

// PDF Outline implementations
constructor TPDFGoToPageAction.Create;
begin
  inherited Create;
  PageIndex := 0;
end;

function TPDFOutlines.Add(Parent: TPDFOutlineNode; const Title: string; Action: TPDFGoToPageAction; Charset: Integer): TPDFOutlineNode;
begin
  Result := TPDFOutlineNode.Create;
  Result.Action := Action;
end;

end.

