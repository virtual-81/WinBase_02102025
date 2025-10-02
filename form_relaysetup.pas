{$a-}
unit form_relaysetup;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, System.DateUtils,  Buttons,

  SysFont,
  Data,

  MyLanguage,
  ctrl_language;

type
  TRelaysSetupDialog = class(TForm)
    lbRelays: TListBox;
    dtDate: TDateTimePicker;
    dtTime: TDateTimePicker;
    lDate1: TLabel;
    lTime1: TLabel;
    gbStartTime1: TGroupBox;
    btnClose: TButton;
    gbFinal: TGroupBox;
    dtFinalDate: TDateTimePicker;
    dtFinalTime: TDateTimePicker;
    lFinalDate: TLabel;
    lFinalTime: TLabel;
    gbPos: TGroupBox;
    edtPos: TEdit;
    gbStartTime2: TGroupBox;
    lDate2: TLabel;
    lTime2: TLabel;
    dtDate2: TDateTimePicker;
    dtTime2: TDateTimePicker;
    sbAdd: TSpeedButton;
    sbDelete: TSpeedButton;
    cbFinal: TCheckBox;
    cbNewFinalFormat: TCheckBox;
    procedure cbFinalClick(Sender: TObject);
    procedure cbNewFinalFormatClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lbRelaysClick(Sender: TObject);
    procedure lbRelaysKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtPosKeyPress(Sender: TObject; var Key: Char);
    procedure dtDateKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbRelaysDblClick(Sender: TObject);
    procedure dtTimeKeyPress(Sender: TObject; var Key: Char);
    procedure btnCloseClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure dtFinalDateKeyPress(Sender: TObject; var Key: Char);
    procedure dtFinalTimeKeyPress(Sender: TObject; var Key: Char);
    procedure dtDate2KeyPress(Sender: TObject; var Key: Char);
    procedure dtTime2KeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    fEvent: TStartListEventItem;
    fActiveRelay: TStartListEventRelayItem;
    procedure set_Event(const Value: TStartListEventItem);
    procedure AddRelay;
    procedure DeleteRelay (index: integer);
    procedure Save;
    procedure SaveActiveRelay;
    procedure UpdateFonts;
    procedure UpdateLanguage;
  public
    { Public declarations }
    property StartEvent: TStartListEventItem read fEvent write set_Event;
    function Execute: boolean;
  end;

implementation

{$R *.dfm}

{ TRelaysSetupDialog }

function TRelaysSetupDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TRelaysSetupDialog.set_Event(const Value: TStartListEventItem);
var
  i: integer;
  y: integer;
