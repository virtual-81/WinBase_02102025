{$apptype console}
program WbdStat;

uses
  Windows,
  Classes,
  SysUtils,
  Data;

var
  d: TData;
  ms: TMemoryStream;

  procedure Stat (const n: AnsiString);
  begin
    writeln (n);
    d:= TData.Create;
    try
      d.LoadFromFile (n);
    except
      writeln ('Error reading '+n);
      d.Free;
      exit;
    end;

    ms:= TMemoryStream.Create;
    //d.Check;
    //d.DupeResults;

    writeln (d.Name);
    writeln ('Image folder: ',d.ImagesFolder);

    d.WriteToStream (ms);
    writeln ('Uncompressed size ',ms.Size);
    ms.Clear;

    d.Events.WriteToStream (ms);
    writeln ('Number of events: ',d.Events.Count,' size ',ms.Size);
    ms.Clear;

    d.Championships.WriteToStream (ms);
    writeln ('Number of championships: ',d.Championships.Count,' size ',ms.Size);
    ms.Clear;

    d.Qualifications.WriteToStream (ms);
    writeln ('Number of qualifications ',d.Qualifications.Count,' size ',ms.Size);
    ms.Clear;

    d.Groups.WriteToStream (ms);
    writeln ('Number of groups ',d.Groups.Count,' size ',ms.Size);
    ms.Clear;

    d.ShootingChampionships.WriteToStream (ms);
    writeln ('Number of shooting championships ',d.ShootingChampionships.Count,' size ',ms.Size);
    ms.Clear;

    d.Regions.WriteToStream (ms);
    writeln ('Number of regions ',d.Regions.Count,' size ',ms.Size);
    ms.Clear;

    d.Districts.WriteToStream (ms);
    writeln ('Number of districts ',d.Districts.Count,' size ',ms.Size);
    ms.Clear;

    d.StartLists.WriteToStream (ms);
    writeln ('Number of start lists ',d.StartLists.Count,' size ',ms.Size);
    ms.Clear;

    writeln;
    ms.Free;
    d.Free;
  end;

var
  i: integer;
begin
  if ParamCount< 1 then
    exit;

  for i:= 1 to ParamCount do
    Stat (ParamStr (i));

  readln;
end.
