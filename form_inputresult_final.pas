{$a-}
unit form_inputresult;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, System.DateUtils, Vcl.ExtCtrls,

  SysFont,
  Data,
  MyStrings,

  MyLanguage,
  ctrl_language;

type
  TEnteredResultItem= class (TCollectionItem)
  private
    fShooter: TShooterItem;
    fDate: TDateTime;
    fEvent: TEventItem;
    fEventName: string;
    fShortName: string;
    fJunior: boolean;
    fRank: integer;
    fCompetition10: DWORD;
    fCompetitionWithTens: boolean;
    fFinal10: DWORD;
    function get_ShortName: string;
    function get_EventName: string;
  public
    constructor Create (ACollection: TCollection); override;
    property Shooter: TShooterItem read fShooter write fShooter;
    property Date: TDateTime read fDate write fDate;
    property Event: TEventItem read fEvent write fEvent;
    property EventName: string read get_EventName write fEventName;
    property ShortName: string read get_ShortName write fShortName;
    property Junior: boolean read fJunior write fJunior;
    property Rank: integer read fRank write fRank;
    property Competition10: DWORD read fCompetition10 write fCompetition10;
    property Final10: DWORD read fFinal10 write fFinal10;
    function CompStr: string;
    property CompetitionWithTens: boolean read fCompetitionWithTens;
  end;

  TInputResultDialog = class(TForm)
    cbEvent: TComboBox;
    lEvent: TLabel;
    lGroup: TLabel;
    lShooter: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    lDate: TLabel;
    edtDate: TEdit;
    edtRank: TEdit;
    lRank: TLabel;
    edtComp: TEdit;
    lComp: TLabel;
    edtFinal: TEdit;
    lFinal: TLabel;
    lbGroups: TListBox;
    lbShooters: TListBox;
    cbJunior: TCheckBox;
    procedure edtRankChange(Sender: TObject);
    procedure lbShootersClick(Sender: TObject);
    procedure lbShootersKeyPress(Sender: TObject; var Key: Char);
    procedure lbGroupsExit(Sender: TObject);
    procedure lbGroupsKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lbGroupsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbGroupsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbShootersKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbEventKeyPress(Sender: TObject; var Key: Char);
    procedure cbEventKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure leDateKeyPress(Sender: TObject; var Key: Char);
    procedure cbEventChange(Sender: TObject);
    procedure leRankChange(Sender: TObject);
    procedure cbJuniorKeyPress(Sender: TObject; var Key: Char);
    procedure leRankKeyPress(Sender: TObject; var Key: Char);
    procedure leCompKeyPress(Sender: TObject; var Key: Char);
    procedure leFinalKeyPress(Sender: TObject; var Key: Char);
    procedure lbShootersDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbGroupsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
    fData: TData;
    fYear: integer;
    fModalResult: integer;
    fGroupSearchStr: string;
    fShooterSearchStr: string;
    function get_Group: TGroupItem;
    procedure set_Group(const Value: TGroupItem);
    function get_Shooter: TShooterItem;
    procedure set_Shooter(const Value: TShooterItem);
    function get_Event: TEventItem;
    function get_EventName: string;
    procedure set_Event(const Value: TEventItem);
    function get_Rank: integer;
    procedure set_EventName(const Value: string);
    procedure set_Rank(const Value: integer);
    function get_Juniors: boolean;
    procedure set_Juniors(const Value: boolean);
    function get_Date: TDateTime;
    procedure set_Date(const Value: TDateTime);
//    function get_Comp: DWORD;
//    procedure set_Comp(const Value: DWORD);
    function get_Final: DWORD;
    procedure set_Final(const Value: DWORD);
    procedure UpdateFonts;
    procedure UpdateLanguage;
    function DoSearchGroup (AStr: string; From: integer): integer;
    function DoSearchShooter (AStr: string; From: integer): integer;
  public
    { Public declarations }
    function Execute: boolean;
    procedure SetData (AData: TData);
    property Group: TGroupItem read get_Group write set_Group;
    property Shooter: TShooterItem read get_Shooter write set_Shooter;
    property Event: TEventItem read get_Event write set_Event;
    property EventName: string read get_EventName write set_EventName;
    property Rank: integer read get_Rank write set_Rank;
    property Juniors: boolean read get_Juniors write set_Juniors;
    property Date: TDateTime read get_Date write set_Date;
    property Year: integer read fYear write fYear;
