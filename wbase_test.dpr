program wbase_test;

uses
  System.SysUtils,
  Vcl.Forms,
  Main in 'Main.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  try
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  except
    on E: Exception do
      Writeln('Error: ', E.Message);
  end;
end.
