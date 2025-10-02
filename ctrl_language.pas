unit ctrl_language;

interface

uses
  Winapi.Windows, System.Classes, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, 
  Vcl.Forms, Vcl.Controls, Vcl.Dialogs, MyLanguage, Vcl.Menus, 
  System.SysUtils, Vcl.Grids;

procedure LoadControlLanguage (AControl: TControl);
procedure LoadComponentLanguage (AComponent: TComponent);

implementation

// Функция для правильного отображения русского текста из языковых файлов
// Исправляет типичные "кракозябры" (когда UTF-8 текст отображён как CP1251: "Р”, "С", "?" и т.п.)
function FixRussianDisplay(const S: string): string;
  function CountCyr(const T: string): Integer;
  var ch: Char;
  begin
    Result := 0;
    for ch in T do
      if (ch >= #$0410) and (ch <= #$044F) or (ch = #$0401) or (ch = #$0451) then
        Inc(Result);
  end;
  function CountMojibake(const T: string): Integer;
  var ch: Char;
  begin
    Result := 0;
    for ch in T do
      if ch in ['?','?','Р','С','?'] then
        Inc(Result);
  end;
var
  moj, cyr: Integer;
  bytes: TBytes;
  fixed: string;
  enc1251: TEncoding;
begin
  Result := S;
  if S = '' then Exit;
  cyr := CountCyr(S);
  moj := CountMojibake(S);
  if (moj > cyr) then
  begin
    enc1251 := TEncoding.GetEncoding(1251);
    try
      // Попытка перекодировать: CP1251 bytes -> UTF-8 string
      // (типичный случай, когда UTF-8 случайно интерпретировали как CP1251)
      bytes := enc1251.GetBytes(S);
      fixed := TEncoding.UTF8.GetString(bytes);
      if CountCyr(fixed) > CountMojibake(fixed) then
        Exit(fixed);
    except
      // игнорируем
    end;
  end;
end;

function CtrlPath (AControl: TControl): string;
begin
  if AControl.Parent<> nil then
    Result:= CtrlPath (AControl.Parent)+'.'+AControl.Name
  else
    Result:= AControl.Name;
end;

function ComponentPath (AComponent: TComponent): string;
begin
  if AComponent.Owner<> nil then
    begin
      if AComponent.Owner is TControl then
        Result:= CtrlPath (AComponent.Owner as TControl)+'.'+AComponent.Name
      else
        Result:= AComponent.Name;
    end
  else
    Result:= AComponent.Name;
end;

procedure LoadGroupBoxLanguage (AGroupBox: TGroupBox);
var
  i: integer;
begin
  AGroupBox.Caption:= FixRussianDisplay(Language.ByTag [CtrlPath (AGroupBox)]);
  for i:= 0 to AGroupBox.ControlCount-1 do
    LoadControlLanguage (AGroupBox.Controls [i]);
end;

procedure LoadLabelLanguage (ALabel: TLabel);
begin
  ALabel.Caption:= FixRussianDisplay(Language.ByTag [CtrlPath (ALabel)]);
end;

procedure LoadButtonLanguage (AButton: TButton);
begin
  AButton.Caption:= FixRussianDisplay(Language.ByTag [CtrlPath (AButton)]);
end;

procedure LoadRadioButtonLanguage (ARadioButton: TRadioButton);
begin
  ARadioButton.Caption:= FixRussianDisplay(Language.ByTag [CtrlPath (ARadioButton)]);
end;

procedure LoadCheckBoxLanguage (ACheckBox: TCheckBox);
begin
  ACheckBox.Caption:= FixRussianDisplay(Language.ByTag [CtrlPath (ACheckBox)]);
end;

procedure LoadFormLanguage (AForm: TForm);
var
  i: integer;
begin
  AForm.Caption:= FixRussianDisplay(Language.ByTag [CtrlPath (AForm)]);
  for i:= 0 to AForm.ControlCount-1 do
    LoadControlLanguage (AForm.Controls [i]);
  for i:= 0 to AForm.ComponentCount-1 do
    LoadComponentLanguage (AForm.Components [i]);
end;

procedure LoadPanelLanguage (APanel: TPanel);
var
  i: integer;
begin
  if APanel.Caption<> '' then
    APanel.Caption:= FixRussianDisplay(Language.ByTag [CtrlPath (APanel)]);
  for i:= 0 to APanel.ControlCount-1 do
    LoadControlLanguage (APanel.Controls [i]);
end;

procedure LoadHeaderControlLanguage (AHeaderControl: THeaderControl);
var
  i: integer;
  p: string;
begin
  p:= CtrlPath (AHeaderControl);
  for i:= 0 to AHeaderControl.Sections.Count-1 do
    begin
      // Получаем перевод по тегу. Если перевод не найден, Language.ByTag возвращает '[Tag]'.
      // В этом случае не затираем исходный текст секции из DFM.
      var tag := p+'['+IntToStr(i)+']';
      var txt := Language.ByTag[tag];
      if (Length(txt) >= 2) and (txt[1] = '[') and (txt[Length(txt)] = ']') then
        continue
      else
        AHeaderControl.Sections [i].Text:= FixRussianDisplay(txt);
    end;
end;

procedure LoadTabSheetLanguage (ATabSheet: TTabSheet);
var
  i: integer;
begin
  if ATabSheet.PageControl<> nil then
    ATabSheet.Caption:= FixRussianDisplay(Language.ByTag [CtrlPath (ATabSheet.PageControl)+'.'+ATabSheet.Name]);
  for i:= 0 to ATabSheet.ControlCount-1 do
    LoadControlLanguage (ATabSheet.Controls [i]);
end;

procedure LoadPageControlLanguage (APageControl: TPageControl);
var
  i: integer;
begin
  for i:= 0 to APageControl.PageCount-1 do
    LoadTabSheetLanguage (APageControl.Pages [i]);
end;

procedure LoadOpenDialogLanguage (AOpenDialog: TOpenDialog);
begin
  AOpenDialog.Title:= FixRussianDisplay(Language.ByTag [ComponentPath (AOpenDialog)]);
end;

function MenuPath (AMenuItem: TMenuItem): string;
begin
  if AMenuItem.Parent<> nil then
    Result:= MenuPath (AMenuItem.Parent)+'.'+AMenuItem.Name
  else if AMenuItem.Owner<> nil then
    Result:= ComponentPath (AMenuItem.Owner)+'.'+AMenuItem.Name
  else
    Result:= '';
end;

procedure LoadMenuItemLanguage (AMenuItem: TMenuItem);
var
  i: integer;
begin
  if (AMenuItem.Name<> '') and (not AMenuItem.IsLine) then
    AMenuItem.Caption:= FixRussianDisplay(Language.ByTag [MenuPath (AMenuItem)]);
  for i:= 0 to AMenuItem.Count-1 do
    LoadMenuItemLanguage (AMenuItem.Items [i]);
end;

procedure LoadMainMenuLanguage (AMainMenu: TMainMenu);
begin
  LoadMenuItemLanguage (AMainMenu.Items);
end;

procedure LoadPopupMenuLanguage (APopupMenu: TPopupMenu);
begin
  LoadMenuItemLanguage (APopupMenu.Items);
end;

procedure LoadControlLanguage (AControl: TControl);
begin
  if AControl is TForm then
    LoadFormLanguage (AControl as TForm)
  else if AControl is TGroupBox then
    LoadGroupBoxLanguage (AControl as TGroupBox)
  else if AControl is TLabel then
    LoadLabelLanguage (AControl as TLabel)
  else if AControl is TButton then
    LoadButtonLanguage (AControl as TButton)
  else if AControl is TRadioButton then
    LoadRadioButtonLanguage (AControl as TRadioButton)
  else if AControl is TCheckBox then
    LoadCheckBoxLanguage (AControl as TCheckBox)
  else if AControl is TPanel then
    LoadPanelLanguage (AControl as TPanel)
  else if AControl is THeaderControl then
    LoadHeaderControlLanguage (AControl as THeaderControl)
  else if AControl is TPageControl then
    LoadPageControlLanguage (AControl as TPageControl);
end;

procedure LoadComponentLanguage (AComponent: TComponent);
begin
  if AComponent is TOpenDialog then
    LoadOpenDialogLanguage (AComponent as TOpenDialog)
  else if AComponent is TMainMenu then
    LoadMainMenuLanguage (AComponent as TMainMenu)
  else if AComponent is TPopupMenu then
    LoadPopupMenuLanguage (AComponent as TPopupMenu);
end;

end.

