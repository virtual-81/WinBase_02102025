{$a-}
unit form_addtostart;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types, System.UITypes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Printers, Vcl.ComCtrls, Vcl.Menus, System.DateUtils,

  Data,
  mystrings,
  SysFont,

  form_shooter,
  form_teamselect,

  MyLanguage,
  ctrl_language;

type
  TEventInfo= record
    fAdded: boolean;
    fPresentEvent: TStartListEventShooterItem;
    fEvent: TStartListEventItem;
    fTeamForPoints: string;
    fTeamForResults: string;
    fOutOfRank: boolean;
    fRegionPoints: boolean;
    fDistrictPoints: boolean;
    start_no: integer;
    filtered: boolean;
    prefered: integer;
  end;

  TAddToStartDialog = class(TForm)
    pnlEvents: TPanel;
    lbEvents: TListBox;
    btnOk: TButton;
    HeaderControl1: THeaderControl;
    lShooter: TLabel;
    lYear: TLabel;
    lNameC: TLabel;
    lYearC: TLabel;
    lCountry: TLabel;
    lCountryC: TLabel;
    lTown: TLabel;
    lTownC: TLabel;
    lClub: TLabel;
    lClubC: TLabel;
    lDateC: TLabel;
    lDate: TLabel;
    lNumC: TLabel;
    btnEdit: TButton;
    cbPrintStartNumbers: TCheckBox;
    lNum: TLabel;
    btnCancel: TButton;
    btnPrint: TButton;
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbEventsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HeaderControl1SectionResize(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure HeaderControl1Resize(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure lbEventsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lbEventsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtStartNumberKeyPress(Sender: TObject; var Key: Char);
    procedure lbEventsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnEditClick(Sender: TObject);
    procedure lNumMouseEnter(Sender: TObject);
    procedure lNumMouseLeave(Sender: TObject);
    procedure lNumClick(Sender: TObject);
    procedure cbPrintStartNumbersClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    { Private declarations }
    fShooter: TShooterItem;
    fStartList: TStartList;
    fEvents: array of TEventInfo;
    fModalResult: integer;
    fStartNumber: integer;
    fNumberPrinted: boolean;
    fEventsFilter: TEventsFilter;
    fLastTeamForResults: string;
    fLastTeamForPoints: string;
    fNoTeamForPointsStr,fNoTeamForResultsStr: string;
    fStartNoStr: string;
    procedure set_Shooter(const Value: TShooterItem);
    procedure set_StartList(const Value: TStartList);
    procedure UpdateShooterInfo;
    procedure UpdateInfo;
    function get_AutoPrint: boolean;
    procedure set_AutoPrint(const Value: boolean);
    procedure Save;
    procedure PrintStartNumber (sh: TStartListShooterItem);
    function SectionAtPos (x: integer): integer;
    procedure SelectTeamForPoints (idx: integer; UseLast: boolean);
    procedure SelectTeamForResults (idx: integer; UseLast: boolean);
    procedure ToggleOutOfRank (idx: integer);
    procedure ToggleRegionPoints (idx: integer);
    procedure ToggleDistrictPoints (idx: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property StartList: TStartList read fStartList write set_StartList;
    property Shooter: TShooterItem read fShooter write set_Shooter;
    function Execute: boolean;
    property AutoPrint: boolean read get_AutoPrint write set_AutoPrint;
    property EventsFilter: TEventsFilter read fEventsFilter write fEventsFilter;
    property LastTeamForPoints: string read fLastTeamForPoints write fLastTeamForPoints;
    property LastTeamForResults: string read fLastTeamForResults write fLastTeamForResults;
  end;

implementation

{$R *.dfm}

{ TAddToStartDialog }

procedure TAddToStartDialog.set_Shooter(const Value: TShooterItem);
begin
  if fStartList= nil then
    raise Exception.Create ('You should set StartList first!');
  fShooter:= Value;
  fNumberPrinted:= false;
  btnPrint.Enabled:= true;
  UpdateInfo;
end;

procedure TAddToStartDialog.set_StartList(const Value: TStartList);
begin
  fStartList:= Value;
  btnPrint.Visible:= fStartList.StartNumbers;
  UpdateInfo;
end;

procedure TAddToStartDialog.ToggleDistrictPoints(idx: integer);
begin
  if (idx>= 0) and (idx< Length (fEvents)) and (fEvents [idx].fAdded) then
    begin
      fEvents [idx].fDistrictPoints:= not fEvents [idx].fDistrictPoints;
      if fEvents [idx].fDistrictPoints then
        fEvents [idx].fOutOfRank:= false;
      lbEvents.Invalidate;
    end;
end;

procedure TAddToStartDialog.ToggleOutOfRank(idx: integer);
begin
  if (idx>= 0) and (idx< Length (fEvents)) and (fEvents [idx].fAdded) then
    begin
      fEvents [idx].fOutOfRank:= not fEvents [idx].fOutOfRank;
      if fEvents [idx].fOutOfRank then
        begin
          fEvents [idx].fTeamForPoints:= '';
          fEvents [idx].fRegionPoints:= false;
          fEvents [idx].fDistrictPoints:= false;
          fEvents [idx].fTeamForResults:= '';
        end;
      lbEvents.Invalidate;
    end;
end;

procedure TAddToStartDialog.ToggleRegionPoints(idx: integer);
begin
  if (idx>= 0) and (idx< Length (fEvents)) and (fEvents [idx].fAdded) then
    begin
      fEvents [idx].fRegionPoints:= not fEvents [idx].fRegionPoints;
      if fEvents [idx].fRegionPoints then
        fEvents [idx].fOutOfRank:= false;
      lbEvents.Invalidate;
    end;
end;

procedure TAddToStartDialog.FormDestroy(Sender: TObject);
begin
  SetLength (fEvents,0);
  fEvents:= nil;
end;

procedure TAddToStartDialog.FormResize(Sender: TObject);
begin
  btnEdit.Left:= ClientWidth-8-btnEdit.Width;
  btnOk.Top:= ClientHeight-8-btnOk.Height;
  btnCancel.Top:= btnOk.Top;
  btnPrint.Top:= btnOk.Top;
  pnlEvents.Width:= ClientWidth;
  pnlEvents.Height:= btnOk.Top-8-pnlEvents.Top;
  cbPrintStartNumbers.Left:= ClientWidth-8-cbPrintStartNumbers.Width;
  btnPrint.Left:= cbPrintStartNumbers.Left-8-btnPrint.Width;
  cbPrintStartNumbers.Top:= btnPrint.Top+(btnPrint.Height-cbPrintStartNumbers.Height) div 2;
end;

procedure TAddToStartDialog.lbEventsDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  ev: TEventInfo;
  st: string;
  c: TColor;
  s: THeaderSection;
  sr: TRect;
  r: TRect;
  graytext,normaltext: TColor;
  uState: cardinal;
begin
  with lbEvents.Canvas do
    begin
      if Index< Length (fEvents) then
        begin
          ev:= fEvents [Index];

          if not (odSelected in State) then
            begin
              if (ev.filtered) or (ev.prefered>= 0) then
                Brush.Color:= clMoneyGreen;
              graytext:= clGrayText;
              normaltext:= clWindowText;
            end
          else
            begin
              graytext:= Font.Color;
              normaltext:= Font.Color;
            end;
          FillRect (ARect);

          Brush.Style:= bsClear;

          s:= HeaderControl1.Sections [0];
          sr:= Rect (s.Left,ARect.Top+3,s.Right,ARect.Bottom-3);
          if ev.fPresentEvent<> nil then
            uState:= DFCS_BUTTONRADIO or DFCS_CHECKED or DFCS_INACTIVE
          else
            uState:= DFCS_BUTTONRADIO or DFCS_INACTIVE;
          DrawFrameControl (Handle,sr,DFC_BUTTON,uState);

          s:= HeaderControl1.Sections [1];
          sr:= Rect (s.Left,ARect.Top+3,s.Right,ARect.Bottom-3);
          if ev.fAdded then
            uState:= DFCS_BUTTONRADIO or DFCS_CHECKED
          else
            uState:= DFCS_BUTTONRADIO;
          DrawFrameControl (Handle,sr,DFC_BUTTON,uState);

          s:= HeaderControl1.Sections [2];
          r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
          with ev.fEvent.Event do
            begin
              Font.Style:= [fsBold];
              TextRect (r,r.Left,ARect.Top+2,ShortName);
              r.Left:= r.Left+TextWidth (ShortName);

              if ev.start_no> 0 then
                begin
                  c:= Font.Color;
                  Font.Style:= [fsBold];
                  if odSelected in State then
                    Font.Color:= clYellow
                  else
                    Font.Color:= clBlue;
                  st:= format (fStartNoStr,[ev.start_no]);
                  TextRect (r,r.Right-2-TextWidth (st),ARect.Top+2,st);
                  r.Right:= r.Right-TextWidth (' '+st);
                  Font.Color:= c;
                  Font.Style:= [];
                end;

              Font.Style:= [];
              st:= ' ('+Name+')';
              TextRect (r,r.Left,ARect.Top+2,st);
            end;

          if ev.fAdded then
            begin
              s:= HeaderControl1.Sections [3];
              sr:= Rect (s.Left,ARect.Top+3,s.Right,ARect.Bottom-3);
              if ev.fOutOfRank then
                uState:= DFCS_BUTTONRADIO or DFCS_CHECKED
              else
                uState:= DFCS_BUTTONRADIO;
              DrawFrameControl (Handle,sr,DFC_BUTTON,uState);

              s:= HeaderControl1.Sections [4];
              r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
              if ev.fTeamForPoints<> '' then
                begin
                  Font.Color:= normaltext;
                  Font.Style:= [fsBold];
                  TextRect (r,r.Left,ARect.Top+2,ev.fTeamForPoints);
                end
              else
                begin
                  Font.Color:= graytext;
                  Font.Style:= [];
                  TextRect (r,r.Left,ARect.Top+2,fNoTeamForPointsStr);
                end;

              s:= HeaderControl1.Sections [5];
              sr:= Rect (s.Left,ARect.Top+3,s.Right,ARect.Bottom-3);
              if ev.fRegionPoints then
                uState:= DFCS_BUTTONRADIO or DFCS_CHECKED
              else
                uState:= DFCS_BUTTONRADIO;
              DrawFrameControl (Handle,sr,DFC_BUTTON,uState);

              s:= HeaderControl1.Sections [6];
              sr:= Rect (s.Left,ARect.Top+3,s.Right,ARect.Bottom-3);
              if ev.fDistrictPoints then
                uState:= DFCS_BUTTONRADIO or DFCS_CHECKED
              else
                uState:= DFCS_BUTTONRADIO;
              DrawFrameControl (Handle,sr,DFC_BUTTON,uState);

              s:= HeaderControl1.Sections [7];
              r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
              if ev.fTeamForResults<> '' then
                begin
                  Font.Color:= normaltext;
                  Font.Style:= [fsBold];
                  TextRect (r,r.Left,ARect.Top+2,ev.fTeamForResults);
                end
              else
                begin
                  Font.Color:= graytext;
                  Font.Style:= [];
                  TextRect (r,r.Left,ARect.Top+2,fNoTeamForResultsStr);
                end;
            end;
        end;
    end;
end;

procedure TAddToStartDialog.FormCreate(Sender: TObject);
begin
  fModalResult:= mrCancel;
  fEventsFilter:= nil;
  Width:= Round (Screen.Width*0.75);
  Height:= Round (Screen.Height*0.75);
  fLastTeamForResults:= '';
  fLastTeamForPoints:= '';
  UpdateLanguage;
  UpdateFonts;
end;

function TAddToStartDialog.Execute: boolean;
begin
  fModalResult:= mrCancel;
  lbEvents.ItemIndex:= 0;
  Result:= (ShowModal= mrOk);
end;

procedure TAddToStartDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ModalResult:= fModalResult;
end;

procedure TAddToStartDialog.HeaderControl1SectionResize(
  HeaderControl: THeaderControl; Section: THeaderSection);
begin
  HeaderControl1Resize (self);
  lbEvents.Invalidate;
end;

procedure TAddToStartDialog.HeaderControl1Resize(Sender: TObject);
begin
  with HeaderControl1 do
    Sections [2].Width:= HeaderControl1.ClientWidth-Sections [0].Width-Sections [1].Width-
      Sections [3].Width-Sections [4].Width-Sections [5].Width-Sections [6].Width-Sections [7].Width;
  lbEvents.Invalidate;
end;

procedure TAddToStartDialog.btnOkClick(Sender: TObject);
begin
  Save;
  fModalResult:= mrOk;
  Close;
end;

procedure TAddToStartDialog.lbEventsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  idx: integer;
  sec: integer;
begin
  idx:= lbEvents.ItemAtPos (Point (x,y),true);
  if (idx>= 0) and (idx< Length (fEvents)) {and (not fEvents [idx].fEvent.Started)} then
    begin
      sec:= SectionAtPos (x);
      case sec of
        1: begin
          if abs (x-((HeaderControl1.Sections [sec].Left+HeaderControl1.Sections [sec].Right) div 2))<= lbEvents.ItemHeight div 2 then
            lbEvents.Cursor:= crHandPoint
          else
            lbEvents.Cursor:= crDefault;
        end;
        3,5,6: begin
          if (fEvents [idx].fAdded) and
             (abs (x-((HeaderControl1.Sections [sec].Left+HeaderControl1.Sections [sec].Right) div 2))<= lbEvents.ItemHeight div 2) then
            lbEvents.Cursor:= crHandPoint
          else
            lbEvents.Cursor:= crDefault;
        end;
        4,7: begin
          if fEvents [idx].fAdded then
            lbEvents.Cursor:= crHandPoint
          else
            lbEvents.Cursor:= crDefault;
        end;
      else
        lbEvents.Cursor:= crDefault;
      end;
    end
  else
    begin
      lbEvents.Cursor:= crDefault;
    end;
end;

procedure TAddToStartDialog.lbEventsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx,sec: integer;
begin
  idx:= lbEvents.ItemAtPos (Point (x,y),true);
  if (idx< 0) or (idx>= Length (fEvents)) then
    exit;
  sec:= SectionAtPos (x);
  case sec of
    1: if Button= mbLeft then begin
      if (abs (x-((HeaderControl1.Sections [sec].Left+HeaderControl1.Sections [sec].Right) div 2))<= lbEvents.ItemHeight div 2) then
        begin
          fEvents [idx].fAdded:= not fEvents [idx].fAdded;
          lbEvents.Invalidate;
        end;
    end;
    3: if Button= mbLeft then begin
      if (abs (x-((HeaderControl1.Sections [sec].Left+HeaderControl1.Sections [sec].Right) div 2))<= lbEvents.ItemHeight div 2) then
        begin
          ToggleOutOfRank (idx);
        end;
    end;
    4: SelectTeamForPoints (idx,Button= mbLeft);
    5: if Button= mbLeft then begin
      if (abs (x-((HeaderControl1.Sections [sec].Left+HeaderControl1.Sections [sec].Right) div 2))<= lbEvents.ItemHeight div 2) then
        begin
          ToggleRegionPoints (idx);
        end;
    end;
    6: if Button= mbLeft then begin
      if (abs (x-((HeaderControl1.Sections [sec].Left+HeaderControl1.Sections [sec].Right) div 2))<= lbEvents.ItemHeight div 2) then
        begin
          ToggleDistrictPoints (idx);
        end;
    end;
    7: SelectTeamForResults (idx,Button= mbLeft);
  end;
end;

procedure TAddToStartDialog.edtStartNumberKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    '0'..'9': {};
    #8: {};
  else
    Key:= #0;
  end;
end;

procedure TAddToStartDialog.lbEventsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_SPACE: begin
      Key:= 0;
      if (lbEvents.ItemIndex>= 0) then
        begin
          fEvents [lbEvents.ItemIndex].fAdded:= not fEvents [lbEvents.ItemIndex].fAdded;
        end;
      lbEvents.Invalidate;
    end;
    VK_F4: if Shift= [] then
      begin
        btnEdit.Click;
      end;
    VK_F9: if Shift= [] then
      begin
        ToggleOutOfRank (lbEvents.ItemIndex);
        Key:= 0;
      end;
    VK_F5: begin
      SelectTeamForPoints (lbEvents.ItemIndex,Shift= []);
      Key:= 0;
    end;
    VK_F7: if Shift= [] then
      begin
        ToggleDistrictPoints (lbEvents.ItemIndex);
        Key:= 0;
      end;
    VK_F6: if Shift= [] then
      begin
        ToggleRegionPoints (lbEvents.ItemIndex);
        Key:= 0;
      end;
    VK_F8: begin
      SelectTeamForResults (lbEvents.ItemIndex,Shift= []);
      Key:= 0;
    end;
    VK_ESCAPE: begin
      Key:= 0;
      btnCancel.Click;
    end;
    VK_RETURN: begin
      Key:= 0;
      btnOk.Click;
    end;
  end;
end;

procedure TAddToStartDialog.btnEditClick(Sender: TObject);
var
  SD: TShooterDetailsDialog;
begin
	if fShooter<> nil then
		begin
      SD:= TShooterDetailsDialog.Create (self);
      SD.Shooter:= fShooter;
      SD.Execute;
      SD.Free;
      UpdateShooterInfo;
		end;
  lbEvents.SetFocus;
end;

procedure TAddToStartDialog.UpdateShooterInfo;
begin
  lShooter.Caption:= fShooter.Surname+', '+fShooter.Name;
  lYear.Caption:= fShooter.BirthFullStr;
  lDateC.Left:= lYear.Left+lYear.Width+48;
  lDate.Left:= lDateC.Left+lDateC.Width+8;
  lDate.Caption:= '';
  lCountry.Caption:= fShooter.RegionFull1+' ('+fShooter.RegionAbbr1+')';
  lTown.Caption:= fShooter.Town;
  lClub.Caption:= fShooter.SocietyAndClub;
end;

procedure TAddToStartDialog.lNumMouseEnter(Sender: TObject);
begin
  lNum.Font.Style:= [fsBold,fsUnderline];
end;

procedure TAddToStartDialog.lNumMouseLeave(Sender: TObject);
begin
  lNum.Font.Style:= [fsBold];
end;

procedure TAddToStartDialog.lNumClick(Sender: TObject);
var
  st: string;
  n,i: integer;
  sh,sh1: TStartListShooterItem;
begin
  st:= IntToStr (fStartNumber);
  if InputQuery (Language ['StartNumberCaption'],Language ['StartNumberPrompt'],st) then
    begin
      val (st,n,i);
      if (n= 0) or (i<> 0) then
        begin
          MessageDlg (Language ['InvalidStartNumber'],mtError,[mbOk],0);
          exit;
        end;
      if n= fStartNumber then
        exit;
      sh:= fStartList.Shooters.FindShooter (n);
      if sh<> nil then
        begin
          // ����� ����� ��� � ����-�� ����
          // ������������, �������� ��� ��� ���� ��� ���������� ��������
          if MessageDlg (format (Language ['StartNumberExists'],[n,sh.Shooter.SurnameAndName]),mtConfirmation,[mbYes,mbNo],0)= idYes then
            begin
              // ������ ��������� ������
              sh.StartNumber:= fStartNumber;
              sh1:= fStartList.Shooters.FindShooter (fShooter);
              if sh1<> nil then
                sh1.StartNumber:= n;
            end
          else
            exit;
        end;
      fStartNumber:= n;
      lNum.Caption:= LeftFillStr (IntToStr (fStartNumber),3,'0');
    end;
end;

function TAddToStartDialog.get_AutoPrint: boolean;
begin
  Result:= cbPrintStartNumbers.Checked;
end;

procedure TAddToStartDialog.set_AutoPrint(const Value: boolean);
begin
  cbPrintStartNumbers.Checked:= Value;
end;

procedure TAddToStartDialog.cbPrintStartNumbersClick(Sender: TObject);
begin
  if Visible then
    lbEvents.SetFocus;
end;

procedure TAddToStartDialog.Save;
var
  j: integer;
  sh: TStartListShooterItem;
  esh: TStartListEventShooterItem;
begin
  sh:= fStartList.Shooters.FindShooter (fShooter);
  if sh<> nil then
    begin
      sh.StartNumber:= fStartNumber;
    end;
  for j:= 0 to Length (fEvents)-1 do
    begin
      if (fEvents [j].fAdded) and (fEvents [j].fPresentEvent= nil) then
        begin      // add shooter to event
          // ���� ������� ���� �� �������� � �����, ��������� ���
          if sh= nil then
            begin
              sh:= fStartList.Shooters.Add;
              sh.Shooter:= fShooter;
              // ����������� ������� ��������� �����
              // ���� ������� ����� ������������� (��� ������� � ������)
              sh.StartNumber:= fStartNumber;
              lNum.Caption:= LeftFillStr (IntToStr (fStartNumber),3,'0');
            end;
          esh:= fEvents [j].fEvent.Shooters.Add;
          esh.StartListShooter:= sh;
          esh.OutOfRank:= fEvents [j].fOutOfRank;
          esh.TeamForPoints:= fEvents [j].fTeamForPoints;
          esh.GiveRegionPoints:= fEvents [j].fRegionPoints;
          esh.GiveDistrictPoints:= fEvents [j].fDistrictPoints;
          esh.TeamForResults:= fEvents [j].fTeamForResults;
        end
      else if (not fEvents [j].fAdded) and (fEvents [j].fPresentEvent<> nil) then
        begin      // delete shooter from event
          fEvents [j].fPresentEvent.Free;
          fEvents [j].fPresentEvent:= nil;
        end
      else if (fEvents [j].fPresentEvent<> nil) then
        begin      // modify
          esh:= fEvents [j].fPresentEvent;
          esh.OutOfRank:= fEvents [j].fOutOfRank;
          esh.TeamForPoints:= fEvents [j].fTeamForPoints;
          esh.GiveRegionPoints:= fEvents [j].fRegionPoints;
          esh.GiveDistrictPoints:= fEvents [j].fDistrictPoints;
          esh.TeamForResults:= fEvents [j].fTeamForResults;
        end;
    end;
  // �������������� ���������� ��������� �������
  if (cbPrintStartNumbers.Checked) and (sh<> nil) then
    begin
      if (not fNumberPrinted) and (not sh.StartNumberPrinted) then
        PrintStartNumber (sh);
    end;
  // ���������, �� �������� ����������� ��������� �������
  // ���� ������ �� ���������, �� ������, ������� �� ������ ��
  // ������������ � ���������� �����
  if (sh<> nil) and (sh.EventsCount= 0) then
    begin
      if MessageDlg (Language ['NoMoreEventsForShooter'],mtConfirmation,[mbYes,mbNo],0)= idYes then
        begin
          sh.Free;
        end;
    end;
  // �� ������� ������ �� ��������, ���� ���� � ��� ��� ����������
  // ����� ��������� �� ���� ������� �������� ��������� ������
  fStartList.Notify (WM_STARTLISTSHOOTERSCHANGED,0,0);
  fModalResult:= mrOk;
end;

procedure TAddToStartDialog.UpdateFonts;
var
  bh: integer;
  w,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbEvents.Canvas.Font:= lbEvents.Font;
  lbEvents.ItemHeight:= lbEvents.Canvas.TextHeight ('Mg')+6;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnEdit.ClientWidth:= Canvas.TextWidth (btnEdit.Caption)+32;
  btnEdit.ClientHeight:= bh;
  lShooter.Font:= Font;
  lShooter.Font.Style:= [fsBold];
  lYear.Font:= Font;
  lYear.Font.Style:= [fsBold];
  lDate.Font:= Font;
  lDate.Font.Style:= [fsBold];
  lCountry.Font:= Font;
  lCountry.Font.Style:= [fsBold];
  lTown.Font:= Font;
  lTown.Font.Style:= [fsBold];
  lClub.Font:= Font;
  lClub.Font.Style:= [fsBold];
  lNum.Font:= Font;
  lNum.Font.Style:= [fsBold];
  w:= lNameC.Width;
  i:= lYearC.Width;
  if i> w then
    w:= i;
  i:= lCountryC.Width;
  if i> w then
    w:= i;
  i:= lTownC.Width;
  if i> w then
    w:= i;
  i:= lClubC.Width;
  if i> w then
    w:= i;
  i:= lNumC.Width;
  if i> w then
    w:= i;
  lNameC.Left:= w+8-lNameC.Width;
  lNameC.Top:= 8;
  lShooter.Left:= w+16;
  lShooter.Top:= lNameC.Top; 
  lYearC.Left:= w+8-lYearC.Width;
  lYearC.Top:= lNameC.Top+lNameC.Height;
  lYear.Left:= w+16;
  lYear.Top:= lYearC.Top;
  lDateC.Top:= lYearC.Top;
  lDate.Top:= lDatec.Top;
  lCountryC.Left:= w+8-lCountryC.Width;
  lCountryC.Top:= lYearC.Top+lYearC.Height;
  lCountry.Left:= w+16;
  lCountry.Top:= lCountryC.Top;
  lTownC.Left:= w+8-lTownC.Width;
  lTownC.Top:= lCountryC.Top+lCountryC.Height;
  lTown.Left:= w+16;
  lTown.Top:= lTownC.Top;
  lClubC.Left:= w+8-lClubC.Width;
  lClubC.Top:= lTownC.Top+lTownC.Height;
  lClub.Left:= w+16;
  lClub.Top:= lClubC.Top;
  lNumC.Left:= w+8-lNumC.Width;
  lNumC.Top:= lClubC.Top+lClubC.Height;
  lNum.Left:= w+16;
  lNum.Top:= lNumC.Top;
  w:= Canvas.TextWidth (btnOk.Caption);
  i:= Canvas.TextWidth (btnCancel.Caption);
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w+32;
  btnCancel.ClientWidth:= w+32;
  btnOk.ClientHeight:= bh;
  btnCancel.ClientHeight:= bh;
  btnPrint.ClientWidth:= Canvas.TextWidth (btnPrint.Caption)+32;
  btnPrint.ClientHeight:= bh;
  cbPrintStartNumbers.Width:= Canvas.TextWidth (cbPrintStartNumbers.Caption)+cbPrintStartNumbers.Height;
  btnOk.Left:= 8;
  btnCancel.Left:= btnOk.Left+btnOk.Width+8;
  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
  pnlEvents.Constraints.MinHeight:= HeaderControl1.Height+lbEvents.Height-lbEvents.ClientHeight+lbEvents.ItemHeight*5;
  Constraints.MinWidth:= Width-ClientWidth+8+btnOk.Width+8+btnCancel.Width+8+btnPrint.Width+8+cbPrintStartNumbers.Width+8;
  Constraints.MinHeight:= Height-ClientHeight+lNum.Top+lNum.Height+8+pnlEvents.Constraints.MinHeight+8+btnOk.Height+8;
end;

procedure TAddToStartDialog.UpdateInfo;
var
  j,i,idx: integer;
  ssh: TStartListShooterItem;
  esh: TStartListEventShooterItem;
  ei: TEventInfo;
begin
  if (fStartList= nil) or (fShooter= nil) then
    exit;

  // ������� �������� ��� ����������
  SetLength (fEvents,fStartList.Events.Count);
  lbEvents.Clear;
  for j:= 0 to fStartList.Events.Count-1 do
    begin
      fEvents [j].fEvent:= fStartList.Events [j];
      if fEventsFilter<> nil then
        fEvents [j].filtered:= fEventsFilter.Filtered (fEvents [j].fEvent.Event)
      else
        fEvents [j].filtered:= false;
      fEvents [j].prefered:= fShooter.Group.Prefered (fEvents [j].fEvent.Event);
      lbEvents.Items.Add ('');
    end;

  // ����� ��������� �� �� ������
  for i:= 0 to Length (fEvents)-2 do
    begin
      idx:= i;
      for j:= i+1 to Length (fEvents)-1 do
        begin
          if (fEvents [j].prefered>= 0) and (fEvents [idx].prefered< 0) then
            begin
              idx:= j;
            end
          else if (fEvents [j].prefered>= 0) and (fEvents [idx].prefered>= 0) then
            begin
              if fEvents [j].prefered< fEvents [idx].prefered then
                idx:= j;
            end
          else if (fEvents [j].prefered< 0) and (fEvents [idx].prefered>= 0) then
            begin
              // ����� ������ �� ������
            end
          else // ��� �� ���������������
            begin
              if (fEvents [j].filtered) and (not fEvents [idx].filtered) then
                idx:= j;
            end;
        end;
      if idx<> i then
        begin
          ei:= fEvents [i];
          fEvents [i]:= fEvents [idx];
          fEvents [idx]:= ei;
        end;
    end;

{  if fEventsFilter<> nil then
    begin
      for j:= 0 to fStartList.Events.Count-1 do
        begin
          if (fEventsFilter.Filtered (fStartList.Events [j].Event)) or
            (fShooter.Group.Prefered (fStartList.Events [j].Event)>= 0) then
            begin
              lbEvents.Items.Add ('');
              fEvents [lbEvents.Count-1].fEvent:= fStartList.Events [j];
              fEvents [lbEvents.Count-1].filtered:= true;
            end;
        end;
      for j:= 0 to fStartList.Events.Count-1 do
        begin
          if (not fEventsFilter.Filtered (fStartList.Events [j].Event)) and
             (fShooter.Group.Prefered (fStartList.Events [j].Event)< 0) then
            begin
              lbEvents.Items.Add ('');
              fEvents [lbEvents.Count-1].fEvent:= fStartList.Events [j];
              fEvents [lbEvents.Count-1].filtered:= false;
            end;
        end;
    end
  else
    begin
      for j:= 0 to fStartList.Events.Count-1 do
        begin
          lbEvents.Items.Add ('');
          fEvents [j].fEvent:= fStartList.Events [j];
          fEvents [j].filtered:= false;
        end;
    end;}

  if fShooter= nil then
    exit;
  for j:= 0 to Length (fEvents)-1 do
    begin
      fEvents [j].start_no:= fEvents [j].fEvent.StartNumber;
      esh:= fEvents [j].fEvent.Shooters.FindShooter (fShooter);
      if esh<> nil then
        begin
          with fEvents [j] do
            begin
              fPresentEvent:= esh;
              fAdded:= true;
              fOutOfRank:= esh.OutOfRank;
              fTeamForPoints:= esh.TeamForPoints;
              fRegionPoints:= esh.GiveRegionPoints;
              fDistrictPoints:= esh.GiveDistrictPoints;
              fTeamForResults:= esh.TeamForResults;
            end;
        end
      else
        begin
          with fEvents [j] do
            begin
              fPresentEvent:= nil;
              fAdded:= false;
              fOutOfRank:= false;
              fTeamForPoints:= '';
              fRegionPoints:= false;
              fDistrictPoints:= false;
              fTeamForResults:= '';
            end;
        end;
    end;
  UpdateShooterInfo;
  ssh:= fStartList.Shooters.FindShooter (fShooter);
  if (ssh<> nil) then
    begin
      fStartNumber:= ssh.StartNumber;
    end
  else
    begin
      fStartNumber:= fStartList.NextAvailableStartNumber;
    end;
  lNum.Caption:= LeftFillStr (IntToStr (fStartNumber),3,'0');
  btnEdit.Top:= lClub.Top+lClub.Height-btnEdit.Height;
  if fStartList.StartNumbers then
    begin
      lNumC.Visible:= true;
      lNum.Visible:= true;
      pnlEvents.Top:= lNum.Top+lNum.Height+8;
      pnlEvents.Height:= btnOk.Top-8-pnlEvents.Top;
    end
  else
    begin
      lNumC.Visible:= false;
      lNum.Visible:= false;
      pnlEvents.Top:= lClub.Top+lClub.Height+8;
      pnlEvents.Height:= btnOk.Top-8-pnlEvents.Top;
    end;
end;

procedure TAddToStartDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
  fStartNoStr:= Language ['StartNo'];
  fNoTeamForPointsStr:= Language ['AddToStartDialog.NoTeamForPointsMark'];
  fNoTeamForResultsStr:= Language ['AddToStartDialog.NoTeamForResultsMark'];
end;

procedure TAddToStartDialog.btnCancelClick(Sender: TObject);
begin
  fModalResult:= mrCancel;
  Close;
end;

procedure TAddToStartDialog.PrintStartNumber (sh: TStartListShooterItem);
begin
  if (sh.EventsCount> 0) then
    begin
      fStartList.StartNumbersPrintout.AddShooter (sh);
      fNumberPrinted:= true;
      btnPrint.Enabled:= false;
    end;
end;

procedure TAddToStartDialog.btnPrintClick(Sender: TObject);
var
  sh: TStartListShooterItem;
begin
  sh:= fStartList.Shooters.FindShooter (fShooter);
  if sh<> nil then
    PrintStartNumber (sh);
  lbEvents.SetFocus;
end;

function TAddToStartDialog.SectionAtPos(x: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= 0 to HeaderControl1.Sections.Count-1 do
    if (x> HeaderControl1.Sections [i].Left) and (x< HeaderControl1.Sections [i].Right) then
      begin
        Result:= i;
        exit;
      end;
end;

procedure TAddToStartDialog.SelectTeamForPoints(idx: integer; UseLast: boolean);
var
  tsd: TTeamSelectDialog;
  p: TPoint;
  r: TRect;
begin
  if (idx< 0) or (idx>= Length (fEvents)) or (not fEvents [idx].fAdded) then
    exit;

  if (fEvents [idx].fTeamForPoints= '') and (UseLast) and ((fLastTeamForPoints<> '') or (fLastTeamForResults<> '')) then
    begin
      if fLastTeamForPoints<> '' then
        fEvents [idx].fTeamForPoints:= fLastTeamForPoints
      else
        begin
          fEvents [idx].fTeamForPoints:= fLastTeamForResults;
          fLastTeamForPoints:= fLastTeamForResults;
        end;
      fEvents [idx].fOutOfRank:= false;
    end
  else
    begin
      r:= lbEvents.ItemRect (idx);
      p:= lbEvents.ClientToScreen (Point (r.Left+HeaderControl1.Sections [4].Left,r.Top));
      tsd:= TTeamSelectDialog.Create (self);
      tsd.Left:= p.X;
      tsd.Top:= p.Y;
      tsd.StartList:= fStartList;
      if fEvents [idx].fTeamForPoints<> '' then
        tsd.Team:= fEvents [idx].fTeamForPoints
      else
        tsd.Team:= fLastTeamForPoints;
      if tsd.Execute then
        begin
          fEvents [idx].fTeamForPoints:= tsd.Team;
          if tsd.Team<> '' then
            begin
              fEvents [idx].fOutOfRank:= false;
              fLastTeamForPoints:= tsd.Team;
            end;
        end;
      tsd.Free;
    end;
  lbEvents.Invalidate;
end;

procedure TAddToStartDialog.SelectTeamForResults(idx: integer; UseLast: boolean);
var
  tsd: TTeamSelectDialog;
  p: TPoint;
  r: TRect;
begin
  if (idx< 0) or (idx>= Length (fEvents)) or (not fEvents [idx].fAdded) then
    exit;

  if (fEvents [idx].fTeamForResults= '') and (UseLast) and ((fLastTeamForResults<> '') or (fLastTeamForPoints<> '')) then
    begin
      if fLastTeamForResults<> '' then
        fEvents [idx].fTeamForResults:= fLastTeamForResults
      else
        begin
          fEvents [idx].fTeamForResults:= fLastTeamForPoints;
          fLastTeamForResults:= fLastTeamForPoints;
        end;
      fEvents [idx].fOutOfRank:= false;
    end
  else
    begin
      r:= lbEvents.ItemRect (idx);
      p:= lbEvents.ClientToScreen (Point (r.Left+HeaderControl1.Sections [7].Left,r.Top));

      tsd:= TTeamSelectDialog.Create (self);
      tsd.Left:= p.X;
      tsd.Top:= p.Y;
      tsd.StartList:= fStartList;
      if fEvents [idx].fTeamForResults<> '' then
        tsd.Team:= fEvents [idx].fTeamForResults
      else
        tsd.Team:= fLastTeamForResults;
      if tsd.Execute then
        begin
          fEvents [idx].fTeamForResults:= tsd.Team;
          if tsd.Team<> '' then
            begin
              fEvents [idx].fOutOfRank:= false;
              fLastTeamForResults:= tsd.Team;
            end;
        end;
      tsd.Free;
    end;
  lbEvents.Invalidate;
end;

end.

