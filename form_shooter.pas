{$a-}
unit form_shooter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Menus, Buttons,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

// TODO: Исправить верстку формы

type
  TShooterDetailsDialog = class(TForm)
    lGender: TLabel;
    rbMale: TRadioButton;
    rbFemale: TRadioButton;
    pnlPhoto: TPanel;
    btnClose: TButton;
    OpenDialog1: TOpenDialog;
    cbQualification: TComboBox;
    lQualification: TLabel;
    edtRegionFull1: TEdit;
    edtRegionFull2: TEdit;
    edtDistrictAbbr: TEdit;
    edtDistrictFull: TEdit;
    lDistrict: TLabel;
    edtRegionAbbr2: TEdit;
    edtRegionAbbr1: TEdit;
    lRegion2: TLabel;
    lRegion1: TLabel;
    edtBirthYear: TEdit;
    edtBirthDate: TEdit;
  edtBirthFull: TEdit;
    lBYear: TLabel;
    lBDate: TLabel;
  lBFull: TLabel;
    lSurname: TLabel;
    lName: TLabel;
    edtName: TEdit;
    lStepName: TLabel;
    edtStepName: TEdit;
    lISSFId: TLabel;
    edtISSFID: TEdit;
    lTown: TLabel;
    edtTown: TEdit;
    lSportClub: TLabel;
    edtSportClub: TEdit;
    PageControl1: TPageControl;
    tsMain: TTabSheet;
    tsAdd: TTabSheet;
    edtSurname: TEdit;
    edtPhone: TEdit;
    tsRemarks: TTabSheet;
    meRemarks: TMemo;
    lPhone: TLabel;
    meWeapon: TMemo;
    lWeapon: TLabel;
    meAddress: TMemo;
    lAddress: TLabel;
    meCoaches: TMemo;
    lCoaches: TLabel;
    mePassport: TMemo;
    lPassport: TLabel;
    sbDeletePhoto: TSpeedButton;
    sbAddPhoto: TSpeedButton;
    sbPrevImage: TSpeedButton;
    sbNextImage: TSpeedButton;
    lSociety: TLabel;
    cbSociety: TComboBox;
    procedure edtDistrictAbbrChange(Sender: TObject);
    procedure edtRegionAbbr2Change(Sender: TObject);
    procedure edtRegionAbbr1Change(Sender: TObject);
    procedure pnlPhotoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OnControlKeyPress(Sender: TObject; var Key: Char);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure btnDeletePhotoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnNextImageClick(Sender: TObject);
    procedure btnPrevImageClick(Sender: TObject);
    procedure btnAddPhotoClick(Sender: TObject);
    // внутренняя логика нормализации ввода
    procedure NameExitNormalize(Sender: TObject);
    procedure SurnameExitNormalize(Sender: TObject);
  private
    { Private declarations }
    fShooter: TShooterItem;
    fImage: TImage;
    fImageIndex: integer;
    procedure LoadValues;
    procedure SaveValues;
    procedure DeletePhoto;
    procedure set_Shooter(const Value: TShooterItem);
    procedure NextImage;
    procedure PrevImage;
    procedure SetImage (index: integer);
    procedure AddNewImage;
    procedure OpenImage (index: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure PhotoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PhotoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure edtBirthFullExit(Sender: TObject);
    function ProperCaseName(const s: string): string;
    function TryParseDDMMYYYY(const s: string; out D: TDateTime): boolean;
  function ShouldSkipControl(Control: TWinControl): Boolean;
  public
    { Public declarations }
    property Shooter: TShooterItem read fShooter write set_Shooter;
    function Execute: boolean;
    procedure Resize; override;
  end;

implementation

uses System.Math, System.Character;

{$R *.dfm}

{ TShooterDetailsDialog }

function TShooterDetailsDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TShooterDetailsDialog.LoadValues;
var
  j: integer;
begin
  // Фамилия: отображаем без внешних пробелов и в ВЕРХНЕМ регистре
  edtSurname.Text:= Trim(fShooter.Surname).ToUpper;
	edtName.Text:= fShooter.Name;
	edtStepName.Text:= fShooter.StepName;
	edtISSFID.Text:= fShooter.ISSFID;
  // старые поля отображаем как read-only, без фокуса
  edtBirthYear.ReadOnly := True;
  edtBirthYear.TabStop := False;
  edtBirthDate.ReadOnly := True;
  edtBirthDate.TabStop := False;
  edtBirthYear.Text:= fShooter.BirthYearStr;
  edtBirthDate.Text:= fShooter.BirthDateStr;
  edtBirthFull.Text:= fShooter.BirthFullStr;
  case fShooter.Gender of
    Male: begin
      rbMale.Checked:= true;
      rbFemale.Checked:= false;
    end;
    Female: begin
      rbMale.Checked:= false;
      rbFemale.Checked:= true;
    end;
  end;
  cbQualification.Clear;
  cbQualification.Items.Add (Language ['NoQual']);
  for j:= 0 to fShooter.Data.Qualifications.Count-1 do
    cbQualification.Items.Add (fShooter.Data.Qualifications.Items [j].Name);
  if fShooter.Qualification<> nil then
    cbQualification.ItemIndex:= fShooter.Qualification.Index+1
  else
    cbQualification.ItemIndex:= 0;
  edtRegionAbbr1.Text:= fShooter.RegionAbbr1;
  // Аббревиатуры регионов/округа всегда показываем в верхнем регистре
  edtRegionAbbr1.Text:= Trim(fShooter.RegionAbbr1).ToUpper;
  edtRegionFull1.Text:= fShooter.RegionFull1;
  edtRegionAbbr2.Text:= Trim(fShooter.RegionAbbr2).ToUpper;
  edtRegionFull2.Text:= fShooter.RegionFull2;
  edtDistrictAbbr.Text:= Trim(fShooter.DistrictAbbr).ToUpper;
  edtDistrictFull.Text:= fShooter.DistrictFull;
	edtTown.Text:= fShooter.Town;
  cbSociety.Clear;
  cbSociety.Items.Add (Language ['NoSociety']);
  for j:= 0 to fShooter.Data.Societies.Count-1 do
    cbSociety.Items.Add (fShooter.Data.Societies.Items [j].Name);
  if fShooter.SportSociety= nil then
    cbSociety.ItemIndex:= 0
  else
    cbSociety.ItemIndex:= fShooter.SportSociety.Index+1;
	edtSportClub.Text:= fShooter.SportClub;
	mePassport.Text:= fShooter.Passport;
	edtPhone.Text:= fShooter.Phone;
	meAddress.Text:= fShooter.Address;
	meCoaches.Text:= fShooter.Coaches;
	meWeapon.Text:= fShooter.Weapons;
	meRemarks.Text:= fShooter.Memo;
  fImageIndex:= 0;
  if fShooter.ImagesCount> 0 then
    SetImage (0)
  else
    SetImage (-1);
  Caption:= format (Language ['ShooterDetailsDialog'],[fShooter.SurnameAndName]);
  // Фоллбэк для подписей, если нет строк локализации (в некоторых сборках возвращается плейсхолдер в квадратных скобках)
  if (Trim(lBFull.Caption)='') or ((Length(lBFull.Caption) >= 2) and (lBFull.Caption[1] = '[') and (lBFull.Caption[Length(lBFull.Caption)] = ']')) then
    lBFull.Caption := 'Дата рождения';
  if (Trim(lBYear.Caption)='') or ((Length(lBYear.Caption) >= 2) and (lBYear.Caption[1] = '[') and (lBYear.Caption[Length(lBYear.Caption)] = ']')) then
    lBYear.Caption := 'Год';
  if (Trim(lBDate.Caption)='') or ((Length(lBDate.Caption) >= 2) and (lBDate.Caption[1] = '[') and (lBDate.Caption[Length(lBDate.Caption)] = ']')) then
    lBDate.Caption := 'Дата';
end;

procedure TShooterDetailsDialog.SaveValues;
begin
  // Страховка: нормализуем регистр Имя/Отчество перед сохранением
  edtName.Text := ProperCaseName(edtName.Text);
  edtStepName.Text := ProperCaseName(edtStepName.Text);

  fShooter.Surname:= Trim(edtSurname.Text).ToUpper;
  fShooter.Name:= Trim (edtName.Text);
  fShooter.StepName:= Trim (edtStepName.Text);
	fShooter.ISSFID:= Trim (edtISSFID.Text);
  // Старые поля только для чтения; сохраняем из нового комбинированного поля
  fShooter.BirthFullStr := Trim(edtBirthFull.Text);
  if rbMale.Checked then
    fShooter.Gender:= Male
  else if rbFemale.Checked then
    fShooter.Gender:= Female;
  if cbQualification.ItemIndex> 0 then
    fShooter.Qualification:= fShooter.Data.Qualifications.Items [cbQualification.ItemIndex-1]
  else
    fShooter.Qualification:= nil;
  fShooter.RegionAbbr1:= Trim (edtRegionAbbr1.Text);
  fShooter.Data.Regions [fShooter.RegionAbbr1]:= Trim (edtRegionFull1.Text);
  fShooter.RegionAbbr2:= Trim (edtRegionAbbr2.Text);
  fShooter.Data.Regions [fShooter.RegionAbbr2]:= Trim (edtRegionFull2.Text);
  fShooter.DistrictAbbr:= Trim (edtDistrictAbbr.Text);
  fShooter.Data.Districts [fShooter.DistrictAbbr]:= Trim (edtDistrictFull.Text);
	fShooter.Town:= Trim (edtTown.Text);
  if cbSociety.ItemIndex< 1 then
    fShooter.SportSociety:= nil
  else
    fShooter.SportSociety:= fShooter.Data.Societies.Items [cbSociety.ItemIndex-1];
	fShooter.SportClub:= Trim (edtSportClub.Text);
	fShooter.Passport:= Trim (mePassport.Text);
	fShooter.Phone:= Trim (edtPhone.Text);
	fShooter.Address:= Trim (meAddress.Text);
	fShooter.Coaches:= Trim (meCoaches.Text);
	fShooter.Weapons:= Trim (meWeapon.Text);
	fShooter.Memo:= Trim (meRemarks.Text);
end;

procedure TShooterDetailsDialog.set_Shooter(const Value: TShooterItem);
begin
  fShooter:= Value;
  LoadValues;
end;

procedure TShooterDetailsDialog.UpdateFonts;
var
  w,i,mh: integer;
  tw: integer;
  dy: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;

  // Поиск максимальной ширины меток
  w:= lSurname.Width;
  if lName.Width> w then
    w:= lName.Width;
  if lStepName.Width> w then
    w:= lStepName.Width;
  if lBFull.Width> w then
    w:= lBFull.Width;
  if lGender.Width> w then
    w:= lGender.Width;
  if lISSFId.Width> w then
    w:= lISSFId.Width;
  if lRegion1.Width> w then
    w:= lRegion1.Width;
  if lRegion2.Width> w then
    w:= lRegion2.Width;
  if lDistrict.Width> w then
    w:= lDistrict.Width;
  if lTown.Width> w then
    w:= lTown.Width;
  if  lSociety.Width> w then
    w:= lSociety.Width;

  // Ограничим максимальную ширину левой колонки ярлыков,
  // чтобы не появлялось слишком много пустого места слева
  // Используем более разумное ограничение на основе типичной длины подписей
  if w > Canvas.TextWidth('Регион дополнительный') + 20 then
    w := Canvas.TextWidth('Регион дополнительный') + 20;

  lSurname.Top:= edtSurname.Top+(edtSurname.Height-lSurname.Height) div 2;
  lSurname.Left:= w-lSurname.Width;
  edtSurname.Left:= w+8;
  edtName.Top:= edtSurname.Top+edtSurname.Height+2;
  lName.Top:= edtName.Top+(edtName.Height-lName.Height) div 2;
  lName.Left:= w-lName.Width;
  edtName.Left:= w+8;
  edtStepName.Top:= edtName.Top+edtName.Height+2;
  lStepName.Top:= edtStepName.Top+(edtStepName.Height-lStepName.Height) div 2;
  lStepName.Left:= w-lStepName.Width;
  edtStepName.Left:= w+8;
  edtBirthFull.Top:= edtStepName.Top+edtStepName.Height+4;
  lBFull.Top:= edtBirthFull.Top+(edtBirthFull.Height-lBFull.Height) div 2;
  lBFull.Left:= w-lBFull.Width;
  edtBirthFull.Left:= w+8;
  edtBirthFull.ClientWidth:= Canvas.TextWidth (' 00.00.0000 ');
  
  // Старые поля располагаем правее с достаточными отступами
  edtBirthYear.Top:= edtBirthFull.Top;
  edtBirthYear.Left:= edtBirthFull.Left+edtBirthFull.Width+48; // увеличим отступ
  edtBirthYear.ClientWidth:= Canvas.TextWidth (' 0000 ');
  lBYear.Left:= edtBirthYear.Left-12-lBYear.Width; // увеличим отступ от поля
  lBYear.Top:= edtBirthYear.Top+(edtBirthYear.Height-lBYear.Height) div 2; // выровняем по центру поля
  
  edtBirthDate.Top:= edtBirthFull.Top;
  edtBirthDate.ClientWidth:= Canvas.TextWidth (' 00.00 ');
  edtBirthDate.Left := edtBirthYear.Left+edtBirthYear.Width+48; // увеличим отступ
  lBDate.Left:= edtBirthDate.Left-12-lBDate.Width; // увеличим отступ от поля
  lBDate.Top:= edtBirthDate.Top+(edtBirthDate.Height-lBDate.Height) div 2; // выровняем по центру поля
  rbMale.Top:= edtBirthYear.Top+edtBirthYear.Height+4;
  rbFemale.Top:= rbMale.Top;
  lGender.Left:= w-lGender.Width;
  rbMale.Left:= w+8;
  rbMale.ClientHeight:= Canvas.TextHeight ('Mg');
  rbMale.ClientWidth:= Canvas.TextWidth (rbMale.Caption)+rbMale.Height+16;
  rbFemale.Left:= rbMale.Left+rbMale.Width+16;
  rbFemale.ClientHeight:= Canvas.TextHeight ('Mg');
  rbFemale.ClientWidth:= Canvas.TextWidth (rbFemale.Caption)+rbFemale.Height+16;
  lGender.Top:= rbMale.Top+(rbMale.Height-lGender.Height) div 2;
  edtISSFID.Top:= rbMale.Top+rbMale.Height+4;
  lISSFId.Top:= edtISSFID.Top+(edtISSFID.Height-lISSFId.Height) div 2;
  lISSFId.Left:= w-lISSFId.Width;
  edtISSFID.Left:= w+8;
  cbQualification.Top:= edtISSFID.Top;
  lQualification.Top:= cbQualification.Top+(cbQualification.Height-lQualification.Height) div 2;
  lQualification.Left:= edtISSFID.Left+edtISSFID.Width+24;
  cbQualification.Left:= lQualification.Left+lQualification.Width+8;
  edtRegionAbbr1.Top:= edtISSFID.Top+edtISSFID.Height+4;
  lRegion1.Top:= edtRegionAbbr1.Top+(edtRegionAbbr1.Height-lRegion1.Height) div 2;
  lRegion1.Left:= w-lRegion1.Width;
  edtRegionAbbr1.Left:= w+8;
  edtRegionAbbr1.ClientWidth:= Canvas.TextWidth ('WWWWWW');
  edtRegionFull1.Top:= edtRegionAbbr1.Top;
  edtRegionFull1.Left:= edtRegionAbbr1.Left+edtRegionAbbr1.Width+4;
  edtRegionAbbr2.Top:= edtRegionAbbr1.Top+edtRegionAbbr1.Height+2;
  lRegion2.Top:= edtRegionAbbr2.Top+(edtRegionAbbr2.Height-lRegion2.Height) div 2;
  lRegion2.Left:= w-lRegion2.Width;
  edtRegionAbbr2.Left:= w+8;
  edtRegionAbbr2.Width:= edtRegionAbbr1.Width;
  edtRegionFull2.Left:= edtRegionFull1.Left;
  edtRegionFull2.Top:= edtRegionAbbr2.Top;
  edtDistrictAbbr.Top:= edtRegionAbbr2.Top+edtRegionAbbr2.Height+2;
  lDistrict.Top:= edtDistrictAbbr.Top+(edtDistrictAbbr.Height-lDistrict.Height) div 2;
  lDistrict.Left:= w-lDistrict.Width;
  edtDistrictAbbr.Left:= w+8;
  edtDistrictAbbr.Width:= edtRegionAbbr2.Width;
  edtDistrictFull.Left:= edtRegionFull2.Left;
  edtDistrictFull.Top:= edtDistrictAbbr.Top;
  edtTown.Top:= edtDistrictAbbr.Top+edtDistrictAbbr.Height+4;
  lTown.Top:= edtTown.Top+(edtTown.Height-lTown.Height) div 2;
  lTown.Left:= w-lTown.Width;
  edtTown.Left:= w+8;
  cbSociety.Top:= edtTown.Top+edtTown.Height+4;
  edtSportClub.Top:= cbSociety.Top;

  lSociety.Top:= cbSociety.Top+(cbSociety.Height-lSociety.Height) div 2;
  lSociety.Left:= w-lSociety.Width;
  cbSociety.Left:= w+8;

  lSportClub.Top:= edtSportClub.Top+(edtSportClub.Height-lSportClub.Height) div 2;
  lSportClub.Left:=cbSociety.Left+cbSociety.Width+24;
  edtSportClub.Left:= lSportClub.Left+lSportClub.Width+8;

  tw:= w+8+edtISSFID.Width+24+lQualification.Width+8+cbQualification.Width+16;
  i:= w+8+rbMale.Width+16+rbFemale.Width+16;
  if i> tw then
    tw:= i;
  // Обновим расчет с новыми отступами между полями даты (48 вместо 32)
  i:= w+8+edtBirthFull.Width+48+edtBirthYear.Width+48+edtBirthDate.Width+16;
  if i> tw then
    tw:= i;

  PageControl1.Constraints.MinWidth:= PageControl1.Width+tw+pnlPhoto.Width-tsMain.ClientWidth;
  PageControl1.Height:= PageControl1.Height+edtSportClub.Top+edtSportClub.Height-tsMain.ClientHeight;
  Constraints.MinWidth:= Width-ClientWidth+PageControl1.Constraints.MinWidth;

  // Кнопки
  btnClose.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnClose.ClientWidth:= Canvas.TextWidth (btnClose.Caption)+32;
  btnClose.Top:= PageControl1.Top+PageControl1.Height+8;

  // По высоте по содержимому
  Constraints.MinHeight:= Height-ClientHeight+btnClose.Top+btnClose.Height;
  Constraints.MaxHeight:= Constraints.MinHeight;

  w:= lPhone.Width;
  if lAddress.Width> w then
    w:= lAddress.Width;
  if lPassport.Width> w then
    w:= lPassport.Width;
  if lCoaches.Width> w then
    w:= lCoaches.Width;
  if lWeapon.Width> w then
    w:= lWeapon.Width;

  dy:= (edtPhone.Height-lPhone.Height) div 2;
  lPhone.Left:= w-lPhone.Width;
  edtPhone.Left:= w+8;
  lPhone.Top:= edtPhone.Top+dy;
  meAddress.Top:= edtPhone.Top+edtPhone.Height+4;
  mh:= (tsAdd.ClientHeight-meAddress.Top-12) div 4;
  lAddress.Top:= meAddress.Top+dy;
  lAddress.Left:= w-lAddress.Width;
  meAddress.Left:= w+8;
  meAddress.Height:= mh;
  lPassport.Left:= w-lPassport.Width;
  mePassport.Top:= meAddress.Top+meAddress.Height+4;
  lPassport.Top:= mePassport.Top+dy;
  mePassport.Height:= mh;
  mePassport.Left:= w+8;
  lCoaches.Left:= w-lCoaches.Width;
  meCoaches.Left:= w+8;
  meCoaches.Top:= mePassport.Top+mePassport.Height+4;
  meCoaches.Height:= mh;
  lCoaches.Top:= meCoaches.Top+dy;
  lWeapon.Left:= w-lWeapon.Width;
  meWeapon.Left:= w+8;
  meWeapon.Top:= meCoaches.Top+meCoaches.Height+4;
  meWeapon.Height:= mh;
  lWeapon.Top:= meWeapon.Top+dy;
end;

procedure TShooterDetailsDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TShooterDetailsDialog.pnlPhotoClick(Sender: TObject);
begin
  if fShooter.ImagesCount> 0 then
    OpenImage (fImageIndex)
  else
    AddNewImage;
end;

procedure TShooterDetailsDialog.DeletePhoto;
begin
  if fShooter.ImagesCount< 1 then
    exit;
  if MessageDlg (Language ['DeletePhotoPrompt'],mtConfirmation,[mbYes,mbNo],0)<> mrYes then
    exit;
  fShooter.DeleteImage (fImageIndex);
  if fImageIndex< fShooter.ImagesCount then
    SetImage (fImageIndex)
  else if fShooter.ImagesCount> 0 then
    SetImage (fImageIndex-1)
  else
    begin
      SetImage (-1);
      fImage.Free;
      fImage:= nil;
    end;
end;

procedure TShooterDetailsDialog.edtDistrictAbbrChange(Sender: TObject);
begin
  edtDistrictFull.Text:= fShooter.Data.Districts [edtDistrictAbbr.Text];
end;

procedure TShooterDetailsDialog.edtRegionAbbr1Change(Sender: TObject);
begin
  edtRegionFull1.Text:= fShooter.Data.Regions [edtRegionAbbr1.Text];
end;

procedure TShooterDetailsDialog.edtRegionAbbr2Change(Sender: TObject);
begin
  edtRegionFull2.Text:= fShooter.Data.Regions [edtRegionAbbr2.Text];
end;

procedure TShooterDetailsDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveValues;
end;

procedure TShooterDetailsDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  NextControl: TWinControl;
  GoForward: Boolean;
  FocusedCtrl: TWinControl;
begin
  // Унифицированная навигация: Enter/Space (в TEdit) = вперед; стрелки = вперед/назад; с пропуском ряда полей
  FocusedCtrl := ActiveControl;
  if Key = VK_RETURN then
    Key := VK_RIGHT;

  if (Key = VK_SPACE) and (FocusedCtrl is TEdit) and not (ssShift in Shift) then
  begin
    // Тримминг для Фамилия/Имя перед переходом
    if SameText(FocusedCtrl.Name, 'edtSurname') or SameText(FocusedCtrl.Name, 'edtName') then
      TEdit(FocusedCtrl).Text := Trim(TEdit(FocusedCtrl).Text);
    Key := VK_RIGHT;
  end;

  if (Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN]) and not (FocusedCtrl is TMemo) then
  begin
    GoForward := not (Key in [VK_LEFT, VK_UP]);
    // Двигаемся по таб-цепочке, пропуская указанные контролы
    var startCtrl := ActiveControl;
    var moved := False;
    var tries := 0;
    repeat
      Inc(tries);
      var before := ActiveControl;
      SelectNext(ActiveControl, GoForward, True);
      moved := ActiveControl <> before;
      if not moved then Break;
    until (not ShouldSkipControl(ActiveControl)) or (tries > 64) or (ActiveControl = startCtrl);

    if moved and (not ShouldSkipControl(ActiveControl)) then
    begin
      Key := 0; // событие обработано
      Exit;
    end;
  end;
