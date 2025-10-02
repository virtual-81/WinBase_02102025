{$a-}
unit form_viewresults;

// TODO: ���������� �����������

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Types, System.UITypes,
	Vcl.Graphics, Vcl.Controls, Vcl.Forms,
	Vcl.Dialogs, System.DateUtils, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus,

  wb_registry,
  Data,
  SysFont,
  form_shootingevent,
  form_shootingchamp,
  form_enterresults,

  MyLanguage,
  MyReports,
  ctrl_language;

type
  TEventReport= class (TMyCustomReport)
  private
    fShootingEvent: TShootingEventItem;
    fResults: array of TResultItem;
  protected
//    function GetCanvas (APageIndex: integer): TCanvas; virtual;
//    function GetHeaderHeight (APageIndex: integer): integer; virtual;
//    function GetFooterHeight (APageIndex: integer): integer; virtual;
//    function GetRowHeight (ARowIndex: integer): integer; virtual;
//    procedure NewPage (APageIndex: integer; AFirstPage: boolean); virtual;
//    procedure PrintHeader (APageIndex: integer; ACanvas: TCanvas; ARect: TRect); virtual;
    procedure PrintFooter (APageIndex: integer; ACanvas: TCanvas; ARect: TRect); override;
//    procedure PrintCell (ARow,ACol: integer; AColObj: TMyReportColumn; ACanvas: TCanvas; ARect: TRect); virtual;
//    procedure PrintRow (ARow: integer; ACanvas: TCanvas; ARect: TRect); virtual;
  public
    constructor Create (AEvent: TShootingEventItem);
    destructor Destroy; override;
    procedure Add (AResult: TResultItem);
    procedure Precalc;
  end;


	TViewForm = class(TForm)
		lbResults: TListBox;
		Splitter1: TSplitter;
    pnlResults: TPanel;
		HeaderControl1: THeaderControl;
    StatusBar1: TStatusBar;
    TreeView1: TTreeView;
    pnlInfo: TPanel;
    lChamp: TLabel;
    lEvent: TLabel;
    lDate: TLabel;
    lChamp1: TLabel;
    lEvent1: TLabel;
    lDate1: TLabel;
    pmResult: TPopupMenu;
    mnuDelete: TMenuItem;
    pmChamp: TPopupMenu;
    mnuChampProps: TMenuItem;
    mnuAddResultsToChamp: TMenuItem;
    procedure mnuAddResultsToChampClick(Sender: TObject);
    procedure mnuChampPropsClick(Sender: TObject);
    procedure TreeView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TreeView1Compare(Sender: TObject; Node1, Node2: TTreeNode; Data: Integer; var Compare: Integer);
    procedure TreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure TreeView1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure pnlInfoClick(Sender: TObject);
    procedure TreeView1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mnuDeleteClick(Sender: TObject);
    procedure lbResultsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lbResultsMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
		procedure HeaderControl1SectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
    procedure lbResultsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HeaderControl1Resize(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure lbResultsDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
	private
		fChampionship: TChampionshipItem;
		fChampionshipName: string;
		fFrom,fTill: TDateTime;
		fData: TData;
    fCurrentEvent: TShootingEventItem;
    fCurrentEventNode: TTreeNode;
    fCurrentEventResults: array of TResultItem;
    y1,y2: integer;
		function get_ChampionshipName: string;
		procedure set_ChampionshipName(const Value: string);
		procedure set_Data(const Value: TData);
    function FindYearNode (const AYear: integer): TTreeNode;
    procedure SetEvent (N: TTreeNode);
    procedure DeleteResults;
    procedure UpdateFonts;
    procedure UpdateLanguage;
    procedure UpdateInfoPanel;
    procedure UpdateNodeCaption (N: TTreeNode);
    procedure InsertNewChampionship;
    procedure DeleteNode;
    procedure EditNode;
    function EditEvent (AEvent: TShootingEventItem): boolean;
    function EditChampionship (AChampionship: TShootingChampionshipItem): boolean;
    procedure EnterResults (ANode: TTreeNode);
  protected
    procedure DoClose (var Action: TCloseAction); override;
    procedure KeyDown (var Key: Word; Shift: TShiftState); override;
	public
    constructor Create (AOwner: TComponent); override;
    destructor Destroy; override;
		property Championship: TChampionshipItem read fChampionship write fChampionship;
		property ChampionshipName: string read get_ChampionshipName write set_ChampionshipName;
		property DateFrom: TDateTime read fFrom write fFrom;
		property DateTill: TDateTime read fTill write fTill;
		property Data: TData read fData write set_Data;
		procedure LoadResults;
    function Execute: boolean;
	end;

implementation

{$R *.dfm}

{ TViewForm }

function TViewForm.get_ChampionshipName: string;
begin
	if fChampionship<> nil then
		Result:= fChampionship.Name
	else
		Result:= fChampionshipName;
end;

procedure TViewForm.LoadResults;
var
	i,j: integer;
  year: integer;
  sch: TShootingChampionshipItem;
  sev: TShootingEventItem;
  yn,cn,en: TTreeNode;
begin
  TreeView1.Items.Clear;
  for i:= 0 to fData.ShootingChampionships.Count-1 do
    begin
      sch:= fData.ShootingChampionships [i];
      year:= sch.Year;
      yn:= FindYearNode (year);
      if yn= nil then
        begin
          yn:= TreeView1.Items.Add (nil,'');
          yn.Data:= Pointer (year);
          UpdateNodeCaption (yn);
        end;
      cn:= TreeView1.Items.AddChild (yn,'');
      cn.Data:= sch;
      for j:= 0 to sch.Events.Count-1 do
        begin
          sev:= sch.Events [j];
          en:= TreeView1.Items.AddChild (cn,'');
          en.Data:= sev;
          UpdateNodeCaption (en);
        end;
      UpdateNodeCaption (cn);
    end;
  fCurrentEvent:= nil;
end;

procedure TViewForm.mnuAddResultsToChampClick(Sender: TObject);
begin
  EnterResults (TreeView1.Selected);
end;

procedure TViewForm.mnuChampPropsClick(Sender: TObject);
begin
  EditNode;
end;

procedure TViewForm.mnuDeleteClick(Sender: TObject);
begin
  if fCurrentEvent= nil then
    exit;
  DeleteResults;
end;

procedure TViewForm.pnlInfoClick(Sender: TObject);
begin
  if fCurrentEvent= nil then
    exit;
  if EditEvent (fCurrentEvent) then
    begin
      UpdateNodeCaption (fCurrentEventNode);
      UpdateInfoPanel;
    end;
end;

procedure TViewForm.set_ChampionshipName(const Value: string);
begin
	fChampionship:= fData.Championships.FindByName (Value);
	if fChampionship<> nil then
		fChampionshipName:= ''
	else
		fChampionshipName:= Value;
end;

procedure TViewForm.HeaderControl1SectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  lbResults.Invalidate;
end;

procedure TViewForm.InsertNewChampionship;
var
  scd: TShootingChampionshipDetails;
  sch: TShootingChampionshipItem;
  yn,cn: TTreeNode;
begin
  if (TreeView1.Selected= nil) or (TreeView1.Selected.Level> 0) then
    exit;
  yn:= TreeView1.Selected;
  scd:= TShootingChampionshipDetails.Create (self);
  scd.SetData (fData);
  scd.SetChampionship (nil);
  if scd.Execute then
    begin
      sch:= fData.ShootingChampionships.Add;
      sch.SetChampionship (scd.Championship,scd.ChampionshipName);
      sch.Country:= scd.Country;
      sch.Town:= scd.Town;
      cn:= TreeView1.Items.AddChild (yn,'');
      cn.Data:= sch;
      UpdateNodeCaption (cn);
      TreeView1.Selected:= cn;
    end;
  scd.Free;
end;

procedure TViewForm.KeyDown(var Key: Word; Shift: TShiftState);
begin
	case Key of
		VK_ESCAPE: begin
			Key:= 0;
			Close;
		end;
	end;
end;

procedure TViewForm.set_Data(const Value: TData);
begin
	fData:= Value;
  LoadResults;
end;

constructor TViewForm.Create(AOwner: TComponent);
var
  x: integer;
begin
  inherited;
  LoadValueFromRegistry ('VRWidth',x,Round (Screen.Width * 0.75));
  Width:= x;
  LoadValueFromRegistry ('VRHeight',x,Round (Screen.Height * 0.75));
  Height:= x;
  LoadValueFromRegistry ('VRLeft',x,(Screen.Width-Width) div 2);
  Left:= x;
  LoadValueFromRegistry ('VRTop',x,(Screen.Height-Height) div 2);
  Top:= x;
  LoadValueFromRegistry ('ViewResultsSplitter',x,Width div 4);
  TreeView1.Width:= x;
  LoadHeaderControlFromRegistry ('ViewResultsHC',HeaderControl1);
  UpdateLanguage;
  UpdateFonts;
end;

procedure TViewForm.DeleteNode;
var
  sev: TShootingEventItem;
  en,cn,yn,yn1: TTreeNode;
  sch: TShootingChampionshipItem;
  y,y1: integer;
begin
  if TreeView1.Selected= nil then
    exit;
  case TreeView1.Selected.Level of
    0: {};
    1: begin
      // ������� ������������
      cn:= TreeView1.Selected;
      sch:= cn.Data;
{      if fData.StartLists.HaveChampionship (sch) then
        begin
          MessageDlg (Language ['ViewResults.CannotDeleteChamp'],mtInformation,[mbOk],0);
          exit;
        end;}
      if MessageDlg (Language ['ViewResults.DeleteChampPrompt'],mtConfirmation,[mbYes,mbNo],0)<> idYes then
        exit;
      if sch.ResultsCount> 0 then
        begin
          MessageDlg (Language ['ViewResults.ResultsInChamp'],mtInformation,[mbOk],0);
          exit;
        end;
      yn:= cn.Parent;
      cn.Free;
      sch.Free;
      if yn.Count= 0 then
        yn.Free;
    end;
    2: begin
      // ������� ����������
      en:= TreeView1.Selected;
      sev:= en.Data;
{      if fData.StartLists.HaveEvent (sev) then
        begin
          MessageDlg (Language ['ViewResults.CannotDeleteEvent'],mtInformation,[mbOk],0);
          exit;
        end;}
      if MessageDlg (Language ['ViewResults.DeleteEventPrompt'],mtConfirmation,[mbYes,mbNo],0)<> idYes then
        exit;
      if sev.ResultsCount> 0 then
        begin
          MessageDlg (Language ['ViewResults.ResultsInEvent'],mtInformation,[mbOk],0);
          exit;
        end;
      if fCurrentEvent= sev then
        begin
          fCurrentEvent:= nil;
          SetLength (fCurrentEventResults,0);
          lbResults.Clear;
          UpdateInfoPanel;
        end;
      cn:= en.Parent;
      sch:= cn.Data;
      en.Free;
      sev.Free;
      UpdateNodeCaption (cn);
      yn:= cn.Parent;
      y:= integer (yn.Data);
      y1:= sch.Year;
      if y<> y1 then
        begin
          yn1:= FindYearNode (y1);
          if yn1= nil then
            begin
              yn1:= TreeView1.Items.Add (nil,'');
              yn1.Data:= pointer (y1);
              UpdateNodeCaption (yn1);
            end;
          cn.MoveTo (yn1,naAddChild);
          TreeView1.Selected:= cn;
          if yn.Count= 0 then
            yn.Free;
        end;
    end;
  end;
end;

procedure TViewForm.DeleteResults;
var
  res: TResultItem;
  i,j: integer;
  ti,idx: integer;
begin
  if lbResults.SelCount< 1 then
    exit;
  if MessageDlg (Language ['DeleteResultPrompt'],mtConfirmation,[mbYes,mbNo],0)<> idYes then
    exit;
  ti:= lbResults.TopIndex;
  idx:= lbResults.ItemIndex;
  i:= 0;
  while i< Length (fCurrentEventResults) do
    begin
      if lbResults.Selected [i] then
        begin
          res:= fCurrentEventResults [i];
          res.Free;
          for j:= i to Length (fCurrentEventResults)-2 do
            fCurrentEventResults [j]:= fCurrentEventResults [j+1];
          SetLength (fCurrentEventResults,Length (fCurrentEventResults)-1);
          lbResults.Items.Delete (i);
        end
      else
        inc (i);
    end;
  if idx>= lbResults.Count then
    lbResults.ItemIndex:= lbResults.Count-1
  else
    begin
      lbResults.ItemIndex:= idx;
      lbResults.TopIndex:= ti;
    end;
end;

destructor TViewForm.Destroy;
begin
  SetLength (fCurrentEventResults,0);
  fCurrentEventResults:= nil;
  inherited;
end;

procedure TViewForm.DoClose(var Action: TCloseAction);
begin
	lbResults.Clear;
	Action:= caFree;
  SaveHeaderControlToRegistry ('ViewResultsHC',HeaderControl1);
  SaveValueToRegistry ('ViewResultsSplitter',TreeView1.Width);
  SaveValueToRegistry ('VRWidth',Width);
  SaveValueToRegistry ('VRHeight',Height);
  SaveValueToRegistry ('VRLeft',Left);
  SaveValueToRegistry ('VRTop',Top);
end;

function TViewForm.EditChampionship(AChampionship: TShootingChampionshipItem): boolean;
var
  scd: TShootingChampionshipDetails;
begin
  scd:= TShootingChampionshipDetails.Create (self);
  scd.SetData (fData);
  scd.SetChampionship (AChampionship);
  if scd.Execute then
    begin
      AChampionship.SetChampionship (scd.Championship,scd.ChampionshipName);
      AChampionship.Country:= scd.Country;
      AChampionship.Town:= scd.Town;
      fData.ResetRatings;
      Result:= true;
    end
  else
    Result:= false;
  scd.Free;
end;

function TViewForm.EditEvent(AEvent: TShootingEventItem): boolean;
var
  sed: TShootingEventDetails;
begin
  sed:= TShootingEventDetails.Create (self);
  sed.SetData (fData);
  sed.SetShootingEvent (AEvent);
  if sed.Execute then
    begin
      AEvent.Date:= sed.Date;
      AEvent.SetEvent (sed.Event,sed.ShortName,sed.EventName);
      AEvent.Town:= sed.Town;
      Result:= true;
    end
  else
    Result:= false;
  sed.Free;
end;

procedure TViewForm.EditNode;
var
  sev: TShootingEventItem;
  sn: TTreeNode;
  sch: TShootingChampionshipItem;
  yn,yn1,cn: TTreeNode;
  year: integer;
begin
  if TreeView1.Selected= nil then
    exit;
  case TreeView1.Selected.Level of
    0: {};
    1: begin
      // ����������� ������������
      sn:= TreeView1.Selected;
      sch:= sn.Data;
      if EditChampionship (sch) then
        begin
          UpdateNodeCaption (sn);
          UpdateInfoPanel;
        end;
    end;
    2: begin
      // ����������� ����������
      sn:= TreeView1.Selected;
      sev:= sn.Data;
      if EditEvent (sev) then
        begin
          UpdateNodeCaption (sn);
          cn:= sn.Parent;
          sch:= cn.Data;
          year:= sch.Year;
          yn:= cn.Parent;
          if year<> integer (yn.Data) then
            begin
              yn1:= FindYearNode (year);
              if yn1= nil then
                begin
                  yn1:= TreeView1.Items.Add (nil,'');
                  yn1.Data:= pointer (year);
                  UpdateNodeCaption (yn1);
                end;
              cn.MoveTo (yn1,naAddChild);
              cn.Data:= nil;
              cn.Data:= sch;
              if yn.Count= 0 then
                yn.Free;
              TreeView1.Selected:= sn;
            end;
          UpdateNodeCaption (cn);
          UpdateInfoPanel;
        end;
    end;
  end;
end;

procedure TViewForm.EnterResults(ANode: TTreeNode);
var
  sch: TShootingChampionshipItem;
  erf: TEnterResultsForm;
  year: integer;
  yn,en: TTreeNode;
  i: integer;
  sev: TShootingEventItem;
begin
  if (ANode= nil) or (ANode.Level<> 1) or (ANode.Data= nil) then
    exit;
  sch:= ANode.Data;
  yn:= ANode.Parent;
  year:= integer (yn.Data);
  erf:= TEnterResultsForm.Create (self);
  erf.SetData (fData,sch,year);
  erf.Execute;
  erf.Free;
  UpdateNodeCaption (ANode);
  ANode.DeleteChildren;
  for i:= 0 to sch.Events.Count-1 do
    begin
      sev:= sch.Events [i];
      en:= TreeView1.Items.AddChild (ANode,'');
      en.Data:= sev;
      UpdateNodeCaption (en);
    end;
  ANode.Data:= nil;
  ANode.Data:= sch;
end;

function TViewForm.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TViewForm.lbResultsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_LEFT: begin
      Key:= 0;
      TreeView1.SetFocus;
    end;
    VK_RIGHT: begin
      Key:= 0;
    end;
    VK_DELETE: begin
      Key:= 0;
      DeleteResults;
    end;
  end;
end;

procedure TViewForm.lbResultsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  idx: integer;
  p: TPoint;
begin
  if fCurrentEvent= nil then
    exit;
  idx:= lbResults.ItemAtPos (Point (X,Y),true);
  if idx< 0 then
    exit;
  if Button= mbRight then
    begin
      p:= lbResults.ClientToScreen (Point (X,Y));
      pmResult.Popup (p.X,p.Y);
    end;
end;

procedure TViewForm.lbResultsMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  idx: integer;
  res: TResultItem;
begin
  if fCurrentEvent= nil then
    exit;
  idx:= lbResults.ItemAtPos (Point (x,y),true);
  if idx>= 0 then
    begin
      res:= fCurrentEventResults [idx];
      lbResults.ShowHint:= false;
      lbResults.Hint:= res.Shooter.Group.Name;
      lbResults.ShowHint:= true;
    end
  else
    begin
      lbResults.Hint:= '';
      lbResults.ShowHint:= false;
    end;
end;

procedure TViewForm.HeaderControl1Resize(Sender: TObject);
begin
  with HeaderControl1 do
    Sections [Sections.Count-1].Width:= ClientWidth-Sections [Sections.Count-1].Left;
end;

function TViewForm.FindYearNode(const AYear: integer): TTreeNode;
var
  n: TTreeNode;
begin
  Result:= nil;
  n:= TreeView1.Items.GetFirstNode;
  while (n<> nil) do
    begin
      if integer (n.Data)= AYear then
        begin
          Result:= n;
          exit;
        end;
      n:= n.getNextSibling;
    end;
end;

procedure TViewForm.TreeView1Change(Sender: TObject; Node: TTreeNode);
var
  n: TTreeNode;
begin
  n:= TreeView1.Selected;
  if n.Level= 2 then
    begin
      SetEvent (n);
    end;
end;

procedure TViewForm.TreeView1Compare(Sender: TObject; Node1,Node2: TTreeNode; Data: Integer; var Compare: Integer);
var
  d1,d2: TDateTime;
begin
  if (Node1.Data= nil) or (Node2.Data= nil) then
    Compare:= 0
  else
    begin
      case Node1.Level of
        0: begin
          if integer (Node1.Data)< integer (Node2.Data) then
            Compare:= -1
          else if integer (Node1.Data)> integer (Node2.Data) then
            Compare:= 1
          else
            Compare:= 0;
        end;
        1: begin
          d1:= TShootingChampionshipItem (Node1.Data).From;
          d2:= TShootingChampionshipItem (Node2.Data).From;
          Compare:= CompareDate (d1,d2);
        end;
        2: begin
          d1:= TShootingEventItem (Node1.Data).Date;
          d2:= TShootingEventItem (Node2.Data).Date;
          Compare:= CompareDate (d1,d2);
        end;
      end;
    end;
end;

procedure TViewForm.TreeView1DragDrop(Sender, Source: TObject; X,Y: Integer);
var
  sn,dn,yn,n,yn1: TTreeNode;
  sev1,sev2: TShootingEventItem;
  sch2: TShootingChampionshipItem;
  i,j,k,ti: integer;
  gr: TGroupItem;
  sh: TShooterItem;
  res: TResultItem;
  year: integer;
begin
  dn:= TreeView1.GetNodeAt (X,Y);
  if Source= TreeView1 then
    begin
      sn:= TreeView1.Selected;
      if (sn= nil) or (sn.Data= nil) or (sn.Level= 0) then
        exit;
      if (dn= nil) or (dn= sn) or (sn.Parent= dn) or (dn.Level= 0) then
        exit;
      if (sn.Level= 1) and (dn.Level> 1) then
        exit;
      if (sn.Level= 2) and (dn.Level= 1) then
        begin
          // ���������� ���������� ������� � ������ ������������
          n:= sn.Parent;
          sev1:= TShootingEventItem (sn.Data);
          sch2:= TShootingChampionshipItem (dn.Data);
          sev1.MoveTo (sch2);
          sn.MoveTo (dn,naAddChild);
          sn.Data:= nil;
          sn.Data:= sev1;
          yn:= dn.Parent;
          year:= sch2.Year;
          if year<> integer (yn.Data) then
            begin
              yn1:= FindYearNode (year);
              if yn1= nil then
                begin
                  yn1:= TreeView1.Items.Add (nil,'');
                  yn1.Data:= pointer (year);
                  UpdateNodeCaption (yn1);
                end;
              dn.MoveTo (yn1,naAddChild);
            end;
          dn.Data:= nil;
          dn.Data:= sch2;
          UpdateNodeCaption (n);
          UpdateNodeCaption (dn);
          UpdateInfoPanel;
        end
      else if (sn.Level= 2) and (dn.Level= 2) then
        begin
          // ���������� ���������� �� ������ ���������� � ������
          sev1:= TShootingEventItem (sn.Data);
          sev2:= TShootingEventItem (dn.Data);
          for i:= 0 to Data.Groups.Count-1 do
            begin
              gr:= Data.Groups [i];
              for j:= 0 to gr.Shooters.Count-1 do
                begin
                  sh:= gr.Shooters [j];
                  for k:= 0 to sh.Results.Count-1 do
                    begin
                      res:= sh.Results [k];
                      if res.ShootingEvent= sev1 then
                        res.ShootingEvent:= sev2;
                    end;
                end;
            end;
          UpdateNodeCaption (sn);
          UpdateNodeCaption (dn);
          TreeView1.Selected:= dn;
          UpdateInfoPanel;
        end
      else if (sn.Level= 1) and (dn.Level= 1) then
        begin
          // ���������� ���������� � ������ ������������
    //      sch1:= TShootingChampionshipItem (sn.Data);
          sch2:= TShootingChampionshipItem (dn.Data);
          while sn.Count> 0 do
            begin
              n:= sn.Item [0];
              sev1:= TShootingEventItem (n.Data);
              sev1.MoveTo (sch2);
              n.MoveTo (dn,naAddChild);
            end;
          UpdateNodeCaption (sn);
          UpdateNodeCaption (dn);
          UpdateInfoPanel;
        end;
    end
  else if Source= lbResults then
    begin
      if lbResults.SelCount< 1 then
        exit;
      if (dn= nil) or (dn.Level< 2) then
        exit;
      sev2:= dn.Data;
      k:= lbResults.ItemIndex;
      ti:= lbResults.TopIndex;
      i:= 0;
      while i< Length (fCurrentEventResults) do
        begin
          if lbResults.Selected [i] then
            begin
              res:= fCurrentEventResults [i];
              res.ShootingEvent:= sev2;
              for j:= i to Length (fCurrentEventResults)-2 do
                fCurrentEventResults [j]:= fCurrentEventResults [j+1];
              SetLength (fCurrentEventResults,Length (fCurrentEventResults)-1);
              lbResults.Items.Delete (i);
            end
          else
            inc (i);
        end;
      if k>= lbResults.Count then
        lbResults.ItemIndex:= lbResults.Count-1
      else
        begin
          lbResults.TopIndex:= ti;
          lbResults.ItemIndex:= k;
        end;
      UpdateNodeCaption (dn);
      if fCurrentEventNode<> nil then
        UpdateNodeCaption (fCurrentEventNode);
    end;
end;

procedure TViewForm.TreeView1DragOver(Sender, Source: TObject; X,Y: Integer; State: TDragState; var Accept: Boolean);
var
  sn,dn: TTreeNode;
  sev1,sev2: TShootingEventItem;
//  sch1,sch2: TShootingChampionshipItem;
begin
  Accept:= false;
  dn:= TreeView1.GetNodeAt (X,Y);
  if Source= TreeView1 then
    begin
      sn:= TreeView1.Selected;
      if (sn= nil) or (sn.Data= nil) or (sn.Level= 0) then
        exit;
      if (dn= nil) or (dn= sn) or (sn.Parent= dn) or (dn.Level= 0) then
        exit;
      if (sn.Level= 2) and (dn.Level= 1) then
        begin
          // ���������� ���������� ������� � ������ ������������
          Accept:= true;
        end
      else if (sn.Level= 2) and (dn.Level= 2) then
        begin
          // ���������� ���������� �� ������ ���������� � ������
          // ���������, ����� �� ���������� ��� ���
          sev1:= TShootingEventItem (sn.Data);
          sev2:= TShootingEventItem (dn.Data);
          if sev1.Event= sev2.Event then
            Accept:= true;
        end
      else if (sn.Level= 1) and (dn.Level= 1) then
        begin
          // ���������� ���������� � ������ ������������
          Accept:= true;
        end;
    end
  else if Source= lbResults then
    begin
      if lbResults.ItemIndex< 0 then
        exit;
      if (dn= nil) or (dn.Level< 2) then
        exit;
      sev2:= dn.Data;
      if (fCurrentEvent<> sev2) and (fCurrentEvent.Event= sev2.Event) then
        Accept:= true;
    end;
end;

procedure TViewForm.TreeView1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RIGHT: begin
      if (TreeView1.Selected<> nil) and (TreeView1.Selected.Level= 2) then
        begin
          Key:= 0;
          lbResults.SetFocus;
        end;
    end;
    VK_INSERT: begin
      Key:= 0;
      if (TreeView1.Selected<> nil) and (TreeView1.Selected.Level= 0) then
        begin
          InsertNewChampionship;
        end;
    end;
    VK_DELETE: begin
      Key:= 0;
      DeleteNode;
    end;
    VK_F4: if Shift= [] then begin
      Key:= 0;
      EditNode;
    end;
    VK_F6: if Shift= [] then begin
      Key:= 0;
      if (TreeView1.Selected<> nil) and (TreeView1.Selected.Level= 1) then
        EnterResults (TreeView1.Selected);
    end;
  end;
end;

procedure TViewForm.TreeView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
  tn: TTreeNode;
begin
  case Button of
    mbRight: begin
      tn:= TreeView1.GetNodeAt (X,Y);
      if tn<> nil then
        begin
          TreeView1.Selected:= tn;
          if tn.Level= 1 then
            begin
              p:= TreeView1.ClientToScreen (Point (X,Y));
              pmChamp.Popup (p.X,p.Y);
            end;
        end;
    end;
  end;
end;

procedure TViewForm.UpdateFonts;
var
  i: integer;
  w: integer;
begin
  Font:= SysFonts.MessageFont;
  lbResults.Canvas.Font:= lbResults.Font;
  i:= lbResults.Canvas.TextHeight ('Mg');
	lbResults.ItemHeight:= i * 2 + 8;
  y1:= 4;
  y2:= i+4;
  w:= lChamp1.Width;
  i:= lEvent1.Width;

  if i> w then
    w:= i;
  i:= lDate.Width;
  if i> w then
    w:= i;
  lChamp.Font:= Font;
  lChamp.Font.Style:= [fsBold];
  lDate.Font:= Font;
  lDate.Font.Style:= [fsBold];
  lEvent.Font:= Font;
  lEvent.Font.Style:= [fsBold];
  lChamp1.Left:= w+8-lChamp1.Width;
  lEvent1.Left:= w+8-lEvent1.Width;
  lDate1.Left:= w+8-lDate1.Width;
  lChamp.Left:= w+16;
  lEvent.Left:= w+16;
  lDate.Left:= w+16;
  lChamp1.Top:= 8;
  lChamp.Top:= lChamp1.Top+lChamp1.Height-lChamp.Height;
  lEvent1.Top:= lChamp1.Top+lChamp1.Height+0;
  lEvent.Top:= lEvent1.Top+lEvent1.Height-lEvent.Height;
  lDate1.Top:= lEvent1.Top+lEvent1.Height+0;
  lDate.Top:= lDate1.Top+lDate1.Height-lDate.Height;
  pnlInfo.ClientHeight:= lDate1.Top+lDate1.Height+8;
  StatusBar1.Font:= SysFonts.StatusFont;
  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
end;

procedure TViewForm.UpdateInfoPanel;
begin
  if fCurrentEvent<> nil then
    begin
      if fCurrentEvent.Event<> nil then
        lEvent.Caption:= fCurrentEvent.Event.ShortName+' - '+fCurrentEvent.Event.Name
      else
        lEvent.Caption:= fCurrentEvent.EventName;
      lEvent.Top:= lEvent1.Top+lEvent1.Height-lEvent.Height;
      lDate.Caption:= _DateToStr (fCurrentEvent.Date);
      lDate.Top:= lDate1.Top+lDate1.Height-lDate.Height;
      lChamp.Caption:= fCurrentEvent.Championship.ChampionshipName;
      lChamp.Top:= lChamp1.Top+lChamp1.Height-lChamp.Height;
    end;
end;

procedure TViewForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TViewForm.UpdateNodeCaption(N: TTreeNode);
var
  y: integer;
  sch: TShootingChampionshipItem;
  sev: TShootingEventItem;
  st: string;
begin
  case N.Level of
    0: begin
      y:= integer (N.Data);
      N.Text:= IntToStr (y);
    end;
    1: begin
      sch:= N.Data;
      st:= sch.ChampionshipName;
      if (sch.From<> 0) and (sch.Till<> 0) then
        begin
          if sch.From< sch.Till then
            st:= st+' ('+_DatesFromTillStr (sch.From,sch.Till)+')'
          else
            st:= st+' ('+_DateToStr (sch.From)+')';
        end;
      N.Text:= st;
    end;
    2: begin
      sev:= N.Data;
      if sev.Event<> nil then
        st:= sev.Event.ShortName{+' ('+e.Event.Name+')'}
      else
        st:= sev.EventName;
      st:= st+' ('+IntToStr (sev.ResultsCount)+')';
      N.Text:= st;
    end;
  end;
end;

procedure TViewForm.lbResultsDrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);
var
  res: TResultItem;
  s: THeaderSection;
  r: TRect;
  x: integer;
