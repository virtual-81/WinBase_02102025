program step1_basic;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  
  try
    ShowMessage('Step 1: Basic Delphi 12 test - SUCCESS!');
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
end.
