program wbdview;

uses
  Forms,
  wbdviewer_main in 'wbdviewer_main.pas';

//{$R *.res}

begin
	Application.Initialize;
	Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
