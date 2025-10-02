program console_test;

{$APPTYPE CONSOLE}

uses
  System.SysUtils;

begin
  try
    Writeln('Console test - SUCCESS!');
    Writeln('Press Enter to exit...');
    Readln;
  except
    on E: Exception do
      Writeln('Error: ', E.ClassName, ': ', E.Message);
  end;
end.
