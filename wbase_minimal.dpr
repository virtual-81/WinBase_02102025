program wbase;

{$APPTYPE GUI}

uses
  Winapi.Windows,
  Vcl.Forms,
  wb_registry in 'wb_registry.pas',
  data in 'data.pas',
  Main in 'Main.pas' {MainForm},
  MyLanguage in 'MyLanguage.pas',
  MyListBoxes in 'MyListBoxes.pas',
  MyPrint in 'MyPrint.pas',
  MyReports in 'MyReports.pas',
  MyStrings in 'MyStrings.pas',
  MyTable in 'MyTable.pas',
  MyTables in 'MyTables.pas',
  PrinterSelector in 'PrinterSelector.pas',
  SysFont in 'SysFont.pas',
  calceval in 'calceval.pas',
  CRC32 in 'CRC32.pas',
  ctrl_language in 'ctrl_language.pas',
  Barcode in 'Barcode.pas',
  siusdata in 'siusdata.pas',
  OldData in 'OldData.pas',
  ListBox_Shooters in 'ListBox_Shooters.pas',
  wb_barcodes in 'wb_barcodes.pas',
  wb_seriesedit in 'wb_seriesedit.pas',
  print_results in 'print_results.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