end;

procedure TShooterDetailsDialog.OnControlKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
    end;
  end;
end;



procedure TShooterDetailsDialog.N2Click(Sender: TObject);
begin
  btnClose.Click;
end;

procedure TShooterDetailsDialog.N4Click(Sender: TObject);
begin
  DeletePhoto;
end;

procedure TShooterDetailsDialog.N5Click(Sender: TObject);
begin
  pnlPhotoClick (self);
end;

procedure TShooterDetailsDialog.btnDeletePhotoClick(Sender: TObject);
begin
  DeletePhoto;
end;

procedure TShooterDetailsDialog.FormCreate(Sender: TObject);
begin
  fImageIndex:= 0;
  fImage:= nil;
  fShooter:= nil;
  edtSurname.Top:= 0;
  edtPhone.Top:= 0;
  cbSociety.Items.Add ('Mg');
  cbQualification.Items.Add ('Mg');
  UpdateLanguage;
  UpdateFonts;
  PageControl1.ActivePage:= tsMain;
  Resize;
  Width:= round (Screen.Width * 0.75);
  Position:= poScreenCenter;
  edtBirthFull.OnExit := edtBirthFullExit;
  // Перехват клавиш формой до контролов
  KeyPreview := True;
  // Автокоррекция регистра Имя/Отчество
  edtName.OnExit := NameExitNormalize;
  edtStepName.OnExit := NameExitNormalize;
  // Фамилия: всегда верхний регистр по вводу, пробелы обрезаем при выходе
  edtSurname.CharCase := ecUpperCase;
  edtSurname.OnExit := SurnameExitNormalize;
  // Аббревиатуры регионов и округов — всегда в верхнем регистре
  edtRegionAbbr1.CharCase := ecUpperCase;
  edtRegionAbbr2.CharCase := ecUpperCase;
  edtDistrictAbbr.CharCase := ecUpperCase;
  // Пробел как переход фокуса: Space -> next control, Shift+Space -> вставка пробела
  // Установим очередность табуляции: после полной даты сразу к выбору пола
  edtBirthFull.TabOrder := edtStepName.TabOrder + 1;
  rbMale.TabOrder := edtBirthFull.TabOrder + 1;
  rbFemale.TabOrder := rbMale.TabOrder + 1;
  // Назначим обработчик навигации клавишами на форму
  OnKeyDown := FormKeyDown;
