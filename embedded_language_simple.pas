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
  // ���������� ������� �������� ������
  LangData := 
    '1,MainForm=WinBASE %s' + #13#10 +
    '12,MainForm.MainMenu1..File1=������' + #13#10 +
    '13,MainForm.MainMenu1..File1.mnuOpenData=������� ������...' + #13#10 +
    '14,MainForm.MainMenu1..File1.mnuSaveData=���������' + #13#10 +
    '15,MainForm.MainMenu1..File1.mnuSaveAs=��������� ���...' + #13#10 +
    '16,MainForm.MainMenu1..File1.mnuMerge=���������������� ������...' + #13#10 +
    '17,MainForm.MainMenu1..File1.mnuSaveRatingToPDF=��������� ������� � PDF...' + #13#10 +
    '18,MainForm.MainMenu1..File1.mnuImport=������ ������' + #13#10 +
    '19,MainForm.MainMenu1..File1.mnuImport.mnuImportBase=�� ������ ����' + #13#10 +
    '20,MainForm.MainMenu1..File1.mnuPhotoFile=������� ����� � ����...' + #13#10 +
    '21,MainForm.MainMenu1..File1.mnuExit=�����' + #13#10 +
    '22,MainForm.MainMenu1..mnuGroups=������' + #13#10 +
    '23,MainForm.MainMenu1..mnuGroups.mnuRenameGroup=�������������' + #13#10 +
    '24,MainForm.MainMenu1..mnuGroups.mnuAddGroup=����� ������' + #13#10 +
    '25,MainForm.MainMenu1..mnuGroups.mnuDeleteGroup=�������' + #13#10 +
    '26,MainForm.MainMenu1..mnuGroups.mnuMoveGroupUp=����������� �����' + #13#10 +
    '27,MainForm.MainMenu1..mnuGroups.mnuMoveGroupDown=����������� ����' + #13#10 +
    '28,MainForm.MainMenu1..mnuGroups.mnuPreferedEvents=������������ ����������...' + #13#10 +
    '29,MainForm.MainMenu1..mnuShooters=����������' + #13#10 +
    '30,MainForm.MainMenu1..mnuShooters.mnuOpenShooterData=�������� ������' + #13#10 +
    '31,MainForm.MainMenu1..mnuShooters.mnuOpenShooterResults=����������' + #13#10 +
    '32,MainForm.MainMenu1..mnuShooters.mnuAddShooter=��������' + #13#10 +
    '33,MainForm.MainMenu1..mnuShooters.mnuMoveShooter=����������� � ������' + #13#10 +
    '34,MainForm.MainMenu1..mnuShooters.mnuDeleteShooter=�������' + #13#10 +
    '35,MainForm.MainMenu1..mnuShooters.mnuExportToFile=������� � ����...' + #13#10 +
    '36,MainForm.MainMenu1..mnuShooters.mnuImportFromFile=������ �� �����...' + #13#10 +
    '37,MainForm.MainMenu1..mnuShooters.mnuAddToStart=������� �� ������������' + #13#10 +
    '38,MainForm.MainMenu1..mnuShooters.mnuPrintList=������ ������' + #13#10 +
    '39,MainForm.MainMenu1..mnuShooters.mnuPrintInStart=������ ������ ����������' + #13#10 +
    '40,MainForm.MainMenu1..mnuShooters.mnuSaveListToPDF=��������� ������ � PDF...' + #13#10 +
    '41,MainForm.MainMenu1..mnuResults=����������' + #13#10 +
    '42,MainForm.MainMenu1..mnuResults.mnuViewResults=�������� �����������' + #13#10 +
    '43,MainForm.MainMenu1..mnuResults.mnuEnterResults=���� �����������' + #13#10 +
    '44,MainForm.MainMenu1..mnuStarts=������������' + #13#10 +
    '45,MainForm.MainMenu1..mnuStarts.mnuManageStart=�����' + #13#10 +
    '46,MainForm.MainMenu1..mnuStarts.mnuStartShooters=���������' + #13#10 +
    '47,MainForm.MainMenu1..mnuStarts.mnuCloseStart=�������' + #13#10 +
    '48,MainForm.MainMenu1..mnuStarts.mnuPrintStartNumbers=���������� ��������� ������' + #13#10 +
    '49,MainForm.MainMenu1..mnuStarts.mnuNewStart=����� ������������' + #13#10 +
    '50,MainForm.MainMenu1..mnuStarts.mnuOpenStart=�������' + #13#10 +
    '51,MainForm.MainMenu1..mnuStarts.mnuStartManager=�������� ������������' + #13#10 +
    '52,MainForm.MainMenu1..mnuStarts.mnuImportStart=������ �� �����...' + #13#10 +
    '53,MainForm.MainMenu1..mnuOptions=������' + #13#10 +
    '54,MainForm.MainMenu1..mnuOptions.mnuRateTable=������� ��������' + #13#10 +
    '55,MainForm.MainMenu1..mnuOptions.mnuSettings=��������� ������' + #13#10 +
    '56,MainForm.MainMenu1..mnuOptions.mnuAutoSave=�������������� ������' + #13#10 +
    '57,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSaveOff=���������' + #13#10 +
    '58,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave5=������ 5 �����' + #13#10 +
    '59,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave10=������ 10 �����' + #13#10 +
    '60,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave30=������ 30 �����' + #13#10 +
    '61,MainForm.MainMenu1..mnuOptions.mnuAutoSave.mnuAutoSave60=������ 60 �����' + #13#10 +
    '70,MainForm.MainMenu1..mnuLanguage=����' + #13#10 +
    '71,MainForm.MainMenu1..mnuLanguage.mnuRussian=�������' + #13#10 +
    '72,MainForm.MainMenu1..mnuLanguage.mnuEnglish=English' + #13#10 +
    '87,MainForm.Marked=��������: %d';
    
  Language.LoadFromString(LangData);
end;

procedure LoadEmbeddedEnglish;
var
  LangData: String;
begin
  // ���������� ���������� �������� ������
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
    '71,MainForm.MainMenu1..mnuLanguage.mnuRussian=�������' + #13#10 +
    '72,MainForm.MainMenu1..mnuLanguage.mnuEnglish=English' + #13#10 +
    '87,MainForm.Marked=Marked: %d';
    
  Language.LoadFromString(LangData);
end;

end.