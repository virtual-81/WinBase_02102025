unit PDF_Stub;

// Временная заглушка для PDF модуля
// Заменить на современную PDF библиотеку при полной миграции

interface

uses
  System.Classes, System.SysUtils;

type
  // Заглушки для типов PDF
  TPDFDocument = class
  public
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
  end;

// Заглушки для процедур
procedure CreatePDFReport(const Title: string; Data: TStrings);

implementation

procedure TPDFDocument.SaveToFile(const FileName: string);
begin
  // Заглушка - создаем простой текстовый файл
  with TStringList.Create do
  try
    Add('PDF Report - ' + FormatDateTime('dd.mm.yyyy hh:nn', Now));
    Add('Эта функция будет реализована после установки PDF библиотеки');
    SaveToFile(ChangeFileExt(FileName, '.txt'));
  finally
    Free;
  end;
end;

procedure TPDFDocument.SaveToStream(Stream: TStream);
var
  S: string;
begin
  S := 'PDF Report - заглушка' + #13#10;
  Stream.WriteBuffer(S[1], Length(S));
end;

procedure CreatePDFReport(const Title: string; Data: TStrings);
begin
  // Заглушка для создания PDF отчетов
  ShowMessage('PDF функция временно недоступна. Данные: ' + Title);
end;

end.
