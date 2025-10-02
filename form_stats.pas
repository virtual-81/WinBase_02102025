{$a-}
unit form_stats;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Clipbrd, Grids, Vcl.StdCtrls, Vcl.ComCtrls,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

type
  TEventStats= record
    Event: TEventItem;
    Results: integer;
    Rating: integer;
  end;

  TShooterStatsDialog = class(TForm)
    btnClose: TButton;
    lbStats: TListBox;
    HeaderControl1: THeaderControl;
    btnCopy: TButton;
    procedure HeaderControl1SectionResize(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure btnCopyClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbStatsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    fShooter: TShooterItem;
    fStats: array of TEventStats;
    fTextHeight: integer;
    procedure set_Shooter(const Value: TShooterItem);
    procedure LoadStats;
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property Shooter: TShooterItem read fShooter write set_Shooter;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

{ TShooterStatsDialog }

procedure TShooterStatsDialog.btnCopyClick(Sender: TObject);
var
  s: string;
  i: integer;
  re: TRichEdit;
begin
  re:= TRichEdit.Create (self);
  re.Visible:= false;
  re.Parent:= self;
  re.Clear;
  re.Font.Charset:= RUSSIAN_CHARSET;
  s:= '';
  for i:= 0 to Length (fStats)-1 do
    begin
      if i> 0 then
        s:= s+#13#10;
      s:= s+fStats [i].Event.ShortName+#9+IntToStr (fStats [i].Results)+#9+
        IntToStr (fStats [i].Rating);
    end;
  re.Text:= s;
  re.SelectAll;
  re.CopyToClipboard;
  re.Parent:= nil;
  re.Free;
end;

function TShooterStatsDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TShooterStatsDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
end;

procedure TShooterStatsDialog.FormDestroy(Sender: TObject);
begin
  lbStats.Count:= 0;
  SetLength (fStats,0);
end;

procedure TShooterStatsDialog.FormResize(Sender: TObject);
begin
  btnClose.Top:= ClientHeight-btnClose.Height;
  btnClose.Left:= ClientWidth-btnClose.Width;
  btnCopy.Top:= btnClose.Top;
  lbStats.Top:= HeaderControl1.Height;
  lbStats.Height:= btnClose.Top-8-lbStats.Top;
  lbStats.Width:= ClientWidth;
  HeaderControl1.Sections [0].Width:= HeaderControl1.ClientWidth-
    HeaderControl1.Sections [1].Width-HeaderControl1.Sections [2].Width;
  lbStats.Invalidate;
end;

procedure TShooterStatsDialog.HeaderControl1SectionResize(
  HeaderControl: THeaderControl; Section: THeaderSection);
begin
  lbStats.Invalidate;
end;

procedure TShooterStatsDialog.lbStatsDrawItem(Control: TWinControl;
  Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s: THeaderSection;
  r: TRect;
begin
  with lbStats.Canvas do
    begin
      FillRect (ARect);
      Brush.Style:= bsClear;
      s:= HeaderControl1.Sections [0];
      r:= Rect (s.Left+2,ARect.Top,s.Right-2,ARect.Bottom);
      Font.Style:= [fsBold];
      TextRect (r,s.Left+2,ARect.Top+2,fStats [Index].Event.ShortName);
      Font.Style:= [];
      TextRect (r,s.Left+2,ARect.Top+2+fTextHeight,fStats [Index].Event.Name);

      s:= HeaderControl1.Sections [1];
      r:= Rect (s.Left+2,ARect.Top,s.Right-2,ARect.Bottom);
      Font.Style:= [fsBold];
      TextRect (r,s.Left+2,ARect.Top+2,IntToStr (fStats [index].Results));

      s:= HeaderControl1.Sections [2];
      r:= Rect (s.Left+2,ARect.Top,s.Right-2,ARect.Bottom);
      Font.Style:= [fsBold];
      TextRect (r,s.Left+2,ARect.Top+2,IntToStr (fStats [index].Rating));
    end;
end;

procedure TShooterStatsDialog.LoadStats;
var
  i,j,found: integer;
  res: TResultItem;
begin
  SetLength (fStats,0);
  for i:= 0 to fShooter.Results.Count-1 do
    begin
      res:= fShooter.Results [i];
      if res.Event= nil then
        continue;
      found:= -1;
      for j:= 0 to Length (fStats)-1 do
        if fStats [j].Event= res.Event then
          begin
            found:= j;
            break;
          end;
      if found= -1 then
        begin
          found:= Length (fStats);
          SetLength (fStats,found+1);
          fStats [found].Event:= res.Event;
          fStats [found].Results:= 0;
          fStats [found].Rating:= 0;
        end;
      inc (fStats [found].Results);
      inc (fStats [found].Rating,res.Rating);
    end;
  lbStats.Count:= Length (fStats);
  if Length (fStats)> 0 then
    lbStats.ItemIndex:= 0;
end;

procedure TShooterStatsDialog.set_Shooter(const Value: TShooterItem);
begin
  fShooter:= Value;
  if fShooter<> nil then
    begin
      Caption:= format (Language ['ShooterStatsDialog'],[fShooter.SurnameAndName]);
      LoadStats;
    end;
end;

procedure TShooterStatsDialog.UpdateFonts;
var
  bh: integer;
  s: THeaderSection;
begin
  Font:= SysFonts.MessageFont;
  lbStats.Canvas.Font:= lbStats.Font;
  fTextHeight:= lbStats.Canvas.TextHeight ('Mg');
  lbStats.ItemHeight:= fTextHeight*2+6;
  HeaderControl1.Canvas.Font:= HeaderControl1.Font;
  HeaderControl1.ClientHeight:= HeaderControl1.Canvas.TextHeight ('Mg')+4;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnClose.ClientHeight:= bh;
  btnCopy.ClientHeight:= bh;
  btnClose.ClientWidth:= Canvas.TextWidth (btnClose.Caption)+32;
  btnCopy.ClientWidth:= Canvas.TextWidth (btnCopy.Caption)+32;
  s:= HeaderControl1.Sections [1];
  s.Width:= HeaderControl1.Canvas.TextWidth (s.Text)+16;
  s:= HeaderControl1.Sections [2];
  s.Width:= HeaderControl1.Canvas.TextWidth (s.Text)+16;
end;

procedure TShooterStatsDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

end.


