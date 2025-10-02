{$a-}
unit form_result;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs, Vcl.StdCtrls, Mask, Vcl.ExtCtrls,

  SysFont,
  Data,
  MyStrings,

  MyLanguage,
  ctrl_language;

type
	TEditResultDialog = class(TForm)
		cbChampionship: TComboBox;
		cbEvent: TComboBox;
		cbJunior: TCheckBox;
    lChamp: TLabel;
    lEvent: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    lDate: TLabel;
    lCountry: TLabel;
    lTown: TLabel;
    lRank: TLabel;
    lComp: TLabel;
    lFinal: TLabel;
    edtDate: TEdit;
    edtCountry: TEdit;
    edtTown: TEdit;
    edtRank: TEdit;
    edtComp: TEdit;
    edtFinal: TEdit;
    procedure edtDateKeyPress(Sender: TObject; var Key: Char);
    procedure cbCompWithTensClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
		procedure cbEventChange(Sender: TObject);
		procedure leRankChange(Sender: TObject);
    procedure leDateKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure cbChampionshipKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbEventKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure leCountryKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure leTownKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure cbJuniorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure leRankKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure leCompKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
		procedure leFinalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnOkClick(Sender: TObject);
	private
		{ Private declarations }
		fResult: TResultItem;
    function get_CompWithTens: boolean;
		function get_Rank: integer;
		procedure CheckFinals;
		function get_Date: TDateTime;
		function get_Championship: TChampionshipItem;
		function get_ChampionshipName: string;
    function get_Competition: DWORD;
    function get_Country: string;
    function get_Event: TEventItem;
		function get_EventName: string;
		function get_Final: DWORD;
		function get_Junior: boolean;
		function get_Town: string;
    procedure UpdateFonts;
    procedure UpdateLanguage;
	public
		{ Public declarations }
		procedure SetResult (AResult: TResultItem);
		property Date: TDateTime read get_Date;
		property Championship: TChampionshipItem read get_Championship;
		property ChampionshipName: string read get_ChampionshipName;
		property Event: TEventItem read get_Event;
		property EventName: string read get_EventName;
		property Country: string read get_Country;
		property Town: string read get_Town;
		property Junior: boolean read get_Junior;
		property Rank: integer read get_Rank;
		property Competition10: DWORD read get_Competition;
		property Final10: DWORD read get_Final;
    property CompWithTens: boolean read get_CompWithTens;
		function Execute: boolean;
    function ShortName: string;
	end;

{var
	EditResultDialog: TEditResultDialog;}

implementation

{$R *.dfm}

function ClearStr (const s: string): string;
var
	i: integer;
begin
	Result:= '';
	for i:= 1 to Length (s) do
		if s [i]<> ' ' then
			Result:= Result+s [i];
end;

{ TResultForm }

procedure TEditResultDialog.SetResult(AResult: TResultItem);
var
	i: integer;
begin
	fResult:= AResult;
	cbChampionship.Clear;
	for i:= 0 to AResult.Data.Championships.Count-1 do
		cbChampionship.Items.Add (AResult.Data.Championships.Items [i].Name);
	cbEvent.Clear;
	for i:= 0 to AResult.Data.Events.Count-1 do
    with AResult.Data.Events.Items [i] do
  		cbEvent.Items.Add (ShortName+' ('+Name+')');
  if AResult.ShootingEvent<> nil then
    edtDate.Text:= FormatDateTime ('dd.mm.yyyy',AResult.Date)
  else
    edtDate.Text:= '';
	if AResult.Championship<> nil then
		cbChampionship.ItemIndex:= AResult.Championship.Index
	else
		cbChampionship.Text:= AResult.ChampionshipName;
	if AResult.Event<> nil then
		cbEvent.ItemIndex:= AResult.Event.Index
	else
		cbEvent.Text:= AResult.EventName;
	edtCountry.Text:= AResult.Country;
	edtTown.Text:= AResult.Town;
	cbJunior.Checked:= AResult.Junior;
  if AResult.Rank> 0 then
    edtRank.Text:= IntToStr (AResult.Rank)
  else
    edtRank.Text:= '';
  edtComp.Text:= AResult.CompetitionStr;
  //cbCompWithTens.Checked:= AResult.CompetitionWithTens;
	if AResult.InFinal then
		begin
			edtFinal.Enabled:= true;
			edtFinal.Text:= AResult.FinalStr;
		end
	else
		begin
			edtFinal.Enabled:= false;
			edtFinal.Text:= '';
		end;
