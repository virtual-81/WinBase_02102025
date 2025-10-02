{$a-}
unit form_compresults;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.Win.Registry, Vcl.StdCtrls, Vcl.ComCtrls, System.UITypes, Vcl.Printers,

  SysFont,
  Data,
  MyPrint,
  wb_registry,

  MyLanguage,
  ctrl_language,

  form_shooterresults, Vcl.ExtCtrls;

type
  TShooterInfo= record
    fight: boolean;
  end;

  TFinalSlot = record
    Letter: string;
    Shooter: TStartListEventShooterItem;
  end;

  TCompetitionResultsForm = class(TForm)
    lbShooters: TListBox;
    HeaderControl1: THeaderControl;
    pnlListBox: TPanel;
    pnlButtons: TPanel;
    btnResetResults: TButton;
    btnResetFinal: TButton;
    // Кнопка экспорта списка финалистов в PDF
    procedure btnFinalistsPDFClick(Sender: TObject);
  procedure btnFinalistsCSVClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnResetFinalClick(Sender: TObject);
    procedure btnResetResultsClick(Sender: TObject);
    procedure lbShootersClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure lbShootersDblClick(Sender: TObject);
    procedure lbShootersDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FormDestroy(Sender: TObject);
    procedure lbShootersMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
    procedure FormCreate(Sender: TObject);
    procedure HeaderControl1Resize(Sender: TObject);
    procedure HeaderControl1SectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    fEvent: TStartListEventItem;
    fShooters: array of TShooterInfo;
    fRegularHeight,fFinalHeight1,fFinalHeight2: integer;
    fHeaderChanged: boolean;
    fCompY: integer;
    fTeamPStr,fRegionPStr,fDistrictPStr: string;
    fSearchStr,fSearchNum: string;
  btnFinalistsPDF: TButton;
  btnFinalistsCSV: TButton;
    // Кеш распределения финалистов по буквам A..H, общий для PDF и CSV
    FCachedSlots: array[0..7] of TFinalSlot;
    FCachedTopN: Integer;
    FCachedSlotsValid: Boolean;
    procedure UpdateInfo;
    procedure set_Event(const Value: TStartListEventItem);
    procedure ChangePriority (index: integer; change: integer; shift: boolean);
    procedure EditManualPoints (index: integer);
    procedure EditRecordComment (index: integer);
    procedure OpenShooter (index: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
    function DoSearchNum (S: string; AFrom: integer): integer;
    function DoSearchStr (S: string; AFrom: integer): integer;
    procedure ResetSearch;
    procedure GenerateFinalistsPDF;
  procedure GenerateFinalistsCSV;
    procedure InvalidateFinalSlots;
    function BuildOrGetFinalSlots(askReshuffle: Boolean): Integer;
    // Persist A..H -> Shooter mapping in registry per StartList/Event
    function FinalistsRegKey: string;
    function TryLoadFinalSlotsFromRegistry(out outTopN: Integer): Boolean;
    procedure SaveFinalSlotsToRegistry(topN: Integer);
  public
    property Event: TStartListEventItem read fEvent write set_Event;
    function Execute: boolean;
  end;

implementation

uses System.Math;

{$R *.dfm}

{ TCompetitionResultsForm }

procedure TCompetitionResultsForm.set_Event(const Value: TStartListEventItem);
begin
  fEvent:= Value;
  InvalidateFinalSlots;
  UpdateInfo;
end;

procedure TCompetitionResultsForm.UpdateFonts;
var
  bh: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnResetResults.ClientHeight:= bh;
  btnResetFinal.ClientHeight:= bh;
  btnResetResults.Left:= 16;
  btnResetResults.Top:= 8;
  btnResetFinal.Top:= btnResetResults.Top;
  btnResetResults.ClientWidth:= Canvas.TextWidth (btnResetResults.Caption)+32;
  btnResetFinal.Left:= btnResetResults.Left+btnResetResults.Width+8;
  btnResetFinal.ClientWidth:= Canvas.TextWidth (btnResetFinal.Caption)+32;
  // Расположим новую кнопку справа от "Очистить только финал"
  if btnFinalistsPDF <> nil then
  begin
    btnFinalistsPDF.Top := btnResetResults.Top;
    btnFinalistsPDF.ClientHeight := bh;
    btnFinalistsPDF.Left := btnResetFinal.Left + btnResetFinal.Width + 8;
    if btnFinalistsPDF.Caption = '' then
      btnFinalistsPDF.Caption := 'Список финалистов';
    btnFinalistsPDF.ClientWidth := Canvas.TextWidth(btnFinalistsPDF.Caption)+32;

    // Рядом кнопка CSV
    if btnFinalistsCSV <> nil then
    begin
      btnFinalistsCSV.Top := btnFinalistsPDF.Top;
      btnFinalistsCSV.ClientHeight := bh;
      btnFinalistsCSV.Left := btnFinalistsPDF.Left + btnFinalistsPDF.Width + 8;
      btnFinalistsCSV.ClientWidth := Canvas.TextWidth(btnFinalistsCSV.Caption)+32;
    end;
  end;
  pnlButtons.ClientHeight:= btnResetResults.Top*2+btnResetResults.Height;
  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
  lbShooters.Font.Name:= 'Arial';
  if Font.Size< 10 then
    lbShooters.Font.Size:= 10
  else
    lbShooters.Font.Size:= Font.Size;
  lbShooters.Canvas.Font:= lbShooters.Font;
  lbShooters.ItemHeight:= lbShooters.Canvas.TextHeight ('Mg')*2+4;
end;

procedure TCompetitionResultsForm.btnFinalistsPDFClick(Sender: TObject);
begin
  GenerateFinalistsPDF;
end;

procedure TCompetitionResultsForm.btnFinalistsCSVClick(Sender: TObject);
begin
  GenerateFinalistsCSV;
end;

procedure TCompetitionResultsForm.GenerateFinalistsPDF;
var
  i, topN: Integer;
  pdf: TPDFDocument;
  prn: TMyPrinter;
  x, y, lh, left, right, top, lineH: Integer;
  s: string;
  sh: TStartListEventShooterItem;
  saveDlg: TSaveDialog;
  initialName, selectedFile: string;
  function FullFIO(const ASh: TStartListEventShooterItem): string;
  begin
    if (ASh <> nil) and (ASh.Shooter <> nil) then
    begin
      Result := ASh.Shooter.SurnameAndName;
      if Trim(ASh.Shooter.StepName) <> '' then
        Result := Result + ' ' + ASh.Shooter.StepName;
    end
    else
      Result := '';
  end;
  function SanitizeFileName(const AName: string): string;
  var
    i: Integer;
    invalidChars: string;
  begin
    Result := AName;
    invalidChars := '\/:*?"<>|';
    for i := 1 to Length(invalidChars) do
      Result := StringReplace(Result, invalidChars[i], '_', [rfReplaceAll]);
  end;
begin
  if (fEvent=nil) or (not fEvent.HasFinal) then
  begin
    MessageDlg('Для этого упражнения не предусмотрен финал.', mtInformation, [mbOK], 0);
    Exit;
  end;
  if fEvent.Shooters.Count=0 then
  begin
    MessageDlg('Нет участников для формирования списка финалистов.', mtInformation, [mbOK], 0);
    Exit;
  end;

  // Получаем (или создаём) фиксированное распределение
  topN := BuildOrGetFinalSlots(False);

  // Предложим сохранить файл
  initialName := Format('Стартовый лист финалистов - %s.pdf', [SanitizeFileName(fEvent.Event.ShortName)]);
  saveDlg := TSaveDialog.Create(Self);
  try
    saveDlg.Title := 'Сохранить PDF файл';
    saveDlg.Filter := 'PDF файлы (*.pdf)|*.pdf|Все файлы (*.*)|*.*';
    saveDlg.DefaultExt := 'pdf';
    saveDlg.FileName := initialName;
    saveDlg.Options := saveDlg.Options + [ofOverwritePrompt, ofNoReadOnlyReturn, ofPathMustExist];
    if not saveDlg.Execute then
      Exit;
    selectedFile := saveDlg.FileName;
    if ExtractFileExt(selectedFile) = '' then
      selectedFile := selectedFile + '.pdf';
  finally
    saveDlg.Free;
  end;

  // Готовим PDF документ
  pdf := TPDFDocument.Create(nil);
  try
    pdf.DocumentInfo.Title := Format('Стартовый лист финалистов в упражнении %s', [fEvent.Event.ShortName]);
    pdf.FileName := selectedFile; // полный путь, выбранный пользователем
    pdf.AutoLaunch := True;
    pdf.BeginDoc;
    prn := TMyPrinter.Create(pdf);
    try
      // Базовая инициализация печати
      prn.Orientation := poPortrait;
      prn.BeginDoc;
      prn.SetBordersMM(20, 15, 10, 5); // как в стандартных протоколах

      // Стандартизованные шрифты и размеры
      var font_name: string;
      var font_size: integer;
      var font_height_large, font_height_small: integer;
      var footerheight, signatureheight: integer;
      GetDefaultProtocolFont(font_name, font_size);
      with prn.Canvas.Font do
      begin
        Name := font_name;
        Charset := PROTOCOL_CHARSET;
        Size := font_size;
        font_height_large := Height;
        font_height_small := Round(font_height_large * 4 / 5);
      end;

      // Геометрия страницы
      left := prn.Left;
      right := prn.Right;
      y := prn.Top;
      prn.Canvas.Font.Height := font_height_small;
      footerheight := prn.Canvas.TextHeight('Mg')*2 + prn.MM2PY(4);
      prn.Canvas.Font.Height := font_height_large;
      signatureheight := prn.Canvas.TextHeight('Mg')*2 + prn.MM2PY(10);

      // ШАПКА: многострочный TitleText по центру (только на первой странице)
      prn.Canvas.Font.Style := [fsBold];
      var headerLines := TStringList.Create;
      try
        headerLines.Text := fEvent.StartList.Info.TitleText;
        for i := 0 to headerLines.Count-1 do
        begin
          s := headerLines[i];
          x := (left + right - prn.Canvas.TextWidth(s)) div 2;
          prn.Canvas.TextOut(x, y, s);
          Inc(y, prn.Canvas.TextHeight('Mg'));
        end;
        if headerLines.Count > 0 then
          Inc(y, prn.MM2PY(2));
      finally
        headerLines.Free;
      end;

      // Заголовок страницы по центру
      prn.Canvas.Font.Style := [fsBold];
      s := 'Стартовый лист финалистов';
      x := (left + right - prn.Canvas.TextWidth(s)) div 2;
      prn.Canvas.TextOut(x, y, s);
      Inc(y, prn.Canvas.TextHeight('Mg') + prn.MM2PY(2));

      // Левая/правая строки: слева краткое, справа полное название упражнения
      prn.Canvas.Font.Style := [fsBold];
      s := fEvent.Event.ShortName;
      prn.Canvas.TextOut(left, y, s);
      prn.Canvas.Font.Style := [];
      s := fEvent.Event.Name;
      x := right - prn.Canvas.TextWidth(s);
      prn.Canvas.TextOut(x, y, s);
      Inc(y, prn.Canvas.TextHeight('Mg'));

      // Строка даты слева и время финала справа (если задано)
      prn.Canvas.Font.Style := [];
      if fEvent.FinalTime > 0 then
        prn.Canvas.TextOut(left, y, FormatDateTime('d-mm-yyyy', fEvent.FinalTime));
      if fEvent.Event.FinalPlaces > 0 then
      begin
        if fEvent.FinalTime > 0 then
          s := FormatDateTime(FINAL_DATETIME, fEvent.FinalTime)
        else
          s := 'Финал  __-__-____, __:__';
        x := right - prn.Canvas.TextWidth(s);
        prn.Canvas.TextOut(x, y, s);
      end;


      // Разделительная линия под шапкой
      Inc(y, prn.Canvas.TextHeight('Mg') + prn.MM2PY(2));
      prn.Canvas.Pen.Width := 1;
      prn.Canvas.MoveTo(left, y);
      prn.Canvas.LineTo(right, y);
      Inc(y, prn.MM2PY(2));

      // Таблица финалистов: Буква, Разряд, ФИО(2 строки), Д.р., Регион, Клуб
      prn.Canvas.Font.Style := [fsBold];
      // Базовый крупный кегль и вычисление высот для двухстрочной ФИО
      prn.Canvas.Font.Size := font_size; // большая строка (фамилия)
      var surnameH := prn.Canvas.TextHeight('Mg');
      prn.Canvas.Font.Size := Max(6, font_size - 2); // вторая строка на 2 пункта меньше
      var givenH := prn.Canvas.TextHeight('Mg');
      // высота линии — сумма двух строк + небольшой отступ
      lineH := surnameH + givenH + prn.MM2PY(2);

      // Заголовки колонок с новыми отступами в мм
      prn.Canvas.Font.Size := font_size;
      prn.Canvas.TextOut(left, y, 'Позиция');
      prn.Canvas.TextOut(left + prn.MM2PX(25), y, 'Разряд');
      prn.Canvas.TextOut(left + prn.MM2PX(50), y, 'ФИО');
  prn.Canvas.TextOut(left + prn.MM2PX(105), y, 'Д.р.');
  prn.Canvas.TextOut(left + prn.MM2PX(135), y, 'Регион');
  prn.Canvas.TextOut(left + prn.MM2PX(160), y, 'Клуб');
      Inc(y, lineH);
      prn.Canvas.Pen.Width := 1;
      prn.Canvas.MoveTo(left, y);
      prn.Canvas.LineTo(right, y);

      // Тело таблицы: фамилия (строка 1), имя отчество (строка 2 меньшим шрифтом)
      for i := 0 to topN-1 do
      begin
  sh := FCachedSlots[i].Shooter;
        if sh = nil then Continue;
        var baseY := y + i*lineH + prn.MM2PY(1);

  // Первая строка: буква и фамилия (заглавными)
  prn.Canvas.Font.Size := font_size;
  prn.Canvas.Font.Style := [];
  // Центрируем букву в колонке позиции (25 мм) по горизонтали
  var colW := prn.MM2PX(25);
  var letterW := prn.Canvas.TextWidth(FCachedSlots[i].Letter);
  var tx := left + (colW - letterW) div 2;
  // По вертикали выровняем букву по центру области фамилии
  var letterH := prn.Canvas.TextHeight('Mg');
  var ty := baseY + (surnameH - letterH) div 2;
  prn.Canvas.TextOut(tx, ty, FCachedSlots[i].Letter);
        prn.Canvas.TextOut(left + prn.MM2PX(25), baseY, sh.Shooter.QualificationName);
        prn.Canvas.TextOut(left + prn.MM2PX(50), baseY, AnsiUpperCase(Trim(sh.Shooter.Surname)) + ',');

        // Вторая строка: имя + отчество меньшим шрифтом
        prn.Canvas.Font.Size := Max(6, font_size - 2);
        var nameY := baseY + surnameH;
        var given := Trim(sh.Shooter.Name);
        if Trim(sh.Shooter.StepName) <> '' then
          given := given + ' ' + Trim(sh.Shooter.StepName);
        prn.Canvas.TextOut(left + prn.MM2PX(50), nameY, given);

        // Дата рождения, регион и клуб на уровне первой строки (рядом с фамилией)
        prn.Canvas.Font.Size := font_size; // используем базовый кегль для этих столбцов
  prn.Canvas.TextOut(left + prn.MM2PX(105), baseY, sh.Shooter.BirthFullStr);
  prn.Canvas.TextOut(left + prn.MM2PX(135), baseY, sh.Shooter.RegionsAbbr);
  prn.Canvas.TextOut(left + prn.MM2PX(160), baseY, sh.Shooter.SocietyAndClub);

        // Во второй строке в колонке Регион печатаем город меньшим шрифтом, как имя/отчество
        prn.Canvas.Font.Size := Max(6, font_size - 2);
        if Trim(sh.Shooter.Town) <> '' then
          // Выравниваем город по левому краю колонки "Регион" (135 мм)
          prn.Canvas.TextOut(left + prn.MM2PX(135), nameY, sh.Shooter.Town);
      end;

      // Блок "Главный секретарь" как в остальных протоколах
      var sigY := prn.Bottom - footerheight - signatureheight + prn.MM2PY(5);
      prn.Canvas.Font.Style := [];
      prn.Canvas.Font.Height := font_height_large;
      var sx := left + prn.MM2PX(3);
      prn.Canvas.TextOut(sx, sigY, SECRETERY_TITLE);
      Inc(sigY, prn.Canvas.TextHeight('Mg'));
      prn.Canvas.TextOut(sx, sigY, fEvent.StartList.Info.SecreteryCategory);
      sx := right - prn.MM2PX(3) - prn.Canvas.TextWidth(fEvent.StartList.Info.Secretery);
      prn.Canvas.TextOut(sx, sigY, fEvent.StartList.Info.Secretery);

      // ФУТЕР как в протоколах: линия, номер страницы, копирайт и подпись
      var fy := prn.Bottom - footerheight + prn.MM2PY(2);
      prn.Canvas.Pen.Width := 1;
      prn.Canvas.MoveTo(prn.Left, fy);
      prn.Canvas.LineTo(prn.Right, fy);
      Inc(fy, prn.MM2PY(2));
      prn.Canvas.Font.Height := font_height_small;
      prn.Canvas.Font.Style := [];
      s := Format(PAGE_NO, [1]);
      prn.Canvas.TextOut(prn.Right - prn.Canvas.TextWidth(s), fy, s);
      s := Format(PAGE_FOOTER, [VERSION_INFO_STR]);
      prn.Canvas.TextOut(prn.Left, fy, s);
      Inc(fy, prn.Canvas.TextHeight('Mg'));
      s := PROTOCOL_MAKER_SIGN;
      prn.Canvas.TextOut(prn.Left, fy, s);
    finally
      prn.Free;
    end;
    pdf.EndDoc;
  finally
    pdf.Free;
  end;

end;

procedure TCompetitionResultsForm.InvalidateFinalSlots;
begin
  FCachedSlotsValid := False;
  FCachedTopN := 0;
  FillChar(FCachedSlots, SizeOf(FCachedSlots), 0);
end;

function TCompetitionResultsForm.BuildOrGetFinalSlots(askReshuffle: Boolean): Integer;
const
  letters: array[0..7] of string = ('A','B','C','D','E','F','G','H');
var
  i, topN, pos, pick: Integer;
  finalists: array of TStartListEventShooterItem;
  used: array of Boolean;
  lastClub: string;

  function ClubOf(sh: TStartListEventShooterItem): string;
  begin
    if (sh<>nil) and (sh.Shooter<>nil) then
      Result := sh.Shooter.SocietyAndClub
    else
      Result := '';
  end;
  function RandPick(excludeAdjacentClub: string): Integer;
  var idx, guard: Integer;
  begin
    guard := 0;
    repeat
      idx := Random(topN);
      Inc(guard);
      if (not used[idx]) and ((excludeAdjacentClub='') or (ClubOf(finalists[idx])<>excludeAdjacentClub)) then
        exit(idx);
      if guard>200 then break;
    until False;
    for idx := 0 to topN-1 do
      if not used[idx] then Exit(idx);
    Result := -1;
  end;
var
  needRebuild: Boolean;
begin
  // Если уже есть валидный кеш и перестановка не запрошена — возвращаем
  if FCachedSlotsValid and (not askReshuffle) then
    Exit(FCachedTopN);

  if askReshuffle and FCachedSlotsValid then
  begin
    if MessageDlg('Переставить финалистов заново?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit(FCachedTopN);
  end;

  if (fEvent=nil) or (fEvent.Shooters.Count=0) then
  begin
    FCachedSlotsValid := False;
    FCachedTopN := 0;
    Exit(0);
  end;

  // Попытка загрузить ранее сохранённое распределение из реестра (только если перестановка не запрошена)
  if (not askReshuffle) and TryLoadFinalSlotsFromRegistry(topN) then
  begin
    FCachedTopN := topN;
    FCachedSlotsValid := True;
    Exit(topN);
  end;

  Randomize;
  topN := Min(8, fEvent.Shooters.Count);
  SetLength(finalists, topN);
  for i := 0 to topN-1 do
    finalists[i] := fEvent.Shooters.Items[i];

  SetLength(used, topN);
  for i:=0 to topN-1 do used[i]:=False;
  lastClub := '';
  for pos := 0 to topN-1 do
  begin
    pick := RandPick(lastClub);
    if pick<0 then pick := 0;
    FCachedSlots[pos].Letter := letters[pos];
    FCachedSlots[pos].Shooter := finalists[pick];
    used[pick] := True;
    lastClub := ClubOf(FCachedSlots[pos].Shooter);
  end;

  FCachedTopN := topN;
  FCachedSlotsValid := True;
  // Сохраняем новое распределение для будущих запусков
  SaveFinalSlotsToRegistry(topN);
  Result := topN;
end;

function TCompetitionResultsForm.FinalistsRegKey: string;
// Уникальный ключ в реестре для текущего StartList и Event
var sid: string;
begin
  if (fEvent<>nil) and (fEvent.StartList<>nil) then
    sid := GUIDToString(fEvent.StartList.ID)
  else
    sid := '{00000000-0000-0000-0000-000000000000}';
  // Пример ключа: FinalSlots_{GUID}_EVTAG
  Result := Format('FinalSlots_%s_%s', [sid, fEvent.Event.Tag]);
end;

function TCompetitionResultsForm.TryLoadFinalSlotsFromRegistry(out outTopN: Integer): Boolean;
// Формат строки в реестре: v1;N=K;A={GUID};B={GUID};...
var raw, token, val: string;
    i, p, found, nFromStore: Integer;
    guidMap: array[0..7] of TGUID;
    hasGuid: array[0..7] of Boolean;
    letter: Char;
    shooterItem: TStartListEventShooterItem;
    j: Integer;
    g: TGUID;
begin
  Result := False;
  outTopN := 0;
  if (fEvent=nil) or (fEvent.Shooters=nil) then Exit(False);

  LoadStrFromRegistry(FinalistsRegKey, raw, '');
  if Trim(raw)='' then Exit(False);

  // Разбираем по ';'
  for i := 0 to 7 do hasGuid[i] := False;
  nFromStore := 0;
  while raw<>'' do
  begin
    p := Pos(';', raw);
    if p>0 then
    begin
      token := Copy(raw, 1, p-1);
      Delete(raw, 1, p);
    end
    else
    begin
      token := raw;
      raw := '';
    end;
    token := Trim(token);
    if token='' then Continue;
    // N=K
    if (Length(token)>=3) and (Copy(token,1,2)='N=') then
    begin
      val := Copy(token,3,MaxInt);
      try
        nFromStore := StrToIntDef(val, 0);
      except
        nFromStore := 0;
      end;
      Continue;
    end;
    // X={GUID}
    if (Length(token)>=3) and (token[2]='=') then
    begin
      letter := token[1];
      val := Copy(token,3,MaxInt);
      try
        g := StringToGUID(val);
      except
        Continue;
      end;
      case UpCase(letter) of
        'A'..'H':
          begin
            i := Ord(UpCase(letter)) - Ord('A');
            guidMap[i] := g;
            hasGuid[i] := True;
          end;
      end;
    end;
  end;

  if nFromStore<=0 then Exit(False);
  nFromStore := Min(nFromStore, 8);

  // Сопоставляем GUID стрелка с элементом текущего события
  found := 0;
  for i := 0 to nFromStore-1 do
  begin
    FCachedSlots[i].Letter := Chr(Ord('A')+i);
    FCachedSlots[i].Shooter := nil;
    if not hasGuid[i] then Continue;
    // ищем стрелка по GUID среди участников события
    shooterItem := nil;
    for j := 0 to fEvent.Shooters.Count-1 do
    begin
      if IsEqualGUID(fEvent.Shooters.Items[j].Shooter.PID, guidMap[i]) then
      begin
        shooterItem := fEvent.Shooters.Items[j];
        Break;
      end;
    end;
    if shooterItem<>nil then
    begin
      FCachedSlots[i].Shooter := shooterItem;
      Inc(found);
    end;
  end;

  // Если нашли все K стрелков — считаем загрузку успешной
  if found = nFromStore then
  begin
    outTopN := nFromStore;
    Result := True;
  end
  else
  begin
    // иначе сбрасываем частично заполненный кеш — построим заново
    for i := 0 to 7 do
    begin
      FCachedSlots[i].Letter := '';
      FCachedSlots[i].Shooter := nil;
    end;
    Result := False;
  end;
end;

procedure TCompetitionResultsForm.SaveFinalSlotsToRegistry(topN: Integer);
var i: Integer;
    s: string;
begin
  if (topN<=0) then Exit;
  s := 'v1;N=' + IntToStr(topN);
  for i := 0 to topN-1 do
  begin
    if (FCachedSlots[i].Shooter<>nil) and (FCachedSlots[i].Shooter.Shooter<>nil) then
      s := s + ';' + Chr(Ord('A')+i) + '=' + GUIDToString(FCachedSlots[i].Shooter.Shooter.PID)
    else
      s := s + ';' + Chr(Ord('A')+i) + '={}';
  end;
  SaveStrToRegistry(FinalistsRegKey, s);
end;

procedure TCompetitionResultsForm.GenerateFinalistsCSV;
var
  i, topN: Integer;
  saveDlg: TSaveDialog;
  initialName, selectedFile: string;
  sl: TStringList;
  line: string;

  function SanitizeFileName(const AName: string): string;
  var
    i: Integer;
    invalidChars: string;
  begin
    Result := AName;
    invalidChars := '\/:*?"<>|';
    for i := 1 to Length(invalidChars) do
      Result := StringReplace(Result, invalidChars[i], '_', [rfReplaceAll]);
  end;
  function QuoteCSV(const s: string): string;
  const DQ = #34;
  var q: string;
  begin
    q := StringReplace(s, DQ, DQ + DQ, [rfReplaceAll]);
    Result := DQ + q + DQ;
  end;
  function SurnameName(const sh: TStartListEventShooterItem): string;
  var fio: string;
  begin
    fio := Trim(sh.Shooter.Surname);
    if Trim(sh.Shooter.Name)<>'' then fio := fio + ' ' + Trim(sh.Shooter.Name);
    Result := fio;
  end;
begin
  if (fEvent=nil) or (not fEvent.HasFinal) then
  begin
    MessageDlg('Для этого упражнения не предусмотрен финал.', mtInformation, [mbOK], 0);
    Exit;
  end;
  if fEvent.Shooters.Count=0 then
  begin
    MessageDlg('Нет участников для формирования списка финалистов.', mtInformation, [mbOK], 0);
    Exit;
  end;

  // Получаем (или создаём) распределение; для CSV разрешаем спросить о «перестановке»
  topN := BuildOrGetFinalSlots(True);

  initialName := Format('Финалисты в упражнении %s.csv', [SanitizeFileName(fEvent.Event.ShortName)]);
  saveDlg := TSaveDialog.Create(Self);
  try
    saveDlg.Title := 'Сохранить CSV файл';
    saveDlg.Filter := 'CSV файлы (*.csv)|*.csv|Все файлы (*.*)|*.*';
    saveDlg.DefaultExt := 'csv';
    saveDlg.FileName := initialName;
    saveDlg.Options := saveDlg.Options + [ofOverwritePrompt, ofNoReadOnlyReturn, ofPathMustExist];
    if not saveDlg.Execute then Exit;
    selectedFile := saveDlg.FileName;
    if ExtractFileExt(selectedFile) = '' then
      selectedFile := selectedFile + '.csv';
  finally
    saveDlg.Free;
  end;

  sl := TStringList.Create;
  try
    // Заголовки
    sl.Add('Позиция;ФАМИЛИЯ Имя;Регион;Клуб');
    // Данные
    for i := 0 to topN-1 do
    begin
      if FCachedSlots[i].Shooter=nil then Continue;
      line := QuoteCSV(FCachedSlots[i].Letter) + ';' +
              QuoteCSV(SurnameName(FCachedSlots[i].Shooter)) + ';' +
              QuoteCSV(FCachedSlots[i].Shooter.Shooter.RegionsAbbr) + ';' +
              QuoteCSV(FCachedSlots[i].Shooter.Shooter.SocietyAndClub);
      sl.Add(line);
    end;
  // Кодировка UTF-8 с BOM для Excel
  sl.WriteBOM := True;
  sl.SaveToFile(selectedFile, TEncoding.UTF8);
  finally
    sl.Free;
  end;

  MessageDlg('Файл успешно сохранён: ' + selectedFile, mtInformation, [mbOK], 0);
end;
procedure TCompetitionResultsForm.UpdateInfo;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  InvalidateFinalSlots;
  if (fEvent.IsFinalOk) and (fEvent.HasFinal) then
    fEvent.Shooters.SortOrder:= soFinal
  else
    fEvent.Shooters.SortOrder:= soSeries;

  Caption:= format (Language ['CompetitionResultsForm'],[fEvent.Event.ShortName,fEvent.Event.Name]);

  lbShooters.Canvas.Font:= lbShooters.Font;
  lbShooters.Canvas.Font.Style:= [fsBold];

  if fEvent.Event.Stages< 2 then
    begin
      fRegularHeight:= 4+lbShooters.Canvas.TextHeight ('Mg')*2;
      fCompY:= 2;
      fFinalHeight1:= fRegularHeight+lbShooters.Canvas.TextHeight ('Mg');
      fFinalHeight2:= fRegularHeight+lbShooters.Canvas.TextHeight ('Mg')*2;
    end
  else
    begin
      fRegularHeight:= 4+lbShooters.Canvas.TextHeight ('Mg')*fEvent.Event.Stages;
      fCompY:= 2+lbShooters.Canvas.TextHeight ('Mg')*(fEvent.Event.Stages-1);
      fFinalHeight1:= fRegularHeight+lbShooters.Canvas.TextHeight ('Mg')*2;
      fFinalHeight2:= fFinalHeight1;
    end;

  lbShooters.ItemHeight:= fRegularHeight;

  lbShooters.Clear;

  SetLength (fShooters,fEvent.Shooters.Count);
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      sh:= fEvent.Shooters.Items [i];
      lbShooters.Items.Add (sh.Shooter.SurnameAndName);
      if (sh.Index> 0) and (sh.CompareTo (fEvent.Shooters.Items [sh.Index-1],fEvent.Shooters.SortOrder)= 0) then
        fShooters [i].fight:= true
      else if (sh.Index< fEvent.Shooters.Count-1) and
            (sh.CompareTo (fEvent.Shooters.Items [sh.Index+1],fEvent.Shooters.SortOrder)= 0) then
        fShooters [i].fight:= true
      else
        fShooters [i].fight:= false;
    end;
  if lbShooters.Count> 0 then
    lbShooters.ItemIndex:= 0;
end;

procedure TCompetitionResultsForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
  fTeamPStr:= Language ['CompetitionResultsForm.TeamStr'];
  fRegionPStr:= Language ['CompetitionResultsForm.RegStr'];
  fDistrictPStr:= Language ['CompetitionResultsForm.DistStr'];
end;

procedure TCompetitionResultsForm.lbShootersClick(Sender: TObject);
begin
  ResetSearch;
end;

procedure TCompetitionResultsForm.lbShootersDblClick(Sender: TObject);
begin
  OpenShooter (lbShooters.ItemIndex);
end;

procedure TCompetitionResultsForm.lbShootersDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  font_color: TColor;
  sh: TStartListEventShooterItem;
  s: THeaderSection;
  idx: integer;
  i,j,x,y,ys,h: integer;
  st: string;
  c: TColor;
  in_final: boolean;
  q: TQualificationItem;
  //bytotal: boolean;
begin
  with lbShooters.Canvas do
    begin
      in_final:= (fEvent.HasFinal) and (Index< fEvent.Event.FinalPlaces);
      if not (odSelected in State) then
        begin
          if in_final then
            Brush.Color:= clMoneyGreen;
        end;
      Brush.Style:= bsSolid;
      FillRect (Rect);
      Brush.Style:= bsClear;

      sh:= fEvent.Shooters.Items [Index];
      if fShooters [Index].fight then
        begin
          if not (odSelected in State) then
            Font.Color:= clRed;
        end;
      font_color:= Font.Color;

      s:= HeaderControl1.Sections [0];
          // Колонка "Место": для упражнений с финалом у первых FinalPlaces показываем метку финала
          if (fEvent.HasFinal) and (Index< fEvent.Event.FinalPlaces) and (sh.DNS<> dnsCompletely) and (not sh.OutOfRank) then
            begin
              // Финал: показываем букву "Ф" вместо места
              TextOut (Rect.Left+s.Left+2,Rect.Top+2,FINAL_MARK);
            end
          else if sh.OutOfRank then
            begin
              c:= Font.Color;
              Font.Color:= clBlue;
              TextOut (Rect.Left+s.Left+2,Rect.Top+2,OUT_OF_RANK_MARK);
              Font.Color:= c;
            end
          else
            begin
              st:= IntToStr (sh.Index+1);
              TextOut (Rect.Left+s.Left+2,Rect.Top+2,st);
            end;

      s:= HeaderControl1.Sections [1];
      if (fSearchNum<> '') and (odSelected in State) then
        begin
          c:= Font.Color;
          Font.Style:= [fsBold,fsUnderLine];
          Font.Color:= clYellow;
          TextOut (Rect.Left+s.Left+2,Rect.Top+2,fSearchNum);
          x:= TextWidth (fSearchNum);
          Font.Color:= c;
          Font.Style:= [];
          st:= sh.StartNumberStr;
          TextOut (Rect.Left+s.Left+2+x,Rect.Top+2,Copy (st,Length (fSearchNum)+1,Length (st)));
        end
      else
        TextOut (Rect.Left+s.Left+2,Rect.Top+2,sh.StartNumberStr);

      s:= HeaderControl1.Sections [2];
      TextOut (Rect.Left+s.Left+2,Rect.Top+2,IntToStr (sh.Position));

      s:= HeaderControl1.Sections [3];
      Font.Style:= [fsBold];
      if (fSearchStr<> '') and (odSelected in State) then
        begin
          c:= Font.Color;
          Font.Style:= [fsBold,fsUnderLine];
          Font.Color:= clYellow;
          TextOut (Rect.Left+s.Left+2,Rect.Top+2,fSearchStr);
          x:= TextWidth (fSearchStr);
          Font.Color:= c;
          Font.Style:= [fsBold];
          st:= sh.Shooter.Surname;
          TextOut (Rect.Left+s.Left+2+x,Rect.Top+2,Copy (st,Length (fSearchStr)+1,Length (st)));
        end
      else
        TextOut (Rect.Left+s.Left+2,Rect.Top+2,sh.Shooter.Surname);
      Font.Style:= [];
      Font.Size:= Font.Size-2;
      TextOut (Rect.Left+s.Left+2,Rect.Top+2+TextHeight ('Mg'),sh.Shooter.Name);
      Font.Size:= Font.Size+2;

      s:= HeaderControl1.Sections [4];
      Font.Style:= [fsBold];
      TextOut (Rect.Left+s.Left+2,Rect.Top+2,sh.Shooter.RegionsAbbr);
      y:= 2+TextHeight ('Mg');
      Font.Style:= [];
      Font.Size:= Font.Size-2;
      TextOut (Rect.Left+s.Left+2,Rect.Top+y,sh.Shooter.Town);
      Font.Size:= Font.Size+2;

      s:= HeaderControl1.Sections [5];
      case sh.DNS of
        dnsCompletely: begin
          if sh.DNSComment<> '' then
            TextOut (Rect.Left+s.Left+2,Rect.Top+2,sh.DNSComment)
          else
            TextOut (Rect.Left+s.Left+2,Rect.Top+2,DNS_MARK);
        end;
        dnsPartially: begin
          x:= Rect.Left+s.Left+2;
          if sh.SeriesCount> 0 then
            begin
              idx:= 0;
              y:= 2;
              Font.Size:= Font.Size-2;
              h:= TextHeight ('Mg');
              for i:= 1 to fEvent.Event.Stages do
                begin
                  x:= Rect.Left+s.Left+2;
                  st:= '';
                  Font.Style:= [];
                  for j:= 1 to fEvent.Event.SeriesPerStage do
                    begin
                      inc (idx);
                      if idx> sh.SeriesCount then
                        Font.Color:= clLtGray;
                      st:= sh.SerieStr(i,j);
                      TextOut (x,Rect.Top+y,st);
                      inc (x,TextWidth (fEvent.SerieTemplate+' '));
                    end;
                  Font.Style:= [fsBold];
                  Font.Color:= font_color;
                  if fEvent.Event.Stages> 1 then
                    begin
                      st:= sh.StageResultStr(i);
                      TextOut (x,Rect.Top+y,st);
                      inc (x,TextWidth (fEvent.CompTemplate+' '));
                      if i< fEvent.Event.Stages then
                        inc (y,h);
                    end;
                end;

              Font.Size:= Font.Size+2;
              st:= sh.CompetitionStr;
              TextOut (x,Rect.Top+2,st);
              inc (x,TextWidth (st)+10);
            end;
          st:= sh.DNSComment;
          Font.Style:= [];
          TextOut (x,Rect.Top+2,st);
        end;
        dnsNone: begin
          y:= 2;
          if sh.SeriesCount> 0 then
            begin
              idx:= 0;
              Font.Size:= Font.Size-2;
              ys:= y+TextHeight ('Mg');
              h:= TextHeight ('Mg');
              ys:= ys-h;
              x:= Rect.Left+s.Left+2;
              for i:= 1 to fEvent.Event.Stages do
                begin
                  x:= Rect.Left+s.Left+2;
                  st:= '';
                  Font.Style:= [];
                  for j:= 1 to fEvent.Event.SeriesPerStage do
                    begin
                      inc (idx);
                      if idx> sh.SeriesCount then
                        Font.Color:= clLtGray;
                      st:= sh.SerieStr(i,j);
                      TextOut (x,Rect.Top+ys,st);
                      inc (x,TextWidth (fEvent.SerieTemplate+' '));
                    end;
                  Font.Style:= [fsBold];
                  Font.Color:= font_color;
                  if fEvent.Event.Stages> 1 then
                    begin
                      st:= sh.StageResultStr(i);
                      TextOut (x,Rect.Top+ys,st);
                      inc (x,TextWidth (fEvent.CompTemplate+' '));
                      if i< fEvent.Event.Stages then
                        begin
                          inc (ys,h);
                          inc (y,h);
                        end;
                    end;
                end;

              Font.Size:= Font.Size+2;
              st:= sh.CompetitionStr;
              TextOut (x,Rect.Top+y,st);

              if sh.CompPriority> 0 then
                begin
                end;

              inc (y,TextHeight ('Mg'));

              if in_final then
                begin
                  if (sh.FinalShotsCount> 0) then
                    begin
                      if fEvent.Event.Stages< 2 then
                        inc (y,TextHeight ('Mg'));
                      st:= sh.FinalShotsStr;
                      Font.Style:= [];
                      Font.Size:= Font.Size-2;
                      TextOut (x-TextWidth (st)-10,Rect.Top+y,st);
                      Font.Size:= Font.Size+2;
                    end;

                  Font.Style:= [fsBold];
                  st:= sh.FinalResultStr;
                  TextOut (x,Rect.Top+y,st);
                  inc (y,TextHeight ('Mg'));
                  st:= sh.TotalResultStr;
                  TextOut (x,Rect.Top+y,st);
                end;
            end;
        end;
      end;

      s:= HeaderControl1.Sections [6];
      x:= s.Left+2;
      y:= fCompY;
      Font.Style:= [];
      if sh.CompShootOffStr<> '' then
        begin
          st:= '('+sh.CompShootOffStr+')';
          TextOut (x,Rect.Top+y,st);
          inc (x,TextWidth (st)+10);
        end;
      if sh.CompPriority> 0 then
        begin
          st:= '';
          for i:= 1 to sh.CompPriority do
            st:= st+'*';
          TextOut (x,Rect.Top+y,st);
        end;
      x:= s.Left+2;
      Font.Style:= [fsBold];
      y:= y+TextHeight ('Mg');
      if sh.FinalShotsCount> 0 then
        y:= y+TextHeight ('Mg');
      Font.Style:= [];
      if sh.FinalShootOffStr<> '' then
        begin
          st:= '('+sh.FinalShootOffStr+')';
          TextOut (x,Rect.Top+y,st);
          inc (x,TextWidth (st)+10);
        end;
      if sh.FinalPriority> 0 then
        begin
          st:= '';
          for i:= 1 to sh.FinalPriority do
            st:= st+'*';
          TextOut (x,Rect.Top+y,st);
        end;

      s:= HeaderControl1.Sections [7];
      x:= s.Left+2;
      y:= Rect.Top+2;
      if (sh.TeamPoints> 0) and (sh.TeamForPoints<> '') then
        begin
          st:= fTeamPStr+inttostr (sh.TeamPoints);
          TextOut (x,y,st);
          inc (x,TextWidth (st)+10);
        end;
      if (sh.RegionPoints> 0) and (sh.GiveRegionPoints) then
        begin
          st:= fRegionPStr+inttostr (sh.RegionPoints);
          TextOut (x,y,st);
          inc (x,TextWidth (st)+10);
        end;
      if (sh.DistrictPoints> 0) and (sh.GiveDistrictPoints) then
        begin
          st:= fDistrictPStr+inttostr (sh.DistrictPoints);
          TextOut (x,y,st);
        end;
      x:= s.Left+2;
      inc (y,TextHeight ('Mg'));

      q:= sh.Qualified{ (bytotal)};
      if q<> nil then
        begin
          st:= q.Name;
          if (sh.QualificationPoints> 0) then
            st:= st+':'+inttostr (sh.QualificationPoints);
          TextOut (x,y,st);
          inc (x,TextWidth (st)+10);
        end;
      if sh.RecordComment<> '' then
        begin
          st:= sh.RecordComment;
          TextOut (x,y,st);
          inc (x,TextWidth (st)+10);
        end;
      if sh.ManualPoints> 0 then
        begin
          st:= '+'+IntToStr (sh.ManualPoints);
          Font.Color:= clRed;
          TextOut (x,y,st);
        end;

    end;
end;

function TCompetitionResultsForm.Execute: boolean;
begin
  Result:= ShowModal= mrOk;
end;

procedure TCompetitionResultsForm.FormDestroy(Sender: TObject);
begin
  SetLength (fShooters,0);
end;

procedure TCompetitionResultsForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ADD: begin
      ResetSearch;
      ChangePriority (lbShooters.ItemIndex,+1,Shift= [ssShift]);
      Key:= 0;
    end;
    VK_SUBTRACT: begin
      ResetSearch;
      ChangePriority (lbShooters.ItemIndex,-1,Shift= [ssShift]);
      Key:= 0;
    end;
    VK_RETURN: begin
      ResetSearch;
      Key:= 0;
      OpenShooter (lbShooters.ItemIndex);
    end;
    VK_ESCAPE: begin
      ResetSearch;
      Key:= 0;
      Close;
    end;
    VK_F2: begin
      ResetSearch;
      Key:= 0;
      if lbShooters.ItemIndex>= 0 then
        EditManualPoints (lbShooters.ItemIndex);
    end;
    VK_F3: begin
      ResetSearch;
      Key:= 0;
      if lbShooters.ItemIndex>= 0 then
        EditRecordComment (lbShooters.ItemIndex);
    end;
  else
    if integer (Key)= integer (VkKeyScan ('=')) then
      begin
        ResetSearch;
        ChangePriority (lbShooters.ItemIndex,+1,Shift= [ssShift]);
      end
    else if integer (Key)= integer (VkKeyScan ('-')) then
      begin
        ResetSearch;
        ChangePriority (lbShooters.ItemIndex,-1,Shift= [ssShift]);
      end;
  end;
end;

procedure TCompetitionResultsForm.FormKeyPress(Sender: TObject; var Key: Char);
var
  idx: integer;
begin
  case Key of
    '0'..'9': begin
      fSearchStr:= '';
      idx:= DoSearchNum (fSearchNum+Key,0);
      if idx>= 0 then
        begin
          fSearchNum:= fSearchNum+Key;
          lbShooters.ItemIndex:= idx;
          lbShooters.Invalidate;
        end;
    end;
    'A'..'Z','a'..'z','А'..'Я','а'..'я': begin
      fSearchNum:= '';
      idx:= DoSearchStr (fSearchStr+Key,0);
      if idx>= 0 then
        begin
          fSearchStr:= fSearchStr+Key;
          lbShooters.ItemIndex:= idx;
          lbShooters.Invalidate;
        end;
    end;
    #8: begin // Backspace - удаление символа из строки поиска
      if fSearchStr <> '' then
        begin
          fSearchStr:= Copy(fSearchStr, 1, Length(fSearchStr) - 1);
          if fSearchStr <> '' then
            begin
              idx:= DoSearchStr(fSearchStr, 0);
              if idx >= 0 then
                begin
                  lbShooters.ItemIndex:= idx;
                  lbShooters.Invalidate;
                end;
            end
          else
            lbShooters.Invalidate;
        end
      else if fSearchNum <> '' then
        begin
          fSearchNum:= Copy(fSearchNum, 1, Length(fSearchNum) - 1);
          if fSearchNum <> '' then
            begin
              idx:= DoSearchNum(fSearchNum, 0);
              if idx >= 0 then
                begin
                  lbShooters.ItemIndex:= idx;
                  lbShooters.Invalidate;
                end;
            end
          else
            lbShooters.Invalidate;
        end;
    end;
    #27: begin // Escape - сброс поиска
      ResetSearch;
    end;
  end;
  Key:= #0;
end;

procedure TCompetitionResultsForm.lbShootersMeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
var
  sh: TStartListEventShooterItem;
begin
  sh:= fEvent.Shooters.Items [Index];
  if Index< fEvent.Event.FinalPlaces then
    begin
      if sh.FinalShotsCount> 0 then
        Height:= fFinalHeight2
      else
        Height:= fFinalHeight1;
    end
  else
    begin
      Height:= fRegularHeight;
    end;
end;

procedure TCompetitionResultsForm.btnResetFinalClick(Sender: TObject);
begin
  if MessageDlg (Language ['CompetitionResultsForm.ResetFinalPrompt'],mtConfirmation,[mbYes,mbNo],0)<> ID_YES then
    exit;
  fEvent.DeleteFinalResults;
  lbShooters.Invalidate;
end;

procedure TCompetitionResultsForm.btnResetResultsClick(Sender: TObject);
begin
  if MessageDlg (Language ['CompetitionResultsForm.ResetResultsPrompt'],mtConfirmation,[mbYes,mbNo],0)<> ID_YES then
    exit;
  fEvent.ResetResults;
  lbShooters.Invalidate;
end;

procedure TCompetitionResultsForm.ChangePriority(index, change: integer;
  shift: boolean);
var
  sh: TStartListEventShooterItem;
  ti: integer;
  p: integer;
begin
  sh:= fEvent.Shooters.Items [index];
  if (fEvent.Shooters.SortOrder= soFinal) and (sh.FinalResult10> 0) then
    begin
      if shift then
        begin
          p:= sh.CompPriority+change;
          if p< 0 then
            exit;
          sh.CompPriority:= p;
        end
      else
        begin
          p:= sh.FinalPriority+change;
          if p< 0 then
            exit;
          sh.FinalPriority:= p;
        end;
    end
  else
    begin
      p:= sh.CompPriority+change;
      if p< 0 then
        exit;
      sh.CompPriority:= p;
    end;
  ti:= lbShooters.TopIndex;
  UpdateInfo;
  lbShooters.TopIndex:= ti;
  lbShooters.ItemIndex:= sh.Index;
end;

procedure TCompetitionResultsForm.FormCreate(Sender: TObject);
begin
  Width:= round (Screen.Width * 0.75);
  Height:= round (Screen.Height * 0.75);
  LoadHeaderControlFromRegistry ('CompetitionResultsHC',HeaderControl1);
  UpdateLanguage;
  UpdateFonts;
  fHeaderChanged:= false;
  Position:= poScreenCenter;
  fSearchStr:= '';
  fSearchNum:= '';
  InvalidateFinalSlots;
  // Создаём кнопку "Список финалистов" программно, чтобы не менять DFM
  btnFinalistsPDF := TButton.Create(self);
  btnFinalistsPDF.Name := 'btnFinalistsPDF';
  btnFinalistsPDF.Parent := pnlButtons;
  btnFinalistsPDF.Caption := 'Список финалистов';
  btnFinalistsPDF.OnClick := btnFinalistsPDFClick;

  // Создаём кнопку "Финалисты в CSV" рядом
  btnFinalistsCSV := TButton.Create(self);
  btnFinalistsCSV.Name := 'btnFinalistsCSV';
  btnFinalistsCSV.Parent := pnlButtons;
  btnFinalistsCSV.Caption := 'Финалисты в CSV';
  btnFinalistsCSV.OnClick := btnFinalistsCSVClick;
  UpdateFonts;
end;

procedure TCompetitionResultsForm.HeaderControl1Resize(Sender: TObject);
begin
  with HeaderControl1 do
    Sections [Sections.Count-1].Width:= ClientWidth-Sections [Sections.Count-1].Left;
end;

procedure TCompetitionResultsForm.HeaderControl1SectionResize(
  HeaderControl: THeaderControl; Section: THeaderSection);
begin
  fHeaderChanged:= true;
  lbShooters.Invalidate;
  HeaderControl1Resize (self);
end;

procedure TCompetitionResultsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if fHeaderChanged then
    SaveHeaderControlToRegistry ('CompetitionResultsHC',HeaderControl1);
end;

function TCompetitionResultsForm.DoSearchNum(S: string;
  AFrom: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= AFrom to fEvent.Shooters.Count-1 do
    begin
      if copy (fEvent.Shooters.Items [i].StartNumberStr,1,Length (S))= S then
        begin
          Result:= i;
          break;
        end;
    end;
end;

function TCompetitionResultsForm.DoSearchStr(S: string;
  AFrom: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= AFrom to fEvent.Shooters.Count-1 do
    begin
      if AnsiSameText (copy (fEvent.Shooters.Items [i].Shooter.Surname,1,Length (S)),S) then
        begin
          Result:= i;
          break;
        end;
    end;
end;

procedure TCompetitionResultsForm.EditManualPoints(index: integer);
var
  sh: TStartListEventShooterItem;
  st: string;
  p,i: integer;
begin
  sh:= fEvent.Shooters.Items [index];
  if sh= nil then
    exit;
  st:= IntToStr (sh.ManualPoints);
  if InputQuery (Language ['ManualPoints'],Language ['ManualPointsPrompt'],st) then
    begin
      val (st,p,i);
      sh.ManualPoints:= p;
      lbShooters.Invalidate;
    end;
end;

procedure TCompetitionResultsForm.EditRecordComment(index: integer);
var
  sh: TStartListEventShooterItem;
  st: string;
begin
  sh:= fEvent.Shooters.Items [index];
  if sh= nil then
    exit;
  st:= sh.RecordComment;
  if InputQuery (Language ['RecordCaption'],Language ['RecordPrompt'],st) then
    begin
      sh.RecordComment:= Trim (st);
      lbShooters.Invalidate;
    end;
end;

procedure TCompetitionResultsForm.OpenShooter(index: integer);
var
  ti: integer;
  sh: TStartListEventShooterItem;
  srd: TShooterSeriesDialog;
begin
  if (index< 0) or (index>= fEvent.Shooters.Count) then
    exit;
  sh:= fEvent.Shooters.Items [index];
  srd:= TShooterSeriesDialog.Create (self);
  srd.AttributesOn:= true;
  srd.RecordCommentOn:= true;
  srd.CompShootOffOn:= true;
  srd.FinalOn:= fEvent.HasFinal;
  srd.LargeSeriesFont:= false;
  srd.Shooter:= sh;
  srd.Execute;
  srd.Free;
  ti:= lbShooters.TopIndex;
  UpdateInfo;
  lbShooters.TopIndex:= ti;
  lbShooters.ItemIndex:= sh.Index;
end;

procedure TCompetitionResultsForm.ResetSearch;
begin
  if (fSearchStr<> '') or (fSearchNum<> '') then
    begin
      fSearchStr:= '';
      fSearchNum:= '';
      lbShooters.Invalidate;
    end;
end;

end.

