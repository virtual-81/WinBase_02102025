unit form_datepicker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ComCtrls, MyLanguage, ctrl_language, Vcl.StdCtrls;

type
  TDatePickerDialog = class(TForm)
    MonthCalendar1: TMonthCalendar;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
  private
    function get_Date: TDateTime;
    procedure set_Date(const Value: TDateTime);
    { Private declarations }
    procedure UpdateLanguage;
    procedure UpdateFonts;
  public
    { Public declarations }
    function Execute: boolean;
    property Date: TDateTime read get_Date write set_Date;
  end;

implementation

{$R *.dfm}

function TDatePickerDialog.Execute: boolean;
begin
  Result:= (ShowModal= mrOk);
end;

procedure TDatePickerDialog.FormCreate(Sender: TObject);
begin
  MonthCalendar1.Left:= 8;
  MonthCalendar1.Top:= 8;
  UpdateLanguage;
  UpdateFonts;
  Position:= poOwnerFormCenter;
end;

function TDatePickerDialog.get_Date: TDateTime;
begin
  Result:= MonthCalendar1.Date;
end;

procedure TDatePickerDialog.set_Date(const Value: TDateTime);
begin
  MonthCalendar1.Date:= Value;
end;

procedure TDatePickerDialog.UpdateFonts;
var
  w,w1,bh: integer;
begin
  MonthCalendar1.AutoSize:= false;
  MonthCalendar1.Width:= 16;
  MonthCalendar1.AutoSize:= true;
  Canvas.Font:= Font;
  bh:= Canvas.TextWidth ('Mg')+12;
  btnOk.ClientWidth:= Canvas.TextWidth (btnOk.Caption)+32;
  btnOk.ClientHeight:= bh;
  btnCancel.ClientWidth:= Canvas.TextWidth (btnCancel.Caption)+32;
  btnCancel.ClientHeight:= bh;
  if btnOk.Width< btnCancel.Width then
    btnOk.Width:= btnCancel.Width
  else
    btnCancel.Width:= btnOk.Width;
  w:= MonthCalendar1.Width;
  w1:= btnOk.Width+btnCancel.Width+16;
  if w< w1 then
    w:= w1;
  ClientWidth:= 16+w;
  btnOk.Top:= MonthCalendar1.Top+MonthCalendar1.Height+32;
  btnCancel.Top:= btnOk.Top;
  btnCancel.Left:= ClientWidth-8-btnCancel.Width;
  btnOk.Left:= btnCancel.Left-16-btnOk.Width;
  ClientHeight:= btnOk.Top+btnOk.Height+8;
end;

procedure TDatePickerDialog.UpdateLanguage;
begin
  LoadControlLanguage (self);
end;

end.

