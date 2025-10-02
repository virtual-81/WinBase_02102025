{$a-}
unit form_managestart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.Printers, System.DateUtils, Vcl.Menus, System.UITypes,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, System.Types,

  mystrings,
  wb_registry,
  SysFont,
  Data,

  MyLanguage,
  ctrl_language,

  form_startinfo,
  form_printprotocol,
  form_relaysetup,
  form_teams,
  form_points,
  form_eventshooters,
  form_start,
  form_selectevent,
  form_compresults,
  form_qualifpoints,
  form_final,
  form_printcomplex,
  form_ascor,
  form_shooterresults,
  form_printshooterscards,
  form_printfinalnumbers,

  wb_barcodes;

// TODO: ���������� ������ ���������� � ���������� ������� (��� ����������)
// TODO: ���������� ����������� ������
// TODO: ���������� ������� ����� ��� ������ (� �������� ��� �����������)

type
  TSpeedupEventData= record
    started: boolean;
    comp_completed: boolean;
    final_completed: boolean;
    lotsdrawn: boolean;
    rel_count: integer;
    pos_count: integer;
    start_no: integer;
    saved: integer;
    shoot_offs: integer;
  end;

  TManageStartForm = class(TForm)
    Panel1: TPanel;
    HeaderControl1: THeaderControl;
    lbEvents: TListBox;
    pnlStart: TPanel;
    lNameC: TLabel;
    lName: TLabel;
    lChampC: TLabel;
    lChamp: TLabel;
    lNumsC: TLabel;
    lStartNumbers: TLabel;
    lTownC: TLabel;
    lRangeC: TLabel;
    lTown: TLabel;
    lRange: TLabel;
    btnChangeInfo: TButton;
    pnlTeams: TPanel;
    lTeamsC: TLabel;
    lTeams: TLabel;
    btnTeams: TButton;
    lPerTeamC: TLabel;
    lPerTeam: TLabel;
  btnPrint: TButton;
  btnImportApplications: TButton;
    btnNormalizeSurnames: TButton;
    pnlQPoints: TPanel;
    btnQualificationPoints: TButton;
    lQPointsC: TLabel;
    lQualificationPoints: TLabel;
    pmEvent: TPopupMenu;
    mnuRelays: TMenuItem;
    mnuLots: TMenuItem;
    mnuResults: TMenuItem;
    mnuShootOff: TMenuItem;
    mnuFinal: TMenuItem;
    N7: TMenuItem;
    mnuDelete: TMenuItem;
    mnuShooters: TMenuItem;
    N10: TMenuItem;
    mnuPrintStartList: TMenuItem;
    mnuPrintResults: TMenuItem;
    N13: TMenuItem;
    mnuAddEvent: TMenuItem;
    N1: TMenuItem;
    mnuDeleteInfo: TMenuItem;
    mnuChangeInfo: TMenuItem;
    mnuPrintShooters: TMenuItem;
    mnuPrintFinalNumbers: TMenuItem;
    mnuProtNo: TMenuItem;
    mnuSave: TMenuItem;
    mnuSaveStartListToPDF: TMenuItem;
    mnuSaveResultsPDF: TMenuItem;
    mnuPoints: TMenuItem;
    mnuPrintPointsTable: TMenuItem;
    mnuSaveAllResults: TMenuItem;
    mnuExportStartList: TMenuItem;
    mnuAcquire: TMenuItem;
    mnuAcquireFinal: TMenuItem;
    mnuPrintCards: TMenuItem;
    mnuPrintFinalCards: TMenuItem;
    mnuCSV: TMenuItem;
    mnuTens: TMenuItem;
    procedure mnuTensClick(Sender: TObject);
    procedure mnuCSVClick(Sender: TObject);
    procedure mnuPrintFinalCardsClick(Sender: TObject);
    procedure mnuPrintCardsClick(Sender: TObject);
    procedure mnuPrintPointsTableClick(Sender: TObject);
    procedure mnuAcquireFinalClick(Sender: TObject);
    procedure mnuAcquireClick(Sender: TObject);
    procedure mnuExportStartListClick(Sender: TObject);
    procedure mnuSaveAllResultsClick(Sender: TObject);
    procedure pmEventPopup(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbEventsDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure lbEventsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnChangeInfoClick(Sender: TObject);
    procedure lbEventsDblClick(Sender: TObject);
    procedure pnlStartResize(Sender: TObject);
    procedure pnlTeamsResize(Sender: TObject);
    procedure btnTeamsClick(Sender: TObject);
  procedure btnPrintClick(Sender: TObject);
  procedure btnImportApplicationsClick(Sender: TObject);
    procedure btnNormalizeSurnamesClick(Sender: TObject);
    procedure btnQualificationPointsClick(Sender: TObject);
    procedure pnlQPointsResize(Sender: TObject);
    procedure lbEventsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lbEventsClick(Sender: TObject);
    procedure mnuRelaysClick(Sender: TObject);
    procedure mnuShootersClick(Sender: TObject);
    procedure mnuLotsClick(Sender: TObject);
    procedure mnuResultsClick(Sender: TObject);
    procedure mnuShootOffClick(Sender: TObject);
    procedure mnuDeleteClick(Sender: TObject);
    procedure mnuPrintStartListClick(Sender: TObject);
    procedure mnuPrintResultsClick(Sender: TObject);
    procedure mnuAddEventClick(Sender: TObject);
    procedure mnuFinalClick(Sender: TObject);
    procedure mnuDeleteInfoClick(Sender: TObject);
    procedure mnuChangeInfoClick(Sender: TObject);
//    procedure mnuPrintStatsClick(Sender: TObject);
    procedure mnuPrintShootersClick(Sender: TObject);
    procedure mnuPrintFinalNumbersClick(Sender: TObject);
    procedure mnuProtNoClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuSaveStartListToPDFClick(Sender: TObject);
    procedure mnuSaveResultsPDFClick(Sender: TObject);
    procedure HeaderControl1SectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
    procedure mnuPointsClick(Sender: TObject);
  private
    { Private declarations }
    fStart: TStartList;
    fModalResult: integer;
    fEventsData: array of TSpeedupEventData;
    fHeaderChanged: boolean;
    fHoverIndex,fHoverSection: integer;
    fAddEventStr: string;
    fPoints0Str,fPoints1Str: string;
    fRegionsPoints0Str,fRegionsPoints1Str: string;
    fDistrictsPoints0Str,fDistrictsPoints1Str: string;
    fTeamsPoints0Str,fTeamsPoints1Str: string;
  fEventInfoStr: string;
  fEventWithTensMarker: string;
    fStartNoStr: string;
    fSavedStr: string;
    fFinishedStr,fCompStr,fStartStr,fLotsStr,fOpenStr: string;
    fShootOffsStr: string;
    procedure set_StartList(const Value: TStartList);
    procedure UpdateStartInfo;
    procedure EditRelays (Index: integer);
    procedure AddEvent;
    procedure DeleteEvent (Index: integer);
    procedure ViewShooters (Index: integer);
    procedure DrawLots (Index: integer);
    procedure DoStart (Index: integer);
    procedure PrintStartList (Index: integer);
    procedure OpenCompetitionResults (Index: integer);
    procedure PrintCompetitionList (index: integer);
    procedure OpenFinal (index: integer);
    procedure PrintAllStartNumbers;
    procedure MoveEventUp (Index: integer);
    procedure MoveEventDown (Index: integer);
    procedure PrintFinalNumbers (index: integer);
    procedure ChangeProtocolNumber (index: integer);
    procedure SaveEvent (index: integer);
    procedure SaveStartListToPDF (index: integer);
    procedure SaveResultsToPDF (index: integer);
    procedure EditEventPoints (index: integer);
    procedure WMStartInfoChanged (var M: TMessage); message WM_STARTLISTINFOCHANGED;
    procedure UpdateStartListInfo;
    procedure WM_StartShootersDeleted (var M: TMessage); message WM_STARTLISTSHOOTERSDELETED;
    procedure WM_StartShootersChanged (var M: TMessage); message WM_STARTLISTSHOOTERSCHANGED;
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure ExportStartListToAscor (index: integer);
    procedure AcquireSiusData (index: integer; AFinal: boolean);
    procedure WMBCShooterCard (var M: TMessage); message WM_BC_SHOOTERCARD;
    procedure SetQualificationTens (index: integer; value: boolean);
    procedure CleanupDanglingStartShooters;
  function NormalizeAllShooterSurnames: Integer;
  public
    { Public declarations }
    property Start: TStartList read fStart write set_StartList;
    function Execute: boolean;
    destructor Destroy; override;
  end;

implementation

uses
  System.Variants, ComObj, Main;

{$R *.dfm}

{ TManageStartForm }

function TManageStartForm.Execute: boolean;
begin
  fModalResult:= mrCancel;
  Result:= (ShowModal= mrOk);
end;

procedure TManageStartForm.ExportStartListToAscor(index: integer);
var
  ed: TSaveDialog;
  ev: TStartListEventItem;
  fn1,fn2: string;
begin
  if (index< 0) or (index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [index];
  if not ev.IsLotsDrawn then
    exit;
  ed:= TSaveDialog.Create (self);
  try
    ed.DefaultExt:= '*.csv';
    ed.Filter:= 'CSV files (*.csv)|*.csv';
    ed.FilterIndex:= 0;
    ed.Title:= Language ['EXPORT_STARTLIST_TO_ASCOR_DIALOG'];
    ed.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing,ofNoChangeDir];
    if ed.Execute then
      begin
        case ev.Event.EventType of
          etRapidFire: begin
            fn1:= ChangeFileExt (ed.FileName,'.STAGE_1.CSV');
            fn2:= ChangeFileExt (ed.FileName,'.STAGE_2.CSV');
            ev.ExportStartListToAscor (0,fn1);
            ev.ExportStartListToAscor (1,fn2);
          end;
        else
          ev.ExportStartListToAscor (0,ed.FileName);
        end;
      end;
  finally
    ed.Free;
  end;
end;

procedure TManageStartForm.set_StartList(const Value: TStartList);
begin
  if Value<> fStart then
    begin
      if fStart<> nil then
        fStart.RemoveNotifier (Handle);
      fStart:= Value;
      if fStart= nil then
        raise Exception.Create ('No start list!');
      CleanupDanglingStartShooters;
      UpdateStartInfo;
      fStart.AddNotifier (Handle);
    end;
end;

procedure TManageStartForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if fStart<> nil then
    fStart.RemoveNotifier (Handle);
  if fHeaderChanged then
    SaveHeaderControlToRegistry ('ManageStartHC',HeaderControl1);
  ModalResult:= fModalResult;
  WBC.ReleaseWindow (self);
  Action:= caFree;
end;

procedure TManageStartForm.lbEventsDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  ev: TStartListEventItem;
  l2,l1: integer;
  s: THeaderSection;
  c: TColor;
  ed: TSpeedupEventData;
  st, marker: string;
  r: TRect;
  x: integer;
begin
  with lbEvents.Canvas do
    begin
      l2:= TextHeight ('Mg');
      l1:= l2 div 2;
      FillRect (ARect);
      c:= Font.Color;
      if (Index>= 0) and (Index< fStart.Events.Count) then
        begin
          ev:= fStart.Events [Index];
          ed:= fEventsData [Index];

          Brush.Style:= bsClear;

          s:= HeaderControl1.Sections [0];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          Font.Style:= [fsBold];
          TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,IntToStr (ev.ProtocolNumber));

          s:= HeaderControl1.Sections [1];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          Font.Style:= [];
          if ev.Info<> fStart.Info then
            begin
              TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,fEventInfoStr);
            end;

          s:= HeaderControl1.Sections [2];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          if (fHoverIndex= Index) and (fHoverSection= 2) then
            begin
              Font.Style:= [fsBold,fsUnderline];
              Font.Color:= clBlue;
            end
          else
            begin
              Font.Style:= [];
            end;
          if ev.RegionsPoints.Count> 0 then
            st:= format (fRegionsPoints1Str,[ev.RegionsPoints.Count])
          else
            st:= fRegionsPoints0Str;
          st:= st+' ';
          if ev.DistrictsPoints.Count> 0 then
            st:= st+format (fDistrictsPoints1Str,[ev.DistrictsPoints.Count])
          else
            st:= st+fDistrictsPoints0Str;
          TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,st);
          if ev.PTeamsPoints.Count> 0 then
            st:= format (fPoints1Str,[ev.PTeamsPoints.Count])
          else
            st:= fPoints0Str;
          st:= st+' ';
          if ev.RTeamsPoints.Count> 0 then
            st:= st+format (fTeamsPoints1Str,[ev.RTeamsPoints.Count])
          else
            st:= st+fTeamsPoints0Str;
          TextRect (r,ARect.Left+s.Left+2,ARect.Top+2+l2,st);
          Font.Color:= c;

          s:= HeaderControl1.Sections [3];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          Font.Style:= [fsBold];
          TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,ev.Event.ShortName);
          x:= TextWidth (ev.Event.ShortName+' ');
          Font.Style:= [];
          if ev.CompetitionWithTens then
            begin
              c:= Font.Color;
              Font.Color:= clRed;
              marker:= fEventWithTensMarker;
          if (marker = '') or
            ((Length(marker) > 1) and (marker[1] = '[') and (marker[Length(marker)] = ']')) then
                marker:= ' ('+Language ['ManageStartForm.pmEvent..mnuTens']+')';
              TextRect (r,ARect.Left+s.Left+2+x,ARect.Top+2,marker);
              Font.Color:= c;
            end;
          TextRect (r,ARect.Left+s.Left+2,ARect.Top+l2+2,ev.Event.Name);
          if ed.start_no> 0 then
            begin
              Font.Style:= [fsBold];
              if odSelected in State then
                Font.Color:= clYellow
              else
                Font.Color:= clBlue;
              st:= format (fStartNoStr,[ed.start_no]);
              TextRect (r,ARect.Left+s.Right-2-TextWidth (st),ARect.Top+2,st);
              Font.Color:= c;
            end;

          s:= HeaderControl1.Sections [4];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          if ev.Relays.Count= 0 then
            begin
              Font.Color:= clRed;
              Font.Style:= [fsBold];
            end
          else
            begin
              Font.Color:= c;
              Font.Style:= [fsBold];
            end;
          TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,IntToStr (ed.rel_count));

          s:= HeaderControl1.Sections [5];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          if (ed.pos_count= 0) or (ed.pos_count< ev.Shooters.Count) then
            begin
              Font.Color:= clRed;
              Font.Style:= [fsBold];
            end
          else
            begin
              Font.Color:= c;
              Font.Style:= [fsBold];
            end;
          TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,IntToStr (ed.pos_count));

          s:= HeaderControl1.Sections [6];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          if ev.Shooters.Count= 0 then
            begin
              Font.Color:= clRed;
              Font.Style:= [fsBold];
            end
          else
            begin
              Font.Color:= c;
              Font.Style:= [fsBold];
            end;
          TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,IntToStr (ev.Shooters.Count));

          s:= HeaderControl1.Sections [7];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          if (ev.Shooters.Count> 0) and (ed.saved= ev.Shooters.Count) then
            begin
              if odSelected in State then
                Font.Color:= clYellow
              else
                Font.Color:= clBlue;
              Font.Style:= [fsBold];
              TextRect (r,ARect.Left+s.Left+2,ARect.Top+l1,fSavedStr);
            end;

          s:= HeaderControl1.Sections [8];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          if ed.comp_completed then
            begin
              if odSelected in State then
                Font.Color:= clYellow
              else
                Font.Color:= clGreen;
              Font.Style:= [];
              if ev.Event.FinalPlaces> 0 then
                begin
                  if ed.final_completed then
                    begin
                      TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,fFinishedStr);
                    end
                  else
                    begin
                      TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,fCompStr);
                    end;
                  if ed.shoot_offs> 0 then
                    begin
                      Font.Color:= clRed;
                      Font.Style:= [fsBold];
                      TextRect (r,ARect.Left+s.Left+2,ARect.Top+l2,format (fShootOffsStr,[ed.shoot_offs]));
                    end;
                end
              else
                begin
                  TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,fFinishedStr);
                end;
            end
          else if ed.started then
            begin
              if odSelected in State then
                Font.Color:= clYellow
              else
                Font.Color:= clGreen;
              Font.Style:= [fsBold];
              TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,fStartStr);
            end
          else if ed.lotsdrawn then
            begin
              if odSelected in State then
                Font.Color:= clWhite
              else
                Font.Color:= clBlack;
              Font.Style:= [];
              TextRect (r,ARect.Left+s.Left+2,ARect.Top+2,fLotsStr);
            end
          else
            begin
              if odSelected in State then
                Font.Color:= clWhite
              else
                Font.Color:= clBlack;
              Font.Style:= [];
              TextRect (r,ARect.Left+s.Left+2,ARect.Top+l1+2,fOpenStr);
            end;
        end
      else if Index= fStart.Events.Count then
        begin
          if not (odSelected in State) then
            Font.Color:= clBlue;
          Font.Style:= [fsBold];
          TextOut (ARect.Left+2,ARect.Top+l1+2,fAddEventStr);
        end;
    end;
