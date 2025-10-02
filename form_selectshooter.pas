unit form_selectshooter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language, Vcl.StdCtrls;

type
  TSelectEventShooterDialog = class(TForm)
    lbShooters: TListBox;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure lbShootersDblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    fEvent: TStartListEventItem;
    function get_Shooter: TStartListEventShooterItem;
    procedure set_Shooter(const Value: TStartListEventShooterItem);
    procedure set_Event(const Value: TStartListEventItem);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    function Execute: boolean;
    property Event: TStartListEventItem read fEvent write set_Event;
    property Shooter: TStartListEventShooterItem read get_Shooter write set_Shooter;
  end;

function SelectEventShooter (AOwner: TComponent; AShooter: TStartListEventShooterItem): TStartListEventShooterItem;

implementation

function SelectEventShooter (AOwner: TComponent; AShooter: TStartListEventShooterItem): TStartListEventShooterItem;
var
  d: TSelectEventShooterDialog;
begin
  d:= TSelectEventShooterDialog.Create (AOwner);
  d.Shooter:= AShooter;
  if d.Execute then
    Result:= d.Shooter
  else
    Result:= AShooter;
  d.Free;
end;

{$R *.dfm}

function TSelectEventShooterDialog.Execute: boolean;
begin
  Result:= ShowModal= mrOk;
end;

procedure TSelectEventShooterDialog.FormCreate(Sender: TObject);
begin
  lbShooters.Top:= 0;
  lbShooters.Left:= 0;
  UpdateLanguage;
  UpdateFonts;
  Width:= Screen.Width div 2;
  Height:= Screen.Height div 2;
  Position:= poScreenCenter;
end;

procedure TSelectEventShooterDialog.FormResize(Sender: TObject);
begin
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnCancel.Top:= ClientHeight-btnCancel.Height;
  btnOk.Top:= btnCancel.Top;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;
  lbShooters.Width:= ClientWidth;
  lbShooters.Height:= btnOk.Top-8-lbShooters.Top;
end;

function TSelectEventShooterDialog.get_Shooter: TStartListEventShooterItem;
begin
  if lbShooters.ItemIndex>= 0 then
    Result:= fEvent.Shooters.Items [lbShooters.ItemIndex]
  else
    Result:= nil;
end;

procedure TSelectEventShooterDialog.lbShootersDblClick(Sender: TObject);
begin
  if (lbShooters.ItemIndex>= 0) then
    btnOk.Click;
end;

procedure TSelectEventShooterDialog.set_Event(const Value: TStartListEventItem);
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  lbShooters.Clear;
  fEvent:= Value;
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      sh:= fEvent.Shooters.Items [i];
      lbShooters.Items.Add (sh.Shooter.SurnameAndName);
    end;
end;

procedure TSelectEventShooterDialog.set_Shooter(const Value: TStartListEventShooterItem);
begin
  if Value.StartEvent<> fEvent then
    Event:= Value.StartEvent;
  lbShooters.ItemIndex:= Value.Index;
end;

procedure TSelectEventShooterDialog.UpdateFonts;
var
  w,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbShooters.Canvas.Font:= self.Font;
  lbShooters.ItemHeight:= lbShooters.Canvas.TextHeight ('Mg')+4;
  btnOk.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnCancel.ClientWidth:= w;
  btnOk.ClientWidth:= w;
  btnCancel.ClientHeight:= btnOk.ClientHeight;
  Constraints.MinWidth:= Width-ClientWidth+btnOk.Width+btnCancel.Width+16;
  Constraints.MinHeight:= Height-ClientHeight+btnOk.Height+8+lbShooters.Height-lbShooters.ClientHeight+
    lbShooters.ItemHeight*6;
end;

procedure TSelectEventShooterDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

end.

