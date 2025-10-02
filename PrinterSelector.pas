unit PrinterSelector;

interface

uses
  Winapi.Windows,System.Classes,Vcl.StdCtrls,Vcl.ComCtrls,Vcl.Printers,Winapi.Messages,Vcl.Controls,System.SysUtils,Vcl.Forms,Vcl.Dialogs;

type
  TPrinterSelector= class (TGroupBox)
  private
    lPrinter: TLabel;
    cbPrinter: TComboBox;
    lCopies: TLabel;
    edtCopies: TEdit;
    udCopies: TUpDown;
    lPages: TLabel;
    edtPages: TEdit;
    fShowCopies,fShowPages: boolean;
    fOldFontChange: TNotifyEvent;
    function get_Pages: string;
    procedure set_Pages(const Value: string);
    function get_Copies: integer;
    procedure set_Copies(const Value: integer);
    procedure set_ShowPages(const Value: boolean);
    procedure set_ShowCopies(const Value: boolean);
    function get_PagesCaption: string;
    procedure set_PagesCaption(const Value: string);
    function get_CopiesCaption: string;
    procedure set_CopiesCaption(const Value: string);
    function get_PrinterCaption: string;
    procedure set_PrinterCaption(const Value: string);
    procedure Rearrange;
    procedure OnFontChanged (Sender: TObject);
    procedure cbPrinterChanged (Sender: TObject);
  protected
    procedure Resize; override;
    procedure SetParent (AParent: TWinControl); override;
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    property PrinterCaption: string read get_PrinterCaption write set_PrinterCaption;
    property CopiesCaption: string read get_CopiesCaption write set_CopiesCaption;
    property PagesCaption: string read get_PagesCaption write set_PagesCaption;
    property ShowCopies: boolean read fShowCopies write set_ShowCopies;
    property ShowPages: boolean read fShowPages write set_ShowPages;
    property Copies: integer read get_Copies write set_Copies;
    property Pages: string read get_Pages write set_Pages;
  end;

implementation

uses Vcl.Graphics;

{ TPrinterSelector }

constructor TPrinterSelector.Create(AOwner: TComponent);
begin
  inherited;
  fShowCopies:= true;
  fShowPages:= true;
  lPrinter:= TLabel.Create (self);
  lPrinter.Name:= 'lPrinter';
  lPrinter.Parent:= self;
  lPrinter.Caption:= '&Printer:';
  lPrinter.FocusControl:= cbPrinter;
  lPrinter.AutoSize:= true;
  cbPrinter:= TComboBox.Create (self);
  cbPrinter.Parent:= self;
  cbPrinter.Style:= csDropDownList;
  cbPrinter.OnChange:= cbPrinterChanged;
  lCopies:= TLabel.Create (self);
  lCopies.Name:= 'lCopies';
  lCopies.Parent:= self;
  lCopies.Caption:= '&Copies:';
  lCopies.FocusControl:= edtCopies;
  lCopies.AutoSize:= true;
  edtCopies:= TEdit.Create (self);
  edtCopies.Parent:= self;
  edtCopies.Width:= 75;
  udCopies:= TUpDown.Create (self);
  udCopies.Parent:= self;
  udCopies.Min:= 1;
  udCopies.Max:= 100;
  udCopies.Associate:= edtCopies;
  udCopies.Position:= 1;
  lPages:= TLabel.Create (self);
  lPages.Name:= 'lPages';
  lPages.Parent:= self;
  lPages.Caption:= 'Pa&ges:';
  lPages.FocusControl:= edtPages;
  lPages.AutoSize:= true;
  edtPages:= TEdit.Create (self);
  edtPages.Parent:= self;
  edtPages.Text:= '';
  edtPages.Width:= 128;
  fOldFontChange:= Font.OnChange;
  Font.OnChange:= OnFontChanged;
  Rearrange;
end;

destructor TPrinterSelector.Destroy;
begin
  inherited;
end;

function TPrinterSelector.get_Copies: integer;
begin
  Result:= udCopies.Position;
end;

function TPrinterSelector.get_CopiesCaption: string;
begin
  Result:= lCopies.Caption;
end;