end;

procedure TShooterDetailsDialog.btnNextImageClick(Sender: TObject);
begin
  NextImage;
end;

procedure TShooterDetailsDialog.btnPrevImageClick(Sender: TObject);
begin
  PrevImage;
end;

procedure TShooterDetailsDialog.NextImage;
begin
  if fImageIndex< fShooter.ImagesCount-1 then
    SetImage (fImageIndex+1);
end;

procedure TShooterDetailsDialog.PrevImage;
begin
  if fImageIndex> 0 then
    SetImage (fImageIndex-1);
end;

procedure TShooterDetailsDialog.Resize;
var
  tw: integer;
begin
  PageControl1.Width:= ClientWidth;
  btnClose.Left:= ClientWidth-btnClose.Width;

  tw:= tsMain.ClientWidth-pnlPhoto.Width;
  pnlPhoto.Left:= tw;
  edtSurname.Width:= tw-16-edtSurname.Left;
  edtName.Width:= edtSurname.Width;
  edtStepName.Width:= edtSurname.Width;
  edtRegionFull1.Width:= tw-16-edtRegionFull1.Left;
  edtRegionFull2.Width:= edtRegionFull1.Width;
  edtDistrictFull.Width:= edtRegionFull1.Width;
  edtTown.Width:= tw-16-edtTown.Left;
  edtSportClub.Width:= tw-16-edtSportClub.Left;

  sbPrevImage.Left:= pnlPhoto.Left;
  sbPrevImage.Top:= pnlPhoto.Top+pnlPhoto.Height+2;
  sbAddPhoto.Left:= sbPrevImage.Left+sbPrevImage.Width;
  sbAddPhoto.Top:= sbPrevImage.Top;
  sbNextImage.Left:= sbAddPhoto.Left+sbAddPhoto.Width;
  sbNextImage.Top:= sbPrevImage.Top;
  sbDeletePhoto.Left:= pnlPhoto.Left+pnlPhoto.Width-sbDeletePhoto.Width;
  sbDeletePhoto.Top:= sbPrevImage.Top;

  edtPhone.Width:= tsAdd.ClientWidth-edtPhone.Left;
  meAddress.Width:= edtPhone.Width;
  mePassport.Width:= meAddress.Width;
  meCoaches.Width:= mePassport.Width;
  meWeapon.Width:= meCoaches.Width;

  cbSociety.Width:= (tw-16) div 2-12-cbSociety.Left;
  lSportClub.Left:= (tw-16) div 2+12;
  edtSportClub.Left:= lSportClub.Left+lSportClub.Width+8;
  edtSportClub.Width:= tw-16-edtSportClub.Left;