//    property Competition10: DWORD read get_Comp write set_Comp;
    property Final10: DWORD read get_Final write set_Final;
    procedure SetCompetition (Comp: DWORD; WithTens: boolean);
    procedure GetCompetition (ER: TEnteredResultItem);
  end;

implementation

{$R *.dfm}

{ TEnteredResultItem }

function TEnteredResultItem.CompStr: string;
begin
  if fCompetitionWithTens then
    Result:= format ('%d.%d',[fCompetition10 div 10,fCompetition10 mod 10])
  else
    Result:= IntToStr (fCompetition10 div 10);
end;

constructor TEnteredResultItem.Create(ACollection: TCollection);
begin
  inherited;
  fShooter:= nil;
  fDate:= 0;
  fEvent:= nil;
  fShortName:= '';
  fEventName:= '';
  fRank:= 0;
  fCompetition10:= 0;
  fCompetitionWithTens:= false;
  fFinal10:= 0;
  fJunior:= false;
end;

function TEnteredResultItem.get_EventName: string;
begin
  if fEvent<> nil then
    Result:= fEvent.Name
  else
    Result:= fEventName;
end;

function TEnteredResultItem.get_ShortName: string;
begin
  if fEvent<> nil then
    Result:= fEvent.ShortName
  else
    Result:= fShortName;
end;

{ TInputResultDialog }

function TInputResultDialog.Execute: boolean;
begin
  fGroupSearchStr:= '';
  fShooterSearchStr:= '';
  fModalResult:= mrCancel;
  Result:= (ShowModal= mrOk);
end;

function TInputResultDialog.get_Group: TGroupItem;
begin
  if lbGroups.ItemIndex>= 0 then
    Result:= fData.Groups [lbGroups.ItemIndex]
  else
    Result:= nil;
end;

procedure TInputResultDialog.SetCompetition(Comp: DWORD; WithTens: boolean);
begin
  if Comp> 0 then
    begin
      if Event<> nil then
        edtComp.Text:= ResultToStr (Comp,WithTens)
      else
        begin
          if not WithTens then
            edtComp.Text:= IntToStr (Comp div 10)
          else
            edtComp.Text:= IntToStr (Comp div 10)+'.'+IntToStr (Comp mod 10);
        end;
    end
  else
    edtComp.Text:= '';
end;

procedure TInputResultDialog.SetData(AData: TData);
var
  i: integer;
begin
  fData:= AData;
  lbGroups.Clear;
  
  // Проверка данных
  if (fData = nil) or (fData.Groups = nil) then
    Exit;
    
  for i:= 0 to fData.Groups.Count-1 do
    lbGroups.Items.Add (fData.Groups [i].Name);
  if lbGroups.Count> 0 then
    Group:= fData.Groups [0]
  else
    lbGroups.ItemIndex:= -1;
  cbEvent.Clear;
  
  if fData.Events <> nil then
  begin
    for i:= 0 to fData.Events.Count-1 do
      with fData.Events.Items [i] do
        cbEvent.Items.Add (ShortName+' ('+Name+')');
    if cbEvent.Items.Count> 0 then
      cbEvent.ItemIndex:= 0;
  end;
end;

procedure TInputResultDialog.set_Group(const Value: TGroupItem);
var
  i: integer;
begin
  if Value= nil then
    begin
      lbGroups.ItemIndex:=  -1;
      lbShooters.Clear;
      if lbShooters.Focused then
        lbGroups.SetFocus;
      lbShooters.Enabled:= false;
    end
  else
    begin
      lbGroups.ItemIndex:= Value.Index;
      lbShooters.Enabled:= true;
      lbShooters.Clear;
      for i:= 0 to Value.Shooters.Count-1 do
        lbShooters.Items.Add (Value.Shooters [i].SurnameAndName);
      lbShooters.ItemIndex:= -1;
    end;
end;

