{$a-}
unit form_teams;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Buttons,
  System.UITypes, System.Types,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

type
  TTeamInfo= record
    Name: string;
    TeamShooters: integer;
    PointsShooters: integer;
  end;

  TTeamsSetupDialog = class(TForm)
    btnClose: TButton;
    edtPerTeam: TEdit;
    lbTeams: TListBox;
    hcTeams: THeaderControl;
    lPerTeam: TLabel;
    hcGroups: THeaderControl;
    lbGroups: TListBox;
    sbGroupAdd: TSpeedButton;
    sbGroupDelete: TSpeedButton;
    sbGroupEdit: TSpeedButton;
    lGroups: TLabel;
    lTeams: TLabel;
    sbTeamEdit: TSpeedButton;
    sbTeamDelete: TSpeedButton;
    procedure sbGroupEditClick(Sender: TObject);
    procedure lbGroupsExit(Sender: TObject);
    procedure lbGroupsEnter(Sender: TObject);
    procedure lbTeamsExit(Sender: TObject);
    procedure lbTeamsEnter(Sender: TObject);
    procedure sbGroupDeleteClick(Sender: TObject);
    procedure lbGroupsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbTeamsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lbTeamsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure sbGroupAddClick(Sender: TObject);
    procedure hcGroupsSectionResize(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure hcTeamsSectionResize(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure lbGroupsClick(Sender: TObject);
    procedure lbGroupsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure hcGroupsResize(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure edtPerTeamKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure lbTeamsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure btnEditClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lbTeamsClick(Sender: TObject);
    procedure hcTeamsResize(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbTeamsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    fStart: TStartList;
    fTeams: array of TTeamInfo;
    fGroup: TStartListTeamsGroup;
    procedure set_Start(const Value: TStartList);
    procedure UpdateData;
    procedure EditTeam (index: integer);
    procedure DeleteTeam (Index: integer);
    procedure ClearTeams;
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure ToggleGroup (Index: integer);
  public
    { Public declarations }
    property Start: TStartList read fStart write set_Start;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

{ TTeamsSetupDialog }

procedure TTeamsSetupDialog.EditTeam(index: integer);
var
  st,st1: string;
begin
  if index< 0 then
    exit;
  st:= fTeams [index].Name;
  if InputQuery (Language ['TeamName'],Language ['TeamNamePrompt'],st1) then
    begin
      fStart.ChangeTeamName (st,st1);
      lbTeams.Items [index]:= st1;
      fTeams [index].Name:= st1;
    end;
end;

procedure TTeamsSetupDialog.edtPerTeamKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN,VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
  end;
end;

function TTeamsSetupDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TTeamsSetupDialog.sbGroupAddClick(Sender: TObject);
var
  s: string;
  g: TStartListTeamsGroup;
begin
  s:= '';
  if InputQuery (Language ['TeamsGroupName'],Language ['TeamsGroupNamePrompt'],s) then
    begin
      s:= Trim (s);
      if s= '' then
        exit;
      g:= fStart.TeamsGroups.Add;
      g.Name:= s;
      lbGroups.Count:= fStart.TeamsGroups.Count;
      lbGroups.ItemIndex:= lbGroups.Count-1;
      fGroup:= g;
      if not lbGroups.Focused then
        lbGroups.SetFocus;
      lbTeams.Invalidate;
      lbGroupsClick (lbGroups);
    end;
end;

procedure TTeamsSetupDialog.sbGroupDeleteClick(Sender: TObject);
var
  ti,i: integer;
begin
  if (lbGroups.ItemIndex>= 0) then
    begin
      i:= lbGroups.ItemIndex;
      ti:= lbGroups.TopIndex;
      fStart.TeamsGroups.Delete (lbGroups.ItemIndex);
      lbGroups.Count:= fStart.TeamsGroups.Count;
      if lbGroups.Count> 0 then
        begin
          if i>= lbGroups.Count then
            dec (i);
          lbGroups.TopIndex:= ti;
          lbGroups.ItemIndex:= i;
          fGroup:= fStart.TeamsGroups [i];
        end
      else
        fGroup:= nil;
      lbGroups.Invalidate;
      lbTeams.Invalidate;
    end;
end;

procedure TTeamsSetupDialog.sbGroupEditClick(Sender: TObject);
var
  s: string;
  g: TStartListTeamsGroup;
begin
  if lbGroups.ItemIndex< 0 then
    exit;
  g:= fStart.TeamsGroups [lbGroups.ItemIndex];
  s:= g.Name;
  if InputQuery (Language ['TeamsGroupName'],Language ['TeamsGroupNamePrompt'],s) then
    begin
      g.Name:= s;
      lbGroups.Invalidate;
    end;
end;

procedure TTeamsSetupDialog.set_Start(const Value: TStartList);
begin
  fStart:= Value;
  UpdateData;
end;

procedure TTeamsSetupDialog.ToggleGroup(Index: integer);
var
  i: integer;
begin
  if (Index< 0) or (Index>= Length (fTeams)) or (fGroup= nil) then
    exit;
  i:= fGroup.TeamIndex (fTeams [Index].Name);
  if i>= 0 then
    begin
      fGroup.Delete (i);
    end
  else
    begin
      fGroup.Add (fTeams [Index].Name);
    end;
  lbGroups.Invalidate;
  lbTeams.Invalidate;
end;

procedure TTeamsSetupDialog.UpdateData;
var
  i: integer;
  teams: TStrings;
begin
  Caption:= format (Language ['TeamsSetupDialog'],[fStart.Info.CaptionText]);
  ClearTeams;
  fGroup:= nil;
  teams:= fStart.GetTeams (false,nil);
  SetLength (fTeams,teams.Count);
  for i:= 0 to teams.Count-1 do
    begin
      fTeams [i].Name:= teams [i];
      fTeams [i].TeamShooters:= fStart.Events.TeamShooters (fTeams [i].Name);
      fTeams [i].PointsShooters:= fStart.Events.PointsTeamShooters (fTeams [i].Name);
    end;
  teams.Free;
  lbTeams.Count:= Length (fTeams);
  if Length (fTeams)> 0 then
    lbTeams.ItemIndex:= 0;
  lbTeamsClick (lbTeams);
  edtPerTeam.Text:= IntToStr (fStart.ShootersPerTeam);
  lbGroups.Count:= fStart.TeamsGroups.Count;
  if lbGroups.Count> 0 then
    begin
      lbGroups.ItemIndex:= 0;
      fGroup:= fStart.TeamsGroups [0];
    end;
  lbGroupsClick (lbGroups);
end;

procedure TTeamsSetupDialog.UpdateFonts;
var
  bh: integer;
  mw: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbTeams.Canvas.Font:= lbTeams.Font;
  lbTeams.ItemHeight:= lbTeams.Canvas.TextHeight ('Mg')+4;
  lbGroups.Canvas.Font:= lbGroups.Font;
  lbGroups.ItemHeight:= lbGroups.Canvas.TextHeight ('Mg')+4;
  hcTeams.Canvas.Font:= hcTeams.Font;
  hcTeams.ClientHeight:= hcTeams.Canvas.TextHeight ('Mg')+4;
  hcTeams.Sections [0].MaxWidth:= lbTeams.ItemHeight+4;
  hcTeams.Sections [0].MinWidth:= lbTeams.ItemHeight+4;
  hcGroups.Canvas.Font:= hcGroups.Font;
  hcGroups.ClientHeight:= hcGroups.Canvas.TextHeight ('Mg')+4;
  hcGroups.Top:= lGroups.Top+lGroups.Height+4;
  hcTeams.Top:= lTeams.Top+lTeams.Height+4;
  lbGroups.Top:= hcGroups.Top+hcGroups.Height;
  lbTeams.Top:= hcTeams.Top+hcTeams.Height;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnClose.ClientHeight:= bh;
  btnClose.ClientWidth:= Canvas.TextWidth (btnClose.Caption)+32;
  mw:= edtPerTeam.Width+8+lPerTeam.Width;
  if (sbTeamDelete.Width+2+sbTeamEdit.Width)*2+16> mw then
    mw:= (sbTeamDelete.Width+2+sbTeamEdit.Width)*2+16;
  if (sbGroupAdd.Width+2+sbGroupDelete.Width+2+sbGroupEdit.Width)*2+16> mw then
    mw:= (sbGroupAdd.Width+2+sbGroupDelete.Width+2+sbGroupEdit.Width)*2+16;
  Constraints.MinWidth:= Width-ClientWidth+mw;
  Constraints.MinHeight:= Height-ClientHeight+btnClose.Height+16+hcTeams.Height+
    lbTeams.Height-lbTeams.ClientHeight+lbTeams.ItemHeight*6+edtPerTeam.Height+16+
    sbTeamEdit.Height+2;
end;

procedure TTeamsSetupDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TTeamsSetupDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  v,c: integer;
begin
  val (edtPerTeam.Text,v,c);
  if c= 0 then
    fStart.ShootersPerTeam:= v;
end;

procedure TTeamsSetupDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
  fGroup:= nil;
end;

procedure TTeamsSetupDialog.FormDestroy(Sender: TObject);
begin
  ClearTeams;
end;

procedure TTeamsSetupDialog.FormResize(Sender: TObject);
begin
  btnClose.Left:= ClientWidth-btnClose.Width;
  btnClose.Top:= ClientHeight-btnClose.Height;
  edtPerTeam.Left:= ClientWidth-edtPerTeam.Width;
  edtPerTeam.Top:= btnClose.Top-edtPerTeam.Height-16;
  lPerTeam.Left:= edtPerTeam.Left-8-lPerTeam.Width;
  lPerTeam.Top:= edtPerTeam.Top+(edtPerTeam.Height-lPerTeam.Height) div 2;
  sbTeamDelete.Top:= edtPerTeam.Top-16-sbTeamDelete.Height;
  sbTeamEdit.Top:= sbTeamDelete.Top;
  lbGroups.Width:= ClientWidth div 2-8;
  hcGroups.Width:= lbGroups.Width;
  lbTeams.Left:= lbGroups.Left+lbGroups.Width+16;
  hcTeams.Left:= lbTeams.Left;
  lTeams.Left:=lbTeams.Left;
  lbTeams.Width:= ClientWidth-lbTeams.Left;
  hcTeams.Width:= lbTeams.Width;
  lbTeams.Height:= sbTeamDelete.Top-2-lbTeams.Top;
  sbTeamEdit.Left:= lbTeams.Left+lbTeams.Width-sbTeamEdit.Width;
  sbTeamDelete.Left:= sbTeamEdit.Left-2-sbTeamDelete.Width;
  lbGroups.Height:= lbTeams.Height;
  sbGroupAdd.Left:= lbGroups.Left;
  sbGroupAdd.Top:= lbGroups.Top+lbGroups.Height+2;
  sbGroupDelete.Left:= sbGroupAdd.Left+sbGroupAdd.Width+2;
  sbGroupDelete.Top:= sbGroupAdd.Top;
  sbGroupEdit.Left:= sbGroupDelete.Left+sbGroupDelete.Width+2;
  sbGroupEdit.Top:= sbGroupAdd.Top;
  lbTeams.Invalidate;
end;

procedure TTeamsSetupDialog.hcGroupsResize(Sender: TObject);
begin
  hcGroups.Sections [0].Width:= hcGroups.ClientWidth-hcGroups.Sections [1].Width;
end;

procedure TTeamsSetupDialog.hcGroupsSectionResize(HeaderControl: THeaderControl;
  Section: THeaderSection);
begin
  lbGroups.Invalidate;
end;

procedure TTeamsSetupDialog.hcTeamsResize(Sender: TObject);
begin
  hcTeams.Sections [1].Width:= hcTeams.ClientWidth-hcTeams.Sections [2].Width-
    hcTeams.Sections [3].Width-hcTeams.Sections [0].Width;
end;

procedure TTeamsSetupDialog.hcTeamsSectionResize(HeaderControl: THeaderControl;
  Section: THeaderSection);
begin
  lbTeams.Invalidate;
end;

procedure TTeamsSetupDialog.lbGroupsClick(Sender: TObject);
begin
  if lbGroups.ItemIndex>= 0 then
    begin
      fGroup:= fStart.TeamsGroups [lbGroups.ItemIndex];
      lbTeams.Invalidate;
      sbGroupDelete.Enabled:= true;
      sbGroupEdit.Enabled:= true;
    end
  else
    begin
      fGroup:= nil;
      sbGroupDelete.Enabled:= false;
      sbGroupEdit.Enabled:= false;
    end;
end;

procedure TTeamsSetupDialog.lbGroupsDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  r: TRect;
  s: THeaderSection;
begin
  with lbGroups.Canvas do
    begin
      if odSelected in State then
        begin
          if not lbGroups.Focused then
            Brush.Color:= clGrayText;
        end;
      FillRect (ARect);
      Brush.Style:= bsClear;
      s:= hcGroups.Sections [0];
      r:= TRect.Create (s.Left+2,ARect.Top,s.Right-2,ARect.Bottom);
      TextRect (r,s.Left+2,ARect.Top+2,fStart.TeamsGroups [Index].Name);
      s:= hcGroups.Sections [1];
      r:= TRect.Create (s.Left+2,ARect.Top,s.Right-2,ARect.Bottom);
      TextRect (r,s.Left+2,ARect.Top+2,IntToStr (fStart.TeamsGroups [Index].Count));
    end;
end;

procedure TTeamsSetupDialog.lbGroupsEnter(Sender: TObject);
begin
  lbGroupsClick (lbGroups);
end;

procedure TTeamsSetupDialog.lbGroupsExit(Sender: TObject);
begin
  sbGroupDelete.Enabled:= false;
  sbGroupEdit.Enabled:= false;
end;

procedure TTeamsSetupDialog.lbGroupsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_INSERT: begin
      Key:= 0;
      sbGroupAdd.Click;
    end;
    VK_DELETE: begin
      Key:= 0;
      sbGroupDelete.Click;
    end;
    VK_RIGHT: begin
      Key:= 0;
      lbTeams.SetFocus;
    end;
  end;
end;

procedure TTeamsSetupDialog.lbTeamsClick(Sender: TObject);
begin
  if lbTeams.ItemIndex>= 0 then
    begin
      sbTeamEdit.Enabled:= true;
      sbTeamDelete.Enabled:= true;
    end
  else
    begin
      sbTeamEdit.Enabled:= false;
      sbTeamDelete.Enabled:= false;
    end;
end;

procedure TTeamsSetupDialog.lbTeamsDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s: THeaderSection;
  r: TRect;
  uState: cardinal;
begin
  with lbTeams.Canvas do
    begin
      if odSelected in State then
        begin
          if not lbTeams.Focused then
            Brush.Color:= clGrayText;
        end;
      FillRect (ARect);
      Brush.Style:= bsClear;
      if fGroup<> nil then
        begin
          s:= hcTeams.Sections [0];
          r:= TRect.Create (s.Left+2,ARect.Top+2,s.Right-2,ARect.Bottom-2);
          if (fGroup<> nil) and (fGroup.TeamIndex (fTeams [Index].Name)>= 0) then
            uState:= DFCS_BUTTONCHECK or DFCS_CHECKED
          else
            uState:= DFCS_BUTTONCHECK;
          DrawFrameControl (Handle,r,DFC_BUTTON,uState);
        end;
      s:= hcTeams.Sections [1];
      r:= TRect.Create (s.Left+2,ARect.Top,s.Right-2,ARect.Bottom);
      TextRect (r,s.Left+2,ARect.Top+2,fTeams [Index].Name);
      s:= hcTeams.Sections [2];
      r:= TRect.Create (s.Left+2,ARect.Top,s.Right-2,ARect.Bottom);
      TextRect (r,s.Left+2,ARect.Top+2,IntToStr (fTeams [Index].TeamShooters));
      s:= hcTeams.Sections [3];
      r:= TRect.Create (s.Left+2,ARect.Top,s.Right-2,ARect.Bottom);
      TextRect (r,s.Left+2,ARect.Top+2,IntToStr (fTeams [Index].PointsShooters));
    end;
end;

procedure TTeamsSetupDialog.lbTeamsEnter(Sender: TObject);
begin
  lbTeamsClick (lbTeams);
end;

procedure TTeamsSetupDialog.lbTeamsExit(Sender: TObject);
begin
  sbTeamEdit.Enabled:= false;
  sbTeamDelete.Enabled:= false;
end;

procedure TTeamsSetupDialog.lbTeamsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
    VK_RETURN: begin
      Key:= 0;
      EditTeam (lbTeams.ItemIndex);
    end;
    VK_DELETE: begin
      Key:= 0;
      DeleteTeam (lbTeams.ItemIndex);
    end;
    VK_SPACE: begin
      Key:= 0;
      if fGroup<> nil then
        begin
          ToggleGroup (lbTeams.ItemIndex);
          if lbTeams.ItemIndex< lbTeams.Count-1 then
            lbTeams.ItemIndex:= lbTeams.ItemIndex+1;
        end;
    end;
    VK_LEFT: begin
      Key:= 0;
      lbGroups.SetFocus;
    end;
  end;
end;

procedure TTeamsSetupDialog.lbTeamsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx: integer;
begin
  if (fGroup<> nil) and (x< hcTeams.Sections [0].Right) then
    begin
      idx:= lbTeams.ItemAtPos (Point (X,Y),true);
      if idx>= 0 then
        ToggleGroup (idx)
      else
        lbTeams.Cursor:= crDefault;
    end
  else
    lbTeams.Cursor:= crDefault;
end;

procedure TTeamsSetupDialog.lbTeamsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  idx: integer;
begin
  if (fGroup<> nil) and (x< hcTeams.Sections [0].Right) then
    begin
      idx:= lbTeams.ItemAtPos (Point (X,Y),true);
      if idx>= 0 then
        lbTeams.Cursor:= crHandPoint
      else
        lbTeams.Cursor:= crDefault;
    end
  else
    lbTeams.Cursor:= crDefault;
end;

procedure TTeamsSetupDialog.btnDeleteClick(Sender: TObject);
begin
  DeleteTeam (lbTeams.ItemIndex);
end;

procedure TTeamsSetupDialog.btnEditClick(Sender: TObject);
begin
  EditTeam (lbTeams.ItemIndex);
end;

procedure TTeamsSetupDialog.ClearTeams;
var
  i: integer;
begin
  lbTeams.Count:= 0;
  for i:= 0 to Length (fTeams)-1 do
    fTeams [i].Name:= '';
  SetLength (fTeams,0);
end;

procedure TTeamsSetupDialog.DeleteTeam (Index: integer);
var
  i: integer;
begin
  if (Index< 0) then
    exit;
  if MessageDlg (format (Language ['DeleteTeamPrompt'],[fTeams [Index].Name]),mtConfirmation,[mbYes,mbNo],0)= idYes then
    begin
      fStart.ChangeTeamName (fTeams [Index].Name,'');
      for i:= Index to Length (fTeams)-2 do
        fTeams [i]:= fTeams [i+1];
      SetLength (fTeams,Length (fTeams)-1);
      lbTeams.Count:= Length (fTeams);
      if Index< lbTeams.Count then
        begin
          lbTeams.ItemIndex:= Index;
        end
      else
        lbTeams.ItemIndex:= Index-1;
      lbTeamsClick (lbTeams);
    end;
end;

end.


