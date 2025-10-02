{$a-,j+}
unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types, Vcl.Graphics, System.Win.Registry,
  System.DateUtils, System.StrUtils, System.Character, Vcl.Printers, System.Math,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Winapi.CommDlg, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.UITypes, Vcl.FileCtrl, Vcl.ComCtrls, 
  Vcl.Imaging.pngimage,  // Заменено PNGimage на встроенную поддержку PNG
  MyPrint,

  Data,
  // PDF, // Временно отключено - заменить на современную PDF библиотеку
  SysFont,
  MyStrings,
  wb_registry,

  form_startinfo,
  form_viewresults,
  form_enterresults,
  form_addtostart,
  form_printprotocol,
  form_table,
  form_settings,
  form_prefered,
  form_move,
  form_startlistmanager,
  form_results,
  form_shooter,
  form_startshooters,
  form_managestart,
  form_startstats,
  form_ascor,
  form_datepicker,

  ListBox_Shooters,

  MyLanguage,
  embedded_language_complete,
  MyTables,
  wb_barcodes,
  ctrl_language;

type
  TStartListPanel= class (TCustomControl)
  private
    fStart: TStartList;
    fStartForm: TManageStartForm;
    btnOpenStart: TButton;
    btnPrintOut: TButton;
    btnClose: TButton;
    btnShooters: TButton;
    btnStats: TButton;
    fCaptionRect: TRect;
    procedure set_Start(const Value: TStartList);
    procedure ArrangeControls;
    procedure WMEraseBkgnd (var M: TMessage); message WM_ERASEBKGND;
    procedure WMStartListInfoChanged (var M: TMessage); message WM_STARTLISTINFOCHANGED;
    procedure WMStartNumbersPrintout (var M: TMessage); message WM_STARTNUMBERSPRINTOUT;
    procedure WMStartListShootersChanged (var M: TMessage); message WM_STARTLISTSHOOTERSCHANGED;
    procedure OnDeleteStart (Sender: TObject);
  public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
    property StartList: TStartList read fStart write set_Start;
    procedure Paint; override;
    procedure Resize; override;
    procedure UpdateLanguage;
  end;


type
  TGroupSettingsItem= class (TCollectionItem)
  private
    fFilter: TEventsFilter;
    fCurrentEvent: TEventItem;
    fCurrentShooter: integer;
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
  end;

  TGroupSettings= class (TCollection)
  private
    function get_GroupSettings(index: integer): TGroupSettingsItem;
  public
    constructor Create;
    function Add: TGroupSettingsItem; overload;
    property Items [index: integer]: TGroupSettingsItem read get_GroupSettings; default;
  end;