begin
  with lbResults.Canvas do
    begin
      if (odSelected in State) then
        begin
          if not lbResults.Focused then
            Brush.Color:= clGrayText;
        end;

      FillRect (ARect);
      if (fCurrentEvent= nil) or (Index< 0) or (Index>= Length (fCurrentEventResults)) then
        exit;
      res:= fCurrentEventResults [Index];

      Brush.Style:= bsClear;

      s:= HeaderControl1.Sections [0];
      r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
      Font.Style:= [fsBold];
      x:= r.Left;
      TextRect (r,x,r.Top+y1,res.Shooter.Surname);
      x:= x+TextWidth (res.Shooter.Surname);
      Font.Style:= [];
      if (odSelected in State) or (odHotLight in State) then
        TextRect (r,x,r.Top+y1,' ('+res.Shooter.Group.Name+')');
      TextRect (r,r.Left,r.Top+y2,res.Shooter.Name);

      s:= HeaderControl1.Sections [1];
      r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
      Font.Style:= [fsBold];
      TextRect (r,r.Left,r.Top+y1,res.RankStr);

      s:= HeaderControl1.Sections [2];
      r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
      Font.Style:= [];
      TextRect (r,r.Left,r.Top+y1,res.CompetitionStr);
      TextRect (r,r.Left,r.Top+y2,res.FinalStr);

      s:= HeaderControl1.Sections [3];
      r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
      Font.Style:= [fsBold];
      TextRect (r,r.Left,r.Top+y1,res.TotalStr);

      s:= HeaderControl1.Sections [4];
      r:= Rect (ARect.Left+s.Left+2,ARect.Top,ARect.Left+s.Right-2,ARect.Bottom);
      Font.Style:= [fsBold];
      TextRect (r,r.Left,r.Top+y1,res.RatingStr);
    end;
