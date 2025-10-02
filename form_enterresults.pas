{$a-,x+,j+}
unit form_enterresults;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, System.DateUtils, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,

  Data,
  SysFont,

  form_inputresult,

  MyLanguage,
  ctrl_language;

const
  NEW_RECORD_STR: string= '����� ������';

type
  TEnteredResults= class (TCollection)
  private
    fShootingChampionship: TShootingChampionshipItem;
    fChampionship: TChampionshipItem;
    fChampionshipName: string;
    fCountry: string;
    fTown: string;
    fYear: integer;
    fData: TData;
    function get_Item(index: integer): TEnteredResultItem;
  public
    constructor Create;
    function Add: TEnteredResultItem;
    property Items [index: integer]: TEnteredResultItem read get_Item; default;
    procedure SaveResults;
    procedure FromTill (var From,Till: TDateTime);
  end;

  TEnterResultsForm = class(TForm)
    ListBox1: TListBox;
    HeaderControl1: THeaderControl;
    Panel1: TPanel;
    pnlInfo: TPanel;
    cbChamp: TComboBox;
    lChamp: TLabel;
    lYear: TLabel;
    edtYear: TEdit;
    edtCountry: TEdit;
    edtTown: TEdit;
    lCountry: TLabel;
    lTown: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1DblClick(Sender: TObject);
    procedure ListBox1KeyPress(Sender: TObject; var Key: Char);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HeaderControl1Resize(Sender: TObject);
    procedure HeaderControl1SectionResize(HeaderControl: THeaderControl;  Section: THeaderSection);
    procedure FormResize(Sender: TObject);
  private
    fResults: TEnteredResults;
    l1y,l2y: integer;
    procedure OpenResult (index: integer);
    procedure NewResult;
    procedure DeleteResult (index: integer);
    function CheckValues: boolean;
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    function Execute: boolean;
    procedure SetData (AData: TData; AChampionship: TShootingChampionshipItem; AYear: integer);
  published
  end;

implementation

{$R *.dfm}

{ TEnterResultsForm }

procedure TEnterResultsForm.UpdateFonts;
var
  w,i,y: integer;
begin
  Font:= SysFonts.MessageFont;
  ListBox1.Canvas.Font:= ListBox1.Font;
  i:= ListBox1.Canvas.TextHeight ('Mg');
  ListBox1.ItemHeight:= i * 2 + 6;
  l1y:= 2;
  l2y:= i+4;
  y:= 8;
  cbChamp.Top:= y;
  edtCountry.Top:= y;
  if edtTown.Height> cbChamp.Height then
    y:= y+edtTown.Height+8
  else
    y:= y+cbChamp.Height+8;
  edtYear.Top:= y;
  edtTown.Top:= y;
  pnlInfo.ClientHeight:= edtTown.Top+edtTown.Height+8;
  lChamp.Top:= cbChamp.Top+(cbChamp.Height-lChamp.Height) div 2;
  lYear.Top:= edtYear.Top+(edtYear.Height-lYear.Height) div 2;
  lCountry.Top:= edtCountry.Top+(edtCountry.Height-lCountry.Height) div 2;
  lTown.Top:= edtTown.Top+(edtTown.Height-lTown.Height) div 2;
  w:= lChamp.Width;
  i:= lYear.Width;
  if i> w then
    w:= i;
  lChamp.Left:= w+8-lChamp.Width;
  lYear.Left:= w+8-lYear.Width;
  cbChamp.Left:= w+16;
  edtYear.Left:= w+16;
  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
end;

procedure TEnterResultsForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
  NEW_RECORD_STR:= Language ['NewResultLine'];
end;

procedure TEnterResultsForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  res: integer;
begin
  if fResults.Count> 0 then
    begin
      res:= MessageDlg (Language ['SaveEnteredResultsPrompt'],mtConfirmation,[mbYes,mbNo,mbCancel],0);
      case res of
        mrYes: begin
          if CheckValues then
            begin
              fResults.SaveResults;
              Action:= caFree;
            end
          else
            Action:= caNone;
        end;
        mrNo: begin
          Action:= caFree;
        end;
      else
        Action:= caNone;
      end;
    end
  else
    Action:= caFree;
end;

procedure TEnterResultsForm.FormCreate(Sender: TObject);
begin
  fResults:= TEnteredResults.Create;
  ListBox1.ItemIndex:= 0;
  Width:= Round (Screen.Width * 0.75);
  Height:= Round (Screen.Height * 0.75);
  Position:= poScreenCenter;
  edtYear.Text:= '';
  cbChamp.Text:= '';
  edtCountry.Text:= '';
  edtTown.Text:= '';
  ListBox1.Count:= fResults.Count+1;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TEnterResultsForm.FormDestroy(Sender: TObject);
