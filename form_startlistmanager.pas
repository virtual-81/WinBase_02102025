{$a-}
unit form_startlistmanager;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,

  Data,
  MyStrings,
  SysFont,

  MyLanguage,
  ctrl_language,

  form_startinfo;


type
  TStartListRec= record
    start: TStartList;
    datefrom,datetill: TDateTime;
    datestr: string;
  end;

  TStartListManager = class(TForm)
    Panel1: TPanel;
    lbStarts: TListBox;
    btnAdd: TButton;
    btnDelete: TButton;
    btnOpen: TButton;
    btnEdit: TButton;
    procedure lbStartsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbStartsDblClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
  private
    { Private declarations }
    fData: TData;
    fTextHeight: integer;
    fStarts: array of TStartListRec;
    procedure UpdateData;
    procedure set_Data(const Value: TData);
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property Data: TData read fData write set_Data;
    function Execute: boolean;
  end;

implementation

uses System.Math;

{$R *.dfm}

{ TStartListManager }

procedure TStartListManager.set_Data(const Value: TData);
begin
  fData:= Value;
  UpdateData;
end;

procedure TStartListManager.UpdateData;
var
  i,j,idx: integer;
  s: TStartListRec;
begin
  if fData= nil then
    exit;
  SetLength (fStarts,fData.StartLists.Count);
  for i:= 0 to Length (fStarts)-1 do
    begin
      fStarts [i].start:= fData.StartLists [i];
      fStarts [i].datefrom:= fStarts [i].start.DateFrom;
      fStarts [i].datetill:= fStarts [i].start.DateTill;
      fStarts [i].datestr:= fStarts [i].start.DatesFromTillStr;
    end;
  for i:= 0 to Length (fStarts)-2 do
    begin
      idx:= i;
      for j:= i+1 to Length (fStarts)-1 do
        if fStarts [j].datefrom> fStarts [idx].datefrom then
          idx:= j;
      if idx<> i then
        begin
          s:= fStarts [idx];
          fStarts [idx]:= fStarts [i];
          fStarts [i]:= s;
        end;
    end;
  lbStarts.Count:= fData.StartLists.Count;
  if lbStarts.Count> 0 then
    begin
      if fData.ActiveStart<> nil then
        begin
          for i:= 0 to Length (fStarts)-1 do
            if fStarts [i].start= fData.StartLists.ActiveStart then
              begin
                lbStarts.ItemIndex:= i;
                break;
              end;
        end
      else
        lbStarts.ItemIndex:= 0;
    end;
  Caption:= format (Language ['StartListManager'],[fData.Name]);
end;

procedure TStartListManager.UpdateFonts;
var
  bh: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  lbStarts.Canvas.Font:= lbStarts.Font;
  fTextHeight:= lbStarts.Canvas.TextHeight ('Mg');
  lbStarts.ItemHeight:= fTextHeight*2+4;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnOpen.Top:= 8;
  btnOpen.Left:= 8;
  btnOpen.ClientWidth:= Canvas.TextWidth (btnOpen.Caption)+32;
  btnOpen.ClientHeight:= bh;
  btnAdd.Top:= 8;
  btnAdd.ClientWidth:= Canvas.TextWidth (btnAdd.Caption)+32;
  btnAdd.Left:= btnOpen.Left+btnOpen.Width+8;
  btnAdd.ClientHeight:= bh;
  btnDelete.Top:= 8;
  btnDelete.ClientWidth:= Canvas.TextWidth (btnDelete.Caption)+32;
  btnDelete.Left:= btnAdd.Left+btnAdd.Width+8;
  btnDelete.ClientHeight:= bh;
  btnEdit.Top:= 8;
  btnEdit.ClientWidth:= Canvas.TextWidth (btnEdit.Caption)+32;
  btnEdit.Left:= btnDelete.Left+btnDelete.Width+8;
  btnEdit.ClientHeight:= bh;
  Panel1.ClientHeight:= btnOpen.Top+btnOpen.Height+8;
  Constraints.MinWidth:= Width-ClientWidth+8+btnOpen.Width+8+btnAdd.Width+8+btnDelete.Width+8+btnEdit.Width+8;
  Constraints.MinHeight:= Height-ClientHeight+Panel1.Height+lbStarts.Height-lbStarts.ClientHeight+lbStarts.ItemHeight*5;
