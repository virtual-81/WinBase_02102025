unit form_startshooters;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Printers, System.Win.Registry,
  System.UITypes, System.Types, Vcl.Menus,

  MyPrint,

  SysFont,
  Data,

  form_addtostart,
  form_shooter,
  form_printprotocol,

  wb_registry,

  MyLanguage,
  MyTables,
  ctrl_language, Vcl.ExtCtrls;

type
  TStartListShootersForm = class(TForm)
    lbShooters: TListBox;
    hcShooters: THeaderControl;
    sbHorz: TScrollBar;
    btnPrint: TButton;
    btnSave: TButton;
    pmShooters: TPopupMenu;
    mnuOpenShooterData: TMenuItem;
    mnuAddToStart: TMenuItem;
    procedure btnSaveClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure sbHorzChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lbShootersDblClick(Sender: TObject);
    procedure lbShootersKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbShootersClick(Sender: TObject);
    procedure lbShootersKeyPress(Sender: TObject; var Key: Char);
    procedure lbShootersMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mnuOpenShooterDataClick(Sender: TObject);
    procedure mnuAddToStartClick(Sender: TObject);
    procedure hcShootersSectionClick(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure hcShootersSectionResize(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure lbShootersDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    fStart: TStartList;
    fNumSearchStr,fNameSearchStr: string;
    fTextHeight: integer;
    fLastClickShiftState: TShiftState;
    procedure set_StartList(const Value: TStartList);
    procedure UpdateFonts;
    function DoSearchNum (s: string; fromidx: integer= 0): integer;
    procedure ResetSearch;
    function DoSearchName (s: string; fromidx: integer= 0): integer;
    procedure OpenShooterEvents (Index: integer);
    procedure OpenShooter (Index: integer);
    procedure UpdateScroll;
//    procedure WMEraseBkgnd (var Msg: TMessage); message WM_ERASEBKGND;
    procedure UpdateLanguage;
    procedure PrintList;
    procedure PrintAllShooters (APrinter: TObject);
    procedure SaveListToPDF;
  public
    { Public declarations }
    function Execute: boolean;
    property StartList: TStartList read fStart write set_StartList;
  end;

implementation

{$R *.dfm}

{ TStartListShootersForm }

procedure TStartListShootersForm.btnPrintClick(Sender: TObject);
begin
  PrintList;
  lbShooters.SetFocus;
end;

procedure TStartListShootersForm.btnSaveClick(Sender: TObject);
begin
  SaveListToPDF;
  lbShooters.SetFocus;
end;

function TStartListShootersForm.DoSearchName(s: string; fromidx: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= fromidx to fStart.Shooters.Count-1 do
    begin
      if AnsiSameText (copy (fStart.Shooters [i].Shooter.SurnameAndName,1,Length (s)),s) then
        begin
          Result:= i;
          exit;
        end;
    end;
  if fromidx> 0 then
    begin
      for i:= 0 to fromidx-1 do
        begin
          if AnsiSameText (copy (fStart.Shooters [i].Shooter.SurnameAndName,1,Length (s)),s) then
            begin
              Result:= i;
              exit;
            end;
        end;
    end;
end;

function TStartListShootersForm.DoSearchNum(s: string; fromidx: integer): integer;
var
  i: integer;
begin
  Result:= -1;
  for i:= fromidx to fStart.Shooters.Count-1 do
    begin
      if copy (fStart.Shooters [i].StartNumberStr,1,Length (s))= s then
        begin
          Result:= i;
          exit;
        end;
    end;
end;

function TStartListShootersForm.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TStartListShootersForm.FormCreate(Sender: TObject);
begin
  fNumSearchStr:= '';
  fNameSearchStr:= '';
  fLastClickShiftState:= []; // Инициализация состояния клавиш
  Width:= round (Screen.Width * 0.9);
  Height:= round (Screen.Height * 0.9);
  
  // Создаем контекстное меню
  pmShooters:= TPopupMenu.Create(Self);
  mnuOpenShooterData:= TMenuItem.Create(Self);
  mnuOpenShooterData.Caption:= 'Личная карточка';
  mnuOpenShooterData.OnClick:= mnuOpenShooterDataClick;
  pmShooters.Items.Add(mnuOpenShooterData);
  
  mnuAddToStart:= TMenuItem.Create(Self);
  mnuAddToStart.Caption:= 'Заявить на упражнения';
  mnuAddToStart.OnClick:= mnuAddToStartClick;
  pmShooters.Items.Add(mnuAddToStart);
  
  lbShooters.PopupMenu:= pmShooters;
  
  UpdateLanguage;
  UpdateFonts;
  ActiveControl:= lbShooters;
  Position:= poScreenCenter;
  // Привязываем обработчик MouseDown
  lbShooters.OnMouseDown:= lbShootersMouseDown;
end;

procedure TStartListShootersForm.FormResize(Sender: TObject);
begin
  hcShooters.Width:= ClientWidth-hcShooters.Left;
  sbHorz.Width:= ClientWidth;
  sbHorz.Top:= ClientHeight-sbHorz.Height;
  UpdateScroll;
  lbShooters.Width:= ClientWidth;
  lbShooters.Height:= sbHorz.Top-lbShooters.Top;
  lbShooters.Invalidate;
end;

procedure TStartListShootersForm.FormShow(Sender: TObject);
var
  i,w,
  wName,wBirth,wDistrict,wRegionTown,wClub,wQual,wEvCount,wEvents: integer;
  sh: TStartListShooterItem;
begin
  if fStart= nil then
    exit;
  wName:= 0; wBirth:= 0; wDistrict:= 0; wRegionTown:= 0; wClub:= 0; wQual:= 0; wEvCount:= 0; wEvents:= 0;
  for i:= 0 to fStart.Shooters.Count-1 do
    begin
      lbShooters.Canvas.Font:= lbShooters.Font;
      sh:= fStart.Shooters [i];
      lbShooters.Canvas.Font.Style:= [fsBold];
      // ФИО целиком
      w:= lbShooters.Canvas.TextWidth (sh.Shooter.SurnameAndNameAndStepName);
      if w> wName then
        wName:= w;
      w:= lbShooters.Canvas.TextWidth (sh.Shooter.BirthFullStr);
      if w> wBirth then
        wBirth:= w;
      w:= lbShooters.Canvas.TextWidth (sh.Shooter.DistrictAbbr);
      if w> wDistrict then
        wDistrict:= w;
      w:= lbShooters.Canvas.TextWidth (sh.Shooter.RegionsAbbr);
      if w> wRegionTown then
        wRegionTown:= w;
      w:= lbShooters.Canvas.TextWidth (sh.Shooter.SocietyAndClub);
      if w> wClub then
        wClub:= w;
      w:= lbShooters.Canvas.TextWidth (sh.Shooter.QualificationName);
      if w> wQual then
        wQual:= w;
      lbShooters.Canvas.Font.Style:= [fsBold];
      w:= lbShooters.Canvas.TextWidth (sh.Shooter.Town);
      if w> wRegionTown then
        wRegionTown:= w;
      lbShooters.Canvas.Font.Size:= lbShooters.Canvas.Font.Size-1;
      w:= lbShooters.Canvas.TextWidth (sh.Shooter.Group.Name);
      if w> wName then
        wName:= w;
      w:= lbShooters.Canvas.TextWidth (sh.EventsNames);
      if w> wEvents then
        wEvents:= w;
    end;
  // Индексы секций после объединения ФИО: 0: номер; 1: Фамилия, Имя, Отчество; 2: Дата рождения; 3: Округ; 4: Регион, Город; 5: Клуб; 6: Квалификация; 7: Заявок; 8: Упражнения
  hcShooters.Sections [1].Width:= wName+16;
  hcShooters.Sections [2].Width:= wBirth+16;
  hcShooters.Sections [3].Width:= wDistrict+16;
  hcShooters.Sections [4].Width:= wRegionTown+16;
  hcShooters.Sections [5].Width:= wClub+16;
  hcShooters.Sections [6].Width:= wQual+16;
  hcShooters.Sections [7].Width:= hcShooters.Sections [7].MinWidth;
  hcShooters.Sections [8].Width:= wEvents+16;
  UpdateScroll;
  lbShooters.SetFocus;
end;

procedure TStartListShootersForm.hcShootersSectionClick(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  case Section.Index of
    0: fStart.Shooters.Sort (slsoStartNumber);
    1: fStart.Shooters.Sort (slsoSurname);
    2: fStart.Shooters.Sort (slsoBirthDate);
    3: fStart.Shooters.Sort (slsoDistrict);
    4: fStart.Shooters.Sort (slsoRegion);
    5: fStart.Shooters.Sort (slsoSociety);
    6: fStart.Shooters.Sort (slsoQualification);
  else
    exit;
  end;
  lbShooters.Invalidate;
end;

procedure TStartListShootersForm.hcShootersSectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  UpdateScroll;
  lbShooters.Invalidate;
end;

procedure TStartListShootersForm.lbShootersClick(Sender: TObject);
begin
  ResetSearch;
end;

procedure TStartListShootersForm.lbShootersMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  // Сохраняем состояние клавиш для использования в обработчике двойного клика
  fLastClickShiftState:= Shift;
end;

procedure TStartListShootersForm.lbShootersDblClick(Sender: TObject);
begin
  // Проверяем сохраненное состояние клавиш
  if (ssShift in fLastClickShiftState) or (ssCtrl in fLastClickShiftState) then
    begin
      // Если зажат Shift или Ctrl - открываем форму заявки на упражнения
      OpenShooterEvents(lbShooters.ItemIndex);
    end
  else
    begin
      // Обычное поведение - открываем личную карточку
      OpenShooter(lbShooters.ItemIndex);
    end;
end;

procedure TStartListShootersForm.mnuOpenShooterDataClick(Sender: TObject);
begin
  // Открываем личную карточку спортсмена
  OpenShooter(lbShooters.ItemIndex);
end;

procedure TStartListShootersForm.mnuAddToStartClick(Sender: TObject);
begin
  // Открываем форму заявки на упражнения
  OpenShooterEvents(lbShooters.ItemIndex);
end;

procedure TStartListShootersForm.lbShootersDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  s: THeaderSection;
  r: TRect;
  sh: TStartListShooterItem;
  w: integer;
  st: string;
  c: TColor;
  dx: integer;
begin
  dx:= hcShooters.Left;
  with lbShooters.Canvas do
    begin
      Brush.Style:= bsSolid;
      FillRect (ARect);
      sh:= fStart.Shooters [Index];
      Brush.Style:= bsClear;
      c:= Font.Color;
      if fStart.StartNumbers then
        begin
          s:= hcShooters.Sections [0];
          r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
          if (fNumSearchStr<> '') and (odSelected in State) then
            begin
              Font.Color:= clYellow;
              Font.Style:= [fsBold,fsUnderline];
              TextRect (r,r.Left,ARect.Top+3,fNumSearchStr);
              w:= TextWidth (fNumSearchStr);
              Font.Style:= [];
              Font.Color:= c;
              st:= sh.StartNumberStr;
              TextRect (r,r.Left+w,ARect.Top+2,copy (st,Length (fNumSearchStr)+1,Length (st)));
            end
          else
            TextRect (r,r.Left,ARect.Top+3,sh.StartNumberStr);
        end;
      s:= hcShooters.Sections [1];
      r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
      Font.Style:= [fsBold];
      if (fNameSearchStr<> '') and (odSelected in State) then
        begin
          Font.Color:= clYellow;
          Font.Style:= [fsBold,fsUnderline];
          TextRect (r,r.Left,ARect.Top+3,fNameSearchStr);
          w:= TextWidth (fNameSearchStr);
          Font.Style:= [];
          Font.Color:= c;
          st:= sh.Shooter.SurnameAndNameAndStepName;
          TextRect (r,r.Left+w,ARect.Top+3,copy (st,Length (fNameSearchStr)+1,Length (st)));
        end
      else
        TextRect (r,r.Left,ARect.Top+2,sh.Shooter.SurnameAndNameAndStepName);
      Font.Style:= [];
      Font.Size:= Font.Size-1;
      Font.Color:= clGrayText;
      TextRect (r,r.Left,ARect.Top+3+fTextHeight,sh.Shooter.Group.Name);
      Font.Color:= c;
      Font.Size:= Font.Size+1;
      // Дата рождения (полная)
      s:= hcShooters.Sections [2];
      r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
      Font.Style:= [];
      TextRect (r,r.Left,ARect.Top+3,sh.Shooter.BirthFullStr);
      Font.Style:= [fsBold];
      s:= hcShooters.Sections [3];
      r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
      TextRect (r,r.Left,ARect.Top+3,sh.Shooter.DistrictAbbr);
      s:= hcShooters.Sections [4];
      r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
      TextRect (r,r.Left,ARect.Top+3,sh.Shooter.RegionsAbbr);
      Font.Style:= [];
      TextRect (r,r.Left,ARect.Top+3+fTextHeight,sh.Shooter.Town);
      Font.Style:= [fsBold];
      s:= hcShooters.Sections [5];
      r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
      Font.Style:= [fsBold];
      TextRect (r,r.Left,ARect.Top+3,sh.Shooter.SocietyName);
      Font.Style:= [];
      TextRect (r,r.Left,ARect.Top+3+fTextHeight,sh.Shooter.SportClub);
      s:= hcShooters.Sections [6];
      r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
      Font.Style:= [fsBold];
      TextRect (r,r.Left,ARect.Top+3,sh.Shooter.QualificationName);
      s:= hcShooters.Sections [7];
      r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
      TextRect (r,r.Left,ARect.Top+2,IntToStr (sh.EventsCount));
      s:= hcShooters.Sections [8];
      r:= Rect (ARect.Left+s.Left+2+dx,ARect.Top,ARect.Left+s.Right-2+dx,ARect.Bottom);
      Font.Style:= [];
      TextRect (r,r.Left,ARect.Top+2,sh.EventsNames);
    end;
end;

procedure TStartListShootersForm.lbShootersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  idx: integer;
begin
  case Key of
    VK_F2: begin
      Key:= 0;
      OpenShooterEvents (lbShooters.ItemIndex);
    end;
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
    VK_RETURN: begin
      Key:= 0;
      if Shift= [ssCtrl] then
        begin
          if fNameSearchStr<> '' then
            begin
              idx:= DoSearchName (fNameSearchStr,lbShooters.ItemIndex+1);
              if (idx>= 0) and (idx<> lbShooters.ItemIndex) then
                begin
                  if lbShooters.SelCount> 1 then
                    lbShooters.ClearSelection;
                  if lbShooters.ItemIndex>= 0 then
                    lbShooters.Selected [lbShooters.ItemIndex]:= false;
                  lbShooters.ItemIndex:= idx;
                  lbShooters.Selected [idx]:= true;
                  lbShooters.Invalidate;
                end;
            end;
        end
      else
        OpenShooter (lbShooters.ItemIndex);
    end;
    VK_F5: begin
      Key:= 0;
      PrintList;
    end;
    VK_F6: begin
      Key:= 0;
      SaveListToPDF;
    end;
  end;
end;

procedure TStartListShootersForm.lbShootersKeyPress(Sender: TObject; var Key: Char);
var
  idx: integer;
begin
  if Key in ['0'..'9'] then
    begin
      idx:= DoSearchNum (fNumSearchStr+Key);
      if idx>= 0 then
        begin
          fNumSearchStr:= fNumSearchStr+Key;
          if lbShooters.SelCount> 1 then
            lbShooters.ClearSelection;
          if lbShooters.ItemIndex>= 0 then
            lbShooters.Selected [lbShooters.ItemIndex]:= false;
          lbShooters.ItemIndex:= idx;
          lbShooters.Selected [idx]:= true;
          lbShooters.Invalidate;
        end;
      Key:= #0;
    end
  else if Key>= #32 then
    begin
      idx:= DoSearchName (fNameSearchStr+Key,lbShooters.ItemIndex);
      if idx>= 0 then
        begin
          fNameSearchStr:= fNameSearchStr+Key;
          if lbShooters.SelCount> 1 then
            lbShooters.ClearSelection;
          if lbShooters.ItemIndex>= 0 then
            lbShooters.Selected [lbShooters.ItemIndex]:= false;
          lbShooters.ItemIndex:= idx;
          lbShooters.Selected [idx]:= true;
          lbShooters.Invalidate;
        end;
      Key:= #0;
    end
  else
    Key:= #0;
end;

procedure TStartListShootersForm.OpenShooter(Index: integer);
var
  sh: TStartListShooterItem;
  shd: TShooterDetailsDialog;
begin
  if Index< 0 then
    exit;
  sh:= fStart.Shooters [Index];
  shd:= TShooterDetailsDialog.Create (self);
  shd.Shooter:= sh.Shooter;
  shd.Execute;
  shd.Free;
  lbShooters.Invalidate;
end;

procedure TStartListShootersForm.OpenShooterEvents(Index: integer);
var
  sh: TStartListShooterItem;
  addform: TAddToStartDialog;
begin
  if Index< 0 then
    exit;
  sh:= fStart.Shooters [Index];
  addform:= TAddToStartDialog.Create (self);
  addform.StartList:= fStart;
  addform.Shooter:= sh.Shooter;
  addform.AutoPrint:= false;
  addform.Execute;
  addform.Free;
  lbShooters.Invalidate;
end;

procedure TStartListShootersForm.PrintAllShooters (APrinter: TObject);
const
  separator= 4;
var
  table: TMyTableColumns;
  lpx,lpy: integer;
  canv: TCanvas;
  leftborder,topborder,rightborder,bottomborder: integer;
  font_height_large,font_height_small: integer;
  thl,ths: integer;
  item_height,footerheight: integer;
  p_width,p_height: integer;
  page_idx: integer;
  y: integer;
  tcNum,tcName,tcDistrict,tcRegion,tcClub,tcQual,tcEventsCount,tcEvents: TMyTableColumn;
  signatureheight: integer;

  function mm2px (mm: single): integer;
  begin
    Result:= round (mm*lpx/25.4);
  end;

  function mm2py (mm: single): integer;
  begin
    Result:= round (mm*lpy/25.4);
  end;

  procedure CreateTable;
  begin
    table:= TMyTableColumns.Create;
    tcNum:= table.Add;  // пїЅпїЅпїЅпїЅпїЅ
    tcName:= table.Add;  // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅ
    tcDistrict:= table.Add;  // пїЅпїЅпїЅпїЅпїЅ
    tcRegion:= table.Add;  // пїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅпїЅпїЅ
    tcClub:= table.Add;  // пїЅпїЅпїЅпїЅ
    tcQual:= table.Add;   // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
    tcEventsCount:= table.Add;  // пїЅпїЅпїЅ-пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
    tcEvents:= table.Add;  // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
  end;

  function MeasureColumns: boolean;
  var
    i: integer;
    sh: TStartListShooterItem;
    w: integer;
  begin
    Result:= false;
    table.Width:= 0;
    with canv do
      begin
        Font.Style:= [];
        Font.Height:= font_height_large;
        for i:= 0 to fStart.Shooters.Count-1 do
          begin
            sh:= fStart.Shooters [i];
            if (lbShooters.SelCount> 1) and (not lbShooters.Selected [i]) then
              continue;
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            tcNum.Fit (TextWidth (sh.StartNumberStr));
            tcName.Fit (TextWidth (sh.Shooter.Surname));
            tcDistrict.Fit (TextWidth (sh.Shooter.DistrictAbbr));
            tcRegion.Fit (TextWidth (sh.Shooter.RegionAbbr1));
            tcClub.Fit (TextWidth (sh.Shooter.SocietyName));
            tcEventsCount.Fit (TextWidth (IntToStr (sh.EventsCount)));
            Font.Style:= [];
            tcQual.Fit (TextWidth (sh.Shooter.QualificationName));
            tcEvents.Fit (TextWidth (sh.EventsNames));
            Font.Height:= font_height_small;
            Font.Style:= [];
            tcName.Fit (TextWidth (sh.Shooter.Name));
            tcRegion.Fit (TextWidth (sh.Shooter.Town));
            tcClub.Fit (TextWidth (sh.Shooter.SportClub));
          end;
      end;
    table.AddSeparator (mm2px (separator));
    w:= table.Width;
    if w< p_width-leftborder-rightborder then
      begin
        tcName.Width:= tcName.Width+p_width-leftborder-rightborder-w;
        Result:= true;
      end;
  end;

  procedure MakeNewPage;
  var
    st: string;
    s: TStringList;
    i: integer;
    w,x: integer;
  begin
    if page_idx> 1 then
      begin
        if APrinter is TPrinter then
          (APrinter as TPrinter).NewPage
        else if APrinter is TPDFDocument then
          begin
            with (APrinter as TPDFDocument) do
              begin
                NewPage;
                canv:= Canvas;
                CurrentPage.Size:= psA4;
                CurrentPage.Orientation:= poPagePortrait;
                p_width:= PageWidth;
                p_height:= PageHeight;
                Canvas.Font.Name:= 'Arial';
                Canvas.Font.Charset:= PROTOCOL_CHARSET;
              end;
          end;
      end;

    with canv do   // footer
      begin
        Font.Height:= font_height_large;
        Pen.Width:= 1;
        y:= p_height-bottomborder-footerheight+mm2py (2);
        MoveTo (leftborder,y);
        LineTo (p_width-rightborder,y);
        y:= y+mm2py (2);
        Font.Height:= font_height_small;
        Font.Style:= [];
        st:= format (PAGE_NO,[page_idx]);
        TextOut (p_width-rightborder-TextWidth (st),y,st);
        st:= format (PAGE_FOOTER,[VERSION_INFO_STR]);
        TextOut (leftborder,y,st);
      end;

    y:= topborder;
    with canv do
      begin
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];

        if page_idx= 1 then
          begin
            Font.Height:= font_height_large;
            Font.Style:= [fsBold];
            s:= TStringList.Create;
            s.Text:= fStart.Info.TitleText;
            for i:= 0 to s.Count-1 do
              begin
                st:= s [i];
                w:= TextWidth (st);
                x:= (leftborder+p_width-rightborder-w) div 2;
                TextOut (x,y,st);
                inc (y,TextHeight (st));
              end;
            if s.Count> 0 then
              inc (y,mm2py (2));
          end;

        Font.Style:= [];
        if page_idx= 1 then
          st:= Language ['AllStartListShootersPageTitle']
        else
          st:= Language ['AllStartListShootersPageTitle1'];
        TextOut (leftborder,y,st);

        st:= fStart.DatesFromTillStr;
//        st:= FormatDateTime ('dddddd',Now);
        Font.Style:= [];
        TextOut (p_width-rightborder-TextWidth (st),y,st);
        y:= y+thl+mm2py (2);
        Pen.Width:= 1;
        MoveTo (leftborder,y);
        LineTo (p_width-rightborder,y);
        y:= y+mm2py (2);
      end;

  end;

var
  i: integer;
  sh: TStartListShooterItem;

  procedure PrintShooter;
  var
    x: integer;
    st: string;
  begin
    with canv do
      begin
        Font.Height:= font_height_large;
        // пїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [];
        st:= sh.StartNumberStr;
        x:= leftborder+tcNum.Right-mm2px (separator/2)-TextWidth (st);
        TextOut (x,y,st);
        // пїЅпїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅ
        Font.Style:= [fsBold];
        Font.Height:= font_height_large;
        x:= leftborder+tcName.Left+mm2px (separator/2);
        st:= sh.Shooter.Surname;
        TextOut (x,y,st);
        Font.Style:= [];
        Font.Height:= font_height_small;
        st:= sh.Shooter.Name;
        TextOut (x,y+thl,st);
        // пїЅпїЅпїЅпїЅпїЅ
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        x:= leftborder+tcDistrict.Left+mm2px (separator/2);
        st:= sh.Shooter.DistrictAbbr;
        TextOut (x,y,st);
        // пїЅпїЅпїЅпїЅпїЅпїЅ, пїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [fsBold];
        x:= leftborder+tcRegion.Left+mm2px (separator/2);
        st:= sh.Shooter.RegionAbbr1;
        TextOut (x,y,st);
        Font.Style:= [];
        Font.Height:= font_height_small;
        st:= sh.Shooter.Town;
        TextOut (x,y+thl,st);
        // пїЅпїЅпїЅпїЅ
        Font.Height:= font_height_large;
        Font.Style:= [fsBold];
        x:= leftborder+tcClub.Left+mm2px (separator/2);
        st:= sh.Shooter.SocietyName;
        TextOut (x,y,st);
        Font.Style:= [];
        Font.Height:= font_height_small;
        st:= sh.Shooter.SportClub;
        TextOut (x,y+thl,st);
        // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [];
        Font.Height:= font_height_large;
        x:= leftborder+tcQual.Left+mm2px (separator/2);
        st:= sh.Shooter.QualificationName;
        TextOut (x,y,st);
        // пїЅпїЅпїЅ-пїЅпїЅ пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [fsBold];
        x:= leftborder+tcEventsCount.Left+mm2px (separator/2);
        st:= IntToStr (sh.EventsCount);
        TextOut (x,y,st);
        // пїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅпїЅ
        Font.Style:= [];
        x:= leftborder+tcEvents.Left+mm2px (separator/2);
        st:= sh.EventsNames;
        TextOut (x,y,st);
      end;
  end;

  procedure MakeSignature;
  var
    x,yy: integer;
  begin
    if y+signatureheight>= p_height-bottomborder-footerheight then
      begin
        inc (page_idx);
        MakeNewPage;
      end;
    with canv do
      begin
        yy:= p_height-bottomborder-footerheight-signatureheight+mm2py (5);
        Font.Style:= [];
        Font.Height:= font_height_large;
        x:= leftborder+mm2px (3);
        TextOut (x,yy,SECRETERY_TITLE);
        yy:= yy+TextHeight ('Mg');
        TextOut (x,yy,fStart.Info.SecreteryCategory);
        x:= p_width-rightborder-mm2px (3)-TextWidth (fStart.Info.Secretery);
        TextOut (x,yy,fStart.Info.Secretery);
      end;
  end;

var
  total_count,events_count: integer;
  font_name: string;
  font_size: integer;
  Reg: TRegistry;

begin
  if APrinter= nil then
    APrinter:= Printer;

  if APrinter is TPrinter then
    begin
      with (APrinter as TPrinter) do
        begin
          Orientation:= poPortrait;
          Title:= Language ['StartShootersForm.AllShootersListPDFTitle'];
          Copies:= 1;
          BeginDoc;
          lpx:= GetDeviceCaps (Canvas.Handle,LOGPIXELSX);
          lpy:= GetDeviceCaps (Canvas.Handle,LOGPIXELSY);
          canv:= Canvas;
          p_width:= PageWidth;
          p_height:= PageHeight;
        end;
    end
  else if APrinter is TPDFDocument then
    begin
      with (APrinter as TPDFDocument) do
        begin
          PageLayout:= plSinglePage;
          PageMode:= pmUseNone;
          DocumentInfo.Title:= Language ['StartShootersForm.AllShootersListPrintTitle'];
          ProtectionEnabled:= true;
          ProtectionOptions:= [coPrint];
          Compression:= ctFlate;
          BeginDoc;
          CurrentPage.Size:= psA4;
          CurrentPage.Orientation:= poPagePortrait;
          lpx:= Resolution;
          lpy:= Resolution;
          canv:= Canvas;
          p_width:= PageWidth;
          p_height:= PageHeight;
        end;
    end
  else
    exit;

  CreateTable;

  leftborder:= mm2px (15);
  topborder:= mm2py (10);
  bottomborder:= mm2py (10);
  rightborder:= mm2px (10);

  font_name:= 'Arial';
  font_size:= 10;
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey (REG_PATH,false) then
      begin
        if Reg.ValueExists ('ProtocolFontName') then
          font_name:= Reg.ReadString ('ProtocolFontName');
        if Reg.ValueExists ('ProtocolFontSize') then
          font_size:= Reg.ReadInteger ('ProtocolFontSize');
        Reg.CloseKey;
      end;
  finally
    Reg.Free;
  end;

  with canv do
    begin
      Font.Charset:= PROTOCOL_CHARSET;
      Font.Name:= font_name;
      Font.Size:= font_size;
      font_height_large:= Font.Height;
      font_height_small:= round (font_height_large * 3/4);
    end;

  repeat
    with canv do
      begin
        Font.Height:= font_height_large;
        thl:= TextHeight ('Mg');
        Font.Height:= font_height_small;
        ths:= TextHeight ('Mg');
      end;
    footerheight:= ths+mm2py (4);
    item_height:= thl+ths+mm2py (1.5);
    signatureheight:= thl*2+mm2py (5)+mm2py (5);
    if MeasureColumns then
      break
    else
      begin
        if abs (font_height_large)> 4 then
          begin
            inc (font_height_large);
            font_height_small:= round (font_height_large * 3/4);
          end
        else
          begin
            if APrinter is TPrinter then
              (APrinter as TPrinter).Abort
            else if APrinter is TPDFDocument then
              (APrinter as TPDFDocument).Abort;
            table.Free;
            exit;
          end;
      end;
  until false;

  total_count:= 0;
  events_count:= 0;

  with canv do
    begin
      page_idx:= 1;
      MakeNewPage;
      for i:= 0 to fStart.Shooters.Count-1 do
        begin
          sh:= fStart.Shooters [i];

          if (lbShooters.SelCount> 1) and (not lbShooters.Selected [i]) then
            continue;

          if y+item_height>= p_height-bottomborder-footerheight then
            begin
              inc (page_idx);
              MakeNewPage;
            end;
          PrintShooter;
          inc (total_count);
          inc (events_count,sh.EventsCount);
          y:= y+item_height;
        end;

      y:= y+mm2py (10);
      if y+thl+thl>= p_height-bottomborder-footerheight then
        begin
          inc (page_idx);
          MakeNewPage;
        end;
      Font.Height:= font_height_large;
      Font.Style:= [];
      TextOut (leftborder+mm2px (10),y,format (Language ['AllShootersTotalCount'],[total_count]));
      inc (y,thl);
      TextOut (leftborder+mm2px (10),y,format (Language ['AllShootersEventsCount'],[events_count]));
    end;

  MakeSignature;

  table.Free;

  if APrinter is TPrinter then
    (APrinter as TPrinter).EndDoc
  else if APrinter is TPDFDocument then
    (APrinter as TPDFDocument).EndDoc;
end;

procedure TStartListShootersForm.PrintList;
var
  pd: TPrintProtocolDialog;
begin
  pd:= TPrintProtocolDialog.Create (self);
  pd.Caption:= Language ['PrintAllShootersPDCaption'];
  pd.ProtocolType:= ptStartNumbers;
  pd.ShowCopies:= true;
  if pd.Execute then
    begin
      PrintAllShooters (Printer);
    end;
  pd.Free;
end;

procedure TStartListShootersForm.ResetSearch;
begin
  if (fNumSearchStr<> '') or (fNameSearchStr<> '') then
    begin
      fNumSearchStr:= '';
      fNameSearchStr:= '';
      lbShooters.Invalidate;
    end;
end;

procedure TStartListShootersForm.SaveListToPDF;
var
  sd: TSaveDialog;
  doc: TPDFDocument;
begin
  sd:= TSaveDialog.Create (self);
  try
    sd.DefaultExt:= '*.pdf';
    sd.Filter:= 'Acrobat PDF (*.pdf)|*.pdf';
    sd.FilterIndex:= 0;
    sd.Title:= Language ['SaveAllShootersPDFCaption'];;
    sd.Options:= [ofOverwritePrompt,ofPathMustExist,ofEnableSizing,ofNoChangeDir];
    if sd.Execute then
      begin
        doc:= TPDFDocument.Create (nil);
        doc.FileName:= sd.FileName;
        doc.AutoLaunch:= false;
        try
          PrintAllShooters (doc);
        finally
          doc.Free;
        end;
      end;
  finally
    sd.Free;
  end;
end;

procedure TStartListShootersForm.sbHorzChange(Sender: TObject);
begin
  hcShooters.Left:= -sbHorz.Position;
  hcShooters.Width:= ClientWidth-hcShooters.Left;
  lbShooters.Invalidate;
end;

procedure TStartListShootersForm.set_StartList(const Value: TStartList);
begin
  fStart:= Value;
  if fStart= nil then
    begin
      Caption:= '';
      lbShooters.Count:= 0;
    end;
  Caption:= fStart.Info.CaptionText;
  lbShooters.Count:= fStart.Shooters.Count;
  if lbShooters.Count> 0 then
    begin
//      lbShooters.ClearSelection;
      lbShooters.ItemIndex:= 0;
      lbShooters.Selected [0]:= true;
    end;
end;

procedure TStartListShootersForm.UpdateFonts;
var
  i,w: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  btnPrint.ClientWidth:= Canvas.TextWidth (btnPrint.Caption)+32;
  btnPrint.ClientHeight:= Canvas.TextHeight (btnPrint.Caption)+12;
  btnSave.ClientWidth:= Canvas.TextWidth (btnSave.Caption)+32;
  btnSave.Height:= btnPrint.Height;
  btnPrint.Left:= 8;
  btnPrint.Top:= 8;
  btnSave.Left:= btnPrint.Left+btnPrint.Width+8;
  btnSave.Top:= btnPrint.Top;
  hcShooters.Canvas.Font:= Canvas.Font;
  fTextHeight:= hcShooters.Canvas.TextHeight ('Mg');
  hcShooters.Top:= btnPrint.Top*2+btnPrint.Height;
  hcShooters.ClientHeight:= fTextHeight+4;
  lbShooters.Left:= 0;
  lbShooters.Top:= hcShooters.Top+hcShooters.Height;
  lbShooters.Canvas.Font:= lbShooters.Font;
  lbShooters.ItemHeight:= lbShooters.Canvas.TextHeight ('Mg')*2+6;
  for i:= 0 to hcShooters.Sections.Count-1 do
    begin
      w:= hcShooters.Canvas.TextWidth (hcShooters.Sections [i].Text)+16;
      hcShooters.Sections [i].MinWidth:= w;
    end;
  with hcShooters.Sections [hcShooters.Sections.Count-1] do
    MinWidth:= MinWidth+GetSystemMetrics (SM_CXVSCROLL);
  hcShooters.Sections [0].MaxWidth:= hcShooters.Sections [0].MinWidth;
  Constraints.MinHeight:= Height-ClientHeight+hcShooters.Height+lbShooters.Height-lbShooters.ClientHeight+
    lbShooters.ItemHeight*10;
  Constraints.MinWidth:= 600;
  sbHorz.Left:= lbShooters.Left;
  sbHorz.Height:= GetSystemMetrics (SM_CYHSCROLL);
end;

procedure TStartListShootersForm.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TStartListShootersForm.UpdateScroll;
var
  w: integer;
begin
  w:= hcShooters.Sections [hcShooters.Sections.Count-1].Right;
  if w<= ClientWidth then
    begin
      sbHorz.Position:= 0;
      sbHorz.Enabled:= false;
      hcShooters.Left:= 0;
      hcShooters.Width:= ClientWidth;
      lbShooters.Invalidate;
    end
  else
    begin
      sbHorz.SmallChange:= 16;
      sbHorz.LargeChange:= 128;
      sbHorz.PageSize:= 1;
      sbHorz.Max:= w;
      sbHorz.PageSize:= ClientWidth;
      sbHorz.Enabled:= true;
      if sbHorz.Position+sbHorz.PageSize> sbHorz.Max then
        sbHorz.Position:= sbHorz.Max-sbHorz.PageSize;
      hcShooters.Left:= -sbHorz.Position;
      hcShooters.Width:= ClientWidth-hcShooters.Left;
      lbShooters.Invalidate;
    end;
end;

type
  PEB_EnumDataRec= ^TEB_EnumDataRec;
  TEB_EnumDataRec= record
    wnd: HWND;
    rgn: HRGN;
  end;

{function EB_EnumChildProc (hWnd: HWND; lParam: LPARAM): BOOL; stdcall;
var
  rgn: HRGN;
  r: TRect;
  p: TPoint;
  d: PEB_EnumDataRec;
begin
  d:= PEB_EnumDataRec (lParam);
  if (GetParent (hWnd)= d^.wnd) and (IsWindowVisible (hWnd)) then
    begin
      GetWindowRect (hWnd,r);
      rgn:= CreateRectRgnIndirect (r);
      p.X:= 0;
      p.Y:= 0;
      ScreenToClient (d^.wnd,p);
      OffsetRgn (rgn,p.X,p.Y);
      CombineRgn (d^.rgn,d^.rgn,rgn,RGN_DIFF);
      DeleteObject (rgn);
    end;
  Result:= true;
end;

procedure TStartListShootersForm.WMEraseBkgnd(var Msg: TMessage);
var
  d: TEB_EnumDataRec;
  DC: HDC;
begin
  DC:= Msg.WParam;
  d.wnd:= Handle;
  d.rgn:= CreateRectRgnIndirect (ClientRect);
  EnumChildWindows (d.wnd,@EB_EnumChildProc,integer (@d));
  FillRgn (DC,d.rgn,Canvas.Brush.Handle);
  DeleteObject (d.rgn);
  Msg.Result:= 0;
end;}

end.

