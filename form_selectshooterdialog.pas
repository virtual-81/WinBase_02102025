{$a-}
unit form_selectshooterdialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

type
  TSelectShooterDialog = class(TForm)
    lbGroups: TListBox;
    lbShooters: TListBox;
    btnOk: TButton;
    btnCancel: TButton;
    lNameC: TLabel;
    lName: TLabel;
    lBYearC: TLabel;
    lBYear: TLabel;
    lBDateC: TLabel;
    lBDate: TLabel;
    lISSFIDC: TLabel;
    lISSFID: TLabel;
    lQualC: TLabel;
    lQual: TLabel;
    lRegionC: TLabel;
    lDistrictC: TLabel;
    lDistrict: TLabel;
    lRegion: TLabel;
    lTownC: TLabel;
    lTown: TLabel;
    lClubC: TLabel;
    lClub: TLabel;
    procedure lbShootersKeyPress(Sender: TObject; var Key: Char);
    procedure lbGroupsKeyPress(Sender: TObject; var Key: Char);
    procedure lbShootersDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lbGroupsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbGroupsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbGroupsClick(Sender: TObject);
    procedure lbShootersClick(Sender: TObject);
    procedure lbShootersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    fData: TData;
    fGroup: TGroupItem;
    fShooter: TShooterItem;
    fSearchGroup,fSearchName: string;
    procedure set_Data(const Value: TData);
    procedure OpenGroup (index: integer);
    procedure OpenShooter (index: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure ResetSearch;
    function DoSearchGroup (s: string; AFrom: integer): integer;
    function DoSearchName (s: string; AFrom: integer): integer;
  public
    { Public declarations }
    property Data: TData read fData write set_Data;
    function Execute: boolean;
    property Shooter: TShooterItem read fShooter;
  end;

implementation

{$R *.dfm}

{ TSelectShooterDialog }

procedure TSelectShooterDialog.OpenGroup(index: integer);
begin
  if (index< 0) or (index>= fData.Groups.Count) then
    exit;
  fGroup:= fData.Groups [index];
  lbShooters.Count:= fGroup.Shooters.Count;
  if lbShooters.Count> 0 then
    begin
      lbShooters.ItemIndex:= 0;
      OpenShooter (0);
    end;
end;

procedure TSelectShooterDialog.set_Data(const Value: TData);
begin
  fData:= Value;
  fGroup:= nil;
  fShooter:= nil;
  lbGroups.Count:= fData.Groups.Count;
  if lbGroups.Count> 0 then
    begin
      lbGroups.ItemIndex:= 0;
      OpenGroup (0);
    end;
end;

procedure TSelectShooterDialog.UpdateFonts;
var
  bh: Integer;
  w,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbShooters.Font:= Font;
  lbShooters.Canvas.Font:= lbShooters.Font;
  lbShooters.ItemHeight:= lbShooters.Canvas.TextHeight ('Mg')+4;
  lbGroups.Font:= Font;
  lbGroups.Canvas.Font:= lbGroups.Font;
  lbGroups.ItemHeight:= lbGroups.Canvas.TextHeight ('Mg')+4;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnOk.ClientHeight:= bh;
  btnCancel.ClientHeight:= bh;
  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w;
  btnCancel.ClientWidth:= w;
  lName.Left:= lNameC.Left+lNameC.Width+8;
  lISSFID.Left:= lISSFIDC.Left+lISSFIDC.Width+8;
  lBYear.Left:= lBYearC.Left+lBYearC.Width+8;
  lQual.Left:= lQualC.Left+lQualC.Width+8;
  lDistrict.Left:= lDistrictC.Left+lDistrictC.Width+8;
  lRegion.Left:= lRegionC.Left+lRegionC.Width+8;
  lTown.Left:= lTownC.Left+lTownC.Width+8;
  lClub.Left:= lClubC.Left+lClubC.Width+8;
  lName.Font.Style:= [fsBold];
  lISSFID.Font.Style:= [fsBold];
  lBYear.Font.Style:= [fsBold];
  lBDate.Font.Style:= [fsBold];
  lQual.Font.Style:= [fsBold];
  lDistrict.Font.Style:= [fsBold];
  lRegion.Font.Style:= [fsBold];
  lTown.Font.Style:= [fsBold];
  lClub.Font.Style:= [fsBold];
  w:= Width-ClientWidth+btnOk.Width+8+btnCancel.Width+GetSystemMetrics (SM_CXVSCROLL)*2;
  i:= lBYearC.Width+8+lBYear.Width+24+lBDateC.Width+8+lBDate.Width+8+btnOk.Width+8+btnCancel.Width;
  if i> w then
    w:= i;
  if w< 320 then
    w:= 320;
  Constraints.MinWidth:= w;
  Constraints.MinHeight:= Height-ClientHeight+lbGroups.Height-lbGroups.ClientHeight+
    lbGroups.ItemHeight*8+8+lNameC.Height+2+lISSFIDC.Height+2+lBYearC.Height+2+lQualC.Height+2+
    lDistrictC.Height+2+lRegionC.Height+2+lTownC.Height+2+lClubC.Height;
end;

procedure TSelectShooterDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TSelectShooterDialog.lbGroupsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  idx: integer;
begin
  case Key of
    VK_RIGHT: begin
      Key:= 0;
      if fGroup<> nil then
        begin
          lbShooters.SetFocus;
          ResetSearch;
        end;
    end;
    VK_RETURN: begin
      Key:= 0;
      if Shift= [ssCtrl] then
        begin
          idx:= DoSearchGroup (fSearchGroup,lbGroups.ItemIndex+1);
          if idx< 0 then
            idx:= DoSearchGroup (fSearchGroup,0);
          if idx>= 0 then
            begin
              lbGroups.ItemIndex:= idx;
              OpenGroup (idx);
              lbGroups.Invalidate;
            end;
        end
      else
        begin
          ResetSearch;
          lbShooters.SetFocus;
        end;
    end;
  end;
end;

procedure TSelectShooterDialog.lbGroupsKeyPress(Sender: TObject; var Key: Char);
var
  idx: integer;
begin
  if Key= #8 then
    begin
      if fSearchGroup<> '' then
        begin
          SetLength (fSearchGroup,Length (fSearchGroup)-1);
          if fSearchGroup<> '' then
            begin
              idx:= DoSearchGroup (fSearchGroup+Key,0);
              if idx>= 0 then
                begin
                  lbGroups.ItemIndex:= idx;
                  OpenGroup (idx);
                end;
            end;
          lbGroups.Invalidate;
        end;
    end
  else if Key> #32 then
    begin
      idx:= DoSearchGroup (fSearchGroup+Key,0);
      if idx>= 0 then
        begin
          fSearchGroup:= fSearchGroup+Key;
          lbGroups.ItemIndex:= idx;
          lbGroups.Invalidate;
          OpenGroup (idx);
        end;
    end;
  Key:= #0;
end;

procedure TSelectShooterDialog.FormCreate(Sender: TObject);
begin
  lbGroups.Left:= 0;
  lbGroups.Top:= 0;
  lbShooters.Top:= 0;
  UpdateLanguage;
  UpdateFonts;
  Position:= poScreenCenter;
  fSearchGroup:= '';
  fSearchName:= '';
end;

procedure TSelectShooterDialog.FormResize(Sender: TObject);
begin
  btnOk.Top:= ClientHeight-btnOk.Height;
  btnCancel.Top:= btnOk.Top;
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-8-btnOk.Width;
  lClubC.Top:= ClientHeight-lClubC.Height;
  lClub.Top:= lClubC.Top;
  lTownC.Top:= lClubC.Top-2-lTownC.Height;
  lTown.Top:= lTownC.Top;
  lRegionC.Top:= lTownC.Top-2-lRegionC.Height;
  lRegion.Top:= lRegionC.Top;
  lDistrictC.Top:= lRegionC.Top-2-lDistrictC.Height;
  lDistrict.Top:= lDistrictC.Top;
  lQualC.Top:= lDistrictC.Top-2-lQualC.Height;
  lQual.Top:= lQualC.Top;
  lBYearC.Top:= lQualC.Top-2-lBYearC.Height;
  lBYear.Top:= lBYearC.Top;
  lBDateC.Top:= lBYearC.Top;
  lBDate.Top:= lBYearC.Top;
  lISSFIDC.Top:= lBYearC.Top-2-lISSFIDC.Height;
  lISSFID.Top:= lISSFIDC.Top;
  lNameC.Top:= lISSFIDC.Top-2-lNameC.Height;
  lName.Top:= lNameC.Top;
  lbGroups.Height:= lNameC.Top-8-lbGroups.Top;
  lbShooters.Height:= lbGroups.Height;
  lbGroups.Width:= round (ClientWidth*2/5)-4;
  lbShooters.Left:= lbGroups.Left+lbGroups.Width+8;
  lbShooters.Width:= ClientWidth-lbShooters.Left;
end;

procedure TSelectShooterDialog.lbGroupsClick(Sender: TObject);
begin
  ResetSearch;
  OpenGroup (lbGroups.ItemIndex);
end;

procedure TSelectShooterDialog.lbGroupsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  c: TColor;
  w: integer;
begin
  with lbGroups.Canvas do
    begin
      if odSelected in State then
        begin
          if lbGroups.Focused then
            Brush.Color:= clHighlight
          else
            Brush.Color:= clGrayText;
        end;
      FillRect (Rect);
      s:= fData.Groups.Items [Index].Name;
      if (fSearchGroup<> '') and (odSelected in State) then
        begin
          c:= Font.Color;
          Font.Color:= clYellow;
          Font.Style:= [fsBold,fsUnderline];
          TextOut (Rect.Left+2,Rect.Top+2,fSearchGroup);
          delete (s,1,Length (fSearchGroup));
          w:= TextWidth (fSearchGroup);
          Font.Style:= [];
          Font.Color:= c;
          TextOut (Rect.Left+2+w,Rect.Top+2,s);
        end
      else
        TextOut (Rect.Left+2,Rect.Top+2,s);
    end;
end;

function TSelectShooterDialog.DoSearchGroup(s: string; AFrom: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= AFrom to fData.Groups.Count-1 do
    if AnsiSameText (s,copy (fData.Groups [i].Name,1,Length (s))) then
      begin
        Result:= i;
        break;
      end;
end;

function TSelectShooterDialog.DoSearchName(s: string; AFrom: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  if fGroup= nil then
    exit;
  for i:= AFrom to fGroup.Shooters.Count-1 do
    if AnsiSameText (s,copy (fGroup.Shooters.Items [i].SurnameAndName,1,Length (s))) then
      begin
        Result:= i;
        break;
      end;
end;

function TSelectShooterDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TSelectShooterDialog.OpenShooter(index: integer);
begin
  if (index< 0) or (fGroup= nil) or (index>= fGroup.Shooters.Count) then
    exit;
  fShooter:= fGroup.Shooters [index];
  lName.Caption:= fShooter.SurnameAndName;
  lISSFID.Caption:= fShooter.ISSFID;
  lBYear.Caption:= fShooter.BirthFullStr;
  lBDateC.Left:= lBYear.Left+lBYear.Width+24;
  lBDate.Left:= lBDateC.Left+lBDateC.Width+8;
  lBDate.Caption:= '';
  lQual.Caption:= fShooter.QualificationName;
  lDistrict.Caption:= fShooter.DistrictAbbr;
  lRegion.Caption:= fShooter.RegionsAbbr;
  lTown.Caption:= fShooter.Town;
  lClub.Caption:= fShooter.SocietyAndClub;
  btnOk.Enabled:= true;
end;

procedure TSelectShooterDialog.ResetSearch;
begin
  if fSearchGroup<> '' then
    begin
      fSearchGroup:= '';
      lbGroups.Invalidate;
    end;
  if fSearchName<> '' then
    begin
      fSearchName:= '';
      lbShooters.Invalidate;
    end;
end;

procedure TSelectShooterDialog.lbShootersClick(Sender: TObject);
begin
  ResetSearch;
  OpenShooter (lbShooters.ItemIndex);
end;

procedure TSelectShooterDialog.lbShootersDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  w: integer;
  c: TColor;
begin
  with lbShooters.Canvas do
    begin
      if odSelected in State then
        begin
          if lbShooters.Focused then
            Brush.Color:= clHighlight
          else
            Brush.Color:= clGrayText;
        end;
      FillRect (Rect);
      s:= fGroup.Shooters.Items [Index].SurnameAndName;
      if (fSearchName<> '') and (odSelected in State) then
        begin
          c:= Font.Color;
          Font.Color:= clYellow;
          Font.Style:= [fsBold,fsUnderline];
          TextOut (Rect.Left+2,Rect.Top+2,fSearchName);
          delete (s,1,Length (fSearchName));
          w:= TextWidth (fSearchName);
          Font.Color:= c;
          Font.Style:= [];
          TextOut (Rect.Left+2+w,Rect.Top+2,s);
        end
      else
        TextOut (Rect.Left+2,Rect.Top+2,s);
    end;
end;

procedure TSelectShooterDialog.lbShootersKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  idx: integer;
begin
  case Key of
    VK_RETURN: begin
      Key:= 0;
      if Shift= [ssCtrl] then
        begin
          idx:= DoSearchName (fSearchName,lbShooters.ItemIndex+1);
          if idx< 0 then
            idx:= DoSearchName (fSearchName,0);
          if idx>= 0 then
            begin
              lbShooters.ItemIndex:= idx;
              OpenShooter (idx);
              lbShooters.Invalidate;
            end;
        end
      else
        begin
          ResetSearch;
          if btnOk.Enabled then
            btnOk.SetFocus;
        end;
    end;
    VK_LEFT: begin
      ResetSearch;
      lbGroups.SetFocus;
      Key:= 0;
    end;
  end;
end;

procedure TSelectShooterDialog.lbShootersKeyPress(Sender: TObject;
  var Key: Char);
var
  idx: integer;
begin
  if Key= #8 then
    begin
      if fSearchName<> '' then
        begin
          SetLength (fSearchName,Length (fSearchName)-1);
          if fSearchName<> '' then
            begin
              idx:= DoSearchName (fSearchName,0);
              if idx>= 0 then
                begin
                  lbShooters.ItemIndex:= idx;
                  OpenShooter (idx);
                end;
            end;
          lbShooters.Invalidate;
        end;
    end
  else if Key> #32 then
    begin
      idx:= DoSearchName (fSearchName+Key,0);
      if idx>= 0 then
        begin
          fSearchName:= fSearchName+Key;
          lbShooters.ItemIndex:= idx;
          lbShooters.Invalidate;
          OpenShooter (idx);
        end;
    end;
  Key:= #0;
end;

end.