function TPrinterSelector.get_Pages: string;
begin
  Result:= edtPages.Text;
end;

function TPrinterSelector.get_PagesCaption: string;
begin
  Result:= lPages.Caption;
end;

function TPrinterSelector.get_PrinterCaption: string;
begin
  Result:= lPrinter.Caption;
end;

procedure TPrinterSelector.OnFontChanged(Sender: TObject);
begin
  if Assigned (fOldFontChange) then
    fOldFontChange (Sender);
  Rearrange;
end;

procedure TPrinterSelector.cbPrinterChanged(Sender: TObject);
begin
  Printer.PrinterIndex:= cbPrinter.ItemIndex;
end;

procedure TPrinterSelector.Rearrange;
var
  y: integer;
  x: integer;
  cr: TRect;
begin
  if Parent= nil then
    exit;
  Canvas.Font:= Font;
  cr:= ClientRect;
  AdjustClientRect (cr);
  y:= cr.Top+8;
  x:= lPrinter.Width;
  if (fShowCopies) and (lCopies.Width> x) then
    x:= lCopies.Width;
  if (fShowPages) and (lPages.Width> x) then
    x:= lPages.Width;
  x:= x+16+cr.Left;
  cbPrinter.Top:= y;
  lPrinter.Top:= cbPrinter.Top+(cbPrinter.Height-lPrinter.Height) div 2;
  lPrinter.Left:= x-lPrinter.Width;
  cbPrinter.Left:= x+8;
  y:= y+cbPrinter.Height+8;
  edtCopies.Top:= y;
  if fShowCopies then
    begin
      lCopies.Top:= edtCopies.Top+(edtCopies.Height-lCopies.Height) div 2;
      lCopies.Left:= x-lCopies.Width;
      edtCopies.Left:= x+8;
      udCopies.Left:= edtCopies.Left+edtCopies.Width;
      udCopies.Top:= edtCopies.Top;
      udCopies.Height:= edtCopies.Height;
      y:= y+edtCopies.Height+8;
    end;
  if fShowPages then
    begin
      edtPages.Top:= y;
      lPages.Top:= edtPages.Top+(edtPages.Height-lPages.Height) div 2;
      lPages.Left:= x-lPages.Width;
      edtPages.Left:= x+8;
      y:= y+edtPages.Height+8;
    end;
  y:= y+8;
  if y<> ClientHeight then
    ClientHeight:= y;
end;

procedure TPrinterSelector.Resize;
var
  cr: TRect;
begin
  inherited;
  cr:= ClientRect;
  AdjustClientRect (cr);
  cbPrinter.Width:= cr.Right-16-cbPrinter.Left;
end;

procedure TPrinterSelector.SetParent(AParent: TWinControl);
begin
  inherited;
  if Parent<> nil then
    begin
      cbPrinter.Items.AddStrings (Printer.Printers);
      cbPrinter.ItemIndex:= Printer.PrinterIndex;
    end;
end;

procedure TPrinterSelector.set_Copies(const Value: integer);
begin
  udCopies.Position:= Value;
end;

procedure TPrinterSelector.set_CopiesCaption(const Value: string);
begin
  lCopies.Caption:= Value;
  Rearrange;
end;

procedure TPrinterSelector.set_Pages(const Value: string);
begin
  edtPages.Text:= Value;
end;

procedure TPrinterSelector.set_PagesCaption(const Value: string);
begin
  lPages.Caption:= Value;
  Rearrange;
end;

procedure TPrinterSelector.set_PrinterCaption(const Value: string);
begin
  lPrinter.Caption:= Value;
  Rearrange;
end;

procedure TPrinterSelector.set_ShowCopies(const Value: boolean);
begin
  fShowCopies:= Value;
  lCopies.Visible:= fShowCopies;
  edtCopies.Visible:= fShowCopies;
  udCopies.Visible:= fShowCopies;
  Rearrange;
end;

procedure TPrinterSelector.set_ShowPages(const Value: boolean);
begin
  fShowPages:= Value;
  lPages.Visible:= fShowPages;
  edtPages.Visible:= fShowPages;
  Rearrange;
end;

end.

