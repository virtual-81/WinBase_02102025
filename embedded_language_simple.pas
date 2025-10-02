unit embedded_language_simple;

interface

uses
  MyLanguage;

procedure LoadEmbeddedRussian;
procedure LoadEmbeddedEnglish;

implementation

procedure LoadEmbeddedRussian;
var
  LangData: String;
begin
  // Встроенные русские языковые данные
  LangData := 
    '1,MainForm=WinBASE %s' + #13#10 +
    '12,MainForm.MainMenu1..File1=Данные' + #13#10 +
    '13,MainForm.MainMenu1..File1.mnuOpenData=Открыть данные...' + #13#10 +
    '14,MainForm.MainMenu1..File1.mnuSaveData=Сохранить' + #13#10 +
    '15,MainForm.MainMenu1..File1.mnuSaveAs=Сохранить как...' + #13#10 +
    '16,MainForm.MainMenu1..File1.mnuMerge=Синхронизировать данные...' + #13#10 +
    '17,MainForm.MainMenu1..File1.mnuSaveRatingToPDF=Сохранить рейтинг в PDF...' + #13#10 +
    '18,MainForm.MainMenu1..File1.mnuImport=Импорт данных' + #13#10 +
    '19,MainForm.MainMenu1..File1.mnuImport.mnuImportBase=Из старой БАЗЫ' + #13#10 +
    '20,MainForm.MainMenu1..File1.mnuPhotoFile=Выбрать папку с фото...' + #13#10 +
    '21,MainForm.MainMenu1..File1.mnuExit=Выход' + #13#10 +
    '22,MainForm.MainMenu1..mnuGroups=Группы' + #13#10 +
    '23,MainForm.MainMenu1..mnuGroups.mnuRenameGroup=Переименовать' + #13#10 +
    '24,MainForm.MainMenu1..mnuGroups.mnuAddGroup=Новая группа' + #13#10 +
    '25,MainForm.MainMenu1..mnuGroups.mnuDeleteGroup=Удалить' + #13#10 +
    '26,MainForm.MainMenu1..mnuGroups.mnuMoveGroupUp=Переместить вверх' + #13#10 +
    '27,MainForm.MainMenu1..mnuGroups.mnuMoveGroupDown=Переместить вниз' + #13#10 +
    '28,MainForm.MainMenu1..mnuGroups.mnuPreferedEvents=Предпочтения упражнений...' + #13#10 +
    '29,MainForm.MainMenu1..mnuShooters=Спортсмены' + #13#10 +
    '30,MainForm.MainMenu1..mnuShooters.mnuOpenShooterData=Анкетные данные' + #13#10 +
    '31,MainForm.MainMenu1..mnuShooters.mnuOpenShooterResults=Результаты' + #13#10 +
    '32,MainForm.MainMenu1..mnuShooters.mnuAddShooter=Добавить' + #13#10 +
    '33,MainForm.MainMenu1..mnuShooters.mnuMoveShooter=Переместить в группу' + #13#10 +
    '34,MainForm.MainMenu1..mnuShooters.mnuDeleteShooter=Удалить' + #13#10 +
    '35,MainForm.MainMenu1..mnuShooters.mnuExportToFile=Экспорт в файл...' + #13#10 +
    '36,MainForm.MainMenu1..mnuShooters.mnuImportFromFile=Импорт из файла...' + #13#10 +
    '37,MainForm.MainMenu1..mnuShooters.mnuAddToStart=Заявить на соревнования' + #13#10 +
    '38,MainForm.MainMenu1..mnuShooters.mnuPrintList=Печать списка' + #13#10 +
    '39,MainForm.MainMenu1..mnuShooters.mnuPrintInStart=Печать списка заявленных' + #13#10 +
    '40,MainForm.MainMenu1..mnuShooters.mnuSaveListToPDF=Сохранить список в PDF...' + #13#10 +
    '41,MainForm.MainMenu1..mnuResults=Результаты' + #13#10 +
    '42,MainForm.MainMenu1..mnuResults.mnuViewResults=Просмотр результатов' + #13#10 +
    '43,MainForm.MainMenu1..mnuResults.mnuEnterResults=Ввод результатов' + #13#10 +
    '44,MainForm.MainMenu1..mnuStarts=Соревнования' + #13#10 +
    '45,MainForm.MainMenu1..mnuStarts.mnuManageStart=Войти' + #13#10 +
    '46,MainForm.MainMenu1..mnuStarts.mnuStartShooters=Участники' + #13#10 +
    '47,MainForm.MainMenu1..mnuStarts.mnuCloseStart=Закрыть' + #13#10 +
    '48,MainForm.MainMenu1..mnuStarts.mnuPrintStartNumbers=Допечатать стартовые номера' + #13#10 +
    '49,MainForm.MainMenu1..mnuStarts.mnuNewStart=Новое соревнование' + #13#10 +
    '50,MainForm.MainMenu1..mnuStarts.mnuOpenStart=Выбрать' + #13#10 +
    '51,MainForm.MainMenu1..mnuStarts.mnuStartManager=Менеджер соревнований' + #13#10 +
    '52,MainForm.MainMenu1..mnuStarts.mnuImportStart=Импорт из файла...' + #13#10 +
    '53,MainForm.MainMenu1..mnuOptions=Сервис' + #13#10 +
    '54,MainForm.MainMenu1..mnuOptions.mnuRateTable=Таблица рейтинга' + #13#10 +
    '55,MainForm.MainMenu1..mnuOptions.mnuSettings=Настройки данных' + #13#10 +
    '56,MainForm.MainMenu1..mnuOptions.mnuAutoSave=Автосохранение данных' + #13#10 +
    '57,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSaveOff=Отключено' + #13#10 +
    '58,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave5=Каждые 5 минут' + #13#10 +
    '59,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave10=Каждые 10 минут' + #13#10 +
    '60,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave30=Каждые 30 минут' + #13#10 +
    '61,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave60=Каждые 60 минут' + #13#10 +
    '70,MainForm.MainMenu1..mnuLanguage=Язык' + #13#10 +
    '71,MainForm.MainMenu1..mnuLanguage.mnuRussian=Русский' + #13#10 +
    '72,MainForm.MainMenu1..mnuLanguage.mnuEnglish=English' + #13#10 +
    '87,MainForm.Marked=Отмечено: %d';
    
  Language.LoadFromString(LangData);
