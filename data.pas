{$A-,J+}
unit Data;

{$DEFINE DISABLE_PDF}  // Temporary disable PDF for Delphi 12 migration
{$WARN IMPLICIT_STRING_CAST OFF}  // Disable Unicode warnings for Delphi 12 migration
{$WARN IMPLICIT_STRING_CAST_LOSS OFF}

{.$define SampleStart}
{.$define debug_info}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  Vcl.Graphics,
  System.Math,
  System.DateUtils,
  MyStrings,
  Vcl.Printers,
  // PDF, // �������� ���������
  System.Win.Registry,
  wb_registry,
  MyLanguage,
  calceval,
  MyReports,
  MyTables,
  MyPrint,
  ZLib,
  CRC32,
  Barcode,
  MyTable,
  OldData;

// TODO: ������� � ������������� ����
// TODO: ��������� �������� � ������������
// TODO: ������� ����������� ��������
// TODO: ������� � ������������� ��������� ������� ��������� ��� �������� - � ���������� � ������
// TODO: ������� ������������ ������� ���� � ������� (�� ��������) � � ������� ������������� (��������) ����
// TODO: ��� �������� ������� ���� ������������, ��� �������� �� �������� �� ���������� �� ����������

type
  TLanguage= (lRussian,lEnglish,lUnknown);

  // PDF compatibility aliases for Delphi 12 migration
  {$IFDEF DISABLE_PDF}
  // Use PDF types from MyPrint unit to avoid conflicts
  TPDFDocument = MyPrint.TPDFDocument;
  {$ENDIF}

type
  TWordDynArray = array of Word;
  
  EInvalidDataFile= class (Exception);
  EDataFileCorrupt= class (Exception);
  EInvalidDataFileVersion= class (Exception);

const
  PrintTwoStartNumbersOnPage: boolean= true;

const
  VERSION_INFO_STR= '1.5.9.2';

const
  OUT_OF_RANK_MARK: string= '��';
  NOT_FOR_TEAM_MARK: string= '��';
  FINAL_MARK: string= '�';
  PROTOCOL_MAKER_SIGN: string= '���������: _________________ (�������, ������)';
  DNS_MARK: string= '������';
  DELETED_CHAMPIONSHIP_MARK: string= '<��������� ���������>';
  DELETED_EVENT_MARK: string= '<��������� ����������>';
  NEW_DATA_NAME: string= '����� ����';
  ALL_RESULTS_PDF_CAPTION: string= 'WinBASE - ��� ����������, %s ';
  START_LIST_PAGE_TITLE: string= '��������� ��������';
  PAGE_NO: string= '�������� %d';
  PAGE_FOOTER: string= 'WinBASE %s ���������� ����������� �����������, ��������, 2006-2007';
  START_LIST_CONTINUE_MARK: string= '...�����������';
  RF_START_TIME_1: string= '�����  hh:mm';
  RF_START_TIME_2: string= '�����  hh:mm';
  FINAL_TIME: string= '�����  hh:mm';
  FINAL_DATETIME: string= '�����  d-mm-yyyy, hh:nn';
  RELAY_NO: string= '�������� %d';
  MT_RELAY_NO: string= '��������� %d';
  SECRETERY_TITLE: string= '������� ��������� ������������,';
  START_LIST_PRINT_TITLE: string= 'WinBASE - ��������� �������� � ���������� %s';
  START_TIME: string= '�����  hh:nn';
  CF_START_TIME_1: string= '����� ��  hh:nn';
  CF_START_DATETIME_1: string= '����� ��  d-mm-yyyy, hh:nn';
  CF_START_TIME_2: string= '����� ��  hh:nn';
  CF_START_DATETIME_2: string= '����� ��  d-mm-yyyy, hh:nn';
    PROTOCOL_NO: string= '�������� �%d';
  FINAL_SHOTS_: string= '�����: ';
  FINAL_SHOOTOFF: string= '(�����������: %s)';
  TEAM_CHAMPIONSHIP_TITLE: string= '��������� ����������';
  TEAM_POINTS_TITLE: string= '��������� ������ ��������';
  REGIONS_POINTS_TITLE: string= '��������� ������ ��������';
  REGIONS_POINTS_CONTINUE: string= '��������� ������ �������� (�����������)';
  DISTRICTS_POINTS_TITLE: string= '��������� ������ �������';
  DISTRICTS_POINTS_CONTINUE: string= '��������� ������ ������� (�����������)';
  TECH_REPORT_TITLE: string= '����������� �����';
  TECH_REPORT_SHOOTERS: string= '�����������';
  TECH_REPORT_TOTAL: string= '�����:';
  EVENT_RESULTS_PRINT_TITLE: string= 'WinBASE - ���������� � ���������� %s';
  EVENT_SHOOTERS_TITLE: string= '������ ����������� �� ���������� %s (%s)';
  EVENT_SHOOTERS_PRINT_TITLE: string= 'WinBASE - ������ ���������� � ���������� %s';
  TEAM_STR: string= '�������';
  REGION_STR: string= '������';
  DISTRICT_STR: string= '�����';
  TOTAL_POINTS: string= '�����'#13'������';
  TOTAL_TEAM_CHAMPIONSHIP_TITLE: string= '��������'#13'�������������� ����������';
  TOTAL_REGION_CHAMPIONSHIP_TITLE: string= '��������'#13'�������������� ����������';
  TOTAL_DISTRICT_CHAMPIONSHIP_TITLE: string= '��������'#13'�������������� ����������';
  TOTAL_CHAMPIONSHIP_CONTINUE: string= '...�����������';
  RIFLE_STR: string= '��������';
  PISTOL_STR: string= '��������';
  MOVING_TARGET_STR: string= '����. ������';
  YOUTHS_MEN: string= '�����';
  YOUTHS_WOMEN: string= '�������';
  JUNIORS_MEN: string= '������';
  JUNIORS_WOMEN: string= '�������';
  ADULTS_MEN: string= '�������';
  ADULTS_WOMEN: string= '�������';
  TOTAL_TEAM_CHAMPIONSHIP_PRINT_TITLE: string = 'WinBASE - �������� ������������ ���������� �� ��������';
  TOTAL_REGION_CHAMPIONSHIP_PRINT_TITLE: string = 'WinBASE - �������� ������������ ���������� �� ��������';
  TOTAL_DISTRICT_CHAMPIONSHIP_PRINT_TITLE: string = 'WinBASE - �������� ������������ ���������� �� �������';
  RUSSIAN_SHOOTING_UNION: string= '���������� ���� ������';
  START_NUMBERS_PRINT_TITLE: string= 'WinBASE - ��������� ������';
  START_SHOOTERS_GROUP_NAME: string= '��������� - %s';
  SHOOTER_UNKNOWN: string= '�����������';
  FINAL_NUMBER_CAPTION: string= '� � � � �';
  FINAL_NUMBERS_PRINT_TITLE: string= 'WinBASE - ��������� ������';
  JURY_TITLE: string= '������� ����� �����������,';
  YES_MARK: string= '��';
  CLMN_START_NUMBER: string= '��������� �����';
  CLMN_SHOOTER: string= '�������, ���';
  CLMN_REGION: string= '������';
  CLMN_SOC_CLUB: string= '���, ����';
  CLMN_RESTEAM: string= '�������';
  CLMN_POINTSTEAM: string= '����� �� �������';
  CLMN_POINTSDISTRICT: string= '����� �� �����';
  CLMN_POINTSREGION: string= '����� �� ������';
  CLMN_RELAY: string= '�����';
  CLMN_LANE: string= '���';
  SUM_STR: string= '�����';
  MONTHS_STR: array [1..12] of string=
    ('������','�������','�����','������','���','����',
     '����','�������','��������','�������','������','�������');
  START_NUMBERS_FONT_NAME: string= 'Tahoma';
  
const
  WM_STARTLISTINFOCHANGED= WM_USER+0;
  WM_STARTNUMBERSPRINTOUT= WM_USER+1;
  WM_STARTLISTEVENTSCHANGED= WM_USER+2;
  WM_STARTLISTSHOOTERSDELETED= WM_USER+3;
  WM_STARTLISTSHOOTERSCHANGED= WM_USER+4;
  WM_CHANGELANGUAGE= WM_USER+5;
  WM_BARCODEBASE= WM_USER+1000;

var
  Global_TruncatePrintedClubs: boolean;
  Global_ProtocolFullRegionNames: boolean;
  Global_CompareBySeries: boolean;
  Global_PrintJury: boolean;
  Global_PrintSecretery: boolean;

const
  OLD_DATA_FILE_GUID: TGUID = '{2E8D7022-45EE-43D2-BBCB-1CDB55D8D92E}';
  TEXT_DATA_FILE_ID= 'WinBASE Data File'+#13#10+'Russian Shooting Union, 2006'+#13#10#13#10;
  CURRENT_DATAFILE_VERSION= 42;

const
  PROTOCOL_CHARSET= RUSSIAN_CHARSET;

const
  START_LIST_FILE_ID: TGUID= '{C9690B4C-E471-4FFD-96E0-497619036351}';

const
  POINTS_FILE_TEXT_ID = #13#10'WinBASE event points file'#13#10;

const
  CSVDelimiter: string= ';';


const
  RULES_CLASSIC= 0;
  RULES_RAPIDFIRE_2011= 1;
  RULES_CENTERFILE_2011= 2;

type
  TData= class;
  TShooterItem= class;
  TGroupItem= class;
  TGroups= class;
  TEventItem= class;
  TEvents= class;
  TQualificationItem= class;
  TQualifications= class;
  TChampionships= class;
  TResultItem= class;
  TResults= class;
  TShooters= class;

  TStartListEventShooterItem= class;
  TStartListEvents= class;
  TStartListEventItem= class;
  TStartListEventRelays= class;
  TStartListInfo= class;
  TStartListPoints= class;
  TStartListShooters= class;
  TStartList= class;
  TStartLists= class;

  TShootingChampionshipItem= class;
  TShootingChampionships= class;
  TShootingEventItem= class;
  TShootingEvents= class;

  TEventRatedPlaces= record
    RatedPlaces: array of integer;
  end;

  TFinalResultOld= record
    _int: word;
    _frac: byte;
  end;

  TAllRanksArray= array of integer;

  TChampionshipItem= class (TCollectionItem)
  private
    _changed: boolean;
    fTag: String;                     {���������� ���}
    fName: String;                    {������ ��������}
    fMQS: boolean;                    {���� �� MQS}
    fRatedEvents: array of TEventRatedPlaces;
    fRatingHold: word;                {������� ������� ���������� �������}
    fPeriod: word;                    {���� �������� ��������}
    fChanging: integer;
    fLastChange: TDateTime;
    procedure set_Tag(const Value: String);
    procedure set_Name(const Value: String);
    procedure set_MQS(const Value: boolean);
    procedure set_RatingHold(const Value: word);
    procedure set_Period(const Value: word);
    function get_Data: TData;
    function get_Championships: TChampionships;
    function get_RatedPlaces(AEvent: TEventItem; Index: integer): integer;
    procedure set_RatedPlaces(AEvent: TEventItem; Index: integer; const Value: integer);
    function get_RatingTable(eventindex, index: integer): integer;
    procedure set_RatingTable(eventindex, index: integer; const Value: integer);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property Tag: String read fTag write set_Tag;
    property Name: String read fName write set_Name;
    property MQS: boolean read fMQS write set_MQS;
    function RatesCount (AEvent: TEventItem): integer; overload;
    function RatesCount (index: integer): integer; overload;
    property RatingHold: word read fRatingHold write set_RatingHold;
    property Period: word read fPeriod write set_Period;
    procedure WriteToStream (Stream: TStream);
    procedure ReadFromStream (Stream: TStream);
    property Data: TData read get_Data;
    procedure CreateTag;
    property Championships: TChampionships read get_Championships;
    function GetRating (AResult: TResultItem): integer;
    procedure ClearTable;
    property Ratings [AEvent: TEventItem; Index: integer]: integer read get_RatedPlaces write set_RatedPlaces;
    procedure DeleteEvent (AEvent: TEventItem);
    property RatingsTable [eventindex: integer; index: integer]: integer
      read get_RatingTable write set_RatingTable;
    procedure AddEvent (AEvent: TEventItem);
    property WasChanged: boolean read _changed;
    procedure Check;
    procedure Assign (Source: TPersistent); override;
    function CSVStr: string;
    procedure Changed;
    procedure BeginChange;
    procedure EndChange;
  end;

  TChampionships= class (TCollection)
  private
    fData: TData;
    fChanged: boolean;
    function get_Championship(Tag: String): TChampionshipItem;
    function get_ChampionshipIdx(Index: integer): TChampionshipItem;
    function get_WasChanged: boolean;
  public
    constructor Create (AData: TData);
    property Championships [Tag: String]: TChampionshipItem read get_Championship; default;
    property Items [Index: integer]: TChampionshipItem read get_ChampionshipIdx;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    function Add: TChampionshipItem;
    property Data: TData read fData;
    function FindByName (AName: String): TChampionshipItem;
    procedure MergeWith (AChampionships: TChampionships);
    procedure DeleteEventTable (AEvent: TEventItem);
    procedure AddEventTable (AEvent: TEventItem);
    property WasChanged: boolean read get_WasChanged;
    procedure Check;
    procedure ExportToCSV (const FName: TFileName);
  end;

  TEventBonus10= record
    fResult: DWORD;
    fRating: integer;
  end;
  TEventBonus= record
    fResult: word;
    fRating: integer;
  end;

  TAgeGroup= (agYouths,agJuniors,agAdults);
  TEventType= (etRegular,etRapidFire,etCenterFire,etMovingTarget,etCenterFire2013,etThreePosition2013,etMovingTarget2013);
  TWeaponType= (wtNone,wtRifle,wtPistol,wtMoving);
  TWeapons= set of TWeaponType;

  TQualificationResultOld= record
    Competition: integer;
    Final: TFinalResultOld;
  end;
  TQualificationResult10= record
    Competition10: DWORD;
    //Total10: DWORD;
    CompetitionTens10: DWORD;
  end;

  TFinalStages= class;

  TFinalStageItem= class (TCollectionItem)
  private
    fShots: integer;
    fTitle: String;
    fTens: boolean;
    fChanged: boolean;
    procedure set_ShotsCount(const Value: integer);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property ShotsCount: integer read fShots write set_ShotsCount;
    function Stages: TFinalStages;
  end;

  TFinalStages= class (TCollection)
  private
    fEvent: TEventItem;
    fChanged: boolean;
    function get_Item (Index: integer): TFinalStageItem;
  public
    constructor Create (AEvent: TEventItem);
    function Add: TFinalStageItem;
    property Items[Index:integer]: TFinalStageItem read get_Item; default;
  end;

  TEventItem= class (TCollectionItem)
  private
    _changed: boolean;
    fTag: String;                         {���������� ���}
    fCode: String;                        {��� ���������� �������������}
    fShortName: String;                   {������������}
    fName: String;                        {������ ��������}
    fMQSResult10: DWORD;                     {��������� MQS}
    fMinRatedResult10: DWORD;                {����������� ����������� ���������}
    fFinalFracs: boolean;                 {���� �� � ������ ������� �����}
    fFinalPlaces: word;                   {���-�� ��������� ����}
    fFinalShots: word;                    {���-�� ��������� ���������}
    fStages: byte;                        {���-�� ���������}
    fSeriesPerStage: byte;                {���-�� ����� � ���������}
    fQualifications10: array of TQualificationResult10;    {���������������� ����������}
    fBonusRatings: array of TEventBonus;  {������� �������� �� ���������}
    fBonusRatings10: array of TEventBonus10;
    fRelayTime: TDateTime;                {����� �� ���� �����}
    fEventType: TEventType;               {��� ���������� - �������, ��-8, ��-5, ��-12, ��-12}
    fWeaponType: TWeaponType;             {��� ������ - ��������, ��������, ����.}   // ������ >=2
    fCompareBySeries: boolean;            {���������� ���������� �� ��������� ������ ��� ���}
    fCompareByFinal: boolean;
    //fCompFracs: boolean;
    fSeparateFinalTable: boolean;
    fChanging: integer;
    fLastChange: TDateTime;
    procedure set_SeparateFinalTable(const Value: boolean);
    //procedure set_CompFracs(const Value: boolean);                  // ������� ���������� � ������������
    procedure set_CompareByFinal(const Value: boolean);             {25.11.12 - ���������� ������ �� ���������� ������, ��� ����� ������������}
    procedure set_Tag(const Value: String);
    procedure set_Name(const Value: String);
    procedure set_MQSResult(const Value: DWORD);
    procedure set_MinRatedResult(const Value: DWORD);
    procedure set_FinalFracs(const Value: boolean);
    procedure set_FinalPlaces(const Value: word);
    procedure set_Stages(const Value: byte);
    procedure set_SeriesPerStage(const Value: byte);
    function get_Qualifications(index: integer): TQualificationResult10;
    procedure set_Qualifications(index: integer; const Value: TQualificationResult10);
    function get_Bonus(index: integer): TEventBonus;
    procedure set_Bonus(index: integer; const Value: TEventBonus);
    function get_Bonus10(index: integer): TEventBonus10;
    procedure set_Bonus10(index: integer; const Value: TEventBonus10);
    function get_Data: TData;
    procedure SortBonuses;
    procedure SortBonuses10;
    procedure set_ShortName(const Value: String);
    function get_Events: TEvents;
    procedure set_FinalShots(const Value: word);
    procedure set_Code(const Value: String);
    procedure set_RelayTime(const Value: TDateTime);
    procedure set_EventType(const Value: TEventType);
    procedure CorrectTag;
    procedure set_CompareBySeries(const Value: boolean);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property Tag: String read fTag write set_Tag;
    property ShortName: String read fShortName write set_ShortName;
    property Name: String read fName write set_Name;
    property MQSResult10: DWORD read fMQSResult10 write set_MQSResult;
    property MinRatedResult10: DWORD read fMinRatedResult10 write set_MinRatedResult;
    property FinalFracs: boolean read fFinalFracs write set_FinalFracs;
    property FinalPlaces: word read fFinalPlaces write set_FinalPlaces;
    property SeparateFinalTable: boolean read fSeparateFinalTable write set_SeparateFinalTable;
    property FinalShots: word read fFinalShots write set_FinalShots;
    property Stages: byte read fStages write set_Stages;
    property SeriesPerStage: byte read fSeriesPerStage write set_SeriesPerStage;
    property Qualifications10 [index: integer]: TQualificationResult10 read get_Qualifications write set_Qualifications;
    function QualificationsCount: integer;
    //function QualifiedTotal (ATotal: DWORD): TQualificationItem; overload;
    //function QualifiedComp (AComp: DWORD): TQualificationItem; overload;
    //function Qualified10 (ACompetition: DWORD; ATotal: DWORD; var ByTotal: boolean): TQualificationItem; overload;
    function Qualified10 (ACompetition: DWORD; Tens: boolean): TQualificationItem;
    property Bonuses [index: integer]: TEventBonus read get_Bonus write set_Bonus;
    property Bonuses10 [index: integer]: TEventBonus10 read get_Bonus10 write set_Bonus10;
    function BonusCount: integer;
    function BonusCount10: integer;
    procedure ClearBonuses;
    procedure AddBonus (Bonus: TEventBonus);
    procedure AddBonus10(Bonus: TEventBonus10);
    function GetBonus (AResult: DWORD; WithTens: boolean): integer;
    property Data: TData read get_Data;
    function InFinal (ARank: integer): boolean;
    procedure CreateTag;
    property Events: TEvents read get_Events;
//    function FinalStr (AFinal: TFinalResult): string;
    function FinalStr (AFinal: DWORD): string;
    function TotalSeries: integer;
    property Code: String read fCode write set_Code;
    property RelayTime: TDateTime read fRelayTime write set_RelayTime;
    property EventType: TEventType read fEventType write set_EventType;
    property WeaponType: TWeaponType read fWeaponType write fWeaponType;
    property WasChanged: boolean read _changed;
    procedure DeleteQualification (index: integer);
    property CompareBySeries: boolean read fCompareBySeries write set_CompareBySeries;
    procedure Assign (Source: TPersistent); override;
    function HaveResults: boolean;
    function CompleteName: String;
    procedure Check;
    function TwoStarts: boolean;
    function CSVStr: string;
    property CompareByFinal: boolean read fCompareByFinal write set_CompareByFinal;
    //property CompFracs: boolean read fCompFracs write set_CompFracs;
    //function CompetitionStr (AComp: DWORD): string; overload;
    //function CompetitionStr (AComp: DWORD; WithTens: boolean): string; overload;
    //function SerieTemplate: string;
    function FinalShotTemplate: String;
    //function CompTemplate: string;
    function FinalTemplate: String;
    //function TotalTemplate: string;
    procedure Changed;
    procedure BeginChange;
    procedure EndChange;
  end;

  TEvents= class (TCollection)
  private
    fChanged: boolean;
    fData: TData;
    function get_Event(Tag: String): TEventItem;
    function get_EventIdx(index: integer): TEventItem;
    function get_WasChanged: boolean;
  public
    constructor Create (AData: TData);
    property Events [Tag: String]: TEventItem read get_Event; default;
    property Items [index: integer]: TEventItem read get_EventIdx;
    function Add: TEventItem;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property Data: TData read fData;
    procedure MergeWith (AEvents: TEvents);
    property WasChanged: boolean read get_WasChanged;
    procedure DeleteQualification (index: integer);
    procedure Check;
    function FindByName (const AName: String): TEventItem;
    procedure ExportToCSV (const FName: TFileName);
  end;

  TFilteredEventItem= class (TCollectionItem)
  private
    fEvent: TEventItem;
  public
    property Event: TEventItem read fEvent;
  end;

  TEventsFilter= class (TCollection)
  private
    function FindEvent (AEvent: TEventItem): TFilteredEventItem;
    function get_Event(index: integer): TEventItem;
  public
    constructor Create;
    function Filtered (AEvent: TEventItem): boolean;
    procedure Add (AEvent: TEventItem); overload;
    procedure Add (AFilter: TEventsFilter); overload;
    procedure Add (AEvents: TEvents); overload;
    procedure Delete (AEvent: TEventItem); overload;
    property Events [index: integer]: TEventItem read get_Event; default;
    function IndexOf (AEvent: TEventItem): integer;
    procedure Add (AGroup: TGroupItem); overload;
  end;

  TQualificationItem= class (TCollectionItem)
  private
    _changed: boolean;
    fLastChange: TDateTime;
    fName: String;
    fSetByResult: boolean;
    procedure set_Name(const Value: String);
    procedure set_SetByResult(const Value: boolean);
    function get_Data: TData;
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property Name: String read fName write set_Name;
    property SetByResult: boolean read fSetByResult write set_SetByResult;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property Data: TData read get_Data;
    function Qualifications: TQualifications;
    property WasChanged: boolean read _changed;
    procedure Check;
    procedure Assign (Source: TPersistent); override;
    function CSVStr: string;
    procedure Changed;
  end;

  TQualifications= class (TCollection)
  private
    fData: TData;
    fChanged: boolean;
    function get_QualificationIdx(index: integer): TQualificationItem;
    function get_WasChanged: boolean;
  public
    constructor Create (AData: TData);
    function Add: TQualificationItem;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property Data: TData read fData;
    property Items [index: integer]: TQualificationItem read get_QualificationIdx;
    procedure MergeWith (AQualifications: TQualifications);
    property WasChanged: boolean read get_WasChanged;
    function FindByName (const AName: String): TQualificationItem;
    procedure Check;
    procedure ExportToCSV (const FName: TFileName);
  end;

  TShootingChampionshipItem= class (TCollectionItem)
  private
    fChampionship: TChampionshipItem;
    fChampionshipName: String;
    fCountry: String;
    fTown: String;
    fChanged: boolean;
    fEvents: TShootingEvents;
    fDate1,fDate2: TDateTime;
    fResultsCount: integer;
    function get_WasChanged: boolean;
    procedure set_Country(const Value: String);
//    procedure set_ChampionshipName(const Value: string);
    function get_ChampionshipName: String;
//    procedure set_Championship(const Value: TChampionshipItem);
    procedure set_Town(const Value: String);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    function Championships: TShootingChampionships;
    function DateBelongs (ADate,AThreshold: TDateTime): boolean;
    procedure FitDate;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    function Data: TData;
    property Town: String read fTown write set_Town;
    property Events: TShootingEvents read fEvents;
    property Championship: TChampionshipItem read fChampionship; // write set_Championship;
    property ChampionshipName: String read get_ChampionshipName; // write set_ChampionshipName;
    property Country: String read fCountry write set_Country;
    function Year: integer;
    property From: TDateTime read fDate1;
    property Till: TDateTime read fDate2;
    property WasChanged: boolean read get_WasChanged;
    procedure Assign (Source: TPersistent); override;
//    function ResultsCount: integer;
    property ResultsCount: integer read fResultsCount;
    procedure DeleteEvents (AEvent: TEventItem);
    procedure ConvertEventToNil (AEvent: TEventItem; const AShortName,AName: String);
    procedure IncrementResults (Number: integer);
    procedure DecrementResults (Number: integer);
    procedure SetChampionship (AChampionship: TChampionshipItem; const AName: String);
  end;

  TShootingChampionships= class (TCollection)
  private
    fData: TData;
    fChanged: boolean;
    function get_WasChanged: boolean;
    function get_Item(index: integer): TShootingChampionshipItem;
  public
    constructor Create (AData: TData);
    function Add: TShootingChampionshipItem;
    property Items [index: integer]: TShootingChampionshipItem read get_Item; default;
    function Find (AChampionship: TChampionshipItem; const AName: String; ADate: TDateTime): TShootingChampionshipItem; overload;
    function Find (AChampionship: TChampionshipItem; const AName: String; ADate: TDateTime; const ACountry,ATown: String): TShootingChampionshipItem; overload;
    property Data: TData read fData;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
//    function GetSameEvent (AEvent: TShootingEventItem): TShootingEventItem;
    function FindEvent (const GUID: TGUID): TShootingEventItem;
    property WasChanged: boolean read get_WasChanged;
    procedure DeleteEvents (AEvent: TEventItem);
    procedure ConvertEventToNil (AEvent: TEventItem; const AShortName,AName: String);
    procedure DeleteChampionships (AChamp: TChampionshipItem);
    procedure ConvertChampionshipToNil (AChamp: TChampionshipItem; const AName: String);
  end;

  TShootingEventItem= class (TCollectionItem)
  private
    fDate: TDateTime;
    fEvent: TEventItem;
    fShortName: String;
    fEventName: String;
    fTown: String;
    fTownOverride: boolean;
    fChanged: boolean;
    fId: TGUID;
    fResultsCount: integer;
    procedure set_Id(const Value: TGUID);
//    function ResultsCount: integer;
//    procedure set_ShortName(const Value: string);
    function get_ShortName: String;
    function get_Town: String;
    procedure set_Town(const Value: String);
    function get_EventName: String;
//    procedure set_EventName(const Value: string);
//    procedure set_Event(const Value: TEventItem);
    procedure set_Date(const Value: TDateTime);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    function Events: TShootingEvents;
    property Date: TDateTime read fDate write set_Date;
    function Championship: TShootingChampionshipItem;
    property Event: TEventItem read fEvent;// write set_Event;
    property EventName: String read get_EventName;// write set_EventName;
    property ShortName: String read get_ShortName;// write set_ShortName;
    function Data: TData;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property Town: String read get_Town write set_Town;
    function Country: String;
    property WasChanged: boolean read fChanged;
    procedure Assign (Source: TPersistent); override;
    property Id: TGUID read fId write set_Id;
//    function ResultsCount: integer;
    property ResultsCount: integer read fResultsCount;
    procedure SetEvent (AEvent: TEventItem; const AShortName,AName: String);
    procedure IncrementResults;
    procedure DecrementResults;
    procedure MoveTo (AChampionship: TShootingChampionshipItem);
  end;

  TShootingEvents= class (TCollection)
  private
    fChampionship: TShootingChampionshipItem;
    fChanged: boolean;
    function get_WasChanged: boolean;
    function get_Item(index: integer): TShootingEventItem;
  public
    constructor Create (AChampionship: TShootingChampionshipItem);
    function Add: TShootingEventItem;
    property Items [index: integer]: TShootingEventItem read get_Item; default;
    property Championship: TShootingChampionshipItem read fChampionship;
    function Find (AEvent: TEventItem; const AName: String; ADate: TDateTime): TShootingEventItem; overload;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read get_WasChanged;
  end;

  TResultsSortOrder= (rsoNone,rsoDate,rsoRank,rsoCompetition,rsoRating);

  TResultItem= class (TCollectionItem)
  private
    //fGUID: TGUID;
    _changed: boolean;
    fLastChange: TDateTime;
    fShEvent: TShootingEventItem;
    fJunior: boolean;
    fRank: integer;
    fCompetition10: DWORD;
    fFinal10: DWORD;
    fCompetitionWithTens: boolean;
    fPrecalcRating: integer;
    fDupe: boolean;
    fStartEventShooterLink: TStartListEventShooterItem;
    procedure set_CompetitionWithTens(const Value: boolean);
    procedure set_Final10(const Value: DWORD);
    procedure set_Competition10(const Value: DWORD);
    function get_Championship: TChampionshipItem;
    function get_Country: String;
    function get_Event: TEventItem;
    function get_Town: String;
    procedure set_ShootingEvent(const Value: TShootingEventItem);
    function get_Date: TDateTime;
    function get_ChampionshipName: String;
    function get_EventName: String;
    procedure set_Rank(const Value: integer);
    function get_Data: TData;
    function get_Group: TGroupItem;
    function get_Shooter: TShooterItem;
    procedure set_Junior(const Value: boolean);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property Date: TDateTime read get_Date;// write set_Date;
    property Championship: TChampionshipItem read get_Championship;// write set_Championship;
    property ChampionshipName: String read get_ChampionshipName;// write set_ChampionshipName;
    property Event: TEventItem read get_Event;// write set_Event;
    property EventName: String read get_EventName;// write set_EventName;
    function EventShortName: String;
    property ShootingEvent: TShootingEventItem read fShEvent write set_ShootingEvent;
    property Country: String read get_Country;// write set_Country;
    property Town: String read get_Town;// write set_Town;
    property Junior: boolean read fJunior write set_Junior;
    property Rank: integer read fRank write set_Rank;
    property Competition10: DWORD read fCompetition10 write set_Competition10;
    property CompetitionWithTens: boolean read fCompetitionWithTens write set_CompetitionWithTens;
    function CompetitionStr: string;
    property Final10: DWORD read fFinal10 write set_Final10;
    function Rating: integer;
    function RankStr: string;
    function FinalStr: string;
    function TotalStr: string;
    function RatingStr: string;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property Shooter: TShooterItem read get_Shooter;
    property Group: TGroupItem read get_Group;
    property Data: TData read get_Data;
    function CompareTo (AResult: TResultItem; Order: TResultsSortOrder): shortint;
    procedure ResetRating;
    function InFinal: boolean;
    procedure Assign (Source: TPersistent); override;
    procedure EncodeFinal (AInt,AFrac: integer); overload;
    procedure EncodeFinal (AFinal: single); overload;
    function Results: TResults;
    property WasChanged: boolean read _changed;
    function SameAs (R: TResultItem): boolean;
    function AsText: string;
    function CSVStr: string;
    //property GUID: TGUID read fGUID;
    procedure Changed;
  end;

  TDupeResultsRec= record
    Origin,Dupe: TResultItem;
  end;
  TDupeResultsArray= array of TDupeResultsRec;

  TResults= class (TCollection)
  private
    fShooter: TShooterItem;
    fChanged: boolean;
    function get_Result(index: integer): TResultItem;
    function get_Data: TData;
    function get_WasChanged: boolean;
  public
    constructor Create (AShooter: TShooterItem);
    property Items [index: integer]: TResultItem read get_Result; default;
    function Add: TResultItem;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property Shooter: TShooterItem read fShooter;
    property Data: TData read get_Data;
    procedure ResetRatings;
    procedure DeleteResults (AEvent: TEventItem); overload;
    procedure DeleteResults (AChampionship: TChampionshipItem); overload;
    function TotalRating (AEvent: TEventItem): integer;
    function ResultsInEvent (AEvent: TEventItem): integer;
    procedure MergeWith (AResults: TResults);
    function FindSame (AResult: TResultItem): TResultItem;
    property WasChanged: boolean read get_WasChanged;
    function FindSameDateAndEvent (ADate: TDateTime; AEvent: TEventItem): TResultItem;
    procedure Check;
    function Last: TResultItem;
    //function FindByGUID (const GUID: TGUID): TResultItem;
  end;

  TAbbrRec= record
    abbr: String;
    name: String;
  end;

  TAbbrNames= class
  private
    fAbbrs: array of TAbbrRec;
    fData: TData;
    fChanged: boolean;
    function get_Item(index: integer): TAbbrRec;
    function get_Name(Abbr: String): String;
    procedure set_Name(Abbr: String; const Value: String);
  public
    constructor Create (AData: TData);
    destructor Destroy; override;
    function Count: integer;
    procedure Clear;
    property Names [Abbr: String]: String read get_Name write set_Name; default;
    property Items [index: integer]: TAbbrRec read get_Item;
    function IndexOf (Abbr: String): integer;
    function WasChanged: boolean;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    procedure Assign (Source: TAbbrNames);
    procedure Check;
    procedure ExportToCSV (const FName: TFileName);
  end;

  TGender= (Male,Female);
  TGenders= set of TGender;

  TShootersSortOrder= (ssoNone,ssoSurname,ssoAge,ssoRating,ssoRegion,ssoQualification,ssoDistrict,ssoSociety);
  TRemoveResultsEvent= procedure (Sender: TObject) of object;

  TSportSocieties= class;

  TSportSocietyItem= class (TCollectionItem)
  private
    fName: String;
    fChanged: boolean;
    procedure set_Name(const Value: String);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property Name: String read fName write set_Name;
    property WasChanged: boolean read fChanged;
    function Societies: TSportSocieties;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    function ShootersCount: integer;
    function Data: TData;
    procedure Assign (Source: TPersistent); override;
  end;

  TSportSocieties= class (TCollection)
  private
    fData: TData;
    fChanged: boolean;
    function get_Item(Index: integer): TSportSocietyItem;
  public
    constructor Create (AData: TData);
    destructor Destroy; override;
    function WasChanged: boolean;
    function Add: TSportSocietyItem;
    property Items [Index: integer]: TSportSocietyItem read get_Item;
    procedure WriteToStream (Stream: TStream);
    procedure ReadFromStream (Stream: TStream);
    function Find (const AName: String): TSportSocietyItem;
    property Data: TData read fData;
    procedure Check;
  end;

  TShooterItem= class (TCollectionItem)
  private
    _changed: boolean;
    fLastChange: TDateTime;
    fChanging: integer;
    fId: TGUID;
    fISSFID: String;
    fSurname: String;
    fName: String;
    fStepName: String;
    fGender: TGender;
    fBirthYear: word;      // ������ >=3
    fBirthDay: byte;
    fBirthMonth: byte;
    fRegionAbbr1: String;
    fRegionAbbr2: String;
    fDistrictAbbr: String;    // ������ >=2
    fSociety: TSportSocietyItem;   // nil, ���� ��� ��������
    fSportClub: String;
    fTown: String;
    fQualification: TQualificationItem;
    fAddress: String;
    fPhone: String;
    fPassport: String;
    fCoaches: String;
    fWeapons: String;
    fMemo: String;
    fResults: TResults;
    fImages: array of String;
    fMarked: integer;
    procedure set_Society(const Value: TSportSocietyItem);
    function get_DistrictFull: String;
    function get_RegionFull1: String;
    function get_RegionFull2: String;
    procedure set_Marked(const Value: integer);
    function get_Data: TData;
    function get_Group: TGroupItem;
    function get_TotalRating(AEvent: TEventItem): integer;
    function get_Images(index: integer): String;
    procedure set_Image(index: integer; const Value: String);
    function get_BirthYearStr: String;
    procedure set_BirthYearStr(const Value: String);
    procedure set_BirthDateStr(const Value: String);
    function get_BirthDateStr: String;
  function get_BirthFullStr: string;
  procedure set_BirthFullStr(const Value: string);
    procedure set_Surname(const Value: String);
    procedure set_ISSFID(const Value: String);
    procedure set_Name(const Value: String);
    procedure set_StepName(const Value: String);
    procedure set_Gender(const Value: TGender);
    procedure set_RegionAbbr1(const Value: string);
    procedure set_RegionAbbr2(const Value: string);
    procedure set_Club(const Value: string);
    procedure set_Town(const Value: string);
    procedure set_Qualification(const Value: TQualificationItem);
    procedure set_Address(const Value: string);
    procedure set_BirthYear(const Value: word);
    procedure set_Coaches(const Value: string);
    procedure set_DistrictAbbr(const Value: string);
    procedure set_Memo(const Value: string);
    procedure set_Passport(const Value: string);
    procedure set_Phone(const Value: string);
    procedure set_Weapons(const Value: string);
    function get_WasChanged: boolean;
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property PID: TGUID read fId;
    property ISSFID: string read fISSFID write set_ISSFID;
    property Surname: string read fSurname write set_Surname;
    property Name: string read fName write set_Name;
    property StepName: string read fStepName write set_StepName;
    property Gender: TGender read fGender write set_Gender;
    property RegionAbbr1: string read fRegionAbbr1 write set_RegionAbbr1;
    property RegionFull1: string read get_RegionFull1;
    property RegionAbbr2: string read fRegionAbbr2 write set_RegionAbbr2;
    property RegionFull2: string read get_RegionFull2;
    function RegionsAbbr: string;
    property SportClub: string read fSportClub write set_Club;
    property Town: string read fTown write set_Town;
    property Qualification: TQualificationItem read fQualification write set_Qualification;
    property Address: string read fAddress write set_Address;
    property Phone: string read fPhone write set_Phone;
    property Passport: string read fPassport write set_Passport;
    property Coaches: string read fCoaches write set_Coaches;
    property Weapons: string read fWeapons write set_Weapons;
    property Memo: string read fMemo write set_Memo;
    property Results: TResults read fResults;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream; SavePersonalInfo: boolean= true);
    property Group: TGroupItem read get_Group;
    property Data: TData read get_Data;
    function QualificationName: string;
    procedure DeleteImage (index: integer);
    property TotalRating [AEvent: TEventItem]: integer read get_TotalRating;
    function CompareTo (AShooter: TShooterItem; Order: TShootersSortOrder): shortint;
    procedure ResetRatings;
    procedure MoveToGroup (AGroup: TGroupItem);
    procedure DeleteResults (AEvent: TEventItem); overload;
    procedure DeleteResults (AChampionship: TChampionshipItem); overload;
    function SurnameAndName (Separator: string= ','): string;
    function SurnameAndNameAndStepName: string;
    function ImagesCount: integer;
    property Images [index: integer]: string read get_Images write set_Image;
    procedure AddImage (const FileName: TFileName);
    property DistrictAbbr: string read fDistrictAbbr write set_DistrictAbbr;
    property DistrictFull: string read get_DistrictFull;
    property BirthYearStr: string read get_BirthYearStr write set_BirthYearStr;
    property BirthDateStr: string read get_BirthDateStr write set_BirthDateStr;
  // ������ ���� ��������: '��.��.����' ���� ����/�����/��� ������, ����� � ������ ��� ��� �����
  property BirthFullStr: string read get_BirthFullStr write set_BirthFullStr;
    property BirthYear: word read fBirthYear write set_BirthYear;
    procedure Assign (Source: TPersistent); override;
    function Shooters: TShooters;
  function NormalizeSurname: boolean;
    property WasChanged: boolean read get_WasChanged;
    property Marked: integer read fMarked write set_Marked;
    property SportSociety: TSportSocietyItem read fSociety write set_Society;
    function SocietyName: string;
    function SocietyAndClub: string;
    function NameXLit: string;
    function SurnameXLit: string;
    function SurnameAndNameXLit (Separator: string= ','): string;
    function RegionAbbr1XLit: string;
    procedure MergeWith (AShooter: TShooterItem);
    procedure Check;
    function CSVStr: string;
    procedure StripPersonalInfo;
    function CSVStr1: string;
    procedure Changed;
    procedure BeginChange;
    procedure EndChange;
  end;

  TShooters= class (TCollection)
  private
    fGroup: TGroupItem;
    fChanged: boolean;
    function get_Shooter(index: integer): TShooterItem;
    function get_Data: TData;
    function get_WasChanged: boolean;
  public
    constructor Create (AGroup: TGroupItem);
    property Items [index: integer]: TShooterItem read get_Shooter; default;
    function Add: TShooterItem;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream; SavePersonalInfo: boolean= true);
    property Group: TGroupItem read fGroup;
    property Data: TData read get_Data;
    procedure ResetRatings;
    procedure DeleteResults (AEvent: TEventItem); overload;
    procedure DeleteResults (AChampionship: TChampionshipItem); overload;
    function FindShooter (const ID: TGUID): TShooterItem;
    function FindShooterByDetail (const ASurname,AName,ABirthYear: string): TShooterItem;
    procedure MergeWith (AShooters: TShooters);
    property WasChanged: boolean read get_WasChanged;
    function FindDuplicate (AShooter: TShooterItem): TShooterItem;
    procedure DeleteSociety (ASociety: TSportSocietyItem);
    function InSociety (ASociety: TSportSocietyItem): integer;
    procedure Check;
  end;

  TGroupRemoveShooterEvent= procedure (Sender: TGroupItem; AShooter: TShooterItem) of object;
  TGroupAddShooterEvent= procedure (Sender: TGroupItem; AShooter: TShooterItem) of object;
  TDeleteEventNotify= procedure (Sender: TGroupItem; AEvent: TEventItem) of object;

  TGroupItem= class (TCollectionItem)
  private
    fName: string;
    fShooters: TShooters;
    fChanged: boolean;
    fPreferedEvents: array of TEventItem;
    fGID: TGUID;
    procedure set_PreferedEvent(Index: integer; const Value: TEventItem);
    function get_PreferedEvent(Index: integer): TEventItem;
    function get_Data: TData;
    procedure set_Name(const Value: string);
    function get_WasChanged: boolean;
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property Name: string read fName write set_Name;
    property Shooters: TShooters read fShooters;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream; SavePersonalInfo: boolean= true);
    property Data: TData read get_Data;
    procedure ResetRatings;
    procedure DeleteResults (AEvent: TEventItem); overload;
    procedure DeleteResults (AChampionship: TChampionshipItem); overload;
    function Groups: TGroups;
    property WasChanged: boolean read get_WasChanged;
    property PreferedEvents [Index: integer]: TEventItem read get_PreferedEvent write set_PreferedEvent;
    function Prefered (AEvent: TEventItem): integer;
    function AddPrefered (AEvent: TEventItem): integer;
    function PreferedCount: integer;
    procedure DeletePrefered (Index: integer);
    function DefaultGender: TGender;
    property GID: TGUID read fGID;
    procedure Check;
    procedure ExportToCSV;
    function CSVStr: string;
  end;

  TGroups= class (TCollection)
  private
    fData: TData;
    fChanged: boolean;
    procedure set_WasChanged(const Value: boolean);
    function get_Group(index: integer): TGroupItem;
    function get_WasChanged: boolean;
  public
    constructor Create (AData: TData);
    property Items [index: integer]: TGroupItem read get_Group; default;
    function Add: TGroupItem;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream; SavePersonalInfo: boolean= true);
    property Data: TData read fData;
    procedure ResetRatings;
    procedure DeleteResults (AEvent: TEventItem); overload;
    procedure DeleteResults (AChampionship: TChampionshipItem); overload;
    function FindShooter (const ID: TGUID): TShooterItem;
    function FindShooterByDetails (const ASurname,AName,ABirthYear: string): TShooterItem;
    procedure MergeWith (AGroups: TGroups);
    function FindByName (const AName: string): TGroupItem;
    property WasChanged: boolean read get_WasChanged write set_WasChanged;
    function FindDuplicate (AShooter: TShooterItem): TShooterItem;
    procedure DeleteSociety (ASociety: TSportSocietyItem);
    procedure Check;
    procedure ExportToCSV (const FName: TFileName);
  end;

  TDataFileHeader= record
    TextID: string [80];
    GUID: TGUID;
    Version: integer;
  end;
  TCompressionHeader= record
//    CompressedSize: cardinal;
    UncompressedSize: cardinal;
    CRC32: LongWord;
  end;

  TData= class
  private
    fChanged: boolean;
    fName: string;
    fId: TGUID;
    fChampionships: TChampionships;
    fEvents: TEvents;
    fQualifications: TQualifications;
    fGroups: TGroups;
    fImagesFolder: TFileName;
    fFileVersion: integer;
    fStartLists: TStartLists;
    fRegions: TAbbrNames;
    fDistricts: TAbbrNames;
    fSocieties: TSportSocieties;
    fDupeResults: TDupeResultsArray;
    fShootingChampionships: TShootingChampionships;
    fRatingDate: TDateTime;
    function get_RatingDate: TDateTime;
    procedure set_RatingDate(const Value: TDateTime);
    procedure set_Name(const Value: string);
    function get_WasChanged: boolean;
    function get_ActiveStart: TStartList;
  public
    constructor Create;
//    procedure Assign (Source: TData);
    destructor Destroy; override;
    property DataID: TGUID read fId;
    property Name: string read fName write set_Name;
    property Championships: TChampionships read fChampionships;
    property Events: TEvents read fEvents;
    property Qualifications: TQualifications read fQualifications;
    property Groups: TGroups read fGroups;
    procedure LoadFromFile (FileName: TFileName);
    procedure ResetRatings;
    property ImagesFolder: TFileName read fImagesFolder write fImagesFolder;
    procedure DeleteResults (AEvent: TEventItem); overload;
    procedure DeleteResults (AChampionship: TChampionshipItem); overload;
    procedure ImportFromFolder (AFolder: TFileName);
    procedure SaveToFile (FileName: TFileName; SaveStartLists: boolean= true; SavePersonalInfo: boolean= true);
    procedure MergeWith (AData: TData);
    property WasChanged: boolean read get_WasChanged write fChanged;
    property StartLists: TStartLists read fStartLists;
    property ActiveStart: TStartList read get_ActiveStart;
    property Regions: TAbbrNames read fRegions;
    property Districts: TAbbrNames read fDistricts;
    property Societies: TSportSocieties read fSocieties;
    procedure Check;
    property DupeResults: TDupeResultsArray read fDupeResults;
    procedure DeleteDupeResults;
    procedure ResetDupeResults;
    property ShootingChampionships: TShootingChampionships read fShootingChampionships;
    property RatingDate: TDateTime read get_RatingDate write set_RatingDate;
    function SpecificRatingDate: boolean;
//    procedure Assign (Source: TData);
//    procedure StripAllPersonalInfo;
    procedure ExportToCSV (ConsoleOutput: boolean);
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream; SaveStartLists: boolean= true; SavePersonalInfo: boolean= true);
    function NormalizeAllShooterSurnames: Integer;
  end;

  TStartListQualificationPoints= class
  private
    fChanged: boolean;
    fPoints: array of integer;
    fStart: TStartList;
    function get_Points(index: integer): integer;
    procedure set_Points(index: integer; const Value: integer);
  public
    constructor Create (AStart: TStartList);
    destructor Destroy; override;
    function Count: integer;
    property Points [index: integer]: integer read get_Points write set_Points; default;
//    procedure ImportFromStream (Stream: TStream);
    procedure Clear;
    property StartList: TStartList read fStart;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read fChanged;
    procedure Assign (Source: TStartListQualificationPoints);
  end;

  TSortOrder= (soNone,soSeries,soAverage,soFinal,soPosition,soSurname,
    soStartNumber,soQualification,soRegion,soTeam,soPoints);
  TStartShootersSortOrder= (slsoNone,slsoStartNumber,slsoSurname,slsoGroup,slsoDistrict,
    slsoRegion,slsoSociety,slsoQualification,slsoBirthDate);

  TStartListEventRelayItem= class (TCollectionItem)
  private
    fChanged: boolean;
    fStartDT: array [0..1] of TDateTime;
    fPositions: array of integer;
    function get_StartEvent: TStartListEventItem;
    function get_Relays: TStartListEventRelays;
    function get_PositionCount: integer;
    function get_PositionsStr: string;
    function get_Position(index: integer): integer;
    function get_StartTime: TDateTime;
    function get_StartTime2: TDateTime;
    procedure set_StartTime(const Value: TDateTime);
    procedure set_StartTime2(const Value: TDateTime);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property StartEvent: TStartListEventItem read get_StartEvent;
    property Relays: TStartListEventRelays read get_Relays;
    property PositionCount: integer read get_PositionCount;
    property PositionsStr: string read get_PositionsStr;
    property Positions [index: integer]: integer read get_Position;
//    procedure ImportFromStream (Stream: TStream);
    property StartTime: TDateTime read get_StartTime write set_StartTime;
    property StartTime2: TDateTime read get_StartTime2 write set_StartTime2;
    function CheckPosition (APosition: integer): boolean;
    function IsCompleted: boolean;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read fChanged;
    procedure Assign (Source: TPersistent); override;
    function SetPositionsStr (const Value: string): boolean;
    procedure PreconfigureStartTime;
  end;

  TStartListEventRelays= class (TCollection)
  private
    fChanged: boolean;
    fStartEvent: TStartListEventItem;
    function get_RelayIdx(index: integer): TStartListEventRelayItem;
    function get_StartList: TStartList;
    function get_WasChanged: boolean;
  public
    constructor Create (AEvent: TStartListEventItem);
    property StartEvent: TStartListEventItem read fStartEvent;
    property Items [index: integer]: TStartListEventRelayItem read get_RelayIdx; default;
    function PositionCount: integer;
    property StartList: TStartList read get_StartList;
    function Add: TStartListEventRelayItem;
//    procedure ImportFromStream (Stream: TStream);
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read get_WasChanged;
    procedure Assign (Source: TPersistent); override;
  end;

  TStartListShooterItem= class;
  TStartListEventShooters= class;

  TDidNotStart= (dnsNone,dnsCompletely,dnsPartially);

  TStartListEventShooterItem= class (TCollectionItem)
  private
    fChanged: boolean;
    fShooter: TStartListShooterItem;
    fRelay: TStartListEventRelayItem;
    fPosition: array [0..1] of integer;        // ������ >=2
    fSeries10: array of DWORD;
//    fFinalShots: array of TFinalResult;
    fFinalShots10: array of word;
//    fFinalResult: TFinalResult;
    fFinalResult10: DWORD;
    fRank: integer;
    fRegionPoints: boolean;                    // ������ >= 4
    fDistrictPoints: boolean;                  // ������ >= 4
    fOutOfRank: boolean;                       // ��� ��������
    fCompShootoffStr: String;
    fCompPriority: integer;
 //   fFinalShootOff: TFinalResult;
    fFinalShootOff10: DWORD;
    fFinalShootOffStr: String;
    fFinalPriority: integer;
    fFinalManual: integer;
    fSaved: boolean;
    fDidNotStart: TDidNotStart;
    fDNSComment: String;
    fManualPoints: integer;
    fRecordComment: String;
    fTeamForPoints: String;
    fTeamForResults: String;
    fInnerTens: integer;
    fResultItem: TResultItem;
    procedure set_FinalManual(const Value: integer);
    procedure set_InnerTens(const Value: integer);
    procedure set_AllSeries(index: integer; const Value: DWORD);
    function get_CompShootOff: double;
    procedure set_Relay(const Value: TStartListEventRelayItem);
    function get_Event: TEventItem;
    function get_Serie(AStage, ASerie: integer): DWORD;
    function get_FinalShots(index: integer): word;
    function get_Shooter: TShooterItem;
    procedure set_StartListShooter(const Value: TStartListShooterItem);
    function get_StartNumber: integer;
    function get_EventShooters: TStartListEventShooters;
    function get_StartEvent: TStartListEventItem;
    procedure set_Serie(AStage, ASerie: integer; const Value: DWORD);
    procedure set_FinalShots(index: integer; const Value: word);
    procedure set_CompShootoffStr(const Value: String);
    function get_Position: integer;
    procedure set_Position(const Value: integer);
    function get_Position2: integer;
    procedure set_Position2(const Value: integer);
    function get_FinalShootOffStr: String;
    procedure set_FinalShootOffStr(const Value: String);
    function get_DNS: TDidNotStart;
    procedure set_DNS(const Value: TDidNotStart);
    function get_DNSComment: String;
    procedure set_DNSComment(const Value: String);
    function get_FinalResult: DWORD;
    procedure set_FinalResult(const Value: DWORD);
    function get_FinalResultStr: String;
    procedure set_FinalShootOff(const Value: DWORD);
    procedure set_CompPriority(const Value: integer);
    procedure set_DistrictPoints(const Value: boolean);
    procedure set_OutOfRank(const Value: boolean);
    procedure set_RegionPoints(const Value: boolean);
    procedure set_FinalPriority(const Value: integer);
    procedure set_ManualPoints(const Value: integer);
    procedure set_RecordComment(const Value: String);
    function get_AllSeries(index: integer): DWORD;
    procedure set_TeamForPoints(const Value: String);
    procedure set_TeamForResults(const Value: String);
    function AverageSerie: double;
  public
    property EventShooters: TStartListEventShooters read get_EventShooters;
    property StartEvent: TStartListEventItem read get_StartEvent;
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property Shooter: TShooterItem read get_Shooter;
    property StartListShooter: TStartListShooterItem read fShooter write set_StartListShooter;
    property Relay: TStartListEventRelayItem read fRelay write set_Relay;
    property Event: TEventItem read get_Event;
    property Series10 [AStage,ASerie: integer]: DWORD read get_Serie write set_Serie;
//    function CompetitionResult: integer;
    function Competition10: DWORD;
    function CompetitionStr: String;
    function StageResults10 (AStage: integer): DWORD;
    function StageResultStr (AStage: integer): String;
    property FinalShots10 [index: integer]: word read get_FinalShots write set_FinalShots;
    property FinalResult10: DWORD read get_FinalResult write set_FinalResult;
//    function Total: TFinalResult;
    function Total10: DWORD;
    property Position: integer read get_Position write set_Position;
    property Position2: integer read get_Position2 write set_Position2;
    property StartNumber: integer read get_StartNumber;
    function CompareTo (AShooter: TStartListEventShooterItem; AOrder: TSortOrder): shortint;
    function StartList: TStartList;
//    procedure ImportFromStream (Stream: TStream);
    function HavePosition: boolean;
    function ComparePositionTo (AShooter: TStartListEventShooterItem): shortint;
    function CompareSurnameTo (AShooter: TStartListEventShooterItem): shortint;
    function SeriesCount: integer;
    function StagesCount: integer;
    function SeriesInStage (index: integer): integer;
    function FinalShotsCount: integer;
    procedure SetFinalShotsCount (ACount: integer);
    property FinalShootOff10: DWORD read fFinalShootOff10 write set_FinalShootOff;
    property CompShootOffVal: double read get_CompShootOff;
    property CompShootOffStr: string read fCompShootoffStr write set_CompShootoffStr;
    property CompPriority: integer read fCompPriority write set_CompPriority;
    function StartNumberStr: string;
    property GiveRegionPoints: boolean read fRegionPoints write set_RegionPoints;
    property GiveDistrictPoints: boolean read fDistrictPoints write set_DistrictPoints;
    property OutOfRank: boolean read fOutOfRank write set_OutOfRank;
    function TeamPoints: integer;
    function RegionPoints: integer;
    function DistrictPoints: integer;
    function AllPointsStr: string;
    function QualificationPoints: integer;
   // function Qualified (var ByTotal: boolean): TQualificationItem;
    function Qualified: TQualificationItem;
//    procedure PrintFinalNumber;
    function FinalShotsStr: string;
    property FinalResultStr: string read get_FinalResultStr;
    procedure SaveResult (AShootingEvent: TShootingEventItem);
    property Saved: boolean read fSaved;
    property FinalShootOffStr: string read get_FinalShootOffStr write set_FinalShootOffStr;
    property FinalPriority: integer read fFinalPriority write set_FinalPriority;
    property DNS: TDidNotStart read get_DNS write set_DNS;
    property DNSComment: string read get_DNSComment write set_DNSComment;
    function IsFinished: boolean;
    property ManualPoints: integer read fManualPoints write set_ManualPoints;
    property RecordComment: string read fRecordComment write set_RecordComment;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    function Shooters: TStartListEventShooters;
    property WasChanged: boolean read fChanged;
    property AllSeries10 [index: integer]: DWORD read get_AllSeries write set_AllSeries;
    property TeamForPoints: string read fTeamForPoints write set_TeamForPoints;
    property TeamForResults: string read fTeamForResults write set_TeamForResults;
    procedure Assign (Source: TPersistent); override;
    function AscorStartListStr (PositionIndex: integer): string;
    procedure ResetFinal;
    property InnerTens: integer read fInnerTens write set_InnerTens;
    function TotalResultStr: string;
    procedure ResetResults;
    function CSVStr: String;
    function SerieStr (AStage,ASerie: integer): string;
    property FinalManual: integer read fFinalManual write set_FinalManual;
  end;

  TRegionStats= record
    Region: string;
    Count: integer;
  end;
  TRegionsStats= array of TRegionStats;

  TStartListEventShooters= class (TCollection)
  private
    fSortOrder: TSortOrder;
    fStartEvent: TStartListEventItem;
    fChanged: boolean;
    function get_StartList: TStartList;
    function get_ShooterIdx(index: integer): TStartListEventShooterItem;
    procedure set_SortOrder(const Value: TSortOrder);
    procedure Sort;
    function get_WasChanged: boolean;
  public
    constructor Create (AEvent: TStartListEventItem);
    property StartEvent: TStartListEventItem read fStartEvent;
    property StartList: TStartList read get_StartList;
    function Add: TStartListEventShooterItem;
    function TeamShooters (ATeam: string): integer;
    function PointsTeamShooters (ATeam: string): integer;
    property Items [index: integer]: TStartListEventShooterItem read get_ShooterIdx;
    property SortOrder: TSortOrder read fSortOrder write set_SortOrder;
    procedure ResetRelays;
    function FindShooter (AShooter: TShooterItem): TStartListEventShooterItem;
//    procedure ImportFromStream (Stream: TStream);
    function Find (From: integer; ASearch: string): integer;
    function FindNum (From: integer; ASearch: string): integer;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read get_WasChanged;
    procedure Assign (Source: TPersistent); override;
    function NumberOf (AQualification: TQualificationItem): integer;
    procedure GetRegionsStats (var RS: TRegionsStats);
  end;

  TStartListEventShootersArray= array of TStartListEventShooterItem;

  TStartListEventItem= class (TCollectionItem)
  private
    fChanged: boolean;
    fEvent: TEventItem;
    fRelays: TStartListEventRelays;
    fShooters: TStartListEventShooters;
    fProtocolNumber: integer;
    fCalculatePoints: boolean;
    fFinalTime: TDateTime;
    fInfo: TStartListInfo;
    fRegionsPoints: TStartListPoints;
    fDistrictsPoints: TStartListPoints;
    fPTeamsPoints: TStartListPoints;
    fRTeamsPoints: TStartListPoints;
    fHasFinal: boolean;
    fNewFinalFormat: boolean;
    fInPointsTable: boolean;
    fCompetitionWithTens: boolean;
  // New finals (VP-60/PP-60): gold medal match storage
  fgGoldShots1: TWordDynArray; // shots (with tenths) for finalist A
  fgGoldShots2: TWordDynArray; // shots (with tenths) for finalist B
  fgGoldPoints1: integer;      // points for A (2/1/0 system)
  fgGoldPoints2: integer;      // points for B
  fgGoldShooterIdx1: integer;  // index in Shooters for finalist A
  fgGoldShooterIdx2: integer;  // index in Shooters for finalist B
    procedure set_CompetitionWithTens(const Value: boolean);
    procedure set_Event(const Value: TEventItem);
    function get_Event: TEventItem;
    procedure set_InPointsTable(const Value: boolean);
    function get_StartList: TStartList;
    procedure PrintRegularStartList (Prn: TObject; ACopies: integer);
    procedure PrintRapidFireStartList (Prn: TObject; ACopies: integer);
    function get_Info: TStartListInfo;
    procedure set_ProtocolNumber(const Value: integer);
    procedure set_CalculatePoints(const Value: boolean);
    procedure set_FinalTime(const Value: TDateTime);
    function get_WasChanged: boolean;
    procedure set_HasFinal (const Value: boolean);
    procedure RecalcGoldPoints;
    function GoldFinished: boolean;
  public
    property Event: TEventItem read get_Event write set_Event;
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property Shooters: TStartListEventShooters read fShooters;
    property Relays: TStartListEventRelays read fRelays;
    property StartList: TStartList read get_StartList;
    function PositionsCount: integer;
    property ProtocolNumber: integer read fProtocolNumber write set_ProtocolNumber;
    property CalculatePoints: boolean read fCalculatePoints write set_CalculatePoints;
    function DrawLots (AMethod: integer): boolean;
    function CheckLots: boolean;
    function FindShooter (ARelay: TStartListEventRelayItem; APosition: integer): TStartListEventShooterItem; overload;
    function FindShooter (AStartNumber: integer): TStartListEventShooterItem; overload;
    function IsLotsDrawn: boolean;
    property FinalTime: TDateTime read fFinalTime write set_FinalTime;
    function IsStarted: boolean;
    function IsCompleted: boolean;
    function ShotForTeam (ATeam: string): TStartListEventShootersArray;
    function TeamPoints (ATeam: string; AGender: TGenders): integer;
    function TeamPointsShooters (ATeam: string; AGender: TGenders): integer;
    function RegionPoints (ARegion: string; AGenders: TGenders): integer;
    function RegionPointsShooters (ARegion: string; AGenders: TGenders): integer;
    function DistrictPoints (ADistrict: string; AGenders: TGenders): integer;
    function DistrictPointsShooters (ADistrict: string; AGenders: TGenders): integer;
    function HaveQualification (Qualification: TQualificationItem): integer;
    function Qualified (QFrom,QTo: TQualificationItem): integer;
    function StartNumber: integer;
    procedure PrintStartList (Prn: TObject; ACopies: integer);
    procedure PrintResults (Prn: TObject; AFinal: boolean; ATeams: boolean;
      ATeamPoints: boolean; ARegionPoints: boolean;
      ADistrictPoints: boolean; AReport: boolean; ACopies: integer; StartDoc: boolean);
    procedure PrintInternationalResults (Prn: TObject; AFinal: boolean; ATeams: boolean;
      ACopies: integer; StartDoc: boolean);
    function IsFinalOk: boolean;
    property Info: TStartListInfo read get_Info;
    function InfoOverriden: boolean;
    procedure OverrideInfo;
    procedure DeleteInfo;
    procedure PrintShootersList (Prn: TObject; ACopies: integer);
    procedure SaveShootersListToPDF (const FName: TFileName);
//    procedure PrintFinalNumbers (APages: string);
    procedure SaveResults;
    function Saved: integer;
    function Fights: integer;
    procedure SaveStartListPDF (const FName: TFileName);
    {function SaveResultsHTML (AFinal: boolean; ATeams: boolean;
      ATeamPoints: boolean; ARegionPoints: boolean; ADistrictPoints: boolean;
      AReport: boolean): TStrings;}
    procedure SaveResultsPDF (const FName: TFileName; AFinal: boolean; ATeams: boolean;
      ATeamPoints: boolean; ARegionPoints: boolean; ADistrictPoints: boolean;
      AReport: boolean); overload;
    procedure SaveResultsPDF (doc: TPDFDocument; AFinal: boolean; ATeams: boolean;
      ATeamPoints: boolean; ARegionPoints: boolean; ADistrictPoints: boolean;
      AReport: boolean); overload;
    procedure SaveResultsPDFInternational (const FName: TFileName; AFinal: boolean; ATeams: boolean); overload;
    procedure SaveResultsPDFInternational (doc: TPDFDocument; AFinal: boolean; ATeams: boolean); overload;
    property RegionsPoints: TStartListPoints read fRegionsPoints;
    property DistrictsPoints: TStartListPoints read fDistrictsPoints;
    property PTeamsPoints: TStartListPoints read fPTeamsPoints;
    property RTeamsPoints: TStartListPoints read fRTeamsPoints;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    function Events: TStartListEvents;
    property WasChanged: boolean read get_WasChanged;
    procedure DeleteFinalResults;
    function DateFrom: TDateTime;
    function DateTill: TDateTime;
    procedure Assign (Source: TPersistent); override;
    property HasFinal: boolean read fHasFinal write set_HasFinal;
    property NewFinalFormat: boolean read fNewFinalFormat write fNewFinalFormat;
    function HasTeamsForResult: boolean;
    function HasTeamsForPoints: boolean;
    function HasRegionsPoints: boolean;
    function HasDistrictsPoints: boolean;
    function HighestRank (ATeam: string; Genders: TGenders): integer;
    procedure ExportStartListToAscor (PositionIndex: integer; FileName: string);
    function StagesComplete: integer;
    function Gender: TGender;
    property InPointsTable: boolean read fInPointsTable write set_InPointsTable;
//    property ShootingEvent: TShootingEventItem read fShootingEvent;
//    function ShootingChampionship: TShootingChampionshipItem;
//    procedure CreateShootingEvent (AEvent: TEventItem);
//    procedure DestroyShootingEventIfEmpty;
//    procedure UpdateShootingEventDate;
//    function PrepareStartListPrint: TStartListReport;
//    procedure PrintShootersCards;
    function NumberOfFinalists: integer;
    procedure ResetResults;
    procedure ExportResultsToCSV (const FName: TFileName);
    function CompetitionStr (AComp: DWORD): string;
    function SerieTemplate: string;
    function TotalTemplate: string;
    function CompTemplate: string;
    function IsPairedEvent: boolean;
    property CompetitionWithTens: boolean read fCompetitionWithTens write set_CompetitionWithTens;
    // Accessors for new gold match
    function GetGoldShots1: TWordDynArray;
    function GetGoldShots2: TWordDynArray;
    property GoldShots1: TWordDynArray read GetGoldShots1;
    property GoldShots2: TWordDynArray read GetGoldShots2;
    property GoldPoints1: integer read fgGoldPoints1;
    property GoldPoints2: integer read fgGoldPoints2;
    property GoldShooterIdx1: integer read fgGoldShooterIdx1;
    property GoldShooterIdx2: integer read fgGoldShooterIdx2;
    procedure ResetGoldMatch;
    procedure AppendGoldShotPair(AShot1, AShot2: word);
    procedure SetGoldFinalists(Index1, Index2: integer);
    procedure SetGoldShot(Index: integer; AShot1, AShot2: word);
    function GoldShotsCount: integer;
  end;

  TStartListEvents= class (TCollection)
  private
    fChanged: boolean;
    fStartList: TStartList;
    function get_EventIdx(index: integer): TStartListEventItem;
    function get_WasChanged: boolean;
  public
    constructor Create (AStartList: TStartList);
    property StartList: TStartList read fStartList;
    function Add: TStartListEventItem;
    property Items [index: integer]: TStartListEventItem read get_EventIdx; default;
    function TeamShooters (ATeam: string): integer;
    function PointsTeamShooters (ATeam: string): integer;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read get_WasChanged;
    procedure Assign (Source: TPersistent); override;
    procedure SaveResultsPDF (const FName: TFileName; AFinal: boolean; ATeams: boolean;
      ATeamPoints: boolean; ARegionPoints: boolean; ADistrictPoints: boolean;
      AReport: boolean); overload;
    procedure SaveResultsPDFInternational (const FName: TFileName; AFinal: boolean; ATeams: boolean); overload;
    function FindByProtocolNumber (ProtocolNumber: integer): TStartListEventItem;
    function NumberOf (AQual: TQualificationItem): integer;
    function TotalShooters: integer;
  end;

  // �������������� ������
  TStartListEventTeams= class;
  TStartListEventTeamItem= class
  private
    fTeams: TStartListEventTeams;
    fTeam: string;
    fShooters: array of TStartListEventShooterItem;
    fIndex: integer;
    function get_Shooter(Index: integer): TStartListEventShooterItem;
  public
    constructor Create (ATeams: TStartListEventTeams);
    destructor Destroy; override;
    property Name: string read fTeam write fTeam;
    procedure Add (AShooter: TStartListEventShooterItem);
    function Count: integer;
    function CompareTo (ATeam: TStartListEventTeamItem): shortint;
    property Shooters [Index: integer]: TStartListEventShooterItem read get_Shooter; default;
    function Sum10: DWORD;
    function ShootersListStr: string;
    function RegionAbbr: string;
    function Points: integer;
    function PointsStr: string;
    function Gender: TGender;
    function GenderValid: boolean;
    function SumStr: string;
  end;

  TStartListEventTeams= class
  private
    fEvent: TStartListEventItem;
    fTeams: array of TStartListEventTeamItem;
    function get_Item(index: integer): TStartListEventTeamItem;
    procedure GatherStats;
    procedure Sort;
  public
    constructor Create (AEvent: TStartListEventItem);
    destructor Destroy; override;
    function Count: integer;
    property Items [index: integer]: TStartListEventTeamItem read get_Item; default;
    function Add (ATeam: string): TStartListEventTeamItem;
    function Find (ATeam: string): TStartListEventTeamItem;
    procedure Delete (Index: integer);
    function RegionPoints (const ARegionAbbr: string; AGenders: TGenders): integer;
  end;

  TStartListPoints= class
  private
    fChanged: boolean;
    fPoints: array of integer;
    function get_Points(Index: integer): integer;
    procedure set_Points(Index: integer; const Value: integer);
  public
    constructor Create;
    destructor Destroy; override;
    function Count: integer;
    procedure Delete (index: integer);
    procedure Insert (index: integer; Points: integer= 0);
    property Points [Index: integer]: integer read get_Points write set_Points; default;
    procedure LoadFromFile (AFileName: string);
    procedure SaveToFile (AFileName: string);
    procedure Assign (APoints: TStartListPoints);
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read fChanged;
    procedure Clear;
  end;

  TStartNumbersPrintout= class;
//  TFinalNumbersPrintout= class;

  TStartListShooterItem= class (TCollectionItem)
  private
    fStartNumber: integer;
    fOldTeam: string;
    fShooter: TShooterItem;
    fStartNumberPrinted: boolean;
    fChanged: boolean;
    procedure set_Shooter(const Value: TShooterItem);
    procedure set_StartNumber(const Value: integer);
    procedure set_StartNumberPrinted(const Value: boolean);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    function StartList: TStartList;
    property Shooter: TShooterItem read fShooter write set_Shooter;
    property StartNumber: integer read fStartNumber write set_StartNumber;
    function EventsCount: integer;
    function EventsNames: string;
//    procedure ImportFromStream (Stream: TStream);
    property StartNumberPrinted: boolean read fStartNumberPrinted write set_StartNumberPrinted;
    function StartNumberStr: string;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    function Shooters: TStartListShooters;
    property WasChanged: boolean read fChanged;
    procedure Assign (Source: TPersistent); override;
    function CompareTo (AShooter: TStartListShooterItem; AOrder: TStartShootersSortOrder): integer;
  end;

  TStartListShooters= class (TCollection)
  private
    fChanged: boolean;
    fStartList: TStartList;
    fStartNumberDigits: integer;
    function get_Shooter(Index: integer): TStartListShooterItem;
    function get_WasChanged: boolean;
  protected
    procedure UpdateStartNumberDigits;
  public
    constructor Create (AStartList: TStartList);
    property StartList: TStartList read fStartList;
    function Add: TStartListShooterItem;
    property Items [Index: integer]: TStartListShooterItem read get_Shooter; default;
    function FindShooter (AShooter: TShooterItem): TStartListShooterItem; overload;
    function FindShooter (AStartNumber: integer): TStartListShooterItem; overload;
//    procedure ImportFromStream (Stream: TStream);
    function NextAvailableStartNumber: integer;
    procedure Delete (AShooter: TStartListShooterItem);
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read get_WasChanged;
    procedure Assign (Source: TPersistent); override;
    procedure Sort (Order: TStartShootersSortOrder);
    function NumberOf (AGender: TGender): integer; overload;
    function NumberOf (AQualification: TQualificationItem): integer; overload;
    procedure GetRegionsStats (var RS: TRegionsStats);
    property StartNumberDigits: integer read fStartNumberDigits;
  end;

  EInvalidStartFile= class (Exception);
  EWrongStartData= class (Exception);

  TStartListInfo= class
  private
    fChanged: boolean;
    fStartList: TStartList;
    fEvent: TStartListEventItem;
    fTitle: String;
    fTown: String;
    fRange: String;
    fChampionshipName: String;
    fChampionship: TChampionshipItem;
    fSecretery: String;
    fSecreteryCategory: String;
    fStartNumbers: boolean;
    fJury: String;
    fJuryCategory: String;
    function get_StartList: TStartList;
    procedure set_JuryCategory(const Value: String);
    procedure set_Jury(const Value: String);
    function get_ChampionshipName: String;
    procedure set_Championship(const Value: TChampionshipItem);
    procedure set_ChampionshipName(const Value: String);
    procedure set_StartNumbers(const Value: boolean);
    procedure set_Title(const Value: String);
    procedure set_Town(const Value: String);
    procedure set_Range(const Value: String);
    procedure set_Secretery(const Value: String);
    procedure set_SecreteryCategory(const Value: String);
    procedure Initialize;
  public
    constructor Create (AStartList: TStartList); overload;
    constructor Create (AEvent: TStartListEventItem); overload;
    property TitleText: String read fTitle write set_Title;
    function CaptionText: String;
    property Town: String read fTown write set_Town;
    property ShootingRange: String read fRange write set_Range;
    property Championship: TChampionshipItem read fChampionship write set_Championship;
    property ChampionshipName: String read get_ChampionshipName write set_ChampionshipName;
//    procedure ImportFromStream (Stream: TStream);
    property Secretery: String read fSecretery write set_Secretery;
    property SecreteryCategory: String read fSecreteryCategory write set_SecreteryCategory;
    function TownAndRange: String;
    procedure Assign (AInfo: TStartListInfo);
//    property StartNumbers: boolean read fStartNumbers write set_StartNumbers;
    property StartList: TStartList read get_StartList;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    property WasChanged: boolean read fChanged;
    function EqualsTo (AInfo: TStartListInfo): boolean;
    property Jury: String read fJury write set_Jury;
    property JuryCategory: String read fJuryCategory write set_JuryCategory;
    function Root: boolean;
  end;

  TStartListTeamsGroups= class;
  TStartListTeamsGroup= class
  private
    fGroups: TStartListTeamsGroups;
    fTeams: array of string;
    fName: string;
    fChanged: boolean;
    function get_Team(Index: integer): string;
    procedure set_Team(Index: integer; const Value: string);
    procedure set_Name(const Value: string);
    function get_WasChanged: boolean;
  public
    constructor Create (AGroups: TStartListTeamsGroups);
    destructor Destroy; override;
    property WasChanged: boolean read get_WasChanged;
    property Name: string read fName write set_Name;
    function Count: integer;
    property Items [Index: integer]: string read get_Team write set_Team; default;
    function Add (ATeam: string): integer;
    function TeamIndex (ATeam: string): integer;
    procedure Delete (Index: integer); overload;
    procedure Delete (ATeam: string); overload;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    procedure Clear;
  end;

  TStartListTeamsGroups= class
  private
    fStart: TStartList;
    fGroups: array of TStartListTeamsGroup;
    fChanged: boolean;
    function get_Group(Index: integer): TStartListTeamsGroup;
    function get_WasChanged: boolean;
  public
    constructor Create (AStartList: TStartList);
    destructor Destroy; override;
    property WasChanged: boolean read get_WasChanged;
    function Count: integer;
    function Add: TStartListTeamsGroup;
    property Items [Index: integer]: TStartListTeamsGroup read get_Group; default;
    procedure Delete (Index: integer); overload;
    procedure Delete (AGroup: TStartListTeamsGroup); overload;
    function GroupIndex (AGroup: TStartListTeamsGroup): integer;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    procedure Clear;
  end;

  TPointsFor= (pfTeam,pfRegion,pfDistrict);
  TPointsTableType= (pttEventTypes,pttEvents);

  TStartList= class (TCollectionItem)
  private
    fId: TGUID;
    fChanged: boolean;
    fShooters: TStartListShooters;
    fStartNumbersPrintout: TStartNumbersPrintout;
    fEvents: TStartListEvents;
    fQualificationPoints: TStartListQualificationPoints;
    fInfo: TStartListInfo;
//    fFinalNumbersPrintout: TFinalNumbersPrintout;
//    fStreamVersion: integer;
    fShootersPerTeam: integer;
    fNotifiers: array of HWND;
    fTeamsGroups: TStartListTeamsGroups;
    fOnDelete: TNotifyEvent;
//    fShootingChampionship: TShootingChampionshipItem;
    _sch: TShootingChampionshipItem;
    function get_StartNumbers: boolean;
    procedure set_StartNumbers(const Value: boolean);
    function get_WasChanged: boolean;
    procedure set_ShootersPerTeam(const Value: integer);
  public
    constructor Create (ACollection: TCollection); override;
    destructor Destroy; override;
    property ID: TGUID read fId;
    property Events: TStartListEvents read fEvents;
    function Data: TData;
    property StartNumbersPrintout: TStartNumbersPrintout read fStartNumbersPrintout;
    property Shooters: TStartListShooters read fShooters;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream);
    function NextAvailableStartNumber: integer;
    procedure PrintAllStartNumbers;
    function Participate (AShooter: TShooterItem): boolean;
    function GetNextProtocolNumber: integer;
    property QualificationPoints: TStartListQualificationPoints read fQualificationPoints;
    property Info: TStartListInfo read fInfo;
//    property FinalNumbersPrintout: TFinalNumbersPrintout read fFinalNumbersPrintout;
    function StartLists: TStartLists;
    property WasChanged: boolean read get_WasChanged;
    function GetTeams (OnlyForPoints: boolean; ForGroup: TStartListTeamsGroup): TStrings;
    property ShootersPerTeam: integer read fShootersPerTeam write set_ShootersPerTeam;
    procedure ChangeTeamName (AFrom,ATo: string);
    function HaveTeams: boolean;
    function DateFrom: TDateTime;
    function DateTill: TDateTime;
    procedure Assign (Source: TPersistent); override;
    procedure AddNotifier (h: HWND);
    procedure RemoveNotifier (h: HWND);
    procedure Notify (Msg: UINT; WParam: WPARAM; LParam: LPARAM);
    procedure PrintPointsTable (Prn: TObject; AgeGroup: TAgeGroup; ACopies: integer;
      PointsFor: TPointsFor; TableType: TPointsTableType; ForGroups: boolean; const ATitle: string);
    procedure SavePointsTable (AFileName: string; AgeGroup: TAgeGroup;
      PointsFor: TPointsFor; TableType: TPointsTableType; ForGroups: boolean; const ATitle: string);
    procedure SavePointsTableHTML (AFileName: string; AgeGroup: TAgeGroup;
      PointsFor: TPointsFor; TableType: TPointsTableType; ForGroups: boolean; const ATitle: string);
    function TeamPoints (ATeam: string; AWeapon: TWeapons; AGender: TGenders): integer;
    function DatesFromTillStr: string;
    property TeamsGroups: TStartListTeamsGroups read fTeamsGroups;
    function GetRegions (OnlyWithPoints: boolean): TStrings;
    function RegionPoints (ARegionAbbr: string;  AWeapon: TWeapons; AGender: TGenders): integer;
    function GetDistricts: TStrings;
    function DistrictPoints (ADistrictAbbr: string; AWeapon: TWeapons; AGenders: TGenders): integer;
    procedure GetTeamRanks (ATeam: string; var AllRanks: TAllRanksArray);
    procedure GetRegionRanks (ARegion: string; var AllRanks: TAllRanksArray);
    procedure GetDistrictRanks (ADistrict: string; var AllRanks: TAllRanksArray);
    property OnDelete: TNotifyEvent read fOnDelete write fOnDelete;
//    procedure CreateShootingChampionship;
//    property ShootingChampionship: TShootingChampionshipItem read fShootingChampionship;
//    procedure DestroyShootingChampionshipIfEmpty;
    procedure ConvertToNil (AChampionship: TChampionshipItem); overload;
    function HasEvent (AEvent: TEventItem): boolean;
    procedure DeleteEvent (AEvent: TEventItem);
    function Qualified (AQualificationFrom,AQualificationTo: TQualificationItem): integer;
    property StartNumbers: boolean read get_StartNumbers write set_StartNumbers;
    function DatesValid: boolean;
    procedure MergeWith (AStartList: TStartList);
  end;

  TStartLists= class (TCollection)
  private
    fData: TData;
    fChanged: boolean;
    fActiveStart: TStartList;
    function GetItems(index: integer): TStartList;
    procedure set_ActiveStart(const Value: TStartList);
    function get_WasChanged: boolean;
  public
    constructor Create (AData: TData);
    property Items [index: integer]: TStartList read GetItems; default;
    function Add: TStartList;
    procedure ReadFromStream (Stream: TStream);
    procedure WriteToStream (Stream: TStream; SaveStartLists: boolean= true);
    property ActiveStart: TStartList read fActiveStart write set_ActiveStart;
    property WasChanged: boolean read get_WasChanged;
    procedure MergeWith (AStartLists: TStartLists);
    function FindById (AID: TGUID): TStartList;
    function FindByInfo (AInfo: TStartListInfo): TStartList;
    procedure Check;
//    function HaveEvent (AShootingEvent: TShootingEventItem): boolean;
//    function HaveChampionship (AChampionship: TShootingChampionshipItem): boolean;
    procedure ConvertChampionshipToNil (AChampionship: TChampionshipItem);
    function HaveEvent (AEvent: TEventItem): boolean;
    procedure DeleteEvent (AEvent: TEventItem);
  end;

  TStartNumbersPrintout= class
  private
    fShooter1,fShooter2: TStartListShooterItem;
    fJobIndex,fPageIndex: integer;
    procedure PrintOut1;
    procedure PrintOut2;
  public
    constructor Create;
    procedure AddShooter (AShooter: TStartListShooterItem);
    procedure Clear;
    function IsPending: boolean;
    procedure StartJob;
    procedure FinishJob;
    procedure CancelJob;
    procedure PrintOut;
  end;

  TTeamEventPoints= record
    event: TStartListEventItem;
    points: integer;
  end;

  TStartListTotalTeamStats= class
  private
    fStartList: TStartList;
    fTeam: string;
    fFullName: string;
    fTotalPoints: integer;
    fRifleMenPoints,fRifleWomenPoints: integer;
    fPistolMenPoints,fPistolWomenPoints: integer;
    fMovingMenPoints,fMovingWomenPoints: integer;
    fAllRanks: TAllRanksArray;
    fEventPoints: array of TTeamEventPoints;
    fMenPoints,fWomenPoints: integer;
  public
    constructor Create (AStartList: TStartList; ATeam: string; APointsFor: TPointsFor);
    destructor Destroy; override;
    property Name: string read fTeam;
    property RifleMenPoints: integer read fRifleMenPoints;
    property RifleWomenPoints: integer read fRifleWomenPoints;
    property PistolMenPoints: integer read fPistolMenPoints;
    property PistolWomenPoints: integer read fPistolWomenPoints;
    property MovingMenPoints: integer read fMovingMenPoints;
    property MovingWomenPoints: integer read fMovingWomenPoints;
    property TotalPoints: integer read fTotalPoints;
    function CompareTo (ATeam: TStartListTotalTeamStats): shortint;
    property FullName: string read fFullName;
    function EventPoints (AEvent: TStartListEventItem): integer;
    property MenPoints: integer read fMenPoints;
    property WomenPoints: integer read fWomenPoints;
  end;

procedure SaveStrToStreamA (Stream: TStream; S: String);
procedure ReadStrFromStreamA (Stream: TStream; out S: String);
function StrToFinal10 (s: string): DWORD;
//function FinalResult (i,f: integer): TFinalResult;

function ResultToStr (R: DWORD; Tens: boolean): string; overload;
function ResultToStr (R: DWORD): string; overload;

procedure DeleteRegionsStats (var RS: TRegionsStats);

procedure UpdateLanguage;

function _DayToStr (D: TDateTime): string;
function _MonthToStr (D: TDateTime): string;
function _YearToStr (D: TDateTime): string;
function _DateToStr (D: TDateTime): string;
function _DatesFromTillStr (D1,D2: TDateTime): string;
function CompareDwords (dw1,dw2: DWORD): integer;

procedure GetDefaultProtocolFont (var name: string; var size: integer);

implementation

uses
  wb_barcodes;

function NormalizeShooterSurname(const Value: string): string;
begin
  Result := Trim(Value);
  if Result <> '' then
    CharUpperBuff(PChar(Result), Length(Result));
end;

procedure GetDefaultProtocolFont (var name: string; var size: integer);
var
  Reg: TRegistry;
begin
  name:= 'Arial';
  size:= 10;
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH,false) then
      begin
        if Reg.ValueExists ('ProtocolFontName') then
          name:= Reg.ReadString ('ProtocolFontName');
        if Reg.ValueExists ('ProtocolFontSize') then
          size:= Reg.ReadInteger ('ProtocolFontSize');
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;
end;

function ResultToStr (R: DWORD; Tens: boolean): string;
begin
  if Tens then
    Result:= format ('%d.%d',[R div 10,R mod 10])
  else
    Result:= format ('%d',[R div 10]);
end;

function ResultToStr (R: DWORD): string;
begin
  if R mod 10= 0 then
    Result:= ResultToStr (R,false)
  else
    Result:= ResultToStr (R,true);
end;

function CompareDwords (dw1,dw2: DWORD): integer;
begin
  if dw1> dw2 then
    Result:= 1
  else if dw1< dw2 then
    Result:= -1
  else
    Result:= 0;
end;

procedure DeleteRegionsStats(var RS: TRegionsStats);
var
  i: integer;
begin
  for i:= 0 to Length (RS)-1 do
    RS [i].Region:= '';
  SetLength (RS,0);
end;

procedure UpdateLanguage;
var
  i: integer;
begin
  OUT_OF_RANK_MARK:= Language ['OUT_OF_RANK_MARK'];
  NOT_FOR_TEAM_MARK:= Language ['NOT_FOR_TEAM_MARK'];
  // Optional translation for final placeholder mark; default is '�'
  // MyLanguage returns "[Tag]" if missing; don't overwrite default in that case
  begin
    var __fm := Language ['FINAL_MARK'];
    if (Length(__fm)>0) and (Copy(__fm,1,1)<> '[') then
      FINAL_MARK := __fm;
  end;
  LoadStrFromRegistry ('ProtocolMakerSignature',PROTOCOL_MAKER_SIGN,Language ['PROTOCOL_MAKER_SIGN']);
  DNS_MARK:= Language ['DNS_MARK'];
  DELETED_CHAMPIONSHIP_MARK:= Language ['DELETED_CHAMPIONSHIP_MARK'];
  DELETED_EVENT_MARK:= Language ['DELETED_EVENT_MARK'];
  NEW_DATA_NAME:= Language ['NEW_DATA_NAME'];
  ALL_RESULTS_PDF_CAPTION:= Language ['ALL_RESULTS_PDF_CAPTION'];
  START_LIST_PAGE_TITLE:= Language ['START_LIST_PAGE_TITLE'];
  PAGE_NO:= Language ['PAGE_NO'];
  PAGE_FOOTER:= Language ['PAGE_FOOTER'];
  START_LIST_CONTINUE_MARK:= Language ['START_LIST_CONTINUE_MARK'];
  RF_START_TIME_1:= Language ['RF_START_TIME_1'];
  RF_START_TIME_2:= Language ['RF_START_TIME_2'];
  FINAL_TIME:= Language ['FINAL_TIME'];
  FINAL_DATETIME:= Language ['FINAL_DATETIME'];
  RELAY_NO:= Language ['RELAY_NO'];
  MT_RELAY_NO:= Language ['MT_RELAY_NO'];
  SECRETERY_TITLE:= Language ['SECRETERY_TITLE'];
  START_LIST_PRINT_TITLE:= Language ['START_LIST_PRINT_TITLE'];
//  START_LIST_PDF_TITLE:= Language ['START_LIST_PDF_TITLE'];
  START_TIME:= Language ['START_TIME'];
  CF_START_TIME_1:= Language ['CF_START_TIME_1'];
  CF_START_DATETIME_1:= Language ['CF_START_DATETIME_1'];
  CF_START_TIME_2:= Language ['CF_START_TIME_2'];
  CF_START_DATETIME_2:= Language ['CF_START_DATETIME_2'];
  PROTOCOL_NO:= Language ['PROTOCOL_NO'];
  FINAL_SHOTS_:= Language ['FINAL_SHOTS_'];
  FINAL_SHOOTOFF:= Language ['FINAL_SHOOTOFF'];
  TEAM_CHAMPIONSHIP_TITLE:= Language ['TEAM_CHAMPIONSHIP_TITLE'];
  TEAM_POINTS_TITLE:= Language ['TEAM_POINTS_TITLE'];
  REGIONS_POINTS_TITLE:= Language ['REGIONS_POINTS_TITLE'];
  REGIONS_POINTS_CONTINUE:= Language ['REGIONS_POINTS_CONTINUE'];
  DISTRICTS_POINTS_TITLE:= Language ['DISTRICTS_POINTS_TITLE'];
  DISTRICTS_POINTS_CONTINUE:= Language ['DISTRICTS_POINTS_CONTINUE'];
  TECH_REPORT_TITLE:= Language ['TECH_REPORT_TITLE'];
  TECH_REPORT_SHOOTERS:= Language ['TECH_REPORT_SHOOTERS'];
  TECH_REPORT_TOTAL:= Language ['TECH_REPORT_TOTAL'];
  EVENT_RESULTS_PRINT_TITLE:= Language ['EVENT_RESULTS_PRINT_TITLE'];
//  EVENT_RESULTS_PDF_TITLE:= Language ['EVENT_RESULTS_PDF_TITLE'];
  EVENT_SHOOTERS_TITLE:= Language ['EVENT_SHOOTERS_TITLE'];
  EVENT_SHOOTERS_PRINT_TITLE:= Language ['EVENT_SHOOTERS_PRINT_TITLE'];
//  EVENT_SHOOTERS_PDF_TITLE:= Language ['EVENT_SHOOTERS_PDF_TITLE'];
  TEAM_STR:= Language ['TEAM_STR'];
  REGION_STR:= Language ['REGION_STR'];
  DISTRICT_STR:= Language ['DISTRICT_STR'];
  TOTAL_POINTS:= Language ['TOTAL_POINTS'];
  TOTAL_TEAM_CHAMPIONSHIP_TITLE:= Language ['TOTAL_TEAM_CHAMPIONSHIP_TITLE'];
  TOTAL_REGION_CHAMPIONSHIP_TITLE:= Language ['TOTAL_REGION_CHAMPIONSHIP_TITLE'];
  TOTAL_DISTRICT_CHAMPIONSHIP_TITLE:= Language ['TOTAL_DISTRICT_CHAMPIONSHIP_TITLE'];
  TOTAL_CHAMPIONSHIP_CONTINUE:= Language ['TOTAL_CHAMPIONSHIP_CONTINUE'];
  RIFLE_STR:= Language ['RIFLE_STR'];
  PISTOL_STR:= Language ['PISTOL_STR'];
  MOVING_TARGET_STR:= Language ['MOVING_TARGET_STR'];
  YOUTHS_MEN:= Language ['YOUTHS_MEN'];
  YOUTHS_WOMEN:= Language ['YOUTHS_WOMEN'];
  JUNIORS_MEN:= Language ['JUNIORS_MEN'];
  JUNIORS_WOMEN:= Language ['JUNIORS_WOMEN'];
  ADULTS_MEN:= Language ['ADULTS_MEN'];
  ADULTS_WOMEN:= Language ['ADULTS_WOMEN'];
  TOTAL_TEAM_CHAMPIONSHIP_PRINT_TITLE:= Language ['TOTAL_TEAM_CHAMPIONSHIP_PRINT_TITLE'];
  TOTAL_REGION_CHAMPIONSHIP_PRINT_TITLE:= Language ['TOTAL_REGION_CHAMPIONSHIP_PRINT_TITLE'];
  TOTAL_DISTRICT_CHAMPIONSHIP_PRINT_TITLE:= Language ['TOTAL_DISTRICT_CHAMPIONSHIP_PRINT_TITLE'];
//  TOTAL_TEAM_CHAMPIONSHIP_PDF_TITLE:= Language ['TOTAL_TEAM_CHAMPIONSHIP_PDF_TITLE'];
//  TOTAL_REGION_CHAMPIONSHIP_PDF_TITLE:= Language ['TOTAL_REGION_CHAMPIONSHIP_PDF_TITLE'];
//  TOTAL_DISTRICT_CHAMPIONSHIP_PDF_TITLE:= Language ['TOTAL_DISTRICT_CHAMPIONSHIP_PDF_TITLE'];
  RUSSIAN_SHOOTING_UNION:= Language ['RUSSIAN_SHOOTING_UNION'];
  START_NUMBERS_PRINT_TITLE:= Language ['START_NUMBERS_PRINT_TITLE'];
  START_SHOOTERS_GROUP_NAME:= Language ['START_SHOOTERS_GROUP_NAME'];
  SHOOTER_UNKNOWN:= Language ['SHOOTER_UNKNOWN'];
  FINAL_NUMBER_CAPTION:= Language ['FINAL_NUMBER_CAPTION'];
  FINAL_NUMBERS_PRINT_TITLE:= Language ['FINAL_NUMBERS_PRINT_TITLE'];
  JURY_TITLE:= Language ['JURY_TITLE'];
  YES_MARK:= Language ['YES_MARK'];
  CLMN_START_NUMBER:= Language ['CLMN_START_NUMBER'];
  CLMN_SHOOTER:= Language ['CLMN_SHOOTER'];
  CLMN_REGION:= Language ['CLMN_REGION'];
  CLMN_SOC_CLUB:= Language ['CLMN_SOC_CLUB'];
  CLMN_RESTEAM:= Language ['CLMN_RESTEAM'];
  CLMN_POINTSTEAM:= Language ['CLMN_POINTSTEAM'];
  CLMN_POINTSDISTRICT:= Language ['CLMN_POINTSDISTRICT'];
  CLMN_POINTSREGION:= Language ['CLMN_POINTSREGION'];
  CLMN_RELAY:= Language ['CLMN_RELAY'];
  CLMN_LANE:= Language ['CLMN_LANE'];
  try
    SUM_STR:= Language ['SUM_STR'];
  except
    SUM_STR:= '�����'; // ���������� �������� �� ���������
  end;
  for i:= 1 to 12 do
    MONTHS_STR [i]:= Language ['MONTHS_STR_'+IntToStr (i)];
end;

function dos2win (stt: string): string;
var
  j: word;
begin
  while (Length (stt)> 0) and (stt [Length (stt)]= ' ') do
    stt:= Copy (stt,1,Length (stt)-1);
  for j:= 1 to length (stt) do
    begin
      // Replace case statement with if statements to avoid duplicate label issues
      if (stt [j] >= #128) and (stt [j] <= #175) then
        stt [j]:= chr (ord (stt [j])+64)
      else if (stt [j] >= #176) and (stt [j] <= #223) then
        stt [j]:= chr (ord (stt [j])-48)
      else if (stt [j] >= #224) and (stt [j] <= #239) then
        stt [j]:= chr (ord (stt [j])+16);
      // Characters #240..#255 remain unchanged
    end;
  dos2win:= stt;
end;

function StrToCSV (const s: string): string;
var
  i: integer;
  quote: boolean;
begin
  Result:= '';
  if s= '' then
    exit;
  quote:= false;
  if pos (',',s)<> 0 then
    quote:= true
  else if pos ('"',s)<> 0 then
    quote:= true;
  if quote then
    Result:= '"';
  for i:= 1 to Length (s) do
    if s [i]= '"' then
      Result:= Result+'""'
    else
      Result:= Result+s [i];
  if quote then
    Result:= Result+'"';
end;

function XLit (s: string): string;
begin
  // TODO: Restore transliteration functionality after migration
  // Temporarily return original string to fix Unicode compatibility
  Result := s;
end;

function _DayToStr (D: TDateTime): string;
begin
  Result:= IntToStr (DayOf (D));
end;

function _MonthToStr (D: TDateTime): string;
var
  m: integer;
begin
  m:= MonthOf (D);
  if (m> 0) and (m<= 12) then
    Result:= MONTHS_STR [m]
  else
    Result:= '';
end;

function _YearToStr (D: TDateTime): string;
begin
  Result:= IntToStr (YearOf (D));
end;

function _DateToStr (D: TDateTime): string;
begin
  Result:= _DayToStr (D)+' '+_MonthToStr (D)+' '+_YearToStr (D);
end;

function _DatesFromTillStr (D1,D2: TDateTime): string;
begin
  Result:= '';
  if d1> d2 then
    exit;
  if YearOf (d2)> YearOf (d1) then
    begin  // ���� �����������
      Result:= _DayToStr (d1)+' '+_MonthToStr (d1)+' '+_YearToStr (d1)+' - '+
        _DayToStr (d2)+' '+_MonthToStr (d2)+' '+_YearToStr (d2);
    end
  else if MonthOf (d2)> MonthOf (d1) then
    begin  // ������ �����������
      Result:= _DayToStr (d1)+' '+_MonthToStr (d1)+' - '+
        _DayToStr (d2)+' '+_MonthToStr (d2)+' '+_YearToStr (d2);
    end
  else if DayOf (d2)> DayOf (d1) then
    begin  // ��� �����������
      Result:= _DayToStr (d1)+' - '+
        _DayToStr (d2)+' '+_MonthToStr (d2)+' '+_YearToStr (d2);
    end
  else
    begin
      Result:= _DayToStr (d1)+' '+_MonthToStr (d1)+' '+_YearToStr (d1);
    end;
end;

procedure SaveStrToStreamA (Stream: TStream; S: String);
var
  l: integer;
  AnsiBytes: TBytes;
begin
  if S <> '' then
  begin
    // ������������ Unicode � Windows-1251 ��� ����������
    AnsiBytes := TEncoding.GetEncoding(1251).GetBytes(S);
    l := Length(AnsiBytes);
    Stream.Write (l,sizeof (l));
    Stream.Write (AnsiBytes[0], l);
  end
  else
  begin
    l := 0;
    Stream.Write (l,sizeof (l));
  end;
end;

procedure ReadStrFromStreamA (Stream: TStream; out S: String);
var
  l: integer;
  AnsiBytes: TBytes;
begin
  Stream.Read (l,sizeof (l));
  if l > 0 then
  begin
    SetLength(AnsiBytes, l);
    Stream.Read (AnsiBytes[0], l);
    // ������������ �� Windows-1251 � Unicode
    S := TEncoding.GetEncoding(1251).GetString(AnsiBytes);
  end
  else
    S := '';
end;

function StrToFinal10 (s: string): DWORD;
var
  i,f,n: integer;
  s1, s2: string;
  dotPos, commaPos: integer;
begin
  Result:= 0;
  s:= Trim(s);
  if s = '' then
    Exit;
    
  // ���� ����������� (����� ��� �������)
  dotPos := pos('.', s);
  commaPos := pos(',', s);
  
  // ���� ���� ����� ��� ������� - ������ ��� ����� � ��������
  if (dotPos > 0) or (commaPos > 0) then
    begin
      // ���������� ��� �����������, ������� ������ ������
      if (dotPos > 0) and ((commaPos = 0) or (dotPos < commaPos)) then
        begin
          // ���������� ����� ��� �����������
          s1:= substr(s, '.', 1);
          s2:= substr(s, '.', 2);
        end
      else
        begin
          // ���������� ������� ��� �����������
          s1:= substr(s, ',', 1);
          s2:= substr(s, ',', 2);
        end;
        
      if (s1 <> '') and (s2 <> '') then
        begin
          val(s1, i, n);
          if n = 0 then
            begin
              val(s2, f, n);
              if n = 0 then
                begin
                  // ���� ������� ������ 9, ����� ������ ������ �����
                  if f > 9 then
                    f := f div 10;
                  Result:= i * 10 + f;
                end;
            end;
        end;
    end
  else
    begin
      // ��� ����������� - ��������� �������� �����
      val(s, i, n);
      if n = 0 then  // �������� ���������� ��������������
        begin
          // ����� �� 110 �� 1090 ���������������� ��� ����� � ��������
          // ��������: 853 = 85.3, 1090 = 109.0
          if (i >= 110) and (i <= 1090) then
            Result := i  // ��� � ������� � ��������
          else
            Result := i * 10;  // ������� ����� ����� ��� �������
        end;
    end;
end;

{
function FinalResult (i,f: integer): TFinalResult;
begin
  Result._int:= i;
  Result._frac:= f;
end;
}

type
  TStartListFileHeader= record
    TextId: array [1..16] of char;
    ID: TGUID;
    Version: integer;
  end;

type
  TPointsFileHeader= record
    TextId: string [80];
    ID: TGUID;
    Version: integer;
  end;

{ TChampionshipItem }

procedure TChampionshipItem.CreateTag;
var
  tag: string;
  idx: integer;
  ch: TChampionshipItem;
begin
  idx:= 0;
  repeat
    inc (idx);
    tag:= format ('CHMP%d',[idx]);
    ch:= Championships [tag];
  until ch= nil;
  fTag:= tag;
  Changed;
end;

function TChampionshipItem.CSVStr: string;
begin
  Result:= IntToStr (Index+1)+CSVDelimiter+
    StrToCSV (fName)+CSVDelimiter+
    IntToStr (fPeriod)+CSVDelimiter+IntToStr (fRatingHold);
end;

function TChampionshipItem.get_Championships: TChampionships;
begin
  Result:= Collection as TChampionships;
end;

function TChampionshipItem.get_Data: TData;
begin
  Result:= (Collection as TChampionships).Data;
end;

procedure TChampionshipItem.ReadFromStream(Stream: TStream);
var
  c,l,j: integer;
  evtag: string;
  ev: TEventItem;
begin
  ReadStrFromStreamA (Stream,fTag);
  //Stream.Read (c, sizeof (c));
  //SetLength (fTag,c);
  //Stream.Read (fTag [1], c);
  ReadStrFromStreamA (Stream,fName);
  //Stream.Read (c, sizeof (c));
  //SetLength (fName, c);
  //Stream.Read (fName [1], c);
  Stream.Read (fMQS,sizeof (fMQS));
  ClearTable;
  if Data.fFileVersion>= 6 then
    begin
      for j:= 0 to Data.Events.Count-1 do
        begin
          Stream.Read (l,sizeof (l));
          SetLength (fRatedEvents [j].RatedPlaces,l);
          Stream.Read (fRatedEvents [j].RatedPlaces [0],l*sizeof (integer));
        end;
    end
  else
    begin
      Stream.Read (c,sizeof (c));
      for j:= 0 to c-1 do
        begin
          ReadStrFromStreamA (Stream,evtag);
          ev:= Data.Events [evtag];
          if (ev<> nil) then
            begin
              Stream.Read (l,sizeof (l));
              SetLength (fRatedEvents [ev.Index].RatedPlaces,l);
              Stream.Read (fRatedEvents [ev.Index].RatedPlaces [0],l*sizeof (integer));
            end
          else
            begin
              Stream.Read (l,sizeof (l));
              Stream.Seek (l*sizeof (integer),soCurrent);
            end;
        end;
    end;
  Stream.Read (fRatingHold,sizeof (fRatingHold));
  Stream.Read (fPeriod,sizeof (fPeriod));
  if Data.fFileVersion>= 40 then
    Stream.Read (fLastChange,sizeof (fLastChange));
  _changed:= false;
  Championships.fChanged:= true;
end;

procedure TChampionshipItem.set_MQS(const Value: boolean);
begin
  if Value<> fMQS then
    begin
      fMQS:= Value;
      Changed;
    end;
end;

procedure TChampionshipItem.set_Name(const Value: string);
begin
  if Value<> fName then
    begin
      fName:= Value;
      Changed;
    end;
end;

procedure TChampionshipItem.set_Period(const Value: word);
begin
  if Value<> fPeriod then
    begin
      fPeriod:= Value;
      Changed;
    end;
end;

procedure TChampionshipItem.set_RatingHold(const Value: word);
begin
  if Value<> fRatingHold then
    begin
      fRatingHold:= Value;
      Changed;
    end;
end;

procedure TChampionshipItem.set_Tag(const Value: String);
begin
  if Value<> fTag then
    begin
      fTag:= Value;
      Changed;
    end;
end;

procedure TChampionshipItem.WriteToStream(Stream: TStream);
var
  //c: integer;
  l,i: integer;
begin
  SaveStrToStreamA (Stream,fTag);
  //c:= Length (fTag);
  //Stream.Write (c, sizeof (c));
  //Stream.Write (fTag [1], c);
  SaveStrToStreamA (Stream,fName);
  //c:= Length (fName);
  //Stream.Write (c, sizeof (c));
  //Stream.Write (fName [1], c);
  Stream.Write (fMQS,sizeof (fMQS));
  for i:= 0 to Data.Events.Count-1 do
    begin
      l:= Length (fRatedEvents [i].RatedPlaces);
      Stream.Write (l,sizeof (l));
      Stream.Write (fRatedEvents [i].RatedPlaces [0],l*sizeof (integer));
    end;
  Stream.Write (fRatingHold,sizeof (fRatingHold));
  Stream.Write (fPeriod,sizeof (fPeriod));
  Stream.Write (fLastChange,sizeof (fLastChange));
  _changed:= false;
end;

function TChampionshipItem.GetRating(AResult: TResultItem): integer;
begin
  Result:= 0;
  if (AResult= nil) or (AResult.Event= nil) or (AResult.Rank<= 0) then
    exit;
  if AResult.Rank<= Length (fRatedEvents [AResult.Event.Index].RatedPlaces) then
    Result:= fRatedEvents [AResult.Event.Index].RatedPlaces [AResult.Rank-1];
end;

procedure TChampionshipItem.Assign(Source: TPersistent);
var
  ch: TChampionshipItem;
  i,j: integer;
begin
  if Source is TChampionshipItem then
    begin
      ch:= Source as TChampionshipItem;
      CreateTag;
      fTag:= ch.Tag;
      fName:= ch.Name;
      fMQS:= ch.MQS;
      ClearTable;
      SetLength (fRatedEvents,Length (ch.fRatedEvents));
      for i:= 0 to Length (fRatedEvents)-1 do
        begin
          SetLength (fRatedEvents [i].RatedPlaces,Length (ch.fRatedEvents [i].RatedPlaces));
          for j:= 0 to Length (fRatedEvents [i].RatedPlaces)-1 do
            fRatedEvents [i].RatedPlaces [j]:= ch.fRatedEvents [i].RatedPlaces [j];
        end;
      fRatingHold:= ch.RatingHold;
      fPeriod:= ch.fPeriod;
      Changed;
    end;
end;

procedure TChampionshipItem.BeginChange;
begin
  inc (fChanging);
end;

procedure TChampionshipItem.Changed;
begin
  if fChanging= 0 then
    begin
      _changed:= true;
      fLastChange:= Now;
    end;
end;

procedure TChampionshipItem.Check;
begin
  // TODO: �������� ������������
end;

procedure TChampionshipItem.ClearTable;
var
  i: integer;
begin
  for i:= 0 to Length (fRatedEvents)-1 do
    SetLength (fRatedEvents [i].RatedPlaces,0);
  SetLength (fRatedEvents,Data.Events.Count);
  Changed;
end;

function TChampionshipItem.RatesCount(AEvent: TEventItem): integer;
begin
  Result:= Length (fRatedEvents [AEvent.Index].RatedPlaces);
end;

constructor TChampionshipItem.Create(ACollection: TCollection);
begin
  inherited;
  ClearTable;
  Championships.fChanged:= true;
  fChanging:= 0;
  fLastChange:= Now;
end;

destructor TChampionshipItem.Destroy;
var
  i: integer;
begin
  for i:= 0 to Length (fRatedEvents)-1 do
    SetLength (fRatedEvents [i].RatedPlaces,0);
  SetLength (fRatedEvents,0);
  Championships.fChanged:= true;
  inherited;
end;

procedure TChampionshipItem.EndChange;
begin
  if fChanging> 0 then
    dec (fChanging);
  if fChanging= 0 then
    begin
      _changed:= true;
      fLastChange:= Now;
    end;
end;

function TChampionshipItem.get_RatedPlaces(AEvent: TEventItem;
  Index: integer): integer;
begin
  Result:= get_RatingTable (AEvent.Index,index);
end;

procedure TChampionshipItem.set_RatedPlaces(AEvent: TEventItem;
  Index: integer; const Value: integer);
begin
  set_RatingTable (AEvent.Index,index,Value);
end;

function TChampionshipItem.RatesCount(index: integer): integer;
begin
  Result:= 0;
  if index< Length (fRatedEvents) then
    Result:= Length (fRatedEvents [index].RatedPlaces);
end;

procedure TChampionshipItem.DeleteEvent(AEvent: TEventItem);
var
  i: integer;
begin
  SetLength (fRatedEvents [AEvent.Index].RatedPlaces,0);
  for i:= AEvent.Index to Data.Events.Count-2 do
    fRatedEvents [i]:= fRatedEvents [i+1];
  SetLength (fRatedEvents,Length (fRatedEvents)-1);
  Changed;
end;

function TChampionshipItem.get_RatingTable(eventindex,
  index: integer): integer;
begin
  if (eventindex>= 0) and (eventindex< Length (fRatedEvents)) and
     (index> 0) and (index<= Length (fRatedEvents [eventindex].RatedPlaces)) then
    Result:= fRatedEvents [eventindex].RatedPlaces [index-1]
  else
    Result:= 0;
end;

procedure TChampionshipItem.set_RatingTable(eventindex, index: integer;
  const Value: integer);
begin
  if (eventindex< 0) or (eventindex>= Length (fRatedEvents)) or (index<= 0) then
    exit;
  with fRatedEvents [eventindex] do
    begin
      if index> Length (RatedPlaces) then
        SetLength (RatedPlaces,index);
      RatedPlaces [index-1]:= Value;
      while (Length (RatedPlaces)> 0) and (RatedPlaces [Length (RatedPlaces)-1]= 0) do
        SetLength (RatedPlaces,Length (RatedPlaces)-1);
      Changed;
    end;
end;

procedure TChampionshipItem.AddEvent(AEvent: TEventItem);
var
  i,l: integer;
begin
  l:= Length (fRatedEvents);
  if AEvent.Index>= l then
    SetLength (fRatedEvents,AEvent.Index+1);
  for i:= l to AEvent.Index do
    SetLength (fRatedEvents [i].RatedPlaces,0);
  Changed;
end;

{ TChampionships }

function TChampionships.Add: TChampionshipItem;
begin
  Result:= inherited Add as TChampionshipItem;
end;

procedure TChampionships.AddEventTable(AEvent: TEventItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].AddEvent (AEvent);
end;

procedure TChampionships.Check;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].Check;
end;

constructor TChampionships.Create (AData: TData);
begin
  inherited Create (TChampionshipItem);
  fData:= AData;
  fChanged:= false;
end;

procedure TChampionships.DeleteEventTable(AEvent: TEventItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].DeleteEvent (AEvent);
end;

procedure TChampionships.ExportToCSV(const FName: TFileName);
var
  i: integer;
  s: TStrings;
begin
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'title'+CSVDelimiter+'period'+CSVDelimiter+'hold');
  for i:= 0 to Count-1 do
    s.Add (Items [i].CSVStr);
  try
    s.SaveToFile (FName);
    s.Free;
  except
    s.Free;
    raise;
  end;
end;

function TChampionships.FindByName(AName: string): TChampionshipItem;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    begin
      Result:= Items [i];
      if AnsiSameText (Result.Name,AName) then
        exit;
    end;
  Result:= nil;
end;

function TChampionships.get_Championship(Tag: string): TChampionshipItem;
var
  i: integer;
  ch: TChampionshipItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      ch:= Items [i];
      if AnsiSameText (ch.Tag,Tag) then
        begin
          Result:= ch;
          break;
        end;
    end;
end;

function TChampionships.get_ChampionshipIdx(
  Index: integer): TChampionshipItem;
begin
  if Index< Count then
    Result:= (inherited Items [Index]) as TChampionshipItem
  else
    Result:= nil;
end;

function TChampionships.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

procedure TChampionships.MergeWith(AChampionships: TChampionships);
var
  i,j,k: integer;
  c,ac: TChampionshipItem;
  e,ae: TEventItem;
begin
  for i:= 0 to AChampionships.Count-1 do
    begin
      ac:= AChampionships.Items [i];
      c:= Championships [ac.Tag];
      if c= nil then
        begin
          c:= Add;
          //c.Assign (ac);
          c.BeginChange;
          try
            c.fTag:= ac.fTag;
            c.fName:= ac.fName;
            c.fMQS:= ac.fMQS;
            c.Changed;
            c.fRatingHold:= ac.fRatingHold;
            c.fPeriod:= ac.fPeriod;
            for j:= 0 to AChampionships.Data.Events.Count-1 do
              begin
                ae:= AChampionships.Data.Events.Items [j];
                e:= Data.Events [ae.Tag];
                if e<> nil then
                  begin
                    SetLength (c.fRatedEvents [e.Index].RatedPlaces,Length (ac.fRatedEvents [ae.Index].RatedPlaces));
                    for k:= 0 to Length (ac.fRatedEvents [ae.Index].RatedPlaces)-1 do
                      c.fRatedEvents [e.Index].RatedPlaces [k]:= ac.fRatedEvents [ae.Index].RatedPlaces [k];
                  end;
              end;
          finally
            c.EndChange;
          end;
        end
      else
        begin
          if ac.fLastChange> c.fLastChange then
            c.Assign (ac);
        end;
    end;
end;

procedure TChampionships.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  ch: TChampionshipItem;
begin
  Clear;
  Stream.Read (c, sizeof (c));
  for i:= 0 to c-1 do
    begin
      ch:= Add;
      ch.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TChampionships.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c, sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TEventItem }

procedure TEventItem.AddBonus(Bonus: TEventBonus);
begin
  SetLength (fBonusRatings,Length (fBonusRatings)+1);
  fBonusRatings [Length (fBonusRatings)-1]:= Bonus;
  SortBonuses;
  Changed;
end;

procedure TEventItem.AddBonus10(Bonus: TEventBonus10);
begin
  SetLength (fBonusRatings10,Length (fBonusRatings10)+1);
  fBonusRatings10 [Length (fBonusRatings10)-1]:= Bonus;
  SortBonuses10;
  Changed;
end;

procedure TEventItem.BeginChange;
begin
  inc (fChanging);
end;

function TEventItem.BonusCount: integer;
begin
  Result:= Length (fBonusRatings);
end;

function TEventItem.BonusCount10: integer;
begin
  Result:= Length (fBonusRatings10);
end;

procedure TEventItem.Changed;
begin
  if fChanging= 0 then
    begin
      _changed:= true;
      fLastChange:= Now;
    end;
end;

procedure TEventItem.Check;
begin
  // TODO: �������� ����������
end;

procedure TEventItem.ClearBonuses;
begin
  SetLength (fBonusRatings,0);
  SetLength (fBonusRatings10,0);
  Changed;
end;

constructor TEventItem.Create(ACollection: TCollection);
begin
  inherited;
  _changed:= false;
  fLastChange:= Now;
  fTag:= '';
  fCode:= '';
  fShortName:= '';
  fName:= '';
  fMQSResult10:= 0;
  fMinRatedResult10:= 0;
  fFinalFracs:= false;
  fFinalPlaces:= 0;
  fFinalShots:= 10;
  fStages:= 1;
  fSeriesPerStage:= 1;
  SetLength (fQualifications10,0);
  SetLength (fBonusRatings,0);
  SetLength (fBonusRatings10,0);
  fRelayTime:= EncodeTime (1,0,0,0);
  fEventType:= etRegular;
  fCompareBySeries:= true;
  fCompareByFinal:= false;
  //fCompFracs:= false;
  fSeparateFinalTable:= false;
  Events.fChanged:= true;       // ���������� ����������� ��� ���������
end;

procedure TEventItem.CreateTag;
var
  tag,tagbase: string;
  idx: integer;
begin
  if fShortName= '' then
    tagbase:= 'EVN'
  else
    tagbase:= Trim (fShortName);
  idx:= 0;
  tag:= tagbase;
  while Events [tag]<> nil do
    begin
      inc (idx);
      tag:= tagbase+'_'+IntToStr (idx);
    end;
  fTag:= tag;
  Changed;
end;

function TEventItem.CSVStr: string;
begin
  Result:= IntToStr (Index+1)+CSVDelimiter+
    StrToCSV (fShortName)+CSVDelimiter+
    StrToCSV (fName)+CSVDelimiter+
    IntToStr (fMinRatedResult10 div 10);
end;

destructor TEventItem.Destroy;
begin
  SetLength (fQualifications10,0);
  SetLength (fBonusRatings,0);
  SetLength (fBonusRatings10,0);
  Events.fChanged:= true;         // �������� ���������� �������� ������
  inherited;
end;

procedure TEventItem.EndChange;
begin
  if fChanging> 0 then
    dec (fChanging);
  if fChanging= 0 then
    begin
      _changed:= true;
      fLastChange:= Now;
    end;
end;

function TEventItem.FinalShotTemplate: string;
begin
  if fFinalFracs then
    Result:= '00.0'
  else
    Result:= '00';
end;

function TEventItem.FinalStr(AFinal: DWORD): string;
begin
  if FinalFracs then
    Result:= IntToStr (AFinal div 10)+'.'+IntToStr (AFinal mod 10)
  else
    Result:= IntToStr (AFinal div 10);
end;

function TEventItem.FinalTemplate: string;
begin
  if fFinalFracs then
    Result:= '000.0'
  else
    Result:= '000';
end;

function TEventItem.GetBonus(AResult: DWORD; WithTens: boolean): integer;
var
  i: integer;
begin
  Result:= 0;
  if WithTens then
    begin
      for i:= 0 to Length (fBonusRatings10)-1 do
        if AResult>= fBonusRatings10 [i].fResult then
          begin
            Result:= fBonusRatings10 [i].fRating;
            break;
          end;
    end
  else
    begin
      for i:= 0 to Length (fBonusRatings)-1 do
        if AResult div 10>= fBonusRatings [i].fResult then
          begin
            Result:= fBonusRatings [i].fRating;
            break;
          end;
    end;
end;

function TEventItem.get_Bonus(index: integer): TEventBonus;
begin
  if (index>= 0) and (index< Length (fBonusRatings)) then
    Result:= fBonusRatings [index]
  else
    begin
      Result.fResult:= 0;
      Result.fRating:= 0;
    end;
end;

function TEventItem.get_Bonus10(index: integer): TEventBonus10;
begin
  if (index>= 0) and (index< Length (fBonusRatings10)) then
    Result:= fBonusRatings10 [index]
  else
    begin
      Result.fResult:= 0;
      Result.fRating:= 0;
    end;
end;

function TEventItem.get_Data: TData;
begin
  Result:= (Collection as TEvents).Data;
end;

function TEventItem.get_Events: TEvents;
begin
  Result:= Collection as TEvents;
end;

function TEventItem.get_Qualifications(index: integer): TQualificationResult10;
begin
  if (index>= 0) and (index< Length (fQualifications10)) then
    Result:= fQualifications10 [index]
  else
    begin
      Result.Competition10:= 0;
      //Result.Total10:= 0;
      Result.CompetitionTens10:= 0;
    end;
end;

function TEventItem.HaveResults: boolean;
var
  i,j: integer;
  g: TGroupItem;
begin
  Result:= false;
  for i:=  0 to Data.Groups.Count - 1 do
    begin
      g:= Data.Groups [i];
      for j:= 0 to g.Shooters.Count-1 do
        if g.Shooters [j].Results.ResultsInEvent (self)> 0 then
          begin
            Result:= true;
            exit;
          end;
    end;
end;

function TEventItem.InFinal(ARank: integer): boolean;
begin
  Result:= (ARank> 0) and (ARank<= fFinalPlaces);
end;

{function TEventItem.QualifiedTotal (ATotal: DWORD): TQualificationItem;
var
  i: integer;
  q: TQualificationItem;
  qr: TQualificationResult10;
begin
  Result:= nil;
  for i:= 0 to Length (fQualifications10)-1 do
    begin
      qr:= fQualifications10 [i];
      q:= Data.Qualifications.Items [i];
      if (q<> nil) and (qr.Total10> 0) then
        begin
          if (ATotal > qr.Total10) and (q.SetByResult) then
            begin
              Result:= q;
              break;
            end;
        end;
    end;
end;}

{function TEventItem.QualifiedComp (AComp: DWORD): TQualificationItem;
var
  i: integer;
  q: TQualificationItem;
  qr: TQualificationResult10;
begin
  Result:= nil;
  for i:= 0 to Length (fQualifications10)-1 do
    begin
      qr:= fQualifications10 [i];
      q:= Data.Qualifications.Items [i];
      if (q<> nil) and (qr.Competition10> 0) then
        begin
          if (AComp >= qr.Competition10) and (q.SetByResult) then
            begin
              Result:= q;
              break;
            end;
        end;
    end;
end;}

function TEventItem.QualificationsCount: integer;
begin
  Result:= Length (fQualifications10);
end;

procedure TEventItem.ReadFromStream(Stream: TStream);
var
  c: integer;
  a: array of integer;
  i: integer;
  a1: array of TQualificationResultOld;
  _w: word;
  bool: boolean;
begin
  ReadStrFromStreamA (Stream,fTag);
  ReadStrFromStreamA (Stream,fCode);
  ReadStrFromStreamA (Stream,fShortName);
  ReadStrFromStreamA (Stream,fName);
  if Data.fFileVersion<= 35 then
    begin
      Stream.Read (_w,sizeof (_w));
      fMQSResult10:= _w * 10;
      Stream.Read (_w,sizeof (_w));
      fMinRatedResult10:= _w * 10;
    end
  else
    begin
      Stream.Read (fMQSResult10,sizeof (fMQSResult10));
      Stream.Read (fMinRatedResult10,sizeof (fMinRatedResult10));
    end;
  Stream.Read (fFinalFracs,sizeof (fFinalFracs));
  Stream.Read (fFinalPlaces,sizeof (fFinalPlaces));
  Stream.Read (fFinalShots,sizeof (fFinalShots));
  Stream.Read (fStages,sizeof (fStages));
  Stream.Read (fSeriesPerStage,sizeof (fSeriesPerStage));
  if Data.fFileVersion<= 4 then
    begin
      Stream.Read (c,sizeof (c));
      SetLength (a,c);
      Stream.Read (a [0],c*sizeof (integer));
      SetLength (fQualifications10,c);
      for i:= 0 to c-1 do
        begin
          fQualifications10 [i].Competition10:= a [i] * 10;
          //fQualifications10 [i].Total10:= 0;
          fQualifications10 [i].CompetitionTens10:= 0;
        end;
      SetLength (a,0);
      a:= nil;
    end
  else
    begin
      Stream.Read (c,sizeof (c));
      SetLength (fQualifications10,c);
      if Data.fFileVersion<= 35 then
        begin
          SetLength (a1,c);
          Stream.Read (a1[0],c*sizeof (TQualificationResultOld));
          for i:= 0 to c-1 do
            begin
              fQualifications10[i].Competition10:= a1[i].Competition * 10;
              //fQualifications10[i].Total10:= a1[i].Final._int * 10 + a1[i].Final._frac;
              fQualifications10[i].CompetitionTens10:= a1[i].Final._int * 10 + a1[i].Final._frac;
            end;
          SetLength (a1,0);
        end
      else
        Stream.Read (fQualifications10 [0],c*sizeof (TQualificationResult10));
    end;
  Stream.Read (c,sizeof (c));
  SetLength (fBonusRatings,c);
  Stream.Read (fBonusRatings [0],c*sizeof (TEventBonus));
  if Data.fFileVersion>= 39 then
    begin
      Stream.Read (c,sizeof (c));
      SetLength (fBonusRatings10,c);
      Stream.Read (fBonusRatings10 [0],c*sizeof (TEventBonus10));
    end
  else
    begin
      SetLength (fBonusRatings10,0);
    end;
  Stream.Read (fRelayTime,sizeof (fRelayTime));
  Stream.Read (fEventType,sizeof (fEventType));
  if Data.fFileVersion>= 2 then
    begin
      Stream.Read (fWeaponType,sizeof (fWeaponType));
    end
  else
    begin
      fWeaponType:= wtNone;
    end;
  if Data.fFileVersion>= 9 then
    Stream.Read (fCompareBySeries,sizeof (fCompareBySeries))
  else
    fCompareBySeries:= true;
  if Data.fFileVersion>= 35 then
    Stream.Read (fCompareByFinal,sizeof (fCompareByFinal))
  else
    fCompareByFinal:= false;
  if Data.fFileVersion>= 36 then
    begin
      if Data.fFileVersion< 38 then
        Stream.Read (bool,sizeof (bool));
        //Stream.Read (fCompFracs,sizeof (fCompFracs))
    end;
  //else
    //fCompFracs:= false;
  if Data.fFileVersion>= 37 then
    Stream.Read (fSeparateFinalTable,sizeof (fSeparateFinalTable))
  else
    fSeparateFinalTable:= false;
  if Data.fFileVersion>= 40 then
    Stream.Read (fLastChange,sizeof (fLastChange));
  _changed:= false;
  Events.fChanged:= true;
end;

{function TEventItem.SerieTemplate: string;
begin
  if fCompFracs then
    Result:= '000.0'
  else
    Result:= '000';
end;}

procedure TEventItem.set_Bonus(index: integer; const Value: TEventBonus);
begin
  if (index>= 0) and (index< 255) then
    begin
      if index>= Length (fBonusRatings) then
        SetLength (fBonusRatings, index);
      fBonusRatings [index-1]:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_Bonus10(index: integer; const Value: TEventBonus10);
begin
  if (index>= 0) and (index< 255) then
    begin
      if index>= Length (fBonusRatings10) then
        SetLength (fBonusRatings10, index);
      fBonusRatings10 [index-1]:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_Code(const Value: string);
begin
  if Value<> fCode then
    begin
      fCode:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_EventType(const Value: TEventType);
begin
  if Value<> fEventType then
    begin
      fEventType:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_FinalFracs(const Value: boolean);
begin
  if Value<> fFinalFracs then
    begin
      fFinalFracs:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_FinalPlaces(const Value: word);
begin
  if Value<> fFinalPlaces then
    begin
      fFinalPlaces:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_FinalShots(const Value: word);
begin
  if Value<> fFinalShots then
    begin
      fFinalShots:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_MinRatedResult(const Value: DWORD);
begin
  if Value<> fMinRatedResult10 then
    begin
      fMinRatedResult10:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_MQSResult(const Value: DWORD);
begin
  if Value<> fMQSResult10 then
    begin
      fMQSResult10:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_Name(const Value: string);
begin
  if Value<> fName then
    begin
      fName:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_Qualifications(index: integer; const Value: TQualificationResult10);
begin
  if Index>= 0 then
    begin
      if index>= Length (fQualifications10) then
        SetLength (fQualifications10, index+1);
      fQualifications10 [index]:= Value;
      while (Length (fQualifications10)> 0) and (fQualifications10 [Length (fQualifications10)-1].Competition10= 0) and
//        (fQualifications10 [Length (fQualifications10)-1].Total10= 0) do
        (fQualifications10 [Length (fQualifications10)-1].CompetitionTens10= 0) do
        SetLength (fQualifications10,Length (fQualifications10)-1);
      Changed;
    end;
end;

procedure TEventItem.set_RelayTime(const Value: TDateTime);
begin
  if Value<> fRelayTime then
    begin
      fRelayTime:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_SeparateFinalTable(const Value: boolean);
begin
  if Value<> fSeparateFinalTable then
    begin
      fSeparateFinalTable:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_SeriesPerStage(const Value: byte);
begin
  if Value<> fSeriesPerStage then
    begin
      fSeriesPerStage:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_ShortName(const Value: string);
begin
  if Value<> fShortName then
    begin
      fShortName:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_Stages(const Value: byte);
begin
  if Value<> fStages then
    begin
      fStages:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_Tag(const Value: string);
begin
  if Value<> fTag then
    begin
      fTag:= Value;
      Changed;
    end;
end;

procedure TEventItem.SortBonuses;
var
  i,j,k: integer;
  eb: TEventBonus;
begin
  for i:= 0 to Length (fBonusRatings)-2 do
    begin
      k:= i;
      for j:= i+1 to Length (fBonusRatings)-1 do
        if fBonusRatings [j].fResult> fBonusRatings [k].fResult then
          k:= j;
      if k<> i then
        begin
          eb:= fBonusRatings [i];
          fBonusRatings [i]:= fBonusRatings [k];
          fBonusRatings [k]:= eb;
        end;
    end;
end;

procedure TEventItem.SortBonuses10;
var
  i,j,k: integer;
  eb: TEventBonus10;
begin
  for i:= 0 to Length (fBonusRatings10)-2 do
    begin
      k:= i;
      for j:= i+1 to Length (fBonusRatings10)-1 do
        if fBonusRatings10 [j].fResult> fBonusRatings10 [k].fResult then
          k:= j;
      if k<> i then
        begin
          eb:= fBonusRatings10 [i];
          fBonusRatings10 [i]:= fBonusRatings10 [k];
          fBonusRatings10 [k]:= eb;
        end;
    end;
end;

function TEventItem.TotalSeries: integer;
begin
  Result:= fStages * fSeriesPerStage;
end;

{function TEventItem.TotalTemplate: string;
begin
  if (fFinalFracs) or (fCompFracs) then
    Result:= '0000.0'
  else
    Result:= '0000';
end;}

function TEventItem.TwoStarts: boolean;
begin
  Result:= EventType in [etRapidFire,etCenterFire,etCenterFire2013];
end;

procedure TEventItem.WriteToStream(Stream: TStream);
var
  c: integer;
begin
  CorrectTag;
  SaveStrToStreamA (Stream,fTag);
  SaveStrToStreamA (Stream,fCode);
  SaveStrToStreamA (Stream,fShortName);
  SaveStrToStreamA (Stream,fName);
  Stream.Write (fMQSResult10,sizeof (fMQSResult10));
  Stream.Write (fMinRatedResult10,sizeof (fMinRatedResult10));
  Stream.Write (fFinalFracs,sizeof (fFinalFracs));
  Stream.Write (fFinalPlaces,sizeof (fFinalPlaces));
  Stream.Write (fFinalShots,sizeof (fFinalShots));
  Stream.Write (fStages,sizeof (fStages));
  Stream.Write (fSeriesPerStage,sizeof (fSeriesPerStage));
  c:= Length (fQualifications10);
  Stream.Write (c,sizeof (c));
  Stream.Write (fQualifications10 [0],c*sizeof (TQualificationResult10));
  c:= Length (fBonusRatings);
  Stream.Write (c,sizeof (c));
  Stream.Write (fBonusRatings [0],c*sizeof (TEventBonus));
  c:= Length (fBonusRatings10);
  Stream.Write (c,sizeof (c));
  Stream.Write (fBonusRatings10 [0],c*sizeof (TEventBonus10));
  Stream.Write (fRelayTime,sizeof (fRelayTime));
  Stream.Write (fEventType,sizeof (fEventType));
  Stream.Write (fWeaponType,sizeof (fWeaponType));
  Stream.Write (fCompareBySeries,sizeof (fCompareBySeries));
  Stream.Write (fCompareByFinal,sizeof (fCompareByFinal));
  //Stream.Write (fCompFracs,sizeof (fCompFracs));
  Stream.Write (fSeparateFinalTable,sizeof (fSeparateFinalTable));
  Stream.Write (fLastChange,sizeof (fLastChange));
  _changed:= false;
end;

{function TEventItem.Qualified10(ACompetition: DWORD; ATotal: DWORD; var ByTotal: boolean): TQualificationItem;
var
  q1,q2: TQualificationItem;
begin
  q1:= QualifiedComp (ACompetition);
  q2:= QualifiedTotal (ATotal);
  ByTotal:= false;
  if (q1= nil) and (q2= nil) then
    Result:= nil
  else if (q1<> nil) and (q2= nil) then
    Result:= q1
  else if (q1= nil) and (q2<> nil) then
    begin
      Result:= q2;
      ByTotal:= true;
    end
  else if q1.Index<= q2.Index then
    Result:= q1
  else
    begin
      Result:= q2;
      ByTotal:= true;
    end;
end;}

function TEventItem.Qualified10 (ACompetition: DWORD; Tens: boolean): TQualificationItem;
var
  i: integer;
  q: TQualificationItem;
  qr: TQualificationResult10;
begin
  Result:= nil;
  if Tens then
    begin
      for i:= 0 to Length (fQualifications10)-1 do
        begin
          qr:= fQualifications10 [i];
          q:= Data.Qualifications.Items [i];
          if (q<> nil) and (qr.Competition10> 0) then
            begin
              if (ACompetition >= qr.CompetitionTens10) and (q.SetByResult) then
                begin
                  Result:= q;
                  break;
                end;
            end;
        end;
    end
  else
    begin
      for i:= 0 to Length (fQualifications10)-1 do
        begin
          qr:= fQualifications10 [i];
          q:= Data.Qualifications.Items [i];
          if (q<> nil) and (qr.Competition10> 0) then
            begin
              if (ACompetition >= qr.Competition10) and (q.SetByResult) then
                begin
                  Result:= q;
                  break;
                end;
            end;
        end;
    end;
end;

{function TEventItem.CompetitionStr(AComp: DWORD; WithTens: boolean): string;
begin
  if WithTens then
    Result:= format ('%d.%d',[AComp div 10,AComp mod 10])
  else
    Result:= IntToStr (AComp div 10);
end;}

function TEventItem.CompleteName: string;
begin
  if fShortName<> '' then
    begin
      Result:= fShortName;
      if fName<> '' then
        Result:= Result+' ('+fName+')';
    end
  else
    begin
      Result:= fName;
    end;
end;

{function TEventItem.CompetitionStr (AComp: DWORD): string;
begin
  Result:= CompetitionStr (AComp, fCompFracs);
end;}

{function TEventItem.CompTemplate: string;
begin
  if fCompFracs then
    Result:= '0000.0'
  else
    Result:= '0000';
end;}

procedure TEventItem.CorrectTag;
begin
  if fTag= '' then
    CreateTag;
end;

procedure TEventItem.DeleteQualification(index: integer);
var
  i: integer;
begin
  if (index>= 0) and (index< Length (fQualifications10)) then
    begin
      for i:= index to Length (fQualifications10)-2 do
        fQualifications10 [i]:= fQualifications10 [i+1];
      SetLength (fQualifications10,Length (fQualifications10)-1);
      Changed;
    end;
end;

procedure TEventItem.set_CompareByFinal(const Value: boolean);
begin
  if Value<> fCompareByFinal then
    begin
      fCompareByFinal:= Value;
      Changed;
    end;
end;

procedure TEventItem.set_CompareBySeries(const Value: boolean);
begin
  if Value<> fCompareBySeries then
    begin
      fCompareBySeries:= Value;
      Changed;
    end;
end;

{procedure TEventItem.set_CompFracs(const Value: boolean);
begin
  if Value<> fCompFracs then
    begin
      fCompFracs:= Value;
      fChanged:= true;
    end;
end;}

procedure TEventItem.Assign(Source: TPersistent);
var
  AEvent: TEventItem;
  i: integer;
begin
  if Source is TEventItem then
    begin
      AEvent:= Source as TEventItem;
      BeginChange;
      try
        fTag:= AEvent.Tag;
        fCode:= AEvent.Code;
        fShortName:= AEvent.ShortName;
        fName:= AEvent.Name;
        fMQSResult10:= AEvent.MQSResult10;
        fMinRatedResult10:= AEvent.MinRatedResult10;
        fFinalFracs:= AEvent.FinalFracs;
        fFinalPlaces:= AEvent.FinalPlaces;
        fFinalShots:= AEvent.FinalShots;
        fStages:= AEvent.Stages;
        fSeriesPerStage:= AEvent.SeriesPerStage;
        SetLength (fQualifications10,Length (AEvent.fQualifications10));
        for i:= 0 to Length (AEvent.fQualifications10)-1 do
          fQualifications10 [i]:= AEvent.fQualifications10 [i];
        SetLength (fBonusRatings,Length (AEvent.fBonusRatings));
        for i:= 0 to Length (AEvent.fBonusRatings)-1 do
          fBonusRatings [i]:= AEvent.fBonusRatings [i];
        SetLength (fBonusRatings10,Length (AEvent.fBonusRatings10));
        for i:= 0 to Length (AEvent.fBonusRatings10)-1 do
          fBonusRatings10 [i]:= AEvent.fBonusRatings10 [i];
        fRelayTime:= AEvent.RelayTime;
        fEventType:= AEvent.EventType;
        fWeaponType:= AEvent.WeaponType;
        fCompareBySeries:= AEvent.CompareBySeries;
      finally
        EndChange;
      end;
    end
  else
    inherited;
end;

{ TEvents }

function TEvents.Add: TEventItem;
begin
  Result:= inherited Add as TEventItem;
  
  fChanged:= true;
end;

procedure TEvents.Check;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].Check;
end;

constructor TEvents.Create (AData: TData);
begin
  inherited Create (TEventItem);
  fData:= AData;
  fChanged:= false;
end;

procedure TEvents.DeleteQualification(index: integer);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].DeleteQualification (index);
end;

procedure TEvents.ExportToCSV(const FName: TFileName);
var
  s: TStrings;
  i: integer;
begin
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'name'+CSVDelimiter+'title'+CSVDelimiter+'minresult');
  for i:= 0 to Count-1 do
    s.Add (Items [i].CSVStr);
  try
    s.SaveToFile (FName);
    s.Free;
  except
    s.Free;
    raise
  end;
end;

function TEvents.FindByName(const AName: string): TEventItem;
var
  i: integer;
  e: TEventItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      e:= Items [i];
      if e.Name= AName then
        begin
          Result:= e;
          break;
        end;
    end;
end;

function TEvents.get_Event(Tag: string): TEventItem;
var
  i: integer;
  ev: TEventItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      ev:= Items [i];
      if AnsiSameText (ev.Tag,Tag) then
        begin
          Result:= ev;
          break;
        end;
    end;
end;

function TEvents.get_EventIdx(index: integer): TEventItem;
begin
  Result:= (inherited Items [index]) as TEventItem;
end;

function TEvents.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  if not fChanged then
    for i:= 0 to Count-1 do
      Result:= Result or Items [i].WasChanged;
end;

procedure TEvents.MergeWith(AEvents: TEvents);
var
  i: integer;
  e,ae: TEventItem;
begin
  for i:= 0 to AEvents.Count-1 do
    begin
      ae:= AEvents.Items [i];
      e:= Events[ae.Tag];
      if e= nil then
        begin
          e:= Add;
          e.Assign (ae);
          Data.Championships.AddEventTable (e);
        end
      else
        begin
          if ae.fLastChange> e.fLastChange then
            e.Assign (ae);
        end;
    end;
end;

procedure TEvents.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  ev: TEventItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      ev:= Add;
      ev.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TEvents.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c, sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TEventsFilter }

procedure TEventsFilter.Add(AEvent: TEventItem);
var
  fe: TFilteredEventItem;
begin
  if not Filtered (AEvent) then
    begin
      fe:= inherited Add as TFilteredEventItem;
      fe.fEvent:= AEvent;
    end;
end;

procedure TEventsFilter.Add(AFilter: TEventsFilter);
var
  i: integer;
begin
  for i:= 0 to AFilter.Count-1 do
    Add ((AFilter.Items [i] as TFilteredEventItem).fEvent);
end;

procedure TEventsFilter.Add(AEvents: TEvents);
var
  i: integer;
begin
  for i:= 0 to AEvents.Count-1 do
    Add (AEvents.Items [i]);
end;

procedure TEventsFilter.Add(AGroup: TGroupItem);
var
  i,j,idx: integer;
  e: TEventItem;
  sh: TShooterItem;
  f: TEventsFilter;
  fe,fe1: TFilteredEventItem;
  p,p1: integer;
begin
  f:= TEventsFilter.Create;
  for i:= 0 to AGroup.Data.Events.Count-1 do
    begin
      e:= AGroup.Data.Events.Items [i];
      for j:= 0 to AGroup.Shooters.Count-1 do
        begin
          sh:= AGroup.Shooters.Items [j];
          if sh.Results.ResultsInEvent (e)> 0 then
            begin
              f.Add (e);
              break;
            end;
        end;
    end;
  // ��������� ������ �� ������������� ������
  for i:= 0 to f.Count-2 do
    begin
      idx:= i;
      fe:= f.Items [i] as TFilteredEventItem;
      for j:= i to f.Count-1 do
        begin
          p:= AGroup.Prefered (fe.Event);
          fe1:= f.Items [j] as TFilteredEventItem;
          p1:= AGroup.Prefered (fe1.Event);
          if (p1>= 0) and ((p< 0) or (p1< p)) then
            fe:= fe1
          else if (p1< 0) and (p< 0) and (fe1.Event.Index< fe.Event.Index) then
            fe:= fe1;
        end;
      fe.Index:= idx;
    end;
  Add (f);
  f.Free;
end;

constructor TEventsFilter.Create;
begin
  inherited Create (TFilteredEventItem);
end;

procedure TEventsFilter.Delete(AEvent: TEventItem);
var
  ev: TFilteredEventItem;
begin
  ev:= FindEvent (AEvent);
  if ev<> nil then
    ev.Free;
end;

function TEventsFilter.Filtered(AEvent: TEventItem): boolean;
begin
  Result:= FindEvent (AEvent)<> nil;
end;

function TEventsFilter.FindEvent(AEvent: TEventItem): TFilteredEventItem;
var
  i: integer;
  ev: TFilteredEventItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      ev:= Items [i] as TFilteredEventItem;
      if ev.fEvent= AEvent then
        begin
          Result:= ev;
          exit;
        end;
    end;
end;

function TEventsFilter.get_Event(index: integer): TEventItem;
begin
  if (index>= 0) and (index< Count) then
    Result:= (Items [index] as TFilteredEventItem).fEvent
  else
    Result:= nil;
end;

function TEventsFilter.IndexOf(AEvent: TEventItem): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to Count-1 do
    if Events [i]= AEvent then
      begin
        Result:= i;
        break;
      end;
end;

{ TQualificationItem }

procedure TQualificationItem.Assign(Source: TPersistent);
begin
  if Source is TQualificationItem then
    begin
      fName:= (Source as TQualificationItem).fName;
      fSetByResult:= (Source as TQualificationItem).fSetByResult;
      Changed;
    end;
end;

procedure TQualificationItem.Changed;
begin
  _changed:= true;
  fLastChange:= Now;
end;

procedure TQualificationItem.Check;
begin
  // TODO: �������� ������������
end;

constructor TQualificationItem.Create(ACollection: TCollection);
begin
  inherited;
  fName:= '';
  _changed:= false;
  fLastChange:= Now;
  fSetByResult:= false;
  Qualifications.fChanged:= true;
end;

function TQualificationItem.CSVStr: string;
begin
  Result:= IntToStr (Index+1)+CSVDelimiter+StrToCSV (fName)+CSVDelimiter+
    IntToStr (byte (fSetByResult));
end;

destructor TQualificationItem.Destroy;
begin
  Qualifications.fChanged:= true;
  inherited;
end;

function TQualificationItem.get_Data: TData;
begin
  Result:= (Collection as TQualifications).Data;
end;

function TQualificationItem.Qualifications: TQualifications;
begin
  Result:= Collection as TQualifications;
end;

procedure TQualificationItem.ReadFromStream(Stream: TStream);
//var
//  c: integer;
begin
  ReadStrFromStreamA (Stream,fName);
  //Stream.Read (c,sizeof (c));
  //SetLength (fName,c);
  //Stream.Read (fName [1],c);
  Stream.Read (fSetByResult,sizeof (fSetByResult));
  if Data.fFileVersion>= 40 then
    Stream.Read (fLastChange,sizeof (fLastChange));
  _changed:= false;
  Qualifications.fChanged:= true;
end;

procedure TQualificationItem.set_Name(const Value: string);
begin
  if Value<> fName then
    begin
      fName:= Value;
      Changed;
    end;
end;

procedure TQualificationItem.set_SetByResult(const Value: boolean);
begin
  if Value<> fSetByResult then
    begin
      fSetByResult:= Value;
      Changed;
    end;
end;

procedure TQualificationItem.WriteToStream(Stream: TStream);
begin
  SaveStrToStreamA (Stream,fName);  // ���������� ���������� ������� ��� Unicode
  Stream.Write (fSetByResult,sizeof (fSetByResult));
  Stream.Write (fLastChange,sizeof (fLastChange));
  _changed:= false;
end;

{ TQualifications }

function TQualifications.Add: TQualificationItem;
begin
  Result:= inherited Add as TQualificationItem;
end;

procedure TQualifications.Check;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].Check;
end;

constructor TQualifications.Create (AData: TData);
begin
  inherited Create (TQualificationItem);
  fData:= AData;
  fChanged:= false;
end;

procedure TQualifications.ExportToCSV(const FName: TFileName);
var
  s: TStrings;
  i: integer;
begin
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'qualification'+CSVDelimiter+'setbyresult');
  for i:= 0 to Count-1 do
    s.Add (Items [i].CSVStr);
  try
    s.SaveToFile (FName);
    s.Free;
  except
    s.Free;
    raise
  end;
end;

function TQualifications.FindByName(
  const AName: string): TQualificationItem;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    if AnsiSameText (Items [i].Name,AName) then
      begin
        Result:= Items [i];
        break;
      end;
end;

function TQualifications.get_QualificationIdx(
  index: integer): TQualificationItem;
begin
  if (index>= 0) and (index< Count) then
    Result:= inherited Items [index] as TQualificationItem
  else
    Result:= nil;
end;

function TQualifications.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

procedure TQualifications.MergeWith(AQualifications: TQualifications);
var
  i: integer;
  q,aq: TQualificationItem;
begin
  for i:= 0 to AQualifications.Count-1 do
    begin
      aq:= AQualifications.Items [i];
      q:= FindByName (aq.Name);
      if q= nil then
        begin
          q:= Add;
          q.Assign (aq);
        end
      else
        begin
          if aq.fLastChange> q.fLastChange then
            q.Assign (aq);
        end;
    end;
end;

procedure TQualifications.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  q: TQualificationItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      q:= Add;
      q.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TQualifications.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TResultItem }

procedure TResultItem.Assign(Source: TPersistent);
var
  sev,src: TShootingEventItem;
  sch: TShootingChampionshipItem;
  ch: TChampionshipItem;
  ev: TEventItem;
  sr: TResultItem;
begin
  if Source is TResultItem then
    begin
      sr:= Source as TResultItem;
      if sr.Data= Data then
        begin
          ShootingEvent:= (Source as TResultItem).ShootingEvent;
          fJunior:= (Source as TResultItem).fJunior;
          fRank:= (Source as TResultItem).fRank;
          fCompetition10:= (Source as TResultItem).fCompetition10;
          fCompetitionWithTens:= (Source as TResultItem).fCompetitionWithTens;
          fFinal10:= (Source as TResultItem).fFinal10;
          fPrecalcRating:= -1; //(Source as TResultItem).fPrecalcRating;
        end
      else
        begin
          src:= (Source as TResultItem).ShootingEvent;
          // ������� ����� ���������� �� GUID
          sev:= Data.ShootingChampionships.FindEvent (src.Id);
          if sev= nil then
            begin
              // ���� �� ����������, ����� ���� ������������ � ����������
              if src.Championship.Championship<> nil then
                ch:= Data.Championships [src.Championship.Championship.Tag]
              else
                ch:= nil;
              sch:= Data.ShootingChampionships.Find (ch,src.Championship.ChampionshipName,src.Date);
              if sch= nil then
                begin
                  sch:= Data.ShootingChampionships.Add;
                  sch.SetChampionship (ch,src.Championship.ChampionshipName);
                end;
              sch.Country:= src.Championship.Country;
              sch.Town:= src.Championship.Town;
              sev:= sch.Events.Find (src.Event,src.EventName,src.Date);
              if sev= nil then
                begin
                  sev:= sch.Events.Add;
                  sev.Id:= src.Id;
                  if src.Event<> nil then
                    begin
                      ev:= Data.Events [src.Event.Tag];
                      sev.SetEvent (ev,src.ShortName,src.EventName);
                    end
                  else
                    begin
                      sev.SetEvent (nil,src.ShortName,src.EventName);
                    end;
                end;
              sev.Date:= src.Date;
              sev.Town:= src.Town;
            end;
          ShootingEvent:= sev;
          fJunior:= (Source as TResultItem).fJunior;
          fRank:= (Source as TResultItem).fRank;
          fCompetition10:= (Source as TResultItem).fCompetition10;
          fCompetitionWithTens:= (Source as TResultItem).fCompetitionWithTens;
          fFinal10:= (Source as TResultItem).fFinal10;
          fPrecalcRating:= -1;
        end;
      Changed;
    end;
end;

function TResultItem.AsText: string;
begin
  Result:= Shooter.SurnameAndName+' - '+DateToStr (Date)+', '+ChampionshipName+', '+Country+', '+Town+', '+
    EventShortName+', '+RankStr+', '+CompetitionStr+', '+FinalStr;
end;

procedure TResultItem.Changed;
begin
  _changed:= true;
  fLastChange:= Now;
end;

function TResultItem.CompareTo(AResult: TResultItem; Order: TResultsSortOrder): shortint;
begin
  case Order of
    rsoNone: Result:= 0;
    rsoDate: Result:= Sign (Date-AResult.Date);
    rsoRank: begin
      if Rank= 0 then
        Result:= -Sign (AResult.Rank)
      else if AResult.Rank= 0 then
        Result:= Sign (Rank)
      else
        Result:= -Sign (Rank-AResult.Rank)
    end;
    rsoCompetition: Result:= CompareDwords (Competition10,AResult.Competition10);
    rsoRating: Result:= Sign (Rating-AResult.Rating);
  else
    Result:= 0;
  end;
end;

function TResultItem.CompetitionStr: string;
begin
  if Event<> nil then
    begin
      if fCompetitionWithTens then
        Result:= IntToStr (fCompetition10 div 10)+'.'+IntToStr (fCompetition10 mod 10)
      else
        Result:= IntToStr (fCompetition10 div 10);
    end
  else
    begin
      if fCompetition10 mod 10> 0 then
        Result:= IntToStr (fCompetition10 div 10)+'.'+IntToStr (fCompetition10 mod 10)
      else
        Result:= IntToStr (fCompetition10 div 10);
    end;
end;

constructor TResultItem.Create(ACollection: TCollection);
begin
  inherited;
  fPrecalcRating:= -1;
  fShEvent:= nil;
  fJunior:= false;
  fRank:= 0;
  fCompetition10:= 0;
  fFinal10:= 0;
  fCompetitionWithTens:= false;
  _changed:= false;
  fLastChange:= Now;
  fDupe:= false;
  fStartEventShooterLink:= nil;
  Results.fChanged:= true;
  //CreateGUID (fGUID);
end;

function TResultItem.CSVStr: string;
begin
  Result:= DateToStr (fShEvent.Date)+','+
    StrToCSV (fShEvent.ShortName)+','+
    StrToCSV (fShEvent.Country)+','+StrToCSV (fShEvent.Town)+','+
    IntToStr (byte (fJunior))+','+
    StrToCsv (RankStr)+','+
    StrToCsv (CompetitionStr)+','+StrToCSV (FinalStr)+','+StrToCSV (TotalStr);
end;

procedure TResultItem.EncodeFinal(AInt, AFrac: integer);
begin
  fFinal10:= Aint * 10 + AFrac;
end;

destructor TResultItem.Destroy;
begin
  if fStartEventShooterLink<> nil then
    begin
      fStartEventShooterLink.fResultItem:= nil;
      fStartEventShooterLink.fChanged:= true;
      fStartEventShooterLink:= nil;
    end;
  if ShootingEvent<> nil then
    ShootingEvent.DecrementResults;
  Results.fChanged:= true;
  inherited;
end;

procedure TResultItem.EncodeFinal(AFinal: single);
begin
  Final10:= Round (AFinal*10);
end;

function TResultItem.EventShortName: string;
begin
  if ShootingEvent<> nil then
    Result:= ShootingEvent.ShortName
  else
    Result:= '';
end;

function TResultItem.FinalStr: string;
begin
  if (ShootingEvent<> nil) and (ShootingEvent.Event<> nil) then
    begin
      if InFinal then
        begin
          case ShootingEvent.Event.EventType of
            etRapidFire: begin
              if ShootingEvent.Date>= EncodeDate (2010,10,26) then
                Result:= IntToStr (fFinal10 div 10)
              else
                Result:= IntToStr (fFinal10 div 10)+'.'+IntTostr (fFinal10 mod 10);
            end;
          else
            if ShootingEvent.Event.FinalFracs then
              Result:= IntToStr (fFinal10 div 10)+'.'+IntTostr (fFinal10 mod 10)
            else
              Result:= IntToStr (fFinal10 div 10);
          end;
        end
      else
        Result:= '';
    end
  else
    begin
      if fFinal10> 0 then
        Result:= IntToStr (fFinal10 div 10)+'.'+IntTostr (fFinal10 mod 10)
      else
        Result:= '';
    end;
end;

function TResultItem.get_Championship: TChampionshipItem;
begin
  if ShootingEvent<> nil then
    Result:= ShootingEvent.Championship.Championship
  else
    Result:= nil;
end;

function TResultItem.get_ChampionshipName: string;
begin
  if ShootingEvent<> nil then
    Result:= ShootingEvent.Championship.ChampionshipName
  else
    Result:= '';
end;

function TResultItem.get_Country: string;
begin
  if ShootingEvent<> nil then
    Result:= ShootingEvent.Country
  else
    Result:= '';
end;

function TResultItem.get_Data: TData;
begin
  Result:= Shooter.Data;
end;

function TResultItem.get_Date: TDateTime;
begin
  if ShootingEvent<> nil then
    Result:= ShootingEvent.Date
  else
    Result:= Now;
end;

function TResultItem.get_Event: TEventItem;
begin
  if ShootingEvent<> nil then
    Result:= ShootingEvent.Event
  else
    Result:= nil;
end;

function TResultItem.get_EventName: string;
begin
  if ShootingEvent<> nil then
    Result:= ShootingEvent.EventName
  else
    Result:= '';
end;

function TResultItem.get_Group: TGroupItem;
begin
  Result:= Shooter.Group;
end;

function TResultItem.get_Shooter: TShooterItem;
begin
  Result:= (Collection as TResults).Shooter;
end;

function TResultItem.get_Town: string;
begin
  if ShootingEvent<> nil then
    Result:= ShootingEvent.Town
  else
    Result:= '';
end;

function TResultItem.InFinal: boolean;
begin
  if (ShootingEvent<> nil) and (ShootingEvent.Event<> nil) then
    Result:= ((fRank> 0) and (fRank<= ShootingEvent.Event.FinalPlaces))
  else
    Result:= false;
end;

function TResultItem.RankStr: string;
begin
  if fRank> 0 then
    Result:= IntToStr (fRank)
  else
    Result:= '';
end;

function TResultItem.Rating: integer;
var
  interval: TDateTime;
  ev: TEventItem;
  ch: TChampionshipItem;
begin
  if fPrecalcRating= -1 then
    begin
      Result:= 0;
      fPrecalcRating:= 0;
      ev:= Event;
      if ev= nil then
        exit;
      ch:= Championship;
      if ch= nil then
        exit;
      // ���������� � ������������ ���������, ������� ����� ��������� �������
      if fCompetition10< ev.MinRatedResult10 then
        Result:= 0
      else
        begin
          // �� ����� ������� ������ ������ ��� ������� �����
          if fRank> 0 then
            Result:= Result+ch.GetRating (self);
          // � ������� ������ ������� ������ ������ �� ���������
//          fr._int:= fCompetition;
//          fr._frac:= 0;
//          Result:= Result+ev.GetBonus (fr);
          Result:= Result+ev.GetBonus (fCompetition10,fCompetitionWithTens);
          // �������� �� �������
          interval:= trunc (Data.RatingDate)-trunc (Date);
          if (interval< 0) or (interval>= ch.Period * 30.5) then
            Result:= 0
          else
            begin
              if interval> ch.RatingHold * 30.5 then
                Result:= round (Result*(1-(interval-ch.RatingHold*30.5)/((ch.Period-ch.RatingHold)*30.5)));
            end;
        end;
      fPrecalcRating:= Result;
    end
  else
    Result:= fPrecalcRating;
end;

function TResultItem.RatingStr: string;
begin
  if Rating> 0 then
    Result:= IntToStr (Rating)
  else
    Result:= '';
end;

procedure TResultItem.ReadFromStream(Stream: TStream);
var
  c: integer;
  f: single;
  del: boolean;
  tag: string;
  _date: TDateTime;
  _ch: TChampionshipItem;
  _cn: string;
  _ev: TEventItem;
  _en: string;
  sch: TShootingChampionshipItem;
  sev: TShootingEventItem;
  _country: string;
  _town: string;
  ch_idx,ev_idx: integer;
  _w: word;
  _fr: TFinalResultOld;
  _b: byte;
begin
  //if Data.fFileVersion>= 40 then
    //Stream.Read (fGUID,sizeof (fGUID));
  if Data.fFileVersion<= 11 then
    Stream.Read (del,sizeof (del))
  else
    del:= false;
  if Data.fFileVersion< 25 then
    begin
      Stream.Read (_date,sizeof (_date));
      // ������ ������������
      if Data.fFileVersion>= 22 then
        begin
          Stream.Read (c,sizeof (c));
          if c>= 0 then
            begin
              if c>= Data.Championships.Count then
                begin
                  raise EInvalidDataFile.Create ('Invalid championship index.');
                end;
              _ch:= Data.Championships.Items [c];
              _cn:= '';
            end
          else
            begin
              _ch:= nil;
              ReadStrFromStreamA (Stream,_cn);
            end;
        end
      else
        begin
          ReadStrFromStreamA (Stream,tag);
    //      Stream.Read (c,sizeof (c));
    //      if c> 1024 then
    //        begin
    //          raise EOutOfMemory.Create ('Bad championship tag!');
    //        end;
    //      SetLength (tag,c);
    //      Stream.Read (tag [1],c);
          _ch:= Data.Championships [tag];
          if tag= '' then
            begin
              Stream.Read (c,sizeof (c));
              if c> 1024 then
                begin
                  raise EOutOfMemory.Create ('Bad championship name!');
                end;
              SetLength (_cn,c);
              Stream.Read (_cn [1],c);
            end
          else
            begin
              if _ch= nil then
                begin
                  _cn:= tag;
    //              fChampionshipTag:= '';
                end
              else
                _cn:= '';
            end;
        end;
      // ������ �������� ����� ����� ������������ ������
      sch:= Data.ShootingChampionships.Find (_ch,_cn,_date);
      if sch= nil then
        begin
          sch:= Data.ShootingChampionships.Add;
          sch.SetChampionship (_ch,_cn);
        end;
      // ������ ����������
      if Data.fFileVersion>= 23 then
        begin
          Stream.Read (c,sizeof (c));
          if c>= 0 then
            begin
              if c>= Data.Events.Count then
                begin
                  raise EInvalidDataFile.Create ('Bad event index');
                end;
              _ev:= Data.Events.Items [c];
              _en:= '';
            end
          else
            begin
              _ev:= nil;
              ReadStrFromStreamA (Stream,_en);
            end;
        end
      else
        begin
          ReadStrFromStreamA (Stream,tag);
          //Stream.Read (c,sizeof (c));
          //if c> 1024 then
          //  begin
          //    raise EOutOfMemory.Create ('Bad event tag!');
          //  end;
          //SetLength (tag,c);
          //Stream.Read (tag [1],c);
          _ev:= Data.Events [tag];
          if tag= '' then
            begin
              ReadStrFromStreamA (Stream,_en);
              //Stream.Read (c,sizeof (c));
              //if c> 1024 then
              //  begin
              //    raise EOutOfMemory.Create ('Bad event name!');
              //  end;
              //SetLength (_en,c);
              //Stream.Read (_en [1],c);
            end
          else
            begin
              if _ev= nil then
                begin
                  _en:= tag;
    //              fEventTag:= '';
                end
              else
                _en:= '';
            end;
        end;
      // ������ �������� ����� ������ ����������
      sev:= sch.Events.Find (_ev,_en,_date);
      if sev= nil then
        begin
          sev:= sch.Events.Add;
          sev.Date:= _date;
          sev.SetEvent (_ev,'',_en);
        end;
      ReadStrFromStreamA (Stream,_country);
      //Stream.Read (c,sizeof (c));
      //if c> 1024 then
        //begin
          //raise EOutOfMemory.Create ('Bad country!');
       // end;
      //SetLength (_country,c);
      //Stream.Read (_country [1],c);
      sch.Country:= _country;
      ReadStrFromStreamA (Stream,_town);
      //Stream.Read (c,sizeof (c));
      //if c> 1024 then
      //  begin
      //    raise EOutOfMemory.Create ('Bad town!');
      //  end;
      //SetLength (_town,c);
      //Stream.Read (_town [1],c);
      sev.Town:= _town;
      ShootingEvent:= sev;
    end
  else
    begin
      if Data.fFileVersion>= 40 then
        begin
          Stream.Read (_w,sizeof (_w));
          ch_idx:= _w;
          Stream.Read (_w,sizeof (_w));
          ev_idx:= _w;
        end
      else
        begin
          Stream.Read (ch_idx,sizeof (ch_idx));
          Stream.Read (ev_idx,sizeof (ev_idx));
        end;
      ShootingEvent:= Data.ShootingChampionships [ch_idx].Events [ev_idx];
    end;
  if Data.fFileVersion< 40 then
    Stream.Read (fJunior,sizeof (fJunior));
  Stream.Read (fRank,sizeof (fRank));
  if Data.fFileVersion<= 35 then
    begin
      Stream.Read (_w,sizeof (_w));
      fCompetition10:= _w * 10;
      fCompetitionWithTens:= false;
    end
  else
    begin
      Stream.Read (fCompetition10,sizeof (fCompetition10));
      if Data.fFileVersion< 40 then
        Stream.Read (fCompetitionWithTens,sizeof (fCompetitionWithTens));
    end;
  if Data.fFileVersion>= 4 then
    begin
      if Data.fFileVersion<= 35 then
        begin
          Stream.Read (_fr,sizeof (_fr));
          fFinal10:= _fr._int * 10 + _fr._frac;
        end
      else
        Stream.Read (fFinal10,sizeof (fFinal10));
    end
  else
    begin
      Stream.Read (f,sizeof (f));
      EncodeFinal (f);
    end;
  if Data.fFileVersion>= 40 then
    begin
      Stream.Read (_b,sizeof (_b));
      fJunior:= (_b and $01)= $01;
      fCompetitionWithTens:= (_b and $02)= $02;
      Stream.Read (fLastChange,sizeof (fLastChange));
    end;
  _changed:= false;
  if del then
    Free;
  Results.fChanged:= true;
end;

procedure TResultItem.ResetRating;
begin
  fPrecalcRating:= -1;
end;

function TResultItem.Results: TResults;
begin
  Result:= Collection as TResults;
end;

function TResultItem.SameAs(R: TResultItem): boolean;
begin
  Result:= false;
  if R.Date<> Date then
    exit;
  if R.fRank<> fRank then
    exit;
  if R.fCompetition10<> fCompetition10 then
    exit;
  if R.fFinal10<> fFinal10 then
    exit;
  if R.fCompetitionWithTens<> fCompetitionWithTens then
    exit;
  if R.Data= Data then
    begin
      if R.Event<> Event then
        exit;
      if (R.Event= nil) and (R.EventName<> EventName) then
        exit;
      if R.Championship<> Championship then
        exit;
      if (R.Championship= nil) and (R.ChampionshipName<> ChampionshipName) then
        exit;
    end
  else
    begin
      if (R.Event= nil) and (Event<> nil) then
        exit;
      if (R.Event<> nil) and (Event= nil) then
        exit;
      if (R.Event<> nil) and (Event<> nil) and (R.Event.Tag<> Event.Tag) then
        exit;
      if (R.Event= nil) and (Event= nil) and (R.EventName<> EventName) then
        exit;
      if (R.Championship= nil) and (Championship<> nil) then
        exit;
      if (R.Championship<> nil) and (Championship= nil) then
        exit;
      if (R.Championship<> nil) and (Championship<> nil) and (R.Championship.Tag<> Championship.Tag) then
        exit;
      if (R.Championship= nil) and (Championship= nil) and (R.ChampionshipName<> ChampionshipName) then
        exit;
    end;
  Result:= true;
end;

procedure TResultItem.set_Competition10(const Value: DWORD);
begin
  if Value<> fCompetition10 then
    begin
      fCompetition10:= Value;
      fPrecalcRating:= -1;
      Changed;
    end;
end;

procedure TResultItem.set_CompetitionWithTens(const Value: boolean);
begin
  if Value<> fCompetitionWithTens then
    begin
      fCompetitionWithTens:= Value;
      if not fCompetitionWithTens then
        fCompetition10:= (fCompetition10 div 10) * 10;
      fPrecalcRating:= -1;
      Changed;
    end;
end;

procedure TResultItem.set_Final10(const Value: DWORD);
begin
  if Value<> fFinal10 then
    begin
      fFinal10:= Value;
      fPrecalcRating:= -1;
      Changed;
    end;
end;

procedure TResultItem.set_Junior(const Value: boolean);
begin
  if Value<> fJunior then
    begin
      fJunior:= Value;
      Changed;
    end;
end;

procedure TResultItem.set_Rank(const Value: integer);
begin
  if Value<> fRank then
    begin
      fRank:= Value;
      fPrecalcRating:= -1;
      Changed;
    end;
end;

procedure TResultItem.set_ShootingEvent(const Value: TShootingEventItem);
begin
  if Value<> fShEvent then
    begin
      if fShEvent<> nil then
        fShEvent.DecrementResults;
      fShEvent:= Value;
      if fShEvent<> nil then
        fShEvent.IncrementResults;
      ResetRating;
    end;
end;

function TResultItem.TotalStr: string;
var
  ev: TEventItem;
  t: DWORD;
begin
  if fCompetition10+fFinal10> 0 then
    begin
      t:= fCompetition10+fFinal10;
      ev:= Event;
      if ev<> nil then
        begin
          if InFinal then
            begin
              case ev.EventType of
                etRapidFire: begin
                  if ShootingEvent.Date>= EncodeDate (2010,10,26) then
                    Result:= ''
                  else
                    Result:= IntToStr (t div 10)+'.'+IntToStr (t mod 10);
                end;
              else
                if (not ev.CompareByFinal) or (ShootingEvent.Date< EncodeDate (2012,11,25)) then
                  Result:= ResultToStr (t,fCompetitionWithTens or ev.FinalFracs)
                else
                  Result:= '';
              end;
            end
          else
            begin
              if (not Event.CompareByFinal) or (ShootingEvent.Date< EncodeDate (2012,11,25)) then
                Result:= ResultToStr (t,fCompetitionWithTens)
              else
                Result:= '';
            end;
        end
      else
        Result:= ResultToStr (t,fCompetitionWithTens);
    end
  else
    Result:= '';
end;

procedure TResultItem.WriteToStream(Stream: TStream);
var
  ch_idx,ev_idx: word;
  b: byte;
begin
  ch_idx:= ShootingEvent.Championship.Index;
  ev_idx:= ShootingEvent.Index;
  //Stream.Write (fGUID,sizeof (fGUID));
  Stream.Write (ch_idx,sizeof (ch_idx));
  Stream.Write (ev_idx,sizeof (ev_idx));
  //Stream.Write (fJunior,sizeof (fJunior));
  Stream.Write (fRank,sizeof (fRank));
  Stream.Write (fCompetition10,sizeof (fCompetition10));
  //Stream.Write (fCompetitionWithTens, sizeof (fCompetitionWithTens));
  Stream.Write (fFinal10,sizeof (fFinal10));
  b:= 0;
  if fJunior then
    b:= b or $01;
  if fCompetitionWithTens then
    b:= b or $02;
  Stream.Write (b,sizeof (b));
  Stream.Write (fLastChange,sizeof (fLastChange));
  _changed:= false;
end;

{ TResults }

function TResults.Add: TResultItem;
begin
  Result:= inherited Add as TResultItem;
end;

procedure TResults.Check;
var
  i,j: integer;
  r1,r2: TResultItem;
  idx: integer;
begin
  idx:= Length (Data.fDupeResults);
  for i:= 0 to Count-1 do
    Items [i].fDupe:= false;
  i:= 0;
  while i< Count-1 do
    begin
      r1:= Items [i];
      if not r1.fDupe then
        begin
          j:= i+1;
          while j< Count do
            begin
              r2:= Items [j];
              if r2.SameAs (r1) then
                begin
                  SetLength (Data.fDupeResults,idx+1);
                  Data.fDupeResults [idx].Origin:= r1;
                  Data.fDupeResults [idx].Dupe:= r2;
                  r2.fDupe:= true;
                  inc (idx);
                end;
              inc (j);
            end;
        end;
      inc (i);
    end;
end;

constructor TResults.Create (AShooter: TShooterItem);
begin
  inherited Create (TResultItem);
  fShooter:= AShooter;
  fChanged:= false;
end;

procedure TResults.DeleteResults(AEvent: TEventItem);
var
  i: integer;
  res: TResultItem;
begin
  i:= 0;
  while i< Count do
    begin
      res:= Items [i];
      if res.Event= AEvent then
        Delete (res.Index)
      else
        inc (i);
    end;
end;

procedure TResults.DeleteResults(AChampionship: TChampionshipItem);
var
  i: integer;
  res: TResultItem;
begin
  i:= 0;
  while i< Count do
    begin
      res:= Items [i];
      if res.Championship= AChampionship then
        Delete (res.Index)
      else
        inc (i);
    end;
end;

{function TResults.FindByGUID(const GUID: TGUID): TResultItem;
var
  i: integer;
  r: TResultItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      r:= Items[i];
      if IsEqualGUID (r.GUID,GUID) then
        begin
          Result:= r;
          exit;
        end;
    end;
end;}

function TResults.FindSame(AResult: TResultItem): TResultItem;
var
  i: integer;
  r: TResultItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      r:= Items [i];
      if r.SameAs (AResult) then
        begin
          Result:= r;
          break;
        end;
    end;
end;

function TResults.FindSameDateAndEvent(ADate: TDateTime; AEvent: TEventItem): TResultItem;
var
  i: integer;
  r: TResultItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      r:= Items [i];
      if (SameDate (r.Date,ADate)) and (r.Event= AEvent) then
        begin
          Result:= r;
          break;
        end;
    end;
end;

function TResults.get_Data: TData;
begin
  Result:= fShooter.Data;
end;

function TResults.get_Result(index: integer): TResultItem;
begin
  if (index>= 0) and (index< Count) then
    Result:= inherited Items [index] as TResultItem
  else
    Result:= nil;
end;

function TResults.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

function TResults.Last: TResultItem;
var
  i: integer;
  res: TResultItem;
begin
  Result:= nil;
  if Count= 0 then
    exit;
  Result:= Items[0];
  for i:= 1 to Count-1 do
    begin
      res:= Items[i];
      if res.Date> Result.Date then
        Result:= res;
    end;
end;

procedure TResults.MergeWith(AResults: TResults);
var
  i: integer;
  r,ar: TResultItem;
begin
  for i:= 0 to AResults.Count-1 do
    begin
      ar:= AResults [i];
      r:= nil; //FindByGUID (ar.GUID);
      if r= nil then
        begin
          r:= FindSame (ar);
          if r= nil then
            begin
              r:= Add;
              //r.fGUID:= ar.GUID;
              r.Assign (ar);
            end
          else
            begin
              if ar.fLastChange> r.fLastChange then
                r.Assign (ar);
            end;
        end
      else
        begin
          if ar.fLastChange> r.fLastChange then
            r.Assign (ar);
        end;
    end;
end;

procedure TResults.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  res: TResultItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      res:= Add;
      res.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TResults.ResetRatings;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].ResetRating;
end;

function TResults.ResultsInEvent(AEvent: TEventItem): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    if Items [i].Event= AEvent then
      inc (Result);
end;

function TResults.TotalRating(AEvent: TEventItem): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    if Items [i].Event= AEvent then
      Result:= Result+Items [i].Rating;
end;

procedure TResults.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TShooterItem }

procedure TShooterItem.AddImage(const FileName: TFileName);
begin
  SetLength (fImages,Length (fImages)+1);
  fImages [Length (fImages)-1]:= FileName;
  Changed;
end;

function TShooterItem.get_BirthYearStr: string;
var
  y: integer;
begin
  y:= fBirthYear;
  if (y> 1900) and (y< YearOf (Now)) then
    Result:= IntToStr (y)
  else
    Result:= '';
end;

procedure TShooterItem.Changed;
begin
  _changed:= true;
  if fChanging= 0 then
    fLastChange:= Now;
end;

procedure TShooterItem.Check;
begin
  // TODO: �������� ������ �������
  fResults.Check;
end;

function TShooterItem.CompareTo(AShooter: TShooterItem; Order: TShootersSortOrder): shortint;
begin
  case Order of
    ssoNone: Result:= 0;
    ssoSurname: Result:= -AnsiCompareText (Surname,AShooter.Surname);
    ssoAge: Result:= Sign (fBirthYear-AShooter.fBirthYear);
    ssoRegion: Result:= -AnsiCompareText (RegionAbbr1,AShooter.RegionAbbr1);
    ssoQualification: begin
      if (fQualification= nil) and (AShooter.Qualification= nil) then
        Result:= 0
      else if (fQualification= nil) and (AShooter.Qualification<> nil) then
        Result:= 1
      else if (fQualification<> nil) and (AShooter.Qualification= nil) then
        Result:= -1
      else
        Result:= -Sign (fQualification.Index-AShooter.Qualification.Index);
    end;
    ssoDistrict: Result:= -AnsiCompareText (DistrictAbbr,AShooter.DistrictAbbr);
    ssoSociety: begin
      if (SportSociety= nil) and (AShooter.SportSociety<> nil) then
        Result:= -1
      else if (SportSociety<> nil) and (AShooter.SportSociety= nil) then
        Result:= -1
      else if (SportSociety= nil) and (AShooter.SportSociety= nil) then
        Result:= -AnsiCompareText (SportClub,AShooter.SportClub)
      else
        Result:= -AnsiCompareText (SportSociety.Name,AShooter.SportSociety.Name);
    end;
  else
    Result:= 0;
  end;
end;

constructor TShooterItem.Create(ACollection: TCollection);
begin
  inherited;
  fResults:= TResults.Create (self);
  CreateGUID (fID);
  SetLength (fImages,0);
  _changed:= false;
  fLastChange:= Now;
  fChanging:= 0;
  Shooters.fChanged:= true;
  fMarked:= 0;
end;

function TShooterItem.CSVStr: string;
begin
  Result:= StrToCSV (ISSFID)+','+StrToCSV (Surname)+','+StrToCSV (Name)+','+StrToCSV (StepName)+','+
    StrToCSV (BirthYearStr)+','+StrToCSV (BirthDateStr)+','+
    StrToCSV (RegionAbbr1)+','+StrToCSV (RegionAbbr2)+','+StrToCSV (DistrictAbbr)+','+
    StrToCSV (SocietyName)+','+StrToCSV (SportClub)+','+
    StrToCSV (Town)+','+StrToCSV (QualificationName)+','+StrToCSV (Address)+','+
    StrToCSV (Phone)+','+StrToCSV (Passport)+','+StrToCSV (Coaches)+','+
    StrToCSV (Weapons)+','+StrToCSV (Memo);
end;

function TShooterItem.CSVStr1: string;
begin
  Result:=
    StrToCSV (ISSFID)+CSVDelimiter+
    IntToStr (Group.Index+1)+CSVDelimiter+
    StrToCSV (SurnameAndNameAndStepName)+CSVDelimiter+
    StrToCSV (BirthDateStr)+CSVDelimiter+StrToCSV (BirthYearStr)+CSVDelimiter;
  if fGender= Female then
    Result:= Result+'1'+CSVDelimiter
  else
    Result:= Result+'0'+CSVDelimiter;
  if fQualification<> nil then
    Result:= Result+IntToStr (fQualification.Index+1)+CSVDelimiter
  else
    Result:= Result+'0'+CSVDelimiter;
  Result:= Result+StrToCSV (RegionAbbr1)+CSVDelimiter+
    StrToCSV (Town)+CSVDelimiter+
    StrToCSV (SocietyName)+CSVDelimiter+
    StrToCSV (SportClub)+CSVDelimiter;
  if ImagesCount> 0 then
    Result:= Result+StrToCSV (Images [0]);
end;

procedure TShooterItem.DeleteImage (index: integer);
var
  i: integer;
begin
  if (index>= 0) and (index< Length (fImages)) then
    begin
      for i:= index to Length (fImages)-2 do
        fImages [i]:= fImages [i+1];
      fImages [Length (fImages)-1]:= '';
      SetLength (fImages,Length (fImages)-1);
      Changed;
    end;
end;

procedure TShooterItem.DeleteResults(AEvent: TEventItem);
begin
  fResults.DeleteResults (AEvent);
end;

procedure TShooterItem.DeleteResults(AChampionship: TChampionshipItem);
begin
  fResults.DeleteResults (AChampionship);
end;

destructor TShooterItem.Destroy;
var
  i: integer;
begin
  for i:= 0 to Length (fImages)-1 do
    fImages [i]:= '';
  SetLength (fImages,0);
  fImages:= nil;
  fResults.Free;
  Shooters.fChanged:= true;
  inherited;
end;

procedure TShooterItem.EndChange;
begin
  if fChanging> 0 then
    dec (fChanging);
  if fChanging= 0 then
    begin
      _changed:= true;
      fLastChange:= Now;
    end;
end;

{function TShooterItem.Fields(index: string): string;
begin
  if AnsiSameText (index,'SURNAME') then
    Result:= Trim (fSurname)
  else if AnsiSameText (index,'NAME') then
    Result:= Trim (fName)
  else if AnsiSameText (index,'STEPNAME') then
    Result:= Trim (fStepName)
  else if AnsiSameText (index,'ISSFID') then
    Result:= Trim (fISSFID)
  else if AnsiSameText (index,'GENDER') then
    begin
      // TODO: �������� ����� �� ������ ������ ?
      case fGender of
        Male: Result:= '�������';
        Female: Result:= '�������';
      end;
    end
  else if AnsiSameText (index,'DATE') then
    Result:= DateToStr (fBirthDate)
  else if AnsiSameText (index,'YEAR') then
    Result:= IntToStr (YearOf (fBirthDate))
  else if AnsiSameText (index,'REGA1') then
    Result:= Trim (fRegionAbbr1)
  else if AnsiSameText (index,'REG1') then
    Result:= Trim (fRegionFull1)
  else if AnsiSameText (index,'REGA2') then
    Result:= Trim (fRegionAbbr2)
  else if AnsiSameText (index,'REG2') then
    Result:= Trim (fRegionFull2)
  else if AnsiSameText (index,'CLUB') then
    Result:= Trim (fClub)
  else if AnsiSameText (index,'TOWN') then
    Result:= Trim (fTown)
  else if AnsiSameText (index,'QUALIF') then
    Result:= QualificationName
  else if AnsiSameText (index,'ADDRESS') then
    Result:= Trim (fAddress)
  else if AnsiSameText (index,'PHONE') then
    Result:= Trim (fPhone)
  else if AnsiSameText (index,'PASSPORT') then
    Result:= Trim (fPassport)
  else if AnsiSameText (index,'COACHES') then
    Result:= Trim (fCoaches)
  else if AnsiSameText (index,'WEAPONS') then
    Result:= Trim (fWeapons)
  else if AnsiSameText (index,'REMARKS') then
    Result:= Trim (fMemo)
  else
    Result:= '������������ ���� "'+index+'"';
end;}

{procedure TShooterItem.GetImage(Image: TImage);
begin
  Data.Images.GetImage (fId,Image);
end;}

function TShooterItem.get_Data: TData;
begin
  Result:= (Collection as TShooters).Data;
end;

function TShooterItem.get_DistrictFull: string;
begin
  Result:= Data.Districts [fDistrictAbbr];
end;

function TShooterItem.get_Group: TGroupItem;
begin
  Result:= (Collection as TShooters).Group;
end;

function TShooterItem.get_Images(index: integer): string;
begin
  if (index>= 0) and (index< Length (fImages)) then
    Result:= fImages [index]
  else
    Result:= '';
end;

function TShooterItem.get_RegionFull1: string;
begin
  Result:= Data.Regions [fRegionAbbr1];
end;

function TShooterItem.get_RegionFull2: string;
begin
  Result:= Data.Regions [fRegionAbbr2];
end;

function TShooterItem.get_TotalRating(AEvent: TEventItem): integer;
begin
  Result:= fResults.TotalRating (AEvent);
end;

function TShooterItem.ImagesCount: integer;
begin
  Result:= Length (fImages);
end;

procedure TShooterItem.MergeWith(AShooter: TShooterItem);
//var
//  i,j: integer;
//  found: boolean;
begin
  if AShooter.fLastChange> fLastChange then
    AShooter.Assign (AShooter);
{  if fISSFID= '' then
    fISSFID:= AShooter.fISSFID;
  if fSurname= '' then
    fSurname:= AShooter.fSurname;
  if fName= '' then
    fName:= AShooter.fName;
  if fStepName= '' then
    fStepName:= AShooter.StepName;
  if fBirthYear= 0 then
    fBirthYear:= AShooter.fBirthYear;
  if fBirthDay= 0 then
    fBirthDay:= AShooter.fBirthDay;
  if fBirthMonth= 0 then
    fBirthMonth:= AShooter.fBirthMonth;
  if fRegionAbbr1= '' then
    fRegionAbbr1:= AShooter.fRegionAbbr1;
  if fRegionAbbr2= '' then
    fRegionAbbr2:= AShooter.fRegionAbbr2;
  if fDistrictAbbr= '' then
    fDistrictAbbr:= AShooter.fDistrictAbbr;
  if fSociety= nil then
    fSociety:= AShooter.fSociety;
  if fSportClub= '' then
    fSportClub:= AShooter.fSportClub;
  if fTown= '' then
    fTown:= AShooter.fTown;
  if fQualification= nil then
    begin
      if AShooter.Data= Data then
        fQualification:= AShooter.fQualification
      else
        fQualification:= Data.Qualifications.FindByName (AShooter.QualificationName);
    end;
  if fAddress= '' then
    fAddress:= AShooter.fAddress;
  if fPhone= '' then
    fPhone:= AShooter.fPhone;
  if Passport= '' then
    fPassport:= AShooter.fPassport;
  if fCoaches= '' then
    fCoaches:= AShooter.fCoaches;
  if fMemo= '' then
    fMemo:= AShooter.fMemo;
  for i:= 0 to Length (AShooter.fImages)-1 do
    begin
      found:= false;
      for j:= 0 to Length (fImages)-1 do
        if AnsiSameText (fImages [j],AShooter.fImages [i]) then
          begin
            found:= true;
            break;
          end;
      if not found then
        begin
          j:= Length (fImages);
          SetLength (fImages,j+1);
          fImages [j]:= AShooter.fImages [i];
        end;
    end;
  Changed;}
end;

procedure TShooterItem.MoveToGroup(AGroup: TGroupItem);
begin
  if (AGroup<> nil) and (AGroup<> Group) then
    begin
      if AGroup.Data= Data then  // ����������� ���������� ������ ����� ������
        begin
          Shooters.fChanged:= true;
          Collection:= nil;
          Collection:= AGroup.fShooters;
          Shooters.fChanged:= true;
        end;
    end;
end;

function TShooterItem.NameXLit: string;
begin
  Result:= XLit (Name);
end;

function TShooterItem.QualificationName: string;
begin
  if fQualification<> nil then
    Result:= fQualification.Name
  else
    Result:= '';
end;

procedure TShooterItem.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  dt: TDateTime;
  b: byte;
  del: boolean;
  s: string;
  soc_idx: integer;
  soc_str: string;
begin
  Stream.Read (fId,sizeof (fId));
  if Data.fFileVersion<= 11 then
    Stream.Read (del,sizeof (del))
  else
    del:= false;
  ReadStrFromStreamA (Stream,fISSFID);
  ReadStrFromStreamA (Stream,fSurname);
  fSurname:= NormalizeShooterSurname(fSurname);
  ReadStrFromStreamA (Stream,fName);
  ReadStrFromStreamA (Stream,fStepName);
  Stream.Read (fGender,sizeof (fGender));
  if Data.fFileVersion>= 3 then
    begin
      Stream.Read (fBirthYear,sizeof (fBirthYear));
      Stream.Read (fBirthMonth,sizeof (fBirthMonth));
      Stream.Read (fBirthDay,sizeof (fBirthDay));
    end
  else
    begin
      Stream.Read (dt,sizeof (dt));
      fBirthYear:= YearOf (dt);
      fBirthDay:= DayOf (dt);
      fBirthMonth:= MonthOf (dt);
    end;
  ReadStrFromStreamA (Stream,fRegionAbbr1);
  if Data.fFileVersion< 16 then
    begin
      ReadStrFromStreamA (Stream,s);
      if (fRegionAbbr1<> '') and (s<> '') then
        Data.Regions [fRegionAbbr1]:= s;
    end;
  ReadStrFromStreamA (Stream,fRegionAbbr2);
  if Data.fFileVersion< 16 then
    begin
      ReadStrFromStreamA (Stream,s);
      if (fRegionAbbr2<> '') and (s<> '') then
        Data.Regions [fRegionAbbr2]:= s;
    end;
  if Data.fFileVersion>= 2 then
    begin
      ReadStrFromStreamA (Stream,fDistrictAbbr);
      if Data.fFileVersion< 16 then
        begin
          ReadStrFromStreamA (Stream,s);
          if (fDistrictAbbr<> '') and (s<> '') then
            Data.Districts [fDistrictAbbr]:= s;
        end;
    end
  else
    begin
      fDistrictAbbr:= '';
//      fDistrictFull:= '';
    end;
  if Data.fFileVersion>= 20 then
    begin
      Stream.Read (soc_idx,sizeof (soc_idx));
      if soc_idx>= 0 then
        fSociety:= Data.Societies.Items [soc_idx]
      else
        fSociety:= nil;
      ReadStrFromStreamA (Stream,fSportClub);
    end
  else
    begin
      if Data.fFileVersion>= 17 then
        ReadStrFromStreamA (Stream,soc_str);
      ReadStrFromStreamA (Stream,fSportClub);
      if Data.fFileVersion< 17 then
        begin
          soc_str:= fSportClub;
          fSportClub:= '';
        end;
      if soc_str= '' then
        fSociety:= nil
      else
        begin
          fSociety:= Data.Societies.Find (soc_str);
          if fSociety= nil then
            begin
              fSociety:= Data.Societies.Add;
              fSociety.Name:= soc_str;
            end;
        end;
    end;
  ReadStrFromStreamA (Stream,fTown);
  if Data.fFileVersion<= 6 then
    begin
      Stream.Read (b,sizeof (b));
      if b> 0 then
        fQualification:= Data.Qualifications.Items [b-1]
      else
        fQualification:= nil;
    end
  else
    begin
      Stream.Read (i,sizeof (i));
      if i>= 0 then
        fQualification:= Data.Qualifications.Items [i]
      else
        fQualification:= nil;
    end;
  ReadStrFromStreamA (Stream,fAddress);
  ReadStrFromStreamA (Stream,fPhone);
  ReadStrFromStreamA (Stream,fPassport);
  ReadStrFromStreamA (Stream,fCoaches);
  ReadStrFromStreamA (Stream,fWeapons);
  ReadStrFromStreamA (Stream,fMemo);
  Stream.Read (c,sizeof (c));
  SetLength (fImages,c);
  for i:= 0 to c-1 do
    ReadStrFromStreamA (Stream,fImages [i]);
  if Data.fFileVersion>= 40 then
    Stream.Read (fLastChange,sizeof (fLastChange));
  fResults.ReadFromStream (Stream);
  _changed:= false;
  Shooters.fChanged:= true;
end;

function TShooterItem.RegionAbbr1XLit: string;
begin
  Result:= XLit (RegionAbbr1);
end;

function TShooterItem.RegionsAbbr: string;
begin
  if (fRegionAbbr1<> '') and (fRegionAbbr2<> '') then
    Result:= fRegionAbbr1+'-'+fRegionAbbr2
  else if (fRegionAbbr1<> '') then
    Result:= fRegionAbbr1
  else if (fRegionAbbr2<> '') then
    Result:= fRegionAbbr2
  else
    Result:= '';
end;

procedure TShooterItem.ResetRatings;
begin
  fResults.ResetRatings;
end;

procedure TShooterItem.set_Image(index: integer; const Value: string);
begin
  if (index>= 0) and (index< Length (fImages)) then
    fImages [index]:= Value
  else
    AddImage (Value);
  Changed;
end;

function TShooterItem.SurnameAndName (Separator: string= ','): string;
begin
  if fName<> '' then
    Result:= NormalizeShooterSurname(fSurname)+Separator+' '+fName
  else
    Result:= NormalizeShooterSurname(fSurname);
end;

function TShooterItem.SurnameAndNameAndStepName: string;
begin
  Result:= NormalizeShooterSurname(fSurname);
  if fName<> '' then
    Result:= Result+' '+fName;
  if fStepName<> '' then
    Result:= Result+' '+fStepName;
end;

function TShooterItem.SurnameAndNameXLit(Separator: string): string;
begin
  if fName<> '' then
    Result:= SurnameXLit+Separator+' '+NameXLit
  else
    Result:= SurnameXLit;
end;

function TShooterItem.SurnameXLit: string;
begin
  Result:= Xlit (Surname);
end;

procedure TShooterItem.WriteToStream(Stream: TStream; SavePersonalInfo: boolean= true);
var
  c,i: integer;
  dt: TDateTime;
  mm,dd: integer;
  soc_idx: integer;
begin
  Stream.Write (fId,sizeof (fId));
//  Stream.Write (fDeleted,sizeof (fDeleted));
  SaveStrToStreamA (Stream,fISSFID);
  SaveStrToStreamA (Stream,fSurname);
  SaveStrToStreamA (Stream,fName);
  SaveStrToStreamA (Stream,fStepName);
  Stream.Write (fGender,sizeof (fGender));
  if Data.fFileVersion>= 3 then
    begin
      Stream.Write (fBirthYear,sizeof (fBirthYear));
      Stream.Write (fBirthMonth,sizeof (fBirthMonth));
      Stream.Write (fBirthDay,sizeof (fBirthDay));
    end
  else
    begin
      mm:= fBirthMonth;
      dd:= fBirthDay;
      if mm= 0 then
        mm:= 1;
      if dd= 0 then
        dd:= 1;
      dt:= EncodeDate (fBirthYear,mm,dd);
      Stream.Write (dt,sizeof (dt));
    end;
  SaveStrToStreamA (Stream,fRegionAbbr1);
//  SaveStrToStream (Stream,fRegionFull1);
  SaveStrToStreamA (Stream,fRegionAbbr2);
//  SaveStrToStream (Stream,fRegionFull2);
  SaveStrToStreamA (Stream,fDistrictAbbr);
//  SaveStrToStream (Stream,fDistrictFull);
//  SaveStrToStream (Stream,fSociety);
  if fSociety<> nil then
    soc_idx:= fSociety.Index
  else
    soc_idx:= -1;
  Stream.Write (soc_idx,sizeof (soc_idx));
  SaveStrToStreamA (Stream,fSportClub);
  SaveStrToStreamA (Stream,fTown);
  if fQualification= nil then
    i:= -1
  else
    i:= fQualification.Index;
  Stream.Write (i,sizeof (i));
  if SavePersonalInfo then
    SaveStrToStreamA (Stream,fAddress)
  else
    SaveStrToStreamA (Stream,'');
  if SavePersonalInfo then
    SaveStrToStreamA (Stream,fPhone)
  else
    SaveStrToStreamA (Stream,'');
  if SavePersonalInfo then
    SaveStrToStreamA (Stream,fPassport)
  else
    SaveStrToStreamA (Stream,'');
  SaveStrToStreamA (Stream,fCoaches);
  if SavePersonalInfo then
    SaveStrToStreamA (Stream,fWeapons)
  else
    SaveStrToStreamA (Stream,'');
  if SavePersonalInfo then
    SaveStrToStreamA (Stream,fMemo)
  else
    SaveStrToStreamA (Stream,'');
  c:= Length (fImages);
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    SaveStrToStreamA (Stream,fImages [i]);
  Stream.Write (fLastChange,sizeof (fLastChange));
  fResults.WriteToStream (Stream);
  _changed:= false;
end;

procedure TShooterItem.set_BirthYearStr(const Value: string);
var
  y,i: integer;
begin
  val (Value,y,i);
  BirthYear:= y;
end;

procedure TShooterItem.set_BirthDateStr(const Value: string);
var
  s: string;
  i: integer;
  m,d: integer;
begin
  s:= Trim (Value);
  val (substr (s,'.',1),d,i);
  val (substr (s,'.',2),m,i);
  if (d<> fBirthDay) or (m<> fBirthMonth) then
    begin
      fBirthDay:= d;
      fBirthMonth:= m;
      Changed;
    end;
end;

function TShooterItem.get_BirthDateStr: string;
begin
  if (fBirthDay= 0) or (fBirthMonth= 0) then
    Result:= ''
  else
    Result:= LeftFillStr (inttostr (fBirthday),2,'0')+'.'+LeftFillStr (inttostr (fBirthMonth),2,'0');
end;

function TShooterItem.get_BirthFullStr: string;
var
  y: word;
begin
  y := fBirthYear;
  if (fBirthDay>0) and (fBirthMonth>0) and (y>0) then
    Result := LeftFillStr(IntToStr(fBirthDay),2,'0')+'.'+LeftFillStr(IntToStr(fBirthMonth),2,'0')+'.'+LeftFillStr(IntToStr(y),4,'0')
  else if y>0 then
    Result := LeftFillStr(IntToStr(y),4,'0')
  else
    Result := '';
end;

procedure TShooterItem.set_BirthFullStr(const Value: string);
  function NormalizeYear(yy: integer): word;
  begin
    if yy<=0 then
      Exit(0);
    if yy<100 then
    begin
      if yy<=30 then
        Result := 2000+yy
      else
        Result := 1900+yy;
    end
    else
      Result := yy;
  end;
var
  s: string;
  d,m,y,code: integer;
  valid: boolean;
begin
  s := Trim(Value);
  if s='' then
  begin
    if (fBirthYear<>0) or (fBirthMonth<>0) or (fBirthDay<>0) then
    begin
      fBirthYear := 0;
      fBirthMonth := 0;
      fBirthDay := 0;
      Changed;
    end;
    Exit;
  end;

  if Pos('.', s) > 0 then
  begin
    val(substr(s, '.', 1), d, code);
    if code<>0 then d := 0;
    val(substr(s, '.', 2), m, code);
    if code<>0 then m := 0;
    val(substr(s, '.', 3), y, code);
    if code<>0 then y := 0;
  end
  else if Length(s) in [4,6,8] then
  begin
    if Length(s)=4 then
    begin
      val(s, y, code);
      d := 0; m := 0;
    end
    else if Length(s)=6 then
    begin
      val(Copy(s,1,2), d, code); if code<>0 then d := 0;
      val(Copy(s,3,2), m, code); if code<>0 then m := 0;
      val(Copy(s,5,2), y, code); if code<>0 then y := 0;
    end
    else // 8
    begin
      val(Copy(s,1,2), d, code); if code<>0 then d := 0;
      val(Copy(s,3,2), m, code); if code<>0 then m := 0;
      val(Copy(s,5,4), y, code); if code<>0 then y := 0;
    end;
  end
  else
  begin
    val(s, y, code);
    d := 0; m := 0;
  end;

  y := NormalizeYear(y);
  if (m<1) or (m>12) then m := 0;
  if (d<1) or (d>31) then d := 0;

  // ������� �������� ���������� ���/������ (��������, 31.02 �����������)
  valid := true;
  if (d>0) and (m>0) then
  begin
    // ���� ��� �� ������, ��������� 2000 ��� ��������, �.�. ������������ ���� �����
    if y=0 then y := 2000;
    try
      EncodeDate(y, m, d);
    except
      on E: EConvertError do valid := false;
      on E: ERangeError do valid := false;
    end;
    if not valid then
    begin
      d := 0;
      m := 0;
      // ���� ��� ��� ����������, �� ��������� ��� ��� 2000
      if (fBirthYear=0) and (Value<>'') and (Length(Value)<>4) then
        y := 0;
    end;
  end;

  if (fBirthYear<>y) or (fBirthMonth<>m) or (fBirthDay<>d) then
  begin
    fBirthYear := y;
    fBirthMonth := m;
    fBirthDay := d;
    Changed;
  end;
end;

procedure TShooterItem.Assign(Source: TPersistent);
var
  sh: TShooterItem;
  i: integer;
begin
  if Source is TShooterItem then
    begin
      sh:= Source as TShooterItem;
      BeginChange;
      try
        //fDeleted:= sh.fDeleted;
        ISSFID:= sh.fISSFID;
        Surname:= sh.fSurname;
        Name:= sh.fName;
        StepName:= sh.fStepName;
        Gender:= sh.fGender;
        fBirthYear:= sh.fBirthYear;
        fBirthDay:= sh.fBirthDay;
        fBirthMonth:= sh.fBirthMonth;
        RegionAbbr1:= sh.fRegionAbbr1;
        //fRegionFull1:= sh.fRegionFull1;
        RegionAbbr2:= sh.fRegionAbbr2;
        //fRegionFull2:= sh.fRegionFull2;
        DistrictAbbr:= sh.fDistrictAbbr;
        //fDistrictFull:= sh.fDistrictFull;
        fSociety:= sh.fSociety;
        SportClub:= sh.fSportClub;
        Town:= sh.fTown;
        if sh.Data= Data then
          Qualification:= sh.Qualification
        else
          begin
            if sh.Qualification= nil then
              Qualification:= nil
            else
              Qualification:= Data.Qualifications.FindByName (sh.QualificationName);
          end;
        Address:= sh.fAddress;
        Phone:= sh.fPhone;
        Passport:= sh.fPassport;
        Coaches:= sh.fCoaches;
        Weapons:= sh.fWeapons;
        Memo:= sh.fMemo;
        SetLength (fImages,Length (sh.fImages));
        for i:= 0 to Length (sh.fImages)-1 do
          fImages [i]:= sh.fImages [i];
      finally
        EndChange;
      end;
    end;
end;

procedure TShooterItem.BeginChange;
begin
  inc (fChanging);
end;

function TShooterItem.Shooters: TShooters;
begin
  Result:= Collection as TShooters;
end;

function TShooterItem.SocietyAndClub: string;
begin
  if fSociety<> nil then
    begin
      if fSportClub<> '' then
        Result:= fSociety.Name+' '+fSportClub
      else
        Result:= fSociety.Name;
    end
  else
    Result:= fSportClub;
end;

function TShooterItem.SocietyName: string;
begin
  if fSociety<> nil then
    Result:= fSociety.Name
  else
    Result:= '';
end;

procedure TShooterItem.StripPersonalInfo;
begin
  fAddress:= '';
  fPhone:= '';
  fPassport:= '';
  fMemo:= '';
end;

function TShooterItem.NormalizeSurname: boolean;
var
  Normalized: string;
begin
  Normalized := NormalizeShooterSurname(fSurname);
  Result := Normalized <> fSurname;
  if Result then
    begin
      fSurname := Normalized;
      Changed;
    end;
end;

procedure TShooterItem.set_Surname(const Value: string);
var
  Normalized: string;
begin
  Normalized := NormalizeShooterSurname(Value);
  if Normalized<> fSurname then
    begin
      fSurname := Normalized;
      Changed;
    end;
end;

procedure TShooterItem.set_ISSFID(const Value: string);
begin
  if Value<> fISSFID then
    begin
      fISSFID:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Name(const Value: string);
begin
  if Value<> fName then
    begin
      fName:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Society(const Value: TSportSocietyItem);
begin
  if Value<> fSociety then
    begin
      fSociety:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_StepName(const Value: string);
begin
  if Value<> fStepName then
    begin
      fStepName:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Gender(const Value: TGender);
begin
  if Value<> fGender then
    begin
      fGender:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_RegionAbbr1(const Value: string);
begin
  if Value<> fRegionAbbr1 then
    begin
      fRegionAbbr1:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_RegionAbbr2(const Value: string);
begin
  if Value<> fRegionAbbr2 then
    begin
      fRegionAbbr2:= Value;
      Changed;
    end;
end;

{procedure TShooterItem.set_RegionFull1(const Value: string);
begin
  if Value<> fRegionFull1 then
    begin:= true;
      fRegionFull1:= Value;
    end;
end;}

{procedure TShooterItem.set_RegionFull2(const Value: string);
begin
  if Value<> fRegionFull2 then
    begin
      fChanged:= true;
      fRegionFull2:= Value;
    end;
end;}

procedure TShooterItem.set_Club(const Value: string);
begin
  if Value<> fSportClub then
    begin
      fSportClub:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Town(const Value: string);
begin
  if Value<> fTown then
    begin
      fTown:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Qualification(const Value: TQualificationItem);
begin
  if Value<> fQualification then
    begin
      fQualification:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Address(const Value: string);
begin
  if Value<> fAddress then
    begin
      fAddress:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_BirthYear(const Value: word);
begin
  if Value<> fBirthYear then
    begin
      fBirthYear:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Coaches(const Value: string);
begin
  if Value<> fCoaches then
    begin
      fCoaches:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_DistrictAbbr(const Value: string);
begin
  if Value<> fDistrictAbbr then
    begin
      fDistrictAbbr:= Value;
      Changed;
    end;
end;

{procedure TShooterItem.set_DistrictFull(const Value: string);
begin
  if Value<> fDistrictFull then
    begin
      fChanged:= true;
      fDistrictFull:= Value;
    end;
end;}

procedure TShooterItem.set_Marked(const Value: integer);
begin
  if Value<> fMarked then
    begin
      fMarked:= Value;
    end;
end;

procedure TShooterItem.set_Memo(const Value: string);
begin
  if Value<> fMemo then
    begin
      fMemo:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Passport(const Value: string);
begin
  if Value<> fPassport then
    begin
      fPassport:= Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Phone(const Value: string);
begin
  if Value<> fPhone then
    begin
      fPhone := Value;
      Changed;
    end;
end;

procedure TShooterItem.set_Weapons(const Value: string);
begin
  if Value<> fWeapons then
    begin
      fWeapons:= Value;
      Changed;
    end;
end;

function TShooterItem.get_WasChanged: boolean;
begin
  Result:= _changed or
    Results.WasChanged;
end;

{ TShooters }

function TShooters.Add: TShooterItem;
begin
  Result:= inherited Add as TShooterItem;
end;

procedure TShooters.Check;
var
  i: integer;
begin
  // TODO: �������� �������� � ������
  for i:= 0 to Count-1 do
    Items [i].Check;
end;

constructor TShooters.Create (AGroup: TGroupItem);
begin
  inherited Create (TShooterItem);
  fGroup:= AGroup;
  fChanged:= false;
end;

procedure TShooters.DeleteResults(AEvent: TEventItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].DeleteResults (AEvent);
end;

procedure TShooters.DeleteResults(AChampionship: TChampionshipItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].DeleteResults (AChampionship);
end;

procedure TShooters.DeleteSociety(ASociety: TSportSocietyItem);
var
  i: integer;
  sh: TShooterItem;
begin
  if ASociety= nil then
    exit;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.SportSociety= ASociety then
        sh.SportSociety:= nil;
    end;
end;

function TShooters.FindDuplicate(AShooter: TShooterItem): TShooterItem;
var
  i: integer;
  sh: TShooterItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if (AShooter.Surname= '') or (AnsiSameText (sh.Surname,AShooter.Surname)) then
        if (AShooter.Name= '') or (AnsiSameText (sh.Name,AShooter.Name)) then
          if (AShooter.BirthYearStr= '') or (sh.BirthYearStr= AShooter.BirthYearStr) then
            if (AShooter<> sh) then
              begin
                Result:= sh;
                break;
              end;
    end;
end;

function TShooters.FindShooter(const ID: TGUID): TShooterItem;
var
  j: integer;
begin
  Result:= nil;
  for j:= 0 to Count-1 do
    if IsEqualGUID (Items [j].fId, ID) then
      begin
        Result:= Items [j];
        exit;
      end;
end;

function TShooters.FindShooterByDetail(const ASurname,
  AName,ABirthYear: string): TShooterItem;
var
  i: integer;
  sh: TShooterItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if (AnsiCompareText (sh.Surname,ASurname)= 0) and (AnsiCompareText (sh.Name,AName)= 0) and
         (sh.BirthYearStr= ABirthYear) then
        begin
          Result:= sh;
          break;
        end;
    end;
end;

function TShooters.get_Data: TData;
begin
  Result:= fGroup.Data;
end;

function TShooters.get_Shooter(index: integer): TShooterItem;
begin
  if (index>= 0) and (index< Count) then
    Result:= inherited Items [index] as TShooterItem
  else
    Result:= nil;
end;

function TShooters.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

function TShooters.InSociety(ASociety: TSportSocietyItem): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    begin
      if Items [i].SportSociety= ASociety then
        inc (Result);
    end;
end;

procedure TShooters.MergeWith(AShooters: TShooters);
var
  i: integer;
  sh,ash: TShooterItem;
begin
  for i:= 0 to AShooters.Count-1 do
    begin
      ash:= AShooters.Items [i];
      sh:= FindShooter (ash.fId);
      if sh= nil then
        sh:= Data.Groups.FindShooterByDetails (ash.fSurname,ash.fName,ash.BirthYearStr);
      if sh= nil then
        begin
          sh:= Add;
          sh.fId:= ash.fId;
        end;
      sh.MergeWith (ash);
      sh.Results.MergeWith (ash.Results);
    end;
end;

procedure TShooters.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  sh: TShooterItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      sh:= Add;
      sh.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TShooters.ResetRatings;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].ResetRatings;
end;

procedure TShooters.WriteToStream(Stream: TStream; SavePersonalInfo: boolean= true);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream,SavePersonalInfo);
  fChanged:= false;
end;

{ TGroupItem }

function TGroupItem.AddPrefered(AEvent: TEventItem): integer;
begin
  Result:= -1;
  if Prefered (AEvent)>= 0 then
    exit;
  Result:= Length (fPreferedEvents);
  SetLength (fPreferedEvents,Result+1);
  fPreferedEvents [Result]:= AEvent;
  fChanged:= true;
end;

procedure TGroupItem.Check;
begin
  fShooters.Check;
end;

constructor TGroupItem.Create(ACollection: TCollection);
begin
  inherited;
  CreateGUID (fGID);
  fShooters:= TShooters.Create (self);
  fChanged:= false;
  SetLength (fPreferedEvents,0);
  Groups.fChanged:= true;
end;

function TGroupItem.CSVStr: string;
begin
  Result:= IntToStr (Index+1)+CSVDelimiter+StrToCSV (fName);
end;

procedure TGroupItem.DeleteResults(AEvent: TEventItem);
begin
  fShooters.DeleteResults (AEvent);
end;

function TGroupItem.DefaultGender: TGender;
var
  s: array [TGender] of Integer;
  i: integer;
  r: double;
begin
  s [Male]:= 0;
  s [Female]:= 0;
  for i:= 0 to Shooters.Count-1 do
    inc (s [Shooters.Items [i].Gender]);
  if Shooters.Count> 0 then
    begin
      r:= s [Male]/Shooters.Count;
      if r>= 0.5 then
        Result:= Male
      else
        Result:= Female;
    end
  else
    Result:= Male;
end;

procedure TGroupItem.DeletePrefered(Index: integer);
var
  i: integer;
begin
  if (Index< 0) or (Index>= Length (fPreferedEvents)) then
    exit;
  for i:= Index to Length (fPreferedEvents)-2 do
    fPreferedEvents [i]:= fPreferedEvents [i+1];
  SetLength (fPreferedEvents,Length (fPreferedEvents)-1);
  fChanged:= true;
end;

procedure TGroupItem.DeleteResults(AChampionship: TChampionshipItem);
begin
  fShooters.DeleteResults (AChampionship);
end;

destructor TGroupItem.Destroy;
begin
  fShooters.Free;
  Groups.fChanged:= true;
  SetLength (fPreferedEvents,0);
  fPreferedEvents:= nil;
  inherited;
end;

procedure TGroupItem.ExportToCSV;
var
  f1,f2: textfile;
  i,j: integer;
  sh: TShooterItem;
  s: string;
  g: TGUID;
  res: TResultItem;
begin
  AssignFile (f1,Data.fName+' - '+Name+'.CSV');
  AssignFile (f2,Data.fName+' - '+Name+' - ����������.CSV');
  Rewrite (f1);
  Rewrite (f2);
  for i:= 0 to Shooters.Count-1 do
    begin
      sh:= Shooters.Items [i];
      CreateGUID (g);
      s:= StrToCSV (GUIDToString (g))+','+sh.CSVStr;
      writeln (f1,s);
      for j:= 0 to sh.Results.Count-1 do
        begin
          res:= sh.Results.Items [j];
          s:= IntToStr (i)+','+StrToCSV (GUIDToString (g))+','+res.CSVStr;
          writeln (f2,s);
        end;
    end;
  CloseFile (f2);
  CloseFile (f1);
end;

function TGroupItem.get_Data: TData;
begin
  Result:= (Collection as TGroups).Data;
end;

function TGroupItem.get_PreferedEvent(Index: integer): TEventItem;
begin
  if (Index>= 0) and (Index< Length (fPreferedEvents)) then
    Result:= fPreferedEvents [Index]
  else
    Result:= nil;
end;

function TGroupItem.get_WasChanged: boolean;
begin
  Result:= fChanged or
    Shooters.WasChanged;
end;

function TGroupItem.Groups: TGroups;
begin
  Result:= Collection as TGroups;
end;

function TGroupItem.Prefered(AEvent: TEventItem): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to Length (fPreferedEvents)-1 do
    if fPreferedEvents [i]= AEvent then
      begin
        Result:= i;
        break;
      end;
end;

function TGroupItem.PreferedCount: integer;
begin
  Result:= Length (fPreferedEvents);
end;

procedure TGroupItem.ReadFromStream(Stream: TStream);
var
  //l: integer;
  c,i: integer;
  tag: string;
  e: TEventItem;
begin
  if Data.fFileVersion>= 21 then      // ���� ���� GUID, �� ������, ����� ������� �����
    Stream.Read (fGID,sizeof (fGID))
  else
    CreateGUID (fGID);
  SetLength (fPreferedEvents,0);
  ReadStrFromStreamA (Stream,fName);
  //Stream.Read (l,sizeof (l));
  //SetLength (fName,l);
  //Stream.Read (fName [1],l);
  if Data.fFileVersion>= 13 then
    begin
      Stream.Read (c,sizeof (c));
      for i:= 0 to c-1 do
        begin
          ReadStrFromStreamA (Stream,tag);
          e:= Data.Events [tag];
          if e<> nil then
            AddPrefered (e);
        end;
    end;
  fShooters.ReadFromStream (Stream);
  fChanged:= false;
  Groups.fChanged:= true;
  if Data.fFileVersion< 21 then      // ���� ������� GUID
    fChanged:= true;
end;

procedure TGroupItem.ResetRatings;
begin
  fShooters.ResetRatings;
end;

procedure TGroupItem.set_Name(const Value: string);
begin
  if Value<> fName then
    fChanged:= true;
  fName:= Value;
end;

procedure TGroupItem.set_PreferedEvent(Index: integer; const Value: TEventItem);
begin
  if (Index>= 0) and (Index< Length (fPreferedEvents)) then
    fPreferedEvents [Index]:= Value
  else
    AddPrefered (Value);
  fChanged:= true;
end;

procedure TGroupItem.WriteToStream(Stream: TStream; SavePersonalInfo: boolean= true);
var
  i,c: integer;
begin
  Stream.Write (fGID,sizeof (fGID));
  SaveStrToStreamA (Stream,fName);  // ���������� ���������� ������� ��� Unicode
  c:= Length (fPreferedEvents);
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    SaveStrToStreamA (Stream,fPreferedEvents [i].Tag);
  fShooters.WriteToStream (Stream,SavePersonalInfo);
  fChanged:= false;
end;

{ TGroups }

function TGroups.Add: TGroupItem;
begin
  Result:= inherited Add as TGroupItem;
end;

procedure TGroups.Check;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].Check;
end;

constructor TGroups.Create(AData: TData);
begin
  inherited Create (TGroupItem);
  fData:= AData;
  fChanged:= false;
end;

procedure TGroups.DeleteResults(AEvent: TEventItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].DeleteResults (AEvent);
end;

procedure TGroups.DeleteResults(AChampionship: TChampionshipItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].DeleteResults (AChampionship);
end;

procedure TGroups.DeleteSociety(ASociety: TSportSocietyItem);
var
  i: integer;
begin
  if ASociety= nil then
    exit;
  for i:= 0 to Count-1 do
    Items [i].Shooters.DeleteSociety (ASociety);
end;

procedure TGroups.ExportToCSV(const FName: TFileName);
var
  i: integer;
  s: TStrings;
begin
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'title');
  for i:= 0 to Count-1 do
    s.Add (Items [i].CSVStr);
  try
    s.SaveToFile (FName);
    s.Free;
  except
    s.Free;
    raise;
  end;
end;

function TGroups.FindByName(const AName: string): TGroupItem;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    if Items [i].fName= AName then
      begin
        Result:= Items [i];
        break;
      end;
end;

function TGroups.FindDuplicate(AShooter: TShooterItem): TShooterItem;
var
  i: integer;
  sh: TShooterItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i].Shooters.FindDuplicate (AShooter);
      if sh<> nil then
        begin
          Result:= sh;
          break;
        end;
    end;
end;

function TGroups.FindShooter(const ID: TGUID): TShooterItem;
var
  j: integer;
  sh: TShooterItem;
begin
  Result:= nil;
  for j:= 0 to Count-1 do
    begin
      sh:= Items [j].Shooters.FindShooter (ID);
      if sh<> nil then
        begin
          Result:= sh;
          exit;
        end;
    end;
end;

function TGroups.FindShooterByDetails(const ASurname,
  AName,ABirthYear: string): TShooterItem;
var
  i: integer;
  sh: TShooterItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i].Shooters.FindShooterByDetail (ASurname,AName,ABirthYear);
      if sh<> nil then
        begin
          Result:= sh;
          exit;
        end;
    end;
end;

function TGroups.get_Group(index: integer): TGroupItem;
begin
  if (index>= 0) and (index< Count) then
    Result:= inherited Items [index] as TGroupItem
  else
    Result:= nil;
end;

function TGroups.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

procedure TGroups.MergeWith(AGroups: TGroups);
var
  i: integer;
  g,ag: TGroupItem;
begin
  for i:= 0 to AGroups.Count-1 do
    begin
      ag:= AGroups.Items [i];
      g:= FindByName (ag.fName);
      if g= nil then
        begin
          g:= Add;
          g.fName:= ag.fName;
          g.fChanged:= true;
        end;
      g.Shooters.MergeWith (ag.Shooters);
    end;
end;

procedure TGroups.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  gr: TGroupItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      gr:= Add;
      gr.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TGroups.ResetRatings;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].ResetRatings;
end;

procedure TGroups.set_WasChanged(const Value: boolean);
begin
  fChanged:= Value;
end;

procedure TGroups.WriteToStream(Stream: TStream; SavePersonalInfo: boolean= true);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream,SavePersonalInfo);
  fChanged:= false;
end;

{ TData }

{procedure TData.Assign(Source: TData);
begin
  if Source= nil then
    exit;
  fName:= Source.fName;
  fId:= Source.fId;
  fChampionships.Assign (Source.Championships);
  fEvents.Assign (Source.Events);
  fQualifications.Assign (Source.Qualifications);
  fGroups.Assign (Source.Groups);
  fImagesFolder:= Source.fImagesFolder;
  fFileVersion:= Source.fFileVersion;
  fStartLists.Assign (Source.StartLists);
  fRegions.Assign (Source.Regions);
  fDistricts.Assign (Source.Districts);
end;}

{procedure TData.Assign(Source: TData);
begin
  fName:= Source.fName;
  fId:= Source.fId;
  fRegions.Assign (Source.Regions);
  fDistricts.Assign (Source.Districts);
  fEvents.Assign (Source.Events);
  fChampionships.Assign (Source.Championships);
  fQualifications.Assign (Source.Qualifications);
  fSocieties.Assign (Source.Societies);
  fShootingChampionships.Assign (Source.ShootingChampionships);
  fGroups.Assign (Source.Groups);
  fImagesFolder:= Source.ImagesFolder;
  fFileVersion:= Source.fFileVersion;
  fStartLists.Assign (Source.StartLists);
  fRatingDate:= Source.RatingDate;
end;}

procedure TData.Check;
begin
  SetLength (fDupeResults,0);
  fEvents.Check;
  fChampionships.Check;
  fQualifications.Check;
  fRegions.Check;
  fDistricts.Check;
  fSocieties.Check;
  fGroups.Check;
  fStartLists.Check;
end;

constructor TData.Create;
begin
  inherited;
  CreateGUID (fID);
  fName:= NEW_DATA_NAME;
  fChampionships:= TChampionships.Create (self);
  fEvents:= TEvents.Create (self);
  fQualifications:= TQualifications.Create (self);
  fRegions:= TAbbrNames.Create (self);
  fDistricts:= TAbbrNames.Create (self);
  fSocieties:= TSportSocieties.Create (self);
  fShootingChampionships:= TShootingChampionships.Create (self);
  fGroups:= TGroups.Create (self);
  fStartLists:= TStartLists.Create (self);
  fRatingDate:= 0;
  SetLength (fDupeResults,0);
  fChanged:= false;
end;

procedure TData.DeleteResults(AEvent: TEventItem);
begin
  fGroups.DeleteResults (AEvent);
end;

procedure TData.DeleteDupeResults;
var
  i: integer;
  r: TResultItem;
begin
  for i:= 0 to Length (fDupeResults)-1 do
    begin
      r:= fDupeResults [i].Dupe;
      r.Free;
    end;
  SetLength (fDupeResults,0);
end;

procedure TData.DeleteResults(AChampionship: TChampionshipItem);
begin
  fGroups.DeleteResults (AChampionship);
end;

destructor TData.Destroy;
begin
  fStartLists.Free;
  fGroups.Free;
  fShootingChampionships.Free;
  fQualifications.Free;
  fEvents.Free;
  fChampionships.Free;
  fRegions.Free;
  fDistricts.Free;
  SetLength (fDupeResults,0);
  fDupeResults:= nil;
  inherited;
end;

procedure TData.ExportToCSV (ConsoleOutput: boolean);
var
  i,j,k: integer;
  ch: TChampionshipItem;
  rev: TEventRatedPlaces;
  st: string;
  s: TStrings;
  ev: TEventItem;
  br: TEventBonus;
  br10: TEventBonus10;
  g: TGroupItem;
  sh: TShooterItem;
  sch: TShootingChampionshipItem;
  sev: TShootingEventItem;
  id: integer;
  rs: TStrings;
  res: TResultItem;
  sevs: array of TShootingEventItem;
  tr: TStrings;
  _rating: integer;

  function FindSEV (se: TShootingEventItem): integer;
  var
    i: integer;
  begin
    for i:= 0 to Length (sevs)-1 do
      if sevs [i]= se then
        begin
          Result:= i+1;
          exit;
        end;
    Result:= -1;
  end;

begin
  if ConsoleOutput then
    writeln ('wbexercises.csv');
  Events.ExportToCSV ('wbexercises.csv');
  if ConsoleOutput then
    writeln ('wbgames.csv');
  Championships.ExportToCSV ('wbgames.csv');
  if ConsoleOutput then
    writeln ('wbcontests.csv');
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'game'+CSVDelimiter+'gametitle'+CSVDelimiter+
    'exercise'+CSVDelimiter+'exercisename'+CSVDelimiter+'date'+
    CSVDelimiter+'country'+CSVDelimiter+'town');
  SetLength (sevs,0);
  id:= 0;
  for i:= 0 to ShootingChampionships.Count-1 do
    begin
      sch:= ShootingChampionships.Items [i];
      for j:= 0 to sch.Events.Count-1 do
        begin
          sev:= sch.Events.Items [j];
          SetLength (sevs,id+1);
          sevs [id]:= sev;
          inc (id);
          st:= IntToStr (id)+CSVDelimiter;
          if sch.fChampionship<> nil then
            st:= st+IntToStr (sch.Index+1)+CSVDelimiter+StrToCSV (sch.fChampionship.Name)+CSVDelimiter
          else
            st:= st+'0'+CSVDelimiter+StrToCSV (sch.fChampionshipName)+CSVDelimiter;
          if sev.fEvent<> nil then
            st:= st+IntToStr (sev.fEvent.Index+1)+CSVDelimiter+StrToCSV (sev.fEvent.ShortName)+CSVDelimiter
          else
            st:= st+'0'+CSVDelimiter+StrToCSV (sev.fShortName)+CSVDelimiter;
          st:= st+DateToStr (sev.fDate)+CSVDelimiter+
            StrToCSV (sev.Country)+CSVDelimiter+StrToCSV (sev.Town);
          s.Add (st);
        end;
    end;
  try
    s.SaveToFile ('wbcontests.csv');
    s.Free;
  except
    s.Free;
    raise;
  end;
  if ConsoleOutput then
    writeln ('wbskills.csv');
  Qualifications.ExportToCSV ('wbskills.csv');
  if ConsoleOutput then
    writeln ('wbscores.csv');
  s:= TStringList.Create;
  s.Add ('game'+CSVDelimiter+'exercise'+CSVDelimiter+'rank'+CSVDelimiter+'points');
  for i:= 0 to Championships.Count-1 do
    begin
      ch:= Championships.Items [i];
      for j:= 0 to Length (ch.fRatedEvents)-1 do
        begin
          rev:= ch.fRatedEvents [j];
          for k:= 0 to Length (rev.RatedPlaces)-1 do
            begin
              st:= IntToStr (ch.Index+1)+CSVDelimiter+IntToStr (j+1)+CSVDelimiter+
                IntToStr (k+1)+CSVDelimiter+IntToStr (rev.RatedPlaces[k]);
              s.Add (st);
            end;
        end;
    end;
  try
    s.SaveToFile ('wbscores.csv');
    s.Free;
  except
    s.Free;
    raise;
  end;
  if ConsoleOutput then
    writeln ('wbaddresult.csv');
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'competition'+CSVDelimiter+'points');
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events.Items [i];
      for j:= 0 to Length (ev.fBonusRatings)-1 do
        begin
          br:= ev.fBonusRatings [j];
          st:= IntToStr (ev.Index+1)+CSVDelimiter+
            IntToStr (br.fResult*10)+CSVDelimiter+
            IntToStr (br.fRating);
          s.Add (st);
        end;
    end;
  try
    s.SaveToFile ('wbaddresult.csv');
    s.Free;
  except
    s.Free;
    raise;
  end;
  if ConsoleOutput then
    writeln ('wbaddresult10.csv');
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'competition'+CSVDelimiter+'points');
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events.Items [i];
      for j:= 0 to Length (ev.fBonusRatings10)-1 do
        begin
          br10:= ev.fBonusRatings10 [j];
          st:= IntToStr (ev.Index+1)+CSVDelimiter+
            IntToStr (br10.fResult*10)+CSVDelimiter+
            IntToStr (br10.fRating);
          s.Add (st);
        end;
    end;
  try
    s.SaveToFile ('wbaddresult10.csv');
    s.Free;
  except
    s.Free;
    raise;
  end;
  if ConsoleOutput then
    writeln ('wbregions.csv');
  Regions.ExportToCSV ('wbregions.csv');
  if ConsoleOutput then
    writeln ('wbdistricts.csv');
  Districts.ExportToCSV ('wbdistricts.csv');
  if ConsoleOutput then
    writeln ('wbgroups.csv');
  Groups.ExportToCSV ('wbgroups.csv');
  if ConsoleOutput then
    writeln ('wbusers.csv');
  if ConsoleOutput then
    writeln ('wbresults.csv');
  if ConsoleOutput then
    writeln ('wbratings.csv');
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'issfid'+CSVDelimiter+'group'+CSVDelimiter+'name'+CSVDelimiter+
    'birthdate'+CSVDelimiter+'birthyear'+CSVDelimiter+'gender'+CSVDelimiter+
    'qualification'+CSVDelimiter+'region'+CSVDelimiter+
    'town'+CSVDelimiter+'society'+CSVDelimiter+'club'+CSVDelimiter+'image');
  rs:= TStringList.Create;
  rs.Add ('contest'+CSVDelimiter+'user'+CSVDelimiter+'rank'+CSVDelimiter+
    'competition'+CSVDelimiter+'final'+CSVDelimiter+'points');
  tr:= TStringList.Create;
  tr.Add ('athlete'+CSVDelimiter+'name'+CSVDelimiter+'exercise'+CSVDelimiter+'points');
  id:= 0;
  for i:= 0 to Groups.Count-1 do
    begin
      g:= Groups.Items [i];
      for j:= 0 to g.Shooters.Count-1 do
        begin
          sh:= g.Shooters.Items [j];
          inc (id);
          st:= IntToStr (id)+CSVDelimiter+sh.CSVStr1;
          s.Add (st);
          for k:= 0 to sh.Results.Count-1 do
            begin
              res:= sh.Results.Items [k];
              st:= IntToStr (FindSEV (res.fShEvent))+CSVDelimiter+
                IntToStr (id)+CSVDelimiter+
                IntToStr (res.Rank)+CSVDelimiter+
                IntToStr (res.Competition10)+CSVDelimiter+
                IntToStr (res.fFinal10)+CSVDelimiter+
                IntToStr (res.Rating);
              rs.Add (st);
            end;
          for k:= 0 to Events.Count-1 do
            begin
              ev:= Events.Items [k];
              _rating:= sh.TotalRating [ev];
              if _rating> 0 then
                begin
                  tr.Add (IntToStr (id)+CSVDelimiter+
                    StrToCSV (sh.SurnameAndNameAndStepName)+CSVDelimiter+
                    IntToStr (k+1)+CSVDelimiter+
                    IntToStr (_rating));
                end;
            end;
        end;
    end;
  try
    s.SaveToFile ('wbusers.csv');
    s.Free;
  except
    s.Free;
    raise;
  end;
  try
    rs.SaveToFile ('wbresults.csv');
    rs.Free;
  except
    rs.Free;
    raise;
  end;
  try
    tr.SaveToFile ('wbratings.csv');
    tr.Free;
  except
    tr.Free;
    raise;
  end;
  SetLength (sevs,0);
  sevs:= nil;
  if ConsoleOutput then
    writeln ('ok.');
end;

function TData.get_ActiveStart: TStartList;
begin
  Result:= StartLists.ActiveStart;
end;

function TData.get_RatingDate: TDateTime;
begin
  if fRatingDate> 0 then
    Result:= fRatingDate
  else
    Result:= Now;
end;

function TData.get_WasChanged: boolean;
begin
  Result:= fChanged or
    fChampionships.WasChanged or
    fEvents.WasChanged or
    fQualifications.WasChanged or
    fGroups.WasChanged or
    fStartLists.WasChanged or
    fRegions.WasChanged or
    fDistricts.WasChanged or
    fSocieties.WasChanged or
    fShootingChampionships.WasChanged;
end;

procedure TData.ImportFromFolder(AFolder: TFileName);
var
  df: file of TOldConfig;
  config: TOldConfig;
  tf: file of TOldFullTable;
  table: TOldFullTable;
  gf: file of toldgroupconfig;
  gc: toldgroupconfig;
  pf: file of toldperson;
  p: toldperson;
  rf: file of toldratingrecord;
  res: toldratingrecord;
  _ch: TChampionshipItem;
  _ev: TEventItem;
  _bonus: TEventBonus;
  _q: TQualificationItem;
  _gr: TGroupItem;
  _gender: TGender;
  _sh: TShooterItem;
  _res: TResultItem;
  i,j,k,n: integer;
  _results: array of toldratingrecord;
  b_year,b_month,b_day: word;
  _sch: TShootingChampionshipItem;
  _sev: TShootingEventItem;
  _date: TDateTime;
//  differs: boolean;
begin
  AFolder:= IncludeTrailingPathDelimiter (AFolder);

  AssignFile (df,AFolder+'base.dta');
  Reset (df);
  Read (df,config);
  CloseFile (df);

  AssignFile (tf,AFolder+'base.tbl');
  Reset (tf);
  Read (tf,table);
  CloseFile (tf);

  fChampionships.Clear;
  fEvents.Clear;
  fQualifications.Clear;
  fGroups.Clear;
  fChanged:= true;

  // events
  for i:= 1 to config.numberofevents do
    begin
      _ev:= Events.Add;
      _ev.Tag:= dos2win (config.events [i].abbr);
      _ev.ShortName:= _ev.Tag;
      _ev.Name:= dos2win (config.events [i].name);
      _ev.MQSResult10:= config.eventsconfig [i].mqsresult * 10;
      _ev.MinRatedResult10:= config.eventsconfig [i].minratingresult * 10;
      _ev.FinalFracs:= config.eventsconfig [i].realpart;
      _ev.FinalPlaces:= config.eventsconfig [i].finalplaces;
      _ev.FinalShots:= 10;   // �� ��������� 10 ��������� ���������
      _ev.Stages:= config.eventsconfig [i].groups;
      _ev.SeriesPerStage:= config.eventsconfig [i].series;
      for j:= 1 to oldmaxclassifications do
        if config.eventsconfig [i].classifications [j].classnumb<> 0 then
          begin
            // Fix for Delphi 12 - cannot use with on property getter
            var tempQualif := _ev.Qualifications10 [config.eventsconfig [i].classifications [j].classnumb];
            tempQualif.Competition10:= config.eventsconfig [i].classifications [j].result * 10;
            //tempQualif.Total10:= 0;
            tempQualif.CompetitionTens10:= 0;
            _ev.Qualifications10 [config.eventsconfig [i].classifications [j].classnumb] := tempQualif;
          end;
      for j:= 1 to oldmaxappresults do
        if table.events [i].appresults [j].result<> 0 then
          begin
            // Initialize record properly for Delphi 12 compatibility
            _bonus := Default(TEventBonus);
            _bonus.fResult:= table.events [i].appresults [j].result;
            _bonus.fRating:= table.events [i].appresults [j].rate;
            _ev.Bonuses [j]:= _bonus;
          end;
    end;

  // championshipos
  for i:= 1 to config.numberofcompetitions do
    begin
      _ch:= Championships.Add;
      _ch.Tag:= format ('CHMP%d',[i]);
      _ch.Name:= dos2win (config.competitions [i]);
      _ch.MQS:= config.mqscompetitions [i];
      // ������� �������� ��� ������
      SetLength (_ch.fRatedEvents,Events.Count);
{      for k:= 0 to Events.Count-1 do
        _ch.fRatedEvents [k].Event:= Events.Items [k];}
      for k:= 0 to Events.Count-1 do
        begin
          n:= 0;
          for j:= 1 to oldmaxrateplaces do
            if table.events [k+1].places [i] [j]> 0 then
              if j> n then
                n:= j;
          SetLength (_ch.fRatedEvents [k].RatedPlaces,n);
          for j:= 0 to n-1 do
            _ch.fRatedEvents [k].RatedPlaces [j]:= table.events [k+1].places [i] [j+1];
        end;
      _ch.RatingHold:= 1;
      _ch.Period:= table.trunctimes [i];
    end;

  // qualifications
  for i:= 0 to oldmaxclassifications do
    begin
      if config.classifications [i]<> '' then
        begin
          _q:= Qualifications.Add;
          _q.Name:= dos2win (config.classifications [i]);
          if _q.Name= '���' then
            _q.SetByResult:= false
          else
            _q.SetByResult:= true;
        end;
    end;

  {$i-}
  // data
  AssignFile (gf,AFolder+config.groupsconfigfile);
  Reset (gf);
  if IOResult= 0 then
    begin
      while not eof (gf) do
        begin
          Read (gf,gc);
          _gr:= Groups.Add;
          _gr.Name:= dos2win (gc.groupname);

          if pos ('����',ansiuppercase (_gr.name))> 0 then
            begin
              _gender:= female;
            end
          else
            begin
              _gender:= male;
            end;

          AssignFile (pf,AFolder+gc.datafile);
          Reset (pf);
          if IOResult<> 0 then
            continue;

          SetLength (_results,0);
          if gc.resultsavailable then
            begin
              {$i-}
              AssignFile (rf,AFolder+gc.ratefile);
              Reset (rf);
              if IOResult= 0 then
                begin
                  SetLength (_results,filesize (rf));
                  for i:= 0 to Length (_results)-1 do
                    Read (rf,_results [i]);
                  CloseFile (rf);
                end;
              {$i-}
            end;

          while not eof (pf) do
            begin
              Read (pf,p);
              _sh:= _gr.Shooters.Add;
//              _sh.Deleted:= false;
              _sh.ISSFID:= '';
              _sh.Surname:= dos2win (p.surname);
              _sh.Name:= dos2win (p.name);
              _sh.StepName:= '';
              _sh.Gender:= _gender;
              b_year:= p.birthyear;
              if b_year< 1900 then
                b_year:= 1900;
              j:= pos ('.',p.birthday);
              if j> 0 then
                begin
                  Val (copy (p.birthday,1,j-1),b_day,i);
                  if b_day< 1 then
                    b_day:= 1;
                  Val (copy (p.birthday,j+1,5),b_month,i);
                  if (b_month< 1) or (b_month> 12) then
                    b_month:= 1;
                  if (b_month< 1) or (b_month> 12) or (b_day< 1) or (b_day> 31) then
                    begin
                    end;
                end
              else
                begin
                  b_day:= 1;
                  b_month:= 1;
                end;
              _sh.fBirthYear:= b_year;
              _sh.fBirthMonth:= b_month;
              _sh.fBirthDay:= b_day;
              _sh.RegionAbbr1:= dos2win (p.countryabbr);
              if (_sh.RegionAbbr1<> '') and (p.country<> '') then
                Regions [_sh.RegionAbbr1]:= p.country;
//              _sh.RegionFull1:= dos2win (p.country);
              _sh.RegionAbbr2:= '';
//              _sh.RegionFull2:= '';
              _sh.DistrictAbbr:= '';
//              _sh.DistrictFull:= '';
//              _sh.Society:= dos2win (p.remarks);
              if p.remarks<> '' then
                begin
                  _sh.SportSociety:= _sh.Data.Societies.Find (dos2win (p.remarks));
                  if _sh.SportSociety= nil then
                    begin
                      _sh.SportSociety:= _sh.Data.Societies.Add;
                      _sh.SportSociety.Name:= dos2win (p.remarks);
                    end;
                end
              else
                _sh.SportSociety:= nil;
              _sh.SportClub:= '';
              _sh.Town:= dos2win (p.town);
              if p.qualification= 0 then
                _sh.Qualification:= nil
              else
                _sh.Qualification:= Qualifications.Items [p.qualification-1];
              _sh.Address:= dos2win (p.address);
              _sh.Phone:= dos2win (p.phone);
              _sh.Passport:= dos2win (p.passport);
              _sh.Coaches:= dos2win (p.coaches);
              _sh.Weapons:= dos2win (p.weapon);
              _sh.Memo:= dos2win (p.remarks);

              for i:= 0 to Length (_results)-1 do
                begin
                  res:= _results [i];
                  if res.number= p.number then
                    begin
                      try
                        _date:= EncodeDate (res.date.year,res.date.month,res.date.day);
                      except
                        _date:= EncodeDate (1980,1,1);
                      end;
                      _res:= _sh.Results.Add;
                      if res.compnum> 0 then
                        _ch:= Championships [format ('CHMP%d',[res.compnum])]
                      else
                        _ch:= nil;
                      _sch:= ShootingChampionships.Find (_ch,dos2win (res.competition),_date);
                      if _sch= nil then
                        begin
                          _sch:= ShootingChampionships.Add;
                          _sch.SetChampionship (_ch,dos2win (res.competition));
                        end;
                      _sch.Country:= res.region;
                      _sch.Town:= '';

                      if res.eventnum> 0 then
                        _ev:= Events [dos2win (config.events [gc.events [res.eventnum]].abbr)]
                      else
                        _ev:= nil;
                      _sev:= _sch.Events.Find (_ev,dos2win (res.event.abbr),_date);
                      if _sev= nil then
                        begin
                          _sev:= _sch.Events.Add;
                          _sev.SetEvent (_ev,dos2win (res.event.abbr),dos2win (res.event.name));
                        end;
                      _sev.Date:= _date;
                      _sev.Town:= '';
                      _res.ShootingEvent:= _sev;
                      _res.Junior:= false;
                      _res.Rank:= res.place;
                      _res.Competition10:= res.mainresult * 10;
                      _res.EncodeFinal (res.final.int,res.final.tens);
                      _results [i].number:= -1;
                    end;
                end;
            end;

          CloseFile (pf);

          j:= 0;
          for i:= 0 to Length (_results)-1 do
            if _results [i].number<> -1 then
              inc (j);
          if j> 0 then
            begin
    //          MessageDlg (format (_gr.Name+#13'%d lost records',[j]),mtError,[mbOk],0);
            end;
        end;
      CloseFile (gf);
    end;
  {$i+}

  Name:= dos2win (config.name);
end;

procedure TData.LoadFromFile(FileName: TFileName);
var
  FS: TFileStream;
  MS: TMemoryStream;
  h: TDataFileHeader;
  DS: TDecompressionStream;
  ch: TCompressionHeader;
  crc: LongWord;
begin
  FS:= TFileStream.Create (FileName,fmOpenRead);
  try
    FS.Read (h,sizeof (h));
    if h.TextID<> TEXT_DATA_FILE_ID then
      raise EInvalidDataFile.Create ('');
    if not IsEqualGUID (h.GUID,OLD_DATA_FILE_GUID) then
      raise EInvalidDataFile.Create ('');
    if h.Version> CURRENT_DATAFILE_VERSION then
      raise EInvalidDataFileVersion.Create ('');
    fFileVersion:= h.Version;
  except
    FS.Free;
    raise;
    exit;
  end;
  MS:= TMemoryStream.Create;
  if fFileVersion<= 32 then
    begin
      try
        MS.Size:= FS.Size-FS.Position;
        MS.CopyFrom (FS,MS.Size);
        FS.Free;
      except
        MS.Free;
        FS.Free;
        raise;
        exit;
      end;
    end
  else
    begin
      // ������� � ������ 33 ������ �������� � ������ ����
      try
        // ������ ��������� ����������
        FS.Read (ch,sizeof (ch));
      except
        MS.Free;
        FS.Free;
        raise;
        exit;
      end;
      DS:= TDecompressionStream.Create (FS);
      try
        MS.Size:= ch.UncompressedSize;
        MS.CopyFrom (DS,ch.UncompressedSize);
        DS.Free;
        FS.Free;
      except
        DS.Free;
        MS.Free;
        FS.Free;
        raise;
        exit;
      end;
      MS.Position:= 0;
      crc:= Crc32Stream (MS,MS.Size);
      if crc<> ch.CRC32 then
        begin
          MS.Free;
          raise EDataFileCorrupt.Create ('CRC error');
        end;
    end;
  MS.Position:= 0;
  try
    ReadFromStream (MS);
  finally
    MS.Free;
  end;
end;

procedure TData.MergeWith(AData: TData);
begin
  fQualifications.MergeWith (AData.Qualifications);
  fEvents.MergeWith (AData.Events);
  fChampionships.MergeWith (AData.Championships);
  fGroups.MergeWith (AData.Groups);
  fStartLists.MergeWith (AData.StartLists);
end;

procedure TData.ReadFromStream(Stream: TStream);
var
  //l: integer;
  i: integer;
begin
  Stream.Read (fId,sizeof (fID));  // data id
  ReadStrFromStreamA (Stream,fName);
  //Stream.Read (l,sizeof (l));
  //SetLength (fName,l);
  //Stream.Read (fName [1],l);
  if fFileVersion>= 16 then
    begin
      fRegions.ReadFromStream (Stream);
      fDistricts.ReadFromStream (Stream);
    end
  else
    begin
      fRegions.Clear;
      fDistricts.Clear;
    end;
  fEvents.ReadFromStream (Stream);
  fChampionships.ReadFromStream (Stream);
  fQualifications.ReadFromStream (Stream);
  if fFileVersion>= 20 then
    fSocieties.ReadFromStream (Stream)
  else
    fSocieties.Clear;
  fShootingChampionships.Clear;
  if fFileVersion>= 25 then
    begin
      fShootingChampionships.ReadFromStream (Stream);
    end;
  fGroups.ReadFromStream (Stream);
  begin
    var NormalizedCount := NormalizeAllShooterSurnames;
    if NormalizedCount > 0 then
      fChanged := true;
  end;
  for i:= 0 to fEvents.Count-1 do
    fEvents.Items [i].CorrectTag;
  if fFileVersion>= 8 then
    StartLists.ReadFromStream (Stream);
  fRatingDate:= 0;
  fChanged:= false;
  if fFileVersion< CURRENT_DATAFILE_VERSION then
    fChanged:= true;
end;

procedure TData.ResetDupeResults;
begin
  SetLength (fDupeResults,0);
end;

procedure TData.ResetRatings;
begin
  fGroups.ResetRatings;
end;

function TData.NormalizeAllShooterSurnames: Integer;
var
  GroupIndex, ShooterIndex: Integer;
  GroupItem: TGroupItem;
  ShooterItem: TShooterItem;
begin
  Result := 0;
  if fGroups = nil then
    Exit;

  for GroupIndex := 0 to fGroups.Count - 1 do
  begin
    GroupItem := fGroups.Items[GroupIndex];
    if GroupItem = nil then
      Continue;

    for ShooterIndex := 0 to GroupItem.Shooters.Count - 1 do
    begin
      ShooterItem := GroupItem.Shooters.Items[ShooterIndex];
      if ShooterItem = nil then
        Continue;

      if ShooterItem.NormalizeSurname then
        Inc(Result);
    end;
  end;
end;

procedure TData.SaveToFile (FileName: TFileName; SaveStartLists: boolean= true; SavePersonalInfo: boolean= true);
var
  MS: TMemoryStream;
  FS: TFileStream;
  h: TDataFileHeader;
  CS: TCompressionStream;
  ch: TCompressionHeader;
begin
  MS:= TMemoryStream.Create;
  try
    fFileVersion:= CURRENT_DATAFILE_VERSION;   // ������������� ������� ������ �����
    WriteToStream (MS,SaveStartLists,SavePersonalInfo);
  except
    MS.Free;
    raise;
    exit;
  end;
  FS:= TFileStream.Create (FileName,fmCreate);
  try
    // ��������� �����
    h.TextID:= TEXT_DATA_FILE_ID;
    h.GUID:= OLD_DATA_FILE_GUID;
    h.Version:= fFileVersion;
    FS.Write (h,sizeof (h));
    // ��������� ������
    ch.UncompressedSize:= MS.Size;
    MS.Position:= 0;
    ch.CRC32:= Crc32Stream (MS,MS.Size);
    FS.Write (ch,sizeof (ch));
  except
    FS.Free;
    MS.Free;
    raise;
    exit;
  end;
  MS.Position:= 0;
  CS:= TCompressionStream.Create (clDefault,FS);
  try
    CS.CopyFrom (MS,MS.Size);
  finally
    CS.Free;
    FS.Free;
    MS.Free;
  end;
end;

procedure TData.set_Name(const Value: string);
begin
  if Value<> fName then
    fChanged:= true;
  fName:= Value;
end;

procedure TData.set_RatingDate(const Value: TDateTime);
begin
  fRatingDate:= Value;
  ResetRatings;
end;

function TData.SpecificRatingDate: boolean;
begin
  Result:= (fRatingDate> 0);
end;

{procedure TData.StripAllPersonalInfo;
var
  i,j: integer;
  g: TGroupItem;
  s: TShooterItem;
begin
  for i:= 0 to Groups.Count-1 do
    begin
      g:= Groups.Items [i];
      for j:= 0 to g.Shooters.Count-1 do
        begin
          s:= g.Shooters.Items [j];
          s.StripPersonalInfo;
        end;
    end;
end;}

procedure TData.WriteToStream(Stream: TStream; SaveStartLists: boolean= true; SavePersonalInfo: boolean= true);
begin
  Stream.Write (fId,sizeof (fID));
  SaveStrToStreamA (Stream,fName);  // ���������� ���������� ������� ��� Unicode
  fRegions.WriteToStream (Stream);
  fDistricts.WriteToStream (Stream);
  fEvents.WriteToStream (Stream);
  fChampionships.WriteToStream (Stream);
  fQualifications.WriteToStream (Stream);
  fSocieties.WriteToStream (Stream);
  fShootingChampionships.WriteToStream (Stream);
  fGroups.WriteToStream (Stream,SavePersonalInfo);
  fStartLists.WriteToStream (Stream,SaveStartLists);
  fChanged:= false;
end;

{ TStartListEvents }

function TStartListEvents.Add: TStartListEventItem;
begin
  Result:= inherited Add as TStartListEventItem;
end;

procedure TStartListEvents.Assign(Source: TPersistent);
var
  i: integer;
  ev: TStartListEventItem;
begin
  if Source is TStartListEvents then
    begin
      Clear;
      for i:= 0 to (Source as TStartListEvents).Count-1 do
        begin
          ev:= Add;
          ev.Assign ((Source as TStartListEvents).Items [i]);
        end;
    end
  else
    inherited;
end;

constructor TStartListEvents.Create;
begin
  inherited Create (TStartListEventItem);
  fStartList:= AStartList;
  fChanged:= false;
end;

function TStartListEvents.FindByProtocolNumber(ProtocolNumber: integer): TStartListEventItem;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    if Items [i].ProtocolNumber= ProtocolNumber then
      begin
        Result:= Items [i];
        break;
      end;
end;

function TStartListEvents.get_EventIdx(
  index: integer): TStartListEventItem;
begin
  Result:= inherited Items [index] as TStartListEventItem;
end;

function TStartListEvents.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

function TStartListEvents.NumberOf(AQual: TQualificationItem): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    Result:= Result+Items [i].Shooters.NumberOf (AQual);
end;

function TStartListEvents.PointsTeamShooters(ATeam: string): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    Result:= Result+Items [i].Shooters.PointsTeamShooters (ATeam);
end;

{procedure TStartListEvents.ImportFromStream(Stream: TStream);
var
  c,j: integer;
  e: TStartListEventItem;
begin
  Stream.Read (c,sizeof (c));
  Clear;
  for j:= 0 to c-1 do
    begin
      e:= Add;
      e.ImportFromStream (Stream);
    end;
  fChanged:= true;
end;}

procedure TStartListEvents.ReadFromStream(Stream: TStream);
var
  c,j: integer;
  e: TStartListEventItem;
begin
  Stream.Read (c,sizeof (c));
  Clear;
  for j:= 0 to c-1 do
    begin
      e:= Add;
      e.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TStartListEvents.SaveResultsPDF(const FName: TFileName; AFinal, ATeams,
  ATeamPoints, ARegionPoints, ADistrictPoints, AReport: boolean);
begin
  // TODO: Restore PDF functionality after migration
  // PDF functions temporarily disabled for Delphi 12 compatibility
end;

procedure TStartListEvents.SaveResultsPDFInternational(const FName: TFileName;
  AFinal, ATeams: boolean);
begin
  // TODO: Restore PDF functionality after migration
  // PDF functions temporarily disabled for Delphi 12 compatibility
end;

function TStartListEvents.TeamShooters(ATeam: string): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    Result:= Result+Items [i].Shooters.TeamShooters (ATeam);
end;

function TStartListEvents.TotalShooters: integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    Result:= Result+Items [i].Shooters.Count;
end;

procedure TStartListEvents.WriteToStream(Stream: TStream);
var
  c,j: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for j:= 0 to c-1 do
    Items [j].WriteToStream (Stream);
  fChanged:= false;
end;

{ TStartListEventItem }

function TStartListEventItem.DrawLots(AMethod: integer): boolean;

  function Method1: boolean;
  var
    i,idx: integer;
    ri: TStartListEventRelayItem;
    rp: integer;
    sh: TStartListEventShooterItem;
    sha: array of TStartListEventShooterItem;
    np: integer;
  begin
    SetLength (sha,fShooters.Count);
    for i:= 0 to fShooters.Count-1 do
      sha [i]:= fShooters.Items [i];
    ri:= fRelays [0];
    rp:= 0;
    while Length (sha)> 0 do
      begin
        // ����� �� ������� ������������� �������
        idx:= Random (Length (sha));
        sh:= sha [idx];
//        if not sh.HavePosition then
          begin
            // ���������, ���� �� ��� ����� � �����
            while rp>= ri.PositionCount do
              begin
                ri:= fRelays [ri.Index+1];
                rp:= 0;
              end;
            // ����������� ����� � ���
            sh.Relay:= ri;
            sh.Position:= ri.Positions [rp];
            inc (rp);
          end;
        // ������� ������� �� �������
        for i:= idx to Length (sha)-2 do
          sha [i]:= sha [i+1];
        SetLength (sha,Length (sha)-1);
      end;
    sha:= nil;

    case Event.EventType of
      //etRegular,etCenterFire,etMovingTarget: {};
      etRapidFire: begin
        for i:= 0 to fShooters.Count-1 do
          begin
            sh:= fShooters.Items [i];
            np:= ((sh.Position-1) div 2)*2+2-((sh.Position-1) mod 2);
            if sh.Relay.CheckPosition (np) then
              sh.Position2:= np;
          end;
      end;
    else
      {}
    end;

    Result:= true;
  end;

  function Method2: boolean;
  begin
    Result:= false;
  end;

begin
  Result:= false;
  Randomize;
  if not CheckLots then
    exit;
  case AMethod of
    1: Result:= Method1;
    2: Result:= Method2;
  else
    Result:= false;
  end;
end;

constructor TStartListEventItem.Create(ACollection: TCollection);
begin
  inherited;
  fRegionsPoints:= TStartListPoints.Create;
  fDistrictsPoints:= TStartListPoints.Create;
  fPTeamsPoints:= TStartListPoints.Create;
  fRTeamsPoints:= TStartListPoints.Create;
  fRelays:= TStartListEventRelays.Create (self);
  fShooters:= TStartListEventShooters.Create (self);
  fEvent:= nil;
  fProtocolNumber:= 0;
  fCalculatePoints:= true;
  fFinalTime:= Now;
  fInfo:= nil;
  fChanged:= false;
  fInPointsTable:= true;
//  fShootingEvent:= nil;
  Events.fChanged:= true;
  fCompetitionWithTens:= false;
  fNewFinalFormat:= false;
  SetLength(fgGoldShots1, 0);
  SetLength(fgGoldShots2, 0);
  fgGoldPoints1 := 0;
  fgGoldPoints2 := 0;
  fgGoldShooterIdx1 := -1;
  fgGoldShooterIdx2 := -1;
end;

{
procedure TStartListEventItem.CreateShootingEvent (AEvent: TEventItem);
begin
  if fShootingEvent<> nil then
    exit;
  fShootingEvent:= ShootingChampionship.Events.Add;
  fShootingEvent.Date:= DateTill;
  fShootingEvent.SetEvent (AEvent,'','');
  fShootingEvent.Town:= Info.Town;
end;
}

destructor TStartListEventItem.Destroy;
begin
  if fInfo<> nil then
    fInfo.Free;
  fShooters.Free;
  fRelays.Free;
  fRTeamsPoints.Free;
  fPTeamsPoints.Free;
  fDistrictsPoints.Free;
  fRegionsPoints.Free;
  Events.fChanged:= true;
  SetLength(fgGoldShots1, 0);
  SetLength(fgGoldShots2, 0);
  fgGoldShooterIdx1 := -1;
  fgGoldShooterIdx2 := -1;
  inherited;
end;

{
procedure TStartListEventItem.DestroyShootingEventIfEmpty;
begin
  if fShootingEvent= nil then
    exit;
  if fShootingEvent.ResultsCount= 0 then
    fShootingEvent.Free;
  fShootingEvent:= nil;
end;
}

function TStartListEventItem.get_StartList: TStartList;
begin
  Result:= (Collection as TStartListEvents).StartList;
end;

procedure TStartListEventItem.ResetGoldMatch;
begin
  SetLength(fgGoldShots1, 0);
  SetLength(fgGoldShots2, 0);
  fgGoldPoints1 := 0;
  fgGoldPoints2 := 0;
  fgGoldShooterIdx1 := -1;
  fgGoldShooterIdx2 := -1;
  fChanged := true;
end;

procedure TStartListEventItem.RecalcGoldPoints;
var
  i: integer;
  s1, s2: integer;
begin
  fgGoldPoints1 := 0;
  fgGoldPoints2 := 0;
  for i := 0 to High(fgGoldShots1) do
  begin
    if i> High(fgGoldShots2) then Break;
    s1 := fgGoldShots1[i];
    s2 := fgGoldShots2[i];
    if s1 > s2 then
      Inc(fgGoldPoints1, 2)
    else if s2 > s1 then
      Inc(fgGoldPoints2, 2)
    else begin
      Inc(fgGoldPoints1, 1);
      Inc(fgGoldPoints2, 1);
    end;
  end;
end;

function TStartListEventItem.GoldFinished: boolean;
begin
  // Stop at 16 with 2-point lead
  Result := ((fgGoldPoints1 >= 16) or (fgGoldPoints2 >= 16)) and (Abs(fgGoldPoints1 - fgGoldPoints2) >= 2);
end;

procedure TStartListEventItem.AppendGoldShotPair(AShot1, AShot2: word);
var
  n: integer;
begin
  if GoldFinished then Exit;
  n := Length(fgGoldShots1);
  SetLength(fgGoldShots1, n+1);
  SetLength(fgGoldShots2, n+1);
  fgGoldShots1[n] := AShot1;
  fgGoldShots2[n] := AShot2;
  RecalcGoldPoints;
  fChanged := true;
end;

procedure TStartListEventItem.SetGoldFinalists(Index1, Index2: integer);
begin
  fgGoldShooterIdx1 := Index1;
  fgGoldShooterIdx2 := Index2;
  fChanged := true;
end;

procedure TStartListEventItem.SetGoldShot(Index: integer; AShot1, AShot2: word);
begin
  if (Index < 0) then Exit;
  if Index >= Length(fgGoldShots1) then
  begin
    SetLength(fgGoldShots1, Index+1);
    SetLength(fgGoldShots2, Index+1);
  end;
  fgGoldShots1[Index] := AShot1;
  fgGoldShots2[Index] := AShot2;
  RecalcGoldPoints;
  fChanged := true;
end;

function TStartListEventItem.GoldShotsCount: integer;
begin
  Result := Length(fgGoldShots1);
end;

function TStartListEventItem.GetGoldShots1: TWordDynArray;
begin
  Result := fgGoldShots1;
end;

function TStartListEventItem.GetGoldShots2: TWordDynArray;
begin
  Result := fgGoldShots2;
end;

{procedure TStartListEventItem.ImportFromStream(Stream: TStream);
var
  c: integer;
  tag: string;
  b: boolean;
begin
  Stream.Read (c,sizeof (c));
  SetLength (tag,c);
  Stream.Read (tag [1],c);
  fEvent:= StartList.Data.Events.Events [tag];
  fRelays.ImportFromStream (Stream);
  fShooters.ImportFromStream (Stream);
  Stream.Read (fProtocolNumber,sizeof (fProtocolNumber));
  Stream.Read (fCalculatePoints,sizeof (fCalculatePoints));
  Stream.Read (fFinalTime,sizeof (fFinalTime));
  Stream.Read (b,sizeof (b));
  if b then
    begin
      OverrideInfo;
      fInfo.ImportFromStream (Stream);
    end
  else
    DeleteInfo;
  if StartList.fStreamVersion>= 5 then
    fPoints.ImportFromStream (Stream);
  fChanged:= true;
end;}

function TStartListEventItem.PositionsCount: integer;
begin
  Result:= Relays.PositionCount;
end;

{procedure TStartListEventItem.SaveToStream(Stream: TStream);
var
  c: integer;
  tag: string;
  b: boolean;
begin
  tag:= fEvent.Tag;
  c:= Length (tag);
  Stream.Write (c,sizeof (c));
  Stream.Write (tag [1],c);
  fRelays.SaveToStream (Stream);
  fShooters.SaveToStream (Stream);
  Stream.Write (fProtocolNumber,sizeof (fProtocolNumber));
  Stream.Write (fCalculatePoints,sizeof (fCalculatePoints));
  Stream.Write (fFinalTime,sizeof (fFinalTime));
  b:= (fInfo<> nil);
  Stream.Write (b,sizeof (b));
  if b then
    fInfo.SaveToStream (Stream);
  fPoints.SaveToStream (Stream);
end;}

{
procedure TStartListEventItem.set_Event(const Value: TEventItem);
begin
  if fEvent= nil then
    begin
      if Value<> nil then
        begin
          fEvent:= Value;
          fChanged:= true;
        end;
    end
  else
    begin
      raise Exception.Create ('������ �������� ������ Event � StartListEvent!');
    end;
end;
}

function TStartListEventItem.CheckLots: boolean;
begin
  Result:= (fShooters.Count> 0) and
    (fRelays.PositionCount>= fShooters.Count);
end;

function TStartListEventItem.CompetitionStr(AComp: DWORD): string;
begin
  if fCompetitionWithTens then
    Result:= format ('%d.%d',[AComp div 10,AComp mod 10])
  else
    Result:= format ('%d',[AComp div 10]);
end;

function TStartListEventItem.CompTemplate: string;
begin
  if fCompetitionWithTens then
    Result:= '0000.0'
  else
    Result:= '0000';
end;

function TStartListEventItem.FindShooter(ARelay: TStartListEventRelayItem;
  APosition: integer): TStartListEventShooterItem;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= nil;
  if (ARelay= nil) or (APosition= 0) then
    exit;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (sh.Relay= ARelay) and (sh.Position= APosition) then
        begin
          Result:= sh;
          break;
        end;
    end;
end;

function TStartListEventItem.IsLotsDrawn: boolean;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  if fShooters.Count> 0 then
    begin
      Result:= true;
      for i:= 0 to fShooters.Count-1 do
        begin
          sh:= fShooters.Items [i];
          if not sh.HavePosition then
            begin
              Result:= false;
              break;
            end;
        end;
    end
  else
    Result:= false;
end;

function TStartListEventItem.IsStarted: boolean;
var
  sh: TStartListEventShooterItem;
  i: integer;
begin
  Result:= false;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (sh.SeriesCount> 0) or (sh.IsFinished) then
        begin
//          fStarted:= true;
          Result:= true;
          break;
        end;
    end;
end;

function TStartListEventItem.NumberOfFinalists: integer;
begin
  Result:= Event.FinalPlaces;
  if Shooters.Count< Result then
    Result:= Shooters.Count;
end;

function TStartListEventItem.IsCompleted: boolean;
var
  i: integer;
begin
  if fShooters.Count> 0 then
    begin
      Result:= true;
      for i:= 0 to fShooters.Count-1 do
        if not fShooters.Items [i].IsFinished then
          begin
            Result:= false;
            break;
          end;
    end
  else
    Result:= false;
end;

{function TStartListEventItem.ShotForTeam(
  ATeam: TStartListTeamItem): TStartListEventShootersArray;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  SetLength (Result,0);
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (sh.Team= ATeam) and (not sh.OutOfRank) and (sh.ForTeam) then
        begin
          SetLength (Result,Length (Result)+1);
          Result [Length (Result)-1]:= sh;
        end;
    end;
end;}

{
function TStartListEventItem.ShootingChampionship: TShootingChampionshipItem;
begin
  Result:= StartList.ShootingChampionship;
end;
}

function TStartListEventItem.ShotForTeam(ATeam: string): TStartListEventShootersArray;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  SetLength (Result,0);
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (AnsiSameText (sh.TeamForResults,ATeam)) and (not sh.OutOfRank) and (sh.DNS<> dnsCompletely) then
        begin
          SetLength (Result,Length (Result)+1);
          Result [Length (Result)-1]:= sh;
        end;
    end;
end;

function TStartListEventItem.TeamPoints(ATeam: string; AGender: TGenders): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= 0;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (AnsiSameText (sh.TeamForPoints,ATeam)) and (not sh.OutOfRank) and
        (sh.Shooter.Gender in AGender) then
        Result:= Result+sh.TeamPoints+sh.QualificationPoints+sh.ManualPoints;
    end;
end;

function TStartListEventItem.TeamPointsShooters(ATeam: string; AGender: TGenders): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= 0;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (AnsiSameText (sh.TeamForPoints,ATeam)) and (not sh.OutOfRank) and
        (sh.Shooter.Gender in AGender) then
        inc (Result);
    end;
end;

function TStartListEventItem.TotalTemplate: string;
begin
  if (fCompetitionWithTens) or (Event.FinalFracs) then
    Result:= '0000.0'
  else
    Result:= '0000';
end;

{
procedure TStartListEventItem.UpdateShootingEventDate;
begin
  fShootingEvent.Date:= DateTill;
end;
}

function TStartListEventItem.HaveQualification(Qualification: TQualificationItem): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= 0;
  for i:= 0 to Shooters.Count-1 do
    begin
      sh:= Shooters.Items [i];
      if sh.Shooter.Qualification= Qualification then
        inc (Result);
    end;
end;

function TStartListEventItem.HighestRank(ATeam: string; Genders: TGenders): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= -1;
  for i:= 0 to Shooters.Count-1 do
    begin
      sh:= Shooters.Items [i];
      if (sh.OutOfRank) or (sh.DNS<> dnsNone) then
        continue;
      if AnsiSameText (sh.fTeamForPoints,ATeam) then
        begin
          Result:= i+1;
          break;
        end;
    end;
end;

function TStartListEventItem.Qualified(QFrom, QTo: TQualificationItem): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
//  t: boolean;
begin
  Result:= 0;
  for i:= 0 to Shooters.Count-1 do
    begin
      sh:= Shooters.Items [i];
      if (sh.Shooter.Qualification= QFrom) and (sh.Qualified{ (t)}= QTo) then
        inc (Result);
    end;
end;

function TStartListEventItem.StagesComplete: integer;
var
  i,c: integer;
begin
  Result:= -1;
  for i:= 0 to fShooters.Count-1 do
    begin
      c:= fShooters.Items [i].StagesCount;
      if (c> Result) or (Result= -1) then
        Result:= c;
    end;
  if Result= -1 then
    Result:= 0;
end;

function TStartListEventItem.StartNumber: integer;
var
  i: integer;
  ev: TStartListEventItem;
  before,after: integer;
begin
  before:= 0;
  for i:= 0 to Index-1 do
    begin
      ev:= StartList.Events [i];
      if ev.Event= Event then
        inc (before);
    end;
  after:= 0;
  for i:= Index+1 to StartList.Events.Count-1 do
    begin
      ev:= StartList.Events [i];
      if ev.Event= Event then
        inc (after);
    end;
  if (before> 0) or (after> 0) then
    Result:= before+1
  else
    Result:= 0;
end;

procedure TStartListEventItem.PrintStartList (Prn: TObject; ACopies: integer);
begin
  case Event.EventType of
    etRegular,etCenterFire,etMovingTarget,etMovingTarget2013: PrintRegularStartList (Prn,ACopies);
    etRapidFire: PrintRapidFireStartList (Prn,ACopies);
    etCenterFire2013,etThreePosition2013: PrintRegularStartList (Prn,ACopies);
  else
  end;
end;

type
  trelayshootersarray= record
    sh: array of TStartListEventShooterItem;
    dt1,dt2: TDateTime;
    ft: TDateTime;
  end;

procedure TStartListEventItem.PrintInternationalResults(Prn: TObject;
  AFinal, ATeams: boolean; ACopies: integer; StartDoc: boolean);
var
  _printer: TMyPrinter;
  _printing: boolean;
  font_name: string;
  font_size: integer;
  xsep,ysep: integer;
  Reg: TRegistry;
  font_height_large: integer;
  thl: integer;
  footerheight: integer;
  page_idx: integer;
  havefinalfracs: boolean;
  cw: array [0..32] of integer;
  y: integer;
  current_page_top: integer;

  function MeasureColumns: boolean;
  var
    i,j: integer;
    sh: TStartListEventShooterItem;
    st: string;
    w: integer;
//    bytotal: boolean;
  begin
    with _printer.Canvas do
      begin
        cw [0]:= 0;     // �����
        cw [1]:= 0;     // ��������� �����
        cw [2]:= 0;     // �������, ���
        cw [3]:= 0;     // ������
        cw [4]:= 0;     // ����������
        cw [5]:= 0;     // ����� ���������
        cw [6]:= 0;     // ����� �������� �����
        cw [7]:= 0;    // �����������/�����������

        Font.Style:= [];
        Font.Height:= font_height_large;
        cw [4]:= TextWidth (SerieTemplate)*Event.SeriesPerStage+_printer.MM2PX (1)*(Event.SeriesPerStage-1);
        Font.Height:= font_height_large;

        for i:= 0 to Shooters.Count-1 do
          begin
            sh:= Shooters.Items [i];

            Font.Height:= font_height_large;
            Font.Style:= [];
            if (sh.DNS<> dnsCompletely) then
              begin
                if sh.OutOfRank then
                  st:= OUT_OF_RANK_MARK
                else if (HasFinal) and (i< Event.FinalPlaces) then
                  st:= FINAL_MARK
                else
                  st:= IntToStr (i+1);
                w:= TextWidth (st);
                if w> cw [0] then
                  cw [0]:= w;
              end;

            if StartList.StartNumbers then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [];
                st:= sh.StartNumberStr;
                w:= TextWidth (st);
                if w> cw [1] then
                  cw [1]:= w;
              end;

            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= sh.Shooter.SurnameAndName;
            w:= TextWidth (st);
            if w> cw [2] then
              cw [2]:= w;

            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= sh.Shooter.RegionAbbr1;
            w:= TextWidth (st);
            if w> cw [3] then
              cw [3]:= w;

            // cw [4] - ����������
            // cw [5] - ���������� ���������
            if (Event.Stages> 1) and (Event.SeriesPerStage> 1) then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [fsBold];
                for j:= 1 to Event.Stages do
                  begin
                    st:= sh.StageResultStr (j);
                    w:= TextWidth (st);
                    if w> cw [5] then
                      cw [5]:= w;
                  end;
              end;

            // cw[6] - �������� ��������� / ��������� ������ / ����� ���������
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            if (AFinal) and (i< Event.FinalPlaces) and (not sh.OutOfRank) then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [fsBold];
                st:= sh.CompetitionStr;
                w:= TextWidth (st);
                if w> cw [6] then
                  cw [6]:= w;
                st:= sh.FinalResultStr;
                w:= TextWidth (st);
                if w> cw [6] then
                  cw [6]:= w;
                st:= sh.TotalResultStr;
                w:= TextWidth (st);
                if w> cw [6] then
                  cw [6]:= w;
              end
            else
              begin
                st:= sh.CompetitionStr;
                w:= TextWidth (st);
                if w> cw [6] then
                  cw [6]:= w;
              end;

            // cw [7] - �����������
            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= '('+sh.CompShootOffStr+')';
            w:= TextWidth (st);
            if w> cw [7] then
              cw [7]:= w;
          end;

        if cw [0]> 0 then
          cw [0]:= cw [0]+xsep div 2;
        for i:= 1 to 6 do
          if cw [i]> 0 then
            cw [i]:= cw [i]+xsep;
        if cw [7]> 0 then
          cw [7]:= cw [7]+xsep div 2;

        w:= 0;
        for i:= 0 to 7 do
          inc (w,cw [i]);
        if w<= _printer.Width then
          begin
            Result:= true;
            cw [3]:= cw [3]+_printer.Width-w;
          end
        else
          Result:= false;
      end;
  end;

  procedure MakeNewPage;
  var
    x,w: integer;
    st: string;
    s: TStrings;
    ii: integer;
    dates: array of TDateTime;

    procedure AddDate (dt: TDateTime);
    var
      i: integer;
    begin
      dt:= DateOf (dt);
      for i:= 0 to Length (dates)-1 do
        if dates [i]= dt then
          exit;
      SetLength (dates,Length (dates)+1);
      dates [Length (dates)-1]:= dt;
    end;

  begin
    if page_idx> 1 then
      begin
        _printer.NewPage;
      end;

    with _printer.Canvas do
      begin
        // footer
        Pen.Width:= 1;
        Font.Style:= [];

        y:= _printer.Bottom-thl*2-_printer.MM2PY (4)+_printer.MM2PY (2);
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
        Font.Height:= font_height_large;
        st:= format (PAGE_NO,[page_idx]);
        TextOut (_printer.Right-TextWidth (st),y,st);
        st:= format (PAGE_FOOTER,[VERSION_INFO_STR]);
        TextOut (_printer.Left,y,st);
        y:= y+TextHeight ('Mg');
        TextOut (_printer.Left,y,PROTOCOL_MAKER_SIGN);

        y:= _printer.Bottom-footerheight+_printer.MM2PY (5);
        Font.Height:= font_height_large;
        Font.Style:= [];
        x:= _printer.Left+_printer.MM2PX (3);
        TextOut (x,y,SECRETERY_TITLE);
        y:= y+thl;
        TextOut (x,y,Info.SecreteryCategory);
        x:= _printer.Right-_printer.MM2PX (3)-TextWidth (Info.Secretery);
        TextOut (x,y,Info.Secretery);

        // header
        y:= _printer.Top;

        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        s:= TStringList.Create;
        s.Text:= Info.TitleText;
        for ii:= 0 to s.Count-1 do
          begin
            st:= s [ii];
            w:= TextWidth (st);
            x:= (_printer.Left+_printer.Right-w) div 2;
            TextOut (x,y,st);
            inc (y,TextHeight (st));
          end;
        // ����������: ����� ������ � ��������� ��� � ����� 1 ������ �������
        if s.Count> 0 then
          y := y + TextHeight('Mg');
        s.Free;

        // ������� ������� ��������� ��� �� ������
        st:= Format (PROTOCOL_NO,[ProtocolNumber]);
        x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
        TextOut (x,y,st);
        y:= y+TextHeight ('Mg')+_printer.MM2PY (1);

        // ����� ����: �������/������� �� �������������� ����������
        case Self.Gender of
          Male: st := '�������';
          Female: st := '�������';
        else
          st := '';
        end;
        if st<>'' then
        begin
          x := (_printer.Left+_printer.Right-TextWidth(st)) div 2;
          TextOut(x,y,st);
          y := y + TextHeight('Mg');
        end;

        // � ������� �������������� � ��������� ������� �� ������
        st := '������������';
        x := (_printer.Left+_printer.Right-TextWidth(st)) div 2;
        TextOut(x,y,st);
        // ����������� �������� ����� ������������
        y := y + TextHeight('Mg') + _printer.MM2PY(2);

        x:= _printer.Left;
        st:= Event.ShortName;
        // ���� ������� �������� ������������ �� ��������� �� ��� �� � �������� ���� ������
        if (Length(st)>0) and ((st[Length(st)]='�') or (st[Length(st)]='�')) then
          Delete(st, Length(st), 1);
        TextOut (x,y,st);
        if Event.Name<> '' then
          begin
            Font.Style:= [];
            st:= Event.Name;
            w:= TextWidth (st);
            x:= _printer.Right-w;
            TextOut (x,y,st);
          end;
{        if StartNumber> 0 then
          begin
            Font.Style:= [fsBold];
            st:= IntToStr (StartNumber)+'-� �����';
            w:= TextWidth (st);
            x:= _printer.PageWidth-rightborder-w;
            TextOut (x,y,st);
          end; }
        y:= y+TextHeight ('Mg');

        Font.Style:= [];
        st:= Info.TownAndRange;
        x:= _printer.Right-TextWidth (st);
        TextOut (x,y,st);

        // �������� ��� ��������� ����
        SetLength (dates,0);
        for ii:= 0 to Relays.Count-1 do
          begin
            AddDate (Relays [ii].StartTime);
            case Event.EventType of
              etRegular: {};
              etCenterFire: {};
              etMovingTarget: {};
              etRapidFire: AddDate (Relays [ii].StartTime2);
              etCenterFire2013: {};
              etThreePosition2013: {};
              etMovingTarget2013: {};
            end;
          end;
        // ���� ���� �����, �� ��������� ���� ������
        if (Event.FinalPlaces> 0) and (AFinal) and (HasFinal) then
          AddDate (FinalTime);

        x:= _printer.Left;
        for ii:= 0 to Length (dates)-1 do
          begin
            st:= FormatDateTime ('dd-mm-yyyy',dates [ii]);
            TextOut (x,y+TextHeight ('Mg')*ii,st);
          end;
        if Length (dates)> 0 then
          y:= y+Length (dates)*thl+_printer.MM2PY (2)
        else
          y:= y+thl+_printer.MM2PY (2);
        SetLength (dates,0);
        dates:= nil;


        Pen.Width:= 1;
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
      end;

    current_page_top:= y;  // ��� ���������� ������ ���� ������
  end;

  function MeasureItemHeight (sh: TStartListEventShooterItem): integer;
  var
    h1,h2,h3: integer;
    s: TStrings;
  begin
    h1:= thl;
    h2:= 0;
    s:= TStringList.Create;
    s.Text:= sh.DNSComment;
    case sh.DNS of
      dnsPartially: begin
        if Event.Stages> 1 then
          h3:= Event.Stages * thl + thl*s.Count
        else
          h3:= thl+thl*s.Count;
      end;
      dnsCompletely: begin
        if s.Count> 0 then
          h3:= thl*s.Count
        else
          h3:= thl;
      end;
    else
      if Event.Stages> 1 then
        h3:= Event.Stages * thl
      else
        h3:= thl;
    end;
    s.Free;
    Result:= h1;
    if h2> Result then
      Result:= h2;
    if h3> Result then
      Result:= h3;
    if (AFinal) and (sh.Index< Event.FinalPlaces) and (HasFinal) then
      begin
        case Event.EventType of
          etRapidFire: Result:= Result+thl+thl*((Event.FinalShots-1) div 10)+_printer.MM2PY (1);
        else
          Result:= Result+thl*((Event.FinalShots-1) div 10)+thl+_printer.MM2PY (1);
        end;
//        if sh.FinalShotsStr<> '' then
          Result:= Result+thl;
      end;
  end;

  procedure PrintShooterItem (sh: TStartListEventShooterItem);
  var
    st: string;
    cx,x,w,y2,y1: integer;
    i,j: integer;
    fx,fy,fc: integer;
    s: TStrings;
//    bytotal: boolean;
//    q: TQualificationItem;
//    qy1,qy2: integer;
  begin
//    y1:= y;
    cx:= _printer.Left;
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [];

        if (sh.DNS<> dnsCompletely) then
          begin
            if sh.OutOfRank then
              st:= OUT_OF_RANK_MARK
            else if (HasFinal) and (sh.Index< Event.FinalPlaces) then
              st:= FINAL_MARK
            else
              st:= IntToStr (sh.Index+1);
            w:= TextWidth (st);
            x:= cx+cw [0]-w-xsep div 2;
            TextOut (x,y,st);
          end;
        cx:= cx+cw [0];

        if StartList.StartNumbers then
          begin
            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= sh.StartNumberStr;
            w:= TextWidth (st);
            x:= cx+cw [1]-w-xsep div 2;
            TextOut (x,y,st);
          end;
        cx:= cx+cw [1];

        x:= cx+xsep div 2;
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        st:= sh.Shooter.SurnameAndName;
        TextOut (x,y,st);
        cx:= cx+cw [2];

        // ������(�)
        Font.Style:= [];
        x:= cx+xsep div 2;
        if sh.Shooter.RegionsAbbr<> '' then
          begin
            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= sh.Shooter.RegionAbbr1;
            TextOut (x,y,st);
          end;
        cx:= cx+cw [3];

        case sh.DNS of
          dnsNone: begin  // ��� ���������
            // ���������� �� ������
            Font.Height:= font_height_large;
            for j:= 1 to Event.Stages do
              begin
    {            if ((AFinal) and (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank)) and (Event.Stages= 1) then
                  y1:= y+thl
                else  }
                  y1:= y+(j-1)*thl;
                Font.Style:= [];
                for i:= 1 to Event.SeriesPerStage do
                  begin
                    st:= sh.SerieStr (j,i);
                    w:= TextWidth (st);
                    x:= cx+(xsep div 2)+i*TextWidth (SerieTemplate)+(i-1)*_printer.MM2PX (1)-w;
                    TextOut (x,y1,st);
                  end;
                if (Event.Stages> 1) and (Event.SeriesPerStage> 1) then
                  begin
                    Font.Style:= [fsBold];
                    st:= sh.StageResultStr (j);
                    w:= TextWidth (st);
                    x:= cx+cw [4]+cw [5]-(xsep div 2)-w;
                    TextOut (x,y1,st);
                  end;
              end;
            cx:= cx+cw [4]+cw [5];

            if Event.Stages> 1 then
              y1:= y+(Event.Stages-1)*thl
            else
              begin
    {            if (AFinal) and (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank) then
                  y1:= y+thl+ths-thl
                else }
                  y1:= y;
              end;

            y2:= y1+thl;

//            qy2:= y;
            if (AFinal) and (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank) then
              begin
                x:= cx-xsep;
                Font.Height:= font_height_large;
                Font.Style:= [];
                // ��������� ��������
                if sh.FinalShotsCount> 0 then
                  begin
                    fy:= y2;
                    for j:= 0 to (Event.FinalShots-1) div 10 do
                      begin
                        fx:= x;
                        fc:= (Event.FinalShots-1) mod 10;
                        for i:= fc downto 0 do
                          begin
                            if j*10+i< sh.FinalShotsCount then
                              st:= Event.FinalStr (sh.FinalShots10 [j*10+i])
                            else
                              st:= '';
                            w:= TextWidth (st);
                            TextOut (fx-w,fy,st);
                            dec (fx,TextWidth (Event.FinalShotTemplate)+xsep);
                          end;
                        if j=0 then
                          begin
                            st:= FINAL_SHOTS_;;
                            w:= TextWidth (st);
                            TextOut (fx-w,fy,st);
                          end;
                        inc (fy,thl);
                      end;
                    y2:= fy-thl;
                  end;

                // ����������� (�����������), ���� ����
                if sh.FinalShootOff10> 0 then
                  begin
                    st:= Format (FINAL_SHOOTOFF,[sh.FinalShootOffStr]);
                    fy:= y2+thl;
                    TextOut (x-xsep*2-TextWidth (st),fy,st);
                  end
                else if sh.FinalShootOffStr<> '' then
                  begin
                    st:= sh.FinalShootOffStr;
                    fy:= y2+thl;
                    TextOut (x-xsep*2-TextWidth (st),fy,st);
                  end;

                // ��������� ��������� �����
                Font.Height:= font_height_large;
                Font.Style:= [fsBold];
                st:= sh.Event.FinalStr (sh.FinalResult10);
                {w:= TextWidth (st);
                x:= cx+cw [10]-xsep div 2-w;}
                x:= cx+xsep div 2;
                TextOut (x,y2,st);
                // ����� �����
                if ((Event.EventType= etRapidFire) and (DateFrom< EncodeDate (2011,4,8))) or
                  ((Event.EventType<> etRapidFire) and ((not Event.CompareByFinal) or (DateFrom< EncodeDate (2012,11,25)))) then
                  begin
                    // 8.4.2011 - ��� ��-8 ����� ��������� ������ �� �����
                    // 25.11.2012 - ��� ������ ���������� ����
                    Font.Height:= font_height_large;
                    Font.Style:= [fsBold];
                    st:= sh.TotalResultStr;
                   { w:= TextWidth (st);
                    x:= cx+cw [10]-xsep div 2-w;}
                    x:= cx+xsep div 2;
                    TextOut (x,y2+thl,st);
                    //qy2:= y2+thl;
                  end;
              end;

            // ��������� ��������
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= sh.CompetitionStr;
            {w:= TextWidth (st);
            if (havefinalfracs) or
               ((AFinal) and (Event.FinalFracs) and
                (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank)) then
              begin
                w:= w+TextWidth ('.0');
                havefinalfracs:= true;
              end;
            x:= cx+cw [10]-xsep div 2-w;}
            x:= cx+xsep div 2;
            TextOut (x,y1,st);
            //qy1:= y1;
            cx:= cx+cw [6];

            // ����������� � �����������
            if sh.CompShootOffStr<> '' then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [];
                st:= '('+sh.CompShootOffStr+')';
                x:= cx+xsep div 2;
                TextOut (x,y1,st);
              end;
            //cx:= cx+cw [7];
          end;
          dnsCompletely: begin  // ������ �� ���������
            Font.Height:= font_height_large;
            Font.Style:= [];
            if sh.DNSComment<> '' then
              begin
                s:= TStringList.Create;
                s.Text:= sh.DNSComment;
                x:= cx+xsep div 2;
                for i:= 0 to s.Count-1 do
                  begin
                    y1:= y+thl*i;
                    TextOut (x,y1,s [i]);
                  end;
                s.Free;
                st:= sh.DNSComment;
              end
            else
              begin
                TextOut (cx+xsep div 2,y,DNS_MARK);
              end;
          end;
          dnsPartially: begin   // ���� ����������, �� �� ��������, ����� �����������
            // ���������� �� ������
            Font.Height:= font_height_large;
            for j:= 1 to Event.Stages do
              begin
                y1:= y+(j-1)*thl;
                Font.Style:= [];
                for i:= 1 to Event.SeriesPerStage do
                  begin
                    st:= sh.SerieStr (j,i);
                    w:= TextWidth (st);
                    x:= cx+(xsep div 2)+i*TextWidth (SerieTemplate)+(i-1)*_printer.MM2PX (1)-w;
                    TextOut (x,y1,st);
                  end;
                if (Event.Stages> 1) and (Event.SeriesPerStage> 1) then
                  begin
                    Font.Style:= [fsBold];
                    st:= sh.StageResultStr (j);
                    w:= TextWidth (st);
                    x:= cx+cw [4]+cw [5]-(xsep div 2)-w;
                    TextOut (x,y1,st);
                  end;
              end;
            if sh.DNSComment<> '' then
              begin
                s:= TStringList.Create;
                s.Text:= sh.DNSComment;
                Font.Style:= [];
                x:= cx+(xsep div 2);
                for i:= 0 to s.Count-1 do
                  begin
                    y1:= y+(Event.Stages+i)*thl;
                    TextOut (x,y1,s [i]);
                  end;
                s.Free;
              end;

            cx:= cx+cw [4]+cw [5];

            if Event.Stages> 1 then
              y1:= y+(Event.Stages-1)*thl
            else
              y1:= y;

            // ��������� ��������
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= sh.CompetitionStr;
//            w:= TextWidth (st);
            if (havefinalfracs) or
               ((AFinal) and (Event.FinalFracs) and
                (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank)) then
              begin
//                w:= w+TextWidth ('.0');
                havefinalfracs:= true;
              end;
//            x:= cx+cw [10]-xsep div 2-w;
            x:= cx+xsep div 2;
            TextOut (x,y1,st);
          end;
        end;
      end;
  end;

  procedure PrintTeamsReport;
  var
    _teams: TStartListEventTeams;
    lx: integer;

    function MeasureColumns: boolean;
    var
      i: integer;
      w: integer;
      st: string;
    begin
      cw [0]:= 0;
      cw [1]:= 0;
      cw [2]:= 0;
      cw [3]:= 0;
      cw [4]:= 0;
      with _printer.Canvas do
        begin
          Font.Height:= font_height_large;
          for i:= 0 to _teams.Count-1 do
            begin
              Font.Style:= [];
              st:= IntToStr (i+1);
              w:= TextWidth (st);
              if w> cw [0] then
                cw [0]:= w;
              Font.Style:= [];
              st:= _teams [i].Name;
              w:= TextWidth (st);
              if w> cw [1] then
                cw [1]:= w;
              Font.Style:= [fsBold];
              st:= _teams[i].SumStr;
              w:= TextWidth (st);
              if w> cw [2] then
                cw [2]:= w;
            end;
          Font.Style:= [];
          cw [0]:= cw [0]+_printer.MM2PX (2);
          cw [1]:= cw [1]+_printer.MM2PX (4);
          cw [2]:= cw [2]+_printer.MM2PX (4)+TextWidth ('-');
//          tw:= _printer.Width-cw [0]-cw [1]-cw [2]-_printer.MM2PX (2);
          Font.Height:= font_height_large;
          Font.Style:= [];
          for i:= 0 to _teams.Count-1 do
            begin
              st:= _teams [i].ShootersListStr;
              w:= TextWidth (st);
              if w> cw [3] then
                cw [3]:= w;
            end;
          cw [3]:= cw [3]+_printer.MM2PX (4);
        end;
      lx:= _printer.Left+(_printer.Width-cw [0]-cw [1]-cw [2]-cw [3]) div 2;
      Result:= true;
    end;

    function MeasureItem (index: integer): integer;
    var
      n: integer;
    begin
      n:= 1;
      Result:= thl+(n-1)*thl+_printer.MM2PY (1);
    end;

    function MeasureAllHeight: integer;
    var
      j: integer;
    begin
      Result:= 0;
      for j:= 0 to _teams.Count-1 do
        Result:= Result+MeasureItem (j);
    end;

  var
    st: string;
    lh,x,w,y1: integer;
    i: integer;
//    pp: integer;
  begin
    _teams:= TStartListEventTeams.Create (self);
    if _teams.Count= 0 then
      begin
        _teams.Free;
        exit;
      end;
    MeasureColumns;
    // ���� ��� ������� �� ������� �� ������� ��������, �������� ��������� ��������
    if (y+thl*2+thl+thl+MeasureAllHeight>= _printer.Bottom-footerheight) and (y> current_page_top) then
      begin
        inc (page_idx);
        MakeNewPage;
      end;
    y:= y+thl*2;

    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        st:= TEAM_CHAMPIONSHIP_TITLE;
        x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
        TextOut (x,y,st);
      end;
    inc (y,thl+thl);

    for i:= 0 to _teams.Count-1 do
      begin
        lh:= MeasureItem (i);
        if y+lh>= _printer.Bottom-footerheight then
          begin
            inc (page_idx);
            MakeNewPage;
          end;

        with _printer.Canvas do
          begin
            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= IntToStr (i+1);
            w:= TextWidth (st);
            x:= lx+cw [0]-_printer.MM2PX (2)-w;
            TextOut (x,y,st);

            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= _teams [i].Name;
            x:= lx+cw [0]+_printer.MM2PX (2);
            TextOut (x,y,st);

            Font.Height:= font_height_large;
            TextOut (lx+cw [0]+cw [1],y,'-');
            Font.Style:= [fsBold];
            st:= _teams[i].SumStr;
            w:= TextWidth (st);
            x:= lx+cw [0]+cw [1]+cw [2]-_printer.MM2PX (2)-w;
            TextOut (x,y,st);

            Font.Height:= font_height_large;
            Font.Style:= [];
            y1:= y;
            x:= lx+cw [0]+cw [1]+cw [2]+_printer.MM2PX (2);
            st:= _teams [i].ShootersListStr;
            TextOut (x,y1,st);
          end;

        inc (y,lh);
      end;
    _teams.Free;
  end;

var
  i: integer;
  sh: TStartListEventShooterItem;
  lineheight: integer;
begin
  if Prn= nil then
    begin
      Prn:= Printer;
      if Prn= nil then
        exit;
    end;

  _printer:= TMyPrinter.Create (Prn);
  _printer.Orientation:= poPortrait;
  _printer.PageSize:= psA4;
  _printer.Copies:= ACopies;
  if _printer.PDF<> nil then
    begin
      if not _printer.PDF.Printing then
        begin
          _printer.PDF.ProtectionEnabled:= true;
          _printer.PDF.ProtectionOptions:= [coPrint];
          _printer.PDF.Compression:= ctFlate;
        end;
      _printing:= _printer.PDF.Printing;
    end
  else
    begin
      _printing:= _printer.Printer.Printing;
    end;
  if not _printing then
    begin
      _printer.Title:= Format (EVENT_RESULTS_PRINT_TITLE,[Event.ShortName]);
      _printer.BeginDoc;
    end;
  _printer.SetBordersMM (15,10,10,5);

  if AFinal then
    Shooters.SortOrder:= soFinal
  else
    Shooters.SortOrder:= soSeries;

  font_name:= 'Arial';
  font_size:= 10;
  xsep:= _printer.MM2PX (2);
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

  with _printer.Canvas do
    begin
      Font.Name:= font_name;
      Font.Charset:= PROTOCOL_CHARSET;
      Font.Size:= font_size;
      font_height_large:= Font.Height;
      ysep:= abs (font_height_large) div 5;
    end;

  repeat
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        thl:= TextHeight ('Mg');
      end;
    footerheight:= thl*2+_printer.MM2PY (4)+thl*2+_printer.MM2PY (5)+_printer.MM2PY (5);
    if MeasureColumns then
      break
    else
      begin
        if abs (font_height_large)> 4 then
          begin
            inc (font_height_large);
          end
        else
          begin
            _printer.Abort;
            _printer.Free;
            exit;
          end;
      end;
  until false;

  havefinalfracs:= false;

  page_idx:= 1;
  MakeNewPage;
  for i:= 0 to Shooters.Count-1 do
    begin
      sh:= Shooters.Items [i];
      lineheight:= MeasureItemHeight (sh);
      if y+lineheight> _printer.Bottom-footerheight then
        begin
          inc (page_idx);
          MakeNewPage;
        end;
      PrintShooterItem (sh);
      inc (y,lineheight+ysep);
    end;

  if (ATeams) and (HasTeamsForResult) then
    begin
      inc (page_idx);
      MakeNewPage;
      PrintTeamsReport;
    end;

  if not _printing then
    _printer.EndDoc;
  _printer.Free;
end;

procedure TStartListEventItem.PrintRapidFireStartList;
const
  separator= 4;
var
  all_relays: array of trelayshootersarray;
  font_height_large: integer;
  font_height_small: integer;
  footerheight,signatureheight: integer;
  cw: array [0..32] of integer;
  page_idx: integer;
  sh: TStartListEventShooterItem;
  lineheight: integer;
  y: integer;
  firstrelayonpage: boolean;
  font_name: string;
  font_size: integer;
  a_teams,a_regions,a_districts: boolean;
  _printer: TMyPrinter;

  function MeasureColumns: boolean;
  var
    i,j: integer;
    st: string;
    w,sep: integer;
  begin
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        cw [0]:= 0;         // ��������� �����
        cw [1]:= 0;                         // �������, ���
        cw [2]:= 0;         // ��� ��������
        cw [3]:= 0;                        // ������������
        cw [4]:= 0;                        // ������� ���������
        cw [5]:= 0;                          // ����������� (����)
        cw [6]:= 0;         // ���
        cw [7]:= 0;         // ��� 2
        cw [8]:= 0;         // ��
        cw [9]:= 0;         // �� �� �������
        cw [10]:= 0;        // �� �� �����
        cw [11]:= 0;        // �� �� ������
        for i:= 0 to Length (all_relays)-1 do
          for j:= 0 to Length (all_relays [i].sh)-1 do
            begin
              sh:= all_relays [i].sh [j];

              // ��������� �����
              if StartList.StartNumbers then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= sh.StartNumberStr;
                  w:= TextWidth (st);
                  if w> cw [0] then
                    cw [0]:= w;
                end;
              // �������, ���
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              w:= TextWidth (sh.Shooter.Surname);
              if w> cw [1] then
                cw [1]:= w;
              Font.Height:= font_height_small;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.Name);
              if w> cw [1] then
                cw [1]:= w;
              // ���� �������� (������)
              Font.Height:= font_height_large;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.BirthFullStr);
              if w> cw [2] then
                cw [2]:= w;
              // ������������
              Font.Height:= font_height_large;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.QualificationName);
              if w> cw [3] then
                cw [3]:= w;
              // ������, �����
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              w:= TextWidth (sh.Shooter.RegionsAbbr);
              if w> cw [4] then
                cw [4]:= w;
              Font.Height:= font_height_small;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.Town);
              if w> cw [4] then
                cw [4]:= w;
              // ����
              Font.Height:= font_height_large;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.SocietyAndClub);
              if w> cw [5] then
                cw [5]:= w;
              // ���
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              w:= TextWidth (IntToStr (sh.Position));
              if w> cw [6] then
                cw [6]:= w;
              // ��� 2
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              w:= TextWidth (IntToStr (sh.Position2));
              if w> cw [7] then
                cw [7]:= w;
              // ��
              Font.Height:= font_height_large;
              Font.Style:= [];
              if sh.OutOfRank then
                w:= TextWidth (OUT_OF_RANK_MARK)
              else
                w:= 0;
              if w> cw [8] then
                cw [8]:= w;
              // �� �� �������
              Font.Height:= font_height_large;
              Font.Style:= [];
              if (a_teams) and (sh.TeamForPoints= '') then
                w:= TextWidth (NOT_FOR_TEAM_MARK)
              else
                w:= 0;
              if w> cw [9] then
                cw [9]:= w;
              // �� �� �����
              Font.Height:= font_height_large;
              Font.Style:= [];
              if (a_districts) and (not sh.GiveDistrictPoints) then
                w:= TextWidth (NOT_FOR_TEAM_MARK)
              else
                w:= 0;
              if w> cw [10] then
                cw [10]:= w;
              // �� �� ������
              Font.Height:= font_height_large;
              Font.Style:= [];
              if (a_regions) and (not sh.GiveRegionPoints) then
                w:= TextWidth (NOT_FOR_TEAM_MARK)
              else
                w:= 0;
              if w> cw [11] then
                cw [11]:= w;
            end;
        sep:= _printer.MM2PX (separator/2);
        for i:= 0 to 11 do
          begin
            if cw [i]> 0 then
              begin
                inc (cw [i],sep);
                sep:= _printer.MM2PX (separator);
              end;
          end;
        for i:= 11 downto 0 do
          begin
            if cw [i]> 0 then
              begin
                cw [i]:= cw [i]-_printer.MM2PX (separator)+_printer.MM2PX (separator/2);
                break;
              end;
          end;
      end;
    w:= 0;
    for i:= 0 to 11 do
      inc (w,cw [i]);
    if w<= _printer.Width then
      begin
        cw [1]:= cw [1]+_printer.Width-w;
        Result:= true;
      end
    else
      Result:= false;
  end;

  procedure MakeTitle;
  var
    s: TStrings;
    ii: integer;
    st: string;
    x,w: integer;
  begin
    with _printer.Canvas do // header
      begin
        if page_idx= 1 then
          begin
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            s:= TStringList.Create;
            s.Text:= Info.TitleText;
            for ii:= 0 to s.Count-1 do
              begin
                st:= s [ii];
                TextOut ((_printer.Left+_printer.Right-TextWidth (st)) div 2,y,st);
                y:= y+TextHeight ('Mg');
              end;
            if s.Count> 0 then
              y:= y+_printer.MM2PY (1);
            s.Free;

            // ��������
            Font.Style:= [fsBold];
            st:= START_LIST_PAGE_TITLE;
            TextOut ((_printer.Left+_printer.Right-TextWidth (st)) div 2,y,st);
            y:= y+TextWidth ('Mg')+_printer.MM2PY (1);
            // ����������
            Font.Style:= [fsBold];
            x:= _printer.Left;
            st:= Event.ShortName;
            TextOut (x,y,st);
            Font.Style:= [];
            st:= Event.Name;
            TextOut (_printer.Right-TextWidth (st),y,st);
            y:= y+TextHeight ('Mg')+_printer.MM2PY (2);
          end
        else
          begin
            // ����������
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            x:= _printer.Left;
            st:= Event.ShortName;
            TextOut (x,y,st);
            Font.Style:= [];
            st:= Event.Name;
            w:= TextWidth (st);
            TextOut (_printer.Right-w,y,st);
            y:= y+TextHeight ('Mg');
            Font.Height:= font_height_large;
            Font.Style:= [];
            // �����������
            st:= START_LIST_CONTINUE_MARK;
            w:= TextWidth (st);
            TextOut (_printer.Right-w,y,st);
            y:= y+TextHeight ('Mg')+_printer.MM2PY (2);
          end;
      end;
    firstrelayonpage:= true;
  end;

var
  relay_idx: integer;

  procedure MakeNewPage;
  var
    st: string;
  begin
    if page_idx> 1 then
      begin
        _printer.NewPage;
      end;
    with _printer.Canvas do   // footer
      begin
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
        y:= y+TextHeight ('Mg');
        st:= PROTOCOL_MAKER_SIGN;
        TextOut (_printer.Left,y,st);
      end;
    y:= _printer.Top;
  end;

  procedure MakeRelayHeader;
  var
    w: integer;
    st: string;
    h: integer;
  begin
    _printer.Canvas.Font.Height:= font_height_large;
    _printer.Canvas.Font.Style:= [];
    if relay_idx> 0 then
      y:= y+_printer.Canvas.TextHeight ('Mg');

    if not firstrelayonpage then
      begin
        h:= _printer.MM2PY (1)+_printer.MM2PY (1)+_printer.Canvas.TextHeight ('Mg')*2;
        if (Event.FinalPlaces> 0) and (HasFinal) then
          h:= h+_printer.Canvas.TextHeight ('Mg');
        h:= h+Length (all_relays [relay_idx].sh)*lineheight;
        if _printer.Bottom-footerheight-y<= h then
          begin
            inc (page_idx);
            MakeNewPage;
            MakeTitle;
          end;
      end;

    _printer.Canvas.MoveTo (_printer.Left,y);
    _printer.Canvas.LineTo (_printer.Right,y);
    y:= y+_printer.MM2PY (1);
    // ���� 1
    if not SameDate (all_relays [relay_idx].dt1,all_relays [relay_idx].dt2) then
      begin
        st:= FormatDateTime ('d-mm-yyyy',all_relays [relay_idx].dt1);
        _printer.Canvas.TextOut (_printer.Left,y,st);
      end;
    // ����� 1
    st:= FormatDateTime (RF_START_TIME_1,all_relays [relay_idx].dt1);
    w:= _printer.Canvas.TextWidth (st);
    _printer.Canvas.TextOut (_printer.Right-w,y,st);
    y:= y+_printer.Canvas.TextHeight ('Mg');

    // ���� 2
    st:= FormatDateTime ('d-mm-yyyy',all_relays [relay_idx].dt2);
    _printer.Canvas.TextOut (_printer.Left,y,st);
    // ����� 2
    st:= FormatDateTime (RF_START_TIME_2,all_relays [relay_idx].dt2);
    w:= _printer.Canvas.TextWidth (st);
    _printer.Canvas.TextOut (_printer.Right-w,y,st);
    // �����
    _printer.Canvas.Font.Style:= [fsBold];
    st:= format (RELAY_NO,[relay_idx+1]);
    w:= _printer.Canvas.TextWidth (st);
    _printer.Canvas.TextOut ((_printer.Left+_printer.Right-w) div 2,y,st);
    y:= y+_printer.Canvas.TextHeight ('Mg');

    if (Event.FinalPlaces> 0) and (HasFinal) then
      begin
        _printer.Canvas.Font.Style:= [];
        if not SameDate (FinalTime,all_relays [relay_idx].dt2) then
          begin
            st:= FormatDateTime ('d-mm-yyyy',FinalTime);
            _printer.Canvas.TextOut (_printer.Left,y,st);
          end;
        st:= FormatDateTime (FINAL_TIME,FinalTime);
        w:= _printer.Canvas.TextWidth (st);
        _printer.Canvas.TextOut (_printer.Right-w,y,st);
        y:= y+_printer.Canvas.TextHeight ('Mg');
      end;

    y:= y+_printer.MM2PY (1);
    _printer.Canvas.MoveTo (_printer.Left,y);
    _printer.Canvas.LineTo (_printer.Right,y);
    y:= y+_printer.MM2PY (1);
    firstrelayonpage:= false;
  end;

  function MeasureLineHeight: integer;
  begin
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Result:= TextHeight ('Mg');
        Font.Height:= font_height_small;
        Result:= Result+TextHeight ('Mg');
        Result:= Result+_printer.MM2PY (1.5);
      end;
  end;

  procedure MakeSignature;
  var
    x,y: integer;
  begin
    with _printer.Canvas do
      begin
        y:= _printer.Bottom-footerheight-signatureheight+_printer.MM2PY (5);
        Font.Style:= [];
        Font.Height:= font_height_large;
        x:= _printer.Left+_printer.MM2PX (3);
        TextOut (x,y,SECRETERY_TITLE);
        y:= y+TextHeight ('Mg');
        TextOut (x,y,Info.SecreteryCategory);
        x:= _printer.Right-_printer.MM2PX (3)-TextWidth (Info.Secretery);
        TextOut (x,y,Info.Secretery);
      end;
  end;

var
  j: integer;
  x,w,y1: integer;
  st: string;
  Reg: TRegistry;
begin
  if Prn= nil then
    begin
      Prn:= Printer;
      if Prn= nil then
        exit;
    end;

  a_teams:= (StartList.HaveTeams) and (PTeamsPoints.Count> 0);
  a_regions:= (HasRegionsPoints) and (RegionsPoints.Count> 0);
  a_districts:= (HasDistrictsPoints) and (DistrictsPoints.Count> 0);
  Shooters.SortOrder:= soPosition;
  SetLength (all_relays,0);
  for relay_idx:= 0 to Relays.Count-1 do
    begin
      SetLength (all_relays,Length (all_relays)+1);
      SetLength (all_relays [Length (all_relays)-1].sh,0);
      for j:= 0 to Shooters.Count-1 do
        if Shooters.Items [j].Relay= Relays [relay_idx] then
          begin
            SetLength (all_relays [Length (all_relays)-1].sh,
              Length (all_relays [Length (all_relays)-1].sh)+1);
            all_relays [Length (all_relays)-1].dt1:= Relays [relay_idx].StartTime;
            all_relays [Length (all_relays)-1].dt2:= Relays [relay_idx].StartTime2;
            all_relays [Length (all_relays)-1].sh [Length (all_relays [Length (all_relays)-1].sh)-1]:=
              Shooters.Items [j];
          end;
      if Length (all_relays [Length (all_relays)-1].sh)= 0 then
        SetLength (all_relays,Length (all_relays)-1);
    end;
  if Length (all_relays)= 0 then
    exit;

  _printer:= TMyPrinter.Create (Prn);
  _printer.PageSize:= psA4;
  _printer.Orientation:= poPortrait;
  if _printer.PDF<> nil then
    begin
      _printer.PDF.ProtectionEnabled:= true;
      _printer.PDF.ProtectionOptions:= [coPrint];
      _printer.PDF.Compression:= ctFlate;
    end;
  _printer.Title:= format (START_LIST_PRINT_TITLE,[Event.ShortName]);
  _printer.Copies:= ACopies;
  _printer.BeginDoc;
  _printer.SetBordersMM (20,15,10,5);

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

  with _printer.Canvas.Font do
    begin
      Name:= font_name;
      Charset:= PROTOCOL_CHARSET;
      Size:= font_size;
      font_height_large:= Height;
      font_height_small:= round (font_height_large * 4/5);
    end;

  repeat
    with _printer.Canvas do
      begin
        Font.Height:= font_height_small;
        footerheight:= TextHeight ('Mg')*2+_printer.MM2PY (4);
        Font.Height:= font_height_large;
        signatureheight:= TextHeight ('Mg')*2+_printer.MM2PY (5)+_printer.MM2PY (5);
      end;
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
            for relay_idx:= 0 to Length (all_relays)-1 do
              SetLength (all_relays [relay_idx].sh,0);
            SetLength (all_relays,0);
            exit;
          end;
      end;
  until false;

  lineheight:= MeasureLineHeight;

  page_idx:= 1;
  MakeNewPage;
  MakeTitle;
  for relay_idx:= 0 to Length (all_relays)-1 do
    begin
      MakeRelayHeader;
      for j:= 0 to Length (all_relays [relay_idx].sh)-1 do
        begin
          sh:= all_relays [relay_idx].sh [j];

          if y+lineheight> _printer.Bottom-footerheight then
            begin
              inc (page_idx);
              MakeNewPage;
              MakeTitle;
            end;

          x:= _printer.Left;

          with _printer.Canvas do
            begin
              // ��������� �����
              if StartList.StartNumbers then
                begin
                  Font.Style:= [];
                  Font.Height:= font_height_large;
                  st:= sh.StartNumberStr;
                  w:= TextWidth (st);
                  TextOut (x+cw [0]-_printer.MM2PX (separator/2)-w,y,st);
                  x:= x+cw [0];
                end;

              // ������� (������� ������)
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              st:= sh.Shooter.Surname;
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              y1:= y+TextHeight ('Mg');
              Font.Style:= [];
              Font.Height:= font_height_small;
              // ��� + �������� (���� ����)
              if sh.Shooter.StepName<> '' then
                st:= sh.Shooter.Name+' '+sh.Shooter.StepName
              else
                st:= sh.Shooter.Name;
              TextOut (x+_printer.MM2PX (separator/2),y1,st);
              x:= x+cw [1];

              // ���� �������� (������)
              Font.Style:= [];
              Font.Height:= font_height_large;
              st:= sh.Shooter.BirthFullStr;
              w:= TextWidth (st);
              TextOut (x+cw [2]-_printer.MM2PX (separator/2)-w,y,st);
              x:= x+cw [2];

              // ������������
              Font.Style:= [];
              Font.Height:= font_height_large;
              st:= sh.Shooter.QualificationName;
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              x:= x+cw [3];

              // ������, �����
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              st:= sh.Shooter.RegionsAbbr;
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              y1:= y+TextHeight ('Mg');
              Font.Height:= font_height_small;
              Font.Style:= [];
              TextOut (x+_printer.MM2PX (separator/2),y1,sh.Shooter.Town);
              x:= x+cw [4];

              // ����
              Font.Height:= font_height_large;
              Font.Style:= [];
              st:= sh.Shooter.SocietyAndClub;
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              x:= x+cw [5];

              // ��� 1
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              st:= IntToStr (sh.Position);
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              x:= x+cw [6];

              // ��� 2
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              st:= IntToStr (sh.Position2);
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              x:= x+cw [7];

              // ��
              if sh.OutOfRank then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= OUT_OF_RANK_MARK;
                  TextOut (x+_printer.MM2PX (separator/2),y,st);
                end;
              x:= x+cw [8];

              // �� �� �������
              if (a_teams) and (sh.TeamForPoints= '') then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= NOT_FOR_TEAM_MARK;
                  TextOut (x+_printer.MM2PX (separator/2),y,st);
                end;
              x:= x+cw [9];

              // �� �� �����
              if (a_districts) and (not sh.GiveDistrictPoints) then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= NOT_FOR_TEAM_MARK;
                  TextOut (x+_printer.MM2PX (separator/2),y,st);
                end;
              x:= x+cw [10];

              // �� �� ������
              if (a_regions) and (not sh.GiveRegionPoints) then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= NOT_FOR_TEAM_MARK;
                  TextOut (x+_printer.MM2PX (separator/2),y,st);
                end;
//              x:= x+cw [10];
            end;

          firstrelayonpage:= false;

          inc (y,lineheight);
        end;
    end;
  if y+signatureheight> _printer.Bottom-footerheight then
    begin
      inc (page_idx);
      MakeNewPage;
      MakeTitle;
    end;
  MakeSignature;
  _printer.EndDoc;
  _printer.Free;

  for relay_idx:= 0 to Length (all_relays)-1 do
    SetLength (all_relays [relay_idx].sh,0);
  SetLength (all_relays,0);
end;

{type
  trelayshootersarray= record
    sh: array of TStartListEventShooterItem;
    dt,dt2: TDateTime;
    ft: TDateTime;
  end;}

procedure TStartListEventItem.PrintRegularStartList (Prn: TObject; ACopies: integer);
const
  separator= 4;
var
  _printer: TMyPrinter;
  all_relays: array of trelayshootersarray;
  i,j: integer;
  font_height_large: integer;
  font_height_small: integer;
  footerheight,signatureheight: integer;
  cw: array [0..32] of integer;
  sh: TStartListEventShooterItem;
  w: integer;
  page_idx: integer;
  y1,y,x: integer;
  lineheight: integer;
  st: string;
  idx: integer;
  font_name: string;
  font_size: integer;
  a_teams,a_regions,a_districts: boolean;
  print_date: boolean;

  function MeasureColumns: boolean;
  var
    i,j: integer;
    idx: integer;
    sep: integer;
  begin
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        cw [0]:= 0;
        cw [1]:= 0;         // ��������� �����
        cw [2]:= 0;                         // �������, ���
        cw [3]:= 0;         // ��� ��������
        cw [4]:= 0;                        // ������������
        cw [5]:= 0;                        // ������� ���������
        cw [6]:= 0;                          // ����������� (����)
        cw [7]:= 0;         // ���
        cw [8]:= 0;         // ��
        cw [9]:= 0;         // �� �� �������
        cw [10]:= 0;        // �� �� �����
        cw [11]:= 0;        // �� �� ������
        idx:= 1;
        for i:= 0 to Length (all_relays)-1 do
          for j:= 0 to Length (all_relays [i].sh)-1 do
            begin
              sh:= all_relays [i].sh [j];

              // ���������� �����
              if Event.EventType in [etMovingTarget,etMovingTarget2013] then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  w:= TextWidth (IntToStr (idx));
                  if w> cw [0] then
                    cw [0]:= w;
                end;
              // ��������� �����
              if StartList.StartNumbers then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= sh.StartNumberStr;
                  w:= TextWidth (st);
                  if w> cw [1] then
                    cw [1]:= w;
                end;
              // �������, ��� + �������� (�� ������ ������)
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              w:= TextWidth (sh.Shooter.Surname);
              if w> cw [2] then
                cw [2]:= w;
              Font.Height:= font_height_small;
              Font.Style:= [];
              // ��� �������� �� ������ ������ ��� ��������
              if sh.Shooter.StepName<> '' then
                st:= sh.Shooter.Name+' '+sh.Shooter.StepName
              else
                st:= sh.Shooter.Name;
              w:= TextWidth (st);
              if w> cw [2] then
                cw [2]:= w;
              // ���� �������� (���������)
              Font.Height:= font_height_large;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.BirthFullStr);
              if w> cw [3] then
                cw [3]:= w;
              // ������������
              Font.Height:= font_height_large;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.QualificationName);
              if w> cw [4] then
                cw [4]:= w;
              // ������, �����
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              w:= TextWidth (sh.Shooter.RegionsAbbr);
              if w> cw [5] then
                cw [5]:= w;
              Font.Height:= font_height_small;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.Town);
              if w> cw [5] then
                cw [5]:= w;
              // ����
              Font.Height:= font_height_large;
              Font.Style:= [];
              w:= TextWidth (sh.Shooter.SocietyAndClub);
              if w> cw [6] then
                cw [6]:= w;
              // ���
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              w:= TextWidth (IntToStr (sh.Position));
              if w> cw [7] then
                cw [7]:= w;
              // ��
              Font.Height:= font_height_large;
              Font.Style:= [];
              if sh.OutOfRank then
                w:= TextWidth (OUT_OF_RANK_MARK)
              else
                w:= 0;
              if w> cw [8] then
                cw [8]:= w;
              // �� �� �������
              Font.Height:= font_height_large;
              Font.Style:= [];
              if (a_teams) and (sh.TeamForPoints= '') then
                w:= TextWidth (NOT_FOR_TEAM_MARK)
              else
                w:= 0;
              if w> cw [9] then
                cw [9]:= w;
              // �� �� �����
              Font.Height:= font_height_large;
              Font.Style:= [];
              if (a_districts) and (not sh.GiveDistrictPoints) then
                w:= TextWidth (NOT_FOR_TEAM_MARK)
              else
                w:= 0;
              if w> cw [10] then
                cw [10]:= w;
              // �� �� ������
              Font.Height:= font_height_large;
              Font.Style:= [];
              if (a_regions) and (not sh.GiveRegionPoints) then
                w:= TextWidth (NOT_FOR_TEAM_MARK)
              else
                w:= 0;
              if w> cw [11] then
                cw [11]:= w;
              inc (idx);
            end;
        sep:= _printer.MM2PX (separator/2);
        for i:= 0 to 11 do
          begin
            if cw [i]> 0 then
              begin
                inc (cw [i],sep);
                sep:= _printer.MM2PX (separator);
              end;
          end;
        for i:= 11 downto 0 do
          begin
            if cw [i]> 0 then
              begin
                cw [i]:= cw [i]-_printer.MM2PX (separator)+_printer.MM2PX (separator/2);
                break;
              end;
          end;
      end;
    w:= 0;
    for i:= 0 to 11 do
      inc (w,cw [i]);
    if w<= _printer.Width then
      begin
        cw [2]:= cw [2]+_printer.Width-w;
        Result:= true;
      end
    else
      Result:= false;
  end;

  procedure MakeNewPage;
  var
    st: string;
  begin
    if (page_idx> 1) or (idx> 1) then
      begin
        _printer.NewPage;
      end;
    with _printer.Canvas do   // footer
      begin
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
        y:= y+TextHeight ('Mg');
        st:= PROTOCOL_MAKER_SIGN;
        TextOut (_printer.Left,y,st);
      end;
    y:= _printer.Top;
  end;

  procedure MakeHeader;
  var
    s: TStrings;
    ii: integer;
  begin
    with _printer.Canvas do // header
      begin
        Font.Height:= font_height_large;

        if page_idx= 1 then
          begin
            Font.Style:= [fsBold];
            s:= TStringList.Create;
            s.Text:= Info.TitleText;
            for ii:= 0 to s.Count-1 do
              begin
                st:= s [ii];
                x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
                TextOut (x,y,st);
                y:= y+TextHeight ('Mg');
              end;
            if s.Count> 0 then
              y:= y+_printer.MM2PY (2);
            s.Free;
          end;

        if page_idx= 1 then
          begin
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= START_LIST_PAGE_TITLE;
            x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
            TextOut (x,y,st);
            y:= y+TextHeight ('Mg')+_printer.MM2PY (2);
          end;

        Font.Style:= [fsBold];
        x:= _printer.Left;
        st:= Event.ShortName;
        TextOut (x,y,st);
        Font.Style:= [];
        st:= Event.Name;
        w:= TextWidth (st);
        TextOut (_printer.Right-w,y,st);
        y:= y+TextHeight ('Mg');

        if page_idx= 1 then
          begin
            Font.Style:= [];
            if Event.EventType in [etRegular,etMovingTarget,etThreePosition2013,etMovingTarget2013] then
              begin
                st:= FormatDateTime (START_TIME,all_relays [i].dt1);
                x:= _printer.Right-TextWidth (st);
                TextOut (x,y,st);
              end
            else if Event.EventType in [etCenterFire,etCenterFire2013] then
              begin
                  begin
                if SameDate (all_relays [i].dt1,all_relays [i].dt2) then
                  st:= FormatDateTime (CF_START_TIME_1,all_relays [i].dt1)
                else
                  begin
                    st:= FormatDateTime (CF_START_DATETIME_1,all_relays [i].dt1);
                    print_date:= false;
                  end;
                x:= _printer.Right-TextWidth (st);
                TextOut (x,y,st);
                y:= y+TextHeight ('Mg');
                if SameDate (all_relays [i].dt1,all_relays [i].dt2) then
                  st:= FormatDateTime (CF_START_TIME_2,all_relays [i].dt2)
                else
                  st:= FormatDateTime (CF_START_DATETIME_2,all_relays [i].dt2);
                x:= _printer.Right-TextWidth (st);
                TextOut (x,y,st);
                  end;
              end;
            if (Event.FinalPlaces> 0) and (HasFinal) then
              begin
                y:= y+TextHeight ('Mg');
                Font.Style:= [];
                if SameDate (FinalTime,all_relays [i].dt1) and SameDate (FinalTime,all_relays [i].dt2) then
                  st:= FormatDateTime (FINAL_TIME,FinalTime)
                else
                  st:= FormatDateTime (FINAL_DATETIME,FinalTime);
                x:= _printer.Right-TextWidth (st);
                TextOut (x,y,st);
              end;
          end
        else
          begin
            Font.Style:= [];
            st:= START_LIST_CONTINUE_MARK;
            x:= _printer.Right-TextWidth (st);
            TextOut (x,y,st);
          end;

        // ����
        if print_date then
          begin
            x:= _printer.Left;
            TextOut (x,y,FormatDateTime ('d-mm-yyyy',all_relays [i].dt1));
          end;

        // �����
        if Event.EventType in [etRegular,etCenterFire,etCenterFire2013,etThreePosition2013] then
          begin
            Font.Style:= [fsBold];
            st:= Format (RELAY_NO,[i+1]);
            x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
            TextOut (x,y,st);
          end
        else if Event.EventType in [etMovingTarget,etMovingTarget2013] then
          begin
            Font.Style:= [fsBold];
            st:= Format (MT_RELAY_NO,[i+1]);
            x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
            TextOut (x,y,st);
          end;

        y:= y+TextHeight ('Mg')+_printer.MM2PY (2);
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
      end;
  end;

  function MeasureLineHeight: integer;
  begin
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Result:= TextHeight ('Mg');
        Font.Height:= font_height_small;
        Result:= Result+TextHeight ('Mg');
        Result:= Result+_printer.MM2PY (1.5);
      end;
  end;

  procedure MakeSignature;
  var
    y,x: integer;
  begin
    with _printer.Canvas do
      begin
        y:= _printer.Bottom-footerheight-signatureheight+_printer.MM2PY (5);
        Font.Style:= [];
        Font.Height:= font_height_large;
        x:= _printer.Left+_printer.MM2PX (3);
        TextOut (x,y,SECRETERY_TITLE);
        y:= y+TextHeight ('Mg');
        TextOut (x,y,Info.SecreteryCategory);
        x:= _printer.Right-_printer.MM2PX (3)-TextWidth (Info.Secretery);
        TextOut (x,y,Info.Secretery);
      end;
  end;

begin
  if Prn= nil then
    begin
      Prn:= Printer;
      if Prn= nil then
        exit;
    end;

  a_teams:= (StartList.HaveTeams) and (PTeamsPoints.Count> 0) and (HasTeamsForPoints);
  a_regions:= (HasRegionsPoints) and (RegionsPoints.Count> 0);
  a_districts:= (HasDistrictsPoints) and (DistrictsPoints.Count> 0);
  Shooters.SortOrder:= soPosition;
  SetLength (all_relays,0);
  for i:= 0 to Relays.Count-1 do
    begin
      SetLength (all_relays,Length (all_relays)+1);
      SetLength (all_relays [Length (all_relays)-1].sh,0);
      for j:= 0 to Shooters.Count-1 do
        if Shooters.Items [j].Relay= Relays [i] then
          begin
            SetLength (all_relays [Length (all_relays)-1].sh,
              Length (all_relays [Length (all_relays)-1].sh)+1);
            all_relays [Length (all_relays)-1].dt1:= Relays [i].StartTime;
            all_relays [Length (all_relays)-1].dt2:= Relays [i].StartTime2;
            all_relays [Length (all_relays)-1].sh [Length (all_relays [Length (all_relays)-1].sh)-1]:=
              Shooters.Items [j];
          end;
      if Length (all_relays [Length (all_relays)-1].sh)= 0 then
        SetLength (all_relays,Length (all_relays)-1);
    end;
  if Length (all_relays)= 0 then
    exit;

  _printer:= TMyPrinter.Create (Prn);
  _printer.Orientation:= poPortrait;
  _printer.Copies:= ACopies;
  _printer.PageSize:= psA4;
  if _printer.PDF<> nil then
    begin
      _printer.PDF.ProtectionEnabled:= true;
      _printer.PDF.ProtectionOptions:= [coPrint];
      _printer.PDF.Compression:= ctFlate;
    end;
  _printer.Title:= Format (START_LIST_PRINT_TITLE,[Event.ShortName]);
  _printer.BeginDoc;
  _printer.SetBordersMM (20,15,10,5);

  GetDefaultProtocolFont (font_name,font_size);

  with _printer.Canvas.Font do
    begin
      Name:= font_name;
      Charset:= PROTOCOL_CHARSET;
      Size:= font_size;
      font_height_large:= Height;
      font_height_small:= round (font_height_large * 4/5);
    end;

  repeat
    with _printer.Canvas do
      begin
        Font.Height:= font_height_small;
        footerheight:= TextHeight ('Mg')*2+_printer.MM2PY (4);
        Font.Height:= font_height_large;
        signatureheight:= TextHeight ('Mg')*2+_printer.MM2PY (5)+_printer.MM2PY (5);
      end;
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
            for i:= 0 to Length (all_relays)-1 do
              SetLength (all_relays [i].sh,0);
            SetLength (all_relays,0);
            exit;
          end;
      end;
  until false;

  idx:= 1;
  for i:= 0 to Length (all_relays)-1 do
    begin
      print_date:= true;
      page_idx:= 1;
      MakeNewPage;
      MakeHeader;
      for j:= 0 to Length (all_relays [i].sh)-1 do
        begin
          sh:= all_relays [i].sh [j];

          lineheight:= MeasureLineHeight;

          if y+lineheight> _printer.Bottom-footerheight then
            begin
              inc (page_idx);
              MakeNewPage;
              MakeHeader;
            end
          else if (j= Length (all_relays [i].sh)-2) and
                  (y+lineheight*2+signatureheight> _printer.Bottom-footerheight) then
            begin
              inc (page_idx);
              MakeNewPage;
              MakeHeader;
            end;

          x:= _printer.Left;

          with _printer.Canvas do
            begin
              // ���������� �����
              if Event.EventType in [etMovingTarget,etMovingTarget2013] then
                begin
                  Font.Style:= [];
                  Font.Height:= font_height_large;
                  st:= IntToStr (idx);
                  w:= TextWidth (st);
                  TextOut (x+cw [0]-_printer.MM2PX (separator/2)-w,y,st);
                  x:= x+cw [0];
                end;

              // ��������� �����
              if StartList.StartNumbers then
                begin
                  Font.Style:= [];
                  Font.Height:= font_height_large;
                  st:= sh.StartNumberStr;
                  w:= TextWidth (st);
                  TextOut (x+cw [1]-_printer.MM2PX (separator/2)-w,y,st);
                  x:= x+cw [1];
                end;

              // �������, ��� + �������� (�� ������ ������)
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              st:= sh.Shooter.Surname;
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              y1:= y+TextHeight ('Mg');
              Font.Style:= [];
              Font.Height:= font_height_small;
              if sh.Shooter.StepName<> '' then
                st:= sh.Shooter.Name+' '+sh.Shooter.StepName
              else
                st:= sh.Shooter.Name;
              TextOut (x+_printer.MM2PX (separator/2),y1,st);
              x:= x+cw [2];

              // ���� �������� (���������)
              Font.Style:= [];
              Font.Height:= font_height_large;
              st:= sh.Shooter.BirthFullStr;
              w:= TextWidth (st);
              TextOut (x+cw [3]-_printer.MM2PX (separator/2)-w,y,st);
              x:= x+cw [3];

              // ������������
              Font.Style:= [];
              Font.Height:= font_height_large;
              st:= sh.Shooter.QualificationName;
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              x:= x+cw [4];

              // ������, �����
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              st:= sh.Shooter.RegionsAbbr;
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              y1:= y+TextHeight ('Mg');
              Font.Height:= font_height_small;
              Font.Style:= [];
              TextOut (x+_printer.MM2PX (separator/2),y1,sh.Shooter.Town);
              x:= x+cw [5];

              // ����
              Font.Height:= font_height_large;
              Font.Style:= [];
              st:= sh.Shooter.SocietyAndClub;
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              x:= x+cw [6];

              // ���
              Font.Height:= font_height_large;
              Font.Style:= [fsBold];
              st:= IntToStr (sh.Position);
              TextOut (x+_printer.MM2PX (separator/2),y,st);
              x:= x+cw [7];

              // ��
              if sh.OutOfRank then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= OUT_OF_RANK_MARK;
                  TextOut (x+_printer.MM2PX (separator/2),y,st);
                end;
              x:= x+cw [8];

              // �� �� �������
              if (a_teams) and (sh.TeamForPoints= '') then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= NOT_FOR_TEAM_MARK;
                  TextOut (x+_printer.MM2PX (separator/2),y,st);
                end;
              x:= x+cw [9];

              // �� �� �����
              if (a_districts) and (not sh.GiveDistrictPoints) then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= NOT_FOR_TEAM_MARK;
                  TextOut (x+_printer.MM2PX (separator/2),y,st);
                end;
              x:= x+cw [10];

              // �� �� ������
              if (a_regions) and (not sh.GiveRegionPoints) then
                begin
                  Font.Height:= font_height_large;
                  Font.Style:= [];
                  st:= NOT_FOR_TEAM_MARK;
                  TextOut (x+_printer.MM2PX (separator/2),y,st);
                end;
//              x:= x+cw [10];
            end;

          inc (y,lineheight);
          inc (idx);
        end;
      if y+signatureheight> _printer.Bottom-footerheight then
        begin
          inc (page_idx);
          MakeNewPage;
          MakeHeader;
        end;
      MakeSignature;
    end;
  _printer.EndDoc;
  _printer.Free;

  for i:= 0 to Length (all_relays)-1 do
    SetLength (all_relays [i].sh,0);
  SetLength (all_relays,0);
end;

procedure TStartListEventItem.set_HasFinal (const Value: boolean);
begin
  if Value<> fHasFinal then
    begin
      fHasFinal:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventItem.set_InPointsTable(const Value: boolean);
begin
  if Value<> fInPointsTable then
    begin
      fInPointsTable:= Value;
      fChanged:= true;
    end;
end;

function TStartListEventItem.HasDistrictsPoints: boolean;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= false;
  if DistrictsPoints.Count= 0 then
    exit;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (sh.GiveDistrictPoints) and (sh.Shooter.DistrictAbbr<> '') then
        begin
          Result:= true;
          break;
        end;
    end;
end;

function TStartListEventItem.HasRegionsPoints: boolean;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= false;
  if RegionsPoints.Count= 0 then
    exit;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (sh.GiveRegionPoints) and ((sh.Shooter.RegionAbbr1<> '') or (sh.Shooter.RegionAbbr2<> '')) then
        begin
          Result:= true;
          break;
        end;
    end;
end;

function TStartListEventItem.HasTeamsForPoints: boolean;
var
  sh: TStartListEventShooterItem;
  i: integer;
begin
  Result:= false;
  if PTeamsPoints.Count= 0 then
    exit;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if sh.TeamForPoints<> '' then
        begin
          Result:= true;
          break;
        end;
    end;
end;

function TStartListEventItem.HasTeamsForResult: boolean;
var
  sh: TStartListEventShooterItem;
  i: integer;
begin
  Result:= false;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if sh.TeamForResults<> '' then
        begin
          Result:= true;
          break;
        end;
    end;
end;

type
  TEventPointsTeamStats= record
    team: string;
    points: integer;
    rank: integer;
  end;
  TEventRegionStats= record
    _abbr: string;
    _name: string;
    points: integer;
  end;
  TEventDistrictStats= record
    _abbr: string;
    _name: string;
    points: integer;
  end;
  type
  TTechCell= record
    qual: integer;
    count: integer;
  end;
  TTechRow= record
    count: integer;
    qual: integer;
    cells: array of TTechCell;
  end;

procedure TStartListEventItem.PrintResults (Prn: TObject; AFinal: boolean;
  ATeams: boolean; ATeamPoints: boolean; ARegionPoints: boolean;
  ADistrictPoints: boolean; AReport: boolean; ACopies: integer;
  StartDoc: boolean);
var
  font_height_large,font_height_small: integer;
  footerheight: integer;
  cw: array [0..31] of integer;
  page_idx: integer;
  y: integer;
  lineheight: integer;
  thl,ths: integer;
  font_name: string;
  font_size: integer;
  xsep,ysep: integer;
  current_page_top: integer;
  _printer: TMyPrinter;

  function MeasureColumns: boolean;
  var
    i,j: integer;
    sh: TStartListEventShooterItem;
    st: string;
    w: integer;
    //bytotal: boolean;
  begin
    with _printer.Canvas do
      begin
        cw [0]:= 0;     // �����
        cw [1]:= 0;     // ��������� �����
        cw [2]:= 0;     // �������, ���
        cw [3]:= 0;     // ��� ��������
        cw [4]:= 0;     // ������������
        cw [5]:= 0;     // �������, �����
        cw [6]:= 0;     // �����
        cw [7]:= 0;     // ����
        cw [8]:= 0;     // ����������
        cw [9]:= 0;     // ����� ���������
        cw [10]:= 0;     // ����� �������� �����
        cw [11]:= 0;    // ����������� ��������
        cw [12]:= 0;    // �����������/�����������
        cw [13]:= 0;    // ����� �� �������
        cw [14]:= 0;    // ����� �� ��������
        cw [15]:= 0;    // ����� �� �����
        cw [16]:= 0;    // ����� �� ������
        cw [17]:= 0;    // ��������� � �������  (�� ��������� �������)
        Font.Style:= [];
        Font.Height:= font_height_small;
        // For paired events, need space for two sets of series plus sums
        if IsPairedEvent then
          begin
            // Width for: Shooter1 series + Shooter2 series + Sums
            cw [8]:= TextWidth (SerieTemplate)*Event.SeriesPerStage*2+_printer.MM2PX (1)*(Event.SeriesPerStage*2-1);
            cw [9]:= TextWidth (SerieTemplate)*2+_printer.MM2PX (1); // Space for pair sums per stage
          end
        else
          cw [8]:= TextWidth (SerieTemplate)*Event.SeriesPerStage+_printer.MM2PX (1)*(Event.SeriesPerStage-1);
        Font.Height:= font_height_large;

        for i:= 0 to Shooters.Count-1 do
          begin
            sh:= Shooters.Items [i];

            Font.Height:= font_height_large;
            Font.Style:= [];
            if (sh.DNS<> dnsCompletely) then
              begin
                if sh.OutOfRank then
                  st:= OUT_OF_RANK_MARK
                else if (HasFinal) and (i< Event.FinalPlaces) then
                  st:= FINAL_MARK
                else
                  st:= IntToStr (i+1);
                w:= TextWidth (st);
                if w> cw [0] then
                  cw [0]:= w;
              end;

{            if StartList.Info.StartNumbers then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [];
                st:= sh.StartNumberStr;
                w:= TextWidth (st);
                if w> cw [1] then
                  cw [1]:= w;
              end;}

            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= sh.Shooter.Surname;
            w:= TextWidth (st);
            if w> cw [2] then
              cw [2]:= w;
            Font.Height:= font_height_small;
            Font.Style:= [];
            if sh.Shooter.StepName<> '' then
              st:= sh.Shooter.Name+' '+sh.Shooter.StepName
            else
              st:= sh.Shooter.Name;
            w:= TextWidth (st);
            if w> cw [2] then
              cw [2]:= w;

            Font.Height:= font_height_small;
            Font.Style:= [];
            st:= sh.Shooter.BirthFullStr;
            w:= TextWidth (st);
            if w> cw [3] then
              cw [3]:= w;

            Font.Height:= font_height_small;
            Font.Style:= [];
            st:= sh.Shooter.QualificationName;
            w:= TextWidth (st);
            if w> cw [4] then
              cw [4]:= w;

            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= sh.Shooter.RegionsAbbr;
            w:= TextWidth (st);
            if w> cw [5] then
              cw [5]:= w;
            Font.Height:= font_height_small;
            Font.Style:= [];
            st:= sh.Shooter.Town;
            w:= TextWidth (st);
            if w> cw [5] then
              cw [5]:= w;

            if ADistrictPoints then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [fsBold];
                st:= sh.Shooter.DistrictAbbr;
                w:= TextWidth (st);
                if w> cw [6] then
                  cw [6]:= w;
              end;

            Font.Height:= font_height_small;
            Font.Style:= [];
            st:= sh.Shooter.SocietyAndClub;
            w:= TextWidth (st);
            if w> cw [7] then
              cw [7]:= w;

            // cw [8] - ����������
            // cw [9] - ���������� ���������
            if (Event.Stages> 1) and (Event.SeriesPerStage> 1) then
              begin
                Font.Height:= font_height_small;
                Font.Style:= [fsBold];
                for j:= 1 to Event.Stages do
                  begin
                    st:= sh.StageResultStr(j);
                    w:= TextWidth (st);
                    if w> cw [9] then
                      cw [9]:= w;
                  end;
              end;

            // cw[10] - �������� ��������� / ��������� ������ / ����� ���������
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            if (AFinal) and (i< Event.FinalPlaces) and (not sh.OutOfRank) then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [fsBold];
                st:= sh.CompetitionStr;
                w:= TextWidth (st);
                if w> cw [10] then
                  cw [10]:= w;
                st:= sh.FinalResultStr;
                w:= TextWidth (st);
                if w> cw [10] then
                  cw [10]:= w;
                st:= sh.TotalResultStr;
                w:= TextWidth (st);
                if w> cw [10] then
                  cw [10]:= w;
              end
            else
              begin
                st:= sh.CompetitionStr;
                w:= TextWidth (st);
                if w> cw [10] then
                  cw [10]:= w;
              end;

            // cw [11] - �����������
            Font.Height:= font_height_small;
            Font.Style:= [];
            st:= '('+sh.CompShootOffStr+')';
            w:= TextWidth (st);
            if w> cw [11] then
              cw [11]:= w;

            // cw [12] - �������� � ����� �� ����
            if sh.Qualified{ (bytotal)}<> nil then
              begin
                Font.Height:= font_height_small;
                Font.Style:= [];
                st:= sh.Qualified{ (bytotal)}.Name;
                if ((ATeamPoints) or (ARegionPoints) or (ADistrictPoints)) and
                    ((sh.TeamForPoints<> '') or (sh.GiveRegionPoints) or (sh.GiveDistrictPoints)) and
                    (sh.QualificationPoints> 0) then
                  begin
                    st:= st+' ('+IntToStr (sh.QualificationPoints)+')';
                  end;
                w:= TextWidth (st);
                if w> cw [12] then
                  cw [12]:= w;
              end;

            // cw [13] - ����� �������
            if (ATeamPoints) and (not sh.OutOfRank) then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [];
                if sh.TeamForPoints= '' then
                  begin
                    if not sh.OutOfRank then
                      begin
                        st:= NOT_FOR_TEAM_MARK;
                        w:= TextWidth (st);
                      end
                    else
                      st:= '';
                  end
                else if sh.TeamPoints> 0 then
                  begin
                    st:= IntToStr (sh.TeamPoints);
                    w:= TextWidth (st);
                  end;
                if w> cw [13] then
                  cw [13]:= w;
              end;

            // cw [14] - ����� �� �����
            if (ADistrictPoints) and (not sh.OutOfRank) and (sh.GiveDistrictPoints) and (sh.DistrictPoints> 0) then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [];
                st:= IntToStr (sh.DistrictPoints);
                w:= TextWidth (st);
                if w> cw [14] then
                  cw [14]:= w;
              end;

            // cw [15] - ����� �� ������
            if (ARegionPoints) and (not sh.OutOfRank) then
              begin
                if sh.GiveRegionPoints then
                  begin
                    if sh.RegionPoints> 0 then
                      st:= IntToStr (sh.RegionPoints)
                    else
                      st:= '';
                  end
                else
                  st:= NOT_FOR_TEAM_MARK;
                if st<> '' then
                  begin
                    Font.Height:= font_height_large;
                    Font.Style:= [];
                    w:= TextWidth (st);
                    if w> cw [15] then
                      cw [15]:= w;
                  end;
              end;

            // cw [16] - "������" �����
            if ((ATeamPoints) or (ADistrictPoints) or (ARegionPoints)) and
              (sh.ManualPoints> 0) and (not sh.OutOfRank) then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [];
                st:= IntToStr (sh.ManualPoints);
                w:= TextWidth (st);
                if w> cw [16] then
                  cw [16]:= w;
              end;

            // cw [17] - �������
            if sh.RecordComment<> '' then
              begin
                Font.Style:= [];
                Font.Height:= font_height_large;
                st:= sh.RecordComment;
                w:= TextWidth (st);
                if w> cw [17] then
                  cw [17]:= w;
              end;

            if (AFinal) and (i< Event.FinalPlaces) and (not sh.OutOfRank) then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [fsBold];
                st:= sh.TotalResultStr;
                w:= TextWidth (st);
                if w> cw [18] then
                  cw [18]:= w;
              end;
          end;

        if cw [0]> 0 then
          cw [0]:= cw [0]+xsep div 2;
        for i:= 1 to 17 do
          if cw [i]> 0 then
            cw [i]:= cw [i]+xsep;
        if cw [18]> 0 then
          cw [18]:= cw [16]+xsep div 2;

        w:= 0;
        for i:= 0 to 17 do
          inc (w,cw [i]);
        if w<= _printer.Width then
          begin
            Result:= true;
            cw [2]:= cw [2]+_printer.Width-w;
          end
        else
          Result:= false;
      end;
  end;

  procedure MakeNewPage;
  var
    x,w: integer;
    st: string;
    s: TStrings;
    ii: integer;
    dates: array of TDateTime;
    //th_l: integer;

    procedure AddDate (dt: TDateTime);
    var
      i: integer;
    begin
      dt:= DateOf (dt);
      for i:= 0 to Length (dates)-1 do
        if dates [i]= dt then
          exit;
      SetLength (dates,Length (dates)+1);
      dates [Length (dates)-1]:= dt;
    end;

  begin
    if page_idx> 1 then
      begin
        _printer.NewPage;
      end;

    with _printer.Canvas do
      begin
        // footer
        Pen.Width:= 1;
        Font.Style:= [];
        //th_l:= TextHeight ('Mg');

        y:= _printer.Bottom-ths*2-_printer.MM2PY (4)+_printer.MM2PY (2);
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
        Font.Height:= font_height_small;
        st:= format (PAGE_NO,[page_idx]);
        TextOut (_printer.Right-TextWidth (st),y,st);
        st:= format (PAGE_FOOTER,[VERSION_INFO_STR]);
        TextOut (_printer.Left,y,st);
        y:= y+thl;
        TextOut (_printer.Left,y,PROTOCOL_MAKER_SIGN);

        y:= _printer.Bottom-footerheight;
        Font.Height:= font_height_large;
        Font.Style:= [];

        // ������� �����
        if (Global_PrintJury) and (Info.Jury+Info.JuryCategory<> '') then
          begin
            y:= y+_printer.MM2PY (5);
            x:= _printer.Left+_printer.MM2PX (3);
            TextOut (x,y,JURY_TITLE);
            y:= y+thl;
            TextOut (x,y,Info.JuryCategory);
            x:= _printer.Right-_printer.MM2PX (3)-TextWidth (Info.Jury);
            TextOut (x,y,Info.Jury);
            y:= y+thl;
          end;

        // secretery
        if (Global_PrintSecretery) and (Info.Secretery+Info.SecreteryCategory<> '') then
          begin
            y:= y+_printer.MM2PY (5);
            x:= _printer.Left+_printer.MM2PX (3);
            TextOut (x,y,SECRETERY_TITLE);
            y:= y+thl;
            TextOut (x,y,Info.SecreteryCategory);
            x:= _printer.Right-_printer.MM2PX (3)-TextWidth (Info.Secretery);
            TextOut (x,y,Info.Secretery);
          end;

        // header
        y:= _printer.Top;

        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        s:= TStringList.Create;
        s.Text:= Info.TitleText;
        for ii:= 0 to s.Count-1 do
          begin
            st:= s [ii];
            w:= TextWidth (st);
            x:= (_printer.Left+_printer.Right-w) div 2;
            TextOut (x,y,st);
            inc (y,TextHeight (st));
          end;
        // ����������: ����� ������ � ��������� ��� � ����� 1 ������ �������
        if s.Count> 0 then
          y := y + TextHeight('Mg');
        s.Free;

        // ������� ������� ��������� ��� �� ������
        st:= Format (PROTOCOL_NO,[ProtocolNumber]);
        x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
        TextOut (x,y,st);
        y:= y+TextHeight ('Mg')+_printer.MM2PY (1);

        // ����� ����: �������/������� �� �������������� ����������
        case Self.Gender of
          Male: st := '�������';
          Female: st := '�������';
        else
          st := '';
        end;
        if st<>'' then
        begin
          x := (_printer.Left+_printer.Right-TextWidth(st)) div 2;
          TextOut(x,y,st);
          y := y + TextHeight('Mg');
        end;

        // � ������� �������������� � ��������� ������� �� ������
        st := '������������';
        x := (_printer.Left+_printer.Right-TextWidth(st)) div 2;
        TextOut(x,y,st);
        // ����������� �������� ����� ������������
        y := y + TextHeight('Mg') + _printer.MM2PY(2);

        x:= _printer.Left;
        st:= Event.ShortName;
        // ���� ������� �������� ������������ �� ��������� �� ��� �� � �������� ���� ������
        if (Length(st)>0) and ((st[Length(st)]='�') or (st[Length(st)]='�')) then
          Delete(st, Length(st), 1);
        TextOut (x,y,st);
        if Event.Name<> '' then
          begin
            Font.Style:= [];
            st:= Event.Name;
            w:= TextWidth (st);
            x:= _printer.Right-w;
            TextOut (x,y,st);
          end;
{        if StartNumber> 0 then
          begin
            Font.Style:= [fsBold];
            st:= IntToStr (StartNumber)+'-� �����';
            w:= TextWidth (st);
            x:= _printer.PageWidth-rightborder-w;
            TextOut (x,y,st);
          end; }
        y:= y+TextHeight ('Mg');

        Font.Style:= [];
        st:= Info.TownAndRange;
        x:= _printer.Right-TextWidth (st);
        TextOut (x,y,st);

        // �������� ��� ��������� ����
        SetLength (dates,0);
        for ii:= 0 to Relays.Count-1 do
          begin
            AddDate (Relays [ii].StartTime);
            case Event.EventType of
              etRegular: {};
              etCenterFire: {};
              etMovingTarget: {};
              etRapidFire: AddDate (Relays [ii].StartTime2);
              etCenterFire2013: {};
              etThreePosition2013: {};
              etMovingTarget2013: {};
            end;
          end;
        // ���� ���� �����, �� ��������� ���� ������
        if (Event.FinalPlaces> 0) and (AFinal) and (HasFinal) then
          AddDate (FinalTime);

        x:= _printer.Left;
        for ii:= 0 to Length (dates)-1 do
          begin
            st:= FormatDateTime ('dd-mm-yyyy',dates [ii]);
            TextOut (x,y+TextHeight ('Mg')*ii,st);
          end;
        if Length (dates)> 0 then
          y:= y+Length (dates)*thl+_printer.MM2PY (2)
        else
          y:= y+thl+_printer.MM2PY (2);
        SetLength (dates,0);
        dates:= nil;


        Pen.Width:= 1;
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
      end;

    current_page_top:= y;  // ��� ���������� ������ ���� ������
  end;

var
  sh: TStartListEventShooterItem;
  havefinalfracs: boolean;         // ��� ������ ��� ������������ ���� � �������� ��������
  sh_pair: TStartListEventShooterItem; // Second shooter in pair for paired events
  is_pair_first: boolean;          // True if current shooter is first in a pair

  function MeasureItemHeight: integer;
  var
    h1,h2,h3: integer;
    s: TStrings;
  begin
    h1:= thl+ths;
    h2:= 0;
    if sh.Shooter.RegionsAbbr<> '' then
      inc (h2,thl);
    if sh.Shooter.Town<> '' then
      inc (h2,ths);
    s:= TStringList.Create;
    s.Text:= sh.DNSComment;
    case sh.DNS of
      dnsPartially: begin
        if Event.Stages> 1 then
          h3:= Event.Stages * ths+thl-ths + ths*s.Count
        else
          h3:= thl+ths*s.Count;
      end;
      dnsCompletely: begin
        if s.Count> 0 then
          h3:= thl-ths+ths*s.Count
        else
          h3:= thl;
      end;
    else
      if Event.Stages> 1 then
        h3:= Event.Stages * ths+thl-ths
      else
        h3:= thl;
    end;
    s.Free;
    Result:= h1;
    if h2> Result then
      Result:= h2;
    if h3> Result then
      Result:= h3;
    if (AFinal) and (sh.Index< Event.FinalPlaces) and (HasFinal) and
      (not Event.SeparateFinalTable) then
      begin
        case Event.EventType of
          etRapidFire: Result:= Result+thl+ths*((Event.FinalShots-1) div 10)+_printer.MM2PY (1);
        else
          Result:= Result+thl+ths*((Event.FinalShots-1) div 10)+thl+_printer.MM2PY (1);
        end;
        if sh.FinalShotsStr<> '' then
          Result:= Result+ths;
      end;
  end;

  procedure PrintShooterItem;
  var
    st: string;
    cx,x,w,y1,y2: integer;
    i,j: integer;
    fx,fy,fc: integer;
    s: TStrings;
    //bytotal: boolean;
    q: TQualificationItem;
    qy1,qy2,qy: integer;
  begin
    cx:= _printer.Left;
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [];

        if (sh.DNS<> dnsCompletely) then
          begin
            if sh.OutOfRank then
              st:= OUT_OF_RANK_MARK
            else if (HasFinal) and (sh.Index< Event.FinalPlaces) then
              st:= FINAL_MARK
            else
              st:= IntToStr (sh.Index+1);
            w:= TextWidth (st);
            x:= cx+cw [0]-w-xsep div 2;
            TextOut (x,y,st);
          end;
        cx:= cx+cw [0];

{        if StartList.Info.StartNumbers then
          begin
            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= sh.StartNumberStr;
            w:= TextWidth (st);
            x:= cx+cw [1]-w-_printer.MM2PX (separator/2);
            TextOut (x,y,st);
          end;}
        cx:= cx+cw [1];

        x:= cx+xsep div 2;
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        st:= sh.Shooter.Surname;
        if IsPairedEvent and (sh_pair <> nil) then
          st:= st + ' / ' + sh_pair.Shooter.Surname;
        TextOut (x,y,st);
        Font.Height:= font_height_small;
        Font.Style:= [];
        if sh.Shooter.StepName<> '' then
          st:= sh.Shooter.Name+' '+sh.Shooter.StepName
        else
          st:= sh.Shooter.Name;
        if IsPairedEvent and (sh_pair <> nil) then
          begin
            if sh_pair.Shooter.StepName<> '' then
              st:= st + ' / ' + sh_pair.Shooter.Name+' '+sh_pair.Shooter.StepName
            else
              st:= st + ' / ' + sh_pair.Shooter.Name;
          end;
        TextOut (x,y+thl,st);
        cx:= cx+cw [2];

        x:= cx+xsep div 2;
        st:= sh.Shooter.BirthFullStr;
        Font.Height:= font_height_small;
        Font.Style:= [];
        TextOut (x,y+thl-ths,st);
        cx:= cx+cw [3];

        Font.Height:= font_height_small;
        Font.Style:= [];
        st:= sh.Shooter.QualificationName;
        x:= cx+xsep div 2;
        TextOut (x,y+thl-ths,st);
        cx:= cx+cw [4];

        // ������(�)
        x:= cx+xsep div 2;
        if sh.Shooter.RegionsAbbr<> '' then
          begin
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= sh.Shooter.RegionsAbbr;
            TextOut (x,y,st);
            y1:= y+thl;
          end
        else
          y1:= y;
        // �����
        Font.Height:= font_height_small;
        Font.Style:= [];
        st:= sh.Shooter.Town;
        TextOut (x,y1,st);
        cx:= cx+cw [5];

        // �����
        if ADistrictPoints then
          begin
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= sh.Shooter.DistrictAbbr;
            x:= cx+xsep div 2;
            TextOut (x,y,st);
            cx:= cx+cw [6];
          end;

        // ����
        Font.Height:= font_height_small;
        Font.Style:= [];
        st:= sh.Shooter.SocietyAndClub;
        x:= cx+xsep div 2;
        TextOut (x,y+thl-ths,st);
        cx:= cx+cw [7];

        case sh.DNS of
          dnsNone: begin  // ��� ���������
            // ���������� �� ������
            Font.Height:= font_height_small;
            for j:= 1 to Event.Stages do
              begin
    {            if ((AFinal) and (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank)) and (Event.Stages= 1) then
                  y1:= y+thl
                else  }
                  y1:= y+thl-ths+(j-1)*ths;
                Font.Style:= [];
                
                // Print first shooter's series
                for i:= 1 to Event.SeriesPerStage do
                  begin
                    st:= sh.SerieStr (j,i);
                    w:= TextWidth (st);
                    x:= cx+(xsep div 2)+i*TextWidth (SerieTemplate)+(i-1)*_printer.MM2PX (1)-w;
                    TextOut (x,y1,st);
                  end;
                
                // For paired events, print second shooter's series and sums
                if IsPairedEvent and (sh_pair <> nil) then
                  begin
                    // Print second shooter's series
                    for i:= 1 to Event.SeriesPerStage do
                      begin
                        st:= sh_pair.SerieStr (j,i);
                        w:= TextWidth (st);
                        x:= cx+(xsep div 2)+(Event.SeriesPerStage+i)*TextWidth (SerieTemplate)+
                            (Event.SeriesPerStage+i-1)*_printer.MM2PX (1)-w;
                        TextOut (x,y1,st);
                      end;
                    
                    // Print series sums for the pair
                    Font.Style:= [fsBold];
                    for i:= 1 to Event.SeriesPerStage do
                      begin
                        // Calculate sum of series i for both shooters
                        st:= CompetitionStr (sh.Series10 [j,i] + sh_pair.Series10 [j,i]);
                        w:= TextWidth (st);
                        x:= cx+(xsep div 2)+(Event.SeriesPerStage*2+i)*TextWidth (SerieTemplate)+
                            (Event.SeriesPerStage*2+i-1)*_printer.MM2PX (1)-w;
                        TextOut (x,y1,st);
                      end;
                  end;
                
                if (Event.Stages> 1) and (Event.SeriesPerStage> 1) then
                  begin
                    Font.Style:= [fsBold];
                    if IsPairedEvent and (sh_pair <> nil) then
                      begin
                        // For pairs, show combined stage result
                        st:= CompetitionStr (sh.StageResults10 (j) + sh_pair.StageResults10 (j));
                      end
                    else
                      st:= sh.StageResultStr(j);
                    w:= TextWidth (st);
                    x:= cx+cw [8]+cw [9]-(xsep div 2)-w;
                    TextOut (x,y1,st);
                  end;
              end;
            cx:= cx+cw [8]+cw [9];

            if Event.Stages> 1 then
              y1:= y+(Event.Stages-1)*ths
            else
              begin
    {            if (AFinal) and (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank) then
                  y1:= y+thl+ths-thl
                else }
                  y1:= y;
              end;

            if Event.Stages> 1 then
              y2:= y1+thl
            else
              y2:= y+thl+ths;

            qy2:= y;
            if (AFinal) and (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank) then
              begin
                x:= cx-xsep;
                Font.Height:= font_height_small;
                Font.Style:= [];
                // ��������� ��������
                if sh.FinalShotsCount> 0 then
                  begin
                    fy:= y2+thl-ths;
                    for j:= 0 to (Event.FinalShots-1) div 10 do
                      begin
                        fx:= x;
                        fc:= (Event.FinalShots-1) mod 10;
                        for i:= fc downto 0 do
                          begin
                            if j*10+i< sh.FinalShotsCount then
                              st:= Event.FinalStr (sh.FinalShots10 [j*10+i])
                            else
                              st:= '';
                            w:= TextWidth (st);
                            TextOut (fx-w,fy,st);
                            dec (fx,TextWidth (Event.FinalShotTemplate)+xsep);
                          end;
                        if j=0 then
                          begin
                            st:= FINAL_SHOTS_;;
                            w:= TextWidth (st);
                            TextOut (fx-w,fy,st);
                          end;
                        inc (fy,ths);
                      end;
                    y2:= fy-thl;
                  end;

                // ����������� (�����������), ���� ����
                if sh.FinalShootOff10> 0 then
                  begin
                    st:= Format (FINAL_SHOOTOFF,[sh.FinalShootOffStr]);
                    fy:= y2+thl;
                    TextOut (x-xsep*2-TextWidth (st),fy,st);
                  end
                else if sh.FinalShootOffStr<> '' then
                  begin
                    st:= sh.FinalShootOffStr;
                    fy:= y2+thl;
                    TextOut (x-xsep*2-TextWidth (st),fy,st);
                  end;

                // ��������� ��������� �����
                Font.Height:= font_height_large;
                Font.Style:= [fsBold];
                st:= sh.Event.FinalStr (sh.FinalResult10);
{                w:= TextWidth (st);
                x:= cx+cw [10]-xsep div 2-w;}
                x:= cx+xsep div 2;
                TextOut (x,y2,st);
                // ����� �����
                if ((Event.EventType= etRapidFire) and (DateFrom< EncodeDate (2011,4,8))) or
                  ((Event.EventType<> etRapidFire) and ((not Event.CompareByFinal) or (DateFrom< EncodeDate (2012,11,25)))) then
                  begin
                    // 8.4.2011 - ��� ��-8 ����� ��������� ������ �� �����
                    // 25.11.2012 - ��� ��������� ���������� ����
                    Font.Height:= font_height_large;
                    Font.Style:= [fsBold];
                    st:= sh.TotalResultStr;
                   { w:= TextWidth (st);
                    x:= cx+cw [10]-xsep div 2-w;}
                    x:= cx+xsep div 2;
                    TextOut (x,y2+thl,st);
                    qy2:= y2+thl;
                  end;
              end;

            // ��������� ��������
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            
            if IsPairedEvent and (sh_pair <> nil) then
              begin
                // For paired events, show combined competition result
                st:= CompetitionStr (sh.Competition10 + sh_pair.Competition10);
              end
            else
              st:= sh.CompetitionStr;
{            w:= TextWidth (st);
            if (havefinalfracs) or
               ((AFinal) and (Event.FinalFracs) and
                (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank)) then
              begin
                w:= w+TextWidth ('.0');
                havefinalfracs:= true;
              end;
            x:= cx+cw [10]-xsep div 2-w;}
            x:= cx+xsep div 2;
            TextOut (x,y1,st);
            qy1:= y1;
            cx:= cx+cw [10];

            // ����������� � �����������
            if sh.CompShootOffStr<> '' then
              begin
                Font.Height:= font_height_small;
                Font.Style:= [];
                st:= '('+sh.CompShootOffStr+')';
                x:= cx+xsep div 2;
                TextOut (x,y1+thl-ths,st);
              end;
            cx:= cx+cw [11];

            // ����������� �������� � ����� �� ����
            q:= sh.Qualified{ (bytotal)};
            if q<> nil then
              begin
                Font.Height:= font_height_small;
                Font.Style:= [];
                st:= q.Name;
                x:= cx+xsep div 2;
                if ((ATeamPoints) or (ARegionPoints) or (ADistrictPoints)) and
                    ((sh.TeamForPoints<> '') or (sh.GiveRegionPoints) or (sh.GiveDistrictPoints)) and
                    (sh.QualificationPoints> 0) then
                  begin
                    st:= st+' ('+IntToStr (sh.QualificationPoints)+')';
                  end;
                {if bytotal then
                  qy:= qy2
                else}
                  qy:= qy1;
                TextOut (x,qy+thl-ths,st);
              end;
            cx:= cx+cw [12];

            // ����� �� �������
            if (ATeamPoints) and (not sh.OutOfRank) then
              begin
                if sh.TeamForPoints= '' then
                  begin
                    Font.Height:= font_height_large;
                    Font.Style:= [];
                    st:= NOT_FOR_TEAM_MARK;
                    x:= cx+xsep div 2;
                    TextOut (x,y,st);
                  end
                else if sh.TeamPoints> 0 then
                  begin
                    Font.Height:= font_height_large;
                    Font.Style:= [];
                    st:= IntToStr (sh.TeamPoints);
                    w:= TextWidth (st);
                    x:= cx+cw [13]-xsep div 2-w;
                    TextOut (x,y,st);
                  end;
              end;
            cx:= cx+cw [13];

            // ����� �� �����
            if (ADistrictPoints) and (not sh.OutOfRank) then
              begin
                if sh.GiveDistrictPoints then
                  begin
                    if sh.DistrictPoints> 0 then
                      st:= IntToStr (sh.DistrictPoints)
                    else
                      st:= '';
                  end
                else
                  begin
                    st:= NOT_FOR_TEAM_MARK;
                  end;
                if st<> '' then
                  begin
                    Font.Height:= font_height_large;
                    Font.Style:= [];
                    w:= TextWidth (st);
                    x:= cx+cw [14]-xsep div 2-w;
                    TextOut (x,y,st);
                  end;
              end;
            cx:= cx+cw [14];

            // ����� �� ������
            if (ARegionPoints) and (not sh.OutOfRank) then
              begin
                if sh.GiveRegionPoints then
                  begin
                    if sh.RegionPoints> 0 then
                      st:= IntToStr (sh.RegionPoints)
                    else
                      st:= '';
                  end
                else
                  st:= NOT_FOR_TEAM_MARK;
                if st<> '' then
                  begin
                    Font.Height:= font_height_large;
                    Font.Style:= [];
                    w:= TextWidth (st);
                    x:= cx+cw [15]-xsep div 2-w;
                    TextOut (x,y,st);
                  end;
              end;
            cx:= cx+cw [15];

            // "������" �����
            if ((ATeamPoints) or (ADistrictPoints) or (ARegionPoints)) and
              (sh.ManualPoints> 0) and (not sh.OutOfRank) then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [];
                st:= IntToStr (sh.ManualPoints);
                w:= TextWidth (st);
                x:= cx+cw [16]-xsep div 2-w;
                TextOut (x,y,st);
              end;
            cx:= cx+cw [16];

            // �������
            if sh.RecordComment<> '' then
              begin
                Font.Height:= font_height_large;
                Font.Style:= [];
                st:= sh.RecordComment;
                x:= cx+xsep div 2;
                TextOut (x,y,st);
              end;
          end;
          dnsCompletely: begin  // ������ �� ���������
            Font.Height:= font_height_small;
            Font.Style:= [];
            if sh.DNSComment<> '' then
              begin
                s:= TStringList.Create;
                s.Text:= sh.DNSComment;
                x:= cx+xsep div 2;
                for i:= 0 to s.Count-1 do
                  begin
                    y1:= y+thl-ths+ths*i;
                    TextOut (x,y1,s [i]);
                  end;
                s.Free;
                st:= sh.DNSComment;
              end
            else
              begin
                TextOut (cx+xsep div 2,y+thl-ths,DNS_MARK);
              end;
          end;
          dnsPartially: begin   // ���� ����������, �� �� ��������, ����� �����������
            // ���������� �� ������
            Font.Height:= font_height_small;
            for j:= 1 to Event.Stages do
              begin
                y1:= y+thl-ths+(j-1)*ths;
                Font.Style:= [];
                for i:= 1 to Event.SeriesPerStage do
                  begin
                    st:= sh.SerieStr(j,i);
                    w:= TextWidth (st);
                    x:= cx+(xsep div 2)+i*TextWidth (SerieTemplate)+(i-1)*_printer.MM2PX (1)-w;
                    TextOut (x,y1,st);
                  end;
                if (Event.Stages> 1) and (Event.SeriesPerStage> 1) then
                  begin
                    Font.Style:= [fsBold];
                    st:= sh.StageResultStr(j);
                    w:= TextWidth (st);
                    x:= cx+cw [8]+cw [9]-(xsep div 2)-w;
                    TextOut (x,y1,st);
                  end;
              end;
            if sh.DNSComment<> '' then
              begin
                s:= TStringList.Create;
                s.Text:= sh.DNSComment;
                Font.Style:= [];
                x:= cx+(xsep div 2);
                for i:= 0 to s.Count-1 do
                  begin
                    y1:= y+thl-ths+(Event.Stages+i)*ths;
                    TextOut (x,y1,s [i]);
                  end;
                s.Free;
              end;

            cx:= cx+cw [8]+cw [9];

            if Event.Stages> 1 then
              y1:= y+(Event.Stages-1)*ths
            else
              y1:= y;

            // ��������� ��������
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            st:= sh.CompetitionStr;
//            w:= TextWidth (st);
            if (havefinalfracs) or
               ((AFinal) and (Event.FinalFracs) and
                (sh.Index< Event.FinalPlaces) and (not sh.OutOfRank)) then
              begin
//                w:= w+TextWidth ('.0');
                havefinalfracs:= true;
              end;
//            x:= cx+cw [10]-xsep div 2-w;
            x:= cx+xsep div 2;
            TextOut (x,y1,st);
          end;
        end;
      end;
  end;

{  procedure PrintSignature;
  var
    y1,x: integer;
  begin
    if y+signatureheight> _printer.PageHeight-bottomborder-footerheight then
      begin
        inc (page_idx);
        MakeNewPage;
      end;
    with canv do
      begin
        y1:= _printer.PageHeight-bottomborder-footerheight-signatureheight+_printer.MM2PY (10);
        Font.Height:= font_height_large;
        Font.Style:= [];
        x:= leftborder+_printer.MM2PX (3);
        TextOut (x,y1,'������� ��������� ������������,');
        y1:= y1+thl;
        TextOut (x,y1,Info.SecreteryCategory);
        x:= _printer.PageWidth-rightborder-_printer.MM2PX (3)-TextWidth (Info.Secretery);
        TextOut (x,y1,Info.Secretery);
      end;
  end;}

  procedure PrintTeamsReport;
  var
    _teams: TStartListEventTeams;
    lx: integer;

    function MeasureColumns: boolean;
    var
      i: integer;
      w: integer;
      st: string;
    begin
      cw [0]:= 0;
      cw [1]:= 0;
      cw [2]:= 0;
      cw [3]:= 0;
      cw [4]:= 0;
      with _printer.Canvas do
        begin
          Font.Height:= font_height_large;
          for i:= 0 to _teams.Count-1 do
            begin
              Font.Style:= [];
              st:= IntToStr (i+1);
              w:= TextWidth (st);
              if w> cw [0] then
                cw [0]:= w;
              Font.Style:= [];
              st:= _teams [i].Name;
              w:= TextWidth (st);
              if w> cw [1] then
                cw [1]:= w;
              Font.Style:= [fsBold];
              st:= _teams[i].SumStr;
              w:= TextWidth (st);
              if w> cw [2] then
                cw [2]:= w;
              if RTeamsPoints.Count> 0 then
                begin
                  st:= _teams [i].PointsStr;
                  w:= TextWidth (st);
                  if w> cw [4] then
                    cw [4]:= w;
                end;
            end;
          Font.Style:= [];
          cw [0]:= cw [0]+_printer.MM2PX (2);
          cw [1]:= cw [1]+_printer.MM2PX (4);
          cw [2]:= cw [2]+_printer.MM2PX (4)+TextWidth ('-');
          cw [4]:= cw [4]+_printer.MM2PX (2)+TextWidth ('-');
//          tw:= _printer.Width-cw [0]-cw [1]-cw [2]-_printer.MM2PX (2);
          Font.Height:= font_height_small;
          Font.Style:= [];
          for i:= 0 to _teams.Count-1 do
            begin
              st:= _teams [i].ShootersListStr;
              w:= TextWidth (st);
              if w> cw [3] then
                cw [3]:= w;
            end;
          cw [3]:= cw [3]+_printer.MM2PX (4);
          cw [4]:= cw [4]+_printer.MM2PX (2);
        end;
      lx:= _printer.Left+(_printer.Width-cw [0]-cw [1]-cw [2]-cw [3]-cw [4]) div 2;
      Result:= true;
    end;

    function MeasureItem (index: integer): integer;
    var
      n: integer;
    begin
      n:= 1;
      Result:= thl+(n-1)*ths+_printer.MM2PY (1);
    end;

    function MeasureAllHeight: integer;
    var
      j: integer;
    begin
      Result:= 0;
      for j:= 0 to _teams.Count-1 do
        Result:= Result+MeasureItem (j);
    end;

  var
    st: string;
    lh,x,w,y1: integer;
    i: integer;
//    pp: integer;
  begin
    _teams:= TStartListEventTeams.Create (self);
    if _teams.Count= 0 then
      begin
        _teams.Free;
        exit;
      end;
    MeasureColumns;
    // ���� ��� ������� �� ������� �� ������� ��������, �������� ��������� ��������
    if (y+thl*2+thl+ths+MeasureAllHeight>= _printer.Bottom-footerheight) and (y> current_page_top) then
      begin
        inc (page_idx);
        MakeNewPage;
      end;
    y:= y+thl*2;

    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        st:= TEAM_CHAMPIONSHIP_TITLE;
        x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
        TextOut (x,y,st);
      end;
    inc (y,thl+ths);

    for i:= 0 to _teams.Count-1 do
      begin
        lh:= MeasureItem (i);
        if y+lh>= _printer.Bottom-footerheight then
          begin
            inc (page_idx);
            MakeNewPage;
          end;

        with _printer.Canvas do
          begin
            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= IntToStr (i+1);
            w:= TextWidth (st);
            x:= lx+cw [0]-_printer.MM2PX (2)-w;
            TextOut (x,y,st);

            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= _teams [i].Name;
            x:= lx+cw [0]+_printer.MM2PX (2);
            TextOut (x,y,st);

            Font.Height:= font_height_large;
            TextOut (lx+cw [0]+cw [1],y,'-');
            Font.Style:= [fsBold];
            st:= _teams[i].SumStr;
            w:= TextWidth (st);
            x:= lx+cw [0]+cw [1]+cw [2]-_printer.MM2PX (2)-w;
            TextOut (x,y,st);

            Font.Height:= font_height_small;
            Font.Style:= [];
            y1:= y+thl-ths;
            x:= lx+cw [0]+cw [1]+cw [2]+_printer.MM2PX (2);
            st:= _teams [i].ShootersListStr;
            TextOut (x,y1,st);

            if (RTeamsPoints.Count> 0) then
              begin
                st:= _teams [i].PointsStr;
                if st<> '' then
                  begin
                    Font.Height:= font_height_large;
                    Font.Style:= [];
                    x:= lx+cw [0]+cw [1]+cw [2]+cw [3];
                    TextOut (x,y,'-');
                    w:= TextWidth (st);
                    x:= lx+cw [0]+cw [1]+cw [2]+cw [3]+cw [4]-_printer.MM2PX (2)-w;
                    TextOut (x,y,st);
                  end;
              end;
          end;

        inc (y,lh);
      end;
    _teams.Free;
  end;

  procedure PrintTeamPointsReport;
  var
    a: array of TEventPointsTeamStats;
    idx,i,j,p: integer;
    ts: TEventPointsTeamStats;
    lx: integer;

    procedure MeasureColumns;
    var
      i,w: integer;
      st: string;
    begin
      cw [0]:= 0;
      cw [1]:= 0;
      cw [2]:= 0;
      with _printer.Canvas do
        begin
          Font.Height:= font_height_large;
          Font.Style:= [];
          for i:= 0 to Length (a)-1 do
            begin
              st:= IntToStr (i+1);
              w:= TextWidth (st);
              if w> cw [0] then
                cw [0]:= w;
              st:= a [i].team;
              w:= TextWidth (st);
              if w> cw [1] then
                cw [1]:= w;
              st:= IntToStr (a [i].points);
              w:= TextWidth (st);
              if w> cw [2] then
                cw [2]:= w;
            end;
        end;
      cw [0]:= cw [0]+_printer.MM2PX (2);
      cw [1]:= cw [1]+_printer.MM2PX (4);
      cw [2]:= cw [2]+_printer.MM2PX (2)+_printer.Canvas.TextWidth ('-');
      lx:= _printer.Left+(_printer.Width-cw [0]-cw [1]-cw [2]) div 2;
    end;

  var
    x,w: integer;
    st: string;
    teams: TStrings;
  begin
    teams:= StartList.GetTeams (false,nil);
    if teams.Count= 0 then
      begin
        teams.Free;
        exit;
      end;
    SetLength (a,0);
    for i:= 0 to teams.Count-1 do
      begin
        p:= TeamPoints (teams [i],[Male,Female]);
        if p> 0 then
          begin
            SetLength (a,Length (a)+1);
            with a [Length (a)-1] do
              begin
                team:= teams [i];
                points:= p;
                rank:= HighestRank (teams [i],[Male,Female]);
              end;
          end;
      end;
    teams.Free;
    if Length (a)= 0 then
      exit;

    // ��������� �������
    for i:= 0 to Length (a)-2 do
      begin
        idx:= i;
        for j:= i+1 to Length (a)-1 do
          begin
            if a [j].points> a [idx].points then
              idx:= j
            else if (a [j].points= a [idx].points) and (a [j].rank> 0) and ((a [j].rank< a [idx].rank) or (a [idx].rank<= 0)) then
              idx:= j;
          end;
        if idx<> i then
          begin
            ts:= a [i];
            a [i]:= a [idx];
            a [idx]:= ts;
          end;
      end;

    MeasureColumns;

    // ���� ������� �� ������� �� ������� ��������, ��������� �� ��������� ��������
    if (y+thl*2+thl+ths+Length (a)*thl>= _printer.Bottom-footerheight) and (y> current_page_top) then
      begin
        inc (page_idx);
        MakeNewPage;
      end;
    inc (y,thl*2);

    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        st:= TEAM_POINTS_TITLE;
        w:= TextWidth (st);
        x:= (_printer.Left+_printer.Right-w) div 2;
        TextOut (x,y,st);
        inc (y,thl+ths);
        Font.Height:= font_height_large;
        Font.Style:= [];
      end;

    for i:= 0 to Length (a)-1 do
      begin
        if y+thl>= _printer.Bottom-footerheight then
          begin
            inc (page_idx);
            MakeNewPage;
          end;

        with _printer.Canvas do
          begin
            st:= IntToStr (i+1);
            w:= TextWidth (st);
            x:= lx+cw [0]-_printer.MM2PX (2)-w;
            TextOut (x,y,st);

            st:= a [i].team;
            x:= lx+cw [0]+_printer.MM2PX (2);
            TextOut (x,y,st);

            TextOut (lx+cw [0]+cw [1],y,'-');
            st:= IntToStr (a [i].points);
            w:= TextWidth (st);
            x:= lx+cw [0]+cw [1]+cw [2]-w;
            TextOut (x,y,st);
          end;

        inc (y,thl);
      end;

    SetLength (a,0);
  end;

  procedure PrintRegionPointsReport;
  var
    regions: array of TEventRegionStats;
    i,ii,idx: integer;
    found: boolean;
    rs: TEventRegionStats;
    st: string;
    w: integer;
    lx,x: integer;
    cols,rows: integer;
    rcw,nw,pw: array [0..2] of integer;
    sh: TStartListEventShooterItem;

    function MeasureColumns: boolean;
    var
      j,jj: integer;
      w: integer;
      idx: integer;
    begin
      if (Length (regions)< 5) and (cols> 2) then
        cols:= 2;
      if (Length (regions)< 3) and (cols> 1) then
        cols:= 1;
      // ������������ ���������� �����
      rows:= Length (regions) div cols;
      if Length (regions) mod cols> 0 then
        begin
          if rows= 0 then
            cols:= Length (regions);
          inc (rows);
        end;
      for j:= 0 to 2 do
        rcw [j]:= 0;
      for jj:= 0 to cols-1 do
        begin
          nw [jj]:= 0;
          pw [jj]:= 0;
          for j:= 0 to rows-1 do
            begin
              idx:= jj*rows+j;
              if idx< Length (regions) then
                begin
                  rs:= regions [idx];
                  w:= _printer.Canvas.TextWidth (rs._name);
                  if w> nw [jj] then
                    nw [jj]:= w;
                  w:= _printer.Canvas.TextWidth (IntToStr (rs.points));
                  if w> pw [jj] then
                    pw [jj]:= w;
                end;
            end;
          rcw [jj]:= nw [jj]+pw [jj]+_printer.Canvas.TextWidth (' - ')+_printer.MM2PX (10);
        end;
      w:= 0;
      for j:= 0 to cols-1 do
        inc (w,rcw [j]);
      lx:= (_printer.Left+_printer.Right-w) div 2;
      Result:= (w<= _printer.Width);
    end;

  begin
    // �������� �������
    SetLength (regions,0);
    for i:= 0 to Shooters.Count-1 do
      begin
        sh:= Shooters.Items [i];
        if Trim (sh.Shooter.RegionAbbr1)<> '' then
          begin
            // ���� ������ ������
            found:= false;
            for ii:= 0 to Length (regions)-1 do
              if AnsiSameText (sh.Shooter.RegionAbbr1,regions [ii]._abbr) then
                begin
                  found:= true;
                  break;
                end;
            if not found then
              begin
                SetLength (regions,Length (regions)+1);
                with regions [Length (regions)-1] do
                  begin
                    _abbr:= sh.Shooter.RegionAbbr1;
                    if Global_ProtocolFullRegionNames then
                      begin
                        _name:= sh.Shooter.RegionFull1;
                        if _name= '' then
                          _name:= _abbr;
                      end
                    else
                      _name:= _abbr;
                    points:= 0;
                  end;
              end;
          end;
        if Trim (sh.Shooter.RegionAbbr2)<> '' then
          begin
            // ���� ������ ������
            found:= false;
            for ii:= 0 to Length (regions)-1 do
              if AnsiSameText (sh.Shooter.RegionAbbr2,regions [ii]._abbr) then
                begin
                  found:= true;
                  break;
                end;
            if not found then
              begin
                SetLength (regions,Length (regions)+1);
                with regions [Length (regions)-1] do
                  begin
                    _abbr:= sh.Shooter.RegionAbbr2;
                    if Global_ProtocolFullRegionNames then
                      begin
                        _name:= sh.Shooter.RegionFull2;
                        if _name= '' then
                          _name:= _abbr;
                      end
                    else
                      _name:= _abbr;
                    points:= 0;
                  end;
              end;
          end;
      end;
    // �������� �����
    for i:= 0 to Length (regions)-1 do
      regions [i].points:= regions [i].points+RegionPoints (regions [i]._abbr,[Male,Female]);
    // ��������� �������
    for i:= 0 to Length (regions)-2 do
      begin
        idx:= i;
        for ii:= i+1 to Length (regions)-1 do
          if regions [ii].points> regions [idx].points then
            idx:= ii;
        if idx<> i then
          begin
            rs:= regions [idx];
            regions [idx]:= regions [i];
            regions [i]:= rs;
          end;
      end;
    // ������� ��� �������, � ������� ��� ������
    while (Length (regions)> 0) and (regions [Length (regions)-1].points= 0) do
      SetLength (regions,Length (regions)-1);
    if Length (regions)= 0 then
      begin
        regions:= nil;
        exit;
      end;

    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [];
        cols:= 3;
        repeat
          if MeasureColumns then
            break;
          dec (cols);
        until cols<= 1;
      end;
    // ���� �� ������� �� ������� ��������, ��������� �� ��������� ��������
    if (y+thl*2+thl+ths+thl*rows> _printer.Bottom-footerheight) and (y> current_page_top) then
      begin
        inc (page_idx);
        MakeNewPage;
      end;
    inc (y,thl*2);
    with _printer.Canvas do
      begin
        Font.Style:= [fsBold];
        st:= REGIONS_POINTS_TITLE;
        w:= TextWidth (st);
        x:= (_printer.Left+_printer.Right-w) div 2;
        TextOut (x,y,st);
      end;
    inc (y,thl+ths);
    _printer.Canvas.Font.Style:= [];
    for i:= 0 to rows-1 do
      begin
        x:= lx;
        for ii:= 0 to cols-1 do
          begin
            idx:= ii*rows+i;
            if idx< Length (regions) then
              begin
                rs:= regions [idx];
                _printer.Canvas.TextOut (x+_printer.MM2PX (5),y,rs._name);
                _printer.Canvas.TextOut (x+_printer.MM2PX (5)+nw [ii],y,' - '+IntToStr (rs.points));
              end;
            inc (x,rcw [ii]);
          end;
        inc (y,thl);
        if y> _printer.Bottom-footerheight then
          begin
            inc (page_idx);
            MakeNewPage;
            inc (y,thl);
            _printer.Canvas.Font.Style:= [fsBold];
            st:= REGIONS_POINTS_CONTINUE;
            w:= _printer.Canvas.TextWidth (st);
            x:= (_printer.Left+_printer.Right-w) div 2;
            _printer.Canvas.TextOut (x,y,st);
            inc (y,thl+ths);
            _printer.Canvas.Font.Style:= [];
          end;
      end;

    SetLength (regions,0);
    regions:= nil;
  end;

  procedure PrintDistrictPointsReport;
  var
    districts: array of TEventDistrictStats;
    i,ii,idx: integer;
    found: boolean;
    sh: TStartListEventShooterItem;
    ds: TEventDistrictStats;
    cols,rows: integer;
    st: string;
    w: integer;
    x,lx: integer;
    dcw,nw,pw: array [0..2] of integer;

    function MeasureColumns: boolean;
    var
      j,jj: integer;
    begin
      if (Length (districts)< 5) and (cols> 2) then
        cols:= 2;
      if (Length (districts)< 3) and (cols> 1) then
        cols:= 1;
      // ������������ ���������� �����
      rows:= Length (districts) div cols;
      if Length (districts) mod cols> 0 then
        begin
          if rows= 0 then
            cols:= Length (districts);
          inc (rows);
        end;
      for j:= 0 to 2 do
        dcw [j]:= 0;
      for jj:= 0 to cols-1 do
        begin
          nw [jj]:= 0;
          pw [jj]:= 0;
          for j:= 0 to rows-1 do
            begin
              if jj*rows+j< Length (districts) then
                begin
                  ds:= districts [jj*rows+j];
                  w:= _printer.Canvas.TextWidth (ds._name);
                  if w> nw [jj] then
                    nw [jj]:= w;
                  w:= _printer.Canvas.TextWidth (IntToStr (ds.points));
                  if w> pw [jj] then
                    pw [jj]:= w;
                end;
            end;
          dcw [jj]:= nw [jj]+pw [jj]+_printer.Canvas.TextWidth (' - ')+_printer.MM2PX (10);
        end;
      w:= 0;
      for j:= 0 to cols-1 do
        inc (w,dcw [j]);
      lx:= (_printer.Left+_printer.Right-w) div 2;
      Result:= (w<= _printer.Width);
    end;

  begin
    SetLength (districts,0);
    for i:= 0 to Shooters.Count-1 do
      begin
        sh:= Shooters.Items [i];
        if Trim (sh.Shooter.DistrictAbbr)= '' then
          continue;
        found:= false;
        for ii:= 0 to Length (districts)-1 do
          if AnsiSameText (sh.Shooter.DistrictAbbr,districts [ii]._abbr) then
            begin
              found:= true;
              break;
            end;
        if not found then
          begin
            SetLength (districts,Length (districts)+1);
            with districts [Length (districts)-1] do
              begin
                _abbr:= sh.Shooter.DistrictAbbr;
                _name:= sh.Shooter.DistrictFull;
                if _name= '' then
                  _name:= _abbr;
                points:= 0;
              end;
          end;
      end;
    // �������� �����
    for i:= 0 to Length (districts)-1 do
      districts [i].points:= districts [i].points+DistrictPoints (districts [i]._abbr,[Male,Female]);
    // ��������� ������
    for i:= 0 to Length (districts)-2 do
      begin
        idx:= i;
        for ii:= i+1 to Length (districts)-1 do
          if districts [ii].points> districts [idx].points then
            idx:= ii;
        if idx<> i then
          begin
            ds:= districts [idx];
            districts [idx]:= districts [i];
            districts [i]:= ds;
          end;
      end;
    // ������� ��� ������ � �������� �������
    while (Length (districts)> 0) and (districts [Length (districts)-1].points= 0) do
      SetLength (districts,Length (districts)-1);
    if Length (districts)= 0 then
      begin
        districts:= nil;
        exit;
      end;
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [];
        cols:= 3;
        repeat
          if MeasureColumns then
            break;
          dec (cols);
        until cols<= 1;
      end;
    // ���� �� ������� �� ������� ��������, �� ��������� �� ���������
    if (y+thl*2+thl*3+ths> _printer.Bottom-footerheight) and (y> current_page_top) then
      begin
        inc (page_idx);
        MakeNewPage;
      end;
    with _printer.Canvas do
      begin
        inc (y,thl*2);
        Font.Style:= [fsBold];
        st:= DISTRICTS_POINTS_TITLE;
        w:= TextWidth (st);
        x:= (_printer.Left+_printer.Right-w) div 2;
        TextOut (x,y,st);
        inc (y,thl+ths);
        Font.Style:= [];
      end;
    for i:= 0 to rows-1 do
      begin
        x:= lx;
        for ii:= 0 to cols-1 do
          begin
            if ii*rows+i< Length (districts) then
              begin
                ds:= districts [ii*rows+i];
                _printer.Canvas.TextOut (x+_printer.MM2PX (5),y,ds._name);
                _printer.Canvas.TextOut (x+_printer.MM2PX (5)+nw [ii],y,' - '+IntToStr (ds.points));
              end;
            inc (x,dcw [ii]);
          end;
        inc (y,thl);
        if y> _printer.Bottom-footerheight then
          begin
            inc (page_idx);
            MakeNewPage;
            inc (y,thl);
            _printer.Canvas.Font.Style:= [fsBold];
            st:= DISTRICTS_POINTS_CONTINUE;
            w:= _printer.Canvas.TextWidth (st);
            x:= (_printer.Left+_printer.Right-w) div 2;
            _printer.Canvas.TextOut (x,y,st);
            inc (y,thl+ths);
            _printer.Canvas.Font.Style:= [];
          end;
      end;
  end;

  procedure PrintTechReport;
  const
    separator= 1.5;
  var
    a: array of TTechRow;
    i,j: integer;
    qcount: integer;
    w0,w1,w2: integer;
    tw: integer;
    left: integer;
    x,x1: integer;
    cw: integer;
    total,cnt: integer;
    st: string;
    w: integer;
    totalheight: integer;
  begin
    qcount:= StartList.Data.Qualifications.Count;
    if (Shooters.Count= 0) or (qcount= 0) then
      exit;
    SetLength (a,qcount);
    for i:= 0 to qcount-1 do
      begin
        a [i].qual:= i;
        a [i].count:= HaveQualification (StartList.Data.Qualifications.Items [i]);
        SetLength (a [i].cells,qcount);
        for j:= 0 to qcount-1 do
          begin
            a [i].cells [j].qual:= j;
            a [i].cells [j].count:= Qualified (StartList.Data.Qualifications.Items [i],StartList.Data.Qualifications.Items [j]);
          end;
      end;

    while (Length (a)> 0) and (a [Length (a)-1].count= 0) do
      SetLength (a,Length (a)-1);
    while (Length (a)> 0) and (a [0].count= 0) do
      begin
        for i:= 1 to Length (a)-1 do
          a [i-1]:= a [i];
        SetLength (a,Length (a)-1);
      end;
    if Length (a)= 0 then
      exit;

    while Length (a [0].cells)> 0 do
      begin
        cnt:= 0;
        for i:= 0 to Length (a)-1 do
          inc (cnt,a [i].cells [0].count);
        if cnt= 0 then
          begin
            for i:= 0 to Length (a)-1 do
              begin
                for j:= 1 to Length (a [i].cells)-1 do
                  a [i].cells [j-1]:= a [i].cells [j];
                SetLength (a [i].cells,Length (a [i].Cells)-1);
              end;
          end
        else
          break;
      end;
    while Length (a [0].cells)> 0 do
      begin
        cnt:= 0;
        for i:= 0 to Length (a)-1 do
          inc (cnt,a [i].cells [Length (a [i].cells)-1].count);
        if cnt= 0 then
          begin
            for i:= 0 to Length (a)-1 do
              SetLength (a [i].cells,Length (a [i].Cells)-1);
          end
        else
          break;
      end;
    if Length (a [0].cells)= 0 then
      begin
        SetLength (a,0);
        exit;
      end;

    // �������� ������ �������
    totalheight:= (thl+_printer.MM2PY (separator)*2)*(Length (a)+1);
    // ���� ������� �� ������� �� ������� ��������, ��������� �� ������� �� ��������� ��������
    if (y+thl*2+totalheight>= _printer.Bottom-footerheight) and (y> current_page_top) then
      begin
        inc (page_idx);
        MakeNewPage;
      end;
    inc (y,thl*2);

    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        st:= TECH_REPORT_TITLE;
        w:= TextWidth (st);
        x:= (_printer.Left+_printer.Right-w) div 2;
        TextOut (x,y,st);
        inc (y,thl);
      end;

    with _printer.Canvas do
      begin
        cw:= 0;
        Font.Style:= [];
        for j:= 0 to Length (a [0].cells)-1 do
          begin
            cnt:= 0;
            for i:= 0 to Length (a)-1 do
              begin
                tw:= TextWidth (StartList.Data.Qualifications.Items [a [i].cells [j].qual].Name);
                if tw> cw then
                  cw:= tw;
                tw:= TextWidth (IntToStr (a [i].cells [j].count));
                if tw> cw then
                  cw:= tw;
                inc (cnt,a [i].cells [j].count);
              end;
            tw:= TextWidth (IntToStr (cnt));
            if tw> cw then
              cw:= tw;
          end;
        w1:= 0;
        w2:= 0;
        total:= 0;
        for i:= 0 to Length (a)-1 do
          begin
            inc (total,a [i].count);
            tw:= TextWidth (StartList.Data.Qualifications.Items [a [i].qual].Name);
            if tw> w1 then
              w1:= tw;
            tw:= TextWidth (IntToStr (a [i].count));
            if tw> w2 then
              w2:= tw;
          end;
        w0:= w1+w2+TextWidth (' - ');
        tw:= TextWidth (TECH_REPORT_SHOOTERS);
        if tw> w0 then
          w0:= tw;
        tw:= TextWidth (TECH_REPORT_TOTAL+IntToStr (total));
        if tw> w0 then
          w0:= tw;
        w0:= w0+_printer.MM2PX (separator*2);
      end;

    cw:= cw + _printer.MM2PX (separator*2);
    tw:= cw * Length (a [0].cells);
    left:= (_printer.Left+_printer.Right-w0-tw) div 2;

    inc (y,_printer.MM2PY (separator));
    with _printer.Canvas do
      begin
        MoveTo (left,y);
        LineTo (left+w0+tw,y);
      end;
    inc (y,_printer.MM2PY (separator));

    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [];;
        x:= left;
        MoveTo (x,y-_printer.MM2PX (separator));
        LineTo (x,y+thl+_printer.MM2PX (separator));
        st:= TECH_REPORT_SHOOTERS;
        TextOut (x+_printer.MM2PX (separator),y,st);
        inc (x,w0);
        MoveTo (x,y-_printer.MM2PX (separator));
        LineTo (x,y+thl+_printer.MM2PX (separator));
        for j:= 0 to Length (a [0].cells)-1 do
          begin
            st:= StartList.Data.Qualifications.Items [a [0].cells [j].qual].Name;
            x1:= (x+x+cw-TextWidth (st)) div 2;
            TextOut (x1,y,st);
            inc (x,cw);
            MoveTo (x,y-_printer.MM2PX (separator));
            LineTo (x,y+thl+_printer.MM2PX (separator));
          end;
        inc (y,thl);
        inc (y,_printer.MM2PY (separator));
        MoveTo (left,y);
        LineTo (left+w0+tw,y);
        inc (y,_printer.MM2PY (separator));
      end;
    for i:= 0 to Length (a)-1 do
      begin
        if y+thl+_printer.MM2PX (separator*2)> _printer.Bottom-footerheight then
          begin
            inc (page_idx);
            MakeNewPage;
            inc (y,thl);
          end;
        with _printer.Canvas do
          begin
            x:= left;
            MoveTo (x,y-_printer.MM2PX (separator));
            LineTo (x,y+thl+_printer.MM2PX (separator));
            st:= StartList.Data.Qualifications.Items [a [i].qual].Name;
            TextOut (x+_printer.MM2PX (separator),y,st);
            st:= IntToStr (a [i].count);
            TextOut (x+w0-TextWidth (st)-_printer.MM2PX (separator),y,st);
            inc (x,w0);
            MoveTo (x,y-_printer.MM2PX (separator));
            LineTo (x,y+thl+_printer.MM2PX (separator));
            for j:= 0 to Length (a [i].cells)-1 do
              begin
                if a [i].cells [j].count> 0 then
                  st:= IntToStr (a [i].cells [j].count)
                else
                  st:= '-';
                x1:= (x+x+cw-TextWidth (st)) div 2;
                TextOut (x1,y,st);
                inc (x,cw);
                MoveTo (x,y-_printer.MM2PX (separator));
                LineTo (x,y+thl+_printer.MM2PX (separator));
              end;
            inc (y,thl);
            inc (y,_printer.MM2PY (separator));
          end;
      end;
    with _printer.Canvas do
      begin
        MoveTo (left,y);
        LineTo (left+w0+tw,y);
        inc (y,_printer.MM2PY (separator));
        x:= left;
        MoveTo (x,y-_printer.MM2PX (separator));
        LineTo (x,y+thl+_printer.MM2PX (separator));
        st:= TECH_REPORT_TOTAL;
        TextOut (x+_printer.MM2PX (separator),y,st);
        st:= IntToStr (total);
        w:= TextWidth (st);
        TextOut (x+w0-_printer.MM2PX (separator)-w,y,st);
        inc (x,w0);
        MoveTo (x,y-_printer.MM2PX (separator));
        LineTo (x,y+thl+_printer.MM2PX (separator));
        for j:= 0 to Length (a [0].cells)-1 do
          begin
            cnt:= 0;
            for i:= 0 to Length (a)-1 do
              inc (cnt,a [i].cells [j].count);
            st:= IntToStr (cnt);
            x1:= (x+x+cw-TextWidth (st)) div 2;
            TextOut (x1,y,st);
            inc (x,cw);
            MoveTo (x,y-_printer.MM2PX (separator));
            LineTo (x,y+thl+_printer.MM2PX (separator));
          end;
        inc (y,thl);
        inc (y,_printer.MM2PY (separator));
        MoveTo (left,y);
        LineTo (left+w0+tw,y);
        inc (y,_printer.MM2PY (separator));
      end;

    for i:= 0 to Length (a)-1 do
      SetLength (a [i].cells,0);
    SetLength (a,0);
  end;

var
  i: integer;
  Reg: TRegistry;
  _printing: boolean;
begin // PrintResults
  if Prn= nil then
    begin
      Prn:= Printer;
      if Prn= nil then
        exit;
    end;

  _printer:= TMyPrinter.Create (Prn);
  _printer.Orientation:= poPortrait;
  _printer.PageSize:= psA4;
  _printer.Copies:= ACopies;
  if _printer.PDF<> nil then
    begin
      if not _printer.PDF.Printing then
        begin
          _printer.PDF.ProtectionEnabled:= true;
          _printer.PDF.ProtectionOptions:= [coPrint];
          _printer.PDF.Compression:= ctFlate;
        end;
      _printing:= _printer.PDF.Printing;
    end
  else
    begin
      _printing:= _printer.Printer.Printing;
    end;
  if not _printing then
    begin
      _printer.Title:= Format (EVENT_RESULTS_PRINT_TITLE,[Event.ShortName]);
      _printer.BeginDoc;
    end;
  _printer.SetBordersMM (15,10,10,5);

  if AFinal then
    Shooters.SortOrder:= soFinal
  else
    Shooters.SortOrder:= soSeries;

  font_name:= 'Arial';
  font_size:= 10;
  xsep:= _printer.MM2PX (2);
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

  with _printer.Canvas do
    begin
      Font.Name:= font_name;
      Font.Charset:= PROTOCOL_CHARSET;
      Font.Size:= font_size;
      font_height_large:= Font.Height;
      font_height_small:= round (font_height_large * 4/5);
      ysep:= abs (font_height_large) div 5;
    end;

  repeat
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        thl:= TextHeight ('Mg');
        Font.Height:= font_height_small;
        ths:= TextHeight ('Mg');
      end;
    footerheight:= ths*2+_printer.MM2PY (4)+_printer.MM2PY (5);
    if (Global_PrintSecretery) and (Info.Secretery+Info.SecreteryCategory<> '') then
      inc (footerheight,thl*2+_printer.MM2PY (5));
    if (Global_PrintJury) and (Info.Jury+Info.JuryCategory<> '') then
      inc (footerheight,thl*2+_printer.MM2PY (5));
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
            exit;
          end;
      end;
  until false;

  havefinalfracs:= false;

  page_idx:= 1;
  MakeNewPage;
  
  if IsPairedEvent then
    begin
      // For paired events, process shooters in pairs
      i:= 0;
      while i< Shooters.Count do
        begin
          sh:= Shooters.Items [i];
          is_pair_first:= (i mod 2 = 0);
          
          // Get the pair partner if this is first in pair and partner exists
          if is_pair_first and (i+1 < Shooters.Count) then
            sh_pair:= Shooters.Items [i+1]
          else
            sh_pair:= nil;
            
          lineheight:= MeasureItemHeight;
          if y+lineheight> _printer.Bottom-footerheight then
            begin
              inc (page_idx);
              MakeNewPage;
            end;
          PrintShooterItem;
          inc (y,lineheight+ysep);
          
          // For paired events, skip printing second shooter individually
          // (it's already printed as part of the pair)
          if is_pair_first and (sh_pair <> nil) then
            inc (i,2)  // Skip both shooters
          else
            inc (i);   // Just move to next
        end;
    end
  else
    begin
      // For non-paired events, process normally
      for i:= 0 to Shooters.Count-1 do
        begin
          sh:= Shooters.Items [i];
          sh_pair:= nil;
          is_pair_first:= false;
          lineheight:= MeasureItemHeight;
          if y+lineheight> _printer.Bottom-footerheight then
            begin
              inc (page_idx);
              MakeNewPage;
            end;
          PrintShooterItem;
          inc (y,lineheight+ysep);
        end;
    end;

  if ATeams then
    PrintTeamsReport;
  if ATeamPoints then
    PrintTeamPointsReport;
  if ADistrictPoints then
    PrintDistrictPointsReport;
  if ARegionPoints then
    PrintRegionPointsReport;
  if AReport then
    PrintTechReport;

  if not _printing then
    _printer.EndDoc;
  _printer.Free;
end;

function TStartListEventItem.IsFinalOk: boolean;
var
  fin,i: integer;
begin
  fin:= 0;
  for i:= 0 to Shooters.Count-1 do
    if Shooters.Items [i].FinalResult10> 0 then
      inc (fin);
  Result:= (fin> 0);
end;

function TStartListEventItem.get_Event: TEventItem;
begin
//  Result:= fShootingEvent.Event;
  Result:= fEvent;
end;

function TStartListEventItem.get_Info: TStartListInfo;
begin
  if fInfo<> nil then
    Result:= fInfo
  else
    Result:= StartList.Info;
end;

function TStartListEventItem.InfoOverriden: boolean;
begin
  Result:= (fInfo<> nil);
end;

procedure TStartListEventItem.OverrideInfo;
begin
  if fInfo= nil then
    begin
      fInfo:= TStartListInfo.Create (self);
      fInfo.Assign (StartList.Info);
      fChanged:= true;
    end;
end;

procedure TStartListEventItem.DeleteInfo;
begin
  if fInfo<> nil then
    begin
      fInfo.Free;
      fInfo:= nil;
      fChanged:= true;
    end;
end;

procedure TStartListEventItem.PrintShootersList (Prn: TObject; ACopies: integer);
const
  separator= 3;
var
  font_height_large: integer;
  font_height_small: integer;
  thl,ths: integer;
  footerheight,lineheight: integer;
  page_idx: integer;
  y: integer;
  cw: array [0..31] of integer;
  font_name: string;
  font_size: integer;
  _printer: TMyPrinter;

  function MeasureColumns: boolean;
  var
    i: integer;
    sh: TStartListEventShooterItem;
    st: string;
    w: integer;
  begin
    for i:= 0 to 31 do
      cw [i]:= 0;

    with _printer.Canvas do
      begin
        Font.Style:= [];
        Font.Height:= font_height_small;
        if StartList.StartNumbers then
          cw [1]:= TextWidth (CLMN_START_NUMBER);
        cw [3]:= TextWidth (CLMN_SHOOTER);
        cw [6]:= TextWidth (CLMN_REGION);
        cw [7]:= TextWidth (CLMN_SOC_CLUB);
        if HasTeamsForResult then
          cw [8]:= TextWidth (CLMN_RESTEAM);
        if HasTeamsForPoints then
          cw [9]:= TextWidth (CLMN_POINTSTEAM);
        if HasDistrictsPoints then
          cw [10]:= TextWidth (CLMN_POINTSDISTRICT);
        if HasRegionsPoints then
          cw [11]:= TextWidth (CLMN_POINTSREGION);
        cw [12]:= TextWidth (CLMN_RELAY);
        cw [13]:= TextWidth (CLMN_LANE);

        Font.Style:= [];
        Font.Height:= font_height_large;
        for i:= 0 to Shooters.Count-1 do
          begin
            sh:= Shooters.Items [i];

            // �����
            st:= IntToStr (i+1)+'.';
            w:= TextWidth (st);
            if w> cw [0] then
              cw [0]:= w;

            // ��������� �����
            if StartList.StartNumbers then
              begin
                st:= sh.StartNumberStr;
                w:= TextWidth (st);
                if w> cw [1] then
                  cw [1]:= w;
              end;

            // ��
            if sh.OutOfRank then
              st:= OUT_OF_RANK_MARK
            else
              st:= '';
            if st<> '' then
              begin
                w:= TextWidth (st);
                if w> cw [2] then
                  cw [2]:= w;
              end;

            // ������� ��� �������� ����� �������
            if sh.Shooter.StepName<> '' then
              st:= sh.Shooter.SurnameAndName+' '+sh.Shooter.StepName
            else
              st:= sh.Shooter.SurnameAndName;
            w:= TextWidth (st);
            if w> cw [3] then
              cw [3]:= w;

            // ���� �������� ���������
            st:= sh.Shooter.BirthFullStr;
            w:= TextWidth (st);
            if w> cw [4] then
              cw [4]:= w;

            // ������
            st:= sh.Shooter.QualificationName;
            w:= TextWidth (st);
            if w> cw [5] then
              cw [5]:= w;

            // �������
            st:= sh.Shooter.RegionsAbbr;
            w:= TextWidth (st);
            if w> cw [6] then
              cw [6]:= w;

            // ����
            st:= sh.Shooter.SocietyAndClub;
            w:= TextWidth (st);
            if w> cw [7] then
              cw [7]:= w;

            // �������
            if HasTeamsForResult then
              begin
                st:= sh.TeamForResults;
                if st<> '' then
                  begin
                    w:= TextWidth (st);
                    if w> cw [8] then
                      cw [8]:= w;
                  end;
              end;

            // ����� �� �������
            if HasTeamsForPoints then
              begin
                st:= sh.TeamForPoints;
                if st<> '' then
                  begin
                    w:= TextWidth (st);
                    if w> cw [9] then
                      cw [9]:= w;
                  end;
              end;

            // ����� �� �����
            if HasDistrictsPoints then
              begin
                if sh.GiveDistrictPoints then
                  st:= YES_MARK
                else
                  st:= '';
                if st<> '' then
                  begin
                    w:= TextWidth (st);
                    if w> cw [10] then
                      cw [10]:= w;
                  end;
              end;

            // ����� �� ������
            if HasRegionsPoints then
              begin
                if sh.GiveRegionPoints then
                  st:= YES_MARK
                else
                  st:= '';
                if st<> '' then
                  begin
                    w:= TextWidth (st);
                    if w> cw [11] then
                      cw [11]:= w;
                  end;
              end;

            // �����, ���
            if (sh.Relay<> nil) then
              begin
                st:= IntToStr (sh.Relay.Index+1);
                w:= TextWidth (st);
                if w> cw [12] then
                  cw [12]:= w;
              end;

            if sh.Position<> 0 then
              begin
                st:= IntToStr (sh.Position);
                w:= TextWidth (st);
                if w> cw [13] then
                  cw [13]:= w;
              end;
          end;

        for i:= 0 to 31 do
          if cw [i]<> 0 then
            cw [i]:= cw [i]+_printer.MM2PX (separator);
        i:= 0;
        while i< 32 do
          begin
            if cw [i]> 0 then
              begin
                cw [i]:= cw [i]-_printer.MM2PX (separator/2);
                break;
              end;
            inc (i);
          end;
        i:= 31;
        while i>= 0 do
          begin
            if cw [i]> 0 then
              begin
                cw [i]:= cw [i]-_printer.MM2PX (separator/2);
                break;
              end;
            dec (i);
          end;
        w:= 0;
        for i:= 0 to 31 do
          inc (w,cw [i]);
        if w<= _printer.Width then
          begin
            Result:= true;
            cw [3]:= cw [3]+_printer.Width-w;
          end
        else
          Result:= false;
      end;
  end;

  procedure MakePageLayout;
  var
    st: string;
    x,i: integer;
    s: TStrings;
  begin
    with _printer.Canvas do
      begin
        // footer
        Pen.Width:= 1;
        y:= _printer.Bottom-footerheight+_printer.MM2PY (2);
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
        Font.Height:= font_height_small;
        st:= Format (PAGE_NO,[page_idx]);
        TextOut (_printer.Right-TextWidth (st),y,st);
        st:= Format (PAGE_FOOTER,[VERSION_INFO_STR]);
        TextOut (_printer.Left,y,st);
        y:= y+TextHeight ('Mg');
        st:= PROTOCOL_MAKER_SIGN;
        TextOut (_printer.Left,y,st);

        // header
        y:= _printer.Top;
        Font.Height:= font_height_large;
        Font.Style:= [];
        s:= TStringList.Create;
        s.Text:= Info.TitleText;
        for i:= 0 to s.Count-1 do
          begin
            st:= s [i];
            x:= (_printer.Left+_printer.Right-TextWidth (st)) div 2;
            TextOut (x,y,st);
            inc (y,TextHeight (st));
          end;
        if s.Count> 0 then
          inc (y,_printer.MM2PY (2));
        s.Free;

        st:= Format (EVENT_SHOOTERS_TITLE,[Event.ShortName,Event.Name]);
        x:= _printer.Left;
        TextOut (x,y,st);
        y:= y+TextHeight ('Mg')+_printer.MM2PY (2);

        // �������� �����
        Pen.Width:= 1;
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (1);
        Font.Height:= font_height_small;
        Font.Style:= [];
        x:= _printer.Left+cw [0];
        if StartList.StartNumbers then
          begin
            st:= CLMN_START_NUMBER;
            TextOut (x+_printer.MM2PX (separator/2),y,st);
          end;
        x:= x+cw [1]+cw [2];
        st:= CLMN_SHOOTER;
        TextOut (x+_printer.MM2PX (separator/2),y,st);
        x:= x+cw [3]+cw [4]+cw [5];
        st:= CLMN_REGION;
        TextOut (x+_printer.MM2PX (separator/2),y,st);
        x:= x+cw [6];
        st:= CLMN_SOC_CLUB;
        TextOut (x+_printer.MM2PX (separator/2),y,st);
        x:= x+cw [7];
        if HasTeamsForResult then
          begin
            st:= CLMN_RESTEAM;
            TextOut (x+_printer.MM2PX (separator/2),y,st);
          end;
        x:= x+cw [8];
        if HasTeamsForPoints then
          begin
            st:= CLMN_POINTSTEAM;
            TextOut (x+_printer.MM2PX (separator/2),y,st);
          end;
        x:= x+cw [9];
        if HasDistrictsPoints then
          begin
            st:= CLMN_POINTSDISTRICT;
            TextOut (x+_printer.MM2PX (separator/2),y,st);
          end;
        x:= x+cw [10];
        if HasRegionsPoints then
          begin
            st:= CLMN_POINTSREGION;
            TextOut (x+_printer.MM2PX (separator/2),y,st);
          end;
        x:= x+cw [11];
        st:= CLMN_RELAY;
        TextOut (x+_printer.MM2PX (separator/2),y,st);
        x:= x+cw [12];
        st:= CLMN_LANE;
        TextOut (x+_printer.MM2PX (separator/2),y,st);

        y:= y+TextHeight ('Mg')+_printer.MM2PY (1);

        Font.Height:= font_height_large;
        Font.Style:= [];
        Pen.Width:= 1;
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
      end;
  end;

var
  sh: TStartListEventShooterItem;

  procedure PrintShooterItem;
  var
    st: string;
    cx: integer;
  begin
    cx:= _printer.Left;
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [];

        // ������
        st:= IntToStr (sh.Index+1)+'.';
        TextOut (cx+cw [0]-_printer.MM2PX (separator/2)-TextWidth (st),y,st);
        cx:= cx+cw [0];

        // ��������� �����
        if StartList.StartNumbers then
          begin
            st:= sh.StartNumberStr;
            TextOut (cx+_printer.MM2PX (separator/2),y,st);
            cx:= cx+cw [1];
          end;

        // ��
        if sh.OutOfRank then
          begin
            st:= OUT_OF_RANK_MARK;
            TextOut (cx+_printer.MM2PX (separator/2),y,st);
          end;
        cx:= cx+cw [2];

        // ������� ��� ��������
        if sh.Shooter.StepName<> '' then
          st:= sh.Shooter.SurnameAndName+' '+sh.Shooter.StepName
        else
          st:= sh.Shooter.SurnameAndName;
        TextOut (cx+_printer.MM2PX (separator/2),y,st);
        cx:= cx+cw [3];

        // ���� �������� ���������
        st:= sh.Shooter.BirthFullStr;
        TextOut (cx+_printer.MM2PX (separator/2),y,st);
        cx:= cx+cw [4];

        // ������
        st:= sh.Shooter.QualificationName;
        TextOut (cx+_printer.MM2PX (separator/2),y,st);
        cx:= cx+cw [5];

        // �������
        st:= sh.Shooter.RegionAbbr1;
        TextOut (cx+_printer.MM2PX (separator/2),y,st);
        cx:= cx+cw [6];

        // ����
        st:= sh.Shooter.SocietyAndClub;
        TextOut (cx+_printer.MM2PX (separator/2),y,st);
        cx:= cx+cw [7];

        // �������
        st:= sh.TeamForResults;
        if st<> '' then
          TextOut (cx+_printer.MM2PX (separator/2),y,st);
        cx:= cx+cw [8];

        // ����� �� �������
        if HasTeamsForPoints then
          begin
            st:= sh.TeamForPoints;
            if st<> '' then
              TextOut (cx+_printer.MM2PX (separator/2),y,st);
          end;
        cx:= cx+cw [9];

        // ����� �� �����
        if HasDistrictsPoints then
          begin
            if sh.GiveDistrictPoints then
              st:= YES_MARK
            else
              st:= '';
            if st<> '' then
              TextOut (cx+_printer.MM2PX (separator/2),y,st);
          end;
        cx:= cx+cw [10];

        // ����� �� ������
        if HasRegionsPoints then
          begin
            if sh.GiveRegionPoints then
              st:= YES_MARK
            else
              st:= '';
            if st<> '' then
              TextOut (cx+_printer.MM2PX (separator/2),y,st);
          end;
        cx:= cx+cw [11];

        // �����
        if sh.Relay<> nil then
          begin
            st:= IntToStr (sh.Relay.Index+1);
            TextOut (cx+_printer.MM2PX (separator/2),y,st);
          end;
        cx:= cx+cw [12];

        // ���
        if sh.Position<> 0 then
          begin
            st:= IntToStr (sh.Position);
            TextOut (cx+_printer.MM2PX (separator/2),y,st);
          end;
      end;
  end;

  procedure MakeNewPage;
  begin
    if page_idx> 1 then
      begin
        _printer.NewPage;
      end;
    MakePageLayout;
  end;

var
  i: integer;
  Reg: TRegistry;
begin
  if Prn= nil then
    begin
      Prn:= Printer;
      if Prn= nil then
        exit;
    end;

  _printer:= TMyPrinter.Create (Prn);
  _printer.Orientation:= poPortrait;
  _printer.PageSize:= psA4;
  _printer.Copies:= ACopies;
  if _printer.PDF<> nil then
    begin
      _printer.PDF.ProtectionEnabled:= true;
      _printer.PDF.ProtectionOptions:= [coPrint];
      _printer.PDF.Compression:= ctFlate;
    end;
  _printer.Title:= format (EVENT_SHOOTERS_PRINT_TITLE,[Event.ShortName]);
  _printer.BeginDoc;
  _printer.SetBordersMM (15,10,5,10);

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

  with _printer.Canvas.Font do
    begin
      Name:= font_name;
      Size:= font_size;
      font_height_large:= Height;
      font_height_small:= round (font_height_large * 3/4);
      Charset:= PROTOCOL_CHARSET;
    end;

  repeat
    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        thl:= TextHeight ('Mg');
        Font.Height:= font_height_small;
        ths:= TextHeight ('Mg');
      end;
    footerheight:= ths*2+_printer.MM2PY (4);
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
            exit;
          end;
      end;
  until false;

  page_idx:= 1;
  MakeNewPage;
  for i:= 0 to Shooters.Count-1 do
    begin
      sh:= Shooters.Items [i];
      lineheight:= thl; //MeasureItemHeight;
      if y+lineheight+_printer.MM2PY (2)> _printer.Bottom-footerheight then
        begin
          inc (page_idx);
          MakeNewPage;
        end;
      PrintShooterItem;
      inc (y,lineheight+_printer.MM2PY (1));
    end;

  _printer.EndDoc;
  _printer.Free;
end;

(*
function TStartListEventItem.PrepareStartListPrint: TStartListReport;
begin
  case fEvent.EventType of
    etRapidFire: {Result:= TStartListRapidFirePrint.Create (self)};
  else
    Result:= TStartListRegularReportPrint.Create (self);
  end;
end;
*)

procedure TStartListEventItem.SaveResults;
var
  i: integer;
  sev: TShootingEventItem;
  sch: TShootingChampionshipItem;
  _date: TDateTime;
begin
  _date:= DateTill;
  sch:= StartList.Data.ShootingChampionships.Find (Info.Championship,Info.ChampionshipName,_date);
  if sch= nil then
    begin
      sch:= StartList.Data.ShootingChampionships.Add;
      sch.SetChampionship (Info.Championship,Info.ChampionshipName);
      sch.Country:= '';
      sch.Town:= Info.Town;
    end;
  sev:= sch.Events.Find (Event,'',_date);
  if sev= nil then
    begin
      sev:= sch.Events.Add;
      sev.SetEvent (Event,'','');
      sev.Date:= _date;
    end;
  Shooters.SortOrder:= soFinal;
  for i:= 0 to fShooters.Count-1 do
    fShooters.Items [i].SaveResult (sev);
  fChanged:= true;
end;

{function TStartListEventItem.SaveResultsHTML(AFinal, ATeams, ATeamPoints,
  ARegionPoints, ADistrictPoints, AReport: boolean): TStrings;
var
  html: TStrings;
  i: integer;
  sh: TStartListEventShooterItem;
begin
  html:= TStringList.Create;
  html.Add ('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">');
  html.Add ('<html lang="en">');
  html.Add ('<head>');
  html.Add ('<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">');
  html.Add ('</head>');
  html.Add ('<body style="font-family: arial,sans-serif">');
  html.Add ('<center><b>');
  html.Add (Info.TitleText);
  html.Add ('</b></center><p>');

  html.Add ('<table width="100%" border=1 frame=box cellspacing=0 cellpadding=0>');
  // TODO: head
  html.Add ('<tbody>');

  for i:= 0 to Shooters.Count-1 do
    begin
      sh:= Shooters.Items[i];
      html.Add ('<tr border=0>');
      //!
      html.Add ('</tr>');
    end;

  html.Add ('</tbody>');
  html.Add ('</table>');

  html.Add ('</body></html>');
end;}

function TStartListEventItem.Saved: integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Shooters.Count-1 do
    if Shooters.Items [i].Saved then
      inc (Result);
end;

function TStartListEventItem.Fights: integer;
var
  i: integer;
begin
  Result:= 0;
  if IsFinalOk then
    Shooters.SortOrder:= soFinal
  else
    Shooters.SortOrder:= soSeries;
  for i:= 0 to Shooters.Count-1 do
    if (i> 0) and (Shooters.Items [i].CompareTo (Shooters.Items [i-1],Shooters.SortOrder)= 0) then
      inc (Result);
end;

function TStartListEventItem.FindShooter(AStartNumber: integer): TStartListEventShooterItem;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to fShooters.Count-1 do
    if fShooters.Items [i].StartNumber= AStartNumber then
      begin
        Result:= fShooters.Items [i];
        break;
      end;
end;

function TStartListEventItem.Gender: TGender;
var
  males,females: integer;
  i: integer;
  sh: TStartListEventShooterItem;
begin
  males:= 0;
  females:= 0;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      case sh.Shooter.Gender of
        Male: inc (males);
        Female: inc (females);
      end;
    end;
  if males>= females then
    Result:= Male
  else
    Result:= Female;
end;

procedure TStartListEventItem.SaveShootersListToPDF (const FName: TFileName);
var
  doc: TPDFDocument;
begin
  doc:= TPDFDocument.Create (nil);
  doc.DefaultCharset:= PROTOCOL_CHARSET;
  doc.FileName:= FName;
  doc.AutoLaunch:= false;
  try
    PrintShootersList (doc,1);
  finally
    doc.Free;
  end;
end;

procedure TStartListEventItem.SaveStartListPDF(const FName: TFileName);
var
  doc: TPDFDocument;
begin
  doc:= TPDFDocument.Create (nil);
  doc.DefaultCharset:= PROTOCOL_CHARSET;
  doc.FileName:= FName;
  doc.AutoLaunch:= false;
  try
    PrintStartList (doc,1);
  finally
    doc.Free;
  end;
end;

function TStartListEventItem.SerieTemplate: string;
begin
  if fCompetitionWithTens then
    Result:= '000.0'
  else
    Result:= '000';
end;

function TStartListEventItem.IsPairedEvent: boolean;
begin
  // Detect paired events by checking if shortname contains female+male marker
  Result:= (Pos('Ж+М', Event.ShortName) > 0) or (Pos('М+Ж', Event.ShortName) > 0) or
           (Pos('(Ж+М)', Event.ShortName) > 0) or (Pos('(М+Ж)', Event.ShortName) > 0);
end;

procedure TStartListEventItem.SaveResultsPDF(const FName: TFileName; AFinal: boolean;
  ATeams: boolean; ATeamPoints: boolean; ARegionPoints: boolean;
  ADistrictPoints: boolean; AReport: boolean);
var
  doc: TPDFDocument;
begin
  doc:= TPDFDocument.Create (nil);
  doc.DefaultCharset:= PROTOCOL_CHARSET;
  doc.FileName:= FName;
  doc.AutoLaunch:= false;
  try
    PrintResults (doc,AFinal,ATeams,ATeamPoints,ARegionPoints,ADistrictPoints,AReport,1,true);
  finally
    doc.Free;
  end;
end;

procedure TStartListEventItem.SaveResultsPDF(doc: TPDFDocument; AFinal: boolean;
  ATeams: boolean; ATeamPoints: boolean; ARegionPoints: boolean;
  ADistrictPoints: boolean; AReport: boolean);
begin
  // TODO: Restore PDF functionality after migration
  // PDF functions temporarily disabled for Delphi 12 compatibility
end;

procedure TStartListEventItem.SaveResultsPDFInternational(
  doc: TPDFDocument; AFinal, ATeams: boolean);
begin
  // TODO: Restore PDF functionality after migration
  // PDF functions temporarily disabled for Delphi 12 compatibility
end;

procedure TStartListEventItem.SaveResultsPDFInternational(const FName: TFileName; AFinal, ATeams: boolean);
var
  doc: TPDFDocument;
begin
  doc:= TPDFDocument.Create (nil);
  doc.DefaultCharset:= PROTOCOL_CHARSET;
  doc.FileName:= FName;
  doc.AutoLaunch:= false;
  try
    PrintInternationalResults (doc,AFinal,ATeams,1,true);
  finally
    doc.Free;
  end;
end;

function TStartListEventItem.RegionPoints(ARegion: string; AGenders: TGenders): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
  _teams: TStartListEventTeams;
begin
  Result:= 0;
  if ARegion= '' then
    exit;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (not sh.OutOfRank) and (sh.GiveRegionPoints) and (sh.Shooter.Gender in AGenders) then
        begin
          if AnsiSameText (sh.Shooter.RegionAbbr1,ARegion) then
            Result:= Result+sh.RegionPoints+sh.QualificationPoints+sh.ManualPoints;
          if AnsiSameText (sh.Shooter.RegionAbbr2,ARegion) then
            Result:= Result+(sh.RegionPoints+sh.QualificationPoints+sh.ManualPoints) div 2;
        end;
    end;
  if RTeamsPoints.Count> 0 then
    begin
      _teams:= TStartListEventTeams.Create (self);
      Result:= Result+_teams.RegionPoints (ARegion,AGenders);
      _teams.Free;
    end;
end;

function TStartListEventItem.RegionPointsShooters(ARegion: string; AGenders: TGenders): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= 0;
  if ARegion= '' then
    exit;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (not sh.OutOfRank) and (sh.GiveRegionPoints) and (sh.Shooter.Gender in AGenders) then
        begin
          if AnsiSameText (sh.Shooter.RegionAbbr1,ARegion) then
            inc (Result);
          if AnsiSameText (sh.Shooter.RegionAbbr2,ARegion) then
            inc (Result);
        end;
    end;
end;

procedure TStartListEventItem.ResetResults;
var
  i: integer;
begin
  for i:= 0 to Shooters.Count-1 do
    Shooters.Items [i].ResetResults;
end;

function TStartListEventItem.DistrictPoints(ADistrict: string; AGenders: TGenders): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= 0;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (sh.Shooter.DistrictAbbr= ADistrict) and (not sh.OutOfRank) and (sh.GiveDistrictPoints) and
        (sh.Shooter.Gender in AGenders) then
        Result:= Result+sh.DistrictPoints+sh.QualificationPoints+sh.ManualPoints;
    end;
end;

function TStartListEventItem.DistrictPointsShooters(ADistrict: string; AGenders: TGenders): integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= 0;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      if (sh.Shooter.DistrictAbbr= ADistrict) and (not sh.OutOfRank) and (sh.GiveDistrictPoints) and
        (sh.Shooter.Gender in AGenders) then
        inc (Result);
    end;
end;

procedure TStartListEventItem.ReadFromStream(Stream: TStream);
var
  c: integer;
  tag: String;
  b: boolean;
  _sev: TShootingEventItem;
begin
  if StartList.Data.fFileVersion< 28 then
    begin
      if StartList.Data.fFileVersion< 27 then
        begin
          ReadStrFromStreamA (Stream,tag);
          //Stream.Read (c,sizeof (c));
          //SetLength (tag,c);
          //Stream.Read (tag [1],c);
          fEvent:= StartList.Data.Events.Events [tag];
        end
      else
        begin
          Stream.Read (c,sizeof (c));
          _sev:= StartList._sch.Events [c];
          fEvent:= _sev.Event;
        end;
    end
  else
    begin
      Stream.Read (c,sizeof (c));
      fEvent:= StartList.Data.Events.Items [c];
    end;
  fRelays.ReadFromStream (Stream);
  fShooters.ReadFromStream (Stream);
  Stream.Read (fProtocolNumber,sizeof (fProtocolNumber));
  Stream.Read (fCalculatePoints,sizeof (fCalculatePoints));
  Stream.Read (fFinalTime,sizeof (fFinalTime));
  Stream.Read (b,sizeof (b));
  if b then
    begin
      OverrideInfo;
      fInfo.ReadFromStream (Stream);
    end
  else
    DeleteInfo;
  fRegionsPoints.ReadFromStream (Stream);
  if StartList.Data.fFileVersion>= 31 then
    begin
      fDistrictsPoints.ReadFromStream (Stream);
      fPTeamsPoints.ReadFromStream (Stream);
    end
  else
    begin
      fDistrictsPoints.Assign (fRegionsPoints);
      fPTeamsPoints.Assign (fRegionsPoints);
    end;
  if StartList.Data.fFileVersion>= 15 then
    Stream.Read (fHasFinal,sizeof (fHasFinal))
  else
    fHasFinal:= fEvent.FinalPlaces> 31;
  if StartList.Data.fFileVersion>= 24 then
    Stream.Read (fInPointsTable,sizeof (fInPointsTable))
  else
    fInPointsTable:= true;
  if StartList.Data.fFileVersion< 28 then
    begin
      if StartList.Data.fFileVersion< 27 then
        begin
          if StartList.Data.fFileVersion>= 26 then
            begin
              Stream.Read (c,sizeof (c));
//              fShootingEvent:= ShootingChampionship.Events [c];
            end
          else
//            fShootingEvent:= nil;
        end;
    end;
  if StartList.Data.fFileVersion>= 30 then
    fRTeamsPoints.ReadFromStream (Stream)
  else
    fRTeamsPoints.Clear;
  if StartList.Data.fFileVersion>= 38 then
    Stream.Read (fCompetitionWithTens,sizeof (fCompetitionWithTens));
  if StartList.Data.fFileVersion>= 42 then
    Stream.Read (fNewFinalFormat,sizeof (fNewFinalFormat))
  else
    fNewFinalFormat:= false;
  if StartList.Data.fFileVersion>= 41 then
    begin
      // Read gold match shots and points
      Stream.Read (c,sizeof(c));
      SetLength(fgGoldShots1, c);
      if c>0 then
        Stream.Read(fgGoldShots1[0], c * SizeOf(word));
      Stream.Read (c,sizeof(c));
      SetLength(fgGoldShots2, c);
      if c>0 then
        Stream.Read(fgGoldShots2[0], c * SizeOf(word));
      Stream.Read (fgGoldPoints1, sizeof(fgGoldPoints1));
      Stream.Read (fgGoldPoints2, sizeof(fgGoldPoints2));
      Stream.Read (fgGoldShooterIdx1, sizeof(fgGoldShooterIdx1));
      Stream.Read (fgGoldShooterIdx2, sizeof(fgGoldShooterIdx2));
    end
  else
    begin
      SetLength(fgGoldShots1, 0);
      SetLength(fgGoldShots2, 0);
      fgGoldPoints1 := 0;
      fgGoldPoints2 := 0;
      fgGoldShooterIdx1 := -1;
      fgGoldShooterIdx2 := -1;
    end;
  fChanged:= false;
end;

procedure TStartListEventItem.WriteToStream(Stream: TStream);
var
  c: integer;
//  tag: string;
  b: boolean;
begin
{  tag:= fEvent.Tag;
  c:= Length (tag);
  Stream.Write (c,sizeof (c));
  Stream.Write (tag [1],c);}
//  c:= fShootingEvent.Index;
//  Stream.Write (c,sizeof (c));
  c:= fEvent.Index;
  Stream.Write (c,sizeof (c));
  fRelays.WriteToStream (Stream);
  fShooters.WriteToStream (Stream);
  Stream.Write (fProtocolNumber,sizeof (fProtocolNumber));
  Stream.Write (fCalculatePoints,sizeof (fCalculatePoints));
  Stream.Write (fFinalTime,sizeof (fFinalTime));
  b:= (fInfo<> nil);
  Stream.Write (b,sizeof (b));
  if b then
    fInfo.WriteToStream (Stream);
  fRegionsPoints.WriteToStream (Stream);
  fDistrictsPoints.WriteToStream (Stream);
  fPTeamsPoints.WriteToStream (Stream);
  Stream.Write (fHasFinal,sizeof (fHasFinal));
  Stream.Write (fInPointsTable,sizeof (fInPointsTable));
//  c:= fShootingEvent.Index;
//  Stream.Write (c,sizeof (c));
  fRTeamsPoints.WriteToStream (Stream);
  Stream.Write (fCompetitionWithTens,sizeof (fCompetitionWithTens));
  Stream.Write (fNewFinalFormat,sizeof (fNewFinalFormat));
  // Write gold match arrays (since v41)
  c := Length(fgGoldShots1);
  Stream.Write(c, SizeOf(c));
  if c>0 then
    Stream.Write(fgGoldShots1[0], c * SizeOf(word));
  c := Length(fgGoldShots2);
  Stream.Write(c, SizeOf(c));
  if c>0 then
    Stream.Write(fgGoldShots2[0], c * SizeOf(word));
  Stream.Write(fgGoldPoints1, SizeOf(fgGoldPoints1));
  Stream.Write(fgGoldPoints2, SizeOf(fgGoldPoints2));
  Stream.Write(fgGoldShooterIdx1, SizeOf(fgGoldShooterIdx1));
  Stream.Write(fgGoldShooterIdx2, SizeOf(fgGoldShooterIdx2));
  fChanged:= false;
end;

function TStartListEventItem.Events: TStartListEvents;
begin
  Result:= Collection as TStartListEvents;
end;

procedure TStartListEventItem.ExportResultsToCSV(const FName: TFileName);
var
  s: TStringList;
  i: integer;
  fs: TFileStream;
  utf8Bytes: TBytes;
  csvLine: string;
begin
  if Shooters.Count = 0 then
    raise Exception.Create('��� ������ ��� ��������');
    
  Shooters.SortOrder:= soFinal;
  s:= TStringList.Create;
  try
    // ��������� ��������� CSV
    s.Add('������,��������� �����,�������,���,��� ��������,������������,���������');
    
    // ��������� ������ ��������
    for i:= 0 to Shooters.Count-1 do
      begin
        try
          csvLine := Shooters.Items [i].CSVStr;
          if csvLine <> '' then
            s.Add(csvLine);
        except
          on E: Exception do
            s.Add('������ ��� ��������� ������� #' + IntToStr(i+1) + ': ' + E.Message);
        end;
      end;
    
    if s.Count <= 1 then
      raise Exception.Create('��� ������ ��� �������� (������ ���������)');
    
    // ��������� � UTF-8 ��� ����������� ����������� ������� ��������
    try
      fs := TFileStream.Create(FName, fmCreate);
      try
        // ��������� BOM ��� UTF-8
        utf8Bytes := TEncoding.UTF8.GetPreamble;
        if Length(utf8Bytes) > 0 then
          fs.WriteBuffer(utf8Bytes[0], Length(utf8Bytes));
        
        // ���������� ���������� � UTF-8
        utf8Bytes := TEncoding.UTF8.GetBytes(s.Text);
        fs.WriteBuffer(utf8Bytes[0], Length(utf8Bytes));
      finally
        fs.Free;
      end;
    except
      on E: Exception do
        begin
          // ���� �� ������� ��������� � UTF-8, ��������� ������� ��������
          try
            s.SaveToFile(FName);
          except
            on E2: Exception do
              raise Exception.Create('�� ������� ��������� ����: ' + E2.Message);
          end;
        end;
    end;
  finally
    s.Free;
  end;
end;

procedure TStartListEventItem.ExportStartListToAscor(PositionIndex: integer; FileName: string);
var
  i: integer;
  s: TStrings;
  fs: TFileStream;
  sh: TStartListEventShooterItem;
begin
  if not IsLotsDrawn then
    exit;
  s:= TStringList.Create;
  for i:= 0 to fShooters.Count-1 do
    begin
      sh:= fShooters.Items [i];
      s.Add (sh.AscorStartListStr (PositionIndex));
    end;
  try
    fs:= TFileStream.Create (FileName,fmCreate);
    try
      s.SaveToStream (fs);
    finally
      fs.Free;
    end;
  finally
    s.Free;
  end;
end;

procedure TStartListEventItem.set_ProtocolNumber(const Value: integer);
begin
  if Value<> fProtocolNumber then
    begin
      fProtocolNumber:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventItem.set_CalculatePoints(const Value: boolean);
begin
  if Value<> fCalculatePoints then
    begin
      fCalculatePoints:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventItem.set_CompetitionWithTens(const Value: boolean);
begin
  if Value<> fCompetitionWithTens then
    begin
      fCompetitionWithTens:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventItem.set_Event(const Value: TEventItem);
begin
  fEvent:= Value;
  fChanged:= true;
end;

procedure TStartListEventItem.set_FinalTime(const Value: TDateTime);
begin
  if Value<> fFinalTime then
    begin
      fChanged:= true;
      fFinalTime:= Value;
    end;
end;

function TStartListEventItem.get_WasChanged: boolean;
begin
  Result:= (fChanged) or
    (fRelays.WasChanged) or
    (fShooters.WasChanged) or
    ((fInfo<> nil) and (fInfo.WasChanged)) or
    (fRegionsPoints.WasChanged) or (fDistrictsPoints.WasChanged) or (fPTeamsPoints.WasChanged) or
    (fRTeamsPoints.WasChanged);
end;

procedure TStartListEventItem.DeleteFinalResults;
var
  i: integer;
begin
  for i:= 0 to fShooters.Count-1 do
    fShooters.Items [i].ResetFinal;
end;

function TStartListEventItem.DateFrom: TDateTime;
var
  i: integer;
  d1,d2: TDateTime;
begin
  Result:= 0;
  for i:= 0 to fRelays.Count-1 do
    begin
      d1:= DateOf (fRelays [i].StartTime);
      if Event.TwoStarts then
        begin
          d2:= DateOf (fRelays [i].StartTime2);
          if d2< d1 then
            d1:= d2;
        end;
      if (i= 0) or (d1< Result) then
        Result:= d1;
    end;
  if HasFinal then
    begin
      d1:= FinalTime;
      if (d1> 0) and ((d1< Result) or (Result= 0)) then
        Result:= d1;
    end;
end;

function TStartListEventItem.DateTill: TDateTime;
var
  i: integer;
  d1,d2: TDateTime;
begin
  Result:= 0;
  for i:= 0 to fRelays.Count-1 do
    begin
      d1:= DateOf (fRelays [i].StartTime);
      if Event.TwoStarts then
        begin
          d2:= DateOf (fRelays [i].StartTime2);
          if d2> d1 then
            d1:= d2;
        end;
      if (i= 0) or (d1> Result) then
        Result:= d1;
    end;
  if HasFinal then
    begin
      d2:= DateOf (FinalTime);
      if (d2> Result) or (Result= 0) then
        Result:= d2;
    end;
end;

procedure TStartListEventItem.Assign(Source: TPersistent);
var
  AEvent: TStartListEventItem;
//  _ev: TEventItem;
begin
  if Source is TStartListEventItem then
    begin
      AEvent:= Source as TStartListEventItem;
      if AEvent.StartList.Data= StartList.Data then
        begin
          fEvent:= AEvent.Event;
//          fShootingEvent:= AEvent.ShootingEvent;
        end
      else
        begin
          fEvent:= StartList.Data.Events [AEvent.Event.Tag];
{          _ev:= StartList.Data.Events [AEvent.Event.Tag];
          if _ev= nil then
            begin
              _ev:= StartList.Data.Events.Add;
              _ev.Assign (AEvent.Event);
              StartList.Data.Championships.AddEventTable (_ev);
            end;
          fShootingEvent:= ShootingChampionship.Events.Find (_ev,'',AEvent.DateTill);
          if fShootingEvent= nil then
            CreateShootingEvent (_ev);}
        end;
      fHasFinal:= AEvent.fHasFinal;
      fInPointsTable:= AEvent.fInPointsTable;
      fCompetitionWithTens:= AEvent.fCompetitionWithTens;
      fRelays.Assign (AEvent.Relays);
      fShooters.Assign (AEvent.Shooters);
      fProtocolNumber:= AEvent.ProtocolNumber;
      fCalculatePoints:= AEvent.CalculatePoints;
      fFinalTime:= AEvent.FinalTime;
      if AEvent.Info<> nil then
        begin
          AEvent.OverrideInfo;
          AEvent.Info.Assign (AEvent.Info);
        end;
      fRegionsPoints.Assign (AEvent.RegionsPoints);
      fDistrictsPoints.Assign (AEvent.DistrictsPoints);
      fPTeamsPoints.Assign (AEvent.PTeamsPoints);
      fRTeamsPoints.Assign (AEvent.RTeamsPoints);
    end
  else
    inherited;
end;

{ TAbbrNames }

procedure TAbbrNames.Assign(Source: TAbbrNames);
var
  l: integer;
begin
  l:= Length (Source.fAbbrs);
  SetLength (fAbbrs,l);
  move (Source.fAbbrs[0],fAbbrs [0],sizeof (TAbbrRec)*l);
  fChanged:= true;
end;

procedure TAbbrNames.Check;
begin
  // TODO: �������� �����������
end;

procedure TAbbrNames.Clear;
var
  i: integer;
begin
  for i:= 0 to Length (fAbbrs)-1 do
    begin
      fAbbrs [i].abbr:= '';
      fAbbrs [i].name:= '';
    end;
  SetLength (fAbbrs,0);
  fChanged:= true;
end;

function TAbbrNames.Count: integer;
begin
  Result:= Length (fAbbrs);
end;

constructor TAbbrNames.Create(AData: TData);
begin
  inherited Create;
  fData:= AData;
  SetLength (fAbbrs,0);
  fChanged:= false;
end;

destructor TAbbrNames.Destroy;
begin
  Clear;
  inherited;
end;

procedure TAbbrNames.ExportToCSV(const FName: TFileName);
var
  i: integer;
  s: TStrings;
  st: string;
begin
  s:= TStringList.Create;
  s.Add ('id'+CSVDelimiter+'short'+CSVDelimiter+'title');
  for i:= 0 to Count-1 do
    begin
      st:= IntToStr (i+1)+CSVDelimiter+
        StrToCSV (fAbbrs [i].abbr)+CSVDelimiter+StrToCSV (fAbbrs[i].name);
      s.Add (st);
    end;
  try
    s.SaveToFile (FName);
    s.Free;
  except
    s.Free;
    raise;
  end;
end;

function TAbbrNames.get_Item(index: integer): TAbbrRec;
begin
  Result:= fAbbrs [index];
end;

function TAbbrNames.get_Name(Abbr: string): string;
var
  idx: integer;
begin
  idx:= IndexOf (Abbr);
  if idx>= 0 then
    Result:= fAbbrs [idx].name
  else
    Result:= '';
end;

function TAbbrNames.IndexOf(Abbr: string): integer;
var
  i: integer;
begin
  Result:= -1;
  Abbr:= Trim (Abbr);
  if Abbr= '' then
    exit;
  for i:= 0 to Length (fAbbrs)-1 do
    begin
      if AnsiSameText (Abbr,fAbbrs [i].abbr) then
        begin
          Result:= i;
          break;
        end;
    end;
end;

procedure TAbbrNames.ReadFromStream(Stream: TStream);
var
  i,c: integer;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  SetLength (fAbbrs,c);
  for i:= 0 to c-1 do
    begin
      ReadStrFromStreamA (Stream,fAbbrs [i].abbr);
      ReadStrFromStreamA (Stream,fAbbrs [i].name);
    end;
  fChanged:= false;
end;

procedure TAbbrNames.set_Name(Abbr: string; const Value: string);
var
  idx: integer;
  n: string;
begin
  idx:= IndexOf (Abbr);
  Abbr:= Trim (Abbr);
  if Abbr= '' then
    exit;
  n:= Trim (Value);
  if idx< 0 then
    begin
      idx:= Length (fAbbrs);
      SetLength (fAbbrs,idx+1);
      fAbbrs [idx].abbr:= Abbr;
      fAbbrs [idx].name:= n;
      fChanged:= true;
    end
  else
    begin
      if not AnsiSameStr (n,fAbbrs [idx].name) then
        begin
          fAbbrs [idx].name:= n;
          fChanged:= true;
        end;
    end;
end;

function TAbbrNames.WasChanged: boolean;
begin
  Result:= fChanged;
end;

procedure TAbbrNames.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      SaveStrToStreamA (Stream,fAbbrs [i].abbr);
      SaveStrToStreamA (Stream,fAbbrs [i].name);
    end;
  fChanged:= false;
end;

{ TStartListEventShooters }

function TStartListEventShooters.Add: TStartListEventShooterItem;
begin
  Result:= inherited Add as TStartListEventShooterItem;
end;

procedure TStartListEventShooters.Assign(Source: TPersistent);
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  if Source is TStartListEventShooters then
    begin
      Clear;
      for i:= 0 to (Source as TStartListEventShooters).Count-1 do
        begin
          sh:= Add;
          sh.Assign ((Source as TStartListEventShooters).Items [i]);
        end;
    end
  else
    inherited;
end;

constructor TStartListEventShooters.Create;
begin
  inherited Create (TStartListEventShooterItem);
  fStartEvent:= AEvent;
  fSortOrder:= soNone;
  fChanged:= false;
end;

function TStartListEventShooters.Find(From: integer; ASearch: string): integer;
var
  sh: TStartListEventShooterItem;
  i: integer;
begin
  Result:= -1;
  for i:= From to Count-1 do
    begin
      sh:= Items [i];
      if AnsiCompareText (ASearch,copy (sh.Shooter.Surname,1,Length (ASearch)))= 0 then
        begin
          Result:= i;
          exit;
        end;
    end;
end;

function TStartListEventShooters.FindNum(From: integer; ASearch: string): integer;
var
  sh: TStartListEventShooterItem;
  i: integer;
  n: string;
begin
  Result:= -1;
  for i:= From to Count-1 do
    begin
      sh:= Items [i];
      n:= sh.StartNumberStr;
      if AnsiCompareText (ASearch,copy (n,1,Length (ASearch)))= 0 then
        begin
          Result:= i;
          exit;
        end;
    end;
end;

function TStartListEventShooters.FindShooter(AShooter: TShooterItem): TStartListEventShooterItem;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    if Items [i].Shooter= AShooter then
      begin
        Result:= Items [i];
        exit;
      end;
end;

procedure TStartListEventShooters.GetRegionsStats(var RS: TRegionsStats);

  function Find (const R: String): integer;
  var
    i: integer;
  begin
    Result:= -1;
    for i:= 0 to Length (RS)-1 do
      if AnsiSameText (RS [i].Region,R) then
        begin
          Result:= i;
          break;
        end;
  end;

var
  i,idx: integer;
  sh: TStartListEventShooterItem;
begin
  if RS<> nil then
    DeleteRegionsStats (RS);
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.Shooter.RegionAbbr1<> '' then
        begin
          idx:= Find (sh.Shooter.RegionAbbr1);
          if idx= -1 then
            begin
              idx:= Length (RS);
              SetLength (RS,idx+1);
              RS [idx].Region:= sh.Shooter.RegionAbbr1;
              RS [idx].Count:= 1;
            end
          else
            inc (RS [idx].Count);
        end;
    end;
end;

function TStartListEventShooters.get_ShooterIdx(index: integer): TStartListEventShooterItem;
begin
  if index< Count then
    Result:= inherited Items [index] as TStartListEventShooterItem
  else
    Result:= nil;
end;

function TStartListEventShooters.get_StartList: TStartList;
begin
  Result:= fStartEvent.StartList;
end;

function TStartListEventShooters.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

function TStartListEventShooters.NumberOf(AQualification: TQualificationItem): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    if Items [i].Shooter.Qualification= AQualification then
      inc (Result);
end;

{procedure TStartListEventShooters.ImportFromStream(Stream: TStream);
var
  c,j: integer;
  s: TStartListEventShooterItem;
begin
  Stream.Read (fSortOrder,sizeof (fSortOrder));
  Stream.Read (c,sizeof (c));
  Clear;
  for j:= 0 to c-1 do
    begin
      s:= Add;
      s.ImportFromStream (Stream);
    end;
  fChanged:= true;
end;}

function TStartListEventShooters.PointsTeamShooters(ATeam: string): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    if AnsiSameText (Items [i].TeamForPoints,ATeam) then
      inc (Result);
end;

procedure TStartListEventShooters.ReadFromStream(Stream: TStream);
var
  c,j: integer;
  s: TStartListEventShooterItem;
begin
  Clear;
  Stream.Read (fSortOrder,sizeof (fSortOrder));
  Stream.Read (c,sizeof (c));
  for j:= 0 to c-1 do
    begin
      s:= Add;
      s.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TStartListEventShooters.ResetRelays;
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    begin
      Items [i].Relay:= nil;
      Items [i].Position:= 0;
    end;
end;

procedure TStartListEventShooters.set_SortOrder(const Value: TSortOrder);
begin
  if Value<> fSortOrder then
    begin
//      fChanged:= true;
      fSortOrder:= Value;
    end;
  Sort;
end;

procedure TStartListEventShooters.Sort;
var
  i,j: integer;
  sh: TStartListEventShooterItem;
begin
  if fSortOrder= soNone then
    exit;
  for i:= 0 to Count-2 do
    begin
      sh:= Items [i];
      for j:= i+1 to Count-1 do
        if Items [j].CompareTo (sh,fSortOrder)> 0 then
          sh:= Items [j];
      if sh.Index<> i then
        sh.Index:= i;
    end;
end;

{function TStartListEventShooters.TeamShooters(
  ATeam: TStartListTeamItem): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    if Items [i].Team= ATeam then
      inc (Result);
end;}

function TStartListEventShooters.TeamShooters(ATeam: string): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    if AnsiSameText (Items [i].TeamForResults,ATeam) then
      inc (Result);
end;

procedure TStartListEventShooters.WriteToStream(Stream: TStream);
var
  c,j: integer;
begin
  Stream.Write (fSortOrder,sizeof (fSortOrder));
  c:= Count;
  Stream.Write (c,sizeof (c));
  for j:= 0 to c-1 do
    Items [j].WriteToStream (Stream);
  fChanged:= false;
end;

{ TStartListEventShooterItem }

function TStartListEventShooterItem.AllPointsStr: string;
var
  p1,p2: integer;
begin
  p1:= TeamPoints;
  p2:= QualificationPoints;
  if (p1> 0) and (p2> 0) then
    Result:= IntToStr (p1)+'+'+IntToStr (p2)
  else if (p2> 0) then
    Result:= '0+'+IntToStr (p2)
  else if (p1> 0) then
    Result:= IntToStr (p1)
  else
    Result:= '';
end;

function TStartListEventShooterItem.AverageSerie: double;
var
  n,i: integer;
begin
  Result:= 0;
  n:= 0;
  for i:= 0 to Length (fSeries10)-1 do
    if fSeries10 [i]> 0 then
      begin
        Result:= Result+fSeries10 [i];
        n:= i+1;
      end;
  if n> 0 then
    Result:= Result / n;
end;

function TStartListEventShooterItem.ComparePositionTo(AShooter: TStartListEventShooterItem): shortint;
begin
  if (AShooter.Relay<> nil) and (fRelay= nil) then
    Result:= 1
  else if (AShooter.Relay= nil) and (fRelay<> nil) then
    Result:= -1
  else if (AShooter.Relay= nil) and (fRelay= nil) then
    Result:= CompareSurnameTo (AShooter)
  else if (AShooter.Relay.Index< fRelay.Index) then
    Result:= 1
  else if (AShooter.Relay.Index> fRelay.Index) then
    Result:= -1
  else
    begin
      if (AShooter.Position> 0) and (Position= 0) then
        Result:= 1
      else if (AShooter.Position= 0) and (Position> 0) then
        Result:= -1
      else if (AShooter.Position= 0) and (Position= 0) then
        Result:= CompareSurnameTo (AShooter)
      else if (AShooter.Position> Position) then
        Result:= -1
      else if (AShooter.Position< Position) then
        Result:= 1
      else
        Result:= CompareSurnameTo (AShooter);
    end;
end;

function TStartListEventShooterItem.CompareSurnameTo(AShooter: TStartListEventShooterItem): shortint;
begin
  Result:= CompareText (fShooter.fShooter.Surname,AShooter.fShooter.Shooter.Surname);
end;

function TStartListEventShooterItem.CompareTo(AShooter: TStartListEventShooterItem; AOrder: TSortOrder): shortint;
var
  i: integer;
  fr1,fr2: DWORD;
begin
  Result:= 0;
  case AOrder of
    soNone: Result:= 0;
    soAverage: Result:= Sign (AverageSerie-AShooter.AverageSerie);
    soSeries: begin
      if (DNS= dnsCompletely) and (AShooter.DNS<> dnsCompletely) then
        Result:= -1
      else if (DNS<> dnsCompletely) and (AShooter.DNS= dnsCompletely) then
        Result:= 1;
      if Result= 0 then
        begin
          if (not fOutOfRank) and (AShooter.OutOfRank) then
            Result:= 1
          else if (fOutOfRank) and (not AShooter.OutOfRank) then
            Result:= -1;
        end;
      if Result= 0 then
        begin
          if (DNS= dnsNone) and (AShooter.DNS<> dnsNone) then
            Result:= 1
          else if (DNS<> dnsNone) and (AShooter.DNS= dnsNone) then
            Result:= -1;
        end;
      if Result= 0 then
        begin
          if (IsFinished) and (not AShooter.IsFinished) then
            Result:= 1
          else if (not IsFinished) and (AShooter.IsFinished) then
            Result:= -1;
        end;
      if Result= 0 then
        begin
          if (DNS= dnsNone) and (AShooter.DNS<> dnsNone) then
            Result:= 1
          else if (DNS<> dnsNone) and (AShooter.DNS= dnsNone) then
            Result:= -1;
        end;
      if Result= 0 then
        Result:= Sign (SeriesCount-AShooter.SeriesCount);
      if Result= 0 then
        Result:= CompareDwords (Competition10,AShooter.Competition10);
      if Result= 0 then
        Result:= Sign (CompShootOffVal-AShooter.CompShootOffVal);
      if Result= 0 then
        Result:= Sign (fCompPriority-AShooter.CompPriority);
      if Result= 0 then
        Result:= Sign (InnerTens-AShooter.InnerTens);
      if (Event.CompareBySeries) and (Global_CompareBySeries) then
        begin
          if Result= 0 then
            begin
              for i:= Length (fSeries10)-1 downto 0 do
                begin
                  Result:= CompareDwords (fSeries10 [i],AShooter.fSeries10 [i]);
                  if Result<> 0 then
                    break;
                end;
            end;
        end;
      if (Result= 0) and (Competition10= 0) then
        Result:= CompareTo (AShooter,soSurname);
    end;
    soFinal: begin
      fr1:= FinalResult10;
      fr2:= AShooter.FinalResult10;
      if (fr1= 0) and (fr2= 0) then
        Result:= CompareTo (AShooter,soSeries)
      else
        begin
          case Event.EventType of
            etRapidFire: begin
              // 8.4.2011
              // ��� ��-8 ������ ������ �������, �� ������� ���������
              // ����������� ��� ����� �������� �����
              // ���������� � ������ �� ������� !!
              Result:= CompareDwords (fr1,fr2);
              if Result= 0 then
                Result:= CompareDwords (fFinalShootOff10,AShooter.FinalShootOff10);
              if Result= 0 then
                Result:= Sign (fFinalPriority-AShooter.fFinalPriority);
            end;
          else
            // ��� ��������� ���������� ���� �� � �����
            // 25.11.2012 - �������� �������
            if (Event.CompareByFinal) and (StartEvent.DateFrom>= EncodeDate(2012,11,25)) then
              begin
                //Result:= 0;
                Result:= Sign (fFinalManual-AShooter.FinalManual);
                if (FinalResult10> 0) and (AShooter.FinalResult10= 0) then
                  Result:= 1
                else if (FinalResult10= 0) and (AShooter.FinalResult10> 0) then
                  Result:= -1;
                if Result= 0 then
                  Result:= CompareDwords (FinalResult10,AShooter.FinalResult10);
                if Result= 0 then
                  Result:= CompareDwords (FinalShootOff10,AShooter.FinalShootOff10);
                if Result= 0 then
                  Result:= Sign (FinalPriority-AShooter.FinalPriority);
              end
            else
              begin
                Result:= CompareDwords (Competition10+FinalResult10,AShooter.Competition10+AShooter.FinalResult10);
                if Result= 0 then
                  Result:= CompareDwords (fFinalShootOff10,AShooter.FinalShootOff10);
                if Result= 0 then
                  Result:= Sign (fFinalPriority-AShooter.fFinalPriority);
              end;
          end;
        end;
    end;
    soPosition: Result:= -ComparePositionTo (AShooter);
    soSurname: Result:= -CompareSurnameTo (AShooter);
    soStartNumber: Result:= -Sign (StartNumber-AShooter.StartNumber);
    soQualification: Result:= Shooter.CompareTo (AShooter.Shooter,ssoQualification);
    soRegion: begin
      Result:= Shooter.CompareTo (AShooter.Shooter,ssoRegion);
      if Result= 0 then
        Result:= -CompareSurnameTo (AShooter);
    end;
    soTeam: begin
      if (TeamForPoints= '') and (AShooter.TeamForPoints<> '') then
        Result:= -1
      else if (TeamForPoints<> '') and (AShooter.TeamForPoints= '') then
        Result:= 1
      else if (TeamForPoints<> '') and (AShooter.TeamForPoints<> '') then
        Result:= AnsiCompareText (AShooter.TeamForPoints,TeamForPoints)
      else
        Result:= 0;
    end;
    soPoints: begin
      if (TeamForPoints<> '') and (AShooter.TeamForPoints= '') then
        Result:= 1
      else if (TeamForPoints= '') and (AShooter.TeamForPoints<> '') then
        Result:= -1
      else
        Result:= 0;
    end;
  end;
end;

function TStartListEventShooterItem.Competition10: DWORD;
var
  i: integer;
begin
  case fDidNotStart of
    dnsCompletely: Result:= 0;
  else
    Result:= 0;
    for i:= 0 to Length (fSeries10)-1 do
      inc (Result,fSeries10 [i]);
  end;
end;

function TStartListEventShooterItem.CompetitionStr: string;
var
  c: DWORD;
begin
  case fDidNotStart of
    dnsCompletely: Result:= '';
  else
    c:= Competition10;
    Result:= StartEvent.CompetitionStr (c);
    {if StartEvent.CompFracs then
      Result:= IntToStr (c div 10)+'.'+IntToStr (c mod 10)
    else
      Result:= IntToStr (Competition10 div 10);}
    if InnerTens> 0 then
      Result:= Result+'-'+IntToStr (InnerTens)+'x';
  end;
end;

constructor TStartListEventShooterItem.Create(ACollection: TCollection);
begin
  inherited;
  SetLength (fSeries10,0);
  SetLength (fFinalShots10,0);
//  fFinalResult._int:= 0;
//  fFinalResult._frac:= 0;
  fFinalResult10:= 0;
  fRank:= -1;
  fDistrictPoints:= false;
  fOutOfRank:= false;
  fCompShootoffStr:= '';
  fCompPriority:= 0;
//  fFinalShootOff._int:= 0;
//  fFinalShootOff._frac:= 0;
  fFinalShootOff10:= 0;
  fFinalShootOffStr:= '';
  fFinalPriority:= 0;
  fDidNotStart:= dnsNone;
  fDNSComment:= '';
  fTeamForPoints:= '';
  fTeamForResults:= '';
  fSaved:= false;
  fChanged:= false;
  fInnerTens:= 0;
  Shooters.fChanged:= true;
  fResultItem:= nil;
  fFinalManual:= 0;
end;

function TStartListEventShooterItem.CSVStr: String;
var
  stage,serie: integer;
begin
//  ������(��� �����), ����� ���������, �������, ���, ��� ��������,
// ������, � ��������� ����� ����� � ���������
  Result:= fShooter.Shooter.RegionAbbr1;
  if StartList.StartNumbers then
    Result:= Result+','+fShooter.StartNumberStr;
  Result:= Result+','+fShooter.Shooter.Surname+','+fShooter.Shooter.Name;
  Result:= Result+','+fShooter.Shooter.BirthYearStr+','+fShooter.Shooter.QualificationName;
  if Event.Stages> 1 then
    begin
      for stage:= 1 to Event.Stages do
        begin
          for serie:= 1 to Event.SeriesPerStage do
            begin
              Result:= Result+',';
              if (stage<= StagesCount) and (serie<= SeriesCount) then
                Result:= Result+StrToCSV(SerieStr(stage,serie));
            end;
          Result:= Result+',';
          if stage<= StagesCount then
            Result:= Result+StrToCSV(StageResultStr(stage));
        end;
    end
  else
    begin
      for serie:= 1 to Event.SeriesPerStage do
        begin
          Result:= Result+',';
          if serie<= SeriesCount then
            Result:= Result+StrToCSV(SerieStr(1,serie));
        end;
    end;
  Result:= Result+','+CompetitionStr;
end;

destructor TStartListEventShooterItem.Destroy;
begin
  if fResultItem<> nil then
    begin
      fResultItem.fStartEventShooterLink:= nil;
      fResultItem.Changed;
      fResultItem:= nil;
    end;
  SetLength (fFinalShots10,0);
  fFinalShots10:= nil;
  SetLength (fSeries10,0);
  fSeries10:= nil;
  Shooters.fChanged:= true;
  inherited;
end;

{function TStartListEventShooterItem.FinalResult10: DWORD;
var
  fr: TFinalResult;
begin
  fr:= FinalResult;
  Result:= fr._int*10+fr._frac;
end;}

{function TStartListEventShooterItem.FinalShootOff10: integer;
begin
  Result:= fFinalShootOff._int*10+fFinalShootOff._frac;
end;}

function TStartListEventShooterItem.FinalShotsCount: integer;
begin
  Result:= Length (fFinalShots10);
end;

function TStartListEventShooterItem.FinalShotsStr: string;
var
  i: integer;
begin
  Result:= '';
  for i:= 0 to FinalShotsCount-1 do
    begin
      if i> 0 then
        Result:= Result+' ';
      Result:= Result+Event.FinalStr (fFinalShots10 [i]);
    end;
end;

function TStartListEventShooterItem.get_CompShootOff: double;
var
  r: extended;
begin
  if Evaluate (fCompShootoffStr,r) then
    Result:= r
  else
    Result:= 0;
end;

function TStartListEventShooterItem.get_DNS: TDidNotStart;
begin
  Result:= fDidNotStart;
end;

function TStartListEventShooterItem.get_DNSComment: string;
begin
  Result:= fDNSComment;
end;

function TStartListEventShooterItem.get_Event: TEventItem;
begin
  Result:= (Collection as TStartListEventShooters).StartEvent.Event;
end;

function TStartListEventShooterItem.get_EventShooters: TStartListEventShooters;
begin
  Result:= Collection as TStartListEventShooters;
end;

{function TStartListEventShooterItem.get_Final: single;
var
  i: integer;
begin
  if fFinalResult<> 0 then
    Result:= fFinalResult
  else
    begin
      Result:= 0;
      for i:= 0 to Length (fFinal)-1 do
        Result:= Result+fFinal [i];
    end;
end;}

function TStartListEventShooterItem.get_FinalResult: DWORD;
var
  i: integer;
begin
  if fFinalResult10> 0 then
    Result:= fFinalResult10
  else
    begin
      Result:= 0;
      for i:= 0 to FinalShotsCount-1 do
        Result:= Result+fFinalShots10 [i];
    end;
end;

function TStartListEventShooterItem.get_FinalShootOffStr: string;
begin
  if fFinalShootOff10> 0 then
    Result:= Event.FinalStr (fFinalShootOff10)
  else
    Result:= fFinalShootOffStr;
end;

function TStartListEventShooterItem.get_FinalShots(index: integer): word;
begin
  if index< Length (fFinalShots10) then
    Result:= fFinalShots10 [index]
  else
    Result:= 0;
end;

function TStartListEventShooterItem.get_Position: integer;
begin
  Result:= fPosition [0];
end;

function TStartListEventShooterItem.get_Position2: integer;
begin
  Result:= fPosition [1];
end;

function TStartListEventShooterItem.get_Serie(AStage, ASerie: integer): DWORD;
var
  idx: integer;
begin
  Result:= 0;
  if (AStage> Event.Stages) or (AStage< 1) then
    exit;
  if (ASerie> Event.SeriesPerStage) or (ASerie< 1) then
    exit;
  idx:= (AStage-1) * Event.SeriesPerStage + ASerie-1;
  if idx< Length (fSeries10) then
    Result:= fSeries10 [idx];
end;

function TStartListEventShooterItem.get_Shooter: TShooterItem;
begin
  Result:= fShooter.fShooter;
end;

function TStartListEventShooterItem.get_StartEvent: TStartListEventItem;
begin
  Result:= EventShooters.StartEvent;
end;

function TStartListEventShooterItem.get_StartNumber: integer;
begin
  Result:= fShooter.StartNumber;
end;

{function TStartListEventShooterItem.get_Team: TStartListTeamItem;
begin
  Result:= fShooter.Team;
end; }

function TStartListEventShooterItem.HavePosition: boolean;
begin
  Result:= (fRelay<> nil) and (Position<> 0);
end;

{procedure TStartListEventShooterItem.ImportFromStream(Stream: TStream);
var
  c,idx,i: integer;
  s:  single;
  b: boolean;
  wso: word;
begin
  Stream.Read (idx,sizeof (idx));
  if idx>= 0 then
    fShooter:= StartList.Shooters [idx]
  else
    begin
      // �� ������ ������� � ��������� ���������
      fShooter:= nil;       // ��� ������-�� ������
      raise Exception.Create ('����� ����� � ��������!');
    end;
  Stream.Read (idx,sizeof (idx));
  if idx>= 0 then
    fRelay:= StartEvent.Relays [idx]
  else
    fRelay:= nil;
  Stream.Read (fPosition, sizeof (fPosition));
  Stream.Read (c,sizeof (c));
  SetLength (fSeries,c);
  Stream.Read (fSeries [0],c*sizeof (integer));
  while (Length (fSeries)> 0) and (fSeries [Length (fSeries)-1]= 0) do
    SetLength (fSeries,Length (fSeries)-1);
  if StartList.fStreamVersion>= 2 then
    begin
      Stream.Read (c,sizeof (c));
      SetLength (fFinalShots,c);
      Stream.Read (fFinalShots [0],c*sizeof (TFinalResult));
      Stream.Read (fFinalResult,sizeof (fFinalResult));
    end
  else
    begin
      Stream.Read (c,sizeof (c));
      SetLength (fFinalShots,c);
      for i:= 0 to c-1 do
        begin
          Stream.Read (s,sizeof (s));
          fFinalShots [i]._int:= Round (s*10) div 10;
          fFinalShots [i]._frac:= Round (s*10) mod 10;
        end;
      Stream.Read (s,sizeof (s));
      if not IsNan(s) then
        begin
          fFinalResult._int:= Round (s*10) div 10;
          fFinalResult._frac:= Round (s*10) mod 10;
        end
      else
        begin
          fFinalResult._int:= 0;
          fFinalResult._frac:= 0;
        end;
    end;
  Stream.Read (fRank,sizeof (fRank));
//  if StartList.Data.fFileVersion<= 10 then
    begin
      Stream.Read (b,sizeof (b));
      if b then
        fTeamForPoints:= fShooter.fOldTeam
      else
        fTeamForPoints:= '';
    end;
//  else
//    ReadStrFromStream (Stream,fTeamForPoints);
  if StartList.fStreamVersion>= 4 then
    begin
      Stream.Read (fRegionPoints,sizeof (fRegionPoints));
      Stream.Read (fDistrictPoints,sizeof (fDistrictPoints));
    end;
//  if StartList.Data.fFileVersion<= 10 then
    begin
      Stream.Read (b,sizeof (b));
      if b then
        fTeamForResults:= fShooter.fOldTeam
      else
        fTeamForResults:= '';
    end;
//  else
//    ReadStrFromStream (Stream,fTeamForResults);
  Stream.Read (fOutOfRank,sizeof (fOutOfRank));
  if StartList.fStreamVersion<= 17 then
    begin
      wso:= 0;
      if StartList.fStreamVersion>= 3 then
        begin
          Stream.Read (wso,sizeof (wso));
        end
      else
        begin
          Stream.Read (s,sizeof (s));
          wso:= Round (s);
        end;
      ReadStrFromStream (Stream,fCompShootoffStr);
      if wso> 0 then
        fCompShootoffStr:= IntToStr (wso);
    end
  else
    ReadStrFromStream (Stream,fCompShootoffStr);
  Stream.Read (fCompPriority,sizeof (fCompPriority));
  if fCompPriority> 32 then      // �������� �����, ����� �� ���� ����� ������� ��������
    fCompPriority:= 32;
  if StartList.fStreamVersion>= 2 then
    begin
      Stream.Read (fFinalShootOff,sizeof (fFinalShootOff));
    end
  else
    begin
      Stream.Read (s,sizeof (s));
      fFinalShootOff._int:= Round (s*10) div 10;
      fFinalShootOff._frac:= Round (s*10) mod 10;
    end;
  ReadStrFromStream (Stream,fFinalShootOffStr);
  Stream.Read (fFinalPriority,sizeof (fFinalPriority));
  Stream.Read (fSaved,sizeof (fSaved));
  Stream.Read (fDidNotStart,sizeof (fDidNotStart));
  ReadStrFromStream (Stream,fDNSComment);
  if StartList.fStreamVersion>= 6 then
    Stream.Read (fManualPoints,sizeof (fManualPoints));
  if StartList.fStreamVersion>= 7 then
    ReadStrFromStream (Stream,fRecordComment);
  fChanged:= true;
end;}

function TStartListEventShooterItem.TeamPoints: integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
  r: integer;
begin
  Result:= 0;
  if (TeamForPoints= '') or (OutOfRank) then
    exit;
  if DNS<> dnsNone then
    exit;
  if SeriesCount< Event.Stages*Event.SeriesPerStage then
    exit;
  r:= 0;
  for i:= 0 to Index do
    begin
      sh:= StartEvent.Shooters.Items [i];
      if (not sh.OutOfRank) and (sh.TeamForPoints<> '') then
        r:= r+1;
    end;
  if (r= 0) or (r> StartEvent.PTeamsPoints.Count) then
    exit;
  Result:= StartEvent.PTeamsPoints [r-1];
end;

{
procedure TStartListEventShooterItem.PrintFinalNumber;
begin
  if Printer= nil then
    exit;
  StartList.FinalNumbersPrintout.StartJob;
  StartList.FinalNumbersPrintout.AddShooter (self);
  StartList.FinalNumbersPrintout.FinishJob;
end;
}

function TStartListEventShooterItem.QualificationPoints: integer;
var
  q: TQualificationItem;
  //bytotal: boolean;
begin
  Result:= 0;
  if (OutOfRank) then
    exit;
  if (TeamForPoints= '') and (not GiveRegionPoints) and (not GiveDistrictPoints) then
    exit;
  if SeriesCount< Event.Stages*Event.SeriesPerStage then
    exit;
  //q:= Event.Qualified10 (Competition10,Total10,bytotal);
  q:= Event.Qualified10 (Competition10,StartEvent.CompetitionWithTens);
  if q<> nil then
    Result:= StartList.QualificationPoints [q.Index];
end;

(*function TStartListEventShooterItem.Qualified (var ByTotal: boolean): TQualificationItem;
begin
  ByTotal:= false;
  if OutOfRank then
    Result:= nil
  else
    begin
      Result:= Event.Qualified10 (Competition10, StartEvent.CompetitionWithTens);
      {if StartEvent.CompetitionWithTens then
        Result:= nil
      else
        Result:= Event.Qualified10 (Competition10,Total10,ByTotal);}
    end;
end;*)

function TStartListEventShooterItem.Qualified: TQualificationItem;
begin
  if OutOfRank then
    Result:= nil
  else
    Result:= Event.Qualified10 (Competition10, StartEvent.CompetitionWithTens);
end;

procedure TStartListEventShooterItem.SaveResult (AShootingEvent: TShootingEventItem);
var
  sr: TResultItem;
  sh: TShooterItem;
  dt: TDateTime;
//  sch: TShootingChampionshipItem;
//  sev: TShootingEventItem;
begin
  sh:= fShooter.Shooter;
  if StartEvent.HasFinal then
    dt:= StartEvent.FinalTime
  else
    dt:= StartEvent.Relays [StartEvent.Relays.Count-1].StartTime;
  sr:= fResultItem;
  if sr= nil then
    sr:= sh.Results.FindSameDateAndEvent (dt,StartEvent.Event);
  if sr= nil then
    sr:= sh.Results.Add;
  sr.ShootingEvent:= AShootingEvent; // StartEvent.ShootingEvent;
  fResultItem:= sr;
(*
{  sr.Date:= dt;
  sr.Event:= StartEvent.Event;
  sr.Championship:= StartEvent.Info.Championship;
  if sr.Championship= nil then
    sr.ChampionshipName:= StartEvent.Info.ChampionshipName;
  sr.Country:= '';
  sr.Town:= StartEvent.Info.Town;}
  sch:= StartList.Data.ShootingChampionships.Find (StartEvent.Info.Championship,StartEvent.Info.ChampionshipName,dt);
  if sch= nil then
    begin
      sch:= StartList.Data.ShootingChampionships.Add;
      sch.Championship:= StartEvent.Info.Championship;
      if sch.Championship= nil then
        sch.ChampionshipName:= StartEvent.Info.ChampionshipName;
//      sch.Country:= StartEvent.Info.Country;
      sch.Town:= StartEvent.Info.Town;
    end;
  sev:= sch.Events.Find (StartEvent.Event,'',dt);
  if sev= nil then
    begin
      sev:= sch.Events.Add;
      sev.SetEvent (StartEvent.Event,'','');
      sev.Date:= dt;
    end;
  sr.ShootingEvent:= sev;*)
  sr.Junior:= false;
  sr.Rank:= Index+1;
  sr.Competition10:= Competition10;
  sr.CompetitionWithTens:= StartEvent.CompetitionWithTens;
  sr.Final10:= FinalResult10;
  sr.fStartEventShooterLink:= self;
  fSaved:= true;
  fChanged:= true;
end;

{procedure TStartListEventShooterItem.SaveToStream(Stream: TStream);
var
  c,idx,i: integer;
  s: single;
begin
  idx:= fShooter.Index;
  Stream.Write (idx,sizeof (idx));
  if fRelay<> nil then
    idx:= fRelay.Index
  else
    idx:= -1;
  Stream.Write (idx,sizeof (idx));
  Stream.Write (fPosition, sizeof (fPosition));
  c:= Length (fSeries);
  Stream.Write (c,sizeof (c));
  Stream.Write (fSeries [0],c*sizeof (integer));
  if StartList.fStreamVersion>= 2 then
    begin
      c:= Length (fFinalShots);
      Stream.Write (c,sizeof (c));
      Stream.Write (fFinalShots [0],c*sizeof (TFinalResult));
      Stream.Write (fFinalResult,sizeof (fFinalResult));
    end
  else
    begin
      c:= Length (fFinalShots);
      Stream.Write (c,sizeof (c));
      for i:= 0 to c-1 do
        begin
          s:= fFinalShots [i]._int+fFinalShots [i]._frac/10;
          Stream.Write (s,sizeof (s));
        end;
      s:= fFinalResult._int+fFinalResult._frac/10;
      Stream.Write (s,sizeof (s));
    end;
  Stream.Write (fRank,sizeof (fRank));
  Stream.Write (fTeamPoints,sizeof (fTeamPoints));
  if StartList.fStreamVersion>= 4 then
    begin
      Stream.Write (fRegionPoints,sizeof (fRegionPoints));
      Stream.Write (fDistrictPoints,sizeof (fDistrictPoints));
    end;
  Stream.Write (fForTeam,sizeof (fForTeam));
  Stream.Write (fOutOfRank,sizeof (fOutOfRank));
  if StartList.fStreamVersion>= 3 then
    begin
      Stream.Write (fCompShootOff,sizeof (fCompShootOff));
    end
  else
    begin
      s:= fCompShootOff;
      Stream.Write (s,sizeof (s));
    end;
  SaveStrToStream (Stream,fCompShootoffStr);
  Stream.Write (fCompPriority,sizeof (fCompPriority));
  if StartList.fStreamVersion>= 2 then
    begin
      Stream.Write (fFinalShootOff,sizeof (fFinalShootOff));
    end
  else
    begin
      s:= fFinalShootOff._int+fFinalShootOff._frac/10;
      Stream.Write (s,sizeof (s));
    end;
  SaveStrToStream (Stream,fFinalShootOffStr);
  Stream.Write (fFinalPriority,sizeof (fFinalPriority));
  Stream.Write (fSaved,sizeof (fSaved));
  Stream.Write (fDidNotStart,sizeof (fDidNotStart));
  SaveStrToStream (Stream,fDNSComment);
  Stream.Write (fManualPoints,sizeof (fManualPoints));
  SaveStrToStream (Stream,fRecordComment);
end;}

function TStartListEventShooterItem.SeriesCount: integer;
begin
  Result:= Length (fSeries10);
end;

function TStartListEventShooterItem.SeriesInStage(index: integer): integer;
begin
  if SeriesCount> index * Event.SeriesPerStage then
    Result:= 0
  else if SeriesCount> (index-1) * Event.SeriesPerStage then
    Result:= SeriesCount mod Event.SeriesPerStage
  else
    Result:= Event.SeriesPerStage;
end;

function TStartListEventShooterItem.SerieStr(AStage,ASerie: integer): string;
var
  s: DWORD;
begin
  s:= Series10 [AStage,ASerie];
  Result:= StartEvent.CompetitionStr (s);
  {if Event.CompFracs then
    Result:= format ('%d.%d',[s div 10,s mod 10])
  else
    Result:= IntToStr (s div 10);}
end;

procedure TStartListEventShooterItem.SetFinalShotsCount(ACount: integer);
var
  idx,i: integer;
begin
  if ACount> Length (fFinalShots10) then
    begin
      idx:= Length (fFinalShots10);
      SetLength (fFinalShots10,ACount);
      for i:= idx to ACount-1 do
        fFinalShots10 [i]:= 0;
      fChanged:= true;
    end
  else if ACount< Length (fFinalShots10) then
    begin
      SetLength (fFinalShots10,ACount);
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_CompShootoffStr(
  const Value: string);
begin
  if Value<> fCompShootoffStr then
    begin
      fCompShootoffStr:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_DNS(const Value: TDidNotStart);
begin
  if Value<> fDidNotStart then
    begin
      fChanged:= true;
      fDidNotStart:= Value;
    end;
end;

procedure TStartListEventShooterItem.set_DNSComment(const Value: string);
begin
  if Value<> fDNSComment then
    begin
      fDNSComment:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_FinalResult(const Value: DWORD);
begin
  if (Length (fFinalShots10)<> 0) or (Value<> fFinalResult10) then
    begin
      SetLength (fFinalShots10,0);
      fFinalResult10:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_FinalShootOffStr(const Value: string);
var
//  fr: TFinalResult;
  i,f: integer;
  i1,i2: integer;
  s: string;
begin
  s:= Trim (Value);
  val (s,i,i1);
  if i1= 0 then
    begin
      FinalShootOff10:= i * 10;
    end
  else
    begin
      val (substr (s,'.',1),i,i1);
      val (substr (s,'.',2),f,i2);
      if i1+i2> 0 then
        begin
          if (fFinalShootOff10<> 0) or (s<> fFinalShootOffStr) then
            begin
              fFinalShootOff10:= 0;
              fFinalShootOffStr:= s;
              fChanged:= true;
            end;
        end
      else
        begin
          FinalShootOff10:= i * 10 + f;
        end;
    end;
end;

procedure TStartListEventShooterItem.set_FinalShots(index: integer; const Value: word);
var
  l,i: integer;
begin
  if (index>= Event.FinalShots) or (index< 0) then
    exit;
  if index>= Length (fFinalShots10) then
    begin
      l:= Length (fFinalShots10);
      SetLength (fFinalShots10,index+1);
      for i:= l to index-1 do
        fFinalShots10 [i]:= 0;
      fChanged:= true;
    end;
  if fFinalShots10 [index]<> Value then
    begin
      fFinalShots10 [index]:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_InnerTens(const Value: integer);
begin
  if Value<> fInnerTens then
    begin
      fInnerTens:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_Position(const Value: integer);
begin
  case Event.EventType of
    etRegular,etThreePosition2013: begin
      if (Value<> fPosition [0]) or (Value<> fPosition [1]) then
        begin
          fPosition [0]:= Value;
          fPosition [1]:= Value;
          fChanged:= true;
        end;
    end;
    etRapidFire,etCenterFire,etMovingTarget,etCenterFire2013,etMovingTarget2013: begin
      if Value<> fPosition [0] then
        begin
          fPosition [0]:= Value;
          fChanged:= true;
        end;
    end;
  end;
end;

procedure TStartListEventShooterItem.set_Position2(const Value: integer);
begin
  case Event.EventType of
    etRegular,etThreePosition2013: begin
      if (Value<> fPosition [0]) or (Value<> fPosition [1]) then
        begin
          fPosition [0]:= Value;
          fPosition [1]:= Value;
          fChanged:= true;
        end;
    end;
    etRapidFire,etCenterFire,etMovingTarget,etCenterFire2013,etMovingTarget2013: begin
      if Value<> fPosition [1] then
        begin
          fPosition [1]:= Value;
          fChanged:= true;
        end;
    end;
  end;
end;

procedure TStartListEventShooterItem.set_Relay(const Value: TStartListEventRelayItem);
begin
  if Value<> fRelay then
    begin
      fRelay:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_Serie(AStage, ASerie: integer; const Value: DWORD);
var
  idx: integer;
begin
  if (AStage> Event.Stages) or (AStage< 1) then
    exit;
  if (ASerie> Event.SeriesPerStage) or (ASerie< 1) then
    exit;
  idx:= (AStage-1) * Event.SeriesPerStage + ASerie-1;
  AllSeries10 [idx]:= Value;
end;

procedure TStartListEventShooterItem.set_StartListShooter(const Value: TStartListShooterItem);
begin
  if Value<> fShooter then
    begin
      fShooter:= Value;
      fChanged:= true;
    end;
end;

function TStartListEventShooterItem.StageResults10(AStage: integer): DWORD;
var
  i: integer;
begin
  Result:= 0;
  if AStage<= Event.Stages then
    begin
      i:= (AStage-1) * Event.SeriesPerStage;
      while (i< Length (fSeries10)) and (i< AStage * Event.SeriesPerStage) do
        begin
          inc (Result,fSeries10 [i]);
          inc (i);
        end;
    end;
end;

function TStartListEventShooterItem.StageResultStr(AStage: integer): string;
var
  s: DWORD;
begin
  s:= StageResults10 (AStage);
  Result:= StartEvent.CompetitionStr (s);
  {if Event.CompFracs then
    Result:= format ('%d.%d',[s div 10,s mod 10])
  else
    Result:= format ('%d',[s div 10]);}
end;

function TStartListEventShooterItem.StagesCount: integer;
var
  c: integer;
begin
  c:= SeriesCount;
  Result:= c div Event.SeriesPerStage+1;
  if c mod Event.SeriesPerStage= 0 then
    dec (Result);
end;

function TStartListEventShooterItem.StartList: TStartList;
begin
  Result:= (Collection as TStartListEventShooters).StartList;
end;

function TStartListEventShooterItem.StartNumberStr: string;
begin
  Result:= fShooter.StartNumberStr;
end;

function TStartListEventShooterItem.RegionPoints: integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
  r: integer;
begin
  Result:= 0;
  if (not GiveRegionPoints) or (OutOfRank) then
    exit;
  if DNS<> dnsNone then
    exit;
  if SeriesCount< Event.Stages*Event.SeriesPerStage then
    exit;
  r:= 0;
  for i:= 0 to Index do
    begin
      sh:= StartEvent.Shooters.Items [i];
      if (not sh.OutOfRank) and (sh.GiveRegionPoints) then
        r:= r+1;
    end;
  if (r= 0) or (r> StartEvent.RegionsPoints.Count) then
    exit;
  Result:= StartEvent.RegionsPoints [r-1];
end;

procedure TStartListEventShooterItem.ResetFinal;
begin
  SetLength (fFinalShots10,0);
  fFinalResult10:= 0;
  fFinalShootOffStr:= '';
  fFinalShootOff10:= 0;
  fFinalPriority:= 0;
  fChanged:= true;
end;

procedure TStartListEventShooterItem.ResetResults;
begin
  ResetFinal;
  SetLength (fSeries10,0);
  fRank:= 0;
  fCompShootoffStr:= '';
  fCompPriority:= 0;
  fManualPoints:= 0;
  fInnerTens:= 0;
  fDidNotStart:= dnsNone;
  fDNSComment:= '';
  if fResultItem<> nil then
    begin
      fResultItem.fStartEventShooterLink:= nil;
      fResultItem:= nil;
    end;
  fChanged:= true;
end;

function TStartListEventShooterItem.DistrictPoints: integer;
var
  i: integer;
  sh: TStartListEventShooterItem;
  r: integer;
begin
  Result:= 0;
  if (not GiveDistrictPoints) or (OutOfRank) then
    exit;
  if DNS<> dnsNone then
    exit;
  if SeriesCount< Event.Stages*Event.SeriesPerStage then
    exit;
  r:= 0;
  for i:= 0 to Index do
    begin
      sh:= StartEvent.Shooters.Items [i];
      if (not sh.OutOfRank) and (sh.GiveDistrictPoints) then
        r:= r+1;
    end;
  if (r= 0) or (r> StartEvent.DistrictsPoints.Count) then
    exit;
  Result:= StartEvent.DistrictsPoints [r-1];
end;

function TStartListEventShooterItem.get_FinalResultStr: string;
begin
  Result:= Event.FinalStr (FinalResult10);
end;

function TStartListEventShooterItem.IsFinished: boolean;
begin
  case fDidNotStart of
    dnsCompletely,dnsPartially: Result:= true;
  else
    Result:= SeriesCount= Event.SeriesPerStage*Event.Stages;
  end;
end;

function TStartListEventShooterItem.Total10: DWORD;
begin
  Result:= Competition10 + FinalResult10;
end;

function TStartListEventShooterItem.TotalResultStr: string;
begin
  case fDidNotStart of
    dnsCompletely: Result:= '';
  else
    if OutOfRank then
      Result:= ''
    else
      begin
        if (not Event.CompareByFinal) or (StartEvent.DateFrom< EncodeDate (2012,11,25)) then
          begin
            Result:= Event.FinalStr (Total10);
          end
        else
          Result:= '';
      end;
  end;
end;

procedure TStartListEventShooterItem.ReadFromStream(Stream: TStream);
var
  c,idx: integer;
  b: boolean;
  wso: word;
  s: String;
  _fr: TFinalResultOld;
  _a: array of TFinalResultOld;
  i: integer;
  _a1: array of integer;
begin
  Stream.Read (idx,sizeof (idx));
  if idx>= 0 then
    fShooter:= StartList.Shooters [idx]
  else
    begin
      // �� ������ ������� � ��������� ���������
      fShooter:= nil;       // ��� ������-�� ������
      raise Exception.Create ('����� ����� � ��������!');
    end;
  Stream.Read (idx,sizeof (idx));
  if idx>= StartEvent.Relays.Count then
    begin
      fRelay:= nil;
    end
  else if idx>= 0 then
    fRelay:= StartEvent.Relays [idx]
  else
    fRelay:= nil;
  Stream.Read (fPosition, sizeof (fPosition));
  Stream.Read (c,sizeof (c));
  SetLength (fSeries10,c);
  if StartList.Data.fFileVersion<= 35 then
    begin
      SetLength (_a1,c);
      Stream.Read (_a1[0],c*sizeof (Integer));
      for i:= 0 to c-1 do
        fSeries10[i]:= _a1[i] * 10;
      SetLength (_a1,0);
    end
  else
    Stream.Read (fSeries10 [0],c*sizeof (DWORD));
  while (Length (fSeries10)> 0) and (fSeries10 [Length (fSeries10)-1]= 0) do
    SetLength (fSeries10,Length (fSeries10)-1);
  Stream.Read (c,sizeof (c));
  SetLength (fFinalShots10,c);
  if StartList.Data.fFileVersion<= 35 then
    begin
      SetLength (_a,c);
      Stream.Read (_a[0],c*sizeof (TFinalResultOld));
      for i:= 0 to c-1 do
        fFinalShots10[i]:= _a[i]._int*10+_a[i]._frac;
      Stream.Read (_fr,sizeof (_fr));
      fFinalResult10:= _fr._int*10+_fr._frac;
      SetLength (_a,0);
    end
  else
    begin
      Stream.Read (fFinalShots10 [0],c*sizeof (word));
      Stream.Read (fFinalResult10,sizeof (fFinalResult10));
    end;
  Stream.Read (fRank,sizeof (fRank));
  if StartList.Data.fFileVersion<= 10 then
    begin
      Stream.Read (b,sizeof (b));
      if b then
        fTeamForPoints:= fShooter.fOldTeam
      else
        fTeamForPoints:= '';
    end
  else
    ReadStrFromStreamA (Stream,fTeamForPoints);
  fTeamForPoints:= Trim (fTeamForPoints);
  Stream.Read (fRegionPoints,sizeof (fRegionPoints));
  Stream.Read (fDistrictPoints,sizeof (fDistrictPoints));
  if StartList.Data.fFileVersion<= 10 then
    begin
      Stream.Read (b,sizeof (b));
      if b then
        fTeamForResults:= fShooter.fOldTeam
      else
        fTeamForResults:= '';
    end
  else
    ReadStrFromStreamA (Stream,fTeamForResults);
  fTeamForResults:= Trim (fTeamForResults);
  Stream.Read (fOutOfRank,sizeof (fOutOfRank));
  if StartList.Data.fFileVersion<= 17 then
    begin
      Stream.Read (wso,sizeof (wso));
      ReadStrFromStreamA (Stream,fCompShootoffStr);
      if wso> 0 then
        fCompShootoffStr:= IntToStr (wso);
    end
  else
    ReadStrFromStreamA (Stream,fCompShootoffStr);
  Stream.Read (fCompPriority,sizeof (fCompPriority));
  if fCompPriority> 32 then      // �������� �����, ����� �� ���� ����� ������� ��������
    fCompPriority:= 32;
  if StartList.Data.fFileVersion<= 35 then
    begin
      Stream.Read (_fr,sizeof (_fr));
      fFinalShootOff10:= _fr._int*10+_fr._frac;
    end
  else
    Stream.Read (fFinalShootOff10,sizeof (fFinalShootOff10));
  ReadStrFromStreamA (Stream,fFinalShootOffStr);
  Stream.Read (fFinalPriority,sizeof (fFinalPriority));
  Stream.Read (fSaved,sizeof (fSaved));
  Stream.Read (fDidNotStart,sizeof (fDidNotStart));
  ReadStrFromStreamA (Stream,fDNSComment);
  Stream.Read (fManualPoints,sizeof (fManualPoints));
  ReadStrFromStreamA (Stream,fRecordComment);
  if StartList.Data.fFileVersion>= 29 then
    Stream.Read (fInnerTens,sizeof (fInnerTens))
  else
    fInnerTens:= 0;
  if StartList.Data.fFileVersion>= 32 then
    begin
      Stream.Read (idx,sizeof (idx));
      if idx>= 0 then
        begin
          if idx>= Shooter.Results.Count then
            begin
              s:= format ('WINBASE: Invalid result index: %s %d',[Shooter.SurnameAndName,idx]);
              OutputDebugStringA (PAnsiChar(AnsiString(s)));
              fResultItem:= nil;
            end
          else
            begin
              fResultItem:= Shooter.Results.Items [idx];
              fResultItem.fStartEventShooterLink:= self;
            end;
        end
      else
        fResultItem:= nil;
    end
  else
    fResultItem:= nil;
  if StartList.Data.fFileVersion>= 38 then
    Stream.Read (fFinalManual,sizeof (fFinalManual))
  else
    fFinalManual:= 0;
  fChanged:= false;
end;

procedure TStartListEventShooterItem.WriteToStream(Stream: TStream);
var
  c,idx: integer;
begin
  idx:= fShooter.Index;
  Stream.Write (idx,sizeof (idx));
  if fRelay<> nil then
    idx:= fRelay.Index
  else
    idx:= -1;
  Stream.Write (idx,sizeof (idx));
  Stream.Write (fPosition, sizeof (fPosition));
  c:= Length (fSeries10);
  Stream.Write (c,sizeof (c));
  Stream.Write (fSeries10 [0],c*sizeof (DWORD));
  c:= Length (fFinalShots10);
  Stream.Write (c,sizeof (c));
  Stream.Write (fFinalShots10 [0],c*sizeof (word));
  Stream.Write (fFinalResult10,sizeof (fFinalResult10));
  Stream.Write (fRank,sizeof (fRank));
  SaveStrToStreamA (Stream,fTeamForPoints);
  Stream.Write (fRegionPoints,sizeof (fRegionPoints));
  Stream.Write (fDistrictPoints,sizeof (fDistrictPoints));
  SaveStrToStreamA (Stream,fTeamForResults);
  Stream.Write (fOutOfRank,sizeof (fOutOfRank));
  SaveStrToStreamA (Stream,fCompShootoffStr);
  Stream.Write (fCompPriority,sizeof (fCompPriority));
  Stream.Write (fFinalShootOff10,sizeof (fFinalShootOff10));
  SaveStrToStreamA (Stream,fFinalShootOffStr);
  Stream.Write (fFinalPriority,sizeof (fFinalPriority));
  Stream.Write (fSaved,sizeof (fSaved));
  Stream.Write (fDidNotStart,sizeof (fDidNotStart));
  SaveStrToStreamA (Stream,fDNSComment);
  Stream.Write (fManualPoints,sizeof (fManualPoints));
  SaveStrToStreamA (Stream,fRecordComment);
  Stream.Write (fInnerTens,sizeof (fInnerTens));
  if fResultItem<> nil then
    idx:= fResultItem.Index
  else
    idx:= -1;
  Stream.Write (idx,sizeof (idx));
  Stream.Write (fFinalManual,sizeof (fFinalManual));
  fChanged:= false;
end;

function TStartListEventShooterItem.Shooters: TStartListEventShooters;
begin
  Result:= Collection as TStartListEventShooters;
end;

procedure TStartListEventShooterItem.set_FinalShootOff(const Value: DWORD);
begin
  if (Value<> fFinalShootOff10) or (fFinalShootOffStr<> '') then
    begin
      fFinalShootOff10:= Value;
      fFinalShootOffStr:= '';
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_AllSeries(index: integer; const Value: DWORD);
var
  l,i: integer;
begin
  if index>= Length (fSeries10) then
    begin
      l:= Length (fSeries10);
      SetLength (fSeries10,index+1);
      for i:= l to index-1 do
        begin
          fSeries10 [i]:= 0;
          fChanged:= true;
        end;
      if Value<> fSeries10 [index] then
        begin
          fSeries10 [index]:= Value;
          fChanged:= true;
        end;
    end
  else
    begin
      if Value<> fSeries10 [index] then
        begin
          fSeries10 [index]:= Value;
          fChanged:= true;
        end;
    end;
  while (Length (fSeries10)> 0) and (fSeries10 [Length (fSeries10)-1]= 0) do
    begin
      SetLength (fSeries10,Length (fSeries10)-1);
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_CompPriority(const Value: integer);
begin
  if Value<> fCompPriority then
    begin
      fCompPriority:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_DistrictPoints(const Value: boolean);
begin
  if Value<> fDistrictPoints then
    begin
      fDistrictPoints:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_OutOfRank(const Value: boolean);
begin
  if Value<> fOutOfRank then
    begin
      fOutOfRank:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_RegionPoints(const Value: boolean);
begin
  if Value<> fRegionPoints then
    begin
      fRegionPoints:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_FinalManual(const Value: integer);
begin
  if Value<> fFinalManual then
    begin
      fFinalManual:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_FinalPriority(const Value: integer);
begin
  if Value<> fFinalPriority then
    begin
      fFinalPriority:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_ManualPoints(const Value: integer);
begin
  if Value<> fManualPoints then
    begin
      fManualPoints:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_RecordComment(const Value: string);
begin
  if Value<> fRecordComment then
    begin
      fRecordComment:= Value;
      fChanged:= true;
    end;
end;

function TStartListEventShooterItem.get_AllSeries(index: integer): DWORD;
begin
  if (index>= 0) and (index< Length (fSeries10)) then
    Result:= fSeries10 [index]
  else
    Result:= 0;
end;

procedure TStartListEventShooterItem.set_TeamForPoints(const Value: string);
begin
  if Trim (Value)<> fTeamForPoints then
    begin
      fTeamForPoints:= Trim (Value);
      fChanged:= true;
    end;
end;

procedure TStartListEventShooterItem.set_TeamForResults(const Value: string);
begin
  if Trim (Value)<> fTeamForResults then
    begin
      fTeamForResults:= Trim (Value);
      fChanged:= true;
    end;
end;

function TStartListEventShooterItem.AscorStartListStr (PositionIndex: integer): string;
var
  p: integer;
begin
  case Event.EventType of
    etRapidFire: p:= (fPosition [PositionIndex]-1)*5+1;
  else
    p:= fPosition [PositionIndex];
  end;
  Result:= fShooter.Shooter.ISSFID+';'+
    StartNumberStr+';'+
    fShooter.Shooter.SurnameXLit+';'+
    fShooter.Shooter.NameXLit+';'+
    fShooter.Shooter.SurnameAndNameXLit ('')+';'+
    fShooter.Shooter.RegionAbbr1XLit+';'+
    '0;0;0;0;'+
    IntToStr (p)+';'+
    IntToStr (fRelay.Index+1)+';'+
    ';0;1;0';
end;

procedure TStartListEventShooterItem.Assign(Source: TPersistent);
var
  AShooter: TStartListEventShooterItem;
  i: integer;
begin
  if Source is TStartListEventShooterItem then
    begin
      AShooter:= Source as TStartListEventShooterItem;

      fShooter:= StartList.Shooters.Items [AShooter.fShooter.Index];
      if AShooter.fRelay<> nil then
        fRelay:= StartEvent.Relays [AShooter.fRelay.Index]
      else
        fRelay:= nil;
      fPosition [0]:= AShooter.fPosition [0];
      fPosition [1]:= AShooter.fPosition [1];
      SetLength (fSeries10,Length (AShooter.fSeries10));
      for i:= 0 to Length (AShooter.fSeries10)-1 do
        fSeries10 [i]:= AShooter.fSeries10 [i];
      SetLength (fFinalShots10,Length (AShooter.fFinalShots10));
      for i:= 0 to Length (AShooter.fFinalShots10)-1 do
        fFinalShots10 [i]:= AShooter.fFinalShots10 [i];
      fFinalResult10:= AShooter.fFinalResult10;
      fRank:= AShooter.fRank;
      fRegionPoints:= AShooter.fRegionPoints;
      fDistrictPoints:= AShooter.fDistrictPoints;
      fOutOfRank:= AShooter.fOutOfRank;
      fCompShootoffStr:= AShooter.fCompShootoffStr;
      fCompPriority:= AShooter.fCompPriority;
      fFinalShootOff10:= AShooter.fFinalShootOff10;
      fFinalShootOffStr:= AShooter.fFinalShootOffStr;
      fFinalPriority:= AShooter.fFinalPriority;
      fFinalManual:= AShooter.fFinalManual;
      fSaved:= AShooter.fSaved;
      fDidNotStart:= AShooter.fDidNotStart;
      fDNSComment:= AShooter.fDNSComment;
      fManualPoints:= AShooter.fManualPoints;
      fRecordComment:= AShooter.fRecordComment;
      fTeamForPoints:= AShooter.fTeamForPoints;
      fTeamForResults:= AShooter.fTeamForResults;
      fInnerTens:= AShooter.fInnerTens;
      if AShooter.fResultItem<> nil then
        begin
          fResultItem:= Shooter.Results.FindSame (AShooter.fResultItem);
        end
      else
        fResultItem:= nil;
      fChanged:= true;
    end
  else
    inherited;
end;

{ TStartListEventRelays }

function TStartListEventRelays.Add: TStartListEventRelayItem;
begin
  Result:= inherited Add as TStartListEventRelayItem;
end;

procedure TStartListEventRelays.Assign(Source: TPersistent);
var
  i: integer;
  r: TStartListEventRelayItem;
begin
  if Source is TStartListEventRelays then
    begin
      Clear;
      for i:= 0 to (Source as TStartListEventRelays).Count-1 do
        begin
          r:= Add;
          r.Assign ((Source as TStartListEventRelays).Items [i]);
        end;
    end
  else
    inherited;
end;

constructor TStartListEventRelays.Create;
begin
  inherited Create (TStartListEventRelayItem);
  fStartEvent:= AEvent;
  fChanged:= false;
end;

function TStartListEventRelays.get_RelayIdx (index: integer): TStartListEventRelayItem;
begin
  Result:= inherited Items [index] as TStartListEventRelayItem;
end;

function TStartListEventRelays.get_StartList: TStartList;
begin
  Result:= fStartEvent.StartList;
end;

function TStartListEventRelays.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

{procedure TStartListEventRelays.ImportFromStream(Stream: TStream);
var
  i,c: integer;
  ri: TStartListEventRelayItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      ri:= Add;
      ri.ImportFromStream (Stream);
    end;
  fChanged:= true;
end;}

function TStartListEventRelays.PositionCount: integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    Result:= Result+Items [i].PositionCount;
end;

procedure TStartListEventRelays.ReadFromStream(Stream: TStream);
var
  i,c: integer;
  ri: TStartListEventRelayItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      ri:= Add;
      ri.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TStartListEventRelays.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TStartListEventRelayItem }

function TStartListEventRelayItem.CheckPosition(APosition: integer): boolean;
var
  i: integer;
begin
  Result:= false;
  for i:= 0 to Length (fPositions)-1 do
    if fPositions [i]= APosition then
      begin
        Result:= true;
        break;
      end;
end;

constructor TStartListEventRelayItem.Create(ACollection: TCollection);
begin
  inherited;
  fStartDT [0]:= Now;
  fStartDT [1]:= fStartDT [0];
  fChanged:= false;
  Relays.fChanged:= true;
end;

function TStartListEventRelayItem.get_Position(index: integer): integer;
begin
  Result:= fPositions [index];
end;

function TStartListEventRelayItem.get_PositionCount: integer;
begin
  Result:= Length (fPositions);
end;

function TStartListEventRelayItem.get_PositionsStr: string;
var
  c,i: integer;
begin
  Result:= '';
  c:= 0;
  for i:= 0 to Length (fPositions)-1 do
    begin
      if (i= 0) then
        Result:= IntToStr (fPositions [i])
      else
        begin
          if fPositions [i]= fPositions [i-1]+1 then
            inc (c)
          else
            begin
              if c> 0 then
                Result:= Result+'-'+IntToStr (fPositions [i-1]);
              Result:= Result+','+IntToStr (fPositions [i]);
              c:= 0;
            end;
        end;
    end;
  if c> 0 then
    Result:= Result+'-'+IntToStr (fPositions [Length (fPositions)-1]);
end;

function TStartListEventRelayItem.get_Relays: TStartListEventRelays;
begin
  Result:= Collection as TStartListEventRelays;
end;

function TStartListEventRelayItem.get_StartEvent: TStartListEventItem;
begin
  Result:= Relays.StartEvent;
end;

function TStartListEventRelayItem.get_StartTime: TDateTime;
begin
  Result:= fStartDT [0];
end;

function TStartListEventRelayItem.get_StartTime2: TDateTime;
begin
  Result:= fStartDT [1];
end;

function TStartListEventRelayItem.IsCompleted: boolean;
var
  sh: TStartListEventShooterItem;
  i: integer;
begin
  Result:= true;
  for i:= 0 to StartEvent.Shooters.Count-1 do
    begin
      sh:= StartEvent.Shooters.Items [i];
      if (sh.Relay= self) and (not sh.IsFinished) then
        begin
          Result:= false;
          break;
        end;
    end;
end;

procedure TStartListEventRelayItem.PreconfigureStartTime;
begin
  if (Index> 0) then
    begin
      // ��������� ����� �� ����� �� ���������� ����������
      fStartDT [0]:= Relays [Index-1].fStartDT [0]+StartEvent.Event.RelayTime;
      fStartDT [1]:= Relays [Index-1].fStartDT [1]+StartEvent.Event.RelayTime;
    end;
end;

{procedure TStartListEventRelayItem.ImportFromStream(Stream: TStream);
var
  c: integer;
begin
  Stream.Read (fStartTime,sizeof (fStartTime));
  Stream.Read (c,sizeof (c));
  SetLength (fPositions,c);
  Stream.Read (fPositions [0],c*sizeof (integer));
  fChanged:= true;
end;}

function TStartListEventRelayItem.SetPositionsStr(const Value: string): boolean;
var
  temp: array of integer;

  function Add (p: integer): boolean;
  var
    i: integer;
  begin
    Result:= false;
    for i:= 0 to Length (temp)-1 do
      if temp [i]= p then
        exit;
    SetLength (temp,Length (temp)+1);
    temp [Length (temp)-1]:= p;
    Result:= true;
  end;

var
  s,s1: string;
  b1,b2,i: integer;
  p,p1,p2: integer;
begin
  Result:= false;
  SetLength (temp,0);
  s:= Value;
  while s<> '' do
    begin
      b1:= pos (',',s);
      if b1= 0 then
        b1:= Length (s)+1;
      s1:= copy (s,1,b1-1);
      if s1<> '' then
        begin
          b2:= pos ('-',s1);
          if b2> 0 then
            begin
              Val (copy (s1,1,b2-1),p1,i);
              if i<> 0 then
                begin
                  SetLength (temp,0);
                  temp:= nil;
                  exit;
                end;
              Val (copy (s1,b2+1,Length (s1)-b2),p2,i);
              if i<> 0 then
                begin
                  SetLength (temp,0);
                  temp:= nil;
                  exit;
                end;
              for i:= p1 to p2 do
                if not Add (i) then
                  begin
                    SetLength (temp,0);
                    temp:= nil;
                    exit;
                  end;
            end
          else
            begin
              Val (s1,p,i);
              if i<> 0 then
                begin
                  SetLength (temp,0);
                  temp:= nil;
                  exit;
                end;
              if not Add (p) then
                begin
                  SetLength (temp,0);
                  temp:= nil;
                  exit;
                end;
            end;
        end;
      delete (s,1,b1);
    end;
  SetLength (fPositions,Length (temp));
  for i:= 0 to Length (temp)-1 do
    fPositions [i]:= temp [i];
  SetLength (temp,0);
  temp:= nil;
  Result:= true;
  fChanged:= true;
end;

procedure TStartListEventRelayItem.set_StartTime(const Value: TDateTime);
begin
  if Value<> fStartDT [0] then
    begin
      fStartDT [0]:= Value;
//      StartEvent.UpdateShootingEventDate;
      fChanged:= true;
    end;
end;

procedure TStartListEventRelayItem.set_StartTime2(const Value: TDateTime);
begin
  if Value<> fStartDT [1] then
    begin
      fStartDT [1]:= Value;
//      StartEvent.UpdateShootingEventDate;
      fChanged:= true;
    end;
end;

procedure TStartListEventRelayItem.ReadFromStream(Stream: TStream);
var
  c: integer;
begin
  Stream.Read (fStartDT,sizeof (fStartDT));
  Stream.Read (c,sizeof (c));
  SetLength (fPositions,c);
  Stream.Read (fPositions [0],c*sizeof (integer));
  fChanged:= false;
end;

procedure TStartListEventRelayItem.WriteToStream(Stream: TStream);
var
  c: integer;
begin
  Stream.Write (fStartDT,sizeof (fStartDT));
  c:= Length (fPositions);
  Stream.Write (c,sizeof (c));
  Stream.Write (fPositions [0],c*sizeof (integer));
  fChanged:= false;
end;

destructor TStartListEventRelayItem.Destroy;
begin
  Relays.fChanged:= true;
  inherited;
end;

procedure TStartListEventRelayItem.Assign(Source: TPersistent);
var
  ARelay: TStartListEventRelayItem;
  i: integer;
begin
  if Source is TStartListEventRelayItem then
    begin
      ARelay:= Source as TStartListEventRelayItem;
      fStartDT [0]:= ARelay.StartTime;
      fStartDT [1]:= ARelay.StartTime2;
//      StartEvent.UpdateShootingEventDate;
      SetLength (fPositions,Length (ARelay.fPositions));
      for i:= 0 to Length (ARelay.fPositions)-1 do
        fPositions [i]:= ARelay.fPositions [i];
      fChanged:= true;
    end
  else
    inherited;
end;

{ TStartList }

procedure TStartList.ChangeTeamName(AFrom, ATo: string);
var
  i,j: integer;
  sh: TStartListEventShooterItem;
begin
  for i:= 0 to fEvents.Count-1 do
    for j:= 0 to fEvents.Items [i].fShooters.Count-1 do
      begin
        sh:= fEvents [i].fShooters.Items [j];
        if AnsiSameText (sh.TeamForPoints,AFrom) then
          sh.TeamForPoints:= ATo;
        if AnsiSameText (sh.TeamForResults,AFrom) then
          sh.TeamForResults:= ATo;
      end;
end;

procedure TStartList.ConvertToNil(AChampionship: TChampionshipItem);
var
  i: integer;
  ev: TStartListEventItem;
begin
  if Info.Championship= AChampionship then
    begin
      Info.Championship:= nil;
      Info.ChampionshipName:= AChampionship.Name;
    end;
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events [i];
      if ev.Info.Championship= AChampionship then
        begin
          ev.Info.Championship:= nil;
          ev.Info.ChampionshipName:= AChampionship.Name;
        end;
    end;
end;

procedure TStartList.GetTeamRanks(ATeam: string; var AllRanks: TAllRanksArray);
var
  ev: TStartListEventItem;
  i,j,idx: integer;
  sh: TStartListEventShooterItem;
begin
  SetLength (AllRanks,0);
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events [i];
      if not ev.InPointsTable then
        continue;
      ev.Shooters.SortOrder:= soFinal;
      for j:= 0 to ev.Shooters.Count-1 do
        begin
          sh:= ev.Shooters.Items [j];
          if AnsiSameText (sh.TeamForPoints,ATeam) then
            begin
              idx:= Length (AllRanks);
              SetLength (AllRanks,idx+1);
              AllRanks [idx]:= j+1;
            end;
        end;
    end;
end;

function TStartList.GetTeams (OnlyForPoints: boolean; ForGroup: TStartListTeamsGroup): TStrings;
var
  list: TStringList;
  i,j: integer;
  sh: TStartListEventShooterItem;

  procedure CheckTeam (team: string);
  var
    j: integer;
  begin
    if team= '' then
      exit;
    if (ForGroup<> nil) and (ForGroup.TeamIndex (team)< 0) then
      exit;
    for j:= 0 to list.Count-1 do
      if AnsiSameText (team,list [j]) then
        exit;
    list.Add (team);
  end;

begin
  list:= TStringList.Create;
  for i:= 0 to fEvents.Count-1 do
    for j:= 0 to fEvents.Items [i].fShooters.Count-1 do
      begin
        sh:= fEvents.Items [i].fShooters.Items [j];
        CheckTeam (sh.TeamForPoints);
        if not OnlyForPoints then
          CheckTeam (sh.TeamForResults);
      end;
  Result:= list;
end;

constructor TStartList.Create (ACollection: TCollection);
begin
  inherited;
  fOnDelete:= nil;
  CreateGUID (fId);
  fInfo:= TStartListInfo.Create (self);
  fEvents:= TStartListEvents.Create (self);
  fStartNumbersPrintout:= TStartNumbersPrintout.Create;
//  fFinalNumbersPrintout:= TFinalNumbersPrintout.Create;
  fShooters:= TStartListShooters.Create (self);
  fQualificationPoints:= TStartListQualificationPoints.Create (self);
  fChanged:= false;
//  fShootingChampionship:= nil;
  StartLists.fChanged:= true;
  SetLength (fNotifiers,0);
  fTeamsGroups:= TStartListTeamsGroups.Create (self);
end;

(*
procedure TStartList.CreateShootingChampionship;
begin
  if fShootingChampionship<> nil then
    exit;
  {$ifdef debug_info}
  OutputDebugString (pchar ('Creating championship for start list: '+Info.CaptionText));
  {$endif}
  fShootingChampionship:= Data.ShootingChampionships.Add;
  fShootingChampionship.SetChampionship (Info.Championship,Info.ChampionshipName);
  fShootingChampionship.Country:= '';
  fShootingChampionship.Town:= Info.Town;
end;
*)

function TStartList.Data: TData;
begin
  Result:= (Collection as TStartLists).fData;
end;

function TStartList.DatesFromTillStr: string;
var
  d1,d2: TDateTime;
begin
  Result:= '...';
  if not DatesValid then
    exit;
  d1:= DateFrom;
  d2:= DateTill;
  Result:= _DatesFromTillStr (d1,d2);
end;

function TStartList.DatesValid: boolean;
var
  i: integer;
  ev: TStartListEventItem;
begin
  Result:= false;
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events.Items [i];
      if ev.Relays.Count> 0 then
        begin
          Result:= true;
          break;
        end;
    end;
end;

procedure TStartList.DeleteEvent(AEvent: TEventItem);
var
  i: integer;
begin
  i:= 0;
  while i< Events.Count do
    begin
      if Events [i].Event= AEvent then
        Events.Delete (i)
      else
        inc (i);
    end;
end;

destructor TStartList.Destroy;
begin
  if Assigned (fOnDelete) then
    fOnDelete (self);
  fShooters.Free;
  fStartNumbersPrintout.Free;
//  fFinalNumbersPrintout.Free;
  fEvents.Free;
  fQualificationPoints.Free;
  fInfo.Free;
  StartLists.fChanged:= true;
  SetLength (fNotifiers,0);
  fNotifiers:= nil;
  fTeamsGroups.Free;
  inherited;
end;

(*
procedure TStartList.DestroyShootingChampionshipIfEmpty;
begin
  if fShootingChampionship= nil then
    exit;
  if fShootingChampionship.ResultsCount= 0 then
    fShootingChampionship.Free;
  fShootingChampionship:= nil;
end;
*)

function TStartList.DistrictPoints(ADistrictAbbr: string; AWeapon: TWeapons; AGenders: TGenders): integer;
var
  i: integer;
  ev: TStartListEventItem;
begin
  Result:= 0;
  for i:= 0 to fEvents.Count-1 do
    begin
      ev:= fEvents.Items [i];
      if not ev.InPointsTable then
        continue;
      if ev.Event.WeaponType in AWeapon then
        Result:= Result+ev.DistrictPoints (ADistrictAbbr,AGenders);
    end;
end;

procedure TStartList.GetDistrictRanks(ADistrict: string; var AllRanks: TAllRanksArray);
var
  ev: TStartListEventItem;
  i,j,idx: integer;
  sh: TStartListEventShooterItem;
begin
  SetLength (AllRanks,0);
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events [i];
      if not ev.InPointsTable then
        continue;
      ev.Shooters.SortOrder:= soFinal;
      for j:= 0 to ev.Shooters.Count-1 do
        begin
          sh:= ev.Shooters.Items [j];
          if AnsiSameText (sh.Shooter.DistrictAbbr,ADistrict) then
            begin
              idx:= Length (AllRanks);
              SetLength (AllRanks,idx+1);
              AllRanks [idx]:= j+1;
            end;
        end;
    end;
end;

function TStartList.GetDistricts: TStrings;
var
  list: TStrings;
  i,j: integer;
  sh: TStartListEventShooterItem;

  procedure CheckDistrict (district: string);
  var
    j: integer;
  begin
    if district= '' then
      exit;
    for j:= 0 to list.Count-1 do
      if AnsiSameText (district,list [j]) then
        exit;
    list.Add (district);
  end;

begin
  list:= TStringList.Create;
  for i:= 0 to fEvents.Count-1 do
    for j:= 0 to fEvents.Items [i].fShooters.Count-1 do
      begin
        sh:= fEvents.Items [i].fShooters.Items [j];
        if (sh.GiveDistrictPoints) and (not sh.OutOfRank) then
          CheckDistrict (sh.Shooter.DistrictAbbr);
      end;
  Result:= list;
end;

function TStartList.GetNextProtocolNumber: integer;
var
  i: integer;
begin
  Result:= 1;
  for i:= 0 to Events.Count-1 do
    if Events [i].ProtocolNumber>= Result then
      Result:= Events [i].ProtocolNumber+1;
end;

procedure TStartList.GetRegionRanks(ARegion: string; var AllRanks: TAllRanksArray);
var
  ev: TStartListEventItem;
  i,j,idx: integer;
  sh: TStartListEventShooterItem;
begin
  SetLength (AllRanks,0);
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events [i];
      if not ev.InPointsTable then
        continue;
      ev.Shooters.SortOrder:= soFinal;
      for j:= 0 to ev.Shooters.Count-1 do
        begin
          sh:= ev.Shooters.Items [j];
          if (AnsiSameText (sh.Shooter.RegionAbbr1,ARegion)) or
             (AnsiSameText (sh.Shooter.RegionAbbr2,ARegion)) then
            begin
              idx:= Length (AllRanks);
              SetLength (AllRanks,idx+1);
              AllRanks [idx]:= j+1;
            end;
        end;
    end;
end;

function TStartList.GetRegions (OnlyWithPoints: boolean): TStrings;
var
  list: TStrings;
  i,j: integer;
  sh: TStartListEventShooterItem;

  procedure CheckRegion (region: string);
  var
    j: integer;
  begin
    if region= '' then
      exit;
    for j:= 0 to list.Count-1 do
      if AnsiSameText (region,list [j]) then
        exit;
    list.Add (region);
  end;

begin
  list:= TStringList.Create;
  for i:= 0 to fEvents.Count-1 do
    for j:= 0 to fEvents.Items [i].fShooters.Count-1 do
      begin
        sh:= fEvents.Items [i].fShooters.Items [j];
        if (OnlyWithPoints) and (not sh.GiveRegionPoints) then
          continue;
        if sh.OutOfRank then
          continue;
        CheckRegion (sh.Shooter.RegionAbbr1);
        CheckRegion (sh.Shooter.RegionAbbr2);
      end;
  Result:= list;
end;

function TStartList.get_StartNumbers: boolean;
begin
  Result:= Info.fStartNumbers;
end;

function TStartList.get_WasChanged: boolean;
begin
  Result:= fChanged or
//    fTeams.WasChanged or
    fShooters.WasChanged or
    fQualificationPoints.WasChanged or
    fEvents.WasChanged or
    fInfo.WasChanged or
    fTeamsGroups.WasChanged;
end;

function TStartList.HasEvent(AEvent: TEventItem): boolean;
var
  i: integer;
begin
  Result:= true;
  for i:= 0 to Events.Count-1 do
    if Events [i].Event= AEvent then
      exit;
  Result:= false;
end;

function TStartList.HaveTeams: boolean;
var
  i,j: integer;
  sh: TStartListEventShooterItem;
begin
  Result:= false;
  for i:= 0 to fEvents.Count-1 do
    for j:= 0 to fEvents.Items [i].fShooters.Count-1 do
      begin
        sh:= fEvents.Items [i].fShooters.Items [j];
        if (sh.TeamForPoints<> '') or (sh.TeamForResults<> '') then
          begin
            Result:= true;
            break;
          end;
      end;
end;

procedure TStartList.MergeWith(AStartList: TStartList);
begin
  // TODO: ���������� ���������
end;

function TStartList.NextAvailableStartNumber: integer;
begin
  Result:= fShooters.NextAvailableStartNumber;
end;

procedure TStartList.Notify(Msg: UINT; WParam: WPARAM; LParam: LPARAM);
var
  i: integer;
begin
  for i:= 0 to Length (fNotifiers)-1 do
    //PostMessage (fNotifiers [i],Msg,WParam,LParam);
    SendMessage (fNotifiers[i],Msg,WParam,LParam);
end;

function TStartList.Participate(AShooter: TShooterItem): boolean;
var
  i: integer;
begin
  Result:= false;
  for i:= 0 to fShooters.Count-1 do
    if fShooters [i].Shooter= AShooter then
      begin
        Result:= (fShooters [i].EventsCount> 0);
        break;
      end;
end;

procedure TStartList.PrintAllStartNumbers;
var
  i: integer;
begin
  fStartNumbersPrintout.StartJob;
  for i:= 0 to fShooters.Count-1 do
    fStartNumbersPrintout.AddShooter (fShooters [i]);
  if fStartNumbersPrintout.IsPending then
    fStartNumbersPrintout.PrintOut;
  fStartNumbersPrintOut.FinishJob;
  fStartNumbersPrintout.Clear;
end;

procedure TStartList.PrintPointsTable(Prn: TObject; AgeGroup: TAgeGroup; ACopies: integer;
  PointsFor: TPointsFor; TableType: TPointsTableType; ForGroups: boolean; const ATitle: string);
var
  teams: array of TStartListTotalTeamStats;
  teamnames: TStrings;
  i,j,idx: integer;
  ts: TStartListTotalTeamStats;
  font_name: string;
  font_size: integer;
  font_height_large,font_height_small: integer;
  footerheight: integer;
  page_idx: integer;
  y: integer;
  th_s,th_l: integer;
  men,women: string;
  title_page: boolean;
  current_group: TStartListTeamsGroup;
  _printer: TMyPrinter;
  Tabl: TMyTable;
  page_height: integer;

  procedure MakeNewPage;
  var
    st,s1: string;
    s: TStrings;
    i,w,x: integer;
  begin
    if page_idx> 1 then
      begin
        _printer.NewPage;
      end;
    with _printer.Canvas do   // footer
      begin
        Pen.Width:= 1;
        y:= _printer.Bottom-th_s*2-_printer.MM2PY (2);
        MoveTo (_printer.Left,y);
        LineTo (_printer.Right,y);
        y:= y+_printer.MM2PY (2);
        Font.Height:= font_height_small;
        Font.Style:= [];
        st:= format (PAGE_NO,[page_idx]);
        TextOut (_printer.Right-TextWidth (st),y,st);
        st:= format (PAGE_FOOTER,[VERSION_INFO_STR]);
        TextOut (_printer.Left,y,st);
        y:= y+TextHeight ('Mg');
        st:= PROTOCOL_MAKER_SIGN;
        TextOut (_printer.Left,y,st);

        y:= _printer.Bottom-footerheight;
        Font.Height:= font_height_large;
        Font.Style:= [];

        // ������� �����
        if Info.Jury+Info.JuryCategory<> '' then
          begin
            y:= y+_printer.MM2PY (5);
            x:= _printer.Left+_printer.MM2PX (3);
            TextOut (x,y,JURY_TITLE);
            y:= y+th_l;
            TextOut (x,y,Info.JuryCategory);
            x:= _printer.Right-_printer.MM2PX (3)-TextWidth (Info.Jury);
            TextOut (x,y,Info.Jury);
            y:= y+th_l;
          end;

        // ���������
        if Info.Secretery+Info.SecreteryCategory<> '' then
          begin
            y:= y+_printer.MM2PY (5);
            x:= _printer.Left+_printer.MM2PX (3);
            TextOut (x,y,SECRETERY_TITLE);
            y:= y+th_l;
            TextOut (x,y,Info.SecreteryCategory);
            x:= _printer.Right-_printer.MM2PX (3)-TextWidth (Info.Secretery);
            TextOut (x,y,Info.Secretery);
          end;
      end;
    y:= _printer.Top;
    // header
    if title_page then
      begin
        title_page:= false;
        with _printer.Canvas do
          begin
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            s:= TStringList.Create;
            s.Text:= Info.TitleText;
            for i:= 0 to s.Count-1 do
              begin
                st:= s [i];
                w:= TextWidth (st);
                x:= (_printer.Left+_printer.Right-w) div 2;
                TextOut (x,y,st);
                inc (y,TextHeight (st));
              end;
            if s.Count> 0 then
              inc (y,_printer.MM2PY (2));
            s.Text:= ATitle;
{            case PointsFor of
              pfTeam: s.Text:= TOTAL_TEAM_CHAMPIONSHIP_TITLE;
              pfRegion: s.Text:= TOTAL_REGION_CHAMPIONSHIP_TITLE;
              pfDistrict: s.Text:= TOTAL_DISTRICT_CHAMPIONSHIP_TITLE;
            end;}
            for i:= 0 to s.Count-1 do
              begin
                s1:= s [i];
                w:= TextWidth (s1);
                x:= (_printer.Left+_printer.Right-w) div 2;
                TextOut (x,y,s1);
                inc (y,TextHeight (s1));
              end;
            if s.Count> 0 then
              inc (y,_printer.MM2PY (2));
            s.Free;
            if current_group<> nil then
              begin
                s1:= current_group.Name;
                w:= TextWidth (s1);
                x:= (_printer.Left+_printer.Right-w) div 2;
                TextOut (x,y,s1);
                inc (y,TextHeight (s1)+_printer.MM2PY (2));
              end;
            st:= DatesFromTillStr;
            Font.Style:= [];
            TextOut (_printer.Left,y,st);
            st:= Info.TownAndRange;
            w:= TextWidth (st);
            TextOut (_printer.Right-w,y,st);
            inc (y,TextHeight ('Mg')+_printer.MM2PY (2));
          end;
      end
    else
      begin
        with _printer.Canvas do
          begin
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            s:= TStringList.Create;
            s.Text:= Info.TitleText;
            for i:= 0 to s.Count-1 do
              begin
                st:= s [i];
                w:= TextWidth (st);
                x:= (_printer.Left+_printer.Right-w) div 2;
                TextOut (x,y,st);
                inc (y,TextHeight (st));
              end;
            if s.Count> 0 then
              inc (y,_printer.MM2PY (2));
            s.Free;

            Font.Height:= font_height_large;
            Font.Style:= [];
            st:= TOTAL_CHAMPIONSHIP_CONTINUE;
            w:= TextWidth (st);
            TextOut (_printer.Right-w,y,st);
            inc (y,TextHeight (st)+_printer.MM2PY (2));
          end;
      end;

    Tabl.Canvas:= _printer.Canvas;
    if Tabl.Width< _printer.Width then
      Tabl.ColWidths[1]:= Tabl.ColWidths[1] + _printer.Width-Tabl.Width;
    page_height:= (_printer.Bottom-footerheight-y);

    inc (page_idx);
  end;

  procedure CreateTabl;
  var
    i,j: integer;
    ev: TStartListEventItem;
    ts: TStartListTotalTeamStats;
    men_col,women_col,total_col: integer;
    men_cnt,women_cnt: integer;
  begin
    Tabl:= TMyTable.Create;
    Tabl.Canvas:= _printer.Canvas;
    Tabl.Font.Name:= font_name;
    Tabl.Font.Charset:= PROTOCOL_CHARSET;
    Tabl.Font.Size:= font_size;
    Tabl.Font.Style:= [];
    Tabl.XPadding:= _printer.MM2PX (1);
    Tabl.YPadding:= _printer.MM2PY (1);
    Tabl.VGrid:= 1;
    Tabl.HGrid:= 1;
    Tabl.HeaderGrid:= true;
    Tabl.BodyGrid:= true;

    Tabl.Header[0,0].AsText:= ''; // �����
    case PointsFor of
      pfTeam: Tabl.Header[1,0].AsText:= TEAM_STR;
      pfRegion: Tabl.Header[1,0].AsText:= REGION_STR;
      pfDistrict: Tabl.Header[1,0].AsText:= DISTRICT_STR;
    end;
    Tabl.Header[1,0].Align:= taCenter;
    Tabl.Header[1,0].VAlign:= taCenter;
    for i:= 0 to Length(teams)-1 do
      begin
        ts:= teams[i];
        Tabl.Cells[0,i].AsText:= IntToStr (i+1);
        Tabl.Cells[0,i].Align:= taRight;
        Tabl.Cells[1,i].AsText:= ts.FullName;
      end;

    case TableType of
      pttEventTypes: begin
        // ������� ��������
        Tabl.Header[2,1].AsText:= men;
        Tabl.Header[3,1].AsText:= women;
        Tabl.Header[2,0].AsText:= RIFLE_STR;
        Tabl.Header[2,0].Align:= taCenter;
        Tabl.Header[2,0].ColSpan:= 2;
        // ������� ��������
        Tabl.Header[4,1].AsText:= men;
        Tabl.Header[5,1].AsText:= women;
        Tabl.Header[4,0].AsText:= PISTOL_STR;
        Tabl.Header[4,0].Align:= taCenter;
        Tabl.Header[4,0].ColSpan:= 2;
        // ������� �����
        Tabl.Header[6,1].AsText:= men;
        Tabl.Header[7,1].AsText:= women;
        Tabl.Header[6,0].AsText:= MOVING_TARGET_STR;
        Tabl.Header[6,0].Align:= taCenter;
        Tabl.Header[6,0].ColSpan:= 2;
        // ������� �����
        Tabl.Header[8,0].AsText:= TOTAL_POINTS;
        Tabl.Header[8,0].RowSpan:= 2;
        Tabl.Header[8,0].Align:= taCenter;
        Tabl.Header[8,0].VAlign:= taCenter;
        for i:= 0 to Length (teams)-1 do
          begin
            ts:= teams[i];
            Tabl.Cells[2,i].AsText:= IntToStr (ts.RifleMenPoints);
            Tabl.Cells[2,i].Align:= taCenter;
            Tabl.Cells[3,i].AsText:= IntToStr (ts.RifleWomenPoints);
            Tabl.Cells[3,i].Align:= taCenter;
            Tabl.Cells[4,i].AsText:= IntToStr (ts.PistolMenPoints);
            Tabl.Cells[4,i].Align:= taCenter;
            Tabl.Cells[5,i].AsText:= IntToStr (ts.PistolWomenPoints);
            Tabl.Cells[5,i].Align:= taCenter;
            Tabl.Cells[6,i].AsText:= IntToStr (ts.MovingMenPoints);
            Tabl.Cells[6,i].Align:= taCenter;
            Tabl.Cells[7,i].AsText:= IntToStr (ts.MovingWomenPoints);
            Tabl.Cells[7,i].Align:= taCenter;
            Tabl.Cells[8,i].AsText:= IntToStr (ts.TotalPoints);
            Tabl.Cells[8,i].Align:= taCenter;
          end;
        Tabl.Header[0,0].RowSpan:= 2;
        Tabl.Header[1,0].RowSpan:= 2;
      end;
      pttEvents: begin
        men_cnt:= 0;
        men_col:= 2;
        women_col:= 2;
        women_cnt:= 0;
        total_col:= 2;
        for i:= 0 to fEvents.Count-1 do
          begin
            ev:= Events[i];
            if not ev.InPointsTable then
              continue;
            if ev.Gender= Male then
              begin
                Tabl.Header[men_col+men_cnt,1].AsText:= ev.Event.ShortName;
                for j:= 0 to Length (teams)-1 do
                  begin
                    ts:= teams[j];
                    Tabl.Cells[men_col+men_cnt,j].AsText:= IntToStr (ts.EventPoints (ev));
                    Tabl.Cells[men_col+men_cnt,j].Align:= taCenter;
                  end;
                inc (men_cnt);
              end;
          end;
        if men_cnt> 0 then
          begin
            Tabl.Header[men_col,0].AsText:= men;
            Tabl.Header[men_col+men_cnt,1].AsText:= SUM_STR;
            for i:= 0 to Length (teams)-1 do
              begin
                ts:= teams[i];
                Tabl.Cells[men_col+men_cnt,i].AsText:= IntToStr (ts.MenPoints);
                Tabl.Cells[men_col+men_cnt,i].Font.Style:= [fsBold];
                Tabl.Cells[men_col+men_cnt,i].Align:= taCenter;
              end;
            women_col:= men_col+men_cnt+1;
          end;
        for i:= 0 to fEvents.Count-1 do
          begin
            ev:= Events[i];
            if not ev.InPointsTable then
              continue;
            if ev.Gender= Female then
              begin
                Tabl.Header[women_col+women_cnt,1].AsText:= ev.Event.ShortName;
                for j:= 0 to Length (teams)-1 do
                  begin
                    ts:= teams[j];
                    Tabl.Cells[women_col+women_cnt,j].AsText:= IntToStr (ts.EventPoints (ev));
                    Tabl.Cells[women_col+women_cnt,j].Align:= taCenter;
                  end;
                inc (women_cnt);
              end;
          end;
        if women_cnt> 0 then
          begin
            Tabl.Header[women_col,0].AsText:= women;
            Tabl.Header[women_col+women_cnt,1].AsText:= SUM_STR;
            for i:= 0 to Length (teams)-1 do
              begin
                ts:= teams[i];
                Tabl.Cells[women_col+women_cnt,i].AsText:= IntToStr (ts.WomenPoints);
                Tabl.Cells[women_col+women_cnt,i].Font.Style:= [fsBold];
                Tabl.Cells[women_col+women_cnt,i].Align:= taCenter;
              end;
          end;
        if men_cnt> 0 then
          begin
            Tabl.Header[men_col,0].ColSpan:= men_cnt+1;
            Tabl.Header[men_col,0].Align:= taCenter;
            inc (total_col,men_cnt+1);
          end;
        if women_cnt> 0 then
          begin
            Tabl.Header[women_col,0].ColSpan:= women_cnt+1;
            Tabl.Header[women_col,0].Align:= taCenter;
            inc (total_col,women_cnt+1);
          end;
        Tabl.Header[total_col,0].AsText:= TOTAL_POINTS;
        Tabl.Header[total_col,0].RowSpan:= 2;
        Tabl.Header[total_col,0].Align:= taCenter;
        Tabl.Header[total_col,0].VAlign:= taCenter;
        for i:= 0 to Length(teams)-1 do
          begin
            ts:= teams[i];
            Tabl.Cells[total_col,i].AsText:= IntToStr (ts.TotalPoints);
            Tabl.Cells[total_col,i].Align:= taCenter;
          end;
        Tabl.Header[0,0].RowSpan:= 2;
        Tabl.Header[1,0].RowSpan:= 2;
      end;
    end;
  end;

  procedure PrintTableForTeams;
  var
    i,j: integer;
    startrow,endrow: integer;
  begin
    // ��������� �������
    for i:= 0 to Length (teams)-2 do
      begin
        idx:= i;
        for j:= i+1 to Length (teams)-1 do
          if teams [j].CompareTo (teams [idx])= 1 then
            idx:= j;
        if idx<> i then
          begin
            ts:= teams [i];
            teams [i]:= teams [idx];
            teams [idx]:= ts;
          end;
      end;

    title_page:= true;

    with _printer.Canvas.Font do
      begin
        Name:= font_name;
        Charset:= PROTOCOL_CHARSET;
        Size:= font_size;
        font_height_large:= Height;
        font_height_small:= round (font_height_large * 4/5);
      end;

    CreateTabl;

    repeat
      if Tabl.Width<= _printer.Width then
        begin
          Tabl.ColWidths[1]:= Tabl.ColWidths[1] + _printer.Width-Tabl.Width;
          break;
        end
      else
        begin
          if abs (Tabl.Font.Height)> 1 then
            Tabl.DecreaseFontSize
          else
            begin
              _printer.Abort;
              Tabl.Free;
              for i:= 0 to Length (teams)-1 do
                teams [i].Free;
              SetLength (teams,0);
              exit;
            end;
        end;
    until false;

    with _printer.Canvas do
      begin
        Font.Height:= font_height_large;
        th_l:= TextHeight ('Mg');
        Font.Height:= font_height_small;
        th_s:= TextHeight ('Mg');
        footerheight:= th_s*2+_printer.MM2PY (4);
        if Info.Secretery+Info.SecreteryCategory<> '' then
          footerheight:= footerheight+th_l*2+_printer.MM2PY (5);
        if Info.Jury+Info.JuryCategory<> '' then
          footerheight:= footerheight+th_l*2+_printer.MM2PY (5);
        if footerheight> th_s*2+_printer.MM2PY (4) then
          footerheight:= footerheight+_printer.MM2PY (5);
      end;

    startrow:= 0;
    while startrow< Tabl.RowCount do
      begin
        MakeNewPage;
        endrow:= Tabl.RowCount-1;
        while Tabl.Height (startrow,endrow)> page_height do
          dec (endrow);
        Tabl.Draw (_printer.Canvas,_printer.Left,y,startrow,endrow);
        startrow:= endrow+1;
      end;

    Tabl.Free;

    for i:= 0 to Length (teams)-1 do
      teams [i].Free;
    SetLength (teams,0);
    teams:= nil;
  end;

begin
  if Prn= nil then
    begin
      Prn:= Printer;
      if Prn= nil then
        exit;
    end;

  case AgeGroup of
    agYouths: begin
      men:= YOUTHS_MEN;
      women:= YOUTHS_WOMEN;
    end;
    agJuniors: begin
      men:= JUNIORS_MEN;
      women:= JUNIORS_WOMEN;
    end;
    agAdults: begin
      men:= ADULTS_MEN;
      women:= ADULTS_WOMEN;
    end;
  end;

  _printer:= TMyPrinter.Create (Prn);
  _printer.Orientation:= poPortrait;
  _printer.PageSize:= psA4;
  _printer.Copies:= ACopies;
  if _printer.PDF<> nil then
    begin
      _printer.PDF.ProtectionEnabled:= true;
      _printer.PDF.ProtectionOptions:= [coPrint];
      _printer.PDF.Compression:= ctFlate;
    end;
  case PointsFor of
    pfTeam: _printer.Title:= TOTAL_TEAM_CHAMPIONSHIP_PRINT_TITLE;
    pfRegion: _printer.Title:= TOTAL_REGION_CHAMPIONSHIP_PRINT_TITLE;
    pfDistrict: _printer.Title:= TOTAL_DISTRICT_CHAMPIONSHIP_PRINT_TITLE;
  end;
  _printer.BeginDoc;
  _printer.SetBordersMM (20,15,10,5);

  try
    GetDefaultProtocolFont (font_name,font_size);
    page_idx:= 1;

    if (ForGroups) and (fTeamsGroups.Count> 0) and (PointsFor= pfTeam) then
      begin
        for i:= 0 to fTeamsGroups.Count-1 do
          begin
            current_group:= fTeamsGroups [i];
            teamnames:= GetTeams (true,current_group);
            if teamnames.Count> 0 then
              begin
                SetLength (teams,teamnames.Count);
                for j:= 0 to teamnames.Count-1 do
                  teams [j]:= TStartListTotalTeamStats.Create (Self,teamnames [j],PointsFor);
                PrintTableForTeams;
              end;
            teamnames.Free;
          end;
      end
    else
      begin
        current_group:= nil;
        case PointsFor of
          pfTeam: teamnames:= GetTeams (true,nil);
          pfRegion: teamnames:= GetRegions (true);
          pfDistrict: teamnames:= GetDistricts;
        else
          exit;
        end;
        if teamnames.Count> 0 then
          begin
            SetLength (teams,teamnames.Count);
            for i:= 0 to teamnames.Count-1 do
              teams [i]:= TStartListTotalTeamStats.Create (Self,teamnames [i],PointsFor);
            PrintTableForTeams;
          end;
        teamnames.Free;
      end;
  finally
    _printer.EndDoc;
    _printer.Free;
  end;
end;

function TStartList.Qualified (AQualificationFrom,AQualificationTo: TQualificationItem): integer;
var
  i: integer;
  ev: TStartListEventItem;
begin
  Result:= 0;
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events [i];
      Result:= Result+ev.Qualified (AQualificationFrom,AQualificationTo);
    end;
end;

procedure TStartList.ReadFromStream(Stream: TStream);
var
  teams: array of string;
  c,i,n: integer;
  sh: TStartListShooterItem;
//  ev: TStartListEventItem;
begin
  if Data.fFileVersion>= 40 then
    Stream.Read (fID,sizeof (fID));
  fInfo.ReadFromStream (Stream);
  if Data.fFileVersion< 28 then
    begin
      if Data.fFileVersion>= 26 then
        begin
          Stream.Read (i,sizeof (i));
          _sch:= Data.ShootingChampionships [i];
        end;
    end;
  Stream.Read (fShootersPerTeam,sizeof (fShootersPerTeam));
  if Data.fFileVersion<= 9 then
    begin
      Stream.Read (c,sizeof (c));
      SetLength (teams,c);
      for i:= 0 to c-1 do
        ReadStrFromStreamA (Stream,teams [i]);
    end;
  fShooters.ReadFromStream (Stream);
  if Data.fFileVersion<= 9 then
    begin
      for i:= 0 to fShooters.Count-1 do
        begin
          sh:= fShooters.Items [i];
          if sh.fOldTeam<> '' then
            begin
              val (sh.fOldTeam,n,c);
              sh.fOldTeam:= teams [n];
            end;
        end;
    end;
  fEvents.ReadFromStream (Stream);
  fQualificationPoints.ReadFromStream (Stream);
  SetLength (teams,0);
  if Data.fFileVersion>= 14 then
    fTeamsGroups.ReadFromStream (Stream);
{  if Data.fFileVersion< 28 then
    begin
      if Data.fFileVersion< 26 then
        begin
          fShootingChampionship:= Data.ShootingChampionships.Find (Info.Championship,Info.ChampionshipName,DateFrom);
          for i:= 0 to StartLists.Count-1 do
            if (StartLists [i]<> self) and (StartLists [i].ShootingChampionship= fShootingChampionship) then
              begin
                fShootingChampionship:= nil;
                break;
              end;
          if fShootingChampionship= nil then
            CreateShootingChampionship;
          for i:= 0 to Events.Count-1 do
            begin
              ev:= Events [i];
              ev.fShootingEvent:= fShootingChampionship.Events.Find (ev._ev,'',ev.DateTill);
              for j:= 0 to i-1 do
                if (Events [j].ShootingEvent= ev.ShootingEvent) then
                  begin
                    ev.fShootingEvent:= nil;
                    break;
                  end;
              if ev.fShootingEvent= nil then
                ev.CreateShootingEvent (ev._ev);
            end;
        end;
    end;}
  fChanged:= false;
  StartLists.fChanged:= true;
end;

function TStartList.RegionPoints(ARegionAbbr: string; AWeapon: TWeapons; AGender: TGenders): integer;
var
  i: integer;
  ev: TStartListEventItem;
begin
  Result:= 0;
  for i:= 0 to fEvents.Count-1 do
    begin
      ev:= fEvents.Items [i];
      if (ev.Event.WeaponType in AWeapon) and (ev.InPointsTable) then
        Result:= Result+ev.RegionPoints (ARegionAbbr,AGender);
    end;
end;

procedure TStartList.RemoveNotifier(h: HWND);
var
  i: integer;
begin
  for i:= 0 to Length (fNotifiers)-1 do
    begin
      if fNotifiers [i]= h then
        begin
          fNotifiers [i]:= fNotifiers [Length (fNotifiers)-1];
          SetLength (fNotifiers,Length (fNotifiers)-1);
          break;
        end;
    end;
end;

procedure TStartList.SavePointsTable(AFileName: string; AgeGroup: TAgeGroup;
  PointsFor: TPointsFor; TableType: TPointsTableType; ForGroups: boolean; const ATitle: string);
var
  doc: TPDFDocument;
begin
  doc:= TPDFDocument.Create (nil);
  doc.DefaultCharset:= PROTOCOL_CHARSET;
  doc.FileName:= AFileName;
  doc.AutoLaunch:= false;
  try
    PrintPointsTable (doc,AgeGroup,1,PointsFor,TableType,ForGroups,ATitle);
  finally
    doc.Free;
  end;
end;

procedure TStartList.SavePointsTableHTML(AFileName: string; AgeGroup: TAgeGroup; PointsFor: TPointsFor; TableType: TPointsTableType; ForGroups: boolean; const ATitle: string);
var
  men,women: string;
  ts,html: TStrings;
  i,j: integer;
  current_group: TStartListTeamsGroup;
  teams: array of TStartListTotalTeamStats;
  teamnames: TStrings;
  Table: TMyTableColumns;

  procedure CreateTable;
  var
    tc,tc1,tcw,tcm: TMyTableColumn;
    i: integer;
    ev: TStartListEventItem;
  begin
    Table:= TMyTableColumns.Create;

    tc:= Table.Add; // �����
    tc.Title:= '';

    tc:= Table.Add; // �������/������/�����
    case PointsFor of
      pfTeam: tc.Title:= TEAM_STR;
      pfRegion: tc.Title:= REGION_STR;
      pfDistrict: tc.Title:= DISTRICT_STR;
    end;

    case TableType of
      pttEventTypes: begin
        // ������� ��������
        tc:= Table.Add;
        tc.Title:= RIFLE_STR;
        tc1:= tc.Add;
        tc1.Title:= men;
        tc1:= tc.Add;
        tc1.Title:= women;
        // ������� ��������
        tc:= Table.Add;
        tc.Title:= PISTOL_STR;
        tc1:= tc.Add;
        tc1.Title:= men;
        tc1:= tc.Add;
        tc1.Title:= women;
        // ������� �����
        tc:= Table.Add;
        tc.Title:= MOVING_TARGET_STR;
        tc1:= tc.Add;
        tc1.Title:= men;
        tc1:= tc.Add;
        tc1.Title:= women;
        // ������� �����
        tc:= Table.Add;
        tc.Title:= TOTAL_POINTS;
      end;
      pttEvents: begin
        tcm:= Table.Add;
        tcm.Title:= men;
        tcw:= Table.Add;
        tcw.Title:= women;
        tc:= Table.Add;
        tc.Title:= TOTAL_POINTS;
        for i:= 0 to Events.Count-1 do
          begin
            ev:= Events [i];
            if not ev.InPointsTable then
              continue;
            case ev.Gender of
              Male: begin
                tc1:= tcm.Add;
                tc1.Title:= ev.Event.ShortName;
                tc1.Obj:= ev;
              end;
              Female: begin
                tc1:= tcw.Add;
                tc1.Title:= ev.Event.ShortName;
                tc1.Obj:= ev;
              end;
            end;
          end;
        tc1:= tcm.Add;
        tc1.Title:= SUM_STR;
        tc1:= tcw.Add;
        tc1.Title:= SUM_STR;
      end;
    end;
  end;

  procedure SaveTeamLineForTypes (team_idx: integer);
  var
    st: string;
  begin
    html.Add ('<tr>');
    html.Add ('<td align="right">'+IntToStr (team_idx+1)+'</td>');
    html.Add ('<td align="left">'+teams [team_idx].FullName+'</td>');
    st:= IntToStr (teams [team_idx].RifleMenPoints);
    html.Add ('<td>'+st+'</td>');
    st:= IntToStr (teams [team_idx].RifleWomenPoints);
    html.Add ('<td>'+st+'</td>');
    st:= IntToStr (teams [team_idx].PistolMenPoints);
    html.Add ('<td>'+st+'</td>');
    st:= IntToStr (teams [team_idx].PistolWomenPoints);
    html.Add ('<td>'+st+'</td>');
    st:= IntToStr (teams [team_idx].MovingMenPoints);
    html.Add ('<td>'+st+'</td>');
    st:= IntToStr (teams [team_idx].MovingWomenPoints);
    html.Add ('<td>'+st+'</td>');
    st:= IntToStr (teams [team_idx].TotalPoints);
    html.Add ('<td>'+st+'</td>');
  end;

  procedure SaveTeamLineForEvents (team_idx: integer);
  var
    st: string;
    tc,tc1: TMyTableColumn;
    p,i: integer;
    ev: TStartListEventItem;
  begin
    html.Add ('<tr>');
    html.Add ('<td align="right">'+IntToStr (team_idx+1)+'</td>');
    html.Add ('<td align="left">'+teams [team_idx].FullName+'</td>');
    // �������
    tc:= Table.Subs [2];
    for i:= 0 to tc.ColCount-1 do
      begin
        tc1:= tc.Subs [i];
        if tc1.Obj<> nil then
          begin
            ev:= tc1.Obj as TStartListEventItem;
            p:= teams [team_idx].EventPoints (ev);
            st:= IntToStr (p);
            html.Add ('<td>'+st+'</td>');
          end
        else
          begin
            st:= IntToStr (teams [team_idx].MenPoints);
            html.Add ('<td><b>'+st+'</b></td>');
          end;
      end;
    // �������
    tc:= Table.Subs [3];
    for i:= 0 to tc.ColCount-1 do
      begin
        tc1:= tc.Subs [i];
        if tc1.Obj<> nil then
          begin
            ev:= tc1.Obj as TStartListEventItem;
            p:= teams [team_idx].EventPoints (ev);
            st:= IntToStr (p);
            html.Add ('<td>'+st+'</td>');
          end
        else
          begin
            st:= IntToStr (teams [team_idx].WomenPoints);
            html.Add ('<td><b>'+st+'</b></td>');
          end;
      end;
    // ����� ������
//    tc:= Table.Subs [4];
    st:= IntToStr (teams [team_idx].TotalPoints);
    html.Add ('<td><b>'+st+'</b></td>');
  end;

  procedure SaveTeamLine (idx: integer);
  begin
    case TableType of
      pttEventTypes: SaveTeamLineForTypes (idx);
      pttEvents: SaveTeamLineForEvents (idx);
    end;
  end;

  procedure SaveTableForTeams;
  var
    i,j,idx: integer;
    ts: TStartListTotalTeamStats;
  begin
    // ��������� �������
    for i:= 0 to Length (teams)-2 do
      begin
        idx:= i;
        for j:= i+1 to Length (teams)-1 do
          if teams [j].CompareTo (teams [idx])= 1 then
            idx:= j;
        if idx<> i then
          begin
            ts:= teams [i];
            teams [i]:= teams [idx];
            teams [idx]:= ts;
          end;
      end;

    CreateTable;

    html.Add ('<table width="100%"  border=1 frame="border" cellspacing=0 cellpadding=2>');
    html.Add ('<thead align="center">');
    html.Add ('<tr>');
    for i:= 0 to Table.ColCount-1 do
      begin
        if Table.Subs [i].ColCount> 0 then
          html.Add ('<td colspan='+IntToStr (Table.Subs [i].ColCount)+'>'+Table.Subs [i].Title+'</td>')
        else
          html.Add ('<td rowspan=2>'+Table.Subs [i].Title+'</td>');
      end;
    html.Add ('</tr><tr>');
    for i:= 0 to Table.ColCount-1 do
      if Table.Subs [i].ColCount> 0 then
        begin
          for j:= 0 to Table.Subs [i].ColCount-1 do
            html.Add ('<td>'+Table.Subs [i].Subs [j].Title+'</td>');
        end;
    html.Add ('</tr></thead>');
    html.Add ('<tbody align="center">');

    for i:= 0 to Length (teams)-1 do
      SaveTeamLine (i);

    html.Add ('</tbody></table>');

    Table.Free;
    for i:= 0 to Length (teams)-1 do
      teams [i].Free;
    SetLength (teams,0);
    teams:= nil;
  end;

begin
  html:= TStringList.Create;
  ts:= TStringList.Create;

  try
    html.Add ('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN">');
    html.Add ('<html lang="en">');
    html.Add ('<head>');
    html.Add ('<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">');
    html.Add ('</head>');
    html.Add ('<body>');

    case AgeGroup of
      agYouths: begin
        men:= YOUTHS_MEN;
        women:= YOUTHS_WOMEN;
      end;
      agJuniors: begin
        men:= JUNIORS_MEN;
        women:= JUNIORS_WOMEN;
      end;
      agAdults: begin
        men:= ADULTS_MEN;
        women:= ADULTS_WOMEN;
      end;
    end;

    html.Add ('<center><b>');
    ts.Text:= Info.TitleText;
    for i:= 0 to ts.Count-1 do
      ts [i]:= ts [i]+'<br>';
    html.AddStrings (ts);
    ts.Clear;
    ts.Text:= ATitle;
    for i:= 0 to ts.Count-1 do
      ts [i]:= ts [i]+'<br>';
    html.AddStrings (ts);
    ts.Clear;
    html.Add ('</b></center><p>');

    if (ForGroups) and (fTeamsGroups.Count> 0) and (PointsFor= pfTeam) then
      begin
        for i:= 0 to fTeamsGroups.Count-1 do
          begin
            current_group:= fTeamsGroups [i];
            teamnames:= GetTeams (true,current_group);
            if teamnames.Count> 0 then
              begin
                SetLength (teams,teamnames.Count);
                for j:= 0 to teamnames.Count-1 do
                  teams [j]:= TStartListTotalTeamStats.Create (Self,teamnames [j],PointsFor);
                SaveTableForTeams;
              end;
            teamnames.Free;
          end;
      end
    else
      begin
  //      current_group:= nil;
        case PointsFor of
          pfTeam: teamnames:= GetTeams (true,nil);
          pfRegion: teamnames:= GetRegions (true);
          pfDistrict: teamnames:= GetDistricts;
        else
          exit;
        end;
        SetLength (teams,teamnames.Count);
        for i:= 0 to teamnames.Count-1 do
          teams [i]:= TStartListTotalTeamStats.Create (Self,teamnames [i],PointsFor);
        teamnames.Free;
        SaveTableForTeams;
      end;

    // ������� �����
    if Info.Jury+Info.JuryCategory<> '' then
      begin
        html.Add ('<p>'+JURY_TITLE+'<br>');
        html.Add (Info.JuryCategory+' '+Info.Jury);
      end;
    // ���������
    if Info.Secretery+Info.SecreteryCategory<> '' then
      begin
        html.Add ('<p>'+SECRETERY_TITLE+'<br>');
        html.Add (Info.SecreteryCategory+' '+Info.Secretery);
      end;

    html.Add ('</body></html>');
    html.SaveToFile (AFileName);
  finally
    ts.Free;
    html.Free;
  end;
end;

procedure TStartList.set_ShootersPerTeam(const Value: integer);
begin
  if Value<> fShootersPerTeam then
    begin
      fShootersPerTeam:= Value;
      fChanged:= true;
    end;
end;

procedure TStartList.set_StartNumbers(const Value: boolean);
begin
  fInfo.set_StartNumbers (Value);
end;

function TStartList.StartLists: TStartLists;
begin
  Result:= Collection as TStartLists;
end;

function TStartList.TeamPoints(ATeam: string; AWeapon: TWeapons; AGender: TGenders): integer;
var
  i: integer;
  ev: TStartListEventItem;
begin
  Result:= 0;
  for i:= 0 to fEvents.Count-1 do
    begin
      ev:= fEvents.Items [i];
      if (ev.Event.WeaponType in AWeapon) and (ev.InPointsTable) then
        Result:= Result+ev.TeamPoints (ATeam,AGender);
    end;
end;

procedure TStartList.WriteToStream(Stream: TStream);
var
  iEvent, iShooter: Integer;
  evItem: TStartListEventItem;
  es: TStartListEventShooterItem;
//var
//  idx: integer;
begin
  // ������������: ����� ������������� ������� ������� ������ �� ��������,
  // ������� ����� ���� ������� ����� (��������, ������/���������� �������)
  // ��� ������������� Access Violation ��� ����������
  try
    // ������� �� ������� ���� EventShooter, � ������� ��� ���������������
    // StartListShooter ��� � �������� ��������� Shooter = nil
    for iEvent := fEvents.Count - 1 downto 0 do
    begin
      evItem := fEvents.Items[iEvent];
      for iShooter := evItem.Shooters.Count - 1 downto 0 do
      begin
        es := evItem.Shooters.Items[iShooter];
        if (es = nil) then
        begin
          evItem.Shooters.Delete(iShooter);
          Continue;
        end;
        // ���� � EventShooter ��� StartListShooter ��� ��������� Shooter = nil � �������
        if (es.StartListShooter = nil) or (es.StartListShooter.Shooter = nil) then
        begin
          es.Free;
          Continue;
        end;
        // �������������� ��������: ���� Shooter.Data <> ��� Data (���������� ������)
        try
          if not Assigned(es.StartListShooter.Shooter) or (es.StartListShooter.Shooter.Data <> Self.Data) then
          begin
            es.Free;
            Continue;
          end;
        except
          // �� ������ ������ � ���� ������ �������� ����������, ������� ������
          es.Free;
          Continue;
        end;
      end;
    end;
  except
    // ����� ������ ��� ������� ���������� � �� �� ����� ���������� �������� ����������
  end;
  Stream.Write (fID,sizeof (fID));
  fInfo.WriteToStream (Stream);
//  idx:= fShootingChampionship.Index;
//  Stream.Write (idx,sizeof (idx));
  Stream.Write (fShootersPerTeam,sizeof (fShootersPerTeam));
  fShooters.WriteToStream (Stream);
  fEvents.WriteToStream (Stream);
  fQualificationPoints.WriteToStream (Stream);
  fTeamsGroups.WriteToStream (Stream);
  fChanged:= false;
end;

function TStartList.DateFrom: TDateTime;
var
  i: integer;
  d: TDateTime;
  ev: TStartListEventItem;
begin
  Result:= 0;
  for i:= 0 to fEvents.Count-1 do
    begin
      ev:= fEvents.Items [i];
      if ev.Relays.Count> 0 then
        d:= ev.DateFrom
      else
        d:= 0;
      if (d> 0) and ((d< Result) or (Result= 0)) then
        Result:= d;
    end;
  if Result= 0 then
    Result:= Now;
end;

function TStartList.DateTill: TDateTime;
var
  i: integer;
  d: TDateTime;
  ev: TStartListEventItem;
begin
  Result:= 0;
  for i:= 0 to fEvents.Count-1 do
    begin
      ev:= fEvents.Items [i];
      if ev.Relays.Count> 0 then
        d:= ev.DateTill
      else
        d:= 0;
      if (d> 0) and (d> Result) then
        Result:= d;
    end;
  if Result= 0 then
    Result:= Now;
end;

procedure TStartList.AddNotifier(h: HWND);
var
  i: integer;
begin
  for i:= 0 to Length (fNotifiers)-1 do
    if fNotifiers [i]= h then
      exit;
  i:= Length (fNotifiers);
  SetLength (fNotifiers,i+1);
  fNotifiers [i]:= h;
end;

procedure TStartList.Assign(Source: TPersistent);
var
  AStart: TStartList;
begin
  if Source is TStartList then
    begin
      AStart:= Source as TStartList;
      fId:= AStart.ID;
      fShootersPerTeam:= AStart.fShootersPerTeam;
      fInfo.Assign (AStart.Info);
{      if Data= AStart.Data then
        begin
          fShootingChampionship:= AStart.ShootingChampionship;
        end
      else
        begin
          CreateShootingChampionship;
        end;}
      fShooters.Assign (AStart.Shooters);
      fEvents.Assign (AStart.Events);
      fQualificationPoints.Assign (AStart.QualificationPoints);
      fChanged:= true;
    end
  else
    inherited;
end;

{ TStartNumbersPrintout }

procedure TStartNumbersPrintout.AddShooter(AShooter: TStartListShooterItem);
begin
  if PrintTwoStartNumbersOnPage then
    begin
      if fShooter1= nil then
        fShooter1:= AShooter
      else
        begin
          fShooter2:= AShooter;
          PrintOut1;
          fShooter1:= nil;
          fShooter2:= nil;
        end;
      AShooter.StartList.Notify (WM_STARTNUMBERSPRINTOUT,0,0);
    end
  else
    begin
      fShooter1:= AShooter;
      PrintOut2;
      fShooter1:= nil;
    end;
end;

procedure TStartNumbersPrintout.CancelJob;
begin
  Printer.Abort;
  fJobIndex:= 0;
  fPageIndex:= 0;
end;

procedure TStartNumbersPrintout.Clear;
begin
  if fShooter1<> nil then
    fShooter1.StartList.Notify (WM_STARTNUMBERSPRINTOUT,0,0)
  else if fShooter2<> nil then
    fShooter2.StartList.Notify (WM_STARTNUMBERSPRINTOUT,0,0);
  fShooter1:= nil;
  fShooter2:= nil;
  if fJobIndex> 0 then
    CancelJob;
  fPageIndex:= 0;
end;

constructor TStartNumbersPrintout.Create;
begin
  fJobIndex:= 0;
  fPageIndex:= 0;
  Clear;
end;

procedure TStartNumbersPrintout.FinishJob;
begin
  if fJobIndex> 0 then
    dec (fJobIndex);
  if fJobIndex= 0 then
    begin
      Printer.EndDoc;
      fPageIndex:= 0;
    end
  else
    begin
      inc (fPageIndex);
    end;
end;

function TStartNumbersPrintout.IsPending: boolean;
begin
  Result:= (fShooter1<> nil) or (fShooter2<> nil);
end;

procedure TStartNumbersPrintout.PrintOut;
begin
  if PrintTwoStartNumbersOnPage then
    PrintOut1
  else
    PrintOut2;
end;

procedure TStartNumbersPrintout.PrintOut1;
var
  cx: integer;
  kx,ky: integer;
  top_border,bottom_border,left_border,right_border: integer;
  y,y1,y2,y4: integer;

  function MM2X (mm: double): integer;
  begin
    Result:= round (mm/25.4*kx);
  end;

  function MM2Y (mm: double): integer;
  begin
    Result:= round (mm/25.4*ky);
  end;

  procedure PrintShooter (AShooter: TStartListShooterItem; Side: byte);
  var
    xleft,xright: integer;
    s1,s2: string;
    x1: integer;
    lpx,lpy: integer;
    s: TStrings;
    i: integer;
    mw,w: integer;
    y3: integer;

    function mm2px (mm: single): integer;
    begin
      Result:= round (mm*lpy/25.4);
    end;

    function mm2py (mm: single): integer;
    begin
      Result:= round (mm*lpx/25.4);
    end;

  begin
    case Side of
      0: begin
        xleft:= left_border;
        xright:= cx-mm2x (10);
      end;
    else
      xleft:= cx+mm2x (10);
      xright:= right_border;
    end;

    lpx:= GetDeviceCaps (Printer.Canvas.Handle,LOGPIXELSX);
    lpy:= GetDeviceCaps (Printer.Canvas.Handle,LOGPIXELSY);

    with Printer.Canvas do
      begin
        Font.Name:= START_NUMBERS_FONT_NAME;
        Font.Charset:= PROTOCOL_CHARSET;

        Pen.Style:= psSolid;
        Pen.Width:= 1;
        Rectangle (xleft,top_border,xright,bottom_border);

        x1:= (xleft+xright) div 2;  // �������� �������
        y:= top_border+mm2py (5);

        (*
          TEXT
          {
            FontHeight =
            FontStyle =
            Align =
            Left =
            Top =
            Right =
            Bottom =
            Width =
            Height =
            Text =
          }
        *)

        // ���������� ���� ������
        Font.Style:= [];
        Font.Height:= (y1-top_border) div 4;
        s1:= RUSSIAN_SHOOTING_UNION;
        while TextWidth (s1)> (xright-xleft-1-mm2px (10)) do
          Font.Height:= abs (Font.Height)-1;
        TextOut (x1-TextWidth (s1) div 2,y,s1);
        inc (y,TextHeight (s1)+mm2py (5));

        // �������� ������������
        Font.Style:= [fsBold];
        Font.Height:= (y1-top_border) div 4;
        s:= TStringList.Create;
        s.Text:= AShooter.StartList.Info.TitleText;
        repeat
          mw:= 0;
          for i:= 0 to s.Count-1 do
            begin
              w:= TextWidth (s [i]);
              if w> mw then
                mw:= w;
            end;
          if mw<= xright-xleft-1-mm2px (10) then
            break;
          Font.Height:= abs (Font.Height)-1;
        until false;
        for i:= 0 to s.Count-1 do
          begin
            TextOut (x1-TextWidth (s [i]) div 2,y,s [i]);
            inc (y,TextHeight (s [i]));
          end;
        s.Free;
        inc (y,mm2py (5));
        y1:= y;
        MoveTo (xleft,y1);
        LineTo (xright,y1);

        // �������, ����
        Font.Height:= (bottom_border-y4) div 2;
        Font.Style:= [fsBold];
        s1:= AShooter.Shooter.RegionsAbbr;
{        if TruncatePrintedClubs then
          s2:= SubStr (AShooter.Shooter.Society,' ',1)
        else
          s2:= AShooter.Shooter.Society;}
        s2:= AShooter.Shooter.SocietyName;
        while TextWidth (s1)+TextWidth (s2)+mm2px (15)>= xright-xleft do
          Font.Height:= abs (Font.Height)-1;
        TextOut (xleft+mm2px (5),bottom_border-TextHeight (s1)-mm2py (5),s1);
        TextOut (xright-mm2px (5)-TextWidth (s2),bottom_border-TextHeight (s1)-mm2py (5),s2);
        y4:= bottom_border-TextHeight ('Mg')-mm2py (10);
        MoveTo (xleft,y4);
        LineTo (xright,y4);

        // ������� ���
        y:= y4-mm2py (10);
        if AShooter.Shooter.Name<> '' then
          begin
            Font.Style:= [fsItalic];
            Font.Height:= (y4-y2) div 4;
            s1:= AShooter.Shooter.Name;
            while TextWidth (s1)+mm2px (10)>= xright-xleft do
              Font.Height:= abs (Font.Height-1);
            TextOut (x1-TextWidth (s1) div 2,y-TextHeight (s1),s1);
            dec (y,TextHeight (s1)+mm2py (5));
          end;
        Font.Style:= [fsBold];
        Font.Height:= (y4-y2) div 4;
        s1:= AnsiUpperCase (AShooter.Shooter.Surname);
        while TextWidth (s1)+mm2px (10)>= xright-xleft do
          Font.Height:= abs (Font.Height-1);
        TextOut (x1-TextWidth (s1) div 2,y-TextHeight (s1),s1);
        dec (y,TextHeight (s1)+mm2py (10));
        y3:= y;
        MoveTo (xleft,y3);
        LineTo (xright,y3);

        // ��������� �����
        Font.Style:= [fsBold];
        Font.Height:= y3-y1-mm2py (20);
        s1:= AShooter.StartNumberStr;
        while TextWidth (s1)> (xright-xleft-mm2px (40)) do
          Font.Height:= abs (Font.Height-1);
        TextOut (x1-TextWidth (s1) div 2,(y1+y3-TextHeight (s1)) div 2,s1);
      end;
    AShooter.StartNumberPrinted:= true;
  end;

begin
  if not IsPending then
    exit;

  StartJob;

  if fPageIndex> 1 then
    Printer.NewPage;

  kx:= GetDeviceCaps (Printer.Handle,LOGPIXELSX);
  ky:= GetDeviceCaps (Printer.Handle,LOGPIXELSY);

  cx:= Printer.PageWidth div 2;
  top_border:= mm2y (10);
  bottom_border:= Printer.PageHeight - mm2y (10);
  left_border:= mm2x (10);
  right_border:= Printer.PageWidth - mm2x (10);

  y1:= top_border+mm2y (35);
  y2:= bottom_border-mm2y (70);
  y4:= bottom_border-mm2y (20);

  with Printer.Canvas do
    begin
      // ���������� ����� ���������� ��� �������
      Pen.Style:= psDot;
      Pen.Width:= 1;
      Pen.Color:= clBlack;
      Brush.Style:= bsClear;
      MoveTo (cx,1);
      LineTo (cx,Printer.PageHeight-1);
    end;

  With Printer.Canvas do
    begin
      if fShooter1<> nil then
        PrintShooter (fShooter1,0);
      if fShooter2<> nil then
        PrintShooter (fShooter2,1);
    end;

  FinishJob;
end;

procedure TStartNumbersPrintout.PrintOut2;
var
  kx,ky: integer;

  function MM2X (mm: double): integer;
  begin
    Result:= round (mm/25.4*kx);
  end;

  function MM2Y (mm: double): integer;
  begin
    Result:= round (mm/25.4*ky);
  end;

  procedure Fit (x1,y1,x2,y2: single; const s: string; style: TFontStyles);
  var
    r: TRect;
    cx,cy: integer;
    h: integer;
  begin
    with Printer.Canvas do
      begin
        Font.Name:= START_NUMBERS_FONT_NAME;
        Font.Charset:= PROTOCOL_CHARSET;
        Font.Style:= style;
        r.Left:= MM2X (x1);
        r.Top:= MM2Y (y1);
        r.Right:= MM2X (x2);
        r.Bottom:= MM2Y (y2);
        cx:= (r.Right+r.Left) div 2;
        cy:= (r.Bottom+r.Top) div 2;
        h:= -(r.Bottom-r.Top);
        Font.Height:= h;
        while TextWidth (s)> r.Right-r.Left do
          begin
            inc (h);
            Font.Height:= h;
          end;
        TextOut (cx-TextWidth (s) div 2,cy-TextHeight (s) div 2,s);
      end;
  end;

var
  st: string;
begin
  if fShooter1= nil then
    exit;

  StartJob;

  if fPageIndex> 1 then
    Printer.NewPage;

  kx:= GetDeviceCaps (Printer.Handle,LOGPIXELSX);
  ky:= GetDeviceCaps (Printer.Handle,LOGPIXELSY);

  with Printer.Canvas do
    begin
      st:= fShooter1.Shooter.RegionAbbr1;
      Fit (55,75,240,95,st,[fsBold]);
      st:= fShooter1.Shooter.Name+' '+fShooter1.Shooter.Surname;
      Fit (55,95,240,125,st,[fsBold]);
      st:= fShooter1.StartNumberStr;
      Fit (55,125,240,165,st,[fsBold]);
    end;

  FinishJob;
end;

procedure TStartNumbersPrintout.StartJob;
begin
  if fJobIndex= 0 then
    begin
      Printer.Orientation:= poLandscape;
      Printer.Title:= START_NUMBERS_PRINT_TITLE;
      Printer.Copies:= 1;
      Printer.BeginDoc;
      fPageIndex:= 1;
    end;
  inc (fJobIndex);
end;

{ TStartListPoints }

procedure TStartListPoints.Assign(APoints: TStartListPoints);
begin
  SetLength (fPoints,Length (APoints.fPoints));
  move (APoints.fPoints [0],fPoints [0],Length (APoints.fPoints)*sizeof (integer));
  fChanged:= true;
end;

procedure TStartListPoints.Clear;
begin
  SetLength (fPoints,0);
end;

function TStartListPoints.Count: integer;
begin
  Result:= Length (fPoints);
end;

constructor TStartListPoints.Create;
begin
  inherited;
  SetLength (fPoints,0);
  fChanged:= false;
end;

procedure TStartListPoints.Delete(index: integer);
var
  i: integer;
begin
  if (index>= 0) and (index< Count) then
    begin
      for i:= index to Count-2 do
        fPoints [i]:= fPoints [i+1];
      SetLength (fPoints,Count-1);
      fChanged:= true;
    end;
end;

destructor TStartListPoints.Destroy;
begin
  SetLength (fPoints,0);
  fPoints:= nil;
  inherited;
end;

function TStartListPoints.get_Points(Index: integer): integer;
begin
  if (Index>= 0) and (Index< Length (fPoints)) then
    Result:= fPoints [Index]
  else
    Result:= 0;
end;

procedure TStartListPoints.Insert(index, Points: integer);
var
  i: integer;
begin
  SetLength (fPoints,Count+1);
  for i:= Count-2 downto index do
    fPoints [i+1]:= fPoints [i];
  fPoints [index]:= Points;
  fChanged:= true;
end;

procedure TStartListPoints.LoadFromFile(AFileName: string);
var
  s: TFileStream;
  h: TPointsFileHeader;
  c: integer;
begin
  s:= TFileStream.Create (AFileName,fmOpenRead);
  try
    s.Read (h,sizeof (h));
    if (h.TextId= POINTS_FILE_TEXT_ID) and (IsEqualGUID (h.ID,START_LIST_FILE_ID)) then
      begin
        s.Read (c,sizeof (c));
        SetLength (fPoints,c);
        s.Read (fPoints [0],c*sizeof (integer));
        fChanged:= true;
      end;
    s.Free;
  except
    s.Free;
    raise;
  end;
end;

procedure TStartListPoints.SaveToFile(AFileName: string);
var
  s: TFileStream;
  h: TPointsFileHeader;
  c: integer;
begin
  s:= TFileStream.Create (AFileName,fmCreate);
  try
    h.TextId:= POINTS_FILE_TEXT_ID;
    h.ID:= START_LIST_FILE_ID;
    h.Version:= 1;
    s.Write (h,sizeof (h));
    c:= Length (fPoints);
    s.Write (c,sizeof (c));
    s.Write (fPoints [0],c*sizeof (integer));
    s.Free;
  except
    s.Free;
    raise;
  end;
end;

procedure TStartListPoints.set_Points(Index: integer; const Value: integer);
begin
  if index>= Count then
    begin
      SetLength (fPoints,Length (fPoints)+1);
      if Value<> fPoints [Count-1] then
        begin
          fPoints [Count-1]:= Value;
          fChanged:= true;
        end;
    end
  else
    begin
      if Value<> fPoints [Index] then
        begin
          fPoints [Index]:= Value;
          fChanged:= true;
        end;
    end;
end;

procedure TStartListPoints.ReadFromStream(Stream: TStream);
var
  c: integer;
begin
  Stream.Read (c,sizeof (c));
  SetLength (fPoints,c);
  Stream.Read (fPoints [0],c*sizeof (integer));
  fChanged:= false;
end;

procedure TStartListPoints.WriteToStream(Stream: TStream);
var
  c: integer;
begin
  c:= Length (fPoints);
  Stream.Write (c,sizeof (c));
  Stream.Write (fPoints [0],c*sizeof (integer));
  fChanged:= false;
end;

{ TStartListShooters }

function TStartListShooters.Add: TStartListShooterItem;
begin
  Result:= inherited Add as TStartListShooterItem;
end;

procedure TStartListShooters.Assign(Source: TPersistent);
var
  i: integer;
  ssh: TStartListShooterItem;
begin
  if Source is TStartListShooters then
    begin
      Clear;
      for i:= 0 to (Source as TStartListShooters).Count-1 do
        begin
          ssh:= Add;
          ssh.Assign ((Source as TStartListShooters).Items [i]);
        end;
    end
  else
    inherited;
end;

constructor TStartListShooters.Create(AStartList: TStartList);
begin
  inherited Create (TStartListShooterItem);
  fStartList:= AStartList;
  fChanged:= false;
  fStartNumberDigits:= 3;
end;

procedure TStartListShooters.Delete(AShooter: TStartListShooterItem);
var
  i: integer;
  esh: TStartListEventShooterItem;
begin
  for i:= 0 to StartList.Events.Count-1 do
    begin
      esh:= StartList.Events [i].Shooters.FindShooter (AShooter.Shooter);
      if esh<> nil then
        esh.Free;
    end;
  AShooter.Free;
end;

function TStartListShooters.FindShooter(AStartNumber: integer): TStartListShooterItem;
var
  i: integer;
  sh: TStartListShooterItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.StartNumber= AStartNumber then
        begin
          Result:= sh;
          break;
        end;
    end;
end;

procedure TStartListShooters.GetRegionsStats(var RS: TRegionsStats);

  function Find (const R: String): integer;
  var
    i: integer;
  begin
    Result:= -1;
    for i:= 0 to Length (RS)-1 do
      if AnsiSameText (RS [i].Region,R) then
        begin
          Result:= i;
          break;
        end;
  end;

var
  i,idx: integer;
  sh: TStartListShooterItem;
begin
  if RS<> nil then
    DeleteRegionsStats (RS);
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.Shooter.RegionAbbr1<> '' then
        begin
          idx:= Find (sh.Shooter.RegionAbbr1);
          if idx= -1 then
            begin
              idx:= Length (RS);
              SetLength (RS,idx+1);
              RS [idx].Region:= sh.Shooter.RegionAbbr1;
              RS [idx].Count:= 1;
            end
          else
            inc (RS [idx].Count);
        end;
    end;
end;

function TStartListShooters.FindShooter(AShooter: TShooterItem): TStartListShooterItem;
var
  j: integer;
begin
  Result:= nil;
  for j:= 0 to Count-1 do
    if Items [j].fShooter= AShooter then
      begin
        Result:= Items [j];
        break;
      end;
end;

function TStartListShooters.get_Shooter(
  Index: integer): TStartListShooterItem;
begin
  Result:= inherited Items [Index] as TStartListShooterItem;
end;

function TStartListShooters.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

{procedure TStartListShooters.ImportFromStream(Stream: TStream);
var
  c,j: integer;
  s: TStartListShooterItem;
begin
  Stream.Read (c,sizeof (c));
  Clear;
  for j:= 0 to c-1 do
    begin
      s:= Add;
      s.ImportFromStream (Stream);
    end;
  fChanged:= true;
end;}

function TStartListShooters.NextAvailableStartNumber: integer;
var
  i: integer;
  sh: TStartListShooterItem;
begin
  Result:= Count+1;
// ���� ������� ������ ��������� �����
  for i:= 1 to Count do
    begin
      sh:= FindShooter (i);
      if sh= nil then
        begin
          Result:= i;
          break;
        end;
    end;
end;

function TStartListShooters.NumberOf(AQualification: TQualificationItem): integer;
var
  i: integer;
  sh: TStartListShooterItem;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.Shooter.Qualification= AQualification then
        inc (Result);
    end;
end;

function TStartListShooters.NumberOf(AGender: TGender): integer;
var
  i: integer;
  sh: TStartListShooterItem;
begin
  Result:= 0;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.Shooter.Gender= AGender then
        inc (Result);
    end;
end;

procedure TStartListShooters.ReadFromStream(Stream: TStream);
var
  c,j: integer;
  s: TStartListShooterItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for j:= 0 to c-1 do
    begin
      s:= Add;
      s.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TStartListShooters.Sort(Order: TStartShootersSortOrder);
var
  i,j: integer;
  sh: TStartListShooterItem;
begin
  for i:= 0 to Count-2 do
    begin
      sh:= Items [i];
      for j:= i+1 to Count-1 do
        if Items [j].CompareTo (sh,Order)< 0 then
          sh:= Items [j];
      sh.Index:= i;
    end;
end;

procedure TStartListShooters.UpdateStartNumberDigits;
var
  m,i: integer;
  sh: TStartListShooterItem;
begin
  // ���� ����� ������� ����� � ������� ��� �����
  m:= 0;
  for i:= 0 to Count-1 do
    begin
      sh:= Items [i];
      if sh.StartNumber> m then
        m:= sh.StartNumber;
    end;
  if m>= 10000 then
    fStartNumberDigits:= 5
  else if m>= 1000 then
    fStartNumberDigits:= 4
  else
    fStartNumberDigits:= 3;
end;

procedure TStartListShooters.WriteToStream(Stream: TStream);
var
  c,j: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for j:= 0 to c-1 do
    Items [j].WriteToStream (Stream);
  fChanged:= false;
end;

{ TStartListShooterItem }

procedure TStartListShooterItem.Assign(Source: TPersistent);
var
  AShooter: TStartListShooterItem;
  g: TGroupItem;
begin
  if Source is TStartListShooterItem then
    begin
      AShooter:= Source as TStartListShooterItem;
      fStartNumber:= AShooter.StartNumber;
      fOldTeam:= AShooter.fOldTeam;
      fShooter:= StartList.Data.Groups.FindShooter (AShooter.Shooter.fId);
      if fShooter= nil then
        fShooter:= StartList.Data.Groups.FindShooterByDetails (AShooter.Shooter.Surname,
                            AShooter.Shooter.Name,AShooter.Shooter.BirthYearStr);
      if fShooter= nil then
        begin
          g:= StartList.Data.Groups.FindByName (AShooter.Shooter.Group.Name);
          if g= nil then
            begin
              g:= StartList.Data.Groups.Add;
              g.Name:= Format (START_SHOOTERS_GROUP_NAME,[AShooter.StartList.Info.CaptionText]);
            end;
          fShooter:= g.Shooters.Add;
          fShooter.Assign (AShooter.Shooter);
        end;
      fStartNumberPrinted:= AShooter.StartNumberPrinted;
      fChanged:= true;
      Shooters.UpdateStartNumberDigits;
    end
  else
    inherited;
end;

function TStartListShooterItem.CompareTo(AShooter: TStartListShooterItem;
  AOrder: TStartShootersSortOrder): integer;
begin
  case AOrder of
    slsoStartNumber: Result:= Sign (StartNumber-AShooter.StartNumber);
    slsoSurname: Result:= -Shooter.CompareTo (AShooter.Shooter,ssoSurname);
    slsoGroup: begin
      Result:= Sign (Shooter.Group.Index-AShooter.Shooter.Group.Index);
      if Result= 0 then
        Result:= CompareTo (AShooter,slsoSurname);
    end;
    slsoDistrict: Result:= -Shooter.CompareTo (AShooter.Shooter,ssoDistrict);
    slsoRegion: Result:= -Shooter.CompareTo (AShooter.Shooter,ssoRegion);
    slsoSociety: Result:= -Shooter.CompareTo (AShooter.Shooter,ssoSociety);
    slsoQualification: Result:= -Shooter.CompareTo (AShooter.Shooter,ssoQualification);
    slsoBirthDate: begin
      // ���������� �� ������ ���� �������� (���, �����, ����). ����������� �������� � �����.
      var y1,y2,m1,m2,d1,d2: integer;
      y1:= Shooter.BirthYear; if y1= 0 then y1:= High (Word);
      y2:= AShooter.Shooter.BirthYear; if y2= 0 then y2:= High (Word);
      Result:= Sign (y1-y2);
      if Result= 0 then
        begin
          m1:= Shooter.fBirthMonth; if m1= 0 then m1:= 99;
          m2:= AShooter.Shooter.fBirthMonth; if m2= 0 then m2:= 99;
          Result:= Sign (m1-m2);
          if Result= 0 then
            begin
              d1:= Shooter.fBirthDay; if d1= 0 then d1:= 99;
              d2:= AShooter.Shooter.fBirthDay; if d2= 0 then d2:= 99;
              Result:= Sign (d1-d2);
            end;
        end;
    end;
  else
    Result:= 0;
  end;
end;

constructor TStartListShooterItem.Create(ACollection: TCollection);
begin
  inherited;
  fStartNumber:= 0;
  fOldTeam:= '';
  fShooter:= nil;
  fStartNumberPrinted:= false;
  fChanged:= false;
  Shooters.fChanged:= true;
end;

destructor TStartListShooterItem.Destroy;
begin
  Shooters.fChanged:= true;
  inherited;
end;

function TStartListShooterItem.EventsCount: integer;
var
  j: integer;
begin
  Result:= 0;
  for j:= 0 to StartList.Events.Count-1 do
    if StartList.Events [j].Shooters.FindShooter (fShooter)<> nil then
      inc (Result);
end;

function TStartListShooterItem.EventsNames: string;
var
  j: integer;
begin
  Result:= '';
  for j:= 0 to StartList.Events.Count-1 do
    if StartList.Events [j].Shooters.FindShooter (fShooter)<> nil then
      begin
        if Result<> '' then
          Result:= Result+', ';
        Result:= Result+StartList.Events [j].Event.ShortName;
      end;
end;

{procedure TStartListShooterItem.ImportFromStream(Stream: TStream);
var
  id: TGUID;
  idx: integer;
  g: TGroupItem;
  gn: string;
begin
  Stream.Read (fStartNumber,sizeof (fStartNumber));
  Stream.Read (fStartNumberPrinted,sizeof (fStartNumberPrinted));
  if StartList.Data.fFileVersion<= 10 then
    begin
      if StartList.Data.fFileVersion<= 9 then
        begin
          Stream.Read (idx,sizeof (idx));
          if idx>= 0 then
            fOldTeam:= IntToStr (idx)
          else
            fOldTeam:= '';
        end
      else
        begin
          ReadStrFromStream (Stream,fOldTeam);
        end;
    end
  else
    fOldTeam:= '';
  Stream.Read (id,sizeof (id));
  fShooter:= StartList.Data.Groups.FindShooter (id);
  if fShooter= nil then
    begin
      // ���� ������� �� ������, ��������� ������, � ��� ��������� "����������"
      gn:= Format (START_SHOOTERS_GROUP_NAME,[StartList.Info.CaptionText]);
      g:= StartList.Data.Groups.FindByName (gn);
      if g= nil then
        begin
          g:= StartList.Data.Groups.Add;
          g.Name:= gn;
        end;
      fShooter:= g.Shooters.Add;
      fShooter.Surname:= SHOOTER_UNKNOWN;
      fShooter.Name:= IntToStr (fShooter.Index+1);
    end;
  fChanged:= true;
end;}

procedure TStartListShooterItem.ReadFromStream(Stream: TStream);
var
  id: TGUID;
  idx: integer;
begin
  Stream.Read (fStartNumber,sizeof (fStartNumber));
  Stream.Read (fStartNumberPrinted,sizeof (fStartNumberPrinted));
  if StartList.Data.fFileVersion<= 10 then
    begin
      if StartList.Data.fFileVersion<= 9 then
        begin
          Stream.Read (idx,sizeof (idx));
          if idx>= 0 then
            fOldTeam:= IntToStr (idx)
          else
            fOldTeam:= '';
        end
      else
        begin
          ReadStrFromStreamA (Stream,fOldTeam);
        end;
    end;
  Stream.Read (id,sizeof (id));
  fShooter:= StartList.Data.Groups.FindShooter (id);
  if fShooter= nil then
    begin
      // ��� �������� ������ ����������, ������ ���� �� ������
      raise Exception.Create ('�� ����� ������� � ����!');
    end;
  Shooters.UpdateStartNumberDigits;
  fChanged:= false;
end;

procedure TStartListShooterItem.set_Shooter(const Value: TShooterItem);
begin
  if Value<> fShooter then
    begin
      fShooter:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListShooterItem.set_StartNumber(const Value: integer);
begin
  if Value<> fStartNumber then
    begin
      fStartNumber:= Value;
      fChanged:= true;
      Shooters.UpdateStartNumberDigits;
    end;
end;

procedure TStartListShooterItem.set_StartNumberPrinted(
  const Value: boolean);
begin
  if Value<> fStartNumberPrinted then
    begin
      fStartNumberPrinted:= Value;
      fChanged:= true;
    end;
end;

{procedure TStartListShooterItem.set_Team(const Value: string);
begin
  if Value<> fTeam then
    begin
      fTeam:= Value;
      fChanged:= true;
    end;
end;}

function TStartListShooterItem.Shooters: TStartListShooters;
begin
  Result:= Collection as TStartListShooters;
end;

function TStartListShooterItem.StartList: TStartList;
begin
  Result:= (Collection as TStartListShooters).fStartList;
end;

function TStartListShooterItem.StartNumberStr: string;
var
  digits: integer;
begin
  digits:= Shooters.StartNumberDigits;
  Result:= LeftFillStr (IntToStr (fStartNumber),digits,'0');
end;

procedure TStartListShooterItem.WriteToStream(Stream: TStream);
var
  id: TGUID;
begin
  Stream.Write (fStartNumber,sizeof (fStartNumber));
  Stream.Write (fStartNumberPrinted,sizeof (fStartNumberPrinted));
//  SaveStrToStream (Stream,fTeam);
  id:= fShooter.PID;
  Stream.Write (id,sizeof (id));
  fChanged:= false;
end;

{ TStartListQualificationPoints }

procedure TStartListQualificationPoints.Assign(
  Source: TStartListQualificationPoints);
var
  i: integer;
begin
  SetLength (fPoints,Length (Source.fPoints));
  for i:= 0 to Length (Source.fPoints)-1 do
    fPoints [i]:= Source.fPoints [i];
  fChanged:= true;
end;

procedure TStartListQualificationPoints.Clear;
begin
  SetLength (fPoints,0);
  fChanged:= true;
end;

function TStartListQualificationPoints.Count: integer;
begin
  Result:= Length (fPoints);
end;

constructor TStartListQualificationPoints.Create(AStart: TStartList);
begin
  inherited Create;
  fStart:= AStart;
  SetLength (fPoints,0);
  fChanged:= false;
end;

destructor TStartListQualificationPoints.Destroy;
begin
  SetLength (fPoints,0);
  fPoints:= nil;
  inherited;
end;

function TStartListQualificationPoints.get_Points(index: integer): integer;
begin
  if (index>= 0) and (index< Count) then
    Result:= fPoints [index]
  else
    Result:= 0;
end;

{procedure TStartListQualificationPoints.ImportFromStream(Stream: TStream);
var
  c: integer;
begin
  Stream.Read (c,sizeof (c));
  SetLength (fPoints,c);
  Stream.Read (fPoints [0],c*sizeof (integer));
  fChanged:= true;
end;}

procedure TStartListQualificationPoints.ReadFromStream(Stream: TStream);
var
  c: integer;
begin
  Stream.Read (c,sizeof (c));
  SetLength (fPoints,c);
  Stream.Read (fPoints [0],c*sizeof (integer));
  fChanged:= false;
end;

procedure TStartListQualificationPoints.set_Points(index: integer; const Value: integer);
var
  i,idx: integer;
begin
  if index< 0 then
    exit;
  if index>= Count then
    begin
      if Value> 0 then
        begin
          idx:= Length (fPoints);
          SetLength (fPoints,index+1);
          for i:= idx to index-1 do
            fPoints [i]:= 0;
          fPoints [index]:= Value;
        end;
    end
  else
    fPoints [index]:= Value;
  while (Length (fPoints)> 0) and (fPoints [Length (fPoints)-1]= 0) do
    SetLength (fPoints,Length (fPoints)-1);
  fChanged:= true;
end;

procedure TStartListQualificationPoints.WriteToStream(Stream: TStream);
var
  c: integer;
begin
  c:= Length (fPoints);
  Stream.Write (c,sizeof (c));
  Stream.Write (fPoints [0],c*sizeof (integer));
  fChanged:= false;
end;

{ TStartListInfo }

procedure TStartListInfo.Assign(AInfo: TStartListInfo);
begin
  fTitle:= AInfo.fTitle;
  fTown:= AInfo.fTown;
  fRange:= AInfo.fRange;
  fChampionshipName:= AInfo.fChampionshipName;
  fStartNumbers:= AInfo.fStartNumbers;
  if AInfo.fChampionship<> nil then
    begin
      if StartList.Data= AInfo.StartList.Data then
        fChampionship:= AInfo.fChampionship
      else
        fChampionship:= StartList.Data.Championships [AInfo.fChampionship.Tag];
    end
  else
    fChampionship:= nil;
  fSecretery:= AInfo.fSecretery;
  fSecreteryCategory:= AInfo.SecreteryCategory;
  fJury:= AInfo.Jury;
  fJuryCategory:= AInfo.JuryCategory;
  fChanged:= true;
end;

function TStartListInfo.CaptionText: string;
begin
  Result:= SubStr (fTitle,#13,1);
end;

constructor TStartListInfo.Create(AStartList: TStartList);
begin
  fStartList:= AStartList;
  fEvent:= nil;
  Initialize;
end;

constructor TStartListInfo.Create(AEvent: TStartListEventItem);
begin
  fStartList:= nil;
  fEvent:= AEvent;
  Initialize;
end;

function TStartListInfo.EqualsTo(AInfo: TStartListInfo): boolean;
begin
  Result:= (AInfo<> nil) and (AnsiSameText (AInfo.fTitle,fTitle));
end;

function TStartListInfo.get_ChampionshipName: string;
begin
  if fChampionship<> nil then
    Result:= fChampionship.Name
  else
    Result:= fChampionshipName;
end;

function TStartListInfo.get_StartList: TStartList;
begin
  if fStartList<> nil then
    Result:= fStartList
  else if fEvent<> nil then
    Result:= fEvent.StartList
  else
    Result:= nil;
end;

procedure TStartListInfo.Initialize;
begin
  fTitle:= '';
  fTown:= '';
  fRange:= '';
  fChampionship:= nil;
  fChampionshipName:= '';
  fStartNumbers:= false;
  fSecretery:= '';
  fSecreteryCategory:= '';
  fJury:= '';
  fJuryCategory:= '';
  fChanged:= false;
end;

{procedure TStartListInfo.ImportFromStream(Stream: TStream);
var
  tag: string;
begin
  ReadStrFromStream (Stream,fTitle);
  ReadStrFromStream (Stream,fTown);
  ReadStrFromStream (Stream,fRange);
  ReadStrFromStream (Stream,tag);
  if tag<> '' then
    begin
      fChampionship:= fStart.Data.Championships.Championships [tag];
      fChampionshipName:= '';
    end
  else
    begin
      ReadStrFromStream (Stream,fChampionshipName);
      fChampionship:= nil;
    end;
  ReadStrFromStream (Stream,fSecretery);
  ReadStrFromStream (Stream,fSecreteryCategory);
  Stream.Read (fStartNumbers,sizeof (fStartNumbers));
  fChanged:= true;
end;}

procedure TStartListInfo.ReadFromStream(Stream: TStream);
var
  tag: string;
begin
  ReadStrFromStreamA (Stream,fTitle);
  ReadStrFromStreamA (Stream,fTown);
  ReadStrFromStreamA (Stream,fRange);
  ReadStrFromStreamA (Stream,tag);
  if tag<> '' then
    begin
      fChampionship:= StartList.Data.Championships.Championships [tag];
      fChampionshipName:= '';
    end
  else
    begin
      ReadStrFromStreamA (Stream,fChampionshipName);
      fChampionship:= nil;
    end;
  ReadStrFromStreamA (Stream,fSecretery);
  ReadStrFromStreamA (Stream,fSecreteryCategory);
  Stream.Read (fStartNumbers,sizeof (fStartNumbers));
  if StartList.Data.fFileVersion>= 19 then
    begin
      ReadStrFromStreamA (Stream,fJury);
      ReadStrFromStreamA (Stream,fJuryCategory);
    end
  else
    begin
      fJury:= '';
      fJuryCategory:= '';
    end;
  fChanged:= false;
end;

function TStartListInfo.Root: boolean;
begin
  Result:= fStartList<> nil;
end;

procedure TStartListInfo.set_Championship(const Value: TChampionshipItem);
begin
  if Value<> fChampionship then
    begin
      fChampionship:= Value;
      if fChampionship<> nil then
        fChampionshipName:= fChampionship.Name
      else
        fChampionshipName:= '';
      fChanged:= true;
      StartList.Notify (WM_STARTLISTINFOCHANGED,0,0);
    end;
end;

procedure TStartListInfo.set_ChampionshipName(const Value: string);
begin
  fChampionshipName:= Value;
  fChampionship:= nil;
  fChanged:= true;
  StartList.Notify (WM_STARTLISTINFOCHANGED,0,0);
end;

procedure TStartListInfo.set_Jury(const Value: string);
begin
  if Value<> fJury then
    begin
      fJury:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListInfo.set_JuryCategory(const Value: string);
begin
  if Value<> fJuryCategory then
    begin
      fJuryCategory:= Value;
      fChanged:= true;
    end;
end;

procedure TStartListInfo.set_Range(const Value: string);
begin
  if Value<> fRange then
    begin
      fChanged:= true;
      fRange:= Value;
      StartList.Notify (WM_STARTLISTINFOCHANGED,0,0);
    end;
end;

procedure TStartListInfo.set_Secretery(const Value: string);
begin
  if Value<> fSecretery then
    begin
      fChanged:= true;
      fSecretery:= Value;
      StartList.Notify (WM_STARTLISTINFOCHANGED,0,0);
    end;
end;

procedure TStartListInfo.set_SecreteryCategory(const Value: string);
begin
  if Value<> fSecreteryCategory then
    begin
      fChanged:= true;
      fSecreteryCategory:= Value;
      StartList.Notify (WM_STARTLISTINFOCHANGED,0,0);
    end;
end;

procedure TStartListInfo.set_StartNumbers(const Value: boolean);
begin
  if Value<> fStartNumbers then
    begin
      fChanged:= true;
      fStartNumbers:= Value;
      StartList.Notify (WM_STARTLISTINFOCHANGED,0,0);
    end;
end;

procedure TStartListInfo.set_Title(const Value: string);
begin
  if Value<> fTitle then
    begin
      fChanged:= true;
      fTitle:= Value;
      StartList.Notify (WM_STARTLISTINFOCHANGED,0,0);
    end;
end;

procedure TStartListInfo.set_Town(const Value: string);
begin
  if Value<> fTown then
    begin
      fChanged:= true;
      fTown:= Value;
      StartList.Notify (WM_STARTLISTINFOCHANGED,0,0);
    end;
end;

function TStartListInfo.TownAndRange: string;
begin
  if (fTown<> '') and (fRange<> '') then
    Result:= fTown+', '+fRange
  else if fTown<> '' then
    Result:= fTown
  else if fRange<> '' then
    Result:= fRange
  else
    Result:= '';
end;

procedure TStartListInfo.WriteToStream(Stream: TStream);
var
  tag: string;
  c: integer;
begin
  SaveStrToStreamA (Stream,fTitle);
  SaveStrToStreamA (Stream,fTown);
  SaveStrToStreamA (Stream,fRange);
  if fChampionship<> nil then
    begin
      tag:= fChampionship.Tag;
      SaveStrToStreamA (Stream,tag);
    end
  else
    begin
      c:= 0;
      Stream.Write (c,sizeof (c));
      SaveStrToStreamA (Stream,fChampionshipName);
    end;
  SaveStrToStreamA (Stream,fSecretery);
  SaveStrToStreamA (Stream,fSecreteryCategory);
  Stream.Write (fStartNumbers,sizeof (fStartNumbers));
  SaveStrToStreamA (Stream,fJury);
  SaveStrToStreamA (Stream,fJuryCategory);
  fChanged:= false;
end;

{ TStartLists }

function TStartLists.Add: TStartList;
{$ifdef SampleStart}
var
  e: TStartListEventItem;
  j,k: integer;
  r: TStartListEventRelayItem;
{$endif}
begin
  Result:= inherited Add as TStartList;

{$ifdef SampleStart}
  Result.Info.TitleText:= '����� ����� �� ����� ������ "���������� ����������"';
  Result.Info.Town:= '�������';
  Result.Info.ShootingRange:= '����� �� �������';
  Result.Info.Championship:= fData.Championships.Items [1];
  Result.Info.Secretery:= '���� ����';
  Result.Info.SecreteryCategory:= '����� ������������� ���������';
  for j:= 0 to 5 do
    begin
      e:= Result.Events.Add;
      e.Event:= fData.Events.Items [j];
      e.ProtocolNumber:= Result.GetNextProtocolNumber;
      r:= e.Relays.Add;
      r.PreconfigureStartTime;
      r.PositionsStr:= '1-10';
      for k:= 1 to 5 do
        begin
          e.Points.Points [k]:= (6-k)*50;
        end;
    end;
  e:= Result.Events.Add;
  e.Event:= fData.Events ['��-6'];
  e.ProtocolNumber:= Result.GetNextProtocolNumber;
  r:= e.Relays.Add;
  r.PositionsStr:= '1-10';
  for j:= 1 to 5 do
    begin
      Result.QualificationPoints [j]:= (6-j)*5;
    end;
  Result.Info.StartNumbers:= true;
{$endif}
end;

procedure TStartLists.Check;
begin
  // TODO: �������� ��������� �������
end;

procedure TStartLists.ConvertChampionshipToNil(AChampionship: TChampionshipItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].ConvertToNil (AChampionship);
end;

constructor TStartLists.Create(AData: TData);
begin
  inherited Create (TStartList);
  fData:= AData;
  fChanged:= false;
  fActiveStart:= nil;
end;

procedure TStartLists.DeleteEvent(AEvent: TEventItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].DeleteEvent (AEvent);
end;

function TStartLists.FindById(AID: TGUID): TStartList;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    if IsEqualGUID (Items [i].ID, AID) then
      begin
        Result:= Items [i];
        break;
      end;
end;

function TStartLists.FindByInfo(AInfo: TStartListInfo): TStartList;
var
  i: integer;
  sl: TStartList;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      sl:= Items [i];
      if sl.Info.EqualsTo (AInfo) then
        begin
          Result:= sl;
          break;
        end;
    end;
end;

function TStartLists.GetItems(index: integer): TStartList;
begin
  if (index>= 0) and (index< Count) then
    Result:= inherited Items [index] as TStartList
  else
    Result:= nil;
end;

function TStartLists.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  for i:= 0 to Count-1 do
    Result:= Result or Items [i].WasChanged;
end;

function TStartLists.HaveEvent(AEvent: TEventItem): boolean;
var
  i: integer;
begin
  Result:= true;
  for i:= 0 to Count-1 do
    if Items [i].HasEvent (AEvent) then
      exit;
  Result:= false;
end;

{
function TStartLists.HaveChampionship(AChampionship: TShootingChampionshipItem): boolean;
var
  i,j: integer;
  sl: TStartList;
  ev: TStartListEventItem;
begin
  Result:= false;
  for i:= 0 to Count-1 do
    begin
      sl:= Items [i];
      for j:= 0 to sl.Events.Count-1 do
        begin
          ev:= sl.Events [j];
          if (ev.ShootingEvent<> nil) and (ev.ShootingEvent.Championship= AChampionship) then
            begin
              Result:= true;
              exit;
            end;
        end;
    end;
end;
}

{
function TStartLists.HaveEvent(AShootingEvent: TShootingEventItem): boolean;
var
  i,j: integer;
  sl: TStartList;
  ev: TStartListEventItem;
begin
  Result:= false;
  for i:= 0 to Count-1 do
    begin
      sl:= Items [i];
      for j:= 0 to sl.Events.Count-1 do
        begin
          ev:= sl.Events [j];
          if ev.ShootingEvent= AShootingEvent then
            begin
              Result:= true;
              exit;
            end;
        end;
    end;
end;
}

procedure TStartLists.MergeWith(AStartLists: TStartLists);
var
  i: integer;
  sl,sl1: TStartList;
begin
  for i:= 0 to AStartLists.Count-1 do
    begin
      sl:= AStartLists [i];
      sl1:= FindById (sl.ID);
      if sl1<> nil then
        sl.MergeWith (sl1)
      else
        begin
          sl1:= FindByInfo (sl.Info);
          if (sl1<> nil) and ((sl1.DateFrom<> sl.DateFrom) or (sl1.DateTill<> sl.DateTill)) then
            sl1:= nil;
          if sl1= nil then
            begin
              sl1:= Add;
              sl1.Assign (sl);
            end
          else
            sl.MergeWith (sl1);
        end;
    end;
end;

procedure TStartLists.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  sl: TStartList;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      sl:= Add;
      sl.ReadFromStream (Stream);
    end;
  Stream.Read (c,sizeof (c));
  if (c>= 0) or (c< Count) then
    fActiveStart:= Items [c];
  fChanged:= false;
end;

procedure TStartLists.set_ActiveStart(const Value: TStartList);
begin
  if Value<> fActiveStart then
    begin
      fChanged:= true;
      fActiveStart:= Value;
    end;
end;

procedure TStartLists.WriteToStream(Stream: TStream; SaveStartLists: boolean);
var
  c,i: integer;
begin
  if SaveStartLists then
    begin
      c:= Count;
      Stream.Write (c,sizeof (c));
      for i:= 0 to c-1 do
        Items [i].WriteToStream (Stream);
      if fActiveStart<> nil then
        c:= fActiveStart.Index
      else
        c:= -1;
      Stream.Write (c,sizeof (c));
      fChanged:= false;
    end
  else
    begin
      c:= 0;
      Stream.Write (c,sizeof (c));
      c:= -1;
      Stream.Write (c,sizeof (c));
    end;
end;

{ TStartListTeamsGroups }

function TStartListTeamsGroups.Add: TStartListTeamsGroup;
var
  i: integer;
begin
  i:= Length (fGroups);
  SetLength (fGroups,i+1);
  fGroups [i]:= TStartListTeamsGroup.Create (self);
  Result:= fGroups [i];
  fChanged:= true;
end;

procedure TStartListTeamsGroups.Clear;
var
  i: integer;
begin
  for i:= 0 to Length (fGroups)-1 do
    fGroups [i].Free;
  SetLength (fGroups,0);
  fChanged:= true;
end;

function TStartListTeamsGroups.Count: integer;
begin
  Result:= Length (fGroups);
end;

constructor TStartListTeamsGroups.Create(AStartList: TStartList);
begin
  inherited Create;
  fStart:= AStartList;
  SetLength (fGroups,0);
  fChanged:= false;
end;

procedure TStartListTeamsGroups.Delete(Index: integer);
var
  i: integer;
begin
  if (Index< 0) or (Index>= Length (fGroups)) then
    exit;
  fGroups [Index].Free;
  for i:= Index to Length (fGroups)-2 do
    fGroups [i]:= fGroups [i+1];
  SetLength (fGroups,Length (fGroups)-1);
  fChanged:= true;
end;

procedure TStartListTeamsGroups.Delete(AGroup: TStartListTeamsGroup);
var
  i: integer;
begin
  i:= GroupIndex (AGroup);
  if i>= 0 then
    Delete (i);
end;

destructor TStartListTeamsGroups.Destroy;
begin
  Clear;
  inherited;
end;

function TStartListTeamsGroups.get_Group(Index: integer): TStartListTeamsGroup;
begin
  if (Index>= 0) and (Index< Length (fGroups)) then
    Result:= fGroups [Index]
  else
    Result:= nil;
end;

function TStartListTeamsGroups.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  if not Result then
    for i:= 0 to Length (fGroups)-1 do
      Result:= Result or fGroups [i].WasChanged;
end;

function TStartListTeamsGroups.GroupIndex(
  AGroup: TStartListTeamsGroup): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to Length (fGroups)-1 do
    if fGroups [i]= AGroup then
      begin
        Result:= i;
        exit;
      end;
end;

procedure TStartListTeamsGroups.ReadFromStream(Stream: TStream);
var
  i,c: integer;
  g: TStartListTeamsGroup;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      g:= Add;
      g.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TStartListTeamsGroups.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Length (fGroups);
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    fGroups [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TStartListTeamsGroup }

function TStartListTeamsGroup.Add(ATeam: string): integer;
var
  i: integer;
begin
  Result:= -1;
  ATeam:= Trim (ATeam);
  if ATeam= '' then
    exit;
  i:= TeamIndex (ATeam);
  if i>= 0 then
    begin
      Result:= i;
      exit;
    end;
  i:= Length (fTeams);
  SetLength (fTeams,i+1);
  fTeams [i]:= ATeam;
  Result:= i;
  fChanged:= true;
end;

procedure TStartListTeamsGroup.Clear;
var
  i: integer;
begin
  for i:= 0 to Length (fTeams)-1 do
    fTeams [i]:= '';
  SetLength (fTeams,0);
  fChanged:= true;
end;

function TStartListTeamsGroup.Count: integer;
begin
  Result:= Length (fTeams);
end;

constructor TStartListTeamsGroup.Create(AGroups: TStartListTeamsGroups);
begin
  inherited Create;
  fGroups:= AGroups;
  SetLength (fTeams,0);
  fName:= '';
  fChanged:= false;
end;

procedure TStartListTeamsGroup.Delete(Index: integer);
var
  i: integer;
begin
  if (Index< 0) or (Index>= Length (fTeams)) then
    exit;
  for i:= Index to Length (fTeams)-2 do
    fTeams [i]:= fTeams [i+1];
  fTeams [Length (fTeams)-1]:= '';
  SetLength (fTeams,Length (fTeams)-1);
  fChanged:= true;
end;

procedure TStartListTeamsGroup.Delete(ATeam: string);
var
  i: integer;
begin
  i:= TeamIndex (ATeam);
  if i>= 0 then
    Delete (i);
end;

destructor TStartListTeamsGroup.Destroy;
begin
  Clear;
  inherited;
end;

function TStartListTeamsGroup.get_Team(Index: integer): string;
begin
  if (Index>= 0) and (Index< Length (fTeams)) then
    Result:= fTeams [Index]
  else
    Result:= '';
end;

function TStartListTeamsGroup.get_WasChanged: boolean;
begin
  Result:= fChanged;
end;

procedure TStartListTeamsGroup.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  s: string;
begin
  Clear;
  ReadStrFromStreamA (Stream,fName);
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      ReadStrFromStreamA (Stream,s);
      Add (Trim (s));
    end;
  fChanged:= false;
end;

procedure TStartListTeamsGroup.set_Name(const Value: string);
begin
  if Trim (Value)<> fName then
    begin
      fName:= Trim (Value);
      fChanged:= true;
    end;
end;

procedure TStartListTeamsGroup.set_Team(Index: integer; const Value: string);
begin
  if (Index>= 0) and (Index< Length (fTeams)) then
    begin
      if Trim (Value)<> fTeams [Index] then
        begin
          fTeams [Index]:= Trim (Value);
          fChanged:= true;
        end;
    end
  else
    begin
      // �� ������ ��� ���������
    end;
end;

function TStartListTeamsGroup.TeamIndex(ATeam: string): integer;
var
  i: integer;
begin
  Result:= -1;
  if Trim (ATeam)= '' then
    exit;
  for i:= 0 to Length (fTeams)-1 do
    if AnsiSameText (fTeams [i],Trim (ATeam)) then
      begin
        Result:= i;
        exit;
      end;
end;

procedure TStartListTeamsGroup.WriteToStream(Stream: TStream);
var
  i,c: integer;
begin
  SaveStrToStreamA (Stream,fName);
  c:= Length (fTeams);
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    SaveStrToStreamA (Stream,fTeams [i]);
  fChanged:= false;
end;

{ TStartListTotalTeamStats }

function TStartListTotalTeamStats.CompareTo(ATeam: TStartListTotalTeamStats): shortint;
var
  i,l1,l2: integer;
begin
  if TotalPoints> ATeam.TotalPoints then
    Result:= 1
  else if TotalPoints< ATeam.TotalPoints then
    Result:= -1
  else
    begin
      Result:= 0;
      l1:= Length (fAllRanks);
      l2:= Length (ATeam.fAllRanks);
      i:= 0;
      while (i< l1) and (i< l2) do
        begin
          if fAllRanks [i]< ATeam.fAllRanks [i] then
            begin
              Result:= 1;
              break;
            end
          else if fAllRanks [i]> ATeam.fAllRanks [i] then
            begin
              Result:= -1;
              break;
            end;
          inc (i);
        end;
      if Result= 0 then
        begin
          if l1> l2 then
            Result:= 1
          else if l1< l2 then
            Result:= -1;
        end;
    end;
end;

constructor TStartListTotalTeamStats.Create (AStartList: TStartList; ATeam: string; APointsFor: TPointsFor);
var
  i,j,idx: integer;
  ev: TStartListEventItem;
  c: integer;
  p: integer;
begin
  inherited Create;
  fStartList:= AStartList;
  fTeam:= ATeam;
  fFullName:= ATeam;
  SetLength (fAllRanks,0);
  SetLength (fEventPoints,0);

  case APointsFor of
    pfTeam: begin
      fTotalPoints:= fStartList.TeamPoints (fTeam,[wtRifle,wtPistol,wtMoving],[Male,Female]);
      fRifleMenPoints:= fStartList.TeamPoints (fTeam,[wtRifle],[Male]);
      fRifleWomenPoints:= fStartList.TeamPoints (fTeam,[wtRifle],[Female]);
      fPistolMenPoints:= fStartList.TeamPoints (fTeam,[wtPistol],[Male]);
      fPistolWomenPoints:= fStartList.TeamPoints (fTeam,[wtPistol],[Female]);
      fMovingMenPoints:= fStartList.TeamPoints (fTeam,[wtMoving],[Male]);
      fMovingWomenPoints:= fStartList.TeamPoints (fTeam,[wtMoving],[Female]);
      fMenPoints:= fStartList.TeamPoints (fTeam,[wtRifle,wtPistol,wtmoving],[Male]);
      fWomenPoints:= fStartList.TeamPoints (fTeam,[wtRifle,wtPistol,wtmoving],[Female]);
      fStartList.GetTeamRanks (fTeam,fAllRanks);
      for i:= 0 to fStartList.Events.Count-1 do
        begin
          ev:= fStartList.Events.Items [i];
          if not ev.InPointsTable then
            continue;
          c:= ev.TeamPointsShooters (fTeam,[Male,Female]);
          if c> 0 then
            begin
              p:= ev.TeamPoints (fTeam,[Male,Female]);
              idx:= Length (fEventPoints);
              SetLength (fEventPoints,idx+1);
              fEventPoints [idx].event:= ev;
              fEventPoints [idx].points:= p;
            end;
        end;
    end;
    pfRegion: begin
      fFullName:= fStartList.Data.Regions [fTeam];
      fTotalPoints:= fStartList.RegionPoints (fTeam,[wtRifle,wtPistol,wtMoving],[Male,Female]);
      fRifleMenPoints:= fStartList.RegionPoints (fTeam,[wtRifle],[Male]);
      fRifleWomenPoints:= fStartList.RegionPoints (fTeam,[wtRifle],[Female]);
      fPistolMenPoints:= fStartList.RegionPoints (fTeam,[wtPistol],[Male]);
      fPistolWomenPoints:= fStartList.RegionPoints (fTeam,[wtPistol],[Female]);
      fMovingMenPoints:= fStartList.RegionPoints (fTeam,[wtMoving],[Male]);
      fMovingWomenPoints:= fStartList.RegionPoints (fTeam,[wtMoving],[Female]);
      fMenPoints:= fStartList.RegionPoints (fTeam,[wtRifle,wtPistol,wtmoving],[Male]);
      fWomenPoints:= fStartList.RegionPoints (fTeam,[wtRifle,wtPistol,wtmoving],[Female]);
      fStartList.GetRegionRanks (fTeam,fAllRanks);
      for i:= 0 to fStartList.Events.Count-1 do
        begin
          ev:= fStartList.Events.Items [i];
          if not ev.InPointsTable then
            continue;
          c:= ev.RegionPointsShooters (fTeam,[Male,Female]);
          if c> 0 then
            begin
              p:= ev.RegionPoints (fTeam,[Male,Female]);
              idx:= Length (fEventPoints);
              SetLength (fEventPoints,idx+1);
              fEventPoints [idx].event:= ev;
              fEventPoints [idx].points:= p;
            end;
        end;
    end;
    pfDistrict: begin
      fFullName:= fStartList.Data.Districts [fTeam];
      fTotalPoints:= fStartList.DistrictPoints (fTeam,[wtRifle,wtPistol,wtMoving],[Male,Female]);
      fRifleMenPoints:= fStartList.DistrictPoints (fTeam,[wtRifle],[Male]);
      fRifleWomenPoints:= fStartList.DistrictPoints (fTeam,[wtRifle],[Female]);
      fPistolMenPoints:= fStartList.DistrictPoints (fTeam,[wtPistol],[Male]);
      fPistolWomenPoints:= fStartList.DistrictPoints (fTeam,[wtPistol],[Female]);
      fMovingMenPoints:= fStartList.DistrictPoints (fTeam,[wtMoving],[Male]);
      fMovingWomenPoints:= fStartList.DistrictPoints (fTeam,[wtMoving],[Female]);
      fMenPoints:= fStartList.DistrictPoints (fTeam,[wtRifle,wtPistol,wtmoving],[Male]);
      fWomenPoints:= fStartList.DistrictPoints (fTeam,[wtRifle,wtPistol,wtmoving],[Female]);
      fStartList.GetDistrictRanks (fTeam,fAllRanks);
      for i:= 0 to fStartList.Events.Count-1 do
        begin
          ev:= fStartList.Events.Items [i];
          if not ev.InPointsTable then
            continue;
          c:= ev.DistrictPointsShooters (fTeam,[Male,Female]);
          if c> 0 then
            begin
              p:= ev.DistrictPoints (fTeam,[Male,Female]);
              idx:= Length (fEventPoints);
              SetLength (fEventPoints,idx+1);
              fEventPoints [idx].event:= ev;
              fEventPoints [idx].points:= p;
            end;
        end;
    end;
  end;
  // ��������� ������ � �������
  for i:= 0 to Length (fAllRanks)-2 do
    begin
      idx:= i;
      for j:= i+1 to Length (fAllRanks)-1 do
        begin
          if fAllRanks [j]< fAllRanks [idx] then
            idx:= j;
        end;
      if idx<> i then
        begin
          j:= fAllRanks [idx];
          fAllRanks [idx]:= fAllRanks [i];
          fAllRanks [i]:= j;
        end;
    end;
end;

destructor TStartListTotalTeamStats.Destroy;
begin
  SetLength (fAllRanks,0);
  fAllRanks:= nil;
  SetLength (fEventPoints,0);
  fEventPoints:= nil;
  inherited;
end;

function TStartListTotalTeamStats.EventPoints(AEvent: TStartListEventItem): integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Length (fEventPoints)-1 do
    begin
      if fEventPoints [i].event= AEvent then
        begin
          Result:= fEventPoints [i].points;
          break;
        end;
    end;
end;

{ TSportSocietyItem }

procedure TSportSocietyItem.Assign(Source: TPersistent);
begin
  if Source is TSportSocietyItem then
    begin
      fName:= (Source as TSportSocietyItem).fName;
      fChanged:= true;
    end
  else
    inherited;
end;

constructor TSportSocietyItem.Create (ACollection: TCollection);
begin
  inherited;
  fName:= '';
  fChanged:= false;
  Societies.fChanged:= true;
end;

function TSportSocietyItem.Data: TData;
begin
  Result:= (Collection as TSportSocieties).Data;
end;

destructor TSportSocietyItem.Destroy;
begin
  fName:= '';
  if Collection<> nil then
    (Collection as TSportSocieties).fChanged:= true;
  inherited;
end;

procedure TSportSocietyItem.ReadFromStream(Stream: TStream);
//var
//  c: integer;
begin
  ReadStrFromStreamA (Stream,fName);
  fChanged:= false;
end;

procedure TSportSocietyItem.set_Name(const Value: string);
begin
  if Value<> fName then
    begin
      fName:= Value;
      fChanged:= true;
    end;
end;

function TSportSocietyItem.ShootersCount: integer;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Data.Groups.Count-1 do
    Result:= Result+Data.Groups [i].Shooters.InSociety (self);
end;

function TSportSocietyItem.Societies: TSportSocieties;
begin
  Result:= Collection as TSportSocieties;
end;

procedure TSportSocietyItem.WriteToStream(Stream: TStream);
var
  c: integer;
begin
  SaveStrToStreamA (Stream,fName);  // ���������� ���������� ������� ��� Unicode
  fChanged:= false;
end;

{ TSportSocieties }

function TSportSocieties.Add: TSportSocietyItem;
begin
  Result:= inherited Add as TSportSocietyItem;
end;

procedure TSportSocieties.Check;
begin
  // TODO: �������� �������
end;

constructor TSportSocieties.Create(AData: TData);
begin
  inherited Create (TSportSocietyItem);
  fData:= AData;
end;

destructor TSportSocieties.Destroy;
begin
  Clear;
  inherited;
end;

function TSportSocieties.Find(const AName: string): TSportSocietyItem;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    if AnsiSameText (Items [i].Name,AName) then
      begin
        Result:= Items [i];
        break;
      end;
end;

function TSportSocieties.get_Item(Index: integer): TSportSocietyItem;
begin
  Result:= inherited Items [Index] as TSportSocietyItem;
end;

procedure TSportSocieties.ReadFromStream(Stream: TStream);
var
  i,c: integer;
  s: TSportSocietyItem;
begin
  Stream.Read (c,sizeof (c));
  Clear;
  for i:= 0 to c-1 do
    begin
      s:= Add;
      s.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

function TSportSocieties.WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  if not Result then
    begin
      for i:= 0 to Count-1 do
        if Items [i].WasChanged then
          begin
            Result:= true;
            break;
          end;
    end;
end;

procedure TSportSocieties.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TShootingChampionshipItem }

procedure TShootingChampionshipItem.Assign(Source: TPersistent);
var
  sch: TShootingChampionshipItem;
begin
  inherited;
  if Source is TShootingChampionshipItem then
    begin
      sch:= Source as TShootingChampionshipItem;
      fChampionship:= sch.fChampionship;
      fChampionshipName:= sch.fChampionshipName;
      fCountry:= sch.fCountry;
      fTown:= sch.fTown;
      fDate1:= sch.fDate1;
      fDate2:= sch.fDate2;
      fEvents.Assign (sch.fEvents);
      fChanged:= true;
    end;
end;

function TShootingChampionshipItem.Championships: TShootingChampionships;
begin
  Result:= Collection as TShootingChampionships;
end;

procedure TShootingChampionshipItem.ConvertEventToNil(AEvent: TEventItem; const AShortName,AName: string);
var
  i: integer;
  ev: TShootingEventItem;
begin
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events [i];
      if ev.Event= AEvent then
        ev.SetEvent (nil,AShortName,AName);
    end;
end;

constructor TShootingChampionshipItem.Create(ACollection: TCollection);
begin
  inherited;
  fChampionship:= nil;
  fChampionshipName:= '';
  fCountry:= '';
  fTown:= '';
  fEvents:= TShootingEvents.Create (self);
  fChanged:= false;
  fDate1:= 0;
  fDate2:= 0;
  fResultsCount:= 0;
  Championships.fChanged:= true;
end;

function TShootingChampionshipItem.Data: TData;
begin
  Result:= Championships.Data;
end;

function TShootingChampionshipItem.DateBelongs(ADate,AThreshold: TDateTime): boolean;
begin
  Result:=  (fDate1= 0) or ((ADate>= fDate1-AThreshold) and (ADate<= fDate2+AThreshold));
end;

procedure TShootingChampionshipItem.DecrementResults (Number: integer);
begin
  if fResultsCount>= Number then
    dec (fResultsCount,Number);
end;

procedure TShootingChampionshipItem.DeleteEvents(AEvent: TEventItem);
var
  i: integer;
begin
  i:= 0;
  while i< Events.Count do
    begin
      if Events [i].Event= AEvent then
        Events.Delete (i)
      else
        inc (i);
    end;
end;

destructor TShootingChampionshipItem.Destroy;
begin
  fEvents.Free;
  Championships.fChanged:= true;
  inherited;
end;

procedure TShootingChampionshipItem.FitDate;
var
  i: integer;
  ev: TShootingEventItem;
begin
  fDate1:= 0;
  fDate2:= 0;
  for i:= 0 to Events.Count-1 do
    begin
      ev:= Events [i];
      if (ev.Date< fDate1) or (fDate1= 0) then
        fDate1:= ev.Date;
      if (ev.Date> fDate2) or (fDate2= 0) then
        fDate2:= ev.Date;
    end;
end;

function TShootingChampionshipItem.get_ChampionshipName: string;
begin
  if fChampionship<> nil then
    Result:= fChampionship.Name
  else
    Result:= fChampionshipName;
end;

function TShootingChampionshipItem.get_WasChanged: boolean;
begin
  Result:= fChanged or Events.WasChanged;
end;

procedure TShootingChampionshipItem.IncrementResults (Number: integer);
begin
  inc (fResultsCount,Number);
end;

procedure TShootingChampionshipItem.ReadFromStream(Stream: TStream);
var
  idx: integer;
begin
  Stream.Read (idx,sizeof (idx));
  if idx>= 0 then
    begin
      fChampionship:= Data.Championships.Items [idx];
      fChampionshipName:= '';
    end
  else
    begin
      fChampionship:= nil;
      ReadStrFromStreamA (Stream,fChampionshipName);
    end;
  ReadStrFromStreamA (Stream,fCountry);
  ReadStrFromStreamA (Stream,fTown);
  fEvents.ReadFromStream (Stream);
  fChanged:= false;
end;

procedure TShootingChampionshipItem.SetChampionship(
  AChampionship: TChampionshipItem; const AName: string);
begin
  if AChampionship<> nil then
    begin
      if fChampionship<> AChampionship then
        begin
          fChampionship:= AChampionship;
          fChanged:= true;
        end;
      if fChampionshipName<> '' then
        begin
          fChampionshipName:= '';
          fChanged:= true;
        end;
    end
  else
    begin
      if fChampionship<> nil then
        begin
          fChampionship:= nil;
          fChanged:= true;
        end;
      if fChampionshipName<> AName then
        begin
          fChampionshipName:= AName;
          fChanged:= true;
        end;
    end;


end;

{
function TShootingChampionshipItem.ResultsCount: integer;
var
  i,j,k: integer;
  gr: TGroupItem;
  sh: TShooterItem;
begin
  Result:= 0;
  for i:= 0 to Data.Groups.Count-1 do
    begin
      gr:= Data.Groups [i];
      for j:= 0 to gr.Shooters.Count-1 do
        begin
          sh:= gr.Shooters [j];
          for k:= 0 to sh.Results.Count-1 do
            if sh.Results [k].ShootingEvent.Championship= self then
              inc (Result);
        end;
    end;
end;
}

{
procedure TShootingChampionshipItem.set_Championship(const Value: TChampionshipItem);
begin
  if Value<> fChampionship then
    begin
      fChampionship:= Value;
      fChanged:= true;
    end;
end;
}

(*
procedure TShootingChampionshipItem.set_ChampionshipName(const Value: string);
//var
//  ch: TChampionshipItem;
begin
  fChampionship:= nil;
  fChampionshipName:= Value;
  fChanged:= true;
{
  ch:= Data.Championships.FindByName (Value);
  if ch<> nil then
    begin
      if ch<> fChampionship then
        begin
          fChampionship:= ch;
          fChampionshipName:= '';
          fChanged:= true;
        end;
    end
  else
    begin
      if (fChampionship<> nil) or (Value<> fChampionshipName) then
        begin
          fChampionship:= nil;
          fChampionshipName:= Value;
          fChanged:= true;
        end;
    end;
}
end;
*)

procedure TShootingChampionshipItem.set_Country(const Value: string);
begin
  if Value<> fCountry then
    begin
      fCountry:= Value;
      fChanged:= true;
    end;
end;

procedure TShootingChampionshipItem.set_Town(const Value: string);
var
  i: integer;
begin
  if Value<> fTown then
    begin
      fTown:= Value;
      fChanged:= true;
    end;
  for i:= 0 to Events.Count-1 do
    Events.Items [i].Town:= fTown;
end;

procedure TShootingChampionshipItem.WriteToStream(Stream: TStream);
var
  idx: integer;
begin
  if fChampionship<> nil then
    begin
      idx:= fChampionship.Index;
      Stream.Write (idx,sizeof (idx));
    end
  else
    begin
      idx:= -1;
      Stream.Write (idx,sizeof (idx));
      SaveStrToStreamA (Stream,fChampionshipName);
    end;
  SaveStrToStreamA (Stream,fCountry);
  SaveStrToStreamA (Stream,fTown);
  fEvents.WriteToStream (Stream);
  fChanged:= false;
end;

function TShootingChampionshipItem.Year: integer;
begin
  Result:= YearOf (fDate1);
end;

{ TShootingChampionships }

function TShootingChampionships.Add: TShootingChampionshipItem;
begin
  Result:= inherited Add as TShootingChampionshipItem;
end;

procedure TShootingChampionships.ConvertChampionshipToNil(AChamp: TChampionshipItem; const AName: string);
var
  i: integer;
  ch: TShootingChampionshipItem;
begin
  for i:= 0 to Count-1 do
    begin
      ch:= Items [i];
      if ch.Championship= AChamp then
        ch.SetChampionship (nil,AName);
    end;
end;

procedure TShootingChampionships.ConvertEventToNil(AEvent: TEventItem; const AShortName,AName: string);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].ConvertEventToNil (AEvent,AShortName,AName);
end;

constructor TShootingChampionships.Create(AData: TData);
begin
  inherited Create (TShootingChampionshipItem);
  fData:= AData;
  fChanged:= false;
end;

procedure TShootingChampionships.DeleteChampionships(AChamp: TChampionshipItem);
var
  i: integer;
  ch: TShootingChampionshipItem;
begin
  i:= 0;
  while i< Count do
    begin
      ch:= Items [i];
      if ch.Championship= AChamp then
        Delete (i)
      else
        inc (i);
    end;
end;

procedure TShootingChampionships.DeleteEvents(AEvent: TEventItem);
var
  i: integer;
begin
  for i:= 0 to Count-1 do
    Items [i].DeleteEvents (AEvent);
end;

function TShootingChampionships.Find(AChampionship: TChampionshipItem; const AName: string; ADate: TDateTime; const ACountry,ATown: string): TShootingChampionshipItem;
var
  c: TShootingChampionshipItem;
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      c:= Items [i];
      if AChampionship<> nil then
        begin
          if (c.Championship= AChampionship) and (c.DateBelongs (ADate,14))
            and (AnsiSameText (c.Country,ACountry))
            and (AnsiSameText (c.Town,ATown)) then
            begin
              Result:= c;
              break;
            end;
        end
      else
        begin
          if (c.ChampionshipName= AName) and (c.DateBelongs (ADate,14)) then
            begin
              Result:= c;
              break;
            end;
        end;
    end;
end;

function TShootingChampionships.Find(AChampionship: TChampionshipItem; const AName: string; ADate: TDateTime): TShootingChampionshipItem;
var
  c: TShootingChampionshipItem;
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      c:= Items [i];
      if AChampionship<> nil then
        begin
          if (c.Championship= AChampionship) and (c.DateBelongs (ADate,14)) then
            begin
              Result:= c;
              break;
            end;
        end
      else
        begin
          if (c.ChampionshipName= AName) and (c.DateBelongs (ADate,14)) then
            begin
              Result:= c;
              break;
            end;
        end;
    end;
end;

function TShootingChampionships.FindEvent(const GUID: TGUID): TShootingEventItem;
var
  i,j: integer;
  sch: TShootingChampionshipItem;
  sev: TShootingEventItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      sch:= Items [i];
      for j:= 0 to sch.Events.Count-1 do
        begin
          sev:= sch.Events [j];
          if IsEqualGUID (sev.Id,GUID) then
            begin
              Result:= sev;
              exit;
            end;
        end;
    end;
end;

{
function TShootingChampionships.GetSameEvent(AEvent: TShootingEventItem): TShootingEventItem;
var
  ach: TChampionshipItem;
  ch: TShootingChampionshipItem;
  i: integer;
  ev: TShootingEventItem;
begin
  Result:= nil;
  ach:= AEvent.Championship.Championship;
  for i:= 0 to Count-1 do
    begin
      ch:= Items [i];
      if (ch.fChampionship= nil) and (ach<> nil) then
        continue;
      if (ch.fChampionship<> nil) and (ach= nil) then
        continue;
      if (ch.fChampionship<> nil) and (ach<> nil) and (not AnsiSameText (ch.fChampionship.Tag,ach.Tag)) then
        continue;
      if (ch.fChampionship= nil) and (ach<> nil) and (not AnsiSameStr (ch.fChampionshipName,ach.fName)) then
        continue;
      if not ch.DateBelongs (AEvent.Date,14) then
        continue;
      ev:= ch.Events.Find (AEvent.Event,AEvent.EventName,AEvent.Date);
      if ev<> nil then
        begin
          Result:= ev;
          break;
        end;
    end;
end;
}

function TShootingChampionships.get_Item(index: integer): TShootingChampionshipItem;
begin
  Result:= (inherited Items [index]) as TShootingChampionshipItem;
end;

function TShootingChampionships.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  if not fChanged then
    for i:= 0 to Count-1 do
      Result:= Result or Items [i].WasChanged;
end;

procedure TShootingChampionships.ReadFromStream(Stream: TStream);
var
  i,c: integer;
  ch: TShootingChampionshipItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      ch:= Add;
      ch.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TShootingChampionships.WriteToStream(Stream: TStream);
var
  i,c: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TShootingEvents }

function TShootingEvents.Add: TShootingEventItem;
begin
  Result:= inherited Add as TShootingEventItem;
end;

constructor TShootingEvents.Create(AChampionship: TShootingChampionshipItem);
begin
  inherited Create (TShootingEventItem);
  fChampionship:= AChampionship;
  fChanged:= false;
end;

function TShootingEvents.Find(AEvent: TEventItem; const AName: string; ADate: TDateTime): TShootingEventItem;
var
  i: integer;
  e: TShootingEventItem;
begin
  Result:= nil;
  for i:= 0 to Count-1 do
    begin
      e:= Items [i];
      if AEvent<> nil then
        begin
          if (e.Event= AEvent) and (SameDate (e.Date,ADate)) then
            begin
              Result:= e;
              break;
            end;
        end
      else
        begin
          if (e.EventName= AName) and (SameDate (e.Date,ADate)) then
            begin
              Result:= e;
              break;
            end;
        end;
    end;
end;

function TShootingEvents.get_Item(index: integer): TShootingEventItem;
begin
  Result:= (inherited Items [index]) as TShootingEventItem;
end;

function TShootingEvents.get_WasChanged: boolean;
var
  i: integer;
begin
  Result:= fChanged;
  if not fChanged then
    for i:= 0 to Count-1 do
      Result:= Result or Items [i].WasChanged;
end;

procedure TShootingEvents.ReadFromStream(Stream: TStream);
var
  c,i: integer;
  e: TShootingEventItem;
begin
  Clear;
  Stream.Read (c,sizeof (c));
  for i:= 0 to c-1 do
    begin
      e:= Add;
      e.ReadFromStream (Stream);
    end;
  fChanged:= false;
end;

procedure TShootingEvents.WriteToStream(Stream: TStream);
var
  c,i: integer;
begin
  c:= Count;
  Stream.Write (c,sizeof (c));
  for i:= 0 to c-1 do
    Items [i].WriteToStream (Stream);
  fChanged:= false;
end;

{ TShootingEventItem }

procedure TShootingEventItem.Assign(Source: TPersistent);
var
  sev: TShootingEventItem;
begin
  inherited;
  if Source is TShootingEventItem then
    begin
      sev:= Source as TShootingEventItem;
      fDate:= sev.fDate;
      fEvent:= sev.fEvent;
      fEventName:= sev.fEventName;
      fTown:= sev.fTown;
      fTownOverride:= sev.fTownOverride;
      fChanged:= true;
    end;
end;

function TShootingEventItem.Championship: TShootingChampionshipItem;
begin
  Result:= Events.Championship;
end;

function TShootingEventItem.Country: string;
begin
  Result:= Championship.Country;
end;

constructor TShootingEventItem.Create(ACollection: TCollection);
begin
  inherited;
  fDate:= 0;
  fEvent:= nil;
  fShortName:= '';
  fEventName:= '';
  fTown:= '';
  fTownOverride:= false;
  fChanged:= false;
  Events.fChanged:= true;
  CreateGUID (fId);
end;

function TShootingEventItem.Data: TData;
begin
  Result:= Championship.Championships.Data;
end;

procedure TShootingEventItem.DecrementResults;
begin
  if fResultsCount> 0 then
    begin
      dec (fResultsCount);
      if Championship<> nil then
        Championship.DecrementResults (1);
    end;
end;

destructor TShootingEventItem.Destroy;
var
  ch: TShootingChampionshipItem;
begin
  ch:= Championship;
  if ch<> nil then
    ch.DecrementResults (fResultsCount);
  Events.fChanged:= true;
  inherited;
  if ch<> nil then
    ch.FitDate;
end;

function TShootingEventItem.Events: TShootingEvents;
begin
  Result:= Collection as TShootingEvents;
end;

function TShootingEventItem.get_EventName: string;
begin
  if fEvent<> nil then
    Result:= fEvent.Name
  else
    Result:= fEventName;
end;

function TShootingEventItem.get_ShortName: string;
begin
  if fEvent<> nil then
    Result:= fEvent.ShortName
  else
    Result:= fShortName;
end;

function TShootingEventItem.get_Town: string;
begin
  if fTownOverride then
    Result:= fTown
  else
    Result:= Championship.Town;
end;

procedure TShootingEventItem.IncrementResults;
begin
  inc (fResultsCount);
  if Championship<> nil then
    Championship.IncrementResults (1);
end;

procedure TShootingEventItem.MoveTo(AChampionship: TShootingChampionshipItem);
var
  sch: TShootingChampionshipItem;
begin
  if AChampionship<> Championship then
    begin
      sch:= Championship;
      if sch<> nil then
        sch.DecrementResults (fResultsCount);
      Collection:= AChampionship.Events;
      if sch<> nil then
        sch.FitDate;
      Championship.IncrementResults (fResultsCount);
      Championship.FitDate;
    end;
end;

procedure TShootingEventItem.ReadFromStream(Stream: TStream);
var
  idx: integer;
begin
  Stream.Read (fDate,sizeof (fDate));
  Championship.FitDate;
  Stream.Read (idx,sizeof (idx));
  if idx>= 0 then
    begin
      fEvent:= Data.Events.Items [idx];
      fEventName:= '';
    end
  else
    begin
      fEvent:= nil;
      if Data.fFileVersion>= 26 then
        ReadStrFromStreamA (Stream,fShortName)
      else
        fShortName:= '';
      ReadStrFromStreamA (Stream,fEventName);
    end;
  Stream.Read (fTownOverride,sizeof (fTownOverride));
  if fTownOverride then
    ReadStrFromStreamA (Stream,fTown)
  else
    fTown:= '';
  Stream.Read (fId,sizeof (fId));
  fChanged:= false;
end;

{
function TShootingEventItem.ResultsCount: integer;
var
  i,j,k: integer;
  gr: TGroupItem;
  sh: TShooterItem;
begin
  Result:= 0;
  for i:= 0 to Data.Groups.Count-1 do
    begin
      gr:= Data.Groups [i];
      for j:= 0 to gr.Shooters.Count-1 do
        begin
          sh:= gr.Shooters [j];
          for k:= 0 to sh.Results.Count-1 do
            if sh.Results [k].ShootingEvent= self then
              inc (Result);
        end;
    end;
end;
}

procedure TShootingEventItem.SetEvent(AEvent: TEventItem; const AShortName,AName: string);
begin
  if AEvent<> nil then
    begin
      if fEvent<> AEvent then
        begin
          fEvent:= AEvent;
          fChanged:= true;
        end;
      if fShortName<> '' then
        begin
          fShortName:= '';
          fChanged:= true;
        end;
      if fEventName<> '' then
        begin
          fEventName:= '';
          fChanged:= true;
        end;
    end
  else
    begin
      if fEvent<> nil then
        begin
          fEvent:= nil;
          fChanged:= true;
        end;
      if fShortName<> AShortName then
        begin
          fShortName:= AShortName;
          fChanged:= true;
        end;
      if fEventName<> AName then
        begin
          fEventName:= AName;
          fChanged:= true;
        end;
    end;
end;

procedure TShootingEventItem.set_Date(const Value: TDateTime);
begin
  if Value<> fDate then
    begin
      fDate:= Value;
      fChanged:= true;
      Championship.FitDate;
    end;
end;

procedure TShootingEventItem.set_Id(const Value: TGUID);
begin
  fId:= Value;
  fChanged:= true;
end;

{
procedure TShootingEventItem.set_Event(const Value: TEventItem);
begin
  if Value<> fEvent then
    begin
      fEvent:= Value;
      if fEvent<> nil then
        fEventName:= '';
      fChanged:= true;
    end;
end;
}

(*
procedure TShootingEventItem.set_EventName(const Value: string);
//var
//  ev: TEventItem;
begin
  fEvent:= nil;
  fEventName:= Value;
  fChanged:= true;
{  ev:= Data.Events.FindByName (Value);
  if ev<> nil then
    begin
      if ev<> fEvent then
        begin
          fEvent:= ev;
          fEventName:= '';
          fChanged:= true;
        end;
    end
  else
    begin
      if (fEvent<> nil) or (Value<> fEventName) then
        begin
          fEvent:= nil;
          fEventName:= Value;
          fChanged:= true;
        end;
    end;}
end;

procedure TShootingEventItem.set_ShortName(const Value: string);
begin
  fEvent:= nil;
  fShortName:= Value;
  fChanged:= true;
end;
*)

procedure TShootingEventItem.set_Town(const Value: string);
begin
  if Value<> Town then
    begin
      if Value= Championship.Town then
        begin
          fTown:= '';
          fTownOverride:= false;
        end
      else
        begin
          fTown:= Value;
          fTownOverride:= true;
        end;
      fChanged:= true;
    end;
end;

procedure TShootingEventItem.WriteToStream(Stream: TStream);
var
  idx: integer;
begin
  Stream.Write (fDate,sizeof (fDate));
  if fEvent<> nil then
    begin
      idx:= fEvent.Index;
      Stream.Write (idx,sizeof (idx));
    end
  else
    begin
      idx:= -1;
      Stream.Write (idx,sizeof (idx));
      SaveStrToStreamA (Stream,fShortName);
      SaveStrToStreamA (Stream,fEventName);
    end;
  Stream.Write (fTownOverride,sizeof (fTownOverride));
  if fTownOverride then
    SaveStrToStreamA (Stream,fTown);
  Stream.Write (fId,sizeof (fId));
  fChanged:= false;
end;

{ TStartListEventTeams }

function TStartListEventTeams.Add(ATeam: string): TStartListEventTeamItem;
var
  i: integer;
begin
  i:= Length (fTeams);
  SetLength (fTeams,i+1);
  Result:= TStartListEventTeamItem.Create (self);
  Result.Name:= ATeam;
  Result.fIndex:= i;
  fTeams [i]:= Result;
end;

function TStartListEventTeams.Count: integer;
begin
  Result:= Length (fTeams);
end;

constructor TStartListEventTeams.Create(AEvent: TStartListEventItem);
begin
  inherited Create;
  fEvent:= AEvent;
  SetLength (fTeams,0);
  GatherStats;
end;

procedure TStartListEventTeams.Delete(Index: integer);
var
  l,i: integer;
begin
  l:= Length (fTeams);
  fTeams [Index].Free;
  for i:= Index to l-2 do
    begin
      fTeams [i]:= fTeams [i+1];
      fTeams [i].fIndex:= i;
    end;
  SetLength (fTeams,l-1);
end;

destructor TStartListEventTeams.Destroy;
var
  i: integer;
begin
  for i:= 0 to Length (fTeams)-1 do
    fTeams [i].Free;
  SetLength (fTeams,0);
  fTeams:= nil;
  inherited;
end;

function TStartListEventTeams.Find(ATeam: string): TStartListEventTeamItem;
var
  i: integer;
begin
  Result:= nil;
  for i:= 0 to Length (fTeams)-1 do
    if AnsiSameText (fTeams [i].Name,ATeam) then
      begin
        Result:= fTeams [i];
        break;
      end;
end;

procedure TStartListEventTeams.GatherStats;
var
  i: integer;
  sh: TStartListEventShooterItem;
  ti: TStartListEventTeamItem;
begin
  // ������� �������� ����� � �������
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      sh:= fEvent.Shooters.Items [i];
      if sh.TeamForResults= '' then
        continue;
      ti:= Find (sh.TeamForResults);
      if ti= nil then
        ti:= Add (sh.TeamForResults);
      ti.Add (sh);
    end;
  // ������� ��� �������, � ������� ������������ ���������� ����������
  i:= 0;
  while i< Count do
    begin
      if fTeams [i].Count= fEvent.StartList.ShootersPerTeam then
        inc (i)
      else
        Delete (i);
    end;
  // ��������� ������� �� �����
  Sort;
  for i:= 0 to Length (fTeams)-1 do
    fTeams [i].fIndex:= i;
end;

function TStartListEventTeams.get_Item(index: integer): TStartListEventTeamItem;
begin
  Result:= fTeams [index];
end;

function TStartListEventTeams.RegionPoints(const ARegionAbbr: string; AGenders: TGenders): integer;
var
  i: integer;
  ti: TStartListEventTeamItem;
begin
  Result:= 0;
  if ARegionAbbr= '' then
    exit;
  for i:= 0 to Count-1 do
    begin
      ti:= fTeams [i];
      if (AnsiSameText (ti.RegionAbbr,ARegionAbbr)) and (ti.GenderValid) and (ti.Gender in AGenders) then
        Result:= Result+ti.Points;
    end;
end;

procedure TStartListEventTeams.Sort;
var
  i,j: integer;
  idx: integer;
  ti,ti1: TStartListEventTeamItem;
begin
  for i:= 0 to Length (fTeams)-2 do
    begin
      idx:= i;
      ti:= fTeams [i];
      for j:= i+1 to Length (fTeams)-1 do
        begin
          ti1:= fTeams [j];
          if ti1.CompareTo (ti)= 1 then
            begin
              idx:= j;
              ti:= ti1;
            end;
        end;
      if idx<> i then
        begin
          ti:= fTeams [idx];
          fTeams [idx]:= fTeams [i];
          fTeams [idx].fIndex:= idx;
          fTeams [i]:= ti;
          fTeams [i].fIndex:= i;
        end;
    end;
end;

{ TStartListEventTeamItem }

procedure TStartListEventTeamItem.Add(AShooter: TStartListEventShooterItem);
var
  i: integer;
begin
  i:= Length (fShooters);
  SetLength (fShooters,i+1);
  fShooters [i]:= AShooter;
end;

function TStartListEventTeamItem.CompareTo(ATeam: TStartListEventTeamItem): shortint;
var
  i,j: integer;
  s1,s2: DWORD;
begin
  Result:= 0;
  if Sum10> ATeam.Sum10 then
    Result:= 1
  else if Sum10< ATeam.Sum10 then
    Result:= -1
  else
    begin
      for i:= fTeams.fEvent.Event.Stages*fTeams.fEvent.Event.SeriesPerStage-1 downto 0 do
        begin
          s1:= 0;
          s2:= 0;
          for j:= 0 to Count-1 do
            s1:= s1+Shooters [j].AllSeries10 [i];
          for j:= 0 to ATeam.Count-1 do
            s2:= s2+ATeam.Shooters [j].AllSeries10 [i];
          if s1> s2 then
            begin
              Result:= 1;
              break;
            end
          else if s1< s2 then
            begin
              Result:= -1;
              break;
            end;
        end;
    end;
end;

function TStartListEventTeamItem.Count: integer;
begin
  Result:= Length (fShooters);
end;

constructor TStartListEventTeamItem.Create(ATeams: TStartListEventTeams);
begin
  inherited Create;
  fTeams:= ATeams;
  SetLength (fShooters,0);
end;

destructor TStartListEventTeamItem.Destroy;
begin
  SetLength (fShooters,0);
  fShooters:= nil;
  inherited;
end;

function TStartListEventTeamItem.Gender: TGender;
begin
  Result:= Male;
  if Count> 0 then
    Result:= Shooters [0].Shooter.Gender;
end;

function TStartListEventTeamItem.GenderValid: boolean;
var
  i: integer;
begin
  Result:= true;
  for i:= 0 to Count-2 do
    if Shooters [i].Shooter.Gender<> Shooters [i+1].Shooter.Gender then
      begin
        Result:= false;
        exit;
      end;
end;

function TStartListEventTeamItem.get_Shooter(Index: integer): TStartListEventShooterItem;
begin
  Result:= fShooters [Index];
end;

function TStartListEventTeamItem.Points: integer;
begin
  Result:= fTeams.fEvent.RTeamsPoints.Points [fIndex];
end;

function TStartListEventTeamItem.PointsStr: string;
var
  p: integer;
begin
  p:= Points;
  if p> 0 then
    Result:= IntToStr (p)
  else
    Result:= '';
end;

function TStartListEventTeamItem.RegionAbbr: string;
var
  i: integer;
  sh: TStartListEventShooterItem;
begin
  // ���� � ���� ���������� ���������� ������, �� ���������� ��� � �������� ����������
  // ���� ������� ������, �� ���������� ������ ������
  Result:= '';
  for i:= 0 to Length (fShooters)-1 do
    begin
      sh:= fShooters [i];
      if sh.Shooter.RegionAbbr1= '' then
        begin
          Result:= '';
          exit;
        end;
      if Result= '' then
        Result:= sh.Shooter.RegionAbbr1
      else if not AnsiSameText (sh.Shooter.RegionAbbr1,Result) then
        begin
          Result:= '';
          exit;
        end;
    end;
end;

function TStartListEventTeamItem.ShootersListStr: string;
var
  i: integer;
begin
  Result:= '';
  for i:= 0 to Length (fShooters)-1 do
    begin
      if i> 0 then
        Result:= Result+', ';
      Result:= Result+fShooters [i].Shooter.SurnameAndName ('');
    end;
end;

function TStartListEventTeamItem.Sum10: DWORD;
var
  i: integer;
begin
  Result:= 0;
  for i:= 0 to Length (fShooters)-1 do
    Result:= Result+fShooters [i].Competition10;
end;

function TStartListEventTeamItem.SumStr: string;
var
  s: DWORD;
begin
  s:= Sum10;
  Result:= fTeams.fEvent.CompetitionStr (s);
  {if fTeams.fEvent.Event.CompFracs then
    Result:= format ('%d.%d',[s div 10,s mod 10])
  else
    Result:= IntToStr (s div 10);}
end;

{ TFinalStages }

function TFinalStages.Add: TFinalStageItem;
begin
  Result:= inherited Add as TFinalStageItem;
end;

constructor TFinalStages.Create(AEvent: TEventItem);
begin
  inherited Create (TFinalStageItem);
  fEvent:= AEvent;
  fChanged:= false;
end;

function TFinalStages.get_Item(Index: integer): TFinalStageItem;
begin
  Result:= inherited Items[Index] as TFinalStageItem;
end;

{ TFinalStageItem }

constructor TFinalStageItem.Create(ACollection: TCollection);
begin
  inherited;
  fShots:= 0;
  fTitle:= '';
  fTens:= true;
  fChanged:= false;
  Stages.fChanged:= true;
end;

destructor TFinalStageItem.Destroy;
begin
  Stages.fChanged:= true;
  inherited;
end;

procedure TFinalStageItem.set_ShotsCount(const Value: integer);
begin
  if Value<> fShots then
    begin
      fShots:= Value;
      fChanged:= true;
    end;
end;

function TFinalStageItem.Stages: TFinalStages;
begin
  Result:= Collection as TFinalStages;
end;

initialization
  Global_TruncatePrintedClubs:= false;
  Global_ProtocolFullRegionNames:= true;
  Global_CompareBySeries:= true;

end.