end;

procedure TShooterDetailsDialog.SetImage(index: integer);
var
  image: TImage;
begin
  if (index>= 0) and (index< fShooter.ImagesCount) then
    begin
      image:= TImage.Create (pnlPhoto);
      image.Center:= true;
      image.Stretch:= true;
      image.Proportional:= true;
      image.OnClick:= pnlPhoto.OnClick;
      image.Align:= alClient;
      try
        if FileExists (fShooter.Data.ImagesFolder+fShooter.Images [index]) then
          begin
            image.Picture.LoadFromFile (fShooter.Data.ImagesFolder+fShooter.Images [index]);
            pnlPhoto.Caption:= '';
            pnlPhoto.Hint:= fShooter.Images [index];
          end
        else
          begin
            pnlPhoto.Hint:= format (Language ['NoPhotoFileName'],[fShooter.Data.ImagesFolder+fShooter.Images [index]]);
            pnlPhoto.Caption:= Language ['NoPhotoFile'];
            if fImage<> nil then
              fImage.Visible:= false;
          end;
      except
        pnlPhoto.Caption:= Language ['PhotoFileError'];
        pnlPhoto.Hint:= format (Language ['CannotLoadPhoto'],[fShooter.Data.ImagesFolder+fShooter.Images [index]]);
        if fImage<> nil then
          fImage.Visible:= false;
      end;
      pnlPhoto.ShowHint:= true;
      Cursor:= crHourGlass;
      Cursor:= crDefault;
      if fImage= nil then
        begin
          fImage:= image;
          fImage.Parent:= pnlPhoto;
        end
      else
        begin
          fImage.Picture.Assign (image.Picture);
          image.Free;
        end;
      fImageIndex:= index;
      sbPrevImage.Enabled:= (fImageIndex> 0);
      sbNextImage.Enabled:= (fImageIndex< fShooter.ImagesCount-1);
      sbDeletePhoto.Enabled:= true;
      fImage.Visible:= true;
    end
  else
    begin
      if fImage<> nil then
        fImage.Visible:= false;
      sbPrevImage.Enabled:= false;
      sbNextImage.Enabled:= false;
      sbDeletePhoto.Enabled:= false;
      pnlPhoto.ShowHint:= false;
    end;