// Временные заглушки для PDF типов до восстановления PDF функциональности  
type
  // Используем типы из MyPrint - только минимальные заглушки здесь
  TPDFCanvas = class
  public
    Font: TFont;
    Pen: TPen;
    function TextWidth(const Text: string): Integer;
    function TextHeight(const Text: string): Integer;
    procedure TextOut(X, Y: Integer; const Text: string);
    procedure MoveTo(X, Y: Integer);
    procedure LineTo(X, Y: Integer);
    constructor Create;
    destructor Destroy; override;
  end;
  
  TPDFOutlineNode = class
  public
    Action: TObject;
  end;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    mnuOpenData: TMenuItem;
    OpenDataDialog: TOpenDialog;
    N2: TMenuItem;
    mnuSaveData: TMenuItem;
    mnuSaveAs: TMenuItem;
    SaveDataDialog: TSaveDialog;
    mnuStarts: TMenuItem;
    mnuNewStart: TMenuItem;
    pnlGroup: TPanel;
    TimerAutoSave: TTimer;
    mnuGroups: TMenuItem;
    mnuAddGroup: TMenuItem;
    mnuDeleteGroup: TMenuItem;
    mnuResults: TMenuItem;
    mnuViewResults: TMenuItem;
    mnuEnterResults: TMenuItem;
    mnuOptions: TMenuItem;
    mnuRateTable: TMenuItem;
    mnuSettings: TMenuItem;
    mnuRenameGroup: TMenuItem;
    mnuMoveGroupUp: TMenuItem;
    mnuMoveGroupDown: TMenuItem;
    Splitter1: TSplitter;
    pnlGroupInfo: TPanel;
    cbEvents: TComboBox;
    lEvent: TLabel;
    mnuShooters: TMenuItem;
    mnuOpenShooterData: TMenuItem;
    mnuOpenShooterResults: TMenuItem;
    mnuAddShooter: TMenuItem;
    mnuMoveShooter: TMenuItem;
    mnuDeleteShooter: TMenuItem;
    pnlGroupsActions: TPanel;
    mnuPhotoFile: TMenuItem;
    mnuOpenStart: TMenuItem;
    StatusBar1: TStatusBar;
    mnuAutoSave: TMenuItem;
    mnuAutoSave5: TMenuItem;
    mnuAutoSave10: TMenuItem;
    mnuAutoSave30: TMenuItem;
    mnuAutoSave60: TMenuItem;
    mnuAutoSaveOff: TMenuItem;
    N3: TMenuItem;
    mnuManageStart: TMenuItem;
    mnuCloseStart: TMenuItem;
    mnuPrintStartNumbers: TMenuItem;
    mnuPrinter: TMenuItem;
    mnuTruncateClubs: TMenuItem;
    mnuAddToStartByOrder: TMenuItem;
    mnuExportToFile: TMenuItem;
    ExportDialog: TSaveDialog;
    mnuImportFromFile: TMenuItem;
    ImportDialog: TOpenDialog;
    mnuPrintList: TMenuItem;
    mnuMerge: TMenuItem;
    MergeDataDialog: TOpenDialog;
    mnuPrintInStart: TMenuItem;
    mnuImportStart: TMenuItem;
    mnuStartManager: TMenuItem;
    mnuProtocolFont: TMenuItem;
    FontDialog1: TFontDialog;
    mnuEachDayBackup: TMenuItem;
    mnuPurgeDailyBackups: TMenuItem;
    pmPopup: TPopupMenu;
    mnuMoveShooterPM: TMenuItem;
    mnuOpenShooterDataPM: TMenuItem;
    mnuShooterResultsPM: TMenuItem;
    mnuAddShooterPM: TMenuItem;
    mnuDeleteShooterPM: TMenuItem;
    mnuSaveListToPDF: TMenuItem;
    dlgSaveToPDF: TSaveDialog;
    N1: TMenuItem;
    mnuSaveRatingToPDF: TMenuItem;
    dlgSaveRating: TSaveDialog;
    mnuPreferedEvents: TMenuItem;
    N4: TMenuItem;
    mnuAddToStartPM: TMenuItem;
    N5: TMenuItem;
    N7: TMenuItem;
    mnuAddToStart: TMenuItem;
    mnuSaveOnExit: TMenuItem;
    N6: TMenuItem;
    mnuExit: TMenuItem;
    mnuStartShooters: TMenuItem;
    mnuEmbedFontFiles: TMenuItem;
    mnuLanguage: TMenuItem;
    mnuRussian: TMenuItem;
    mnuEnglish: TMenuItem;
    mnuExportNoChamps: TMenuItem;
    mnuCheck: TMenuItem;
    tvGroups: TTreeView;
    mnuCompareBySeries: TMenuItem;
    mnuImport: TMenuItem;
    mnuImportBase: TMenuItem;
    mnuProtocolMakerSign: TMenuItem;
    mnuInnerTens: TMenuItem;
    mnuHelp: TMenuItem;
    mnuAbout: TMenuItem;
    mnuRatingDate: TMenuItem;
    mnuNow: TMenuItem;
    mnuSpecificDate: TMenuItem;
    mnuStartNumbersMode: TMenuItem;
    mnuCSV: TMenuItem;
    dlgSaveToCSV: TSaveDialog;
    mnuSelectInactive: TMenuItem;
    FontDialog2: TFontDialog;
    PrintDialog1: TPrintDialog;
    mnuStartNumbersFont: TMenuItem;
    procedure mnuStartNumbersFontClick(Sender: TObject);
    procedure mnuSelectInactiveClick(Sender: TObject);
    procedure mnuCSVClick(Sender: TObject);
    procedure mnuStartNumbersModeClick(Sender: TObject);
    procedure mnuSpecificDateClick(Sender: TObject);
    procedure mnuNowClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure mnuInnerTensClick(Sender: TObject);
    procedure mnuProtocolMakerSignClick(Sender: TObject);
    procedure mnuImportBaseClick(Sender: TObject);
    procedure mnuCompareBySeriesClick(Sender: TObject);
    procedure mnuCheckClick(Sender: TObject);
    procedure mnuExportNoChampsClick(Sender: TObject);
    procedure mnuEnglishClick(Sender: TObject);
    procedure mnuRussianClick(Sender: TObject);
    procedure mnuEmbedFontFilesClick(Sender: TObject);
    procedure mnuStartShootersClick(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuSaveOnExitClick(Sender: TObject);
    procedure mnuAddToStartClick(Sender: TObject);
    procedure mnuAddToStartPMClick(Sender: TObject);
    procedure mnuPreferedEventsClick(Sender: TObject);
    procedure pnlGroupInfoResize(Sender: TObject);
    procedure mnuSaveRatingToPDFClick(Sender: TObject);
    procedure mnuSaveListToPDFClick(Sender: TObject);
    procedure mnuDeleteShooterPMClick(Sender: TObject);
    procedure mnuAddShooterPMClick(Sender: TObject);
    procedure mnuShooterResultsPMClick(Sender: TObject);
    procedure mnuOpenShooterDataPMClick(Sender: TObject);
    procedure pnlShootersExit(Sender: TObject);
    procedure pnlShootersEnter(Sender: TObject);
    procedure tvGroupsExit(Sender: TObject);
    procedure tvGroupsEnter(Sender: TObject);
    procedure mnuOpenDataClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mnuSaveDataClick(Sender: TObject);
    procedure mnuSaveAsClick(Sender: TObject);
    procedure btnCloseStartClick(Sender: TObject);
    procedure TimerAutoSaveTimer(Sender: TObject);
    procedure tvGroupsChange(Sender: TObject; Node: TTreeNode);
    procedure FormDestroy(Sender: TObject);
    procedure mnuAddGroupClick(Sender: TObject);
    procedure mnuDeleteGroupClick(Sender: TObject);
    procedure mnuViewResultsClick(Sender: TObject);
    procedure mnuRateTableClick(Sender: TObject);
    procedure mnuSettingsClick(Sender: TObject);
//    procedure HeaderControl1SectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
//    procedure HeaderControl1Resize(Sender: TObject);
    procedure mnuRenameGroupClick(Sender: TObject);
    procedure tvGroupsEdited(Sender: TObject; Node: TTreeNode; var S: String);
    procedure HeaderControl1SectionClick(HeaderControl: THeaderControl; Section: THeaderSection);
    procedure mnuMoveGroupUpClick(Sender: TObject);
    procedure mnuMoveGroupDownClick(Sender: TObject);
    procedure tvGroupsCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure mnuEnterResultsClick(Sender: TObject);
    procedure mnuAddShooterClick(Sender: TObject);
    procedure mnuDeleteShooterClick(Sender: TObject);
    procedure tvGroupsKeyPress(Sender: TObject; var Key: Char);
    procedure tvGroupsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mnuPhotoFileClick(Sender: TObject);
    procedure cbEventsKeyPress(Sender: TObject; var Key: Char);
    procedure cbEventsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnManageClick(Sender: TObject);
    procedure mnuAutoSaveOffClick(Sender: TObject);
    procedure mnuAutoSave5Click(Sender: TObject);
    procedure mnuAutoSave10Click(Sender: TObject);
    procedure mnuAutoSave30Click(Sender: TObject);
    procedure mnuAutoSave60Click(Sender: TObject);
    procedure btnPrintoutClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mnuManageStartClick(Sender: TObject);
    procedure mnuCloseStartClick(Sender: TObject);
    procedure mnuPrintStartNumbersClick(Sender: TObject);
    procedure mnuNewStartClick(Sender: TObject);
    procedure mnuPrinterClick(Sender: TObject);
    procedure mnuTruncateClubsClick(Sender: TObject);
    procedure mnuAddToStartByOrderClick(Sender: TObject);
    procedure mnuExportToFileClick(Sender: TObject);
    procedure mnuImportFromFileClick(Sender: TObject);
    procedure mnuPrintListClick(Sender: TObject);
    procedure mnuMergeClick(Sender: TObject);
    procedure mnuPrintInStartClick(Sender: TObject);
    procedure mnuOpenStartClick(Sender: TObject);
    procedure mnuStartManagerClick(Sender: TObject);
    procedure mnuProtocolFontClick(Sender: TObject);
    procedure mnuOpenShooterDataClick(Sender: TObject);
    procedure mnuOpenShooterResultsClick(Sender: TObject);
    procedure mnuEachDayBackupClick(Sender: TObject);
    procedure mnuPurgeDailyBackupsClick(Sender: TObject);
  private
    { Private declarations }
    fDoOpenData: boolean;
    fShootersLb: TShootersListBox;
    fGroup: TGroupItem;
    fGroupSettings: TGroupSettingsItem;
    fSortOrder: TShootersSortOrder;
    fGroupsSettings: TGroupSettings;
    cbEventsMaxWidth: integer;
    fAutoSave: integer;
    fAutoPrintStartNumbers: boolean;
    fAddToStartByOrder: boolean;
    fLastTeamForResults: string;
    fLastTeamForPoints: string;
    fLastOpenedDataFileName: string;
    fEachDayBackup: boolean;
    fStartForm: TManageStartForm;
    fStartPanel: TStartListPanel;
    fSaveDataOnExit: boolean;
    fLanguage: TLanguage;
    function OpenData (FileName: string): boolean;
    procedure DataOpened;
    function GetDataFileName (var FileName: string): boolean;
    procedure UpdateStartPanel;
    function CloseStart: boolean;
    procedure LoadGroupNames;
    function OpenGroup (index: integer): boolean;
    function EditGroupSettings (AGroup: TGroupItem): boolean;
    procedure AddGroup;
    procedure DeleteGroup (AGroup: TGroupItem);
    procedure ViewResults;
    procedure EnterResults;
    procedure OpenRatingTable;
    procedure OpenDataSettings;
    procedure MoveGroupUp (AGroup: TGroupItem);
    procedure MoveGroupDown (AGroup: TGroupItem);
    procedure OnEventChange (Sender: TObject);
    procedure OnShooterDblClick (Sender: TObject);
    procedure OpenShooterResults (AShooter: TShootersFilterItem);
    procedure OpenShooterData (AShooter: TShooterItem);
    procedure LoadEventsFilter (AGroup: TGroupItem);
    procedure UpdateEventsCombo;
    procedure OnMoveToGroup (Sender: TObject);
    procedure OnShootersKeyDown (Sender: TObject; var Key: word; State: TShiftState);
    procedure DeleteShooters (index: integer);
    procedure DeleteShooter (AShooter: TShootersFilterItem; NoQuestions: boolean);
    procedure UpdateMoveMenu;
    procedure AddToStartList (ListBox: TShootersListBox); overload;
    function AddToStartList (Shooter: TShooterItem; var LastTeamForResults: string; var LastTeamForPoints: string): boolean; overload;
    procedure MoveToGroup (AGroup: TGroupItem);
    procedure SaveData;
    procedure UpdateShootersListBox;
    procedure UpdateStartMenu;
    function NewStart: boolean;
//    procedure CheckFileAssociations;
    procedure PurgeDailyBackups;
    procedure OnCloseStart (Sender: TObject);
    procedure SaveAllRatingToPDF;
    procedure UpdateLanguage;
    procedure RunSplash;
    procedure ShowSplash (Sender: TObject);
    procedure StopSplash (Sender: TObject);
    procedure EditGroupPreferedEvents (AGroup: TGroupItem);
//    procedure CMSysFontChanged (var Msg: TMessage); message CM_SYSFONTCHANGED;
    procedure UpdateFonts;
    procedure MoveShooters;
    procedure btnShootersClick (Sender: TObject);
    procedure btnStatsClick (Sender: TObject);
    procedure ChangeLanguage (ALanguage: TLanguage);
//    procedure WMChangeLanguage (var Msg: TMessage); message WM_CHANGELANGUAGE;
    procedure OnChangeMark (Sender: TObject);
    procedure PrintShootersList (Prn: TObject; Criteria: TPrintListCriteria);
    procedure OnAppMessage (var M: TMsg; var Handled: boolean);
    procedure UpdateRatingDate;
    procedure UpdateRatingDateMenu;
    procedure CheckGroupGender;
    procedure SelectInactiveShooters (d: TDate);
  public
    function GetActiveDataFileName: string;
    procedure RefreshGroupTree;
  end;

var
  MainForm: TMainForm;
  fData: TData;
  fDataFileName: string;
  EmbedFontFilesToPDF: Boolean;  // Временная переменная для PDF функциональности

function GetCurrentDataFileName: string;

implementation

{$R *.dfm}

// Функция для правильного отображения русского текста из базы данных
function FixRussianDisplay(const S: string): string;
begin
  // Данные уже в правильной Unicode кодировке, возвращаем как есть
  // Сохраняем все символы включая переносы строк
  Result := S;
end;

function TMainForm.GetActiveDataFileName: string;
begin
  Result := fDataFileName;
end;

procedure TMainForm.RefreshGroupTree;
var
  SelectedIndex: Integer;
begin
  if (fData = nil) or (tvGroups = nil) then
    Exit;

  if fGroup <> nil then
    SelectedIndex := fGroup.Index
  else
    SelectedIndex := -1;

  LoadGroupNames;

  if (SelectedIndex >= 0) and
     (tvGroups.Items.Count > 0) and
     (tvGroups.Items[0].Count > SelectedIndex) then
  begin
    tvGroups.Selected := tvGroups.Items[0].Item[SelectedIndex];
  end;
end;

// Реализация PDF заглушек
constructor TPDFCanvas.Create;
begin
  inherited Create;
  Font := TFont.Create;
  Pen := TPen.Create;
end;

destructor TPDFCanvas.Destroy;
begin
  Font.Free;
  Pen.Free;
  inherited Destroy;
end;

function TPDFCanvas.TextWidth(const Text: string): Integer;
begin
  Result := Length(Text) * 8; // Заглушка
end;

function TPDFCanvas.TextHeight(const Text: string): Integer;
begin
  Result := Font.Size;  // Простая заглушка
end;

procedure TPDFCanvas.TextOut(X, Y: Integer; const Text: string);
begin
  // Заглушка
end;

procedure TPDFCanvas.MoveTo(X, Y: Integer);
begin
  // Заглушка - ничего не делаем
end;

procedure TPDFCanvas.LineTo(X, Y: Integer);
begin
  // Заглушка - ничего не делаем
end;

const
  MARKED_STR: string= 'Отмечено: %d';
  RUSSIAN_CHARSET = 204;  // Временная константа для PDF функциональности
  PROTOCOL_CHARSET = 204; // Временная константа для протоколов

procedure TMainForm.mnuOpenDataClick(Sender: TObject);
var
  filename: string;
begin
  if GetDataFileName (filename) then
    begin
      if OpenData (filename) then
        begin
        end;
    end;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
//  CheckFileAssociations;
  if fDoOpenData then
    begin
      fDoOpenData:= false;
      if ParamCount> 0 then
        begin
          OpenData (ExpandFileName (paramstr (1)));
        end
      else
        begin
          OpenData (fLastOpenedDataFileName);
        end;
    end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  Reg: TRegistry;
  i: integer;
  lastdataid: string;
  lv: integer;
  lname: string;
begin
  fData:= nil;
  fDoOpenData:= false;

  Application.OnMessage:= OnAppMessage;

  fGroup:= nil;
  fGroupsSettings:= TGroupSettings.Create;
  fGroupSettings:= nil;
  fSortOrder:= ssoRating;

  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey ('\Software\007Soft\WinBASE',true) then
      begin
        if Reg.ValueExists ('LastOpenedData') then
          lastdataid:= Reg.ReadString ('LastOpenedData')
        else
          lastdataid:= '';
        if Reg.ValueExists ('WindowState') then
          begin
            i:= Reg.ReadInteger ('WindowState');
            case TWindowState (i) of
              wsNormal,wsMinimized: begin
                Position:= poDesigned;
                WindowState:= wsNormal;
                if Reg.ValueExists ('WindowLeft') then
                  Left:= Reg.ReadInteger ('WindowLeft');
                if Reg.ValueExists ('WindowTop') then
                  Top:= Reg.ReadInteger ('WindowTop');
                if Reg.ValueExists ('WindowWidth') then
                  Width:= Reg.ReadInteger ('WindowWidth');
                if Reg.ValueExists ('WindowHeight') then
                  Height:= Reg.ReadInteger ('WindowHeight');
              end;
              wsMaximized: begin
                Position:= poDesigned;
                WindowState:= wsMaximized;
              end;
            end;
          end
        else
          Position:= poDefault;
        if Reg.ValueExists ('Splitter') then
          tvGroups.Width:= Reg.ReadInteger ('Splitter');
        TimerAutoSave.Enabled:= false;
        if Reg.ValueExists ('AutoSave') then
          fAutoSave:= Reg.ReadInteger ('AutoSave')
        else
          fAutoSave:= 0;
        case fAutoSave of
          5: mnuAutoSave5.Checked:= true;
          10: mnuAutoSave10.Checked:= true;
          30: mnuAutoSave30.Checked:= true;
          60: mnuAutoSave60.Checked:= true;
        else
          mnuAutoSaveOff.Checked:= true;
        end;
        if Reg.ValueExists ('AutoPrintStartNumbers') then
          fAutoPrintStartNumbers:= Reg.ReadBool ('AutoPrintStartNumbers')
        else
          fAutoPrintStartNumbers:= true;
        if Reg.ValueExists ('StartNumbersFontName') then
          START_NUMBERS_FONT_NAME:= Reg.ReadString ('StartNumbersFontName');
        if Reg.ValueExists ('TruncatePrintedClubs') then
          Global_TruncatePrintedClubs:= Reg.ReadBool ('TruncatePrintedClubs')
        else
          Global_TruncatePrintedClubs:= false;
        if Reg.ValueExists ('CompareBySeries') then
          Global_CompareBySeries:= Reg.ReadBool ('CompareBySeries')
        else
          Global_CompareBySeries:= true;
        if Reg.ValueExists ('AddToStartByOrder') then
          fAddToStartByOrder:= Reg.ReadBool ('AddToStartByOrder')
        else
          fAddToStartByOrder:= false;
        
        // Инициализация переменных для команд при заявке на упражнения
        fLastTeamForResults:= '';
        fLastTeamForPoints:= '';
        if Reg.ValueExists ('EachDayBackup') then
          fEachDayBackup:= Reg.ReadBool ('EachDayBackup')
        else
          fEachDayBackup:= true;
        if Reg.ValueExists ('SaveDataOnExit') then
          fSaveDataOnExit:= Reg.ReadBool ('SaveDataOnExit')
        else
          fSaveDataOnExit:= false;
{        if Reg.ValueExists ('EmbedFontFilesToPDF') then
          EmbedFontFilesToPDF:= Reg.ReadBool ('EmbedFontFilesToPDF')
        else}
          EmbedFontFilesToPDF:= true;
        if Reg.ValueExists ('Language') then
          lv:= Reg.ReadInteger ('Language')
        else
          lv:= -1;
        case lv of
          LANG_RUSSIAN: fLanguage:= lRussian;
          LANG_ENGLISH: fLanguage:= lEnglish;
        else
          fLanguage:= lRussian;
        end;
        if Reg.ValueExists ('InnerTens') then
          Global_GetInnerTensFromAscor:= Reg.ReadBool ('InnerTens')
        else
          Global_GetInnerTensFromAscor:= true;

        if Reg.ValueExists ('PrintTwoStartNumbersPerPage') then
          PrintTwoStartNumbersOnPage:= Reg.ReadBool ('PrintTwoStartNumbersPerPage');

        if Reg.ValueExists ('PrintJuryInProtocols') then
          Global_PrintJury:= Reg.ReadBool ('PrintJuryInProtocols')
        else
          Global_PrintJury:= false;

        if Reg.ValueExists ('PrintSecreteryInProtocols') then
          Global_PrintSecretery:= Reg.ReadBool ('PrintSecreteryInProtocols')
        else
          Global_PrintSecretery:= true;

        mnuTruncateClubs.Checked:= Global_TruncatePrintedClubs;
        mnuCompareBySeries.Checked:= Global_CompareBySeries;
        mnuEachDayBackup.Checked:= fEachDayBackup;
        mnuAddToStartByOrder.Checked:= fAddToStartByOrder;
        mnuSaveOnExit.Checked:= fSaveDataOnExit;
        mnuEmbedFontFiles.Checked:= EmbedFontFilesToPDF;
        mnuInnerTens.Checked:= Global_GetInnerTensFromAscor;
        mnuStartNumbersMode.Checked:= PrintTwoStartNumbersOnPage;
        Reg.CloseKey;
      end;
    if paramcount> 0 then
      begin
        fDoOpenData:= true;
      end;
    if lastdataid<> '' then
      begin
        if Reg.OpenKey ('\Software\007Soft\WinBASE\'+lastdataid,false) then
          begin
            if Reg.ValueExists ('FileName') then
              begin
                if Reg.ValueExists ('FileName') then
                  begin
                    fLastOpenedDataFileName:= Reg.ReadString ('FileName');
                    fDoOpenData:= true;
                  end;
              end;
            Reg.CloseKey;
          end;
      end;
  finally
    Reg.Free;
  end;

  case fLanguage of
    lRussian: begin
      lname:= 'RUSSIAN';
      mnuRussian.Checked:= true;
    end;
    lEnglish: begin
      lname:= 'ENGLISH';
      mnuEnglish.Checked:= true;
    end;
  else
    lname:= 'RUSSIAN';
  end;
  
  // Сначала пробуем загрузить из внешнего файла (приоритет)
  if FileExists('russian.wbl') and FileExists('english.wbl') then
  begin
    // Внешние файлы есть - используем их
    try
      if fLanguage = lRussian then
        Language.LoadFromTextFile('russian.wbl')
      else
        Language.LoadFromTextFile('english.wbl');
    except
      // Если ошибка загрузки файла - используем встроенные данные
      if fLanguage = lRussian then
        LoadEmbeddedRussian
      else
        LoadEmbeddedEnglish;
    end;
  end
  else
  begin
    // Внешних файлов нет - используем встроенные данные
    if fLanguage = lRussian then
      LoadEmbeddedRussian
    else
      LoadEmbeddedEnglish;
  end;

  fShootersLb:= TShootersListBox.Create (pnlGroup);
//  fShootersLb.Font.Style:= [fsBold];
  fShootersLb.Name:= 'GroupHC';
  fShootersLb.Align:= alClient;
  fShootersLb.ParentFont:= true;
  fShootersLb.Color:= pnlGroup.Color;
  fShootersLb.ParentCtl3D:= false;
  fShootersLb.Ctl3D:= true;
  fShootersLb.BorderWidth:= 0;
  fShootersLb.Header.OnSectionClick:= HeaderControl1SectionClick;
  fShootersLb.OnDblClick:= OnShooterDblClick;
  fShootersLb.OnKeyDown:= OnShootersKeyDown;
  fShootersLb.PopupMenu:= pmPopup;
  fShootersLb.Parent:= pnlGroup;
  fShootersLb.OnChangeMark:= OnChangeMark;
  fShootersLb.ItemExtraHeight:= 10;
  fShootersLb.OnExit:= pnlShootersExit;
  fShootersLb.OnEnter:= pnlShootersEnter;

  fStartPanel:= TStartListPanel.Create (self);
  fStartPanel.Align:= alTop;
  fStartPanel.Visible:= false;
  fStartPanel.Parent:= self;
  fStartPanel.Height:= 64;
  fStartPanel.btnOpenStart.OnClick:= btnManageClick;
  fStartPanel.btnPrintOut.OnClick:= btnPrintoutClick;
  fStartPanel.btnShooters.OnClick:= btnShootersClick;
  fStartPanel.btnClose.OnClick:= btnCloseStartClick;
  fStartPanel.btnStats.OnClick:= btnStatsClick;

  // Принудительно устанавливаем русский язык
  fLanguage := lRussian;
  mnuRussian.Checked := true;
  mnuEnglish.Checked := false;
  
  UpdateLanguage;
  
  UpdateFonts;

  LoadHeaderControlFromRegistry ('GroupHC',fShootersLb.Header);

  fStartPanel.ArrangeControls;

  RunSplash;
end;

function TMainForm.OpenData(FileName: string): boolean;
var
  data: TData;
  Reg: TRegistry;
  m: string;
begin
  Result:= false;
  if not FileExists (FileName) then
    begin
      m:= format (Language ['MainForm.DataFileNotFound'],[AnsiUpperCase (filename)]);
      MessageDlg (m,mtError,[mbOk],0);
      exit;
    end;
  TimerAutoSave.Enabled:= false;
  data:= TData.Create;
  Screen.Cursor:= crHourGlass;
  Application.ProcessMessages;
  try
    data.LoadFromFile (FileName);
    if (fData<> nil) and (fData.ActiveStart<> nil) then
      CloseStart;
    tvGroups.Items.Clear;
    if fData<> nil then
      fData.Free;
    fGroup:= nil;
    fData:= data;
    fDataFileName:= FileName;
    Reg:= TRegistry.Create;
    try
      Reg.RootKey:= HKEY_CURRENT_USER;
      if Reg.OpenKey ('\Software\007Soft\WinBASE\'+GUIDToString (fData.DataID),true) then
        begin
          Reg.WriteString ('Name',fData.Name);
          if Reg.ValueExists ('ImagesFolder') then
            fData.ImagesFolder:= Reg.ReadString ('ImagesFolder')
          else
            fData.ImagesFolder:= IncludeTrailingBackslash (ExtractFileDir (FileName));
          Reg.CloseKey;
        end;
      if Reg.OpenKey ('\Software\007Soft\WinBASE',true) then
        begin
          Reg.WriteString ('LastOpenedData',GuidToString (fData.DataID));
          Reg.CloseKey;
        end;
    finally
      Reg.Free;
    end;
    DataOpened;
    Result:= true;
  except
    on EInvalidDataFile do
      begin
        data.Free;
        MessageDlg (Language ['InvalidDataFile'],mtError,[mbOk],0);
      end;
    on EInvalidDataFileVersion do
      begin
        data.Free;
        MessageDlg (Language ['InvalidDataFileVersion'],mtError,[mbOk],0);
      end;
    on EDataFileCorrupt do
      begin
        data.Free;
        MessageDlg (Language ['DataFileCorrupt'],mtError,[mbOk],0);
      end
    else
      begin
        data.Free;
        m:= format (Language ['MainForm.CannotOpenData'],[AnsiUpperCase (filename)]);
        MessageDlg (m,mtError,[mbOk],0);
      end;
  end;
  Screen.Cursor:= crDefault;
end;

function TMainForm.GetDataFileName(var FileName: string): boolean;
begin
  if OpenDataDialog.Execute then
    begin
      FileName:= OpenDataDialog.FileName;
      Result:= true;
    end
  else
    Result:= false;
end;

procedure TMainForm.mnuSaveDataClick(Sender: TObject);
begin
  if fData= nil then
    exit;
  SaveData;
end;

procedure TMainForm.mnuSaveAsClick(Sender: TObject);
var
  fn: string;
begin
  if fData= nil then
    exit;
  SaveDataDialog.FileName:= fDataFileName;
  fn:= fDataFileName;
  fDataFileName:= '';
  SaveData;
  if fDataFileName= '' then
    fDataFileName:= fn;
  Caption:= format (Language ['MainForm'],[VERSION_INFO_STR])+ ' - ' + FixRussianDisplay(fData.Name)+' ('+fDataFileName+')';
end;

procedure TMainForm.btnCloseStartClick(Sender: TObject);
var
  Reg: TRegistry;
begin
  CloseStart;
  UpdateShootersListBox;
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey ('\Software\007Soft\WinBASE\'+GUIDToString (fData.DataID), true) then
      begin
        Reg.DeleteValue ('Start');
        Reg.CloseKey;
      end;
  finally
  end;
end;

function TMainForm.CloseStart: boolean;
begin
  if fStartForm<> nil then
    fStartForm.Free;
  fStartForm:= nil;
  if pnlGroup.Visible then
    fShootersLb.ListBox.SetFocus
  else
    tvGroups.SetFocus;
  fData.StartLists.ActiveStart:= nil;
  UpdateStartPanel;
  UpdateStartMenu;
  UpdateShootersListBox;
  Result:= true;
end;

procedure TMainForm.UpdateStartPanel;
begin
  if (fData<> nil) and (fData.ActiveStart<> nil) then
    begin
      fStartPanel.Visible:= true;
      fStartPanel.StartList:= fData.ActiveStart;
    end
  else
    begin
      fStartPanel.Visible:= false;
      fStartPanel.StartList:= nil;
    end;
end;

procedure TMainForm.AddToStartList(ListBox: TShootersListBox);
var
  sh: TShootersFilterItem;
  i: integer;
  p_team,r_team: string;
begin
  p_team:= '';
  r_team:= '';
  if ListBox.MarkedCount= 0 then
    AddToStartList (ListBox.CurrentShooter.Shooter,r_team,p_team)
  else
    begin
      if fAddToStartByOrder then
        begin
          // Обработка нажатий на кнопки, что не понимает
          i:= 0;
          while ListBox.MarkedCount> 0 do
            begin
              inc (i);
              sh:= fShootersLb.Shooters.MarkedIdx (i);
              if sh<> nil then
                begin
                  if AddToStartList (sh.Shooter,r_team,p_team) then
                    begin
                      sh.Shooter.Marked:= 0;
                      ListBox.Invalidate;
                    end
                  else
                    break;
                end;
            end;
        end
      else
        begin
          // Загрузка приложения из ресурсов
          while ListBox.MarkedCount> 0 do
            begin
              sh:= ListBox.Marked [0];
              if AddToStartList (sh.Shooter,r_team,p_team) then
                begin
                  sh.Shooter.Marked:= 0;
                  ListBox.Invalidate;
                end
              else
                break;
            end;
        end;
    end;
end;

function TMainForm.AddToStartList(Shooter: TShooterItem; var LastTeamForResults: string; var LastTeamForPoints: string): boolean;
var
  addform: TAddToStartDialog;
begin
  addform:= TAddToStartDialog.Create (self);
  addform.EventsFilter:= fGroupSettings.fFilter;
  addform.StartList:= fData.ActiveStart;
  addform.Shooter:= Shooter;
  addform.AutoPrint:= fAutoPrintStartNumbers;
  addform.LastTeamForPoints:= LastTeamForPoints;
  addform.LastTeamForResults:= LastTeamForResults;
  Result:= addform.Execute;
  fAutoPrintStartNumbers:= addform.AutoPrint;
  LastTeamForPoints:= addform.LastTeamForPoints;
  LastTeamForResults:= addform.LastTeamForResults;
  addform.Free;
  UpdateShootersListBox;
  UpdateStartMenu;
end;

procedure TMainForm.LoadGroupNames;
var
  N,GN: TTreeNode;
  j: integer;
begin
  tvGroups.Items.Clear;
  N:= tvGroups.Items.Add (nil,Language ['MainForm.GroupsItem']);
  for j:= 0 to fData.Groups.Count-1 do
    begin
      GN:= tvGroups.Items.AddChild (N,fData.Groups [j].Name);
      GN.StateIndex:= 2;
    end;
  N.Expanded:= true;
end;

procedure TMainForm.TimerAutoSaveTimer(Sender: TObject);
begin
  if fData<> nil then
    SaveData;
end;

procedure TMainForm.tvGroupsChange(Sender: TObject; Node: TTreeNode);
var
  N: TTreeNode;
begin
  if Node.Level= 1 then
    begin
      OpenGroup (Node.Index);
      mnuMoveGroupUp.Enabled:= (Node.Index> 0);
      mnuMoveGroupDown.Enabled:= (Node.GetNextSibling<> nil);
      mnuDeleteGroup.Enabled:= true;
      pnlGroupsActions.Visible:= false;
      pnlGroup.Visible:= true;
    end
  else
    begin
      if fGroup<> nil then
        begin
          N:= tvGroups.Items [0].Item [fGroup.Index];
          N.StateIndex:= 2;
        end;
      fGroup:= nil;
      fShootersLb.Clear;
      mnuMoveGroupUp.Enabled:= false;
      mnuMoveGroupDown.Enabled:= false;
      mnuDeleteGroup.Enabled:= false;
      pnlGroup.Visible:= false;
      pnlGroupsActions.Visible:= true;
    end;
end;

function TMainForm.OpenGroup(index: integer): boolean;
var
  N: TTreeNode;
begin
  if (index>= 0) and (index< fData.Groups.Count) then
    begin
      if fGroup<> fData.Groups [index] then
        begin
          if fGroup<> nil then
            begin
              N:= tvGroups.Items [0].Item [fGroup.Index];
              N.StateIndex:= 2;
              fGroupSettings:= fGroupsSettings [fGroup.Index];
              fGroupSettings.fCurrentShooter:= fShootersLb.ItemIndex;
            end;
          fGroup:= fData.Groups [index];
          fGroupSettings:= fGroupsSettings [index];
          fShootersLb.Clear;
          fShootersLb.Add (fGroup.Shooters);
          fShootersLb.SortOrder:= fSortOrder;
          fShootersLb.Event:= fGroupSettings.fCurrentEvent;
          fShootersLb.Sort;
          UpdateEventsCombo;
          if fShootersLb.Shooters.Count> 0 then
            begin
              if fGroupSettings.fCurrentShooter>= 0 then
                fShootersLb.ItemIndex:= fGroupSettings.fCurrentShooter
              else
                fShootersLb.ItemIndex:= 0;
              fShootersLb.Enabled:= true;
            end
          else
            fShootersLb.Enabled:= false;
          UpdateMoveMenu;
          UpdateShootersListBox;
        end;
      N:= tvGroups.Items [0].Item [index];
      N.StateIndex:= 1;
      Result:= true;
    end
  else
    Result:= false;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  fStartPanel.Free;
  fGroupsSettings.Free;
  fShootersLb.Clear;
  if fData<> nil then
    begin
      fData.Free;
      fData:= nil;
    end;
//  fShootersLb.Free;
//  fShootersLb.Parent:= nil;
end;

function TMainForm.EditGroupSettings(AGroup: TGroupItem): boolean;
var
  s,c: string;
begin
  Result:= false;
  if AGroup= nil then
    exit;

  s:= AGroup.Name;
  if AGroup.Name= '' then
    c:= Language ['NewGroup']
  else
    c:= Language ['GroupName'];
  if InputQuery (c,'',s) then
    begin
      s:= Trim (s);
      if s= '' then
        begin
          MessageDlg (Language ['GroupNameEmpty'],mtError,[mbOk],0);
          exit;
        end;
      AGroup.Name:= s;
      Result:= true;
    end;
end;

procedure TMainForm.mnuAboutClick(Sender: TObject);
var
  msg: string;
begin
  case fLanguage of
    lEnglish: begin
      msg:= format (Language ['MainForm'],[VERSION_INFO_STR])+#13#13+
        'Idea: Oleg Lapkin, Anatoli Aktov, coaches of the USSR Olympic shooting team'#13+
        'Development and testing: Yuri Lapkin, Michail Konovalov, Oleg Lapkin'#13+
        'Programming: Yuri Lapkin'#13#13+
        'This software is FREEWARE.'#13+
        'It was developed specially for Soviet and Russian Olympic shooting teams.'#13+
        'It is a property of developers and CAN NOT be used in commercial purposes.'#13#13+
        'http://www.scatt.com/winbase'#13+
        '1988-2010';
    end;
  else
    msg:= format (Language ['MainForm'],[VERSION_INFO_STR])+#13#13+
      'Идея: Олег Лапкин, Анатолий Актов, '+
      'тренеры сборной команды СССР по пулевой стрельбе'#13+
      'Разработка и тестирование: Юрий Лапкин, Михаил Коновалов, Олег Лапкин '#13+
      'Программирование: Юрий Лапкин'#13+#13+
      'Данная программа является свободным ПО для сборных команд СНГ и России, '+
      'является собственностью разработчиков и '#13+
      'НЕ может быть использована в коммерческих целях.'#13#13+
      'http://www.scatt.com/winbase'#13+
      '1988-2010';
  end;
  MessageDlg (msg,mtInformation,[mbOk],0);
end;

procedure TMainForm.mnuAddGroupClick(Sender: TObject);
begin
  AddGroup;
end;

procedure TMainForm.AddGroup;
var
  gr: TGroupItem;
  gs: TGroupSettingsItem;
  N: TTreeNode;
begin
  gr:= fData.Groups.Add;
  if EditGroupSettings (gr) then
    begin
      N:= tvGroups.Items.AddChild (tvGroups.Items [0],gr.Name);
      gs:= fGroupsSettings.Add;
      gs.fCurrentEvent:= nil;
      tvGroups.Selected:= N;
    end
  else
    gr.Free;
end;

procedure TMainForm.mnuDeleteGroupClick(Sender: TObject);
begin
  DeleteGroup (fGroup);
end;

procedure TMainForm.DeleteGroup(AGroup: TGroupItem);
var
  N: TTreeNode;
begin
  if AGroup= nil then
    exit;
  if MessageDlg (format (Language ['DeleteGroupPrompt'],[AGroup.Name]),mtConfirmation,[mbYes,mbNo],0)= idYes then
    begin
      Cursor:= crHourGlass;
      N:= tvGroups.Items [0].Item [AGroup.Index];
      fGroupsSettings.Delete (AGroup.Index);
      AGroup.Free;
      fGroup:= nil;
      tvGroups.Items.Delete (N);
      Cursor:= crDefault;
    end;
end;

procedure TMainForm.mnuViewResultsClick(Sender: TObject);
begin
  ViewResults;
end;

procedure TMainForm.ViewResults;
var
  vrf: TViewForm;
  i: integer;
begin
  vrf:= TViewForm.Create (self);
  vrf.Data:= fData;
  vrf.Execute;
  vrf.Free;
  for i:= 0 to fData.Groups.Count-1 do
    LoadEventsFilter (fData.Groups [i]);
  UpdateEventsCombo;
end;

procedure TMainForm.EnterResults;
var
  erf: TEnterResultsForm;
  i: integer;
begin
  erf:= TEnterResultsForm.Create (self);
  erf.SetData (fData,nil,YearOf (Now));
  erf.Execute;
  erf.Free;
  for i:= 0 to fData.Groups.Count-1 do
    LoadEventsFilter (fData.Groups [i]);
  UpdateEventsCombo;
end;

procedure TMainForm.mnuRateTableClick(Sender: TObject);
begin
  OpenRatingTable;
end;

procedure TMainForm.OpenRatingTable;
var
  rtf: TRateTableForm;
begin
  if fData= nil then
    exit;
  rtf:= TRateTableForm.Create (self);
  rtf.Data:= fData;
  rtf.Execute;
  rtf.Free;
end;

procedure TMainForm.mnuSelectInactiveClick(Sender: TObject);
var
  dtd: TDatePickerDialog;
  d: TDateTime;
begin
  if fData= nil then
    exit;
  dtd:= TDatePickerDialog.Create (self);
  dtd.Date:= Now;
  d:= 0;
  if dtd.Execute then
    if dtd.Date< DateOf (Now) then
      d:= dtd.Date;
  dtd.Free;
  if d= 0 then
    exit;
  // открыта база, в ней нет ни каких-либо групп спортсменов либо
  SelectInactiveShooters (d);
end;

procedure TMainForm.mnuSettingsClick(Sender: TObject);
begin
  OpenDataSettings;
end;

procedure TMainForm.mnuShooterResultsPMClick(Sender: TObject);
begin
  OpenShooterResults (fShootersLb.CurrentShooter);
end;

procedure TMainForm.mnuSpecificDateClick(Sender: TObject);
var
  dtd: TDatePickerDialog;
begin
  if fData= nil then
    exit;
  dtd:= TDatePickerDialog.Create (self);
  dtd.Date:= fData.RatingDate;
  if dtd.Execute then
    begin
      if dtd.Date< DateOf (Now) then
        fData.RatingDate:= dtd.Date
      else
        fData.RatingDate:= 0;
    end;
  dtd.Free;
  UpdateRatingDate;
end;

procedure TMainForm.OpenDataSettings;
var
  sf: TSettingsForm;
  i: integer;
begin
  if fData= nil then
    exit;
  sf:= TSettingsForm.Create (self);
  sf.Data:= fData;
  sf.Execute;
  sf.Free;
  for i:= 0 to fData.Groups.Count-1 do
    LoadEventsFilter (fData.Groups [i]);
  UpdateEventsCombo;
end;

{
procedure TMainForm.HeaderControl1SectionResize(
  HeaderControl: THeaderControl; Section: THeaderSection);
begin
  HeaderControl1Resize (self);
  fShootersLb.Refresh;
end;
}

{
procedure TMainForm.HeaderControl1Resize(Sender: TObject);
var
  s: THeaderSection;
begin
  s:= HeaderControl1.Sections [HeaderControl1.Sections.Count-1];
  s.Width:= HeaderControl1.ClientWidth-s.Left;
end;
}

procedure TMainForm.mnuRenameGroupClick(Sender: TObject);
var
  N: TTreeNode;
begin
  if fGroup= nil then
    exit;
  tvGroups.ReadOnly:= false;
  N:= tvGroups.Items [0].Item [fGroup.Index];
  N.EditText;
end;

procedure TMainForm.mnuRussianClick(Sender: TObject);
begin
  mnuRussian.Checked:= true;
  ChangeLanguage (lRussian);
end;

procedure TMainForm.tvGroupsEdited(Sender: TObject; Node: TTreeNode;
  var S: String);
begin
  if (fGroup= nil) or (fGroup.Index<> Node.Index) then
    exit;
  fGroup.Name:= S;
  tvGroups.ReadOnly:= true;
end;

procedure TMainForm.tvGroupsEnter(Sender: TObject);
begin
  mnuDeleteGroup.ShortCut:= ShortCut (VK_DELETE,[]);
end;

procedure TMainForm.tvGroupsExit(Sender: TObject);
begin
  mnuDeleteGroup.ShortCut:= ShortCut (0,[]);
end;

procedure TMainForm.DataOpened;
var
  j: integer;
begin
  Caption:= format (Language ['MainForm'],[VERSION_INFO_STR])+ ' - ' + FixRussianDisplay(fData.Name)+' ('+fDataFileName+')';
  fGroup:= nil;
  fShootersLb.Clear;
  LoadGroupNames;
  UpdateStartPanel;
  UpdateStartMenu;
  TimerAutoSave.Interval:= fAutoSave*60*1000;
  TimerAutoSave.Enabled:= fAutoSave> 0;
  mnuGroups.Visible:= true;
  mnuShooters.Visible:= true;
  mnuResults.Visible:= true;
  mnuStarts.Visible:= true;
  mnuSaveData.Enabled:= true;
  mnuSaveAs.Enabled:= true;
  mnuMerge.Enabled:= true;
  mnuSaveRatingToPDF.Enabled:= true;
  mnuCheck.Enabled:= true;
  mnuExportNoChamps.Enabled:= true;
  mnuRateTable.Enabled:= true;
  mnuSettings.Enabled:= true;
  mnuPhotoFile.Enabled:= true;
  fGroupsSettings.Clear;
  UpdateRatingDateMenu;
  for j:= 0 to fData.Groups.Count-1 do
    begin
      fGroupsSettings.Add;
      LoadEventsFilter (fData.Groups [j]);
    end;
  if fData.Groups.Count> 0 then
    begin
      tvGroups.Selected:= tvGroups.Items [0].Item [0];
      if pnlGroup.Visible then
        fShootersLb.ListBox.SetFocus;
      UpdateEventsCombo;
      UpdateShootersListBox;
    end
  else
    begin
      UpdateEventsCombo;
      UpdateShootersListBox;
    end;
end;

procedure TMainForm.HeaderControl1SectionClick(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  case Section.Index of
    2: fSortOrder:= ssoSurname;
    3: fSortOrder:= ssoAge;
    4: fSortOrder:= ssoQualification;
    5: fSortOrder:= ssoRegion;
    6: fSortOrder:= ssoRating;
  else
    exit;
  end;
  if fSortOrder<> fShootersLb.SortOrder then
    begin
      fShootersLb.SortOrder:= fSortOrder;
      fShootersLb.Sort;
      fShootersLb.Refresh;
    end;
end;

procedure TMainForm.mnuMoveGroupUpClick(Sender: TObject);
begin
  MoveGroupUp (fGroup);
end;

procedure TMainForm.MoveGroupUp(AGroup: TGroupItem);
var
  N: TTreeNode;
  gs: TGroupSettingsItem;
begin
  if (AGroup= nil) or (AGroup.Index<= 0) then
    exit;
  N:= tvGroups.Items [0].Item [AGroup.Index];
  N.StateIndex:= 0;
  gs:= fGroupsSettings [AGroup.Index];
  AGroup.Index:= AGroup.Index-1;
  fData.Groups.WasChanged:= true;
  gs.Index:= gs.Index-1;
  N.MoveTo (N.getPrevSibling,naInsert);
  tvGroups.Refresh;
  mnuMoveGroupUp.Enabled:= AGroup.Index> 0;
  mnuMoveGroupDown.Enabled:= AGroup.Index< fData.Groups.Count-1;
  N.StateIndex:= 1;
end;

procedure TMainForm.mnuMoveGroupDownClick(Sender: TObject);
begin
  MoveGroupDown (fGroup);
end;

procedure TMainForm.MoveGroupDown(AGroup: TGroupItem);
var
  N,N1: TTreeNode;
  gs: TGroupSettingsItem;
begin
  if (AGroup= nil) or (AGroup.Index>= fData.Groups.Count-1) then
    exit;
  N:= tvGroups.Items [0].Item [AGroup.Index];
  N.StateIndex:= 0;
  gs:= fGroupsSettings [AGroup.Index];
  AGroup.Index:= AGroup.Index+1;
  fData.Groups.WasChanged:= true;
  gs.Index:= gs.Index+1;
  N1:= N.getNextSibling.getNextSibling;
  if N1<> nil then
    N.MoveTo (N1,naInsert)
  else
    N.MoveTo (N.Parent,naAddChild);
  mnuMoveGroupUp.Enabled:= AGroup.Index> 0;
  mnuMoveGroupDown.Enabled:= AGroup.Index< fData.Groups.Count-1;
  N.StateIndex:= 1;
end;

{ TGroupSettings }

function TGroupSettings.Add: TGroupSettingsItem;
begin
  Result:= inherited Add as TGroupSettingsItem;
end;

constructor TGroupSettings.Create;
begin
  inherited Create (TGroupSettingsItem);
end;

function TGroupSettings.get_GroupSettings(
  index: integer): TGroupSettingsItem;
begin
  Result:= inherited Items [index] as TGroupSettingsItem;
end;

{ TGroupSettingsItem }

constructor TGroupSettingsItem.Create(ACollection: TCollection);
begin
  inherited;
  fFilter:= TEventsFilter.Create;
  fCurrentShooter:= -1;
  fCurrentEvent:= nil;
end;

destructor TGroupSettingsItem.Destroy;
begin
  fFilter.Free;
  inherited;
end;

procedure TMainForm.OnAppMessage(var M: TMsg; var Handled: boolean);
var
  key: word;
begin
  case M.message of
    WM_KEYDOWN: begin
      key:= M.wParam;
      Handled:= WBC.ProceedKeyDown (key);
      //Handled:= false;
    end;
  end;
end;

procedure TMainForm.OnChangeMark(Sender: TObject);
begin
  StatusBar1.Panels [0].Text:= format (FixRussianDisplay(MARKED_STR),[fShootersLb.MarkedCount]);
end;

procedure TMainForm.OnCloseStart(Sender: TObject);
begin
  fStartForm:= nil;
  UpdateStartPanel;
  UpdateShootersListBox;
  UpdateStartMenu;
  if pnlGroup.Visible then
    fShootersLb.ListBox.SetFocus
  else
    tvGroups.SetFocus;
end;

procedure TMainForm.OnEventChange(Sender: TObject);
begin
  fGroupSettings.fCurrentEvent:= fGroupSettings.fFilter.Events [cbEvents.ItemIndex];
  fShootersLb.Event:= fGroupSettings.fCurrentEvent;
  if fShootersLb.SortOrder= ssoRating then
    fShootersLb.Sort
  else
    fShootersLb.Refresh;
end;

procedure TMainForm.tvGroupsCustomDrawItem(Sender: TCustomTreeView;
  Node: TTreeNode; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if Node.StateIndex= 1 then
    begin
      tvGroups.Canvas.Font.Style:= [fsBold];
      if not (cdsSelected in State) then
        begin
          tvGroups.Canvas.Brush.Color:= clGrayText;
          tvGroups.Canvas.Font.Color:= clHighlightText;
        end;
    end
  else
    begin
      tvGroups.Canvas.Font.Style:= [];
      if not (cdsSelected in State) then
        tvGroups.Canvas.Brush.Color:= clWindow;
    end;
  DefaultDraw:= true;
end;

procedure TMainForm.OnShooterDblClick(Sender: TObject);
var
  ShiftState: TShiftState;
begin
  if fShootersLb.CurrentShooter<> nil then
    begin
      // Получаем сохраненное состояние клавиш из момента клика мыши
      ShiftState := fShootersLb.GetLastClickShiftState;
      
      // Если зажат Shift или Ctrl - открываем форму заявки на упражнения
      if (ssShift in ShiftState) or (ssCtrl in ShiftState) then
        begin
          // Открываем форму заявки на упражнения
          if (fData <> nil) and (fData.ActiveStart <> nil) then
            begin
              fShootersLb.ResetSearch;
              AddToStartList(fShootersLb.CurrentShooter.Shooter, fLastTeamForResults, fLastTeamForPoints);
            end;
        end
      else
        begin
          // Обычное поведение - открываем личную карточку
          OpenShooterData(fShootersLb.CurrentShooter.Shooter);
        end;
    end;
end;

procedure TMainForm.OpenShooterData (AShooter: TShooterItem);
var
  SD: TShooterDetailsDialog;
begin
  fShootersLb.ResetSearch;
  if AShooter= nil then
    exit;
  SD:= TShooterDetailsDialog.Create (self);
  SD.Shooter:= AShooter;
  SD.Execute;
  SD.Free;
  fShootersLb.Refresh;
end;

procedure TMainForm.OpenShooterResults(AShooter: TShootersFilterItem);
var
  RF: TShooterResultsForm;
  i: integer;
begin
  fShootersLb.ResetSearch;
  if AShooter= nil then
    exit;
  if AShooter.Shooter= nil then
    exit;
  RF:= TShooterResultsForm.Create (self);
  RF.Shooter:= AShooter.Shooter;
  RF.Execute;
  RF.Free;
  for i:= 0 to fData.Groups.Count-1 do
    LoadEventsFilter (fData.Groups [i]);
  UpdateEventsCombo;
  AShooter.HasResults:= AShooter.Shooter.Results.ResultsInEvent (fShootersLb.Event)> 0;
  fShootersLb.Refresh;
end;

procedure TMainForm.mnuSaveListToPDFClick(Sender: TObject);
begin
  // Вместо создания PDF файла используем печать на PDF принтер
  ShowMessage('Выберите PDF принтер (например, Microsoft Print to PDF) для сохранения в PDF');
  PrintShootersList (Printer,plMarked);
end;

procedure TMainForm.mnuSaveOnExitClick(Sender: TObject);
begin
  mnuSaveOnExit.Checked:= not mnuSaveOnExit.Checked;
  fSaveDataOnExit:= mnuSaveOnExit.Checked;
end;

procedure TMainForm.mnuSaveRatingToPDFClick(Sender: TObject);
begin
  SaveAllRatingToPDF;
end;

procedure TMainForm.pnlGroupInfoResize(Sender: TObject);
begin
  lEvent.Left:= 8;
  cbEvents.Top:= 4;
  cbEvents.Left:= lEvent.Left+lEvent.Width+8;
  cbEvents.Width:= pnlGroupInfo.ClientWidth-cbEvents.Left-8;
  pnlGroupInfo.ClientHeight:= cbEvents.Height+8;
end;

procedure TMainForm.pnlShootersEnter(Sender: TObject);
begin
  mnuDeleteShooter.ShortCut:= ShortCut (VK_DELETE,[]);
  mnuOpenShooterData.ShortCut:= ShortCut (VK_RETURN,[]);
  mnuOpenShooterResults.ShortCut:= ShortCut (VK_F5,[]);
  mnuAddShooter.ShortCut:= ShortCut (VkKeyScan ('n'),[ssCtrl]);
end;

procedure TMainForm.pnlShootersExit(Sender: TObject);
begin
  mnuDeleteShooter.ShortCut:= ShortCut (0,[]);
  mnuOpenShooterData.ShortCut:= ShortCut (0,[]);
  mnuOpenShooterResults.ShortCut:= ShortCut (0,[]);
  mnuAddShooter.ShortCut:= ShortCut (0,[]);
end;

procedure TMainForm.LoadEventsFilter(AGroup: TGroupItem);
var
  idx,i,j: integer;
  e: TEventItem;
  gs: TGroupSettingsItem;
  sh: TShooterItem;
  fe,fe1: TFilteredEventItem;
  p,p1: integer;
begin
  gs:= fGroupsSettings [AGroup.Index];
  gs.fFilter.Clear;

  for j:= 0 to AGroup.Data.Events.Count-1 do
    begin
      e:= AGroup.Data.Events.Items [j];
      for i:= 0 to AGroup.Shooters.Count-1 do
        begin
          sh:= AGroup.Shooters.Items [i];
          if sh.Results.ResultsInEvent (e)> 0 then
            begin
              gs.fFilter.Add (e);
              break;
            end;
        end;
    end;

  // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
  for i:= 0 to gs.fFilter.Count-2 do
    begin
      idx:= i;
      fe:= gs.fFilter.Items [i] as TFilteredEventItem;
      for j:= i to gs.fFilter.Count-1 do
        begin
          p:= AGroup.Prefered (fe.Event);
          fe1:= gs.fFilter.Items [j] as TFilteredEventItem;
          p1:= AGroup.Prefered (fe1.Event);
          if (p1>= 0) and ((p< 0) or (p1< p)) then
            fe:= fe1
          else if (p1< 0) and (p< 0) and (fe1.Event.Index< fe.Event.Index) then
            fe:= fe1;
        end;
      fe.Index:= idx;
    end;

  if not gs.fFilter.Filtered (gs.fCurrentEvent) then
    begin
      if gs.fFilter.Count> 0 then
        gs.fCurrentEvent:= gs.fFilter [0]
      else
        gs.fCurrentEvent:= nil;
    end;
end;

procedure TMainForm.mnuEnglishClick(Sender: TObject);
begin
  mnuEnglish.Checked:= true;
  ChangeLanguage (lEnglish);
end;

procedure TMainForm.mnuEnterResultsClick(Sender: TObject);
begin
  EnterResults;
end;

procedure TMainForm.mnuAddShooterClick(Sender: TObject);
var
  sh,sh1: TShooterItem;
  res: boolean;
  shf: TShootersFilterItem;
begin
  if fGroup= nil then
    exit;

  sh:= fGroup.Shooters.Add;
  sh.Gender:= fGroup.DefaultGender;
  OpenShooterData (sh);

  // пїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅ пїЅпїЅпїЅ, пїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
  if (sh.Surname= '') and (sh.Name= '') then
    begin
      sh.Free;
      exit;
    end;

  sh1:= fData.Groups.FindDuplicate (sh);
  if sh1<> nil then
    begin
      res:= MessageDlg (format (Language ['ShooterAlreadyExists'],[sh1.Group.Name]),mtConfirmation,[mbYes,mbNo],0)= idYes;
    end
  else
    res:= true;
  if res then
    begin
      fShootersLb.Add (sh);
      fShootersLb.ItemIndex:= fShootersLb.Shooters.Count-1;
    end
  else
    begin
      sh.Free;
      if sh1.Group= fGroup then
        begin
          shf:= fShootersLb.Shooters.FindItem (sh1);
          if shf<> nil then
            fShootersLb.ItemIndex:= shf.Index;
        end
      else
        begin
        end;
    end;
end;

procedure TMainForm.mnuAddShooterPMClick(Sender: TObject);
begin
  mnuAddShooterClick (Sender);
end;

procedure TMainForm.UpdateEventsCombo;
var
  j,w: integer;
begin
  cbEvents.Enabled:= true;
  cbEvents.OnChange:= nil;
  cbEvents.Clear;
  cbEventsMaxWidth:= 0;
  cbEvents.Canvas.Font.Style:= [fsBold];
  if fGroupSettings<> nil then
    begin
      for j:= 0 to fGroupSettings.fFilter.Count-1 do
        begin
          cbEvents.Items.Add (fGroupSettings.fFilter [j].Name);
          w:= cbEvents.Canvas.TextWidth (fGroupSettings.fFilter [j].ShortName);
          if w> cbEventsMaxWidth then
            cbEventsMaxWidth:= w;
        end;
      if fShootersLb.Event<> fGroupSettings.fCurrentEvent then
        fShootersLb.Event:= fGroupSettings.fCurrentEvent;
      cbEvents.OnChange:= OnEventChange;
    end;
  if cbEvents.Items.Count= 0 then
    begin
      cbEvents.Style:= csSimple;
      cbEvents.Items.Add (Language ['NoRatedEvents']);
      cbEvents.ItemIndex:= 0;
      cbEvents.Enabled:= false;
      if fGroupSettings<> nil then
        fGroupSettings.fCurrentEvent:= nil;
    end
  else
    begin
      cbEvents.Style:= csOwnerDrawFixed;
      cbEvents.ItemIndex:= fGroupSettings.fFilter.IndexOf (fGroupSettings.fCurrentEvent);
      cbEvents.Enabled:= true;
    end;
end;

procedure TMainForm.mnuDeleteShooterClick(Sender: TObject);
begin
  DeleteShooters (fShootersLb.ItemIndex);
end;

procedure TMainForm.mnuDeleteShooterPMClick(Sender: TObject);
begin
  mnuDeleteShooterClick (Sender);
end;

procedure TMainForm.DeleteShooters(index: integer);
var
  sh: TShootersFilterItem;
  i: integer;
begin
  if fShootersLb.MarkedCount> 0 then
    begin
      if MessageDlg (Language ['DeleteMarkedPrompt'],mtConfirmation,[mbYes,mbNo],0)<> mrYes then
        exit;
      i:= 0;
      while (i< fShootersLb.Shooters.Count) do
        begin
          sh:= fShootersLb [i];
          if sh.Shooter.Marked> 0 then
            DeleteShooter (sh,true)
          else
            inc (i);
        end;
    end
  else if (index>= 0) and (index< fShootersLb.Shooters.Count) then
    begin
      sh:= fShootersLb [index];
      DeleteShooter (sh,false);
    end
  else
    exit;
  LoadEventsFilter (fGroup);
  UpdateEventsCombo;
  if index>= fShootersLb.Shooters.Count then
    fShootersLb.ItemIndex:= fShootersLb.Shooters.Count-1
  else
    fShootersLb.ItemIndex:= index;
end;

procedure TMainForm.UpdateMoveMenu;
var
  gr: TGroupItem;
  i: integer;
  mi: TMenuItem;
begin
  mnuMoveShooter.Clear;
  mnuMoveShooterPM.Clear;
  for i:= 0 to fData.Groups.Count-1 do
    begin
      gr:= fData.Groups [i];
      mi:= TMenuItem.Create (mnuMoveShooter);
      mi.Caption:= gr.Name;
      if gr= fGroup then
        mi.Enabled:= false;
      mi.OnClick:= OnMoveToGroup;
      mnuMoveShooter.Add (mi);
      mi:= TMenuItem.Create (mnuMoveShooterPM);
      mi.Caption:= gr.Name;
      if gr= fGroup then
        mi.Enabled:= false;
      mi.OnClick:= OnMoveToGroup;
      mnuMoveShooterPM.Add (mi);
    end;
end;

procedure TMainForm.UpdateRatingDate;
begin
  UpdateRatingDateMenu;
  fShootersLb.SortOrder:= fShootersLb.SortOrder;
  fShootersLb.Sort;
  fShootersLb.Refresh;
end;

procedure TMainForm.UpdateRatingDateMenu;
begin
  if fData.SpecificRatingDate then
    begin
      mnuNow.Checked:= false;
      mnuSpecificDate.Checked:= true;
      mnuSpecificDate.Caption:= Language ['MainForm.MainMenu1..mnuOptions.mnuRatingDate.mnuSpecificDate']+' - '+DateToStr (fData.RatingDate);
    end
  else
    begin
      mnuNow.Checked:= true;
      mnuSpecificDate.Checked:= false;
      mnuSpecificDate.Caption:= Language ['MainForm.MainMenu1..mnuOptions.mnuRatingDate.mnuSpecificDate']+'...';
    end;
end;

procedure TMainForm.OnMoveToGroup(Sender: TObject);
var
  gr: TGroupItem;
begin
  gr:= fData.Groups [(Sender as TMenuItem).MenuIndex];
  MoveToGroup (gr);
end;

procedure TMainForm.tvGroupsKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      fShootersLb.ListBox.SetFocus;
    end;
    #27: begin
      Key:= #0;
    end;
  end;
end;

procedure TMainForm.tvGroupsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RIGHT: begin
      if tvGroups.Selected.Level= 1 then
        begin
          Key:= 0;
          fShootersLb.ListBox.SetFocus;
        end;
    end;
    VK_ESCAPE: begin
      Close;
    end;
    VK_UP: begin
      if Shift= [ssShift] then
        begin
          Key:= 0;
          MoveGroupUp (fGroup);
        end;
    end;
    VK_DOWN: begin
      if Shift= [ssShift] then
        begin
          Key:= 0;
          MoveGroupDown (fGroup);
        end;
    end;
{    VK_F12: begin
      fData.ExportToCSV;
    end;}
  end;
end;

procedure TMainForm.OnShootersKeyDown(Sender: TObject; var Key: word; State: TShiftState);
begin
  case Key of
    VK_LEFT: begin
      Key:= 0;
      fShootersLb.LBClick (nil);
      tvGroups.SetFocus;
    end;
    VK_F8: begin
      Key:= 0;
      DeleteShooters (fShootersLb.ItemIndex);
      fShootersLb.ResetSearch;
    end;
    VK_RETURN: begin
      if State= [ssCtrl] then
        begin
        end;
    end;
    VK_F6: begin
      Key:= 0;
      MoveShooters;
    end;
    VK_F7: begin
      Key:= 0;
      fShootersLb.ResetSearch;
      if cbEvents.Enabled then
        begin
          cbEvents.SetFocus;
          cbEvents.DroppedDown:= true;
        end;
    end;
    VK_F2: begin
      Key:= 0;
      fShootersLb.ResetSearch;
      If (fData<> nil) and (fData.ActiveStart<> nil) then
        begin
          AddToStartList (fShootersLb);
        end;
    end;
    VK_ESCAPE: begin
      Close;
    end;
    VK_F1: begin
      if (ssCtrl in State) and (ssAlt in State) then
        begin
          CheckGroupGender;
          Key:= 0;
        end;
    end;
  end;
end;

procedure TMainForm.MoveToGroup(AGroup: TGroupItem);
var
  sh: TShootersFilterItem;
  index,i: integer;
begin
  index:= fShootersLb.ItemIndex;
  if fShootersLb.MarkedCount> 0 then
    begin
      i:= 0;
      while (i< fShootersLb.Count) do
        begin
          sh:= fShootersLb [i];
          if sh.Shooter.Marked> 0 then
            begin
              sh.Shooter.MoveToGroup (AGroup);
              fShootersLb.DeleteShooter (sh.Index);
              sh.Shooter.Marked:= 0;
            end
          else
            inc (i);
        end;
    end
  else if fShootersLb.ItemIndex>= 0 then
    begin
      sh:= fShootersLb [fShootersLb.ItemIndex];
      sh.Shooter.MoveToGroup (AGroup);
      fShootersLb.DeleteShooter (sh.Index);
    end
  else
    exit;
  LoadEventsFilter (AGroup);
  LoadEventsFilter (fGroup);
  UpdateEventsCombo;
  if index>= fShootersLb.Count then
    fShootersLb.ItemIndex:= fShootersLb.Count-1
  else
    fShootersLb.ItemIndex:= index;
end;

procedure TMainForm.mnuPhotoFileClick(Sender: TObject);
var
  adir: string;
begin
  adir:= fData.ImagesFolder;
  if SelectDirectory (Language ['SelectPhotoFolder'],'',adir) then
    begin
      fData.ImagesFolder:= IncludeTrailingBackslash (adir);
    end;
end;

procedure TMainForm.cbEventsKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #13,#27: begin
      fShootersLb.ListBox.SetFocus;
    end;
  end;
end;

procedure TMainForm.cbEventsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  e: TEventItem;
begin
  with cbEvents.Canvas do
    begin
      FillRect (Rect);
      Font.Style:= [fsBold];
      e:= fGroupSettings.fFilter [Index];
      if e<> nil then
        begin
          TextOut (Rect.Left+2,Rect.Top,e.ShortName);
          Font.Style:= [];
          TextOut (Rect.Left+2+cbEventsMaxWidth,Rect.Top,' ('+e.Name+')');
        end
      else
        begin
//          TextOut (Rect.Left,Rect.Top,'ququ');
        end;
    end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Reg: TRegistry;
begin
  if fStartForm<> nil then
    fStartForm.Free;
  fStartForm:= nil;
  SaveHeaderControlToRegistry ('GroupHC',fShootersLb.Header);
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if fData<> nil then
      begin
        if Reg.OpenKey ('\Software\007Soft\WinBASE\'+GUIDToString (fData.DataID),true) then
          begin
            Reg.WriteString ('Name',fData.Name);
            Reg.WriteString ('FileName',fDataFileName);
            Reg.WriteString ('ImagesFolder',fData.ImagesFolder);
            Reg.CloseKey;
          end;
      end;
    if Reg.OpenKey ('\Software\007Soft\WinBASE', true) then
      begin
        Reg.WriteInteger ('WindowState',integer (WindowState));
        Reg.WriteInteger ('WindowLeft',Left);
        Reg.WriteInteger ('WindowTop',Top);
        Reg.WriteInteger ('WindowWidth',Width);
        Reg.WriteInteger ('WindowHeight',Height);
        Reg.WriteInteger ('Splitter',tvGroups.Width);
        if mnuAutoSave5.Checked then
          Reg.WriteInteger ('AutoSave',5)
        else if mnuAutoSave10.Checked then
          Reg.WriteInteger ('AutoSave',10)
        else if mnuAutoSave30.Checked then
          Reg.WriteInteger ('AutoSave',30)
        else if mnuAutoSave60.Checked then
          Reg.WriteInteger ('AutoSave',60)
        else
          Reg.WriteInteger ('AutoSave',0);
        Reg.WriteBool ('AutoPrintStartNumbers',fAutoPrintStartNumbers);
        Reg.WriteBool ('TruncatePrintedClubs',Global_TruncatePrintedClubs);
        Reg.WriteBool ('CompareBySeries',Global_CompareBySeries);
        Reg.WriteBool ('AddToStartByOrder',fAddToStartByOrder);
        if fData<> nil then
          Reg.WriteString ('LastOpenedData',GUIDToString (fData.DataID))
        else
          Reg.DeleteValue ('LastOpenedData');
        Reg.WriteBool ('EachDayBackup',fEachDayBackup);
        Reg.WriteBool ('SaveDataOnExit',fSaveDataOnExit);
        Reg.WriteBool ('EmbedFontFilesToPDF',EmbedFontFilesToPDF);
        Reg.WriteBool ('PrintTwoStartNumbersPerPage',PrintTwoStartNumbersOnPage);
        case fLanguage of
          lRussian: Reg.WriteInteger ('Language',LANG_RUSSIAN);
          lEnglish: Reg.WriteInteger ('Language',LANG_ENGLISH);
        end;
        Reg.WriteBool ('PrintJuryInProtocols',Global_PrintJury);
        Reg.WriteBool ('PrintSecreteryInProtocols',Global_PrintSecretery);
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure TMainForm.btnManageClick(Sender: TObject);
begin
  if fData= nil then
    exit;

  fShootersLb.ResetSearch;

  if fData.ActiveStart= nil then
    NewStart;
  if fData.ActiveStart= nil then
    exit;

{  if fStartForm<> nil then
    begin
      fStartForm.Show;
      if fStartForm.WindowState= wsMinimized then
        fStartForm.WindowState:= wsMaximized;
      fStartForm.SetFocus;
    end
  else
    begin}
      fStartForm:= TManageStartForm.Create (self);
      fStartForm.Start:= fData.ActiveStart;
//      fStartForm.FormStyle:= fsStayOnTop;
      fStartForm.WindowState:= wsMaximized;
//      fStartForm.OnDestroy:= OnCloseStart;
      fStartForm.Execute;
      fStartForm.Free;
      OnCloseStart (fStartForm);
{    end;}
end;

procedure TMainForm.mnuAutoSaveOffClick(Sender: TObject);
begin
  TimerAutoSave.Interval:= 1000;
  TimerAutoSave.Enabled:= false;
  mnuAutoSaveOff.Checked:= true;
  fAutoSave:= 0;
end;

procedure TMainForm.mnuAutoSave5Click(Sender: TObject);
begin
  TimerAutoSave.Interval:= 5*1000*60;
  TimerAutoSave.Enabled:= true;
  mnuAutoSave5.Checked:= true;
  fAutoSave:= 5;
end;

procedure TMainForm.mnuAutoSave10Click(Sender: TObject);
begin
  TimerAutoSave.Interval:= 10*1000*60;
  TimerAutoSave.Enabled:= true;
  mnuAutoSave10.Checked:= true;
  fAutoSave:= 10;
end;

procedure TMainForm.mnuAutoSave30Click(Sender: TObject);
begin
  TimerAutoSave.Interval:= 30*1000*60;
  TimerAutoSave.Enabled:= true;
  mnuAutoSave30.Checked:= true;
  fAutoSave:= 30;
end;

procedure TMainForm.mnuAutoSave60Click(Sender: TObject);
begin
  TimerAutoSave.Interval:= 60*1000*60;
  TimerAutoSave.Enabled:= true;
  mnuAutoSave60.Checked:= true;
  fAutoSave:= 60;
end;

procedure TMainForm.btnPrintoutClick(Sender: TObject);
begin
  fData.ActiveStart.StartNumbersPrintout.PrintOut;
  fData.ActiveStart.StartNumbersPrintout.Clear;
  mnuPrintStartNumbers.Enabled:= false;
end;

procedure TMainForm.RunSplash;
begin
  // Временно отключен splash screen из-за отсутствующих ресурсов
  exit;
end;

procedure TMainForm.ShowSplash (Sender: TObject);
var
  t: TTimer;
  w: TForm;
  b: integer;
begin
  t:= Sender as TTimer;
  w:= t.Owner as TForm;
  b:= w.AlphaBlendValue;
  b:= b+64;
  if b> 255 then
    begin
      b:= 255;
      t.OnTimer:= StopSplash;
      t.Interval:= 1500;
    end
  else
    t.Interval:= 50;
  w.AlphaBlendValue:= b;
end;

procedure TMainForm.StopSplash (Sender: TObject);
var
  t: TTimer;
  w: TForm;
  b: integer;
begin
  t:= Sender as TTimer;
  w:= t.Owner as TForm;
  b:= w.AlphaBlendValue;
  b:= b - 32;
  if b> 0 then
    w.AlphaBlendValue:= b
  else
    w.Free;
  t.Interval:= 50;
end;

procedure TMainForm.EditGroupPreferedEvents (AGroup: TGroupItem);
var
  gpe: TPreferedEventsEditor;
begin
  if AGroup= nil then
    exit;
  gpe:= TPreferedEventsEditor.Create (self);
  gpe.Group:= AGroup;
  gpe.Execute;
  LoadEventsFilter (AGroup);
  UpdateEventsCombo;
  UpdateShootersListBox;
end;

{procedure TMainForm.CMSysFontChanged (var Msg: TMessage);
begin
  UpdateFonts;
  Msg.Result:= LRESULT (true);
end;}

procedure TMainForm.UpdateFonts;
begin
  SysFonts.GetMetricSettings;
  Font:= SysFonts.MessageFont;
  fShootersLb.Font:= Font;
  cbEvents.Font:= Font;
  cbEvents.Canvas.Font:= Font;
  cbEvents.Canvas.Font:= cbEvents.Font;
  cbEvents.ItemHeight:= cbEvents.Canvas.TextHeight ('Mg')+4;
  pnlGroupInfo.ClientHeight:= cbEvents.Height+8;
  fStartPanel.Font:= SysFonts.MessageFont;
  fStartPanel.Canvas.Font:= fStartPanel.Font;
  fStartPanel.ArrangeControls;
  StatusBar1.Font:= SysFonts.StatusFont;
  UpdateEventsCombo;
  UpdateShootersListBox;
  tvGroups.Update;
//  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
//  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
  Refresh;
end;

procedure TMainForm.MoveShooters;
var
  msd: TMoveShootersDialog;
begin
  if fShootersLb.ItemIndex< 0 then
    exit;
  if fData.Groups.Count< 2 then
    exit;
  fShootersLb.ResetSearch;
  msd:= TMoveShootersDialog.Create (self);
  if fShootersLb.MarkedCount> 0 then
    msd.Group:= fGroup
  else
    msd.Shooter:= fShootersLb.CurrentShooter.Shooter;
  if msd.Execute then
    MoveToGroup (msd.Group);
  msd.Free;
end;

procedure TMainForm.btnShootersClick (Sender: TObject);
var
  sls: TStartListShootersForm;
begin
  if (fData= nil) or (fData.ActiveStart= nil) then
    exit;
  fShootersLb.ResetSearch;
  sls:= TStartListShootersForm.Create (self);
  sls.StartList:= fData.ActiveStart;
  sls.Execute;
  sls.Free;
  UpdateStartPanel;
  UpdateShootersListBox;
  UpdateStartMenu;
  if pnlGroup.Visible then
    fShootersLb.ListBox.SetFocus
  else
    tvGroups.SetFocus;
end;

procedure TMainForm.btnStatsClick(Sender: TObject);
var
  sf: TStartListStatsDialog;
begin
  sf:= TStartListStatsDialog.Create (self);
  sf.StartList:= fData.ActiveStart;
  sf.ShowModal;
  sf.Free;
end;

procedure TMainForm.ChangeLanguage (ALanguage: TLanguage);
var
  msg: TMessage;
begin
  fLanguage:= ALanguage;
  case fLanguage of
    lRussian: Language.LoadFromResourceName (HInstance,'RUSSIAN');
    lEnglish: Language.LoadFromResourceName (HInstance,'ENGLISH');
  end;
  UpdateLanguage;
  UpdateFonts;
  fStartPanel.Resize;
  pnlGroupInfoResize (self);
  Refresh;
  msg.Msg:= WM_CHANGELANGUAGE;
  Broadcast (msg);
end;

procedure TMainForm.CheckGroupGender;
var
  sh: TShootersFilterItem;
  i: integer;
  g: TGender;
begin
  if fGroup= nil then
    exit;
  g:= Male;
  for i:= 0 to fShootersLb.Shooters.Count-1 do
    begin
      sh:= fShootersLb.Shooters.Items [i];
      if (i= 0) then
        g:= sh.Shooter.Gender
      else
        begin
          if sh.Shooter.Gender<> g then
            begin
              fShootersLb.ItemIndex:= i;
              break;
            end;
        end;
    end;
end;

type
  tshooterrating= record
    sh: TShooterItem;
    rating: integer;
  end;

procedure TMainForm.SaveAllRatingToPDF;
begin
  // Вместо создания PDF файла используем печать на PDF принтер
  ShowMessage('Выберите PDF принтер (например, Microsoft Print to PDF) для сохранения рейтинга в PDF');
  mnuPrintListClick(Self);  // Вызываем обычную печать списка участников
end;

procedure TMainForm.SaveData;
var
  tf,dir,fname,bakfile: string;
  Reg: TRegistry;
  temp: array [0..MAX_PATH] of char;
  res: cardinal;
begin
  TimerAutoSave.Enabled:= false;
  fname:= fDataFileName;
  if fname= '' then
    begin
      if SaveDataDialog.Execute then
        fname:= SaveDataDialog.FileName
      else
        begin
          if fAutoSave> 0 then
            TimerAutoSave.Enabled:= true;
          exit;
        end;
    end;
  Cursor:= crHourGlass;
  Application.ProcessMessages;
  try
    dir:= ExtractFileDir (fname);
    res:= GetTempFileName (pchar (dir),'WBASE',0,@temp);
    if res= 0 then
      begin
        MessageDlg (Language ['CannotCreateTempFile'],mtError,[mbOk],0);
        exit;
      end;
    tf:= pchar (@temp);
    fData.SaveToFile (tf);
    if FileExists (fname) then
      begin
        if fEachDayBackup then
          bakfile:= fname+'.'+FormatDateTime ('yy-mm-dd',Now)+'.BAK'
        else
          bakfile:= fname+'.BAK';
        CopyFile (pchar (fname),pchar (bakfile),false);
      end;
    MoveFileEx (pchar (tf),pchar (fname),MOVEFILE_COPY_ALLOWED or MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH);
    fDataFileName:= fname;
  except
    on E: Exception do
      MessageDlg(Format('%s%sФайл: %s%sПричина: %s', [Language['SaveDataError'], sLineBreak, fname, sLineBreak, E.Message]), mtError, [mbOk], 0)
    else
      MessageDlg (Language ['SaveDataError'],mtError,[mbOk],0);
  end;

  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey ('\Software\007Soft\WinBASE\'+GUIDToString (fData.DataID), true) then
      begin
        Reg.WriteString ('Name',fData.Name);
        Reg.WriteString ('FileName',fDataFileName);
        Reg.WriteString ('ImagesFolder',fData.ImagesFolder);
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

procedure TMainForm.SelectInactiveShooters(d: TDate);
var
  i: integer;
  sh: TShootersFilterItem;
  res: TResultItem;
begin
  for i:= 0 to fShootersLb.Shooters.Count-1 do
    begin
      sh:= fShootersLb.Shooters.Items[i];
      res:= sh.Shooter.Results.Last;
      if res<> nil then
        begin
          if res.Date>= d then
            sh.Shooter.Marked:= 0
          else
            sh.Shooter.Marked:= 1;
        end
      else
        sh.Shooter.Marked:= 1;
    end;
  OnChangeMark(self);
end;

procedure TMainForm.UpdateShootersListBox;
var
  filter: TShootersFilter;
  i: integer;
  sh: TShootersFilterItem;
  slsh: TStartListShooterItem;
begin
  filter:= fShootersLb.Shooters;
  for i:= 0 to filter.Count-1 do
    begin
      sh:= filter.Items [i];
      if fData.ActiveStart<> nil then
        begin
          slsh:= fData.ActiveStart.Shooters.FindShooter (sh.Shooter);
          if slsh<> nil then
            sh.InStart:= slsh.EventsCount
          else
            sh.InStart:= -1;
        end
      else
        sh.InStart:= -1;
    end;
  fShootersLb.Refresh;
  StatusBar1.Panels [0].Text:= format (FixRussianDisplay(MARKED_STR),[filter.MarkedCount]);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  res: integer;
begin
  CanClose:= false;
  if fData<> nil then
    begin
      if fData.WasChanged then
        begin
          if fSaveDataOnExit then
            SaveData
          else
            begin
              res:= MessageDlg (Language ['SaveDataPrompt'],mtConfirmation,mbYesNoCancel,0);
              case res of
                idYes: SaveData;
                idNo: {};
                idCancel: exit;
              end;
            end;
        end;
    end;
  CanClose:= true;
end;

procedure TMainForm.mnuManageStartClick(Sender: TObject);
begin
  btnManageClick (self);
end;

procedure TMainForm.mnuCheckClick(Sender: TObject);
var
  f: textfile;
  i: integer;
begin
  if fData= nil then
    exit;
  fData.Check;
  if Length (fData.DupeResults)> 0 then
    begin
      AssignFile (f,'dupes.txt');
      Rewrite (f);
      for i:= 0 to Length (fData.DupeResults)-1 do
        begin
          Writeln (f,fData.DupeResults [i].Origin.AsText);
          Writeln (f,' > '+fData.DupeResults [i].Dupe.AsText);
        end;
      CloseFile (f);
      if MessageDlg (format (Language ['MainForm.DUPES_FOUND'],[Length (fData.DupeResults)]),mtConfirmation,[mbYes,mbNo],0)= idYes then
        begin
          fData.DeleteDupeResults;
          if fGroup<> nil then
            begin
              UpdateEventsCombo;
              fShootersLb.Refresh;
            end;
          UpdateStartPanel;
        end
      else
        fData.ResetDupeResults;
    end
  else
    begin
      MessageDlg (Language ['Mainform.CHECK_OK'],mtInformation,[mbOk],0);
    end;
end;

procedure TMainForm.mnuCloseStartClick(Sender: TObject);
begin
  btnCloseStartClick (self);
end;

procedure TMainForm.mnuCompareBySeriesClick(Sender: TObject);
begin
  mnuCompareBySeries.Checked:= not mnuCompareBySeries.Checked;
  Global_CompareBySeries:= mnuCompareBySeries.Checked;
end;

procedure TMainForm.mnuCSVClick(Sender: TObject);
var
  s: TStrings;
  i: integer;
  mc: integer;
  sh: TShootersFilterItem;
begin
  if dlgSaveToCSV.Execute then
    begin
      s:= TStringList.Create;
      mc:= fShootersLb.MarkedCount;
      for i:= 0 to fShootersLb.Count-1 do
        begin
          sh:= fShootersLb.Shooters.Items [i];
          if (mc= 0) or (sh.Shooter.Marked> 0) then
            s.Add (sh.CSVStr);
        end;
      if s.Count> 0 then
        s.SaveToFile (dlgSaveToCSV.FileName);
      s.Free;
    end;
end;

procedure TMainForm.mnuPrintStartNumbersClick(Sender: TObject);
begin
  btnPrintoutClick (self);
end;

procedure TMainForm.mnuNewStartClick(Sender: TObject);
begin
  if NewStart then
    btnManageClick (self);
end;

procedure TMainForm.mnuNowClick(Sender: TObject);
begin
  if fData= nil then
    exit;
  fData.RatingDate:= 0;
  UpdateRatingDate;
end;

procedure TMainForm.UpdateStartMenu;
var
  mi: TMenuItem;
  i: integer;
  b: boolean;
begin
  if fData<> nil then
    begin
      mnuOpenStart.Enabled:= fData.StartLists.Count> 0;
      mnuOpenStart.Clear;
      mnuOpenStart.OnClick:= nil;
      for i:= 0 to fData.StartLists.Count-1 do
        begin
          mi:= TMenuItem.Create (mnuOpenStart);
          mi.Caption:= fData.StartLists [i].Info.CaptionText;
          mi.Tag:= i;
          mi.OnClick:= mnuOpenStartClick;
          if (fData.ActiveStart<> nil) and (fData.ActiveStart.Index= i) then
            mi.Default:= true
          else
            mi.Default:= false;
          mnuOpenStart.Add (mi);
        end;
    end
  else
    mnuOpenStart.Enabled:= false;

  b:= (fData<> nil) and (fData.ActiveStart<> nil);

  mnuAddToStart.Enabled:= b;
  mnuAddToStartPM.Enabled:= b;
  mnuCloseStart.Enabled:= b;
  mnuManageStart.Enabled:= b;
  mnuStartShooters.Enabled:= b and (fData.ActiveStart.Shooters.Count> 0);
  mnuPrintStartNumbers.Enabled:= b and (fData.ActiveStart.StartNumbersPrintout.IsPending);
end;

procedure TMainForm.mnuPrinterClick(Sender: TObject);
var
  pd: TPrintProtocolDialog;
begin
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= Language ['Printer'];
  pd.ShowCopies:= false;
  pd.ProtocolType:= ptStartNumbers;
  pd.Execute;
  pd.Free;
end;

procedure TMainForm.mnuTruncateClubsClick(Sender: TObject);
begin
  mnuTruncateClubs.Checked:= not mnuTruncateClubs.Checked;
  Global_TruncatePrintedClubs:= mnuTruncateClubs.Checked;
end;

procedure TMainForm.mnuAddToStartByOrderClick(Sender: TObject);
begin
  fAddToStartByOrder:= not fAddToStartByOrder;
  mnuAddToStartByOrder.Checked:= fAddToStartByOrder;
end;

procedure TMainForm.mnuAddToStartClick(Sender: TObject);
begin
  fShootersLb.ResetSearch;
  if (fData<> nil) and (fData.ActiveStart<> nil) then
    AddToStartList (fShootersLb);
end;

procedure TMainForm.mnuAddToStartPMClick(Sender: TObject);
begin
  fShootersLb.ResetSearch;
  if (fData<> nil) and (fData.ActiveStart<> nil) then
    AddToStartList (fShootersLb);
end;

procedure TMainForm.DeleteShooter(AShooter: TShootersFilterItem; NoQuestions: boolean);
var
  ssh: TStartListShooterItem;
  part: boolean;
  i: integer;
begin
  if not NoQuestions then
    begin
      if MessageDlg (format (Language ['DeleteShooterPrompt'],[AShooter.Shooter.SurnameAndName]),
                     mtConfirmation,[mbYes,mbNo],0)<> idYes then
        exit;
    end;
  part:= false;
  for i:= 0 to fData.StartLists.Count-1 do
    if fData.StartLists [i].Shooters.FindShooter (AShooter.Shooter)<> nil then
      begin
        part:= true;
        break;
      end;
  if part then
    begin
      if MessageDlg (format (Language ['DeleteParticipatedPrompt'],[AShooter.Shooter.SurnameAndName]),mtConfirmation,[mbYes,mbNo],0)<> idYes then
        exit;
    end;
  for i:= 0 to fData.StartLists.Count-1 do
    begin
      ssh:= fData.StartLists [i].Shooters.FindShooter (AShooter.Shooter);
      if ssh<> nil then
        begin
          fData.StartLists [i].Shooters.Delete (ssh);
          fData.StartLists [i].Notify (WM_STARTLISTSHOOTERSDELETED,0,0);
        end;
    end;
  fGroup.Shooters.Delete (AShooter.Shooter.Index);
  fShootersLb.DeleteShooter (AShooter.Index);
end;

procedure TMainForm.mnuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.mnuExportNoChampsClick(Sender: TObject);
var
  ed: TSaveDialog;
  ch: boolean;
begin
  if fData= nil then
    exit;
  ed:= TSaveDialog.Create (self);
  try
    ed.DefaultExt:= '*.wbd';
    ed.Filter:=  'WinBASE data files|*.wbd';
    ed.FilterIndex:= 0;
    ed.Title:= Language ['EXPORT_NO_CHAMPS_DIALOG_TITLE'];
    ed.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing];
    if ed.Execute then
      begin
        ch:= fData.WasChanged;
        fData.SaveToFile (ed.FileName,false,false);
        fData.WasChanged:= ch;
      end;
  finally
    ed.Free;
  end;
end;

procedure TMainForm.mnuExportToFileClick(Sender: TObject);
var
  stream: TFileStream;
  sh: TShootersFilterItem;
  i: integer;
  pid: TGUID;
begin
  if ExportDialog.Execute then
    begin
      stream:= TFileStream.Create (ExportDialog.FileName,fmCreate);
      try
        if fShootersLb.MarkedCount> 0 then
          begin
            i:= fShootersLb.MarkedCount;
            stream.Write (i,sizeof (i));
            for i:= 0 to fShootersLb.Count-1 do
              begin
                sh:= fShootersLb [i];
                if sh.Shooter.Marked> 0 then
                  begin
                    pid:= sh.Shooter.PID;
                    stream.Write (pid,sizeof (pid));
                    sh.Shooter.WriteToStream (stream);
                  end;
              end;
          end
        else if fShootersLb.ItemIndex>= 0 then
          begin
            i:= 1;
            stream.Write (i,sizeof (i));
            sh:= fShootersLb [fShootersLb.ItemIndex];
            pid:= sh.Shooter.PID;
            stream.Write (pid,sizeof (pid));
            sh.Shooter.WriteToStream (stream);
          end;
      finally
        stream.Free;
      end;
    end;
end;

procedure TMainForm.mnuImportBaseClick(Sender: TObject);
var
  folder: string;
  data: TData;
begin
  folder:= GetCurrentDir;
  if SelectDirectory (folder,[],0) then
    begin
      data:= TData.Create;
      try
        data.ImportFromFolder (folder);
        if (fData<> nil) and (fData.ActiveStart<> nil) then
          CloseStart;
        tvGroups.Items.Clear;
        if fData<> nil then
          fData.Free;
        fGroup:= nil;
        fData:= data;
        fDataFileName:= '';
        DataOpened;
      except
        data.Free;
      end;
    end;
end;

procedure TMainForm.mnuImportFromFileClick(Sender: TObject);
var
  stream: TFileStream;
  c,i: integer;
  sh: TShooterItem;
  pid: TGUID;
  res: integer;
begin
  if ImportDialog.Execute then
    begin
      stream:= TFileStream.Create (ImportDialog.FileName,fmOpenRead);
      try
        stream.Read (c,sizeof (c));
        for i:= 0 to c-1 do
          begin
            stream.Read (pid,sizeof (pid));
            sh:= fData.Groups.FindShooter (pid);
            if sh<> nil then
              begin
                res:= MessageDlg (format (Language ['ReplaceExistingShooterPrompt'],[sh.SurnameAndName]),mtError,[mbYes,mbNo],0);
                if res= idYes then
                  begin
                    sh.ReadFromStream (stream);
                  end
                else
                  begin
                    sh:= fGroup.Shooters.Add;
                    sh.ReadFromStream (stream);
                    sh.Free;
                  end;
              end
            else
              begin
                sh:= fGroup.Shooters.Add;
                sh.ReadFromStream (stream);
                fShootersLb.Add (sh);
                fShootersLb.ItemIndex:= fShootersLb.Count-1;
              end;
          end;
      finally
        stream.Free;
      end;
    end;
end;

procedure TMainForm.mnuInnerTensClick(Sender: TObject);
begin
  mnuInnerTens.Checked:= not mnuInnerTens.Checked;
  Global_GetInnerTensFromAscor:= mnuInnerTens.Checked;
end;

procedure TMainForm.mnuPrintListClick(Sender: TObject);
begin
  PrintShootersList (Printer,plMarked);
end;

procedure TMainForm.mnuMergeClick(Sender: TObject);
var
  d: TData;
begin
  if MergeDataDialog.Execute then
    begin
      Screen.Cursor:= crHourGlass;
      d:= TData.Create;
      d.LoadFromFile (MergeDataDialog.FileName);
      fData.MergeWith (d);
      DataOpened;
      d.Free;
      Screen.Cursor:= crDefault;
    end;
end;

procedure TMainForm.mnuPreferedEventsClick(Sender: TObject);
begin
  EditGroupPreferedEvents (fGroup);
end;

procedure TMainForm.mnuPrintInStartClick(Sender: TObject);
begin
  PrintShootersList (Printer,plInStart);
end;

procedure TMainForm.mnuOpenShooterDataPMClick(Sender: TObject);
begin
  if fShootersLb.CurrentShooter<> nil then
    OpenShooterData (fShootersLb.CurrentShooter.Shooter);
end;

procedure TMainForm.mnuOpenStartClick(Sender: TObject);
var
  mi: TMenuItem;
begin
  if Sender is TMenuItem then
    begin
      mi:= Sender as TMenuItem;
      if (fData.ActiveStart= nil) or (fData.ActiveStart.Index<> mi.Tag) then
        begin
          fData.StartLists.ActiveStart:= fData.StartLists.Items [mi.Tag];
          UpdateStartPanel;
          UpdateStartMenu;
          UpdateShootersListBox;
        end;
    end;
end;

procedure TMainForm.mnuStartManagerClick(Sender: TObject);
var
  slm: TStartListManager;
begin
  slm:= TStartListManager.Create (self);
  slm.Data:= fData;
  slm.Execute;
  slm.Free;
  UpdateStartPanel;
  UpdateStartMenu;
  UpdateShootersListBox;
end;

procedure TMainForm.mnuStartNumbersFontClick(Sender: TObject);
var
  Reg: TRegistry;
  font_name: string;
begin
  font_name:= START_NUMBERS_FONT_NAME;
  FontDialog2.Font.Charset:= PROTOCOL_CHARSET;
  FontDialog2.Font.Name:= font_name;
  FontDialog2.Font.Style:= [];
  if FontDialog2.Execute then
    begin
      START_NUMBERS_FONT_NAME:= FontDialog2.Font.Name;
      Reg:= TRegistry.Create;
      try
        Reg.RootKey:= HKEY_CURRENT_USER;
        if Reg.OpenKey (REG_PATH,false) then
          begin
            Reg.WriteString ('StartNumbersFontName',START_NUMBERS_FONT_NAME);
            Reg.CloseKey;
          end;
      finally
        Reg.Free;
      end;
    end;
end;

procedure TMainForm.mnuStartNumbersModeClick(Sender: TObject);
begin
  mnuStartNumbersMode.Checked:= not mnuStartNumbersMode.Checked;
  PrintTwoStartNumbersOnPage:= mnuStartNumbersMode.Checked;
end;

procedure TMainForm.mnuStartShootersClick(Sender: TObject);
begin
  if fStartPanel.Visible then
    fStartPanel.btnShooters.Click;
end;

function TMainForm.NewStart: boolean;
var
  st: TStartList;
  SI: TStartInfoDialog;
  res: boolean;
begin
  Result:= false;
  st:= fData.StartLists.Add;
  st.ShootersPerTeam:= 3;
  si:= TStartInfoDialog.Create (self);
  si.Info:= st.Info;
  si.Caption:= Language ['NewStart'];
  res:= si.Execute;
  si.Free;
  if not res then
    begin
      st.Free;
      if pnlGroup.Visible then
        fShootersLb.ListBox.SetFocus;
      exit;
    end;
//  st.CreateShootingChampionship;
  fData.StartLists.ActiveStart:= st;
  UpdateStartPanel;
  UpdateStartMenu;
  Result:= true;
end;

procedure TMainForm.mnuProtocolFontClick(Sender: TObject);
var
  Reg: TRegistry;
  font_name: string;
  font_size: integer;
begin
  font_name:= 'Arial';
  font_size:= 10;
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH,false) then
      begin
        if Reg.ValueExists ('ProtocolFontName') then
          font_name:= Reg.ReadString ('ProtocolFontName');
        if Reg.ValueExists ('ProtocolFontSize') then
          font_size:= Reg.ReadInteger ('ProtocolFontSize');
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
  FontDialog1.Font.Charset:= PROTOCOL_CHARSET;
  FontDialog1.Font.Name:= font_name;
  FontDialog1.Font.Size:= font_size;
  FontDialog1.Font.Style:= [];
  if FontDialog1.Execute then
    begin
      Reg:= TRegistry.Create;
      try
        Reg.RootKey:= HKEY_CURRENT_USER;
        if Reg.OpenKey (REG_PATH,false) then
          begin
            Reg.WriteString ('ProtocolFontName',FontDialog1.Font.Name);
            Reg.WriteInteger ('ProtocolFontSize',FontDialog1.Font.Size);
            Reg.CloseKey;
          end;
      finally
        Reg.Free;
      end;
    end;
end;

procedure TMainForm.mnuProtocolMakerSignClick(Sender: TObject);
var
  st: string;
begin
  st:= PROTOCOL_MAKER_SIGN;
  if InputQuery (Language ['Main.ProtocolMakerSignCaption'],Language ['Main.ProtocolMakerSignPrompt'],st) then
    begin
      PROTOCOL_MAKER_SIGN:= st;
      SaveStrToRegistry ('ProtocolMakerSignature',st);
    end;
end;

{
const
  WinBASE_DataFile= 'WinBASE.DataFile';

procedure TMainForm.CheckFileAssociations;
var
  Reg: TRegistry;
  res: boolean;
begin
  res:= true;
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CLASSES_ROOT;
    // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ WinBASEdatafile
    if not Reg.OpenKey (WinBASE_DataFile,false) then
      begin
        // пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ WinBASEdatafile
        res:= Reg.OpenKey (WinBASE_DataFile+'\DefaultIcon',true);
        if res then
          begin
            // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ
            Reg.WriteString ('',Application.ExeName+',1');
            Reg.CloseKey;
            res:= Reg.OpenKey (WinBASE_DataFile+'\shell\open\command',true);
            if res then
              begin
                // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
                Reg.WriteString ('',Application.ExeName+' "%1"');
                Reg.CloseKey;
              end;
          end;
        if not res then
          MessageDlg (Language ['RegistryAccessError'],mtError,[mbOk],0);
      end
    else
      Reg.CloseKey;
    // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
    if res then
      begin
        if Reg.OpenKey ('.wbd',false) then
          begin
            // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅ пїЅпїЅпїЅ пїЅпїЅ
            if not AnsiSameText (Reg.ReadString (''),WinBASE_DataFile) then
              begin
                // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
                if MessageDlg (Language ['SetFileTypePrompt'],mtConfirmation,[mbYes,mbNo],0)= idYes then
                  begin
                    Reg.WriteString ('',WinBASE_DataFile);
                  end;
              end;
            Reg.CloseKey;
          end
        else
          begin
            // пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
            if Reg.OpenKey ('.wbd',true) then
              begin
                Reg.WriteString ('',WinBASE_DataFile);
                Reg.CloseKey;
              end
            else
              MessageDlg (Language ['RegistryAccessError'],mtError,[mbOk],0);
          end;
      end;
    Reg.Free;
  except
    Reg.Free;
    MessageDlg (Language ['RegistryAccessError'],mtError,[mbOk],0);
  end;
end;
}

procedure TMainForm.mnuOpenShooterDataClick(Sender: TObject);
begin
  if fShootersLb.CurrentShooter<> nil then
    OpenShooterData (fShootersLb.CurrentShooter.Shooter);
end;

procedure TMainForm.mnuOpenShooterResultsClick(Sender: TObject);
begin
  OpenShooterResults (fShootersLb.CurrentShooter);
end;

procedure TMainForm.mnuEachDayBackupClick(Sender: TObject);
begin
  fEachDayBackup:= not fEachDayBackup;
  mnuEachDayBackup.Checked:= fEachDayBackup;
end;

procedure TMainForm.mnuEmbedFontFilesClick(Sender: TObject);
begin
  EmbedFontFilesToPDF:= not EmbedFontFilesToPDF;
  mnuEmbedFontFiles.Checked:= EmbedFontFilesToPDF;
end;

procedure TMainForm.PrintShootersList (Prn: TObject; Criteria: TPrintListCriteria);
const
  separator= 4;
var
  _printer: TMyPrinter;
  table: TMyTableColumns;
  tcIndex,tcName,tcYear,tcQual,tcRegion,tcSoc,tcClub,tcRating: TMyTableColumn;
  font_height_large,font_height_small: integer;
  thl,ths: integer;
  footerheight: integer;
  page_idx: integer;
  y: integer;

  function MeasureColumns: boolean;
  var
    i: integer;
    sh: TShootersFilterItem;
    st: string;
    w: integer;
    in_list: boolean;
  begin
    Result:= false;
    table.Width:= 0;
    with _printer.Canvas do
      begin
        Font.Style:= [];
        Font.Height:= font_height_large;
        for i:= 0 to fShootersLb.Shooters.Count-1 do
          begin
            sh:= fShootersLb.Shooters.Items [i];

            case Criteria of
              plAll: in_list:= true;
              plMarked: in_list:= (sh.Shooter.Marked> 0) or (fShootersLb.MarkedCount= 0);
              plInStart: in_list:= (sh.InStart>= 0);
            else
              in_list:= false;
            end;

            if in_list then
              begin
                // пїЅпїЅпїЅпїЅпїЅ
                Font.Style:= [];
                tcIndex.Fit (TextWidth (IntToStr (i+1)));
                // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅ
                Font.Style:= [fsBold];
                st:= sh.Shooter.Surname;
                w:= TextWidth (st);
                Font.Style:= [];
                if sh.Shooter.Name<> '' then
                  begin
                    st:= ', '+sh.Shooter.Surname;
                    w:= w+TextWidth (st);
                  end;
                tcName.Fit (w);
                // пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
                Font.Style:= [];
                tcYear.Fit (TextWidth (sh.Shooter.BirthFullStr));
                // пїЅпїЅпїЅпїЅпїЅпїЅ
                Font.Style:= [];
                tcQual.Fit (TextWidth (sh.Shooter.QualificationName));
                // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
                Font.Style:= [];
                tcRegion.Fit (TextWidth (sh.Shooter.RegionAbbr1));
                // пїЅпїЅпїЅ
                Font.Style:= [];
                st:= sh.Shooter.SocietyName;
                tcSoc.Fit (TextWidth (st));
                // пїЅпїЅпїЅпїЅ
                Font.Style:= [];
                tcClub.Fit (TextWidth (sh.Shooter.SportClub));
                // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
                if fShootersLb.Event<> nil then
                  begin
                    Font.Style:= [fsBold];
                    tcRating.Fit (TextWidth (sh.RatingStr));
                  end;
              end;
          end;
      end;
    table.AddSeparator (_printer.MM2PX (separator));
    w:= table.Width;
    if w< _printer.Width then
      begin
        tcName.Width:= tcName.Width+_printer.Width-w;
        Result:= true;
      end;
  end;

  procedure MakeNewPage;
  var
    st: string;
  begin
    if page_idx> 1 then
      _printer.NewPage;

    with _printer.Canvas do   // footer
      begin
        Font.Height:= font_height_large;
        Pen.Width:= 1;
        y:= _printer.Bottom-footerheight+_printer.MM2PY (2);
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
        Font.Height:= font_height_small;
        Font.Style:= [];
        st:= format (PAGE_NO,[page_idx]);
        TextOut (_printer.Right-TextWidth (st),y,st);
        st:= format (PAGE_FOOTER,[VERSION_INFO_STR]);
        TextOut (_printer.Left,y,st);
      end;

    y:= _printer.Top;
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        if fShootersLb.Event<> nil then
          begin
            case Criteria of
              plAll,plMarked: st:= format (Language ['MainForm.RatingInEvent'],[fShootersLb.Event.ShortName]);
              plInStart: st:= Language ['MainForm.ParticipatedList'];
            else
              st:= '';
            end;
          end
        else
          begin
            st:= Language ['MainForm.GroupListTitle'];
          end;
        TextOut (_printer.Left,y,st);
        st:= _DayToStr (fData.RatingDate)+' '+
          _MonthToStr (fData.RatingDate)+' '+
          _YearToStr (fData.RatingDate);
        Font.Style:= [];
        TextOut (_printer.Right-TextWidth (st),y,st);
        y:= y+thl+_printer.MM2PY (2);
        Pen.Width:= 1;
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
      end;
  end;

  procedure CreateTable;
  begin
    table:= TMyTableColumns.Create;
    tcIndex:= table.Add;  // пїЅпїЅпїЅпїЅпїЅ
    tcName:= table.Add;  // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅ
    tcYear:= table.Add;  // пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
    tcQual:= table.Add;  // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
    tcRegion:= table.Add;  // пїЅпїЅпїЅпїЅпїЅпїЅ
    tcSoc:= table.Add;  // пїЅпїЅпїЅ
    tcClub:= table.Add;  // пїЅпїЅпїЅпїЅ
    tcRating:= table.Add;  // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
  end;

var
  i: integer;
  sh: TShootersFilterItem;
  in_list: boolean;

  procedure PrintShooter;
  var
    x: integer;
    st: string;
  begin
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        // пїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [];
        st:= IntToStr (sh.Index+1);
        x:= _printer.Left+tcIndex.Right-_printer.MM2PX (separator/2)-TextWidth (st);
        TextOut (x,y,st);
        // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅ
        Font.Style:= [fsBold];
        x:= _printer.Left+tcName.Left+_printer.MM2PX (separator/2);
  st:= sh.Shooter.Surname;
        TextOut (x,y,st);
        x:= x+TextWidth (st);
        if sh.Shooter.Name<> '' then
          begin
            Font.Style:= [];
            st:= sh.Shooter.Name;
            TextOut (x,y,', '+st);
            if sh.Shooter.StepName<> '' then
              TextOut (x+TextWidth(', '+st), y, ' '+sh.Shooter.StepName);
          end;
        // пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [];
  st:= sh.Shooter.BirthFullStr;
        TextOut (_printer.Left+tcYear.Left+_printer.MM2PX (separator/2),y,st);
        // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [];
        st:= sh.Shooter.QualificationName;
        TextOut (_printer.Left+tcQual.Left+_printer.MM2PX (separator/2),y,st);
        // пїЅпїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [];
        st:= sh.Shooter.RegionAbbr1;
        TextOut (_printer.Left+tcRegion.Left+_printer.MM2PX (separator/2),y,st);
        // пїЅпїЅпїЅ
        if sh.Shooter.SportSociety<> nil then
          begin
            Font.Style:= [];
            st:= sh.Shooter.SocietyName;
            TextOut (_printer.Left+tcSoc.Left+_printer.MM2PX (separator/2),y,st);
          end;
        // пїЅпїЅпїЅпїЅ
        Font.Style:= [];
        st:= sh.Shooter.SportClub;
        TextOut (_printer.Left+tcClub.Left+_printer.MM2PX (separator/2),y,st);
        // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ
        if fShootersLb.Event<> nil then
          begin
            Font.Style:= [fsBold];
            st:= sh.RatingStr;
            TextOut (_printer.Left+tcRating.Right-_printer.MM2PX (separator/2)-TextWidth (st),y,st);
          end;
      end;
  end;

begin
  // Показываем диалог печати для выбора принтера
  if not PrintDialog1.Execute then
    exit;  // Пользователь отменил печать
    
  _printer:= TMyPrinter.Create (Prn);
  _printer.PageSize:= MyPrint.psA4;
  _printer.Orientation:= poPortrait;
  if _printer.PDF<> nil then
    begin
      _printer.Title:= Language ['ShootersListPrintTitle'];
      _printer.PDF.ProtectionEnabled:= true;
      _printer.PDF.ProtectionOptions:= [MyPrint.coPrint];
      _printer.PDF.Compression:= MyPrint.ctFlate;
    end
  else
    _printer.Title:= Language ['MainForm.ShootersListPDFTitle'];
  _printer.Copies:= 1;
  _printer.BeginDoc;
  _printer.SetBordersMM (15,10,10,10);

  CreateTable;

  with _printer.Canvas.Font do
    begin
      Charset:= PROTOCOL_CHARSET;
      Name:= 'Arial';
      Size:= 12;
      font_height_large:= Height;
      font_height_small:= round (font_height_large * 3/4);
    end;

  repeat
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        thl:= TextHeight ('Mg');
        Font.Height:= font_height_small;
        ths:= TextHeight ('Mg');
      end;
    footerheight:= ths+_printer.MM2PY (4);
    if MeasureColumns then
      break
    else
      begin
        if abs (font_height_large)> 4 then
          begin
            inc (font_height_large);
            font_height_small:= round (font_height_large * 3/4);
          end
        else
          begin
            _printer.Abort;
            _printer.Free;
            table.Free;
            exit;
          end;
      end;
  until false;

  with _printer.Canvas do
    begin
      page_idx:= 1;
      MakeNewPage;
      for i:= 0 to fShootersLb.Count-1 do
        begin
          sh:= fShootersLb.Shooters.Items [i];

          case Criteria of
            plAll: in_list:= true;
            plMarked: in_list:= (sh.Shooter.Marked> 0) or (fShootersLb.MarkedCount= 0);
            plInStart: in_list:= (sh.InStart >= 0);
          else
            in_list:= false;
          end;

          if in_list then
            begin
              if y+thl>= _printer.Bottom-footerheight then
                begin
                  inc (page_idx);
                  MakeNewPage;
                end;
              PrintShooter;
              y:= y+thl;
            end;
        end;
    end;

  table.Free;

  _printer.EndDoc;
  _printer.Free;
end;

{
procedure TShootersFilter.PrintList(APrinter: TObject; Criteria: TPrintListCriteria);
var
  lpx,lpy: integer;
  canv: TCanvas;
  leftborder,topborder,rightborder,bottomborder: integer;
  p_width,p_height: integer;

var


var
  i: integer;
begin
end;
}


procedure TMainForm.PurgeDailyBackups;
var
  sr: TSearchRec;
  dir: string;
  res: integer;
begin
  if fDataFileName= '' then
    exit;
  dir:= IncludeTrailingPathDelimiter (ExtractFileDir (fDataFileName));
  res:= FindFirst (fDataFileName+'.*.BAK',faAnyFile,sr);
  while res= 0 do
    begin
      DeleteFile (dir+sr.Name);
      res:= FindNext (sr);
    end;
  FindClose (sr);
end;

procedure TMainForm.mnuPurgeDailyBackupsClick(Sender: TObject);
begin
  PurgeDailyBackups;
end;

{ TStartListPanel }

procedure TStartListPanel.ArrangeControls;
begin
  fCaptionRect:= ClientRect;
  fCaptionRect.Left:= fCaptionRect.Left+8;
  fCaptionRect.Right:= ClientRect.Right-8-btnClose.Width-8;
  fCaptionRect.Top:= fCaptionRect.Top+8;
  if Visible then
    begin
      Canvas.Font:= SysFonts.MessageFont;
      Canvas.Font.Style:= [fsBold];
      if (fCaptionRect.Right> fCaptionRect.Left) and (fStart<> nil) and (fStart.Info.TitleText<> '') then
        fCaptionRect.Bottom:= fCaptionRect.Top+
          DrawText (Canvas.Handle,PChar (FixRussianDisplay(fStart.Info.TitleText)),Length (fStart.Info.TitleText),
            fCaptionRect,DT_WORDBREAK or DT_CALCRECT)
      else
        fCaptionRect.Bottom:= fCaptionRect.Top+Canvas.TextHeight ('Mg');
      Canvas.Font:= btnOpenStart.Font;
      btnOpenStart.ClientWidth:= Canvas.TextWidth (btnOpenStart.Caption)+32;
      btnOpenStart.ClientHeight:= Canvas.TextHeight ('Mg')+12;
      btnPrintOut.ClientWidth:= Canvas.TextWidth (btnPrintOut.Caption)+32;
      btnPrintOut.ClientHeight:= btnOpenStart.ClientHeight;
      btnShooters.ClientWidth:= Canvas.TextWidth (btnShooters.Caption)+32;
      btnShooters.ClientHeight:= btnOpenStart.ClientHeight;
      btnStats.ClientWidth:= Canvas.TextWidth (btnStats.Caption)+32;
      btnStats.ClientHeight:= btnOpenStart.ClientHeight;
    end;
  btnOpenStart.Top:= fCaptionRect.Bottom+8;
  btnOpenStart.Left:= 8;
  btnShooters.Left:= btnOpenStart.Left+btnOpenStart.Width+8;
  btnShooters.Top:= btnOpenStart.Top;
  btnStats.Left:= btnShooters.Left+btnShooters.Width+8;
  btnStats.Top:= btnOpenStart.Top;
  btnPrintOut.Left:= btnStats.Left+btnStats.Width+8;
  btnPrintOut.Top:= btnOpenStart.Top;
  ClientHeight:= btnOpenStart.Top+btnOpenStart.Height+8;
  btnClose.Left:= ClientRect.Right-8-btnClose.Width;
end;

constructor TStartListPanel.Create(AOwner: TComponent);
begin
  inherited;
  fStart:= nil;
  fStartForm:= nil;
  btnOpenStart:= TButton.Create (self);
  btnOpenStart.Left:= 8;
  fCaptionRect.Left:= 0;
  fCaptionRect.Right:= 0;
  fCaptionRect.Top:= 0;
  fCaptionRect.Bottom:= 8;
  btnOpenStart.Top:= fCaptionRect.Bottom+8;
  btnOpenStart.Caption:= Language ['btnOpenStart'];
  btnOpenStart.Width:= 137;
  btnOpenStart.Height:= 25;
  btnOpenStart.Parent:= self;

  btnPrintOut:= TButton.Create (self);
  btnPrintOut.Left:= btnOpenStart.Left+btnOpenStart.Width+8;
  btnPrintOut.Top:= btnOpenStart.Top;
  btnPrintOut.Height:= btnOpenStart.Height;
  btnPrintOut.Width:= 177;
  btnPrintOut.Caption:= Language ['btnPrintOut'];
  btnPrintOut.Parent:= self;

  btnClose:= TButton.Create (self);
  btnClose.Caption:= 'X';
  btnClose.Top:= 8;
  btnClose.Height:= GetSystemMetrics (SM_CYCAPTION);
  btnClose.Width:= btnClose.Height;
  btnClose.Left:= 8;
  btnClose.Parent:= self;

  btnShooters:= TButton.Create (self);
  btnShooters.Caption:= Language ['btnShooters'];
  btnShooters.Top:= 8;
  btnShooters.Height:= btnOpenStart.Height;
  btnShooters.Width:= 137;
  btnShooters.Parent:= self;

  btnStats:= TButton.Create (self);
  btnStats.Caption:= Language ['btnStats'];
  btnStats.Top:= 8;
  btnStats.Height:= btnOpenStart.Height;
  btnStats.Width:= 137;
  btnStats.Parent:= self;

  BevelEdges:= [beLeft,beTop,beRight,beBottom];
  BevelKind:= bkTile;
  BorderWidth:= 1;
  Font:= SysFonts.MessageFont;
  Canvas.Font:= SysFonts.MessageFont;
  Color:= clWhite;
end;

destructor TStartListPanel.Destroy;
begin
  if fStart<> nil then
    fStart.OnDelete:= nil;
  fStart:= nil;
  inherited;
end;

procedure TStartListPanel.OnDeleteStart(Sender: TObject);
begin
  // пїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ пїЅпїЅпїЅпїЅпїЅ
  StartList:= nil;
end;

procedure TStartListPanel.Paint;
begin
  with Canvas do
    begin
      Brush.Color:= clWindow;
      FillRect (ClipRect);
      if fStart<> nil then
        begin
          Font.Style:= [fsBold];
          var FixedText := FixRussianDisplay(fStart.Info.TitleText);
          DrawText (Canvas.Handle,PChar (FixedText),Length (FixedText),
            fCaptionRect,DT_WORDBREAK);
        end;
    end;
end;

procedure TStartListPanel.Resize;
begin
  inherited;
  ArrangeControls;
end;

procedure TStartListPanel.set_Start(const Value: TStartList);
begin
  if Value<> fStart then
    begin
      if fStart<> nil then
        begin
          fStart.RemoveNotifier (Handle);
          fStart.OnDelete:= nil;
        end;
      fStart:= Value;
      if fStart= nil then
        begin
          Caption:= '';
          Visible:= false;
        end
      else
        begin
          fStart.OnDelete:= OnDeleteStart;
          fStart.AddNotifier (Handle);
          btnPrintOut.Visible:= fStart.StartNumbersPrintout.IsPending;
          btnShooters.Enabled:= (fStart.Shooters.Count> 0);
          Caption:= fStart.Info.CaptionText;
          ArrangeControls;
          Invalidate;
          Visible:= true;
        end;
    end;
end;

procedure TStartListPanel.UpdateLanguage;
begin
  btnOpenStart.Caption:= Language ['btnOpenStart'];
  btnPrintOut.Caption:= Language ['btnPrintOut'];
  btnShooters.Caption:= Language ['btnShooters'];
  btnStats.Caption:= Language ['btnStats'];
  ArrangeControls;
end;

procedure TMainForm.UpdateLanguage;
var
  tn: TTreeNode;
begin
  LoadControlLanguage (self);
  LoadControlLanguage (fShootersLb.Header);
  Caption:= format (Language ['MainForm'],[VERSION_INFO_STR]);
  MARKED_STR:= FixRussianDisplay(Language ['MainForm.Marked']);
  fStartPanel.UpdateLanguage;
  Data.UpdateLanguage;
  if tvGroups.Items.Count> 0 then
    begin
      tn:= tvGroups.Items [0];
      if tn<> nil then
        tn.Text:= Language ['MainForm.GroupsItem'];
    end;
end;

procedure TStartListPanel.WMEraseBkgnd(var M: TMessage);
begin
  M.Result:= LRESULT (false);
end;

procedure TStartListPanel.WMStartListInfoChanged(var M: TMessage);
begin
  ArrangeControls;
  M.Result:= LRESULT (true);
end;

procedure TStartListPanel.WMStartListShootersChanged(var M: TMessage);
begin
  btnShooters.Enabled:= (fStart.Shooters.Count> 0);
end;

procedure TStartListPanel.WMStartNumbersPrintout(var M: TMessage);
begin
  btnPrintOut.Visible:= fStart.StartNumbersPrintout.IsPending;
  M.Result:= LRESULT (true);
end;

function GetCurrentDataFileName: string;
begin
  if Assigned(MainForm) then
    Result := MainForm.GetActiveDataFileName
  else
    Result := '';
end;

end.