procedure TInputResultDialog.FormCreate(Sender: TObject);
begin
  Width:= Screen.Width div 2;
  Height:= Screen.Height div 2;
  edtDate.Text:= '';
  edtRank.Text:= '';
  edtComp.Text:= '';
  edtFinal.Text:= '';
  edtFinal.Visible:= false;
  lFinal.Visible:= false;
  UpdateLanguage;
  UpdateFonts;
  Position:= poScreenCenter;
end;

function TInputResultDialog.get_Shooter: TShooterItem;
begin
  if (lbShooters.Enabled) and (Group<> nil) and (lbShooters.ItemIndex>= 0) and 
     (lbShooters.ItemIndex < Group.Shooters.Count) then
    begin
      Result:= Group.Shooters [lbShooters.ItemIndex];
    end
  else
    begin
      Result:= nil;
    end;
end;

procedure TInputResultDialog.set_Shooter(const Value: TShooterItem);
begin
  if Value= nil then
    begin
      lbShooters.ItemIndex:= -1;
    end
  else
    begin
      if Value.Group<> Group then
        Group:= Value.Group;
      lbShooters.ItemIndex:= Value.Index;
    end;
end;

procedure TInputResultDialog.UpdateFonts;
var
  w,i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbGroups.Canvas.Font:= lbGroups.Font;
  lbGroups.ItemHeight:= lbGroups.Canvas.TextHeight ('Mg');
  lbShooters.Canvas.Font:= lbShooters.Font;
  lbShooters.ItemHeight:= lbShooters.Canvas.TextHeight ('Mg');
  lbGroups.Top:= lGroup.Top+lGroup.Height+2;
  lbShooters.Top:= lbGroups.Top;
  cbEvent.Canvas.Font:= cbEvent.Font;
  cbEvent.ItemHeight:= cbEvent.Canvas.TextHeight ('Mg');
  edtDate.ClientWidth:= Canvas.TextWidth (FormatDateTime (' dd/mm/yyyy ',Now));
  cbJunior.ClientHeight:= Canvas.TextHeight ('Mg');
  cbJunior.ClientWidth:= cbJunior.Height+8+Canvas.TextWidth (cbJunior.Caption);
  cbJunior.Left:= edtDate.Left+edtDate.Width+16;
  lRank.Left:= cbJunior.Left+cbJunior.Width+16;
  edtRank.Left:= lRank.Left;
  edtRank.ClientWidth:= Canvas.TextWidth ('00000');
  if edtRank.Width< lRank.Width then
    edtRank.Width:= lRank.Width;
  lComp.Left:= edtRank.Left+edtRank.Width+16;
  edtComp.Left:= lComp.Left;
  edtComp.ClientWidth:= Canvas.TextWidth ('0000000.0');
  if edtComp.Width< lComp.Width then
    edtComp.Width:= lComp.Width;
  lFinal.Left:= edtComp.Left+edtComp.Width+16;
  edtFinal.Left:= lFinal.Left;
  edtFinal.ClientWidth:= Canvas.TextWidth ('000000.0');
  if edtFinal.Width< lFinal.Width then
    edtFinal.Width:= lFinal.Width;
  Constraints.MinWidth:= Width-ClientWidth+edtFinal.Left+edtFinal.Width;
  lbShooters.Left:= lbGroups.Left+lbGroups.Width+8;
  lShooter.Left:= lbShooters.Left;
  ClientWidth:= lbShooters.Left+lbShooters.Width;
  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w;
  btnCancel.ClientWidth:= w;
  btnOk.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnCancel.ClientHeight:= btnOk.ClientHeight;
  Constraints.MinHeight:= Height-ClientHeight+btnOk.Height+16+edtDate.Height+2+lDate.Height+
    8+cbEvent.Height+2+lEvent.Height+8+lbGroups.Height-lbGroups.ClientHeight+
    lbGroups.ItemHeight*8+lGroup.Height+2;
end;

procedure TInputResultDialog.UpdateLanguage;
begin
  try
    LoadControlLanguage (self);
  except
    // Игнорируем ошибки при загрузке языка - это не критично
  end;
end;

function TInputResultDialog.get_Event: TEventItem;
begin
  if (cbEvent.ItemIndex >= 0) and (fData <> nil) and (fData.Events <> nil) and 
     (cbEvent.ItemIndex < fData.Events.Count) then
    Result:= fData.Events.Items [cbEvent.ItemIndex]
  else
    Result:= nil;
