program wbd2ftp;

uses
  Forms,
  wbd2ftp_main in 'wbd2ftp_main.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