end;

procedure TManageStartForm.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  LoadHeaderControlFromRegistry ('ManageStartHC',HeaderControl1);
  fHeaderChanged:= false;
  fHoverIndex:= -1;
  fHoverSection:= -1;
  WBC.RegisterWindow (self);
  UpdateFonts;
end;

procedure TManageStartForm.CleanupDanglingStartShooters;
  function IsValidShooter(const StartShooter: TStartListShooterItem): Boolean;
  begin
    Result := False;
    if StartShooter = nil then
      Exit;
    try
      Result := Assigned(StartShooter.Shooter) and (StartShooter.Shooter.Data = fStart.Data);
    except
      Result := False;
    end;
  end;
var
  i, j, k: Integer;
  StartShooter: TStartListShooterItem;
  EventItem: TStartListEventItem;
  EventShooter: TStartListEventShooterItem;
  NeedCleanup: Boolean;
begin
  if (fStart = nil) or (fStart.Shooters = nil) then
    Exit;

  for i := fStart.Shooters.Count - 1 downto 0 do
  begin
    StartShooter := fStart.Shooters.Items[i];
    if not IsValidShooter(StartShooter) then
    begin
      for j := fStart.Events.Count - 1 downto 0 do
      begin
        EventItem := fStart.Events[j];
        for k := EventItem.Shooters.Count - 1 downto 0 do
        begin
          EventShooter := EventItem.Shooters.Items[k];
          NeedCleanup := False;
          try
            NeedCleanup := (EventShooter.StartListShooter = StartShooter) or
              (Assigned(EventShooter.Shooter) and (EventShooter.Shooter = StartShooter.Shooter));
          except
            NeedCleanup := True;
          end;
          if NeedCleanup then
            EventShooter.Free;
        end;
      end;
      fStart.Shooters.Delete(StartShooter);
    end;
  end;
end;

function TManageStartForm.NormalizeAllShooterSurnames: Integer;
begin
  if (fStart <> nil) and (fStart.Data <> nil) then
    Result := fStart.Data.NormalizeAllShooterSurnames
  else
    Result := 0;
end;

procedure TManageStartForm.UpdateFonts;
var
  bh,w,w1: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbEvents.Canvas.Font:= lbEvents.Font;
  lbEvents.ItemHeight:= lbEvents.Canvas.TextHeight ('Mg')*2+4;
  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
  w:= lNameC.Width;
  w1:= lChampC.Width;
  if w1> w then
    w:= w1;
  w1:= lNumsC.Width;
  if w1> w then
    w:= w1;
  w1:= lTownC.Width;
  if w1> w then
    w:= w1;
  w1:= lRangeC.Width;
  if w1> w then
    w:= w1;
  lNameC.Top:= 8;
  lNameC.Left:= 16+w-lNameC.Width;
  lName.Font:= Font;
  lName.Font.Style:= [fsBold];
  lName.Left:= w+24;
  lName.Top:= lNameC.Top;
  lChampC.Top:= lNameC.Top+lNameC.Height;
  lChampC.Left:= 16+w-lChampC.Width;
  lChamp.Left:= w+24;
  lChamp.Top:= lChampC.Top;
  lChamp.Font:= Font;
  lChamp.Font.Style:= [fsBold];
  lNumsC.Top:= lChampC.Top+lChampC.Height;
  lNumsC.Left:= 16+w-lNumsC.Width;
  lStartNumbers.Top:= lNumsC.Top;
  lStartNumbers.Left:= w+24;
  lStartNumbers.Font:= Font;
  lStartNumbers.Font.Style:= [fsBold];
  lTownC.Top:= lNumsC.Top+lNumsC.Height;
  lTownC.Left:= 16+w-lTownC.Width;
  lTown.Top:= lTownC.Top;
  lTown.Left:= w+24;
  lTown.Font:= Font;
  lTown.Font.Style:= [fsBold];
  lRangeC.Top:= lTownC.Top+lTownC.Height;
  lRangeC.Left:= 16+w-lRangeC.Width;
  lRange.Top:= lRangeC.Top;
  lRange.Left:= w+24;
  lRange.Font:= Font;
  lRange.Font.Style:= [fsBold];
  pnlStart.ClientHeight:= lRangeC.Top+lRangeC.Height+8;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnChangeInfo.ClientWidth:= Canvas.TextWidth (btnChangeInfo.Caption)+32;
  btnChangeInfo.ClientHeight:= bh;
  btnPrint.ClientWidth:= Canvas.TextWidth (btnPrint.Caption)+32;
  btnPrint.ClientHeight:= bh;
  btnImportApplications.ClientWidth:= Canvas.TextWidth (btnImportApplications.Caption)+32;
  btnImportApplications.ClientHeight:= bh;
  btnNormalizeSurnames.ClientWidth := Canvas.TextWidth(btnNormalizeSurnames.Caption)+32;
  btnNormalizeSurnames.ClientHeight := bh;
  if pnlStart.ClientHeight< 8+btnChangeInfo.Height+8+btnPrint.Height+8 then
    pnlStart.ClientHeight:= 8+btnChangeInfo.Height+8+btnPrint.Height+8;
  w:= lTeamsC.Width;
  w1:= lPerTeamC.Width;
  if w1> w then
    w:= w1;
  lTeamsC.Top:= 8;
  lTeamsC.Left:= w+16-lTeamsC.Width;
  lTeams.Left:= w+24;
  lTeams.Top:= lTeamsC.Top;
  lTeams.Font:= Font;
  lTeams.Font.Style:= [fsBold];
  lPerTeamC.Left:= w+16-lPerTeamC.Width;
  lPerTeamC.Top:= lTeamsC.Top+lTeamsC.Height;
  lPerTeam.Left:= w+24;
  lPerTeam.Top:= lPerTeamC.Top;
  lPerTeam.Font:= Font;
  lPerTeam.Font.Style:= [fsBold];
  pnlTeams.ClientHeight:= lPerTeam.Top+lPerTeam.Height+8;
  btnTeams.ClientWidth:= Canvas.TextWidth (btnTeams.Caption)+32;
  btnTeams.ClientHeight:= bh;
  if btnTeams.Height+16> pnlTeams.ClientHeight then
    pnlTeams.ClientHeight:= btnTeams.Height+16;
  lQPointsC.Top:= 8;
  lQPointsC.Left:= 16;
  lQualificationPoints.Top:= lQPointsC.Top;
  lQualificationPoints.Left:= lQPointsC.Left+lQPointsC.Width+8;
  lQualificationPoints.Font:= Font;
  lQualificationPoints.Font.Style:= [fsBold];
  pnlQPoints.ClientHeight:= lQPointsC.Top+lQPointsC.Height+8;
  btnQualificationPoints.ClientHeight:= bh;
  btnQualificationPoints.ClientWidth:= Canvas.TextWidth (btnQualificationPoints.Caption)+32;
  if pnlQPoints.ClientHeight< btnQualificationPoints.Height+16 then
    pnlQPoints.ClientHeight:= btnQualificationPoints.Height+16;
end;

procedure TManageStartForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
  fAddEventStr:= Language ['ManageStartForm.AddEventStr'];
  fEventInfoStr:= Language ['ManageStartForm.EventInfoStr'];
  fPoints0Str:= Language ['ManageStartForm.Points0Str'];
  fPoints1Str:= Language ['ManageStartForm.Points1Str'];
  fTeamsPoints0Str:= Language ['ManageStartForm.TeamsPoints0Str'];
  fTeamsPoints1Str:= Language ['ManageStartForm.TeamsPoints1Str'];
  fStartNoStr:= Language ['StartNo'];
  fSavedStr:= Language ['ManageStartForm.SavedStr'];
  fFinishedStr:= Language ['ManageStartForm.FinishedStr'];
  fCompStr:= Language ['ManageStartForm.CompStr'];
  fStartStr:= Language ['ManageStartForm.StartStr'];
  fLotsStr:= Language ['ManageStartForm.LotsStr'];
  fOpenStr:= Language ['ManageStartForm.OpenStr'];
  fShootOffsStr:= Language ['ManageStartForm.ShootOffsStr'];
  fRegionsPoints0Str:= Language ['ManageStartForm.RegionsPoints0Str'];
  fRegionsPoints1Str:= Language ['ManageStartForm.RegionsPoints1Str'];
  fDistrictsPoints0Str:= Language ['ManageStartForm.DistrcitsPoints0Str'];
  fDistrictsPoints1Str:= Language ['ManageStartForm.DistrcitsPoints1Str'];
  fEventWithTensMarker:= Language ['ManageStartForm.EventWithTensMarker'];
  if (fEventWithTensMarker <> '') and (fEventWithTensMarker[1] = '[') and
     (fEventWithTensMarker[Length(fEventWithTensMarker)] = ']') then
    fEventWithTensMarker:= ' ('+Language ['ManageStartForm.pmEvent..mnuTens']+')';
end;

procedure TManageStartForm.UpdateStartInfo;
var
  i: integer;
  ev: TStartListEventItem;
  teams: TStrings;
begin
  for i:= 0 to lbEvents.ControlCount-1 do
    lbEvents.Controls [i].Free;

  lbEvents.Clear;
  SetLength (fEventsData,fStart.Events.Count);
  for i:= 0 to fStart.Events.Count-1 do
    begin
      ev:= fStart.Events [i];
      lbEvents.Items.Add (ev.Event.ShortName);
      with fEventsData [i] do
        begin
          started:= ev.IsStarted;
          lotsdrawn:= ev.IsLotsDrawn;
          rel_count:= ev.Relays.Count;
          pos_count:= ev.PositionsCount;
          comp_completed:= ev.IsCompleted;
          start_no:= ev.StartNumber;
          final_completed:= ev.IsFinalOk;
          saved:= ev.Saved;
          shoot_offs:= ev.Fights;
        end;
    end;

  lbEvents.Items.Add (fAddEventStr);
  lbEvents.ItemIndex:= 0;
  UpdateStartListInfo;
  
  // Обновляем состояние меню после установки начального выбора
  lbEventsClick(lbEvents);

  teams:= fStart.GetTeams (false,nil);
  if teams.Count= 0 then
    lTeams.Caption:= Language ['ManageStartForm.Teams0']
  else
    begin
      lTeams.Caption:= format (Language ['ManageStartForm.Teams1'],[teams.Count]);
    end;
  teams.Free;

  lPerTeam.Caption:= IntToStr (fStart.ShootersPerTeam);
  if fStart.QualificationPoints.Count= 0 then
    lQualificationPoints.Caption:= Language ['ManageStartForm.Points0']
  else
    lQualificationPoints.Caption:= Language ['ManageStartForm.Points1'];
end;

procedure TManageStartForm.UpdateStartListInfo;
begin
  lName.Caption:= fStart.Info.CaptionText;
  lChamp.Caption:= fStart.Info.ChampionshipName;
  if fStart.StartNumbers then
    lStartNumbers.Caption:= Language ['ManageStartForm.StartNumbers1']
  else
    lStartNumbers.Caption:= Language ['ManageStartForm.StartNumbers0'];
  btnPrint.Enabled:= fStart.StartNumbers;
  lTown.Caption:= fStart.Info.Town;
  lRange.Caption:= fStart.Info.ShootingRange;
  Caption:= fStart.Info.CaptionText;
  
  // Обновляем состояние меню
  pmEventPopup(pmEvent);
end;