end;

function TInputResultDialog.get_EventName: string;
begin
  if (cbEvent.ItemIndex >= 0) and (fData <> nil) and (fData.Events <> nil) and 
     (cbEvent.ItemIndex < fData.Events.Count) then
    Result:= fData.Events.Items [cbEvent.ItemIndex].Name
  else
    Result:= cbEvent.Text;
end;

procedure TInputResultDialog.set_Event(const Value: TEventItem);
begin
  if Value<> nil then
    begin
      cbEvent.ItemIndex:= Value.Index;
      edtFinal.Visible:= (Rank <= Value.FinalPlaces) and (Rank> 0);
      lFinal.Visible:= edtFinal.Visible;
    end
  else
    begin
      cbEvent.ItemIndex:= -1;
      edtFinal.Visible:= false;
      lFinal.Visible:= edtFinal.Visible;
    end;
end;

function TInputResultDialog.get_Rank: integer;
var
  i: integer;
begin
  val (edtRank.Text,Result,i);
end;

procedure TInputResultDialog.set_EventName(const Value: string);
begin
  cbEvent.Text:= Value;
end;

procedure TInputResultDialog.set_Rank(const Value: integer);
var
  e: TEventItem;
begin
  if Value> 0 then
    edtRank.Text:= IntToStr (Value)
  else
    edtRank.Text:= '';
  e:= Event;
  if e<> nil then
    begin
      edtFinal.Visible:= (Value> 0) and (Value<= e.FinalPlaces);
      lFinal.Visible:= edtFinal.Visible;
    end
  else
    begin
      edtFinal.Visible:= false;
      lFinal.Visible:= edtFinal.Visible;
    end;
end;

function TInputResultDialog.get_Juniors: boolean;
begin
  Result:= cbJunior.Checked;
end;

procedure TInputResultDialog.set_Juniors(const Value: boolean);
begin
  cbJunior.Checked:= Value;
end;

function TInputResultDialog.get_Date: TDateTime;
var
  d,m,y,i: integer;
  s: string;
begin
  s:= Trim (edtDate.Text);
  val (substr (s,'.',1),d,i);
  val (substr (s,'.',2),m,i);
  val (substr (s,'.',3),y,i);
  if (y= 0) and (i<> 0) then
    y:= fYear;
  if (y>= 80) and (y< 100) then
    y:= y+1900
  else if (y>= 0) and (y< 80) then
    y:= y+2000;
  if not TryEncodeDate (y,m,d,Result) then
    Result:= EncodeDate (fYear,1,1);
end;

procedure TInputResultDialog.set_Date(const Value: TDateTime);
begin
  if YearOf (Value)= fYear then
    edtDate.Text:= FormatDateTime ('dd.mm',Value)
  else
    edtDate.Text:= FormatDateTime ('dd.mm.yyyy',Value);
end;

{
function TInputResultDialog.get_Comp: DWORD;
begin
  Result:= StrToFinal10 (edtComp.Text);
end;
}

{
procedure TInputResultDialog.set_Comp(const Value: DWORD);
begin
  if Value> 0 then
    begin
      if Event<> nil then
        edtComp.Text:= Event.CompStr (Value)
      else
        begin
          if Value mod 10= 0 then
            edtComp.Text:= IntToStr (Value div 10)
          else
            edtComp.Text:= IntToStr (Value div 10)+'.'+IntToStr (Value mod 10);
        end;
    end
  else
    edtComp.Text:= '';
end;
}

function TInputResultDialog.get_Final: DWORD;
begin
  if (edtFinal.Enabled) and (edtFinal.Visible) then
    begin
      Result:= StrToFinal10 (edtFinal.Text);
    end
  else
    begin
      Result:= 0;
    end;
end;

procedure TInputResultDialog.set_Final(const Value: DWORD);
var
  e: TEventItem;
begin
  e:= Event;
  if e<> nil then
    begin
      edtFinal.Text:= e.FinalStr (Value);
    end
  else
    begin
      edtFinal.Text:= IntToStr (Value div 10)+'.'+IntToStr (Value mod 10);
    end;