end;

procedure TShooterDetailsDialog.AddNewImage;
var
  fn,folder,filename,newfilename: string;
begin
  if OpenDialog1.InitialDir= '' then
    OpenDialog1.InitialDir:= fShooter.Data.ImagesFolder;
	OpenDialog1.Filter:= GraphicFilter(TGraphic);
	if not OpenDialog1.Execute then
    exit;
  filename:= OpenDialog1.FileName;
  fn:= ExtractFileName (filename);
  folder:= IncludeTrailingPathDelimiter (ExtractFileDir (filename));
  if fShooter.Data.ImagesFolder= '' then
    begin
      fShooter.Data.ImagesFolder:= folder;
    end
  else if not AnsiSameText (fShooter.Data.ImagesFolder,folder) then
    begin
      newfilename:= fShooter.Data.ImagesFolder+fn;
      CopyFile (PChar (filename),PChar (newfilename),false);
    end;
  fShooter.AddImage (fn);
  SetImage (fShooter.ImagesCount-1);
end;

procedure TShooterDetailsDialog.OpenImage(index: integer);
var
  f: TForm;
  i: TImage;
begin
  if fImageIndex< 0 then
    exit;
  f:= TForm.Create (self);
  i:= TImage.Create (f);
  i.Parent:= f;
  i.Align:= alClient;
  i.Proportional:= true;
  i.Stretch:= true;
  i.Center:= true;
  i.OnMouseDown:= PhotoMouseDown;
  try
    i.Picture.LoadFromFile (fShooter.Data.ImagesFolder+fShooter.Images [fImageIndex]);
  except
    f.Free;
    exit;
  end;
  f.OnMouseDown:= PhotoMouseDown;
  f.OnKeyDown:= PhotoKeyDown;
  f.Width:= Screen.Width;
  f.Height:= Screen.Height;
  f.BorderStyle:= bsNone;
  f.Position:= poScreenCenter;
  f.ShowModal;
  f.Free;
