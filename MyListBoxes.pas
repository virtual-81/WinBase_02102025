unit MyListBoxes;

interface

uses
  Winapi.Windows,Vcl.Graphics,Winapi.Messages,System.SysUtils,Vcl.Menus,
  System.Classes,Vcl.Controls,Vcl.StdCtrls,Vcl.ComCtrls,Vcl.Forms;

type
  THeadedListBox= class;
  THeadedListBoxSection= class;
  THListBox= class;

  THeaderListBoxDrawItem= procedure (Sender: THeadedListBox; ListBox: THListBox; Index: integer; Rect: TRect; Section: THeadedListBoxSection; State: TOwnerDrawState) of object;

  THListBox= class (TListBox)
  private
    fOnHScroll: TScrollEvent;
    procedure WMHScroll (var M: TMessage); message WM_HSCROLL;
    procedure WMEraseBkGnd (var M: TMessage); message WM_ERASEBKGND;
  public
    property OnHScroll: TScrollEvent read fOnHScroll write fOnHScroll;
    procedure KeyDown (var Key: word; State: TShiftState); override;
    procedure KeyPress (var Key: char); override;
  end;

  THeadedListBoxSection= class (THeaderSection)
  private
    fFont: TFont;
    fHAlign: TAlignment;
    fHLB: THeadedListBox;
    procedure set_HAlign(const Value: TAlignment);
    procedure set_ListBox(const Value: THeadedListBox);
    procedure set_Font(const Value: TFont);
    procedure FontChange (Sender: TObject);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property Font: TFont read fFont write set_Font;
    property ListBox: THeadedListBox write set_ListBox;
    property Alignment: TAlignment read fHAlign write set_HAlign;
  end;

  THeadedListBox= class (TWinControl)
  private
    fHeader: THeaderControl;
    fListBox: THListBox;
    fOnDrawItem: THeaderListBoxDrawItem;
    fMaxItemHeight: integer;
    fItemExtraHeight: integer;
    fSectionTextLeft,fSectionTextRight: integer;
    function get_PopupMenu: TPopupMenu;
    procedure set_PopupMenu(const Value: TPopupMenu);
//    function get_OnKeyDown: TKeyEvent;
//    procedure set_OnKeyDown(const Value: TKeyEvent);
    function get_OnDblClick: TNotifyEvent;
    procedure set_OnDblClick(const Value: TNotifyEvent);
    function get_ItemIndex: integer;
    procedure set_ItemIndex(const Value: integer);
    procedure set_SectionTextRight(const Value: integer);
    procedure set_SectionTextLeft(const Value: integer);
    function get_Font: TFont;
    procedure set_Font(const Value: TFont);
    procedure set_ItemExtraHeight(const Value: integer);
    procedure OnSectionResize (Sender: THeaderControl; Section: THeaderSection);
    procedure OnCreateSectionClass (Sender: TCustomHeaderControl; var SectionClass: THeaderSectionClass);
    procedure OnHScroll (Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: integer);
    procedure UpdateItemHeight;
    procedure MeasureItem (Sender: TWinControl; Index: integer; var AHeight: integer);
    procedure OnFontChange (Sender: TObject);
    procedure WMEraseBkGnd (var M: TMessage); message WM_ERASEBKGND;
//    procedure AdjustHeaderHeight;
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    property ListBox: THListBox read fListBox;
    function AddSection (const Text: string): THeadedListBoxSection;
    procedure Resize; override;
    property OnDrawItem: THeaderListBoxDrawItem read fOnDrawItem write fOnDrawItem;
    procedure DrawItem (Sender: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState); virtual;
    procedure DrawItemSection (Index: integer; ARect: TRect; State: TOwnerDrawState; Section: THeadedListBoxSection; const Text: string); virtual;
    property ItemExtraHeight: integer read fItemExtraHeight write set_ItemExtraHeight;
    property Font: TFont read get_Font write set_Font;
    property SectionTextLeft: integer read fSectionTextLeft write set_SectionTextLeft;
    property SectionTextRight: integer read fSectionTextRight write set_SectionTextRight;
    property Header: THeaderControl read fHeader;
    property ItemIndex: integer read get_ItemIndex write set_ItemIndex;
    procedure Clear; virtual;
    property OnDblClick: TNotifyEvent read get_OnDblClick write set_OnDblClick;
