unit wbdviewer_main;

interface

uses
  Winapi.Windows,Winapi.Messages,Vcl.Forms,MyListBoxes,System.SysUtils,SysFont,Vcl.Graphics,
  Data, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Controls, System.Classes, ToolWin,
  ListBox_Shooters;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    tbShooters: TToolButton;
    tbResults: TToolButton;
    pnlResults: TPanel;
    lChamp1: TLabel;
    lChamp: TLabel;
    lEvent: TLabel;
    lEvent1: TLabel;
    lDate1: TLabel;
    lDate: TLabel;
    tvResults: TTreeView;
    Splitter2: TSplitter;
    pnlShooters: TPanel;
    lbGroups: TListBox;
    Splitter1: TSplitter;
    cbEvents: TComboBox;
    HeaderControl1: THeaderControl;
    procedure lbGroupsClick(Sender: TObject);
    procedure cbEventsChange(Sender: TObject);
    procedure tbResultsClick(Sender: TObject);
    procedure tbShootersClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Splitter2Moved(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
  private
    { Private declarations }
    lbShooters: TShootersListBox;
    lbResults: THeadedListBox;
    fInfoHeight: integer;
    fInfoWidth: integer;
    fData: TData;
    fActiveEvent: TEventItem;
    fGroupEvents: TEventsFilter;
    procedure Arrange;
    procedure UpdateFonts;
    procedure DataLoaded;
    procedure GroupOpened;
    procedure ReloadShooters;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$R mainwindow.res}

procedure TForm1.Arrange;
var
  x: integer;
begin
  // tsMain
  lbGroups.Width:= Splitter1.Left-lbGroups.Left;
  lbGroups.Height:= ClientHeight-lbGroups.Top*2;
  lbShooters.Left:= Splitter1.Left+Splitter1.Width;
  lbShooters.Width:= pnlShooters.ClientWidth-pnlShooters.BorderWidth-lbShooters.Left;
  lbShooters.Height:= pnlShooters.ClientHeight-pnlShooters.BorderWidth-lbShooters.Top;
  cbEvents.Left:= lbShooters.Left;
  cbEvents.Width:= lbShooters.Width;

  // tsResults
  x:= Splitter2.Left+Splitter2.Width;
  tvResults.Width:= Splitter2.Left-tvResults.Left;
  lbResults.Left:= x;
  lbResults.Width:= pnlResults.ClientWidth-4-lbResults.Left;
  lbResults.Top:= fInfoHeight;
  lbResults.Height:= pnlResults.ClientHeight-4-lbResults.Top;

  lChamp1.Left:= x+fInfoWidth+8-lChamp1.Width;
  lEvent1.Left:= x+fInfoWidth+8-lEvent1.Width;
  lDate1.Left:= x+fInfoWidth+8-lDate1.Width;
  lChamp.Left:= x+fInfoWidth+16;
  lEvent.Left:= x+fInfoWidth+16;
  lDate.Left:= x+fInfoWidth+16;
end;

procedure TForm1.cbEventsChange(Sender: TObject);
begin
  fActiveEvent:= fGroupEvents.Events [cbEvents.ItemIndex];
  ReloadShooters;
end;

procedure TForm1.DataLoaded;
var
  i: integer;
begin
  lbGroups.Clear;
  for i:= 0 to fData.Groups.Count-1 do
    lbGroups.Items.Add (fData.Groups [i].Name);
  lbShooters.Clear;
  if fData.Groups.Count> 0 then
    begin
      lbGroups.ItemIndex:= 0;
      GroupOpened;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  sec: THeadedListBoxSection;
begin
  pnlShooters.Align:= alClient;
  cbEvents.Top:= pnlShooters.BorderWidth+lbGroups.Top;

  lbShooters:= TShootersListBox.Create (pnlShooters);


//	fShootersLb.Align:= alClient;
	lbShooters.ParentFont:= true;
//	fShootersLb.Header:= HeaderControl1;
	lbShooters.Color:= pnlShooters.Color;
  lbShooters.ParentCtl3D:= false;
  lbShooters.Ctl3D:= true;
  lbShooters.BorderWidth:= 0;
  lbShooters.BorderStyle:= bsSingle;
//	fShootersLb.OnDblClick:= OnShooterDblClick;
//  fShootersLb.OnKeyDown:= OnShootersKeyDown;
//	fShootersLb.PopupMenu:= pmPopup;
//  fShootersLb.OnChangeMark:= OnChangeMark;
  lbShooters.Parent:= pnlShooters;

{
  lbShooters:= THeadedListBox.Create (pnlShooters);
  lbShooters.Parent:= pnlShooters;
  lbShooters.ItemExtraHeight:= 6;
  lbShooters.SectionTextLeft:= 2;
  lbShooters.Constraints.MinWidth:= 100;
}

  Constraints.MinWidth:= 480;

//  pnlResults:= TMyPanel.Create (self);
//  pnlResults.Parent:= Self;

  lbResults:= THeadedListBox.Create (pnlResults);
  lbResults.Parent:= pnlResults;
  lbResults.ItemExtraHeight:= 6;
  lbResults.SectionTextLeft:= 2;

  pnlResults.Align:= alClient;


  UpdateFonts;

  Arrange;

