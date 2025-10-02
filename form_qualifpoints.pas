{$a-}
unit form_qualifpoints;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Grids,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

type
  TQualificationPointsDialog = class(TForm)
    sgPoints: TStringGrid;
    btnClose: TButton;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgPointsSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure sgPointsKeyPress(Sender: TObject; var Key: Char);
  private
    fQualificationPoints: TStartListQualificationPoints;
    procedure UpdateData;
    procedure set_Points(const Value: TStartListQualificationPoints);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    property Points: TStartListQualificationPoints read fQualificationPoints write set_Points;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

{ TQualificationPointsDialog }

function TQualificationPointsDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TQualificationPointsDialog.FormCreate(Sender: TObject);
begin
  Width:= Screen.Width div 3;
  Height:= Screen.Height div 3;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TQualificationPointsDialog.FormResize(Sender: TObject);
begin
  btnClose.Left:= ClientWidth-btnClose.Width;
  btnClose.Top:= ClientHeight-btnClose.Height;
  sgPoints.Width:= ClientWidth;
  sgPoints.Height:= btnClose.Top-8;
  sgPoints.ColWidths [0]:= sgPoints.ClientWidth div 2;
  sgPoints.ColWidths [1]:= sgPoints.ClientWidth-sgPoints.GridLineWidth*2-sgPoints.ColWidths [0];
end;

procedure TQualificationPointsDialog.set_Points(
  const Value: TStartListQualificationPoints);
begin
  fQualificationPoints:= Value;
  UpdateData;
end;

procedure TQualificationPointsDialog.UpdateData;
var
  i: integer;
  w,maxw: integer;
  st: string;
  qs: string;
begin
  sgPoints.RowCount:= 1+fQualificationPoints.StartList.Data.Qualifications.Count;
  sgPoints.Row:= 1;
  sgPoints.Col:= 1;
  sgPoints.Canvas.Font:= sgPoints.Font;
  qs:= Language ['QualificationPointsDialog.Qual'];
  maxw:= sgPoints.Canvas.TextWidth (qs);
  for i:= 0 to fQualificationPoints.StartList.Data.Qualifications.Count-1 do
    begin
      st:= fQualificationPoints.StartList.Data.Qualifications.Items [i].Name;
      sgPoints.Cells [0,i+1]:= st;
      sgPoints.Cells [1,i+1]:= IntToStr (fQualificationPoints [i]);
      w:= sgPoints.Canvas.TextWidth (st);
      if w> maxw then
        maxw:= w;
    end;
  sgPoints.ColWidths [0]:= maxw*2;
  sgPoints.ColWidths [1]:= 100;
  sgPoints.ClientWidth:= sgPoints.ColWidths [0]+sgPoints.ColWidths [1]+sgPoints.GridLineWidth*2;
  btnClose.Left:= sgPoints.Left+sgPoints.Width-btnClose.Width;
  sgPoints.Cells [0,0]:= qs;
  sgPoints.Cells [1,0]:= Language ['QualificationPointsDialog.Points'];
end;

procedure TQualificationPointsDialog.UpdateFonts;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  sgPoints.Canvas.Font:= sgPoints.Font;
  sgPoints.DefaultRowHeight:= sgPoints.Canvas.TextHeight ('Mg')+6;
  btnClose.ClientWidth:= Canvas.TextWidth (btnClose.Caption)+32;
  btnClose.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  Constraints.MinWidth:= Width;
  Constraints.MinHeight:= Height-ClientHeight+btnClose.Height+8+
    sgPoints.Height-sgPoints.ClientHeight+
    (sgPoints.DefaultRowHeight+sgPoints.GridLineWidth)*8;
end;

procedure TQualificationPointsDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TQualificationPointsDialog.sgPointsSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: String);
var
  v,i: integer;
begin
  val (Value,v,i);
  if i= 0 then
    fQualificationPoints [ARow-1]:= v;
end;

procedure TQualificationPointsDialog.sgPointsKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #27: begin
      if not sgPoints.EditorMode then
        btnClose.Click;
      Key:= #0;
    end;
  end;
end;

end.