begin
  fEvent:= Value;
  lbRelays.Clear;
  for i:= 0 to fEvent.Relays.Count-1 do
    lbRelays.Items.Add (format (RELAY_NO,[i+1]));
  lbRelays.Items.Add (Language ['AddRelay']);
  lbRelays.ItemIndex:= 0;
  lbRelaysClick (self);
  sbDelete.Enabled:= fEvent.Relays.Count> 0;
  cbFinal.Checked:= fEvent.HasFinal;
  cbNewFinalFormat.Checked:= fEvent.NewFinalFormat;
  cbNewFinalFormat.Enabled:= cbFinal.Checked and ((fEvent.Event.ShortName = 'ВП-60') or (fEvent.Event.ShortName = 'ПП-60'));
  dtFinalDate.Date:= fEvent.FinalTime;
  dtFinalTime.Time:= fEvent.FinalTime;

  case fEvent.Event.EventType of
    etRegular,etThreePosition2013: begin
      gbPos.Caption:= Language ['RegPositions'];
      gbStartTime1.Caption:= '';
      gbStartTime2.Caption:= '';
    end;
    etRapidFire: begin
      gbPos.Caption:= Language ['RFPositions'];
      gbStartTime1.Caption:= Language ['RFTime1'];
      gbStartTime2.Caption:= Language ['RFTime2'];
    end;
    etCenterFire,etCenterFire2013: begin
      gbPos.Caption:= Language ['CFPositions'];
      gbStartTime1.Caption:= Language ['CFTime1'];
      gbStartTime2.Caption:= Language ['CFTime2'];
    end;
    etMovingTarget,etMovingTarget2013: begin
      gbPos.Caption:= Language ['MTPositions'];
      gbStartTime1.Caption:= '';
      gbStartTime2.Caption:= '';
    end;
  end;

  gbPos.Top:= 0;
  edtPos.Top:= 8+Canvas.TextHeight (gbPos.Caption);
  gbPos.ClientHeight:= edtPos.Top+edtPos.Height+8;
  y:= gbPos.Top+gbPos.Height+8;
  gbStartTime1.Top:= y;

  dtDate.Top:= 8+Canvas.TextHeight (gbStartTime1.Caption);
  lDate1.Top:= dtDate.Top+(dtDate.Height-lDate1.Height) div 2;
  dtTime.Top:= dtDate.Top+dtDate.Height+4;
  lTime1.Top:= dtTime.Top+(dtTime.Height-lTime1.Height) div 2;
  gbStartTime1.ClientHeight:= dtTime.Top+dtTime.Height+8;
  dtDate2.Top:= 8+Canvas.TextHeight (gbStartTime2.Caption);
  lDate2.Top:= dtDate2.Top+(dtDate2.Height-lDate2.Height) div 2;
  dtTime2.Top:= dtDate2.Top+dtDate2.Height+4;
  lTime2.Top:= dtTime2.Top+(dtTime2.Height-lTime2.Height) div 2;
  gbStartTime2.ClientHeight:= dtTime2.Top+dtTime2.Height+8;

  y:= y+gbStartTime1.Height+8;
  case fEvent.Event.EventType of
    etRegular,etThreePosition2013: begin
      gbStartTime2.Visible:= false;
    end;
    etRapidFire: begin
      gbStartTime2.Visible:= true;
      gbStartTime2.Top:= y;
      y:= y+gbStartTime2.Height+8;
    end;
    etCenterFire,etCenterFire2013: begin
      gbStartTime2.Visible:= true;
      gbStartTime2.Top:= y;
      y:= y+gbStartTime2.Height+8;
    end;
    etMovingTarget,etMovingTarget2013: begin
      gbStartTime2.Visible:= false;
    end;
  end;

  if fEvent.Event.FinalPlaces> 0 then
    begin
      cbFinal.Visible:= true;
      cbFinal.Top:= y;
      y:= y+cbFinal.Height+8;
      if cbFinal.Checked then
        begin
          dtFinalDate.Enabled:= true;
          dtFinalTime.Enabled:= true;
        end
      else
        begin
          dtFinalDate.Enabled:= false;
          dtFinalTime.Enabled:= false;
        end;
      gbFinal.Visible:= true;
      gbFinal.Top:= y;
      y:= y+gbFinal.Height+8;
    end
  else
    begin
      cbFinal.Visible:= false;
      gbFinal.Visible:= false;
    end;

  btnClose.Top:= y;
  lbRelays.Height:= y-8;
  sbAdd.Top:= lbRelays.Top+lbRelays.Height+2;
  sbDelete.Top:= sbAdd.Top;
  ClientHeight:= btnClose.Top+btnClose.Height;
  Position:= poScreenCenter;
end;

