{$a-}
unit form_prefered;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls,

  Data,
  SysFont,

  MyLanguage,
  ctrl_language;

type
  TPreferedEventsEditor = class(TForm)
    btnAdd: TButton;
    btnRemove: TButton;
    lbEvents: TListBox;
    lbPrefered: TListBox;
    lEvents: TLabel;
    lPrefered: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure lbPreferedClick(Sender: TObject);
    procedure lbEventsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    fGroup: TGroupItem;
    procedure set_Group(const Value: TGroupItem);
    procedure UpdateData;
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property Group: TGroupItem read fGroup write set_Group;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

procedure TPreferedEventsEditor.btnAddClick(Sender: TObject);
begin
  if fGroup.AddPrefered (fGroup.Data.Events.Items [lbEvents.ItemIndex])>= 0 then
    begin
      lbPrefered.Items.Add (fGroup.Data.Events.Items [lbEvents.ItemIndex].ShortName);
      btnAdd.Enabled:= false;
    end;
end;

procedure TPreferedEventsEditor.btnRemoveClick(Sender: TObject);
var
  idx: integer;
begin
  idx:= lbPrefered.ItemIndex;
  fGroup.DeletePrefered (idx);
  lbPrefered.Items.Delete (idx);
  if lbPrefered.Count> 0 then
    begin
      if idx>= lbPrefered.Count then
        dec (idx);
      lbPrefered.ItemIndex:= idx;
    end
  else
    btnRemove.Enabled:= false;
  lbEventsClick (lbEvents);
end;

function TPreferedEventsEditor.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TPreferedEventsEditor.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  lEvents.Left:= 0;
  lEvents.Top:= 0;
  lPrefered.Top:= 0;
  lbEvents.Left:= 0;
  UpdateFonts;
  Width:= Screen.Width div 2;
  Height:= Screen.Height div 2;
  Position:= poScreenCenter;
end;

procedure TPreferedEventsEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
  end;
end;

procedure TPreferedEventsEditor.FormResize(Sender: TObject);
begin
  lbEvents.Width:= (ClientWidth-btnAdd.Width-16) div 2;
  lEvents.Width:= lbEvents.Width;
  lbEvents.Height:= ClientHeight-lbEvents.Top;
  btnAdd.Left:= lbEvents.Left+lbEvents.Width+8;
  btnRemove.Left:= btnAdd.Left;
  lbPrefered.Left:= btnAdd.Left+btnAdd.Width+8;
  lPrefered.Left:= lbPrefered.Left;
  lbPrefered.Width:= ClientWidth-lbPrefered.Left;
  lPrefered.Width:= lbPrefered.Width;
  lbPrefered.Height:= ClientHeight-lbPrefered.Top;
end;

procedure TPreferedEventsEditor.lbEventsClick(Sender: TObject);
begin
  btnAdd.Enabled:= fGroup.Prefered (fGroup.Data.Events.Items [lbEvents.ItemIndex])< 0;
end;

procedure TPreferedEventsEditor.lbPreferedClick(Sender: TObject);
begin
  btnRemove.Enabled:= lbPrefered.ItemIndex>= 0;
end;

procedure TPreferedEventsEditor.set_Group(const Value: TGroupItem);
begin
  fGroup:= Value;
  UpdateData;
end;

procedure TPreferedEventsEditor.UpdateData;
var
  i: integer;
begin
  lbPrefered.Clear;
  for i:= 0 to fGroup.PreferedCount-1 do
    lbPrefered.Items.Add (fGroup.PreferedEvents [i].ShortName);
  lbEvents.Clear;
  for i:= 0 to fGroup.Data.Events.Count-1 do
    lbEvents.Items.Add (fGroup.Data.Events.Items [i].ShortName);
  if lbPrefered.Count> 0 then
    begin
      lbPrefered.ItemIndex:= 0;
    end
  else
    begin
      btnRemove.Enabled:= false;
    end;
  if lbEvents.Count> 0 then
    begin
      lbEvents.Enabled:= true;
      lbEvents.ItemIndex:= 0;
      lbEventsClick (lbEvents);
    end
  else
    begin
      lbEvents.Enabled:= false;
      btnAdd.Enabled:= false;
    end;
  Caption:= format (Language ['PreferedEventsEditor'],[fGroup.Name]);
end;

procedure TPreferedEventsEditor.UpdateFonts;
var
  bh: integer;
  w,w1: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbEvents.Top:= lEvents.Top+lEvents.Height+4;
  lbPrefered.Top:= lbEvents.Top;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnAdd.ClientHeight:= bh;
  btnRemove.ClientHeight:= bh;
  w:= Canvas.TextWidth (btnAdd.Caption);
  w1:= Canvas.TextWidth (btnRemove.Caption);
  if w1> w then
    w:= w1;
  btnAdd.ClientWidth:= w+24;
  btnAdd.Top:= lbEvents.Top+8;
  btnRemove.ClientWidth:= w+24;
  btnRemove.Top:= btnAdd.Top+btnAdd.Height+8;
  Constraints.MinWidth:= Width-ClientWidth+btnAdd.Width+16+lEvents.Width+8+lPrefered.Width+8;
end;

procedure TPreferedEventsEditor.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

end.