end;

procedure TViewForm.SetEvent (N: TTreeNode);
var
  i,j,k,idx: integer;
  gr: TGroupItem;
  sh: TShooterItem;
  res: TResultItem;
begin
  fCurrentEvent:= N.Data;
  fCurrentEventNode:= N;
  UpdateInfoPanel;
  SetLength (fCurrentEventResults,0);
  idx:= 0;
  for i:= 0 to fData.Groups.Count-1 do
    begin
      gr:= fData.Groups [i];
      for j:= 0 to gr.Shooters.Count-1 do
        begin
          sh:= gr.Shooters [j];
          for k:= 0 to sh.Results.Count-1 do
            begin
              res:= sh.Results [k];
              if res.ShootingEvent= fCurrentEvent then
                begin
                  SetLength (fCurrentEventResults,idx+1);
                  fCurrentEventResults [idx]:= res;
                  inc (idx);
                end;
            end;
        end;
    end;
  // ��������� ����������
  for i:= 0 to Length (fCurrentEventResults)-2 do
    begin
      idx:= i;
      res:= fCurrentEventResults [i];
      for j:= i+1 to Length (fCurrentEventResults)-1 do
        begin
          if fCurrentEventResults [j].CompareTo (res,rsoRank)> 0 then
            begin
              idx:= j;
              res:= fCurrentEventResults [j];
            end;
        end;
      if idx<> i then
        begin
          res:= fCurrentEventResults [idx];
          fCurrentEventResults [idx]:= fCurrentEventResults [i];
          fCurrentEventResults [i]:= res;
        end;
    end;
  lbResults.Items.BeginUpdate;
  lbResults.Clear;
  for i:= 0 to Length (fCurrentEventResults)-1 do
    begin
      lbResults.Items.Add (fCurrentEventResults [i].Shooter.SurnameAndName);
    end;
  lbResults.Items.EndUpdate;
  if lbResults.Count> 0 then
    lbResults.ItemIndex:= 0;
