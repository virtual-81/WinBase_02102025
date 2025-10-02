{$a-}
unit form_startinfo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Win.Registry,

  Data,
  SysFont,

  MyLanguage,
  ctrl_language;

type
  TStartInfoDialog = class(TForm)
    cbStartNumbers: TCheckBox;
    btnOk: TButton;
    btnCancel: TButton;
    lChamp: TLabel;
    cbChamp: TComboBox;
    gbSecretery: TGroupBox;
    gbPlace: TGroupBox;
    lTown: TLabel;
    cbTown: TComboBox;
    lRange: TLabel;
    cbRange: TComboBox;
    lSecretery: TLabel;
    cbSecretery: TComboBox;
    lCategory: TLabel;
    cbCategory: TComboBox;
    meName: TMemo;
    lTitle: TLabel;
    gbJury: TGroupBox;
    lJury: TLabel;
    lJuryCategory: TLabel;
    cbJury: TComboBox;
    cbJuryCategory: TComboBox;
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    fInfo: TStartListInfo;
    fMaxHistory: integer;
    procedure set_Info(const Value: TStartListInfo);
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure WMChangeLanguage (var Msg: TMessage); message WM_CHANGELANGUAGE;
  public
    { Public declarations }
    property Info: TStartListInfo read fInfo write set_Info;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

{ TStartInfoDialog }

function TStartInfoDialog.Execute: boolean;
begin
  Result:= false;
  if fInfo= nil then
    exit;
  Result:= (ShowModal= mrOk);
end;

procedure TStartInfoDialog.set_Info(const Value: TStartListInfo);
var
  i: integer;
  Reg: TRegistry;
begin
  fInfo:= Value;
  if fInfo= nil then
    raise Exception.Create ('no start info!');
  meName.Text:= fInfo.TitleText;
  cbTown.Clear;
  cbRange.Clear;
  cbSecretery.Clear;
  cbCategory.Clear;
  cbJury.Clear;
  cbJuryCategory.Clear;

  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
		if Reg.OpenKey ('\Software\007Soft\WinBASE\Starts', true) then
      begin
        if Reg.ValueExists ('Towns') then
          cbTown.Items.Text:= Reg.ReadString ('Towns');
        if Reg.ValueExists ('Ranges') then
          cbRange.Items.Text:= Reg.ReadString ('Ranges');
        if Reg.ValueExists ('MaxHistory') then
          fMaxHistory:= Reg.ReadInteger ('MaxHistory')
        else
          fMaxHistory:= 32;
        if Reg.ValueExists ('Secretery') then
          cbSecretery.Items.Text:= Reg.ReadString ('Secretery');
        if Reg.ValueExists ('Categories') then
          cbCategory.Items.Text:= Reg.ReadString ('Categories');
        if Reg.ValueExists ('Jury') then
          cbJury.Items.Text:= Reg.ReadString ('Jury');
        if Reg.ValueExists ('JuryCategories') then
          cbJuryCategory.Items.Text:= Reg.ReadString ('JuryCategories');
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;

  cbTown.Text:= fInfo.Town;
  cbRange.Text:= fInfo.ShootingRange;
  cbStartNumbers.Enabled:= fInfo.Root;
  cbStartNumbers.Checked:= fInfo.StartList.StartNumbers;
  cbChamp.Clear;
  for i:= 0 to fInfo.StartList.Data.Championships.Count-1 do
    cbChamp.Items.Add (fInfo.StartList.Data.Championships.Items [i].Name);
  if fInfo.Championship<> nil then
    cbChamp.ItemIndex:= fInfo.Championship.Index
  else
    cbChamp.Text:= fInfo.ChampionshipName;
  cbSecretery.Text:= fInfo.Secretery;
  cbCategory.Text:= fInfo.SecreteryCategory;
  cbJury.Text:= fInfo.Jury;
  cbJuryCategory.Text:= fInfo.JuryCategory;
end;