procedure TManageStartForm.lbEventsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
    VK_F2: begin
      Key:= 0;
      if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
        OpenCompetitionResults (lbEvents.ItemIndex);
    end;
    VK_F3: begin
      Key:= 0;
      if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
        ViewShooters (lbEvents.ItemIndex);
    end;
    VK_F4: begin
      if Shift= [] then
        begin
          Key:= 0;
          if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
            DrawLots (lbEvents.ItemIndex);
        end;
    end;
    VK_F5: begin
      Key:= 0;
      if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
        DoStart (lbEvents.ItemIndex);
    end;
    VK_F6: begin
      Key:= 0;
      if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
        PrintStartList (lbEvents.ItemIndex);
    end;
    VK_F7: begin
      Key:= 0;
      btnChangeInfoClick (self);
    end;
    VK_F8: begin
      Key:= 0;
      if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
        PrintCompetitionList (lbEvents.ItemIndex);
    end;
    VK_F9: begin
      Key:= 0;
      if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
        EditEventPoints (lbEvents.ItemIndex);
    end;
{    VK_RETURN: begin
      Key:= 0;
      lbEventsDblClick (self);
    end;}
    VK_DELETE: begin
      Key:= 0;
      if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
        DeleteEvent (lbEvents.ItemIndex);
    end;
    VK_UP: begin
      if Shift= [ssShift] then
        begin
          Key:= 0;
          if (lbEvents.ItemIndex> 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
            MoveEventUp (lbEvents.ItemIndex);
        end;
    end;
    VK_DOWN: begin
      if Shift= [ssShift] then
        begin
          Key:= 0;
          if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count-1) then
            MoveEventDown (lbEvents.ItemIndex);
        end;
    end;
 end;
end;

procedure TManageStartForm.btnChangeInfoClick(Sender: TObject);
var
  si: TStartInfoDialog;
begin
  si:= TStartInfoDialog.Create (self);
  si.Info:= fStart.Info;
  si.Caption:= fStart.Info.CaptionText;
  si.Execute;
  si.Free;
  lbEvents.SetFocus;
end;

procedure TManageStartForm.EditRelays(Index: integer);
var
  ev: TStartListEventItem;
  rs: TRelaysSetupDialog;