end;

{ TEventReport }

procedure TEventReport.Add(AResult: TResultItem);
var
  idx: integer;
begin
  idx:= Length (fResults);
  SetLength (fResults,idx+1);
  fResults [idx]:= AResult;
  RowCount:= Length (fResults);
end;

constructor TEventReport.Create (AEvent: TShootingEventItem);
begin
  inherited Create;
  fShootingEvent:= AEvent;
  SetLength (fResults,0);
  PrintTableHeader:= true;
  DrawHeaderGrid:= true;
  FillHeader:= false;
end;

destructor TEventReport.Destroy;
begin
  SetLength (fResults,0);
  fResults:= nil;
  inherited;
end;

procedure TEventReport.Precalc;
begin
  // TODO: ������� ������� ������� � ��������� �����
//  Columns.Add ();
  inherited Precalc;
end;

procedure TEventReport.PrintFooter(APageIndex: integer; ACanvas: TCanvas; ARect: TRect);
var
  st: string;
begin
  with ACanvas do
    begin
      MoveTo (ARect.Left,ARect.Top);
      LineTo (ARect.Right,ARect.Top);
      st:= format (PAGE_NO,[APageIndex]);
      TextOut (ARect.Right-TextWidth (st),ARect.Top+1,st);
      st:= format (PAGE_FOOTER,[VERSION_INFO_STR]);
      TextOut (ARect.Left,ARect.Top+1,st);
    end;
end;

end.


