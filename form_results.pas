{$a-}
unit form_results;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Menus, CheckLst, Buttons, Grids, Vcl.Printers,
	System.UITypes, System.Types,

  MyPrint,
  Data,
  SysFont,
  wb_registry,

  MyLanguage,
  ctrl_language,

  form_stats,
  form_result;

type
	TResultsFilterItem= class (TCollectionItem)
	private
		fResult: TResultItem;
		fMarked: boolean;
	public
		property Result: TResultItem read fResult write fResult;
		property Marked: boolean read fMarked write fMarked;
	end;

	TResultsFilter= class (TCollection)
	private
		fSortBy: TResultsSortOrder;
		function get_ResultIdx(index: integer): TResultsFilterItem;
		function get_Result(index: integer): TResultItem;
	public
		constructor Create (AShooter: TShooterItem);
		function Add (AResult: TResultItem): TResultsFilterItem; overload;
		procedure Add (AResults: TResults); overload;
		function Add: TResultsFilterItem; overload;
		property Items [index: integer]: TResultsFilterItem read get_ResultIdx;
		property Results [index: integer]: TResultItem read get_Result; default;
		procedure Sort;
		property SortOrder: TResultsSortOrder read fSortBy write fSortBy;
		function MarkedCount: integer;
	end;

	TShooterResultsForm = class(TForm)
		lbResults: TListBox;
		HeaderControl1: THeaderControl;
		pnlFilter: TPanel;
		clbFilter: TCheckListBox;
    btnCloseFilter: TSpeedButton;
    MainMenu1: TMainMenu;
    mnuResults: TMenuItem;
    mnuAdd1: TMenuItem;
    mnuDelete1: TMenuItem;
    mnuFilter1: TMenuItem;
    N1: TMenuItem;
    mnuMark: TMenuItem;
    mnuMarkAll: TMenuItem;
    N2: TMenuItem;
    mnuClose: TMenuItem;
    mnuStats: TMenuItem;
    mnuPrint: TMenuItem;
    mnuSaveToPDF: TMenuItem;
    SaveToPDFDialog: TSaveDialog;
    procedure pnlFilterResize(Sender: TObject);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormCreate(Sender: TObject);
		procedure lbResultsDrawItem(Control: TWinControl; Index: Integer;
			ARect: TRect; State: TOwnerDrawState);
		procedure HeaderControl1SectionResize(HeaderControl: THeaderControl;
			Section: THeaderSection);
		procedure FormDestroy(Sender: TObject);
		procedure HeaderControl1SectionClick(HeaderControl: THeaderControl;
			Section: THeaderSection);
		procedure HeaderControl1Resize(Sender: TObject);
		procedure lbResultsDblClick(Sender: TObject);
		procedure clbFilterClickCheck(Sender: TObject);
		procedure btnCloseFilterClick(Sender: TObject);
		procedure mnuDelete1Click(Sender: TObject);
		procedure mnuAdd1Click(Sender: TObject);
		procedure mnuFilter1Click(Sender: TObject);
		procedure mnuMarkClick(Sender: TObject);
    procedure mnuMarkAllClick(Sender: TObject);
    procedure clbFilterKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbResultsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mnuCloseClick(Sender: TObject);
    procedure mnuStatsClick(Sender: TObject);
    procedure mnuPrintClick(Sender: TObject);
    procedure mnuSaveToPDFClick(Sender: TObject);
	private
		{ Private declarations }
		fShooter: TShooterItem;
		fFilter: TResultsFilter;
		procedure set_Shooter(const Value: TShooterItem);
		procedure LoadFilter;
		procedure DeleteResults (index: integer);
		procedure ChangeResult (index: integer);
		procedure SetFilter;
		procedure LoadEvents;
		procedure ApplyFilter;
		procedure LoadResultsListBox;
		function EditResult (Res: TResultItem; New: boolean): boolean;
		procedure AddResult;
		procedure ToggleMark (Index: integer);
		procedure MarkAll (Marked: boolean);
    procedure ViewStats;
    procedure PrintResults (APrinter: TObject);
    procedure CheckFilter (AEvent: TEventItem);
    procedure UpdateFonts;
    procedure UpdateLanguage;
	public
		{ Public declarations }
		property Shooter: TShooterItem read fShooter write set_Shooter;
    function Execute: boolean;
	end;

