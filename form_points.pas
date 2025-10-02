{$a-}
unit form_points;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Grids, Vcl.StdCtrls,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language, Vcl.ComCtrls;

type
  TPointsSetupDialog = class(TForm)
    sgPoints: TStringGrid;
    btnClose: TButton;
    btnLoad: TButton;
    btnSave: TButton;
    SavePointsDialog: TSaveDialog;
    LoadPointsDialog: TOpenDialog;
    btnAdd: TButton;
    btnDelete: TButton;
    TabControl1: TTabControl;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TabControl1Change(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure sgPointsKeyPress(Sender: TObject; var Key: Char);
    procedure sgPointsSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
    procedure FormCreate(Sender: TObject);
    procedure sgPointsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
  private
    { Private declarations }
    fPTeamsPoints,fRegionsPoints,fDistrictsPoints,fRTeamsPoints: TStartListPoints;
    fCurrentPoints: TStartListPoints;
//    procedure set_PTeamsPoints(const Value: TStartListPoints);
    procedure DeletePoints (Index: integer);
    procedure InsertPoints (Index: integer);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property PTeamsPoints: TStartListPoints read fPTeamsPoints;
    property RegionsPoints: TStartListPoints read fRegionsPoints;
    property DistrictsPoints: TStartListPoints read fDistrictsPoints;
    property RTeamsPoints: TStartListPoints read fRTeamsPoints;
    procedure SetEvent (AEvent: TStartListEventItem);
    function Execute: boolean;
    procedure UpdateData;
  end;

implementation

{$R *.dfm}

{ TPointsSetupDialog }

function TPointsSetupDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

{procedure TPointsSetupDialog.set_Points(const Value: TStartListPoints);
begin
  fPoints.Assign (Value);
  UpdateData;
end;}

procedure TPointsSetupDialog.UpdateData;
var
  i: integer;
begin
  sgPoints.RowCount:= fCurrentPoints.Count+2;
  for i:= 1 to fCurrentPoints.Count do
    begin
      sgPoints.Cells [0,i]:= IntToStr (i);
      sgPoints.Cells [1,i]:= IntToStr (fCurrentPoints [i-1]);
    end;
  sgPoints.Cells [0,fCurrentPoints.Count+1]:= IntToStr (fCurrentPoints.Count+1);
  sgPoints.Cells [1,fCurrentPoints.Count+1]:= '';
  sgPoints.Row:= 1;
end;

procedure TPointsSetupDialog.UpdateFonts;
var
  bh: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnAdd.ClientHeight:= bh;
  btnAdd.ClientWidth:= Canvas.TextWidth (btnAdd.Caption)+32;
  btnDelete.ClientHeight:= bh;
  btnDelete.ClientWidth:= Canvas.TextWidth (btnDelete.Caption)+32;
  btnDelete.Left:= btnAdd.Left+btnAdd.Width+8;
  btnLoad.ClientHeight:= bh;
  btnLoad.ClientWidth:= Canvas.TextWidth (btnLoad.Caption)+32;
  btnLoad.Left:= btnDelete.Left+btnDelete.Width+24;
  btnSave.ClientHeight:= bh;
  btnSave.ClientWidth:= Canvas.TextWidth (btnSave.Caption)+32;
  btnSave.Left:= btnLoad.Left+btnLoad.Width+8;
  btnClose.ClientHeight:= bh;
  btnClose.ClientWidth:= Canvas.TextWidth (btnAdd.Caption)+32;
  btnClose.Left:= btnSave.Left+btnSave.Width+24;
  ClientWidth:= btnClose.Left+btnClose.Width;
  Constraints.MinWidth:= Width;
  TabControl1.Canvas.Font:= TabControl1.Font;
  TabControl1.TabHeight:= TabControl1.Canvas.TextHeight ('Mg')+6;
  sgPoints.Canvas.Font:= sgPoints.Font;
  sgPoints.DefaultRowHeight:= sgPoints.Canvas.TextHeight ('Mg')+6;
  Constraints.MinHeight:= Height-ClientHeight+sgPoints.Height-sgPoints.ClientHeight+
    (sgPoints.DefaultRowHeight+sgPoints.GridLineWidth)*10+8+btnClose.Height;
end;

procedure TPointsSetupDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
  TabControl1.Tabs.Text:= Language ['PointsSetupDialog.Tabs'];
  sgPoints.Cells [0,0]:= Language ['PointsSetupDialog.Ranks'];
  sgPoints.Cells [1,0]:= Language ['PointsSetupDialog.Points'];
end;

procedure TPointsSetupDialog.sgPointsKeyPress(Sender: TObject; var Key: Char);

  procedure SetCell;
  begin
    sgPoints.Cells [sgPoints.Col,sgPoints.Row]:= IntToStr (fCurrentPoints [sgPoints.Row-1]);
    if sgPoints.Row= sgPoints.RowCount-1 then
      begin
        sgPoints.RowCount:= sgPoints.RowCount+1;
        sgPoints.Cells [0,sgPoints.RowCount-1]:= IntToStr (sgPoints.RowCount-1);
      end;
    sgPoints.EditorMode:= false;
  end;

begin
  case Key of
    #13: begin
      if sgPoints.EditorMode then
        begin
          Key:= #0;
          SetCell;
          sgPoints.Row:= sgPoints.Row+1;
        end;
    end;
    #27: begin
      if sgPoints.EditorMode then
        begin
          Key:= #0;
          SetCell;
        end
      else
        begin
          Key:= #0;
          btnClose.Click;
        end;
    end;
  end;
end;

procedure TPointsSetupDialog.sgPointsSetEditText(Sender: TObject; ACol,ARow: Integer; const Value: String);
var
  v,i: integer;
begin
  val (Value,v,i);
  if i= 0 then
    fCurrentPoints [ARow-1]:= v;
end;

procedure TPointsSetupDialog.TabControl1Change(Sender: TObject);
begin
  case TabControl1.TabIndex of
    0: fCurrentPoints:= fRegionsPoints;
    1: fCurrentPoints:= fDistrictsPoints;
    2: fCurrentPoints:= fPTeamsPoints;
    3: fCurrentPoints:= fRTeamsPoints;
  end;
  UpdateData;
end;

procedure TPointsSetupDialog.FormCreate(Sender: TObject);
begin
  fPTeamsPoints:= TStartListPoints.Create;
  fRegionsPoints:= TStartListPoints.Create;
  fDistrictsPoints:= TStartListPoints.Create;
  fRTeamsPoints:= TStartListPoints.Create;
  fCurrentPoints:= fRegionsPoints;
  sgPoints.ColCount:= 2;
  sgPoints.FixedCols:= 1;
  sgPoints.RowCount:= 2;
  sgPoints.FixedRows:= 1;
  TabControl1.Left:= 0;
  TabControl1.Top:= 0;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TPointsSetupDialog.sgPointsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_DELETE: begin
      if (not sgPoints.EditorMode) and (sgPoints.Row<= fCurrentPoints.Count) then
        DeletePoints (sgPoints.Row-1);
    end;
    VK_INSERT: begin
      if (not sgPoints.EditorMode) and (sgPoints.Row<= fCurrentPoints.Count) then
        InsertPoints (sgPoints.Row-1);
    end;
  end;
end;

procedure TPointsSetupDialog.DeletePoints(Index: integer);
var
  i: integer;
begin
  fCurrentPoints.Delete (Index);
  for i:= Index to fCurrentPoints.Count-1 do
    sgPoints.Cells [1,i+1]:= IntToStr (fCurrentPoints [i]);
  sgPoints.Cells [1,fCurrentPoints.Count+1]:= '';
  sgPoints.RowCount:= sgPoints.RowCount-1;
end;

procedure TPointsSetupDialog.InsertPoints(Index: integer);
var
  i: integer;
begin
  fCurrentPoints.Insert (Index);
  for i:= Index to fCurrentPoints.Count-1 do
    sgPoints.Cells [1,i+1]:= IntToStr (fCurrentPoints [i]);
  sgPoints.RowCount:= sgPoints.RowCount+1;
  sgPoints.Cells [0,sgPoints.RowCount-1]:= IntToStr (sgPoints.RowCount-1);
end;

procedure TPointsSetupDialog.SetEvent(AEvent: TStartListEventItem);
begin
  fPTeamsPoints.Assign (AEvent.PTeamsPoints);
  fRegionsPoints.Assign (AEvent.RegionsPoints);
  fDistrictsPoints.Assign (AEvent.DistrictsPoints);
  fRTeamsPoints.Assign (AEvent.RTeamsPoints);
  fCurrentPoints:= fRegionsPoints;
  TabControl1.TabIndex:= 0;
  UpdateData;
end;

procedure TPointsSetupDialog.FormDestroy(Sender: TObject);
begin
  fPTeamsPoints.Free;
  fRTeamsPoints.Free;
  fRegionsPoints.Free;
  fDistrictsPoints.Free;
end;

procedure TPointsSetupDialog.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      btnClose.Click;
    end;
  end;
end;

procedure TPointsSetupDialog.FormResize(Sender: TObject);
begin
  btnClose.Left:= ClientWidth-btnClose.Width;
  btnClose.Top:= ClientHeight-btnClose.Height;
  btnAdd.Top:= btnClose.Top;
  btnDelete.Top:= btnClose.Top;
  btnLoad.Top:= btnClose.Top;
  btnSave.Top:= btnClose.Top;
  TabControl1.Width:= ClientWidth;
  TabControl1.Height:= btnClose.Top-8;
//  sgPoints.Width:= ClientWidth;
//  sgPoints.Height:= btnClose.Top-8;
  sgPoints.ColWidths [0]:= sgPoints.ClientWidth div 2;
  sgPoints.ColWidths [1]:= sgPoints.ClientWidth-sgPoints.ColWidths [0];
end;

procedure TPointsSetupDialog.btnSaveClick(Sender: TObject);
begin
  if SavePointsDialog.Execute then
    begin
      fCurrentPoints.SaveToFile (SavePointsDialog.FileName);
    end;
  sgPoints.SetFocus;
end;

procedure TPointsSetupDialog.btnAddClick(Sender: TObject);
begin
  if (not sgPoints.EditorMode) and (sgPoints.Row<= fCurrentPoints.Count) then
    InsertPoints (sgPoints.Row-1);
  sgPoints.SetFocus;
end;

procedure TPointsSetupDialog.btnDeleteClick(Sender: TObject);
begin
  if (not sgPoints.EditorMode) and (sgPoints.Row<= fCurrentPoints.Count) then
    DeletePoints (sgPoints.Row-1);
  sgPoints.SetFocus;
end;

procedure TPointsSetupDialog.btnLoadClick(Sender: TObject);
begin
  if LoadPointsDialog.Execute then
    begin
      fCurrentPoints.LoadFromFile (LoadPointsDialog.FileName);
      UpdateData;
    end;
  sgPoints.SetFocus;
end;

end.


