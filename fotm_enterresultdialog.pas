unit fotm_enterresultdialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.ExtCtrls;

type
  TEnterResultDialog = class(TForm)
    pnlGroup: TPanel;
    pnlShooter: TPanel;
    pnlDate: TPanel;
    pnlEvent: TPanel;
    pnlJunior: TPanel;
    Panel1: TPanel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.