procedure TRelaysSetupDialog.UpdateFonts;
var
  bh: integer;
  dw,w: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;
  bh:= Canvas.TextHeight ('Mg')+12;
  btnClose.ClientHeight:= bh;
  btnClose.ClientWidth:= Canvas.TextWidth (btnClose.Caption)+32;
  edtPos.Top:= 8+Canvas.TextHeight (gbPos.Caption);
  gbStartTime1.Left:= lbRelays.Left+lbRelays.Width+16;
  gbStartTime2.Left:= gbStartTime1.Left;
  gbPos.Left:= gbStartTime1.Left;
  gbFinal.Left:= gbStartTime1.Left;
  cbFinal.Left:= gbFinal.Left;
  gbPos.ClientHeight:= edtPos.Top+edtPos.Height+8;
  gbStartTime1.Top:= gbPos.Top+gbPos.Height+8;
  gbStartTime2.Top:= gbStartTime1.Top+gbStartTime1.Height+8;
  dtFinalDate.Top:= 8+Canvas.TextHeight (gbFinal.Caption);
  lFinalDate.Top:= dtFinalDate.Top+(dtFinalDate.Height-lFinalDate.Height) div 2;
  dtFinalTime.Top:= dtFinalDate.Top+dtFinalDate.Height+4;
  lFinalTime.Top:= dtFinalTime.Top+(dtFinalTime.Height-lFinalTime.Height) div 2;
  gbFinal.ClientHeight:= dtFinalTime.Top+dtFinalTime.Height+8;
  dw:= Canvas.TextWidth (FormatDateTime (' dd/mm/yyyy ',Now))+dtDate.ClientHeight+4;
  cbFinal.ClientHeight:= Canvas.TextHeight ('Mg');
  cbFinal.ClientWidth:= cbFinal.Height+8+Canvas.TextWidth (cbFinal.Caption);
  dtDate.ClientWidth:= dw;
  dtTime.ClientWidth:= dw;
  dtDate2.ClientWidth:= dw;
  dtTime2.ClientWidth:= dw;
  dtFinalDate.ClientWidth:= dw;
  dtFinalTime.ClientWidth:= dw;
  w:= lDate1.Width;
  if lTime1.Width> w then
    w:= lTime1.Width;
  if lDate2.Width> w then
    w:= lDate2.Width;
  if lTime2.Width> w then
    w:= lTime2.Width;
  if lFinalDate.Width> w then
    w:= lFinalDate.Width;
  if lFinalTime.Width> w then
    w:= lFinalTime.Width;
  lDate1.Left:= w+8-lDate1.Width;
  lTime1.Left:= w+8-lTime1.Width;
  lDate2.Left:= w+8-lDate2.Width;
  lTime2.Left:= w+8-lTime2.Width;
  lFinalDate.Left:= w+8-lFinalDate.Width;
  lFinalTime.Left:= w+8-lFinalTime.Width;
  dtDate.Left:= w+16;
  dtTime.Left:= w+16;
  dtDate2.Left:= w+16;
  dtTime2.Left:= w+16;
  dtFinalDate.Left:= w+16;
  dtFinalTime.Left:= w+16;
  gbStartTime1.ClientWidth:= w+16+dtDate.Width+8;
  gbStartTime2.Width:= gbStartTime1.Width;
  gbFinal.Width:= gbStartTime2.Width;
  gbPos.Width:= gbFinal.Width;
  edtPos.Left:= 8;
  edtPos.Width:= gbPos.ClientWidth-16;
  ClientWidth:= gbPos.Left+gbPos.Width;
  btnClose.Left:= ClientWidth-btnClose.Width;
  sbDelete.Left:= lbRelays.Left+lbRelays.Width-sbDelete.Width;
  sbAdd.Left:= sbDelete.Left-2-sbAdd.Width;
end;

procedure TRelaysSetupDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
  cbNewFinalFormat.Caption:= Language ['NEW_FINAL_FORMAT_DESCRIPTION'];
end;

procedure TRelaysSetupDialog.lbRelaysClick(Sender: TObject);
begin
  if (fActiveRelay<> nil) and (lbRelays.ItemIndex= fActiveRelay.Index) then
    exit;
  SaveActiveRelay;
  fActiveRelay:= nil;
  if (lbRelays.ItemIndex>= 0) and (lbRelays.ItemIndex< fEvent.Relays.Count) then
    begin
      fActiveRelay:= fEvent.Relays [lbRelays.ItemIndex];
      edtPos.Enabled:= true;
      edtPos.Text:= fActiveRelay.PositionsStr;
      dtDate.Enabled:= true;
      dtDate.Date:= fActiveRelay.StartTime;
      dtTime.Enabled:= true;
      dtTime.Time:= fActiveRelay.StartTime;
      dtDate2.Enabled:= true;
      dtDate2.Date:= fActiveRelay.StartTime2;
      dtTime2.Enabled:= true;
      dtTime2.Time:= fActiveRelay.StartTime2;
      sbDelete.Enabled:= true;
    end
  else
    begin
      edtPos.Enabled:= false;
      dtDate.Enabled:= false;
      dtTime.Enabled:= false;
      dtDate2.Enabled:= false;
      dtTime2.Enabled:= false;
      sbDelete.Enabled:= false;
    end;
end;

procedure TRelaysSetupDialog.lbRelaysKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_RETURN: begin
      Key:= 0;
      lbRelaysDblClick (self);
    end;
    VK_ESCAPE: begin
      Key:= 0;
      Close;
    end;
    VK_DELETE: begin
      Key:= 0;
      DeleteRelay (lbRelays.ItemIndex);
    end;
  end;
end;

procedure TRelaysSetupDialog.edtPosKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #27: begin
      lbRelays.SetFocus;
      Key:= #0;
    end;
    #13: begin
      Key:= #0;
      dtDate.SetFocus;
    end;
  end;
end;

procedure TRelaysSetupDialog.dtDateKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #27: begin
      Key:= #0;
      lbRelays.SetFocus;
    end;
    #13: begin
      Key:= #0;
      dtTime.SetFocus;
    end;
  end;
end;

procedure TRelaysSetupDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Save;
  ModalResult:= mrOk;
end;

procedure TRelaysSetupDialog.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
  UpdateFonts;
end;

procedure TRelaysSetupDialog.lbRelaysDblClick(Sender: TObject);
begin
  if (lbRelays.ItemIndex>= 0) and (lbRelays.ItemIndex< fEvent.Relays.Count) then
    edtPos.SetFocus
  else if lbRelays.ItemIndex= fEvent.Relays.Count then
    begin
      AddRelay;
    end;
