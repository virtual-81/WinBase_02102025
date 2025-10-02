program step3_mystrings;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  MyStrings in 'MyStrings.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  
  try
    ShowMessage('Step 3: MyStrings test - FillStr result: "' + FillStr('test', 10, '*') + '"');
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
end.
