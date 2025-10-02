{$a-}
unit form_selectevent;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

type
  TSelectEventDialog = class(TForm)
    lbEvents: TListBox;
    btnCancel: TButton;
    btnOk: TButton;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbEventsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lbEventsDblClick(Sender: TObject);
  private
    fData: TData;
    fShortWidth: integer;
    procedure set_Data(const Value: TData);
    function get_Event: TEventItem;
    procedure set_Event(const Value: TEventItem);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    property Data: TData read fData write set_Data;
    function Execute: boolean;
    property Event: TEventItem read get_Event write set_Event;
  end;

implementation

{$R *.dfm}

{ TSelectEventDialog }

function TSelectEventDialog.Execute: boolean;
begin
  Result:= ShowModal= mrOk;
end;

function TSelectEventDialog.get_Event: TEventItem;
begin
  if lbEvents.ItemIndex>= 0 then
    Result:= fData.Events.Items [lbEvents.ItemIndex]
  else
    Result:= nil;
end;

procedure TSelectEventDialog.set_Data(const Value: TData);
var
  i,w: integer;
  e: TEventItem;
begin
  fData:= Value;
  lbEvents.Clear;
  lbEvents.Canvas.Font.Style:= [fsBold];
  fShortWidth:= 0;
  for i:= 0 to fData.Events.Count-1 do
    begin
      e:= fData.Events.Items [i];
      lbEvents.Items.Add (e.Name);
      w:= lbEvents.Canvas.TextWidth (e.ShortName);
      if w> fShortWidth then
        fShortWidth:= w;
    end;
  inc (fShortWidth,lbEvents.Canvas.TextWidth (' - '));
  if lbEvents.Count> 0 then
    lbEvents.ItemIndex:= 0;
end;

procedure TSelectEventDialog.set_Event(const Value: TEventItem);
begin
  lbEvents.ItemIndex:= Value.Index;
end;

procedure TSelectEventDialog.UpdateFonts;
var
  w,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbEvents.Canvas.Font:= self.Font;
  lbEvents.ItemHeight:= lbEvents.Canvas.TextHeight ('Mg')+4;
  btnOk.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnCancel.ClientWidth:= w;
  btnOk.ClientWidth:= w;
  btnCancel.ClientHeight:= btnOk.ClientHeight;
  Constraints.MinWidth:= Width-ClientWidth+btnOk.Width+btnCancel.Width+16;
  Constraints.MinHeight:= Height-ClientHeight+btnOk.Height+8+lbEvents.Height-lbEvents.ClientHeight+
    lbEvents.ItemHeight*6;
end;

procedure TSelectEventDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TSelectEventDialog.FormCreate(Sender: TObject);
begin
  lbEvents.Top:= 0;
  lbEvents.Left:= 0;
  UpdateLanguage;
  UpdateFonts;
  Width:= Screen.Width div 2;
  Height:= Screen.Height div 2;
  Position:= poScreenCenter;
end;

procedure TSelectEventDialog.FormResize(Sender: TObject);
begin
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnCancel.Top:= ClientHeight-btnCancel.Height;
  btnOk.Top:= btnCancel.Top;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;
  lbEvents.Width:= ClientWidth;
  lbEvents.Height:= btnOk.Top-8-lbEvents.Top;
end;

procedure TSelectEventDialog.lbEventsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  e: TEventItem;
begin
  with lbEvents.Canvas do
    begin
      FillRect (Rect);
      e:= fData.Events.Items [Index];
      Font.Style:= [fsBold];
      TextOut (Rect.Left+2,Rect.Top+2,e.ShortName);
      Font.Style:= [];
      TextOut (Rect.Left+fShortWidth+2,Rect.Top+2,e.Name);
    end;
end;

procedure TSelectEventDialog.lbEventsDblClick(Sender: TObject);
begin
  if (lbEvents.ItemIndex>= 0) then
    btnOk.Click;
end;

end.