end;

procedure TRelaysSetupDialog.dtTimeKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #27,#13: begin
      Key:= #0;
      if gbStartTime2.Visible then
        dtDate2.SetFocus
      else
        lbRelays.SetFocus;
    end;
  end;
end;

procedure TRelaysSetupDialog.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TRelaysSetupDialog.btnAddClick(Sender: TObject);
begin
  AddRelay;
end;

procedure TRelaysSetupDialog.AddRelay;
var
  r: TStartListEventRelayItem;
begin
  r:= fEvent.Relays.Add;
  r.PreconfigureStartTime;
  r.SetPositionsStr ('');
  lbRelays.Items.Insert (r.Index,format (RELAY_NO,[r.Index+1]));
  lbRelays.ItemIndex:= r.Index;
  lbRelaysClick (self);
  edtPos.SetFocus;
end;

procedure TRelaysSetupDialog.btnDeleteClick(Sender: TObject);
begin
  DeleteRelay (lbRelays.ItemIndex);
end;

procedure TRelaysSetupDialog.cbFinalClick(Sender: TObject);
begin
  if cbFinal.Checked then
    begin
      dtFinalDate.Enabled:= true;
      dtFinalTime.Enabled:= true;
    end
  else
    begin
      dtFinalDate.Enabled:= false;
      dtFinalTime.Enabled:= false;
    end;
  cbNewFinalFormat.Enabled:= cbFinal.Checked and ((fEvent.Event.ShortName = 'ВП-60') or (fEvent.Event.ShortName = 'ПП-60'));
  if not cbFinal.Checked then
    cbNewFinalFormat.Checked:= False;
end;

procedure TRelaysSetupDialog.cbNewFinalFormatClick(Sender: TObject);
begin
  // Новый формат доступен только для ВП-60 и ПП-60
  if cbNewFinalFormat.Checked and not ((fEvent.Event.ShortName = 'ВП-60') or (fEvent.Event.ShortName = 'ПП-60')) then
    begin
      ShowMessage('Новый формат финала доступен только для упражнений ВП-60 и ПП-60');
      cbNewFinalFormat.Checked:= False;
    end;
end;

procedure TRelaysSetupDialog.DeleteRelay(index: integer);
begin
  if (index< 0) or (index>= fEvent.Relays.Count) then
    exit;
  fEvent.Relays [index].Free;
  lbRelays.Items.Delete (lbRelays.Count-2);
  lbRelays.ItemIndex:= index;
  fActiveRelay:= nil;
  lbRelaysClick (lbRelays);
end;

procedure TRelaysSetupDialog.Save;
begin
  SaveActiveRelay;
  if fEvent.Event.FinalPlaces> 0 then
    begin
      fEvent.FinalTime:= DateOf (dtFinalDate.Date) + TimeOf (dtFinalTime.Time);
      fEvent.HasFinal:= cbFinal.Checked;
      fEvent.NewFinalFormat:= cbNewFinalFormat.Checked;
    end;
end;

procedure TRelaysSetupDialog.SaveActiveRelay;
begin
  if fActiveRelay<> nil then
    begin
      if not fActiveRelay.SetPositionsStr (edtPos.Text) then
        MessageDlg (Language ['InvalidPositionsStr'],mtError,[mbOk],0);
      fActiveRelay.StartTime:= DateOf (dtDate.Date) + TimeOf (dtTime.Time);
      fActiveRelay.StartTime2:= DateOf (dtDate2.Date) + TimeOf (dtTime2.Time);
    end;
end;

procedure TRelaysSetupDialog.dtFinalDateKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #13: begin
      Key:= #0;
      dtFinalTime.SetFocus;
    end;
    #27: begin
      Key:= #0;
      lbRelays.SetFocus;
    end;
  end;
end;

procedure TRelaysSetupDialog.dtFinalTimeKeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #27,#13: begin
      Key:= #0;
      lbRelays.SetFocus;
    end;
  end;
end;

procedure TRelaysSetupDialog.dtDate2KeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #27: begin
      Key:= #0;
      lbRelays.SetFocus;
    end;
    #13: begin
      Key:= #0;
      dtTime2.SetFocus;
    end;
  end;
end;

procedure TRelaysSetupDialog.dtTime2KeyPress(Sender: TObject;
  var Key: Char);
begin
  case Key of
    #27,#13: begin
      Key:= #0;
      lbRelays.SetFocus;
    end;
  end;
end;

end.


