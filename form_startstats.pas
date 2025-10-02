unit form_startstats;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Clipbrd,

  Data,
  MyLanguage,
  ctrl_language,
  SysFont, Vcl.StdCtrls;

type
  TStartListStatsDialog = class(TForm)
    btnCopy: TButton;
    btnOk: TButton;
    Memo1: TMemo;
    procedure FormResize(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fStartList: TStartList;
    procedure set_StartList(const Value: TStartList);
    procedure UpdateLanguage;
    procedure UpdateFonts;
  public
    { Public declarations }
    property StartList: TStartList read fStartList write set_StartList;
  end;

implementation

{$R *.dfm}

procedure TStartListStatsDialog.btnCopyClick(Sender: TObject);
begin
  Memo1.SelectAll;
  Memo1.CopyToClipboard;
  Memo1.SelLength:= 0;
end;

procedure TStartListStatsDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
end;

procedure TStartListStatsDialog.FormResize(Sender: TObject);
begin
  Memo1.Top:= 8;
  Memo1.Left:= 8;
  Memo1.Width:= ClientWidth-16;

  btnCopy.Left:= 8;
  btnCopy.Top:= ClientHeight-8-btnCopy.Height;

  btnOk.Top:= btnCopy.Top;
  btnOk.Left:= ClientWidth-8-btnOk.Width;

  Memo1.Height:= btnCopy.Top-8-Memo1.Top;
end;

procedure TStartListStatsDialog.set_StartList(const Value: TStartList);
var
  ta,ra: TStrings;
  n1,n2,i,j: integer;
  q,q1: TQualificationItem;
  s: string;
  ev: TStartListEventItem;
  rs: TRegionsStats;
begin
  fStartList:= Value;
  Memo1.Clear;
  Memo1.Lines.Add ('Чемпионат России по пулевой стрельбе');
  Memo1.Lines.Add ('Кубок России по пулевой стрельбе');
  Memo1.Lines.Add ('');
  Memo1.Lines.Add (fStartList.Info.TitleText);
  Memo1.Lines.Add (fStartList.DatesFromTillStr);
  Memo1.Lines.Add (fStartList.Info.TownAndRange);
  Memo1.Lines.Add ('');
  Memo1.Lines.Add ('1. Общее число участников - '+IntToStr (fStartList.Shooters.Count));
  Memo1.Lines.Add ('в том числе: мужчины - '+IntToStr (fStartList.Shooters.NumberOf (Male))+', женщины - '+IntToStr (fStartList.Shooters.NumberOf (Female)));
  Memo1.Lines.Add ('Всего заявок стрелков - '+IntToStr (fStartList.Events.TotalShooters));
  Memo1.Lines.Add ('');
  ta:= fStartList.GetTeams (true,nil);
  ra:= fstartList.GetRegions (false);     // все регионы, исключаем пустые или нет
  Memo1.Lines.Add ('2. Представители спортивных организаций из '+IntToStr (ra.Count)+' субъектов, '+IntToStr (ta.Count)+' команд');
  ra.Free;
  ta.Free;
  Memo1.Lines.Add ('');
  Memo1.Lines.Add ('3. Распределение по квалификации');
  for i:= 0 to fStartList.Data.Qualifications.Count-1 do
    begin
      q:= fStartList.Data.Qualifications.Items [i];
      n1:= fStartList.Shooters.NumberOf (q);
      if n1> 0 then
        begin
          n2:= fStartList.Events.NumberOf (q);
          memo1.Lines.Add (q.Name+': участников - '+IntToStr (n1)+', заявок - '+IntToStr (n2));
        end;
    end;
  n1:= fStartList.Shooters.NumberOf (nil);
  if n1> 0 then
    Memo1.Lines.Add ('Без квалификации - '+IntToStr (n1));
  for i:= 0 to fStartList.Data.Qualifications.Count-1 do
    begin
      q:= fStartList.Data.Qualifications.Items [i];
      if not q.SetByResult then
        continue;
      s:= '';
      for j:= 0 to fStartList.Data.Qualifications.Count-1 do
        begin
          q1:= fStartList.Data.Qualifications.Items [j];
          n1:= fStartList.Qualified (q1,q);
          if n1> 0 then
            begin
              if s<> '' then
                s:= s+', ';
              s:= s+q1.Name+' - '+IntToStr (n1);
            end;
        end;
      if s<> '' then
        begin
          Memo1.Lines.Add ('');
          Memo1.Lines.Add ('Выполнившие разряды '+q.Name+', раз:');
          Memo1.Lines.Add (s);
        end;
    end;
  // по выполнению разрядов
  s:= '';
  for j:= 0 to fStartList.Data.Qualifications.Count-1 do
    begin
      q1:= fStartList.Data.Qualifications.Items [j];
      n1:= fStartList.Qualified (q1,nil);
      if n1> 0 then
        begin
          if s<> '' then
            s:= s+', ';
          s:= s+q1.Name+' - '+IntToStr (n1);
        end;
    end;
  if s<> '' then
    begin
      Memo1.Lines.Add ('');
      Memo1.Lines.Add ('Не выполнили ни одного норматива, раз:');
      Memo1.Lines.Add (s);
    end;
  // Статистика участников отдельно по каждому из упражнений
  Memo1.Lines.Add ('');
  Memo1.Lines.Add ('Статистика по регионам и упражнениям:');
  for j:= 0 to fStartList.Events.Count-1 do
    begin
      ev:= fStartList.Events.Items [j];
      Memo1.Lines.Add (ev.Event.ShortName);
      rs:= nil;
      ev.Shooters.GetRegionsStats (rs);
      if Length (rs)> 0 then
        begin
          s:= '';
          for i:= 0 to Length (rs)-1 do
            begin
              if Length (s)>= 80 then
                begin
                  Memo1.Lines.Add (s);
                  s:= '';
                end;
              if s<> '' then
                s:= s+', ';
              s:= s+rs [i].Region+' - '+IntToStr (rs [i].Count);
            end;
          if s<> '' then
            Memo1.Lines.Add (s);
          DeleteRegionsStats (rs);
        end;
      Memo1.Lines.Add ('');
    end;
  fStartList.Shooters.GetRegionsStats (rs);
  if Length (rs)> 0 then
    begin
      Memo1.Lines.Add ('');
      Memo1.Lines.Add ('Статистика по регионам и участникам:');
      for i:= 0 to Length (rs)-1 do
        begin
          if rs [i].Count> 0 then
            Memo1.Lines.Add (rs [i].Region+' - '+IntToStr (rs [i].Count));
        end;
      DeleteRegionsStats (rs);
    end;
end;

procedure TStartListStatsDialog.UpdateFonts;
var
  bh: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;

  bh:= Canvas.TextHeight ('Mg')+12;
  btnCopy.ClientWidth:= Canvas.TextWidth (btnCopy.Caption)+32;
  btnCopy.ClientHeight:= bh;
  btnOk.ClientWidth:= Canvas.TextWidth (btnOk.Caption)+32;
  btnOk.ClientHeight:= bh;

  Width:= Screen.Width div 2;
  Height:= Screen.Height div 2;
  Position:= poOwnerFormCenter;
end;

procedure TStartListStatsDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

end.