{  sec:= lbShooters.AddSection ('����');
  sec.MinWidth:= 48;
  sec.MaxWidth:= 48;
  sec:= lbShooters.AddSection ('');
  sec.MinWidth:= 32;
  sec.MaxWidth:= 32;
  lbShooters.AddSection ('�������, ���');
  lbShooters.AddSection ('��� ��������');
  lbShooters.AddSection ('������������');
  lbShooters.AddSection ('�������');
  lbShooters.AddSection ('�������');}
  lbResults.AddSection ('�������, ���');
  lbResults.AddSection ('�����');
  lbResults.AddSection ('���������');
  lbResults.AddSection ('�����');
  lbResults.AddSection ('�����');
  lbResults.AddSection ('�������');

  fGroupEvents:= TEventsFilter.Create;
  fActiveEvent:= nil;
  if ParamCount> 0 then
    begin
      fData:= TData.Create;
      fData.LoadFromFile (ParamStr (1));
      DataLoaded;
    end
  else
    fData:= nil;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  fActiveEvent:= nil;
  FreeAndNil (fGroupEvents);
  if fData<> nil then
    FreeAndNil (fData);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Arrange;
end;

procedure TForm1.GroupOpened;
var
  g: TGroupItem;
  i: integer;
begin
  g:= fData.Groups [lbGroups.ItemIndex];
  fGroupEvents.Clear;
  fGroupEvents.Add (g);
  cbEvents.Clear;
  for i:= 0 to fGroupEvents.Count-1 do
    cbEvents.Items.Add (fGroupEvents.Events [i].ShortName);
  if fGroupEvents.Count> 0 then
    begin
      cbEvents.ItemIndex:= 0;
      fActiveEvent:= fGroupEvents.Events [0];
    end;
  ReloadShooters;
end;

procedure TForm1.lbGroupsClick(Sender: TObject);
begin
  GroupOpened;
end;

procedure TForm1.ReloadShooters;
var
  g: TGroupItem;
  i: integer;
  sh: TShooterItem;
  r: integer;
  s: string;
begin
  g:= fData.Groups [lbGroups.ItemIndex];
  lbShooters.Clear;
  lbShooters.Add (g.Shooters);
  lbShooters.Event:= fActiveEvent;

{
  lbShooters.ListBox.Clear;
  for i:= 0 to g.Shooters.Count-1 do
    begin
      sh:= g.Shooters [i];
      r:= sh.Results.TotalRating (fActiveEvent);
      if r> 0 then
        s:= IntToStr (r)
      else
        s:= '';
  lbShooters.ListBox.Items.Add (#9#9+sh.SurnameAndName+#9+sh.BirthFullStr+#9+sh.QualificationName+#9+sh.RegionsAbbr+#9+s);
    end;
}
end;

procedure TForm1.Splitter1CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  Accept:= (NewSize> lbGroups.Constraints.MinWidth) and (NewSize+Splitter1.Width+lbShooters.Constraints.MinWidth<= ClientWidth-pnlShooters.BorderWidth*2);
end;

procedure TForm1.Splitter1Moved(Sender: TObject);
begin
  Arrange;
end;

procedure TForm1.Splitter2Moved(Sender: TObject);
begin
  Arrange;
end;

procedure TForm1.tbResultsClick(Sender: TObject);
begin
  if not tbResults.Down then
    begin
      tbShooters.Down:= false;
      pnlShooters.Visible:= false;
      tbResults.Down:= true;
      pnlResults.Visible:= true;
    end;
end;

procedure TForm1.tbShootersClick(Sender: TObject);
begin
  if not tbShooters.Down then
    begin
      tbResults.Down:= false;
      pnlResults.Visible:= false;
      tbShooters.Down:= true;
      pnlShooters.Visible:= true;
    end;
end;

procedure TForm1.UpdateFonts;
var
  i: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbResults.Font:= Font;
  lbResults.ListBox.Font.Style:= [fsBold];
  lbShooters.Font:= Font;
  cbEvents.Font:= Font;
  cbEvents.Canvas.Font:= Font;
  ToolBar1.Font:= Font;
  ToolBar1.Canvas.Font:= Font;

  cbEvents.ItemHeight:= cbEvents.Canvas.TextHeight ('Mg')+6;
  lbShooters.Top:= cbEvents.Top+cbEvents.Height+8;

  lbGroups.Top:= ToolBar1.Top+ToolBar1.Height+4;

  fInfoWidth:= lChamp1.Width;
  i:= lEvent1.Width;
  if i> fInfoWidth then
    fInfoWidth:= i;
  i:= lDate.Width;
  if i> fInfoWidth then
    fInfoWidth:= i;
  lChamp.Font:= Font;
  lChamp.Font.Style:= [fsBold];
  lDate.Font:= Font;
  lDate.Font.Style:= [fsBold];
  lEvent.Font:= Font;
  lEvent.Font.Style:= [fsBold];
  lChamp1.Top:= 8;
  lChamp.Top:= lChamp1.Top+lChamp1.Height-lChamp.Height;
  lEvent1.Top:= lChamp1.Top+lChamp1.Height+0;
  lEvent.Top:= lEvent1.Top+lEvent1.Height-lEvent.Height;
  lDate1.Top:= lEvent1.Top+lEvent1.Height+0;
  lDate.Top:= lDate1.Top+lDate1.Height-lDate.Height;
  fInfoHeight:= lDate1.Top+lDate1.Height+8;
end;

end.