end;

function TEditResultDialog.ShortName: string;
begin
  if cbEvent.ItemIndex>= 0 then
    Result:= ''
  else
    Result:= '';
  // TODO: �������� ��� � �������
end;

procedure TEditResultDialog.UpdateFonts;
var
  w,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;

  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w;
  btnCancel.ClientWidth:= w;
  btnOk.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnCancel.ClientHeight:= btnOk.ClientHeight;

  cbChampionship.Canvas.Font:= cbChampionship.Font;
  cbChampionship.ItemHeight:= cbChampionship.Canvas.TextHeight ('Mg');
  cbEvent.Canvas.Font:= cbEvent.Font;
  cbEvent.ItemHeight:= cbEvent.Canvas.TextHeight ('Mg');
  cbJunior.ClientHeight:= Canvas.TextHeight ('Mg');
  //cbCompWithTens.ClientHeight:= Canvas.TextHeight ('Mg');
  //cbCompWithTens.ClientWidth:= cbCompWithTens.ClientHeight + Canvas.TextWidth (cbCompWithTens.Caption) + 8;

  edtDate.Top:= 0;
  edtDate.ClientWidth:= Canvas.TextWidth (FormatDateTime (' dd/mm/yyyy ',Now));
  lDate.Top:= edtDate.Top+(edtDate.Height-lDate.Height) div 2;
  cbChampionship.Top:= edtDate.Top+edtDate.Height+4;
  lChamp.Top:= cbChampionship.Top+(cbChampionship.Height-lChamp.Height) div 2;
  cbEvent.Top:= cbChampionship.Top+cbChampionship.Height+4;
  lEvent.Top:= cbEvent.Top+(cbEvent.Height-lEvent.Height) div 2;
  edtCountry.Top:= cbEvent.Top+cbEvent.Height+4;
  lCountry.Top:= edtCountry.Top+(edtCountry.Height-lCountry.Height) div 2;
  edtTown.Top:= edtCountry.Top+edtCountry.Height+4;
  lTown.Top:= edtTown.Top+(edtTown.Height-lTown.Height) div 2;
  cbJunior.Top:= edtTown.Top+edtTown.Height+8;
  edtRank.Top:= cbJunior.Top+cbJunior.Height+8;
  lRank.Top:= edtRank.Top+(edtRank.Height-lRank.Height) div 2;
  edtComp.Top:= edtRank.Top+edtRank.Height+4;
  lComp.Top:= edtComp.Top+(edtComp.Height-lComp.Height) div 2;
  edtFinal.Top:= edtComp.Top+edtComp.Height+4;
  lFinal.Top:= edtFinal.Top+(edtFinal.Height-lFinal.Height) div 2;
  btnOk.Top:= edtFinal.Top+edtFinal.Height+16;
  btnCancel.Top:= btnOk.Top;
  ClientHeight:= btnOk.Top+btnOk.Height;

  w:= lDate.Width;
  if lChamp.Width> w then
    w:= lChamp.Width;
  if lEvent.Width> w then
    w:= lEvent.Width;
  if lCountry.Width> w then
    w:= lCountry.Width;
  if lTown.Width> w then
    w:= lTown.Width;
  if lRank.Width> w then
    w:= lRank.Width;
  if lComp.Width> w then
    w:= lComp.Width;
  if lFinal.Width> w then
    w:= lFinal.Width;

  lDate.Left:= w-lDate.Width;
  lChamp.Left:= w-lChamp.Width;
  lEvent.Left:= w-lEvent.Width;
  lCountry.Left:= w-lCountry.Width;
  lTown.Left:= w-lTown.Width;
  lRank.Left:= w-lRank.Width;
  lComp.Left:= w-lComp.Width;
  lFinal.Left:= w-lFinal.Width;

  //cbCompWithTens.Left:= edtComp.Left + edtComp.Width + 16;
  //cbCompWithTens.Top:= edtComp.Top + (edtComp.Height - cbCompWithTens.Height) div 2;

  edtDate.Left:= w+8;
  cbChampionship.Left:= w+8;
  cbEvent.Left:= w+8;
  edtCountry.Left:= w+8;
  edtTown.Left:= w+8;
  cbJunior.Left:= w+8;
  edtRank.Left:= w+8;
  edtComp.Left:= w+8;
  edtFinal.Left:= w+8;

  edtCountry.Width:= cbChampionship.Width;
  edtTown.Width:= cbChampionship.Width;
  cbEvent.Width:= cbChampionship.Width;
  ClientWidth:= w+8+cbChampionship.Width;

  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;