//  res: integer;
begin
  if (Index< 0) or (Index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [Index];
  rs:= TRelaysSetupDialog.Create (self);
  rs.Caption:= format (Language ['EventRelaysCaption'],[ev.Event.ShortName,ev.Event.Name]);
  rs.StartEvent:= ev;
  rs.Execute;
  rs.Free;
  UpdateStartInfo;
  lbEvents.ItemIndex:= ev.Index;
end;

procedure TManageStartForm.AcquireSiusData(index: integer; AFinal: boolean);
var
  ev: TStartListEventItem;
  af: TSiusForm;
begin
  if (index< 0) or (index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events.Items [index];
  if not ev.IsLotsDrawn then
    begin
      exit;
    end;
  af:= TSiusForm.Create (self);
  af.FinalMode:= AFinal;
  af.StartEvent:= ev;
  af.Execute;
  af.Free;
  UpdateStartInfo;
  lbEvents.ItemIndex:= ev.Index;
end;

procedure TManageStartForm.AddEvent;
var
  ev: TStartListEventItem;
  se: TSelectEventDialog;
begin
  se:= TSelectEventDialog.Create (self);
  se.Data:= fStart.Data;
  if se.Execute then
    begin
      ev:= fStart.Events.Add;
      ev.ProtocolNumber:= fStart.GetNextProtocolNumber;
      ev.Event:= se.Event;
//      ev.CreateShootingEvent (se.Event);
      UpdateStartInfo;
      lbEvents.ItemIndex:= ev.Index;
    end;
  se.Free;
end;

procedure TManageStartForm.DeleteEvent(Index: integer);
var
  ev: TStartListEventItem;
  res: integer;
  idx: integer;
begin
  ev:= fStart.Events [Index];
  res:= MessageDlg (format (Language ['DeleteStartEventPrompt'],[ev.Event.ShortName,ev.Event.Name]),mtConfirmation,[mbYes,mbNo],0);
  if res= idYes then
    begin
      idx:= lbEvents.ItemIndex;
//      ev.DestroyShootingEventIfEmpty;
      fStart.Events.Delete (Index);
      UpdateStartInfo;
      lbEvents.ItemIndex:= idx;
    end;
end;

procedure TManageStartForm.lbEventsDblClick(Sender: TObject);
begin
  if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
    EditRelays (lbEvents.ItemIndex)
  else if lbEvents.ItemIndex= fStart.Events.Count then
    AddEvent;
end;

procedure TManageStartForm.pnlStartResize(Sender: TObject);
begin
  btnPrint.Left:= pnlStart.ClientWidth-btnPrint.Width-16;
  btnPrint.Top:= pnlStart.ClientHeight-8-btnPrint.Height;
  btnChangeInfo.Left:= pnlStart.ClientWidth-btnChangeInfo.Width-16;
  btnChangeInfo.Top:= btnPrint.Top-8-btnChangeInfo.Height;
  btnImportApplications.Top:= btnPrint.Top;
  btnImportApplications.Left:= btnPrint.Left-btnImportApplications.Width-8;
  btnNormalizeSurnames.Top:= btnPrint.Top;
  btnNormalizeSurnames.Left:= btnImportApplications.Left-btnNormalizeSurnames.Width-8;
  if btnNormalizeSurnames.Left < 16 then
  begin
    btnNormalizeSurnames.Left := 16;
    btnImportApplications.Left := btnNormalizeSurnames.Left + btnNormalizeSurnames.Width + 8;
  end;
  if btnImportApplications.Left < 16 then
    btnImportApplications.Left := 16;
end;

procedure TManageStartForm.pnlTeamsResize(Sender: TObject);
begin
  btnTeams.Left:= pnlTeams.ClientWidth-btnTeams.Width-16;
  btnTeams.Top:= pnlTeams.ClientHeight-btnTeams.Height-8;
end;

procedure TManageStartForm.btnTeamsClick(Sender: TObject);
var
  TD: TTeamsSetupDialog;
begin
  TD:= TTeamsSetupDialog.Create (self);
  TD.Start:= fStart;
  TD.Execute;
  TD.Free;
  UpdateStartInfo;
  lbEvents.SetFocus;
end;

procedure TManageStartForm.btnPrintClick(Sender: TObject);
begin
  PrintAllStartNumbers;
  lbEvents.SetFocus;
end;

procedure TManageStartForm.btnImportApplicationsClick(Sender: TObject);
const
  MaxEmptyRowsBeforeStop = 5;
  ValidQualifications: array [0..6] of string = ('I','II','III','КМС','МС','МСМК','ЗМС');
  FirstEventColumnIndex = 27; // Колонка AA в Excel
  LastEventColumnIndex = 62; // Колонка BJ: упражнения дальше не анализируем
type
  TEventColumnInfo = record
    ColumnIndex: Integer;
    Header: string;
  end;
  TStringArray = array of string;
  TEventStatInfo = record
    Name: string;
    Count: Integer;
  end;
var
  OpenDialog: TOpenDialog;
  ExcelApp, Workbook, Worksheet: OleVariant;
  Row, Col: Integer;
  ProcessedCount, ImportedCount, SkippedCount: Integer;
  SkippedList, UpdatedList, NotProcessedList, AnomalyList, BirthConflictList, LogLines: TStringList;
  EventAssignedList, EventSkippedList, EventCreatedList: TStringList;
  LastName, FirstName, Patronymic, Qualification, Region, GenderStr, WeaponStr, City, Club: string;
  BirthDateStr, FullName, RawQualification, HeaderCellValue: string;
  BirthDate: TDateTime;
  Gender: TGender;
  Weapon: TWeaponType;
  Group, PartialGroup: TGroupItem;
  Shooter, ExistingShooter, PartialMatchShooter: TShooterItem;
  QualificationEnum: TQualificationItem;
  OldQualification: TQualificationItem;
  ResultMsg, ShortSummary, ChangeDetails, AttentionLine, OldValue: string;
  I, LinesToShow: Integer;
  WorkbookOpened: Boolean;
  Success: Boolean;
  EmptyRowCounter: Integer;
  BirthValue: Variant;
  RegionInfo, CityInfo, ClubInfo: string;
  CreatedGroups: Integer;
  UpdatedCount, NotProcessedCount, BirthConflictCount: Integer;
  LogFileName: string;
  BirthYear: Word;
  DetectedPartialWeapon: TWeaponType;
  HasPartialWeapon, BirthMatches: Boolean;
  UsedRange: OleVariant;
  EventColumns: array of TEventColumnInfo;
  EventAssignmentCount, EventSkippedCount: Integer;
  EventParticipantStats: TStringList;
  EventStats: array of TEventStatInfo;
  SurnameNormalizedCount: Integer;
  HeaderRow, DataStartRow, UsedCols: Integer;

  function Normalize(const S: string): string;
  begin
    Result := UpperCase(Trim(S));
  end;

  function TryNormalizeQualification(const Value: string; out NormalizedValue: string): boolean;
  var
    Prepared: string;
  begin
    Prepared := Normalize(Value);
    Prepared := StringReplace(Prepared, ' РАЗРЯД', '', [rfReplaceAll]);
    Prepared := StringReplace(Prepared, 'РАЗРЯД', '', [rfReplaceAll]);
    Prepared := StringReplace(Prepared, 'РАЗР.', '', [rfReplaceAll]);
    Prepared := Trim(Prepared);

    if Prepared = '' then
    begin
      NormalizedValue := '';
      Exit(False);
    end;

    if (Prepared = '1') or (Prepared = 'I') then
      NormalizedValue := 'I'
    else if (Prepared = '2') or (Prepared = 'II') then
      NormalizedValue := 'II'
    else if (Prepared = '3') or (Prepared = 'III') then
      NormalizedValue := 'III'
    else if Prepared = 'КМС' then
      NormalizedValue := 'КМС'
    else if Prepared = 'МС' then
      NormalizedValue := 'МС'
    else if Prepared = 'МСМК' then
      NormalizedValue := 'МСМК'
    else if Prepared = 'ЗМС' then
      NormalizedValue := 'ЗМС'
    else
    begin
      NormalizedValue := Prepared;
      Exit(False);
    end;
    Result := True;
  end;

  function IsQualificationAllowed(const Value: string; out NormalizedValue: string): boolean;
  var
    Candidate: string;
    J: Integer;
  begin
    NormalizedValue := '';
    if not TryNormalizeQualification(Value, Candidate) then
      Exit(False);
    for J := Low(ValidQualifications) to High(ValidQualifications) do
      if Candidate = ValidQualifications[J] then
      begin
        NormalizedValue := Candidate;
        Exit(True);
      end;
    Result := False;
  end;

  function TryParseBirthDate(const Value: Variant; out DateValue: TDateTime; out Formatted: string): boolean;
  var
    S: string;
    FS: TFormatSettings;
  begin
    Result := False;
    if VarIsNull(Value) or VarIsEmpty(Value) then
      Exit;
    try
      if VarIsType(Value, varDate) or VarIsNumeric(Value) then
        DateValue := VarToDateTime(Value)
      else
      begin
        S := Trim(VarToStr(Value));
        if S = '' then
          Exit;
        FS := FormatSettings;
        FS.DateSeparator := '.';
        FS.ShortDateFormat := 'dd.mm.yyyy';
        if not TryStrToDate(S, DateValue, FS) then
        begin
          FS.DateSeparator := '/';
          FS.ShortDateFormat := 'dd/mm/yyyy';
          if not TryStrToDate(S, DateValue, FS) then
          begin
            FS.DateSeparator := '-';
            FS.ShortDateFormat := 'yyyy-mm-dd';
            if not TryStrToDate(S, DateValue, FS) then
              Exit;
          end;
        end;
      end;
      Formatted := FormatDateTime('dd.mm.yyyy', DateValue);
      Result := True;
    except
      Result := False;
    end;
  end;

  function TryParseGender(const Value: string; out AGender: TGender): boolean;
  var
    Norm: string;
  begin
    Norm := Normalize(Value);
    if (Norm = 'М') or (Norm = 'M') or (Norm = 'МУЖ') or (Norm = 'МУЖЧИНА') or (Norm = 'МУЖСКОЙ') or (Norm = 'MALE') then
    begin
      AGender := Male;
      Result := True;
    end
    else if (Norm = 'Ж') or (Norm = 'F') or (Norm = 'ЖЕН') or (Norm = 'ЖЕНЩИНА') or (Norm = 'ЖЕНСКИЙ') or (Norm = 'FEMALE') then
    begin
      AGender := Female;
      Result := True;
    end
    else
      Result := False;
  end;

  function TryParseWeapon(const Value: string; out AWeapon: TWeaponType): boolean;
  var
    Norm: string;
  begin
    Norm := Normalize(Value);
    if (Norm = 'П') or (Norm = 'ПИСТОЛЕТ') or (Norm = 'P') or (Norm = 'PISTOL') then
    begin
      AWeapon := wtPistol;
      Result := True;
    end
    else if (Norm = 'В') or (Norm = 'ВИНТОВКА') or (Norm = 'R') or (Norm = 'RIFLE') then
    begin
      AWeapon := wtRifle;
      Result := True;
    end
    else if (Norm = 'ДМ') or (Pos('ДВИЖ', Norm) > 0) or (Norm = 'DM') or (Norm = 'MOVING') then
    begin
      AWeapon := wtMoving;
      Result := True;
    end
    else
      Result := False;
  end;

  function WeaponName(AWeapon: TWeaponType): string;
  begin
    case AWeapon of
      wtRifle: Result := 'ВИНТОВКА';
      wtPistol: Result := 'ПИСТОЛЕТ';
      wtMoving: Result := 'ДВИЖУЩАЯСЯ МИШЕНЬ';
    else
      Result := '';
    end;
  end;

  function GenderName(AGender: TGender): string;
  begin
    case AGender of
      Male: Result := 'МУЖЧИНЫ';
      Female: Result := 'ЖЕНЩИНЫ';
    else
      Result := '';
    end;
  end;

  function FindGroupFor(AWeapon: TWeaponType; AGender: TGender): TGroupItem;
  var
    TargetName, UpperTarget, CandidateUpper: string;
    Index: Integer;
    WeaponNameUpper, GenderNameUpper: string;
  begin
    Result := nil;
    WeaponNameUpper := Normalize(WeaponName(AWeapon));
    GenderNameUpper := Normalize(GenderName(AGender));
    TargetName := WeaponName(AWeapon) + ' ' + GenderName(AGender);
    UpperTarget := Normalize(TargetName);
    for Index := 0 to fStart.Data.Groups.Count - 1 do
      if Normalize(fStart.Data.Groups[Index].Name) = UpperTarget then
        Exit(fStart.Data.Groups[Index]);
    for Index := 0 to fStart.Data.Groups.Count - 1 do
    begin
      CandidateUpper := Normalize(fStart.Data.Groups[Index].Name);
      if (Pos(WeaponNameUpper, CandidateUpper) > 0) and (Pos(GenderNameUpper, CandidateUpper) > 0) then
        Exit(fStart.Data.Groups[Index]);
    end;
  end;

  function EnsureGroupFor(AWeapon: TWeaponType; AGender: TGender; ARow: Integer): TGroupItem;
  var
    TargetName: string;
  begin
    Result := FindGroupFor(AWeapon, AGender);
    if Result = nil then
    begin
      TargetName := WeaponName(AWeapon) + ' ' + GenderName(AGender);
      Result := fStart.Data.Groups.Add;
      Result.Name := TargetName;
      Inc(CreatedGroups);
      if LogLines <> nil then
        LogLines.Add(Format('Строка %d: создана новая группа "%s"', [ARow, TargetName]));
    end;
  end;

  function SaveImportLog(const Lines: TStrings): string;
  var
    DataFile, Dir, BaseName: string;
    TimeStamp: string;
    FS: TFileStream;
    Utf8: UTF8String;
  begin
    Result := '';
    if (Lines = nil) or (Lines.Count = 0) then
      Exit;

    DataFile := GetCurrentDataFileName;
    if DataFile = '' then
      DataFile := OpenDialog.FileName;

    Dir := ExtractFileDir(DataFile);
    if Dir = '' then
      Dir := GetCurrentDir;

    BaseName := ChangeFileExt(ExtractFileName(DataFile), '');
    if BaseName = '' then
      BaseName := 'import';

    TimeStamp := FormatDateTime('yyyymmdd_hhnnss', Now);
    Result := IncludeTrailingPathDelimiter(Dir) +
      Format('%s_import_%s.log', [BaseName, TimeStamp]);

    try
      FS := TFileStream.Create(Result, fmCreate or fmOpenWrite or fmShareDenyWrite);
      try
        Utf8 := UTF8Encode(Lines.Text);
        if Length(Utf8) > 0 then
          FS.WriteBuffer(PAnsiChar(Utf8)^, Length(Utf8));
      finally
        FS.Free;
      end;
    except
      Result := '';
    end;
  end;

  function FormatFullName(const ASurname, AName, APatronymic: string): string;
  begin
    Result := Trim(ASurname);
    if AName <> '' then
      Result := Trim(Result + ' ' + AName);
    if APatronymic <> '' then
      Result := Trim(Result + ' ' + APatronymic);
  end;

  function SameTextTrim(const A, B: string): boolean;
  var
    TrimA, TrimB: string;
  begin
    TrimA := Trim(A);
    TrimB := Trim(B);
    Result := (TrimA = TrimB) and (A = TrimA) and (B = TrimB);
  end;

  function SameTextRelaxed(const A, B: string): boolean;
  begin
    Result := AnsiSameText(Trim(A), Trim(B));
  end;

  function PatronymicMatches(const Existing, Incoming: string): boolean;
  begin
    if (Trim(Existing) = '') or (Trim(Incoming) = '') then
      Exit(True);
    Result := AnsiSameText(Trim(Existing), Trim(Incoming));
  end;

  function IsBirthDateKnown(const Value: string): boolean;
  var
    Dummy: TDateTime;
    FS: TFormatSettings;
    S: string;
  begin
    S := Trim(Value);
    if S = '' then
      Exit(False);
    FS := FormatSettings;
    FS.DateSeparator := '.';
    FS.ShortDateFormat := 'dd.mm.yyyy';
    Result := TryStrToDate(S, Dummy, FS);
  end;

  function BirthInfoMatches(AShooter: TShooterItem; const IncomingBirthStr: string; IncomingBirthYear: Word): Boolean;
  var
    ExistingBirth: string;
  begin
    ExistingBirth := Trim(AShooter.BirthFullStr);
    if (ExistingBirth <> '') and (Trim(IncomingBirthStr) <> '') then
      Exit(ExistingBirth = Trim(IncomingBirthStr));

    if ExistingBirth = '' then
    begin
      if (IncomingBirthYear <> 0) and (AShooter.BirthYear <> 0) then
        Exit(AShooter.BirthYear = IncomingBirthYear)
      else if AShooter.BirthYear = 0 then
        Exit(True);
    end;

    Result := False;
  end;

  function FormatBirthInfo(const BirthStr: string; BirthYearValue: Word): string;
  begin
    if Trim(BirthStr) <> '' then
      Result := Trim(BirthStr)
    else if BirthYearValue <> 0 then
      Result := IntToStr(BirthYearValue)
    else
      Result := '<нет>';
  end;

  function FindDuplicateInGroup(AGroup: TGroupItem): TShooterItem;
  var
    Idx: Integer;
    Existing: TShooterItem;
  begin
    Result := nil;
    for Idx := 0 to AGroup.Shooters.Count - 1 do
    begin
      Existing := AGroup.Shooters[Idx];
      if AnsiSameText(Existing.Surname, LastName) and
         AnsiSameText(Existing.Name, FirstName) and
         PatronymicMatches(Existing.StepName, Patronymic) then
      begin
        if Trim(Existing.BirthFullStr) = Trim(BirthDateStr) then
        begin
          Result := Existing;
          Exit;
        end;

        if not IsBirthDateKnown(Existing.BirthFullStr) then
        begin
          if (BirthYear <> 0) and
             ((Existing.BirthYear = 0) or (Existing.BirthYear = BirthYear)) and
             SameTextRelaxed(Existing.RegionAbbr1, Region) and
             SameTextRelaxed(Existing.Town, City) then
          begin
            Result := Existing;
            Exit;
          end;
        end;
      end;
    end;
  end;

  function IsRowCompletelyEmpty: boolean;
  begin
    Result := (LastName = '') and (FirstName = '') and (RawQualification = '') and
      ((VarIsNull(BirthValue) or VarIsEmpty(BirthValue) or (Trim(VarToStr(BirthValue)) = ''))) and
      (GenderStr = '') and (WeaponStr = '') and (Region = '') and (City = '') and (Club = '');
  end;

  function FindQualificationItem(const Normalized, Original: string): TQualificationItem;
  var
    CandidateNormalized: string;
    Index: Integer;
  begin
    Result := nil;
    Result := fStart.Data.Qualifications.FindByName(Normalized);
    if Result <> nil then
      Exit;

    if Original <> Normalized then
    begin
      Result := fStart.Data.Qualifications.FindByName(Original);
      if Result <> nil then
        Exit;
    end;

    if Normalized = 'I' then
    begin
      Result := fStart.Data.Qualifications.FindByName('1');
      if Result <> nil then
        Exit;
    end
    else if Normalized = 'II' then
    begin
      Result := fStart.Data.Qualifications.FindByName('2');
      if Result <> nil then
        Exit;
    end
    else if Normalized = 'III' then
    begin
      Result := fStart.Data.Qualifications.FindByName('3');
      if Result <> nil then
        Exit;
    end;

    for Index := 0 to fStart.Data.Qualifications.Count - 1 do
      if IsQualificationAllowed(fStart.Data.Qualifications.Items[Index].Name, CandidateNormalized) and
         (CandidateNormalized = Normalized) then
        Exit(fStart.Data.Qualifications.Items[Index]);
  end;

  function DisplayValue(const S: string): string;
  begin
    if Trim(S) = '' then
      Result := '<пусто>'
    else
      Result := S;
  end;

  function QualificationDisplay(Value: TQualificationItem): string;
  begin
    if Value <> nil then
      Result := Value.Name
    else
      Result := '<нет>';
  end;

  function DetectWeaponFromGroup(AGroup: TGroupItem; out AWeapon: TWeaponType): boolean;
  var
    UpperName: string;
  begin
    Result := False;
    AWeapon := wtPistol;
    if AGroup = nil then
      Exit;
    UpperName := Normalize(AGroup.Name);
    if Pos('ПИСТОЛ', UpperName) > 0 then
    begin
      AWeapon := wtPistol;
      Exit(True);
    end;
    if Pos('ВИНТОВ', UpperName) > 0 then
    begin
      AWeapon := wtRifle;
      Exit(True);
    end;
    if (Pos('ДВИЖ', UpperName) > 0) or (Pos('MOVING', UpperName) > 0) then
    begin
      AWeapon := wtMoving;
      Exit(True);
    end;
  end;

  function FindShooterAcrossGroups(out AGroup: TGroupItem; out AWeapon: TWeaponType;
    out WeaponDetected: Boolean; out BirthMatches: Boolean): TShooterItem;
  var
    GroupIdx, ShooterIdx: Integer;
    CandidateGroup: TGroupItem;
    Candidate: TShooterItem;
    SameRegion, SameCity: Boolean;
  begin
    Result := nil;
    AGroup := nil;
    WeaponDetected := False;
    BirthMatches := False;
    AWeapon := wtPistol;
    for GroupIdx := 0 to fStart.Data.Groups.Count - 1 do
    begin
      CandidateGroup := fStart.Data.Groups[GroupIdx];
      for ShooterIdx := 0 to CandidateGroup.Shooters.Count - 1 do
      begin
        Candidate := CandidateGroup.Shooters[ShooterIdx];
        if AnsiSameText(Candidate.Surname, LastName) and
           AnsiSameText(Candidate.Name, FirstName) and
           PatronymicMatches(Candidate.StepName, Patronymic) then
        begin
          SameRegion := SameTextRelaxed(Candidate.RegionAbbr1, Region);
          SameCity := SameTextRelaxed(Candidate.Town, City);
          if SameRegion and SameCity then
          begin
            Result := Candidate;
            AGroup := CandidateGroup;
            WeaponDetected := DetectWeaponFromGroup(CandidateGroup, AWeapon);
            BirthMatches := BirthInfoMatches(Candidate, BirthDateStr, BirthYear);
            Exit;
          end;
        end;
      end;
    end;
  end;

  procedure AppendChange(var Target: string; const FieldName, OldValue, NewValue: string);
  var
    Entry: string;
  begin
    Entry := Format('%s: %s -> %s', [FieldName, DisplayValue(OldValue), DisplayValue(NewValue)]);
    if Target <> '' then
      Target := Target + '; ';
    Target := Target + Entry;
  end;

  function SanitizeEventKey(const Value: string): string;
  const
    SanitizeSkipChars: TSysCharSet = [' ', '.', ',', ';', ':', '"', '''', '(', ')', '[', ']', '{', '}', '/', '\', '-', '_', '+', #9, #10, #13];
  var
    i: Integer;
    ch: Char;
    Temp: string;
  begin
    Temp := '';
    for i := 1 to Length(Value) do
    begin
      ch := Value[i];
      case ch of
        '–','—':
          Continue;
        'х','Х','x','X':
          ch := 'X';
        'ё','Ё':
          ch := 'Е';
      end;
      if CharInSet(ch, SanitizeSkipChars) then
        Continue;
      Temp := Temp + ch;
    end;
    Result := Normalize(Temp);
  end;

  function BuildEventCandidateKeys(const Header: string; AGender: TGender): TStringArray;
  const
    GenderSuffixUpper: array[TGender] of string = ('М','Ж');
    GenderSuffixLower: array[TGender] of string = ('м','ж');
    GenderFullUpper: array[TGender] of string = ('МУЖЧИНЫ','ЖЕНЩИНЫ');
    GenderFullLower: array[TGender] of string = ('мужчины','женщины');
    GenderShortUpper: array[TGender] of string = ('МУЖ','ЖЕН');
    GenderShortLower: array[TGender] of string = ('муж','жен');
  var
    Base: string;
    procedure AddCandidate(const Value: string);
    var
      Key: string;
      idx: Integer;
    begin
      if Trim(Value) = '' then
        Exit;
      Key := SanitizeEventKey(Value);
      if Key = '' then
        Exit;
      for idx := Low(Result) to High(Result) do
        if Result[idx] = Key then
          Exit;
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := Key;
    end;
  begin
    SetLength(Result, 0);
    Base := Trim(Header);
    if Base = '' then
      Exit;
    AddCandidate(Base);
    AddCandidate(Base + GenderSuffixUpper[AGender]);
    AddCandidate(Base + GenderSuffixLower[AGender]);
    AddCandidate(Base + ' ' + GenderSuffixUpper[AGender]);
    AddCandidate(Base + ' ' + GenderSuffixLower[AGender]);
    AddCandidate(Base + ' (' + GenderSuffixUpper[AGender] + ')');
    AddCandidate(Base + ' (' + GenderSuffixLower[AGender] + ')');
    AddCandidate(Base + ' ' + GenderFullUpper[AGender]);
    AddCandidate(Base + ' ' + GenderFullLower[AGender]);
    AddCandidate(Base + ' ' + GenderShortUpper[AGender]);
    AddCandidate(Base + ' ' + GenderShortLower[AGender]);
    AddCandidate(GenderSuffixUpper[AGender] + ' ' + Base);
    AddCandidate(GenderSuffixLower[AGender] + ' ' + Base);
    AddCandidate(GenderFullUpper[AGender] + ' ' + Base);
    AddCandidate(GenderFullLower[AGender] + ' ' + Base);
  end;

  function EventKeyMatches(const EventKey: string; const Keys: TStringArray): boolean;
  var
    idx: Integer;
  begin
    Result := False;
    if EventKey = '' then
      Exit;
    for idx := Low(Keys) to High(Keys) do
      if Keys[idx] = EventKey then
        Exit(True);
  end;

  function FindStartListEventByKeys(const Keys: TStringArray): TStartListEventItem;
  var
    idx: Integer;
    Candidate: TStartListEventItem;
    Key: string;
  begin
    Result := nil;
    if Length(Keys) = 0 then
      Exit;
    for idx := 0 to fStart.Events.Count - 1 do
    begin
      Candidate := fStart.Events[idx];
      Key := SanitizeEventKey(Candidate.Event.ShortName);
      if EventKeyMatches(Key, Keys) then
        Exit(Candidate);
      Key := SanitizeEventKey(Candidate.Event.Name);
      if EventKeyMatches(Key, Keys) then
        Exit(Candidate);
    end;
  end;

  function FindDataEventByKeys(const Keys: TStringArray): TEventItem;
  var
    idx: Integer;
    Candidate: TEventItem;
    Key: string;
  begin
    Result := nil;
    if Length(Keys) = 0 then
      Exit;
    for idx := 0 to fStart.Data.Events.Count - 1 do
    begin
      Candidate := fStart.Data.Events.Items[idx];
      Key := SanitizeEventKey(Candidate.ShortName);
      if EventKeyMatches(Key, Keys) then
        Exit(Candidate);
      Key := SanitizeEventKey(Candidate.Name);
      if EventKeyMatches(Key, Keys) then
        Exit(Candidate);
    end;
  end;

  procedure IncrementEventStat(const EventName: string);
  var
    Count: Integer;
  begin
    if EventParticipantStats = nil then
      Exit;
    if Trim(EventName) = '' then
      Exit;
    Count := StrToIntDef(EventParticipantStats.Values[EventName], 0);
    Inc(Count);
    EventParticipantStats.Values[EventName] := IntToStr(Count);
  end;

  procedure PrepareEventStats;
  var
    StatIdx, OtherIdx: Integer;
    Temp: TEventStatInfo;
  begin
    if EventParticipantStats = nil then
    begin
      SetLength(EventStats, 0);
      Exit;
    end;

    SetLength(EventStats, EventParticipantStats.Count);
    for StatIdx := 0 to EventParticipantStats.Count - 1 do
    begin
      EventStats[StatIdx].Name := EventParticipantStats.Names[StatIdx];
      EventStats[StatIdx].Count := StrToIntDef(EventParticipantStats.ValueFromIndex[StatIdx], 0);
    end;

    for StatIdx := 0 to High(EventStats) - 1 do
      for OtherIdx := StatIdx + 1 to High(EventStats) do
        if (EventStats[OtherIdx].Count > EventStats[StatIdx].Count) or
           ((EventStats[OtherIdx].Count = EventStats[StatIdx].Count) and
            (CompareText(EventStats[OtherIdx].Name, EventStats[StatIdx].Name) < 0)) then
        begin
          Temp := EventStats[StatIdx];
          EventStats[StatIdx] := EventStats[OtherIdx];
          EventStats[OtherIdx] := Temp;
        end;
  end;


  function EnsureStartListEvent(const Header: string; AGender: TGender; ARow: Integer; out WasCreated: Boolean): TStartListEventItem;
  var
    Keys: TStringArray;
    DataEvent: TEventItem;
    ExistingEvent: TStartListEventItem;
    idx: Integer;
  begin
    WasCreated := False;
    Keys := BuildEventCandidateKeys(Header, AGender);
    Result := FindStartListEventByKeys(Keys);
    if Result <> nil then
      Exit;

    DataEvent := FindDataEventByKeys(Keys);
    if DataEvent = nil then
      Exit(nil);

    for idx := 0 to fStart.Events.Count - 1 do
    begin
      ExistingEvent := fStart.Events[idx];
      if ExistingEvent.Event = DataEvent then
        Exit(ExistingEvent);
    end;

    Result := fStart.Events.Add;
    Result.ProtocolNumber := fStart.GetNextProtocolNumber;
    Result.Event := DataEvent;
    WasCreated := True;
    if EventCreatedList.IndexOf(DataEvent.ShortName) = -1 then
      EventCreatedList.Add(DataEvent.ShortName);
  end;

  function IsParticipationCell(const Value: Variant): boolean;
  var
    S: string;
    N: Double;
  begin
    Result := False;
    if VarIsEmpty(Value) or VarIsNull(Value) then
      Exit;
    if VarIsNumeric(Value) then
    begin
      try
        N := VarAsType(Value, varDouble);
        Result := N <> 0;
        Exit;
      except
        // fall back to string comparison below
      end;
    end;
    S := Trim(VarToStr(Value));
    if S = '' then
      Exit;
    if SameText(S, '0') then
      Exit;
    Result := True;
  end;

  procedure AssignShooterToEvents(AShooter: TShooterItem; const ShooterName: string; AGender: TGender; ARow: Integer);
  var
    idx: Integer;
    CellValue: Variant;
    TargetEvent: TStartListEventItem;
    EventShooter: TStartListEventShooterItem;
    WasCreated: Boolean;
    StartListShooter: TStartListShooterItem;
  begin
    if (AShooter = nil) or (Length(EventColumns) = 0) then
      Exit;

    StartListShooter := nil;

    for idx := 0 to High(EventColumns) do
    begin
      CellValue := Worksheet.Cells[ARow, EventColumns[idx].ColumnIndex].Value;
      if not IsParticipationCell(CellValue) then
        Continue;

      TargetEvent := EnsureStartListEvent(EventColumns[idx].Header, AGender, ARow, WasCreated);
      if TargetEvent = nil then
      begin
        EventSkippedList.Add(Format('Строка %d: %s — упражнение "%s" не найдено', [ARow, ShooterName, EventColumns[idx].Header]));
        Inc(EventSkippedCount);
        Continue;
      end;

      if StartListShooter = nil then
      begin
        StartListShooter := fStart.Shooters.FindShooter(AShooter);
        if StartListShooter = nil then
        begin
          StartListShooter := fStart.Shooters.Add;
          StartListShooter.Shooter := AShooter;
          StartListShooter.StartNumber := fStart.NextAvailableStartNumber;
          StartListShooter.StartNumberPrinted := False;
        end;
      end;

      if TargetEvent.Shooters.FindShooter(AShooter) <> nil then
        Continue;

      EventShooter := TargetEvent.Shooters.Add;
      EventShooter.StartListShooter := StartListShooter;
      IncrementEventStat(TargetEvent.Event.ShortName);

      EventAssignedList.Add(Format('Строка %d: %s → %s', [ARow, ShooterName, TargetEvent.Event.ShortName]));
      Inc(EventAssignmentCount);
    end;
  end;

begin
  OpenDialog := TOpenDialog.Create(Self);
  SkippedList := TStringList.Create;
  UpdatedList := TStringList.Create;
  NotProcessedList := TStringList.Create;
  AnomalyList := TStringList.Create;
  BirthConflictList := TStringList.Create;
  LogLines := TStringList.Create;
  EventAssignedList := TStringList.Create;
  EventSkippedList := TStringList.Create;
  EventCreatedList := TStringList.Create;
  EventParticipantStats := TStringList.Create;
  EventParticipantStats.NameValueSeparator := '=';
  ExcelApp := Unassigned;
  Workbook := Unassigned;
  Worksheet := Unassigned;
  UsedRange := Unassigned;
  WorkbookOpened := False;
  Success := False;
  ProcessedCount := 0;
  ImportedCount := 0;
  UpdatedCount := 0;
  NotProcessedCount := 0;
  BirthConflictCount := 0;
  SkippedCount := 0;
  CreatedGroups := 0;
  LogFileName := '';
  BirthYear := 0;
  EventAssignmentCount := 0;
  EventSkippedCount := 0;
  try
    OpenDialog.Filter := 'Excel Files (*.xlsx)|*.xlsx|All Files (*.*)|*.*';
    OpenDialog.Title := 'Выберите файл Excel с заявками';
    OpenDialog.Options := OpenDialog.Options + [ofFileMustExist, ofPathMustExist];
    if DirectoryExists(ExtractFilePath(OpenDialog.FileName)) then
      OpenDialog.InitialDir := ExtractFilePath(OpenDialog.FileName)
    else
      OpenDialog.InitialDir := ExtractFilePath(Application.ExeName);

      if not OpenDialog.Execute then
      Exit;

    Screen.Cursor := crHourGlass;
    try
      ExcelApp := CreateOleObject('Excel.Application');
      ExcelApp.Visible := False;
      ExcelApp.DisplayAlerts := False;

      Workbook := ExcelApp.Workbooks.Open(OpenDialog.FileName, 0, True);
      WorkbookOpened := True;
      Worksheet := Workbook.Worksheets[1];

      if LogLines <> nil then
      begin
        LogLines.Add('=== Импорт из Excel ===');
        LogLines.Add(Format('Файл: %s', [OpenDialog.FileName]));
        LogLines.Add(Format('Дата: %s', [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]));
      end;

      HeaderRow := 1;
      DataStartRow := 2;
      for I := 1 to 50 do
      begin
        HeaderCellValue := Trim(VarToStr(Worksheet.Cells[I, 3].Value));
        if SameTextRelaxed(HeaderCellValue, 'ФАМИЛИЯ') or
           SameTextRelaxed(HeaderCellValue, 'Фамилия') or
           SameTextRelaxed(HeaderCellValue, 'SURNAME') then
        begin
          HeaderRow := I;
          Break;
        end;
      end;
      DataStartRow := HeaderRow + 1;
      if DataStartRow < 2 then
        DataStartRow := 2;

      SetLength(EventColumns, 0);
      try
        UsedRange := Worksheet.UsedRange;
      except
        UsedRange := Unassigned;
      end;
      if not VarIsEmpty(UsedRange) then
      begin
        try
          UsedCols := UsedRange.Column + UsedRange.Columns.Count - 1;
        except
          UsedCols := 0;
        end;
      end
      else
        UsedCols := 0;

      if UsedCols < FirstEventColumnIndex then
        UsedCols := FirstEventColumnIndex;
      if UsedCols > LastEventColumnIndex then
        UsedCols := LastEventColumnIndex;

      for Col := FirstEventColumnIndex to UsedCols do
      begin
        HeaderCellValue := Trim(VarToStr(Worksheet.Cells[HeaderRow, Col].Value));
        if HeaderCellValue <> '' then
        begin
          SetLength(EventColumns, Length(EventColumns) + 1);
          EventColumns[High(EventColumns)].ColumnIndex := Col;
          EventColumns[High(EventColumns)].Header := HeaderCellValue;
        end;
      end;

      Row := DataStartRow;
      EmptyRowCounter := 0;
      while EmptyRowCounter < MaxEmptyRowsBeforeStop do
      begin
        LastName := Trim(VarToStr(Worksheet.Cells[Row, 3].Value));
        FirstName := Trim(VarToStr(Worksheet.Cells[Row, 4].Value));
        Patronymic := Trim(VarToStr(Worksheet.Cells[Row, 5].Value));
        RawQualification := Trim(VarToStr(Worksheet.Cells[Row, 6].Value));
        BirthValue := Worksheet.Cells[Row, 7].Value;
        GenderStr := Trim(VarToStr(Worksheet.Cells[Row, 8].Value));
        WeaponStr := Trim(VarToStr(Worksheet.Cells[Row, 9].Value));
        Region := Trim(VarToStr(Worksheet.Cells[Row, 11].Value));
        City := Trim(VarToStr(Worksheet.Cells[Row, 12].Value));
        Club := Trim(VarToStr(Worksheet.Cells[Row, 13].Value));

        if IsRowCompletelyEmpty then
        begin
          Inc(EmptyRowCounter);
          Inc(Row);
          Continue;
        end;

        EmptyRowCounter := 0;
        Inc(ProcessedCount);
        BirthYear := 0;

        Qualification := '';
        if not IsQualificationAllowed(RawQualification, Qualification) then
        begin
          Inc(SkippedCount);
          SkippedList.Add(Format('Строка %d: квалификация "%s"', [Row, RawQualification]));
          Inc(Row);
          Continue;
        end;

        if (LastName = '') or (FirstName = '') then
        begin
          Inc(SkippedCount);
          SkippedList.Add(Format('Строка %d: пустые ФИО', [Row]));
          Inc(Row);
          Continue;
        end;

        LastName := UpperCase(Trim(LastName));

        if not TryParseBirthDate(BirthValue, BirthDate, BirthDateStr) then
        begin
          Inc(SkippedCount);
          SkippedList.Add(Format('Строка %d: неверная дата рождения', [Row]));
          Inc(Row);
          Continue;
        end;

        BirthYear := YearOf(BirthDate);
    FullName := FormatFullName(LastName, FirstName, Patronymic);

        if not TryParseGender(GenderStr, Gender) then
        begin
          Inc(SkippedCount);
          SkippedList.Add(Format('Строка %d: непонятный пол "%s"', [Row, GenderStr]));
          Inc(Row);
          Continue;
        end;

        if not TryParseWeapon(WeaponStr, Weapon) then
        begin
          Inc(SkippedCount);
          SkippedList.Add(Format('Строка %d: непонятный вид оружия "%s"', [Row, WeaponStr]));
          Inc(Row);
          Continue;
        end;

        Group := EnsureGroupFor(Weapon, Gender, Row);
        if Group = nil then
        begin
          Inc(SkippedCount);
          SkippedList.Add(Format('Строка %d: не удалось создать группу для %s %s', [Row, WeaponName(Weapon), GenderName(Gender)]));
          Inc(Row);
          Continue;
        end;

        QualificationEnum := FindQualificationItem(Qualification, RawQualification);

        ExistingShooter := FindDuplicateInGroup(Group);
        if ExistingShooter <> nil then
        begin
          ChangeDetails := '';

          if Trim(ExistingShooter.Surname) <> LastName then
          begin
            AppendChange(ChangeDetails, 'Фамилия', Trim(ExistingShooter.Surname), LastName);
            ExistingShooter.Surname := LastName;
          end;

          if (Trim(ExistingShooter.StepName) = '') and (Trim(Patronymic) <> '') then
          begin
            AppendChange(ChangeDetails, 'Отчество', '<нет>', Patronymic);
            ExistingShooter.StepName := Patronymic;
          end;

          OldValue := ExistingShooter.BirthFullStr;
          if (Trim(OldValue) = '') and IsBirthDateKnown(BirthDateStr) and
             ((ExistingShooter.BirthYear = 0) or (ExistingShooter.BirthYear = BirthYear)) and
             SameTextRelaxed(ExistingShooter.RegionAbbr1, Region) and
             SameTextRelaxed(ExistingShooter.Town, City) then
          begin
            AppendChange(ChangeDetails, 'Дата рождения', DisplayValue(OldValue), BirthDateStr);
            ExistingShooter.BirthFullStr := BirthDateStr;
            if BirthYear <> 0 then
              ExistingShooter.BirthYear := BirthYear;
          end;

          RegionInfo := ExistingShooter.RegionAbbr1;
          if not SameTextTrim(RegionInfo, Region) then
          begin
            AppendChange(ChangeDetails, 'Регион', Trim(RegionInfo), Region);
            ExistingShooter.RegionAbbr1 := Region;
          end;

          CityInfo := ExistingShooter.Town;
          if not SameTextTrim(CityInfo, City) then
          begin
            AppendChange(ChangeDetails, 'Город', Trim(CityInfo), City);
            ExistingShooter.Town := City;
          end;

          ClubInfo := ExistingShooter.SportClub;
          if not SameTextTrim(ClubInfo, Club) then
          begin
            AppendChange(ChangeDetails, 'Клуб', Trim(ClubInfo), Club);
            ExistingShooter.SportClub := Club;
          end;

          OldQualification := ExistingShooter.Qualification;
          if OldQualification <> QualificationEnum then
          begin
            if (OldQualification <> nil) and
               (SameTextRelaxed(OldQualification.Name, 'МС') or
                SameTextRelaxed(OldQualification.Name, 'МСМК') or
                SameTextRelaxed(OldQualification.Name, 'ЗМС')) then
            begin
              if (QualificationEnum = nil) or (not SameTextRelaxed(OldQualification.Name, QualificationEnum.Name)) then
                AnomalyList.Add(Format('Строка %d: %s — странное несоответствие квалификации: в базе %s, в файле %s',
                  [Row, FullName, QualificationDisplay(OldQualification), QualificationDisplay(QualificationEnum)]));
            end
            else
            begin
              AppendChange(ChangeDetails, 'Квалификация', QualificationDisplay(OldQualification), QualificationDisplay(QualificationEnum));
              ExistingShooter.Qualification := QualificationEnum;
            end;
          end;

          if ChangeDetails <> '' then
          begin
            Inc(UpdatedCount);
            UpdatedList.Add(Format('Строка %d: %s — %s', [Row, FullName, ChangeDetails]));
          end;

          AssignShooterToEvents(ExistingShooter, FullName, Gender, Row);

          Inc(Row);
          Continue;
        end;

        BirthMatches := False;
        PartialMatchShooter := FindShooterAcrossGroups(PartialGroup, DetectedPartialWeapon, HasPartialWeapon, BirthMatches);
        if PartialMatchShooter <> nil then
        begin
          if not BirthMatches then
          begin
            AttentionLine := Format('Строка %d: %s (Регион: %s; Город: %s) — конфликт даты рождения: в базе %s, в файле %s. НЕ ОБРАБОТАНО!',
              [Row, FullName, DisplayValue(Region), DisplayValue(City),
               FormatBirthInfo(PartialMatchShooter.BirthFullStr, PartialMatchShooter.BirthYear),
               FormatBirthInfo(BirthDateStr, BirthYear)]);
            BirthConflictList.Add(AttentionLine);
            Inc(BirthConflictCount);
            Inc(Row);
            Continue;
          end;

          if HasPartialWeapon and (DetectedPartialWeapon <> Weapon) then
          begin
            AttentionLine := Format('Строка %d: %s (Регион: %s) уже зарегистрирован в группе "%s" с видом оружия %s. В файле указан вид оружия %s. НЕ ОБРАБОТАНО!',
              [Row, FullName, DisplayValue(Region), PartialGroup.Name, WeaponName(DetectedPartialWeapon), WeaponName(Weapon)]);
            NotProcessedList.Add(AttentionLine);
            Inc(NotProcessedCount);
            Inc(Row);
            Continue;
          end;
        end;

        Shooter := Group.Shooters.Add;
        Shooter.Surname := LastName;
        Shooter.Name := FirstName;
        Shooter.StepName := Patronymic;
        Shooter.Gender := Gender;
        Shooter.BirthFullStr := BirthDateStr;
        Shooter.RegionAbbr1 := Region;
        Shooter.Town := City;
        Shooter.SportClub := Club;
        if QualificationEnum <> nil then
          Shooter.Qualification := QualificationEnum;

        AssignShooterToEvents(Shooter, FullName, Gender, Row);

        Inc(ImportedCount);
        Inc(Row);
      end;

      SurnameNormalizedCount := NormalizeAllShooterSurnames;

      ShortSummary := Format('Обработано: %d; добавлено: %d; обновлено: %d; пропущено: %d; новые группы: %d; не обработано (оружие): %d; конфликты дат: %d; добавлено в упражнения: %d; новые упражнения: %d; упражнения не найдены: %d; фамилий исправлено: %d',
        [ProcessedCount, ImportedCount, UpdatedCount, SkippedCount, CreatedGroups, NotProcessedCount, BirthConflictCount, EventAssignmentCount, EventCreatedList.Count, EventSkippedCount, SurnameNormalizedCount]);

      ResultMsg := 'Импорт завершен.'#13#10 + ShortSummary;

      if SurnameNormalizedCount > 0 then
        ResultMsg := ResultMsg + Format(#13#10'Фамилии приведены к верхнему регистру: %d', [SurnameNormalizedCount]);

      if NotProcessedCount > 0 then
      begin
        ResultMsg := ResultMsg + Format(#13#10'Не обработано из-за конфликта вида оружия: %d (детали в логе)', [NotProcessedCount]);
      end;

      if BirthConflictCount > 0 then
      begin
        ResultMsg := ResultMsg + Format(#13#10'Конфликты даты рождения: %d (детали в логе)', [BirthConflictCount]);
      end;

      if AnomalyList.Count > 0 then
      begin
        ResultMsg := ResultMsg + Format(#13#10'Странные несоответствия: %d (детали в логе)', [AnomalyList.Count]);
      end;

      if EventAssignmentCount > 0 then
      begin
        ResultMsg := ResultMsg + Format(#13#10'Добавлены в упражнения: %d (детали в логе)', [EventAssignmentCount]);
      end;

      if EventCreatedList.Count > 0 then
      begin
        ResultMsg := ResultMsg + Format(#13#10'Создано упражнений: %d (детали в логе)', [EventCreatedList.Count]);
      end;

      if EventSkippedCount > 0 then
      begin
        ResultMsg := ResultMsg + Format(#13#10'Упражнения без совпадений: %d (детали в логе)', [EventSkippedCount]);
      end;

      if (EventParticipantStats <> nil) and (EventParticipantStats.Count > 0) then
      begin
        PrepareEventStats;
        LinesToShow := Length(EventStats);
        if LinesToShow > 5 then
          LinesToShow := 5;
        ResultMsg := ResultMsg + #13#10'Статистика по упражнениям:';
        for I := 0 to LinesToShow - 1 do
          ResultMsg := ResultMsg + Format(#13#10'  • %s — %d', [EventStats[I].Name, EventStats[I].Count]);
        if Length(EventStats) > LinesToShow then
          ResultMsg := ResultMsg + Format(#13#10'  ... и ещё %d упражнений', [Length(EventStats) - LinesToShow]);
      end
      else
        SetLength(EventStats, 0);

      if LogLines <> nil then
      begin
        LogLines.Add('');
        LogLines.Add(ShortSummary);
        if CreatedGroups > 0 then
          LogLines.Add(Format('Создано новых групп: %d', [CreatedGroups]));
        if SurnameNormalizedCount > 0 then
          LogLines.Add(Format('Фамилии приведены к верхнему регистру: %d', [SurnameNormalizedCount]));
        if UpdatedCount > 0 then
        begin
          LogLines.Add('Измененные участники:');
          for I := 0 to UpdatedList.Count - 1 do
            LogLines.Add('  ' + UpdatedList[I]);
        end;
        if NotProcessedCount > 0 then
        begin
          LogLines.Add('Не обработаны из-за конфликта вида оружия:');
          for I := 0 to NotProcessedList.Count - 1 do
            LogLines.Add('  ' + NotProcessedList[I]);
        end;
        if BirthConflictCount > 0 then
        begin
          LogLines.Add('Конфликты даты рождения:');
          for I := 0 to BirthConflictList.Count - 1 do
            LogLines.Add('  ' + BirthConflictList[I]);
        end;
        if AnomalyList.Count > 0 then
        begin
          LogLines.Add('Странные несоответствия:');
          for I := 0 to AnomalyList.Count - 1 do
            LogLines.Add('  ' + AnomalyList[I]);
        end;
        if EventCreatedList.Count > 0 then
        begin
          LogLines.Add('Созданы новые упражнения:');
          for I := 0 to EventCreatedList.Count - 1 do
            LogLines.Add('  ' + EventCreatedList[I]);
        end;
        if Length(EventStats) > 0 then
        begin
          LogLines.Add('Статистика участников по упражнениям:');
          for I := 0 to Length(EventStats) - 1 do
            LogLines.Add(Format('  %s — %d', [EventStats[I].Name, EventStats[I].Count]));
        end;
        if EventSkippedCount > 0 then
        begin
          LogLines.Add('Не удалось подобрать упражнения:');
          for I := 0 to EventSkippedList.Count - 1 do
            LogLines.Add('  ' + EventSkippedList[I]);
        end;
      end;

      UpdateStartInfo;
      if Assigned(MainForm) then
        MainForm.RefreshGroupTree;
      Success := True;
    except
      on E: Exception do
        MessageDlg('Ошибка при импорте: ' + E.Message, mtError, [mbOK], 0);
    end;
  finally
    Screen.Cursor := crDefault;
    if WorkbookOpened then
      try
        Workbook.Close(False);
      except
      end;
    try
      if not VarIsEmpty(ExcelApp) then
        ExcelApp.Quit;
    except
    end;
    if not VarIsEmpty(Worksheet) then
      VarClear(Worksheet);
    if not VarIsEmpty(Workbook) then
      VarClear(Workbook);
    if not VarIsEmpty(ExcelApp) then
      VarClear(ExcelApp);
    if not VarIsEmpty(UsedRange) then
      VarClear(UsedRange);
    if not Success then
    begin
      if LogLines <> nil then
      begin
        LogLines.Free;
        LogLines := nil;
      end;
    end;
    SkippedList.Free;
    UpdatedList.Free;
    NotProcessedList.Free;
    AnomalyList.Free;
    BirthConflictList.Free;
    EventAssignedList.Free;
    EventSkippedList.Free;
    EventCreatedList.Free;
    EventParticipantStats.Free;
    OpenDialog.Free;
  end;

  if Success then
  begin
    if (LogLines <> nil) and (LogLines.Count > 0) then
    begin
      LogFileName := SaveImportLog(LogLines);
      LogLines.Free;
      if LogFileName <> '' then
        ResultMsg := ResultMsg + #13#10 + 'Полный лог: ' + LogFileName;
    end;
    ShowMessage(ResultMsg);
  end
  else if LogLines <> nil then
  begin
    LogLines.Free;
  end;
end;

procedure TManageStartForm.btnNormalizeSurnamesClick(Sender: TObject);
var
  Changed: Integer;
begin
  Changed := NormalizeAllShooterSurnames;
  if Changed > 0 then
  begin
    UpdateStartInfo;
    if Assigned(MainForm) then
      MainForm.RefreshGroupTree;
    lbEvents.Invalidate;
    ShowMessage(Format('Фамилии приведены к верхнему регистру: %d', [Changed]));
  end
  else
    ShowMessage('Все фамилии уже были в верхнем регистре.');
end;

procedure TManageStartForm.ViewShooters(Index: integer);
var
  ES: TEventShootersForm;
  ev: TStartListEventItem;
begin
  ev:= fStart.Events [Index];
  ES:= TEventShootersForm.Create (self);
  ES.StartEvent:= ev;
  ES.Execute;
  ES.Free;
  UpdateStartInfo;
  lbEvents.ItemIndex:= ev.Index;
end;

procedure TManageStartForm.WMBCShooterCard(var M: TMessage);
var
  sc: PWBC_ShooterCard;
  ev: TStartListEventItem;
  sh: TStartListEventShooterItem;
  sr: TShooterSeriesDialog;
begin
  sc:= PWBC_ShooterCard (M.LPARAM);
  if sc= nil then
    exit;
  ev:= fStart.Events.FindByProtocolNumber (sc^.ProtocolNumber);
  if ev= nil then
    exit;
  if sc^.Relay>= ev.Relays.Count then
    exit;
  if sc^.StartNumber> 0 then
    sh:= ev.FindShooter (sc^.StartNumber)
  else
    sh:= ev.FindShooter (ev.Relays [sc^.Relay],sc^.Lane);
  if sh= nil then
    exit;
  sr:= TShooterSeriesDialog.Create (self);
  sr.AttributesOn:= false;
  sr.RecordCommentOn:= false;
  sr.CompShootOffOn:= false;
  sr.FinalOn:= false;
  sr.LargeSeriesFont:= true;
  sr.Shooter:= sh;
  sr.Execute;
  sr.Free;
  UpdateStartInfo;
end;

procedure TManageStartForm.WMStartInfoChanged(var M: TMessage);
begin
  UpdateStartListInfo;
  M.Result:= LRESULT (true);
end;

procedure TManageStartForm.WM_StartShootersChanged(var M: TMessage);
begin
  UpdateStartInfo;
  M.Result:= LRESULT (true);
end;

procedure TManageStartForm.WM_StartShootersDeleted(var M: TMessage);
begin
  UpdateStartInfo;
  M.Result:= LRESULT (true);
end;

procedure TManageStartForm.DrawLots(Index: integer);
var
  ev: TStartListEventItem;
begin
  if (index< 0) or (index> fStart.Events.Count-1) then
    exit;
  ev:= fStart.Events [Index];
  if ev.IsStarted then
    begin
      if MessageDlg (Language ['RedrawLotsPrompt'],mtConfirmation,[mbYes,mbNo],0)<> idYes then
        exit;
    end;
  ev.DrawLots (1);
  UpdateStartInfo;
  lbEvents.ItemIndex:= ev.Index;
end;

procedure TManageStartForm.DoStart(Index: integer);
var
  ev: TStartListEventItem;
  sf: TStartForm;
  ti: integer;
begin
  if (Index< 0) or (Index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events.Items [Index];
  if not ev.IsLotsDrawn then
    begin
      MessageDlg (Language ['NoLotsNoStart'],mtError,[mbOk],0);
      exit;
    end;
  sf:= TStartForm.Create (self);
  sf.StartEvent:= ev;
  sf.Execute;
  sf.Free;
  ti:= lbEvents.TopIndex;
  UpdateStartInfo;
  lbEvents.ItemIndex:= ev.Index;
  lbEvents.TopIndex:= ti;
end;

procedure TManageStartForm.PrintStartList(Index: integer);
var
  ev: TStartListEventItem;
  pd: TPrintProtocolDialog;
begin
  ev:= fStart.Events [Index];
  if not ev.IsLotsDrawn then
    begin
      MessageDlg (Language ['NoLotsNoStartList'],mtError,[mbOk],0);
      exit;
    end;
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= Language ['PrintStartListCaption'];
  pd.ProtocolType:= ptStart;
  pd.ShowCopies:= true;
  if pd.Execute then
    ev.PrintStartList (nil,pd.Copies);
  pd.Free;
end;

procedure TManageStartForm.OpenCompetitionResults(Index: integer);
var
  ev: TStartListEventItem;
  cr: TCompetitionResultsForm;
  seg: integer;
begin
  ev:= fStart.Events [Index];
  cr:= TCompetitionResultsForm.Create (self);
  cr.Event:= ev;
  cr.Execute;
  cr.Free;
  seg:= lbEvents.TopIndex;
  UpdateStartInfo;
  lbEvents.TopIndex:= seg;
  lbEvents.ItemIndex:= ev.Index;
end;

procedure TManageStartForm.PrintCompetitionList(index: integer);
var
  ev: TStartListEventItem;
  pd: TPrintProtocolDialog;
begin
  ev:= fStart.Events [index];
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= Language ['PrintResultsCaption'];
  pd.ShowCopies:= true;
  pd.SelectPrinter:= true;
  pd.ProtocolType:= ptResults;
  pd.ProtocolFormat:= pfRussian;
  pd.Final:= (ev.HasFinal) and (ev.Event.FinalPlaces> 0);
  pd.FinalEnabled:= (ev.HasFinal) and (ev.IsFinalOk);
  pd.Teams:= ev.HasTeamsForResult;
  pd.TeamsEnabled:= ev.HasTeamsForResult;
  pd.TeamPointsEnabled:= (ev.PTeamsPoints.Count> 0) and (ev.HasTeamsForPoints);
  pd.TeamPoints:= pd.TeamPointsEnabled;
  pd.RegionPointsEnabled:= (ev.RegionsPoints.Count> 0) and (ev.HasRegionsPoints);
  pd.RegionPoints:= pd.RegionPointsEnabled;
  pd.DistrictPointsEnabled:= (ev.DistrictsPoints.Count> 0) and (ev.HasDistrictsPoints);
  pd.DistrictPoints:= pd.DistrictPointsEnabled;
  pd.PrintJury:= Global_PrintJury;
  pd.PrintSecretery:= Global_PrintSecretery;
  pd.Report:= true;
  if pd.Execute then
    begin
      Global_PrintJury:= pd.PrintJury;
      Global_PrintSecretery:= pd.PrintSecretery;
      case pd.ProtocolFormat of
        pfRussian: begin
          ev.PrintResults (Printer,pd.Final,pd.Teams,pd.TeamPoints,
            pd.RegionPoints,pd.DistrictPoints,pd.Report,pd.Copies,true);
        end;
        pfInternational: begin
          ev.PrintInternationalResults (Printer,pd.Final,pd.Teams,pd.Copies,true);
        end;
      end;
    end;
  pd.Free;
end;

procedure TManageStartForm.btnQualificationPointsClick(Sender: TObject);
var
  qpd: TQualificationPointsDialog;
begin
  qpd:= TQualificationPointsDialog.Create (self);
  qpd.Points:= fStart.QualificationPoints;
  qpd.Execute;
  qpd.Free;
  UpdateStartInfo;
  lbEvents.SetFocus;
end;

procedure TManageStartForm.pnlQPointsResize(Sender: TObject);
begin
  btnQualificationPoints.Left:= pnlQPoints.ClientWidth-btnQualificationPoints.Width-16;
  btnQualificationPoints.Top:= pnlQPoints.ClientHeight-8-btnQualificationPoints.Height;
end;

procedure TManageStartForm.pmEventPopup(Sender: TObject);
var
  idx: integer;
  ev: TStartListEventItem;
begin
  idx:= lbEvents.ItemIndex;
  // Если не выбрано событие, то отключаем элементы меню
  if (idx< 0) or (idx>= fStart.Events.Count) then
    begin
      mnuRelays.Enabled:= false;
      mnuShooters.Enabled:= false;
      mnuLots.Enabled:= false;
      mnuResults.Enabled:= false;
      mnuShootOff.Enabled:= false;
      mnuFinal.Enabled:= false;
      mnuDelete.Enabled:= false;
      mnuPrintStartList.Enabled:= false;
      mnuPrintResults.Enabled:= false;
      mnuPrintShooters.Enabled:= false;
      mnuPrintFinalNumbers.Enabled:= false;
      mnuProtNo.Enabled:= false;
      mnuRelays.ShortCut:= 0;
      mnuAddEvent.ShortCut:= ShortCut (VK_RETURN,[]);
      mnuPrintCards.Enabled:= false;
      mnuPrintFinalCards.Enabled:= false;
      mnuAcquire.Enabled:= false;
      mnuAcquireFinal.Enabled:= false;
      mnuSaveResultsPDF.Enabled:= false;
      mnuSaveStartListToPDF.Enabled:= false;
      mnuCSV.Enabled:= false;
      mnuExportStartList.Enabled:= false;
      mnuPoints.Enabled:= false;
      mnuChangeInfo.Enabled:= false;
      mnuDeleteInfo.Enabled:= false;
      mnuSave.Enabled:= false;
      mnuTens.Enabled:= false;
    end
  else
    begin
      ev:= fStart.Events [idx];
      mnuRelays.Enabled:= true;
      mnuShooters.Enabled:= true;
      mnuLots.Enabled:= true;
      mnuResults.Enabled:= true;
      mnuShootOff.Enabled:= true;
      mnuFinal.Enabled:= (fEventsData [idx].comp_completed) and (ev.Event.FinalPlaces> 0) and (ev.HasFinal);
      mnuDelete.Enabled:= true;
      mnuPrintStartList.Enabled:= true;
      mnuPrintResults.Enabled:= fEventsData [idx].started;
      mnuPrintShooters.Enabled:= true;
      mnuPrintFinalNumbers.Enabled:= (fEventsData [idx].comp_completed) and (ev.Event.FinalPlaces> 0);
      mnuProtNo.Enabled:= true;
      mnuAddEvent.ShortCut:= 0;
      mnuRelays.ShortCut:= ShortCut (VK_RETURN,[]);
      mnuPrintCards.Enabled:= fEventsData [idx].lotsdrawn;
      mnuPrintFinalCards.Enabled:= fEventsData [idx].comp_completed;
      mnuAcquire.Enabled:= fEventsData [idx].lotsdrawn;
      mnuAcquireFinal.Enabled:= (ev.Event.EventType<> etRapidFire);
      mnuSaveStartListToPDF.Enabled:= mnuPrintStartList.Enabled;
      mnuSaveResultsPDF.Enabled:= mnuPrintResults.Enabled;
      // Экспорт CSV доступен если есть стрелки для экспорта
      mnuCSV.Enabled:= (ev.Shooters.Count > 0);
      // Убираем отладочную информацию из заголовка
      // Caption:= 'DEBUG: shooters=' + IntToStr(ev.Shooters.Count) + ', lotsdrawn=' + BoolToStr(fEventsData [idx].lotsdrawn, True);
      mnuExportStartList.Enabled:= fEventsData [idx].lotsdrawn;
      mnuPoints.Enabled:= true;
      mnuChangeInfo.Enabled:= true;
      mnuDeleteInfo.Enabled:= ev.InfoOverriden;
      mnuSave.Enabled:= fEventsData [idx].comp_completed;
      mnuTens.Enabled:= true;
      mnuTens.Checked:= ev.CompetitionWithTens;
    end;
end;

procedure TManageStartForm.lbEventsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx: integer;
  p: TPoint;
begin
  if Button= mbRight then
    begin
      p:= Point (X,Y);
      idx:= lbEvents.ItemAtPos (p,true);
      if idx>= 0 then
        begin
          lbEvents.ItemIndex:= idx;
          // Обновляем состояние меню при изменении выбора
          pmEventPopup(pmEvent);
          p:= lbEvents.ClientToScreen (p);
          pmEvent.Popup (p.x,p.y);
        end;
    end;
end;

procedure TManageStartForm.lbEventsClick(Sender: TObject);
var
  idx: integer;
  ev: TStartListEventItem;
begin
  // Обновляем данные перед обновлением меню
  idx:= lbEvents.ItemIndex;
  if (idx >= 0) and (idx < fStart.Events.Count) then
    begin
      ev:= fStart.Events [idx];
      // Обновляем данные события
      with fEventsData [idx] do
        begin
          started:= ev.IsStarted;
          lotsdrawn:= ev.IsLotsDrawn;
          rel_count:= ev.Relays.Count;
          pos_count:= ev.PositionsCount;
          comp_completed:= ev.IsCompleted;
          start_no:= ev.StartNumber;
          final_completed:= ev.IsFinalOk;
          saved:= ev.Saved;
          shoot_offs:= ev.Fights;
        end;
    end;
  
  // Обновляем состояние меню при клике на элемент списка
  pmEventPopup(pmEvent);
end;

procedure TManageStartForm.mnuRelaysClick(Sender: TObject);
begin
  if lbEvents.ItemIndex>= Length (fEventsData) then
    AddEvent
  else
    EditRelays (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuShootersClick(Sender: TObject);
begin
  ViewShooters (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuLotsClick(Sender: TObject);
begin
  DrawLots (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuResultsClick(Sender: TObject);
begin
  DoStart (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuShootOffClick(Sender: TObject);
begin
  OpenCompetitionResults (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuTensClick(Sender: TObject);
begin
  mnuTens.Checked:= not mnuTens.Checked;
  SetQualificationTens (lbEvents.ItemIndex,mnuTens.Checked);
end;

procedure TManageStartForm.mnuDeleteClick(Sender: TObject);
begin
  DeleteEvent (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuPrintStartListClick(Sender: TObject);
begin
  PrintStartList (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuPrintResultsClick(Sender: TObject);
begin
  PrintCompetitionList (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuAcquireClick(Sender: TObject);
begin
  AcquireSiusData (lbEvents.ItemIndex,false);
end;

procedure TManageStartForm.mnuAcquireFinalClick(Sender: TObject);
begin
  AcquireSiusData (lbEvents.ItemIndex,true);
end;

procedure TManageStartForm.mnuAddEventClick(Sender: TObject);
begin
  AddEvent;
end;

procedure TManageStartForm.mnuFinalClick(Sender: TObject);
begin
  OpenFinal (lbEvents.ItemIndex);
end;

procedure TManageStartForm.OpenFinal(index: integer);
var
  ev: TStartListEventItem;
  fd: TFinalDialog;
  ti: integer;
begin
  ev:= fStart.Events [index];
  if (ev= nil) or (ev.Event.FinalPlaces<= 0) or (not ev.HasFinal) then
    exit;
  if not ev.IsCompleted then
    begin
      MessageDlg (Language ['EventNotFinished'],mtError,[mbOk],0);
      exit;
    end;
  fd:= TFinalDialog.Create (self);
  fd.Event:= ev;
  fd.Execute;
  fd.Free;
  ti:= lbEvents.TopIndex;
  UpdateStartInfo;
  lbEvents.ItemIndex:= ev.Index;
  lbEvents.TopIndex:= ti;
end;

procedure TManageStartForm.PrintAllStartNumbers;
var
  pd: TPrintProtocolDialog;
begin
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= Language ['PrintStartnumbersCaption'];
  pd.ShowCopies:= false;
  pd.ProtocolType:= ptStartNumbers;
  if pd.Execute then
    fStart.PrintAllStartNumbers;
  pd.Free;
end;

procedure TManageStartForm.MoveEventDown(Index: integer);
var
  ev: TStartListEventItem;
begin
  ev:= fStart.Events.Items [Index];
  ev.Index:= ev.Index+1;
  UpdateStartInfo;
  lbEvents.ItemIndex:= ev.Index;
end;

procedure TManageStartForm.MoveEventUp(Index: integer);
var
  ev: TStartListEventItem;
begin
  ev:= fStart.Events.Items [Index];
  ev.Index:= ev.Index-1;
  UpdateStartInfo;
  lbEvents.ItemIndex:= ev.Index;
end;

procedure TManageStartForm.mnuDeleteInfoClick(Sender: TObject);
var
  ev: TStartListEventItem;
begin
  ev:= fStart.Events.Items [lbEvents.ItemIndex];
  if ev= nil then
    exit;
  ev.DeleteInfo;
  lbEvents.Refresh;
  lbEvents.SetFocus;
end;

procedure TManageStartForm.mnuExportStartListClick(Sender: TObject);
begin
  ExportStartListToAscor (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuChangeInfoClick(Sender: TObject);
var
  ev: TStartListEventItem;
  si: TStartInfoDialog;
  _info: TStartListInfo;
begin
  ev:= fStart.Events.Items [lbEvents.ItemIndex];
  if ev= nil then
    exit;
  _info:= ev.Info;
  ev.OverrideInfo;
  si:= TStartInfoDialog.Create (self);
  si.Info:= ev.Info;
  si.Caption:= format (Language ['StartEventInfoCaption'],[ev.Event.ShortName,ev.Event.Name]);
  if not si.Execute then
    begin
      if _info= nil then
        ev.DeleteInfo;
    end;
  si.Free;
  lbEvents.Refresh;
  lbEvents.SetFocus;
end;

procedure TManageStartForm.mnuCSVClick(Sender: TObject);
var
  sd: TSaveDialog;
  ev: TStartListEventItem;
  index: integer;
begin
  try
    index:= lbEvents.ItemIndex;
    if (index< 0) or (index>= fStart.Events.Count) then
      begin
        ShowMessage('Не выбрано упражнение для экспорта');
        exit;
      end;
    
    ev:= fStart.Events [index];
    if not ev.IsLotsDrawn then
      begin
        ShowMessage('Жеребьевка не проведена. Экспорт невозможен.');
        exit;
      end;
    
    // Более мягкая проверка - разрешаем экспорт если есть хотя бы один стрелок с результатами
    if (ev.Shooters.Count = 0) then
      begin
        ShowMessage('Нет стрелков для экспорта.');
        exit;
      end;
    
    sd:= TSaveDialog.Create (self);
    try
      sd.DefaultExt:= 'csv';
      sd.Filter:= 'CSV files (*.csv)|*.csv|All files (*.*)|*.*';
      sd.FilterIndex:= 1;
      sd.Title:= Language ['EXPORT_RESULTS_TO_CSV'];
      sd.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing,ofNoChangeDir];
      sd.FileName:= 'results_' + ev.Event.ShortName + '.csv';
      
      if sd.Execute then
        begin
          try
            ev.ExportResultsToCSV (sd.FileName);
            ShowMessage('Результаты успешно экспортированы в файл: ' + sd.FileName);
          except
            on E: Exception do
              ShowMessage('Ошибка при сохранении файла: ' + E.Message);
          end;
        end;
    finally
      sd.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка при экспорте: ' + E.Message);
  end;
end;

{
procedure TManageStartForm.mnuPrintStatsClick(Sender: TObject);
var
  pd: TPrintProtocolDialog;
begin
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= Language ['PrintStartStatsCaption'];
  pd.ProtocolType:= ptStartNumbers;
  pd.ShowCopies:= false;
  if pd.Execute then
    begin
      fStart.PrintEventsStats;
    end;
  pd.Free;
end;}

procedure TManageStartForm.mnuPrintShootersClick(Sender: TObject);
var
  pd: TPrintProtocolDialog;
  ev: TStartListEventItem;
begin
  if (lbEvents.ItemIndex< 0) or (lbEvents.ItemIndex>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [lbEvents.ItemIndex];
  if ev.Shooters.Count< 1 then
    begin
      MessageDlg (Language ['NoShooterInEvent'],mtError,[mbOk],0);
      exit;
    end;
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= format (Language ['PrintEventShootersCaption'],[ev.Event.ShortName,ev.Event.Name]);
  pd.ShowCopies:= true;
  pd.ProtocolType:= ptStartNumbers;
  if pd.Execute then
    ev.PrintShootersList (Printer,pd.Copies);
  pd.Free;
end;

procedure TManageStartForm.mnuPrintCardsClick(Sender: TObject);
var
  pd: TPrintShootersCardsDialog;
  ev: TStartListEventItem;
  psc: TShootersCardsPrintout;
  i: integer;
begin
  if (lbEvents.ItemIndex< 0) or (lbEvents.ItemIndex>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [lbEvents.ItemIndex];
  if not ev.IsLotsDrawn then
    exit;
  ev.Shooters.SortOrder:= soPosition;
  pd:= TPrintShootersCardsDialog.Create (self);
  pd.SetEvent (ev);
  pd.Caption:= format (Language ['PrintShootersCards'],[ev.Event.ShortName]);
  if pd.Execute then
    begin
      psc:= TShootersCardsPrintout.Create (ev);
      psc.Anonimous:= pd.cbAnonymous.Checked;
      psc.PrintEventTitle:= pd.cbEventTitle.Checked;
      for i:= 0 to ev.Shooters.Count-1 do
        psc.Checked [i]:= pd.clbShooters.Checked [i];
      psc.Print;
      psc.Free;
    end;
  pd.Free;
end;

procedure TManageStartForm.mnuPrintFinalCardsClick(Sender: TObject);
var
  ev: TStartListEventItem;
  pd: TPrintFinalCardsDialog;
  pfc: TFinalCardsPrintout;
  i: integer;
begin
  if (lbEvents.ItemIndex< 0) or (lbEvents.ItemIndex>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [lbEvents.ItemIndex];
  ev.Shooters.SortOrder:= soSeries;
  pd:= TPrintFinalCardsDialog.Create (self);
  pd.SetEvent (ev);
  if pd.Execute then
    begin
      pfc:= TFinalCardsPrintout.Create (ev);
      for i:= 0 to pd.ShootersCount-1 do
        begin
          if pd.clbNumbers.Checked [i] then
            pfc.Shooters [i]:= pd.Shooters [i]
          else
            pfc.Shooters [i]:= nil;
        end;
      pfc.Print;
      pfc.Free;
    end;
  pd.Free;
end;

procedure TManageStartForm.mnuPrintFinalNumbersClick(Sender: TObject);
begin
  PrintFinalNumbers (lbEvents.ItemIndex);
end;

procedure TManageStartForm.mnuPrintPointsTableClick(Sender: TObject);
var
  pcd: TPrintComplexDialog;
begin
  pcd:= TPrintComplexDialog.Create (self);
  pcd.SetStartList (fStart);
  pcd.Execute;
  pcd.Free;
end;

procedure TManageStartForm.PrintFinalNumbers(index: integer);
var
  ev: TStartListEventItem;
//  pd: TPrintProtocolDialog;
  pfnd: TPrintFinalNumbersDialog;
  fnpo: TFinalNumbersPrintOut;
  i: integer;
begin
  if (index< 0) or (index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [index];
  if (ev.Event.FinalPlaces<= 0) or (not fEventsData [index].comp_completed) then
    exit;
  pfnd:= TPrintFinalNumbersDialog.Create (self);
  pfnd.SetEvent (ev);
  if pfnd.Execute then
    begin
      fnpo:= TFinalNumbersPrintOut.Create (ev);
      for i:= 0 to pfnd.ShootersCount-1 do
        begin
          if pfnd.clbNumbers.Checked [i] then
            fnpo.Shooters [i]:= pfnd.Shooters [i]
          else
            fnpo.Shooters [i]:= nil;
        end;
      fnpo.Print;
      fnpo.Free;
    end;
  pfnd.Free;
end;

procedure TManageStartForm.mnuProtNoClick(Sender: TObject);
begin
  ChangeProtocolNumber (lbEvents.ItemIndex);
end;

procedure TManageStartForm.ChangeProtocolNumber(index: integer);
var
  ev: TStartListEventItem;
  st: string;
  v,i: integer;
begin
  if (index< 0) or (index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [index];
  st:= IntToStr (ev.ProtocolNumber);
  if InputQuery (Language ['ProtocolNo'],format (Language ['ProtocolNoPrompt'],[ev.Event.ShortName,ev.Event.Name]),st) then
    begin
      val (st,v,i);
      if (i= 0) and (v> 0) then
        begin
          ev.ProtocolNumber:= v;
          lbEvents.Invalidate;
        end;
    end;
end;

procedure TManageStartForm.mnuSaveAllResultsClick(Sender: TObject);
var
  pd: TPrintProtocolDialog;
  i: integer;
  afinal,aregions,adistricts: boolean;
  ev: TStartListEventItem;
  sd: TSaveDialog;
  ateams: boolean;
begin
  afinal:= false;
  aregions:= false;
  adistricts:= false;
  ateams:= fStart.HaveTeams;
  for i:= 0 to fStart.Events.Count-1 do
    begin
      ev:= fStart.Events [i];
      afinal:= afinal or ev.HasFinal or ev.IsFinalOk;
      aregions:= aregions or ((ev.RegionsPoints.Count> 0) and (ev.HasRegionsPoints));
      adistricts:= adistricts or ((ev.DistrictsPoints.Count> 0) and (ev.HasDistrictsPoints));
      ateams:= ateams or ((ev.PTeamsPoints.Count> 0) and (ev.HasTeamsForPoints));
    end;
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= Language ['SaveAllResultsInPDFCaption'];
  pd.SelectPrinter:= false;
  pd.ProtocolType:= ptResults;
  pd.ProtocolFormat:= pfRussian;
  pd.Final:= true;
  pd.FinalEnabled:= true;
  pd.Teams:= true;
  pd.TeamsEnabled:= fStart.HaveTeams;
  pd.TeamPointsEnabled:= ateams;
  pd.TeamPoints:= ateams;
  pd.RegionPointsEnabled:= aregions;
  pd.RegionPoints:= aregions;
  pd.DistrictPointsEnabled:= adistricts;
  pd.DistrictPoints:= adistricts;
  pd.Report:= true;
  if pd.Execute then
    begin
      sd:= TSaveDialog.Create (self);
      try
        sd.DefaultExt:= '*.pdf';
        sd.Filter:= 'Acrobat PDF (*.pdf)|*.pdf';
        sd.FilterIndex:= 0;
        sd.Title:= Language ['SaveAllResultsInPDFCaption'];
        sd.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing,ofNoChangeDir];
        if sd.Execute then
          begin
            case pd.ProtocolFormat of
              pfRussian: begin
                fStart.Events.SaveResultsPDF (sd.FileName,pd.Final,pd.Teams,
                  pd.TeamPoints,pd.RegionPoints,pd.DistrictPoints,pd.Report);
              end;
              pfInternational: begin
                fStart.Events.SaveResultsPDFInternational (sd.FileName,pd.Final,pd.Teams);
              end;
            end;
          end;
      finally
        sd.Free;
      end;
    end;
  pd.Free;
end;

procedure TManageStartForm.mnuSaveClick(Sender: TObject);
begin
  SaveEvent (lbEvents.ItemIndex);
end;

procedure TManageStartForm.SaveEvent(index: integer);
var
  ev: TStartListEventItem;
  ti: integer;
begin
  if (index< 0) or (index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [index];
  if not ev.IsCompleted then
    exit;
  ev.SaveResults;
  ti:= lbEvents.TopIndex;
  UpdateStartInfo;
  lbEvents.TopIndex:= ti;
  lbEvents.ItemIndex:= ev.Index;
end;

procedure TManageStartForm.mnuSaveStartListToPDFClick(Sender: TObject);
begin
  SaveStartListToPDF (lbEvents.ItemIndex);
end;

procedure TManageStartForm.SaveStartListToPDF(index: integer);
var
  ev: TStartListEventItem;
  sd: TSaveDialog;
begin
  if (index< 0) or (index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [index];
  if not ev.IsLotsDrawn then
    exit;
  sd:= TSaveDialog.Create (self);
  try
    sd.DefaultExt:= '*.pdf';
    sd.Filter:= 'Acrobat PDF (*.pdf)|*.pdf';
    sd.FilterIndex:= 0;
    sd.Title:= Language ['SaveStartListToPDFTitle'];
    sd.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing,ofNoChangeDir];
    if sd.Execute then
      begin
        ev.SaveStartListPDF (sd.FileName);
      end;
  finally
    sd.Free;
  end;
end;

procedure TManageStartForm.SetQualificationTens(index: integer;
  value: boolean);
var
  ev: TStartListEventItem;
begin
  if (index< 0) or (index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [index];
  ev.CompetitionWithTens:= Value;
  lbEvents.Refresh;
end;

procedure TManageStartForm.mnuSaveResultsPDFClick(Sender: TObject);
begin
  SaveResultsToPDF (lbEvents.ItemIndex);
end;

procedure TManageStartForm.SaveResultsToPDF(index: integer);
var
  ev: TStartListEventItem;
  pd: TPrintProtocolDialog;
  sd: TSaveDialog;
begin
  if (index< 0) or (index>= fStart.Events.Count) then
    exit;
  ev:= fStart.Events [index];
  if not ev.IsCompleted then
    begin
      MessageDlg (Language ['NoFinishNoResults'],mtError,[mbOk],0);
      exit;
    end;
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= Language ['SaveResultsToPDFCaption'];
  pd.SelectPrinter:= false;
  pd.ProtocolType:= ptResults;
  pd.ProtocolFormat:= pfRussian;
  pd.Final:= (ev.HasFinal) and (ev.Event.FinalPlaces> 0);
  pd.FinalEnabled:= (ev.HasFinal) and (ev.IsFinalOk);
  pd.Teams:= ev.HasTeamsForResult;
  pd.TeamsEnabled:= ev.HasTeamsForResult;
  pd.TeamPointsEnabled:= (ev.PTeamsPoints.Count> 0) and (ev.HasTeamsForPoints);
  pd.TeamPoints:= pd.TeamPointsEnabled;
  pd.RegionPointsEnabled:= (ev.RegionsPoints.Count> 0) and (ev.HasRegionsPoints);
  pd.RegionPoints:= pd.RegionPointsEnabled;
  pd.DistrictPointsEnabled:= (ev.DistrictsPoints.Count> 0) and (ev.HasDistrictsPoints);
  pd.DistrictPoints:= pd.DistrictPointsEnabled;
  pd.Report:= true;
  if pd.Execute then
    begin
      sd:= TSaveDialog.Create (self);
      try
        sd.DefaultExt:= '*.pdf';
        sd.Filter:= 'Acrobat PDF (*.pdf)|*.pdf';
        sd.FilterIndex:= 0;
        sd.Title:= pd.Caption;
        sd.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing,ofNoChangeDir];
        if sd.Execute then
          begin
            case pd.ProtocolFormat of
              pfRussian: begin
                ev.SaveResultsPDF (sd.FileName,pd.Final,pd.Teams,
                  pd.TeamPoints,pd.RegionPoints,pd.DistrictPoints,pd.Report);
              end;
              pfInternational: begin
                ev.SaveResultsPDFInternational (sd.FileName,pd.Final,pd.Teams);
              end;
            end;
          end;
      finally
        sd.Free;
      end;
    end;
  pd.Free;
end;

procedure TManageStartForm.HeaderControl1SectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  fHeaderChanged:= true;
  lbEvents.Invalidate;
end;

procedure TManageStartForm.EditEventPoints(index: integer);
var
  ev: TStartListEventItem;
  psd: TPointsSetupDialog;
begin
  ev:= fStart.Events.Items [Index];
  if ev= nil then
    exit;
  psd:= TPointsSetupDialog.Create (self);
  psd.SetEvent (ev);
//  psd.Points:= ev.PTeamsPoints;
  psd.Caption:= format (Language ['EventPoints'],[ev.Event.ShortName]);
  if psd.Execute then
    begin
      ev.PTeamsPoints.Assign (psd.PTeamsPoints);
      ev.RegionsPoints.Assign (psd.RegionsPoints);
      ev.DistrictsPoints.Assign (psd.DistrictsPoints);
      ev.RTeamsPoints.Assign (psd.RTeamsPoints);
      lbEvents.Invalidate;
    end;
  psd.Free;
end;

procedure TManageStartForm.mnuPointsClick(Sender: TObject);
begin
  if (lbEvents.ItemIndex>= 0) and (lbEvents.ItemIndex< fStart.Events.Count) then
    EditEventPoints (lbEvents.ItemIndex);
end;

destructor TManageStartForm.Destroy;
begin
  SetLength (fEventsData,0);
  inherited;
end;

end.