end;

procedure TInputResultDialog.btnOkClick(Sender: TObject);
begin
  if Group= nil then
    begin
      lbGroups.SetFocus;
      Beep;
      exit;
    end;
  if Shooter= nil then
    begin
      lbShooters.SetFocus;
      Beep;
      exit;
    end;
  fModalResult:= mrOk;
  Close;
end;

procedure TInputResultDialog.btnCancelClick(Sender: TObject);
begin
  fModalResult:= mrCancel;
  Close;
end;

procedure TInputResultDialog.lbGroupsClick(Sender: TObject);
begin
  if lbGroups.ItemIndex>= 0 then
    Group:= fData.Groups [lbGroups.ItemIndex];
  if fGroupSearchStr<> '' then
    begin
      fGroupSearchStr:= '';
      lbGroups.Invalidate;
    end;
end;

procedure TInputResultDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  ModalResult:= fModalResult;
end;

procedure TInputResultDialog.lbGroupsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  idx: integer;
begin
  case Key of
    VK_RETURN,VK_RIGHT: if Shift= [] then
      begin
        if lbGroups.ItemIndex>= 0 then
          begin
            lbShooters.SetFocus;
            if (lbShooters.ItemIndex= -1) and (lbShooters.Count> 0) then
              lbShooters.ItemIndex:= 0;
          end;
        Key:= 0;
      end
    else if Shift= [ssCtrl] then
      begin
        idx:= DoSearchGroup (fGroupSearchStr,lbGroups.ItemIndex+1);
        if idx>= 0 then
          begin
            lbGroups.ItemIndex:= idx;
            Group:= fData.Groups [idx];
            lbGroups.Invalidate;
          end;
        Key:= 0;
      end;
  end;
end;

procedure TInputResultDialog.lbGroupsKeyPress(Sender: TObject; var Key: Char);
var
  idx: integer;
begin
  if Key>= #32 then
    begin
      idx:= DoSearchGroup (fGroupSearchStr+Key,0);
      if (idx>= 0) then
        begin
          fGroupSearchStr:= fGroupSearchStr+Key;
          lbGroups.ItemIndex:= idx;
          Group:= fData.Groups [idx];
          lbGroups.Invalidate;
        end;
      Key:= #0;
    end
  else if Key= #8 then
    begin
      if fGroupSearchStr<> '' then
        begin
          idx:= DoSearchGroup (copy (fGroupSearchStr,1,Length (fGroupSearchStr)),0);
          if (idx>= 0) then
            begin
              SetLength (fGroupSearchStr,Length (fGroupSearchStr)-1);
              lbGroups.ItemIndex:= idx;
              Group:= fData.Groups [idx];
              lbGroups.Invalidate;
            end;
        end;
      Key:= #0;
    end;
end;

procedure TInputResultDialog.lbShootersKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT: begin
      Key:= 0;
      lbGroups.SetFocus;
    end;
    VK_RETURN,VK_RIGHT: begin
      Key:= 0;
      if lbShooters.ItemIndex>= 0 then
        cbEvent.SetFocus;
    end;
  end;
end;

procedure TInputResultDialog.lbShootersKeyPress(Sender: TObject; var Key: Char);
var
  idx: integer;
begin
  if Key>= #32 then
    begin
      idx:= DoSearchShooter (fShooterSearchStr+Key,0);
      if (idx>= 0) then
        begin
          fShooterSearchStr:= fShooterSearchStr+Key;
          lbShooters.ItemIndex:= idx;
          lbShooters.Invalidate;
        end;
      Key:= #0;
    end
  else if Key= #8 then
    begin
      if fShooterSearchStr<> '' then
        begin
          idx:= DoSearchShooter (copy (fShooterSearchStr,1,Length (fShooterSearchStr)),0);
          if (idx>= 0) then
            begin
              SetLength (fShooterSearchStr,Length (fShooterSearchStr)-1);
              lbShooters.ItemIndex:= idx;
              lbShooters.Invalidate;
            end;
        end;
      Key:= #0;
    end;
end;

procedure TInputResultDialog.cbEventKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      edtDate.SetFocus;
    end;
  end;
end;