end;

procedure LoadEmbeddedEnglish;
var
  LangData: String;
begin
  // Встроенные английские языковые данные
  LangData := 
    '1,MainForm=WinBASE %s' + #13#10 +
    '12,MainForm.MainMenu1..File1=Data' + #13#10 +
    '13,MainForm.MainMenu1..File1.mnuOpenData=Open data...' + #13#10 +
    '14,MainForm.MainMenu1..File1.mnuSaveData=Save' + #13#10 +
    '15,MainForm.MainMenu1..File1.mnuSaveAs=Save as...' + #13#10 +
    '16,MainForm.MainMenu1..File1.mnuMerge=Synchronize data...' + #13#10 +
    '17,MainForm.MainMenu1..File1.mnuSaveRatingToPDF=Save rating to PDF...' + #13#10 +
    '18,MainForm.MainMenu1..File1.mnuImport=Import data' + #13#10 +
    '19,MainForm.MainMenu1..File1.mnuImport.mnuImportBase=From old BASE' + #13#10 +
    '20,MainForm.MainMenu1..File1.mnuPhotoFile=Select photo folder...' + #13#10 +
    '21,MainForm.MainMenu1..File1.mnuExit=Exit' + #13#10 +
    '22,MainForm.MainMenu1..mnuGroups=Groups' + #13#10 +
    '23,MainForm.MainMenu1..mnuGroups.mnuRenameGroup=Rename' + #13#10 +
    '24,MainForm.MainMenu1..mnuGroups.mnuAddGroup=New group' + #13#10 +
    '25,MainForm.MainMenu1..mnuGroups.mnuDeleteGroup=Delete' + #13#10 +
    '26,MainForm.MainMenu1..mnuGroups.mnuMoveGroupUp=Move up' + #13#10 +
    '27,MainForm.MainMenu1..mnuGroups.mnuMoveGroupDown=Move down' + #13#10 +
    '28,MainForm.MainMenu1..mnuGroups.mnuPreferedEvents=Event preferences...' + #13#10 +
    '29,MainForm.MainMenu1..mnuShooters=Shooters' + #13#10 +
    '30,MainForm.MainMenu1..mnuShooters.mnuOpenShooterData=Personal data' + #13#10 +
    '31,MainForm.MainMenu1..mnuShooters.mnuOpenShooterResults=Results' + #13#10 +
    '32,MainForm.MainMenu1..mnuShooters.mnuAddShooter=Add' + #13#10 +
    '33,MainForm.MainMenu1..mnuShooters.mnuMoveShooter=Move to group' + #13#10 +
    '34,MainForm.MainMenu1..mnuShooters.mnuDeleteShooter=Delete' + #13#10 +
    '35,MainForm.MainMenu1..mnuShooters.mnuExportToFile=Export to file...' + #13#10 +
    '36,MainForm.MainMenu1..mnuShooters.mnuImportFromFile=Import from file...' + #13#10 +
    '37,MainForm.MainMenu1..mnuShooters.mnuAddToStart=Add to competition' + #13#10 +
    '38,MainForm.MainMenu1..mnuShooters.mnuPrintList=Print list' + #13#10 +
    '39,MainForm.MainMenu1..mnuShooters.mnuPrintInStart=Print registered list' + #13#10 +
    '40,MainForm.MainMenu1..mnuShooters.mnuSaveListToPDF=Save list to PDF...' + #13#10 +
    '41,MainForm.MainMenu1..mnuResults=Results' + #13#10 +
    '42,MainForm.MainMenu1..mnuResults.mnuViewResults=View results' + #13#10 +
    '43,MainForm.MainMenu1..mnuResults.mnuEnterResults=Enter results' + #13#10 +
    '44,MainForm.MainMenu1..mnuStarts=Competitions' + #13#10 +
    '45,MainForm.MainMenu1..mnuStarts.mnuManageStart=Enter' + #13#10 +
    '46,MainForm.MainMenu1..mnuStarts.mnuStartShooters=Participants' + #13#10 +
    '47,MainForm.MainMenu1..mnuStarts.mnuCloseStart=Close' + #13#10 +
    '48,MainForm.MainMenu1..mnuStarts.mnuPrintStartNumbers=Print start numbers' + #13#10 +
    '49,MainForm.MainMenu1..mnuStarts.mnuNewStart=New competition' + #13#10 +
    '50,MainForm.MainMenu1..mnuStarts.mnuOpenStart=Select' + #13#10 +
    '51,MainForm.MainMenu1..mnuStarts.mnuStartManager=Competition manager' + #13#10 +
    '52,MainForm.MainMenu1..mnuStarts.mnuImportStart=Import from file...' + #13#10 +
    '53,MainForm.MainMenu1..mnuOptions=Tools' + #13#10 +
    '54,MainForm.MainMenu1..mnuOptions.mnuRateTable=Rating table' + #13#10 +
    '55,MainForm.MainMenu1..mnuOptions.mnuSettings=Data settings' + #13#10 +
    '56,MainForm.MainMenu1..mnuOptions.mnuAutoSave=Auto save data' + #13#10 +
    '57,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSaveOff=Disabled' + #13#10 +
    '58,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave5=Every 5 minutes' + #13#10 +
    '59,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave10=Every 10 minutes' + #13#10 +
    '60,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave30=Every 30 minutes' + #13#10 +
    '61,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave60=Every 60 minutes' + #13#10 +
    '70,MainForm.MainMenu1..mnuLanguage=Language' + #13#10 +
    '71,MainForm.MainMenu1..mnuLanguage.mnuRussian=Русский' + #13#10 +
    '72,MainForm.MainMenu1..mnuLanguage.mnuEnglish=English' + #13#10 +
    '87,MainForm.Marked=Marked: %d';
    
  Language.LoadFromString(LangData);
end;

end.