//    property OnKeyDown: TKeyEvent read get_OnKeyDown write set_OnKeyDown;
    property PopupMenu: TPopupMenu read get_PopupMenu write set_PopupMenu;
  end;

implementation

{ THeadedListBox }

function THeadedListBox.AddSection(const Text: string): THeadedListBoxSection;
begin
  Result:= fHeader.Sections.Add as THeadedListBoxSection;
  Result.ListBox:= self;
  Result.Text:= Text;
end;

procedure THeadedListBox.AlignControls(AControl: TControl; var Rect: TRect);
var
  h: integer;
begin
  inherited;
  if Parent<> nil then
    begin
      h:= fHeader.Canvas.TextHeight ('Mg')+4;
      fHeader.ClientHeight:= h;
    end;
  fListBox.Top:= fHeader.Top+fHeader.Height;
end;

procedure THeadedListBox.Clear;
begin
  fListBox.Clear;
end;

constructor THeadedListBox.Create(AOwner: TComponent);
begin
  inherited;
  BevelKind:= bkTile;
  fHeader:= THeaderControl.Create (self);
  fHeader.Style:= hsButtons;
  fHeader.Left:= 0;
  fHeader.Top:= 0;
  fHeader.Parent:= self;
  fHeader.Align:= alNone;
  fHeader.OnSectionResize:= OnSectionResize;
  fHeader.OnCreateSectionClass:= OnCreateSectionClass;
  fListBox:= THListBox.Create (self);
  fListBox.Left:= 0;
  fListBox.Top:= fHeader.Top+fHeader.Height;
  fListBox.Parent:= self;
  fListBox.BorderStyle:= bsNone;
  fListBox.OnDrawItem:= DrawItem;
  fListBox.Style:= lbOwnerDrawVariable;
  fListBox.OnMeasureItem:= MeasureItem;
  fListBox.OnHScroll:= OnHScroll;
  fMaxItemHeight:= fListBox.ItemHeight;
  fItemExtraHeight:= 0;
  fSectionTextLeft:= 0;
  fSectionTextRight:= 0;
//  Font.OnChange:= OnFontChange;
end;

procedure THeadedListBox.DrawItemSection(Index: integer; ARect: TRect; State: TOwnerDrawState; Section: THeadedListBoxSection; const Text: string);
var
  r: TRect;
  x,y: integer;
  fc: TColor;
begin
  with fListBox.Canvas do
    begin
      if Section<> nil then
        begin
          r:= Rect (ARect.Left+Section.Left,ARect.Top,ARect.Left+Section.Right,ARect.Bottom);
          case Section.Alignment of
            taRightJustify: x:= r.Right-TextWidth (Text)-fSectionTextRight;
            taCenter: x:= (r.Left+r.Right-TextWidth (Text)) div 2;
          else
            x:= r.Left+fSectionTextLeft;
          end;
          fc:= Font.Color;
          Font:= Section.Font;
          Font.Color:= fc;
        end
      else
        begin
          r:= ARect;
          x:= r.Left+fSectionTextLeft;
        end;
      y:= r.Top+(fItemExtraHeight div 2);
      TextRect (r,x,y,Text);
    end;
end;

destructor THeadedListBox.Destroy;
begin
  fListBox.Free;
  fListBox:= nil;
  fHeader.Free;
  fHeader:= nil;
  inherited;
end;

procedure THeadedListBox.OnCreateSectionClass(Sender: TCustomHeaderControl; var SectionClass: THeaderSectionClass);
begin
  SectionClass:= THeadedListBoxSection;
end;

procedure THeadedListBox.OnFontChange(Sender: TObject);
begin
  fListBox.Font:= Font;
  fHeader.Font:= Font;
  fHeader.Canvas.Font:= Font;
  fMaxItemHeight:= -1;
  Invalidate;
end;