begin
  fResults.Free;
end;

procedure TEnterResultsForm.OpenResult(index: integer);
var
  er: TEnteredResultItem;
  ird: TInputResultDialog;
begin
  er:= fResults [index];
  ird:= TInputResultDialog.Create (self);
  ird.SetData (fResults.fData);
  ird.Year:= fResults.fYear;
  ird.Shooter:= er.Shooter;
  ird.EventName:= er.EventName;
  ird.Event:= er.Event;
  ird.Date:= er.Date;
  ird.Juniors:= er.Junior;
  ird.Rank:= er.Rank;
  ird.SetCompetition (er.Competition10,er.CompetitionWithTens);
  ird.Final10:= er.Final10;
  ird.Caption:= format (Language ['ShootersResult'],[er.Shooter.SurnameAndName]);
  ird.ActiveControl:= ird.cbEvent;
  if ird.Execute then
    begin
      er.Shooter:= ird.Shooter;
      er.Event:= ird.Event;
      er.EventName:= ird.EventName;
      er.Date:= ird.Date;
      er.Junior:= ird.Juniors;
      er.Rank:= ird.Rank;
      ird.GetCompetition (er);
      er.Final10:= ird.Final10;
      ListBox1.Invalidate;
    end;
  ird.Free;
end;

procedure TEnterResultsForm.SetData(AData: TData; AChampionship: TShootingChampionshipItem; AYear: integer);
var
  i: integer;
begin
  fResults.fData:= AData;
  cbChamp.Clear;
  for i:= 0 to fResults.fData.Championships.Count-1 do
    cbChamp.Items.Add (fResults.fData.Championships.Items [i].Name);
  edtYear.Text:= IntToStr (AYear);
  fResults.fShootingChampionship:= AChampionship;
  if AChampionship<> nil then
    begin
      if AChampionship.Championship<> nil then
        cbChamp.ItemIndex:= AChampionship.Championship.Index
      else
        cbChamp.Text:= AChampionship.ChampionshipName;
      cbChamp.Enabled:= false;
      edtYear.Enabled:= false;
      edtCountry.Text:= AChampionship.Country;
      edtTown.Text:= AChampionship.Town;
      ActiveControl:= ListBox1;
    end
  else
    begin
      cbChamp.Enabled:= true;
      cbChamp.Text:= '';
      edtYear.Enabled:= false;
      edtCountry.Text:= '';
      edtTown.Text:= '';
      ActiveControl:= cbChamp;
    end;
end;

procedure TEnterResultsForm.NewResult;
var
  er: TEnteredResultItem;
  ird: TInputResultDialog;
  y,i: integer;
begin
  ird:= TInputResultDialog.Create (self);
  if fResults.Count> 0 then
    er:= fResults [fResults.Count-1]
  else
    er:= nil;
  ird.SetData (fResults.fData);
  val (edtYear.Text,y,i);
  if (y< 1980) or (y> YearOf (Now)) then
    begin
      y:= YearOf (Now);
      edtYear.Text:= IntToStr (y);
    end;
  ird.Year:= y;
  ird.Caption:= Language ['NewResult'];
  if er<> nil then
    begin
      ird.Shooter:= er.Shooter;
      ird.Event:= er.Event;
      ird.Date:= er.Date;
    end;
  ird.ActiveControl:= ird.lbGroups;
  if ird.Execute then
    begin
      er:= fResults.Add;
      er.Shooter:= ird.Shooter;
      er.Event:= ird.Event;
      er.EventName:= ird.EventName;
      er.Date:= ird.Date;
      er.Junior:= ird.Juniors;
      er.Rank:= ird.Rank;
      ird.GetCompetition (er);
      er.Final10:= ird.Final10;
      ListBox1.Count:= fResults.Count+1;
      ListBox1.ItemIndex:= ListBox1.Count-1;
    end;
  ird.Free;
end;

procedure TEnterResultsForm.DeleteResult(index: integer);
var
  res: integer;
  er: TEnteredResultItem;
begin
  er:= fResults [index];
  res:= MessageDlg (format (Language ['DeleteShootersResultPrompt'],[er.Shooter.SurnameAndName]),mtConfirmation,[mbYes,mbNo],0);
  if res= mrYes then
    begin
      er.Free;
      ListBox1.Count:= fResults.Count+1;
      ListBox1.ItemIndex:= index;
    end;
end;

function TEnterResultsForm.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