implementation

{$R *.dfm}

{ TShooterDetailsForm }

procedure TShooterResultsForm.ChangeResult(index: integer);
var
	res: TResultItem;
	fr: TResultsFilterItem;
	seg: integer;
begin
	fr:= fFilter.Items [index];
	res:= fr.Result;
	if res= nil then
		exit;
	if EditResult (res,false) then
		begin
			fFilter.Sort;
			seg:= lbResults.TopIndex;
			LoadResultsListBox;
			lbResults.TopIndex:= seg;
			lbResults.ItemIndex:= fr.Index;
		end;
end;

procedure TShooterResultsForm.DeleteResults(index: integer);
var
	i: integer;
begin
	if fFilter.MarkedCount> 0 then
		begin
			if MessageDlg (Language ['DeleteMarkedResultsPrompt'],mtConfirmation,[mbYes,mbNo],0)= mrYes then
				begin
					i:= 0;
					while i< fFilter.Count do
						begin
							if fFilter.Items [i].Marked then
								begin
									fShooter.Results.Delete (fFilter.Results [i].Index);
									fFilter.Delete (i);
								end
							else
								inc (i);
						end;
				end;
		end
	else if (index>= 0) and (index< fFilter.Count) then
		begin
			if MessageDlg (Language ['DeleteResultPrompt'],mtConfirmation,[mbYes,mbNo],0)= mrYes then
				begin
					fShooter.Results.Delete (fFilter.Results [index].Index);
					fFilter.Delete (index);
				end;
		end;
	LoadResultsListBox;
	if index>= lbResults.Count then
		lbResults.ItemIndex:= lbResults.Count-1
	else
		lbResults.ItemIndex:= index;
	LoadEvents;
end;

procedure TShooterResultsForm.FormClose(Sender: TObject;
	var Action: TCloseAction);
begin
	lbResults.Clear;
  SaveHeaderControlToRegistry ('ResultsHC',HeaderControl1);
end;

procedure TShooterResultsForm.FormCreate(Sender: TObject);
begin
  clbFilter.Left:= 8;
  clbFilter.Top:= 8;
  Width:= round (Screen.Width * 0.7);
  Height:= round (Screen.Height * 0.7);
  UpdateLanguage;
  UpdateFonts;
	fFilter:= TResultsFilter.Create (fShooter);
  LoadHeaderControlFromRegistry ('ResultsHC',HeaderControl1);
end;

procedure TShooterResultsForm.FormDestroy(Sender: TObject);
begin
	fFilter.Free;
end;

procedure TShooterResultsForm.HeaderControl1SectionClick(
	HeaderControl: THeaderControl; Section: THeaderSection);
var
	so: TResultsSortOrder;
begin
	case Section.Index of
		0: so:= rsoDate;
		2: so:= rsoRank;
		3: so:= rsoCompetition;
		5: so:= rsoRating;
	else
		exit;
	end;
	if so<> fFilter.SortOrder then
		begin
			fFilter.SortOrder:= so;
			fFilter.Sort;
			lbResults.Refresh;
		end;
end;

procedure TShooterResultsForm.HeaderControl1SectionResize(
	HeaderControl: THeaderControl; Section: THeaderSection);
begin
	HeaderControl1Resize (self);
	lbResults.Refresh;
end;

procedure TShooterResultsForm.HeaderControl1Resize(Sender: TObject);
var
	s: THeaderSection;
begin
	s:= HeaderControl1.Sections [HeaderControl1.Sections.Count-1];
	s.Width:= HeaderControl1.ClientWidth-s.Left;
end;