procedure TStartInfoDialog.UpdateFonts;
var
  bh: integer;
  w,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  bh:= Canvas.TextHeight ('Mg')+12;
  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnOk.ClientHeight:= bh;
  btnOk.ClientWidth:= w;
  btnCancel.ClientHeight:= bh;
  btnCancel.ClientWidth:= w;
  meName.Top:= lTitle.Top+lTitle.Height+2;
  meName.ClientHeight:= Canvas.TextHeight ('Mg')*3;
  cbTown.Font:= Font;

  w:= lTown.Width;
  i:= lRange.Width;
  if i> w then
    w:= i;
  lTown.Left:= 16+w-lTown.Width;
  lRange.Left:= 16+w-lRange.Width;
  cbTown.Left:= w+24;
  cbTown.Width:= gbPlace.ClientWidth-16-cbTown.Left;
  cbRange.Left:= w+24;
  cbRange.Width:= gbPlace.ClientWidth-16-cbRange.Left;

  w:= lSecretery.Width;
  i:= lCategory.Width;
  if i> w then
    w:= i;
  lSecretery.Left:= w+16-lSecretery.Width;
  lCategory.Left:= w+16-lCategory.Width;
  cbSecretery.Left:= w+24;
  cbCategory.Left:= w+24;

  w:= lJury.Width;
  i:= lJuryCategory.Width;
  if i> w then
    w:= i;
  lJury.Left:= w+16-lJury.Width;
  lJuryCategory.Left:= w+16-lJuryCategory.Width;
  cbJury.Left:= w+24;
  cbJuryCategory.Left:= w+24;

  Height:= Constraints.MinHeight;
end;

procedure TStartInfoDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
  meName.Hint:= Language ['StartInfoDialog.meName.Hint'];
  cbChamp.Hint:= Language ['StartInfoDialog.cbChamp.Hint'];
end;

procedure TStartInfoDialog.WMChangeLanguage(var Msg: TMessage);
begin
  UpdateLanguage;
  UpdateFonts;
  Resize;
end;

procedure TStartInfoDialog.btnOkClick(Sender: TObject);
var
  Reg: TRegistry;

  procedure Check (s: string; st: TStrings);
  var
    i: integer;
  begin
    for i:= 0 to st.Count-1 do
      if AnsiSameStr (s,st [i]) then
        exit;
    st.Insert (0,s);
    while st.Count> fMaxHistory do
      st.Delete (st.Count-1);
  end;

  function IndexOf (s: string; st: TStrings): integer;
  var
    i: integer;
  begin
    Result:= -1;
    for i:= 0 to st.Count-1 do
      if AnsiSameStr (s,st [i]) then
        begin
          Result:= i;
          exit;
        end;
  end;

var
  idx: integer;
begin
  fInfo.TitleText:= meName.Text;
  if (cbStartNumbers.Enabled) and (fInfo.Root) then
    fInfo.StartList.StartNumbers:= cbStartNumbers.Checked;
  fInfo.Town:= cbTown.Text;
  Check (cbTown.Text,cbTown.Items);
  fInfo.ShootingRange:= cbRange.Text;
  Check (cbRange.Text,cbRange.Items);
  if cbChamp.ItemIndex>= 0 then
    fInfo.Championship:= fInfo.StartList.Data.Championships.Items [cbChamp.ItemIndex]
  else
    begin
      idx:= IndexOf (cbChamp.Text,cbChamp.Items);
      if idx>= 0 then
        fInfo.Championship:= fInfo.StartList.Data.Championships.Items [idx]
      else
        fInfo.ChampionshipName:= cbChamp.Text;
    end;
  fInfo.Secretery:= cbSecretery.Text;
  Check (cbSecretery.Text,cbSecretery.Items);
  fInfo.SecreteryCategory:= cbCategory.Text;
  Check (cbCategory.Text,cbCategory.Items);
  fInfo.Jury:= cbJury.Text;
  Check (cbJury.Text,cbJury.Items);
  fInfo.JuryCategory:= cbJuryCategory.Text;
  Check (cbJuryCategory.Text,cbJuryCategory.Items);
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
		if Reg.OpenKey ('\Software\007Soft\WinBASE\Starts', true) then
      begin
        Reg.WriteString ('Towns',cbTown.Items.Text);
        Reg.WriteString ('Ranges',cbRange.Items.Text);
        Reg.WriteInteger ('MaxHistory',fMaxHistory);
        Reg.WriteString ('Secretery',cbSecretery.Items.Text);
        Reg.WriteString ('Categories',cbCategory.Items.Text);
        Reg.WriteString ('Jury',cbJury.Items.Text);
        Reg.WriteString ('JuryCategories',cbJuryCategory.Items.Text);
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure TStartInfoDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
  Width:= Round (Screen.Width*0.5);
  FormResize (self);
  Position:= poScreenCenter;
