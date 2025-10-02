program step2_crc32;

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
    ShowMessage('Step 2: CRC32 test - CRC of empty data: ' + IntToStr(Crc32Buffer(nil, 0)));
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
end.