procedure TInputResultDialog.cbEventKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RIGHT: begin
      Key:= 0;
      edtDate.SetFocus;
    end;
    VK_LEFT: begin
      Key:= 0;
    end;
  end;
end;

procedure TInputResultDialog.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
    #27: begin
      Key:= #0;
      btnCancel.Click;
    end;
  end;
end;

procedure TInputResultDialog.FormResize(Sender: TObject);
begin
  lbGroups.Width:= round (ClientWidth * 2/5)-4;
  lbShooters.Left:= lbGroups.Left+lbGroups.Width+8;
  lbShooters.Width:= ClientWidth-lbShooters.Left;
  lShooter.Left:= lbShooters.Left;
  cbEvent.Width:= ClientWidth;
  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-btnOk.Width-8;
  btnOk.Top:= ClientHeight-btnOk.Height;
  btnCancel.Top:= btnOk.Top;
  edtDate.Top:= btnOk.Top-16-edtDate.Height;
  lDate.Top:= edtDate.Top-2-lDate.Height;
  cbJunior.Top:= edtDate.Top+(edtDate.Height-cbJunior.Height) div 2;
  edtRank.Top:= edtDate.Top;
  lRank.Top:= lDate.Top;
  edtComp.Top:= edtDate.Top;
  lComp.Top:= lDate.Top;
  edtFinal.Top:= edtDate.Top;
  lFinal.Top:= lComp.Top;
  cbEvent.Top:= lDate.Top-8-cbEvent.Height;
  lEvent.Top:= cbEvent.Top-2-lEvent.Height;
  lbGroups.Height:= lEvent.Top-8-lbGroups.Top;
  lbShooters.Height:= lbGroups.Height;
end;

procedure TInputResultDialog.GetCompetition(ER: TEnteredResultItem);
begin
  if pos ('.',edtComp.Text)> 0 then
    begin
      ER.Competition10:= StrToFinal10 (edtComp.Text);
      ER.fCompetitionWithTens:= true;
    end
  else
    begin
      ER.Competition10:= StrToFinal10 (edtComp.Text);
      ER.fCompetitionWithTens:= false;
    end;
end;

procedure TInputResultDialog.leDateKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      if (cbJunior <> nil) and cbJunior.Enabled then
        cbJunior.SetFocus;
    end;
  end;
end;

procedure TInputResultDialog.cbEventChange(Sender: TObject);
var
  r: integer;
begin
  if (cbEvent.ItemIndex >= 0) and (fData <> nil) and (fData.Events <> nil) and 
     (cbEvent.ItemIndex < fData.Events.Count) then
    begin
      r:= Rank;
      edtFinal.Visible:= (r> 0) and (r<= fData.Events.Items [cbEvent.ItemIndex].FinalPlaces);
      lFinal.Visible:= edtFinal.Visible;
    end
  else
    begin
      edtFinal.Visible:= false;
      lFinal.Visible:= edtFinal.Visible;
    end;
end;

procedure TInputResultDialog.leRankChange(Sender: TObject);
var
  r: integer;
begin
  if cbEvent.ItemIndex>= 0 then
    begin
      r:= Rank;
      edtFinal.Visible:= (r> 0) and (r<= fData.Events.Items [cbEvent.ItemIndex].FinalPlaces);
      lFinal.Visible:= edtFinal.Visible;
    end
  else
    begin
      edtFinal.Visible:= false;
      lFinal.Visible:= edtFinal.Visible;
    end;
end;

procedure TInputResultDialog.cbJuniorKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      if (edtRank <> nil) and edtRank.Enabled then
        edtRank.SetFocus;
    end;
  end;
end;