end;

procedure TStartInfoDialog.FormResize(Sender: TObject);
begin
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnCancel.Top:= ClientHeight-btnCancel.Height;
  btnOk.Top:= btnCancel.Top;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;

  gbJury.Width:= ClientWidth;
  cbJury.Width:= gbJury.ClientWidth-16-cbJury.Left;
  cbJuryCategory.Width:= gbJury.ClientWidth-16-cbJuryCategory.Left;
  if gbSecretery.Caption= '' then
    cbJury.Top:= 8
  else
    cbJury.Top:= 8+Canvas.TextHeight (gbJury.Caption);
  lJury.Top:= cbJury.Top+(cbJury.Height-lJury.Height) div 2;
  cbJuryCategory.Top:= cbJury.Top+cbJury.Height+8;
  lJuryCategory.Top:= cbJuryCategory.Top+(cbJuryCategory.Height-lJuryCategory.Height) div 2;
  gbJury.ClientHeight:= cbJuryCategory.Top+cbJuryCategory.Height+8;
  gbJury.Top:= btnOk.Top-8-gbJury.Height;

  gbSecretery.Width:= ClientWidth;
  cbSecretery.Width:= gbSecretery.ClientWidth-16-cbSecretery.Left;
  cbCategory.Width:= cbSecretery.Width;
  if gbSecretery.Caption= '' then
    cbSecretery.Top:= 8
  else
    cbSecretery.Top:= 8+Canvas.TextHeight (gbSecretery.Caption);
  lSecretery.Top:= cbSecretery.Top+(cbSecretery.Height-lSecretery.Height) div 2;
  cbCategory.Top:= cbSecretery.Top+cbSecretery.Height+8;
  lCategory.Top:= cbCategory.Top+(cbCategory.Height-lCategory.Height) div 2;
  gbSecretery.ClientHeight:= cbCategory.Top+cbCategory.Height+8;
  gbSecretery.Top:= gbJury.Top-8-gbSecretery.Height;

  gbPlace.Width:= ClientWidth;
  cbTown.Width:= gbPlace.ClientWidth-16-cbTown.Left;
  cbRange.Width:= cbTown.Width;
  if gbPlace.Caption= '' then
    cbTown.Top:= 8
  else
    cbTown.Top:= 8+Canvas.TextHeight (gbPlace.Caption);
  lTown.Top:= cbTown.Top+(cbTown.Height-lTown.Height) div 2;
  cbRange.Top:= cbTown.Top+cbTown.Height+8;
  lRange.Top:= cbRange.Top+(cbRange.Height-lRange.Height) div 2;
  gbPlace.ClientHeight:= cbRange.Top+cbRange.Height+8;
  gbPlace.Top:= gbSecretery.Top-8-gbPlace.Height;

  cbStartNumbers.Width:= ClientWidth;
  cbStartNumbers.Top:= gbPlace.Top-8-cbStartNumbers.Height;
  cbChamp.Width:= ClientWidth;
  cbChamp.Top:= cbStartNumbers.Top-8-cbChamp.Height;
  lChamp.Width:= ClientWidth;
  lChamp.Top:= cbChamp.Top-lChamp.Height-2;
  meName.Width:= ClientWidth;
  meName.Height:= lChamp.Top-8-meName.Top;
  Canvas.Font:= Font;
  if meName.ClientHeight< Canvas.TextHeight ('Mg')*4 then
    begin
      meName.ClientHeight:= Canvas.TextHeight ('Mg')*4;
      Constraints.MinHeight:= btnOk.Height+8+
        gbJury.Height+8+gbSecretery.Height+8+gbPlace.Height+8+
        cbStartNumbers.Height+8+cbChamp.Height+2+lChamp.Height+8+meName.Height+2+
        lTitle.Height+Height-ClientHeight;
    end;
end;

end.