procedure THeadedListBox.DrawItem(Sender: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
var
  i: integer;
  s: THeadedListBoxSection;
  st,st1: string;
  p: integer;
begin
  if Index>= ListBox.Count then
    exit;
  if Assigned (fOnDrawItem) then
    begin
      fListBox.Canvas.Brush.Style:= bsSolid;
      fListBox.Canvas.FillRect (ARect);
      for i:= 0 to Header.Sections.Count-1 do
        begin
          s:= Header.Sections [i] as THeadedListBoxSection;
          fOnDrawItem (self,fListBox,Index,ARect,s,State);
        end;
    end
  else
    begin
      if Header.Sections.Count> 0 then
        s:= Header.Sections [0] as THeadedListBoxSection
      else
        s:= nil;
      st:= fListBox.Items [Index];
      with fListBox.Canvas do
        begin
          Brush.Style:= bsSolid;
          FillRect (ARect);
          while st<> '' do
            begin
              p:= pos (#9,st);
              if p= 0 then
                begin
                  DrawItemSection (Index,ARect,State,s,st);
                  exit;
                end;
              st1:= copy (st,1,p-1);
              DrawItemSection (Index,ARect,State,s,st1);
              if (s= nil) or (fHeader.Sections.Count<= s.Index+1) then
                exit;
              delete (st,1,p);
              s:= fHeader.Sections [s.Index+1] as THeadedListBoxSection;
            end;
        end;
    end;
end;

function THeadedListBox.get_Font: TFont;
begin
  Result:= inherited Font;
end;

function THeadedListBox.get_ItemIndex: integer;
begin
  Result:= ListBox.ItemIndex;
end;

function THeadedListBox.get_OnDblClick: TNotifyEvent;
begin
  Result:= fListBox.OnDblClick;
end;

{
function THeadedListBox.get_OnKeyDown: TKeyEvent;
begin
  Result:= fListBox.OnKeyDown;
end;
}

function THeadedListBox.get_PopupMenu: TPopupMenu;
begin
  Result:= fListBox.PopupMenu;
end;

procedure THeadedListBox.MeasureItem(Sender: TWinControl; Index: integer; var AHeight: integer);
begin
  if fMaxItemHeight< 0 then
    UpdateItemHeight;
  AHeight:= fMaxItemHeight+fItemExtraHeight;
end;

procedure THeadedListBox.OnHScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: integer);
begin
  fHeader.Left:= -ScrollPos;
  fHeader.Width:= ClientWidth-fHeader.Left;
end;

procedure THeadedListBox.OnSectionResize(Sender: THeaderControl; Section: THeaderSection);
var
  si: TScrollInfo;
begin
  fListBox.ScrollWidth:= fHeader.Sections [fHeader.Sections.Count-1].Right;
  fListBox.Invalidate;
  si.cbSize:= sizeof (si);
  si.fMask:= SIF_POS;
  if GetScrollInfo (fListBox.Handle,SB_HORZ,si) then
    OnHScroll (self,scEndScroll,si.nPos);
end;

procedure THeadedListBox.Resize;
var
  si: TScrollInfo;
  sw: integer;
begin
  inherited;
  fHeader.Width:= ClientWidth-fHeader.Left;
  fListBox.Width:= ClientWidth;
  fListBox.Height:= ClientHeight-fListBox.Top;
  if fHeader.Sections.Count> 0 then
    begin
      sw:= fHeader.Sections [fHeader.Sections.Count-1].Right;
      if sw> fListBox.ClientWidth then
        begin
          fListBox.ScrollWidth:= sw;
          si.cbSize:= sizeof (si);
          si.fMask:= SIF_POS;
          if GetScrollInfo (fListBox.Handle,SB_HORZ,si) then
            begin
              OnHScroll (fListBox,scPosition,si.nPos);
            end;
        end;
    end;
end;

{
procedure THeadedListBox.SetParent(AParent: TWinControl);
begin
  inherited;
  if AParent<> nil then
    AdjustHeaderHeight;
end;
}

procedure THeadedListBox.set_Font(const Value: TFont);
begin
  inherited Font.Assign (Font);
  OnFontChange (self);
end;

procedure THeadedListBox.set_ItemExtraHeight(const Value: integer);
begin
  fItemExtraHeight:= Value;
  Refresh;
end;

procedure THeadedListBox.set_ItemIndex(const Value: integer);
begin
  ListBox.ItemIndex:= Value;
end;

procedure THeadedListBox.set_OnDblClick(const Value: TNotifyEvent);
begin
  fListBox.OnDblClick:= Value;
end;

{
procedure THeadedListBox.set_OnKeyDown(const Value: TKeyEvent);
begin
  fListBox.OnKeyDown:= Value;
end;
}

procedure THeadedListBox.set_PopupMenu(const Value: TPopupMenu);
begin
  fListBox.PopupMenu:= Value;
end;

procedure THeadedListBox.set_SectionTextLeft(const Value: integer);
begin
  fSectionTextLeft:= Value;
  ListBox.Invalidate;
end;

procedure THeadedListBox.set_SectionTextRight(const Value: integer);
begin
  fSectionTextRight:= Value;
  ListBox.Invalidate;
end;

procedure THeadedListBox.UpdateItemHeight;
var
  h,h1: integer;
  i: integer;
  s: THeadedListBoxSection;
begin
  with fListBox.Canvas do
    begin
      h:= TextHeight ('Mg');
      for i:= 0 to fHeader.Sections.Count-1 do
        begin
          s:= fHeader.Sections [i] as THeadedListBoxSection;
          Font:= s.Font;
          h1:= TextHeight ('Mg');
          if h1> h then
            h:= h1;
        end;
    end;
  fMaxItemHeight:= h;
end;

procedure THeadedListBox.WMEraseBkGnd(var M: TMessage);
begin
  M.Result:= LRESULT (false);
end;

{ THeadedListBoxSection }

constructor THeadedListBoxSection.Create(ACollection: TCollection);
begin
  inherited;
  fHLB:= nil;
  fFont:= TFont.Create;
  fFont.OnChange:= FontChange;
  fHAlign:= taLeftJustify;
end;

destructor THeadedListBoxSection.Destroy;
begin
  inherited;
end;

procedure THeadedListBoxSection.FontChange(Sender: TObject);
begin
  if fHLB<> nil then
    begin
      fHLB.fMaxItemHeight:= -1;
      fHLB.Refresh;
    end;
end;

procedure THeadedListBoxSection.set_Font(const Value: TFont);
begin
  fFont.Assign (Value);
  if fHLB<> nil then
    fHLB.ListBox.Invalidate;
end;

procedure THeadedListBoxSection.set_HAlign(const Value: TAlignment);
begin
  fHAlign:= Value;
  if fHLB<> nil then
    fHLB.ListBox.Invalidate;
end;

procedure THeadedListBoxSection.set_ListBox(const Value: THeadedListBox);
begin
  fHLB:= Value;
  if fHLB<> nil then
    begin
      Font:= fHLB.ListBox.Font;
    end;
end;

{ THListBox }

procedure THListBox.KeyDown(var Key: word; State: TShiftState);
begin
  if (Parent is THeadedListBox) then
    (Parent as THeadedListBox).KeyDown (Key,State);
  inherited;
end;

procedure THListBox.KeyPress (var Key: char);
begin
  if (Parent is THeadedListBox) then
    (Parent as THeadedListBox).KeyPress (Key);
  inherited;
end;

procedure THListBox.WMEraseBkGnd(var M: TMessage);
var
  r,r1: TRect;
  dc: HDC;
begin
  r:= ClientRect;
  dc:= M.wParam;
  Canvas.Brush.Style:= bsSolid;
  Canvas.Brush.Color:= Color;
  if Count> 0 then
    begin
      r1:= ItemRect (Count-1);
      r.Top:= r1.Bottom;
    end;
  Winapi.Windows.FillRect (dc,r,Canvas.Brush.Handle);
  M.Result:= LRESULT (true);
end;

procedure THListBox.WMHScroll (var M: TMessage);
var
  p: integer;
  c: word;
  si: TScrollInfo;
begin
  inherited;
  if Assigned (fOnHScroll) then
    begin
      c:= LoWord (M.WParam);
      si.cbSize:= sizeof (si);
      si.fMask:= SIF_POS;
      if GetScrollInfo (Handle,SB_HORZ,si) then
        begin
          p:= si.nPos;
        end
      else
        begin
          p:= HiWord (M.WParam);
        end;
      fOnHScroll (self,TScrollCode (c),p);
    end;
end;

end.

