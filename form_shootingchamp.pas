unit form_shootingchamp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs,

  SysFont,
  ctrl_language,

  Data, Vcl.StdCtrls;

type
  TShootingChampionshipDetails = class(TForm)
    lChamp: TLabel;
    cbChamp: TComboBox;
    cbOther: TCheckBox;
    lName: TLabel;
    edtName: TEdit;
    lCountry: TLabel;
    edtCountry: TEdit;
    lTown: TLabel;
    edtTown: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormResize(Sender: TObject);
    procedure cbOtherClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fData: TData;
    procedure UpdateLanguage;
    procedure UpdateFonts;
  public
    function Execute: boolean;
    function Championship: TChampionshipItem;
    function ChampionshipName: string;
    function Country: string;
    function Town: string;
    procedure SetData (AData: TData);
    procedure SetChampionship (AChampionship: TShootingChampionshipItem);
  end;

implementation

{$R *.dfm}

{ TShootingChampionshipDetails }

procedure TShootingChampionshipDetails.cbOtherClick(Sender: TObject);
begin
  if cbOther.Checked then
    begin
      cbChamp.Enabled:= false;
      lChamp.Enabled:= false;
      edtName.Enabled:= true;
      lName.Enabled:= true;
    end
  else
    begin
      if (cbChamp.ItemIndex< 0) and (fData.Championships.Count> 0) then
        cbChamp.ItemIndex:= 0;
      cbChamp.Enabled:= true;
      lChamp.Enabled:= true;
      edtName.Enabled:= false;
      lName.Enabled:= false;
    end;
end;

function TShootingChampionshipDetails.Championship: TChampionshipItem;
begin
  if not cbOther.Checked then
    Result:= fData.Championships.Items [cbChamp.ItemIndex]
  else
    Result:= nil;
end;

function TShootingChampionshipDetails.ChampionshipName: string;
begin
  if cbOther.Checked then
    Result:= edtName.Text
  else
    Result:= '';
end;

function TShootingChampionshipDetails.Country: string;
begin
  Result:= edtCountry.Text;
end;

function TShootingChampionshipDetails.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TShootingChampionshipDetails.FormCreate(Sender: TObject);
begin
  fData:= nil;
  Width:= Screen.Width div 2;
  if Width< 480 then
    Width:= 480;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TShootingChampionshipDetails.FormResize(Sender: TObject);
begin
  cbChamp.Width:= ClientWidth-cbChamp.Left;
  edtName.Width:= ClientWidth-edtName.Left;
  edtCountry.Width:= ClientWidth-edtCountry.Left;
  edtTown.Width:= ClientWidth-edtTown.Left;
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-16-btnOk.Width;
end;

procedure TShootingChampionshipDetails.SetChampionship (AChampionship: TShootingChampionshipItem);
begin
  if AChampionship<> nil then
    begin
      if AChampionship.Championship<> nil then
        cbChamp.ItemIndex:= AChampionship.Championship.Index
      else
        cbChamp.ItemIndex:= -1;
      cbOther.Checked:= (AChampionship.Championship= nil);
      edtName.Text:= AChampionship.ChampionshipName;
      edtCountry.Text:= AChampionship.Country;
      edtTown.Text:= AChampionship.Town;
    end
  else
    begin
      cbChamp.ItemIndex:= 0;
      cbOther.Checked:= false;
      edtName.Text:= '';
      edtCountry.Text:= '';
      edtTown.Text:= '';
    end;
  cbOtherClick (self);
end;

procedure TShootingChampionshipDetails.SetData(AData: TData);
var
  i: integer;
begin
  fData:= AData;
  cbChamp.Clear;
  for i:= 0 to fData.Championships.Count-1 do
    cbChamp.Items.Add (fData.Championships.Items [i].Name);
end;

function TShootingChampionshipDetails.Town: string;
begin
  Result:= edtTown.Text;
end;

procedure TShootingChampionshipDetails.UpdateFonts;
var
  w,y,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;

  w:= lChamp.Width;
  if lName.Width> w then
    w:= lName.Width;
  if lCountry.Width> w then
    w:= lCountry.Width;
  if lTown.Width> w then
    w:= lTown.Width;

  y:= 0;
  cbChamp.Left:= w+8;
  cbChamp.Top:= y;
  lChamp.Left:= w-lChamp.Width;
  lChamp.Top:= cbChamp.Top+(cbChamp.Height-lChamp.Height) div 2;
  inc (y,cbChamp.Height+8);

  cbOther.Left:= w+8;
  cbOther.Top:= y;
  cbOther.ClientHeight:= Canvas.TextHeight ('Mg');
  cbOther.ClientWidth:= Canvas.TextWidth (cbOther.Caption)+cbOther.Height*2;
  inc (y,cbOther.Height+8);

  edtName.Left:= w+8;
  edtName.Top:= y;
  lName.Left:= w-lName.Width;
  lName.Top:= edtName.Top+(edtName.Height-lName.Height) div 2;
  inc (y,edtName.Height+8);

  edtCountry.Left:= w+8;
  edtCountry.Top:= y;
  lCountry.Left:= w-lCountry.Width;
  lCountry.Top:= edtCountry.Top+(edtCountry.Height-lCountry.Height) div 2;
  inc (y,edtCountry.Height+8);

  edtTown.Left:= w+8;
  edtTown.Top:= y;
  lTown.Left:= w-lTown.Width;
  lTown.Top:= edtTown.Top+(edtTown.Height-lTown.Height) div 2;
  inc (y,edtTown.Height+8);

  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w;
  btnCancel.ClientWidth:= w;
  btnOk.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnCancel.ClientHeight:= btnOk.ClientHeight;

  btnOk.Top:= y;
  btnCancel.Top:= btnOk.Top;

  ClientHeight:= btnOk.Top+btnOk.Height;
end;

procedure TShootingChampionshipDetails.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

end.

