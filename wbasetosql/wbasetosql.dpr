{$APPTYPE CONSOLE}
program wbasetosql;

uses
  classes,
  SysUtils,
  Data,
  pasmysql;

var
  d: TData;
  sql: TMyDB;
  i,j,k: integer;
  res: TResultItem;
  gr: TGroupItem;
  cmd: string;
  sh: TShooterItem;
  gender: string;
  society: string;
  image: string;
  reg: TAbbrRec;
  junior: string;
  eventshortname: string;
  s: string;
  ev: TEventItem;
  rating: integer;

  groups,shooters,regions,districts,results,events,ratings: TStrings;

  function _sf (s: string): string;
  begin
    if s= '' then
      Result:= '\N'
    else
      Result:= Trim (s);
  end;

begin
  d:= TData.Create;

  try
    d.LoadFromFile (paramstr (1));
    writeln ('data loaded from file ',paramstr (1));
  except
    writeln ('Cannot load data from ',paramstr (1));
    d.Free;
    exit;
  end;

  groups:= TStringList.Create;
  shooters:= TStringList.Create;
  regions:= TStringList.Create;
  districts:= TStringList.Create;
  results:= TStringList.Create;
  events:= TStringList.Create;
  ratings:= TStringList.Create;

  for i:= 0 to d.Regions.Count-1 do
    begin
      reg:= d.Regions.Items [i];
      regions.Add (_sf (reg.abbr)+#9+_sf (reg.name));
    end;
  regions.SaveToFile ('regions.sql.txt');

  for i:= 0 to d.Districts.Count-1 do
    begin
      reg:= d.Districts.Items [i];
      districts.Add (_sf (reg.abbr)+#9+_sf (reg.name));
    end;
  districts.SaveToFile ('districts.sql.txt');

  for i:= 0 to d.Events.Count-1 do
    begin
      ev:= d.Events.Items [i];
      s:= _sf (ev.Tag)+#9+_sf (ev.ShortName)+#9+_sf (ev.Name)+#9+_sf (ev.Code);
      events.Add (s);
    end;
  events.SaveToFile ('events.sql.txt');

  for i:= 0 to d.Groups.Count-1 do
    begin
      gr:= d.Groups.Items [i];
      s:= GUIDToString (gr.GID)+#9+_sf (gr.Name);
      groups.Add (s);

      for j:= 0 to gr.Shooters.Count-1 do
        begin
          sh:= gr.Shooters.Items [j];
          case sh.Gender of
            Male: gender:= 'm';
            Female: gender:= 'f';
          end;
          if sh.SportSociety<> nil then
            society:= sh.SportSociety.Name
          else
            society:= '';
          if sh.ImagesCount> 0 then
            image:= sh.Images [0]
          else
            image:= '';
          s:= GUIDToString (gr.GID)+#9+GUIDToString (sh.PID)+#9+_sf (sh.ISSFID)+#9+
            _sf (sh.Surname)+#9+_sf (sh.Name)+#9+_sf (sh.StepName)+#9+
            _sf (gender)+#9+_sf (sh.BirthYearStr)+#9+_sf (sh.BirthDateStr)+#9+
            _sf (sh.RegionAbbr1)+#9+_sf (sh.RegionAbbr2)+#9+_sf (sh.DistrictAbbr)+#9+
            _sf (society)+#9+_sf (sh.SportClub)+#9+_sf (sh.Town)+#9+
            _sf (sh.QualificationName)+#9+_sf (sh.Address)+#9+_sf (sh.Phone)+#9+
            _sf (sh.Passport)+#9+_sf (sh.Coaches)+#9+_sf (sh.Weapons)+#9+
            _sf (sh.Memo)+#9+_sf (image);
          shooters.Add (s);
          for k:= 0 to d.Events.Count-1 do
            begin
              ev:= d.Events.Items [k];
              rating:= sh.Results.TotalRating (ev);
              if rating> 0 then
                begin
                  s:= GUIDToString (sh.PID)+#9+_sf (ev.ShortName)+#9+IntToStr (rating);
                  ratings.Add (s);
                end;
            end;
          for k:= 0 to sh.Results.Count-1 do
            begin
              res:= sh.Results.Items [k];
              if res.Junior then
                junior:= 'j'
              else
                junior:= '';
              if res.Event<> nil then
                eventshortname:= res.Event.ShortName
              else
                eventshortname:= '';
              s:= GUIDToString (sh.PID)+#9+FormatDateTime ('yyyy-mm-dd',res.Date)+#9+
                _sf (res.ChampionshipName)+#9+_sf (eventshortname)+#9+
                _sf (res.EventName)+#9+_sf (res.Country)+#9+_sf (res.Town)+#9+
                _sf (junior)+#9+_sf (res.RankStr)+#9+IntToStr (res.Competition)+#9+
                _sf (res.FinalStr)+#9+_sf (res.TotalStr)+#9+IntToStr (res.Rating);
              results.Add (s);
            end;
        end;
    end;
  groups.SaveToFile ('groups.sql.txt');
  shooters.SaveToFile ('shooters.sql.txt');
  results.SaveToFile ('results.sql.txt');
  ratings.SaveToFile ('ratings.sql.txt');

  sql:= TMyDB.Create (nil);
  if sql.Connect ('localhost','root','hatobaka','winbase') then
    begin
      writeln ('connected to database');
      sql.Query ('SET CHARACTER SET cp1251');
      sql.Query ('DELETE FROM groups');
      sql.Query ('DELETE FROM shooters');
      sql.Query ('DELETE FROM regions');
      sql.Query ('DELETE FROM districts');
      sql.Query ('DELETE FROM results');
      sql.Query ('DELETE FROM events');
      sql.Query ('DELETE FROM ratings');
      if not sql.Query ('LOAD DATA LOCAL INFILE "groups.sql.txt" INTO TABLE groups LINES TERMINATED BY ''\r\n''') then
        writeln (sql.LastError);
      if not sql.Query ('LOAD DATA LOCAL INFILE "regions.sql.txt" INTO TABLE regions LINES TERMINATED BY ''\r\n''') then
        writeln (sql.LastError);
      if not sql.Query ('LOAD DATA LOCAL INFILE "districts.sql.txt" INTO TABLE districts LINES TERMINATED BY ''\r\n''') then
        writeln (sql.LastError);
      if not sql.Query ('LOAD DATA LOCAL INFILE "shooters.sql.txt" INTO TABLE shooters LINES TERMINATED BY ''\r\n''') then
        writeln (sql.LastError);
      if not sql.Query ('LOAD DATA LOCAL INFILE "results.sql.txt" INTO TABLE results LINES TERMINATED BY ''\r\n''') then
        writeln (sql.LastError);
      if not sql.Query ('LOAD DATA LOCAL INFILE "events.sql.txt" INTO TABLE events LINES TERMINATED BY ''\r\n''') then
        writeln (sql.LastError);
      if not sql.Query ('LOAD DATA LOCAL INFILE "ratings.sql.txt" INTO TABLE ratings LINES TERMINATED BY ''\r\n''') then
        writeln (sql.LastError);


    {

      for i:= 0 to d.Groups.Count-1 do
        begin
          gr:= d.Groups.Items [i];
          cmd:= format ('INSERT INTO groups VALUES (''%s'',''%s'')',[GUIDToString (gr.GID),gr.Name]);
          if not sql.Query (cmd) then
            begin
              writeln (sql.ErrorMessage);
            end;
          for j:= 0 to gr.Shooters.Count-1 do
            begin
              sh:= gr.Shooters.Items [j];
              case sh.Gender of
                Male: gender:= 'm';
                Female: gender:= 'f';
              end;
              if sh.Society<> nil then
                society:= sh.Society.Name
              else
                society:= '';
              if sh.ImagesCount> 0 then
                image:= sh.Images [0]
              else
                image:= '';
              cmd:= 'INSERT INTO shooters VALUES(';
              cmd:= cmd+''''+GUIDToString (gr.GID)+''',';
              cmd:= cmd+''''+GUIDToString (sh.PID)+''',';
              cmd:= cmd+''''+sh.ISSFID+''',';
              cmd:= cmd+''''+sh.Surname+''',';
              cmd:= cmd+''''+sh.Name+''',';
              cmd:= cmd+''''+sh.StepName+''',';
              cmd:= cmd+''''+gender+''',';
              cmd:= cmd+''''+sh.BirthYearStr+''',';
              cmd:= cmd+''''+sh.BirthDateStr+''',';
              cmd:= cmd+''''+sh.RegionAbbr1+''',';
              cmd:= cmd+''''+sh.RegionAbbr2+''',';
              cmd:= cmd+''''+sh.DistrictAbbr+''',';
              cmd:= cmd+''''+society+''',';
              cmd:= cmd+''''+sh.SportClub+''',';
              cmd:= cmd+''''+sh.Town+''',';
              cmd:= cmd+''''+sh.QualificationName+''',';
              cmd:= cmd+''''+sh.Address+''',';
              cmd:= cmd+''''+sh.Phone+''',';
              cmd:= cmd+''''+sh.Passport+''',';
              cmd:= cmd+''''+sh.Coaches+''',';
              cmd:= cmd+''''+sh.Weapons+''',';
              cmd:= cmd+''''+sh.Memo+''',';
              cmd:= cmd+''''+image+'''';
              cmd:= cmd+')';
              if not sql.Query (cmd) then
                begin
                  writeln (sql.ErrorMessage);
                //  readln;
                end;
              for k:= 0 to sh.Results.Count-1 do
                begin
                  res:= sh.Results.Items [k];
                  if res.Junior then
                    junior:= 'j'
                  else
                    junior:= '';
                  if res.Event<> nil then
                    eventshortname:= res.Event.ShortName
                  else
                    eventshortname:= '';
                  cmd:= 'INSERT INTO results VALUES(';
                  cmd:= cmd+''''+GUIDToString (sh.PID)+''',';
                  cmd:= cmd+''''+FormatDateTime ('yyyy-mm-dd',res.Date)+''',';
                  cmd:= cmd+''''+res.ChampionshipName+''',';
                  cmd:= cmd+''''+eventshortname+''',';
                  cmd:= cmd+''''+res.EventName+''',';
                  cmd:= cmd+''''+res.Country+''',';
                  cmd:= cmd+''''+res.Town+''',';
                  cmd:= cmd+''''+junior+''',';
                  cmd:= cmd+''''+res.RankStr+''',';
                  cmd:= cmd+IntToStr (res.Competition)+',';
                  cmd:= cmd+''''+res.FinalStr+''',';
                  cmd:= cmd+''''+res.TotalStr+''',';
                  cmd:= cmd+IntToStr (res.Rating)+');';
                  if not sql.Query (cmd) then
                    begin
                      writeln (sql.ErrorMessage);
                      readln;
                    end;
                end;
              write (#13,'group ',i+1,' shooter ',j+1,'          ');
            end;
        end;
      writeln ('groups loaded');   }

      sql.Close;
    end
  else
    begin
      writeln ('unable to connect to database!');
      writeln (sql.ErrorMessage);
    end;

  sql.Free;

  writeln ('closed database connection');

  d.Free;
end.
