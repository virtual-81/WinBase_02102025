{$a-}
unit form_teamselect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, CheckLst,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

type
  TTeamSelectDialog = class(TForm)
    edtTeam: TEdit;
    lbTeams: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure lbTeamsClick(Sender: TObject);
    procedure lbTeamsDblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtTeamKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbTeamsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtTeamChange(Sender: TObject);
  private
    { Private declarations }
    fStart: TStartList;
    fModalResult: integer;
    procedure set_StartList(const Value: TStartList);
    function get_Team: string;
    procedure set_Team(const Value: string);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property StartList: TStartList read fStart write set_StartList;
    property Team: string read get_Team write set_Team;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

{ TForm1 }

function TTeamSelectDialog.Execute: boolean;
begin
  fModalResult:= mrCancel;
  Result:= (ShowModal= mrOk);
end;

function TTeamSelectDialog.get_Team: string;
begin
  Result:= edtTeam.Text;
end;

procedure TTeamSelectDialog.set_StartList(const Value: TStartList);
var
  teams: TStrings;
  w,i,j,idx,h: integer;
  s: string;
begin
  fStart:= Value;
  teams:= fStart.GetTeams (false,nil);
  // ��������� ������� �� ��������
  for i:= 0 to teams.Count-2 do
    begin
      idx:= i;
      for j:= i+1 to teams.Count-1 do
        if AnsiCompareText (teams [j],teams [idx])< 0 then
          idx:= j;
      if idx<> i then
        begin
          s:= teams [idx];
          teams [idx]:= teams [i];
          teams [i]:= s;
        end;
    end;
  lbTeams.Clear;
  lbTeams.Items.AddStrings (teams);
  teams.Free;
  h:= lbTeams.Count*lbTeams.Canvas.TextHeight ('Mg');
  if h> Screen.WorkAreaHeight div 2 then
    h:= Screen.WorkAreaHeight div 2;
  if h< lbTeams.Canvas.TextHeight ('Mg') then
    h:= lbTeams.Canvas.TextHeight ('Mg');
  lbTeams.ClientHeight:= h;
  w:= 0;
  for i:= 0 to lbTeams.Count-1 do
    if lbTeams.Canvas.TextWidth (lbTeams.Items [i])> w then
      w:= lbTeams.Canvas.TextWidth (lbTeams.Items [i]);
  if w> Screen.WorkAreaWidth div 2 then
    w:= Screen.WorkAreaWidth div 2;
  if w< 100 then
    w:= 100;
  lbTeams.ClientWidth:= w;
  edtTeam.Top:= lbTeams.Top+lbTeams.Height;
  edtTeam.Left:= 0;
  edtTeam.Width:= lbTeams.Width;
  ClientWidth:= edtTeam.Width;
  ClientHeight:= edtTeam.Top+edtTeam.Height;
  if Left+Width> Screen.WorkAreaWidth then
    Left:= Screen.WorkAreaWidth-Width;
  if Top+Height> Screen.WorkAreaHeight then
    Top:= Screen.WorkAreaHeight-Height;
end;

procedure TTeamSelectDialog.set_Team(const Value: string);
var
  i: integer;
begin
  edtTeam.Text:= Value;
  lbTeams.ItemIndex:= -1;
  for i:= 0 to lbTeams.Count-1 do
    if AnsiSameText (lbTeams.Items [i],Value) then
      begin
        lbTeams.ItemIndex:= i;
        break;
      end;
end;

procedure TTeamSelectDialog.UpdateFonts;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
end;

procedure TTeamSelectDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TTeamSelectDialog.lbTeamsClick(Sender: TObject);
begin
  edtTeam.OnChange:= nil;
  edtTeam.Text:= lbTeams.Items [lbTeams.ItemIndex];
  edtTeam.OnChange:= edtTeamChange;
end;

procedure TTeamSelectDialog.lbTeamsDblClick(Sender: TObject);
begin
  fModalResult:= mrOk;
  Close;
end;

procedure TTeamSelectDialog.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ModalResult:= fModalResult;
end;

procedure TTeamSelectDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
end;

procedure TTeamSelectDialog.edtTeamKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
      if Shift= [] then
        begin
          Key:= 0;
          fModalResult:= mrOk;
          Close;
        end
      else if Shift= [ssShift] then
        begin
          Key:= 0;
          lbTeamsClick (self);
        end;
    end;
    VK_ESCAPE: begin
      Key:= 0;
      fModalResult:= mrCancel;
      Close;
    end;
    VK_UP,VK_DOWN,VK_NEXT,VK_PRIOR: begin
      PostMessage (lbTeams.Handle,WM_KEYDOWN,Key,0);
      Key:= 0;
    end;
  end;
end;

procedure TTeamSelectDialog.lbTeamsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
      if Shift= [] then
        begin
          Key:= 0;
          fModalResult:= mrOk;
          Close;
        end;
    end;
    VK_ESCAPE: begin
      Key:= 0;
      fModalResult:= mrCancel;
      Close;
    end;
  end;
end;

procedure TTeamSelectDialog.edtTeamChange(Sender: TObject);
var
  i: integer;
begin
  if edtTeam.Text<> '' then
    begin
      for i:= 0 to lbTeams.Count-1 do
        if AnsiSameText (copy (lbTeams.Items [i],1,Length (edtTeam.Text)),edtTeam.Text) then
          begin
            lbTeams.ItemIndex:= i;
            exit;
          end;
      lbTeams.ItemIndex:= -1;
    end
  else
    lbTeams.ItemIndex:= -1;
end;

end.