function TEnterResultsForm.CheckValues: boolean;
begin
  Result:= false;
  if cbChamp.Text= '' then
    begin
      MessageDlg (Language ['ChampNotSelected'],mtError,[mbOk],0);
      cbChamp.SetFocus;
      exit;
    end;
  if cbChamp.ItemIndex>= 0 then
    begin
      fResults.fChampionship:= fResults.fData.Championships.Items [cbChamp.ItemIndex];
      fResults.fChampionshipName:= fResults.fData.Championships.Items [cbChamp.ItemIndex].Name;
    end
  else
    begin
      fResults.fChampionship:= nil;
      fResults.fChampionshipName:= cbChamp.Text;
    end;
  fResults.fCountry:= edtCountry.Text;
  fResults.fTown:= edtTown.Text;
  Result:= true;
end;

{ TEnteredResults }

function TEnteredResults.Add: TEnteredResultItem;
begin
  Result:= inherited Add as TEnteredResultItem;
end;

constructor TEnteredResults.Create;
begin
  inherited Create (TEnteredResultItem);
  fChampionship:= nil;
  fChampionshipName:= '';
  fCountry:= '';
  fTown:= '';
  fYear:= YearOf (Now);
  fData:= nil;
  fShootingChampionship:= nil;
end;

procedure TEnteredResults.FromTill(var From, Till: TDateTime);
var
  i: integer;
  er: TEnteredResultItem;
begin
  From:= 0;
  Till:= 0;
  for i:= 0 to Count-1 do
    begin
      er:= Items [i];
      if (er.Date< From) or (From= 0) then
        From:= er.Date;
      if (er.Date> Till) or (Till= 0) then
        Till:= er.Date;
    end;
end;

function TEnteredResults.get_Item(index: integer): TEnteredResultItem;
begin
  Result:= inherited Items [index] as TEnteredResultItem;
end;

procedure TEnteredResults.SaveResults;
var
  i: integer;
  er: TEnteredResultItem;
  res: TResultItem;
  _date: TDateTime;
  sev: TShootingEventItem;
  date1,date2: TDateTime;
begin
  FromTill (date1,date2);
  if fShootingChampionship= nil then
    begin
      fShootingChampionship:= fData.ShootingChampionships.Find (fChampionship,fChampionshipName,date1,fCountry,fTown);
      if fShootingChampionship= nil then
        begin
          fShootingChampionship:= fData.ShootingChampionships.Add;
          fShootingChampionship.SetChampionship (fChampionship,fChampionshipName);
          fShootingChampionship.Country:= fCountry;
          fShootingChampionship.Town:= fTown;
        end;
    end;
  for i:= 0 to Count-1 do
    begin
      er:= Items [i];
      res:= er.Shooter.Results.Add;
      _date:= er.Date;
      sev:= fShootingChampionship.Events.Find (er.Event,er.EventName,_date);
      if sev= nil then
        begin
          sev:= fShootingChampionship.Events.Add;
          sev.Date:= _date;
          sev.SetEvent (er.Event,er.ShortName,er.EventName);
        end;
      res.ShootingEvent:= sev;
      res.Junior:= er.Junior;
      res.Rank:= er.Rank;
      res.Competition10:= er.Competition10;
      res.CompetitionWithTens:= er.CompetitionWithTens;
      res.Final10:= er.Final10;
    end;
end;

procedure TEnterResultsForm.ListBox1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  w: integer;
  s: string;
  h: THeaderSection;
  r: TRect;
  er: TEnteredResultItem;