function TInputResultDialog.DoSearchGroup(AStr: string; From: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  if (fData = nil) or (fData.Groups = nil) then
    Exit;
  for i:= From to fData.Groups.Count-1 do
    if AnsiSameText (AStr,copy (fData.Groups [i].Name,1,Length (AStr))) then
      begin
        Result:= i;
        break;
      end;
end;

function TInputResultDialog.DoSearchShooter(AStr: string;
  From: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= From to lbShooters.Count-1 do
    if AnsiSameText (AStr,copy (lbShooters.Items [i],1,Length (AStr))) then
      begin
        Result:= i;
        break;
      end;
end;

procedure TInputResultDialog.edtRankChange(Sender: TObject);
var
  v,i: integer;
begin
  val (edtRank.Text,v,i);
  edtFinal.Visible:= (i= 0) and ((v> 0) and (v<= fData.Events.Items [cbEvent.ItemIndex].FinalPlaces));
end;

procedure TInputResultDialog.leRankKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      if (edtComp <> nil) and edtComp.Enabled then
        edtComp.SetFocus;
    end;
  end;
end;

procedure TInputResultDialog.leCompKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      if (edtFinal <> nil) and edtFinal.Visible and edtFinal.Enabled then
        edtFinal.SetFocus
      else if (btnOk <> nil) and btnOk.Enabled then
        btnOk.SetFocus;
    end;
  end;
end;

procedure TInputResultDialog.leFinalKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      if (btnOk <> nil) and btnOk.Enabled then
        btnOk.SetFocus;
    end;
  end;
end;

procedure TInputResultDialog.lbShootersClick(Sender: TObject);
begin
  if fShooterSearchStr<> '' then
    begin
      fShooterSearchStr:= '';
      lbShooters.Invalidate;
    end;
end;

procedure TInputResultDialog.lbShootersDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  c: TColor;
  w: integer;
begin
  // Проверка границ массива
  if (Index < 0) or (Index >= lbShooters.Items.Count) then
    Exit;
    
  with lbShooters.Canvas do
    begin
      if lbShooters.Focused then
        begin
          FillRect (Rect);
          if (fShooterSearchStr<> '') and (odSelected in State) then
            begin
              s:= lbShooters.Items [Index];
              Font.Style:= [fsBold,fsUnderline];
              c:= Font.Color;
              Font.Color:= clYellow;
              TextOut (Rect.Left+2,Rect.Top,fShooterSearchStr);
              w:= TextWidth (fShooterSearchStr);
              Font.Color:= c;
              Font.Style:= [];
              TextOut (Rect.Left+2+w,Rect.Top,copy (s,Length (fShooterSearchStr)+1,Length (s)));
            end
          else
            TextOut (Rect.Left+2,Rect.Top,lbShooters.Items [Index]);
        end
      else
        begin
          if odSelected in State then
            begin
              Brush.Color:= lbShooters.Color;
              Font.Style:= [fsBold];
              Font.Color:= lbGroups.Font.Color;
            end;
          FillRect (Rect);
          TextOut (Rect.Left+2,Rect.Top,lbShooters.Items [Index]);
        end;
    end;
end;

procedure TInputResultDialog.lbGroupsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  s: string;
  c: TColor;
  w: integer;
begin
  // Проверка границ массива и указателей
  if (Index < 0) or (Index >= lbGroups.Items.Count) then
    Exit;
  if (fData = nil) or (Index >= fData.Groups.Count) then
    Exit;
    
  with lbGroups.Canvas do
    begin
      if lbGroups.Focused then
        begin
          FillRect (Rect);
          if (fGroupSearchStr<> '') and (odSelected in State) then
            begin
              s:= fData.Groups [Index].Name;
              Font.Style:= [fsBold,fsUnderline];
              c:= Font.Color;
              Font.Color:= clYellow;
              TextOut (Rect.Left+2,Rect.Top,fGroupSearchStr);
              w:= TextWidth (fGroupSearchStr);
              Font.Color:= c;
              Font.Style:= [];
              TextOut (Rect.Left+2+w,Rect.Top,copy (s,Length (fGroupSearchStr)+1,Length (s)));
            end
          else
            TextOut (Rect.Left+2,Rect.Top,lbGroups.Items [Index]);
        end
      else
        begin
          if odSelected in State then
            begin
              Brush.Color:= lbGroups.Color;
              Font.Style:= [fsBold];
              Font.Color:= lbGroups.Font.Color;
            end;
          FillRect (Rect);
          TextOut (Rect.Left+2,Rect.Top,lbGroups.Items [Index]);
        end;
    end;
end;

procedure TInputResultDialog.lbGroupsExit(Sender: TObject);
begin
  fGroupSearchStr:= '';
  lbGroups.Invalidate;
end;

end.

