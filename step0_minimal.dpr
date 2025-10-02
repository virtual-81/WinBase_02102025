program step0_minimal;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  ShowMessage('Minimal test - SUCCESS!');
end.
