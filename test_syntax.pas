unit test_syntax;

interface

type
  // Предварительные объявления
  TPDFOutlineNode = class;
  TPDFGoToPageAction = class;
  
  TPDFCanvas = class
  public
    Font: TFont;
    function TextWidth(const Text: string): Integer;
    procedure TextOut(X, Y: Integer; const Text: string);
    constructor Create;
    destructor Destroy; override;
  end;

  TPDFOutlines = class
  public
    constructor Create;
    function Add(Parent: TPDFOutlineNode; const Title: string; Action: TPDFGoToPageAction; Charset: Integer): TPDFOutlineNode;
  end;

  TPDFDocument = class
  private
    FFileName: string;
    FAutoLaunch: Boolean;
    FCurrentPage: Integer;
    FPageWidth: Double;
    FPageHeight: Double;
  public
    Canvas: TPDFCanvas;
    Outlines: TPDFOutlines;
    property FileName: string read FFileName write FFileName;
    property AutoLaunch: Boolean read FAutoLaunch write FAutoLaunch;
    property CurrentPage: Integer read FCurrentPage write FCurrentPage;
    property PageWidth: Double read FPageWidth write FPageWidth;
    property PageHeight: Double read FPageHeight write FPageHeight;
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Abort;
    procedure BeginDoc;
    procedure EndDoc;
    procedure NewPage;
  end;
  
  TPDFOutlineNode = class
  public
    Action: TObject;
  end;
  
  TPDFGoToPageAction = class
  public
    PageIndex: Integer;
    constructor Create;
  end;

implementation

uses Classes, Graphics;

constructor TPDFCanvas.Create;
begin
  inherited Create;
end;

end.
