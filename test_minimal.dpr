program test_minimal;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  
  try
    ShowMessage('Minimal test - �������� ����������!');
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
end.