end;

procedure TStartListManager.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

procedure TStartListManager.lbStartsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with lbStarts.Canvas do
    begin
      FillRect (Rect);
      if (Index< 0) or (Index>= Length (fStarts)) then
        exit;
      if fData.ActiveStart= fStarts [Index].start then
        Font.Style:= [fsBold]
      else
        Font.Style:= [];
      TextOut (Rect.Left+2,Rect.Top+2,fStarts [Index].start.Info.CaptionText);
      Font.Style:= [];
      TextOut (Rect.Left+2,Rect.Top+2+fTextHeight,fStarts [index].datestr);
    end;
end;

function TStartListManager.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TStartListManager.FormCreate(Sender: TObject);
begin
  Width:= Screen.Width div 2;
  Height:= Screen.Height div 2;
  Position:= poScreenCenter;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TStartListManager.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
    VK_RETURN: begin
      Key:= 0;
      lbStartsDblClick (lbStarts);
    end;
    VK_INSERT: begin
      Key:= 0;
      btnAdd.Click;
    end;
    VK_DELETE: begin
      Key:= 0;
      btnDelete.Click;
    end;
    VK_F4: begin
      Key:= 0;
      btnEdit.Click;
    end;
  end;
end;

procedure TStartListManager.lbStartsDblClick(Sender: TObject);
begin
  if lbStarts.ItemIndex>= 0 then
    begin
      fData.StartLists.ActiveStart:= fStarts [lbStarts.ItemIndex].start;
      Close;
    end;
end;

procedure TStartListManager.btnOpenClick(Sender: TObject);
begin
  lbStartsDblClick (lbStarts);
  lbStarts.SetFocus;
end;

procedure TStartListManager.btnDeleteClick(Sender: TObject);
var
  idx: integer;
  ti: integer;
  s: TStartList;
begin
  if lbStarts.ItemIndex>= 0 then
    begin
      s:= fStarts [lbStarts.ItemIndex].start;
      if MessageDlg (format (Language ['DeleteStartPrompt'],[s.Info.TitleText]),mtConfirmation,[mbYes,mbNo],0)= idYes then
        begin
          idx:= lbStarts.ItemIndex;
          ti:= lbStarts.TopIndex;
          if fData.ActiveStart= s then
            fData.StartLists.ActiveStart:= nil;
//          s.DestroyShootingChampionshipIfEmpty;
          fData.StartLists.Delete (s.Index);
          UpdateData;
          if idx>= Length (fStarts) then
            begin
              idx:= Length (fStarts)-1;
              if ti> idx then
                ti:= idx;
            end;
          lbStarts.ItemIndex:= idx;
          lbStarts.TopIndex:= ti;
        end;
    end;
  lbStarts.SetFocus;
end;

procedure TStartListManager.btnAddClick(Sender: TObject);
var
  st: TStartList;
  SI: TStartInfoDialog;
  res: boolean;
  ti: integer;
begin
  st:= fData.StartLists.Add;
  si:= TStartInfoDialog.Create (self);
  si.Info:= st.Info;
  si.Caption:= Language ['NewStart'];
  res:= si.Execute;
  si.Free;
  lbStarts.SetFocus;
  if not res then
    begin
      st.Free;
      exit;
    end;
//  st.CreateShootingChampionship;
  ti:= lbStarts.TopIndex;
  UpdateData;
  lbStarts.TopIndex:= ti;
  lbStarts.ItemIndex:= st.Index;
end;

procedure TStartListManager.btnEditClick(Sender: TObject);
var
  st: TStartList;
  si: TStartInfoDialog;
begin
  if (lbStarts.ItemIndex>= 0) and (lbStarts.ItemIndex< fData.StartLists.Count) then
    begin
      st:= fData.StartLists [lbStarts.ItemIndex];
      si:= TStartInfoDialog.Create (self);
      si.Info:= st.Info;
      si.Caption:= st.Info.CaptionText;
      si.Execute;
      si.Free;
      lbStarts.SetFocus;
      lbStarts.Invalidate;
    end;
end;

end.