end;

procedure TShooterDetailsDialog.PhotoKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  (Sender as TForm).Close;
end;

procedure TShooterDetailsDialog.PhotoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Sender is TForm then
    (Sender as TForm).Close
  else if Sender is TImage then
    ((Sender as TImage).Parent as TForm).Close;
end;

procedure TShooterDetailsDialog.btnAddPhotoClick(Sender: TObject);
begin
  AddNewImage;
end;

procedure TShooterDetailsDialog.edtBirthFullExit(Sender: TObject);
var
  s: string;
  hadDayMonth: boolean;
  dt, nowDate: TDateTime;
  curY, curM, curD: word;
begin
  s := Trim(edtBirthFull.Text);
  hadDayMonth := (Pos('.', s) > 0) or ((Length(s) = 6) or (Length(s) = 8));
  // Присвоим свойство — оно спарсит и нормализует значения
  fShooter.BirthFullStr := s;
  // Перечитаем нормализованную строку для отображения
  edtBirthFull.Text := fShooter.BirthFullStr;
  // Также синхронизируем старые отображаемые поля
  edtBirthYear.Text := fShooter.BirthYearStr;
  edtBirthDate.Text := fShooter.BirthDateStr;
  if hadDayMonth and (fShooter.BirthDateStr = '') and (s <> '') then
  begin
    MessageDlg('Некорректная дата рождения. Укажите существующую дату в формате ДД.ММ.ГГГГ.', mtWarning, [mbOK], 0);
    edtBirthFull.SetFocus;
    edtBirthFull.SelectAll;
    Exit;
  end;
  // Запрет будущих дат: полная дата не > сегодня; если введён только год — не больше текущего года
  nowDate := Date;
  DecodeDate(nowDate, curY, curM, curD);
  if TryParseDDMMYYYY(edtBirthFull.Text, dt) then
  begin
    if dt > nowDate then
    begin
      MessageDlg('Дата рождения не может быть в будущем.', mtWarning, [mbOK], 0);
      edtBirthFull.SetFocus;
      edtBirthFull.SelectAll;
      Exit;
    end;
  end
  else if (edtBirthFull.Text <> '') and (Pos('.', edtBirthFull.Text) = 0) then
  begin
    if StrToIntDef(edtBirthFull.Text, 0) > curY then
    begin
      MessageDlg('Год рождения не может быть в будущем.', mtWarning, [mbOK], 0);
      edtBirthFull.SetFocus;
      edtBirthFull.SelectAll;
      Exit;
    end;
  end;
  // Если всё ок, двигаем фокус на выбор пола
  if not rbMale.Focused and edtBirthFull.Focused then
    rbMale.SetFocus;
