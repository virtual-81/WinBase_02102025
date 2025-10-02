{$a-}
unit form_table;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs, Grids, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, ValEdit, Buttons,

  Data,
  SysFont,

  MyLanguage,
  ctrl_language;

type
	TRateTableForm = class(TForm)
		sgTable: TStringGrid;
		PageControl1: TPageControl;
		tsTable: TTabSheet;
		tsBonus: TTabSheet;
		tsTiming: TTabSheet;
    lbEvents: TListBox;
    lMinResult: TLabel;
    sgTimings: TStringGrid;
    btnBack: TButton;
    lbChamps: TListBox;
    Splitter2: TSplitter;
    edtMinResult: TEdit;
    vleBonus: TValueListEditor;
    vleBonus10: TValueListEditor;
    lBonus: TLabel;
    lBonus10: TLabel;
    procedure vleBonus10SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure vleBonus10KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
		procedure FormClose(Sender: TObject; var Action: TCloseAction);
		procedure FormKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure sgTableKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
    procedure sgTableSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure tsBonusResize(Sender: TObject);
    procedure lbEventsClick(Sender: TObject);
    procedure sgTimingsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure sgTimingsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbEventsKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure vleBonusKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure meMinResultKeyDown(Sender: TObject; var Key: Word;
			Shift: TShiftState);
		procedure vleBonusSelectCell(Sender: TObject; ACol, ARow: Integer;
			var CanSelect: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure meMinResultChange(Sender: TObject);
    procedure lbChampsClick(Sender: TObject);
	private
		{ Private declarations }
		fData: TData;
		fChanged: boolean;
		fSelectedEvent: integer;
		function CheckTableWidth: boolean;
		procedure SetCell;
		procedure SelectEvent (index: integer);
		procedure SetCell1;
		procedure EscapeCell1;
    procedure SelectChampionship (index: integer);
    procedure set_Data (AData: TData);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    property Data: TData write set_Data;
    function Execute: boolean;
	end;

implementation

uses System.Math;

{$R *.dfm}

{ TRateTableForm }

procedure TRateTableForm.set_Data(AData: TData);
var
	i,w,maxwidth: integer;
	ch: TChampionshipItem;
begin
	fData:= AData;
  Caption:= format (Language.ByTag ['RateTableForm'],[fData.Name]);

	// �������� ��� �������
  lbChamps.Clear;
  for i:= 0 to fData.Championships.Count-1 do
    lbChamps.Items.Add (fData.Championships.Items [i].Name);
  if fData.Championships.Count> 0 then
    begin
      lbChamps.ItemIndex:= 0;
      sgTable.Enabled:= true;
    end
  else
    begin
      lbChamps.ItemIndex:= -1;
      sgTable.Enabled:= false;
    end;

 	sgTable.RowCount:= 1;
	sgTable.ColCount:= 2;

	sgTable.Canvas.Font:= sgTable.Font;
  if lbChamps.ItemIndex>= 0 then
    SelectChampionship (lbChamps.ItemIndex);

  sgTable.FixedRows:= 1;

 	sgTable.Constraints.MinWidth:= sgTable.ColWidths [0] + sgTable.ColWidths [1] * 3;
 	sgTable.Constraints.MinHeight:= sgTable.RowHeights [0] * 4;

	for i:= 1 to sgTable.ColCount-1 do
		sgTable.Cells [i,0]:= IntToStr (i);

	// �������� ��� ����������

	fSelectedEvent:= -1;
	lbEvents.Clear;
	for i:= 0 to fData.Events.Count-1 do
    lbEvents.Items.Add (fData.Events.Items [i].ShortName);
	SelectEvent (0);

	// �������� ��� ������
  sgTimings.ColCount:= 3;
	sgTimings.RowCount:= fData.Championships.Count+1;
  sgTimings.Cells [0,0]:= Language ['RateTableForm.Champs'];
	sgTimings.Cells [1,0]:= Language ['RateTableForm.Period'];
	sgTimings.Cells [2,0]:= Language ['RateTableForm.Hold'];

	sgTimings.Canvas.Font:= sgTimings.Font;
	for i:= 1 to 2 do
		sgTimings.ColWidths [i]:= sgTimings.Canvas.TextWidth (sgTimings.Cells [i,0])+32;
  maxwidth:= 0;
  for i:= 0 to fData.Championships.Count-1 do
    begin
      w:= sgTimings.Canvas.TextWidth (fData.Championships.Items [i].Name);
      if w> maxwidth then
        maxwidth:= w;
    end;
  inc (maxwidth,16);
  if maxwidth> sgTimings.ClientWidth-sgTimings.ColWidths [1]-sgTimings.ColWidths [2] then
    maxwidth:= sgTimings.ClientWidth-sgTimings.ColWidths [1]-sgTimings.ColWidths [2];
  sgTimings.ColWidths [0]:= maxwidth;

	for i:= 0 to fData.Championships.Count-1 do
		begin
			ch:= fData.Championships.Items [i];
			sgTimings.Cells [0,i+1]:= ch.Name;
			sgTimings.Cells [1,i+1]:= IntToStr (ch.Period);
			sgTimings.Cells [2,i+1]:= IntToStr (ch.RatingHold);
		end;

	fChanged:= false;
end;

procedure TRateTableForm.FormClose(Sender: TObject;
	var Action: TCloseAction);
begin
	SelectEvent (fSelectedEvent);
  fData.ResetRatings;
	ModalResult:= mrOk;
end;

procedure TRateTableForm.FormKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_F7: PageControl1.ActivePage:= tsTable;
		VK_F3: PageControl1.ActivePage:= tsBonus;
		VK_F4: PageControl1.ActivePage:= tsTiming;
	end;
end;

 procedure TRateTableForm.SetCell;
var
	i,j: integer;
	ch: TChampionshipItem;
begin
  ch:= fData.Championships.Items [lbChamps.ItemIndex];
	Val (sgTable.Cells [sgTable.Col,sgTable.Row],i,j);
  ch.RatingsTable [sgTable.Row-1,sgTable.Col]:= i;
  if sgTable.Col> ch.RatesCount (sgTable.Row-1) then
    sgTable.Cells [sgTable.Col,sgTable.Row]:= ''
  else
    sgTable.Cells [sgTable.Col,sgTable.Row]:= IntToStr (i);
  fChanged:= true;
end;

procedure TRateTableForm.sgTableKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
var
	ch: TChampionshipItem;

	procedure MoveRight;
	begin
		if sgTable.Col< sgTable.ColCount-1 then
			sgTable.Col:= sgTable.Col+1;
	end;

begin
  ch:= fData.Championships.Items [lbChamps.ItemIndex];
	case Key of
		VK_ESCAPE: begin
			Key:= 0;
			if sgTable.EditorMode then
				begin
					sgTable.EditorMode:= false;
          if sgTable.Col> ch.RatesCount (sgTable.Row-1) then
            sgTable.Cells [sgTable.Col,sgTable.Row]:= ''
          else
            sgTable.Cells [sgTable.Col,sgTable.Row]:= IntToStr (ch.RatingsTable [sgTable.Row-1,sgTable.Col]);
				end
			else
				Close;
		end;
		VK_DELETE: begin
			if not sgTable.EditorMode then
				begin
          ch.RatingsTable [sgTable.Row-1,sgTable.Col]:= 0;
					sgTable.Cells [sgTable.Col,sgTable.Row]:= '';
					CheckTableWidth;
				end;
		end;
		VK_RETURN: begin
			if sgTable.EditorMode then
				begin
					SetCell;
					if CheckTableWidth then
						MoveRight;
				end;
		end;
		VK_TAB: begin
			if sgTable.EditorMode then
  			SetCell;
		end;
    VK_UP,VK_DOWN: begin
			if sgTable.EditorMode then
				begin
					SetCell;
					CheckTableWidth;
				end;
		end;
	end;
end;

function TRateTableForm.CheckTableWidth: boolean;
var
	i,j: integer;
	ch: TChampionshipItem;
	maxwidth,c: integer;
begin
	Result:= true;
	maxwidth:= 0;
  ch:= fData.Championships.Items [lbChamps.ItemIndex];
  for i:= 0 to fData.Events.Count-1 do
    if ch.RatesCount (i)> maxwidth then
      maxwidth:= ch.RatesCount (i);

  if sgTable.ColCount> maxwidth+2 then
    begin
      if sgTable.Col> maxwidth+1 then
        sgTable.Col:= maxwidth+1;
      sgTable.ColCount:= maxwidth+2;
      for i:= 1 to sgTable.RowCount-1 do
        sgTable.Cells [sgTable.ColCount-1,i]:= '';
      Result:= false;
    end
  else if sgTable.ColCount< maxwidth+2 then
    begin
      c:= sgTable.ColCount;
      sgTable.ColCount:= maxwidth+2;
      for i:= c to sgTable.ColCount-1 do
        begin
          sgTable.Cells [i,0]:= IntToStr (i);
          for j:= 1 to sgTable.RowCount-1 do
            sgTable.Cells [i,j]:= '';
        end;
    end;
end;

procedure TRateTableForm.sgTableSelectCell(Sender: TObject; ACol,
	ARow: Integer; var CanSelect: Boolean);
begin
	if sgTable.EditorMode then
		begin
			SetCell;
			CheckTableWidth;
		end;
	CanSelect:= true;
end;

procedure TRateTableForm.tsBonusResize(Sender: TObject);
begin
  lbEvents.Height:= tsBonus.ClientHeight;
	lbEvents.Width:= tsBonus.ClientWidth div 3;
  vleBonus.Left:= lbEvents.Left+lbEvents.Width+8;
  lBonus.Left:= vleBonus.Left;
  vleBonus.Width:= (tsBonus.ClientWidth-vleBonus.Left) div 2;
	vleBonus.ColWidths [0]:= vleBonus.Width div 2;
  vleBonus10.Left:= vleBonus.Left+vleBonus.Width+8;
  lBonus10.Left:= vleBonus10.Left;
  vleBonus10.Width:= tsBonus.ClientWidth-vleBonus10.Left;
  vleBonus10.ColWidths [0]:= vleBonus10.Width div 2;
  lMinResult.Left:= vleBonus.Left;
  lMinResult.Top:= tsBonus.ClientHeight-lMinResult.Height;
  edtMinResult.Top:= lMinResult.Top;
  edtMinResult.Left:= tsBonus.ClientWidth-edtMinResult.Width;
  lMinResult.Width:= edtMinResult.Left-8-lMinResult.Left;
  btnBack.Left:= vleBonus.Left;
  btnBack.Width:= vleBonus10.Left+vleBonus10.Width-vleBonus.Left;
  btnBack.Top:= edtMinResult.Top-16-btnBack.Height;
  vleBonus.Height:= btnBack.Top-8-vleBonus.Top;
  vleBonus10.Height:= vleBonus.Height;
end;

procedure TRateTableForm.UpdateFonts;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  sgTable.Canvas.Font:= sgTable.Font;
  sgTable.DefaultRowHeight:= sgTable.Canvas.TextHeight ('Mg')+sgTable.GridLineWidth+4;
  lBonus.Canvas.Font:= lBonus.Font;
  lBonus10.Canvas.Font:= lBonus10.Font;
  lBonus.ClientHeight:= lBonus.Canvas.TextHeight (lBonus.Caption);
  lBonus10.ClientHeight:= lBonus.Canvas.TextHeight (lBonus10.Caption);
  vleBonus.Top:= lBonus.Top+lBonus.Height+4;
  vleBonus.Canvas.Font:= vleBonus.Font;
  vleBonus.DefaultRowHeight:= vleBonus.Canvas.TextHeight ('Mg')+vleBonus.GridLineWidth+4;
  vleBonus10.Top:= lBonus10.Top+lBonus10.Height+4;
  vleBonus10.Canvas.Font:= vleBonus10.Font;
  vleBonus10.DefaultRowHeight:= vleBonus10.Canvas.TextHeight ('Mg')+vleBonus10.GridLineWidth+4;
  btnBack.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  sgTimings.Canvas.Font:= sgTimings.Font;
  sgTimings.DefaultRowHeight:= sgTimings.Canvas.TextHeight ('Mg')+sgTimings.GridLineWidth+4;
end;

procedure TRateTableForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
  vleBonus.TitleCaptions [0]:= Language ['RateTableForm.Result'];
  vleBonus.TitleCaptions [1]:= Language ['RateTableForm.Points'];
  vleBonus10.TitleCaptions [0]:= Language ['RateTableForm.Result'];
  vleBonus10.TitleCaptions [1]:= Language ['RateTableForm.Points'];
end;

procedure TRateTableForm.lbEventsClick(Sender: TObject);
begin
	SelectEvent (lbEvents.ItemIndex);
end;

procedure TRateTableForm.SelectEvent(index: integer);
var
	ev: TEventItem;
	i,j: integer;
	eb: TEventBonus;
  eb10: TEventBonus10;
begin
	if fSelectedEvent>= 0 then
		begin
			ev:= fData.Events.Items [fSelectedEvent];
			ev.ClearBonuses;
			for i:= 0 to vleBonus.Strings.Count-1 do
				begin
					Val (vleBonus.Keys [i+1],eb.fResult,j);
					Val (vleBonus.Values [vleBonus.Keys [i+1]],eb.fRating,j);
					if (eb.fResult> 0) and (eb.fRating> 0) then
						ev.AddBonus (eb);
				end;
      for i:= 0 to vleBonus10.Strings.Count-1 do
        begin
          eb10.fResult:= StrToFinal10 (vleBonus10.Keys[i+1]);
					Val (vleBonus10.Values [vleBonus10.Keys [i+1]],eb10.fRating,j);
					if (eb10.fResult> 0) and (eb10.fRating> 0) then
						ev.AddBonus10 (eb10);
        end;
			ev.MinRatedResult10:= StrToFinal10 (edtMinResult.Text);
		end;

	if index>= 0 then
		begin
			ev:= fData.Events.Items [index];
			vleBonus.Strings.Clear;
			for i:= 0 to ev.BonusCount-1 do
				vleBonus.InsertRow (IntToStr (ev.Bonuses [i].fResult),IntToStr (ev.Bonuses [i].fRating),true);
      vleBonus10.Strings.Clear;
			for i:= 0 to ev.BonusCount10-1 do
				vleBonus10.InsertRow (ResultToStr (ev.Bonuses10 [i].fResult,true),IntToStr (ev.Bonuses10 [i].fRating),true);
			edtMinResult.Text:= IntToStr (ev.MinRatedResult10 div 10);
			fSelectedEvent:= index;
			lbEvents.ItemIndex:= index;
			btnBack.Enabled:= false;
		end;
end;

procedure TRateTableForm.sgTimingsSelectCell(Sender: TObject; ACol,
	ARow: Integer; var CanSelect: Boolean);
begin
	if sgTimings.EditorMode then
		SetCell1;
	CanSelect:= true;
end;

procedure TRateTableForm.SetCell1;
var
	ch: TChampionshipItem;
	i: word;
	j: integer;
begin
	ch:= fData.Championships.Items [sgTimings.Row-1];
	val (sgTimings.Cells [sgTimings.Col,sgTimings.Row],i,j);
	case sgTimings.Col of
		1: ch.Period:= i;
		2: ch.RatingHold:= i;
	end;
end;

procedure TRateTableForm.sgTimingsKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_ESCAPE: begin
			if sgTimings.EditorMode then
				EscapeCell1
			else
				Close;
			Key:= 0;
		end;
		VK_RETURN: if sgTimings.EditorMode then
			begin
				SetCell1;
				Key:= 0;
			end;
	end;
end;

procedure TRateTableForm.EscapeCell1;
var
	ch: TChampionshipItem;
begin
	ch:= fData.Championships.Items [sgTimings.Row-1];
	case sgTimings.Col of
		1: sgTimings.Cells [sgTimings.Col,sgTimings.Row]:= IntToStr (ch.Period);
		2: sgTimings.Cells [sgTimings.Col,sgTimings.Row]:= IntToStr (ch.RatingHold);
	end;
end;

procedure TRateTableForm.lbEventsKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_ESCAPE: Close;
	end;
end;

procedure TRateTableForm.vleBonus10KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	case Key of
		VK_ESCAPE: begin
			if vleBonus10.EditorMode then
				begin
					vleBonus10.EditorMode:= false;
				end
			else
				Close;
		end;
		VK_DELETE: begin
			if (vleBonus10.Row> 0) and (vleBonus10.Row<= vleBonus10.Strings.Count) then
				begin
					vleBonus10.DeleteRow (vleBonus10.Row);
					btnBack.Enabled:= true;
				end;
		end;
		VK_RETURN: begin
			if vleBonus10.EditorMode then
				begin
					btnBack.Enabled:= true;
				end;
		end;
	end;
end;

procedure TRateTableForm.vleBonus10SelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
	if vleBonus10.EditorMode then
		btnBack.Enabled:= true;
	CanSelect:= true;
end;

procedure TRateTableForm.vleBonusKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_ESCAPE: begin
			if vleBonus.EditorMode then
				begin
					vleBonus.EditorMode:= false;
				end
			else
				Close;
		end;
		VK_DELETE: begin
			if (vleBonus.Row> 0) and (vleBonus.Row<= vleBonus.Strings.Count) then
				begin
					vleBonus.DeleteRow (vleBonus.Row);
					btnBack.Enabled:= true;
				end;
		end;
		VK_RETURN: begin
			if vleBonus.EditorMode then
				begin
					btnBack.Enabled:= true;
				end;
		end;
	end;
end;

procedure TRateTableForm.meMinResultKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_ESCAPE: Close;
	end;
end;

procedure TRateTableForm.vleBonusSelectCell(Sender: TObject; ACol,
	ARow: Integer; var CanSelect: Boolean);
begin
	if vleBonus.EditorMode then
		btnBack.Enabled:= true;
	CanSelect:= true;
end;

procedure TRateTableForm.FormCreate(Sender: TObject);
begin
	fSelectedEvent:= -1;
  Width:= Round (Screen.Width*0.75);
  Height:= Round (Screen.Height*0.75);
  Position:= poScreenCenter;
  lbEvents.Left:= 0;
  lbEvents.Top:= 0;
  //vleBonus.Top:= 0;
  //vleBonus10.Top:= 0;
  lBonus.Top:= 0;
  lBonus10.Top:= 0;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TRateTableForm.btnBackClick(Sender: TObject);
var
	se: integer;
begin
	se:= fSelectedEvent;
	fSelectedEvent:= -1;
	SelectEvent (se);
end;

procedure TRateTableForm.meMinResultChange(Sender: TObject);
begin
	btnBack.Enabled:= true;
end;

procedure TRateTableForm.lbChampsClick(Sender: TObject);
begin
  SelectChampionship (lbChamps.ItemIndex);
end;

procedure TRateTableForm.SelectChampionship(index: integer);
var
  ch: TChampionshipItem;
  i,j: integer;
  maxwidth,w,cc: integer;
  st: string;
begin
  ch:= fData.Championships.Items [lbChamps.ItemIndex];

  sgTable.Cells [0,0]:= Language ['RateTableForm.Events'];
  sgTable.RowCount:= fData.Events.Count+1;
  sgTable.ColCount:= 2;
  maxwidth:= sgTable.Canvas.TextWidth (sgTable.Cells [0,0]);
  for i:= 0 to fData.Events.Count-1 do
    begin
      st:= fData.Events.Items [i].ShortName;
      sgTable.Cells [0,i+1]:= st;
      w:= sgTable.Canvas.TextWidth (st);
      if w> maxwidth then
        maxwidth:= w;
      cc:= ch.RatesCount (fData.Events.Items [i]);
      if sgTable.ColCount< cc+2 then
        sgTable.ColCount:= cc+2;
      for j:= 0 to cc-1 do
        sgTable.Cells [j+1,i+1]:= IntToStr (ch.Ratings [fData.Events.Items [i],j+1]);
      for j:= cc to sgTable.ColCount-1 do
        sgTable.Cells [j+1,i+1]:= '';
    end;
  for i:= 1 to sgTable.ColCount-1 do
    sgTable.Cells [i,0]:= IntToStr (i);

  if maxwidth > sgTable.ClientWidth div 2 then
    maxwidth:= sgTable.ClientWidth div 2;
  sgTable.ColWidths [0]:= maxwidth+16;
end;

function TRateTableForm.Execute: boolean;
begin
  Result:= false;
  if fData= nil then
    exit;
  if fData.Championships.Count= 0 then
    begin
      MessageDlg (Language ['NoChamps'],mtError,[mbOk],0);
      exit;
    end;
  if fData.Events.Count= 0 then
    begin
      MessageDlg (Language ['NoEvents'],mtError,[mbOk],0);
      exit;
    end;
  Result:= (ShowModal= mrOk);
end;

end.

