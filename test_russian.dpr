program test_russian;

uses
  SysUtils, MyLanguage;

var
  lang: TMyLanguage;
begin
  lang := TMyLanguage.Create;
  try
    WriteLn('Testing Russian language loading...');
    
    if lang.LoadFromTextFile('russian.wbl') then
    begin
      WriteLn('Russian.wbl loaded successfully!');
      WriteLn('String count: ', lang.Count);
      
      // Проверяем несколько ключевых строк
      WriteLn('String 0: ', lang.GetString(0));
      WriteLn('String 1: ', lang.GetString(1));
      WriteLn('String 2: ', lang.GetString(2));
    end
    else
      WriteLn('Failed to load russian.wbl');
      
  finally
    lang.Free;
  end;
  
  WriteLn('Press Enter to exit...');
  ReadLn;
end.