end;

procedure TEditResultDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TEditResultDialog.cbEventChange(Sender: TObject);
begin
	CheckFinals;
end;

function TEditResultDialog.get_Rank: integer;
var
	i: integer;
begin
	Val (Trim (edtRank.Text),Result,i);
end;

procedure TEditResultDialog.leRankChange(Sender: TObject);
begin
	CheckFinals;
end;

procedure TEditResultDialog.CheckFinals;
var
	ev: TEventItem;
begin
	if cbEvent.ItemIndex>= 0 then
		begin
			ev:= fResult.Data.Events.Items [cbEvent.ItemIndex];
			edtFinal.Enabled:= ev.InFinal (Rank);
      //cbCompWithTens.Checked:= false; //ev.CompFracs;
		end
	else
		begin
			edtFinal.Enabled:= false;
      //cbCompWithTens.Checked:= false;
		end;
end;

procedure TEditResultDialog.edtDateKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin 
      Key:= #0;
    end;
  end;
end;

procedure TEditResultDialog.leDateKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_RETURN,VK_DOWN: begin
      edtDate.Text:= FormatDateTime ('dd.mm.yyyy',Date);
			cbChampionship.SetFocus;
			Key:= 0;
		end;
	end;
end;

procedure TEditResultDialog.cbChampionshipKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_RETURN: begin
			cbEvent.SetFocus;
			Key:= 0;
		end;
	end;
end;

procedure TEditResultDialog.cbCompWithTensClick(Sender: TObject);
begin
  //edtComp.Text:= fResult.CompetitionStr;
end;

procedure TEditResultDialog.cbEventKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_RETURN: begin
			edtCountry.SetFocus;
			Key:= 0;
		end;
	end;
end;

procedure TEditResultDialog.leCountryKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_RETURN,VK_DOWN: begin
			edtTown.SetFocus;
			Key:= 0;
		end;
		VK_UP: begin
			cbEvent.SetFocus;
			Key:= 0;
		end;
	end;
end;

procedure TEditResultDialog.leTownKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_RETURN,VK_DOWN: begin
			cbJunior.SetFocus;
			Key:= 0;
		end;
		VK_UP: begin
			edtCountry.SetFocus;
			Key:= 0;
		end;
	end;
end;

procedure TEditResultDialog.cbJuniorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	case Key of
		VK_RETURN,VK_DOWN: begin
			edtRank.SetFocus;
			Key:= 0;
		end;
		VK_UP: begin
			edtTown.SetFocus;
			Key:= 0;
		end;
	end;
end;

procedure TEditResultDialog.leRankKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	case Key of
		VK_RETURN,VK_DOWN: begin
			edtComp.SetFocus;
			Key:= 0;
		end;
		VK_UP: begin
			cbJunior.SetFocus;
			Key:= 0;
		end;
	end;
end;

procedure TEditResultDialog.leCompKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_RETURN: begin
			if edtFinal.Enabled then
				edtFinal.SetFocus
			else
				btnOk.SetFocus;
			Key:= 0;
		end;
		VK_DOWN: begin
			if edtFinal.Enabled then
				edtFinal.SetFocus;
			Key:= 0;
		end;
		VK_UP: begin
			edtRank.SetFocus;
			Key:= 0;
		end;
	end;
end;

