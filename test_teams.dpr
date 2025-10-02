program test_teams;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  form_teams in 'form_teams.pas' {FormTeams};

begin
  try
    WriteLn('Testing form_teams compilation...');
    WriteLn('Success!');
  except
    on E: Exception do
      WriteLn(E.ClassName, ': ', E.Message);
  end;
end.
