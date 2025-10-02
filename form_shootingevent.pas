unit form_shootingevent;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs,

  Data,
  SysFont,

  MyStrings,
  MyLanguage,
  ctrl_language, Vcl.StdCtrls;

type
  TShootingEventDetails = class(TForm)
    lDate: TLabel;
    edtDate: TEdit;
    lEvent: TLabel;
    cbEvent: TComboBox;
    lTown: TLabel;
    edtTown: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    edtName: TEdit;
    lName: TLabel;
    edtShortName: TEdit;
    lShortName: TLabel;
    cbOther: TCheckBox;
    procedure cbOtherClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fData: TData;
    procedure UpdateLanguage;
    procedure UpdateFonts;
  public
    function Execute: boolean;
    function Date: TDateTime;
    function Event: TEventItem;
    function EventName: string;
    function ShortName: string;
    function Town: string;
    procedure SetData (AData: TData);
    procedure SetShootingEvent (AShootingEvent: TShootingEventItem);
  end;

implementation

{$R *.dfm}

{ TShootingEventDetails }

procedure TShootingEventDetails.cbOtherClick(Sender: TObject);
begin
  if cbOther.Checked then
    begin
      cbEvent.Enabled:= false;
      lEvent.Enabled:= false;
      edtName.Enabled:= true;
      lName.Enabled:= true;
      edtShortName.Enabled:= true;
      lShortName.Enabled:= true;
    end
  else
    begin
      if (cbEvent.ItemIndex< 0) and (fData.Events.Count> 0) then
        cbEvent.ItemIndex:= 0;
      cbEvent.Enabled:= true;
      lEvent.Enabled:= true;
      edtName.Enabled:= false;
      lName.Enabled:= false;
      edtShortName.Enabled:= false;
      lShortName.Enabled:= false;
    end;
end;

function TShootingEventDetails.Date: TDateTime;
var
  y,m,d,i: integer;
  s: string;
begin
  s:= Trim (edtDate.Text);
  Val (substr (s,'.',1),d,i);
  Val (substr (s,'.',2),m,i);
  Val (substr (s,'.',3),y,i);
  if y< 100 then
    begin
      if y< 80 then
        y:= 2000+y
      else
        y:= 1900+y;
    end;
  if d= 0 then
    d:= 1;
  if m= 0 then
    m:= 1;
  Result:= EncodeDate (y,m,d);
end;

function TShootingEventDetails.Event: TEventItem;
begin
	if (not cbOther.Checked) and (cbEvent.ItemIndex>= 0) then
		Result:= fData.Events.Items [cbEvent.ItemIndex]
	else
		Result:= nil;
end;

function TShootingEventDetails.EventName: string;
begin
  Result:= edtName.Text;
end;

function TShootingEventDetails.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TShootingEventDetails.FormCreate(Sender: TObject);
begin
  fData:= nil;
  Width:= Screen.Width div 2;
  if Width< 480 then
    Width:= 480;
  UpdateLanguage;
  UpdateFonts;
end;

procedure TShootingEventDetails.FormResize(Sender: TObject);
begin
  cbEvent.Width:= ClientWidth-cbEvent.Left;
  edtTown.Width:= ClientWidth-edtTown.Left;
  edtShortName.Width:= ClientWidth-edtShortName.Left;
  edtName.Width:= ClientWidth-edtName.Left;
//  cbOther.Width:= ClientWidth-cbOther.Left;

  btnCancel.Left:= ClientWidth-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-16-btnOk.Width;
end;

procedure TShootingEventDetails.SetData(AData: TData);
var
  i: integer;
begin
  fData:= AData;
  cbEvent.Clear;
  for i:= 0 to fData.Events.Count-1 do
    with fData.Events.Items [i] do
  		cbEvent.Items.Add (ShortName+' ('+Name+')');
end;

