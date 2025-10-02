program wbase_synpdf;

{$APPTYPE GUI}

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Vcl.Forms,
  // Подключаем SynPDF напрямую через DPR, чтобы IDE точно видела исходники
  SynPdf in 'vendor\SynPDF-master\SynPDF-master\SynPdf.pas',
  SynGdiPlus in 'vendor\SynPDF-master\SynPDF-master\SynGdiPlus.pas',
  SynCrypto in 'vendor\SynPDF-master\SynPDF-master\SynCrypto.pas',
  SynZip in 'vendor\SynPDF-master\SynPDF-master\SynZip.pas',
  SynLZ in 'vendor\SynPDF-master\SynPDF-master\SynLZ.pas',
  SynCommons in 'vendor\SynPDF-master\SynPDF-master\SynCommons.pas',
  SynTable in 'vendor\SynPDF-master\SynPDF-master\SynTable.pas',
  wb_registry in 'wb_registry.pas',
  data in 'data.pas',
  Main in 'Main.pas' {MainForm},
  form_shooter in 'form_shooter.pas' {ShooterDetailsDialog},
  form_results in 'form_results.pas' {ShooterResultsForm},
  form_result in 'form_result.pas' {EditResultDialog},
  form_startinfo in 'form_startinfo.pas' {StartInfoDialog},
  form_managestart in 'form_managestart.pas' {ManageStartForm},
  form_selectevent in 'form_selectevent.pas' {SelectEventDialog},
  form_stats in 'form_stats.pas' {ShooterStatsDialog},
  form_table in 'form_table.pas' {RateTableForm},
  form_viewresults in 'form_viewresults.pas' {ViewForm},
  form_settings in 'form_settings.pas' {SettingsForm},
  form_eventparams in 'form_eventparams.pas' {EventParamsDialog},
  form_enterresults in 'form_enterresults.pas' {EnterResultsForm},
  form_addtostart in 'form_addtostart.pas' {AddToStartDialog},
  form_teamselect in 'form_teamselect.pas' {TeamSelectDialog},
  form_relaysetup in 'form_relaysetup.pas' {RelaysSetupDialog},
  form_teams in 'form_teams.pas' {TeamsSetupDialog},
  form_points in 'form_points.pas' {PointsSetupDialog},
  form_qualifpoints in 'form_qualifpoints.pas' {QualificationPointsDialog},
  form_eventshooters in 'form_eventshooters.pas' {EventShootersForm},
  form_relaypos in 'form_relaypos.pas' {RelayPositionDialog},
  form_start in 'form_start.pas' {StartForm},
  form_shooterresults in 'form_shooterresults.pas' {ShooterSeriesDialog},
  form_compresults in 'form_compresults.pas' {CompetitionResultsForm},
  form_printprotocol in 'form_printprotocol.pas' {PrintProtocolDialog},
  form_final in 'form_final.pas' {FinalDialog},
  form_inputresult in 'form_inputresult.pas' {InputResultDialog},
  form_selectshooterdialog in 'form_selectshooterdialog.pas' {SelectShooterDialog},
  form_startlistmanager in 'form_startlistmanager.pas' {StartListManager},
  form_move in 'form_move.pas' {MoveShootersDialog},
  form_prefered in 'form_prefered.pas' {PreferedEventsEditor},
  form_startshooters in 'form_startshooters.pas' {StartListShootersForm},
  form_ascor in 'form_ascor.pas' {SiusForm},
  form_printcomplex in 'form_printcomplex.pas' {PrintComplexDialog},
  form_shootingevent in 'form_shootingevent.pas' {ShootingEventDetails},
  form_shootingchamp in 'form_shootingchamp.pas' {ShootingChampionshipDetails},
  ListBox_Shooters in 'ListBox_Shooters.pas',
  form_startstats in 'form_startstats.pas' {StartListStatsDialog},
  wb_barcodes in 'wb_barcodes.pas',
  wb_seriesedit in 'wb_seriesedit.pas',
  form_printshooterscards in 'form_printshooterscards.pas' {PrintShootersCardsDialog},
  form_printfinalnumbers in 'form_printfinalnumbers.pas' {PrintFinalNumbersDialog},
  print_results in 'print_results.pas',
  form_datepicker in 'form_datepicker.pas' {DatePickerDialog},
  form_selectshooter in 'form_selectshooter.pas' {SelectEventShooterDialog},
  OldData in 'OldData.pas',
  embedded_language_complete in 'embedded_language_complete.pas';

{$R *.res}

begin
  {$IFDEF MSWINDOWS}
  SetConsoleOutputCP(CP_UTF8);
  SetConsoleCP(CP_UTF8);
  DefaultSystemCodePage := CP_UTF8;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
