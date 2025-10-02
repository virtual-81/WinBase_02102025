{$apptype console}

program wbd2csv;

uses
  Classes,Data;

var
  d: TData;
  inf,outf: string;

begin
  if paramcount< 1 then
    begin
      writeln ('wbd2csv converter');
      writeln ('USAGE: wbd2csv <input wbd file>');
      exit;
    end;
  inf:= paramstr (1);
  outf:= paramstr (2);
  d:= TData.Create;
  try
    d.LoadFromFile (inf);
  except
    d.Free;
    writeln ('ERROR: cannot read file ',inf);
    exit;
  end;
  try
    Data.CSVDelimiter:= ';';
    d.ExportToCSV (true);
  except
    d.Free;
    writeln ('ERROR: cannot write csv files');
    exit;
  end;
  d.Free;
end.