procedure TShootingEventDetails.SetShootingEvent(AShootingEvent: TShootingEventItem);
begin
  if AShootingEvent<> nil then
    begin
      edtDate.Text:= FormatDateTime ('dd.mm.yyyy',AShootingEvent.Date);
    	if AShootingEvent.Event<> nil then
    		cbEvent.ItemIndex:= AShootingEvent.Event.Index
      else
        cbEvent.ItemIndex:= -1;
      cbOther.Checked:= (AShootingEvent.Event= nil);
      edtShortName.Text:= AShootingEvent.ShortName;
      edtName.Text:= AShootingEvent.EventName;
      edtTown.Text:= AShootingEvent.Town;
    end
  else
    begin
      edtDate.Text:= '';
      cbEvent.ItemIndex:= 0;
      cbOther.Checked:= false;
      edtShortName.Text:= '';
      edtName.Text:= '';
      edtTown.Text:= '';
    end;
  cbOtherClick (self);
end;

function TShootingEventDetails.ShortName: string;
begin
  Result:= edtShortName.Text;
end;

function TShootingEventDetails.Town: string;
begin
  Result:= edtTown.Text;
end;

procedure TShootingEventDetails.UpdateFonts;
var
  w,i,y: integer;
begin
  Font:= SysFonts.MessageFont;
  Canvas.Font:= Font;

  w:= lDate.Width;
  if lEvent.Width> w then
    w:= lEvent.Width;
  if lTown.Width> w then
    w:= lTown.Width;
  if lName.Width> w then
    w:= lName.Width;
  if lShortName.Width> w then
    w:= lShortName.Width;

  y:= 8;
  edtDate.Top:= y;
  edtDate.Left:= w+8;
  edtDate.Width:= Canvas.TextWidth ('  00.00.0000  ')+32;
  lDate.Left:= w-lDate.Width;
  lDate.Top:= edtDate.Top+(edtDate.Height-lDate.Height) div 2;
  inc (y,edtDate.Height+8);

  cbEvent.Top:= y;
  cbEvent.Left:= w+8;
  lEvent.Left:= w-lEvent.Width;
  lEvent.Top:= cbEvent.Top+(cbEvent.Height-lEvent.Height) div 2;
  inc (y,cbEvent.Height+8);

  cbOther.Left:= w+8;
  cbOther.Top:= y;
  cbOther.ClientHeight:= Canvas.TextHeight ('Mg');
  cbOther.ClientWidth:= Canvas.TextWidth (cbOther.Caption)+cbOther.Height*2;
  inc (y,cbOther.Height+8);

  edtShortName.Top:= y;
  edtShortName.Left:= w+8;
  lShortName.Left:= w-lShortName.Width;
  lShortName.Top:= edtShortName.Top+(edtShortName.Height-lShortName.Height) div 2;
  inc (y,edtShortName.Height+8);

  edtName.Top:= y;
  edtName.Left:= w+8;
  lName.Left:= w-lName.Width;
  lName.Top:= edtName.Top+(edtName.Height-lName.Height) div 2;
  inc (y,edtName.Height+8);

  edtTown.Top:= y;
  edtTown.Left:= w+8;
  lTown.Left:= w-lTown.Width;
  lTown.Top:= edtTown.Top+(edtTown.Height-lTown.Height) div 2;
  inc (y,edtTown.Height+8);

  w:= Canvas.TextWidth (btnOk.Caption)+32;
  i:= Canvas.TextWidth (btnCancel.Caption)+32;
  if i> w then
    w:= i;
  btnOk.ClientWidth:= w;
  btnCancel.ClientWidth:= w;
  btnOk.ClientHeight:= Canvas.TextHeight ('Mg')+12;
  btnCancel.ClientHeight:= btnOk.ClientHeight;

  btnOk.Top:= y;
  btnCancel.Top:= btnOk.Top;

  ClientHeight:= btnOk.Top+btnOk.Height;
end;

procedure TShootingEventDetails.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

end.