procedure TEditResultDialog.leFinalKeyDown(Sender: TObject; var Key: Word;
	Shift: TShiftState);
begin
	case Key of
		VK_RETURN: begin
			btnOk.SetFocus;
			Key:= 0;
		end;
		VK_UP: begin
  		edtComp.SetFocus;
			Key:= 0;
		end;
	end;
end;

function TEditResultDialog.get_Date: TDateTime;
var
  y,m,d,i: integer;
  s: string;
begin
  s:= Trim (edtDate.Text);
  Val (substr (s,'.',1),d,i);
  Val (substr (s,'.',2),m,i);
  Val (substr (s,'.',3),y,i);
  if y< 100 then
    begin
      if y< 80 then
        y:= 2000+y
      else
        y:= 1900+y;
    end;
  if d= 0 then
    d:= 1;
  if m= 0 then
    m:= 1;
  Result:= EncodeDate (y,m,d);
end;

function TEditResultDialog.get_Championship: TChampionshipItem;
begin
	if cbChampionship.ItemIndex>= 0 then
		Result:= fResult.Data.Championships.Items [cbChampionship.ItemIndex]
	else
		Result:= nil;
end;

function TEditResultDialog.get_ChampionshipName: string;
begin
	if cbChampionship.ItemIndex>= 0 then
		Result:= ''
	else
		Result:= cbChampionship.Text;
end;

function TEditResultDialog.get_Competition: DWORD;
begin
  Result:= StrToFinal10 (Trim (edtComp.Text));
end;

function TEditResultDialog.get_CompWithTens: boolean;
begin
  Result:= (pos ('.',edtComp.Text)> 0);
end;

function TEditResultDialog.get_Country: string;
begin
	Result:= edtCountry.Text;
end;

function TEditResultDialog.get_Event: TEventItem;
begin
	if cbEvent.ItemIndex>= 0 then
		Result:= fResult.Data.Events.Items [cbEvent.ItemIndex]
	else
		Result:= nil;
end;

function TEditResultDialog.get_EventName: string;
begin
	if cbEvent.ItemIndex>= 0 then
		Result:= ''
	else
		Result:= cbEvent.Text;
end;

function TEditResultDialog.get_Final: DWORD;
begin
	if edtFinal.Enabled then
    begin
      Result:= StrToFinal10 (edtFinal.Text);
    end
	else
    begin
      Result:= 0;
    end;
end;

function TEditResultDialog.get_Junior: boolean;
begin
	Result:= cbJunior.Checked;
end;

function TEditResultDialog.get_Town: string;
begin
	Result:= edtTown.Text;
end;

function TEditResultDialog.Execute: boolean;
begin
	Result:= (ShowModal= mrOk);
end;

procedure TEditResultDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
end;

procedure TEditResultDialog.btnOkClick(Sender: TObject);
var
  _date: TDateTime;
  _ch: TChampionshipItem;
  _ev: TEventItem;
  sch: TShootingChampionshipItem;
  sev: TShootingEventItem;
begin
  _date:= Date;
  _ch:= Championship;
  _ev:= Event;
  if fResult.ShootingEvent<> nil then
    begin
      sch:= fResult.ShootingEvent.Championship;
      sev:= fResult.ShootingEvent;
    end
  else
    begin
      sch:= fResult.Data.ShootingChampionships.Find (_ch,ChampionshipName,_date);
      if sch= nil then
        begin
          sch:= fResult.Data.ShootingChampionships.Add;
          sch.SetChampionship (_ch,ChampionshipName);
        end;
      sev:= sch.Events.Find (_ev,EventName,_date);
      if sev= nil then
        begin
          sev:= sch.Events.Add;
        end;
    end;
  sev.SetEvent (_ev,ShortName,EventName);
  sev.Date:= _date;
  sch.Country:= Country;
  sch.Town:= Town;
  fResult.ShootingEvent:= sev;
	fResult.Junior:= Junior;
	fResult.Rank:= Rank;
	fResult.Competition10:= Competition10;
  fResult.CompetitionWithTens:= CompWithTens;
  fResult.Final10:= Final10;
end;

end.