end;

function TShooterDetailsDialog.ProperCaseName(const s: string): string;
  function IsSep(ch: Char): boolean;
  begin
    Result := CharInSet(ch, [' ', '-', '''']);
  end;
var
  i: Integer;
  upNext: boolean;
  ch: Char;
  buf: string;
begin
  buf := Trim(s).ToLower;
  upNext := True;
  for i := 1 to Length(buf) do
  begin
    ch := buf[i];
    if upNext and ch.IsLetter then
      buf[i] := ch.ToUpper
    else
      buf[i] := ch;
    upNext := IsSep(ch);
  end;
  Result := buf;
end;

procedure TShooterDetailsDialog.NameExitNormalize(Sender: TObject);
var
  e: TEdit;
begin
  if Sender is TEdit then
  begin
    e := TEdit(Sender);
    e.Text := ProperCaseName(e.Text);
  end;
end;

procedure TShooterDetailsDialog.SurnameExitNormalize(Sender: TObject);
var
  e: TEdit;
begin
  if Sender is TEdit then
  begin
    e := TEdit(Sender);
    // Удаляем пробелы слева/справа; регистр уже принудительно верхний через CharCase
    e.Text := Trim(e.Text);
  end;
end;

function TShooterDetailsDialog.TryParseDDMMYYYY(const s: string; out D: TDateTime): boolean;
var
  dd, mm, yy: integer;
  parts: TArray<string>;
begin
  Result := False;
  D := 0;
  parts := s.Split(['.']);
  if Length(parts) <> 3 then
    Exit;
  if not TryStrToInt(parts[0], dd) then Exit;
  if not TryStrToInt(parts[1], mm) then Exit;
  if not TryStrToInt(parts[2], yy) then Exit;
  Result := TryEncodeDate(yy, mm, dd, D);
end;

function TShooterDetailsDialog.ShouldSkipControl(Control: TWinControl): Boolean;
const
  // Пропускаем: ISSF ID; расшифровку после "Регион"; "Доп. регион" (код) и его расшифровку; расшифровку после "Округ"
  SkipNames: array[0..4] of string = (
    'edtISSFID',        // ISSF ID
    'edtRegionFull1',   // расшифровка Регион
    'edtRegionAbbr2',   // Доп. регион (код)
    'edtRegionFull2',   // расшифровка Доп. регион
    'edtDistrictFull'   // расшифровка Округ
  );
var
  i: Integer;
begin
  Result := False;
  if Control = nil then Exit;
  for i := Low(SkipNames) to High(SkipNames) do
    if SameText(Control.Name, SkipNames[i]) then
      Exit(True);
  // Также не даём фокус скрытым/без TabStop
  if (not Control.Visible) or (not Control.TabStop) then
    Exit(True);
end;


end.