begin
  with ListBox1.Canvas do
    begin
      FillRect(Rect);
      if index> fResults.Count then
        exit
      else if index= fResults.Count then
        begin
          ListBox1.Canvas.FillRect(Rect);
          s:= NEW_RECORD_STR;
          w:= ListBox1.Canvas.TextWidth (s);
          TextOut (Rect.Left+(ListBox1.ClientWidth-w) div 2,Rect.Top+4,s);
        end
      else
        begin
          er:= fResults [index];
          Brush.Style:= bsClear;

          h:= HeaderControl1.Sections [0];
          r.Top:= Rect.Top;
          r.Bottom:= Rect.Bottom;
          r.Left:= h.Left;
          r.Right:= h.Right;
          Font.Style:= [fsBold];
          TextRect (r,r.Left+2,r.Top+l1y,er.Shooter.SurnameAndName);
          Font.Style:= [];
          TextRect (r,r.Left+2,r.Top+l2y,er.Shooter.Group.Name);

          if er.Date<> 0 then
            begin
              h:= HeaderControl1.Sections [1];
              r.Top:= Rect.Top;
              r.Bottom:= Rect.Bottom;
              r.Left:= h.Left;
              r.Right:= h.Right;
              Font.Style:= [];
              TextRect (r,r.Left+2,r.Top+l1y,FormatDateTime ('dd.mm.yyyy',er.Date));
            end;

          if (er.Event<> nil) or (er.EventName<> '') then
            begin
              h:= HeaderControl1.Sections [2];
              r.Top:= Rect.Top;
              r.Bottom:= Rect.Bottom;
              r.Left:= h.Left;
              r.Right:= h.Right;
              if er.Event<> nil then
                begin
                  Font.Style:= [fsBold];
                  TextRect (r,r.Left+2,r.Top+l1y,er.Event.ShortName);
                  Font.Style:= [];
                  TextRect (r,r.Left+2,r.Top+l2y,er.Event.Name);
                end
              else
                begin
                  Font.Style:= [];
                  TextRect (r,r.Left+2,r.Top+(l1y+l2y) div 2,er.EventName);
                end;
            end;

          if er.Junior then
            begin
              h:= HeaderControl1.Sections [3];
              r.Top:= Rect.Top;
              r.Bottom:= Rect.Bottom;
              r.Left:= h.Left;
              r.Right:= h.Right;
              Font.Style:= [];
              TextRect (r,(r.Left+r.Right-TextWidth ('�')) div 2,r.Top+l1y,'�');
            end;

          if er.Rank> 0 then
            begin
              h:= HeaderControl1.Sections [4];
              r.Top:= Rect.Top;
              r.Bottom:= Rect.Bottom;
              r.Left:= h.Left;
              r.Right:= h.Right;
              Font.Style:= [fsBold];
              TextRect (r,r.Left+2,r.Top+l1y,IntToStr (er.Rank));
            end;

          if er.Competition10> 0 then
            begin
              h:= HeaderControl1.Sections [5];
              r.Top:= Rect.Top;
              r.Bottom:= Rect.Bottom;
              r.Left:= h.Left;
              r.Right:= h.Right;
              Font.Style:= [];
              TextRect (r,r.Left+2,r.Top+l1y,er.CompStr);
            end;

          if (er.Event<> nil) and (er.Event.InFinal (er.Rank)) then
            begin
              h:= HeaderControl1.Sections [6];
              r.Top:= Rect.Top;
              r.Bottom:= Rect.Bottom;
              r.Left:= h.Left;
              r.Right:= h.Right;
              Font.Style:= [];
              TextRect (r,r.Left+2,r.Top+l1y,er.Event.FinalStr (er.Final10));
            end;
        end;
    end;
end;

procedure TEnterResultsForm.ListBox1DblClick(Sender: TObject);
begin
  if ListBox1.ItemIndex< 0 then
    exit;
  if ListBox1.ItemIndex< fResults.Count then
    OpenResult (ListBox1.ItemIndex)
  else
    NewResult;
end;

procedure TEnterResultsForm.ListBox1KeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      if ListBox1.ItemIndex= fResults.Count then
        NewResult
      else if ListBox1.ItemIndex>= 0 then
        OpenResult (ListBox1.ItemIndex);
    end;
    #27: begin
      Close;
    end;
  end;
end;

procedure TEnterResultsForm.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_DELETE: begin
      if (ListBox1.ItemIndex>= 0) and (ListBox1.ItemIndex< fResults.Count) then
        DeleteResult (ListBox1.ItemIndex);
      Key:= 0;
    end;
  end;
end;

procedure TEnterResultsForm.HeaderControl1Resize(Sender: TObject);
begin
  with HeaderControl1 do
    Sections [6].Width:= ClientWidth-Sections [6].Left;
end;

procedure TEnterResultsForm.HeaderControl1SectionResize(
  HeaderControl: THeaderControl; Section: THeaderSection);
begin
  ListBox1.Invalidate;
  HeaderControl1Resize (HeaderControl1);
end;

procedure TEnterResultsForm.FormResize(Sender: TObject);
var
  w,i: integer;
  x: integer;
begin
  x:= pnlInfo.ClientWidth div 2;
  cbChamp.Width:= x-8-cbChamp.Left;
  w:= lCountry.Width;
  i:= lTown.Width;
  if i> w then
    w:= i;
  lCountry.Left:= x+w+8-lCountry.Width;
  lTown.Left:= x+w+8-lTown.Width;
  edtCountry.Left:= x+w+16;
  edtTown.Left:= x+w+16;
  edtCountry.Width:= pnlInfo.ClientWidth-edtCountry.Left-8;
  edtTown.Width:= edtCountry.Width;
end;

end.

