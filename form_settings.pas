{$a-}
unit form_settings;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types, System.UITypes,
	Vcl.Graphics, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, CheckLst,

  Data,
  SysFont,

  MyLanguage,
  ctrl_language,

  form_eventparams;

type
	TSettingsForm = class(TForm)
		pcSettings: TPageControl;
		tsEvents: TTabSheet;
		tsChampionships: TTabSheet;
		tsQualifications: TTabSheet;
		tsGeneral: TTabSheet;
		hcEvents: THeaderControl;
		lbEvents: TListBox;
		hcChampionships: THeaderControl;
    pnlQuals: TPanel;
		lbQualifications: TListBox;
    pnlEvents: TPanel;
    pnlChamps: TPanel;
    btnAddEvent: TButton;
    btnDeleteEvent: TButton;
		lbChampionships: TListBox;
    btnAddChamp: TButton;
    btnDeleteChamp: TButton;
    hcQualifications: THeaderControl;
    btnAddQual: TButton;
    btnDeleteQual: TButton;
    btnMoveUpQual: TButton;
    btnMoveDownQual: TButton;
    edtName: TEdit;
    lName: TLabel;
    tsSocieties: TTabSheet;
    btnAddSoc: TButton;
    btnDeleteSoc: TButton;
    btnMoveSocUp: TButton;
    btnMoveSocDown: TButton;
    lbSocieties: TListBox;
    btnCopyEvent: TButton;
    btnCopyChamp: TButton;
    procedure lbChampionshipsClick(Sender: TObject);
    procedure btnCopyChampClick(Sender: TObject);
    procedure btnMoveSocDownClick(Sender: TObject);
    procedure btnMoveSocUpClick(Sender: TObject);
    procedure lbSocietiesKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure lbSocietiesDblClick(Sender: TObject);
    procedure btnDeleteSocClick(Sender: TObject);
    procedure lbSocietiesClick(Sender: TObject);
    procedure btnAddSocClick(Sender: TObject);
    procedure tsSocietiesResize(Sender: TObject);
    procedure tsGeneralResize(Sender: TObject);
		procedure FormCreate(Sender: TObject);
		procedure lbEventsDrawItem(Control: TWinControl; Index: Integer;
			ARect: TRect; State: TOwnerDrawState);
		procedure hcEventsSectionResize(HeaderControl: THeaderControl;
			Section: THeaderSection);
		procedure lbEventsDblClick(Sender: TObject);
		procedure btnAddEventClick(Sender: TObject);
		procedure lbEventsClick(Sender: TObject);
		procedure btnDeleteEventClick(Sender: TObject);
		procedure lbChampionshipsDrawItem(Control: TWinControl; Index: Integer;
			ARect: TRect; State: TOwnerDrawState);
		procedure lbChampionshipsMouseMove(Sender: TObject; Shift: TShiftState;
			X, Y: Integer);
		procedure lbChampionshipsMouseDown(Sender: TObject;
			Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure lbChampionshipsDblClick(Sender: TObject);
		procedure btnAddChampClick(Sender: TObject);
		procedure btnDeleteChampClick(Sender: TObject);
		procedure hcChampionshipsSectionResize(HeaderControl: THeaderControl;
			Section: THeaderSection);
		procedure lbEventsKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure FormKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure lbChampionshipsKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure pcSettingsChange(Sender: TObject);
		procedure leNameKeyPress(Sender: TObject; var Key: Char);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure btnAddQualClick(Sender: TObject);
		procedure btnDeleteQualClick(Sender: TObject);
		procedure btnMoveUpQualClick(Sender: TObject);
		procedure btnMoveDownQualClick(Sender: TObject);
		procedure lbQualificationsClick(Sender: TObject);
		procedure lbQualificationsDblClick(Sender: TObject);
		procedure lbQualificationsKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure lbQualificationsDrawItem(Control: TWinControl;
			Index: Integer; ARect: TRect; State: TOwnerDrawState);
		procedure lbQualificationsMouseMove(Sender: TObject;
			Shift: TShiftState; X, Y: Integer);
		procedure lbQualificationsMouseDown(Sender: TObject;
			Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
	private
		{ Private declarations }
		fData: TData;
    fYesStr: string;
		procedure set_Data(const Value: TData);
		procedure LoadEvents;
		procedure LoadChampionships;
		procedure LoadQualifications;
		function EditChampionship (AChampionship: TChampionshipItem): boolean;
		procedure DeleteEvent (Index: integer);
		procedure AddEvent;
		procedure EditEvent (Index: integer);
		procedure OpenChampionship (Index: integer);
		procedure DeleteChampionship (Index: integer);
		procedure AddChampionship;
    procedure CopyChampionship;
		procedure AddQualification;
		procedure DeleteQualification (Index: integer);
		procedure MoveQualification (Index: integer; Up: boolean);
		function EditQualification (Q: TQualificationItem): boolean;
		procedure OpenQualification (Index: integer);
		procedure ToggleMQS (Index: integer);
		procedure ToggleQualification (Index: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure LoadSocieties;
    procedure AddSociety;
    procedure DeleteSociety (Index: integer);
    procedure EditSociety (Index: integer);
		procedure MoveSociety (Index: integer; Up: boolean);
	public
		{ Public declarations }
		property Data: TData read fData write set_Data;
    function Execute: boolean;
	end;

implementation

{$R *.dfm}

{ TSettingsForm }

procedure TSettingsForm.LoadChampionships;
var
	i: integer;
begin
	lbChampionships.Clear;
	if fData<> nil then
		begin
			for i:= 0 to fData.Championships.Count-1 do
				lbChampionships.Items.Add (fData.Championships.Items [i].Name);
		end;
end;

procedure TSettingsForm.LoadEvents;
var
	i: integer;
	maxwidth,w: integer;
	ev: TEventItem;
begin
	lbEvents.Clear;
	if fData<> nil then
		begin
			lbEvents.Canvas.Font:= lbEvents.Font;
			maxwidth:= 0;
			for i:= 0 to fData.Events.Count-1 do
				begin
					ev:= fData.Events.Items [i];
					lbEvents.Items.Add (ev.ShortName);
					w:= lbEvents.Canvas.TextWidth (ev.Name);
					if w> maxwidth then
						maxwidth:= w;
				end;
			if maxwidth> lbEvents.ClientWidth div 2 then
				maxwidth:= lbEvents.ClientWidth div 2;
			hcEvents.Sections [0].Width:= maxwidth+8;
		end;
end;

procedure TSettingsForm.LoadQualifications;
var
	i: integer;
begin
	lbQualifications.Clear;
	if fData<> nil then
		begin
			for i:= 0 to fData.Qualifications.Count-1 do
				lbQualifications.Items.Add (fData.Qualifications.Items [i].Name);
		end;
end;

procedure TSettingsForm.LoadSocieties;
var
  i: integer;
  s: string;
  soc: TSportSocietyItem;
begin
  lbSocieties.Clear;
  if fData<> nil then
    begin
      for i:= 0 to fData.Societies.Count-1 do
        begin
          soc:= fData.Societies.Items [i];
          s:= format ('[%d]   %s',[soc.ShootersCount,soc.Name]);
          lbSocieties.Items.Add (s);
        end;
    end;
end;

procedure TSettingsForm.set_Data(const Value: TData);
begin
	fData:= Value;
	Caption:= format (Language ['SettingsForm'],[fData.Name]);
	edtName.Text:= fData.Name;
	LoadEvents;
	LoadChampionships;
	LoadQualifications;
  LoadSocieties;
	pcSettings.ActivePage:= tsGeneral;
end;

procedure TSettingsForm.FormCreate(Sender: TObject);
begin
  Width:= round (Screen.Width * 0.9);
  Height:= round (Screen.Height * 0.9);
  UpdateLanguage;
  UpdateFonts;
  Position:= poScreenCenter;
end;

procedure TSettingsForm.lbEventsDrawItem(Control: TWinControl;
	Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
	ev: TEventItem;
	Section: THeaderSection;
	sr: TRect;
	l2,l1,l0: integer;
begin
	ev:= fData.Events.Items [index];
	with lbEvents.Canvas do
		begin
			Brush.Style:= bsSolid;
      FillRect (ARect);
			if ev= nil then
				exit;

			Brush.Style:= bsClear;
			l0:= 3;
			l2:= abs (Font.Height)+3;
			l1:= (lbEvents.ItemHeight - abs (Font.Height)) div 2;

			Section:= hcEvents.Sections [0];
			sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
			Font.Style:= [fsBold];
			TextRect (sr,sr.Left,sr.Top+l0,ev.ShortName);
			Font.Style:= [];
			TextRect (sr,sr.Left,sr.Top+l2,ev.Name);
      Font.Style:= [fsBold];

      Section:= hcEvents.Sections [1];
			sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
      TextRect (sr,sr.Left,sr.Top+l1,ev.Code);

			Section:= hcEvents.Sections [2];
			sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
			TextRect (sr,sr.Left,sr.Top+l1,IntToStr (ev.MQSResult10 div 10));

			Section:= hcEvents.Sections [3];
			sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
			if ev.FinalFracs then
				TextRect (sr,sr.Left,sr.Top+l1,fYesStr);

			Section:= hcEvents.Sections [4];
			sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
			if ev.FinalPlaces> 0 then
				TextRect (sr,sr.Left,sr.Top+l1,IntToStr (ev.FinalPlaces));

			Section:= hcEvents.Sections [5];
			sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
			TextRect (sr,sr.Left,sr.Top+l1,IntToStr (ev.Stages)+', '+IntToStr (ev.SeriesPerStage));

			Section:= hcEvents.Sections [6];
			sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
			TextRect (sr,sr.Left,sr.Top+l1,FormatDateTime ('hh:nn',ev.RelayTime));
		end;
end;

procedure TSettingsForm.hcEventsSectionResize(
  HeaderControl: THeaderControl; Section: THeaderSection);
begin
	lbEvents.Refresh;
end;

procedure TSettingsForm.lbEventsDblClick(Sender: TObject);
begin
	EditEvent (lbEvents.ItemIndex);
end;

procedure TSettingsForm.btnAddEventClick(Sender: TObject);
begin
	AddEvent;
end;

procedure TSettingsForm.lbEventsClick(Sender: TObject);
begin
	btnDeleteEvent.Enabled:= lbEvents.ItemIndex>= 0;
//  btnCopyEvent.Enabled:= btnDeleteEvent.Enabled;
end;

procedure TSettingsForm.btnDeleteEventClick(Sender: TObject);
begin
	DeleteEvent (lbEvents.ItemIndex);
end;

procedure TSettingsForm.lbChampionshipsDrawItem(Control: TWinControl;
	Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
	ch: TChampionshipItem;
	Section: THeaderSection;
	sr: TRect;
  uState: cardinal;
begin
	ch:= fData.Championships.Items [Index];
	with lbChampionships.Canvas do
		begin
			Brush.Style:= bsSolid;
      FillRect (ARect);

			if ch= nil then
				exit;

			Brush.Style:= bsClear;

			Section:= hcChampionships.Sections [0];
			sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
			TextRect (sr,sr.Left,sr.Top+3,ch.Name);

			Section:= hcChampionships.Sections [1];
      sr:= Rect (Section.Left,ARect.Top+3,Section.Right,ARect.Bottom-3);
			if ch.MQS then
        uState:= DFCS_BUTTONCHECK or DFCS_CHECKED
      else
        uState:= DFCS_BUTTONCHECK;
      DrawFrameControl (Handle,sr,DFC_BUTTON,uState);
		end;
end;

procedure TSettingsForm.lbChampionshipsMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
var
	idx: integer;
	section: THeaderSection;
begin
	idx:= lbChampionships.ItemAtPos (Point (X,Y),true);
	if idx>= 0 then
		begin
			section:= hcChampionships.Sections [1];
			if abs (X-(section.Left+section.Right) div 2)<= (lbChampionships.ItemHeight-6) div 2 then
				lbChampionships.Cursor:= crHandPoint
			else
				lbChampionships.Cursor:= crDefault;
		end
	else
		lbChampionships.Cursor:= crDefault;
end;

procedure TSettingsForm.lbChampionshipsMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	idx: integer;
	section: THeaderSection;
begin
	idx:= lbChampionships.ItemAtPos (Point (X,Y),true);
	lbChampionships.ItemIndex:= idx;
	if idx>= 0 then
		begin
			section:= hcChampionships.Sections [1];
			if abs (X-(section.Left+section.Right) div 2) <= (lbChampionships.ItemHeight-6) div 2 then
				ToggleMQS (idx);
		end;
end;

procedure TSettingsForm.lbChampionshipsClick(Sender: TObject);
begin
  btnCopyChamp.Enabled:= (lbChampionships.ItemIndex>= 0);
  btnDeleteChamp.Enabled:= btnCopyChamp.Enabled;
end;

procedure TSettingsForm.lbChampionshipsDblClick(Sender: TObject);
begin
	OpenChampionship (lbChampionships.ItemIndex);
end;

function TSettingsForm.EditChampionship(
	AChampionship: TChampionshipItem): boolean;
var
	s: string;
	c: string;
begin
	Result:= false;
	s:= AChampionship.Name;
	if AChampionship.Tag= '' then
		c:= Language ['NewChamp']
	else
		c:= Language ['ChampName'];
	if InputQuery (c,'',s) then
		begin
			s:= Trim (s);
			if s= '' then
				begin
					MessageDlg (Language ['ChampNameEmpty'],mtError,[mbOk],0);
					exit;
				end;
			if AChampionship.Tag= '' then
				AChampionship.CreateTag;
			AChampionship.Name:= s;
			Result:= true;
		end;
end;

procedure TSettingsForm.btnAddChampClick(Sender: TObject);
begin
	AddChampionship;
end;

procedure TSettingsForm.btnDeleteChampClick(Sender: TObject);
begin
	DeleteChampionship (lbChampionships.ItemIndex);
end;

procedure TSettingsForm.hcChampionshipsSectionResize(
  HeaderControl: THeaderControl; Section: THeaderSection);
begin
	lbChampionships.Refresh;
end;

procedure TSettingsForm.lbEventsKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_DELETE: begin
			Key:= 0;
			DeleteEvent (lbEvents.ItemIndex);
		end;
		VK_INSERT: begin
			Key:= 0;
			AddEvent;
		end;
		VK_RETURN: begin
			Key:= 0;
			EditEvent (lbEvents.ItemIndex);
		end;
	end;
end;

procedure TSettingsForm.DeleteEvent(Index: integer);
var
	ev: TEventItem;
	idx: integer;
begin
  if (index< 0) or (index>= fData.Events.Count) then
    exit;
	ev:= fData.Events.Items [Index];
  if ev= nil then
    exit;
  if MessageDlg (format (Language ['DeleteEventPrompt'],[ev.ShortName,ev.Name]),mtConfirmation,[mbYes,mbNo],0)<> idYes then
    exit;
  if fData.StartLists.HaveEvent (ev) then
    begin
      if MessageDlg (Language ['DeleteEventFromStartListsPrompt'],mtConfirmation,[mbYes,mbNo],0)<> idYes then
        exit;
      fData.StartLists.DeleteEvent (ev);
    end;
  idx:= ev.Index;
  if MessageDlg (Language ['DeleteEventResultsPrompt'],mtConfirmation,[mbYes,mbNo],0)= idYes then
    begin
      fData.DeleteResults (ev);
      fData.ShootingChampionships.DeleteEvents (ev);
    end
  else
    fData.ShootingChampionships.ConvertEventToNil (ev,ev.ShortName,ev.Name);
  fData.Championships.DeleteEventTable (ev);
  fData.Events.Delete (ev.Index);
  LoadEvents;
  if idx< lbEvents.Count then
    lbEvents.ItemIndex:= idx
  else
    lbEvents.ItemIndex:= lbEvents.Count-1;
end;

procedure TSettingsForm.AddEvent;
var
  epd: TEventParamsDialog;
	ev: TEventItem;
begin
	ev:= fData.Events.Add;
  fData.Championships.AddEventTable (ev);
  epd:= TEventParamsDialog.Create (self);
  epd.Event:= ev;
  if epd.Execute then
    begin
      LoadEvents;
      lbEvents.ItemIndex:= ev.Index;
    end
  else
    begin
      fData.Championships.DeleteEventTable (ev);
      ev.Free;
    end;
  epd.Free;
end;

procedure TSettingsForm.EditEvent(Index: integer);
var
	ev: TEventItem;
  epd: TEventParamsDialog;
begin
	ev:= fData.Events.Items [Index];
  epd:= TEventParamsDialog.Create (self);
	if ev<> nil then
		begin
			epd.Event:= ev;
      if epd.Execute then
  			lbEvents.Refresh;
		end;
  epd.Free;
end;

procedure TSettingsForm.FormKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_ESCAPE: begin
			Close;
			ModalResult:= mrCancel;
		end;
		VK_F3: begin
			Key:= 0;
			pcSettings.SelectNextPage (not (ssShift in Shift),true);
		end;
	end;
end;

procedure TSettingsForm.lbChampionshipsKeyDown(Sender: TObject;
	var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_DELETE: begin
			Key:= 0;
			DeleteChampionship (lbChampionships.ItemIndex);
		end;
		VK_INSERT: begin
			Key:= 0;
			AddChampionship;
		end;
		VK_RETURN: begin
			Key:= 0;
			OpenChampionship (lbChampionships.ItemIndex);
		end;
		VK_SPACE: begin
			Key:= 0;
			ToggleMQS (lbChampionships.ItemIndex);
		end;
	end;
end;

procedure TSettingsForm.OpenChampionship(Index: integer);
var
	ch: TChampionshipItem;
begin
	ch:= fData.Championships.Items [Index];
	if ch<> nil then
		if EditChampionship (ch) then
			lbChampionships.Refresh;
end;

procedure TSettingsForm.DeleteChampionship(Index: integer);
var
	ch: TChampionshipItem;
	idx: integer;
begin
	ch:= fData.Championships.Items [lbChampionships.ItemIndex];
	if ch<> nil then
		begin
			if MessageDlg (format (Language ['DeleteChampPrompt'],[ch.Name]),mtConfirmation,[mbYes,mbNo],0)= idYes then
				begin
					idx:= ch.Index;
					if MessageDlg (Language ['DeleteChampResultsPrompt'],mtConfirmation,[mbYes,mbNo],0)= idYes then
            begin
  						fData.DeleteResults (ch);
              fData.ShootingChampionships.DeleteChampionships (ch);
            end
          else
            fData.ShootingChampionships.ConvertChampionshipToNil (ch,ch.Name);
          fData.StartLists.ConvertChampionshipToNil (ch);
					fData.Championships.Delete (ch.Index);
					LoadChampionships;
					if idx< lbChampionships.Count then
						lbChampionships.ItemIndex:= idx
					else
						lbChampionships.ItemIndex:= lbChampionships.Count-1;
				end;
		end;
end;

procedure TSettingsForm.AddChampionship;
var
	ch: TChampionshipItem;
begin
	ch:= fData.Championships.Add;
	if EditChampionship (ch) then
		begin
			LoadChampionships;
			lbChampionships.ItemIndex:= ch.Index;
		end
	else
		ch.Free;
end;

procedure TSettingsForm.pcSettingsChange(Sender: TObject);
begin
	case pcSettings.ActivePageIndex of
		0: edtName.SetFocus;
		1: lbEvents.SetFocus;
		2: lbChampionships.SetFocus;
		3: lbQualifications.SetFocus;
	end;
end;

procedure TSettingsForm.leNameKeyPress(Sender: TObject; var Key: Char);
begin
	case Key of
		#1..#7,#9..#31: begin
			Key:= #0;
		end;
	end;
end;

procedure TSettingsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
	fData.Name:= edtName.Text;
end;

procedure TSettingsForm.btnAddQualClick(Sender: TObject);
begin
	AddQualification;
end;

procedure TSettingsForm.btnAddSocClick(Sender: TObject);
begin
  AddSociety;
end;

procedure TSettingsForm.btnCopyChampClick(Sender: TObject);
begin
  CopyChampionship;
end;

procedure TSettingsForm.btnDeleteQualClick(Sender: TObject);
begin
	DeleteQualification (lbQualifications.ItemIndex);
end;

procedure TSettingsForm.btnDeleteSocClick(Sender: TObject);
begin
  DeleteSociety (lbSocieties.ItemIndex);
end;

procedure TSettingsForm.btnMoveUpQualClick(Sender: TObject);
begin
	MoveQualification (lbQualifications.ItemIndex,true);
end;

procedure TSettingsForm.CopyChampionship;
var
	ch,ch1: TChampionshipItem;
begin
  if lbChampionships.ItemIndex< 0 then
    exit;
  ch1:= fData.Championships.Items [lbChampionships.ItemIndex];
	ch:= fData.Championships.Add;
  ch.Assign (ch1);
	if EditChampionship (ch) then
		begin
			LoadChampionships;
			lbChampionships.ItemIndex:= ch.Index;
		end
	else
		ch.Free;
end;

procedure TSettingsForm.btnMoveDownQualClick(Sender: TObject);
begin
	MoveQualification (lbQualifications.ItemIndex,false);
end;

procedure TSettingsForm.btnMoveSocDownClick(Sender: TObject);
begin
  MoveSociety (lbSocieties.ItemIndex,false);
end;

procedure TSettingsForm.btnMoveSocUpClick(Sender: TObject);
begin
  MoveSociety (lbSocieties.ItemIndex,true);
end;

procedure TSettingsForm.AddQualification;
var
	q: TQualificationItem;
begin
	q:= fData.Qualifications.Add;
	if EditQualification (q) then
		begin
			LoadQualifications;
			lbQualifications.ItemIndex:= q.Index;
		end
	else
		q.Free;
end;

procedure TSettingsForm.AddSociety;
var
  s: TSportSocietyItem;
  n: string;
begin
  n:= '';
  if InputQuery (Language ['AddSocietyCaption'],Language ['AddSocietyPrompt'],n) then
    begin
      s:= fData.Societies.Find (n);
      if s= nil then
        begin
          s:= fData.Societies.Add;
          s.Name:= n;
          lbSocieties.Items.Add (s.Name);
        end;
      lbSocieties.ItemIndex:= s.Index;
    end;
  lbSocieties.SetFocus;
end;

procedure TSettingsForm.DeleteQualification(Index: integer);
var
	q: TQualificationItem;
	idx: integer;
begin
	q:= fData.Qualifications.Items [Index];
	if q= nil then
		exit;
	if MessageDlg (format (Language ['DeleteQualPrompt'],[q.Name]),mtConfirmation,[mbYes,mbNo],0)= idYes then
		begin
			idx:= q.Index;
      fData.Events.DeleteQualification (q.Index);
			fData.Qualifications.Delete (q.Index);
			LoadQualifications;
			if idx< lbQualifications.Count then
				lbQualifications.ItemIndex:= idx
			else
				lbQualifications.ItemIndex:= lbQualifications.Count-1;
		end;
end;

procedure TSettingsForm.DeleteSociety (Index: integer);
var
  s: TSportSocietyItem;
  idx: integer;
begin
  s:= fData.Societies.Items [Index];
  if s= nil then
    exit;
  if MessageDlg (format (Language ['DeleteSocietyPrompt'],[s.Name]),mtConfirmation,[mbYes,mbNo],0)= idYes then
    begin
      idx:= s.Index;
      fData.Groups.DeleteSociety (s);
      s.Free;
      lbSocieties.Items.Delete (idx);
      if idx< lbSocieties.Count then
        lbSocieties.ItemIndex:= idx
      else
        lbSocieties.ItemIndex:= lbSocieties.Count-1;
    end;
end;

procedure TSettingsForm.MoveQualification(Index: integer; Up: boolean);
var
	q: TQualificationItem;
	topidx: integer;
begin
	q:= fData.Qualifications.Items [Index];
	if q= nil then
		exit;
	if (Up) and (q.Index= 0) then
		exit;
	if (not Up) and (q.Index= fData.Qualifications.Count-1) then
		exit;
	if Up then
		q.Index:= q.Index-1
	else
		q.Index:= q.Index+1;
	topidx:= lbQualifications.TopIndex;
	LoadQualifications;
	lbQualifications.TopIndex:= topidx;
	lbQualifications.ItemIndex:= q.Index;
	lbQualificationsClick (self);
end;

procedure TSettingsForm.MoveSociety(Index: integer; Up: boolean);
var
  s: TSportSocietyItem;
  topidx: integer;
begin
  s:= fData.Societies.Items [Index];
  if s= nil then
    exit;
  if (Up) and (s.Index=0) then
    exit;
  if (not Up) and (s.Index= fData.Societies.Count-1) then
    exit;
  if Up then
    s.Index:= s.Index-1
  else
    s.Index:= s.Index+1;
  topidx:= lbSocieties.TopIndex;
  LoadSocieties;
  lbSocieties.TopIndex:= topidx;
  lbSocieties.ItemIndex:= s.Index;
  lbSocietiesClick (self);
end;

function TSettingsForm.EditQualification(Q: TQualificationItem): boolean;
var
	s,c: string;
begin
	Result:= false;
	s:= Q.Name;
	if Q.Name= '' then
		c:= Language ['NewQual']
	else
		c:= Language ['QualName'];
	if InputQuery (c,'',s) then
		begin
			s:= Trim (s);
			if s= '' then
				begin
					MessageDlg (Language ['QualNameEmpty'],mtError,[mbOk],0);
					exit;
				end;
			Q.Name:= s;
			Result:= true;
		end;
end;

procedure TSettingsForm.EditSociety(Index: integer);
var
  s: TSportSocietyItem;
  n: string;
begin
  if Index< 0 then
    exit;
  s:= fData.Societies.Items [Index];
  n:= s.Name;
  if InputQuery (Language ['EditSocietyCaption'],Language ['EditSocietyPrompt'],n) then
    begin
      s.Name:= n;
      lbSocieties.Items [Index]:= s.Name;
    end;
end;

procedure TSettingsForm.lbQualificationsClick(Sender: TObject);
begin
	btnMoveUpQual.Enabled:= (lbQualifications.ItemIndex> 0);
	btnMoveDownQual.Enabled:= (lbQualifications.ItemIndex< lbQualifications.Count-1);
end;

procedure TSettingsForm.lbQualificationsDblClick(Sender: TObject);
begin
	OpenQualification (lbQualifications.ItemIndex);
end;

procedure TSettingsForm.lbQualificationsKeyDown(Sender: TObject;
	var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_RETURN: begin
			Key:= 0;
			OpenQualification (lbQualifications.ItemIndex);
		end;
		VK_DELETE: begin
			Key:= 0;
			DeleteQualification (lbQualifications.ItemIndex);
		end;
		VK_INSERT: begin
			Key:= 0;
			AddQualification;
		end;
		VK_UP: if ssShift in Shift then
			begin
				Key:= 0;
				MoveQualification (lbQualifications.ItemIndex,true);
			end;
		VK_DOWN: if ssShift in Shift then
			begin
				Key:= 0;
				MoveQualification (lbQualifications.ItemIndex,false);
			end;
		VK_SPACE: begin
			Key:= 0;
			ToggleQualification (lbQualifications.ItemIndex);
		end;
	end;
end;

procedure TSettingsForm.OpenQualification(Index: integer);
var
	q: TQualificationItem;
begin
	q:= fData.Qualifications.Items [Index];
	if q= nil then
		exit;
	if EditQualification (q) then
		begin
			lbQualifications.Refresh;
		end;
end;

procedure TSettingsForm.lbQualificationsDrawItem(Control: TWinControl;
	Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
	q: TQualificationItem;
	sr: TRect;
	Section: THeaderSection;
  uState: cardinal;
begin
	q:= fData.Qualifications.Items [Index];
	with lbQualifications.Canvas do
		begin
			Brush.Style:= bsSolid;
      FillRect (ARect);
			if q= nil then
				exit;
			Brush.Style:= bsClear;

			Section:= hcQualifications.Sections [0];
			sr:= Rect (ARect.Left+Section.Left+4,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
			TextRect (sr,sr.Left,sr.Top+3,q.Name);

			Section:= hcQualifications.Sections [1];
      sr:= Rect (Section.Left,ARect.Top+3,Section.Right,ARect.Bottom-3);
			if q.SetByResult then
        uState:= DFCS_BUTTONCHECK or DFCS_CHECKED
      else
        uState:= DFCS_BUTTONCHECK;
      DrawFrameControl (Handle,sr,DFC_BUTTON,uState);
		end;
end;

procedure TSettingsForm.ToggleMQS(Index: integer);
var
	ch: TChampionshipItem;
begin
	ch:= fData.Championships.Items [Index];
	if ch<> nil then
		begin
			ch.MQS:= not ch.MQS;
			lbChampionships.Refresh;
		end;
end;

procedure TSettingsForm.ToggleQualification(Index: integer);
var
	q: TQualificationItem;
begin
	q:= fData.Qualifications.Items [Index];
	if q<> nil then
		begin
			q.SetByResult:= not q.SetByResult;
			lbQualifications.Refresh;
		end;
end;

procedure TSettingsForm.tsGeneralResize(Sender: TObject);
begin
  edtName.Width:= tsGeneral.ClientWidth-32-edtName.Left;
end;

procedure TSettingsForm.tsSocietiesResize(Sender: TObject);
begin
  lbSocieties.Width:= tsSocieties.ClientWidth-lbSocieties.Left-4;
  lbSocieties.Height:= tsSocieties.ClientHeight-lbSocieties.Top-4;
end;

procedure TSettingsForm.UpdateFonts;
var
  bh: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  edtName.Left:= lName.Left+lName.Width+16;
  lName.Top:= edtName.Top+(edtName.Height-lName.Height) div 2;
  lbEvents.Canvas.Font:= lbEvents.Font;
  lbEvents.ItemHeight:= lbEvents.Canvas.TextHeight ('Mg')*2+6;
  lbChampionships.Canvas.Font:= lbChampionships.Font;
  lbChampionships.ItemHeight:= lbChampionships.Canvas.TextHeight ('Mg')+6;
  lbQualifications.Canvas.Font:= lbQualifications.Font;
	lbQualifications.ItemHeight:= lbQualifications.Canvas.TextHeight ('Mg')+6;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnAddEvent.Left:= 8;
  btnAddEvent.Top:= 8;
  btnAddEvent.ClientHeight:= bh;
  btnAddEvent.ClientWidth:= Canvas.TextWidth (btnAddEvent.Caption)+16;
  btnDeleteEvent.Top:= btnAddEvent.Top;
  btnDeleteEvent.Left:= btnAddEvent.Left+btnAddEvent.Width+8;
  btnDeleteEvent.ClientWidth:= Canvas.TextWidth (btnDeleteEvent.Caption)+16;
  btnDeleteEvent.ClientHeight:= bh;
  btnCopyEvent.Top:= btnAddEvent.Top;
  btnCopyEvent.Left:= btnDeleteEvent.Left+btnDeleteEvent.Width+8;
  btnCopyEvent.ClientWidth:= Canvas.TextWidth (btnCopyEvent.Caption)+16;
  btnCopyEvent.ClientHeight:= bh;
  btnAddChamp.Left:= 8;
  btnAddChamp.Top:= 8;
  btnAddChamp.ClientHeight:= bh;
  btnAddChamp.ClientWidth:= Canvas.TextWidth (btnAddChamp.Caption)+16;
  btnDeleteChamp.Top:= btnAddChamp.Top;
  btnDeleteChamp.Left:= btnAddChamp.Left+btnAddChamp.Width+8;
  btnDeleteChamp.Width:= Canvas.TextWidth (btnDeleteChamp.Caption)+16;
  btnDeleteChamp.ClientHeight:= bh;
  btnCopyChamp.Top:= btnAddChamp.Top;
  btnCopyChamp.Left:= btnDeleteChamp.Left+btnDeleteChamp.Width+8;
  btnCopyChamp.ClientWidth:= Canvas.TextWidth (btnCopyChamp.Caption)+16;
  btnCopyChamp.ClientHeight:= bh;
  btnAddQual.Left:= 8;
  btnAddQual.Top:= 8;
  btnAddQual.Width:= Canvas.TextWidth (btnAddQual.Caption)+16;
  btnAddQual.ClientHeight:= bh;
  btnDeleteQual.Left:= btnAddQual.Left+btnAddQual.Width+8;
  btnDeleteQual.Width:= Canvas.TextWidth (btnDeleteQual.Caption)+16;
  btnDeleteQual.ClientHeight:= bh;
  btnMoveUpQual.Left:= btnDeleteQual.Left+btnDeleteQual.Width+24;
  btnMoveUpQual.Width:= Canvas.TextWidth (btnMoveUpQual.Caption)+16;
  btnMoveUpQual.ClientHeight:= bh;
  btnMoveDownQual.Left:= btnMoveUpQual.Left+btnMoveUpQual.Width+8;
  btnMoveDownQual.Width:= Canvas.TextWidth (btnMoveDownQual.Caption)+16;
  btnMoveDownQual.ClientHeight:= bh;
  pnlEvents.ClientHeight:= btnAddEvent.Top+btnAddEvent.Height+8;
  pnlChamps.ClientHeight:= btnAddChamp.Top+btnAddChamp.Height+8;
  pnlQuals.ClientHeight:= btnAddQual.Top+btnAddQual.Height+8;
  hcEvents.Canvas.Font:= hcEvents.Font;
  hcEvents.ClientHeight:= hcEvents.Canvas.TextHeight ('Mg')+4;
  hcChampionships.Canvas.Font:= hcChampionships.Font;
  hcChampionships.ClientHeight:= hcChampionships.Canvas.TextHeight ('Mg')+4;
  hcQualifications.Canvas.Font:= hcQualifications.Font;
  hcQualifications.ClientHeight:= hcQualifications.Canvas.TextHeight ('Mg')+4;
  btnAddSoc.Left:= 8;
  btnAddSoc.Top:= 8;
  btnAddSoc.Width:= Canvas.TextWidth (btnAddSoc.Caption)+16;
  btnAddSoc.ClientHeight:= bh;
  btnDeleteSoc.Left:= btnAddSoc.Left+btnAddSoc.Width+8;
  btnDeleteSoc.Width:= Canvas.TextWidth (btnDeleteSoc.Caption)+16;
  btnDeleteSoc.Height:= btnAddSoc.Height;
  btnDeleteSoc.Top:= btnAddSoc.Top;
  btnMoveSocUp.Left:= btnDeleteSoc.Left+btnDeleteSoc.Width+24;
  btnMoveSocUp.Width:= Canvas.TextWidth (btnMoveSocUp.Caption)+16;
  btnMoveSocUp.Height:= btnAddSoc.Height;
  btnMoveSocUp.Top:= btnAddSoc.Top;
  btnMoveSocDown.Left:= btnMoveSocUp.Left+btnMoveSocUp.Width+8;
  btnMoveSocDown.Width:= Canvas.TextWidth (btnMoveSocDown.Caption)+16;
  btnMoveSocDown.Height:= btnAddSoc.Height;
  btnMoveSocDown.Top:= btnMoveSocUp.Top;
  lbSocieties.Left:= 4;
  lbSocieties.Top:= btnAddSoc.Top+btnAddSoc.Height+8;
  lbSocieties.Canvas.Font:= lbSocieties.Font;
  lbSocieties.ItemHeight:= lbSocieties.Canvas.TextHeight ('Mg')+6;
end;

procedure TSettingsForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
  fYesStr:= Language ['Yes'];
end;

procedure TSettingsForm.lbQualificationsMouseMove(Sender: TObject;
	Shift: TShiftState; X, Y: Integer);
var
	idx: integer;
	section: THeaderSection;
begin
	idx:= lbQualifications.ItemAtPos (Point (X,Y),true);
	if idx>= 0 then
		begin
			section:= hcQualifications.Sections [1];
			if abs (X - (section.Left+section.Right) div 2) <= (lbQualifications.ItemHeight-6) div 2 then
				lbQualifications.Cursor:= crHandPoint
			else
				lbQualifications.Cursor:= crDefault;
		end
	else
		lbQualifications.Cursor:= crDefault;
end;

procedure TSettingsForm.lbSocietiesClick(Sender: TObject);
begin
	btnMoveSocUp.Enabled:= (lbSocieties.ItemIndex> 0);
	btnMoveSocDown.Enabled:= (lbSocieties.ItemIndex< lbSocieties.Count-1);
  btnDeleteSoc.Enabled:= (lbSocieties.ItemIndex>= 0);
end;

procedure TSettingsForm.lbSocietiesDblClick(Sender: TObject);
begin
  EditSociety (lbSocieties.ItemIndex);
end;

procedure TSettingsForm.lbSocietiesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
      Key:= 0;
      EditSociety (lbSocieties.ItemIndex);
    end;
    VK_INSERT: begin
      Key:= 0;
      AddSociety;
    end;
    VK_DELETE: begin
      Key:= 0;
      DeleteSociety (lbSocieties.ItemIndex);
    end;
  end;
end;

procedure TSettingsForm.lbQualificationsMouseDown(Sender: TObject;
	Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	idx: integer;
	section: THeaderSection;
begin
	idx:= lbQualifications.ItemAtPos (Point (X,Y),true);
	if idx>= 0 then
		begin
			lbQualifications.ItemIndex:= idx;
			section:= hcQualifications.Sections [1];
      if abs (X - (section.Left+section.Right) div 2) <= (lbQualifications.ItemHeight-6) div 2 then
				ToggleQualification (idx);
		end
end;

function TSettingsForm.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

end.