procedure TShooterResultsForm.lbResultsDrawItem(Control: TWinControl;
	Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
	res: TResultItem;
	y1,y2: integer;

	procedure DrawText (dx,dy: integer);
	var
		sr: TRect;
		Section: THeaderSection;
		w,fdy: integer;
	begin
		with lbResults.Canvas do
			begin
				// ����
				Font.Style:= [fsBold];
				Section:= HeaderControl1.Sections [0];
				sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
				TextRect (sr,sr.Left+dx,sr.Top+y1+dy,DateToStr (res.Date));

				// ������������, ����������
				Section:= HeaderControl1.Sections [1];
				sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
				TextRect (sr,sr.Left+dx,sr.Top+y1+dy,res.ChampionshipName);
				if res.Event<> nil then
					begin
						w:= TextWidth (res.Event.ShortName);
						TextRect (sr,sr.Left+dx,sr.Top+y2+dy,res.Event.ShortName);
						Font.Style:= [];
						fdy:= abs (Font.Height);
						fdy:= fdy-abs (Font.Height);
						TextRect (sr,sr.Left+dx+w,sr.Top+y2+dy+fdy,' ('+res.EventName+')');
					end
				else
					begin
						Font.Style:= [];
						TextRect (sr,sr.Left+dx,sr.Top+y2+dy,res.EventName);
					end;

				// �����
				Font.Style:= [fsBold];
				Section:= HeaderControl1.Sections [2];
				sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
				TextRect (sr,sr.Left+dx,sr.Top+y1+dy+1,res.RankStr);

				// ���������, �����
				Section:= HeaderControl1.Sections [3];
				sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
				TextRect (sr,sr.Left+dx,sr.Top+y1+dy,res.CompetitionStr);
				Font.Style:= [];
				if res.FinalStr<> '' then
					TextRect (sr,sr.Left+dx,sr.Top+y2+dy,res.FinalStr);

				// �����
				Font.Style:= [fsBold];
				Section:= HeaderControl1.Sections [4];
				sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
				TextRect (sr,sr.Left+dx,sr.Top+y1+dy,res.TotalStr);

				// �������
				Font.Style:= [fsBold];
				Section:= HeaderControl1.Sections [5];
				sr:= Rect (ARect.Left+Section.Left+2,ARect.Top,ARect.Left+Section.Right-2,ARect.Bottom);
				TextRect (sr,sr.Left+dx,sr.Top+y1+dy,res.RatingStr);
			end;
	end;

begin
	res:= fFilter [index];
	with lbResults.Canvas do
		begin
			if res<> nil then
				begin
					y1:= 4;
					y2:= 4+TextHeight ('Mg');
					FillRect (ARect);
					Brush.Style:= bsClear;
					if fFilter.Items [index].Marked then
						begin
							if odSelected in State then
  							Font.Color:= clYellow
							else
								Font.Color:= clRed;
						end;
					DrawText (0,0);
				end
			else
				FillRect (ARect);
		end;
end;

procedure TShooterResultsForm.set_Shooter(const Value: TShooterItem);
begin
	fShooter:= Value;
	Caption:= format (Language ['ShooterResultsForm'],[fShooter.SurnameAndName]);
	LoadFilter;
	LoadEvents;
end;

procedure TShooterResultsForm.SetFilter;
var
	i: integer;
begin
	if not pnlFilter.Visible then
		begin
			if (lbResults.ItemIndex-lbResults.TopIndex+1) * lbResults.ItemHeight >= lbResults.ClientHeight then
				begin
					i:= lbResults.ItemIndex - (lbResults.ClientHeight div lbResults.ItemHeight) + 1;
					if i < 0 then
						i:= 0;
					if i >= lbResults.Count then
						i:= lbResults.Count-1;
					lbResults.TopIndex:= i;
				end;
			pnlFilter.Visible:= true;
			ApplyFilter;
			clbFilter.SetFocus;
		end
	else
		begin
			pnlFilter.Visible:= false;
			ApplyFilter;
			lbResults.SetFocus;
		end;
end;

procedure TShooterResultsForm.LoadEvents;
var
	i,c: integer;
	ev: TEventItem;
begin
	clbFilter.Clear;
	for i:= 0 to fShooter.Data.Events.Count-1 do
		begin
			ev:= fShooter.Data.Events.Items [i];
      c:= fShooter.Results.ResultsInEvent (ev);
      if c> 0 then
        begin
          if ev.Name<> '' then
            clbFilter.Items.Add (ev.ShortName+'  ('+ev.Name+')')
          else
            clbFilter.Items.Add (ev.ShortName);
          clbFilter.Items.Objects [clbFilter.Count-1]:= ev;
          clbFilter.Checked [clbFilter.Count-1]:= true;
        end;
		end;
  if fShooter.Results.ResultsInEvent (nil)> 0 then
    begin
      clbFilter.Items.Add (Language ['OtherEvents']);
      clbFilter.Items.Objects [clbFilter.Count-1]:= nil;
      clbFilter.Checked [clbFilter.Count-1]:= true;
    end;
	i:= clbFilter.Count * clbFilter.ItemHeight;
	if i > ClientHeight div 2 then
		i:= ClientHeight div 2;
	clbFilter.ClientHeight:= i;
  if clbFilter.Height> btnCloseFilter.Height then
  	pnlFilter.ClientHeight:= clbFilter.Height+16
  else
    pnlFilter.ClientHeight:= btnCloseFilter.Height+16;
end;

procedure TShooterResultsForm.ApplyFilter;
begin
	LoadFilter;
end;

procedure TShooterResultsForm.LoadResultsListBox;
var
	i: integer;
begin
	lbResults.Clear;
	for i:= 0 to fFilter.Count-1 do
    lbResults.Items.Add ('');
  if lbResults.Count> 0 then
    lbResults.ItemIndex:= 0;
end;

function TShooterResultsForm.EditResult(Res: TResultItem; New: boolean): boolean;
var
  erd: TEditResultDialog;
begin
  erd:= TEditResultDialog.Create (self);
	if New then
		erd.Caption:= Language ['NewResultCaption']
	else
		erd.Caption:= Language ['EditResultCaption'];
	erd.SetResult (Res);
	Result:= erd.Execute;
  erd.Free;
end;

procedure TShooterResultsForm.AddResult;
var
	res: TResultItem;
	fr: TResultsFilterItem;
begin
	res:= fShooter.Results.Add;
	if EditResult (res,true) then
		begin
			fr:= fFilter.Add (res);
			fFilter.Sort;
			LoadResultsListBox;
			lbResults.ItemIndex:= fr.Index;
      CheckFilter (fr.fResult.Event);
		end
	else
		res.Free;
end;

procedure TShooterResultsForm.ToggleMark(Index: integer);
var
	fr: TResultsFilterItem;
begin
	fr:= fFilter.Items [Index];
	if fr<> nil then
		begin
			fr.Marked:= not fr.Marked;
			if Index< lbResults.Count-1 then
				lbResults.ItemIndex:= Index+1
			else
				begin
					lbResults.ItemIndex:= -1;
					lbResults.ItemIndex:= lbResults.Count-1;
				end;
		end;
end;

procedure TShooterResultsForm.UpdateFonts;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbResults.Canvas.Font:= lbResults.Font;
	lbResults.ItemHeight:= lbResults.Canvas.TextHeight ('Mg')*2 + 8;
  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
  btnCloseFilter.ClientWidth:= Canvas.TextWidth (btnCloseFilter.Caption)+32;
  btnCloseFilter.ClientHeight:= Canvas.TextHeight ('Mg')+12;
end;

procedure TShooterResultsForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TShooterResultsForm.MarkAll(Marked: boolean);
var
	i: integer;
begin
	for i:= 0 to fFilter.Count-1 do
		fFilter.Items [i].Marked:= Marked;
	lbResults.Refresh;
end;

{ TResultsFilter }

function TResultsFilter.Add(AResult: TResultItem): TResultsFilterItem;
begin
	Result:= Add;
	Result.Result:= AResult;
end;

procedure TResultsFilter.Add(AResults: TResults);
var
	i: integer;
begin
	for i:= 0 to AResults.Count-1 do
		Add (AResults [i]);
end;

function TResultsFilter.Add: TResultsFilterItem;
begin
	Result:= inherited Add as TResultsFilterItem;
end;

constructor TResultsFilter.Create(AShooter: TShooterItem);
begin
	inherited Create (TResultsFilterItem);
	fSortBy:= rsoNone;
end;

procedure TShooterResultsForm.LoadFilter;
var
	i,j: integer;
	res: TResultItem;
begin
	lbResults.Clear;
	fFilter.Clear;
	for i:= 0 to fShooter.Results.Count-1 do
		begin
			res:= fShooter.Results [i];
			if pnlFilter.Visible then
				begin
          for j:= 0 to clbFilter.Count-1 do
            begin
              if (clbFilter.Checked [j]) and
                 (clbFilter.Items.Objects [j]= res.Event) then
                begin
                  fFilter.Add (res);
                  break;
                end;
            end;
				end
			else
				fFilter.Add (res);
		end;
	fFilter.SortOrder:= rsoDate;
	fFilter.Sort;
	LoadResultsListBox;
end;

function TResultsFilter.get_Result(index: integer): TResultItem;
var
	rf: TResultsFilterItem;
begin
	rf:= Items [index];
	if rf<> nil then
		Result:= rf.Result
	else
		Result:= nil;
end;

function TResultsFilter.get_ResultIdx(index: integer): TResultsFilterItem;
begin
	if (index>= 0) and (index< Count) then
		Result:= inherited Items [index] as TResultsFilterItem
	else
		Result:= nil;
end;

function TResultsFilter.MarkedCount: integer;
var
	i: integer;
begin
	Result:= 0;
	for i:= 0 to Count-1 do
		if Items [i].Marked then
			inc (Result);
end;

procedure TResultsFilter.Sort;
var
	i,j: integer;
	r1,r2: TResultsFilterItem;
begin
	if fSortBy= rsoNone then
		exit;
	for i:= 0 to Count-2 do
		begin
			r1:= Items [i];
			for j:= i+1 to Count-1 do
				begin
					r2:= Items [j];
					if r2.Result.CompareTo (r1.Result,fSortBy)> 0 then
						r1:= r2;
				end;
			if r1.Index<> i then
				r1.Index:= i;
		end;
end;

procedure TShooterResultsForm.lbResultsDblClick(Sender: TObject);
begin
	ChangeResult (lbResults.ItemIndex);
end;

procedure TShooterResultsForm.clbFilterClickCheck(Sender: TObject);
begin
	ApplyFilter;
end;

procedure TShooterResultsForm.btnCloseFilterClick(Sender: TObject);
begin
	SetFilter;
  lbResults.SetFocus;
end;

procedure TShooterResultsForm.mnuDelete1Click(Sender: TObject);
begin
	DeleteResults (lbResults.ItemIndex);
end;

procedure TShooterResultsForm.mnuAdd1Click(Sender: TObject);
begin
	AddResult;
end;

procedure TShooterResultsForm.mnuFilter1Click(Sender: TObject);
begin
	SetFilter;
end;

procedure TShooterResultsForm.mnuMarkClick(Sender: TObject);
begin
	ToggleMark (lbResults.ItemIndex);
end;

procedure TShooterResultsForm.mnuMarkAllClick(Sender: TObject);
begin
	MarkAll (fFilter.MarkedCount= 0);
end;

function TShooterResultsForm.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TShooterResultsForm.clbFilterKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      btnCloseFilter.Click;
    end;
    VK_F7: ViewStats;
  end;
end;

procedure TShooterResultsForm.lbResultsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: Close;
    VK_INSERT,VK_SPACE: begin
      Key:= 0;
      ToggleMark (lbResults.ItemIndex);
    end;
    VK_ADD: begin
      Key:= 0;
      MarkAll (true);
    end;
    VK_SUBTRACT: begin
      Key:= 0;
      MarkAll (false);
    end;
    VK_F7: ViewStats;
    VK_RETURN: lbResultsDblClick (lbResults);
  end;
end;

procedure TShooterResultsForm.mnuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TShooterResultsForm.ViewStats;
var
  SD: TShooterStatsDialog;
begin
  SD:= TShooterStatsDialog.Create (self);
  SD.Shooter:= fShooter;
  SD.Execute;
  SD.Free;
end;

procedure TShooterResultsForm.mnuStatsClick(Sender: TObject);
begin
  ViewStats;
end;

procedure TShooterResultsForm.pnlFilterResize(Sender: TObject);
begin
  btnCloseFilter.Left:= pnlFilter.ClientWidth-8-btnCloseFilter.Width;
  btnCloseFilter.Top:= 8;
  clbFilter.Width:= btnCloseFilter.Left-8-clbFilter.Left;
end;

procedure TShooterResultsForm.mnuPrintClick(Sender: TObject);
begin
  PrintResults (Printer);
end;

procedure TShooterResultsForm.PrintResults(APrinter: TObject);
const
  separator= 4;
var
  lpx,lpy: integer;
  canv: TCanvas;
  leftborder,topborder,rightborder,bottomborder: integer;
  font_height_large,font_height_small: integer;
  thl,ths: integer;
  footerheight: integer;
  cw: array [0..32] of integer;
  p_width,p_height: integer;
  page_idx: integer;
  y: integer;

  function mm2px (mm: single): integer;
  begin
    Result:= round (mm*lpx/25.4);
  end;

  function mm2py (mm: single): integer;
  begin
    Result:= round (mm*lpy/25.4);
  end;

  function MeasureColumns: boolean;
  var
    i: integer;
    res: TResultsFilterItem;
    st: string;
    w: integer;
    sep: integer;
  begin
    for i:= 0 to 32 do
      cw [i]:= 0;
    with canv do
      begin
        Font.Style:= [];
        Font.Height:= font_height_large;
        for i:= 0 to fFilter.Count-1 do
          begin
            res:= fFilter.Items [i];
            if (res.Marked) or (fFilter.MarkedCount= 0) then
              begin
                // ����
                Font.Style:= [];
                st:= FormatDateTime ('dd-mm-yyyy',res.Result.Date);
                w:= TextWidth (st);
                if w> cw [0] then
                  cw [0]:= w;

                // ������������, ����������
                Font.Style:= [fsBold];
                st:= res.Result.ChampionshipName;
                w:= TextWidth (st);
                if w> cw [1] then
                  cw [1]:= w;
                if res.Result.Event<> nil then
                  begin
                    st:= res.Result.Event.ShortName;
                    w:= TextWidth (st);
                    if res.Result.Event.Name<> '' then
                      begin
                        Font.Style:= [];
                        st:= ' ('+res.Result.Event.Name+')';
                        w:= w+TextWidth (st);
                      end;
                  end
                else
                  begin
                    Font.Style:= [];
                    st:= res.Result.EventName;
                    w:= TextWidth (st);
                  end;
                if w> cw [1] then
                  cw [1]:= w;

                // �����
                Font.Style:= [fsBold];
                st:= res.Result.RankStr;
                w:= TextWidth (st);
                if w> cw [2] then
                  cw [2]:= w;

                // ���������, �����
                if res.Result.InFinal then
                  begin
                    Font.Style:= [];
                    st:= res.Result.CompetitionStr;
                    w:= TextWidth (st);
                    if w> cw [3] then
                      cw [3]:= w;
                    st:= res.Result.FinalStr;
                    w:= TextWidth (st);
                    if w> cw [3] then
                      cw [3]:= w;
                    Font.Style:= [fsBold];
                    st:= res.Result.TotalStr;
                    w:= TextWidth (st);
                    if w> cw [4] then
                      cw [4]:= w;
                  end
                else
                  begin
                    Font.Style:= [fsBold];
                    st:= res.Result.CompetitionStr;
                    w:= TextWidth (st);
                    if w> cw [3] then
                      cw [3]:= w;
                  end;

                // �������
                Font.Style:= [fsBold];
                st:= res.Result.RatingStr;
                w:= TextWidth (st);
                if w> cw [5] then
                  cw [5]:= w;
              end;
          end;

        sep:= mm2px (separator/2);
        for i:= 0 to 32 do
          begin
            if cw [i]> 0 then
              begin
                cw [i]:= cw [i]+sep;
                sep:= mm2px (separator);
              end;
          end;
        for i:= 32 downto 0 do
          begin
            if cw [i]> 0 then
              begin
                cw [i]:= cw [i]-mm2px (separator)+mm2px (separator/2);
                break;
              end;
          end;

        w:= 0;
        for i:= 0 to 32 do
          inc (w,cw [i]);
        if w<= p_width-leftborder-rightborder then
          begin
            Result:= true;
            cw [1]:= cw [1]+p_width-leftborder-rightborder-w;
          end
        else
          Result:= false;
      end;
  end;

  procedure MakeNewPage;
  var
    st: string;
  begin
    if page_idx> 1 then
      begin
        if APrinter is TPrinter then
          (APrinter as TPrinter).NewPage
        else if APrinter is TPDFDocument then
          begin
            with (APrinter as TPDFDocument) do
              begin
                NewPage;
                canv:= Canvas;
                CurrentPage.Size:= psA4;
                CurrentPage.Orientation:= poPagePortrait;
                p_width:= PageWidth;
                p_height:= PageHeight;
                Canvas.Font.Name:= 'Arial';
                Canvas.Font.Charset:= PROTOCOL_CHARSET;
              end;
          end;
      end;

    with canv do   // footer
      begin
        Font.Height:= font_height_large;
        Pen.Width:= 1;
        y:= p_height-bottomborder-footerheight+mm2py (2);
        MoveTo (leftborder,y);
        LineTo (p_width-rightborder,y);
        y:= y+mm2py (2);
        Font.Height:= font_height_small;
        Font.Style:= [];
        st:= format (PAGE_NO,[page_idx]);
        TextOut (p_width-rightborder-TextWidth (st),y,st);
        st:= format (PAGE_FOOTER,[VERSION_INFO_STR]);
        TextOut (leftborder,y,st);
      end;

    y:= topborder;
    with canv do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        st:= fShooter.SurnameAndName;
        TextOut (leftborder,y,st);
        st:= _DayToStr (fShooter.Data.RatingDate)+' '+
          _MonthToStr (fShooter.Data.RatingDate)+' '+
          _YearToStr (fShooter.Data.RatingDate);
        Font.Style:= [];
        TextOut (p_width-rightborder-TextWidth (st),y,st);
        y:= y+thl+mm2py (2);
        Pen.Width:= 1;
        MoveTo (leftborder,y);
        LineTo (p_width-rightborder,y);
        y:= y+mm2py (2);
      end;
  end;

var
  rslt: TResultsFilterItem;

  procedure PrintResult;
  var
    x,w: integer;
    st: string;
  begin
    with canv do
      begin
        Font.Height:= font_height_large;

        x:= leftborder;
        Font.Style:= [];
        st:= FormatDateTime ('dd-mm-yyyy',rslt.Result.Date);
        TextOut (x,y,st);
        x:= x+cw [0];

        Font.Style:= [fsBold];
        st:= rslt.Result.ChampionshipName;
        TextOut (x+mm2px (separator/2),y,st);

        if rslt.Result.Event<> nil then
          begin
            st:= rslt.Result.Event.ShortName;
            w:= TextWidth (st);
            TextOut (x+mm2px (separator/2),y+thl,st);
            if rslt.Result.Event.Name<> '' then
              begin
                Font.Style:= [];
                st:= ' ('+rslt.Result.Event.Name+')';
                TextOut (x+mm2px (separator/2)+w,y+thl,st);
              end;
          end
        else
          begin
            Font.Style:= [];
            st:= rslt.Result.EventName;
            TextOut (x+mm2px (separator/2),y+thl,st);
          end;
        x:= x+cw [1];

        Font.Style:= [fsBold];
        st:= rslt.Result.RankStr;
        TextOut (x+mm2px (separator/2),y,st);
        x:= x+cw [2];

        if rslt.Result.InFinal then
          begin
            Font.Style:= [];
            st:= rslt.Result.CompetitionStr;
            TextOut (x+mm2px (separator/2),y,st);
            st:= rslt.Result.FinalStr;
            TextOut (x+mm2px (separator/2),y+thl,st);
            x:= x+cw [3];
            Font.Style:= [fsBold];
            st:= rslt.Result.TotalStr;
            TextOut (x+mm2px (separator/2),y,st);
            x:= x+cw [4];
          end
        else
          begin
            Font.Style:= [fsBold];
            st:= rslt.Result.CompetitionStr;
            TextOut (x+mm2px (separator/2),y,st);
            x:= x+cw [3]+cw [4];
          end;

        Font.Style:= [fsBold];
        st:= rslt.Result.RatingStr;
        TextOut (x+mm2px (separator/2),y,st);
      end;
  end;

var
  i: integer;
begin
  if APrinter= nil then
    APrinter:= Printer;

  if APrinter is TPrinter then
    begin
      with (APrinter as TPrinter) do
        begin
          Orientation:= poPortrait;
          Title:= format (Language ['ShooterResultsPrintTitle'],[fShooter.SurnameAndName]);
          Copies:= 1;
          BeginDoc;
          lpx:= GetDeviceCaps (Canvas.Handle,LOGPIXELSX);
          lpy:= GetDeviceCaps (Canvas.Handle,LOGPIXELSY);
          canv:= Canvas;
          p_width:= PageWidth;
          p_height:= PageHeight;
        end;
    end
  else if APrinter is TPDFDocument then
    begin
      with (APrinter as TPDFDocument) do
        begin
          PageLayout:= plSinglePage;
          PageMode:= pmUseNone;
          DocumentInfo.Title:= format (Language ['ShooterResultsPDFTitle'],[fShooter.SurnameAndName]);
          BeginDoc;
          CurrentPage.Size:= psA4;
          CurrentPage.Orientation:= poPagePortrait;
          lpx:= Resolution;
          lpy:= Resolution;
          canv:= Canvas;
          p_width:= PageWidth;
          p_height:= PageHeight;
        end;
    end
  else
    exit;

  leftborder:= mm2px (15);
  topborder:= mm2py (10);
  bottomborder:= mm2py (10);
  rightborder:= mm2px (10);

  with canv.Font do
    begin
      Charset:= PROTOCOL_CHARSET;
      Name:= 'Arial';
      Size:= 12;
      font_height_large:= Height;
      font_height_small:= round (font_height_large * 3/4);
    end;
  repeat
    with canv do
      begin
        Font.Height:= font_height_large;
        thl:= TextHeight ('Mg');
        Font.Height:= font_height_small;
        ths:= TextHeight ('Mg');
      end;
    footerheight:= ths+mm2py (4);
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
            if APrinter is TPrinter then
              (APrinter as TPrinter).Abort
            else if APrinter is TPDFDocument then
              (APrinter as TPDFDocument).Abort;
            exit;
          end;
      end;
  until false;

  with canv do
    begin
      page_idx:= 1;
      MakeNewPage;
      for i:= 0 to fFilter.Count-1 do
        begin
          rslt:= fFilter.Items [i];
          if (rslt.Marked) or (fFilter.MarkedCount= 0) then
            begin
              if y+thl*2+mm2py (2)>= p_height-bottomborder-footerheight then
                begin
                  inc (page_idx);
                  MakeNewPage;
                end;
              PrintResult;
              y:= y+thl*2+mm2py (2);
            end;
        end;
    end;

  if APrinter is TPrinter then
    (APrinter as TPrinter).EndDoc
  else if APrinter is TPDFDocument then
    (APrinter as TPDFDocument).EndDoc;
end;

procedure TShooterResultsForm.mnuSaveToPDFClick(Sender: TObject);
var
  doc: TPDFDocument;
begin
  if SaveToPDFDialog.Execute then
    begin
      doc:= TPDFDocument.Create (self);
      try
        doc.FileName:= SaveToPDFDialog.FileName;
        PrintResults (doc);
      finally
        doc.Free;
      end;
    end;
end;

procedure TShooterResultsForm.CheckFilter (AEvent: TEventItem);
begin
  LoadEvents;
  ApplyFilter;
end;

end.

