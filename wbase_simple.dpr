program wbase_simple;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  CRC32 in 'CRC32.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  
  try
    // Простой тест запуска
    ShowMessage('WinBASE migration test - Delphi 12 compatibility check');
    
    // Тест CRC32
    ShowMessage('CRC32 test: ' + IntToStr(Crc32Buffer(nil, 0)));
    
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
  
  // Application.CreateForm(TMainForm, MainForm);
  // Application.Run;
end.
