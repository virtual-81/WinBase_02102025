unit PDF;

interface
//{$DEFINE CANVASDBG}
//{$DEFINE _Debug}

{$IFDEF VER110}
{$DEFINE CB}
{$OBJEXPORTALL On}
{$ENDIF}
{$IFDEF VER125}
{$DEFINE CB}
{$OBJEXPORTALL On}
{$ENDIF}
{$IFDEF VER130}
{$IFDEF BCB}
{$DEFINE CB}
{$OBJEXPORTALL On}
{$ENDIF}
{$ENDIF}
{$IFDEF VER140}
{$IFDEF BCB}
{$DEFINE CB}
{$OBJEXPORTALL On}
{$ENDIF}
{$ENDIF}

{.$IFNDEF _Debug}
{.$D-,L-}
{.$ENDIF}

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, System.Math, Jpeg, Winapi.ShellAPI;

var
  EmbedFontFilesToPDF: boolean;

type
  TDoublePoint = record
    x, y: Extended;
  end;
  TTextCTM = record
    a, b, c, d, x, y: Extended;
  end;

  TPDFPageOrientation = (poPagePortrait, poPageLandscape);
  TPDFVersion = (v13, v14);
  TCCITT = (CCITT31D, CCITT32D, CCITT42D);
  TPDFPageType = (ptPage, ptXForm, ptAnnotation);
  TPDFLineJoin = (ljMiter, ljRound, ljBevel);
  TPDFLineCap = (lcButtEnd, lcRound, lcProjectingSquare);
  TCJKFont = (cjkChinaTrad, cjkChinaSimpl, cjkJapan, cjkKorean);
  TPDFSubmitType = (stGet, stPost, stFDF);

  TViewerPreference = (vpHideToolBar, vpHideMenuBar, vpHideWindowUI, vpFitWindow, vpCenterWindow);
  TViewerPreferences = set of TViewerPreference;

  TAnnotationFlag = (afInvisible, afHidden, afPrint, afNoZoom, afNoRotate, afNoView, afReadOnly);

  TAnnotationFlags = set of TAnnotationFlag;
  TEncripKey = array[1..5] of Byte;

  THorJust = (hjLeft, hjCenter, hjRight);
  TVertJust = (vjUp, vjCenter, vjDown);

  TCompressionType = (ctNone, ctFlate);
  TImageCompressionType = (itcFlate, itcJpeg, itcCCITT3, itcCCITT32d, itcCCITT4);
  TPDFCriptoOption = (coPrint, coModifyStructure, coCopyInformation, coModifyAnnotation);
  TPDFCtiptoOptions = set of TPDFCriptoOption;
  TPageLayout = (plSinglePage, plOneColumn, plTwoColumnLeft, plTwoColumnRight);

  TPageMode = (pmUseNone, pmUseOutlines, pmUseThumbs, pmFullScreen);
  TPDFPageRotate = (pr0, pr90, pr180, pr270);

  TPDFException = class(Exception);

  TPDFDocument = class;
  TPDFFonts = class;
  TPDFImages = class;
  TPDFImage = class;
  TPDFPage = class;

  TPDFControlHint = class(TObject)
  private
    FCaption: string;
    FCharset: TFontCharset;
  public
    property Caption: string read FCaption write FCaption;
    property Charset: TFontCharset read FCharset write FCharset;
  end;

  TPDFControlFont = class
  private
    FSize: Integer;
    FName: string;
    FColor: TColor;
    FCharset: TFontCharset;
    FStyle: TFontStyles;
    procedure SetCharset(const Value: TFontCharset);
    procedure SetSize(const Value: Integer);
  public
    constructor Create;
    property Name: string read FName write FName;
    property Charset: TFontCharset read FCharset write SetCharset;
    property Style: TFontStyles read FStyle write FStyle;
    property Size: Integer read FSize write SetSize;
    property Color: TColor read FColor write FColor;
  end;

  TPDFPageSize = (psUserDefined, psLetter, psA4, psA3, psLegal, psB5, psC5, ps8x11, psB4,
    psA5, psFolio, psExecutive, psEnvB4, psEnvB5, psEnvC6, psEnvDL, psEnvMonarch,
    psEnv9, psEnv10, psEnv11);

  TPDFDocInfo = class(TPersistent)
  private
    Producer: string;
    ID: Integer;
    FKeywords: string;
    FTitle: string;
    FCreator: string;
    FAuthor: string;
    FSubject: string;
    FCreationDate: TDateTime;
    FCharset: TFontCharset;
    procedure SetCharset(const Value: TFontCharset);
    procedure SetAuthor(const Value: string);
    procedure SetCreationDate(const Value: TDateTime);
    procedure SetCreator(const Value: string);
    procedure SetKeywords(const Value: string);
    procedure SetSubject(const Value: string);
    procedure SetTitle(const Value: string);
  public
    property CreationDate: TDateTime read FCreationDate write SetCreationDate;
  published
    property Author: string read FAuthor write SetAuthor;
    property Creator: string read FCreator write SetCreator;
    property Keywords: string read FKeywords write SetKeywords;
    property Subject: string read FSubject write SetSubject;
    property Title: string read FTitle write SetTitle;
    property Charset: TFontCharset read FCharset write SetCharset;
  end;

  TTextAnnotationIcon = (taiComment, taiKey, taiNote, taiHelp, taiNewParagraph, taiParagraph, taiInsert);
  TPDFControl = class;

  TPDFControls = class
  private
    FControls: TList;
    function GetCount: Integer;
    function GetControl(Index: Integer): TPDFControl;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Control: TPDFControl): Integer;
    function IndexOf(Control: TPDFControl): Integer;
    procedure Delete(Control: TPDFControl);
    procedure Clear;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPDFControl read GetControl; default;
  end;

  TPDFAction = class(TObject)
  private
    FOwner: TPDFDocument;
    ActionID: Integer;
    FNext: TPDFAction;
    procedure Prepare;
    procedure Save; virtual; abstract;
  public
    constructor Create; virtual;
  end;

  TPDFActionClass = class of TPDFAction;

  TPDFURLAction = class(TPDFAction)
  private
    FURL: string;
    procedure Save; override;
    procedure SetURL(const Value: string);
  public
    property URL: string read FURL write SetURL;
  end;

  TPDFJavaScriptAction = class(TPDFAction)
  private
    FJavaScript: string;
    procedure Save; override;
    procedure SetJavaScript(const Value: string);
  public
    property JavaScript: string read FJavaScript write SetJavaScript;
  end;

  TPDFGoToPageAction = class(TPDFAction)
  private
    FTopOffset: Integer;
    FPageIndex: Integer;
    procedure Save; override;
    procedure SetPageIndex(const Value: Integer);
    procedure SetTopOffset(const Value: Integer);
  public
    property PageIndex: Integer read FPageIndex write SetPageIndex;
    property TopOffset: Integer read FTopOffset write SetTopOffset;
  end;

  TPDFVisibeControlAction = class(TPDFAction)
  private
    FVisible: Boolean;
    FControls: TPDFControls;
    procedure Save; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property Visible: Boolean read FVisible write FVisible;
    property Controls: TPDFControls read FControls;
  end;

  TPDFSubmitFormAction = class(TPDFAction)
  private
    FFields: TPDFControls;
    FRG: TList;
    FIncludeEmptyFields: Boolean;
    FURL: string;
    FSubmitType: TPDFSubmitType;
    procedure Save; override;
    procedure SetURL(const Value: string);
  public
    constructor Create; override;
    destructor Destroy; override;
    property IncludeFields: TPDFControls read FFields;
    property URL: string read FURL write SetURL;
    property SendEmpty: Boolean read FIncludeEmptyFields write FIncludeEmptyFields;
    property SubmitType: TPDFSubmitType read FSubmitType write FSubmitType;
  end;

  TPDFResetFormAction = class(TPDFAction)
  private
    FFields: TPDFControls;
    FRG: TList;
    procedure Save; override;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ResetFields: TPDFControls read FFields;
  end;

  TPDFImportDataAction = class(TPDFAction)
  private
    FFileName: string;
    procedure Save; override;
    procedure SetFileName(const Value: string);
  public
    property FileName: string read FFileName write SetFileName;
  end;

  TPDFCustomAnnotation = class(TObject)
  private
    FOwner: TPDFPage;
    AnnotID: Integer;
    FLeft, FTop, FRight, FBottom: Integer;
    FFlags: TAnnotationFlags;
    FBorderStyle: string;
    FBorderColor: TColor;
    function CalcFlags: Integer;
    procedure Save; virtual; abstract;
    function GetBox: TRect;
    procedure SetBox(const Value: TRect);
  public
    constructor Create(AOwner: TPDFPage);
    property Box: TRect read GetBox write SetBox;
    property BorderStyle: string read FBorderStyle write FBorderStyle;
    property Flags: TAnnotationFlags read FFlags write FFlags;
    property BorderColor: TColor read FBorderColor write FBorderColor;
  end;


  TPDFControl = class(TPDFCustomAnnotation)
  private
    FRequired: Boolean;
    FReadOnly: Boolean;
    FName: string;
    FOnMouseDown: TPDFAction;
    FOnMouseExit: TPDFAction;
    FOnMouseEnter: TPDFAction;
    FOnMouseUp: TPDFAction;
    FOnLostFocus: TPDFAction;
    FOnSetFocus: TPDFAction;
    FColor: TColor;
    FFont: TPDFControlFont;
    FFN: string;
    FHint: TPDFControlHint;
    procedure SetName(const Value: string);
    procedure SetOnMouseDown(const Value: TPDFAction);
    procedure SetOnMouseEnter(const Value: TPDFAction);
    procedure SetOnMouseExit(const Value: TPDFAction);
    procedure SetOnMouseUp(const Value: TPDFAction);
    procedure SetOnLostFocus(const Value: TPDFAction);
    procedure SetOnSetFocus(const Value: TPDFAction);
    procedure SetColor(const Value: TColor);
    function CalcActions: string;
  public
    constructor Create(AOwner: TPDFPage; AName: string); virtual;
    destructor Destroy; override;
    property ReadOnly: Boolean read FReadOnly write FReadOnly;
    property Required: Boolean read FRequired write FRequired;
    property Name: string read FName write SetName;
    property Color: TColor read FColor write SetColor;
    property Font: TPDFControlFont read FFont;
    property Hint: TPDFControlHint read FHint;
    property OnMouseUp: TPDFAction read FOnMouseUp write SetOnMouseUp;
    property OnMouseDown: TPDFAction read FOnMouseDown write SetOnMouseDown;
    property OnMouseEnter: TPDFAction read FOnMouseEnter write SetOnMouseEnter;
    property OnMouseExit: TPDFAction read FOnMouseExit write SetOnMouseExit;
    property OnSetFocus: TPDFAction read FOnSetFocus write SetOnSetFocus;
    property OnLostFocus: TPDFAction read FOnLostFocus write SetOnLostFocus;
  end;

  TPDFControlClass = class of TPDFControl;

  TPDFRadioGroup = class
  private
    FButtons: TPDFControls;
    FOwner: TPDFDocument;
    GroupID: Integer;
    FName: string;
    procedure Save;
  public
    constructor Create(AOwner: TPDFDocument; Name: string);
    destructor Destroy; override;
  end;


  TPDFButton = class(TPDFControl)
  private
    FCaption: string;
    procedure Save; override;
  protected
    FUp: TPDFPage;
    FDown: TPDFPage;
    procedure Paint; virtual;
  public
    constructor Create(AOwner: TPDFPage; AName: string); override;
    property Caption: string read FCaption write FCaption;
  end;

  TPDFInputControl = class(TPDFControl)
  private
    FOnOtherControlChanged: TPDFJavaScriptAction;
    FOnKeyPress: TPDFJavaScriptAction;
    FOnBeforeFormatting: TPDFJavaScriptAction;
    FOnChange: TPDFJavaScriptAction;
    procedure SetOnOtherControlChanged(const Value: TPDFJavaScriptAction);
    procedure SetOnKeyPress(const Value: TPDFJavaScriptAction);
    procedure SetOnBeforeFormatting(const Value: TPDFJavaScriptAction);
    procedure SetOnChange(const Value: TPDFJavaScriptAction);
    function CalcActions: string;
  public
    property OnKeyPress: TPDFJavaScriptAction read FOnKeyPress write SetOnKeyPress;
    property OnBeforeFormatting: TPDFJavaScriptAction read FOnBeforeFormatting write SetOnBeforeFormatting;
    property OnChange: TPDFJavaScriptAction read FOnChange write SetOnChange;
    property OnOtherControlChanged: TPDFJavaScriptAction read FOnOtherCOntrolChanged write SetOnOtherCOntrolChanged;
  end;

  TPDFCheckBox = class(TPDFInputControl)
  private
    FChecked: Boolean;
    FCaption: string;
    procedure Save; override;
  protected
    FCheck: TPDFPage;
    FUnCheck: TPDFPage;
    procedure Paint; virtual;
  public
    constructor Create(AOwner: TPDFPage; AName: string); override;
    property Checked: Boolean read FChecked write FChecked;
    property Caption: string read FCaption write FCaption;
  end;

  TPDFRadioButton = class(TPDFInputControl)
  private
    FRG: TPDFRadioGroup;
    FChecked: Boolean;
    FExportValue: string;
    procedure Save; override;
    procedure SetExportValue(const Value: string);
  protected
    FCheck: TPDFPage;
    FUnCheck: TPDFPage;
    procedure Paint; virtual;
  public
    constructor Create(AOwner: TPDFPage; AName: string); override;
    property ExportValue: string read FExportValue write SetExportValue;
    property Checked: Boolean read FChecked write FChecked;
  end;


  TPDFEdit = class(TPDFInputControl)
  private
    FText: string;
    FIsPassword: Boolean;
    FShowBorder: Boolean;
    FMultiline: Boolean;
    FMaxLength: Integer;
    FJustification: THorJust;
    procedure Save; override;
    procedure SetMaxLength(const Value: Integer);
  protected
    FShow: TPDFPage;
    procedure Paint; virtual;
  public
    constructor Create(AOwner: TPDFPage; AName: string); override;
    property Text: string read FText write FText;
    property Multiline: Boolean read FMultiline write FMultiline;
    property IsPassword: Boolean read FIsPassword write FIsPassword;
    property ShowBorder: Boolean read FShowBorder write FShowBorder;
    property MaxLength: Integer read FMaxLength write SetMaxLength;
    property Justification: THorJust read FJustification write FJustification;
  end;

  TPDFComboBox = class(TPDFInputControl)
  private
    FEditEnabled: Boolean;
    FItems: TStringList;
    FText: string;
    procedure Save; override;
  protected
    FShow: TPDFPage;
    procedure Paint; virtual;
  public
    constructor Create(AOwner: TPDFPage; AName: string); override;
    destructor Destroy; override;
    property Items: TStringList read FItems;
    property EditEnabled: Boolean read FEditEnabled write FEditEnabled;
    property Text: string read FText write FText;
  end;

  TPDFTextAnnotation = class(TPDFCustomAnnotation)
  private
    FText: string;
    FCaption: string;
    FTextAnnotationIcon: TTextAnnotationIcon;
    FOpened: Boolean;
    FCharset: TFontCharset;
    procedure Save; override;
  public
    property Caption: string read FCaption write FCaption;
    property Text: string read FText write FText;
    property TextAnnotationIcon: TTextAnnotationIcon read FTextAnnotationIcon write FTextAnnotationIcon;
    property Opened: Boolean read FOpened write FOpened;
    property Charset: TFontCharset read FCharset write FCharset;
  end;

  TPDFActionAnnotation = class(TPDFCustomAnnotation)
  private
    FAction: TPDFAction;
    procedure Save; override;
    procedure SetAction(const Value: TPDFAction);
  public
    property Action: TPDFAction read FAction write SetAction;
  end;

  TPDFActions = class(TObject)
  private
    FOwner: TPDFDocument;
    FActions: TList;
    function GetCount: Integer;
    function GetAction(Index: Integer): TPDFAction;
    procedure Clear;
  public
    constructor Create(AOwner: TPDFDocument);
    destructor Destroy; override;
    function Add(Action: TPDFAction): Integer;
    function IndexOf(Action: TPDFAction): Integer;
    procedure Delete(Action: TPDFAction);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPDFAction read GetAction; default;
  end;

  TPDFAcroForm = class(TObject)
  private
    AcroID: Integer;
    FOwner: TPDFDocument;
    FFields: TPDFControls;
    FFonts: TList;
    FRadioGroups: TList;
    procedure Save;
    function GetEmpty: Boolean;
  public
    constructor Create(AOwner: TPDFDocument);
    procedure Clear;
    destructor Destroy; override;
    property Empty: Boolean read GetEmpty;
  end;

  TPDFPages = class;

  TPDFPage = class(TObject)
  private
    FOwner: TPDFDocument;
    FAnnot: TList;
    FMatrix: TTextCTM;
    FForms: TPDFPages;
    FIsForm: Boolean;
    FRes: Integer;
    D2P: Extended;
    FContent: TStringList;
    FHeight: Integer;
    FWidth: Integer;
    FPageSize: TPDFPageSize;
    FX: Extended;
    FY: Extended;
    FRotate: TPDFPageRotate;
    FLinkedFont: TList;
    FLinkedImages: TList;
    ResourceID: Integer;
    PageID: Integer;
    ContentID: Integer;
    FEBold: Boolean;
    FEItalic: Boolean;
    FEUnderLine: Boolean;
    FEStrike: Boolean;
    FCTM: TTextCTM;
    FF: TTextCTM;
    FCurrentFontSize: Extended;
    FCurrentFontIndex: Integer;
    FCurrentDash: string;
    FHorizontalScaling: Extended;
    FCharSpace: Extended;
    FWordSpace: Extended;
    FRise: Extended;
    FRender: Integer;
    FFontInited: Boolean;
    FTextInited: Boolean;
    FTextLeading: Extended;
    FSaveCount: Integer;
    FTextAngle: Extended;
    FRealAngle: Extended;
    FOrientation: TPDFPageOrientation;
    Factions: Boolean;
    FMF: TMetafile;
    FCanvas: TCanvas;
    FWaterMark: Integer;
    FThumbnail: Integer;
    FRemoveCR: Boolean;
    FEmulationEnabled: Boolean;
    FCanvasOver: Boolean;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetPageSize(Value: TPDFPageSize);
    procedure Save;
    procedure AppendAction(Action: string);
    function IntToExtX(AX: Extended): Extended;
    function IntToExtY(AY: Extended): Extended;
    function ExtToIntX(AX: Extended): Extended;
    function ExtToIntY(AY: Extended): Extended;
    procedure DrawArcWithBezier(CenterX, CenterY, RadiusX, RadiusY, StartAngle, SweepRange: Extended; UseMoveTo: Boolean = True);
    procedure SetRotate(const Value: TPDFPageRotate);
    procedure RawSetTextPosition(X, Y: Extended);
    procedure RawTextOut(X, Y, Orientation: Extended; TextStr: string);
    procedure RawLineTo(X, Y: Extended);
    procedure RawMoveTo(X, Y: Extended);
    procedure RawRect(X, Y, W, H: Extended);
    function RawArc(X1, Y1, x2, y2, x3, y3, x4, y4: Extended): TDoublePoint; overload;
    function RawArc(X1, Y1, x2, y2, BegAngle, EndAngle: Extended): TDoublePoint; overload;
    function RawPie(X1, Y1, x2, y2, x3, y3, x4, y4: Extended): TDoublePoint; overload;
    function RawPie(X1, Y1, x2, y2, BegAngle, EndAngle: Extended): TDoublePoint; overload;
    procedure RawCircle(X, Y, R: Extended);
    procedure RawEllipse(x1, y1, x2, y2: Extended);
    procedure RawRectRotated(X, Y, W, H, Angle: Extended);
    procedure RawShowImage(ImageIndex: Integer; x, y, w, h, angle: Extended);
    procedure RawConcat(A, B, C, D, E, F: Extended);
    procedure RawTranslate(XT, YT: Extended);
    procedure DeleteAllAnnotations;
    procedure RawCurveto(X1, Y1, X2, Y2, X3, Y3: Extended);
    procedure ConcatTextMatrix(A, B, C, D, X, Y: Extended);
    procedure SetTextMatrix(A, B, C, D, X, Y: Extended);
    procedure ResetTextCTM;
    procedure SetOrientation(const Value: TPDFPageOrientation);
    function GetHeight: Integer;
    function GetWidth: Integer;
    procedure CreateCanvas;
    procedure DeleteCanvas;
    procedure CloseCanvas;

    procedure SetWaterMark(const Value: Integer);
    procedure SetThumbnail(const Value: Integer);
    procedure PrepareID;
  public
    constructor Create(AOwner: TPDFDocument);
    destructor Destroy; override;

    // Annotation
    function SetAnnotation(ARect: TRect; Title, Text: string; Color: TColor; Flags: TAnnotationFlags; Opened: Boolean; Charset: TFontCharset): TPDFCustomAnnotation; overload;
    function SetAnnotation(ARect: TRect; Title, Text: string; Color: TColor; Flags: TAnnotationFlags; Opened: Boolean): TPDFCustomAnnotation; overload;
    function SetUrl(ARect: TRect; URL: string): TPDFCustomAnnotation;
    function SetAction(ARect: TRect; Action: TPDFAction): TPDFCustomAnnotation;
    function SetLinkToPage(ARect: TRect; PageIndex: Integer; TopOffset: Integer): TPDFCustomAnnotation;
    function CreateControl(CClass: TPDFControlClass; ControlName: string; Box: TRect): TPDFControl;

    // Text operation
    procedure BeginText;
    procedure EndText;
    procedure RotateText(Degrees: Extended);
    procedure SetActiveFont(FontName: string; FontStyle: TFontStyles; FontSize: Extended; FontCharset: TFontCharset); overload;
    procedure SetActiveFont(FontName: string; FontStyle: TFontStyles; FontSize: Extended); overload;
    procedure SetCharacterSpacing(Spacing: Extended);
    procedure SetHorizontalScaling(Scale: Extended);
    procedure SetLineCap(LineCap: TPDFLineCap);
    procedure SetLineJoin(LineJoin: TPDFLineJoin);
    procedure SetMiterLimit(MiterLimit: Extended);
    procedure SetTextPosition(X, Y: Extended);
    procedure SetTextRenderingMode(Mode: integer);
    procedure SetTextRise(Rise: Extended);
    procedure SetWordSpacing(Spacing: Extended);
    procedure SkewText(Alpha, Beta: Extended);
    procedure TextOut(X, Y, Orientation: Extended; TextStr: string);
    procedure TextShow(TextStr: string);
    function GetTextWidth(Text: string): Extended;
    procedure TextBox(Rect: TRect; Text: string; Hor: THorJust; Vert: TVertJust);
    // Path operation
    procedure Clip;
    procedure EoClip;
    procedure EoFill;
    procedure EoFillAndStroke;
    procedure Fill;
    procedure FillAndStroke;
    procedure NewPath;
    procedure ClosePath;
    procedure Stroke;

    // Graphic primitive operation
    procedure LineTo(X, Y: Extended);
    procedure MoveTo(X, Y: Extended);
    procedure Curveto(X1, Y1, X2, Y2, X3, Y3: Extended);
    procedure Rectangle(X1, Y1, X2, Y2: Extended);
    // Advanced graphic operation
    procedure Circle(X, Y, R: Extended);
    procedure Ellipse(X1, Y1, X2, Y2: Extended);
    function Arc(X1, Y1, x2, y2, x3, y3, x4, y4: Extended): TDoublePoint; overload;
    function Arc(X1, Y1, x2, y2, BegAngle, EndAngle: Extended): TDoublePoint; overload;
    procedure Pie(X1, Y1, x2, y2, x3, y3, x4, y4: Extended); overload;
    procedure Pie(X1, Y1, x2, y2, BegAngle, EndAngle: Extended); overload;
    procedure RectRotated(X, Y, W, H, Angle: Extended);
    procedure RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);
    // Graphic state operation
    procedure GStateRestore;
    procedure GStateSave;
    procedure NoDash;
    procedure SetCMYKColor(C, M, Y, K: Extended);
    procedure SetCMYKColorFill(C, M, Y, K: Extended);
    procedure SetCMYKColorStroke(C, M, Y, K: Extended);
    procedure SetRGBColor(R, G, B: Extended);
    procedure SetRGBColorFill(R, G, B: Extended);
    procedure SetRGBColorStroke(R, G, B: Extended);
    procedure SetDash(DashSpec: string);
    procedure SetFlat(FlatNess: integer);
    procedure SetGray(Gray: Extended);
    procedure SetGrayFill(Gray: Extended);
    procedure SetGrayStroke(Gray: Extended);
    procedure SetLineWidth(lw: Extended);

    // Transform operation
    procedure Concat(A, B, C, D, E, F: Extended);
    procedure Scale(SX, SY: Extended);
    procedure Rotate(Angle: Extended);
    procedure Translate(XT, YT: Extended);
    // Picture
    procedure ShowImage(ImageIndex: Integer; x, y, w, h, angle: Extended);

    // Other
    procedure Comment(st: string);
    procedure PlayMetaFile(MF: TMetaFile); overload;
    procedure PlayMetaFile(MF: TMetafile; x, y, XScale, YScale: Extended); overload;
    property Orientation: TPDFPageOrientation read FOrientation write SetOrientation;
    property Size: TPDFPageSize read FPageSize write SetPageSize;
    property Height: Integer read GetHeight write SetHeight;
    property Width: Integer read GetWidth write SetWidth;
    property PageRotate: TPDFPageRotate read FRotate write SetRotate;
    property WaterMark: Integer read FWaterMark write SetWaterMark;
    property Thumbnail: Integer read FThumbnail write SetThumbnail;
    property TextInited: Boolean read FTextInited;
    property CanvasOver: Boolean read FCanvasOver write FCanvasOver;
  end;

  TPDFPages = class(TObject)
  private
    IsWaterMarks: Boolean;
    FOwner: TPDFDocument;
    FPages: TList;
    function GetCount: Integer;
    function GetPage(Index: Integer): TPDFPage;
    procedure Clear;
  public
    constructor Create(AOwner: TPDFDocument; WM: Boolean);
    destructor Destroy; override;
    function Add: TPDFPage;
    function IndexOf(Page: TPDFPage): Integer;
    procedure Delete(Page: TPDFPage);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPDFPage read GetPage; default;
  end;

  TPDFOutlines = class;

  TPDFOutlineNode = class(TObject)
  private
    OutlineNodeID: Integer;
    FChild: TList;
    FOwner: TPDFOutlines;
    FParent: TPDFOutlineNode;
    FPrev: TPDFOutlineNode;
    FNext: TPDFOutlineNode;
    FTitle: string;
    FExpanded: Boolean;
    FCharset: TFontCharset;
    FAction: TPDFAction;
    FColor: TColor;
    FStyle: TFontStyles;
    procedure SetTitle(const Value: string);
    function GetCount: Integer;
    function GetHasChildren: Boolean;
    function GetItem(Index: Integer): TPDFOutlineNode;
    procedure Save;
    procedure SetExpanded(const Value: Boolean);
    procedure SetCharset(const Value: TFontCharset);
    procedure SetAction(const Value: TPDFAction);
  public
    procedure Delete;
    procedure DeleteChildren;
    constructor Create(AOwner: TPDFOutlines);
    destructor Destroy; override;
    function GetFirstChild: TPDFOutlineNode;
    function GetLastChild: TPDFOutlineNode;
    function GetNext: TPDFOutlineNode;
    function GetNextChild(Node: TPDFOutlineNode): TPDFOutlineNode;
    function GetNextSibling: TPDFOutlineNode;
    function GetPrev: TPDFOutlineNode;
    function GetPrevChild(Node: TPDFOutlineNode): TPDFOutlineNode;
    function GetPrevSibling: TPDFOutlineNode;
    property Action: TPDFAction read FAction write SetAction;
    property Title: string read FTitle write SetTitle;
    property Color: TColor read FColor write FColor;
    property Style: TFontStyles read FStyle write FStyle;
    property Count: Integer read GetCount;
    property HasChildren: Boolean read GetHasChildren;
    property Item[Index: Integer]: TPDFOutlineNode read GetItem;
    property Expanded: Boolean read FExpanded write SetExpanded;
    property Charset: TFontCharset read FCharset write SetCharset;
  end;

  TPDFOutlines = class(TObject)
  private
    OutlinesID: Integer;
    FList: TList;
    FOwner: TPDFDocument;
    function GetCount: Integer;
    function GetItem(Index: Integer): TPDFOutlineNode;
    function Add(Node: TPDFOutlineNode): TPDFOutlineNode; overload;
    function AddChild(Node: TPDFOutlineNode): TPDFOutlineNode; overload;
    function AddChildFirst(Node: TPDFOutlineNode): TPDFOutlineNode; overload;
//    function AddFirst(Node: TPDFOutlineNode): TPDFOutlineNode; overload;
    function Insert(Node: TPDFOutlineNode): TPDFOutlineNode; overload;
  public
    procedure Clear;
    procedure Delete(Node: TPDFOutlineNode);
    function GetFirstNode: TPDFOutlineNode;

    function Add(Node: TPDFOutlineNode; Title: string; Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode; overload;
    function Add(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode; overload;
    function AddChild(Node: TPDFOutlineNode; Title: string; Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode; overload;
    function AddChild(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode; overload;
    function AddChildFirst(Node: TPDFOutlineNode; Title: string; Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode; overload;
    function AddChildFirst(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode; overload;
    function AddFirst(Node: TPDFOutlineNode; Title: string; Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode; overload;
    function AddFirst(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode; overload;
    function Insert(Node: TPDFOutlineNode; Title: string; Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode; overload;
    function Insert(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode; overload;

    constructor Create(AOwner: TPDFDocument);
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property Item[Index: Integer]: TPDFOutlineNode read GetItem; default;
  end;

  TPDFFont = class(TObject)
  private
    FontID: Integer;
    FontDescriptorID: Integer;
    FontFileID: Integer;
    FontName: string;
    RealName: string;
    RealStyle: TFontStyles;
    RealCharset: TFontCharset;
    Standart: Boolean;
    AliasName: string;
    StdID: Byte;
    IsCJK: Boolean;
    CJKType: TCJKFont;
    FWidth: array[0..255] of SmallInt;
    WidthLoaded: Boolean;
    procedure Save(Doc: TPDFDocument);
    procedure LoadingWidth;
    function GetWidth(Index: Integer): Word;
  public
    constructor Create;
  end;

  TPDFFonts = class(TObject)
  private
    FOwner: TPDFDocument;
    FFonts: TList;
    FLast: TPDFFont;
    FLastIndex: Integer;
    function GetCount: Integer;
    function GetFont(Index: Integer): TPDFFont;
    procedure EmbiddingFontFiles;
  public
    constructor Create(AOwner: TPDFDocument);
    destructor Destroy; override;
    procedure Delete(Index: Integer);
    procedure Clear;
    function Add: TPDFFont;
    function IndexOf(FontName: TFontName; FontStyle: TFontStyles; FontCharset: TFontCharset): Integer;
    function CheckFont(FontName: TFontName; FontStyle: TFontStyles; FontCharset: TFontCharset): string;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPDFFont read GetFont; default;
  end;

  TPDFImage = class(TObject)
  private
    FCT: TImageCompressionType;
    ImageName: string;
    PictureID: Integer;
    FHeight: Integer;
    FWidth: Integer;
    Data: TMemoryStream;
    FBitPerPixel: Integer;
    GrayScale: Boolean;
    Saved: Boolean;
    procedure Save(Doc: TPDFDocument);
  public
    constructor Create(Image: TGraphic; Compression: TImageCompressionType; Doc: TPDFDocument = nil); overload;
    constructor Create(FileName: TFileName; Compression: TImageCompressionType; Doc: TPDFDocument = nil); overload;
    destructor Destroy; override;
    property Height: Integer read FHeight;
    property Width: Integer read FWidth;
    property BitPerPixel: Integer read FBitPerPixel;
  end;

  TPDFImages = class(TObject)
  private
    FOwner: TPDFDocument;
    FImages: TList;
    function GetCount: Integer;
    function GetImage(Index: Integer): TPDFImage;
  public
    constructor Create(AOwner: TPDFDocument);
    destructor Destroy; override;
    procedure Delete(Index: Integer);
    procedure Clear;
    function Add(Image: TGraphic; Compression: TImageCompressionType): TPDFImage; overload;
    function Add(FileName: TFileName; Compression: TImageCompressionType): TPDFImage; overload;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TPDFImage read GetImage; default;
  end;

  TPDFDocument = class(TComponent)
  private
    IDOffset: array of Integer;
    CurID: Integer;
    EncriptID: Integer;
    PagesID: Integer;
    CatalogID: Integer;
    XREFOffset: Integer;
    FAcroForm: TPDFAcroForm;
    FFileName: TFileName;
    FPages: TPDFPages;
    FWaterMarks: TPDFPages;
    FActions: TPDFActions;
    FFonts: TPDFFonts;
    FImages: TPDFImages;
    FRadioGroups: TList;
    FStream: TStream;
    FCompression: TCompressionType;
    FDocumentInfo: TPDFDocInfo;
    FPageLayout: TPageLayout;
    FPageMode: TPageMode;
    FCurrentPage: TPDFPage;
    FOutlines: TPDFOutlines;
    FProtectionEnabled: Boolean;
    FUserPassword: string;
    FOwnerPassword: string;
    FProtectionOptions: TPDFCtiptoOptions;
    FKey: TEncripKey;
    FPFlags: Cardinal;
    FileID: string;
    FNotEmbeddedFont: TStringList;
    FOutputStream: TStream;
    FJPEGQuality: Integer;
    FPrinting: Boolean;
    FAborted: Boolean;
    FAutoLaunch: Boolean;
    FResolution: Integer;
    FViewerPreferences: TViewerPreferences;
    FOpenDocumentAction: TPDFAction;
    FACURL: Boolean;
    FOnePass: Boolean;
    FVersion: TPDFVersion;
    FDefaultCharset: TFontCharset;
    procedure SetDefaultCharset(const Value: TFontCharset);
    procedure CalcKey;
    procedure SaveXREF;
    procedure SaveTrailer;
    procedure SaveDocumentInfo;
    procedure SetFileName(const Value: TFileName);
    procedure SetCompression(const Value: TCompressionType);
    procedure SetDocumentInfo(const Value: TPDFDocInfo);
    procedure SaveToStream(st: string; CR: Boolean = True);
    function GetNextID: Integer;
    procedure SetPageLayout(const Value: TPageLayout);
    procedure SetPageMode(const Value: TPageMode);
    procedure SetOwnerPassword(const Value: string);
    procedure SetProtectionEnabled(const Value: Boolean);
    procedure SetProtectionOptions(const Value: TPDFCtiptoOptions);
    procedure SetUserPassword(const Value: string);
    procedure GenFileID;
    function CalcOwnerPassword: string;
    function CalcUserPassword: string;
    procedure SetNotEmbeddedFont(const Value: TStringList);
    function GetPageCount: Integer;
    function GetPage(Index: Integer): TPDFPage;
    procedure SetOutputStream(const Value: TStream);
    procedure SetJPEGQuality(const Value: Integer);
    procedure SetAutoLaunch(const Value: Boolean);
    function GetCanvas: TCanvas;
    function GetPageHeight: Integer;
    function GetPageNumber: Integer;
    function GetPageWidth: Integer;
    function GetWaterMark(Index: Integer): TPDFPage;
    procedure AppendAction(const Action: TPDFAction);
    procedure SetOpenDocumentAction(const Value: TPDFAction);
    procedure StartObj(var ID: Integer);
    procedure CloseHObj;
    procedure CloseObj;
    procedure StartStream;
    procedure CloseStream;
    procedure SetOnePass(const Value: Boolean);
    procedure ClearAll;
    procedure DeleteAllRadioGroups;
    function CreateRadioGroup(Name: string): TPDFRadioGroup;
    procedure SetVersion(const Value: TPDFVersion);
    procedure StoreDocument;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Abort;
    procedure BeginDoc;
    procedure EndDoc;
    procedure NewPage;
    procedure SetCurrentPage(Index: Integer);
    function GetCurrentPageIndex: Integer;
    function AddImage(Image: TGraphic; Compression: TImageCompressionType): Integer; overload;
    function AddImage(FileName: TFileName; Compression: TImageCompressionType): Integer; overload;
    function CreateWaterMark: Integer;
    function CreateAction(CClass: TPDFActionClass): TPDFAction;
    property OpenDocumentAction: TPDFAction read FOpenDocumentAction write SetOpenDocumentAction;
    property Outlines: TPDFOutlines read FOutlines;
    property CurrentPage: TPDFPage read FCurrentPage;
    property PageCount: Integer read GetPageCount;
    property Page[Index: Integer]: TPDFPage read GetPage; default;
    property WaterMark[Index: Integer]: TPDFPage read GetWaterMark;
    property Printing: Boolean read FPrinting;
    property Aborted: Boolean read FAborted;
    property Canvas: TCanvas read GetCanvas;
    property OutputStream: TStream read FOutputStream write SetOutputStream;
    property PageHeight: Integer read GetPageHeight;
    property PageWidth: Integer read GetPageWidth;
    property PageNumber: Integer read GetPageNumber;
  published
    property AutoLaunch: Boolean read FAutoLaunch write SetAutoLaunch;
    property FileName: TFileName read FFileName write SetFileName;
    property Compression: TCompressionType read FCompression write SetCompression;
    property DocumentInfo: TPDFDocInfo read FDocumentInfo write SetDocumentInfo;
    property PageLayout: TPageLayout read FPageLayout write SetPageLayout;
    property PageMode: TPageMode read FPageMode write SetPageMode;
    property ProtectionEnabled: Boolean read FProtectionEnabled write SetProtectionEnabled;
    property ProtectionOptions: TPDFCtiptoOptions read FProtectionOptions write SetProtectionOptions;
    property OwnerPassword: string read FOwnerPassword write SetOwnerPassword;
    property UserPassword: string read FUserPassword write SetUserPassword;
    property NonEmbeddedFont: TStringList read FNotEmbeddedFont write SetNotEmbeddedFont;
    property JPEGQuality: Integer read FJPEGQuality write SetJPEGQuality;
    property Resolution: Integer read FResolution write FResolution;
    property ViewerPreferences: TViewerPreferences read FViewerPreferences write FViewerPreferences;
    property AutoCreateURL: Boolean read FACURL write FACURL;
    property OnePass: Boolean read FOnePass write SetOnePass;
    property Version: TPDFVersion read FVersion write SetVersion;
    property DefaultCharset: TFontCharset read FDefaultCharset write SetDefaultCharset;
  end;

  GTypeItem = (gtiPen, gtiFont, gtiBrush);
  THTItem = record
    Handle: HGDIOBJ;
    Index: Cardinal;
    TP: GTypeItem;
  end;
  PHTItem = ^THTItem;


implementation

resourcestring
  SCCITTProcedureNotInited = 'CCITT Procedure not inited';
  SExportValuePresent = 'In this radiogroup such exportvalue present';
  SCannotSetEmptyExportValue = 'Cannot set empty export value for radiobutton';
  SNoSuchRadiogroupInThisDocument = 'No such radiogroup in this document';
  SCannotSetNegativeSize = 'Cannot set negative size';
  SCannotUseSuchCharset = 'Cannot use such charset';
  SCannotChangePageInOnePassMode = 'Cannot change page in one pass mode';
  SCannotAccessToPageInOnePassMode = 'Cannot access to page in One Pass mode';
  SCannotReceiveDataForFont = 'Cannot receive data for font ';
  SNotValidTrueTypeFont = 'Not valid true type font.';
  SAlreadyExists = ' already exists.';
  SPDFControlNamed = 'PDFControl Named ';
  SCannotCompressNotMonochromeImageViaCCITT = 'Cannot compress not monochrome image via CCITT';
  SFileNameCannotBeEmpty = 'FileName cannot be empty';
  SURLCannotBeEmpty = 'URL cannot be empty';
  STopOffsetCannotBeNegative = 'Top Offset cannot be negative';
  SPageIndexCannotBeNegative = 'PageIndex cannot be negative';
  SJavaScriptCannotBeEmpty = 'JavaScript cannot be empty';
  SAnnotationMustHaveTPDFPageAsOwner = 'Annotation must have TPDFPage as owner';
  SMetafileNotLoaded = 'Metafile not loaded';
  SOutlineNodeMustHaveOwner = 'Outline node must have owner';
  SImageWithSuchIndexNotCreatedYetForThisDocument = 'Image with such index not created yet for this document';
  SWatermarkCannotHaveThumbnail = 'Watermark cannot have thumbnail';
  SCannotCreateURLToWatermark = 'Cannot create URL to watermark';
  SCanvasForThisPageNotCreatedOrWasRemoved = 'Canvas for this page not created or was removed.';
  SWaterMarkWithSuchIndexNotCreatedYetForThisDocument = 'WaterMark with such index not created yet for this document';
  SWatermarkCannotHaveWatermark = 'Watermark cannot have watermark';
  SCanvasForThisPageAlreadyCreated = 'Canvas for this page already created';
  SPageInProgress = 'Page in progress';
  SCannotCreateLinkToPageToWatermark = 'Cannot create "Link To Page" to watermark';
  SCannotCreateAnnotationToWatermark = 'Cannot create annotation to watermark';
  SActiveFontNotSetting = 'Active font not setting';
  SOutOfRange = 'Out of range';
  STextObjectNotInited = 'Text object not inited';
  STextObjectInited = 'Text object inited';
  SCannotBeginTextObjectTwice = 'Cannot begin text object twice';
  SGenerationPDFFileNotActivated = 'Generation PDF file not activated';
  SGenerationPDFFileInProgress = 'Generation PDF file in progress';
  SBitmapNotMonochrome = 'Bitmap not monochrome';
  SInvalidStreamOperation = 'Invalid stream operation';
  SCompressionError = 'Compression error';
  SRC4InvalidKeyLength = 'RC4: Invalid key length';

const
  PassKey: array[1..32] of Byte = ($28, $BF, $4E, $5E, $4E, $75, $8A, $41, $64, $00, $4E,
    $56, $FF, $FA, $01, $08, $2E, $2E, $00, $B6, $D0, $68,
    $3E, $80, $2F, $0C, $A9, $FE, $64, $53, $69, $7A);

type
  Gliph = record
    UnicodeID: Word;
    Name: string[20];
  end;
  PByteArray = ^TByteArray;
  TByteArray = array[0..MaxInt - 1] of Byte;

  TPDFPen = record
    lopnStyle: UINT;
    lopnWidth: Extended;
    lopnColor: COLORREF;
  end;

  TEMWParser = class
  private
    CurWidth: array[0..255] of Integer;
    FPage: TPDFPage;
    Cal: Extended;
    BM: TBitmap;
    MS: TMemoryStream;
    GObjs: TList;
    CV: Pointer;
    CurVal: TPoint;
    PolyFIllMode: Boolean;
    BGMode: Boolean;
    TextColor: Cardinal;
    BGColor: Cardinal;
    VertMode: TVertJust;
    HorMode: THorJust;
    UpdatePos: Boolean;
    Clipping: Boolean;
    CCW: Boolean;
    CPen: TPDFPen;
    CBrush: TLogBrush;
    CFont: TLogFont;
    CurFill: Cardinal;
    ClipRect: TRect;
    isCR: Boolean;
    FInText: Boolean;
    FInPath: Boolean;
    MFH: THandle;
    SBM: Integer;
    com: Integer;
    DDC: Boolean;
    IsNullBrush: Boolean;
    CWPS: TSize;
    CurRec: Integer;
    RE: TRect;
    FCha: Boolean;
    FCCha: Boolean;
    BCha: Boolean;
    PCha: Boolean;
    XOff, YOff, XScale, YScale: Extended;
    procedure PStroke;
    procedure PFillAndStroke;
    function GetTextWidth(Text: string): Extended;
    function GX(Value: Extended): Extended;
    function GY(Value: Extended): Extended;

    procedure SetCurFont;

    procedure DoSetWindowExtEx;
    procedure DoSetWindowOrgEx;
    procedure DoSetViewPortExtEx;
    procedure DoSetViewPortOrgEx;

    procedure DoPolyBezier; //
    procedure DoPolygon; //
    procedure DoPolyLine; //
    procedure DoPolyBezierTo; //
    procedure DoPolyLineTo; //
    procedure DoPolyPolyLine; //
    procedure DoPolyPolyGon; //
    procedure DoSetBKMode; //
    procedure DoSetPolyFillMode; //
    procedure DoSetTextAlign; //
    procedure DoSetTextColor; //
    procedure DoSetBKColor; //
    procedure DoMoveToEx; //
    procedure DoSetPixelV; //
    procedure DoInterSectClipRect; //
    procedure DoSaveDC; //
    procedure DoRestoreDC; //

    procedure DoSetWorldTransform; //
    procedure DoModifyWorldTransform;

    procedure DoSelectObject; //
    procedure DoCreatePen; //
    procedure DoCreateBrushInDirect; //
    procedure DoDeleteObject; //
    procedure DoAngleArc; //
    procedure DoEllipse; //
    procedure DoRectangle; //
    procedure DoRoundRect; //
    procedure DoArc; //
    procedure DoChord; //
    procedure DoPie; //
    procedure DoLineTo; //
    procedure DoArcTo; //
    procedure DoPolyDraw; //
    procedure DoSetArcDirection; //
    procedure DoSetMiterLimit; //
    procedure DoBeginPath; //
    procedure DoEndPath; //
    procedure DoCloseFigure; //
    procedure DoFillPath; //
    procedure DoStrokeAndFillPath; //
    procedure DoStrokePath; //
    procedure DoSelectClipPath; //
    procedure DoAbortPath; //
    procedure DoSetDibitsToDevice;
    procedure DoStretchDiBits;
    procedure DoCreateFontInDirectW; //

    procedure DoExtTextOutA; //
    procedure DoExtTextOutW; //

    procedure DoPolyBezier16; //
    procedure DoPolygon16; //
    procedure DoPolyLine16; //
    procedure DoPolyBezierTo16; //
    procedure DoPolyLineTo16; //
    procedure DoPolyPolyLine16; //
    procedure DoPolyPolygon16; //
    procedure DoPolyDraw16; //
    procedure DoSetTextJustification; //
    procedure DoExtCreatePen; //
    procedure DoExcludeClipRect;
    procedure DoBitBlt;
    procedure DoSetStretchBltMode;
    procedure DoStretchBlt;
    procedure SetInPath(const Value: Boolean);
    procedure SetInText(const Value: Boolean);
    procedure SetBrushColor;
    procedure SetPenColor;
    procedure SetFontColor;
    procedure SetBGColor;
  protected
    property InText: Boolean read FInText write SetInText;
    property InPath: Boolean read FInPath write SetInPath;
  public
    constructor Create(APage: TPDFPage);
    procedure LoadMetaFile(MF: TMetafile);
    procedure Execute;
    function GetMax: TSize;
    destructor Destroy; override;
  end;


type
  TableEntry = record
    Length: Byte;
    Code: Byte;
    RunLen: SmallInt;
  end;
  Codes = array[0..108] of TableEntry;
  TTag = (G3_1D, G3_2D);
const
  EOL = 1;
  G3CODE_EOL = -1;
  G3CODE_INVALID = -2;
  G3CODE_EOF = -3;
  G3CODE_INCOMP = -4;
  WhiteCodes: Codes =
  ((Length: 8; Code: $35; RunLen: 0), (Length: 6; Code: $7; RunLen: 1), (Length: 4; Code: $7; RunLen: 2),
    (Length: 4; Code: $8; RunLen: 3), (Length: 4; Code: $B; RunLen: 4), (Length: 4; Code: $C; RunLen: 5),
    (Length: 4; Code: $E; RunLen: 6), (Length: 4; Code: $F; RunLen: 7), (Length: 5; Code: $13; RunLen: 8),
    (Length: 5; Code: $14; RunLen: 9), (Length: 5; Code: $7; RunLen: 10), (Length: 5; Code: $8; RunLen: 11),
    (Length: 6; Code: $8; RunLen: 12), (Length: 6; Code: $3; RunLen: 13), (Length: 6; Code: $34; RunLen: 14),
    (Length: 6; Code: $35; RunLen: 15), (Length: 6; Code: $2A; RunLen: 16), (Length: 6; Code: $2B; RunLen: 17),
    (Length: 7; Code: $27; RunLen: 18), (Length: 7; Code: $C; RunLen: 19), (Length: 7; Code: $8; RunLen: 20),
    (Length: 7; Code: $17; RunLen: 21), (Length: 7; Code: $3; RunLen: 22), (Length: 7; Code: $4; RunLen: 23),
    (Length: 7; Code: $28; RunLen: 24), (Length: 7; Code: $2B; RunLen: 25), (Length: 7; Code: $13; RunLen: 26),
    (Length: 7; Code: $24; RunLen: 27), (Length: 7; Code: $18; RunLen: 28), (Length: 8; Code: $2; RunLen: 29),
    (Length: 8; Code: $3; RunLen: 30), (Length: 8; Code: $1A; RunLen: 31), (Length: 8; Code: $1B; RunLen: 32),
    (Length: 8; Code: $12; RunLen: 33), (Length: 8; Code: $13; RunLen: 34), (Length: 8; Code: $14; RunLen: 35),
    (Length: 8; Code: $15; RunLen: 36), (Length: 8; Code: $16; RunLen: 37), (Length: 8; Code: $17; RunLen: 38),
    (Length: 8; Code: $28; RunLen: 39), (Length: 8; Code: $29; RunLen: 40), (Length: 8; Code: $2A; RunLen: 41),
    (Length: 8; Code: $2B; RunLen: 42), (Length: 8; Code: $2C; RunLen: 43), (Length: 8; Code: $2D; RunLen: 44),
    (Length: 8; Code: $4; RunLen: 45), (Length: 8; Code: $5; RunLen: 46), (Length: 8; Code: $A; RunLen: 47),
    (Length: 8; Code: $B; RunLen: 48), (Length: 8; Code: $52; RunLen: 49), (Length: 8; Code: $53; RunLen: 50),
    (Length: 8; Code: $54; RunLen: 51), (Length: 8; Code: $55; RunLen: 52), (Length: 8; Code: $24; RunLen: 53),
    (Length: 8; Code: $25; RunLen: 54), (Length: 8; Code: $58; RunLen: 55), (Length: 8; Code: $59; RunLen: 56),
    (Length: 8; Code: $5A; RunLen: 57), (Length: 8; Code: $5B; RunLen: 58), (Length: 8; Code: $4A; RunLen: 59),
    (Length: 8; Code: $4B; RunLen: 60), (Length: 8; Code: $32; RunLen: 61), (Length: 8; Code: $33; RunLen: 62),
    (Length: 8; Code: $34; RunLen: 63), (Length: 5; Code: $1B; RunLen: 64), (Length: 5; Code: $12; RunLen: 128),
    (Length: 6; Code: $17; RunLen: 192), (Length: 7; Code: $37; RunLen: 256), (Length: 8; Code: $36; RunLen: 320),
    (Length: 8; Code: $37; RunLen: 384), (Length: 8; Code: $64; RunLen: 448), (Length: 8; Code: $65; RunLen: 512),
    (Length: 8; Code: $68; RunLen: 576), (Length: 8; Code: $67; RunLen: 640), (Length: 9; Code: $CC; RunLen: 704),
    (Length: 9; Code: $CD; RunLen: 768), (Length: 9; Code: $D2; RunLen: 832), (Length: 9; Code: $D3; RunLen: 896),
    (Length: 9; Code: $D4; RunLen: 960), (Length: 9; Code: $D5; RunLen: 1024), (Length: 9; Code: $D6; RunLen: 1088),
    (Length: 9; Code: $D7; RunLen: 1152), (Length: 9; Code: $D8; RunLen: 1216), (Length: 9; Code: $D9; RunLen: 1280),
    (Length: 9; Code: $DA; RunLen: 1344), (Length: 9; Code: $DB; RunLen: 1408), (Length: 9; Code: $98; RunLen: 1472),
    (Length: 9; Code: $99; RunLen: 1536), (Length: 9; Code: $9A; RunLen: 1600), (Length: 6; Code: $18; RunLen: 1664),
    (Length: 9; Code: $9B; RunLen: 1728), (Length: 11; Code: $8; RunLen: 1792), (Length: 11; Code: $C; RunLen: 1856),
    (Length: 11; Code: $D; RunLen: 1920), (Length: 12; Code: $12; RunLen: 1984), (Length: 12; Code: $13; RunLen: 2048),
    (Length: 12; Code: $14; RunLen: 2112), (Length: 12; Code: $15; RunLen: 2176), (Length: 12; Code: $16; RunLen: 2240),
    (Length: 12; Code: $17; RunLen: 2304), (Length: 12; Code: $1C; RunLen: 2368), (Length: 12; Code: $1D; RunLen: 2432),
    (Length: 12; Code: $1E; RunLen: 2496), (Length: 12; Code: $1F; RunLen: 2560), (Length: 12; Code: $1; RunLen: G3Code_EOL),
    (Length: 9; Code: $1; RunLen: G3Code_INVALID), (Length: 10; Code: $1; RunLen: G3Code_INVALID), (Length: 11; Code: $1; RunLen: G3Code_INVALID),
    (Length: 12; Code: $0; RunLen: G3Code_INVALID));

  BlackCodes: Codes =
  ((Length: 10; Code: $37; RunLen: 0), (Length: 3; Code: $2; RunLen: 1), (Length: 2; Code: $3; RunLen: 2),
    (Length: 2; Code: $2; RunLen: 3), (Length: 3; Code: $3; RunLen: 4), (Length: 4; Code: $3; RunLen: 5),
    (Length: 4; Code: $2; RunLen: 6), (Length: 5; Code: $3; RunLen: 7), (Length: 6; Code: $5; RunLen: 8),
    (Length: 6; Code: $4; RunLen: 9), (Length: 7; Code: $4; RunLen: 10), (Length: 7; Code: $5; RunLen: 11),
    (Length: 7; Code: $7; RunLen: 12), (Length: 8; Code: $4; RunLen: 13), (Length: 8; Code: $7; RunLen: 14),
    (Length: 9; Code: $18; RunLen: 15), (Length: 10; Code: $17; RunLen: 16), (Length: 10; Code: $18; RunLen: 17),
    (Length: 10; Code: $8; RunLen: 18), (Length: 11; Code: $67; RunLen: 19), (Length: 11; Code: $68; RunLen: 20),
    (Length: 11; Code: $6C; RunLen: 21), (Length: 11; Code: $37; RunLen: 22), (Length: 11; Code: $28; RunLen: 23),
    (Length: 11; Code: $17; RunLen: 24), (Length: 11; Code: $18; RunLen: 25), (Length: 12; Code: $CA; RunLen: 26),
    (Length: 12; Code: $CB; RunLen: 27), (Length: 12; Code: $CC; RunLen: 28), (Length: 12; Code: $CD; RunLen: 29),
    (Length: 12; Code: $68; RunLen: 30), (Length: 12; Code: $69; RunLen: 31), (Length: 12; Code: $6A; RunLen: 32),
    (Length: 12; Code: $6B; RunLen: 33), (Length: 12; Code: $D2; RunLen: 34), (Length: 12; Code: $D3; RunLen: 35),
    (Length: 12; Code: $D4; RunLen: 36), (Length: 12; Code: $D5; RunLen: 37), (Length: 12; Code: $D6; RunLen: 38),
    (Length: 12; Code: $D7; RunLen: 39), (Length: 12; Code: $6C; RunLen: 40), (Length: 12; Code: $6D; RunLen: 41),
    (Length: 12; Code: $DA; RunLen: 42), (Length: 12; Code: $DB; RunLen: 43), (Length: 12; Code: $54; RunLen: 44),
    (Length: 12; Code: $55; RunLen: 45), (Length: 12; Code: $56; RunLen: 46), (Length: 12; Code: $57; RunLen: 47),
    (Length: 12; Code: $64; RunLen: 48), (Length: 12; Code: $65; RunLen: 49), (Length: 12; Code: $52; RunLen: 50),
    (Length: 12; Code: $53; RunLen: 51), (Length: 12; Code: $24; RunLen: 52), (Length: 12; Code: $37; RunLen: 53),
    (Length: 12; Code: $38; RunLen: 54), (Length: 12; Code: $27; RunLen: 55), (Length: 12; Code: $28; RunLen: 56),
    (Length: 12; Code: $58; RunLen: 57), (Length: 12; Code: $59; RunLen: 58), (Length: 12; Code: $2B; RunLen: 59),
    (Length: 12; Code: $2C; RunLen: 60), (Length: 12; Code: $5A; RunLen: 61), (Length: 12; Code: $66; RunLen: 62),
    (Length: 12; Code: $67; RunLen: 63), (Length: 10; Code: $F; RunLen: 64), (Length: 12; Code: $C8; RunLen: 128),
    (Length: 12; Code: $C9; RunLen: 192), (Length: 12; Code: $5B; RunLen: 256), (Length: 12; Code: $33; RunLen: 320),
    (Length: 12; Code: $34; RunLen: 384), (Length: 12; Code: $35; RunLen: 448), (Length: 13; Code: $6C; RunLen: 512),
    (Length: 13; Code: $6D; RunLen: 576), (Length: 13; Code: $4A; RunLen: 640), (Length: 13; Code: $4B; RunLen: 704),
    (Length: 13; Code: $4C; RunLen: 768), (Length: 13; Code: $4D; RunLen: 832), (Length: 13; Code: $72; RunLen: 896),
    (Length: 13; Code: $73; RunLen: 960), (Length: 13; Code: $74; RunLen: 1024), (Length: 13; Code: $75; RunLen: 1088),
    (Length: 13; Code: $76; RunLen: 1152), (Length: 13; Code: $77; RunLen: 1216), (Length: 13; Code: $52; RunLen: 1280),
    (Length: 13; Code: $53; RunLen: 1344), (Length: 13; Code: $54; RunLen: 1408), (Length: 13; Code: $55; RunLen: 1472),
    (Length: 13; Code: $5A; RunLen: 1536), (Length: 13; Code: $5B; RunLen: 1600), (Length: 13; Code: $64; RunLen: 1664),
    (Length: 13; Code: $65; RunLen: 1728), (Length: 11; Code: $8; RunLen: 1792), (Length: 11; Code: $C; RunLen: 1856),
    (Length: 11; Code: $D; RunLen: 1920), (Length: 12; Code: $12; RunLen: 1984), (Length: 12; Code: $13; RunLen: 2048),
    (Length: 12; Code: $14; RunLen: 2112), (Length: 12; Code: $15; RunLen: 2176), (Length: 12; Code: $16; RunLen: 2240),
    (Length: 12; Code: $17; RunLen: 2304), (Length: 12; Code: $1C; RunLen: 2368), (Length: 12; Code: $1D; RunLen: 2432),
    (Length: 12; Code: $1E; RunLen: 2496), (Length: 12; Code: $1F; RunLen: 2560), (Length: 12; Code: $1; RunLen: G3Code_EOL),
    (Length: 9; Code: $1; RunLen: G3Code_INVALID), (Length: 10; Code: $1; RunLen: G3Code_INVALID), (Length: 11; Code: $1; RunLen: G3Code_INVALID),
    (Length: 12; Code: $0; RunLen: G3Code_INVALID));

const horizcode: TableEntry = (Length: 3; Code: $1);
const passcode: TableEntry = (Length: 4; Code: $1);
const vcodes: array[0..6] of TableEntry = ((Length: 7; Code: $3), (Length: 6; Code: $3), (Length: 3; Code: $3),
    (Length: 1; Code: $1), (Length: 3; Code: $2), (Length: 6; Code: $2), (Length: 7; Code: $2));


  msbmask: array[0..8] of Byte = ($0, $01, $03, $07, $0F, $1F, $3F, $7F, $FF);
  zeroruns: array[0..255] of byte = (
    8, 7, 6, 6, 5, 5, 5, 5, 4, 4, 4, 4, 4, 4, 4, 4,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  oneruns: array[0..255] of byte = (
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 7, 8);



type


  TCCITTCompression = class(TObject)
  private
    Bit: Byte;
    Data: Byte;
    RowBytes: Integer;
    RowPixels: Integer;
    FStream: TStream;
    FCT: TCCITT;
    Tag: TTag;
    K, MaxK: Integer;
    Refline: PByte;
    procedure FlushBits;
    procedure PutBits(Bits, Length: Byte);
    procedure PutSpan(Span: Integer; C: Codes);
    function Find0Span(BP: PByte; BS, BE: Integer): Integer;
    function Find1Span(BP: PByte; BS, BE: Integer): Integer;
    function FindDiff(BP: PByte; BS, BE: Integer; Color: Integer): Integer;
    function FindDiff2(BP: PByte; BS, BE: Integer; Color: Integer): Integer;
    function Encode1DRow(BP: PByte; Bits: Integer): Boolean;
    function Encode2DRow(BP, RP: PByte; Bits: Integer): Boolean;
    function is2DEncoding: Boolean;
  public
    procedure Execute(B: TBitmap);
    property Stream: TStream read FStream write FStream;
    property CompressionType: TCCITT read FCT write FCT;
  end;


{ TCCITTCompression }


function TCCITTCompression.Encode1DRow(BP: PByte; Bits: Integer): Boolean;
var
  Span, BS: Integer;
begin
  BS := 0;
  Result := True;
  repeat
    Span := find0span(BP, BS, Bits);
    putspan(Span, WhiteCodes);
    Inc(BS, Span);
    if bs >= Bits then Break;
    Span := find1span(BP, BS, Bits);
    putspan(Span, BlackCodes);
    Inc(BS, Span);
    if bs >= Bits then Break;
  until False;
end;

function TCCITTCompression.Encode2DRow(BP, RP: PByte; Bits: Integer): Boolean;
var
  a0, a1, b1, a2, b2, d: Integer;
  function Pixel(P: PByte; ix: Integer): byte;
  begin
    Inc(P, ix shr 3);
    Result := (p^ shr (7 - (ix and 7))) and 1;
  end;
begin
  Result := True;
  a0 := 0;
  if Pixel(BP, 0) <> 0 then
    a1 := 0 else a1 := finddiff(BP, 0, Bits, 0);
  if Pixel(RP, 0) <> 0 then
    b1 := 0 else b1 := finddiff(RP, 0, Bits, 0);
  repeat
    b2 := finddiff2(rp, b1, bits, PIXEL(rp, b1));
    if b2 >= a1 then
    begin
      d := b1 - a1;
      if not ((d >= -1) and (d <= 3)) then
      begin
        a2 := finddiff2(bp, a1, bits, PIXEL(bp, a1));
        PutBits(horizcode.Code, horizcode.Length);
        if ((a0 + a1 = 0) or (PIXEL(bp, a0) = 0)) then
        begin
          putspan(a1 - a0, WhiteCodes);
          putspan(a2 - a1, BlackCodes);
        end
        else
        begin
          putspan(a1 - a0, BlackCodes);
          putspan(a2 - a1, WhiteCodes);
        end;
        a0 := a2;
      end
      else
      begin
        PutBits(vcodes[d + 3].Code, vcodes[d + 3].Length);
        a0 := a1;
      end
    end
    else
    begin
      PutBits(passcode.Code, passcode.Length);
      a0 := b2;
    end;
    if a0 >= Bits then Break;
    a1 := finddiff(bp, a0, bits, PIXEL(bp, a0));
    b1 := finddiff(rp, a0, bits, (not PIXEL(bp, a0)) and 1);
    b1 := finddiff(rp, b1, bits, PIXEL(bp, a0));
  until False;
end;

procedure TCCITTCompression.Execute(B: TBitmap);
var
  P, L, M: PByte;
  i, j: Integer;
begin
  if FStream = nil then
    raise Exception.Create('Not set output stream.');
  if B.PixelFormat <> pf1bit then
    raise Exception.Create('Not b/w image.');
  if (B.Width = 0) or (B.Height = 0) then Exit;
  RowPixels := B.Width;
  RowBytes := (B.Width + 7) shr 3;
  GetMem(P, RowBytes);
  try
    if FCT <> ccitt31d then
      GetMem(Refline, RowBytes) else Refline := nil;
    try
      Bit := 8;
      Data := 0;
      Tag := G3_1D;
      if Refline <> nil then
        FillChar(Refline^, RowBytes, 0);
      if is2DEncoding then
      begin
        k := 2;
        maxk := 2;
      end else
      begin
        k := 0;
        maxk := 0;
      end;
      for i := 0 to B.Height - 1 do
      begin
        L := P;
        M := B.ScanLine[i];
        for j := 0 to RowBytes - 1 do
        begin
          L^ := not M^;
          Inc(L);
          Inc(M);
        end;
        case FCT of
          CCITT42D:
            begin
              if not Encode2DRow(P, Refline, RowPixels) then
                raise Exception.Create('Error');
              Move(P^, refline^, RowBytes);
            end;
          CCITT31D:
            begin
              if not Encode1DRow(P, RowPixels) then
                raise Exception.Create('Error');
            end;
          CCITT32D:
            begin
              PutBits(1, 12);
              PutBits(0, 1);
              if not Encode2DRow(P, Refline, RowPixels) then
                raise Exception.Create('Error');
              Move(P^, refline^, RowBytes);
            end;
        end;
      end;
      if FCT = CCITT42D then
      begin
        PutBits(EOL, 12);
        PutBits(EOL, 12);
      end;
      if bit <> 8 then FlushBits;
    finally
      if Refline <> nil then FreeMem(Refline);
    end;
  finally
    FreeMem(P);
  end;
end;

function TCCITTCompression.Find0Span(BP: PByte; BS, BE: Integer): Integer;
var
  Bits: Integer;
  Span, N: Integer;
begin
  Bits := BE - BS;
  Inc(BP, bs shr 3);
  n := (bs and 7);
  if (bits > 0) and (Boolean(N)) then
  begin
    span := zeroruns[(bp^ shl n) and $FF];
    if (span > 8 - n) then span := 8 - n;
    if (span > bits) then span := bits;
    if (n + span < 8) then
    begin
      Result := span;
      Exit;
    end;
    Dec(Bits, Span);
    Inc(BP);
  end
  else span := 0;
  while bits >= 8 do
  begin
    if BP^ <> 0 then
    begin
      Result := span + zeroruns[bp^];
      Exit;
    end;
    Inc(Span, 8);
    Dec(Bits, 8);
    Inc(BP);
  end;
  if bits > 0 then
  begin
    n := zeroruns[bp^];
    if N > Bits then Inc(Span, Bits) else Inc(Span, N);
  end;
  Result := span;
end;

function TCCITTCompression.Find1Span(BP: PByte; BS, BE: Integer): Integer;
var
  Bits: Integer;
  Span, N: Integer;
begin
  Bits := BE - BS;
  Inc(BP, bs shr 3);
  n := (bs and 7);
  if (bits > 0) and (Boolean(N)) then
  begin
    span := oneruns[(bp^ shl n) and $FF];
    if (span > 8 - n) then span := 8 - n;
    if (span > bits) then span := bits;
    if (n + span < 8) then
    begin
      Result := span;
      Exit;
    end;
    Dec(Bits, Span);
    Inc(BP);
  end
  else span := 0;
  while bits >= 8 do
  begin
    if BP^ <> $FF then
    begin
      Result := span + oneruns[bp^];
      Exit;
    end;
    Inc(Span, 8);
    Dec(Bits, 8);
    Inc(BP);
  end;
  if bits > 0 then
  begin
    n := oneruns[bp^];
    if N > Bits then Inc(Span, Bits) else Inc(Span, N);
  end;
  Result := span;
end;

function TCCITTCompression.FindDiff(BP: PByte; BS, BE: Integer;
  Color: Integer): Integer;
begin
  if Color = 0 then
    Result := BS + Find0Span(BP, BS, BE) else Result := BS + Find1Span(BP, BS, BE);
end;

function TCCITTCompression.FindDiff2(BP: PByte; BS, BE: Integer;
  Color: Integer): Integer;
begin
  if BS < BE then Result := Finddiff(BP, BS, BE, Color) else Result := BE;
end;

procedure TCCITTCompression.FlushBits;
begin
  FStream.Write(Data, 1);
  Data := 0;
  Bit := 8;
end;

function TCCITTCompression.is2DEncoding: Boolean;
begin
  Result := (FCT = CCITT32D) or (FCT = CCITT42D);
end;

procedure TCCITTCompression.PutBits(Bits, Length: Byte);
begin
  while Length > Bit do
  begin
    Data := Data or (Bits shr (Length - Bit));
    Length := Length - Bit;
    FlushBits;
  end;
  Data := Data or ((Bits and msbmask[Length]) shl (Bit - Length));
  Dec(Bit, Length);
  if Bit = 0 then FlushBits;
end;

procedure TCCITTCompression.PutSpan(Span: Integer; C: Codes);
var
  Code, Length: Byte;
begin
  while span >= 2624 do
  begin
    Code := C[63 + (2560 shr 6)].Code;
    Length := C[63 + (2560 shr 6)].Length;
    PutBits(Code, Length);
    Dec(Span, C[63 + (2560 shr 6)].RunLen);
  end;
  if Span >= 64 then
  begin
    Code := C[63 + (Span shr 6)].Code;
    Length := C[63 + (Span shr 6)].Length;
    PutBits(Code, Length);
    Dec(Span, C[63 + (Span shr 6)].RunLen);
  end;
  Code := C[Span].Code;
  Length := C[Span].Length;
  PutBits(Code, Length);
end;



procedure SaveBMPtoCCITT(BM: TBitmap; AStream: TStream; CCITT: TCCITT);
var
  CC: TCCITTCompression;
begin
  CC := TCCITTCompression.Create;
  try
    CC.CompressionType := CCITT;
    CC.Stream := AStream;
    CC.Execute(BM);
  finally
    CC.Free;
  end;
end;



const
  AllGliph: array[0..1050] of Gliph = (
    (UnicodeID: $0041; Name: 'A'), (UnicodeID: $00C6; Name: 'AE'), (UnicodeID: $01FC; Name: 'AEacute'), (UnicodeID: $F7E6; Name: 'AEsmall'), (UnicodeID: $00C1; Name: 'Aacute'), (UnicodeID: $F7E1; Name: 'Aacutesmall'), (UnicodeID: $0102; Name: 'Abreve'), (UnicodeID: $00C2; Name: 'Acircumflex'), (UnicodeID: $F7E2; Name: 'Acircumflexsmall'),
    (UnicodeID: $F6C9; Name: 'Acute'), (UnicodeID: $F7B4; Name: 'Acutesmall'), (UnicodeID: $00C4; Name: 'Adieresis'), (UnicodeID: $F7E4; Name: 'Adieresissmall'), (UnicodeID: $00C0; Name: 'Agrave'), (UnicodeID: $F7E0; Name: 'Agravesmall'), (UnicodeID: $0391; Name: 'Alpha'), (UnicodeID: $0386; Name: 'Alphatonos'),
    (UnicodeID: $0100; Name: 'Amacron'), (UnicodeID: $0104; Name: 'Aogonek'), (UnicodeID: $00C5; Name: 'Aring'), (UnicodeID: $01FA; Name: 'Aringacute'), (UnicodeID: $F7E5; Name: 'Aringsmall'), (UnicodeID: $F761; Name: 'Asmall'), (UnicodeID: $00C3; Name: 'Atilde'), (UnicodeID: $F7E3; Name: 'Atildesmall'),
    (UnicodeID: $0042; Name: 'B'), (UnicodeID: $0392; Name: 'Beta'), (UnicodeID: $F6F4; Name: 'Brevesmall'), (UnicodeID: $F762; Name: 'Bsmall'), (UnicodeID: $0043; Name: 'C'), (UnicodeID: $0106; Name: 'Cacute'), (UnicodeID: $F6CA; Name: 'Caron'), (UnicodeID: $F6F5; Name: 'Caronsmall'),
    (UnicodeID: $010C; Name: 'Ccaron'), (UnicodeID: $00C7; Name: 'Ccedilla'), (UnicodeID: $F7E7; Name: 'Ccedillasmall'), (UnicodeID: $0108; Name: 'Ccircumflex'), (UnicodeID: $010A; Name: 'Cdotaccent'), (UnicodeID: $F7B8; Name: 'Cedillasmall'), (UnicodeID: $03A7; Name: 'Chi'), (UnicodeID: $F6F6; Name: 'Circumflexsmall'),
    (UnicodeID: $F763; Name: 'Csmall'), (UnicodeID: $0044; Name: 'D'), (UnicodeID: $010E; Name: 'Dcaron'), (UnicodeID: $0110; Name: 'Dcroat'), (UnicodeID: $2206; Name: 'Delta'), (UnicodeID: $0394; Name: 'Delta'), (UnicodeID: $F6CB; Name: 'Dieresis'), (UnicodeID: $F6CC; Name: 'DieresisAcute'),
    (UnicodeID: $F6CD; Name: 'DieresisGrave'), (UnicodeID: $F7A8; Name: 'Dieresissmall'), (UnicodeID: $F6F7; Name: 'Dotaccentsmall'), (UnicodeID: $F764; Name: 'Dsmall'), (UnicodeID: $0045; Name: 'E'), (UnicodeID: $00C9; Name: 'Eacute'), (UnicodeID: $F7E9; Name: 'Eacutesmall'), (UnicodeID: $0114; Name: 'Ebreve'),
    (UnicodeID: $011A; Name: 'Ecaron'), (UnicodeID: $00CA; Name: 'Ecircumflex'), (UnicodeID: $F7EA; Name: 'Ecircumflexsmall'), (UnicodeID: $00CB; Name: 'Edieresis'), (UnicodeID: $F7EB; Name: 'Edieresissmall'), (UnicodeID: $0116; Name: 'Edotaccent'), (UnicodeID: $00C8; Name: 'Egrave'), (UnicodeID: $F7E8; Name: 'Egravesmall'),
    (UnicodeID: $0112; Name: 'Emacron'), (UnicodeID: $014A; Name: 'Eng'), (UnicodeID: $0118; Name: 'Eogonek'), (UnicodeID: $0395; Name: 'Epsilon'), (UnicodeID: $0388; Name: 'Epsilontonos'), (UnicodeID: $F765; Name: 'Esmall'), (UnicodeID: $0397; Name: 'Eta'), (UnicodeID: $0389; Name: 'Etatonos'),
    (UnicodeID: $00D0; Name: 'Eth'), (UnicodeID: $F7F0; Name: 'Ethsmall'), (UnicodeID: $20AC; Name: 'Euro'), (UnicodeID: $0046; Name: 'F'), (UnicodeID: $F766; Name: 'Fsmall'), (UnicodeID: $0047; Name: 'G'), (UnicodeID: $0393; Name: 'Gamma'), (UnicodeID: $011E; Name: 'Gbreve'),
    (UnicodeID: $01E6; Name: 'Gcaron'), (UnicodeID: $011C; Name: 'Gcircumflex'), (UnicodeID: $0122; Name: 'Gcommaaccent'), (UnicodeID: $0120; Name: 'Gdotaccent'), (UnicodeID: $F6CE; Name: 'Grave'), (UnicodeID: $F760; Name: 'Gravesmall'), (UnicodeID: $F767; Name: 'Gsmall'), (UnicodeID: $0048; Name: 'H'),
    (UnicodeID: $25CF; Name: 'H18533'), (UnicodeID: $25AA; Name: 'H18543'), (UnicodeID: $25AB; Name: 'H18551'), (UnicodeID: $25A1; Name: 'H22073'), (UnicodeID: $0126; Name: 'Hbar'), (UnicodeID: $0124; Name: 'Hcircumflex'), (UnicodeID: $F768; Name: 'Hsmall'), (UnicodeID: $F6CF; Name: 'Hungarumlaut'),
    (UnicodeID: $F6F8; Name: 'Hungarumlautsmall'), (UnicodeID: $0049; Name: 'I'), (UnicodeID: $0132; Name: 'IJ'), (UnicodeID: $00CD; Name: 'Iacute'), (UnicodeID: $F7ED; Name: 'Iacutesmall'), (UnicodeID: $012C; Name: 'Ibreve'), (UnicodeID: $00CE; Name: 'Icircumflex'), (UnicodeID: $F7EE; Name: 'Icircumflexsmall'),
    (UnicodeID: $00CF; Name: 'Idieresis'), (UnicodeID: $F7EF; Name: 'Idieresissmall'), (UnicodeID: $0130; Name: 'Idotaccent'), (UnicodeID: $2111; Name: 'Ifraktur'), (UnicodeID: $00CC; Name: 'Igrave'), (UnicodeID: $F7EC; Name: 'Igravesmall'), (UnicodeID: $012A; Name: 'Imacron'), (UnicodeID: $012E; Name: 'Iogonek'),
    (UnicodeID: $0399; Name: 'Iota'), (UnicodeID: $03AA; Name: 'Iotadieresis'), (UnicodeID: $038A; Name: 'Iotatonos'), (UnicodeID: $F769; Name: 'Ismall'), (UnicodeID: $0128; Name: 'Itilde'), (UnicodeID: $004A; Name: 'J'), (UnicodeID: $0134; Name: 'Jcircumflex'), (UnicodeID: $F76A; Name: 'Jsmall'),
    (UnicodeID: $004B; Name: 'K'), (UnicodeID: $039A; Name: 'Kappa'), (UnicodeID: $0136; Name: 'Kcommaaccent'), (UnicodeID: $F76B; Name: 'Ksmall'), (UnicodeID: $004C; Name: 'L'), (UnicodeID: $F6BF; Name: 'LL'), (UnicodeID: $0139; Name: 'Lacute'), (UnicodeID: $039B; Name: 'Lambda'),
    (UnicodeID: $013D; Name: 'Lcaron'), (UnicodeID: $013B; Name: 'Lcommaaccent'), (UnicodeID: $013F; Name: 'Ldot'), (UnicodeID: $0141; Name: 'Lslash'), (UnicodeID: $F6F9; Name: 'Lslashsmall'), (UnicodeID: $F76C; Name: 'Lsmall'), (UnicodeID: $004D; Name: 'M'), (UnicodeID: $F6D0; Name: 'Macron'),
    (UnicodeID: $F7AF; Name: 'Macronsmall'), (UnicodeID: $F76D; Name: 'Msmall'), (UnicodeID: $039C; Name: 'Mu'), (UnicodeID: $004E; Name: 'N'), (UnicodeID: $0143; Name: 'Nacute'), (UnicodeID: $0147; Name: 'Ncaron'), (UnicodeID: $0145; Name: 'Ncommaaccent'), (UnicodeID: $F76E; Name: 'Nsmall'),
    (UnicodeID: $00D1; Name: 'Ntilde'), (UnicodeID: $F7F1; Name: 'Ntildesmall'), (UnicodeID: $039D; Name: 'Nu'), (UnicodeID: $004F; Name: 'O'), (UnicodeID: $0152; Name: 'OE'), (UnicodeID: $F6FA; Name: 'OEsmall'), (UnicodeID: $00D3; Name: 'Oacute'), (UnicodeID: $F7F3; Name: 'Oacutesmall'),
    (UnicodeID: $014E; Name: 'Obreve'), (UnicodeID: $00D4; Name: 'Ocircumflex'), (UnicodeID: $F7F4; Name: 'Ocircumflexsmall'), (UnicodeID: $00D6; Name: 'Odieresis'), (UnicodeID: $F7F6; Name: 'Odieresissmall'), (UnicodeID: $F6FB; Name: 'Ogoneksmall'), (UnicodeID: $00D2; Name: 'Ograve'), (UnicodeID: $F7F2; Name: 'Ogravesmall'),
    (UnicodeID: $01A0; Name: 'Ohorn'), (UnicodeID: $0150; Name: 'Ohungarumlaut'), (UnicodeID: $014C; Name: 'Omacron'), (UnicodeID: $2126; Name: 'Omega'), (UnicodeID: $03A9; Name: 'Omega'), (UnicodeID: $038F; Name: 'Omegatonos'), (UnicodeID: $039F; Name: 'Omicron'), (UnicodeID: $038C; Name: 'Omicrontonos'),
    (UnicodeID: $00D8; Name: 'Oslash'), (UnicodeID: $01FE; Name: 'Oslashacute'), (UnicodeID: $F7F8; Name: 'Oslashsmall'), (UnicodeID: $F76F; Name: 'Osmall'), (UnicodeID: $00D5; Name: 'Otilde'), (UnicodeID: $F7F5; Name: 'Otildesmall'), (UnicodeID: $0050; Name: 'P'), (UnicodeID: $03A6; Name: 'Phi'),
    (UnicodeID: $03A0; Name: 'Pi'), (UnicodeID: $03A8; Name: 'Psi'), (UnicodeID: $F770; Name: 'Psmall'), (UnicodeID: $0051; Name: 'Q'), (UnicodeID: $F771; Name: 'Qsmall'), (UnicodeID: $0052; Name: 'R'), (UnicodeID: $0154; Name: 'Racute'), (UnicodeID: $0158; Name: 'Rcaron'),
    (UnicodeID: $0156; Name: 'Rcommaaccent'), (UnicodeID: $211C; Name: 'Rfraktur'), (UnicodeID: $03A1; Name: 'Rho'), (UnicodeID: $F6FC; Name: 'Ringsmall'), (UnicodeID: $F772; Name: 'Rsmall'), (UnicodeID: $0053; Name: 'S'), (UnicodeID: $250C; Name: 'SF010000'), (UnicodeID: $2514; Name: 'SF020000'),
    (UnicodeID: $2510; Name: 'SF030000'), (UnicodeID: $2518; Name: 'SF040000'), (UnicodeID: $253C; Name: 'SF050000'), (UnicodeID: $252C; Name: 'SF060000'), (UnicodeID: $2534; Name: 'SF070000'), (UnicodeID: $251C; Name: 'SF080000'), (UnicodeID: $2524; Name: 'SF090000'), (UnicodeID: $2500; Name: 'SF100000'),
    (UnicodeID: $2502; Name: 'SF110000'), (UnicodeID: $2561; Name: 'SF190000'), (UnicodeID: $2562; Name: 'SF200000'), (UnicodeID: $2556; Name: 'SF210000'), (UnicodeID: $2555; Name: 'SF220000'), (UnicodeID: $2563; Name: 'SF230000'), (UnicodeID: $2551; Name: 'SF240000'), (UnicodeID: $2557; Name: 'SF250000'),
    (UnicodeID: $255D; Name: 'SF260000'), (UnicodeID: $255C; Name: 'SF270000'), (UnicodeID: $255B; Name: 'SF280000'), (UnicodeID: $255E; Name: 'SF360000'), (UnicodeID: $255F; Name: 'SF370000'), (UnicodeID: $255A; Name: 'SF380000'), (UnicodeID: $2554; Name: 'SF390000'), (UnicodeID: $2569; Name: 'SF400000'),
    (UnicodeID: $2566; Name: 'SF410000'), (UnicodeID: $2560; Name: 'SF420000'), (UnicodeID: $2550; Name: 'SF430000'), (UnicodeID: $256C; Name: 'SF440000'), (UnicodeID: $2567; Name: 'SF450000'), (UnicodeID: $2568; Name: 'SF460000'), (UnicodeID: $2564; Name: 'SF470000'), (UnicodeID: $2565; Name: 'SF480000'),
    (UnicodeID: $2559; Name: 'SF490000'), (UnicodeID: $2558; Name: 'SF500000'), (UnicodeID: $2552; Name: 'SF510000'), (UnicodeID: $2553; Name: 'SF520000'), (UnicodeID: $256B; Name: 'SF530000'), (UnicodeID: $256A; Name: 'SF540000'), (UnicodeID: $015A; Name: 'Sacute'), (UnicodeID: $0160; Name: 'Scaron'),
    (UnicodeID: $F6FD; Name: 'Scaronsmall'), (UnicodeID: $015E; Name: 'Scedilla'), (UnicodeID: $F6C1; Name: 'Scedilla'), (UnicodeID: $015C; Name: 'Scircumflex'), (UnicodeID: $0218; Name: 'Scommaaccent'), (UnicodeID: $03A3; Name: 'Sigma'), (UnicodeID: $F773; Name: 'Ssmall'), (UnicodeID: $0054; Name: 'T'),
    (UnicodeID: $03A4; Name: 'Tau'), (UnicodeID: $0166; Name: 'Tbar'), (UnicodeID: $0164; Name: 'Tcaron'), (UnicodeID: $0162; Name: 'Tcommaaccent'), (UnicodeID: $021A; Name: 'Tcommaaccent'), (UnicodeID: $0398; Name: 'Theta'), (UnicodeID: $00DE; Name: 'Thorn'), (UnicodeID: $F7FE; Name: 'Thornsmall'),
    (UnicodeID: $F6FE; Name: 'Tildesmall'), (UnicodeID: $F774; Name: 'Tsmall'), (UnicodeID: $0055; Name: 'U'), (UnicodeID: $00DA; Name: 'Uacute'), (UnicodeID: $F7FA; Name: 'Uacutesmall'), (UnicodeID: $016C; Name: 'Ubreve'), (UnicodeID: $00DB; Name: 'Ucircumflex'), (UnicodeID: $F7FB; Name: 'Ucircumflexsmall'),
    (UnicodeID: $00DC; Name: 'Udieresis'), (UnicodeID: $F7FC; Name: 'Udieresissmall'), (UnicodeID: $00D9; Name: 'Ugrave'), (UnicodeID: $F7F9; Name: 'Ugravesmall'), (UnicodeID: $01AF; Name: 'Uhorn'), (UnicodeID: $0170; Name: 'Uhungarumlaut'), (UnicodeID: $016A; Name: 'Umacron'), (UnicodeID: $0172; Name: 'Uogonek'),
    (UnicodeID: $03A5; Name: 'Upsilon'), (UnicodeID: $03D2; Name: 'Upsilon1'), (UnicodeID: $03AB; Name: 'Upsilondieresis'), (UnicodeID: $038E; Name: 'Upsilontonos'), (UnicodeID: $016E; Name: 'Uring'), (UnicodeID: $F775; Name: 'Usmall'), (UnicodeID: $0168; Name: 'Utilde'), (UnicodeID: $0056; Name: 'V'),
    (UnicodeID: $F776; Name: 'Vsmall'), (UnicodeID: $0057; Name: 'W'), (UnicodeID: $1E82; Name: 'Wacute'), (UnicodeID: $0174; Name: 'Wcircumflex'), (UnicodeID: $1E84; Name: 'Wdieresis'), (UnicodeID: $1E80; Name: 'Wgrave'), (UnicodeID: $F777; Name: 'Wsmall'), (UnicodeID: $0058; Name: 'X'),
    (UnicodeID: $039E; Name: 'Xi'), (UnicodeID: $F778; Name: 'Xsmall'), (UnicodeID: $0059; Name: 'Y'), (UnicodeID: $00DD; Name: 'Yacute'), (UnicodeID: $F7FD; Name: 'Yacutesmall'), (UnicodeID: $0176; Name: 'Ycircumflex'), (UnicodeID: $0178; Name: 'Ydieresis'), (UnicodeID: $F7FF; Name: 'Ydieresissmall'),
    (UnicodeID: $1EF2; Name: 'Ygrave'), (UnicodeID: $F779; Name: 'Ysmall'), (UnicodeID: $005A; Name: 'Z'), (UnicodeID: $0179; Name: 'Zacute'), (UnicodeID: $017D; Name: 'Zcaron'), (UnicodeID: $F6FF; Name: 'Zcaronsmall'), (UnicodeID: $017B; Name: 'Zdotaccent'), (UnicodeID: $0396; Name: 'Zeta'),
    (UnicodeID: $F77A; Name: 'Zsmall'), (UnicodeID: $0061; Name: 'a'), (UnicodeID: $00E1; Name: 'aacute'), (UnicodeID: $0103; Name: 'abreve'), (UnicodeID: $00E2; Name: 'acircumflex'), (UnicodeID: $00B4; Name: 'acute'), (UnicodeID: $0301; Name: 'acutecomb'), (UnicodeID: $00E4; Name: 'adieresis'),
    (UnicodeID: $00E6; Name: 'ae'), (UnicodeID: $01FD; Name: 'aeacute'), (UnicodeID: $2015; Name: 'afii00208'), (UnicodeID: $0410; Name: 'afii10017'), (UnicodeID: $0411; Name: 'afii10018'), (UnicodeID: $0412; Name: 'afii10019'), (UnicodeID: $0413; Name: 'afii10020'), (UnicodeID: $0414; Name: 'afii10021'),
    (UnicodeID: $0415; Name: 'afii10022'), (UnicodeID: $0401; Name: 'afii10023'), (UnicodeID: $0416; Name: 'afii10024'), (UnicodeID: $0417; Name: 'afii10025'), (UnicodeID: $0418; Name: 'afii10026'), (UnicodeID: $0419; Name: 'afii10027'), (UnicodeID: $041A; Name: 'afii10028'), (UnicodeID: $041B; Name: 'afii10029'),
    (UnicodeID: $041C; Name: 'afii10030'), (UnicodeID: $041D; Name: 'afii10031'), (UnicodeID: $041E; Name: 'afii10032'), (UnicodeID: $041F; Name: 'afii10033'), (UnicodeID: $0420; Name: 'afii10034'), (UnicodeID: $0421; Name: 'afii10035'), (UnicodeID: $0422; Name: 'afii10036'), (UnicodeID: $0423; Name: 'afii10037'),
    (UnicodeID: $0424; Name: 'afii10038'), (UnicodeID: $0425; Name: 'afii10039'), (UnicodeID: $0426; Name: 'afii10040'), (UnicodeID: $0427; Name: 'afii10041'), (UnicodeID: $0428; Name: 'afii10042'), (UnicodeID: $0429; Name: 'afii10043'), (UnicodeID: $042A; Name: 'afii10044'), (UnicodeID: $042B; Name: 'afii10045'),
    (UnicodeID: $042C; Name: 'afii10046'), (UnicodeID: $042D; Name: 'afii10047'), (UnicodeID: $042E; Name: 'afii10048'), (UnicodeID: $042F; Name: 'afii10049'), (UnicodeID: $0490; Name: 'afii10050'), (UnicodeID: $0402; Name: 'afii10051'), (UnicodeID: $0403; Name: 'afii10052'), (UnicodeID: $0404; Name: 'afii10053'),
    (UnicodeID: $0405; Name: 'afii10054'), (UnicodeID: $0406; Name: 'afii10055'), (UnicodeID: $0407; Name: 'afii10056'), (UnicodeID: $0408; Name: 'afii10057'), (UnicodeID: $0409; Name: 'afii10058'), (UnicodeID: $040A; Name: 'afii10059'), (UnicodeID: $040B; Name: 'afii10060'), (UnicodeID: $040C; Name: 'afii10061'),
    (UnicodeID: $040E; Name: 'afii10062'), (UnicodeID: $F6C4; Name: 'afii10063'), (UnicodeID: $F6C5; Name: 'afii10064'), (UnicodeID: $0430; Name: 'afii10065'), (UnicodeID: $0431; Name: 'afii10066'), (UnicodeID: $0432; Name: 'afii10067'), (UnicodeID: $0433; Name: 'afii10068'), (UnicodeID: $0434; Name: 'afii10069'),
    (UnicodeID: $0435; Name: 'afii10070'), (UnicodeID: $0451; Name: 'afii10071'), (UnicodeID: $0436; Name: 'afii10072'), (UnicodeID: $0437; Name: 'afii10073'), (UnicodeID: $0438; Name: 'afii10074'), (UnicodeID: $0439; Name: 'afii10075'), (UnicodeID: $043A; Name: 'afii10076'), (UnicodeID: $043B; Name: 'afii10077'),
    (UnicodeID: $043C; Name: 'afii10078'), (UnicodeID: $043D; Name: 'afii10079'), (UnicodeID: $043E; Name: 'afii10080'), (UnicodeID: $043F; Name: 'afii10081'), (UnicodeID: $0440; Name: 'afii10082'), (UnicodeID: $0441; Name: 'afii10083'), (UnicodeID: $0442; Name: 'afii10084'), (UnicodeID: $0443; Name: 'afii10085'),
    (UnicodeID: $0444; Name: 'afii10086'), (UnicodeID: $0445; Name: 'afii10087'), (UnicodeID: $0446; Name: 'afii10088'), (UnicodeID: $0447; Name: 'afii10089'), (UnicodeID: $0448; Name: 'afii10090'), (UnicodeID: $0449; Name: 'afii10091'), (UnicodeID: $044A; Name: 'afii10092'), (UnicodeID: $044B; Name: 'afii10093'),
    (UnicodeID: $044C; Name: 'afii10094'), (UnicodeID: $044D; Name: 'afii10095'), (UnicodeID: $044E; Name: 'afii10096'), (UnicodeID: $044F; Name: 'afii10097'), (UnicodeID: $0491; Name: 'afii10098'), (UnicodeID: $0452; Name: 'afii10099'), (UnicodeID: $0453; Name: 'afii10100'), (UnicodeID: $0454; Name: 'afii10101'),
    (UnicodeID: $0455; Name: 'afii10102'), (UnicodeID: $0456; Name: 'afii10103'), (UnicodeID: $0457; Name: 'afii10104'), (UnicodeID: $0458; Name: 'afii10105'), (UnicodeID: $0459; Name: 'afii10106'), (UnicodeID: $045A; Name: 'afii10107'), (UnicodeID: $045B; Name: 'afii10108'), (UnicodeID: $045C; Name: 'afii10109'),
    (UnicodeID: $045E; Name: 'afii10110'), (UnicodeID: $040F; Name: 'afii10145'), (UnicodeID: $0462; Name: 'afii10146'), (UnicodeID: $0472; Name: 'afii10147'), (UnicodeID: $0474; Name: 'afii10148'), (UnicodeID: $F6C6; Name: 'afii10192'), (UnicodeID: $045F; Name: 'afii10193'), (UnicodeID: $0463; Name: 'afii10194'),
    (UnicodeID: $0473; Name: 'afii10195'), (UnicodeID: $0475; Name: 'afii10196'), (UnicodeID: $F6C7; Name: 'afii10831'), (UnicodeID: $F6C8; Name: 'afii10832'), (UnicodeID: $04D9; Name: 'afii10846'), (UnicodeID: $200E; Name: 'afii299'), (UnicodeID: $200F; Name: 'afii300'), (UnicodeID: $200D; Name: 'afii301'),
    (UnicodeID: $066A; Name: 'afii57381'), (UnicodeID: $060C; Name: 'afii57388'), (UnicodeID: $0660; Name: 'afii57392'), (UnicodeID: $0661; Name: 'afii57393'), (UnicodeID: $0662; Name: 'afii57394'), (UnicodeID: $0663; Name: 'afii57395'), (UnicodeID: $0664; Name: 'afii57396'), (UnicodeID: $0665; Name: 'afii57397'),
    (UnicodeID: $0666; Name: 'afii57398'), (UnicodeID: $0667; Name: 'afii57399'), (UnicodeID: $0668; Name: 'afii57400'), (UnicodeID: $0669; Name: 'afii57401'), (UnicodeID: $061B; Name: 'afii57403'), (UnicodeID: $061F; Name: 'afii57407'), (UnicodeID: $0621; Name: 'afii57409'), (UnicodeID: $0622; Name: 'afii57410'),
    (UnicodeID: $0623; Name: 'afii57411'), (UnicodeID: $0624; Name: 'afii57412'), (UnicodeID: $0625; Name: 'afii57413'), (UnicodeID: $0626; Name: 'afii57414'), (UnicodeID: $0627; Name: 'afii57415'), (UnicodeID: $0628; Name: 'afii57416'), (UnicodeID: $0629; Name: 'afii57417'), (UnicodeID: $062A; Name: 'afii57418'),
    (UnicodeID: $062B; Name: 'afii57419'), (UnicodeID: $062C; Name: 'afii57420'), (UnicodeID: $062D; Name: 'afii57421'), (UnicodeID: $062E; Name: 'afii57422'), (UnicodeID: $062F; Name: 'afii57423'), (UnicodeID: $0630; Name: 'afii57424'), (UnicodeID: $0631; Name: 'afii57425'), (UnicodeID: $0632; Name: 'afii57426'),
    (UnicodeID: $0633; Name: 'afii57427'), (UnicodeID: $0634; Name: 'afii57428'), (UnicodeID: $0635; Name: 'afii57429'), (UnicodeID: $0636; Name: 'afii57430'), (UnicodeID: $0637; Name: 'afii57431'), (UnicodeID: $0638; Name: 'afii57432'), (UnicodeID: $0639; Name: 'afii57433'), (UnicodeID: $063A; Name: 'afii57434'),
    (UnicodeID: $0640; Name: 'afii57440'), (UnicodeID: $0641; Name: 'afii57441'), (UnicodeID: $0642; Name: 'afii57442'), (UnicodeID: $0643; Name: 'afii57443'), (UnicodeID: $0644; Name: 'afii57444'), (UnicodeID: $0645; Name: 'afii57445'), (UnicodeID: $0646; Name: 'afii57446'), (UnicodeID: $0648; Name: 'afii57448'),
    (UnicodeID: $0649; Name: 'afii57449'), (UnicodeID: $064A; Name: 'afii57450'), (UnicodeID: $064B; Name: 'afii57451'), (UnicodeID: $064C; Name: 'afii57452'), (UnicodeID: $064D; Name: 'afii57453'), (UnicodeID: $064E; Name: 'afii57454'), (UnicodeID: $064F; Name: 'afii57455'), (UnicodeID: $0650; Name: 'afii57456'),
    (UnicodeID: $0651; Name: 'afii57457'), (UnicodeID: $0652; Name: 'afii57458'), (UnicodeID: $0647; Name: 'afii57470'), (UnicodeID: $06A4; Name: 'afii57505'), (UnicodeID: $067E; Name: 'afii57506'), (UnicodeID: $0686; Name: 'afii57507'), (UnicodeID: $0698; Name: 'afii57508'), (UnicodeID: $06AF; Name: 'afii57509'),
    (UnicodeID: $0679; Name: 'afii57511'), (UnicodeID: $0688; Name: 'afii57512'), (UnicodeID: $0691; Name: 'afii57513'), (UnicodeID: $06BA; Name: 'afii57514'), (UnicodeID: $06D2; Name: 'afii57519'), (UnicodeID: $06D5; Name: 'afii57534'), (UnicodeID: $20AA; Name: 'afii57636'), (UnicodeID: $05BE; Name: 'afii57645'),
    (UnicodeID: $05C3; Name: 'afii57658'), (UnicodeID: $05D0; Name: 'afii57664'), (UnicodeID: $05D1; Name: 'afii57665'), (UnicodeID: $05D2; Name: 'afii57666'), (UnicodeID: $05D3; Name: 'afii57667'), (UnicodeID: $05D4; Name: 'afii57668'), (UnicodeID: $05D5; Name: 'afii57669'), (UnicodeID: $05D6; Name: 'afii57670'),
    (UnicodeID: $05D7; Name: 'afii57671'), (UnicodeID: $05D8; Name: 'afii57672'), (UnicodeID: $05D9; Name: 'afii57673'), (UnicodeID: $05DA; Name: 'afii57674'), (UnicodeID: $05DB; Name: 'afii57675'), (UnicodeID: $05DC; Name: 'afii57676'), (UnicodeID: $05DD; Name: 'afii57677'), (UnicodeID: $05DE; Name: 'afii57678'),
    (UnicodeID: $05DF; Name: 'afii57679'), (UnicodeID: $05E0; Name: 'afii57680'), (UnicodeID: $05E1; Name: 'afii57681'), (UnicodeID: $05E2; Name: 'afii57682'), (UnicodeID: $05E3; Name: 'afii57683'), (UnicodeID: $05E4; Name: 'afii57684'), (UnicodeID: $05E5; Name: 'afii57685'), (UnicodeID: $05E6; Name: 'afii57686'),
    (UnicodeID: $05E7; Name: 'afii57687'), (UnicodeID: $05E8; Name: 'afii57688'), (UnicodeID: $05E9; Name: 'afii57689'), (UnicodeID: $05EA; Name: 'afii57690'), (UnicodeID: $FB2A; Name: 'afii57694'), (UnicodeID: $FB2B; Name: 'afii57695'), (UnicodeID: $FB4B; Name: 'afii57700'), (UnicodeID: $FB1F; Name: 'afii57705'),
    (UnicodeID: $05F0; Name: 'afii57716'), (UnicodeID: $05F1; Name: 'afii57717'), (UnicodeID: $05F2; Name: 'afii57718'), (UnicodeID: $FB35; Name: 'afii57723'), (UnicodeID: $05B4; Name: 'afii57793'), (UnicodeID: $05B5; Name: 'afii57794'), (UnicodeID: $05B6; Name: 'afii57795'), (UnicodeID: $05BB; Name: 'afii57796'),
    (UnicodeID: $05B8; Name: 'afii57797'), (UnicodeID: $05B7; Name: 'afii57798'), (UnicodeID: $05B0; Name: 'afii57799'), (UnicodeID: $05B2; Name: 'afii57800'), (UnicodeID: $05B1; Name: 'afii57801'), (UnicodeID: $05B3; Name: 'afii57802'), (UnicodeID: $05C2; Name: 'afii57803'), (UnicodeID: $05C1; Name: 'afii57804'),
    (UnicodeID: $05B9; Name: 'afii57806'), (UnicodeID: $05BC; Name: 'afii57807'), (UnicodeID: $05BD; Name: 'afii57839'), (UnicodeID: $05BF; Name: 'afii57841'), (UnicodeID: $05C0; Name: 'afii57842'), (UnicodeID: $02BC; Name: 'afii57929'), (UnicodeID: $2105; Name: 'afii61248'), (UnicodeID: $2113; Name: 'afii61289'),
    (UnicodeID: $2116; Name: 'afii61352'), (UnicodeID: $202C; Name: 'afii61573'), (UnicodeID: $202D; Name: 'afii61574'), (UnicodeID: $202E; Name: 'afii61575'), (UnicodeID: $200C; Name: 'afii61664'), (UnicodeID: $066D; Name: 'afii63167'), (UnicodeID: $02BD; Name: 'afii64937'), (UnicodeID: $00E0; Name: 'agrave'),
    (UnicodeID: $2135; Name: 'aleph'), (UnicodeID: $03B1; Name: 'alpha'), (UnicodeID: $03AC; Name: 'alphatonos'), (UnicodeID: $0101; Name: 'amacron'), (UnicodeID: $0026; Name: 'ampersand'), (UnicodeID: $F726; Name: 'ampersandsmall'), (UnicodeID: $2220; Name: 'angle'), (UnicodeID: $2329; Name: 'angleleft'),
    (UnicodeID: $232A; Name: 'angleright'), (UnicodeID: $0387; Name: 'anoteleia'), (UnicodeID: $0105; Name: 'aogonek'), (UnicodeID: $2248; Name: 'approxequal'), (UnicodeID: $00E5; Name: 'aring'), (UnicodeID: $01FB; Name: 'aringacute'), (UnicodeID: $2194; Name: 'arrowboth'), (UnicodeID: $21D4; Name: 'arrowdblboth'),
    (UnicodeID: $21D3; Name: 'arrowdbldown'), (UnicodeID: $21D0; Name: 'arrowdblleft'), (UnicodeID: $21D2; Name: 'arrowdblright'), (UnicodeID: $21D1; Name: 'arrowdblup'), (UnicodeID: $2193; Name: 'arrowdown'), (UnicodeID: $F8E7; Name: 'arrowhorizex'), (UnicodeID: $2190; Name: 'arrowleft'), (UnicodeID: $2192; Name: 'arrowright'),
    (UnicodeID: $2191; Name: 'arrowup'), (UnicodeID: $2195; Name: 'arrowupdn'), (UnicodeID: $21A8; Name: 'arrowupdnbse'), (UnicodeID: $F8E6; Name: 'arrowvertex'), (UnicodeID: $005E; Name: 'asciicircum'), (UnicodeID: $007E; Name: 'asciitilde'), (UnicodeID: $002A; Name: 'asterisk'), (UnicodeID: $2217; Name: 'asteriskmath'),
    (UnicodeID: $F6E9; Name: 'asuperior'), (UnicodeID: $0040; Name: 'at'), (UnicodeID: $00E3; Name: 'atilde'), (UnicodeID: $0062; Name: 'b'), (UnicodeID: $005C; Name: 'backslash'), (UnicodeID: $007C; Name: 'bar'), (UnicodeID: $03B2; Name: 'beta'), (UnicodeID: $2588; Name: 'block'),
    (UnicodeID: $F8F4; Name: 'braceex'), (UnicodeID: $007B; Name: 'braceleft'), (UnicodeID: $F8F3; Name: 'braceleftbt'), (UnicodeID: $F8F2; Name: 'braceleftmid'), (UnicodeID: $F8F1; Name: 'bracelefttp'), (UnicodeID: $007D; Name: 'braceright'), (UnicodeID: $F8FE; Name: 'bracerightbt'), (UnicodeID: $F8FD; Name: 'bracerightmid'),
    (UnicodeID: $F8FC; Name: 'bracerighttp'), (UnicodeID: $005B; Name: 'bracketleft'), (UnicodeID: $F8F0; Name: 'bracketleftbt'), (UnicodeID: $F8EF; Name: 'bracketleftex'), (UnicodeID: $F8EE; Name: 'bracketlefttp'), (UnicodeID: $005D; Name: 'bracketright'), (UnicodeID: $F8FB; Name: 'bracketrightbt'), (UnicodeID: $F8FA; Name: 'bracketrightex'),
    (UnicodeID: $F8F9; Name: 'bracketrighttp'), (UnicodeID: $02D8; Name: 'breve'), (UnicodeID: $00A6; Name: 'brokenbar'), (UnicodeID: $F6EA; Name: 'bsuperior'), (UnicodeID: $2022; Name: 'bullet'), (UnicodeID: $0063; Name: 'c'), (UnicodeID: $0107; Name: 'cacute'), (UnicodeID: $02C7; Name: 'caron'),
    (UnicodeID: $21B5; Name: 'carriagereturn'), (UnicodeID: $010D; Name: 'ccaron'), (UnicodeID: $00E7; Name: 'ccedilla'), (UnicodeID: $0109; Name: 'ccircumflex'), (UnicodeID: $010B; Name: 'cdotaccent'), (UnicodeID: $00B8; Name: 'cedilla'), (UnicodeID: $00A2; Name: 'cent'), (UnicodeID: $F6DF; Name: 'centinferior'),
    (UnicodeID: $F7A2; Name: 'centoldstyle'), (UnicodeID: $F6E0; Name: 'centsuperior'), (UnicodeID: $03C7; Name: 'chi'), (UnicodeID: $25CB; Name: 'circle'), (UnicodeID: $2297; Name: 'circlemultiply'), (UnicodeID: $2295; Name: 'circleplus'), (UnicodeID: $02C6; Name: 'circumflex'), (UnicodeID: $2663; Name: 'club'),
    (UnicodeID: $003A; Name: 'colon'), (UnicodeID: $20A1; Name: 'colonmonetary'), (UnicodeID: $002C; Name: 'comma'), (UnicodeID: $F6C3; Name: 'commaaccent'), (UnicodeID: $F6E1; Name: 'commainferior'), (UnicodeID: $F6E2; Name: 'commasuperior'), (UnicodeID: $2245; Name: 'congruent'), (UnicodeID: $00A9; Name: 'copyright'),
    (UnicodeID: $F8E9; Name: 'copyrightsans'), (UnicodeID: $F6D9; Name: 'copyrightserif'), (UnicodeID: $00A4; Name: 'currency'), (UnicodeID: $F6D1; Name: 'cyrBreve'), (UnicodeID: $F6D2; Name: 'cyrFlex'), (UnicodeID: $F6D4; Name: 'cyrbreve'), (UnicodeID: $F6D5; Name: 'cyrflex'), (UnicodeID: $0064; Name: 'd'),
    (UnicodeID: $2020; Name: 'dagger'), (UnicodeID: $2021; Name: 'daggerdbl'), (UnicodeID: $F6D3; Name: 'dblGrave'), (UnicodeID: $F6D6; Name: 'dblgrave'), (UnicodeID: $010F; Name: 'dcaron'), (UnicodeID: $0111; Name: 'dcroat'), (UnicodeID: $00B0; Name: 'degree'), (UnicodeID: $03B4; Name: 'delta'),
    (UnicodeID: $2666; Name: 'diamond'), (UnicodeID: $00A8; Name: 'dieresis'), (UnicodeID: $F6D7; Name: 'dieresisacute'), (UnicodeID: $F6D8; Name: 'dieresisgrave'), (UnicodeID: $0385; Name: 'dieresistonos'), (UnicodeID: $00F7; Name: 'divide'), (UnicodeID: $2593; Name: 'dkshade'), (UnicodeID: $2584; Name: 'dnblock'),
    (UnicodeID: $0024; Name: 'dollar'), (UnicodeID: $F6E3; Name: 'dollarinferior'), (UnicodeID: $F724; Name: 'dollaroldstyle'), (UnicodeID: $F6E4; Name: 'dollarsuperior'), (UnicodeID: $20AB; Name: 'dong'), (UnicodeID: $02D9; Name: 'dotaccent'), (UnicodeID: $0323; Name: 'dotbelowcomb'), (UnicodeID: $0131; Name: 'dotlessi'),
    (UnicodeID: $F6BE; Name: 'dotlessj'), (UnicodeID: $22C5; Name: 'dotmath'), (UnicodeID: $F6EB; Name: 'dsuperior'), (UnicodeID: $0065; Name: 'e'), (UnicodeID: $00E9; Name: 'eacute'), (UnicodeID: $0115; Name: 'ebreve'), (UnicodeID: $011B; Name: 'ecaron'), (UnicodeID: $00EA; Name: 'ecircumflex'),
    (UnicodeID: $00EB; Name: 'edieresis'), (UnicodeID: $0117; Name: 'edotaccent'), (UnicodeID: $00E8; Name: 'egrave'), (UnicodeID: $0038; Name: 'eight'), (UnicodeID: $2088; Name: 'eightinferior'), (UnicodeID: $F738; Name: 'eightoldstyle'), (UnicodeID: $2078; Name: 'eightsuperior'), (UnicodeID: $2208; Name: 'element'),
    (UnicodeID: $2026; Name: 'ellipsis'), (UnicodeID: $0113; Name: 'emacron'), (UnicodeID: $2014; Name: 'emdash'), (UnicodeID: $2205; Name: 'emptyset'), (UnicodeID: $2013; Name: 'endash'), (UnicodeID: $014B; Name: 'eng'), (UnicodeID: $0119; Name: 'eogonek'), (UnicodeID: $03B5; Name: 'epsilon'),
    (UnicodeID: $03AD; Name: 'epsilontonos'), (UnicodeID: $003D; Name: 'equal'), (UnicodeID: $2261; Name: 'equivalence'), (UnicodeID: $212E; Name: 'estimated'), (UnicodeID: $F6EC; Name: 'esuperior'), (UnicodeID: $03B7; Name: 'eta'), (UnicodeID: $03AE; Name: 'etatonos'), (UnicodeID: $00F0; Name: 'eth'),
    (UnicodeID: $0021; Name: 'exclam'), (UnicodeID: $203C; Name: 'exclamdbl'), (UnicodeID: $00A1; Name: 'exclamdown'), (UnicodeID: $F7A1; Name: 'exclamdownsmall'), (UnicodeID: $F721; Name: 'exclamsmall'), (UnicodeID: $2203; Name: 'existential'), (UnicodeID: $0066; Name: 'f'), (UnicodeID: $2640; Name: 'female'),
    (UnicodeID: $FB00; Name: 'ff'), (UnicodeID: $FB03; Name: 'ffi'), (UnicodeID: $FB04; Name: 'ffl'), (UnicodeID: $FB01; Name: 'fi'), (UnicodeID: $2012; Name: 'figuredash'), (UnicodeID: $25A0; Name: 'filledbox'), (UnicodeID: $25AC; Name: 'filledrect'), (UnicodeID: $0035; Name: 'five'),
    (UnicodeID: $215D; Name: 'fiveeighths'), (UnicodeID: $2085; Name: 'fiveinferior'), (UnicodeID: $F735; Name: 'fiveoldstyle'), (UnicodeID: $2075; Name: 'fivesuperior'), (UnicodeID: $FB02; Name: 'fl'), (UnicodeID: $0192; Name: 'florin'), (UnicodeID: $0034; Name: 'four'), (UnicodeID: $2084; Name: 'fourinferior'),
    (UnicodeID: $F734; Name: 'fouroldstyle'), (UnicodeID: $2074; Name: 'foursuperior'), (UnicodeID: $2044; Name: 'fraction'), (UnicodeID: $2215; Name: 'fraction'), (UnicodeID: $20A3; Name: 'franc'), (UnicodeID: $0067; Name: 'g'), (UnicodeID: $03B3; Name: 'gamma'), (UnicodeID: $011F; Name: 'gbreve'),
    (UnicodeID: $01E7; Name: 'gcaron'), (UnicodeID: $011D; Name: 'gcircumflex'), (UnicodeID: $0123; Name: 'gcommaaccent'), (UnicodeID: $0121; Name: 'gdotaccent'), (UnicodeID: $00DF; Name: 'germandbls'), (UnicodeID: $2207; Name: 'gradient'), (UnicodeID: $0060; Name: 'grave'), (UnicodeID: $0300; Name: 'gravecomb'),
    (UnicodeID: $003E; Name: 'greater'), (UnicodeID: $2265; Name: 'greaterequal'), (UnicodeID: $00AB; Name: 'guillemotleft'), (UnicodeID: $00BB; Name: 'guillemotright'), (UnicodeID: $2039; Name: 'guilsinglleft'), (UnicodeID: $203A; Name: 'guilsinglright'), (UnicodeID: $0068; Name: 'h'), (UnicodeID: $0127; Name: 'hbar'),
    (UnicodeID: $0125; Name: 'hcircumflex'), (UnicodeID: $2665; Name: 'heart'), (UnicodeID: $0309; Name: 'hookabovecomb'), (UnicodeID: $2302; Name: 'house'), (UnicodeID: $02DD; Name: 'hungarumlaut'), (UnicodeID: $002D; Name: 'hyphen'), (UnicodeID: $00AD; Name: 'hyphen'), (UnicodeID: $F6E5; Name: 'hypheninferior'),
    (UnicodeID: $F6E6; Name: 'hyphensuperior'), (UnicodeID: $0069; Name: 'i'), (UnicodeID: $00ED; Name: 'iacute'), (UnicodeID: $012D; Name: 'ibreve'), (UnicodeID: $00EE; Name: 'icircumflex'), (UnicodeID: $00EF; Name: 'idieresis'), (UnicodeID: $00EC; Name: 'igrave'), (UnicodeID: $0133; Name: 'ij'),
    (UnicodeID: $012B; Name: 'imacron'), (UnicodeID: $221E; Name: 'infinity'), (UnicodeID: $222B; Name: 'integral'), (UnicodeID: $2321; Name: 'integralbt'), (UnicodeID: $F8F5; Name: 'integralex'), (UnicodeID: $2320; Name: 'integraltp'), (UnicodeID: $2229; Name: 'intersection'), (UnicodeID: $25D8; Name: 'invbullet'),
    (UnicodeID: $25D9; Name: 'invcircle'), (UnicodeID: $263B; Name: 'invsmileface'), (UnicodeID: $012F; Name: 'iogonek'), (UnicodeID: $03B9; Name: 'iota'), (UnicodeID: $03CA; Name: 'iotadieresis'), (UnicodeID: $0390; Name: 'iotadieresistonos'), (UnicodeID: $03AF; Name: 'iotatonos'), (UnicodeID: $F6ED; Name: 'isuperior'),
    (UnicodeID: $0129; Name: 'itilde'), (UnicodeID: $006A; Name: 'j'), (UnicodeID: $0135; Name: 'jcircumflex'), (UnicodeID: $006B; Name: 'k'), (UnicodeID: $03BA; Name: 'kappa'), (UnicodeID: $0137; Name: 'kcommaaccent'), (UnicodeID: $0138; Name: 'kgreenlandic'), (UnicodeID: $006C; Name: 'l'),
    (UnicodeID: $013A; Name: 'lacute'), (UnicodeID: $03BB; Name: 'lambda'), (UnicodeID: $013E; Name: 'lcaron'), (UnicodeID: $013C; Name: 'lcommaaccent'), (UnicodeID: $0140; Name: 'ldot'), (UnicodeID: $003C; Name: 'less'), (UnicodeID: $2264; Name: 'lessequal'), (UnicodeID: $258C; Name: 'lfblock'),
    (UnicodeID: $20A4; Name: 'lira'), (UnicodeID: $F6C0; Name: 'll'), (UnicodeID: $2227; Name: 'logicaland'), (UnicodeID: $00AC; Name: 'logicalnot'), (UnicodeID: $2228; Name: 'logicalor'), (UnicodeID: $017F; Name: 'longs'), (UnicodeID: $25CA; Name: 'lozenge'), (UnicodeID: $0142; Name: 'lslash'),
    (UnicodeID: $F6EE; Name: 'lsuperior'), (UnicodeID: $2591; Name: 'ltshade'), (UnicodeID: $006D; Name: 'm'), (UnicodeID: $00AF; Name: 'macron'), (UnicodeID: $02C9; Name: 'macron'), (UnicodeID: $2642; Name: 'male'), (UnicodeID: $2212; Name: 'minus'), (UnicodeID: $2032; Name: 'minute'),
    (UnicodeID: $F6EF; Name: 'msuperior'), (UnicodeID: $00B5; Name: 'mu'), (UnicodeID: $03BC; Name: 'mu'), (UnicodeID: $00D7; Name: 'multiply'), (UnicodeID: $266A; Name: 'musicalnote'), (UnicodeID: $266B; Name: 'musicalnotedbl'), (UnicodeID: $006E; Name: 'n'), (UnicodeID: $0144; Name: 'nacute'),
    (UnicodeID: $0149; Name: 'napostrophe'), (UnicodeID: $0148; Name: 'ncaron'), (UnicodeID: $0146; Name: 'ncommaaccent'), (UnicodeID: $0039; Name: 'nine'), (UnicodeID: $2089; Name: 'nineinferior'), (UnicodeID: $F739; Name: 'nineoldstyle'), (UnicodeID: $2079; Name: 'ninesuperior'), (UnicodeID: $2209; Name: 'notelement'),
    (UnicodeID: $2260; Name: 'notequal'), (UnicodeID: $2284; Name: 'notsubset'), (UnicodeID: $207F; Name: 'nsuperior'), (UnicodeID: $00F1; Name: 'ntilde'), (UnicodeID: $03BD; Name: 'nu'), (UnicodeID: $0023; Name: 'numbersign'), (UnicodeID: $006F; Name: 'o'), (UnicodeID: $00F3; Name: 'oacute'),
    (UnicodeID: $014F; Name: 'obreve'), (UnicodeID: $00F4; Name: 'ocircumflex'), (UnicodeID: $00F6; Name: 'odieresis'), (UnicodeID: $0153; Name: 'oe'), (UnicodeID: $02DB; Name: 'ogonek'), (UnicodeID: $00F2; Name: 'ograve'), (UnicodeID: $01A1; Name: 'ohorn'), (UnicodeID: $0151; Name: 'ohungarumlaut'),
    (UnicodeID: $014D; Name: 'omacron'), (UnicodeID: $03C9; Name: 'omega'), (UnicodeID: $03D6; Name: 'omega1'), (UnicodeID: $03CE; Name: 'omegatonos'), (UnicodeID: $03BF; Name: 'omicron'), (UnicodeID: $03CC; Name: 'omicrontonos'), (UnicodeID: $0031; Name: 'one'), (UnicodeID: $2024; Name: 'onedotenleader'),
    (UnicodeID: $215B; Name: 'oneeighth'), (UnicodeID: $F6DC; Name: 'onefitted'), (UnicodeID: $00BD; Name: 'onehalf'), (UnicodeID: $2081; Name: 'oneinferior'), (UnicodeID: $F731; Name: 'oneoldstyle'), (UnicodeID: $00BC; Name: 'onequarter'), (UnicodeID: $00B9; Name: 'onesuperior'), (UnicodeID: $2153; Name: 'onethird'),
    (UnicodeID: $25E6; Name: 'openbullet'), (UnicodeID: $00AA; Name: 'ordfeminine'), (UnicodeID: $00BA; Name: 'ordmasculine'), (UnicodeID: $221F; Name: 'orthogonal'), (UnicodeID: $00F8; Name: 'oslash'), (UnicodeID: $01FF; Name: 'oslashacute'), (UnicodeID: $F6F0; Name: 'osuperior'), (UnicodeID: $00F5; Name: 'otilde'),
    (UnicodeID: $0070; Name: 'p'), (UnicodeID: $00B6; Name: 'paragraph'), (UnicodeID: $0028; Name: 'parenleft'), (UnicodeID: $F8ED; Name: 'parenleftbt'), (UnicodeID: $F8EC; Name: 'parenleftex'), (UnicodeID: $208D; Name: 'parenleftinferior'), (UnicodeID: $207D; Name: 'parenleftsuperior'), (UnicodeID: $F8EB; Name: 'parenlefttp'),
    (UnicodeID: $0029; Name: 'parenright'), (UnicodeID: $F8F8; Name: 'parenrightbt'), (UnicodeID: $F8F7; Name: 'parenrightex'), (UnicodeID: $208E; Name: 'parenrightinferior'), (UnicodeID: $207E; Name: 'parenrightsuperior'), (UnicodeID: $F8F6; Name: 'parenrighttp'), (UnicodeID: $2202; Name: 'partialdiff'), (UnicodeID: $0025; Name: 'percent'),
    (UnicodeID: $002E; Name: 'period'), (UnicodeID: $00B7; Name: 'periodcentered'), (UnicodeID: $2219; Name: 'periodcentered'), (UnicodeID: $F6E7; Name: 'periodinferior'), (UnicodeID: $F6E8; Name: 'periodsuperior'), (UnicodeID: $22A5; Name: 'perpendicular'), (UnicodeID: $2030; Name: 'perthousand'), (UnicodeID: $20A7; Name: 'peseta'),
    (UnicodeID: $03C6; Name: 'phi'), (UnicodeID: $03D5; Name: 'phi1'), (UnicodeID: $03C0; Name: 'pi'), (UnicodeID: $002B; Name: 'plus'), (UnicodeID: $00B1; Name: 'plusminus'), (UnicodeID: $211E; Name: 'prescription'), (UnicodeID: $220F; Name: 'product'), (UnicodeID: $2282; Name: 'propersubset'),
    (UnicodeID: $2283; Name: 'propersuperset'), (UnicodeID: $221D; Name: 'proportional'), (UnicodeID: $03C8; Name: 'psi'), (UnicodeID: $0071; Name: 'q'), (UnicodeID: $003F; Name: 'question'), (UnicodeID: $00BF; Name: 'questiondown'), (UnicodeID: $F7BF; Name: 'questiondownsmall'), (UnicodeID: $F73F; Name: 'questionsmall'),
    (UnicodeID: $0022; Name: 'quotedbl'), (UnicodeID: $201E; Name: 'quotedblbase'), (UnicodeID: $201C; Name: 'quotedblleft'), (UnicodeID: $201D; Name: 'quotedblright'), (UnicodeID: $2018; Name: 'quoteleft'), (UnicodeID: $201B; Name: 'quotereversed'), (UnicodeID: $2019; Name: 'quoteright'), (UnicodeID: $201A; Name: 'quotesinglbase'),
    (UnicodeID: $0027; Name: 'quotesingle'), (UnicodeID: $0072; Name: 'r'), (UnicodeID: $0155; Name: 'racute'), (UnicodeID: $221A; Name: 'radical'), (UnicodeID: $F8E5; Name: 'radicalex'), (UnicodeID: $0159; Name: 'rcaron'), (UnicodeID: $0157; Name: 'rcommaaccent'), (UnicodeID: $2286; Name: 'reflexsubset'),
    (UnicodeID: $2287; Name: 'reflexsuperset'), (UnicodeID: $00AE; Name: 'registered'), (UnicodeID: $F8E8; Name: 'registersans'), (UnicodeID: $F6DA; Name: 'registerserif'), (UnicodeID: $2310; Name: 'revlogicalnot'), (UnicodeID: $03C1; Name: 'rho'), (UnicodeID: $02DA; Name: 'ring'), (UnicodeID: $F6F1; Name: 'rsuperior'),
    (UnicodeID: $2590; Name: 'rtblock'), (UnicodeID: $F6DD; Name: 'rupiah'), (UnicodeID: $0073; Name: 's'), (UnicodeID: $015B; Name: 'sacute'), (UnicodeID: $0161; Name: 'scaron'), (UnicodeID: $015F; Name: 'scedilla'), (UnicodeID: $F6C2; Name: 'scedilla'), (UnicodeID: $015D; Name: 'scircumflex'),
    (UnicodeID: $0219; Name: 'scommaaccent'), (UnicodeID: $2033; Name: 'second'), (UnicodeID: $00A7; Name: 'section'), (UnicodeID: $003B; Name: 'semicolon'), (UnicodeID: $0037; Name: 'seven'), (UnicodeID: $215E; Name: 'seveneighths'), (UnicodeID: $2087; Name: 'seveninferior'), (UnicodeID: $F737; Name: 'sevenoldstyle'),
    (UnicodeID: $2077; Name: 'sevensuperior'), (UnicodeID: $2592; Name: 'shade'), (UnicodeID: $03C3; Name: 'sigma'), (UnicodeID: $03C2; Name: 'sigma1'), (UnicodeID: $223C; Name: 'similar'), (UnicodeID: $0036; Name: 'six'), (UnicodeID: $2086; Name: 'sixinferior'), (UnicodeID: $F736; Name: 'sixoldstyle'),
    (UnicodeID: $2076; Name: 'sixsuperior'), (UnicodeID: $002F; Name: 'slash'), (UnicodeID: $263A; Name: 'smileface'), (UnicodeID: $0020; Name: 'space'), (UnicodeID: $00A0; Name: 'space'), (UnicodeID: $2660; Name: 'spade'), (UnicodeID: $F6F2; Name: 'ssuperior'), (UnicodeID: $00A3; Name: 'sterling'),
    (UnicodeID: $220B; Name: 'suchthat'), (UnicodeID: $2211; Name: 'summation'), (UnicodeID: $263C; Name: 'sun'), (UnicodeID: $0074; Name: 't'), (UnicodeID: $03C4; Name: 'tau'), (UnicodeID: $0167; Name: 'tbar'), (UnicodeID: $0165; Name: 'tcaron'), (UnicodeID: $0163; Name: 'tcommaaccent'),
    (UnicodeID: $021B; Name: 'tcommaaccent'), (UnicodeID: $2234; Name: 'therefore'), (UnicodeID: $03B8; Name: 'theta'), (UnicodeID: $03D1; Name: 'theta1'), (UnicodeID: $00FE; Name: 'thorn'), (UnicodeID: $0033; Name: 'three'), (UnicodeID: $215C; Name: 'threeeighths'), (UnicodeID: $2083; Name: 'threeinferior'),
    (UnicodeID: $F733; Name: 'threeoldstyle'), (UnicodeID: $00BE; Name: 'threequarters'), (UnicodeID: $F6DE; Name: 'threequartersemdash'), (UnicodeID: $00B3; Name: 'threesuperior'), (UnicodeID: $02DC; Name: 'tilde'), (UnicodeID: $0303; Name: 'tildecomb'), (UnicodeID: $0384; Name: 'tonos'), (UnicodeID: $2122; Name: 'trademark'),
    (UnicodeID: $F8EA; Name: 'trademarksans'), (UnicodeID: $F6DB; Name: 'trademarkserif'), (UnicodeID: $25BC; Name: 'triagdn'), (UnicodeID: $25C4; Name: 'triaglf'), (UnicodeID: $25BA; Name: 'triagrt'), (UnicodeID: $25B2; Name: 'triagup'), (UnicodeID: $F6F3; Name: 'tsuperior'), (UnicodeID: $0032; Name: 'two'),
    (UnicodeID: $2025; Name: 'twodotenleader'), (UnicodeID: $2082; Name: 'twoinferior'), (UnicodeID: $F732; Name: 'twooldstyle'), (UnicodeID: $00B2; Name: 'twosuperior'), (UnicodeID: $2154; Name: 'twothirds'), (UnicodeID: $0075; Name: 'u'), (UnicodeID: $00FA; Name: 'uacute'), (UnicodeID: $016D; Name: 'ubreve'),
    (UnicodeID: $00FB; Name: 'ucircumflex'), (UnicodeID: $00FC; Name: 'udieresis'), (UnicodeID: $00F9; Name: 'ugrave'), (UnicodeID: $01B0; Name: 'uhorn'), (UnicodeID: $0171; Name: 'uhungarumlaut'), (UnicodeID: $016B; Name: 'umacron'), (UnicodeID: $005F; Name: 'underscore'), (UnicodeID: $2017; Name: 'underscoredbl'),
    (UnicodeID: $222A; Name: 'union'), (UnicodeID: $2200; Name: 'universal'), (UnicodeID: $0173; Name: 'uogonek'), (UnicodeID: $2580; Name: 'upblock'), (UnicodeID: $03C5; Name: 'upsilon'), (UnicodeID: $03CB; Name: 'upsilondieresis'), (UnicodeID: $03B0; Name: 'upsilondieresistonos'), (UnicodeID: $03CD; Name: 'upsilontonos'),
    (UnicodeID: $016F; Name: 'uring'), (UnicodeID: $0169; Name: 'utilde'), (UnicodeID: $0076; Name: 'v'), (UnicodeID: $0077; Name: 'w'), (UnicodeID: $1E83; Name: 'wacute'), (UnicodeID: $0175; Name: 'wcircumflex'), (UnicodeID: $1E85; Name: 'wdieresis'), (UnicodeID: $2118; Name: 'weierstrass'),
    (UnicodeID: $1E81; Name: 'wgrave'), (UnicodeID: $0078; Name: 'x'), (UnicodeID: $03BE; Name: 'xi'), (UnicodeID: $0079; Name: 'y'), (UnicodeID: $00FD; Name: 'yacute'), (UnicodeID: $0177; Name: 'ycircumflex'), (UnicodeID: $00FF; Name: 'ydieresis'), (UnicodeID: $00A5; Name: 'yen'),
    (UnicodeID: $1EF3; Name: 'ygrave'), (UnicodeID: $007A; Name: 'z'), (UnicodeID: $017A; Name: 'zacute'), (UnicodeID: $017E; Name: 'zcaron'), (UnicodeID: $017C; Name: 'zdotaccent'), (UnicodeID: $0030; Name: 'zero'), (UnicodeID: $2080; Name: 'zeroinferior'), (UnicodeID: $F730; Name: 'zerooldstyle'), (UnicodeID: $2070; Name: 'zerosuperior'), (UnicodeID: $03B6; Name: 'zeta'));

  StWidth: array[1..14, 0..268] of word = (
    (
    278, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 278, 355, 556, 556, 889, 667, 191,
    333, 333, 389, 584, 278, 333, 278, 278, 556, 556,
    556, 556, 556, 556, 556, 556, 556, 556, 278, 278,
    584, 584, 584, 556, 1015, 667, 667, 722, 722, 667,
    611, 778, 722, 278, 500, 667, 556, 833, 722, 778,
    667, 778, 722, 667, 611, 722, 667, 944, 667, 667,
    611, 278, 278, 278, 469, 556, 333, 556, 556, 500,
    556, 556, 278, 556, 556, 222, 222, 500, 222, 833,
    556, 556, 556, 556, 333, 500, 278, 556, 500, 722,
    500, 500, 500, 334, 260, 334, 584, 350, 558, 350,
    222, 556, 333, 1000, 556, 556, 333, 1000, 667, 333,
    1000, 350, 611, 350, 350, 222, 222, 333, 333, 350,
    556, 1000, 333, 1000, 500, 333, 944, 350, 500, 667,
    278, 333, 556, 556, 556, 556, 260, 556, 333, 737,
    370, 556, 584, 333, 737, 333, 333, 584, 333, 333,
    333, 556, 537, 278, 333, 333, 365, 556, 834, 834,
    834, 611, 667, 667, 667, 667, 667, 667, 1000, 722,
    667, 667, 667, 667, 278, 278, 278, 278, 722, 722,
    778, 778, 778, 778, 778, 584, 778, 722, 722, 722,
    722, 667, 667, 611, 556, 556, 556, 556, 556, 556,
    889, 500, 556, 556, 556, 556, 278, 278, 278, 278,
    556, 556, 556, 556, 556, 556, 556, 584, 611, 556,
    556, 556, 556, 500, 556, 500, 556, 333, 333, 333,
    278, 500, 500, 167, 333, 222, 584, 333, 400
    ),

    (
    278, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 333, 474, 556, 556, 889, 722, 238,
    333, 333, 389, 584, 278, 333, 278, 278, 556, 556,
    556, 556, 556, 556, 556, 556, 556, 556, 333, 333,
    584, 584, 584, 611, 975, 722, 722, 722, 722, 667,
    611, 778, 722, 278, 556, 722, 611, 833, 722, 778,
    667, 778, 722, 667, 611, 722, 667, 944, 667, 667,
    611, 333, 278, 333, 584, 556, 333, 556, 611, 556,
    611, 556, 333, 611, 611, 278, 278, 556, 278, 889,
    611, 611, 611, 611, 389, 556, 333, 611, 556, 778,
    556, 556, 500, 389, 280, 389, 584, 350, 558, 350,
    278, 556, 500, 1000, 556, 556, 333, 1000, 667, 333,
    1000, 350, 611, 350, 350, 278, 278, 500, 500, 350,
    556, 1000, 333, 1000, 556, 333, 944, 350, 500, 667,
    278, 333, 556, 556, 556, 556, 280, 556, 333, 737,
    370, 556, 584, 333, 737, 333, 333, 584, 333, 333,
    333, 611, 556, 278, 333, 333, 365, 556, 834, 834,
    834, 611, 722, 722, 722, 722, 722, 722, 1000, 722,
    667, 667, 667, 667, 278, 278, 278, 278, 722, 722,
    778, 778, 778, 778, 778, 584, 778, 722, 722, 722,
    722, 667, 667, 611, 556, 556, 556, 556, 556, 556,
    889, 556, 556, 556, 556, 556, 278, 278, 278, 278,
    611, 611, 611, 611, 611, 611, 611, 584, 611, 611,
    611, 611, 611, 556, 611, 556, 611, 333, 333, 333,
    278, 611, 611, 167, 333, 278, 584, 333, 400
    ),

    (
    278, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 278, 355, 556, 556, 889, 667, 191,
    333, 333, 389, 584, 278, 333, 278, 278, 556, 556,
    556, 556, 556, 556, 556, 556, 556, 556, 278, 278,
    584, 584, 584, 556, 1015, 667, 667, 722, 722, 667,
    611, 778, 722, 278, 500, 667, 556, 833, 722, 778,
    667, 778, 722, 667, 611, 722, 667, 944, 667, 667,
    611, 278, 278, 278, 469, 556, 333, 556, 556, 500,
    556, 556, 278, 556, 556, 222, 222, 500, 222, 833,
    556, 556, 556, 556, 333, 500, 278, 556, 500, 722,
    500, 500, 500, 334, 260, 334, 584, 350, 558, 350,
    222, 556, 333, 1000, 556, 556, 333, 1000, 667, 333,
    1000, 350, 611, 350, 350, 222, 222, 333, 333, 350,
    556, 1000, 333, 1000, 500, 333, 944, 350, 500, 667,
    278, 333, 556, 556, 556, 556, 260, 556, 333, 737,
    370, 556, 584, 333, 737, 333, 333, 584, 333, 333,
    333, 556, 537, 278, 333, 333, 365, 556, 834, 834,
    834, 611, 667, 667, 667, 667, 667, 667, 1000, 722,
    667, 667, 667, 667, 278, 278, 278, 278, 722, 722,
    778, 778, 778, 778, 778, 584, 778, 722, 722, 722,
    722, 667, 667, 611, 556, 556, 556, 556, 556, 556,
    889, 500, 556, 556, 556, 556, 278, 278, 278, 278,
    556, 556, 556, 556, 556, 556, 556, 584, 611, 556,
    556, 556, 556, 500, 556, 500, 556, 333, 333, 333,
    278, 500, 500, 167, 333, 222, 584, 333, 400
    ),

    (
    278, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 333, 474, 556, 556, 889, 722, 238,
    333, 333, 389, 584, 278, 333, 278, 278, 556, 556,
    556, 556, 556, 556, 556, 556, 556, 556, 333, 333,
    584, 584, 584, 611, 975, 722, 722, 722, 722, 667,
    611, 778, 722, 278, 556, 722, 611, 833, 722, 778,
    667, 778, 722, 667, 611, 722, 667, 944, 667, 667,
    611, 333, 278, 333, 584, 556, 333, 556, 611, 556,
    611, 556, 333, 611, 611, 278, 278, 556, 278, 889,
    611, 611, 611, 611, 389, 556, 333, 611, 556, 778,
    556, 556, 500, 389, 280, 389, 584, 350, 558, 350,
    278, 556, 500, 1000, 556, 556, 333, 1000, 667, 333,
    1000, 350, 611, 350, 350, 278, 278, 500, 500, 350,
    556, 1000, 333, 1000, 556, 333, 944, 350, 500, 667,
    278, 333, 556, 556, 556, 556, 280, 556, 333, 737,
    370, 556, 584, 333, 737, 333, 333, 584, 333, 333,
    333, 611, 556, 278, 333, 333, 365, 556, 834, 834,
    834, 611, 722, 722, 722, 722, 722, 722, 1000, 722,
    667, 667, 667, 667, 278, 278, 278, 278, 722, 722,
    778, 778, 778, 778, 778, 584, 778, 722, 722, 722,
    722, 667, 667, 611, 556, 556, 556, 556, 556, 556,
    889, 556, 556, 556, 556, 556, 278, 278, 278, 278,
    611, 611, 611, 611, 611, 611, 611, 584, 611, 611,
    611, 611, 611, 556, 611, 556, 611, 333, 333, 333,
    278, 611, 611, 167, 333, 278, 584, 333, 400
    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 333, 408, 500, 500, 833, 778, 180,
    333, 333, 500, 564, 250, 333, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 278, 278,
    564, 564, 564, 444, 921, 722, 667, 667, 722, 611,
    556, 722, 722, 333, 389, 722, 611, 889, 722, 722,
    556, 722, 667, 556, 611, 722, 722, 944, 722, 722,
    611, 333, 278, 333, 469, 500, 333, 444, 500, 444,
    500, 444, 333, 500, 500, 278, 278, 500, 278, 778,
    500, 500, 500, 500, 333, 389, 278, 500, 500, 722,
    500, 500, 444, 480, 200, 480, 541, 350, 500, 350,
    333, 500, 444, 1000, 500, 500, 333, 1000, 556, 333,
    889, 350, 611, 350, 350, 333, 333, 444, 444, 350,
    500, 1000, 333, 980, 389, 333, 722, 350, 444, 722,
    250, 333, 500, 500, 500, 500, 200, 500, 333, 760,
    276, 500, 564, 333, 760, 333, 333, 564, 300, 300,
    333, 500, 453, 250, 333, 300, 310, 500, 750, 750,
    750, 444, 722, 722, 722, 722, 722, 722, 889, 667,
    611, 611, 611, 611, 333, 333, 333, 333, 722, 722,
    722, 722, 722, 722, 722, 564, 722, 722, 722, 722,
    722, 722, 556, 500, 444, 444, 444, 444, 444, 444,
    667, 444, 444, 444, 444, 444, 278, 278, 278, 278,
    500, 500, 500, 500, 500, 500, 500, 564, 500, 500,
    500, 500, 500, 500, 500, 500, 611, 333, 333, 333,
    278, 556, 556, 167, 333, 278, 564, 333, 400
    ),
    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 333, 555, 500, 500, 1000, 833, 278,
    333, 333, 500, 570, 250, 333, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 333, 333,
    570, 570, 570, 500, 930, 722, 667, 722, 722, 667,
    611, 778, 778, 389, 500, 778, 667, 944, 722, 778,
    611, 778, 722, 556, 667, 722, 722, 1000, 722, 722,
    667, 333, 278, 333, 581, 500, 333, 500, 556, 444,
    556, 444, 333, 500, 556, 278, 333, 556, 278, 833,
    556, 500, 556, 556, 444, 389, 333, 556, 500, 722,
    500, 500, 444, 394, 220, 394, 520, 350, 500, 350,
    333, 500, 500, 1000, 500, 500, 333, 1000, 556, 333,
    1000, 350, 667, 350, 350, 333, 333, 500, 500, 350,
    500, 1000, 333, 1000, 389, 333, 722, 350, 444, 722,
    250, 333, 500, 500, 500, 500, 220, 500, 333, 747,
    300, 500, 570, 333, 747, 333, 333, 570, 300, 300,
    333, 556, 540, 250, 333, 300, 330, 500, 750, 750,
    750, 500, 722, 722, 722, 722, 722, 722, 1000, 722,
    667, 667, 667, 667, 389, 389, 389, 389, 722, 722,
    778, 778, 778, 778, 778, 570, 778, 722, 722, 722,
    722, 722, 611, 556, 500, 500, 500, 500, 500, 500,
    722, 444, 444, 444, 444, 444, 278, 278, 278, 278,
    500, 556, 500, 500, 500, 500, 500, 570, 500, 556,
    556, 556, 556, 500, 556, 500, 667, 333, 333, 333,
    278, 556, 556, 167, 333, 278, 570, 333, 400
    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 333, 420, 500, 500, 833, 778, 214,
    333, 333, 500, 675, 250, 333, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 333, 333,
    675, 675, 675, 500, 920, 611, 611, 667, 722, 611,
    611, 722, 722, 333, 444, 667, 556, 833, 667, 722,
    611, 722, 611, 500, 556, 722, 611, 833, 611, 556,
    556, 389, 278, 389, 422, 500, 333, 500, 500, 444,
    500, 444, 278, 500, 500, 278, 278, 444, 278, 722,
    500, 500, 500, 500, 389, 389, 278, 500, 444, 667,
    444, 444, 389, 400, 275, 400, 541, 350, 500, 350,
    333, 500, 556, 889, 500, 500, 333, 1000, 500, 333,
    944, 350, 556, 350, 350, 333, 333, 556, 556, 350,
    500, 889, 333, 980, 389, 333, 667, 350, 389, 556,
    250, 389, 500, 500, 500, 500, 275, 500, 333, 760,
    276, 500, 675, 333, 760, 333, 333, 675, 300, 300,
    333, 500, 523, 250, 333, 300, 310, 500, 750, 750,
    750, 500, 611, 611, 611, 611, 611, 611, 889, 667,
    611, 611, 611, 611, 333, 333, 333, 333, 722, 667,
    722, 722, 722, 722, 722, 675, 722, 722, 722, 722,
    722, 556, 611, 500, 500, 500, 500, 500, 500, 500,
    667, 444, 444, 444, 444, 444, 278, 278, 278, 278,
    500, 500, 500, 500, 500, 500, 500, 675, 500, 500,
    500, 500, 500, 444, 500, 444, 556, 333, 333, 333,
    278, 500, 500, 167, 333, 278, 675, 333, 400
    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 389, 555, 500, 500, 833, 778, 278,
    333, 333, 500, 570, 250, 333, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 333, 333,
    570, 570, 570, 500, 832, 667, 667, 667, 722, 667,
    667, 722, 778, 389, 500, 667, 611, 889, 722, 722,
    611, 722, 667, 556, 611, 722, 667, 889, 667, 611,
    611, 333, 278, 333, 570, 500, 333, 500, 500, 444,
    500, 444, 333, 500, 556, 278, 278, 500, 278, 778,
    556, 500, 500, 500, 389, 389, 278, 556, 444, 667,
    500, 444, 389, 348, 220, 348, 570, 350, 500, 350,
    333, 500, 500, 1000, 500, 500, 333, 1000, 556, 333,
    944, 350, 611, 350, 350, 333, 333, 500, 500, 350,
    500, 1000, 333, 1000, 389, 333, 722, 350, 389, 611,
    250, 389, 500, 500, 500, 500, 220, 500, 333, 747,
    266, 500, 606, 333, 747, 333, 333, 570, 300, 300,
    333, 576, 500, 250, 333, 300, 300, 500, 750, 750,
    750, 500, 667, 667, 667, 667, 667, 667, 944, 667,
    667, 667, 667, 667, 389, 389, 389, 389, 722, 722,
    722, 722, 722, 722, 722, 570, 722, 722, 722, 722,
    722, 611, 611, 500, 500, 500, 500, 500, 500, 500,
    722, 444, 444, 444, 444, 444, 278, 278, 278, 278,
    500, 556, 500, 500, 500, 500, 500, 570, 500, 556,
    556, 556, 556, 444, 500, 444, 611, 333, 333, 333,
    278, 556, 556, 167, 333, 278, 606, 333, 400
    ),

    (
    600, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600
    ),
    (
    600, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600
    ),

    (
    600, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600
    ),

    (
    600, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600, 600,
    600, 600, 600, 600, 600, 600, 600, 600, 600
    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 250, 333, 713, 500, 549, 833, 778, 439,
    333, 333, 500, 549, 250, 549, 250, 278, 500, 500,
    500, 500, 500, 500, 500, 500, 500, 500, 278, 278,
    549, 549, 549, 444, 549, 722, 667, 722, 612, 611,
    763, 603, 722, 333, 631, 722, 686, 889, 722, 722,
    768, 741, 556, 592, 611, 690, 439, 768, 645, 795,
    611, 333, 863, 333, 658, 500, 500, 631, 549, 549,
    494, 439, 521, 411, 603, 329, 603, 549, 549, 576,
    521, 549, 549, 521, 549, 603, 439, 576, 713, 686,
    493, 686, 494, 480, 200, 480, 549, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 620, 247, 549, 167, 713, 500, 753, 753, 753,
    753, 1042, 987, 603, 987, 603, 400, 549, 411, 549,
    549, 713, 494, 460, 549, 549, 549, 549, 1000, 603,
    1000, 658, 823, 686, 795, 987, 768, 768, 823, 768,
    768, 713, 713, 713, 713, 713, 713, 713, 768, 713,
    790, 790, 890, 823, 549, 250, 713, 603, 603, 1042,
    987, 603, 987, 603, 494, 329, 790, 790, 786, 713,
    384, 384, 384, 384, 384, 384, 494, 494, 494, 494,
    0, 329, 274, 686, 686, 686, 384, 384, 384, 384,
    384, 384, 494, 494, 494, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0

    ),

    (
    250, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 278, 974, 961, 974, 980, 719, 789, 790,
    791, 690, 960, 939, 549, 855, 911, 933, 911, 945,
    974, 755, 846, 762, 761, 571, 677, 763, 760, 759,
    754, 494, 552, 537, 577, 692, 786, 788, 788, 790,
    793, 794, 816, 823, 789, 841, 823, 833, 816, 831,
    923, 744, 723, 749, 790, 792, 695, 776, 768, 792,
    759, 707, 708, 682, 701, 826, 815, 789, 789, 707,
    687, 696, 689, 786, 787, 713, 791, 785, 791, 873,
    761, 762, 762, 759, 759, 892, 892, 788, 784, 438,
    138, 277, 415, 392, 392, 668, 668, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 732, 544, 544, 910, 667, 760, 760, 776, 595,
    694, 626, 788, 788, 788, 788, 788, 788, 788, 788,
    788, 788, 788, 788, 788, 788, 788, 788, 788, 788,
    788, 788, 788, 788, 788, 788, 788, 788, 788, 788,
    788, 788, 788, 788, 788, 788, 788, 788, 788, 788,
    788, 788, 894, 838, 1016, 458, 748, 924, 748, 918,
    927, 928, 928, 834, 873, 828, 924, 924, 917, 930,
    931, 463, 883, 836, 836, 867, 867, 696, 696, 874,
    0, 874, 760, 946, 771, 865, 771, 888, 967, 888,
    831, 873, 927, 970, 918, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0
    ));


function IP(Old: Pointer; sz: Integer): Pointer;
var
  v: PByte;
begin
  v := Old;
  Inc(v, sz);
  Result := Pointer(v);
end;

type
  TdesBlockB = array[0..7] of Byte;
  TdesBlock = Int64;
  PdesBlock = ^TdesBlock;
  PdesBlockI = ^TdesBlockI;
  TdesBlockI = array[0..1] of DWORD;
  TdesKeySchedule = array[0..127] of Byte;
  TMD5Byte64 = array[0..63] of Byte;
  TMD5Byte16 = array[0..15] of Byte;
  TMD5Int16 = array[0..15] of DWORD;
  TMD5Int4 = array[0..3] of DWORD;
  TMD5Int2 = array[0..1] of DWORD;
  TMD5Ctx = record
    State: TMD5Int4;
    Count: TMD5Int2;
    Buffer: TMD5Byte64;
    BLen: DWORD;
  end;

type
  TRC4Data = record
    Key: array[0..255] of byte; { current key }
    OrgKey: array[0..255] of byte; { original key }
  end;

procedure RC4Init(var Data: TRC4Data; Key: pointer; Len: integer);
var
  xKey: array[0..255] of byte;
  i, j: integer;
  t: byte;
begin
  if (Len <= 0) or (Len > 256) then
    raise Exception.Create(SRC4InvalidKeyLength);
  for i := 0 to 255 do
  begin
    Data.Key[i] := i;
    xKey[i] := PByte(integer(Key) + (i mod Len))^;
  end;
  j := 0;
  for i := 0 to 255 do
  begin
    j := (j + Data.Key[i] + xKey[i]) and $FF;
    t := Data.Key[i];
    Data.Key[i] := Data.Key[j];
    Data.Key[j] := t;
  end;
  Move(Data.Key, Data.OrgKey, 256);
end;

procedure RC4Burn(var Data: TRC4Data);
begin
  FillChar(Data, Sizeof(Data), $FF);
end;

procedure RC4Crypt(var Data: TRC4Data; InData, OutData: pointer; Len: integer);
var
  t, i, j: byte;
  k: integer;
  Ind, Ou: PByteArray;
begin
  ind := InData;
  Ou := OutData;
  i := 0;
  j := 0;
  for k := 0 to Len - 1 do
  begin
    i := Byte(i + 1);
    j := Byte(j + Data.Key[i]);
    t := Data.Key[i];
    Data.Key[i] := Data.Key[j];
    Data.Key[j] := t;
    t := Byte(Data.Key[i] + Data.Key[j]);
    Ou[k] := Ind[k] xor Data.Key[t];
  end;
end;

procedure RC4Reset(var Data: TRC4Data);
begin
  Move(Data.OrgKey, Data.Key, 256);
end;
{$L md5_386.obj}
procedure Transform(var Accu; const Buf); external;

procedure MD5Init(var Context: TMD5ctx);
begin
  Context.BLen := 0;
  Context.Count[0] := 0;
  Context.Count[1] := 0;
  Context.State[0] := $67452301;
  Context.State[1] := $EFCDAB89;
  Context.State[2] := $98BADCFE;
  Context.State[3] := $10325476;
end;

procedure MD5Update(var Context: TMD5ctx; const ChkBuf; Len: DWORD);
var
  BufPtr: ^Byte;
  Left: Cardinal;
begin
  if Context.Count[0] + DWORD(Integer(Len) shl 3) < Context.Count[0] then Inc(Context.Count[1]);
  Inc(Context.Count[0], Integer(Len) shl 3);
  Inc(Context.Count[1], Integer(Len) shr 29);

  BufPtr := @ChkBuf;
  if Context.bLen > 0 then
  begin
    Left := 64 - Context.bLen; if Left > Len then Left := Len;
    Move(BufPtr^, Context.Buffer[Context.bLen], Left);
    Inc(Context.bLen, Left); Inc(BufPtr, Left);
    if Context.bLen < 64 then Exit;
    Transform(Context.State, Context.Buffer);
    Context.bLen := 0;
    Dec(Len, Left)
  end;
  while Len >= 64 do
  begin
    Transform(Context.State, BufPtr^);
    Inc(BufPtr, 64);
    Dec(Len, 64)
  end;
  if Len > 0 then begin
    Context.bLen := Len;
    Move(BufPtr^, Context.Buffer[0], Context.bLen)
  end
end;

procedure MD5Final(var Digest: TMD5Byte16; var Context: TMD5ctx);
var
  WorkBuf: TMD5Byte64;
  WorkLen: Cardinal;
begin
  Digest := TMD5Byte16(Context.State);
  Move(Context.Buffer, WorkBuf, Context.bLen); {make copy of buffer}
  {pad out to block of form (0..55, BitLo, BitHi)}
  WorkBuf[Context.bLen] := $80;
  WorkLen := Context.bLen + 1;
  if WorkLen > 56 then begin
    FillChar(WorkBuf[WorkLen], 64 - WorkLen, 0);
    TransForm(Digest, WorkBuf);
    WorkLen := 0
  end;
  FillChar(WorkBuf[WorkLen], 56 - WorkLen, 0);
  TMD5Int16(WorkBuf)[14] := Context.Count[0];
  TMD5Int16(WorkBuf)[15] := Context.Count[1];
  Transform(Digest, WorkBuf);
  FillChar(Context, SizeOf(Context), 0);
end;

procedure xCalcMD5(Input: Pointer; InputLen: Integer; var Digest: TMD5Byte16);
var
  Context: TMD5CTX;
begin
  MD5Init(Context);
  MD5Update(Context, Input^, InputLen);
  MD5Final(Digest, Context);
end;

function DigestToStr(const D: TMD5Byte16): string;
const
  HexChars: string[16] = '0123456789abcdef';
var
  I: Integer;
begin
  SetLength(Result, 32);
  for I := 0 to 15 do
  begin
    Result[1 + I * 2] := HexChars[1 + D[I] shr 4];
    Result[2 + I * 2] := HexChars[1 + D[I] and 15];
  end;
end;

function md5result(st: string): string;
var
  Digest: TMD5Byte16;
begin
  xCalcMD5(@st[1], length(st), digest);
  result := digesttostr(digest);
end;

function ByteToHex(B: Byte): string;
const
  H: string[16] = '0123456789ABCDEF';
begin
  Result := H[1 + b shr 4] + H[1 + b and $F];
end;

function WordToHex(W: Word): string;
begin
  Result := ByteToHex(Hi(W)) + ByteToHex(Lo(W))
end;

function FormatFloat(Value: Extended): string;
var
  c: Char;
begin
  c := DecimalSeparator;
  DecimalSeparator := '.';
  Result := SysUtils.FormatFloat('0.####', Value);
  DecimalSeparator := c;
end;

function EnCodeString(Encoding: Boolean; Key: TEncripKey; ID: Integer; Source: string): string;
var
  FullKey: array[1..10] of Byte;
  Digest: TMD5Byte16;
  AKey: TRC4Data;
  S: string;
begin
  if (Source = '') or (not Encoding) then
  begin
    Result := Source;
    Exit;
  end;
  S := Source;
  FillChar(FullKey, 10, 0);
  Move(Key, FullKey, 5);
  Move(ID, FullKey[6], 3);
  xCalcMD5(@FullKey, 10, Digest);
  RC4Init(AKey, @Digest, 10);
  RC4Crypt(AKey, @s[1], @S[1], Length(S));
  Result := S;
end;

function EnCodeHexString(Encoding: Boolean; Key: TEncripKey; ID: Integer; Source: string): string;
var
  FullKey: array[1..10] of Byte;
  Digest: TMD5Byte16;
  AKey: TRC4Data;
  a: array of Byte;
  S: string;
  i: Integer;
begin
  if (Source = '') or (not Encoding) then
  begin
    Result := Source;
    Exit;
  end;
  S := '';
  FillChar(FullKey, 10, 0);
  Move(Key, FullKey, 5);
  Move(ID, FullKey[6], 3);
  xCalcMD5(@FullKey, 10, Digest);
  RC4Init(AKey, @Digest, 10);
  SetLength(a, Length(Source) div 2);
  for i := 1 to Length(Source) div 2 do
    a[i - 1] := StrToInt('$' + Source[i shl 1 - 1] + Source[i shl 1]);
  RC4Crypt(AKey, @a[0], @a[0], Length(Source) div 2);
  for i := 1 to Length(Source) div 2 do
    S := S + ByteToHex(a[i - 1]);
  Result := S;
end;


procedure EnCodeStream(Encoding: Boolean; Key: TEncripKey; ID: Integer; Source: TMemoryStream);
var
  FullKey: array[1..10] of Byte;
  Digest: TMD5Byte16;
  AKey: TRC4Data;
begin
  if (not Encoding) or (Source.Size = 0) then
    Exit;
  FillChar(FullKey, 10, 0);
  Move(Key, FullKey, 5);
  Move(ID, FullKey[6], 3);
  xCalcMD5(@FullKey, 10, Digest);
  RC4Init(AKey, @Digest, 10);
  RC4Crypt(AKey, Source.Memory, Source.Memory, Source.Size);
end;

function UnicodeChar(Text: string; Charset: Integer): string;
var
  A: array of Word;
  i: Integer;
  W: PWideChar;
  CodePage: Integer;
  OS: Integer;
begin
  Result := '';
  case Charset of
    EASTEUROPE_CHARSET: CodePage := 1250;
    RUSSIAN_CHARSET: CodePage := 1251;
    GREEK_CHARSET: CodePage := 1253;
    TURKISH_CHARSET: CodePage := 1254;
    BALTIC_CHARSET: CodePage := 1257;
    SHIFTJIS_CHARSET: CodePage := 932;
    129: CodePage := 949;
    CHINESEBIG5_CHARSET: CodePage := 950;
    GB2312_CHARSET: CodePage := 936;
  else
    CodePage := 1252;
  end;
  OS := MultiByteToWideChar(CodePage, 0, PChar(Text), Length(Text), nil, 0);
  if OS = 0 then Exit;
  SetLength(A, OS);
  W := @a[0];
  if MultiByteToWideChar(CodePage, 0, PChar(Text), Length(Text), W, OS) <> 0 then
  begin
    Result := 'FEFF';
    for i := 0 to Length(Text) - 1 do
      Result := Result + WordToHex(A[i]);
  end;
end;

type
  TAlloc = function(AppData: Pointer; Items, Size: Integer): Pointer;
  TFree = procedure(AppData, Block: Pointer);

  TZStreamRec = packed record
    next_in: PChar;
    avail_in: Integer;
    total_in: Integer;

    next_out: PChar;
    avail_out: Integer;
    total_out: Integer;

    msg: PChar;
    internal: Pointer;

    zalloc: TAlloc;
    zfree: TFree;
    AppData: Pointer;

    data_type: Integer;
    adler: Integer;
    reserved: Integer;
  end;


  TCustomZlibStream = class(TStream)
  private
    FStrm: TStream;
    FStrmPos: Integer;
    FOnProgress: TNotifyEvent;
    FZRec: TZStreamRec;
    FBuffer: array[Word] of Char;
  protected
    procedure Progress(Sender: TObject); dynamic;
    property OnProgress: TNotifyEvent read FOnProgress write FOnProgress;
    constructor Create(Strm: TStream);
  end;

  TCompressionLevel = (clNone, clFastest, clDefault, clMax);

  TCompressionStream = class(TCustomZlibStream)
  private
    function GetCompressionRate: Single;
  public
    constructor Create(CompressionLevel: TCompressionLevel; Dest: TStream);
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    property CompressionRate: Single read GetCompressionRate;
    property OnProgress;
  end;

type
  EZlibError = class(Exception);
  ECompressionError = class(EZlibError);
const
  Z_NO_FLUSH = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH = 2;
  Z_FULL_FLUSH = 3;
  Z_FINISH = 4;

  Z_OK = 0;
  Z_STREAM_END = 1;
  Z_NEED_DICT = 2;
  Z_ERRNO = (-1);
  Z_STREAM_ERROR = (-2);
  Z_DATA_ERROR = (-3);
  Z_MEM_ERROR = (-4);
  Z_BUF_ERROR = (-5);
  Z_VERSION_ERROR = (-6);

  Z_NO_COMPRESSION = 0;
  Z_BEST_SPEED = 1;
  Z_BEST_COMPRESSION = 9;
  Z_DEFAULT_COMPRESSION = (-1);

  Z_FILTERED = 1;
  Z_HUFFMAN_ONLY = 2;
  Z_DEFAULT_STRATEGY = 0;

  Z_BINARY = 0;
  Z_ASCII = 1;
  Z_UNKNOWN = 2;

  Z_DEFLATED = 8;

{$L deflate.obj}
{$L inflate.obj}
{$L inftrees.obj}
{$L trees.obj}
{$L adler32.obj}
{$L infblock.obj}
{$L infcodes.obj}
{$L infutil.obj}
{$L inffast.obj}

procedure _tr_init; external;
procedure _tr_tally; external;
procedure _tr_flush_block; external;
procedure _tr_align; external;
procedure _tr_stored_block; external;
procedure adler32; external;
procedure inflate_blocks_new; external;
procedure inflate_blocks; external;
procedure inflate_blocks_reset; external;
procedure inflate_blocks_free; external;
procedure inflate_set_dictionary; external;
procedure inflate_trees_bits; external;
procedure inflate_trees_dynamic; external;
procedure inflate_trees_fixed; external;
procedure inflate_trees_free; external;
procedure inflate_codes_new; external;
procedure inflate_codes; external;
procedure inflate_codes_free; external;
procedure _inflate_mask; external;
procedure inflate_flush; external;
procedure inflate_fast; external;

procedure _memset(P: Pointer; B: Byte; count: Integer); cdecl;
begin
  FillChar(P^, count, B);
end;

procedure _memcpy(dest, source: Pointer; count: Integer); cdecl;
begin
  Move(source^, dest^, count);
end;

const
  zlib_Version = '1.0.4';

// deflate compresses data
function deflateInit_(var strm: TZStreamRec; level: Integer; version: PChar;
  recsize: Integer): Integer; external;
function deflate(var strm: TZStreamRec; flush: Integer): Integer; external;
function deflateEnd(var strm: TZStreamRec): Integer; external;

function zlibAllocMem(AppData: Pointer; Items, Size: Integer): Pointer;
begin
  GetMem(Result, Items * Size);
end;

procedure zlibFreeMem(AppData, Block: Pointer);
begin
  FreeMem(Block);
end;

function zlibCheck(code: Integer): Integer;
begin
  Result := code;
  if code < 0 then
    raise EZlibError.Create(SCompressionError); //!!
end;

function CCheck(code: Integer): Integer;
begin
  Result := code;
  if code < 0 then
    raise ECompressionError.Create(SCompressionError); //!!
end;

procedure CompressBuf(const InBuf: Pointer; InBytes: Integer;
  out OutBuf: Pointer; out OutBytes: Integer);
var
  strm: TZStreamRec;
  P: Pointer;
begin
  FillChar(strm, sizeof(strm), 0);
  strm.zalloc := zlibAllocMem;
  strm.zfree := zlibFreeMem;
  OutBytes := ((InBytes + (InBytes div 10) + 12) + 255) and not 255;
  GetMem(OutBuf, OutBytes);
  try
    strm.next_in := InBuf;
    strm.avail_in := InBytes;
    strm.next_out := OutBuf;
    strm.avail_out := OutBytes;
    CCheck(deflateInit_(strm, Z_BEST_COMPRESSION, zlib_version, sizeof(strm)));
    try
      while CCheck(deflate(strm, Z_FINISH)) <> Z_STREAM_END do
      begin
        P := OutBuf;
        Inc(OutBytes, 256);
        ReallocMem(OutBuf, OutBytes);
        strm.next_out := PChar(Integer(OutBuf) + (Integer(strm.next_out) - Integer(P)));
        strm.avail_out := 256;
      end;
    finally
      CCheck(deflateEnd(strm));
    end;
    ReallocMem(OutBuf, strm.total_out);
    OutBytes := strm.total_out;
  except
    FreeMem(OutBuf);
    raise
  end;
end;

// TCustomZlibStream

constructor TCustomZLibStream.Create(Strm: TStream);
begin
  inherited Create;
  FStrm := Strm;
  FStrmPos := Strm.Position;
  FZRec.zalloc := zlibAllocMem;
  FZRec.zfree := zlibFreeMem;
end;

procedure TCustomZLibStream.Progress(Sender: TObject);
begin
  if Assigned(FOnProgress) then FOnProgress(Sender);
end;


// TCompressionStream

constructor TCompressionStream.Create(CompressionLevel: TCompressionLevel;
  Dest: TStream);
const
  Levels: array[TCompressionLevel] of ShortInt =
  (Z_NO_COMPRESSION, Z_BEST_SPEED, Z_DEFAULT_COMPRESSION, Z_BEST_COMPRESSION);
begin
  inherited Create(Dest);
  FZRec.next_out := FBuffer;
  FZRec.avail_out := sizeof(FBuffer);
  CCheck(deflateInit_(FZRec, Levels[CompressionLevel], zlib_version, sizeof(FZRec)));
end;

destructor TCompressionStream.Destroy;
begin
  FZRec.next_in := nil;
  FZRec.avail_in := 0;
  try
    if FStrm.Position <> FStrmPos then FStrm.Position := FStrmPos;
    while (CCheck(deflate(FZRec, Z_FINISH)) <> Z_STREAM_END)
      and (FZRec.avail_out = 0) do
    begin
      FStrm.WriteBuffer(FBuffer, sizeof(FBuffer));
      FZRec.next_out := FBuffer;
      FZRec.avail_out := sizeof(FBuffer);
    end;
    if FZRec.avail_out < sizeof(FBuffer) then
      FStrm.WriteBuffer(FBuffer, sizeof(FBuffer) - FZRec.avail_out);
  finally
    deflateEnd(FZRec);
  end;
  inherited Destroy;
end;

function TCompressionStream.Read(var Buffer; Count: Longint): Longint;
begin
  raise ECompressionError.Create(SInvalidStreamOperation);
end;

function TCompressionStream.Write(const Buffer; Count: Longint): Longint;
begin
  FZRec.next_in := @Buffer;
  FZRec.avail_in := Count;
  if FStrm.Position <> FStrmPos then FStrm.Position := FStrmPos;
  while (FZRec.avail_in > 0) do
  begin
    CCheck(deflate(FZRec, 0));
    if FZRec.avail_out = 0 then
    begin
      FStrm.WriteBuffer(FBuffer, sizeof(FBuffer));
      FZRec.next_out := FBuffer;
      FZRec.avail_out := sizeof(FBuffer);
      FStrmPos := FStrm.Position;
      Progress(Self);
    end;
  end;
  Result := Count;
end;

function TCompressionStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  if (Offset = 0) and (Origin = soFromCurrent) then
    Result := FZRec.total_in
  else
    raise ECompressionError.Create(SInvalidStreamOperation);
end;

function TCompressionStream.GetCompressionRate: Single;
begin
  if FZRec.total_in = 0 then
    Result := 0
  else
    Result := (1.0 - (FZRec.total_out / FZRec.total_in)) * 100.0;
end;


procedure MultiplyCTM(var T: TTextCTM; const S: TTextCTM);
var
  T1: TTextCTM;
begin
  Move(T, T1, SizeOf(T));
  T.a := S.a * T1.a + S.b * T1.c;
  T.b := S.a * T1.b + S.b * T1.d;
  T.c := S.c * T1.a + S.d * T1.c;
  T.d := S.c * T1.b + S.d * T1.d;
  T.x := S.x * T1.a + S.y * T1.c + T1.x;
  T.y := S.x * T1.b + S.y * T1.d + T1.y;
end;

function ReplStr(Source: string; Ch: Char; Sub: string): string;
var
  I: Integer;
begin
  Result := '';
  for i := 1 to Length(Source) do
    if Source[I] <> Ch then Result := Result + Source[i] else Result := Result + Sub;
end;

function EscapeSpecialChar(TextStr: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(TextStr) do
    case TextStr[I] of
      '(': Result := Result + '\(';
      ')': Result := Result + '\)';
      '\': Result := Result + '\\';
      #13: Result := result + '\r';
    else Result := Result + chr(Ord(textstr[i]));
    end;
end;

procedure swp(var A, B: Integer); overload;
var
  C: Integer;
begin
  C := A;
  A := B;
  B := C;
end;

procedure swp(var A, B: Extended); overload;
var
  C: Extended;
begin
  C := A;
  A := B;
  B := C;
end;

function IntToStrWithZero(ID, Count: Integer): string;
var
  s, d: string;
  I: Integer;
begin
  s := IntToStr(ID);
  I := Count - Length(s);
  d := '';
  for I := 0 to I - 1 do
    d := d + '0';
  Result := d + s;
end;

procedure NormalizeRect(var Rect: TRect); overload;
begin
  if Rect.Left > Rect.Right then swp(Rect.Left, Rect.Right);
  if Rect.Top > Rect.Bottom then swp(Rect.Top, Rect.Bottom);
end;

procedure NormalizeRect(var x1, y1, x2, y2: integer); overload;
begin
  if x1 > x2 then swp(x2, x1);
  if y1 > y2 then swp(y2, y1);
end;

procedure NormalizeRect(var x1, y1, x2, y2: Extended); overload;
begin
  if x1 > x2 then swp(x2, x1);
  if y1 > y2 then swp(y2, y1);
end;


function DPoint(x, y: Extended): TDoublePoint;
begin
  Result.x := x;
  Result.y := y;
end;

procedure RotateCoordinate(X, Y, Angle: Extended; var XO, YO: Extended);
var
  rcos, rsin: Extended;
begin
  Angle := Angle * (PI / 180);
  rcos := cos(angle);
  rsin := sin(angle);
  XO := rcos * x - rsin * y;
  YO := rsin * x + rcos * y;
end;


function IsTrueType(FontName: string): Boolean;
var
  LF: TLogFont;
  TT: Boolean;
  DC: HDC;
  function Check(const Enum: ENUMLOGFONTEX; const PFD: TNEWTEXTMETRICEXA; FT: DWORD; var TT: Boolean): Integer; stdcall;
  begin
    TT := (FT = TRUETYPE_FONTTYPE);
    Result := 1;
  end;
begin
  if FontName = '' then
  begin
    Result := False;
    Exit;
  end;
  FillChar(LF, SizeOf(LF), 0);
  LF.lfCharSet := DEFAULT_CHARSET;
  Move(FontName[1], LF.lfFaceName, Length(FontName));
  DC := GetDC(0);
  try
    EnumFontFamiliesEx(DC, LF, @Check, Integer(@TT), 0);
  finally
    ReleaseDC(0, DC);
  end;
  Result := tt;
end;

function FontTest(FontName: string; var FontStyle: TFontStyles; var FontCharset: TFontCharset; var FullFontName: string): Boolean;
type
  TFontInfo = record
    FontName: TFontName;
    Style: TFontStyles;
    Charset: TFontCharset;
    FullFontName: string;
    Error: Boolean;
    DefautCharset: TFontCharset;
    DefItalic: Boolean;
    DefBold: Boolean;
    Step: Integer;
  end;

  function Back(const Enum: ENUMLOGFONTEX; const PFD: TNEWTEXTMETRICEXA; FT: DWORD; var FI: TFontInfo): Integer; stdcall;
  var
    Bold, Italic: Boolean;
    Er: Boolean;
  begin
    if FT <> TRUETYPE_FONTTYPE then
    begin
      Result := 1;
      Exit;
    end;
    Bold := Enum.elfLogFont.lfWeight >= 600;
    Italic := Enum.elfLogFont.lfItalic <> 0;
    if FI.Step = 0 then
    begin
      FI.DefautCharset := Enum.elfLogFont.lfCharSet;
      FI.DefItalic := Italic;
      FI.DefBold := Bold;
    end;
    Inc(FI.Step);
    Er := False;
    if (fsbold in FI.Style) <> Bold then Er := True;
    if (fsItalic in FI.Style) <> Italic then Er := True;
    if Enum.elfLogFont.lfCharSet <> FI.Charset then Er := True;
    FI.Error := Er;
    if Er then
      Result := 1 else
    begin
      FI.FullFontName := Enum.elfFullName;
      Result := 0;
    end;
  end;
var
  LogFont: TLogFont;
  BM: TBitmap;
  ST: TFontStyles;
  FI: TFontInfo;
begin
  FI.FontName := FontName;
  FI.Charset := FontCharset;
  FI.Style := FontStyle;
  FillChar(LogFont, SizeOf(LogFont), 0);
  LogFont.lfCharSet := DEFAULT_CHARSET;
  move(FI.FontName[1], LogFont.lfFaceName, Length(FI.FontName));
  FI.DefautCharset := 0;
  FI.Step := 0;
  FI.Error := True;
  ST := FI.Style;
  BM := TBitmap.Create;
  try
    EnumFontFamiliesEx(BM.Canvas.Handle, LogFont, @Back, Integer(@FI), 0);
    if FI.Step <> 0 then
      if FI.Error then
      begin
        if fsItalic in FI.Style then
        begin
          FI.Style := FI.Style - [fsItalic];
          EnumFontFamiliesEx(BM.Canvas.Handle, LogFont, @Back, Integer(@FI), 0);
        end;
        if FI.Error then
          if fsBold in FI.Style then
          begin
            FI.Style := FI.Style - [fsBold];
            EnumFontFamiliesEx(BM.Canvas.Handle, LogFont, @Back, Integer(@FI), 0);
          end;
        if FI.Error then
        begin
          FI.Style := [];
          if FI.DefItalic then FI.Style := FI.Style + [fsItalic];
          if FI.DefBold then FI.Style := FI.Style + [fsBold];
          EnumFontFamiliesEx(BM.Canvas.Handle, LogFont, @Back, Integer(@FI), 0);
        end;
        if FI.Error then
        begin
          FI.Style := ST;
          FI.Charset := FI.DefautCharset;
          EnumFontFamiliesEx(BM.Canvas.Handle, LogFont, @Back, Integer(@FI), 0);
        end;
        if FI.Error then
          if fsItalic in FI.Style then
          begin
            FI.Style := FI.Style - [fsItalic];
            EnumFontFamiliesEx(BM.Canvas.Handle, LogFont, @Back, Integer(@FI), 0);
          end;
        if FI.Error then
          if fsBold in FI.Style then
          begin
            FI.Style := FI.Style - [fsBold];
            EnumFontFamiliesEx(BM.Canvas.Handle, LogFont, @Back, Integer(@FI), 0);
          end;
        if FI.Error then
        begin
          FI.Style := [];
          if FI.DefItalic then FI.Style := FI.Style + [fsItalic];
          if FI.DefBold then FI.Style := FI.Style + [fsBold];
          EnumFontFamiliesEx(BM.Canvas.Handle, LogFont, @Back, Integer(@FI), 0);
        end;
      end;
  finally
    BM.Free;
  end;
  Result := not FI.Error;
  if not FI.Error then
  begin
    FontName := FI.FontName;
    FullFontName := FI.FullFontName;
    FontStyle := FI.Style;
    FontCharset := FI.Charset;
  end;
end;


{ TPDFDocument }

procedure TPDFDocument.Abort;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  ClearAll;
  if FOutputStream = nil then DeleteFile(FileName);
  FAborted := True;
  FPrinting := False;
end;

procedure TPDFDocument.BeginDoc;
begin
  if FPrinting then
    raise TPDFException.Create(SGenerationPDFFileInProgress);
  ClearAll;
  GenFileID;
  FPFlags := $FFFFFFC0;
  if coPrint in ProtectionOptions then FPFlags := FPFlags or 4;
  if coModifyStructure in ProtectionOptions then FPFlags := FPFlags or 8;
  if coCopyInformation in ProtectionOptions then FPFlags := FPFlags or 16;
  if coModifyAnnotation in ProtectionOptions then FPFlags := FPFlags or 32;
  if ProtectionEnabled then CalcKey;
  if FOutputStream = nil then
    FStream := TFileStream.Create(FileName, fmCreate) else FStream := TMemoryStream.Create;
  if Version = v13 then SaveToStream('%PDF-1.3')
  else SaveToStream('%PDF-1.4');
  FPrinting := True;
  FAborted := False;
  PagesID := GetNextID;
  FCurrentPage := FPages.Add;
  FCurrentPage.CreateCanvas;
end;

function TPDFDocument.CalcOwnerPassword: string;
var
  Key: TRC4Data;
  Pass, Op: array[1..32] of byte;
  I: Integer;
  Digest: TMD5Byte16;
begin
  if FOwnerPassword <> '' then Move(FOwnerPassword[1], Pass, 32);
  for I := 1 to 32 - Length(FOwnerPassword) do
    Pass[I + Length(FOwnerPassword)] := passkey[I];
  xCalcMD5(@Pass[1], 32, Digest);
  RC4Init(Key, @Digest, 5);
  if FUserPassword <> '' then Move(FUserPassword[1], Pass, 32);
  for I := 1 to 32 - Length(FUserPassword) do
    Pass[I + Length(FUserPassword)] := passkey[I];
  RC4Crypt(Key, @Pass, @op, 32);
  Result := '';
  for I := 1 to 32 do Result := Result + chr(op[I]);
end;

function TPDFDocument.CalcUserPassword: string;
var
  I: Integer;
  Op: array[1..32] of Byte;
  AKey: TRC4Data;
begin
  RC4Init(AKey, @FKey, 5);
  RC4Crypt(AKey, @PassKey, @op, 32);
  Result := '';
  for I := 1 to 32 do Result := Result + chr(op[I]);
end;

constructor TPDFDocument.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDefaultCharset:= ANSI_CHARSET;
  FRadioGroups := TList.Create;
  FPages := TPDFPages.Create(Self, False);
  FActions := TPDFActions.Create(Self);
  FWaterMarks := TPDFPages.Create(Self, True);
  FFonts := TPDFFonts.Create(Self);
  FNotEmbeddedFont := TStringList.Create;
  FImages := TPDFImages.Create(Self);
  FOutlines := TPDFOutlines.Create(Self);
  FDocumentInfo := TPDFDocInfo.Create;
  FDocumentInfo.Charset:= FDefaultCharset;
  FAcroForm := TPDFAcroForm.Create(Self);
  FDocumentInfo.Creator := '';
  FDocumentInfo.CreationDate := Now;
  FDocumentInfo.Producer := '';
  FDocumentInfo.Author := '';
  FDocumentInfo.Title := '';
  FDocumentInfo.Subject := '';
  FDocumentInfo.Keywords := '';
  FCurrentPage := nil;
  FOutputStream := nil;
  FJPEGQuality := 80;
  FAborted := False;
  FPrinting := False;
  FResolution := 72;
  FOpenDocumentAction := nil;
  FOnePass := False;
end;

destructor TPDFDocument.Destroy;
begin
  FRadioGroups.Free;
  FDocumentInfo.Free;
  FOutlines.Free;
  FImages.Free;
  FFonts.Free;
  FPages.Free;
  FActions.Free;
  FWaterMarks.Free;
  FNotEmbeddedFont.Free;
  FAcroForm.Free;
  inherited;
end;


procedure TPDFDocument.EndDoc;
begin
  try
    StoreDocument;
  except
    on Exception do
    begin
      Abort;
      raise;
    end;
  end;
  if FOutputStream <> nil then
  begin
    FStream.Position := 0;
    FOutputStream.CopyFrom(FStream, FStream.Size);
  end;
  ClearAll;
  FPrinting := False;
  FAborted := False;
  if (FOutputStream = nil) and (AutoLaunch) then
  try
    ShellExecute(GetActiveWindow, 'open', PChar(FFileName), nil, nil, SW_NORMAL);
  except
  end;
end;

procedure TPDFDocument.NewPage;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  FCurrentPage.CloseCanvas;
  if OnePass then FCurrentPage.Save;
  FCurrentPage := FPages.Add;
  FCurrentPage.CreateCanvas;
end;

procedure TPDFDocument.SetFileName(const Value: TFileName);
begin
  if FPrinting then
    raise TPDFException.Create(SGenerationPDFFileInProgress);
  FFileName := Value;
end;

procedure TPDFDocument.SetCompression(const Value: TCompressionType);
begin
  FCompression := Value;
end;

function TPDFDocument.GetNextID: Integer;
begin
  Inc(CurID);
  SetLength(IDOffset, CurID);
  Result := CurID;
end;

procedure TPDFDocument.SaveTrailer;
begin
  SaveToStream('trailer');
  SaveToStream('<<');
  SaveToStream('/Size ' + IntToStr(CurID + 1));
  SaveToStream('/Root ' + IntToStr(CatalogID) + ' 0 R');
  SaveToStream('/Info ' + IntToStr(FDocumentInfo.ID) + ' 0 R');
  if FProtectionEnabled then
    SaveToStream('/Encrypt ' + IntToStr(EncriptID) + ' 0 R');
  SaveToStream('/ID [<' + FileID + '><' + FileID + '>]');
  SaveToStream('>>');
end;

procedure TPDFDocument.SaveXREF;
var
  I: Integer;
begin
  XREFOffset := FStream.Position;
  SaveToStream('xref');
  SaveToStream('0 ' + IntToStr(CurID + 1));
  SaveToStream(IntToStrWithZero(0, 10) + ' ' + IntToStr($FFFF) + ' f');
  for I := 0 to CurID - 1 do
    SaveToStream(IntToStrWithZero(idoffset[I], 10) + ' ' + IntToStrWithZero(0, 5) + ' n');
end;

procedure TPDFDocument.SaveDocumentInfo;

  function St (const s: string): string;
  begin
    if FDocumentInfo.Charset<> ANSI_CHARSET then
      Result:= '<'+EnCodeHexString(FProtectionEnabled, FKey, FDocumentInfo.ID, UnicodeChar (s,FDocumentInfo.Charset))+'>'
    else
      Result:= '('+EscapeSpecialChar (EnCodeString(FProtectionEnabled, FKey, FDocumentInfo.ID, s))+')';
  end;

begin
  StartObj(FDocumentInfo.ID);
  SaveToStream('/Creator '+ St (FDocumentInfo.Creator));
  SaveToStream('/CreationDate ' + St ('D:' + FormatDateTime('yyyymmddhhnnss', FDocumentInfo.CreationDate)));
  SaveToStream('/Producer ' + St (FDocumentInfo.Producer));
  SaveToStream('/Author ' + St (FDocumentInfo.Author));
  SaveToStream('/Title ' + St (FDocumentInfo.Title));
  SaveToStream('/Subject ' + St (FDocumentInfo.Subject));
  SaveToStream('/Keywords ' + St (FDocumentInfo.Keywords));
  CloseHObj;
  CloseObj;
end;

procedure TPDFDocument.SetDefaultCharset(const Value: TFontCharset);
begin
  FDefaultCharset:= Value;
  FDocumentInfo.Charset:= Value;
end;

procedure TPDFDocument.SetDocumentInfo(const Value: TPDFDocInfo);
begin
  FDocumentInfo.Charset:= Value.Charset;
  FDocumentInfo.Creator := Value.Creator;
  FDocumentInfo.CreationDate := Value.CreationDate;
  FDocumentInfo.Author := Value.Author;
  FDocumentInfo.Title := Value.Title;
  FDocumentInfo.Subject := Value.Subject;
  FDocumentInfo.Keywords := Value.Keywords;
end;

procedure TPDFDocument.SaveToStream(st: string; CR: Boolean);
var
  WS: string;
  Ad: Pointer;
begin
  WS := st;
  if CR then WS := WS + #13#10;
  Ad := @WS[1];
  FStream.Write(ad^, Length(WS));
end;

procedure TPDFDocument.SetPageLayout(const Value: TPageLayout);
begin
  FPageLayout := Value;
end;

procedure TPDFDocument.SetPageMode(const Value: TPageMode);
begin
  FPageMode := Value;
end;

procedure TPDFDocument.SetCurrentPage(Index: Integer);
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  if OnePass then
    raise TPDFException.Create(SCannotChangePageInOnePassMode);
  FCurrentPage.CloseCanvas;
  FCurrentPage := FPages[Index];
  FCurrentPage.CreateCanvas;
end;

procedure TPDFDocument.SetOwnerPassword(const Value: string);
begin
  if FPrinting then
    raise TPDFException.Create(SGenerationPDFFileInProgress);
  FOwnerPassword := Value;
end;

procedure TPDFDocument.SetProtectionEnabled(const Value: Boolean);
begin
  if FPrinting then
    raise TPDFException.Create(SGenerationPDFFileInProgress);
  FProtectionEnabled := Value;
end;

procedure TPDFDocument.SetProtectionOptions(
  const Value: TPDFCtiptoOptions);
begin
  if FPrinting then
    raise TPDFException.Create(SGenerationPDFFileInProgress);
  FProtectionOptions := Value;
end;

procedure TPDFDocument.SetUserPassword(const Value: string);
begin
  if FPrinting then
    raise TPDFException.Create(SGenerationPDFFileInProgress);
  FUserPassword := Value;
end;

procedure TPDFDocument.CalcKey;
var
  Digest: TMD5Byte16;
  W, Z, C: string;
  Cont: TMD5Ctx;
  i: Integer;
begin
  z := CalcOwnerPassword;
  W := Copy(FUserPassword, 1, 32);
  SetLength(W, 32);
  if Length(FUserPassword) < 32 then Move(PassKey, W[Length(FUserPassword) + 1], 32 - Length(FUserPassword));
  C := '';
  for i := 1 to 16 do
    C := C + chr(StrToInt('$' + FileID[i shl 1 - 1] + FileID[i shl 1]));
  MD5Init(Cont);
  MD5Update(Cont, w[1], 32);
  MD5Update(Cont, z[1], 32);
  MD5Update(Cont, FPFlags, 4);
  MD5Update(Cont, C[1], 16);
  MD5Final(Digest, Cont);
  Move(Digest, FKey, 5);
end;

procedure TPDFDocument.GenFileID;
var
  s: string;
begin
  s := FileName + FormatDateTime('ddd dd-mm-yyyy hh:nn:ss.zzz', Now);
  FileID := LowerCase(md5result(s));
end;

procedure TPDFDocument.SetNotEmbeddedFont(const Value: TStringList);
begin
  FNotEmbeddedFont.Assign(Value);
end;

function TPDFDocument.GetCurrentPageIndex: Integer;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  Result := FPages.FPages.IndexOf(Pointer(FCurrentPage));
end;

function TPDFDocument.AddImage(Image: TGraphic;
  Compression: TImageCompressionType): Integer;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  Result := FImages.FImages.IndexOf(Pointer(FImages.Add(Image, Compression)));
end;

function TPDFDocument.AddImage(FileName: TFileName;
  Compression: TImageCompressionType): Integer;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  Result := FImages.FImages.IndexOf(Pointer(FImages.Add(FileName, Compression)));
end;

function TPDFDocument.GetPageCount: Integer;
begin
  Result := FPages.Count;
end;

function TPDFDocument.GetPage(Index: Integer): TPDFPage;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  if OnePass then
    raise TPDFException.Create(SCannotAccessToPageInOnePassMode);
  if (Index < 0) or (Index > FPages.Count - 1) then
    raise TPDFException.Create(SOutOfRange);
  Result := FPages[Index];
end;

procedure TPDFDocument.SetOutputStream(const Value: TStream);
begin
  if FPrinting then
    raise TPDFException.Create(SGenerationPDFFileInProgress);
  FOutputStream := Value;
end;

procedure TPDFDocument.SetJPEGQuality(const Value: Integer);
begin
  FJPEGQuality := Value;
end;

procedure TPDFDocument.SetAutoLaunch(const Value: Boolean);
begin
  FAutoLaunch := Value;
end;


function TPDFDocument.GetCanvas: TCanvas;
begin
  if CurrentPage = nil then Result := nil else Result := CurrentPage.FCanvas;
end;

function TPDFDocument.GetPageHeight: Integer;
var
  DC: HDC;
  I: Integer;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  DC := GetDC(0);
  I := GetDeviceCaps(dc, LOGPIXELSX);
  ReleaseDC(0, DC);
  Result := MulDiv(CurrentPage.FHeight, I, 72);
end;

function TPDFDocument.GetPageNumber: Integer;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  Result := GetCurrentPageIndex + 1;
end;

function TPDFDocument.GetPageWidth: Integer;
var
  DC: HDC;
  I: Integer;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  DC := GetDC(0);
  I := GetDeviceCaps(dc, LOGPIXELSX);
  ReleaseDC(0, DC);
  Result := MulDiv(CurrentPage.FWidth, I, 72);
end;

function TPDFDocument.CreateWaterMark: Integer;
var
  P: TPDFPage;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  P := FWaterMarks.Add;
  Result := FWaterMarks.IndexOf(P);
end;

function TPDFDocument.GetWaterMark(Index: Integer): TPDFPage;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  Result := FWaterMarks.GetPage(Index);
end;

procedure TPDFDocument.AppendAction(const Action: TPDFAction);
var
  i: Integer;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  if FActions.IndexOf(Action) < 0 then
  begin
    i := FActions.Add(Action);
    if FActions[i].ActionID < 1 then
      FActions[i].ActionID := GetNextID;
  end;
end;

procedure TPDFDocument.SetOpenDocumentAction(const Value: TPDFAction);
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  if FOpenDocumentAction = nil then FOpenDocumentAction := Value
  else
  begin
    Value.FNext := FOpenDocumentAction;
    FOpenDocumentAction := Value;
  end;
  AppendAction(Value);
end;

procedure TPDFDocument.CloseHObj;
begin
  SaveToStream('>>');
end;

procedure TPDFDocument.CloseObj;
begin
  SaveToStream('endobj');
end;

procedure TPDFDocument.StartObj(var ID: Integer);
var
  Offset: Integer;
begin
  if ID <= 0 then ID := GetNextID;
  Offset := FStream.Position;
  if ID > CurID then raise TPDFException.Create(SOutOfRange);
  IDOffset[ID - 1] := Offset;
  SaveToStream(IntToStr(ID) + ' 0 obj');
  SaveToStream('<<', False);
end;

procedure TPDFDocument.CloseStream;
begin
  SaveToStream('endstream');
end;

procedure TPDFDocument.StartStream;
begin
  SaveToStream('stream');
end;

procedure TPDFDocument.SetOnePass(const Value: Boolean);
begin
  if FPrinting then
    raise TPDFException.Create(SGenerationPDFFileInProgress);
  FOnePass := Value;
end;

procedure TPDFDocument.ClearAll;
begin
  CurID := 0;
  FDocumentInfo.ID := 0;
  PagesID := 0;
  CatalogID := 0;
  EncriptID := 0;
  IDOffset := nil;
  DeleteAllRadioGroups;
  FImages.Clear;
  FFonts.Clear;
  FPages.Clear;
  FWaterMarks.Clear;
  FActions.Clear;
  FOutlines.Clear;
  FCurrentPage := nil;
  FAcroForm.Clear;
  FOpenDocumentAction := nil;
  if FStream <> nil then
  begin
    FStream.Free;
    FStream := nil;
  end;
end;

procedure TPDFDocument.DeleteAllRadioGroups;
var
  I: Integer;
begin
  for I := 0 to FRadioGroups.Count - 1 do
    TPDFRadioGroup(FRadioGroups[I]).Free;
  FRadioGroups.Clear;
end;

function TPDFDocument.CreateAction(CClass: TPDFActionClass): TPDFAction;
var
  SO: TPDFAction;
begin
  SO := CClass.Create;
  AppendAction(SO);
  Result := SO;
end;

function TPDFDocument.CreateRadioGroup(Name: string): TPDFRadioGroup;
var
  RG: TPDFRadioGroup;
begin
  RG := TPDFRadioGroup.Create(Self, Name);
  RG.GroupID := GetNextID;
  FRadioGroups.Add(RG);
  Result := RG;
end;

procedure TPDFDocument.SetVersion(const Value: TPDFVersion);
begin
  FVersion := Value;
end;

procedure TPDFDocument.StoreDocument;
var
  i: Integer;
begin
  if not FPrinting then
    raise TPDFException.Create(SGenerationPDFFileNotActivated);
  FCurrentPage.CloseCanvas;
  if OnePass then FCurrentPage.Save;
  SaveDocumentInfo;
  i := 0;
  while i < FActions.Count do
  begin
    FActions[i].Prepare;
    Inc(i);
  end;
  for i := 0 to FWaterMarks.Count - 1 do
    FWaterMarks[i].CloseCanvas;
  for i := 0 to FWaterMarks.Count - 1 do
    FWaterMarks[i].Save;

  StartObj(PagesID);
  SaveToStream('/Type /Pages');
  SaveToStream('/Kids [');
  for i := 0 to FPages.Count - 1 do
    SaveToStream(IntToStr(FPages[i].PageID) + ' 0 R');
  SaveToStream(']');
  SaveToStream('/Count ' + IntToStr(FPages.Count));
  CloseHObj;
  CloseObj;
  if not OnePass then
    for i := 0 to FPages.Count - 1 do
      FPages[i].Save;
  for i := 0 to FActions.Count - 1 do
    FActions[i].Save;
  if Outlines.Count <> 0 then
  begin
    FOutlines.OutlinesID := GetNextID;
    for i := 0 to FOutlines.Count - 1 do
      FOutlines[i].OutlineNodeID := GetNextID;
    for i := 0 to FOutlines.Count - 1 do
      FOutlines[i].Save;
    StartObj(FOutlines.OutlinesID);
    SaveToStream('/Type /Outlines');
    SaveToStream('/Count ' + IntToStr(FOutlines.Count));
    for i := 0 to FOutlines.Count - 1 do
    begin
      if (FOutlines[i].FParent = nil) and (FOutlines[i].FPrev = nil) then
        SaveToStream('/First ' + IntToStr(FOutlines[i].OutlineNodeID) + ' 0 R');
      if (FOutlines[i].FParent = nil) and (FOutlines[i].FNext = nil) then
        SaveToStream('/Last ' + IntToStr(FOutlines[i].OutlineNodeID) + ' 0 R');
    end;
    CloseHObj;
    CloseObj;
  end;
  for i := 0 to FRadioGroups.Count - 1 do
    TPDFRadioGroup(FRadioGroups[i]).Save;
  if not FAcroForm.Empty then FAcroForm.Save;
  StartObj(CatalogID);
  SaveToStream('/Type /Catalog');
  SaveToStream(' /Pages ' + IntToStr(PagesID) + ' 0 R');
  case PageLayout of
    plSinglePage: SaveToStream('/PageLayout /SinglePage');
    plOneColumn: SaveToStream('/PageLayout /OneColumn');
    plTwoColumnLeft: SaveToStream('/Pagelayout /TwoColumnLeft');
    plTwoColumnRight: SaveToStream('/PageLayout /TwoColumnRight');
  end;
  if ViewerPreferences <> [] then
  begin
    SaveToStream('/ViewerPreferences <<');
    if vpHideToolBar in ViewerPreferences then SaveToStream('/HideToolbar true');
    if vpHideMenuBar in ViewerPreferences then SaveToStream('/HideMenubar true');
    if vpHideWindowUI in ViewerPreferences then SaveToStream('/HideWindowUI true');
    if vpFitWindow in ViewerPreferences then SaveToStream('/FitWindow true');
    if vpCenterWindow in ViewerPreferences then SaveToStream('/CenterWindow true');
    SaveToStream('>>');
  end;
  case PageMode of
    pmUseNone: SaveToStream('/PageMode /UseNone');
    pmUseOutlines: SaveToStream('/PageMode /UseOutlines');
    pmUseThumbs: SaveToStream('/PageMode /UseThumbs');
    pmFullScreen: SaveToStream('/PageMode /FullScreen');
  end;
  if FOpenDocumentAction <> nil then
    SaveToStream('/OpenAction ' + IntToStr(FOpenDocumentAction.ActionID) + ' 0 R');
  if FOutlines.Count <> 0 then
    SaveToStream('/Outlines ' + IntToStr(FOutlines.OutlinesID) + ' 0 R');
  if not FAcroForm.Empty then
    SaveToStream('/AcroForm ' + IntToStr(FAcroForm.AcroID) + ' 0 R');
  CloseHObj;
  CloseObj;
  if FProtectionEnabled then
  begin
    StartObj(EncriptID);
    SaveToStream('/Filter /Standard');
    SaveToStream('/V 1');
    SaveToStream('/R 2');
    SaveToStream('/P ' + IntToStr(FPFlags));
    SaveToStream('/O (' + EscapeSpecialChar(CalcOwnerPassword) + ')');
    SaveToStream('/U (' + EscapeSpecialChar(CalcUserPassword) + ')');
    CloseHObj;
    CloseObj;
  end;
  if EmbedFontFilesToPDF then
    FFonts.EmbiddingFontFiles;
  for i := 0 to FFonts.Count - 1 do
    FFonts[i].Save(Self);
  if not FOnePass then
    for i := 0 to FImages.Count - 1 do
      FImages[i].Save(Self);
  SaveXREF;
  SaveTrailer;
  SaveToStream('startxref');
  SaveToStream(IntToStr(XREFOffset));
  SaveToStream('%%EOF');
end;

{ TPDFPage }

procedure TPDFPage.AppendAction(Action: string);
begin
  FContent.Add(Action);
end;

function TPDFPage.Arc(X1, Y1, x2, y2, BegAngle,
  EndAngle: Extended): TDoublePoint;
var
  d: TDoublePoint;
begin
  D := RawArc(ExtToIntX(X1), ExtToIntY(Y1), ExtToIntX(X2), ExtToIntY(Y2), -EndAngle, -BegAngle);
  Result := DPoint(IntToExtX(d.x), IntToExtY(d.y));
end;

function TPDFPage.Arc(X1, Y1, x2, y2, x3, y3, x4, y4: Extended): TDoublePoint;
var
  d: TDoublePoint;
begin
  D := RawArc(ExtToIntX(X1), ExtToIntY(Y1), ExtToIntX(X2), ExtToIntY(Y2),
    ExtToIntX(X4), ExtToIntY(Y4), ExtToIntX(X3), ExtToIntY(y3));
  Result := DPoint(IntToExtX(d.x), IntToExtY(d.y));
end;

procedure TPDFPage.BeginText;
begin
  if FTextInited then
    raise TPDFException.Create(SCannotBeginTextObjectTwice);
  AppendAction('BT');
  FTextInited := True;
  ResetTextCTM;
  if FFontInited then
    if FEItalic then SkewText(0, 0);
end;

procedure TPDFPage.Circle(X, Y, R: Extended);
begin
  RawCircle(ExtToIntX(X), ExtToIntY(Y), ExtToIntX(R));
end;

procedure TPDFPage.Clip;
begin
  AppendAction('W');
end;

procedure TPDFPage.ClosePath;
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction('h');
end;

procedure TPDFPage.Comment(st: string);
begin
  AppendAction('% ' + st);
end;

procedure TPDFPage.ConcatTextMatrix(A, B, C, D, X, Y: Extended);
var
  sCTM: TTextCTM;
begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  sCTM.a := a;
  sCTM.b := b;
  sCTM.c := c;
  sCTM.d := d;
  sCTM.x := x;
  sCTM.y := y;
  MultiplyCTM(FCTM, sCTM);
  setTextMatrix(FCTM.a, FCTM.b, FCTM.c, FCTM.d, FCTM.x, FCTM.y);
end;

constructor TPDFPage.Create(AOwner: TPDFDocument);
begin
  FOwner := AOwner;
  PageID := FOwner.GetNextID;
  FAnnot := TList.Create;
  FCurrentDash := '[] 0';
  FContent := TStringList.Create;
  FLinkedFont := TList.Create;
  FLinkedImages := TList.Create;
  FForms := TPDFPages.Create(FOwner, True);
  FMF := nil;
  FRes := FOwner.FResolution;
  D2P := FRes / 72;
  Size := psA4;
  PageRotate := pr0;
  FCharSpace := 0;
  FWordSpace := 0;
  FRemoveCR := False;
  FEmulationEnabled := True;
  FHorizontalScaling := 100;
  FFontInited := False;
  FCurrentFontSize := 10;
  FTextLeading := 0;
  FRender := 0;
  FRise := 0;
  FTextInited := False;
  FSaveCount := 0;
  GStateSave;
  ResetTextCTM;
  Factions := False;
  FWaterMark := -1;
  FThumbnail := -1;
  FMatrix.a := 1;
  FMatrix.b := 0;
  FMatrix.c := 0;
  FMatrix.d := 1;
  FMatrix.x := 0;
  FMatrix.y := 0;
  FF := FMatrix;
  FCanvasOver := True;
end;

procedure TPDFPage.Curveto(X1, Y1, X2, Y2, X3, Y3: Extended);
begin
  RawCurveto(ExtToIntX(x1), ExtToIntY(y1), ExtToIntX(x2), ExtToIntY(y2), ExtToIntX(x3), ExtToIntY(y3));
end;

destructor TPDFPage.Destroy;
begin
  DeleteCanvas;
  DeleteAllAnnotations;
  FAnnot.Free;
  FLinkedImages.Free;
  FLinkedFont.Free;
  FContent.Free;
  FForms.Free;
  inherited;
end;

procedure TPDFPage.DrawArcWithBezier(CenterX, CenterY, RadiusX, RadiusY,
  StartAngle, SweepRange: Extended; UseMoveTo: Boolean);
var
  Coord, C2: array[0..3] of TDoublePoint;
  a, b, c, x, y: Extended;
  ss, cc: Double;
  i: Integer;
begin
  if SweepRange = 0 then
  begin
    if UseMoveTo then
      RawMoveTo(CenterX + RadiusX * cos(StartAngle),
        CenterY - RadiusY * sin(StartAngle));
    RawLineTo(CenterX + RadiusX * cos(StartAngle),
      CenterY - RadiusY * sin(StartAngle));
    Exit;
  end;

  b := sin(SweepRange / 2);
  c := cos(SweepRange / 2);
  a := 1 - c;
  x := a * 4 / 3;
  y := b - x * c / b;

  ss := sin(StartAngle + SweepRange / 2);
  cc := cos(StartAngle + SweepRange / 2);

  Coord[0] := DPoint(c, b);
  Coord[1] := DPoint(c + x, y);
  Coord[2] := DPoint(c + x, -y);
  Coord[3] := DPoint(c, -b);

  for i := 0 to 3 do
  begin
    C2[i].x := CenterX + RadiusX * (Coord[i].x * cc + Coord[i].y * ss) - 0.0001;
    C2[i].y := CenterY + RadiusY * (-Coord[i].x * ss + Coord[i].y * cc) - 0.0001;
  end;
  if UseMoveTo then RawMoveTo(C2[0].x, C2[0].y);
  RawCurveto(C2[1].x, C2[1].y, C2[2].x, C2[2].y, C2[3].x, C2[3].y);
end;

procedure TPDFPage.Ellipse(X1, Y1, X2, Y2: Extended);
begin
  RawEllipse(ExtToIntX(X1), ExtToIntY(Y1), ExtToIntX(X2), ExtToIntY(Y2));
end;

procedure TPDFPage.EndText;
begin
  AppendAction('ET');
  FTextInited := False;
end;

procedure TPDFPage.EoClip;
begin
  AppendAction('W*');
end;

procedure TPDFPage.EoFill;
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction('f*');
end;

procedure TPDFPage.EoFillAndStroke;
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction('B*');
end;

function TPDFPage.ExtToIntX(AX: Extended): Extended;
begin
  Result := AX / D2P;
  Factions := True;
end;

function TPDFPage.ExtToIntY(AY: Extended): Extended;
begin
  Result := FHeight - AY / D2P;
  Factions := True;
end;

procedure TPDFPage.Fill;
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction('f');
end;

procedure TPDFPage.FillAndStroke;
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction('B');
end;

procedure TPDFPage.GStateRestore;
begin
  if FSaveCount <> 1 then
  begin
    AppendAction('Q');
    Dec(FSaveCount);
  end;
end;

procedure TPDFPage.GStateSave;
begin
  Inc(FSaveCount);
  AppendAction('q');
end;

function TPDFPage.IntToExtX(AX: Extended): Extended;
begin
  Result := AX * D2P;
  Factions := True;
end;

function TPDFPage.IntToExtY(AY: Extended): Extended;
begin
  Result := (FHeight - AY) * D2P;
  Factions := True;
end;

procedure TPDFPage.LineTo(X, Y: Extended);
begin
  RawLineTo(ExttointX(X), ExtToIntY(Y));
end;

procedure TPDFPage.MoveTo(X, Y: Extended);
begin
  RawMoveTo(ExttointX(X), ExtToIntY(Y));
end;

procedure TPDFPage.NewPath;
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction('n');
end;

procedure TPDFPage.NoDash;
begin
  SetDash('[] 0');
end;

procedure TPDFPage.Pie(X1, Y1, x2, y2, BegAngle, EndAngle: Extended);
begin
  RawPie(ExtToIntX(X1), ExtToIntY(Y1), ExtToIntX(X2), ExtToIntY(Y2), -EndAngle, -BegAngle);
end;

procedure TPDFPage.Pie(X1, Y1, x2, y2, x3, y3, x4, y4: Extended);
begin
  RawPie(ExtToIntX(X1), ExtToIntY(Y1), ExtToIntX(X2),
    ExtToIntY(Y2), ExtToIntX(X4), ExtToIntY(Y4), ExtToIntX(X3), ExtToIntY(y3));
end;

function TPDFPage.RawArc(X1, Y1, x2, y2, x3, y3, x4,
  y4: Extended): TDoublePoint;
var
  CenterX, CenterY: Extended;
  RadiusX, RadiusY: Extended;
  StartAngle,
    EndAngle,
    SweepRange: Extended;
  UseMoveTo: Boolean;
begin
  CenterX := (x1 + x2) / 2;
  CenterY := (y1 + y2) / 2;
  RadiusX := (abs(x1 - x2) - 1) / 2;
  RadiusY := (abs(y1 - y2) - 1) / 2;
  if RadiusX < 0 then RadiusX := 0;
  if RadiusY < 0 then RadiusY := 0;

  StartAngle := ArcTan2(-(y3 - CenterY) * RadiusX,
    (x3 - CenterX) * RadiusY);
  EndAngle := ArcTan2(-(y4 - CenterY) * RadiusX,
    (x4 - CenterX) * RadiusY);
  SweepRange := EndAngle - StartAngle;

  if SweepRange < 0 then SweepRange := SweepRange + 2 * PI;

  Result := DPoint(CenterX + RadiusX * cos(StartAngle),
    CenterY - RadiusY * sin(StartAngle));

  UseMoveTo := True;
  while SweepRange > PI / 2 do
  begin
    DrawArcWithBezier(CenterX, CenterY, RadiusX, RadiusY,
      StartAngle, PI / 2, UseMoveTo);
    SweepRange := SweepRange - PI / 2;
    StartAngle := StartAngle + PI / 2;
    UseMoveTo := False;
  end;
  if SweepRange >= 0 then
    DrawArcWithBezier(CenterX, CenterY, RadiusX, RadiusY,
      StartAngle, SweepRange, UseMoveTo);
end;


function TPDFPage.RawArc(X1, Y1, x2, y2, BegAngle,
  EndAngle: Extended): TDoublePoint;
var
  CenterX, CenterY: Extended;
  RadiusX, RadiusY: Extended;
  StartAngle,
    EndsAngle,
    SweepRange: Extended;
  UseMoveTo: Boolean;
begin
  CenterX := (x1 + x2) / 2;
  CenterY := (y1 + y2) / 2;
  RadiusX := (abs(x1 - x2) - 1) / 2;
  RadiusY := (abs(y1 - y2) - 1) / 2;
  if RadiusX < 0 then RadiusX := 0;
  if RadiusY < 0 then RadiusY := 0;

  StartAngle := BegAngle * pi / 180;
  EndsAngle := EndAngle * pi / 180;
  SweepRange := EndsAngle - StartAngle;

  if SweepRange < 0 then SweepRange := SweepRange + 2 * PI;

  Result := DPoint(CenterX + RadiusX * cos(StartAngle),
    CenterY - RadiusY * sin(StartAngle));
  UseMoveTo := True;
  while SweepRange > PI / 2 do
  begin
    DrawArcWithBezier(CenterX, CenterY, RadiusX, RadiusY,
      StartAngle, PI / 2, UseMoveTo);
    SweepRange := SweepRange - PI / 2;
    StartAngle := StartAngle + PI / 2;
    UseMoveTo := False;
  end;
  if SweepRange >= 0 then
    DrawArcWithBezier(CenterX, CenterY, RadiusX, RadiusY,
      StartAngle, SweepRange, UseMoveTo);
end;

procedure TPDFPage.RawCircle(X, Y, R: Extended);
const
  b: Extended = 0.5522847498;
begin
  RawMoveto(X + R, Y);
  RawCurveto(X + R, Y + b * R, X + b * R, Y + R, X, Y + R);
  RawCurveto(X - b * R, Y + R, X - R, Y + b * R, X - R, Y);
  RawCurveto(X - R, Y - b * R, X - b * R, Y - R, X, Y - R);
  RawCurveto(X + b * R, Y - R, X + R, Y - b * R, X + R, Y);
end;

procedure TPDFPage.RawConcat(A, B, C, D, E, F: Extended);
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  FF.a := A;
  FF.b := B;
  FF.c := C;
  FF.d := D;
  FF.x := E;
  FF.y := F;
  AppendAction(FormatFloat(A) + ' ' + FormatFloat(B) + ' ' +
    FormatFloat(C) + ' ' + FormatFloat(D) + ' ' +
    FormatFloat(E) + ' ' + FormatFloat(F) + ' cm');
end;

procedure TPDFPage.RawCurveto(X1, Y1, X2, Y2, X3, Y3: Extended);
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction(FormatFloat(x1) + ' ' + FormatFloat(y1) + ' ' + FormatFloat(x2) + ' ' +
    FormatFloat(y2) + ' ' + FormatFloat(x3) + ' ' + FormatFloat(y3) + ' c');
  FX := X3;
  FY := Y3;
end;

procedure TPDFPage.RawEllipse(x1, y1, x2, y2: Extended);
const
  b = 0.5522847498;
var
  RX, RY, X, Y: Extended;
begin
  Rx := (x2 - x1) / 2;
  Ry := (y2 - y1) / 2;
  X := x1 + Rx;
  Y := y1 + Ry;
  RawMoveto(X + Rx, Y);
  RawCurveto(X + RX, Y + b * RY, X + b * RX, Y + RY, X, Y + RY);
  RawCurveto(X - b * RX, Y + RY, X - RX, Y + b * RY, X - RX, Y);
  RawCurveto(X - RX, Y - b * RY, X - b * RX, Y - RY, X, Y - RY);
  RawCurveto(X + b * RX, Y - RY, X + RX, Y - b * RY, X + RX, Y);
end;

procedure TPDFPage.RawLineTo(X, Y: Extended);
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction(FormatFloat(X) + ' ' + FormatFloat(Y) + ' l');
  FX := X;
  FY := Y;
end;

procedure TPDFPage.RawMoveTo(X, Y: Extended);
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction(FormatFloat(X) + ' ' + FormatFloat(Y) + ' m');
  FX := X;
  FY := Y;
end;


function TPDFPage.RawPie(X1, Y1, x2, y2, BegAngle,
  EndAngle: Extended): TDoublePoint;
var
  CX, CY: Extended;
  dp: TDoublePoint;
begin
  dp := RawArc(X1, Y1, x2, y2, BegAngle, EndAngle);
  CX := X1 + (x2 - X1) / 2;
  CY := Y1 + (Y2 - Y1) / 2;
  RawLineTo(CX, CY);
  RawMoveTo(dp.x, dp.y);
  RawLineTo(CX, CY);
end;

function TPDFPage.RawPie(X1, Y1, x2, y2, x3, y3, x4,
  y4: Extended): TDoublePoint;
var
  CX, CY: Extended;
  dp: TDoublePoint;
begin
  dp := RawArc(X1, Y1, x2, y2, x3, y3, x4, y4);
  CX := (x2 - X1) / 2;
  CY := (Y2 - Y1) / 2;
  RawLineTo(CX, CY);
  RawMoveTo(dp.x, dp.y);
  RawLineTo(CX, CY);
end;

procedure TPDFPage.RawRect(X, Y, W, H: Extended);
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction(FormatFloat(x) + ' ' + FormatFloat(y) + ' ' +
    FormatFloat(w) + ' ' + FormatFloat(h) + ' re');
  FX := X;
  FY := Y;
end;

procedure TPDFPage.RawRectRotated(X, Y, W, H, Angle: Extended);
var
  xo, yo: Extended;
begin
  RawMoveto(x, y);
  RotateCoordinate(w, 0, angle, xo, yo);
  RawLineto(x + xo, y + yo);
  RotateCoordinate(w, h, angle, xo, yo);
  RawLineto(x + xo, y + yo);
  RotateCoordinate(0, h, angle, xo, yo);
  RawLineto(x + xo, y + yo);
end;

procedure TPDFPage.RawSetTextPosition(X, Y: Extended);
begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  AppendAction(FormatFloat(FCTM.a) + ' ' + FormatFloat(FCTM.b) + ' ' + FormatFloat(FCTM.c) + ' ' +
    FormatFloat(FCTM.d) + ' ' + FormatFloat(x) + ' ' + FormatFloat(y) + ' Tm');
  FCTM.x := X;
  FCTM.y := Y;
end;

procedure TPDFPage.RawTextOut(X, Y, Orientation: Extended;
  TextStr: string);
begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  if not FFontInited then
    raise TPDFException.Create(SActiveFontNotSetting);
  RawSetTextPosition(X, Y);
  if Orientation <> FTextAngle then
    Rotatetext(Orientation);
  TextShow(TextStr);
end;

procedure TPDFPage.RawTranslate(XT, YT: Extended);
begin
  RawConcat(1, 0, 0, 1, xt, yt);
end;

procedure TPDFPage.Rectangle(X1, Y1, X2, Y2: Extended);
var
  convw, convh, H, W: Extended;
begin
  NormalizeRect(x1, y1, x2, y2);
  W := X2 - X1;
  H := Y2 - Y1;
  convw := ExtToIntX(X1 + W) - ExtToIntX(X1);
  convh := ExtToIntY(Y1 + H) - ExtToIntY(Y1);
  RawRect(ExtToIntX(X1), ExtToIntY(y1), convw, convh);
end;

procedure TPDFPage.RectRotated(X, Y, W, H, Angle: Extended);
var
  convw, convh: Extended;
begin
  convw := ExtToIntX(X + W) - ExtToIntY(X);
  convh := ExtToIntY(Y + H) - ExtToIntY(Y);
  RawRectRotated(ExtToIntX(X), ExtToIntY(y), convw, convh, Angle);
end;

procedure TPDFPage.Rotate(Angle: Extended);
var
  vsin, vcos: Extended;
begin
  Angle := Angle * (PI / 180);
  vsin := sin(angle);
  vcos := cos(angle);
  RawConcat(vcos, vsin, -vsin, vcos, 0, 0);
end;

procedure TPDFPage.RotateText(Degrees: Extended);
var
  a, b, c, d, e, f, angle, vcos, vsin: Extended;
begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  FRealAngle := Degrees;
  Degrees := Degrees - FTextAngle;
  angle := PI * degrees / 180.0;
  vcos := cos(angle);
  vsin := sin(angle);
  a := vcos;
  b := vsin;
  c := -vsin;
  d := vcos;
  e := 0.0;
  f := 0.0;
  ConcatTextMatrix(a, b, c, d, e, f);
  FTextAngle := Degrees;
end;

procedure TPDFPage.Save;
var
  I: Integer;
  MS: TMemoryStream;
  CS: TCompressionStream;
  S, O: string;
begin
  PrepareID;
  for I := FSaveCount downto 1 do GStateRestore;
  for I := 0 to FForms.Count - 1 do FForms[I].Save;
  ResourceID := FOwner.GetNextID;
  if not FIsForm then
    ContentID := FOwner.GetNextID;
  FSaveCount := 2;
  GStateRestore;
  if FRemoveCR then
  begin
    S := FContent.Text;
    O := '';
    I := Pos(#13#10, S);
    while I <> 0 do
    begin
      O := O + ' ' + Copy(S, 1, I - 1);
      Delete(S, 1, I + 1);
      I := Pos(#13#10, S);
    end;
    O := O + ' ' + S;
    FContent.Text := O;
  end;
  for I := 0 to FAnnot.Count - 1 do
  begin
    TPDFCustomAnnotation(FAnnot[I]).Save;
  end;
  FOwner.StartObj(ResourceID);
  if FLinkedFont.Count > 0 then
  begin
    FOwner.SaveToStream(' /Font <<');
    for I := 0 to FLinkedFont.Count - 1 do
      FOwner.SaveToStream('/' + TPDFFont(FLinkedFont[I]).AliasName + ' ' + IntToStr(TPDFFont(FLinkedFont[I]).FontID) + ' 0 R');
    FOwner.SaveToStream('>>');
  end;
  if (FLinkedImages.Count > 0) or (FWaterMark >= 0) or (FForms.Count > 0) then
  begin
    FOwner.SaveToStream(' /XObject <<');
    for I := 0 to FLinkedImages.Count - 1 do
      FOwner.SaveToStream('/' + TPDFImage(FLinkedImages[I]).ImageName + ' ' + IntToStr(TPDFImage(FLinkedImages[I]).PictureID) + ' 0 R');
    if FWaterMark >= 0 then FOwner.SaveToStream('/Form' + IntToStr(FWaterMark) + ' ' + IntToStr(FOwner.FWaterMarks[FWaterMark].PageID) + ' 0 R');
    for I := 0 to FForms.Count - 1 do
      FOwner.SaveToStream('/IF' + IntToStr(0) + ' ' + IntToStr(FForms[I].PageID) + ' 0 R');
    FOwner.SaveToStream('>>');
  end;
  FOwner.CloseHObj;
  FOwner.CloseObj;
  if not FIsForm then
  begin
    if FWaterMark >= 0 then
      FContent.Insert(0, 'q /Form' + IntToStr(FWaterMark) + ' Do   Q');
    FOwner.StartObj(ContentID);
    if FOwner.Compression = ctFlate then
    begin
      MS := TMemoryStream.Create;
      try
        CS := TCompressionStream.Create(clDefault, MS);
        try
          FContent.SaveToStream(CS);
        finally
          CS.Free;
        end;
        FOwner.SaveToStream('/Length ' + IntToStr(MS.size));
        FOwner.SaveToStream('/Filter /FlateDecode');
        FOwner.CloseHObj;
        FOwner.StartStream;
        MS.Position := 0;
        EnCodeStream(FOwner.FProtectionEnabled, FOwner.FKey, ContentID, MS);
        FOwner.FStream.CopyFrom(MS, MS.Size);
        FOwner.SaveToStream('');
      finally
        MS.Free;
      end;
    end else
    begin
      FOwner.SaveToStream('/Length ' + IntToStr(Length(FContent.Text)));
      FOwner.CloseHObj;
      FOwner.StartStream;
      FOwner.SaveToStream(EnCodeString(FOwner.FProtectionEnabled, FOwner.FKey, ContentID, FContent.Text));
    end;
    FContent.Text := '';
    FOwner.CloseStream;
    FOwner.CloseObj;
    FOwner.StartObj(PageID);
    FOwner.SaveToStream('/Type /Page');
    FOwner.SaveToStream('/Parent ' + IntToStr(FOwner.PagesID) + ' 0 R');
    FOwner.SaveToStream('/Resources ' + IntToStr(ResourceID) + ' 0 R');
    FOwner.SaveToStream('/Contents [' + IntToStr(ContentID) + ' 0 R]');
    if FThumbnail >= 0 then FOwner.SaveToStream('/Thumb ' + IntToStr(FOwner.FImages[FThumbnail].PictureID) + ' 0 R');
    FOwner.SaveToStream('/MediaBox [0 0 ' + IntToStr(FWidth) + ' ' + IntToStr(FHeight) + ']');
    case FRotate of
      pr90: FOwner.SaveToStream('/Rotate 90');
      pr180: FOwner.SaveToStream('/Rotate 180');
      pr270: FOwner.SaveToStream('/Rotate 270');
    end;
    if FAnnot.Count <> 0 then
    begin
      FOwner.SaveToStream('/Annots [');
      for I := 0 to FAnnot.Count - 1 do
        FOwner.SaveToStream(IntToStr(TPDFCustomAnnotation(FAnnot[I]).AnnotID) + ' 0 R');
      FOwner.SaveToStream(']');
    end;
    FOwner.CloseHObj;
    FOwner.CloseObj;
  end else
  begin
    FOwner.StartObj(PageID);
    FOwner.SaveToStream('/Type /XObject');
    FOwner.SaveToStream('/Subtype /Form');
    FOwner.SaveToStream('/Resources ' + IntToStr(ResourceID) + ' 0 R');
    FOwner.SaveToStream('/Matrix [' + FormatFloat(FMatrix.a) + ' ' + FormatFloat(FMatrix.b) + ' ' + FormatFloat(FMatrix.c) + ' ' +
      FormatFloat(FMatrix.d) + ' ' + FormatFloat(FMatrix.x) + ' ' + FormatFloat(FMatrix.y) + ' ]');
    FOwner.SaveToStream('/BBox [0 0 ' + IntToStr(FWidth) + ' ' + IntToStr(FHeight) + ']');
    if FOwner.Compression = ctFlate then
    begin
      MS := TMemoryStream.Create;
      try
        CS := TCompressionStream.Create(clDefault, MS);
        try
          FContent.SaveToStream(CS);
        finally
          CS.Free;
        end;
        FOwner.SaveToStream('/Length ' + IntToStr(MS.size));
        FOwner.SaveToStream('/Filter /FlateDecode');
        FOwner.CloseHObj;
        FOwner.StartStream;
        MS.Position := 0;
        EnCodeStream(FOwner.FProtectionEnabled, FOwner.FKey, ContentID, MS);
        FOwner.FStream.CopyFrom(MS, MS.Size);
        FOwner.SaveToStream('');
      finally
        MS.Free;
      end;
    end else
    begin
      FOwner.SaveToStream('/Length ' + IntToStr(Length(FContent.Text)));
      FOwner.CloseHObj;
      FOwner.StartStream;
      FOwner.SaveToStream(EnCodeString(FOwner.FProtectionEnabled, FOwner.FKey, ContentID, FContent.Text));
    end;
    FContent.Text := '';
    FOwner.CloseStream;
    FOwner.CloseObj;
  end;
end;

procedure TPDFPage.Scale(SX, SY: Extended);
begin
  RawConcat(sx, 0, 0, sy, 0, 0);
end;

procedure TPDFPage.SetActiveFont(FontName: string; FontStyle: TFontStyles; FontSize: Extended; FontCharset: TFontCharset);
begin
  if not FTextInited then AppendAction('BT');
  FOwner.FFonts.CheckFont(FontName, FontStyle, FontCharset);
  if FLinkedFont.IndexOf(Pointer(FOwner.FFonts.FLast)) = -1 then
    FLinkedFont.Add(Pointer(FOwner.FFonts.FLast));
  AppendAction('/' + FOwner.FFonts.FLast.AliasName + ' ' + FormatFloat(FontSize) + ' Tf');
  FCurrentFontIndex := FOwner.FFonts.FLastIndex;
  FCurrentFontSize := FontSize;
  FFontInited := True;
  if FEmulationEnabled then
  begin
    FEUnderLine := fsUnderline in FontStyle;
    FEStrike := fsStrikeOut in FontStyle;
  end;
  if FOwner.FFonts.FLast.Standart then
  begin
    FEBold := False;
    FEItalic := False;
    if not FTextInited then AppendAction('ET')
  end else
    if FEmulationEnabled then
    begin
      FEBold := (fsBold in FontStyle) and (not (fsBold in FOwner.FFonts.FLast.RealStyle));
      FEItalic := (fsItalic in FontStyle) and (not (fsItalic in FOwner.FFonts.FLast.RealStyle));
      if not FTextInited then AppendAction('ET') else SkewText(0, 0); ;
    end;
end;

function TPDFPage.SetAnnotation(ARect: TRect; Title, Text: string; Color: TColor; Flags: TAnnotationFlags;
  Opened: Boolean): TPDFCustomAnnotation;
begin
  Result:= SetAnnotation (ARect,Title,Text,Color,Flags,Opened,FOwner.FDefaultCharset);
end;

procedure TPDFPage.SetCharacterSpacing(Spacing: Extended);
begin
  if not FTextInited then
    AppendAction('BT');
  Spacing := Spacing / D2P;
  AppendAction(FormatFloat(Spacing) + ' Tc');
  FCharSpace := Spacing;
  if not FTextInited then
    AppendAction('ET');
end;

procedure TPDFPage.SetCMYKColor(C, M, Y, K: Extended);
begin
  SetCMYKColorFill(C, M, Y, K);
  SetCMYKColorStroke(C, M, Y, K);
end;

procedure TPDFPage.SetCMYKColorFill(C, M, Y, K: Extended);
begin
  AppendAction(FormatFloat(C) + ' ' + FormatFloat(M) + ' ' + FormatFloat(Y) + ' ' + FormatFloat(K) + ' k');
end;

procedure TPDFPage.SetCMYKColorStroke(C, M, Y, K: Extended);
begin
  AppendAction(FormatFloat(C) + ' ' + FormatFloat(M) + ' ' + FormatFloat(Y) + ' ' + FormatFloat(K) + ' K');
end;

procedure TPDFPage.SetDash(DashSpec: string);
begin
  if FCurrentDash <> DashSpec then
  begin
    AppendAction(DashSpec + ' d');
    FCurrentDash := DashSpec;
  end;
end;

procedure TPDFPage.SetFlat(FlatNess: integer);
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction(Format('%d i', [FlatNess]));
end;

procedure TPDFPage.SetGray(Gray: Extended);
begin
  SetGrayFill(Gray);
  SetGrayStroke(Gray);
end;

procedure TPDFPage.SetGrayFill(Gray: Extended);
begin
  AppendAction(FormatFloat(Gray) + ' g');
end;

procedure TPDFPage.SetGrayStroke(Gray: Extended);
begin
  AppendAction(FormatFloat(Gray) + ' G');
end;

procedure TPDFPage.SetHeight(const Value: Integer);
begin
  if Factions then
    raise TPDFException.Create(SPageInProgress);
  if FHeight <> Value then
  begin
    FHeight := round(Value / D2P);
    FPageSize := psUserDefined;
    if FMF <> nil then
      FMF.Height := Value;
  end;
end;

procedure TPDFPage.SetHorizontalScaling(Scale: Extended);
begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  AppendAction(FormatFloat(Scale) + ' Tz');
  FHorizontalScaling := Scale;
end;

procedure TPDFPage.SetLineCap(LineCap: TPDFLineCap);
begin
  AppendAction(Format('%d j', [Ord(LineCap)]));
end;

procedure TPDFPage.SetLineJoin(LineJoin: TPDFLineJoin);
begin
  AppendAction(Format('%d J', [Ord(LineJoin)]));
end;

procedure TPDFPage.SetLineWidth(lw: Extended);
begin
  AppendAction(FormatFloat(lw / D2P) + ' w');
end;

procedure TPDFPage.SetMiterLimit(MiterLimit: Extended);
begin
  MiterLimit := MiterLimit / D2P;
  AppendAction(FormatFloat(MiterLimit) + ' M');
end;

procedure TPDFPage.SetPageSize(Value: TPDFPageSize);
begin
  if Factions then
    raise TPDFException.Create(SPageInProgress);
  FPageSize := Value;
  case Value of
    psLetter:
      begin
        FHeight := 792;
        FWidth := 612;
      end;
    psA4:
      begin
        FHeight := 842;
        FWidth := 595;
      end;
    psA3:
      begin
        FHeight := 1190;
        FWidth := 842;
      end;
    psLegal:
      begin
        FHeight := 1008;
        FWidth := 612;
      end;
    psB5:
      begin
        FHeight := 728;
        FWidth := 516;
      end;
    psC5:
      begin
        FHeight := 649;
        FWidth := 459;
      end;
    ps8x11:
      begin
        FHeight := 792;
        FWidth := 595;
      end;
    psB4:
      begin
        FHeight := 1031;
        FWidth := 728;
      end;
    psA5:
      begin
        FHeight := 595;
        FWidth := 419;
      end;
    psFolio:
      begin
        FHeight := 936;
        FWidth := 612;
      end;
    psExecutive:
      begin
        FHeight := 756;
        FWidth := 522;
      end;
    psEnvB4:
      begin
        FHeight := 1031;
        FWidth := 728;
      end;
    psEnvB5:
      begin
        FHeight := 708;
        FWidth := 499;
      end;
    psEnvC6:
      begin
        FHeight := 459;
        FWidth := 323;
      end;
    psEnvDL:
      begin
        FHeight := 623;
        FWidth := 312;
      end;
    psEnvMonarch:
      begin
        FHeight := 540;
        FWidth := 279;
      end;
    psEnv9:
      begin
        FHeight := 639;
        FWidth := 279;
      end;
    psEnv10:
      begin
        FHeight := 684;
        FWidth := 297;
      end;
    psEnv11:
      begin
        FHeight := 747;
        FWidth := 324;
      end;
  end;
  if FMF <> nil then
  begin
    FMF.Width := Width;
    FMF.Height := Height;
  end;
  SetOrientation(FOrientation);
end;


procedure TPDFPage.SetRGBColor(R, G, B: Extended);
begin
  SetRGBcolorFill(R, G, B);
  SetRGBcolorStroke(R, G, B);
end;

procedure TPDFPage.SetRGBColorFill(R, G, B: Extended);
begin
  AppendAction(FormatFloat(R) + ' ' + FormatFloat(G) + ' ' + FormatFloat(B) + ' rg');
end;

procedure TPDFPage.SetRGBColorStroke(R, G, B: Extended);
begin
  AppendAction(FormatFloat(R) + ' ' + FormatFloat(G) + ' ' + FormatFloat(B) + ' RG');
end;

procedure TPDFPage.SetRotate(const Value: TPDFPageRotate);
begin
  FRotate := Value;
end;

procedure TPDFPage.SetTextMatrix(A, B, C, D, X, Y: Extended);
begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  AppendAction(FormatFloat(A) + ' ' + FormatFloat(B) + ' ' + FormatFloat(C) + ' ' +
    FormatFloat(D) + ' ' + FormatFloat(X) + ' ' + FormatFloat(Y) + ' Tm');
  FCTM.a := A;
  FCTM.b := B;
  FCTM.c := C;
  FCTM.d := D;
  FCTM.x := X;
  FCTM.y := Y;
end;

procedure TPDFPage.SetTextPosition(X, Y: Extended);
begin
  RawSetTextPosition(ExtToIntX(X), ExtToIntY(Y) - FCurrentFontSize);
end;

procedure TPDFPage.SetTextRenderingMode(Mode: integer);
begin
  if not FTextInited then
    AppendAction('BT');
  AppendAction(Format('%d Tr', [mode]));
  if not FTextInited then
    AppendAction('ET');
  FRender := Mode;
end;

procedure TPDFPage.SetTextRise(Rise: Extended);
begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  Rise := Rise / D2P;
  AppendAction(FormatFloat(Rise) + ' Ts');
  FRise := Rise;
end;

procedure TPDFPage.SetWidth(const Value: Integer);
begin
  if Factions then
    raise TPDFException.Create(SPageInProgress);
  if FWidth <> Value then
  begin
    FWidth := round(Value / D2P);
    FPageSize := psUserDefined;
    if FMF <> nil then
      FMF.Width := Value;
  end;
end;


procedure TPDFPage.SetWordSpacing(Spacing: Extended);
begin
  Spacing := Spacing / D2P;
  if not FTextInited then
    AppendAction('BT');
  AppendAction(FormatFloat(Spacing) + ' Tw');
  if not FTextInited then
    AppendAction('ET');
  FWordSpace := Spacing;
end;

procedure TPDFPage.SkewText(Alpha, Beta: Extended);
var
  a, b, c, d, e, f: Extended;
begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  if FEItalic then Beta := Beta + 7;
  a := 1.0;
  b := tan(PI * alpha / 180.0);
  c := tan(PI * beta / 180.0);
  d := 1.0;
  e := 0.0;
  f := 0.0;
  ConcatTextMatrix(a, b, c, d, e, f);
end;

procedure TPDFPage.Stroke;
begin
  if FTextInited then
    raise TPDFException.Create(STextObjectInited);
  AppendAction('S');
end;

procedure TPDFPage.TextOut(X, Y, Orientation: Extended; TextStr: string);
  procedure CheckURL(CH: string);
  var
    S: string;
    LB, L: Extended;
    A: Integer;
    I: Integer;
  begin
    A := Pos(uppercase(CH), UpperCase(TextStr));
    if A <> 0 then
    begin
      if A <> 1 then
        if TextStr[A - 1] > #32 then Exit;
      S := Copy(TextStr, 1, A - 1);
      LB := GetTextWidth(S);
      S := Copy(TextStr, A, Length(TextStr));
      I := 1;
      while (S[I] > #32) and (I <= Length(S)) do Inc(I);
      S := Copy(S, 1, I);
      L := GetTextWidth(S);
      SetUrl(Rect(round(X + LB), round(y + 0.33 * FCurrentFontSize), round(X + LB + L), round(Y + FCurrentFontSize)), S);
    end;
  end;
begin
  RawTextOut(ExtToIntX(X), ExtToIntY(Y) - FCurrentFontSize, Orientation, TextStr);
  FTextAngle := Orientation;
  if FOwner.FACURL then
    if not FIsForm then
      if FTextAngle = 0 then
      begin
        CheckURL('http://');
        CheckURL('mailto:');
        CheckURL('ftp://');
      end;
end;

procedure TPDFPage.TextShow(TextStr: string);

begin
  if not FTextInited then
    raise TPDFException.Create(STextObjectNotInited);
  if not FFontInited then
    raise TPDFException.Create(SActiveFontNotSetting);
  AppendAction('(' + EscapeSpecialChar(TextStr) + ') Tj');
  if FEBold then
  begin
    AppendAction('-0.02 -0.02 TD');
    AppendAction('(' + EscapeSpecialChar(TextStr) + ') Tj');
    AppendAction('0.02 0 TD');
    AppendAction('(' + EscapeSpecialChar(TextStr) + ') Tj');
    AppendAction('-0.02 0.02 TD');
    AppendAction('(' + EscapeSpecialChar(TextStr) + ') Tj');
  end;
  if FEUnderLine or FEStrike then
  begin
    AppendAction('ET');
    FTextInited := False;
  end;
  if FEUnderLine then
  begin
    RawRectRotated(FCTM.x + 3 * sin((PI / 180) * FRealAngle), FCTM.y - 3 * cos(FRealAngle * (PI / 180)),
      GetTextWidth(TextStr) / D2P, FCurrentFontSize * 0.05, FRealAngle);
  end;
  if FEStrike then
  begin
    RawRectRotated(FCTM.x - FCurrentFontSize / 4 * sin((PI / 180) * FRealAngle), FCTM.y + FCurrentFontSize / 4 * cos(FRealAngle * (PI / 180)),
      GetTextWidth(TextStr) / d2p, FCurrentFontSize * 0.05, FRealAngle);
  end;
  if FEUnderLine or FEStrike then
  begin
    case FRender of
      0: Fill;
      1: Stroke;
      2: FillAndStroke;
    else Fill;
    end;
    AppendAction('BT');
    FTextInited := True;
    AppendAction(FormatFloat(FCTM.a) + ' ' + FormatFloat(FCTM.b) + ' ' + FormatFloat(FCTM.c) + ' ' +
      FormatFloat(FCTM.d) + ' ' + FormatFloat(FCTM.x) + ' ' + FormatFloat(FCTM.y) + ' Tm');
  end;
end;

procedure TPDFPage.Translate(XT, YT: Extended);
begin
  RawTranslate(ExtToIntX(XT), ExtToIntY(YT));
end;

procedure TPDFPage.RawShowImage(ImageIndex: Integer; x, y, w, h, angle: Extended);
begin
  if (ImageIndex < 0) or (ImageIndex > FOwner.Fimages.Count - 1) then
    raise TPDFException.Create(SOutOfRange);
  GStateSave;
  RawTranslate(x, y);
  if Abs(angle) > 0.001 then
    Rotate(angle);
  RawConcat(w, 0, 0, h, 0, 0);
  AppendAction('/' + FOwner.Fimages[ImageIndex].ImageName + ' Do');
  GStateRestore;
  if FLinkedImages.IndexOf(Pointer(FOwner.Fimages[ImageIndex])) = -1 then FLinkedImages.Add(Pointer(FOwner.Fimages[ImageIndex]));
end;

procedure TPDFPage.ShowImage(ImageIndex: Integer; x, y, w, h,
  angle: Extended);
begin
  RawShowImage(ImageIndex, ExtToIntX(X), ExtToIntY(y) - h / d2p, w / d2p, h / d2p, angle);
end;

procedure TPDFPage.DeleteAllAnnotations;
var
  i: Integer;
begin
  for i := 0 to FAnnot.Count - 1 do
    TPDFCustomAnnotation(FAnnot[i]).Free;
  FAnnot.Clear;
end;

function TPDFPage.GetTextWidth(Text: string): Extended;
var
  i: integer;
  ch: char;
  tmpWidth: Extended;
begin
  if not FFontInited then
    raise TPDFException.Create(SActiveFontNotSetting);
  Result := 0;
  if FOwner.FFonts[FCurrentFontIndex].IsCJK then Exit;
  for i := 1 to Length(Text) do
  begin
    ch := Text[i];
    tmpWidth := FOwner.FFonts[FCurrentFontIndex].GetWidth(Ord(ch)) * FCurrentFontSize / 1000;
    if FHorizontalScaling <> 100 then
      tmpWidth := tmpWidth * FHorizontalScaling / 100;
    if tmpWidth > 0 then
      tmpWidth := tmpWidth + FCharSpace
    else
      tmpWidth := 0;
    if (ch = ' ') and (FWordSpace > 0) and (i <> Length(Text)) then
      tmpWidth := tmpWidth + FWordSpace;
    Result := Result + tmpWidth;
  end;
  Result := IntToExtX(Result - FCharSpace);
end;

function TPDFPage.SetAnnotation(ARect: TRect; Title, Text: string;
  Color: TColor; Flags: TAnnotationFlags; Opened: Boolean; Charset: TFontCharset): TPDFCustomAnnotation;
var
  A: TPDFTextAnnotation;
begin
  if FIsForm then
    raise TPDFException.Create(SCannotCreateAnnotationToWatermark);
  A := TPDFTextAnnotation.Create(Self);
  A.Caption := Title;
  A.Text := Text;
  A.BorderColor := Color;
  A.Box := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  A.Flags := Flags;
  A.Charset := Charset;
  A.Opened := Opened;
  Result := A;
end;


function TPDFPage.SetLinkToPage(ARect: TRect; PageIndex,
  TopOffset: Integer): TPDFCustomAnnotation;
var
  A: TPDFActionAnnotation;
begin
  if FIsForm then
    raise TPDFException.Create(SCannotCreateLinkToPageToWatermark);
  A := TPDFActionAnnotation.Create(Self);
  A.Box := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  A.Action := TPDFGoToPageAction.Create;
  TPDFGoToPageAction(A.Action).PageIndex := PageIndex;
  TPDFGoToPageAction(A.Action).TopOffset := TopOffset;
  A.BorderStyle := '[]';
  Result := A;
end;

function TPDFPage.SetUrl(ARect: TRect; URL: string): TPDFCustomAnnotation;
var
  A: TPDFActionAnnotation;
begin
  if FIsForm then
    raise TPDFException.Create(SCannotCreateURLToWatermark);
  A := TPDFActionAnnotation.Create(Self);
  A.Box := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  A.Action := TPDFURLAction.Create;
  TPDFURLAction(A.Action).URL := URL;
  A.BorderStyle := '[]';
  Result := A;
end;

procedure TPDFPage.RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);
const
  b = 0.5522847498;
var
  RX, RY: Extended;
begin
  NormalizeRect(x1, y1, x2, y2);
  Rx := x3 / 2;
  Ry := y3 / 2;
  MoveTo(X1 + RX, Y1);
  LineTo(X2 - RX, Y1);
  Curveto(X2 - RX + b * RX, Y1, X2, Y1 + RY - b * RY, X2, Y1 + ry);
  LineTo(X2, Y2 - RY);
  Curveto(X2, Y2 - RY + b * RY, X2 - RX + b * RX, Y2, X2 - RX, Y2);
  LineTo(X1 + RX, Y2);
  Curveto(X1 + RX - b * RX, Y2, X1, Y2 - RY + b * RY, X1, Y2 - RY);
  LineTo(X1, Y1 + RY);
  Curveto(X1, Y1 + RY - b * RY, X1 + RX - b * RX, Y1, X1 + RX, Y1);
  ClosePath;
end;

procedure TPDFPage.TextBox(Rect: TRect; Text: string; Hor: THorJust; Vert: TVertJust);
var
  x, y: Extended;
begin
  NormalizeRect(Rect);
  Y := Rect.Top;
  x := Rect.Left;
  case Hor of
    hjLeft: x := Rect.Left;
    hjRight: x := Rect.Right - GetTextWidth(Text);
    hjCenter: x := Rect.Left + (Rect.Right - Rect.Left - GetTextWidth(Text)) / 2;
  end;
  case Vert of
    vjUp: y := Rect.Top;
    vjDown: y := Rect.Bottom - FCurrentFontSize;
    vjCenter: y := Rect.Top + (Rect.Bottom - Rect.Top - FCurrentFontSize) / 2;
  end;
  TextOut(x, y, 0, Text);
end;


procedure TPDFPage.ResetTextCTM;
begin
  FCTM.a := 1;
  FCTM.b := 0;
  FCTM.c := 0;
  FCTM.d := 1;
  FCTM.x := 0;
  FCTM.y := 0;
  FTextAngle := 0;
  FRealAngle := 0;
end;

procedure TPDFPage.SetOrientation(const Value: TPDFPageOrientation);
begin
  if Factions then
    raise TPDFException.Create(SPageInProgress);
  FOrientation := Value;
  if Value = poPagePortrait then
    if FWidth > FHeight then swp(FWidth, FHeight);
  if Value = poPageLandScape then
    if FWidth < FHeight then swp(FWidth, FHeight);
end;

procedure TPDFPage.Concat(A, B, C, D, E, F: Extended);
begin
  RawConcat(A, B, C, D, ExtToIntX(E), -ExtToIntX(F));
end;

function TPDFPage.GetHeight: Integer;
begin
  Result := Round(FHeight * D2P);
end;

function TPDFPage.GetWidth: Integer;
begin
  Result := Round(FWidth * D2P);
end;

procedure TPDFPage.CloseCanvas;
var
  s: string;
  Pars: TEMWParser;
  SZ: TSize;
  Z: Boolean;
begin
  if FMF = nil then Exit;
  FCanvas.Free;
  Z := False;
  Pars := TEMWParser.Create(Self);
  try
    FMF.Enhanced := True;
    Pars.LoadMetaFile(FMF);
    SZ := Pars.GetMax;
    if (SZ.cx <= 0) or (SZ.cy <= 0) then Z := True;
    if not Z then
    begin
      s := FContent.Text;
      FContent.Clear;
      Pars.Execute;
      if FCanvasOver then FContent.Text := FContent.Text + #13 + s
      else FContent.Text := s + #13 + FContent.Text;
    end;
  finally
    Pars.Free;
  end;
  FMF.Free;
  FMF := nil;
end;

procedure TPDFPage.PlayMetaFile(MF: TMetaFile);
begin
  PlayMetaFile(MF, 0, 0, 1, 1);
end;

procedure TPDFPage.PlayMetaFile(MF: TMetafile; x, y, XScale, YScale: Extended);
var
  P: TPDFPage;
  Pars: TEMWParser;
  S: TSize;
  Z: Boolean;
begin
  Z := False;
  P := FForms.Add;
  if P.FCanvas <> nil then
    P.DeleteCanvas;
  P.FWidth := FWidth;
  P.FHeight := FHeight;
  P.FRes := FRes;
  P.D2P := D2P;
  Pars := TEMWParser.Create(P);
  try
    MF.Enhanced := True;
    Pars.LoadMetaFile(MF);
    S := Pars.GetMax;
    if (S.cx <= 0) or (S.cy <= 0) then Z := True;
    if not Z then
    begin
      P.Width := abs(S.cx);
      P.Height := abs(S.cy);
      Pars.Execute;
    end else FForms.Delete(P);
  finally
    Pars.Free;
  end;
  if not Z then
  begin
    AppendAction('q /IF' + IntToStr(FForms.IndexOf(P)) + ' Do Q');
    P.FMatrix.x := x / D2P;
    P.FMatrix.y := (Height - P.Height * YScale - y) / D2P;
    P.FMatrix.a := XScale;
    P.FMatrix.d := YScale;
  end;
end;

procedure TPDFPage.CreateCanvas;
begin
  if FMF = nil then
  begin
    FMF := TMetafile.Create;
    FCanvas := TMetafileCanvas.Create(FMF, 0);
  end else
    raise TPDFException.Create(SCanvasForThisPageAlreadyCreated);
end;

procedure TPDFPage.SetWaterMark(const Value: Integer);
begin
  if Value < 0 then
  begin
    FWaterMark := Value;
    Exit;
  end;
  if FIsForm then
    raise TPDFException.Create(SWatermarkCannotHaveWatermark);
  if Value >= FOwner.FWaterMarks.Count then
    raise TPDFException.Create(SWaterMarkWithSuchIndexNotCreatedYetForThisDocument);
  FWaterMark := Value;
end;

procedure TPDFPage.DeleteCanvas;
begin
  if FMF <> nil then
  begin
    FCanvas.Free;
    FMF.Free;
    FMF := nil;
    FCanvas := nil;
  end;
end;

function TPDFPage.SetAction(ARect: TRect; Action: TPDFAction): TPDFCustomAnnotation;
var
  A: TPDFActionAnnotation;
begin
  if FIsForm then
    raise TPDFException.Create(SCannotCreateURLToWatermark);
  A := TPDFActionAnnotation.Create(Self);
//  FAnnot.Add(Pointer(A));
  A.Box := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  A.Action := Action;
  A.BorderStyle := '[]';
  Result := A;
end;

procedure TPDFPage.SetActiveFont(FontName: string; FontStyle: TFontStyles; FontSize: Extended);
begin
  SetActiveFont (FontName,FontStyle,FontSize,FOwner.FDefaultCharset);
end;

procedure TPDFPage.SetThumbnail(const Value: Integer);
begin
  if Value < 0 then
  begin
    FThumbnail := Value;
    Exit;
  end;
  if FIsForm then
    raise TPDFException.Create(SWatermarkCannotHaveThumbnail);
  if Value >= FOwner.FImages.Count then
    raise TPDFException.Create(SImageWithSuchIndexNotCreatedYetForThisDocument);
  FThumbnail := Value;
end;

procedure TPDFPage.PrepareID;
var
  I: Integer;
begin
  for I := 0 to FLinkedFont.Count - 1 do
    if TPDFFont(FLinkedFont[I]).FontID = -1 then TPDFFont(FLinkedFont[I]).FontID := FOwner.GetNextID;
  for I := 0 to FLinkedImages.Count - 1 do
    if TPDFImage(FLinkedImages[I]).PictureID = -1 then
      TPDFImage(FLinkedImages[I]).Save(FOwner);
  for I := 0 to FAnnot.Count - 1 do
    if TPDFCustomAnnotation(FAnnot[I]).AnnotID = -1 then TPDFCustomAnnotation(FAnnot[I]).AnnotID := FOwner.GetNextID;
  if FThumbnail >= 0 then
    if FOwner.FImages[FThumbnail].PictureID = -1 then FOwner.FImages[FThumbnail].Save(FOwner);
end;

function TPDFPage.CreateControl(CClass: TPDFControlClass; ControlName: string;
  Box: TRect): TPDFControl;
var
  SO: TPDFControl;
begin
  SO := CClass.Create(Self, ControlName);
  SO.Box := Box;
  Result := SO;
end;


{ TPDFPages }

function TPDFPages.Add: TPDFPage;
begin
  Result := TPDFPage.Create(FOwner);
  FPages.Add(Pointer(Result));
  Result.FIsForm := IsWaterMarks;
end;

procedure TPDFPages.Clear;
var
  I: Integer;
begin
  for I := 0 to FPages.Count - 1 do
    TPDFPage(FPages[I]).Free;
  FPages.Clear;
end;

constructor TPDFPages.Create(AOwner: TPDFDocument; WM: Boolean);
begin
  FOwner := AOwner;
  FPages := TList.Create;
  IsWaterMarks := WM;
end;

procedure TPDFPages.Delete(Page: TPDFPage);
var
  I: Integer;
begin
  I := IndexOf(Page);
  if I <> -1 then
  begin
    Page.Free;
    FPages.Delete(I);
  end;
end;

destructor TPDFPages.Destroy;
begin
  Clear;
  FPages.Free;
end;

function TPDFPages.GetCount: Integer;
begin
  Result := FPages.Count;
end;

function TPDFPages.GetPage(Index: Integer): TPDFPage;
begin
  Result := TPDFPage(FPages[Index]);
end;

function TPDFPages.IndexOf(Page: TPDFPage): Integer;
begin
  Result := FPages.IndexOf(Pointer(Page));
end;

{ TPDFFonts }

function TPDFFonts.Add: TPDFFont;
begin
  Result := TPDFFont.Create;
  FFonts.Add(Pointer(Result));
  Result.FontID := FOwner.GetNextID;
end;

function TPDFFonts.CheckFont(FontName: TFontName; FontStyle: TFontStyles; FontCharset: TFontCharset): string;
var
  I: Integer;
  k: Integer;
  FF: TPDFFont;
  FFN: string;
  ID: Integer;
  FA: string;
  FAD, FD: string;
  RC: TFontCharset;
  RS: TFontStyles;
  LF: TLogFont;
  DC: HDC;
  function A(const Enum: ENUMLOGFONTEX; const PFD: TNEWTEXTMETRICEXA; FT: DWORD; var Test: Integer): Integer; stdcall;
  begin
    Test := 1;
    Result := 0;
  end;
begin
  if FontCharset = default_charset then FontCharset := ANSI_CHARSET;
  if FontCharset in [$80, 129, 136, 134] then
  begin
    case FontCharset of
      $80: FFN := 'JapanFont';
      129: FFN := 'KoreanFont';
      136: FFN := 'ChineseTraditionalFont';
    else FFN := 'ChineseSimplifiedFont';
    end;
    i := IndexOf(FFN, FontStyle, FontCharset);
    if i <> -1 then
    begin
      FLast := FFonts[i];
      FLastIndex := I;
    end else
    begin
      FD := '';
      if fsBold in FontStyle then
        FD := FD + 'B';
      if fsItalic in FontStyle then
        FD := FD + 'I';
      FF := Add;
      FF.Standart := True;
      FF.FontName := FFN;
      FF.RealName := FFN;
      FF.IsCJK := True;
      case FontCharset of
        $80:
          begin
            FF.AliasName := 'CIDJ' + FD;
            FF.CJKType := cjkJapan;
          end;
        129:
          begin
            FF.AliasName := 'CIDK' + FD;
            FF.CJKType := cjkKorean;
          end;
        136:
          begin
            FF.AliasName := 'CIDCT' + FD;
            FF.CJKType := cjkChinaTrad;
          end;
      else
        begin
          FF.AliasName := 'CIDCS' + FD;
          FF.CJKType := cjkChinaSimpl;
        end;
      end;
      FF.RealStyle := FontStyle;
      FF.RealCharset := FontCharset;
      FLast := FF;
      FLastIndex := FFonts.Count - 1;
    end;
    Exit;
  end;
  if UpperCase(FontName) = 'ARIAL' then
    if FontCharset = ANSI_CHARSET then FontName := 'Helvetica' else
    begin
      DC := GetDC(0);
      try
        FillChar(LF, SizeOf(LF), 0);
        LF.lfFaceName := 'ARIAL';
        LF.lfCharSet := FontCharset;
        I := 0;
        EnumFontFamiliesEx(DC, LF, @A, Longint(@I), 0);
        if I = 0 then FontName := 'Helvetica';
      finally
        ReleaseDC(0, DC);
      end;
    end;
  if UpperCase(FontName) = 'COURIER NEW' then
    if FontCharset = ANSI_CHARSET then FontName := 'Courier' else
    begin
      DC := GetDC(0);
      try
        FillChar(LF, SizeOf(LF), 0);
        LF.lfFaceName := 'COURIER NEW';
        LF.lfCharSet := FontCharset;
        I := 0;
        EnumFontFamiliesEx(DC, LF, @A, Longint(@I), 0);
        if I = 0 then FontName := 'Courier';
      finally
        ReleaseDC(0, DC);
      end;
    end;
  if UpperCase(FontName) = 'TIMES NEW ROMAN' then
    if FontCharset = ANSI_CHARSET then FontName := 'Times' else
    begin
      DC := GetDC(0);
      try
        FillChar(LF, SizeOf(LF), 0);
        LF.lfFaceName := 'TIMES NEW ROMAN';
        LF.lfCharSet := FontCharset;
        I := 0;
        EnumFontFamiliesEx(DC, LF, @A, Longint(@I), 0);
        if I = 0 then FontName := 'Times';
      finally
        ReleaseDC(0, DC);
      end;
    end;

  RS := FontStyle;
  RS := RS - [fsUnderline, fsStrikeOut];
  RC := FontCharset;
  ID := -1;
  FA := UpperCase(FontName);
  if FA = 'HELVETICA' then
    if (fsBold in FontStyle) and (fsItalic in FontStyle) then
    begin
      FFN := 'Helvetica-BoldOblique';
      ID := 3;
    end
    else
      if fsBold in FontStyle then
      begin
        FFN := 'Helvetica-Bold';
        ID := 1;
      end
      else
        if fsItalic in FontStyle then
        begin
          FFN := 'Helvetica-Oblique';
          ID := 2;
        end
        else
        begin
          FFN := 'Helvetica';
          ID := 0;
        end;
  if FA = 'TIMES' then
    if (fsBold in FontStyle) and (fsItalic in FontStyle) then
    begin
      FFN := 'Times-BoldItalic';
      ID := 7;
    end
    else
      if fsBold in FontStyle then
      begin
        FFN := 'Times-Bold';
        ID := 5;
      end
      else
        if fsItalic in FontStyle then
        begin
          FFN := 'Times-Italic';
          ID := 6;
        end
        else
        begin
          FFN := 'Times-Roman';
          ID := 4;
        end;
  if FA = 'COURIER' then
    if (fsBold in FontStyle) and (fsItalic in FontStyle) then
    begin
      FFN := 'Courier-BoldOblique';
      ID := 11;
    end
    else
      if fsBold in FontStyle then
      begin
        FFN := 'Courier-Bold';
        ID := 9;
      end
      else
        if fsItalic in FontStyle then
        begin
          FFN := 'Courier-Oblique';
          ID := 10;
        end
        else
        begin
          FFN := 'Courier';
          ID := 8;
        end;
  if FA = 'SYMBOL' then
  begin
    FFN := 'Symbol';
    ID := 12;
  end;
  if FA = 'ZAPFDINGBATS' then
  begin
    FFN := 'ZapfDingbats';
    ID := 13
  end;
  if ID <> -1 then
  begin
    RC := ANSI_CHARSET;
    i := IndexOf(FFN, RS, RC);
    if i <> -1 then
    begin
      FLast := FFonts[i];
      FLastIndex := I;
    end else
    begin
      FF := Add;
      FF.Standart := True;
      FF.FontName := FFN;
      FF.RealName := FFN;
      FF.StdID := ID + 1;
      FF.RealStyle := RS;
      FF.AliasName := 'F' + IntToStr(ID);
      FLast := FF;
      FLastIndex := FFonts.Count - 1;
    end;
    Exit;
  end;
  if not FontTest(FontName, RS, RC, FAD) then
    raise TPDFException.Create(SNotValidTrueTypeFont);
  FD := FontName;
  if fsBold in RS then
    FD := FD + ' Bold';
  if fsItalic in RS then
    FD := FD + ' Italic';
  FFN := ReplStr(FD, ' ', '#20');
  I := IndexOf(FontName, RS, RC);
  if I <> -1 then
  begin
    FLast := FFonts[i];
    FLastIndex := I;
  end else
  begin
    FF := Add;
    FF.Standart := False;
    FF.FontName := FFN;
    FF.RealName := FontName;
    FF.RealStyle := RS;
    FF.RealCharset := RC;
    k := 0;
    for i := 0 to Count - 1 do
      if not Items[i].Standart then Inc(k);
    FF.AliasName := 'TT' + IntToStr(k);
    FLast := FF;
    FLastIndex := Count - 1;
    Items[FLastIndex].LoadingWidth;
  end;
end;

procedure TPDFFonts.Clear;
var
  I: Integer;
begin
  for I := 0 to FFonts.Count - 1 do
    TPDFFont(FFonts[I]).Free;
  FFonts.Clear;
end;

constructor TPDFFonts.Create(AOwner: TPDFDocument);
begin
  FFonts := TList.Create;
  FOwner := AOwner;
end;

procedure TPDFFonts.Delete(Index: Integer);
begin
  TPDFFont(FFonts[Index]).Free;
  FFonts.Delete(Index);
end;

destructor TPDFFonts.Destroy;
begin
  Clear;
  FFonts.Free;
  inherited;
end;

procedure TPDFFonts.EmbiddingFontFiles;
var
  I, O, RS: Integer;
  Files: TStringList;
  MS: TMemoryStream;
  CS: TCompressionStream;
  F: Boolean;
  P: Pointer;
  FZ: Cardinal;
  B: TBitmap;
begin
  Files := TStringList.Create;
  try
    for I := 0 to Count - 1 do
    begin
      if Items[I].Standart then Continue;
      F := False;
      for O := 0 to FOwner.NonEmbeddedFont.Count - 1 do
        if UpperCase(FOwner.NonEmbeddedFont[O]) = UpperCase(Items[i].RealName) then
        begin
          F := True;
          Items[I].FontFileID := -1;
          Break;
        end;
      if F then Continue;
      RS := 0;
      O := Files.IndexOf(Items[I].FontName);
      if O = -1 then
      begin
        Files.AddObject(Items[i].RealName {FontName}, TObject(Items[I].FontFileID));
        MS := TMemoryStream.Create;
        try
          B := TBitmap.Create;
          try
            B.Canvas.Font.Name := Items[i].RealName;
            B.Canvas.Font.Style := Items[i].RealStyle;
            FZ := GetFontData(B.Canvas.Handle, 0, 0, nil, 0);
            if FZ = GDI_ERROR then
              raise TPDFException.Create(SCannotReceiveDataForFont + Items[i].FontName);
            GetMem(P, FZ);
            try
              if GetFontData(B.Canvas.Handle, 0, 0, P, FZ) = GDI_ERROR then
                raise TPDFException.Create(SCannotReceiveDataForFont + Items[i].FontName);
              CS := TCompressionStream.Create(clDefault, MS);
              try
                CS.Write(P^, FZ);
              finally
                CS.Free;
              end;
              RS := FZ;
            finally
              FreeMem(P);
            end;
          finally
            B.Free;
          end;
          MS.Position := 0;
          FOwner.StartObj(Items[I].FontFileID);
          FOwner.SaveToStream('/Filter /FlateDecode /Length ' + IntToStr(MS.Size) + ' /Length1 ' + IntToStr(RS));
          FOwner.CloseHObj;
          FOwner.StartStream;
          EnCodeStream(FOwner.FProtectionEnabled, FOwner.FKey, Items[I].FontFileID, MS);
          FOwner.FStream.CopyFrom(MS, MS.Size);
          FOwner.SaveToStream('');
          FOwner.CloseStream;
          FOwner.CloseObj;
        finally
          MS.Free;
        end;
      end else Items[I].FontFileID := Integer(Files.Objects[O]);
    end;
  finally
    Files.Free;
  end;
end;

function TPDFFonts.GetCount: Integer;
begin
  Result := FFonts.Count;
end;

function TPDFFonts.GetFont(Index: Integer): TPDFFont;
begin
  Result := TPDFFont(FFonts[Index]);
end;


function TPDFFonts.IndexOf(FontName: TFontName; FontStyle: TFontStyles;
  FontCharset: TFontCharset): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if (UpperCase(Items[i].RealName) = UpperCase(FontName)) and (Items[i].RealStyle = FontStyle) and (Items[i].RealCharset = FontCharset) then
    begin
      Result := i;
      Break;
    end;
end;

{ TPDFImages }

function TPDFImages.Add(Image: TGraphic;
  Compression: TImageCompressionType): TPDFImage;
begin
  Result := TPDFImage.Create(Image, Compression, FOwner);
  FImages.Add(Pointer(Result));
  Result.ImageName := 'Im' + IntToStr(Count - 1);
//  Result.PictureID := FOwner.GetNextID;
end;

function TPDFImages.Add(FileName: TFileName;
  Compression: TImageCompressionType): TPDFImage;
begin
  Result := TPDFImage.Create(FileName, Compression, FOwner);
  FImages.Add(Pointer(Result));
  Result.ImageName := 'Im' + IntToStr(Count - 1);
//  Result.PictureID := FOwner.GetNextID;
end;

procedure TPDFImages.Clear;
var
  I: Integer;
begin
  for I := 0 to FImages.Count - 1 do
    TPDFImage(FImages[I]).Free;
  FImages.Clear;
end;

constructor TPDFImages.Create(AOwner: TPDFDocument);
begin
  FOwner := AOwner;
  FImages := TList.Create;
end;

procedure TPDFImages.Delete(Index: Integer);
begin
  TPDFImage(FImages[Index]).Free;
  FImages.Delete(Index);
end;

destructor TPDFImages.Destroy;
begin
  Clear;
  FImages.Free;
  inherited;
end;

function TPDFImages.GetCount: Integer;
begin
  Result := FImages.Count;
end;

function TPDFImages.GetImage(Index: Integer): TPDFImage;
begin
  Result := TPDFImage(FImages[Index]);
end;

{ TPDFFont }

constructor TPDFFont.Create;
begin
  WidthLoaded := False;
  IsCJK := False;
  FontID := -1;
end;

function TPDFFont.GetWidth(Index: Integer): Word;
begin
  if IsCJK then
  begin
    Result := 1000;
    Exit;
  end;
  if Standart then
  begin
    Result := stWidth[StdID, Index];
    Exit;
  end;
  Result := FWidth[Index];
end;

procedure TPDFFont.LoadingWidth;
type
  A = array[0..255] of ABC;
var
  AR: ^A;
  BM: TBitmap;
  I: Integer;
begin
  New(Ar);
  try
    BM := TBitmap.Create;
    try
      BM.Canvas.Font.Name := RealName;
      BM.Canvas.Font.Style := RealStyle;
      BM.Canvas.Font.Charset := RealCharset;
      BM.Canvas.Font.Size := Round(1000 * 72 / BM.Canvas.Font.PixelsPerInch);
      GetCharABCWidths(BM.Canvas.Handle, 0, 255, ar^);
      for I := 0 to 255 do
        FWidth[I] := ar^[I].abcA + Integer(ar^[I].abcB) + ar^[I].abcC;
    finally
      BM.Free;
    end;
  finally
    Dispose(AR);
  end;
end;

procedure TPDFFont.Save(Doc: TPDFDocument);
var
  BM: TBitmap;
  I, J: Integer;
  S, Wid: string;
  OTM: OUTLINETEXTMETRIC;
  CodePage: Integer;
  st: string;
  ad: array[1..255] of word;
  W: PWideChar;
  k: Integer;
  F: Boolean;
  DDD: Integer;
  LR: Boolean;
begin
  if IsCJK then
  begin
    st := '';
    if fsbold in RealStyle then st := st + 'Bold';
    if fsItalic in RealStyle then st := st + 'Italic';
    if st <> '' then st := ',' + st;
    DDD := Doc.GetNextID;
    FontDescriptorID := Doc.GetNextID;
    Doc.StartObj(FontID);
    case CJKType of
      cjkJapan:
        begin
          Doc.SaveToStream('/Type /Font /Subtype /Type0  /BaseFont /HeiseiMin-W3' + st);
          Doc.SaveToStream('/DescendantFonts  [ ' + IntToStr(DDD) + ' 0 R ] /Encoding /90msp-RKSJ-H');
          Doc.CloseHObj;
          Doc.CloseObj;
          Doc.StartObj(DDD);
          Doc.SaveToStream('/Type /Font /Subtype /CIDFontType2 /BaseFont /HeiseiMin-W3' + st);
          Doc.SaveToStream('/WinCharSet 128 /FontDescriptor ' + IntToStr(FontDescriptorID) + ' 0 R');
          Doc.SaveToStream('/CIDSystemInfo << /Registry (Adobe) /Ordering (Japan1) /Supplement 2 >>');
          Doc.SaveToStream('/DW 1000 /W [ 1 95 500 231 632 500 ]');
          Doc.CloseHObj;
          Doc.CloseObj;
          Doc.StartObj(FontDescriptorID);
          Doc.SaveToStream('/Type /FontDescriptor');
          Doc.SaveToStream('/Ascent 857');
          Doc.SaveToStream('/CapHeight 718');
          Doc.SaveToStream('/Descent -143');
          Doc.SaveToStream('/Flags 6');
          Doc.SaveToStream('/FontBBox [-123 -257 1001 910]');
          Doc.SaveToStream('/FontName /HeiseiMin-W3' + st);
          Doc.SaveToStream('/ItalicAngle 0');
          Doc.SaveToStream('/MissingWidth 500');
          Doc.SaveToStream('/StemV 93');
          Doc.SaveToStream('/StemH 31');
          Doc.SaveToStream('/XHeight 500');
          Doc.SaveToStream('/Leading 250');
          Doc.SaveToStream('/MaxWidth 1000');
          Doc.SaveToStream('/AvgWidth 702');
          Doc.SaveToStream('/Style << /Panose <010502020400000000000000> >>');
          Doc.CloseHObj;
          Doc.CloseObj;
        end;
      cjkKorean:
        begin
          Doc.SaveToStream('/Type /Font /Subtype /Type0  /BaseFont /HYSMyeongJo-Medium' + st);
          Doc.SaveToStream('/DescendantFonts  [ ' + IntToStr(DDD) + ' 0 R ] /Encoding /KSCms-UHC-H');
          Doc.CloseHObj;
          Doc.CloseObj;
          Doc.StartObj(DDD);
          Doc.SaveToStream('/Type /Font /Subtype /CIDFontType2 /BaseFont /HYSMyeongJo-Medium' + st);
          Doc.SaveToStream('/WinCharSet 128 /FontDescriptor ' + IntToStr(FontDescriptorID) + ' 0 R');
          Doc.SaveToStream('/CIDSystemInfo << /Registry (Adobe) /Ordering (Korea1) /Supplement 1 >>');
          Doc.SaveToStream('/DW 1000 /W [ 1 95 500 8094 8190 500 ]');
          Doc.CloseHObj;
          Doc.CloseObj;
          Doc.StartObj(FontDescriptorID);
          Doc.SaveToStream('/Type /FontDescriptor');
          Doc.SaveToStream('/Ascent 880');
          Doc.SaveToStream('/CapHeight 800');
          Doc.SaveToStream('/Descent -120');
          Doc.SaveToStream('/Flags 6');
          Doc.SaveToStream('/FontBBox [-0 -148 1001 880]');
          Doc.SaveToStream('/FontName /HYSMyeongJo-Medium' + st);
          Doc.SaveToStream('/ItalicAngle 0');
          Doc.SaveToStream('/MissingWidth 500');
          Doc.SaveToStream('/StemV 93');
          Doc.SaveToStream('/StemH 31');
          Doc.SaveToStream('/XHeight 616');
          Doc.SaveToStream('/Leading 250');
          Doc.SaveToStream('/MaxWidth 1000');
          Doc.SaveToStream('/AvgWidth 1000');
          Doc.SaveToStream('/Style << /Panose <010502020400000000000000> >>');
          Doc.CloseHObj;
          Doc.CloseObj;
        end;
      cjkChinaTrad:
        begin
          Doc.SaveToStream('/Type /Font /Subtype /Type0  /BaseFont /MSung-Light' + st);
          Doc.SaveToStream('/DescendantFonts  [ ' + IntToStr(DDD) + ' 0 R ] /Encoding /ETenms-B5-H');
          Doc.CloseHObj;
          Doc.CloseObj;
          Doc.StartObj(DDD);
          Doc.SaveToStream('/Type /Font /Subtype /CIDFontType2 /BaseFont /MSung-Light' + st);
          Doc.SaveToStream('/WinCharSet 128 /FontDescriptor ' + IntToStr(FontDescriptorID) + ' 0 R');
          Doc.SaveToStream('/CIDSystemInfo << /Registry (Adobe) /Ordering (CNS1) /Supplement 0 >>');
          Doc.SaveToStream('/DW 1000 /W [ 1 95 500 13648 13742 500 ]');
          Doc.CloseHObj;
          Doc.CloseObj;
          Doc.StartObj(FontDescriptorID);
          Doc.SaveToStream('/Type /FontDescriptor');
          Doc.SaveToStream('/Ascent 880');
          Doc.SaveToStream('/CapHeight 880');
          Doc.SaveToStream('/Descent -120');
          Doc.SaveToStream('/Flags 6');
          Doc.SaveToStream('/FontBBox [-160 -249 1015 888]');
          Doc.SaveToStream('/FontName /MSung-Light' + st);
          Doc.SaveToStream('/ItalicAngle 0');
          Doc.SaveToStream('/MissingWidth 500');
          Doc.SaveToStream('/StemV 93');
          Doc.SaveToStream('/StemH 31');
          Doc.SaveToStream('/XHeight 616');
          Doc.SaveToStream('/Leading 250');
          Doc.SaveToStream('/MaxWidth 1000');
          Doc.SaveToStream('/AvgWidth 1000');
          Doc.SaveToStream('/Style << /Panose <010502020400000000000000> >>');
          Doc.CloseHObj;
          Doc.CloseObj;
        end;
    else
      begin
        Doc.SaveToStream('/Type /Font /Subtype /Type0  /BaseFont /STSong-Light' + st);
        Doc.SaveToStream('/DescendantFonts  [ ' + IntToStr(DDD) + ' 0 R ] /Encoding /GB-EUC-H');
        Doc.CloseHObj;
        Doc.CloseObj;
        Doc.StartObj(DDD);
        Doc.SaveToStream('/Type /Font /Subtype /CIDFontType2 /BaseFont /STSong-Light' + st);
        Doc.SaveToStream('/WinCharSet 128 /FontDescriptor ' + IntToStr(FontDescriptorID) + ' 0 R');
        Doc.SaveToStream('/CIDSystemInfo << /Registry (Adobe) /Ordering (GB1) /Supplement 2 >>');
        Doc.SaveToStream('/DW 1000 /W [ 1 95 500 814 939 500 7712 [ 500 ] 7716 [ 500 ] ]');
        Doc.CloseHObj;
        Doc.CloseObj;
        Doc.StartObj(FontDescriptorID);
        Doc.SaveToStream('/Type /FontDescriptor');
        Doc.SaveToStream('/Ascent 880');
        Doc.SaveToStream('/CapHeight 880');
        Doc.SaveToStream('/Descent -120');
        Doc.SaveToStream('/Flags 6');
        Doc.SaveToStream('/FontBBox [-25 -254 1000 880]');
        Doc.SaveToStream('/FontName /STSong-Light' + st);
        Doc.SaveToStream('/ItalicAngle 0');
        Doc.SaveToStream('/MissingWidth 500');
        Doc.SaveToStream('/StemV 93');
        Doc.SaveToStream('/StemH 31');
        Doc.SaveToStream('/XHeight 616');
        Doc.SaveToStream('/Leading 250');
        Doc.SaveToStream('/MaxWidth 1000');
        Doc.SaveToStream('/AvgWidth 1000');
        Doc.SaveToStream('/Style << /Panose <010502020400000000000000> >>');
        Doc.CloseHObj;
        Doc.CloseObj;
      end;
    end;
    Exit;
  end;
  if not Standart then
  begin
    if not WidthLoaded then LoadingWidth;
    BM := TBitmap.Create;
    try
      BM.Canvas.Font.Name := RealName;
      BM.Canvas.Font.Style := RealStyle;
      BM.Canvas.Font.Charset := RealCharset;
      BM.Canvas.Font.Size := Round(1000 * 72 / BM.Canvas.Font.PixelsPerInch);
      FillChar(OTM, SizeOf(OTM), 0);
      OTM.otmSize := SizeOf(OTM);
      GetOutlineTextMetrics(BM.Canvas.Handle, SizeOf(OTM), @OTM);
      Wid := '';
      for I := 0 to 15 do
      begin
        S := '';
        for J := 0 to 15 do
        begin
          S := S + IntToStr(FWidth[I * 16 + J]) + ' ';
        end;
        Wid := Wid + #13#10 + S;
      end;
    finally
      BM.Free;
    end;
    S := '';
    case RealCharset of
      BALTIC_CHARSET: S := '-Baltic';
      EASTEUROPE_CHARSET: S := '-EastEurope';
      GREEK_CHARSET: S := '-Greek';
      MAC_CHARSET: S := '-MAC';
      OEM_CHARSET: S := '-OEM';
      RUSSIAN_CHARSET: S := '-Russian';
      SYMBOL_CHARSET: S := '-Symbol';
      TURKISH_CHARSET: S := '-Turkish';
    end;
    Doc.StartObj(FontDescriptorID);
    Doc.SaveToStream('/Type /FontDescriptor');
    Doc.SaveToStream('/Ascent ' + IntToStr(OTM.otmAscent));
    Doc.SaveToStream('/CapHeight 666');
    Doc.SaveToStream('/Descent ' + IntToStr(OTM.otmDescent));
    Doc.SaveToStream('/Flags 32');
    Doc.SaveToStream('/FontBBox [' + IntToStr(OTM.otmrcFontBox.Left) + ' ' + IntToStr(OTM.otmrcFontBox.Bottom) + ' ' + IntToStr(OTM.otmrcFontBox.Right) + ' ' + IntToStr(OTM.otmrcFontBox.Top) + ']');
    Doc.SaveToStream('/FontName /' + FontName + S);
    Doc.SaveToStream('/ItalicAngle ' + IntToStr(OTM.otmItalicAngle));
    Doc.SaveToStream('/StemV 87');
    if FontFileID <> -1 then
      Doc.SaveToStream('/FontFile2 ' + IntToStr(FontFileID) + ' 0 R');
    Doc.CloseHObj;
    Doc.CloseObj;
    Doc.StartObj(FontID);
    Doc.SaveToStream('/Type /Font');
    Doc.SaveToStream('/Subtype /TrueType');
    Doc.SaveToStream('/BaseFont /' + FontName);
    Doc.SaveToStream('/FirstChar 0');
    Doc.SaveToStream('/LastChar 255');
    if RealCharset = ANSI_CHARSET then Doc.SaveToStream('/Encoding /WinAnsiEncoding') else
      if RealCharset = Symbol_charset then Doc.SaveToStream('/Encoding /StandardEncoding') else
        if RealCharset = MAC_CHARSET then Doc.SaveToStream('/Encoding /MacRomanEncoding') else
        begin
          Doc.SaveToStream('/Encoding <</Type/Encoding');
          case RealCharset of
            BALTIC_CHARSET: CodePage := 1257;
            CHINESEBIG5_CHARSET: CodePage := 950;
            EASTEUROPE_CHARSET: CodePage := 1250;
            GB2312_CHARSET: CodePage := 936;
            GREEK_CHARSET: CodePage := 1253;
            OEM_CHARSET: CodePage := CP_OEMCP;
            RUSSIAN_CHARSET: CodePage := 1251;
            SHIFTJIS_CHARSET: CodePage := 932;
            TURKISH_CHARSET: CodePage := 1254;
            HEBREW_CHARSET: CodePage := 1255;
            ARABIC_CHARSET: CodePage := 1256;
            THAI_CHARSET: CodePage := 874;
            VIETNAMESE_CHARSET: CodePage := 1258;
          else CodePage := 1252;
          end;
          st := '';
          for i := 1 to 255 do
            st := st + Chr(i);
          W := @ad;
          i := MultiByteToWideChar(CodePage, 0, PChar(st), 255, w, 255);
          if i <> 0 then
          begin
            Doc.SaveToStream('/Differences [1 ');
            for i := 1 to 255 do
            begin
              F := False;
              for k := 0 to 1050 do
                if ad[I] = AllGliph[k].UnicodeID then
                begin
                  LR := (I mod 16) = 0;
                  Doc.SaveToStream('/' + Allgliph[k].Name, LR);
                  F := True;
                  Break;
                end;
              if not F then
                if ad[I] > 256 then
                  Doc.SaveToStream('/uni' + WordToHex(ad[I]), False) else Doc.SaveToStream('/space', false);
            end;
            Doc.SaveToStream(']');
          end else
          begin
            Doc.SaveToStream('/BaseEncoding /WinAnsiEncoding');
          end;
          Doc.CloseHObj;
        end;
    Doc.SaveToStream('/FontDescriptor ' + IntToStr(FontDescriptorID) + ' 0 R');
    Doc.SaveToStream('/Widths [' + Wid + ']');
    Doc.CloseHObj;
    Doc.CloseObj;
  end else
  begin
    Doc.StartObj(FontID);
    Doc.SaveToStream('/Type /Font');
    Doc.SaveToStream('/Subtype /Type1');
    Doc.SaveToStream('/BaseFont /' + FontName);
    if (UpperCase(FontName) <> 'SYMBOL') and (UpperCase(FontName) <> 'ZAPFDINGBATS') then
      Doc.SaveToStream('/Encoding /WinAnsiEncoding');
    Doc.SaveToStream('/FirstChar 32');
    Doc.SaveToStream('/LastChar 255');
    Doc.CloseHObj;
    Doc.CloseObj;
  end;
end;

{ TPDFImage }

constructor TPDFImage.Create(Image: TGraphic;
  Compression: TImageCompressionType; Doc: TPDFDocument = nil);
var
  J: TJPEGImage;
  B: TBitmap;
  CS: TCompressionStream;
  pb: PByteArray;
  bb: Byte;
  x, y: Integer;
begin
  PictureID := -1;
  Saved := False;
  GrayScale := False;
  FCT := Compression;
  FWidth := Image.Width;
  FHeight := Image.Height;
  if not ((Image is TJPEGImage) or (Image is TBitmap)) then
    raise TPDFException.Create('Not valid image.');
  Data := TMemoryStream.Create;
  if FCT = ITCjpeg then
  begin
    J := TJPEGImage.Create;
    try
      J.Assign(Image);
      J.ProgressiveEncoding := False;
      if Doc <> nil then
        J.CompressionQuality := Doc.FJPEGQuality else J.CompressionQuality := 80;
      J.SaveToStream(Data);
      Data.Position := 0;
      if J.Grayscale then
        Grayscale := True;
      FBitPerPixel := 8;
    finally
      J.Free;
    end;
  end;
  if FCT = itcFlate then
  begin
    B := TBitmap.Create;
    try
      B.Assign(Image);
      b.PixelFormat := pf24bit;
      CS := TCompressionStream.Create(clDefault, Data);
      try
        for y := 0 to B.Height - 1 do
        begin
          pb := B.ScanLine[y];
          x := 0;
          while x < (b.Width - 1) * 3 do
          begin
            bb := pb[x];
            pb[x] := pb[x + 2];
            pb[x + 2] := bb;
            x := x + 3;
          end;
          CS.Write(pb^, b.Width * 3);
        end;
      finally
        CS.Free;
      end;
      FBitPerPixel := 8;
      Data.Position := 0;
    finally
      B.Free;
    end;
  end;
  if FCT in [itcCCITT3, itcCCITT32d, itcCCITT4] then
  begin
    if not (Image is TBitmap) then
      raise TPDFException.Create('CCITT compression work only for bitmap');
    FBitPerPixel := 1;
    case FCT of
      itcCCITT3: SaveBMPtoCCITT(TBitmap(Image), Data, CCITT31D);
      itcCCITT32d: SaveBMPtoCCITT(TBitmap(Image), Data, CCITT32D);
      itcCCITT4: SaveBMPtoCCITT(TBitmap(Image), Data, CCITT42D);
    end;
    Data.Position := 0;
  end;
end;

constructor TPDFImage.Create(FileName: TFileName;
  Compression: TImageCompressionType; Doc: TPDFDocument = nil);
var
  Gr: TGraphic;
begin
  try
    gr := TBitmap.Create;
    try
      Gr.LoadFromFile(FileName);
      Create(Gr, Compression, Doc);
    finally
      Gr.Free;
    end;
  except
    on Exception do
    begin
      gr := TJPEGImage.Create;
      try
        Gr.LoadFromFile(FileName);
        Create(Gr, Compression);
      finally
        Gr.Free;
      end;
    end;
  end;
end;

destructor TPDFImage.Destroy;
begin
  Data.Free;
  inherited;
end;

procedure TPDFImage.Save(Doc: TPDFDocument);
begin
  if Saved then Exit;
  Doc.StartObj(PictureID);
  Doc.SaveToStream('/Type /XObject');
  Doc.SaveToStream('/Subtype /Image');
  if (FBitPerPixel <> 1) and (not GrayScale) then Doc.SaveToStream('/ColorSpace /DeviceRGB')
  else Doc.SaveToStream('/ColorSpace /DeviceGray');
  Doc.SaveToStream('/BitsPerComponent ' + IntToStr(BitPerPixel));
  Doc.SaveToStream('/Width ' + IntToStr(FWidth));
  Doc.SaveToStream('/Height ' + IntToStr(FHeight));
  case FCT of
    itcJpeg: Doc.SaveToStream('/Filter /DCTDecode');
    itcFlate: Doc.SaveToStream('/Filter /FlateDecode');
  else Doc.SaveToStream('/Filter [/CCITTFaxDecode]');
  end;
  Doc.SaveToStream('/Length ' + IntToStr(Data.Size));
  case FCT of
    itcCCITT3: Doc.SaveToStream('/DecodeParms [<</K 0 /Columns ' + Inttostr(FWidth) + ' /Rows ' + IntToStr(FHeight) + '>>]');
    itcCCITT32d: Doc.SaveToStream('/DecodeParms [<</K 1 /Columns ' + Inttostr(FWidth) + ' /Rows ' + IntToStr(FHeight) + '>>]');
    itcCCITT4: Doc.SaveToStream('/DecodeParms [<</K -1 /Columns ' + Inttostr(FWidth) + ' /Rows ' + IntToStr(FHeight) + '>>]');
  end;
  Doc.CloseHObj;
  Doc.StartStream;
  Data.Position := 0;
  EnCodeStream(Doc.FProtectionEnabled, Doc.FKey, PictureID, Data);
  Doc.FStream.CopyFrom(Data, Data.Size);
  Data.Clear;
  Doc.CloseStream;
  Doc.CloseObj;
  Saved := True;
end;

{ TPDFOutlines }

function TPDFOutlines.Add(Node: TPDFOutlineNode): TPDFOutlineNode;
var
  N, T, M: TPDFOutlineNode;
  I: Integer;
begin
  N := TPDFOutlineNode.Create(Self);
  if Node <> nil then T := Node.FParent else T := nil;
  N.FParent := T;
  N.FNext := nil;
  M := nil;
  for I := 0 to FList.Count - 1 do
    if (TPDFOutlineNode(FList[I]).FParent = T) and (TPDFOutlineNode(FList[I]).FNext = nil) then
    begin
      M := TPDFOutlineNode(FList[I]);
      Break;
    end;
  if M <> nil then M.FNext := N;
  N.FPrev := M;
  FList.Add(Pointer(N));
  if T <> nil then T.FChild.Add(Pointer(N));
  Result := N;
end;

function TPDFOutlines.AddChild(Node: TPDFOutlineNode): TPDFOutlineNode;
var
  N, T, M: TPDFOutlineNode;
  I: Integer;
begin
  N := TPDFOutlineNode.Create(Self);
  T := Node;
  N.FParent := T;
  N.FNext := nil;
  M := nil;
  for I := 0 to FList.Count - 1 do
    if (TPDFOutlineNode(FList[I]).FParent = T) and (TPDFOutlineNode(FList[I]).FNext = nil) then
    begin
      M := TPDFOutlineNode(FList[I]);
      Break;
    end;
  if M <> nil then M.FNext := N;
  N.FPrev := M;
  FList.Add(Pointer(N));
  if T <> nil then T.FChild.Add(Pointer(N));
  Result := N;
end;

function TPDFOutlines.AddChildFirst(
  Node: TPDFOutlineNode): TPDFOutlineNode;
var
  N, T, M: TPDFOutlineNode;
  I: Integer;
begin
  N := TPDFOutlineNode.Create(Self);
  T := Node;
  N.FParent := T;
  N.FPrev := nil;
  M := nil;
  for I := 0 to FList.Count - 1 do
    if (TPDFOutlineNode(FList[I]).FParent = T) and (TPDFOutlineNode(FList[I]).FPrev = nil) then
    begin
      M := TPDFOutlineNode(FList[I]);
      Break;
    end;
  if M <> nil then M.FPrev := N;
  N.FNext := M;
  FList.Add(Pointer(N));
  if T <> nil then T.FChild.Add(Pointer(N));
  Result := N;
end;

{function TPDFOutlines.AddFirst(Node: TPDFOutlineNode): TPDFOutlineNode;
var
  N, T, M: TPDFOutlineNode;
  I: Integer;
begin
  N := TPDFOutlineNode.Create(Self);
  if Node <> nil then T := Node.FParent else T := nil;
  N.FParent := T;
  N.FPrev := nil;
  M := nil;
  for I := 0 to FList.Count - 1 do
    if (TPDFOutlineNode(FList[I]).FParent = T) and (TPDFOutlineNode(FList[I]).FPrev = nil) then
    begin
      M := TPDFOutlineNode(FList[I]);
      Break;
    end;
  if M <> nil then M.FPrev := N;
  N.FNext := M;
  FList.Add(Pointer(N));
  if T <> nil then T.FChild.Add(Pointer(N));
  Result := N;
end;}


procedure TPDFOutlines.Clear;
begin
  while FList.Count <> 0 do
    TPDFOutlineNode(FList[0]).Delete;
end;

constructor TPDFOutlines.Create(AOwner: TPDFDocument);
begin
  FList := TList.Create;
  FOwner := AOwner;
end;

procedure TPDFOutlines.Delete(Node: TPDFOutlineNode);
begin
  Node.Delete;
end;

destructor TPDFOutlines.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

function TPDFOutlines.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TPDFOutlines.GetFirstNode: TPDFOutlineNode;
begin
  if FList.Count <> 0 then Result := TPDFOutlineNode(FList[0]) else Result := nil;
end;

function TPDFOutlines.GetItem(Index: Integer): TPDFOutlineNode;
begin
  Result := TPDFOutlineNode(FList[Index]);
end;

function TPDFOutlines.Insert(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode;
begin
  Result:= Insert (Node,Title,Action,FOwner.FDefaultCharset);
end;

function TPDFOutlines.Insert(Node: TPDFOutlineNode): TPDFOutlineNode;
var
  N, Ne: TPDFOutlineNode;
begin
  if Node = nil then
  begin
    Result := Add(nil);
    Exit;
  end;
  N := TPDFOutlineNode.Create(Self);
  Ne := Node.FNext;
  N.FParent := Node.FParent;
  N.FPrev := Node;
  N.FNext := Node.FNext;
  Node.FNext := N;
  if Ne <> nil then Ne.FPrev := N;
  FList.Add(Pointer(N));
  if N.FParent <> nil then N.FParent.FChild.Add(Pointer(N));
  Result := N;
end;

function TPDFOutlines.Add(Node: TPDFOutlineNode; Title: string; Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode;
begin
  Result := Add(Node);
  Result.Title := Title;
  Result.Action := Action;
  Result.Charset := Charset;
end;

function TPDFOutlines.Add(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode;
begin
  Result:= Add (Node,Title,Action,FOwner.FDefaultCharset);
end;

function TPDFOutlines.AddChild(Node: TPDFOutlineNode; Title: string;
  Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode;
begin
  Result := AddChild(Node);
  Result.Title := Title;
  Result.Action := Action;
  Result.Charset := Charset;
end;

function TPDFOutlines.AddChild(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode;
begin
  Result:= AddChild (Node,Title,Action,FOwner.FDefaultCharset);
end;

function TPDFOutlines.AddChildFirst(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode;
begin
  Result:= AddChildFirst (Node,Title,Action,FOwner.FDefaultCharset);
end;

function TPDFOutlines.AddFirst(Node: TPDFOutlineNode; Title: string; Action: TPDFAction): TPDFOutlineNode;
begin
  Result:= AddFirst (Node,Title,Action,FOwner.FDefaultCharset);
end;

function TPDFOutlines.AddChildFirst(Node: TPDFOutlineNode; Title: string;
  Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode;
begin
  Result := AddChildFirst(Node);
  Result.Title := Title;
  Result.Action := Action;
  Result.Charset := Charset;
end;

function TPDFOutlines.AddFirst(Node: TPDFOutlineNode; Title: string;
  Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode;
begin
  Result := Add(Node);
  Result.Title := Title;
  Result.Action := Action;
  Result.Charset := Charset;
end;

function TPDFOutlines.Insert(Node: TPDFOutlineNode; Title: string;
  Action: TPDFAction; Charset: TFontCharset): TPDFOutlineNode;
begin
  Result := Insert(Node);
  Result.Title := Title;
  Result.Action := Action;
  Result.Charset := Charset;
end;

{ TPDFOutlineNode }

constructor TPDFOutlineNode.Create(AOwner: TPDFOutlines);
begin
  if AOwner = nil then
    raise TPDFException.Create(SOutlineNodeMustHaveOwner);
  FOwner := AOwner;
  FChild := TList.Create;
end;

procedure TPDFOutlineNode.Delete;
var
  I: Integer;
  P, N: TPDFOutlineNode;
begin
  DeleteChildren;
  P := GetPrev;
  N := GetNext;
  if P <> nil then
    P.FNext := N;
  if N <> nil then
    N.FPrev := P;
  I := FOwner.FList.IndexOf(Pointer(Self));
  if I <> -1 then FOwner.FList.Delete(I);
  if FParent <> nil then
  begin
    I := FParent.FChild.IndexOf(Pointer(Self));
    if I <> -1 then FParent.FChild.Delete(I);
  end;
  Free;
end;

procedure TPDFOutlineNode.DeleteChildren;
begin
  while FChild.Count <> 0 do
    TPDFOutlineNode(FChild[0]).Delete;
end;

destructor TPDFOutlineNode.Destroy;
begin
  FChild.Free;
  inherited;
end;


function TPDFOutlineNode.GetCount: Integer;
begin
  Result := FChild.Count;
end;


function TPDFOutlineNode.GetFirstChild: TPDFOutlineNode;
var
  I: Integer;
begin
  Result := nil;
  if Count = 0 then
    Exit;
  for I := 0 to FChild.Count - 1 do
    if TPDFOutlineNode(FChild[I]).FPrev = nil then
    begin
      Result := TPDFOutlineNode(FChild[I]);
      Exit;
    end;
end;

function TPDFOutlineNode.GetHasChildren: Boolean;
begin
  Result := Count <> 0;
end;

function TPDFOutlineNode.GetItem(Index: Integer): TPDFOutlineNode;
begin
  Result := TPDFOutlineNode(FChild[Index]);
end;

function TPDFOutlineNode.GetLastChild: TPDFOutlineNode;
var
  I: Integer;
begin
  Result := nil;
  if Count = 0 then
    Exit;
  for I := 0 to FChild.Count - 1 do
    if TPDFOutlineNode(FChild[I]).FNext = nil then
    begin
      Result := TPDFOutlineNode(FChild[I]);
      Exit;
    end;
end;

function TPDFOutlineNode.GetNext: TPDFOutlineNode;
var
  I: Integer;
begin
  I := FOwner.FList.IndexOf(Self);
  if I <> FOwner.FList.Count - 1 then Result := FOwner[i + 1] else Result := nil;
end;

function TPDFOutlineNode.GetNextChild(
  Node: TPDFOutlineNode): TPDFOutlineNode;
var
  i: Integer;
begin
  i := FChild.IndexOf(Pointer(Node));
  if (i = -1) or (i = FChild.Count - 1) then Result := nil else Result := TPDFOutlineNode(FChild[i + 1]);
end;

function TPDFOutlineNode.GetNextSibling: TPDFOutlineNode;
begin
  Result := FNext;
end;

function TPDFOutlineNode.GetPrev: TPDFOutlineNode;
var
  I: Integer;
begin
  I := FOwner.FList.IndexOf(Self);
  if I <> 0 then Result := FOwner[i - 1] else Result := nil;
end;

function TPDFOutlineNode.GetPrevChild(
  Node: TPDFOutlineNode): TPDFOutlineNode;
var
  i: Integer;
begin
  i := FChild.IndexOf(Pointer(Node));
  if (i = -1) or (i = 0) then Result := nil else Result := TPDFOutlineNode(FChild[i - 1]);
end;

function TPDFOutlineNode.GetPrevSibling: TPDFOutlineNode;
begin
  Result := FPrev;
end;

procedure TPDFOutlineNode.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TPDFOutlineNode.Save;
var
  I: Integer;
begin
  FOwner.FOwner.StartObj(OutlineNodeID);
  if FCharset = ANSI_charset then
    FOwner.FOwner.SaveToStream('/Title (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, OutlineNodeID, Title)) + ')')
  else
    FOwner.FOwner.SaveToStream('/Title <' + EnCodeHexString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, OutlineNodeID, UnicodeChar(FTitle, FCharset)) + '>');
  if FOwner.FOwner.Version = v14 then
  begin
    if Color <> 0 then
      FOwner.FOwner.SaveToStream('/C [' + FormatFloat(GetRValue(Color) / 255) + ' ' +
        FormatFloat(GetGValue(Color) / 255) + ' ' + FormatFloat(GetBValue(Color) / 255) + ' ]');
    I := 0;
    if fsbold in Style then I := I or 2;
    if fsItalic in Style then I := I or 1;
    if I <> 0 then
      FOwner.FOwner.SaveToStream('/F ' + IntToStr(I));
  end;
  if FChild.Count <> 0 then
  begin
    if FExpanded then
      FOwner.FOwner.SaveToStream('/Count ' + IntToStr(FChild.Count))
    else FOwner.FOwner.SaveToStream('/Count -' + IntToStr(FChild.Count));
    FOwner.FOwner.SaveToStream('/First ' + IntToStr(GetFirstChild.OutlineNodeID) + ' 0 R');
    FOwner.FOwner.SaveToStream('/Last ' + IntToStr(GetLastChild.OutlineNodeID) + ' 0 R');
  end;
  if FParent = nil then FOwner.FOwner.SaveToStream('/Parent ' + IntToStr(FOwner.OutlinesID) + ' 0 R')
  else FOwner.FOwner.SaveToStream('/Parent ' + IntToStr(FParent.OutlineNodeID) + ' 0 R');
  if FNext <> nil then
    FOwner.FOwner.SaveToStream('/Next ' + IntToStr(FNext.OutlineNodeID) + ' 0 R');
  if FPrev <> nil then
    FOwner.FOwner.SaveToStream('/Prev ' + IntToStr(FPrev.OutlineNodeID) + ' 0 R');
  if FAction <> nil then
    FOwner.FOwner.SaveToStream('/A ' + IntToStr(FAction.ActionID) + ' 0 R');
  FOwner.FOwner.CloseHObj;
  FOwner.FOwner.CloseObj;
end;

procedure TPDFOutlineNode.SetExpanded(const Value: Boolean);
begin
  FExpanded := Value;
end;

procedure TPDFOutlineNode.SetCharset(const Value: TFontCharset);
begin
  FCharset := Value;
end;

procedure TPDFOutlineNode.SetAction(const Value: TPDFAction);
begin
  if Value <> nil then
  begin
    FOwner.FOwner.AppendAction(Value);
    FAction := Value;
  end;
end;

{ TPDFDocInfo }

procedure TPDFDocInfo.SetAuthor(const Value: string);
begin
  FAuthor := Value;
end;

procedure TPDFDocInfo.SetCharset(const Value: TFontCharset);
begin
  FCharset := Value;
end;

procedure TPDFDocInfo.SetCreationDate(const Value: TDateTime);
begin
  FCreationDate := Value;
end;

procedure TPDFDocInfo.SetCreator(const Value: string);
begin
  FCreator := Value;
end;

procedure TPDFDocInfo.SetKeywords(const Value: string);
begin
  FKeywords := Value;
end;

procedure TPDFDocInfo.SetSubject(const Value: string);
begin
  FSubject := Value;
end;

procedure TPDFDocInfo.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

type
  TSmallPointArray = array[0..MaxInt div SizeOf(TSmallPoint) - 1] of TSmallPoint;
  PSmallPointArray = ^TSmallPointArray;
  TPointArray = array[0..MaxInt div SizeOf(TPoint) - 1] of TPoint;
  PPointArray = ^TPointArray;

{ TEMWParser }


constructor TEMWParser.Create(APage: TPDFPage);
begin
  FPage := APage;
  BM := TBitmap.Create;
  GObjs := TList.Create;
  MS := TMemoryStream.Create;
  BGMode := True;
  PolyFIllMode := True;
  VertMode := vjUp;
  HorMode := hjLeft;
  UpdatePos := True;
  Clipping := False;
  FInPath := False;
  CCW := True;
  com := 72000 div BM.Canvas.Font.PixelsPerInch;
  Cal := FPage.FRes / BM.Canvas.Font.PixelsPerInch;
  DDC := True;
  CWPS.cx := 0;
  CWPS.cy := 0;
end;


destructor TEMWParser.Destroy;
var
  I: Integer;
begin
  for i := 0 to GObjs.Count - 1 do
  begin
    DeleteObject(PHTItem(GObjs[i])^.Handle);
    Dispose(GObjs[i]);
  end;
  GObjs.Clear;
  MS.Free;
  GObjs.Free;
  BM.Free;
  inherited;
end;

procedure TEMWParser.DoAbortPath;
begin
  FPage.NewPath;
  InPath := False;
end;

procedure TEMWParser.DoAngleArc;
var
  Data: PEMRAngleArc;
begin
  Data := CV;
  FPage.MoveTo(GX(CurVal.x), GY(CurVal.y));
  FPage.LineTo(GX(Data^.ptlCenter.x + cos(Data^.eStartAngle * Pi / 180) * Data^.nRadius), GY(Data^.ptlCenter.y -
    sin(Data^.eStartAngle * Pi / 180) * Data^.nRadius));
  if Abs(Data^.eSweepAngle) >= 360 then
    FPage.Ellipse(GX(data^.ptlCenter.x - Integer(Data^.nRadius)), GY(data^.ptlCenter.y - Integer(Data^.nRadius)),
      GX(data^.ptlCenter.x + Integer(Data^.nRadius)), GY(data^.ptlCenter.y + Integer(Data^.nRadius))) else
    FPage.Arc(GX(data^.ptlCenter.x - Integer(Data^.nRadius)), GY(data^.ptlCenter.y - Integer(Data^.nRadius)),
      GX(data^.ptlCenter.x + Integer(Data^.nRadius)), GY(data^.ptlCenter.y + Integer(Data^.nRadius)),
      data^.eStartAngle, data^.eStartAngle + data^.eSweepAngle);
  CurVal := Point(Round(Data^.ptlCenter.x + cos((Data^.eStartAngle + Data^.eSweepAngle) * Pi / 180) * Data^.nRadius),
    Round(Data^.ptlCenter.y - sin((Data^.eStartAngle + Data^.eSweepAngle) * Pi / 180) * Data^.nRadius));
  if not InPath then PStroke;
end;

procedure TEMWParser.DoArc;
var
  Data: PEMRArc;
begin
  Data := CV;
  if CCW then FPage.Arc(GX(Data^.rclBox.Left), GY(Data^.rclBox.Top), GX(Data^.rclBox.Right), GY(Data^.rclBox.Bottom),
      GX(Data^.ptlStart.x), GY(Data^.ptlStart.y), GX(Data^.ptlEnd.x), GY(Data^.ptlEnd.y))
  else
    FPage.Arc(GX(Data^.rclBox.Left), GY(Data^.rclBox.Top), GX(Data^.rclBox.Right), GY(Data^.rclBox.Bottom),
      GX(Data^.ptlEnd.x), GY(Data^.ptlEnd.y), GX(Data^.ptlStart.x), GY(Data^.ptlStart.y));
  if not InPath then PStroke;
end;

procedure TEMWParser.DoArcTo;
var
  Data: PEMRArc;
  CenterX, CenterY: Extended;
  RadiusX, RadiusY: Extended;
  StartAngle, EndAngle: Extended;
begin
  Data := CV;
  FPage.MoveTo(GX(CurVal.x), GY(CurVal.y));
  if not CCW then
  begin
    swp(Data^.ptlStart.x, Data^.ptlEnd.x);
    swp(Data^.ptlStart.y, Data^.ptlEnd.y);
  end;
  CenterX := (Data^.rclBox.Left + Data^.rclBox.Right) / 2;
  CenterY := (Data^.rclBox.Top + Data^.rclBox.Bottom) / 2;
  RadiusX := (abs(Data^.rclBox.Left - Data^.rclBox.Right) - 1) / 2;
  RadiusY := (abs(Data^.rclBox.Top - Data^.rclBox.Bottom) - 1) / 2;
  if RadiusX < 0 then RadiusX := 0;
  if RadiusY < 0 then RadiusY := 0;
  StartAngle := ArcTan2(-(Data^.ptlStart.y - CenterY) * RadiusX,
    (Data^.ptlStart.x - CenterX) * RadiusY);
  EndAngle := ArcTan2(-(Data^.ptlEnd.y - CenterY) * RadiusX,
    (Data^.ptlEnd.x - CenterX) * RadiusY);
  FPage.LineTo(GX(CenterX + RadiusX * cos(StartAngle)), GY(CenterY - RadiusY * sin(StartAngle)));
  FPage.Arc(GX(Data^.rclBox.Left), GY(Data^.rclBox.Top), GX(Data^.rclBox.Right), GY(Data^.rclBox.Bottom),
    GX(Data^.ptlStart.x), GY(Data^.ptlStart.y), GX(Data^.ptlEnd.x), GY(Data^.ptlEnd.y));
  CurVal := Point(round(CenterX + RadiusX * cos(EndAngle)), Round(CenterY - RadiusY * sin(StartAngle)));
  if not InPath then PStroke;
end;

procedure TEMWParser.DoBeginPath;
begin
  InPath := True;
  FPage.NewPath;
  FPage.MoveTo(GX(CurVal.x), GY(CurVal.y));
end;

procedure TEMWParser.DoBitBlt;
var
  Data: PEMRBitBlt;
  it: Boolean;
begin
  Data := CV;
  if InText then
  begin
    InText := False;
    it := True;
  end else it := False;
  FPage.Rectangle(gX(data^.xDest), gY(Data^.yDest), gX(Data^.xDest + Data^.cxDest), gY(Data^.yDest + Data^.cyDest));
  FPage.Fill;
  if it then InText := True;
end;

procedure TEMWParser.DoChord;
var
  Data: PEMRChord;
  DP: TDoublePoint;
begin
  Data := CV;
  if CCW then DP := FPage.Arc(GX(Data^.rclBox.Left), GY(Data^.rclBox.Top), GX(Data^.rclBox.Right), GY(Data^.rclBox.Bottom),
      GX(Data^.ptlStart.x), GY(Data^.ptlStart.y), GX(Data^.ptlEnd.x), GY(Data^.ptlEnd.y))
  else
    DP := FPage.Arc(GX(Data^.rclBox.Left), GY(Data^.rclBox.Top), GX(Data^.rclBox.Right), GY(Data^.rclBox.Bottom),
      GX(Data^.ptlEnd.x), GY(Data^.ptlEnd.y), GX(Data^.ptlStart.x), GY(Data^.ptlStart.y));
  FPage.LineTo(GX(DP.x), GY(DP.y));
  if not InPath then PFillAndStroke;
end;

procedure TEMWParser.DoCloseFigure;
begin
  FPage.ClosePath;
end;

procedure TEMWParser.DoCreateBrushInDirect;
var
  P: PHTItem;
  H: HBrush;
  Data: PEMRCreateBrushIndirect;
begin
  Data := CV;
  H := CreateBrushIndirect(Data^.lb);
  New(p);
  GObjs.Add(P);
  P^.Handle := H;
  P^.TP := gtiBrush;
  P^.Index := Data^.ihBrush;
end;

procedure TEMWParser.DoCreateFontInDirectW;
var
  P: PHTItem;
  H: HFont;
  Data: PEMRExtCreateFontIndirect;
  A: TLogFontW;
  F: TLogFont;
  At: array[0..31] of Char;
begin
  Data := CV;
  Move(data^.elfw.elfLogFont, A, SizeOf(A));
  Move(a, F, SizeOf(F));
  WideCharToMultiByte(CP_ACP, 0, A.lfFaceName, 32, At, 32, nil, nil);
  Move(AT, F.lfFaceName, 32);
  H := CreateFontIndirect(F);
  New(p);
  GObjs.Add(P);
  P^.Handle := H;
  P^.TP := gtiFont;
  P^.Index := Data^.ihFont;
end;

procedure TEMWParser.DoCreatePen;
var
  P: PHTItem;
  H: HPEN;
  Data: PEMRCreatePen;
begin
  Data := CV;
  H := CreatePen(Data^.lopn.lopnStyle, Data^.lopn.lopnWidth.x, Data^.lopn.lopnColor);
  New(p);
  GObjs.Add(P);
  P^.Handle := H;
  P^.TP := gtiPen;
  P^.Index := Data^.ihPen;
end;

procedure TEMWParser.DoDeleteObject;
var
  Data: PEMRDeleteObject;
  I: Integer;
begin
  Data := CV;
  for I := 0 to GObjs.Count - 1 do
    if PhtItem(GObjs[I])^.Index = Data^.ihObject then
    begin
      DeleteObject(PHTItem(GObjs[i])^.Handle);
      Dispose(GObjs[I]);
      GObjs.Delete(I);
      Break;
    end;
end;

procedure TEMWParser.DoEllipse;
var
  Data: PEMREllipse;
begin
  Data := CV;
  FPage.Ellipse(GX(data^.rclBox.Left), GY(Data^.rclBox.Top), GX(Data^.rclBox.Right), GY(Data^.rclBox.Bottom));
  if not InPath then PFillAndStroke;
end;

procedure TEMWParser.DoEndPath;
begin
  InPath := False;
end;

procedure TEMWParser.DoExcludeClipRect;
begin
  if Clipping then
  begin
    Clipping := False;
    FPage.GStateRestore;
  end;
end;

procedure TEMWParser.DoExtCreatePen;
var
  Data: PEMRExtCreatePen;
  P: PHTItem;
  H: HPEN;
begin
  Data := CV;
  H := CreatePen(Data^.elp.elpPenStyle, Data^.elp.elpWidth, Data^.elp.elpColor);
  New(p);
  GObjs.Add(P);
  P^.Handle := H;
  P^.TP := gtiPen;
  P^.Index := Data^.ihPen;
end;

procedure TEMWParser.DoExtTextOutA;
var
  Data: PEMRExtTextOut;
  S: string;
  o: Pointer;
  RSZ: Extended;
  NRZ: Extended;
  PIN: PINT;
  i: Integer;
  X, Y: Extended;
  RU: Boolean;
begin
  RU := False;
  Data := CV;
  if Data^.emrtext.nChars = 0 then Exit;
  if not InPath then
  begin
    if (Data^.emrtext.fOptions and ETO_CLIPPED <> 0) or (Data^.emrtext.fOptions and ETO_OPAQUE <> 0) then
    begin
      RU := True;
      FPage.EndText;
      if (Data^.emrtext.fOptions and ETO_Clipped <> 0) then
      begin
        FPage.GStateSave;
        FPage.NewPath;
        FPage.Rectangle(GX(Data^.emrtext.rcl.Left), GY(Data^.emrtext.rcl.Top), GX(Data^.emrtext.rcl.Right), GY(Data^.emrtext.rcl.Bottom));
        FPage.Clip;
        FPage.NewPath;
      end;
      if (Data^.emrtext.fOptions and ETO_OPAQUE <> 0) then
      begin
        SetBGColor;
        FPage.NewPath;
        FPage.Rectangle(GX(Data^.emrtext.rcl.Left), GY(Data^.emrtext.rcl.Top), GX(Data^.emrtext.rcl.Right), GY(Data^.emrtext.rcl.Bottom));
        FPage.Fill;
      end;
      FPage.BeginText;
    end;
    SetFontColor;
  end;
  SetLength(S, Data^.emrtext.nChars);
  o := IP(CV, Data^.emrtext.offString);
  Move(o^, S[1], Data^.emrtext.nChars);
  PIN := IP(CV, Data^.emrtext.offDx);
  RSZ := 0;
  for i := 1 to Data^.emrtext.nChars do
  begin
    RSZ := RSZ + pin^;
    Inc(PIN);
  end;
  RSZ := XScale * Cal * RSZ - 1;
  NRZ := GetTextWidth(S);
  FPage.SetCharacterSpacing((RSZ - NRZ) / Data^.emrtext.nChars);
  case VertMode of
    vjCenter: Y := GY(Data^.rclBounds.Top + (Data^.rclBounds.Bottom - Data^.rclBounds.Top - BM.Canvas.TextHeight(S)) / 2);
    vjDown: Y := GY(Data^.rclBounds.Bottom - BM.Canvas.TextHeight(S));
  else
    if not RU then Y := GY(Data^.emrtext.ptlReference.Y) else Y := GY(Data^.rclBounds.Top);
  end;
  case HorMode of
    hjRight: x := GX(Data^.rclBounds.Right - RSZ);
    hjCenter: x := GX(Data^.rclBounds.Left + (Data^.rclBounds.Right - Data^.rclBounds.Left - RSZ) / 2);
  else
    if not RU then X := GX(Data^.emrtext.ptlReference.X) else X := GX(Data^.rclBounds.Left);
  end;
  FPage.TextOut(X, Y, CFont.lfEscapement / 10, s);
  if not InPath then
  begin
    if (Data^.emrtext.fOptions and ETO_Clipped <> 0) then
    begin
      FPage.EndText;
      FPage.GStateRestore;
      FPage.BeginText;
    end;
  end;
end;

procedure TEMWParser.DoExtTextOutW;
var
  Data: PEMRExtTextOut;
  S: string;
  o: Pointer;
  CodePage: Integer;
  I: Integer;
  sd: PByteArray;
  RSZ: Extended;
  NRZ: Extended;
  PIN: PINT;
  RS: Integer;
  X, Y: Extended;
  RU: Boolean;
begin
  RU := False;
  Data := CV;
  if Data^.emrtext.nChars = 0 then Exit;
  if not InPath then
  begin
    if (Data^.emrtext.fOptions and ETO_CLIPPED <> 0) or (Data^.emrtext.fOptions and ETO_OPAQUE <> 0) then
    begin
      RU := True;
      FPage.EndText;
      if (Data^.emrtext.fOptions and ETO_Clipped <> 0) then
      begin
        FPage.GStateSave;
        FPage.NewPath;
        FPage.Rectangle(GX(Data^.emrtext.rcl.Left), GY(Data^.emrtext.rcl.Top),
          GX(Data^.emrtext.rcl.Right), GY(Data^.emrtext.rcl.Bottom));
        FPage.Clip;
        FPage.NewPath;
      end;
      if (Data^.emrtext.fOptions and ETO_OPAQUE <> 0) then
      begin
        SetBGColor;
        FPage.NewPath;
        FPage.Rectangle(GX(Data^.emrtext.rcl.Left), GY(Data^.emrtext.rcl.Top),
          GX(Data^.emrtext.rcl.Right), GY(Data^.emrtext.rcl.Bottom));
        FPage.Fill;
      end;
      FPage.BeginText;
    end;
    SetFontColor;
  end;
  case CFont.lfCharSet of
    EASTEUROPE_CHARSET: CodePage := 1250;
    RUSSIAN_CHARSET: CodePage := 1251;
    GREEK_CHARSET: CodePage := 1253;
    TURKISH_CHARSET: CodePage := 1254;
    BALTIC_CHARSET: CodePage := 1257;
    SHIFTJIS_CHARSET: CodePage := 932;
    129: CodePage := 949;
    CHINESEBIG5_CHARSET: CodePage := 950;
    GB2312_CHARSET: CodePage := 936;
    Symbol_charset: CodePage := -1;
  else
    CodePage := CP_ACP;
  end;
  if CodePage <> -1 then
  begin
    o := IP(CV, Data^.emrtext.offString);
    S := '';
    rs := WideCharToMultiByte(CodePage, 0, o, Data^.emrtext.nChars, nil, 0, nil, nil);
    if rs <> 0 then
    begin
      SetLength(S, RS);
      WideCharToMultiByte(CodePage, 0, o, Data^.emrtext.nChars, @s[1], RS, nil, nil)
    end;
  end
  else
  begin
    SetLength(S, Data^.emrtext.nChars);
    SD := IP(CV, Data^.emrtext.offString);
    for i := 1 to Data^.emrtext.nChars do s[i] := chr(sd[((i - 1) shl 1)]);
  end;
  if not FPage.FOwner.FFonts[FPage.FCurrentFontIndex].IsCJK then
  begin
    PIN := IP(CV, Data^.emrtext.offDx);
    RSZ := 0;
    for i := 1 to Data^.emrtext.nChars do
    begin
      RSZ := RSZ + pin^;
      Inc(PIN);
    end;
    RSZ := XScale * Cal * RSZ - 1;
    NRZ := GetTextWidth(S);
    FPage.SetCharacterSpacing((RSZ - NRZ) / Data^.emrtext.nChars);
    case VertMode of
      vjCenter: Y := GY(Data^.rclBounds.Top + (Data^.rclBounds.Bottom - Data^.rclBounds.Top - BM.Canvas.TextHeight(S)) / 2);
      vjDown: Y := GY(Data^.rclBounds.Bottom - BM.Canvas.TextHeight(S));
    else
      if not RU then Y := GY(Data^.emrtext.ptlReference.Y) else Y := GY(Data^.rclBounds.Top);
    end;
    case HorMode of
      hjRight: x := GX(Data^.rclBounds.Right - RSZ);
      hjCenter: x := GX(Data^.rclBounds.Left + (Data^.rclBounds.Right - Data^.rclBounds.Left - RSZ) / 2);
    else
      if not RU then X := GX(Data^.emrtext.ptlReference.X) else X := GX(Data^.rclBounds.Left);
    end;
  end else
  begin
    FPage.SetCharacterSpacing(-0.6);
    Y := GY(Data^.emrtext.ptlReference.y);
    x := GX(Data^.emrtext.ptlReference.x);
  end;
  FPage.TextOut(X, Y, CFont.lfEscapement / 10, s);
  if not InPath then
  begin
    if (Data^.emrtext.fOptions and ETO_Clipped <> 0) then
    begin
      FPage.EndText;
      FPage.GStateRestore;
      FPage.BeginText;
    end;
  end;
end;

procedure TEMWParser.DoFillPath;
begin
  InPath := False;
  if not IsNullBrush then FPage.Fill;
  FPage.NewPath;
end;

procedure TEMWParser.DoInterSectClipRect;
var
  Data: PEMRIntersectClipRect;
begin
  Data := CV;
  if Clipping then FPage.GStateRestore;
  FPage.GStateSave;
  Clipping := True;
  FPage.NewPath;
  FPage.Rectangle(GX(Data^.rclClip.Left), GY(Data^.rclClip.Top), GX(Data^.rclClip.Right), GY(Data^.rclClip.Bottom));
  isCR := True;
  ClipRect := Rect(Data^.rclClip.Left, Data^.rclClip.Top, Data^.rclClip.Right, Data^.rclClip.Bottom);
  FPage.Clip;
  FPage.NewPath;
end;

procedure TEMWParser.DoLineTo;
var
  Data: PEMRLineTo;
begin
  Data := CV;
  if not InPath then FPage.MoveTo(GX(CurVal.x), GY(CurVal.y));
  FPage.LineTo(GX(Data^.ptl.x), GY(Data^.ptl.y));
  CurVal := Data^.ptl;
  if not InPath then PStroke;
end;

procedure TEMWParser.DoMoveToEx;
var
  PMove: PEMRLineTo;
begin
  PMove := CV;
  CurVal.x := pmove^.ptl.x;
  CurVal.y := pmove^.ptl.y;
  if InPath then
  begin
    if InText then InText := False;
    FPage.MoveTo(GX(CurVal.x), GY(CurVal.y));
  end;
end;

procedure TEMWParser.DoPie;
var
  Data: PEMRPie;
begin
  Data := CV;
  FPage.Pie(GX(Data^.rclBox.Left), gY(Data^.rclBox.Top), GX(Data^.rclBox.Right), GY(Data^.rclBox.Bottom),
    GX(Data^.ptlStart.x), GY(Data^.ptlStart.y), GX(Data^.ptlEnd.x), GY(Data^.ptlEnd.y));
  if not InPath then PFillAndStroke;
end;

procedure TEMWParser.DoPolyBezier;
var
  i: Integer;
  PL: PEMRPolyline;
begin
  with FPage do
  begin
    PL := CV;
    if PL^.cptl >= 4 then
    begin
      MoveTo(GX(PL^.aptl[0].x), GY(PL^.aptl[0].y));
      for i := 1 to (PL^.cptl - 1) div 3 do
        Curveto(GX(PL^.aptl[1 + (i - 1) * 3].x), GY(PL^.aptl[1 + (i - 1) * 3].y),
          GX(PL^.aptl[1 + (i - 1) * 3 + 1].x), GY(PL^.aptl[1 + (i - 1) * 3 + 1].y),
          GX(PL^.aptl[1 + (i - 1) * 3 + 2].x), GY(PL^.aptl[1 + (i - 1) * 3 + 2].y));
      if not InPath then PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyBezier16;
var
  i: Integer;
  PL16: PEMRPolyline16;
begin
  with FPage do
  begin
    PL16 := CV;
    if PL16^.cpts >= 4 then
    begin
      MoveTo(GX(PL16^.apts[0].x), GY(PL16^.apts[0].y));
      for i := 1 to (PL16^.cpts - 1) div 3 do
        Curveto(GX(PL16^.apts[1 + (i - 1) * 3].x), GY(PL16^.apts[1 + (i - 1) * 3].y),
          GX(PL16^.apts[1 + (i - 1) * 3 + 1].x), GY(PL16^.apts[1 + (i - 1) * 3 + 1].y),
          GX(PL16^.apts[1 + (i - 1) * 3 + 2].x), GY(PL16^.apts[1 + (i - 1) * 3 + 2].y));
      if not InPath then PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyBezierTo;
var
  i: Integer;
  PL: PEMRPolyline;
begin
  with FPage do
  begin
    PL := CV;
    if PL^.cptl >= 3 then
    begin
      MoveTo(GX(CurVal.x), GY(CurVal.y));
      for i := 1 to (PL^.cptl) div 3 do
      begin
        Curveto(GX(PL^.aptl[(i - 1) * 3].x), GY(PL^.aptl[(i - 1) * 3].y),
          GX(PL^.aptl[(i - 1) * 3 + 1].x), GY(PL^.aptl[(i - 1) * 3 + 1].y),
          GX(PL^.aptl[(i - 1) * 3 + 2].x), GY(PL^.aptl[(i - 1) * 3 + 2].y));
        CurVal := Point(PL^.aptl[(i - 1) * 3 + 2].x, PL^.aptl[(i - 1) * 3 + 2].y);
      end;
      if not InPath then PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyBezierTo16;
var
  i: Integer;
  PL16: PEMRPolyline16;
begin
  with FPage do
  begin
    PL16 := CV;
    if PL16^.cpts >= 4 then
    begin
      MoveTo(GX(CurVal.x), GY(CurVal.y));
      for i := 1 to PL16^.cpts div 3 do
      begin
        Curveto(GX(PL16^.apts[(i - 1) * 3].x), GY(PL16^.apts[(i - 1) * 3].y),
          GX(PL16^.apts[(i - 1) * 3 + 1].x), GY(PL16^.apts[(i - 1) * 3 + 1].y),
          GX(PL16^.apts[(i - 1) * 3 + 2].x), GY(PL16^.apts[(i - 1) * 3 + 2].y));
        CurVal := Point(PL16^.apts[1 + (i - 1) * 3 + 2].x, PL16^.apts[1 + (i - 1) * 3 + 2].y);
      end;
      if not InPath then PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyDraw;
var
  I: Integer;
  K: Cardinal;
  Types: PByteArray;
  Data: PEMRPolyDraw;
  TV: TPoint;
begin
  with FPage do
  begin
    Data := CV;
    if not InPath then NewPath;
    MoveTo(GX(CurVal.x), GY(CurVal.y));
    TV := CurVal;
    K := SizeOf(TEMRPolyDraw) - 1 + SizeOf(TPoint) * (Data^.cptl - 1);
    Types := IP(CV, K);
    K := 0;
    I := 0;
    while K < Data^.cptl do
    begin
      if Types[I] = PT_MOVETO then
      begin
        TV.x := Data^.aPTL[K].x;
        TV.y := Data^.aPTL[K].y;
        MoveTo(GX(TV.x), GY(TV.y));
        Inc(K);
        CurVal := TV;
      end else
        if (Types[I] and PT_LINETO) <> 0 then
        begin
          LineTo(GX(Data^.aPTL[K].x), GY(Data^.aPTL[K].y));
          Inc(K);
          CurVal := Point(Data^.aPTL[K].x, Data^.aPTL[K].y);
          if (Types[I] and PT_ClOSEFIGURE) <> 0 then
          begin
            LineTo(GX(TV.x), GY(TV.y));
            CurVal := TV;
          end;
        end else
          if (Types[I] and PT_BEZIERTO) <> 0 then
          begin
            Curveto(GX(Data^.aPTL[K].x), GY(Data^.aPTL[K].y),
              GX(Data^.aPTL[K + 1].x), GY(Data^.aPTL[K + 1].y),
              GX(Data^.aPTL[K + 2].x), GY(Data^.aPTL[K + 2].y));
            CurVal := Point(Data^.aPTL[K + 2].x, Data^.aPTL[K + 2].y);
            Inc(K, 3);
            if (Types[I] and PT_ClOSEFIGURE) <> 0 then
            begin
              LineTo(GX(TV.x), GY(TV.y));
              CurVal := TV;
            end;
          end
    end;
    if not InPath then PStroke;
  end;
end;

procedure TEMWParser.DoPolyDraw16;
var
  I: Integer;
  K: Cardinal;
  Types: PByteArray;
  Data: PEMRPolyDraw16;
  TV: TPoint;
begin
  with FPage do
  begin
    Data := CV;
    if not InPath then NewPath;
    MoveTo(GX(CurVal.x), GY(CurVal.y));
    TV := CurVal;
    K := SizeOf(TEMRPolyDraw16) - 1 + SizeOf(TSmallPoint) * (Data^.cpts - 1);
    Types := IP(CV, K);
    K := 0;
    I := 0;
    while K < Data^.cpts do
    begin
      if Types[I] = PT_MOVETO then
      begin
        TV.x := Data^.aPTs[K].x;
        TV.y := Data^.aPTs[K].y;
        MoveTo(GX(TV.x), GY(TV.y));
        Inc(K);
        CurVal := TV;
      end else
        if (Types[I] and PT_LINETO) <> 0 then
        begin
          LineTo(GX(Data^.aPTs[K].x), GY(Data^.aPTs[K].y));
          Inc(K);
          CurVal := Point(Data^.aPTS[K].x, Data^.aPTs[K].y);
          if (Types[I] and PT_ClOSEFIGURE) <> 0 then
          begin
            LineTo(GX(TV.x), GY(TV.y));
            CurVal := TV;
          end;
        end else
          if (Types[I] and PT_BEZIERTO) <> 0 then
          begin
            Curveto(GX(Data^.aPTs[K].x), GY(Data^.aPTs[K].y),
              GX(Data^.aPTs[K + 1].x), GY(Data^.aPTs[K + 1].y),
              GX(Data^.aPTs[K + 2].x), GY(Data^.aPTs[K + 2].y));
            CurVal := Point(Data^.aPTs[K + 2].x, Data^.aPTs[K + 2].y);
            Inc(K, 3);
            if (Types[I] and PT_ClOSEFIGURE) <> 0 then
            begin
              LineTo(GX(TV.x), GY(TV.y));
              CurVal := TV;
            end;
          end
    end;
    if not InPath then PStroke;
  end;
end;

procedure TEMWParser.DoPolygon;
var
  i: Integer;
  PL: PEMRPolyline;
begin
  with FPage do
  begin
    PL := CV;
    if PL^.cptl > 0 then
    begin
      NewPath;
      MoveTo(GX(pl^.aptl[0].x), GY(PL^.aptl[0].y));
      for I := 1 to pl^.cptl - 1 do LineTo(GX(pl^.aptl[i].x), GY(pl^.aptl[i].y));
      if not InPath then
      begin
        ClosePath;
        PFillAndStroke;
      end;
    end;
  end;
end;

procedure TEMWParser.DoPolygon16;
var
  i: Integer;
  PL16: PEMRPolyline16;
begin
  with FPage do
  begin
    PL16 := CV;
    if PL16^.cpts > 0 then
    begin
      NewPath;
      MoveTo(GX(pl16^.apts[0].x), GY(PL16^.apts[0].y));
      for I := 1 to pl16^.cpts - 1 do LineTo(GX(pl16^.apts[i].x), GY(pl16^.apts[i].y));
      if not InPath then
      begin
        ClosePath;
        PFillAndStroke;
      end;
    end;
  end;
end;

procedure TEMWParser.DoPolyLine;
var
  i: Integer;
  PL: PEMRPolyline;
begin
  with FPage do
  begin
    PL := CV;
    if PL^.cptl > 0 then
    begin
      NewPath;
      MoveTo(GX(pl^.aptl[0].x), GY(PL^.aptl[0].y));
      for I := 1 to pl^.cptl - 1 do LineTo(GX(pl^.aptl[i].x), GY(pl^.aptl[i].y));
      if not InPath then PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyLine16;
var
  i: Integer;
  PL16: PEMRPolyline16;
begin
  with FPage do
  begin
    PL16 := CV;
    if PL16^.cpts > 0 then
    begin
      NewPath;
      MoveTo(GX(pl16^.apts[0].x), GY(PL16^.apts[0].y));
      for I := 1 to pl16^.cpts - 1 do LineTo(GX(pl16^.apts[i].x), GY(pl16^.apts[i].y));
      if not InPath then PStroke;
    end;
  end;
end;

procedure TEMWParser.DoPolyLineTo;
var
  i: Integer;
  PL: PEMRPolyline;
begin
  with FPage do
  begin
    PL := CV;
    if PL^.cptl > 0 then
    begin
      NewPath;
      MoveTo(GX(CurVal.x), GY(CurVal.y));
      for I := 0 to pl^.cptl - 1 do LineTo(GX(pl^.aptl[i].x), GY(pl^.aptl[i].y));
      if not InPath then PStroke;
      CurVal := Point(pl^.aptl[pl^.cptl - 1].x, pl^.aptl[pl^.cptl - 1].y);
    end;
  end;
end;

procedure TEMWParser.DoPolyLineTo16;
var
  i: Integer;
  PL16: PEMRPolyline16;
begin
  with FPage do
  begin
    PL16 := CV;
    if PL16^.cpts > 0 then
    begin
      NewPath;
      MoveTo(GX(CurVal.x), GY(CurVal.y));
      for I := 0 to pl16^.cpts - 1 do LineTo(GX(pl16^.apts[i].x), GY(pl16^.apts[i].y));
      if not InPath then PStroke;
      CurVal := Point(pl16^.apts[pl16^.cpts - 1].x, pl16^.apts[pl16^.cpts - 1].y);
    end;
  end;
end;

procedure TEMWParser.DoPolyPolyGon;
var
  I, J, K, L: Integer;
  PPPAL: PPointArray;
  PPL: PEMRPolyPolyline;
begin
  with FPage do
  begin
    PPL := CV;
    NewPath;
    K := SizeOf(TEMRPolyPolyline) - SizeOf(TPoint) + SizeOf(dword) * (ppl^.nPolys - 1);
    PPPAL := IP(CV, K);
    K := 0;
    for j := 0 to ppl^.nPolys - 1 do
    begin
      MoveTo(GX(PPPAL[K].x), GY(PPPAL[K].y));
      L := K;
      Inc(K);
      for I := 1 to ppl^.aPolyCounts[J] - 1 do
      begin
        LineTo(GX(PPPAL[K].x), GY(PPPAL[K].y));
        Inc(K);
      end;
      LineTo(GX(PPPAL[L].x), GY(PPPAL[L].y));
    end;
    PFillAndStroke;
  end;
end;

procedure TEMWParser.DoPolyPolygon16;
var
  I, J, K, L: Integer;
  PPPA: PSmallPointArray;
  PPL16: PEMRPolyPolyline16;
begin
  with FPage do
  begin
    PPL16 := CV;
    NewPath;
    K := SizeOf(TEMRPolyPolyline16) - SizeOf(TSmallPoint) + SizeOf(dword) * (ppl16^.nPolys - 1);
    PPPA := IP(CV, K);
    K := 0;
    for j := 0 to ppl16^.nPolys - 1 do
    begin
      MoveTo(GX(PPPA[K].x), GY(PPPA[K].y));
      L := K;
      Inc(K);
      for I := 1 to ppl16^.aPolyCounts[J] - 1 do
      begin
        LineTo(GX(PPPA[K].x), GY(PPPA[K].y));
        Inc(K);
      end;
      LineTo(GX(PPPA[L].x), GY(PPPA[L].y));
    end;
    PFillAndStroke;
  end;
end;

procedure TEMWParser.DoPolyPolyLine;
var
  I, J, K: Integer;
  PPPAL: PPointArray;
  PPL: PEMRPolyPolyline;
begin
  with FPage do
  begin
    PPL := CV;
    NewPath;
    K := SizeOf(TEMRPolyPolyline) - SizeOf(TPoint) + SizeOf(dword) * (ppl^.nPolys - 1);
    PPPAL := IP(CV, K);
    K := 0;
    for j := 0 to ppl^.nPolys - 1 do
    begin
      MoveTo(GX(PPPAL[K].x), GY(PPPAL[K].y));
      Inc(K);
      for I := 1 to ppl^.aPolyCounts[J] - 1 do
      begin
        LineTo(GX(PPPAL[K].x), GY(PPPAL[K].y));
        Inc(K);
      end;
    end;
    if not InPath then PStroke;
  end;
end;

procedure TEMWParser.DoPolyPolyLine16;
var
  I, J, K: Integer;
  PPPA: PSmallPointArray;
  PPL16: PEMRPolyPolyline16;
begin
  with FPage do
  begin
    PPL16 := CV;
    NewPath;
    K := SizeOf(TEMRPolyPolyline16) - SizeOf(TSmallPoint) + SizeOf(dword) * (ppl16^.nPolys - 1);
    PPPA := IP(CV, K);
    K := 0;
    for j := 0 to ppl16^.nPolys - 1 do
    begin
      MoveTo(GX(PPPA[K].x), GY(PPPA[K].y));
      Inc(K);
      for I := 1 to ppl16^.aPolyCounts[J] - 1 do
      begin
        LineTo(GX(PPPA[K].x), GY(PPPA[K].y));
        Inc(K);
      end;
    end;
    if not InPath then PStroke;
  end;
end;

procedure TEMWParser.DoRectangle;
var
  Data: PEMREllipse;
begin
  Data := CV;
  FPage.Rectangle(GX(data^.rclBox.Left), GY(data^.rclBox.Top), GX(Data^.rclBox.Right - 1), GY(Data^.rclBox.Bottom - 1));
  if not InPath then
    if (CPen.lopnWidth <> 0) and (CPen.lopnStyle <> ps_null) then
      FPage.FillAndStroke else FPage.Fill;
end;


procedure TEMWParser.DoRestoreDC;
var
  Data: PEMRRestoreDC;
  H: HGDIOBJ;
  NPen: TLogPen;
  NBrush: TLogBrush;
  NFont: TLogFont;
  TR: TXForm;
begin
  Data := CV;
  RestoreDC(BM.Canvas.Handle, Data^.iRelative);
// CheckTransform
  GetWorldTransform(BM.Canvas.Handle, TR);
  XOff := TR.eDx * Cal;
  YOff := TR.eDy * Cal;
  XScale := TR.eM11;
  YScale := TR.eM22;
  if Clipping then
  begin
    Clipping := False;
    if InText then
    begin
      FPage.EndText;
      FPage.GStateRestore;
      FPage.BeginText;
    end else FPage.GStateRestore;
  end;
// Check Pen
  H := GetCurrentObject(BM.Canvas.Handle, OBJ_PEN);
  GetObject(H, SizeOf(NPen), @NPen);
  if NPen.lopnColor <> CPen.lopnColor then
  begin
    CPen.lopnColor := NPen.lopnColor;
    SetPenColor;
  end;
  if NPen.lopnStyle <> CPen.lopnStyle then
  begin
    CPen.lopnStyle := NPen.lopnStyle;
    case CPen.lopnStyle of
      ps_Solid, ps_InsideFrame: FPage.NoDash;
      ps_Dash: FPage.SetDash('[8 8] 0');
      ps_Dot: FPage.SetDash('[2 2] 0');
      ps_DashDot: FPage.SetDash('[8 2 2 2] 0');
      ps_DashDotDot: FPage.SetDash('[8 2 2 2 2 2] 0');
    end;
  end;
  if NPen.lopnWidth.x * XScale <> CPen.lopnWidth then
  begin
    CPen.lopnWidth := NPen.lopnWidth.x * xScale;
    FPage.SetLineWidth(Cal * CPen.lopnWidth);
  end;

//Chech Brush
  H := GetCurrentObject(BM.Canvas.Handle, OBJ_BRUSH);
  GetObject(H, SizeOf(NBrush), @NBrush);
  if NBrush.lbColor <> CBrush.lbColor then
  begin
    CBrush.lbColor := NBrush.lbColor;
    if not InText then SetBrushColor;
  end;

//Check Font
  H := GetCurrentObject(BM.Canvas.Handle, OBJ_FONT);
  GetObject(H, SizeOf(NFont), @NFont);
  if (CFont.lfFaceName <> NFont.lfFaceName) or (CFont.lfWeight <> NFont.lfWeight) or
    (CFont.lfItalic <> NFont.lfItalic) or (CFont.lfUnderline <> NFont.lfUnderline) or
    (CFont.lfStrikeOut <> NFont.lfStrikeOut) or (CFont.lfCharSet <> NFont.lfCharSet) or
    (CFont.lfHeight <> NFont.lfHeight) then
  begin
    Move(NFont, CFont, SizeOf(CFont));
    SetCurFont;
  end;
end;

procedure TEMWParser.DoRoundRect;
var
  Data: PEMRRoundRect;
begin
  Data := CV;
  FPage.RoundRect(Round(GX(Data^.rclBox.Left)), Round(GY(Data^.rclBox.Top)),
    Round(GX(Data^.rclBox.Right)), Round(GY(Data^.rclBox.Bottom)),
    Round(GX(Data^.szlCorner.cx)), Round(GY(Data^.szlCorner.cy)));
  if not InPath then PFillAndStroke;
end;

procedure TEMWParser.DoSaveDC;
begin
  SaveDC(BM.Canvas.Handle);
end;

procedure TEMWParser.DoSelectClipPath;
begin
  if Clipping then FPage.GStateRestore;
  FPage.GStateSave;
  Clipping := True;
  FPage.Clip;
  isCR := False;
  FPage.NewPath;
  InPath := False;
end;

procedure TEMWParser.DoSelectObject;
var
  Data: PEMRSelectObject;
  NPen: TLogPen;
  NBrush: TLogBrush;
  NFont: TLogFont;
  I: Integer;
begin
  Data := CV;
  if (Data^.ihObject and $80000000) = 0 then
  begin
    for I := 0 to GObjs.Count - 1 do
      if PHTItem(GObjs[I])^.Index = Data^.ihObject then
      begin
        SelectObject(BM.Canvas.Handle, PHTItem(GObjs[I])^.Handle);
        if PHTItem(GObjs[I])^.TP = gtiPen then
        begin
// Check Pen
          GetObject(PHTItem(GObjs[I])^.Handle, SizeOf(NPen), @NPen);
          if NPen.lopnColor <> CPen.lopnColor then
          begin
            CPen.lopnColor := NPen.lopnColor;
            SetPenColor;
          end;
          if NPen.lopnStyle <> CPen.lopnStyle then
          begin
            CPen.lopnStyle := NPen.lopnStyle;
            case CPen.lopnStyle of
              ps_Solid, ps_InsideFrame: FPage.NoDash;
              ps_Dash: FPage.SetDash('[8 8] 0');
              ps_Dot: FPage.SetDash('[2 2] 0');
              ps_DashDot: FPage.SetDash('[8 2 2 2] 0');
              ps_DashDotDot: FPage.SetDash('[8 2 2 2 2 2] 0');
            end;
          end;
          if NPen.lopnWidth.x * XScale <> CPen.lopnWidth then
          begin
            CPen.lopnWidth := NPen.lopnWidth.x * xscale;
            FPage.SetLineWidth(Cal * CPen.lopnWidth);
          end;
        end;
//Chech Brush
        if PHTItem(GObjs[I])^.TP = gtiBrush then
        begin
          IsNullBrush := False;
          GetObject(PHTItem(GObjs[I])^.Handle, SizeOf(NBrush), @NBrush);
          if NBrush.lbColor <> CBrush.lbColor then
          begin
            CBrush.lbColor := NBrush.lbColor;
            if not InText then SetBrushColor;
          end;
        end;
//Check Font
        if PHTItem(GObjs[I])^.TP = gtiFont then
        begin
          GetObject(PHTItem(GObjs[I])^.Handle, SizeOf(NFont), @NFont);
          if (CFont.lfFaceName <> NFont.lfFaceName) or (CFont.lfWeight <> NFont.lfWeight) or
            (CFont.lfItalic <> NFont.lfItalic) or (CFont.lfUnderline <> NFont.lfUnderline) or
            (CFont.lfStrikeOut <> NFont.lfStrikeOut) or (CFont.lfCharSet <> NFont.lfCharSet) or
            (CFont.lfHeight <> NFont.lfHeight) then
          begin
            Move(NFont, CFont, SizeOf(CFont));
            Fcha := True;
            if InText then SetCurFont;
          end;
        end;
        Break;
      end;
  end
  else
  begin
    I := Data^.ihObject and $7FFFFFFF;
    SelectObject(BM.Canvas.Handle, GetStockObject(I));
    case I of
      WHITE_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := clWhite;
          if not InText then SetBrushColor;
        end;
      LTGRAY_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := $AAAAAA;
          if not InText then SetBrushColor;
        end;
      GRAY_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := $808080;
          if not InText then SetBrushColor;
        end;
      DKGRAY_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := $666666;
          if not InText then SetBrushColor;
        end;
      BLACK_BRUSH:
        begin
          IsNullBrush := False;
          CBrush.lbColor := 0;
          if not InText then SetBrushColor;
        end;
      Null_BRUSH:
        begin
          CBrush.lbColor := clWhite;
          IsNullBrush := True;
          if not InText then SetBrushColor;
        end;
      WHITE_PEN:
        begin
          CPen.lopnColor := clWhite;
          FPage.SetRGBColorStroke(1, 1, 1);
        end;
      BLACK_PEN:
        begin
          CPen.lopnColor := clBlack;
          FPage.SetRGBColorStroke(0, 0, 0);
        end;
      Null_PEN:
        begin
          CPen.lopnStyle := PS_NULL;
        end;
      OEM_FIXED_FONT, ANSI_FIXED_FONT, ANSI_VAR_FONT, SYSTEM_FONT:
        begin
//          CFont.lfFaceName :=  'Arial';
          Fcha := True;
          if InText then SetCurFont;
        end;
    end;
  end;
end;


procedure TEMWParser.DoSetArcDirection;
var
  Data: PEMRSetArcDirection;
begin
  Data := CV;
  CCW := Data^.iArcDirection = AD_COUNTERCLOCKWISE;
end;

procedure TEMWParser.DoSetBKColor;
var
  PColor: PEMRSetTextColor;
begin
  PColor := CV;
  BGColor := PColor^.crColor;
end;

procedure TEMWParser.DoSetBKMode;
var
  PMode: PEMRSelectclippath;
begin
  PMode := CV;
  if PMode^.iMode = TRANSPARENT then BGMode := False;
end;

procedure TEMWParser.DoSetDibitsToDevice;
var
  Data: PEMRSetDIBitsToDevice;
  B: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
begin
  Data := CV;
  P := IP(CV, Data^.offBmiSrc);
  O := IP(CV, Data^.offBitsSrc);
  B := TBitmap.Create;
  try
    B.Width := Data^.cxSrc;
    B.Height := Data^.cySrc;
    SetDIBitsToDevice(B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
      Data^.iStartScan, Data^.cScans, O, p^, Data^.iUsageSrc);
    I := FPage.FOwner.AddImage(B, itcJpeg);
    FPage.ShowImage(I, GX(Data^.rclBounds.Left), GY(Data^.rclBounds.Top),
      GX(Data^.cxSrc), GY(Data^.cySrc), 0);
  finally
    B.Free;
  end;
end;

procedure TEMWParser.DoSetMiterLimit;
//var
//  Data: PEMRSetMiterLimit;
begin
//  Data := CV;
//  FPage.SetMiterLimit(Data^.eMiterLimit);
end;

procedure TEMWParser.DoSetPixelV;
var
  Data: PEMRSetPixelV;
begin
  Data := CV;
  FPage.NewPath;
  if Data^.crColor <> CPen.lopnColor then
    FPage.SetRGBColorStroke(GetRValue(Data^.crColor) / 255,
      GetGValue(Data^.crColor) / 255, GetBValue(Data^.crColor) / 255);
  if CPen.lopnWidth <> 1 then
    FPage.SetLineWidth(1);
  FPage.MoveTo(GX(Data^.ptlPixel.x), GY(Data^.ptlPixel.y));
  FPage.LineTo(GX(Data^.ptlPixel.x) + 0.01, GY(Data^.ptlPixel.y) + 0.01);
  PStroke;
  if CPen.lopnWidth <> 1 then
    FPage.SetLineWidth(Cal * CPen.lopnWidth);
  if Data^.crColor <> CPen.lopnColor then
    FPage.SetRGBColorStroke(GetRValue(CPen.lopnColor) / 255,
      GetGValue(CPen.lopnColor) / 255, GetBValue(CPen.lopnColor) / 255);
end;

procedure TEMWParser.DoSetPolyFillMode;
var
  PMode: PEMRSelectclippath;
begin
  PMode := CV;
  if PMode^.iMode = Alternate then PolyFIllMode := True;
end;

procedure TEMWParser.DoSetStretchBltMode;
var
  Data: PEMRSetStretchBltMode;
begin
  Data := CV;
  SBM := Data^.iMode;
end;

procedure TEMWParser.DoSetTextAlign;
var
  PMode: PEMRSelectclippath;
begin
  PMode := CV;
  HorMode := hjLeft;
  VertMode := vjUp;
  if PMode^.iMode and ta_BaseLine <> 0 then VertMode := vjCenter;
  if PMode^.iMode and ta_Bottom <> 0 then VertMode := vjDown;
  if PMode^.iMode and ta_Top <> 0 then VertMode := vjUp;
  if PMode^.iMode and ta_Center <> 0 then HorMode := hjCenter;
  if PMode^.iMode and ta_Left <> 0 then HorMode := hjLeft;
  if PMode^.iMode and ta_Right <> 0 then HorMode := hjRight;
  UpdatePos := (PMode^.iMode and ta_UpdateCP <> 0);
end;

procedure TEMWParser.DoSetTextColor;
var
  PColor: PEMRSetTextColor;
begin
  PColor := CV;
  TextColor := PColor^.crColor;
  if InText then SetFontColor;
end;

procedure TEMWParser.DoSetTextJustification;
//var
//  Data: PEMRLineTo;
begin
//  Data := CV;
//  if (Data^.ptl.x = 0) or (Data^.ptl.y = 0) then
//    FPage.SetWordSpacing(0) else FPage.SetWordSpacing(G(Data^.ptl.x / Data^.ptl.y));
end;

procedure TEMWParser.DoSetViewPortExtEx;
var
  Data: PEMRSetViewportExtEx;
begin
  Data := CV;
  if (CWPS.cx = 0) or (CWPS.cy = 0) then Exit;
  if (Data^.szlExtent.cx = 0) or (Data^.szlExtent.cy = 0) then Exit;
  XScale := Data^.szlExtent.cx / CWPS.cx;
  YScale := Data^.szlExtent.cy / CWPS.cy;
end;

procedure TEMWParser.DoSetViewPortOrgEx;
//var
//  Data: PEMRSetViewportOrgEx;
begin
//  Data := CV;
//  XOff := -Cal*data^.ptlOrigin.x*XScale;
//  YOff := -Cal*data^.ptlOrigin.y*YScale;
end;

procedure TEMWParser.DoSetWindowExtEx;
var
  Data: PEMRSetViewportExtEx;
begin
  Data := CV;
  CWPS := Data^.szlExtent;
end;

procedure TEMWParser.DoSetWindowOrgEx;
//var
//  Data: PEMRSetViewportOrgEx;
begin
//  Data := CV;
//  XOff := -Cal*data^.ptlOrigin.x;
//  YOff := -Cal*data^.ptlOrigin.y;
end;

procedure TEMWParser.DoSetWorldTransform;
var
  PWorldTransf: PEMRSetWorldTransform;
begin
  PWorldTransf := CV;
  XScale := PWorldTransf^.xform.eM11;
  YScale := PWorldTransf^.xform.eM22;
  XOff := PWorldTransf^.xform.eDx * Cal;
  YOff := PWorldTransf^.xform.eDy * Cal;
  SetWorldTransform(BM.Canvas.Handle, PWorldTransf^.xform);
end;

procedure TEMWParser.DoStretchBlt;
var
  Data: PEMRStretchBlt;
  B: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
begin
  Data := CV;
  P := IP(CV, Data^.offBmiSrc);
  O := IP(CV, Data^.offBitsSrc);
  if (Data^.cySrc <> 0) and (Data^.cxSrc <> 0) then
  begin
    B := TBitmap.Create;
    try
      B.Width := Data^.cxSrc;
      B.Height := Data^.cySrc;
      StretchDIBits(B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
        B.Width, B.Height, O, p^, Data^.iUsageSrc, Data^.dwRop);
      I := FPage.FOwner.AddImage(B, itcFlate);
      FPage.ShowImage(I, GX(Data^.rclBounds.Left), GY(Data^.rclBounds.Top),
        GX(Data^.rclBounds.Right - Data^.rclBounds.Left), GY(Data^.rclBounds.Bottom - Data^.rclBounds.Top), 0);
    finally
      B.Free;
    end;
  end;
end;

procedure TEMWParser.DoStretchDiBits;
var
  Data: PEMRStretchDiBits;
  B: TBitmap;
  O: Pointer;
  P: PBitmapInfo;
  I: Integer;
begin
  Data := CV;
  P := IP(CV, Data^.offBmiSrc);
  O := IP(CV, Data^.offBitsSrc);
  B := TBitmap.Create;
  try
    B.Width := Data^.cxSrc;
    B.Height := Data^.cySrc;
    StretchDIBits(B.Canvas.Handle, 0, 0, B.Width, B.Height, Data^.xSrc, Data^.ySrc,
      B.Width, B.Height, O, p^, Data^.iUsageSrc, Data^.dwRop);
    I := FPage.FOwner.AddImage(B, itcJpeg);
    if (Data^.rclBounds.Right - Data^.rclBounds.Left > 0) and
      (Data^.rclBounds.Bottom - Data^.rclBounds.Top > 0) then
      FPage.ShowImage(I, GX(Data^.rclBounds.Left), GY(Data^.rclBounds.Top),
        GX(Data^.rclBounds.Right - Data^.rclBounds.Left), GY(Data^.rclBounds.Bottom - Data^.rclBounds.Top), 0) else
      FPage.ShowImage(I, GX(Data^.xDest), GY(Data^.yDest), GX(data^.cxDest), GY(Data^.cyDest), 0);
  finally
    B.Free;
  end;
end;

procedure TEMWParser.DoStrokeAndFillPath;
begin
  InPath := False;
  PFillAndStroke;
  InPath := False;
  FPage.NewPath;
end;

procedure TEMWParser.DoStrokePath;
begin
  InPath := False;
  PStroke;
  FPage.NewPath;
end;

{$IFDEF CANVASDBG}
var
  iii: Integer = 0;
{$ENDIF}


procedure TEMWParser.Execute;
var
  i, off: Integer;
  Header: PEnhMetaHeader;
  FEX: Boolean;
  RH: PEMR;
{$IFDEF CANVASDBG}
  Debug: TStringList;
  S: string;
  SC: Integer;
  NDW: Integer;
  Pin: PINT;
{$ENDIF}
begin
  if MS.Size = 0 then
    raise TPDFException.Create(SMetafileNotLoaded);
  CurRec := 0;
  XScale := 1;
  YScale := 1;
  Fcha := True;
  FCCha := True;
  BCha := True;
  PCha := True;
  IsNullBrush := False;
  XOff := 0;
  YOff := 0;
{$IFDEF CANVASDBG}
  Debug := TStringList.Create;
{$ENDIF}
  FEX := False;
  for i := 0 to GObjs.Count - 1 do
  begin
    DeleteObject(PHTItem(GObjs[i])^.Handle);
    Dispose(GObjs[i]);
  end;
  GObjs.Clear;
{$IFDEF CANVASDBG}
  CreateDir('HDCDebug');
  MS.SaveToFile('HDCDebug\' + IntToStr(iii) + '.emf');
{$ENDIF}
  CV := MS.Memory;
  Header := CV;
  Off := Header^.nSize;
  RE := Header^.rclBounds;
  while not FEX do
  begin
    Inc(CurRec);
    CV := IP(CV, Off);
    RH := CV;
    Off := RH^.nSize;
{$IFDEF CANVASDBG}
    SC := FPage.FContent.Count;
{$ENDIF}
    if InText then
      if not (RH^.iType in
        [EMR_EXTTEXTOUTA, EMR_EXTTEXTOUTW, EMR_SELECTOBJECT, EMR_BITBLT,
        EMR_CREATEBRUSHINDIRECT, EMR_CREATEPEN, EMR_SAVEDC, EMR_RESTOREDC,
          EMR_SETTEXTALIGN, EMR_SETBKMODE, EMR_EXTCREATEFONTINDIRECTW,
          EMR_DELETEOBJECT, EMR_SETTEXTCOLOR, EMR_MOVETOEX, EMR_SETBKCOLOR]) then
        InText := False;
    if (RH^.iType in [EMR_EXTTEXTOUTA, EMR_EXTTEXTOUTW]) then
      if not InText then InText := True;
    case RH^.iType of
      EMR_SETWINDOWEXTEX: DoSetWindowExtEx;
      EMR_SETWINDOWORGEX: DoSetWindowOrgEx;
      EMR_SETVIEWPORTEXTEX: DoSetViewPortExtEx;
      EMR_SETVIEWPORTORGEX: DoSetViewPortOrgEx;
      EMR_POLYBEZIER: DoPolyBezier;
      EMR_POLYGON: DoPolygon;
      EMR_POLYLINE: DoPolyLine;
      EMR_POLYBEZIERTO: DoPolyBezierTo;
      EMR_POLYLINETO: DoPolyLineTo;
      EMR_POLYPOLYLINE: DoPolyPolyLine;
      EMR_POLYPOLYGON: DoPolyPolyGon;
      EMR_EOF: FEX := True;
      EMR_SETPIXELV: DoSetPixelV;
      EMR_SETBKMODE: DoSetBKMode;
      EMR_SETPOLYFILLMODE: DoSetPolyFillMode;
      EMR_SETTEXTALIGN: DoSetTextAlign;
      EMR_SETTEXTCOLOR: DoSetTextColor;
      EMR_SETBKCOLOR: DoSetBKColor;
      EMR_MOVETOEX: DoMoveToEx;
      EMR_INTERSECTCLIPRECT: DoInterSectClipRect;
      EMR_EXTSELECTCLIPRGN, EMR_EXCLUDECLIPRECT: DoExcludeClipRect;
      EMR_SAVEDC: DoSaveDC;
      EMR_RESTOREDC: DoRestoreDC;
      EMR_SETWORLDTRANSFORM: DoSetWorldTransform;
      EMR_MODIFYWORLDTRANSFORM: DoModifyWorldTransform;
      EMR_SELECTOBJECT: DoSelectObject;
      EMR_CREATEPEN: DoCreatePen;
      EMR_CREATEBRUSHINDIRECT: DoCreateBrushInDirect;
      EMR_DELETEOBJECT: DoDeleteObject;
      EMR_ANGLEARC: DoAngleArc;
      EMR_ELLIPSE: DoEllipse;
      EMR_RECTANGLE: DoRectangle;
      EMR_ROUNDRECT: DoRoundRect;
      EMR_ARC: DoArc;
      EMR_CHORD: DoChord;
      EMR_PIE: DoPie;
      EMR_LINETO: DoLineTo;
      EMR_ARCTO: DoArcTo;
      EMR_POLYDRAW: DoPolyDraw;
      EMR_SETARCDIRECTION: DoSetArcDirection;
      EMR_SETMITERLIMIT: DoSetMiterLimit;
      EMR_BEGINPATH: DoBeginPath;
      EMR_ENDPATH: DoEndPath;
      EMR_CLOSEFIGURE: DoCloseFigure;
      EMR_FILLPATH: DoFillPath;
      EMR_STROKEANDFILLPATH: DoStrokeAndFillPath;
      EMR_STROKEPATH: DoStrokePath;
      EMR_SELECTCLIPPATH: DoSelectClipPath;
      EMR_ABORTPATH: DoAbortPath;
      EMR_SETDIBITSTODEVICE: DoSetDibitsToDevice;
      EMR_STRETCHDIBITS: DoStretchDiBits;
      EMR_EXTCREATEFONTINDIRECTW: DoCreateFontInDirectW;
      EMR_EXTTEXTOUTA: DoExtTextOutA;
      EMR_EXTTEXTOUTW: DoExtTextOutW;
      EMR_POLYBEZIER16: DoPolyBezier16;
      EMR_POLYGON16: DoPolygon16;
      EMR_POLYLINE16: DoPolyLine16;
      EMR_POLYBEZIERTO16: DoPolyBezierTo16;
      EMR_POLYLINETO16: DoPolyLineTo16;
      EMR_POLYPOLYLINE16: DoPolyPolyLine16;
      EMR_POLYPOLYGON16: DoPolyPolygon16;
      EMR_POLYDRAW16: DoPolyDraw16;
      EMR_EXTCREATEPEN: DoExtCreatePen;
      EMR_SETTEXTJUSTIFICATION: DoSetTextJustification;
      EMR_BITBLT: DoBitBLT;
      EMR_SETSTRETCHBLTMODE: DoSetStretchBltMode;
      EMR_STRETCHBLT: DoStretchBlt;
    end;
{$IFDEF CANVASDBG}
    case RH^.iType of
      EMR_HEADER: S := 'HEADER';
      EMR_POLYBEZIER: S := 'POLYBEZIER';
      EMR_POLYGON: S := 'POLYGON';
      EMR_POLYLINE: S := 'POLYLINE';
      EMR_POLYBEZIERTO: S := 'POLYBEZIERTO';
      EMR_POLYLINETO: S := 'POLYLINETO';
      EMR_POLYPOLYLINE: S := 'POLYPOLYLINE';
      EMR_POLYPOLYGON: S := 'POLYPOLYGON';
      EMR_SETWINDOWEXTEX: S := 'SETWINDOWEXTEX';
      EMR_SETWINDOWORGEX: S := 'SETWINDOWORGEX';
      EMR_SETVIEWPORTEXTEX: S := 'SETVIEWPORTEXTEX';
      EMR_SETVIEWPORTORGEX: S := 'SETVIEWPORTORGEX';
      EMR_SETBRUSHORGEX: S := 'SETBRUSHORGEX';
      EMR_EOF: begin S := 'EOF'; FEX := True; end;
      EMR_SETPIXELV: S := 'SETPIXELV';
      EMR_SETMAPPERFLAGS: S := 'SETMAPPERFLAGS';
      EMR_SETMAPMODE: S := 'SETMAPMODE';
      EMR_SETBKMODE: S := 'SETBKMODE';
      EMR_SETPOLYFILLMODE: S := 'SETPOLYFILLMODE';
      EMR_SETROP2: S := 'SETROP2';
      EMR_SETSTRETCHBLTMODE: S := 'SETSTRETCHBLTMODE';
      EMR_SETTEXTALIGN: S := 'SETTEXTALIGN';
      EMR_SETCOLORADJUSTMENT: S := 'SETCOLORADJUSTMENT';
      EMR_SETTEXTCOLOR: S := 'SETTEXTCOLOR';
      EMR_SETBKCOLOR: S := 'SETBKCOLOR';
      EMR_OFFSETCLIPRGN: S := 'OFFSETCLIPRGN';
      EMR_MOVETOEX: S := 'MOVETOEX';
      EMR_SETMETARGN: S := 'SETMETARGN';
      EMR_EXCLUDECLIPRECT: S := 'EXCLUDECLIPRECT';
      EMR_INTERSECTCLIPRECT: S := 'INTERSECTCLIPRECT';
      EMR_SCALEVIEWPORTEXTEX: S := 'SCALEVIEWPORTEXTEX';
      EMR_SCALEWINDOWEXTEX: S := 'SCALEWINDOWEXTEX';
      EMR_SAVEDC: S := 'SAVEDC';
      EMR_RESTOREDC: S := 'RESTOREDC';
      EMR_SETWORLDTRANSFORM: S := 'SETWORLDTRANSFORM';
      EMR_MODIFYWORLDTRANSFORM: S := 'MODIFYWORLDTRANSFORM';
      EMR_SELECTOBJECT: S := 'SELECTOBJECT';
      EMR_CREATEPEN: S := 'CREATEPEN';
      EMR_CREATEBRUSHINDIRECT: S := 'CREATEBRUSHINDIRECT';
      EMR_DELETEOBJECT: S := 'DELETEOBJECT';
      EMR_ANGLEARC: S := 'ANGLEARC';
      EMR_ELLIPSE: S := 'ELLIPSE';
      EMR_RECTANGLE: S := 'RECTANGLE';
      EMR_ROUNDRECT: S := 'ROUNDRECT';
      EMR_ARC: S := 'ARC';
      EMR_CHORD: S := 'CHORD';
      EMR_PIE: S := 'PIE';
      EMR_SELECTPALETTE: S := 'SELECTPALETTE';
      EMR_CREATEPALETTE: S := 'CREATEPALETTE';
      EMR_SETPALETTEENTRIES: S := 'SETPALETTEENTRIES';
      EMR_RESIZEPALETTE: S := 'RESIZEPALETTE';
      EMR_REALIZEPALETTE: S := 'REALIZEPALETTE';
      EMR_EXTFLOODFILL: S := 'EXTFLOODFILL';
      EMR_LINETO: S := 'LINETO';
      EMR_ARCTO: S := 'ARCTO';
      EMR_POLYDRAW: S := 'POLYDRAW';
      EMR_SETARCDIRECTION: S := 'SETARCDIRECTION';
      EMR_SETMITERLIMIT: S := 'SETMITERLIMIT';
      EMR_BEGINPATH: S := 'BEGINPATH';
      EMR_ENDPATH: S := 'ENDPATH';
      EMR_CLOSEFIGURE: S := 'CLOSEFIGURE';
      EMR_FILLPATH: S := 'FILLPATH';
      EMR_STROKEANDFILLPATH: S := 'STROKEANDFILLPATH';
      EMR_STROKEPATH: S := 'STROKEPATH';
      EMR_FLATTENPATH: S := 'FLATTENPATH';
      EMR_WIDENPATH: S := 'WIDENPATH';
      EMR_SELECTCLIPPATH: S := 'SELECTCLIPPATH';
      EMR_ABORTPATH: S := 'ABORTPATH';
      EMR_GDICOMMENT: S := 'GDICOMMENT';
      EMR_FILLRGN: S := 'FILLRGN';
      EMR_FRAMERGN: S := 'FRAMERGN';
      EMR_INVERTRGN: S := 'INVERTRGN';
      EMR_PAINTRGN: S := 'PAINTRGN';
      EMR_EXTSELECTCLIPRGN: S := 'EXTSELECTCLIPRGN';
      EMR_BITBLT: S := 'BITBLT';
      EMR_STRETCHBLT: S := 'STRETCHBLT';
      EMR_MASKBLT: S := 'MASKBLT';
      EMR_PLGBLT: S := 'PLGBLT';
      EMR_SETDIBITSTODEVICE: S := 'SETDIBITSTODEVICE';
      EMR_STRETCHDIBITS: S := 'STRETCHDIBITS';
      EMR_EXTCREATEFONTINDIRECTW: S := 'EXTCREATEFONTINDIRECTW';
      EMR_EXTTEXTOUTA: S := 'EXTTEXTOUTA';
      EMR_EXTTEXTOUTW: S := 'EXTTEXTOUTW';
      EMR_POLYBEZIER16: S := 'POLYBEZIER16';
      EMR_POLYGON16: S := 'POLYGON16';
      EMR_POLYLINE16: S := 'POLYLINE16';
      EMR_POLYBEZIERTO16: S := 'POLYBEZIERTO16';
      EMR_POLYLINETO16: S := 'POLYLINETO16';
      EMR_POLYPOLYLINE16: S := 'POLYPOLYLINE16';
      EMR_POLYPOLYGON16: S := 'POLYPOLYGON16';
      EMR_POLYDRAW16: S := 'POLYDRAW16';
      EMR_CREATEMONOBRUSH: S := 'CREATEMONOBRUSH';
      EMR_CREATEDIBPATTERNBRUSHPT: S := 'CREATEDIBPATTERNBRUSHPT';
      EMR_EXTCREATEPEN: S := 'EXTCREATEPEN';
      EMR_POLYTEXTOUTA: S := 'POLYTEXTOUTA';
      EMR_POLYTEXTOUTW: S := 'POLYTEXTOUTW';
      EMR_SETICMMODE: S := 'SETICMMODE';
      EMR_CREATECOLORSPACE: S := 'CREATECOLORSPACE';
      EMR_SETCOLORSPACE: S := 'SETCOLORSPACE';
      EMR_DELETECOLORSPACE: S := 'DELETECOLORSPACE';
      EMR_GLSRECORD: S := 'GLSRECORD';
      EMR_GLSBOUNDEDRECORD: S := 'GLSBOUNDEDRECORD';
      EMR_PIXELFORMAT: S := 'PIXELFORMAT';
      EMR_DRAWESCAPE: S := 'DRAWESCAPE';
      EMR_EXTESCAPE: S := 'EXTESCAPE';
      EMR_STARTDOC: S := 'STARTDOC';
      EMR_SMALLTEXTOUT: S := 'SMALLTEXTOUT';
      EMR_FORCEUFIMAPPING: S := 'FORCEUFIMAPPING';
      EMR_NAMEDESCAPE: S := 'NAMEDESCAPE';
      EMR_COLORCORRECTPALETTE: S := 'COLORCORRECTPALETTE';
      EMR_SETICMPROFILEA: S := 'SETICMPROFILEA';
      EMR_SETICMPROFILEW: S := 'SETICMPROFILEW';
      EMR_ALPHABLEND: S := 'ALPHABLEND';
      EMR_ALPHADIBBLEND: S := 'ALPHADIBBLEND';
      EMR_TRANSPARENTBLT: S := 'TRANSPARENTBLT';
      EMR_TRANSPARENTDIB: S := 'TRANSPARENTDIB';
      EMR_GRADIENTFILL: S := 'GRADIENTFILL';
      EMR_SETLINKEDUFIS: S := 'SETLINKEDUFIS';
      EMR_SETTEXTJUSTIFICATION: S := 'SETTEXTJUSTIFICATION';
    end;
    NDW := (RH^.nSize - 8) div 4;
    Pin := Pointer(RH);
    Inc(Pin);
    for i := 0 to NDW - 1 do
    begin
      Inc(Pin);
      S := S + ' ' + IntToStr(Pin^);
      if i > 8 then Break;
    end;
    Debug.Add(IntToStr(CurRec) + '   ' + S);
    if SC <> FPage.FContent.Count then
    begin
      Debug.Add('');
      Debug.Add('-----------------------------------');
    end;
    for i := SC to FPage.FContent.Count - 1 do
      Debug.Add('     ' + FPage.FContent[i]);
    if SC <> FPage.FContent.Count then
    begin
      Debug.Add('-----------------------------------');
      Debug.Add('');
    end;

{$ENDIF}
  end;
{$IFDEF CANVASDBG}
  Debug.SaveToFile('HDCDebug\' + IntToStr(iii) + '.txt');
  Inc(iii);
  Debug.Free;
{$ENDIF}
end;

function TEMWParser.GX(Value: Extended): Extended;
begin
  Result := XOff + XScale * Value * Cal;
end;

function TEMWParser.GY(Value: Extended): Extended;
begin
  Result := YOff + YScale * Value * Cal;
end;


function TEMWParser.GetMax: TSize;
var
  Header: PEnhMetaHeader;
begin
  if MS.Size = 0 then
    raise TPDFException.Create(SMetafileNotLoaded);
  CV := MS.Memory;
  Header := CV;
  Result.cx := Round(Cal * header^.rclBounds.Right);
  Result.cy := Round(Cal * header^.rclBounds.Bottom);
end;

function TEMWParser.GetTextWidth(Text: string): Extended;
var
  i: integer;
  ch: char;
  tmpWidth: Extended;
begin
  Result := 0;
  for i := 1 to Length(Text) do
  begin
    ch := Text[i];
    tmpWidth := CurWidth[Ord(ch)];
    Result := Result + tmpWidth;
  end;
  Result := Result / 1000;
end;

procedure TEMWParser.LoadMetaFile(MF: TMetafile);
begin
  MS.Clear;
  MF.SaveToStream(MS);
  MFH := MF.Handle;
end;

procedure TEMWParser.SetCurFont;
var
  Rp: Boolean;
  St: TFontStyles;
  I: Integer;
  FS: Extended;
begin
  if not Fcha then Exit;
  Fcha := False;
  St := [];
  if CFont.lfWeight >= 600 then St := St + [fsBold];
  if CFont.lfItalic <> 0 then St := St + [fsItalic];
  if CFont.lfStrikeOut <> 0 then St := St + [fsStrikeOut];
  if CFont.lfUnderline <> 0 then St := St + [fsUnderline];
  Rp := False;
  if not IsTrueType(CFont.lfFaceName) then RP := True;
  if UpperCase(CFont.lfFaceName) = 'ZAPFDINGBATS' then Rp := False;
  if UpperCase(CFont.lfFaceName) = 'SYMBOL' then Rp := False;
  FS := //Min(-CFont.lfHeight * 72 / BM.Canvas.Font.PixelsPerInch,
    -MulDiv(CFont.lfHeight, 72, BM.Canvas.Font.PixelsPerInch) * YScale; //);
  if not Rp then
    FPage.SetActiveFont(CFont.lfFaceName, St, FS, CFont.lfCharSet) else
    FPage.SetActiveFont('Arial', St, FS, CFont.lfCharSet);
  for i := 0 to 255 do
    CurWidth[I] := round(FPage.FOwner.FFonts[FPage.FCurrentFontIndex].GetWidth(I) * FPage.FCurrentFontSize * FPage.D2P);
end;

procedure TEMWParser.SetInPath(const Value: Boolean);
begin
  FInPath := Value;
end;

procedure TEMWParser.PFillAndStroke;
begin
  if not IsNullBrush then
  begin
    if (CPen.lopnWidth <> 0) and (CPen.lopnStyle <> ps_null) then
      if PolyFIllMode then FPage.EoFillAndStroke else FPage.FillAndStroke
    else if PolyFIllMode then FPage.EoFill else FPage.Fill
  end else PStroke;
end;

procedure TEMWParser.PStroke;
begin
  if (CPen.lopnWidth <> 0) and (CPen.lopnStyle <> ps_null) then
    FPage.Stroke else FPage.NewPath;
end;

procedure TEMWParser.SetInText(const Value: Boolean);
begin
  FInText := Value;
  if Value = True then
  begin
    FPage.BeginText;
    SetCurFont;
    SetFontColor;
  end else
  begin
    FPage.EndText;
    SetBrushColor;
  end;
end;

procedure TEMWParser.SetBrushColor;
begin
  if CurFill <> CBrush.lbColor then
  begin
    CurFill := CBrush.lbColor;
    FPage.SetRGBColorFill(GetRValue(CBrush.lbColor) / 255,
      GetGValue(CBrush.lbColor) / 255, GetBValue(CBrush.lbColor) / 255);
  end;
end;

procedure TEMWParser.SetFontColor;
begin
  if CurFill <> TextColor then
  begin
    CurFill := TextColor;
    FPage.SetRGBColorFill(GetRValue(TextColor) / 255, GetGValue(TextColor) / 255, GetBValue(TextColor) / 255);
  end;
end;

procedure TEMWParser.SetPenColor;
begin
  FPage.SetRGBColorStroke(GetRValue(CPen.lopnColor) / 255,
    GetGValue(CPen.lopnColor) / 255, GetBValue(CPen.lopnColor) / 255);
end;

procedure TEMWParser.SetBGColor;
begin
  if CurFill <> BGColor then
  begin
    CurFill := BGColor;
    FPage.SetRGBColorFill(GetRValue(BGColor) / 255, GetGValue(BGColor) / 255, GetBValue(BGColor) / 255);
  end;
end;

procedure TEMWParser.DoModifyWorldTransform;
var
  PWorldTransf: PEMRModifyWorldTransform;
  TR: TXForm;
begin
  PWorldTransf := CV;
  if (PWorldTransf^.iMode = 0) or (PWorldTransf^.iMode = 1) or (PWorldTransf^.iMode = 2) then
  begin
    ModifyWorldTransform(BM.Canvas.Handle, PWorldTransf^.xform, pworldTransf^.iMode);
    GetWorldTransform(BM.Canvas.Handle, TR);
    XOff := TR.eDx * Cal;
    YOff := TR.eDy * Cal;
    XScale := TR.eM11;
    YScale := TR.eM22;
  end else
  begin
    XScale := PWorldTransf^.xform.eM11;
    YScale := PWorldTransf^.xform.eM22;
    XOff := PWorldTransf^.xform.eDx * Cal;
    YOff := PWorldTransf^.xform.eDy * Cal;
  end;
end;

{ TPDFCustomAnnotation }

function TPDFCustomAnnotation.CalcFlags: Integer;
begin
  Result := 0;
  if afInvisible in FFlags then Result := Result or 1;
  if afHidden in FFlags then Result := Result or 2;
  if afPrint in FFlags then Result := Result or 4;
  if afNoZoom in FFlags then Result := Result or 8;
  if afNoRotate in FFlags then Result := Result or 16;
  if afNoView in FFlags then Result := Result or 32;
  if afReadOnly in FFlags then Result := Result or 64;
end;

constructor TPDFCustomAnnotation.Create(AOwner: TPDFPage);
begin
  if AOwner = nil then
    raise TPDFException.Create(SAnnotationMustHaveTPDFPageAsOwner);
  FOwner := AOwner;
  AnnotID := FOwner.FOwner.GetNextID;
  FBorderStyle := '[0 0 1]';
  FBorderColor := clYellow;
  FOwner.FAnnot.Add(Pointer(Self));
end;

function TPDFCustomAnnotation.GetBox: TRect;
begin
  Result.Left := Round(FOwner.IntToExtX(FLeft));
  Result.Top := Round(FOwner.IntToExtY(FTop));
  Result.Bottom := Round(FOwner.IntToExtY(FBottom));
  Result.Right := Round(FOwner.IntToExtX(FRight));
end;


procedure TPDFCustomAnnotation.SetBox(const Value: TRect);
var
  R: TRect;
begin
  R := Value;
  NormalizeRect(R.Left, R.Top, R.Right, R.Bottom);
  FLeft := Round(FOwner.ExtToIntX(R.Left));
  FTop := Round(FOwner.ExtToIntY(R.Top));
  FBottom := Round(FOwner.ExtToIntY(R.Bottom));
  FRight := Round(FOwner.ExtToIntX(R.Right));
end;

{ TPDFTextAnnotation }


procedure TPDFTextAnnotation.Save;
begin
  FOwner.FOwner.StartObj(AnnotID);
  FOwner.FOwner.SaveToStream('/Type /Annot');
  FOwner.FOwner.SaveToStream('/Subtype /Text');
  FOwner.FOwner.SaveToStream('/Border ' + FBorderStyle);
  FOwner.FOwner.SaveToStream('/F ' + IntToStr(CalcFlags));
  FOwner.FOwner.SaveToStream('/C [' + FormatFloat(GetRValue(FBorderColor) / 255) + ' ' +
    FormatFloat(GetGValue(FBorderColor) / 255) + ' ' + FormatFloat(GetBValue(FBorderColor) / 255) + ' ]');
  FOwner.FOwner.SaveToStream('/Rect [' + IntToStr(Round(FLeft)) + ' ' + IntToStr(FBottom) +
    ' ' + IntToStr(FRight) + ' ' + IntToStr(FTop) + ']');
  if FCharset = ANSI_CHARSET then
  begin
    FOwner.FOwner.SaveToStream('/T (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, FCaption)) + ')');
    FOwner.FOwner.SaveToStream('/Contents (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, FText)) + ')');
  end else
  begin
    FOwner.FOwner.SaveToStream('/T <' + EnCodeHexString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, UnicodeChar(FCaption, FCharset)) + '>');
    FOwner.FOwner.SaveToStream('/Contents <' + EnCodeHexString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, UnicodeChar(FText, FCharset)) + '>');
  end;
  case TextAnnotationIcon of
    taiComment: FOwner.FOwner.SaveToStream('/Name /Comment');
    taiKey: FOwner.FOwner.SaveToStream('/Name /Key');
    taiNote: FOwner.FOwner.SaveToStream('/Name /Note');
    taiHelp: FOwner.FOwner.SaveToStream('/Name /Help');
    taiNewParagraph: FOwner.FOwner.SaveToStream('/Name /NewParagraph');
    taiParagraph: FOwner.FOwner.SaveToStream('/Name /Paragraph');
    taiInsert: FOwner.FOwner.SaveToStream('/Name /Insert');
  end;
  if FOpened then FOwner.FOwner.SaveToStream('/Open true') else FOwner.FOwner.SaveToStream('/Open false');
  FOwner.FOwner.CloseHObj;
  FOwner.FOwner.CloseObj;
end;

{ TPDFActionAnotation }

procedure TPDFActionAnnotation.Save;
begin
  FOwner.FOwner.StartObj(AnnotID);
  FOwner.FOwner.SaveToStream('/Type /Annot');
  FOwner.FOwner.SaveToStream('/Subtype /Link');
  FOwner.FOwner.SaveToStream('/Border ' + FBorderStyle);
  FOwner.FOwner.SaveToStream('/F ' + IntToStr(CalcFlags));
  FOwner.FOwner.SaveToStream('/C [' + FormatFloat(GetRValue(FBorderColor) / 255) + ' ' +
    FormatFloat(GetGValue(FBorderColor) / 255) + ' ' + FormatFloat(GetBValue(FBorderColor) / 255) + ' ]');
  FOwner.FOwner.SaveToStream('/Rect [' + IntToStr(Round(FLeft)) + ' ' + IntToStr(FBottom) +
    ' ' + IntToStr(FRight) + ' ' + IntToStr(FTop) + ']');
  FOwner.FOwner.SaveToStream('/A ' + IntToStr(FAction.ActionID) + ' 0 R');
  FOwner.FOwner.CloseHObj;
  FOwner.FOwner.CloseObj;
end;

procedure TPDFActionAnnotation.SetAction(const Value: TPDFAction);
begin
  FOwner.FOwner.AppendAction(Value);
  FAction := Value;
end;


{ TPDFActions }

function TPDFActions.Add(Action: TPDFAction): Integer;
begin
  Result := FActions.Add(Pointer(Action));
  Action.FOwner := FOwner;
end;

procedure TPDFActions.Clear;
var
  I: Integer;
begin
  for I := 0 to FActions.Count - 1 do
    TPDFAction(FActions[I]).Free;
  FActions.Clear;
end;

constructor TPDFActions.Create(AOwner: TPDFDocument);
begin
  FActions := TList.Create;
  FOwner := AOwner;
end;

procedure TPDFActions.Delete(Action: TPDFAction);
var
  I: Integer;
begin
  I := IndexOf(Action);
  if I <> -1 then
  begin
    TPDFAction(FActions[I]).Free;
    FActions.Delete(I);
  end;
end;

destructor TPDFActions.Destroy;
begin
  Clear;
  FActions.Free;
  inherited;
end;

function TPDFActions.GetAction(Index: Integer): TPDFAction;
begin
  Result := TPDFAction(FActions[Index]);
end;

function TPDFActions.GetCount: Integer;
begin
  Result := FActions.Count;
end;

function TPDFActions.IndexOf(Action: TPDFAction): Integer;
begin
  Result := FActions.IndexOf(Pointer(Action));
end;

{ TPDFURLAction }

procedure TPDFURLAction.Save;
begin
  FOwner.StartObj(ActionID);
  FOwner.SaveToStream('/S /URI /URI (' + EscapeSpecialChar(EnCodeString(FOwner.FProtectionEnabled, FOwner.FKey, ActionID, FURL)) + ')');
  if FNext <> nil then
    FOwner.SaveToStream('/Next ' + IntToStr(FNext.ActionID) + ' 0 R');
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;

procedure TPDFURLAction.SetURL(const Value: string);
begin
  if Value = '' then
    raise TPDFException.Create(SURLCannotBeEmpty);
  FURL := Value;
end;

{ TPDFAction }

constructor TPDFAction.Create;
begin
  FNext := nil;
  ActionID := 0;
end;

procedure TPDFAction.Prepare;
begin
  if ActionID < 1 then
    ActionID := FOwner.GetNextID;
  if FNext <> nil then
    FOwner.AppendAction(FNext);
end;

{ TPDFJavaScriptAction }

procedure TPDFJavaScriptAction.Save;
begin
  FOwner.StartObj(ActionID);
  FOwner.SaveToStream('/S /JavaScript /JS (' + EscapeSpecialChar(EnCodeString(FOwner.FProtectionEnabled, FOwner.FKey, ActionID, FJavaScript)) + ')');
  if FNext <> nil then
    FOwner.SaveToStream('/Next ' + IntToStr(FNext.ActionID) + ' 0 R');
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;

procedure TPDFJavaScriptAction.SetJavaScript(const Value: string);
begin
  if Value = '' then
    raise TPDFException.Create(SJavaScriptCannotBeEmpty);
  FJavaScript := Value;
end;

{ TPDFGoToPageAction }

procedure TPDFGoToPageAction.Save;
begin
  FOwner.StartObj(ActionID);
  FOwner.SaveToStream('/S /GoTo /D [' + IntToStr(FOwner.FPages[FPageIndex].PageID) +
    ' 0 R /FitH ' + IntToStr(Round(FOwner.FPages[PageIndex].ExtToIntY(FTopOffset))) + ']');
  if FNext <> nil then
    FOwner.SaveToStream('/Next ' + IntToStr(FNext.ActionID) + ' 0 R');
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;

procedure TPDFGoToPageAction.SetPageIndex(const Value: Integer);
begin
  if Value < 0 then
    raise TPDFException.Create(SPageIndexCannotBeNegative);
  FPageIndex := Value;
end;

procedure TPDFGoToPageAction.SetTopOffset(const Value: Integer);
begin
  if Value < 0 then
    raise TPDFException.Create(STopOffsetCannotBeNegative);
  FTopOffset := Value;
end;

{ TPDFVisibeControlAction }

constructor TPDFVisibeControlAction.Create;
begin
  FControls := TPDFControls.Create;
  Visible := True;
end;

destructor TPDFVisibeControlAction.Destroy;
begin
  FControls.Free;
end;

procedure TPDFVisibeControlAction.Save;
var
  I: Integer;
begin
  FOwner.StartObj(ActionID);
  FOwner.SaveToStream('/S /Hide /T [', False);
  for I := 0 to FControls.Count - 1 do
    FOwner.SaveToStream(IntToStr(FControls[I].AnnotID) + ' 0 R ', False);
  FOwner.SaveToStream(']');
  if FVisible then FOwner.SaveToStream('/H false');
  if FNext <> nil then
    FOwner.SaveToStream('/Next ' + IntToStr(FNext.ActionID) + ' 0 R');
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;


{ TPDFControls }

function TPDFControls.Add(Control: TPDFControl): Integer;
begin
  Result := FControls.Add(Pointer(Control));
end;

procedure TPDFControls.Clear;
begin
  FControls.Clear;
end;

constructor TPDFControls.Create;
begin
  FControls := TList.Create;
end;

procedure TPDFControls.Delete(Control: TPDFControl);
begin
  FControls.Delete(IndexOf(Control));
end;

destructor TPDFControls.Destroy;
begin
  FControls.Free;
end;

function TPDFControls.GetControl(Index: Integer): TPDFControl;
begin
  Result := TPDFControl(FControls[Index]);
end;

function TPDFControls.GetCount: Integer;
begin
  Result := FControls.Count;
end;

function TPDFControls.IndexOf(Control: TPDFControl): Integer;
begin
  Result := FControls.IndexOf(Pointer(Control));
end;

{ TPDFSubmitFormAction }

constructor TPDFSubmitFormAction.Create;
begin
  URL := 'http://www.borland.com';
  FFields := TPDFControls.Create;
  FRG := TList.Create
end;

destructor TPDFSubmitFormAction.Destroy;
begin
  FRG.Free;
  FFields.Free;
end;

procedure TPDFSubmitFormAction.Save;
var
  I, Flag: Integer;
  S: string;
begin
  I := 0;
  while I < FFields.Count do
  begin
    if FFields[I] is TPDFButton then FFields.Delete(FFields[I]) else
      if FFields[I] is TPDFRadioButton then
      begin
        if FRG.IndexOf(TPDFRadioButton(FFields[I]).FRG) < 0 then
          FRG.Add(TPDFRadioButton(FFields[I]).FRG);
        FFields.Delete(FFields[I]);
      end else Inc(I);
  end;
  Flag := 0;
  if SubmitType <> StFDF then
  begin
    if SubmitType <> stPost then
      Flag := Flag or 8;
    Flag := Flag or 4;
    S := '';
  end
  else S := '#FDF';
  if FIncludeEmptyFields then Flag := Flag or 2;
  FOwner.StartObj(ActionID);
  FOwner.SaveToStream('/S /SubmitForm');
  FOwner.SaveToStream('/F <</FS /URL /F (' + EscapeSpecialChar(EnCodeString(FOwner.FProtectionEnabled, FOwner.FKey, ActionID, FURL + S)) + ')>>');
  if (FFields.Count > 0) or (FRG.Count > 0) then
  begin
    FOwner.SaveToStream('/Fields [', False);
    for I := 0 to FFields.Count - 1 do
      FOwner.SaveToStream(IntToStr(FFields[I].AnnotID) + ' 0 R ', False);
    for I := 0 to FRG.Count - 1 do
      FOwner.SaveToStream(IntToStr(TPDFRadioGroup(FRG[I]).GroupID) + ' 0 R ', False);
    FOwner.SaveToStream(']');
  end;
  FOwner.SaveToStream('/Flags ' + IntToStr(Flag));
  if FNext <> nil then
    FOwner.SaveToStream('/Next ' + IntToStr(FNext.ActionID) + ' 0 R');
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;

procedure TPDFSubmitFormAction.SetURL(const Value: string);
begin
  if Value = '' then
    raise TPDFException.Create(SURLCannotBeEmpty);
  FURL := Value;
end;

{ TPDFResetFormAction }

constructor TPDFResetFormAction.Create;
begin
  FFields := TPDFControls.Create;
  FRG := TList.Create;
end;

destructor TPDFResetFormAction.Destroy;
begin
  FRG.Free;
  FFields.Free;
end;

procedure TPDFResetFormAction.Save;
var
  I: Integer;
begin
  I := 0;
  while I < FFields.Count do
  begin
    if FFields[I] is TPDFButton then FFields.Delete(FFields[I]) else
      if FFields[I] is TPDFRadioButton then
      begin
        if FRG.IndexOf(TPDFRadioButton(FFields[I]).FRG) < 0 then
          FRG.Add(TPDFRadioButton(FFields[I]).FRG);
        FFields.Delete(FFields[I]);
      end else Inc(I);
  end;
  FOwner.StartObj(ActionID);
  FOwner.SaveToStream('/S /ResetForm');
  if (FFields.Count > 0) or (FRG.Count > 0) then
  begin
    FOwner.SaveToStream('/Fields [', False);
    for I := 0 to FFields.Count - 1 do
      FOwner.SaveToStream(IntToStr(FFields[I].AnnotID) + ' 0 R ', False);
    for I := 0 to FRG.Count - 1 do
      FOwner.SaveToStream(IntToStr(TPDFRadioGroup(FRG[I]).GroupID) + ' 0 R ', False);
    FOwner.SaveToStream(']');
  end;
  if FNext <> nil then
    FOwner.SaveToStream('/Next ' + IntToStr(FNext.ActionID) + ' 0 R');
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;

{ TPDFImportDataAction }

procedure TPDFImportDataAction.Save;
begin
  FOwner.StartObj(ActionID);
  FOwner.SaveToStream('/S /ImportData');
  FOwner.SaveToStream('/F <</Type /FileSpec /F (' + EscapeSpecialChar(EnCodeString(FOwner.FProtectionEnabled, FOwner.FKey, ActionID, FFileName)) + ')>>');
  if FNext <> nil then
    FOwner.SaveToStream('/Next ' + IntToStr(FNext.ActionID) + ' 0 R');
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;

procedure TPDFImportDataAction.SetFileName(const Value: string);
begin
  if Value = '' then
    raise TPDFException.Create(SFileNameCannotBeEmpty);
  FFileName := Value;
end;

{ TPDFControl }

function TPDFControl.CalcActions: string;
begin
  Result := '';
  if OnMouseUp <> nil then
    Result := Result + '/A ' + IntToStr(OnMouseUp.ActionID) + ' 0 R'#13#10;
  Result := Result + '/AA <<';
  if OnMouseEnter <> nil then
    Result := Result + '/E ' + IntToStr(OnMouseEnter.ActionID) + ' 0 R';
  if OnMouseExit <> nil then
    Result := Result + '/X ' + IntToStr(OnMouseExit.ActionID) + ' 0 R';
  if OnMouseDown <> nil then
    Result := Result + '/D ' + IntToStr(OnMouseDown.ActionID) + ' 0 R';
  if OnLostFocus <> nil then
    Result := Result + '/Bl ' + IntToStr(OnLostFocus.ActionID) + ' 0 R';
  if OnSetFocus <> nil then
    Result := Result + '/D ' + IntToStr(OnSetFocus.ActionID) + ' 0 R';
end;

constructor TPDFControl.Create(AOwner: TPDFPage; AName: string);
begin
  inherited Create(AOwner);
  Name := AName;
  FFont := TPDFControlFont.Create;
  FHint := TPDFControlHint.Create;
  FBorderColor := clBlack;
  if not ((Self is TPDFButton) or (Self is TPDFRadioButton)) then
    FOwner.FOwner.FAcroForm.FFields.Add(Self);
end;

destructor TPDFControl.Destroy;
begin
  FFont.Free;
  FHint.Free;
  inherited;
end;

procedure TPDFControl.SetColor(const Value: TColor);
begin
  FColor := Value;
end;

procedure TPDFControl.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TPDFControl.SetOnLostFocus(const Value: TPDFAction);
begin
  if FOnLostFocus = nil then FOnLostFocus := Value
  else
  begin
    Value.FNext := FOnLostFocus;
    FOnLostFocus := Value;
  end;
  FOwner.FOwner.AppendAction(Value);
end;

procedure TPDFControl.SetOnMouseDown(const Value: TPDFAction);
begin
  if FOnMouseDown = nil then FOnMouseDown := Value
  else
  begin
    Value.FNext := FOnMouseDown;
    FOnMouseDown := Value;
  end;
  FOwner.FOwner.AppendAction(Value);
end;

procedure TPDFControl.SetOnMouseEnter(const Value: TPDFAction);
begin
  if FOnMouseEnter = nil then FOnMouseEnter := Value
  else
  begin
    Value.FNext := FOnMouseEnter;
    FOnMouseEnter := Value;
  end;
  FOwner.FOwner.AppendAction(Value);
end;

procedure TPDFControl.SetOnMouseExit(const Value: TPDFAction);
begin
  if FOnMouseExit = nil then FOnMouseExit := Value
  else
  begin
    Value.FNext := FOnMouseExit;
    FOnMouseExit := Value;
  end;
  FOwner.FOwner.AppendAction(Value);
end;

procedure TPDFControl.SetOnMouseUp(const Value: TPDFAction);
begin
  if FOnMouseUp = nil then FOnMouseUp := Value
  else
  begin
    Value.FNext := FOnMouseUp;
    FOnMouseUp := Value;
  end;
  FOwner.FOwner.AppendAction(Value);
end;

procedure TPDFControl.SetOnSetFocus(const Value: TPDFAction);
begin
  if FOnSetFocus = nil then FOnSetFocus := Value
  else
  begin
    Value.FNext := FOnSetFocus;
    FOnSetFocus := Value;
  end;
  FOwner.FOwner.AppendAction(Value);
end;

{ TPDFAcroForm }

procedure TPDFAcroForm.Clear;
begin
  FFields.Clear;
  FFonts.Clear;
  FRadioGroups.Clear;
end;

constructor TPDFAcroForm.Create(AOwner: TPDFDocument);
begin
  FFields := TPDFControls.Create;
  FFonts := TList.Create;
  FOwner := AOwner;
  FRadioGroups := TList.Create;
end;

destructor TPDFAcroForm.Destroy;
begin
  FRadioGroups.Free;
  FFonts.Free;
  FFields.Free;
end;

function TPDFAcroForm.GetEmpty: Boolean;
begin
  Result := (FFields.Count = 0) and (FRadioGroups.Count = 0);
end;

procedure TPDFAcroForm.Save;
var
  I, ResID: Integer;
begin
  if (FFields.Count = 0) and (FRadioGroups.Count = 0) then Exit;
  FOwner.StartObj(ResID);
  FOwner.SaveToStream('/Font <<', False);
  for I := 0 to FFonts.Count - 1 do
    FOwner.SaveToStream('/' + TPDFFont(FFonts[I]).AliasName + ' ' + IntToStr(TPDFFont(FFonts[I]).FontID) + ' 0 R ', False);
  FOwner.SaveToStream('>>');
  FOwner.CloseHObj;
  FOwner.CloseObj;
  FOwner.StartObj(AcroID);
  FOwner.SaveToStream('/Fields [', False);
  for I := 0 to FFields.Count - 1 do
    FOwner.SaveToStream(IntToStr(FFields[I].AnnotID) + ' 0 R ', False);
  for I := 0 to FRadioGroups.Count - 1 do
    FOwner.SaveToStream(IntToStr(TPDFRadioGroup(FRadioGroups[I]).GroupID) + ' 0 R ', False);
  FOwner.SaveToStream(']', False);
  FOwner.SaveToStream('/DR ' + IntToStr(ResID) + ' 0 R');
  FOwner.SaveToStream('/CO [', False);
  for I := 0 to FFields.Count - 1 do
    if FFields[I] is TPDFInputControl then
      if TPDFInputControl(FFields[I]).OnOtherCOntrolChanged <> nil then
        FOwner.SaveToStream(IntToStr(FFields[I].AnnotID) + ' 0 R ', False);
  FOwner.SaveToStream(']', False);
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;

{ TPDFInputControl }

function TPDFInputControl.CalcActions: string;
begin
  Result := inherited CalcActions;
  if OnKeyPress <> nil then
    Result := Result + '/K ' + IntToStr(OnKeyPress.ActionID) + ' 0 R';
  if OnBeforeFormatting <> nil then
    Result := Result + '/F ' + IntToStr(OnBeforeFormatting.ActionID) + ' 0 R';
  if OnChange <> nil then
    Result := Result + '/V ' + IntToStr(OnChange.ActionID) + ' 0 R';
  if OnOtherControlChanged <> nil then
    Result := Result + '/C ' + IntToStr(OnOtherControlChanged.ActionID) + ' 0 R';
end;

procedure TPDFInputControl.SetOnBeforeFormatting(const Value: TPDFJavaScriptAction);
begin
  FOnBeforeFormatting := Value;
  FOwner.FOwner.AppendAction(Value);
end;

procedure TPDFInputControl.SetOnChange(const Value: TPDFJavaScriptAction);
begin
  FOnChange := Value;
  FOwner.FOwner.AppendAction(Value);
end;

procedure TPDFInputControl.SetOnKeyPress(const Value: TPDFJavaScriptAction);
begin
  FOnKeyPress := Value;
  FOwner.FOwner.AppendAction(Value);
end;

procedure TPDFInputControl.SetOnOtherCOntrolChanged(const Value: TPDFJavaScriptAction);
begin
  FOnOtherCOntrolChanged := Value;
  FOwner.FOwner.AppendAction(Value);
end;

{ TPDFControlFont }

constructor TPDFControlFont.Create;
begin
  FName := 'Arial';
  FColor := clBlack;
  FCharset := 0;
  FSize := 8;
  FStyle := [];
end;

procedure TPDFControlFont.SetCharset(const Value: TFontCharset);
begin
  FCharset := Value;
end;

procedure TPDFControlFont.SetSize(const Value: Integer);
begin
  if Value < 0 then
    raise TPDFException.Create(SCannotSetNegativeSize);
  FSize := Value;
end;

{ TPDFButton }

constructor TPDFButton.Create(AOwner: TPDFPage; AName: string);
begin
  inherited Create(AOwner, AName);
  FColor := clSilver;
end;

procedure TPDFButton.Paint;
var
  x, y, z: array[0..3] of Byte;
  i: Integer;
begin
  I := ColorToRGB(FFont.Color);
  Move(i, x[0], 4);
  i := ColorToRGB(FColor);
  Move(i, z[0], 4);
  i := ColorToRGB(FBorderColor);
  Move(i, y[0], 4);
  with FUp do
  begin
    Width := abs(FRight - FLeft);
    Height := abs(FBottom - FTop);
    SetRGBColorFill(z[0] / 255 * 0.6, z[1] / 255 * 0.6, z[2] / 255 * 0.6);
    MoveTo(Width - 0.5, 0.5);
    LineTo(Width - 0.5, Height - 0.5);
    LineTo(0.5, Height - 0.5);
    LineTo(1.5, Height - 1.5);
    LineTo(Width - 1.5, Height - 1.5);
    LineTo(Width - 1.5, 1.5);
    LineTo(Width - 0.5, 0.5);
    Fill;
    SetRGBColorFill(z[0] / 255 * 1.4, z[1] / 255 * 1.4, z[2] / 255 * 1.4);
    MoveTo(0.5, Height - 0.5);
    LineTo(0.5, 0.5);
    LineTo(Width - 0.5, 0.5);
    LineTo(Width - 1.5, 1.5);
    LineTo(1.5, 1.5);
    LineTo(1.5, Height - 1.5);
    LineTo(0.5, Height - 0.5);
    Fill;
    SetRGBColorFill(z[0] / 255, z[1] / 255, z[2] / 255);
    Rectangle(1.5, 1.5, Width - 1.5, Height - 1.5);
    Fill;
    SetLineWidth(1);
    SetRGBColorStroke(y[0] / 255, y[1] / 255, y[2] / 255);
    Rectangle(0, 0, Width, Height);
    Stroke;
    BeginText;
    SetRGBColorFill(x[0] / 255, X[1] / 255, X[2] / 255);
    SetActiveFont(FFont.Name, FFont.Style, FFont.Size, FFont.Charset);
    FFN := FOwner.FFonts.FLast.AliasName;
    TextBox(Rect(0, 0, Width, Height), Caption, hjCenter, vjCenter);
    EndText;
  end;
  with FDown do
  begin
    Width := abs(FRight - FLeft);
    Height := abs(FBottom - FTop);
    SetLineWidth(1);
    SetRGBColorFill(z[0] / 255, z[1] / 255, z[2] / 255);
    Rectangle(0, 0, Width, Height);
    Fill;
    SetRGBColorStroke(z[0] / 255 * 1.4, z[1] / 255 * 1.4, z[2] / 255 * 1.4);
    MoveTo(Width - 0.5, 1);
    LineTo(Width - 0.5, Height - 0.5);
    LineTo(1, Height - 0.5);
    Stroke;
    SetRGBColorStroke(z[0] / 255 * 0.6, z[1] / 255 * 0.6, z[2] / 255 * 0.6);
    MoveTo(0.5, Height - 1);
    LineTo(0.5, 0.5);
    LineTo(Width - 1, 0.5);
    Stroke;
    SetRGBColorStroke(y[0] / 255, y[1] / 255, y[2] / 255);
    Rectangle(0, 0, Width, Height);
    Stroke;
    BeginText;
    SetRGBColorFill(x[0] / 255, X[1] / 255, X[2] / 255);
    SetActiveFont(FFont.Name, FFont.Style, FFont.Size, FFont.Charset);
    TextBox(Rect(0, 0, Width, Height - 2), Caption, hjCenter, vjCenter);
    EndText;
  end;
end;

procedure TPDFButton.Save;
var
  i, j: Integer;
begin
  FUp := TPDFPage.Create(FOwner.FOwner);
  try
    FUp.FIsForm := True;
    try
      FDown := TPDFPage.Create(FOwner.FOwner);
      FDown.FIsForm := True;
      Paint;
      FUp.Save;
      FDown.Save;
      for i := 0 to FUp.FLinkedFont.Count - 1 do
        if FOwner.FOwner.FAcroForm.FFonts.IndexOf(FUp.FLinkedFont[i]) = -1 then
          FOwner.FOwner.FAcroForm.FFonts.Add(FUp.FLinkedFont[i]);
      FOwner.FOwner.StartObj(AnnotID);
      FOwner.FOwner.SaveToStream('/Type /Annot');
      FOwner.FOwner.SaveToStream('/Subtype /Widget');
      FOwner.FOwner.SaveToStream('/Rect [' + IntToStr(Round(FLeft)) + ' ' + IntToStr(FBottom) +
        ' ' + IntToStr(FRight) + ' ' + IntToStr(FTop) + ']');
      FOwner.FOwner.SaveToStream('/P ' + IntToStr(FOwner.PageID) + ' 0 R');
      FOwner.FOwner.SaveToStream('/MK <</CA (' +
        EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, Caption)) + ') ', False);
      FOwner.FOwner.SaveToStream('/BC [' + FormatFloat(GetRValue(FBorderColor) / 255) + ' ' +
        FormatFloat(GetGValue(FBorderColor) / 255) + ' ' + FormatFloat(GetBValue(FBorderColor) / 255) + ' ]', False);
      FOwner.FOwner.SaveToStream('/BG [' + FormatFloat(GetRValue(FColor) / 255) + ' ' +
        FormatFloat(GetGValue(FColor) / 255) + ' ' + FormatFloat(GetBValue(FColor) / 255) + ' ]', False);
      FOwner.FOwner.SaveToStream('>>');
      FOwner.FOwner.SaveToStream('/DA (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled,
        FOwner.FOwner.FKey, AnnotID, '/' + FFN + ' ' + IntToStr(FFont.Size))) + ' Tf ' +
        FormatFloat(GetRValue(FFont.Color) / 255) + ' ' +
        FormatFloat(GetGValue(FFont.Color) / 255) + ' ' + FormatFloat(GetBValue(FFont.Color) / 255) + ' rg)');
      FOwner.FOwner.SaveToStream('/BS <</W 1 /S /B>>');
      FOwner.FOwner.SaveToStream('/T (' +
        EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, Name)) + ')');
      FOwner.FOwner.SaveToStream('/FT /Btn');
      if FHint.Caption <> '' then
        if (FHint.Charset in [0..2]) then
          FOwner.FOwner.SaveToStream('/TU (' +
            EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, FHint.Caption)) + ')')
        else
          FOwner.FOwner.SaveToStream('/TU <' +
            EnCodeHexString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, UnicodeChar(FHint.Caption, FHint.Charset)) + '>');
      i := 0;
      if FReadOnly then i := i or 1;
      if FRequired then i := i or 2;
      j := 1 shl 16;
      i := i or j;
      FOwner.FOwner.SaveToStream('/F ' + IntToStr(CalcFlags));
      FOwner.FOwner.SaveToStream('/Ff ' + IntToStr(i));
      FOwner.FOwner.SaveToStream('/H /P');
      FOwner.FOwner.SaveToStream('/AP <</N ' + IntToStr(FUp.PageID) + ' 0 R ', False);
      FOwner.FOwner.SaveToStream('/D ' + IntToStr(FDown.PageID) + ' 0 R', False);
      FOwner.FOwner.SaveToStream('>>');
      FOwner.FOwner.SaveToStream(CalcActions + '>>');
      FOwner.FOwner.CloseHObj;
      FOwner.FOwner.CloseObj;
    finally
      FDown.Free;
    end;
  finally
    FUp.Free;
  end;
end;

{ TPDFCheckBox }

constructor TPDFCheckBox.Create(AOwner: TPDFPage; AName: string);
begin
  inherited Create(AOwner, AName);
  FColor := clWhite;
end;

procedure TPDFCheckBox.Paint;
var
  x, y, z: array[0..3] of Byte;
  i: Integer;
begin
  I := ColorToRGB(FFont.Color);
  Move(i, x[0], 4);
  i := ColorToRGB(FColor);
  Move(i, z[0], 4);
  i := ColorToRGB(FBorderColor);
  Move(i, y[0], 4);
  with FCheck do
  begin
    Width := abs(FRight - FLeft);
    Height := abs(FBottom - FTop);
    SetLineWidth(1);
    SetRGBColorFill(z[0] / 255, z[1] / 255, z[2] / 255);
    Rectangle(0, 0, Width, Height);
    Fill;
    SetRGBColor(y[0] / 255, y[1] / 255, y[2] / 255);
    Rectangle(0.5, 0.5, Height - 0.5, Height - 0.5);
    Stroke;
    BeginText;
    SetActiveFont('ZapfDingbats', [], Height - 2);
    TextBox(Rect(2, 2, Height - 2, Height - 4), '8', hjCenter, vjCenter);
    SetRGBColorFill(x[0] / 255, X[1] / 255, X[2] / 255);
    SetActiveFont(FFont.Name, FFont.Style, FFont.Size, FFont.Charset);
    TextBox(Rect(Height + 4, 0, Width, Height), Caption, hjLeft, vjCenter);
    EndText;
  end;
  with FUncheck do
  begin
    Width := abs(FRight - FLeft);
    Height := abs(FBottom - FTop);
    SetLineWidth(1);
    SetRGBColorFill(z[0] / 255, z[1] / 255, z[2] / 255);
    Rectangle(0, 0, Width, Height);
    Fill;
    SetRGBColorStroke(y[0] / 255, y[1] / 255, y[2] / 255);
    Rectangle(0.5, 0.5, Height - 0.5, Height - 0.5);
    Stroke;
    BeginText;
    SetRGBColorFill(x[0] / 255, X[1] / 255, X[2] / 255);
    SetActiveFont(FFont.Name, FFont.Style, FFont.Size, FFont.Charset);
    TextBox(Rect(Height + 4, 0, Width, Height), Caption, hjLeft, vjCenter);
    EndText;
  end;
end;

procedure TPDFCheckBox.Save;
var
  i: Integer;
begin
  FCheck := TPDFPage.Create(FOwner.FOwner);
  try
    FCheck.FIsForm := True;
    FUnCheck := TPDFPage.Create(FOwner.FOwner);
    try
      FUnCheck.FIsForm := True;
      Paint;
      FCheck.Save;
      FUnCheck.Save;
      FOwner.FOwner.StartObj(AnnotID);
      FOwner.FOwner.SaveToStream('/Type /Annot');
      FOwner.FOwner.SaveToStream('/Subtype /Widget');
      FOwner.FOwner.SaveToStream('/H /T');
      FOwner.FOwner.SaveToStream('/Rect [' + IntToStr(Round(FLeft)) + ' ' + IntToStr(FBottom) +
        ' ' + IntToStr(FRight) + ' ' + IntToStr(FTop) + ']');
      FOwner.FOwner.SaveToStream('/P ' + IntToStr(FOwner.PageID) + ' 0 R');
      if FChecked then FOwner.FOwner.SaveToStream('/V /Yes /AS /Yes') else FOwner.FOwner.SaveToStream('/V /Off /AS /Off');
      FOwner.FOwner.SaveToStream('/T (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, Name)) + ')');
      FOwner.FOwner.SaveToStream('/FT /Btn');
      FOwner.FOwner.SaveToStream('/F ' + IntToStr(CalcFlags));
      i := 0;
      if FReadOnly then i := i or 1;
      if FRequired then i := i or 2;
      FOwner.FOwner.SaveToStream('/Ff ' + IntToStr(i));
      FOwner.FOwner.SaveToStream('/AP <</N << /Yes ' + IntToStr(FCheck.PageID) + ' 0 R ', False);
      FOwner.FOwner.SaveToStream('/Off  ' + IntToStr(FUnCheck.PageID) + ' 0 R >> ', False);
      FOwner.FOwner.SaveToStream('>>');
      FOwner.FOwner.SaveToStream(CalcActions + '>>');
      FOwner.FOwner.CloseHObj;
      FOwner.FOwner.CloseObj;
    finally
      FUnCheck.Free;
    end;
  finally
    FCheck.Free;
  end;
end;

{ TPDFEdit }

constructor TPDFEdit.Create(AOwner: TPDFPage; AName: string);
begin
  inherited Create(AOwner, AName);
  FBorderColor := clBlack;
  FColor := clWhite;
  FShowBorder := True;
  FMultiline := False;
  FIsPassword := False;
  FMaxLength := 0;
end;

procedure TPDFEdit.Paint;
var
  x, y, z: array[0..3] of Byte;
  i: Integer;
  s: string;
begin
  i := ColorToRGB(FColor);
  Move(i, z[0], 4);
  i := ColorToRGB(FBorderColor);
  Move(i, y[0], 4);
  I := ColorToRGB(FFont.Color);
  Move(i, x[0], 4);
  with FShow do
  begin
    Width := abs(FRight - FLeft);
    Height := abs(FBottom - FTop);
    FEmulationEnabled := False;
    SetLineWidth(1);
    SetRGBColorFill(z[0] / 255, z[1] / 255, z[2] / 255);
    SetRGBColorStroke(y[0] / 255, y[1] / 255, y[2] / 255);
    Rectangle(0, 0, Width, Height);
    if FShowBorder then FillAndStroke else Fill;
    NewPath;
    Rectangle(0, 0, Width, Height);
    Clip;
    NewPath;
    AppendAction('/Tx BMC');
    BeginText;
    SetRGBColorFill(x[0] / 255, X[1] / 255, X[2] / 255);
    SetActiveFont(FFont.Name, FFont.Style, FFont.Size, FFont.Charset);
    FFN := FOwner.FFonts.FLast.AliasName;
    if FText <> '' then
      if not FIsPassword then
        TextBox(Rect(2, 2, Width - 2, Height - 2), FText, FJustification, vjCenter)
      else
      begin
        s := '';
        for i := 1 to Length(FText) do s := s + '*';
        TextBox(Rect(2, 2, Width - 2, Height - 2), s, FJustification, vjCenter)
      end;
    EndText;
    AppendAction('EMC');
  end;
end;

procedure TPDFEdit.Save;
var
  i, j: Integer;
begin
  FShow := TPDFPage.Create(FOwner.FOwner);
  try
    FShow.FIsForm := True;
    FShow.FRemoveCR := True;
    Paint;
    for i := 0 to FShow.FLinkedFont.Count - 1 do
      if FOwner.FOwner.FAcroForm.FFonts.IndexOf(FShow.FLinkedFont[i]) = -1 then
        FOwner.FOwner.FAcroForm.FFonts.Add(FShow.FLinkedFont[i]);
    FShow.Save;
    FOwner.FOwner.StartObj(AnnotID);
    FOwner.FOwner.SaveToStream('/Type /Annot');
    FOwner.FOwner.SaveToStream('/Subtype /Widget');
    FOwner.FOwner.SaveToStream('/Rect [' + IntToStr(Round(FLeft)) + ' ' + IntToStr(FBottom) +
      ' ' + IntToStr(FRight) + ' ' + IntToStr(FTop) + ']');
    FOwner.FOwner.SaveToStream('/FT /Tx');
    FOwner.FOwner.SaveToStream('/F ' + IntToStr(CalcFlags));
    FOwner.FOwner.SaveToStream('/P ' + IntToStr(FOwner.PageID) + ' 0 R');
    FOwner.FOwner.SaveToStream('/T (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, Name)) + ')');
    i := 0;
    if FReadOnly then i := i or 1;
    if FRequired then i := i or 2;
    if FMultiline then
    begin
      j := 1 shl 12;
      i := i or j;
    end;
    if FIsPassword then
    begin
      j := 1 shl 13;
      i := i or j;
    end;
    FOwner.FOwner.SaveToStream('/Ff ' + IntToStr(i));
    case FJustification of
      hjCenter: FOwner.FOwner.SaveToStream('/Q 1');
      hjRight: FOwner.FOwner.SaveToStream('/Q 2');
    end;
    if FText <> '' then
      FOwner.FOwner.SaveToStream('/V (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, FText)) + ')');
    if FText <> '' then
      FOwner.FOwner.SaveToStream('/DV (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, FText)) + ')');
    if FMaxLength <> 0 then
      FOwner.FOwner.SaveToStream('/MaxLen ' + IntToStr(FMaxLength));
    FOwner.FOwner.SaveToStream('/DA (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled,
      FOwner.FOwner.FKey, AnnotID, '/' + FFN + ' ' + IntToStr(FFont.Size))) + ' Tf ' +
      FormatFloat(GetRValue(FFont.Color) / 255) + ' ' +
      FormatFloat(GetGValue(FFont.Color) / 255) + ' ' + FormatFloat(GetBValue(FFont.Color) / 255) + ' rg)');
    FOwner.FOwner.SaveToStream('/AP <</N ' + IntToStr(FShow.PageID) + ' 0 R >> ');
    FOwner.FOwner.SaveToStream(CalcActions + '>>');
    FOwner.FOwner.CloseHObj;
    FOwner.FOwner.CloseObj;
  finally
    FShow.Free;
  end;
end;

procedure TPDFEdit.SetMaxLength(const Value: Integer);
begin
  if Value < 0 then FMaxLength := 0 else FMaxLength := Value;
end;

{ TPDFComboBox }

constructor TPDFComboBox.Create(AOwner: TPDFPage; AName: string);
begin
  inherited Create(AOwner, AName);
  FItems := TStringList.Create;
  FEditEnabled := True;
  FBorderColor := clBlack;
  FColor := clWhite;
end;

destructor TPDFComboBox.Destroy;
begin
  inherited;
  FItems.Free;
end;

procedure TPDFComboBox.Paint;
var
  x, y, z: array[0..3] of Byte;
  i: Integer;
begin
  i := ColorToRGB(FColor);
  Move(i, z[0], 4);
  i := ColorToRGB(FBorderColor);
  Move(i, y[0], 4);
  I := ColorToRGB(FFont.Color);
  Move(i, x[0], 4);
  with FShow do
  begin
    Width := abs(FRight - FLeft);
    Height := abs(FBottom - FTop);
    FEmulationEnabled := False;
    SetLineWidth(1);
    SetRGBColorFill(z[0] / 255, z[1] / 255, z[2] / 255);
    SetRGBColorStroke(y[0] / 255, y[1] / 255, y[2] / 255);
    Rectangle(0, 0, Width, Height);
    FillAndStroke;
    NewPath;
    Rectangle(0, 0, Width, Height);
    Clip;
    NewPath;
    AppendAction('/Tx BMC');
    BeginText;
    SetRGBColorFill(x[0] / 255, X[1] / 255, X[2] / 255);
    SetActiveFont(FFont.Name, FFont.Style, FFont.Size, FFont.Charset);
    FFN := FOwner.FFonts.FLast.AliasName;
    if FText <> '' then
      TextBox(Rect(2, 2, Width - 2, Height - 2), FText, hjLeft, vjCenter);
    EndText;
    AppendAction('EMC');
  end;
end;

procedure TPDFComboBox.Save;
var
  i, j: Integer;
begin
  FShow := TPDFPage.Create(FOwner.FOwner);
  try
    FShow.FIsForm := True;
    FShow.FRemoveCR := True;
    Paint;
    for i := 0 to FShow.FLinkedFont.Count - 1 do
      if FOwner.FOwner.FAcroForm.FFonts.IndexOf(FShow.FLinkedFont[i]) = -1 then
        FOwner.FOwner.FAcroForm.FFonts.Add(FShow.FLinkedFont[i]);
    FShow.Save;
    FOwner.FOwner.StartObj(AnnotID);
    FOwner.FOwner.SaveToStream('/Type /Annot');
    FOwner.FOwner.SaveToStream('/Subtype /Widget');
    FOwner.FOwner.SaveToStream('/Rect [' + IntToStr(Round(FLeft)) + ' ' + IntToStr(FBottom) +
      ' ' + IntToStr(FRight) + ' ' + IntToStr(FTop) + ']');
    FOwner.FOwner.SaveToStream('/FT /Ch');
    FOwner.FOwner.SaveToStream('/F ' + IntToStr(CalcFlags));
    FOwner.FOwner.SaveToStream('/P ' + IntToStr(FOwner.PageID) + ' 0 R');
    FOwner.FOwner.SaveToStream('/T (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, Name)) + ')');
    i := 0;
    if FReadOnly then i := i or 1;
    if FRequired then i := i or 2;
    j := 1 shl 17;
    i := i or j;
    if FEditEnabled then
    begin
      j := 1 shl 18;
      i := i or j;
    end;
    FOwner.FOwner.SaveToStream('/Ff ' + IntToStr(i));
    FOwner.FOwner.SaveToStream('/Opt [', False);
    for i := 0 to Items.Count - 1 do
      FOwner.FOwner.SaveToStream('(' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, Items[i])) + ')');
    FOwner.FOwner.SaveToStream(']');
    FOwner.FOwner.SaveToStream('/F 4');
    if FText <> '' then
      FOwner.FOwner.SaveToStream('/V (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, FText)) + ')');
    if FText <> '' then
      FOwner.FOwner.SaveToStream('/DV (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, FText)) + ')');
    FOwner.FOwner.SaveToStream('/DA (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled,
      FOwner.FOwner.FKey, AnnotID, '/' + FFN + ' ' + IntToStr(FFont.Size))) + ' Tf ' +
      FormatFloat(GetRValue(FFont.Color) / 255) + ' ' +
      FormatFloat(GetGValue(FFont.Color) / 255) + ' ' + FormatFloat(GetBValue(FFont.Color) / 255) + ' rg)');
    FOwner.FOwner.SaveToStream('/AP <</N ' + IntToStr(FShow.PageID) + ' 0 R >> ');
    FOwner.FOwner.SaveToStream(CalcActions + '>>');
    FOwner.FOwner.CloseHObj;
    FOwner.FOwner.CloseObj;
  finally
    FShow.Free;
  end;
end;

{ TPDFRadioButton }

constructor TPDFRadioButton.Create(AOwner: TPDFPage; AName: string);
var
  I: Integer;
  F: Boolean;
begin
  inherited Create(AOwner, AName);
  FExportValue := '';
  FColor := clWhite;
  F := False;
  for I := 0 to FOwner.FOwner.FRadioGroups.Count - 1 do
    if UpperCase(AName) = UpperCase(TPDFRadioGroup(FOwner.FOwner.FRadioGroups[I]).FName) then
    begin
      FRG := TPDFRadioGroup(FOwner.FOwner.FRadioGroups[I]);
      F := True;
      Break;
    end;
  if not F then
    FRG := FOwner.FOwner.CreateRadioGroup(AName);
  FRG.FButtons.Add(Self);
  ExportValue := '';
end;

procedure TPDFRadioButton.Paint;
var
  x, y, z: array[0..3] of Byte;
  i: Integer;
begin
  I := ColorToRGB(FFont.Color);
  Move(i, x[0], 4);
  i := ColorToRGB(FColor);
  Move(i, z[0], 4);
  i := ColorToRGB(FBorderColor);
  Move(i, y[0], 4);
  with FCheck do
  begin
    Width := abs(FRight - FLeft);
    Height := abs(FBottom - FTop);
    SetLineWidth(1);
    SetRGBColorFill(z[0] / 255, z[1] / 255, z[2] / 255);
    SetRGBColorStroke(y[0] / 255, y[1] / 255, y[2] / 255);
    Circle(Width / 2, Height / 2, Height / 2 - 0.5);
    FillAndStroke;
    SetRGBColorFill(x[0] / 255, X[1] / 255, X[2] / 255);
    Circle(Width / 2, Height / 2, Height / 4 - 0.5);
    Fill;
    BeginText;
    SetActiveFont('ZapfDingbats', [], 10);
    FFN := FOwner.FFonts.FLast.AliasName;
    EndText;
  end;
  with FUncheck do
  begin
    Width := abs(FRight - FLeft);
    Height := abs(FBottom - FTop);
    SetLineWidth(1);
    SetRGBColorFill(z[0] / 255, z[1] / 255, z[2] / 255);
    SetRGBColorStroke(y[0] / 255, y[1] / 255, y[2] / 255);
    Circle(Width / 2, Height / 2, Height / 2 - 0.5);
    FillAndStroke;
  end;
end;

procedure TPDFRadioButton.Save;
var
  i: Integer;
begin
  FCheck := TPDFPage.Create(FOwner.FOwner);
  try
    FCheck.FIsForm := True;
    FUnCheck := TPDFPage.Create(FOwner.FOwner);
    try
      FUnCheck.FIsForm := True;
      Paint;
      FCheck.Save;
      FUnCheck.Save;
      for i := 0 to FCheck.FLinkedFont.Count - 1 do
        if FOwner.FOwner.FAcroForm.FFonts.IndexOf(FCheck.FLinkedFont[i]) = -1 then
          FOwner.FOwner.FAcroForm.FFonts.Add(FCheck.FLinkedFont[i]);
      FOwner.FOwner.StartObj(AnnotID);
      FOwner.FOwner.SaveToStream('/Type /Annot');
      FOwner.FOwner.SaveToStream('/Subtype /Widget');
      FOwner.FOwner.SaveToStream('/Rect [' + IntToStr(Round(FLeft)) + ' ' + IntToStr(FBottom) +
        ' ' + IntToStr(FRight) + ' ' + IntToStr(FTop) + ']');
      FOwner.FOwner.SaveToStream('/P ' + IntToStr(FOwner.PageID) + ' 0 R');
      if FChecked then FOwner.FOwner.SaveToStream('/AS /' + FExportValue) else FOwner.FOwner.SaveToStream('/AS /Off');
      FOwner.FOwner.SaveToStream('/MK <</CA (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, 'l')) + ') ', False);
      FOwner.FOwner.SaveToStream('/AC (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, '��')) + ')/RC (' +
        EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled, FOwner.FOwner.FKey, AnnotID, '��')) + ')', False);
      FOwner.FOwner.SaveToStream('/BC [' + FormatFloat(GetRValue(FBorderColor) / 255) + ' ' +
        FormatFloat(GetGValue(FBorderColor) / 255) + ' ' + FormatFloat(GetBValue(FBorderColor) / 255) + ' ]', False);
      FOwner.FOwner.SaveToStream('/BG [' + FormatFloat(GetRValue(FColor) / 255) + ' ' +
        FormatFloat(GetGValue(FColor) / 255) + ' ' + FormatFloat(GetBValue(FColor) / 255) + ' ]', False);
      FOwner.FOwner.SaveToStream('>>');
      FOwner.FOwner.SaveToStream('/DA (' + EscapeSpecialChar(EnCodeString(FOwner.FOwner.FProtectionEnabled,
        FOwner.FOwner.FKey, AnnotID, '/' + FFN + ' 0')) + ' Tf ' +
        FormatFloat(GetRValue(FFont.Color) / 255) + ' ' +
        FormatFloat(GetGValue(FFont.Color) / 255) + ' ' + FormatFloat(GetBValue(FFont.Color) / 255) + ' rg)');
      FOwner.FOwner.SaveToStream('/F ' + IntToStr(CalcFlags));
      FOwner.FOwner.SaveToStream('/Parent ' + IntToStr(FRG.GroupID) + ' 0 R');
      FOwner.FOwner.SaveToStream('/AP <</N << /' + FExportValue + ' ' + IntToStr(FCheck.PageID) + ' 0 R ', False);
      FOwner.FOwner.SaveToStream('/Off  ' + IntToStr(FUnCheck.PageID) + ' 0 R >> ', False);
      FOwner.FOwner.SaveToStream('/D << /' + FName + ' ' + IntToStr(FCheck.PageID) + ' 0 R ', False);
      FOwner.FOwner.SaveToStream('/Off  ' + IntToStr(FUnCheck.PageID) + ' 0 R >> ', False);
      FOwner.FOwner.SaveToStream('>>');
      FOwner.FOwner.SaveToStream('/H /T');
      FOwner.FOwner.SaveToStream(CalcActions + '>>');
      FOwner.FOwner.CloseHObj;
      FOwner.FOwner.CloseObj;
    finally
      FUnCheck.Free;
    end;
  finally
    FCheck.Free;
  end;
end;

procedure TPDFRadioButton.SetExportValue(const Value: string);
var
  I: Integer;
  WS: string;
begin
  WS := ReplStr(Value, ' ', '_');
  if WS = '' then
    if FExportValue <> '' then
      raise TPDFException.Create(SCannotSetEmptyExportValue) else
    FExportValue := FName + IntToStr(FRG.FButtons.Count) else
    for I := 0 to FRG.FButtons.Count - 1 do
      if UpperCase(TPDFRadioButton(FRG.FButtons[I]).FName) = UpperCase(WS) then
        raise TPDFException.Create(SExportValuePresent);
  FExportValue := WS;
end;

{ TPDFRadioGroup }

constructor TPDFRadioGroup.Create(AOwner: TPDFDocument; Name: string);
begin
  FOwner := AOwner;
  FName := Name;
  FButtons := TPDFControls.Create;
end;

destructor TPDFRadioGroup.Destroy;
begin
  FButtons.Free;
  inherited;
end;

procedure TPDFRadioGroup.Save;
var
  I: Integer;
begin
  FOwner.FAcroForm.FRadioGroups.Add(Self);
  FOwner.StartObj(GroupID);
  FOwner.SaveToStream('/FT /Btn');
  FOwner.SaveToStream('/T (' + EscapeSpecialChar(EnCodeString(FOwner.FProtectionEnabled, FOwner.FKey, GroupID, FName)) + ')');
  for I := 0 to FButtons.Count - 1 do
    if TPDFRadioButton(FButtons[I]).FChecked then
    begin
      FOwner.SaveToStream('/V /' + TPDFRadioButton(FButtons[I]).FExportValue);
      FOwner.SaveToStream('/DV /' + TPDFRadioButton(FButtons[I]).FExportValue);
      Break;
    end;
  FOwner.SaveToStream('/Kids [', False);
  for I := 0 to FButtons.Count - 1 do FOwner.SaveToStream(IntToStr(TPDFRadioButton(FButtons[I]).AnnotID) + ' 0 R ', False);
  FOwner.SaveToStream(']');
  I := 0;
  if TPDFRadioButton(FButtons[0]).FReadOnly then i := i or 1;
  if TPDFRadioButton(FButtons[0]).FRequired then i := i or 2;
  if FButtons.Count <> 1 then I := I or (1 shl 14);
  I := I or (1 shl 15);
  FOwner.SaveToStream('/Ff ' + IntToStr(I));
  FOwner.CloseHObj;
  FOwner.CloseObj;
end;

initialization
  EmbedFontFilesToPDF:= true;

end.


