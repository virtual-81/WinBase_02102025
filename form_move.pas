{$a-}
unit form_move;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls,

  data,
  SysFont,
  MyStrings,

  MyLanguage,
  ctrl_language;

type
  TMoveShootersDialog = class(TForm)
    lbGroups: TListBox;
    btnOk: TButton;
    btnCancel: TButton;
    lPrompt: TLabel;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fData: TData;
    fGroups: array of TGroupItem;
    fSourceGroup: TGroupItem;
    fShooter: TShooterItem;
    function get_Group: TGroupItem;
    procedure set_Group(const Value: TGroupItem);
    procedure set_Shooter(const Value: TShooterItem);
    procedure UpdateValues;
    procedure UpdateLanguage;
    procedure UpdateFonts;
  public
    property Group: TGroupItem read get_Group write set_Group;
    property Shooter: TShooterItem read fShooter write set_Shooter;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

{ TMoveShootersDialog }

function TMoveShootersDialog.Execute: boolean;
begin
  Result:= ShowModal= mrOk;
end;

procedure TMoveShootersDialog.FormCreate(Sender: TObject);
begin
  lPrompt.Left:= 16;
  lPrompt.Top:= 16;
  lbGroups.Left:= 16;
  UpdateLanguage;
  UpdateFonts;
  Width:= Screen.Width div 3;
  Height:= Screen.Height div 2;
  Position:= poScreenCenter;
end;

procedure TMoveShootersDialog.FormResize(Sender: TObject);
begin
  lPrompt.Width:= ClientWidth-32;
  lbGroups.Top:= lPrompt.Top+lPrompt.Height+2;
  lbGroups.Width:= ClientWidth-32;
  btnOk.Top:= ClientHeight-16-btnOk.Height;
  btnCancel.Top:= btnOk.Top;
  btnCancel.Left:= ClientWidth-16-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;
  lbGroups.Height:= btnOk.Top-8-lbGroups.Top;
end;

function TMoveShootersDialog.get_Group: TGroupItem;
begin
  if lbGroups.ItemIndex>= 0 then
    Result:= fGroups [lbGroups.ItemIndex]
  else
    Result:= nil;
end;

procedure TMoveShootersDialog.set_Group(const Value: TGroupItem);
begin
  // ��� ������ ���������� ���������� ������
  fSourceGroup:= Value;
  fData:= fSourceGroup.Data;
  fShooter:= nil;
  UpdateValues;
  FormResize (self);
end;

procedure TMoveShootersDialog.set_Shooter(const Value: TShooterItem);
begin
  // ���������� ����������
  if Value= nil then
    exit;
  fSourceGroup:= Value.Group;
  fShooter:= Value;
  fData:= fShooter.Data;
  UpdateValues;
  FormResize (self);
end;

procedure TMoveShootersDialog.UpdateFonts;
var
  w,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  w:= Canvas.TextWidth (btnOk.Caption);
  i:= Canvas.TextWidth (btnCancel.Caption);
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w+32;
  btnCancel.ClientWidth:= w+32;
  btnOk.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnCancel.Height:= btnOk.Height;
end;

procedure TMoveShootersDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TMoveShootersDialog.UpdateValues;
var
  w,w1,i,c: integer;
  g: TGroupItem;
begin
  SetLength (fGroups,0);
  lbGroups.Clear;
  for i:= 0 to fData.Groups.Count-1 do
    begin
      g:= fData.Groups [i];
      if g<> fSourceGroup then
        begin
          lbGroups.Items.Add (g.Name);
          SetLength (fGroups,Length (fGroups)+1);
          fGroups [Length (fGroups)-1]:= g;
        end;
    end;
  if lbGroups.Count> 0 then
    lbGroups.ItemIndex:= 0;
  if fShooter<> nil then
    lPrompt.Caption:= format (Language ['MoveShooterPrompt'],[fShooter.SurnameAndName])
  else
    lPrompt.Caption:= Language ['MoveMarkedPrompt'];
  c:= SubStrCount (lPrompt.Caption,#10);
  w:= 0;
  for i:= 1 to c do
    begin
      w1:= Canvas.TextWidth (substr (lPrompt.Caption,#10,i));
      if w1> w then
        w:= w1;
    end;
  lPrompt.ClientWidth:= w;
  lPrompt.ClientHeight:= Canvas.TextHeight ('Mg')*c;
  Constraints.MinHeight:= Height-ClientHeight+16+lPrompt.Height+lbGroups.Height-lbGroups.ClientHeight+lbGroups.ItemHeight*5+8+btnOk.Height+16;
  w:= lPrompt.Width+32;
  w1:= 16+btnOk.Width+8+btnCancel.Width+16;
  if w1> w then
    w:= w1;
  Constraints.MinWidth:= Width-ClientWidth+w+1;
  Position:= poScreenCenter;
end;

end.


