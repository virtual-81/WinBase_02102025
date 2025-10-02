{$a-}
unit form_eventshooters;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Menus, Grids,
  System.UITypes,

  MyStrings,
  Data,
  SysFont,
  Vcl.Printers,

  MyLanguage,
  ctrl_language,

  form_printprotocol,
  form_selectshooterdialog,
  form_relaypos,

  MyListBoxes;

type
  TEventShootersForm = class(TForm)
    Panel3: TPanel;
    btnPrint: TButton;
    btnPDF: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnPDFClick(Sender: TObject);
    procedure OnListBoxDrawItem (Sender: THeadedListBox; ListBox: THListBox; Index: integer; ARect: TRect; Section: THeadedListBoxSection; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure OnListBoxKeyDown(Sender: TObject; var Key: Word;  Shift: TShiftState);
    procedure OnListBoxDblClick (Sender: TObject);
    procedure OnListBoxKeyPress(Sender: TObject; var Key: Char);
    procedure OnListBoxClick(Sender: TObject);
    procedure HeaderControl1SectionClick(HeaderControl: THeaderControl;  Section: THeaderSection);
    procedure btnPrintClick(Sender: TObject);
  private
    { Private declarations }
    fEvent: TStartListEventItem;
    fSearchStr: string;
    fSearchNum: string;
    fTeamSection,fStartNumberSection,fShooterSection: THeadedListBoxSection;
    fSortOrders: array [0..31] of TSortOrder;
//    fNoTeamForPointsStr: string;
    fRegionPoints0Str,fRegionPoints1Str: string;
    fDistrictPoints0Str,fDistrictPoints1Str: string;
    fListBox: THeadedListBox;
    fPointsLayout: boolean;
    procedure set_Event(const Value: TStartListEventItem);
    procedure ClearPosition;
    procedure DeleteShooter (Index: integer);
    procedure ChangeShooter (index: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property StartEvent: TStartListEventItem read fEvent write set_Event;
    function Execute: boolean;
    procedure UpdateData;
  end;

implementation

{$R *.dfm}

{ TEventShootersForm }

function TEventShootersForm.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TEventShootersForm.set_Event(const Value: TStartListEventItem);
var
  i,w,maxw: integer;
  s: THeadedListBoxSection;
  ssh: TStartListEventShooterItem;
begin
  fEvent:= Value;
  fPointsLayout:= (fEvent.PTeamsPoints.Count> 0) or
    (fEvent.RTeamsPoints.Count> 0) or (fEvent.RegionsPoints.Count> 0) or
    (fEvent.DistrictsPoints.Count> 0);

  fEvent.Shooters.SortOrder:= soPosition;

  for i:= 0 to Length (fSortOrders)-1 do
    fSortOrders [i]:= soNone;

  fListBox.Header.Sections.Clear;
  if fEvent.StartList.StartNumbers then
    begin
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.Num']);
      s.Width:= 50;
      s.Font.Style:= [fsBold];
      s.AllowClick:= true;
      s.AutoSize:= false;
      s.Style:= hsText;
      fSortOrders [s.Index]:= soStartNumber;
      fStartNumberSection:= s;
    end
  else
    fStartNumberSection:= nil;

  s:= fListBox.AddSection (Language ['EventShootersForm.HC.Name']);
  s.Width:= 100;
  s.Font.Style:= [fsBold];
  fListBox.ListBox.Canvas.Font.Style:= s.Font.Style;
  fSortOrders [s.Index]:= soSurname;
  fShooterSection:= s;
  s.AllowClick:= true;
  maxw:= s.Width;
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      ssh:= fEvent.Shooters.Items [i];
      w:= fListBox.ListBox.Canvas.TextWidth (ssh.Shooter.SurnameAndName);
      if w> maxw then
        maxw:= w;
    end;
  s.Width:= maxw+32;

  s:= fListBox.AddSection (Language ['EventShootersForm.HC.Qual']);
  s.Width:= 75;
  fSortOrders [s.Index]:= soQualification;
  s.AllowClick:= true;
  s.Font.Style:= [fsBold];
  fListBox.ListBox.Canvas.Font.Style:= s.Font.Style;
  maxw:= s.Width;
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      ssh:= fEvent.Shooters.Items [i];
      w:= fListBox.ListBox.Canvas.TextWidth (ssh.Shooter.QualificationName);
      if w> maxw then
        maxw:= w;
    end;
  s.Width:= maxw+8;

  s:= fListBox.AddSection (Language ['EventShootersForm.HC.Region']);
  s.Width:= 75;
  s.Font.Style:= [fsBold];
  fListBox.ListBox.Canvas.Font.Style:= s.Font.Style;
  fSortOrders [s.Index]:= soRegion;
  s.AllowClick:= true;
  maxw:= s.Width;
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      ssh:= fEvent.Shooters.Items [i];
      w:= fListBox.ListBox.Canvas.TextWidth (ssh.Shooter.RegionAbbr1);
      if w> maxw then
        maxw:= w;
    end;
  s.Width:= maxw+8;

  s:= fListBox.AddSection (Language ['EventShootersForm.HC.Team']);
  s.Width:= 75;
  s.Font.Style:= [fsBold];
  fListBox.ListBox.Canvas.Font.Style:= s.Font.Style;
  fSortOrders [s.Index]:= soTeam;
  fTeamSection:= s;
  s.AllowClick:= true;
  maxw:= s.Width;
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      ssh:= fEvent.Shooters.Items [i];
      w:= fListBox.ListBox.Canvas.TextWidth (substr (ssh.TeamForResults,' ',1));
      if w> maxw then
        maxw:= w;
    end;
  s.Width:= maxw+8;

  if fPointsLayout then
    begin
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.Points']);
      s.Width:= 50;
      fSortOrders [s.Index]:= soPoints;
      s.AllowClick:= true;
      s.Font.Style:= [fsBold];
      fListBox.ListBox.Canvas.Font.Style:= s.Font.Style;
      maxw:= s.Width;
      for i:= 0 to fEvent.Shooters.Count-1 do
        begin
          ssh:= fEvent.Shooters.Items [i];
          w:= fListBox.ListBox.Canvas.TextWidth (substr (ssh.TeamForPoints,' ',1));
          if w> maxw then
            maxw:= w;
        end;
      s.Width:= maxw+8;

      s:= fListBox.AddSection (Language ['EventShootersForm.HC.RegPoints']);
      s.Width:= 50;
      fSortOrders [s.Index]:= soNone;
      s.AllowClick:= true;
      s.Font.Style:= [fsBold];

      s:= fListBox.AddSection (Language ['EventShootersForm.HC.DisPoints']);
      s.Width:= 50;
      s.Font.Style:= [fsBold];
      fSortOrders [s.Index]:= soNone;
       s.AllowClick:= true;
   end;

  case fEvent.Event.EventType of
    etRegular,etCenterFire,etCenterFire2013,etThreePosition2013: begin
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.RegRelay']);
      s.Width:= 50;
      s.Font.Style:= [fsBold];
      fSortOrders [s.Index]:= soPosition;
      s.AllowClick:= true;
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.RegPos']);
      s.Width:= 60;
      s.Font.Style:= [fsBold];
      fSortOrders [s.Index]:= soPosition;
      s.AllowClick:= true;
    end;
    etRapidFire: begin
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.RFRelay']);
      s.Width:= 50;
      s.Font.Style:= [fsBold];
      fSortOrders [s.Index]:= soPosition;
      s.AllowClick:= true;
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.RFPos1']);
      s.Width:= 50;
      s.Font.Style:= [fsBold];
      fSortOrders [s.Index]:= soPosition;
      s.AllowClick:= true;
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.RFPos2']);
      s.Width:= 60;
      s.Font.Style:= [fsBold];
      fSortOrders [s.Index]:= soPosition;
      s.AllowClick:= true;
    end;
    etMovingTarget,etMovingTarget2013: begin
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.MTRelay']);
      s.Width:= 50;
      s.Font.Style:= [fsBold];
      fSortOrders [s.Index]:= soPosition;
      s.AllowClick:= true;
      s:= fListBox.AddSection (Language ['EventShootersForm.HC.MTPos']);
      s.Width:= 60;
      s.Font.Style:= [fsBold];
      fSortOrders [s.Index]:= soPosition;
      s.AllowClick:= true;
    end;
  end;
  fListBox.Header.OnSectionClick:= HeaderControl1SectionClick;
  UpdateData;
end;

procedure TEventShootersForm.UpdateData;
var
  i: integer;
  sh: TStartListEventShooterItem;
  s: string;
begin
  Caption:= format (Language ['EventShootersForm'],[fEvent.Event.ShortName,fEvent.Event.Name]);
  fSearchStr:= '';
  fSearchNum:= '';
  fListBox.Clear;
  for i:= 0 to fEvent.Shooters.Count-1 do
    begin
      sh:= fEvent.Shooters.Items [i];
      if fEvent.StartList.StartNumbers then
        s:= sh.StartNumberStr+#9
      else
        s:= '';
      s:= s+sh.Shooter.SurnameAndName+#9;
      s:= s+sh.Shooter.QualificationName+#9;
      s:= s+sh.Shooter.RegionAbbr1+#9;
      s:= s+SubStr (sh.TeamForResults,' ',1)+#9;
      if fPointsLayout then
        begin
          if sh.TeamForPoints<> '' then
            s:= s+sh.TeamForPoints+#9
          else
            s:= s+NOT_FOR_TEAM_MARK+#9;
          if sh.GiveRegionPoints then
            s:= s+fRegionPoints1Str+#9
          else
            s:= s+fRegionPoints0Str+#9;
          if sh.GiveDistrictPoints then
            s:= s+fDistrictPoints1Str+#9
          else
            s:= s+fDistrictPoints0Str+#9;
        end;
      if sh.Relay<> nil then
        begin
          s:= s+IntToStr (sh.Relay.Index+1)+#9;
          if sh.Position> 0 then
            s:= s+IntToStr (sh.Position)+#9
          else
            s:= s+#9;
          case fEvent.Event.EventType of
            etRegular,etCenterFire,etMovingTarget,etCenterFire2013,etThreePosition2013,etMovingTarget2013: {};
            etRapidFire: begin
              if sh.Position2> 0 then
                s:= s+IntToStr (sh.Position2);
            end;
          end;
        end;
      fListBox.ListBox.Items.Add (s);
    end;
  if fListBox.ListBox.Count> 0 then
    fListBox.ListBox.ItemIndex:= 0;
end;

procedure TEventShootersForm.UpdateFonts;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  btnPrint.ClientWidth:= Canvas.TextWidth (btnPrint.Caption)+32;
  btnPrint.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnPDF.Left:= btnPrint.Left+btnPrint.Width+16;
  btnPDF.ClientWidth:= Canvas.TextWidth (btnPDF.Caption)+32;
  btnPDF.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  Panel3.ClientHeight:= 16+btnPrint.Height;
  fListBox.Font:= Font;
  fListBox.ItemExtraHeight:= 10;
end;

procedure TEventShootersForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
//  LoadControlLanguage (fListBox.Header);
//  fNoTeamForPointsStr:= Language [625];
  fRegionPoints0Str:= Language ['EventShootersForm.RegPoints0'];
  fRegionPoints1Str:= Language ['EventShootersForm.RegPoints1'];
  fDistrictPoints0Str:= Language ['EventShootersForm.DistPoints0'];
  fDistrictPoints1Str:= Language ['EventShootersForm.DistPoints1'];
end;

procedure TEventShootersForm.FormCreate(Sender: TObject);
begin
  btnPrint.Left:= 8;
  btnPrint.Top:= 8;
  btnPDF.Top:= 8;
  fListBox:= THeadedListBox.Create (self);
  fListBox.Align:= alClient;
  fListBox.OnDblClick:= OnListBoxDblClick;
  fListBox.ListBox.OnClick:= OnListBoxClick;
  fListBox.ListBox.OnKeyDown:= OnListBoxKeyDown;
  fListBox.ListBox.OnKeyPress:= OnListBoxKeyPress;
  fListBox.OnDrawItem:= OnListBoxDrawItem;
  fListBox.SectionTextLeft:= 2;
  fListBox.Parent:= self;
  ActiveControl:= fListBox.ListBox;
  UpdateLanguage;
  UpdateFonts;
  Width:= Round (Screen.Width * 0.75);
  Height:= Round (Screen.Height * 0.75);
  Position:= poScreenCenter;
end;

procedure TEventShootersForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
  end;
end;

procedure TEventShootersForm.OnListBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  idx: integer;
  s: string;
begin
  case Key of
    VK_RETURN: begin
      Key:= 0;
      if Shift= [] then
        OnListBoxDblClick (self)
      else if (Shift= [ssCtrl]) and (fSearchStr<> '') then
        begin
          idx:= fEvent.Shooters.Find (fListBox.ListBox.ItemIndex+1,fSearchStr);
          if idx> fListBox.ListBox.ItemIndex then
            begin
              s:= fSearchStr;
              fListBox.ListBox.ItemIndex:= idx;
              fSearchStr:= s;
              fListBox.ListBox.Invalidate;
            end
          else
            begin
              idx:= fEvent.Shooters.Find (0,fSearchStr);
              if idx< fListBox.ListBox.ItemIndex then
                begin
                  s:= fSearchStr;
                  fListBox.ListBox.ItemIndex:= idx;
                  fSearchStr:= s;
                  fListBox.ListBox.Invalidate;
                end;
            end;
        end
      else if (Shift= [ssCtrl]) and (fSearchNum<> '') then
        begin
          idx:= fEvent.Shooters.FindNum (fListBox.ListBox.ItemIndex+1,fSearchNum);
          if idx> fListBox.ListBox.ItemIndex then
            begin
              s:= fSearchNum;
              fListBox.ListBox.ItemIndex:= idx;
              fSearchNum:= s;
              fListBox.ListBox.Invalidate;
            end;
        end;
    end;
    VK_DELETE: begin
      Key:= 0;
      fSearchStr:= '';
      fSearchNum:= '';
      ClearPosition;
    end;
    VK_F6: begin
      Key:= 0;
      fSearchStr:= '';
      fSearchNum:= '';
      fListBox.ListBox.Invalidate;
      ChangeShooter (fListBox.ListBox.ItemIndex);
    end;
  end;
end;

procedure TEventShootersForm.OnListBoxDblClick(Sender: TObject);
var
  RPD: TRelayPositionDialog;
  sh,sh1: TStartListEventShooterItem;
begin
  if (fListBox.ListBox.ItemIndex>= 0) and (fListBox.ListBox.ItemIndex< fEvent.Shooters.Count) then
    begin
      fSearchStr:= '';
      fSearchNum:= '';
      fListBox.ListBox.Invalidate;
      sh:= fEvent.Shooters.Items [fListBox.ListBox.ItemIndex];
      RPD:= TRelayPositionDialog.Create (self);
      RPD.Shooter:= sh;
      if RPD.Execute then
        begin
          if (RPD.Relay<> nil) and (RPD.Position1> 0) and
             ((RPD.Relay<> sh.Relay) or (RPD.Position1<> sh.Position)) then
            begin
              sh1:= fEvent.FindShooter (RPD.Relay,RPD.Position1);
              if sh1<> nil then
                begin
                  sh1.Relay:= sh.Relay;
                  sh1.Position:= sh.Position;
                  case fEvent.Event.EventType of
                    etRegular: {};
                    etCenterFire: {};
                    etMovingTarget: {};
                    etRapidFire: sh1.Position2:= sh.Position2;
                    etCenterFire2013: {};
                    etThreePosition2013: {};
                    etMovingTarget2013: {};
                  end;
                end;
            end;
          sh.Relay:= RPD.Relay;
          sh.Position:= RPD.Position1;
          case fEvent.Event.EventType of
            etRegular: {};
            etCenterFire: {};
            etMovingTarget: {};
            etRapidFire: sh.Position2:= RPD.Position2;
            etCenterFire2013: {};
            etThreePosition2013: {};
            etMovingTarget2013: {};
          end;
          sh.TeamForPoints:= RPD.TeamForPoints;
          sh.GiveRegionPoints:= RPD.GiveRegionPoints;
          sh.GiveDistrictPoints:= RPD.GiveDistrictPoints;
          sh.TeamForPoints:= RPD.TeamForPoints;
          sh.TeamForResults:= RPD.TeamForResults;
          sh.OutOfRank:= RPD.OutOfRank;
          fEvent.Shooters.SortOrder:= fEvent.Shooters.SortOrder;
          UpdateData;
          fListBox.ListBox.ItemIndex:= sh.Index;
        end;
      RPD.Free;
    end;
end;

procedure TEventShootersForm.OnListBoxDrawItem(Sender: THeadedListBox;
  ListBox: THListBox; Index: integer; ARect: TRect;
  Section: THeadedListBoxSection; State: TOwnerDrawState);
var
  sh: TStartListEventShooterItem;
  c: TColor;
  w: integer;
  s,st: string;
  r: TRect;
begin
  sh:= fEvent.Shooters.Items [Index];
  r:= Rect (ARect.Left+Section.Left,ARect.Top,ARect.Left+Section.Right,ARect.Bottom);
  if Section= fShooterSection then
    begin
      s:= sh.Shooter.SurnameAndName;
      with fListBox.ListBox.Canvas do
        begin
          c:= Font.Color;
          Font:= Section.Font;
          Font.Color:= c;
          if (fSearchStr<> '') and (odSelected in State) then
            begin
              Brush.Style:= bsClear;
              Font.Style:= [fsBold,fsUnderline];
              c:= Font.Color;
              Font.Color:= clYellow;
              TextRect (r,r.Left+2,r.Top+5,fSearchStr);
              w:= TextWidth (fSearchStr);
              Font.Style:= [];
              Font.Color:= c;
              st:= copy (s,Length (fSearchStr)+1,Length (s));
              TextRect (r,r.Left+2+w,r.Top+5,st);
            end
          else
            begin
              TextRect (r,r.Left+2,r.Top+5,s);
            end;
        end;
    end
  else if Section= fStartNumberSection then
    begin
      s:= sh.StartNumberStr;
      with fListBox.ListBox.Canvas do
        begin
          c:= Font.Color;
          Font:= Section.Font;
          Font.Color:= c;
          if (fSearchNum<> '') and (odSelected in State) then
            begin
              Brush.Style:= bsClear;
              Font.Style:= [fsBold,fsUnderline];
              c:= Font.Color;
              Font.Color:= clYellow;
              TextRect (r,r.Left+2,r.Top+5,fSearchNum);
              w:= TextWidth (fSearchNum);
              Font.Style:= [fsBold];
              Font.Color:= c;
              st:= s;
              delete (st,1,Length (fSearchNum));
              TextRect (r,r.Left+2+w,r.Top+5,st);
            end
          else
            begin
              TextRect (r,r.Left+2,r.Top+5,s);
            end;
        end;
    end
  else
    fListBox.DrawItemSection (Index,ARect,State,Section,substr (fListBox.ListBox.Items [Index],#9,Section.Index+1))
end;

procedure TEventShootersForm.ClearPosition;
var
  sh: TStartListEventShooterItem;
begin
  if (fListBox.ListBox.ItemIndex>= 0) and (fListBox.ListBox.ItemIndex< fEvent.Shooters.Count) then
    begin
      sh:= fEvent.Shooters.Items [fListBox.ListBox.ItemIndex];
      if sh.HavePosition then
        begin
          sh.Relay:= nil;
          sh.Position:= 0;
          sh.Position2:= 0;
        end
      else
        DeleteShooter (fListBox.ListBox.ItemIndex);
      fListBox.ListBox.Refresh;
    end;
end;

procedure TEventShootersForm.DeleteShooter(Index: integer);
var
  sh: TStartListEventShooterItem;
  ssh: TStartListShooterItem;
  idx: integer;
begin
  if (Index< 0) or (Index>= fEvent.Shooters.Count) then
    exit;
  sh:= fEvent.Shooters.Items [Index];
  if MessageDlg (format (Language ['DeleteEventShooterPrompt'],[sh.Shooter.SurnameAndName]),mtConfirmation,[mbYes,mbNo],0)= idYes then
    begin
      ssh:= sh.StartListShooter;
      idx:= sh.Index;
      sh.Free;
      // ���� ������� ������ ����� �� ��������, ������� ��� �� ������������ ���������
      if ssh.EventsCount= 0 then
        ssh.Free;
      UpdateData;
      if idx>= fListBox.ListBox.Count then
        idx:= fListBox.ListBox.Count-1;
      fListBox.ListBox.ItemIndex:= idx;
    end;
end;

procedure TEventShootersForm.ChangeShooter(index: integer);
var
  ssd: TSelectShooterDialog;
  esh: TStartListEventShooterItem;
  ssh: TStartListShooterItem;
  sh: TShooterItem;
begin
  if (index< 0) or (index>= fEvent.Shooters.Count) then
    exit;
  esh:= fEvent.Shooters.Items [index];
  ssd:= TSelectShooterDialog.Create (self);
  ssd.Data:= fEvent.StartList.Data;
  if ssd.Execute then
    begin
      sh:= ssd.Shooter;
      ssh:= fEvent.StartList.Shooters.FindShooter (sh);
      if ssh= nil then
        begin  // ���� ����� ��������� ��� �� ��������� �� � ����� ����������
          if esh.StartListShooter.EventsCount= 1 then
            begin  // ������� ������� �������� ������ � ���� ����������
              if MessageDlg (Language ['ReplaceEventShooterPrompt'],mtConfirmation,[mbYes,mbNo],0)= idYes then
                begin
                  esh.StartListShooter.Shooter:= sh;
                  UpdateData;
//                  lbShooters.Refresh;
                end;
            end
          else
            begin  // ������� ������� �������� � � ������ �����������
              if MessageDlg (Language ['ReplaceEventShooterAnywherePrompt'],mtConfirmation,[mbYes,mbNo],0)= idYes then
                begin   // �������� �� ���� �����������
                  esh.StartListShooter.Shooter:= sh;
                  UpdateData;
//                  lbShooters.Refresh;
                end
              else
                begin
                  ssh:= StartEvent.StartList.Shooters.Add;
                  ssh.StartNumber:= StartEvent.StartList.NextAvailableStartNumber;
                  ssh.Shooter:= sh;
                  ssh.StartNumberPrinted:= false;
                  esh.StartListShooter:= ssh;
                  UpdateData;
//                  lbShooters.Refresh;
                end;
            end;
        end
      else
        begin  // ���� ����� ��������� ��� ��������� � �����-�� �����������
          if fEvent.Shooters.FindShooter (sh)= nil then
            begin  // ����� ������� ��� �� ��������� � ���� ����������
              if MessageDlg (Language ['ReplaceEventShooterPrompt'],mtConfirmation,[mbYes,mbNo],0)= idYes then
                begin
                  esh.StartListShooter:= ssh;
                  UpdateData;
//                  lbShooters.Refresh;
                end;
            end
          else
            begin  // ����� ������� ��� ��������� � ���� ����������
              MessageDlg (Language ['EventShooterExists'],mtError,[mbOk],0);
            end;
        end;
    end;
  ssd.Free;
end;

procedure TEventShootersForm.OnListBoxKeyPress(Sender: TObject; var Key: Char);
var
  s: string;
  idx: integer;
begin
  if CharInSet(Key, ['0'..'9']) and (fEvent.StartList.StartNumbers) then
    begin
      s:= fSearchNum+Key;
      idx:= fEvent.Shooters.FindNum (0,s);
      if idx>= 0 then
        begin
          fListBox.ListBox.ItemIndex:= idx;
          fSearchNum:= s;
          fSearchStr:= '';
          fListBox.ListBox.Invalidate;
        end;
      Key:= #0;
    end
  else if Key> #32 then
		begin
			s:= fSearchStr+Key;
			idx:= fEvent.Shooters.Find (0,s);
			if idx>= 0 then
				begin
					fListBox.ListBox.ItemIndex:= idx;
					fSearchStr:= s;
          fSearchNum:= '';
					fListBox.ListBox.Invalidate;
				end;
      Key:= #0;
		end;
end;

procedure TEventShootersForm.OnListBoxClick(Sender: TObject);
begin
  if (fSearchStr<> '') or (fSearchNum<> '') then
    begin
      fSearchStr:= '';
      fSearchNum:= '';
      fListBox.ListBox.Invalidate;
    end;
end;

procedure TEventShootersForm.HeaderControl1SectionClick (HeaderControl: THeaderControl; Section: THeaderSection);
var
  order: TSortOrder;
begin
  if Section= nil then
    exit;
  order:= fSortOrders [Section.Index];
  if order= soNone then
    exit;
  fSearchStr:= '';
  fSearchNum:= '';
  fEvent.Shooters.SortOrder:= order;
  UpdateData;
end;

procedure TEventShootersForm.btnPDFClick(Sender: TObject);
var
  sd: TSaveDialog;
begin
  sd:= TSaveDialog.Create (self);
  sd.DefaultExt:= '*.pdf';
  sd.Filter:= 'PDF files (*.pdf)|*.PDF';
  sd.Title:= Language ['EventShootersPdfTitle'];
  sd.Options:= [ofOverwritePrompt, ofPathMustExist, ofEnableSizing, ofDontAddToRecent];
  if sd.Execute then
    begin
      fEvent.SaveShootersListToPDF (sd.FileName);
    end;
  sd.Free;
  fListBox.ListBox.SetFocus;
end;

procedure TEventShootersForm.btnPrintClick(Sender: TObject);
var
  pd: TPrintProtocolDialog;
begin
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= format (Language ['EventShootersPrintTitle'],[fEvent.Event.ShortName]);
  pd.ShowCopies:= true;
  pd.ProtocolType:= ptStartNumbers;
  if pd.Execute then
    fEvent.PrintShootersList (Printer,pd.Copies);
  pd.Free;
  fListBox.ListBox.SetFocus;
end;

end.


