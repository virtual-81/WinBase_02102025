object MainForm: TMainForm
  Left = 448
  Top = 123
  Caption = 'WinBASE'
  ClientHeight = 592
  ClientWidth = 793
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  Menu = MainMenu1
  Position = poScreenCenter
  Scaled = False
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Splitter1: TSplitter
    Left = 241
    Top = 0
    Width = 6
    Height = 573
    AutoSnap = False
    Color = clBtnFace
    ParentColor = False
    ResizeStyle = rsUpdate
    ExplicitLeft = 253
    ExplicitTop = -6
    ExplicitHeight = 715
  end
  object pnlGroupsActions: TPanel
    Left = 247
    Top = 0
    Width = 546
    Height = 573
    Align = alClient
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Caption = 'pnlGroupsActions'
    Color = clWhite
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    Visible = False
    ExplicitWidth = 544
    ExplicitHeight = 565
  end
  object pnlGroup: TPanel
    Left = 247
    Top = 0
    Width = 546
    Height = 573
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    Ctl3D = False
    FullRepaint = False
    ParentCtl3D = False
    TabOrder = 0
    Visible = False
    ExplicitWidth = 544
    ExplicitHeight = 565
    object pnlGroupInfo: TPanel
      Left = 0
      Top = 0
      Width = 546
      Height = 32
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      BorderWidth = 4
      FullRepaint = False
      TabOrder = 0
      OnResize = pnlGroupInfoResize
      ExplicitWidth = 544
      object lEvent: TLabel
        Left = 8
        Top = 8
        Width = 72
        Height = 15
        Caption = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077':'
        Transparent = False
      end
      object cbEvents: TComboBox
        Left = 80
        Top = 6
        Width = 402
        Height = 19
        AutoDropDown = True
        Style = csOwnerDrawFixed
        Ctl3D = False
        Enabled = False
        ItemHeight = 13
        ParentCtl3D = False
        TabOrder = 0
        TabStop = False
        OnDrawItem = cbEventsDrawItem
        OnKeyPress = cbEventsKeyPress
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 573
    Width = 793
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ParentFont = True
    UseSystemFont = False
    ExplicitTop = 565
    ExplicitWidth = 791
  end
  object tvGroups: TTreeView
    Left = 0
    Top = 0
    Width = 241
    Height = 573
    Align = alLeft
    BevelInner = bvNone
    BevelOuter = bvNone
    Ctl3D = True
    Indent = 19
    MultiSelectStyle = []
    ParentCtl3D = False
    RightClickSelect = True
    TabOrder = 3
    OnChange = tvGroupsChange
    OnCustomDrawItem = tvGroupsCustomDrawItem
    OnEdited = tvGroupsEdited
    OnEnter = tvGroupsEnter
    OnExit = tvGroupsExit
    OnKeyDown = tvGroupsKeyDown
    OnKeyPress = tvGroupsKeyPress
    ExplicitHeight = 565
  end
  object MainMenu1: TMainMenu
    AutoHotkeys = maManual
    Left = 16
    Top = 72
    object File1: TMenuItem
      Caption = '&'#1044#1072#1085#1085#1099#1077
      object mnuOpenData: TMenuItem
        Caption = '&'#1054#1090#1082#1088#1099#1090#1100' '#1076#1072#1085#1085#1099#1077
        ShortCut = 16463
        OnClick = mnuOpenDataClick
      end
      object mnuSaveData: TMenuItem
        Caption = '&'#1057#1086#1093#1088#1072#1085#1080#1090#1100
        Enabled = False
        ShortCut = 16467
        OnClick = mnuSaveDataClick
      end
      object mnuSaveAs: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082'...'
        Enabled = False
        OnClick = mnuSaveAsClick
      end
      object mnuMerge: TMenuItem
        Caption = #1057#1080#1085#1093#1088#1086#1085#1080#1079#1080#1088#1086#1074#1072#1090#1100' '#1076#1072#1085#1085#1099#1077'...'
        Enabled = False
        OnClick = mnuMergeClick
      end
      object mnuImport: TMenuItem
        Caption = #1048#1084#1087#1086#1088#1090
        object mnuImportBase: TMenuItem
          Caption = #1080#1079' '#1089#1090#1072#1088#1086#1081' '#1041#1072#1079#1099
          OnClick = mnuImportBaseClick
        end
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuSaveRatingToPDF: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1088#1077#1081#1090#1080#1085#1075' '#1074' PDF...'
        Enabled = False
        OnClick = mnuSaveRatingToPDFClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuCheck: TMenuItem
        Caption = #1055#1088#1086#1074#1077#1088#1082#1072
        Enabled = False
        OnClick = mnuCheckClick
      end
      object mnuExportNoChamps: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090' '#1076#1072#1085#1085#1099#1093' '#1073#1077#1079' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1081'...'
        Enabled = False
        OnClick = mnuExportNoChampsClick
      end
      object mnuPhotoFile: TMenuItem
        Caption = #1042#1099#1073#1088#1072#1090#1100' '#1087#1072#1087#1082#1091' '#1089' '#1092#1086#1090#1086'...'
        Enabled = False
        OnClick = mnuPhotoFileClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object mnuExit: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = mnuExitClick
      end
    end
    object mnuGroups: TMenuItem
      Caption = #1043#1088#1091#1087#1087#1099
      Visible = False
      object mnuRenameGroup: TMenuItem
        Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100
        OnClick = mnuRenameGroupClick
      end
      object mnuAddGroup: TMenuItem
        Caption = #1053#1086#1074#1072#1103' '#1075#1088#1091#1087#1087#1072
        OnClick = mnuAddGroupClick
      end
      object mnuDeleteGroup: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100' '#1075#1088#1091#1087#1087#1091
        OnClick = mnuDeleteGroupClick
      end
      object mnuMoveGroupUp: TMenuItem
        Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1074#1074#1077#1088#1093
        OnClick = mnuMoveGroupUpClick
      end
      object mnuMoveGroupDown: TMenuItem
        Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1074#1085#1080#1079
        OnClick = mnuMoveGroupDownClick
      end
      object mnuPreferedEvents: TMenuItem
        Caption = #1055#1088#1077#1076#1087#1086#1095#1090#1077#1085#1080#1103' '#1091#1087#1088#1072#1078#1085#1077#1085#1080#1081'...'
        OnClick = mnuPreferedEventsClick
      end
    end
    object mnuShooters: TMenuItem
      Caption = #1057#1087#1086#1088#1090#1089#1084#1077#1085#1099
      Visible = False
      object mnuOpenShooterData: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1072#1085#1082#1077#1090#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
        ShortCut = 13
        OnClick = mnuOpenShooterDataClick
      end
      object mnuOpenShooterResults: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099
        ShortCut = 116
        OnClick = mnuOpenShooterResultsClick
      end
      object mnuAddShooter: TMenuItem
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100
        OnClick = mnuAddShooterClick
      end
      object mnuMoveShooter: TMenuItem
        Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1074' '#1075#1088#1091#1087#1087#1091
      end
      object mnuDeleteShooter: TMenuItem
        AutoHotkeys = maManual
        Caption = #1059#1076#1072#1083#1080#1090#1100
        ShortCut = 46
        OnClick = mnuDeleteShooterClick
      end
      object mnuExportToFile: TMenuItem
        Caption = #1069#1082#1089#1087#1086#1088#1090' '#1074' '#1092#1072#1081#1083'...'
        OnClick = mnuExportToFileClick
      end
      object mnuImportFromFile: TMenuItem
        Caption = #1048#1084#1087#1086#1088#1090' '#1080#1079' '#1092#1072#1081#1083#1072'...'
        OnClick = mnuImportFromFileClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mnuAddToStart: TMenuItem
        Caption = #1047#1072#1103#1074#1080#1090#1100' '#1085#1072' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1103
        OnClick = mnuAddToStartClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object mnuPrintList: TMenuItem
        Caption = #1055#1077#1095#1072#1090#1100' '#1089#1087#1080#1089#1082#1072
        OnClick = mnuPrintListClick
      end
      object mnuPrintInStart: TMenuItem
        Caption = #1055#1077#1095#1072#1090#1100' '#1089#1087#1080#1089#1082#1072' '#1079#1072#1103#1074#1083#1077#1085#1085#1099#1093
        OnClick = mnuPrintInStartClick
      end
      object mnuSaveListToPDF: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1074' PDF...'
        OnClick = mnuSaveListToPDFClick
      end
      object mnuCSV: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1074' CSV...'
        OnClick = mnuCSVClick
      end
      object mnuSelectInactive: TMenuItem
        Caption = #1054#1090#1084#1077#1090#1080#1090#1100' '#1085#1077#1072#1082#1090#1080#1074#1085#1099#1093' '#1089#1087#1086#1088#1090#1089#1084#1077#1085#1086#1074'...'
        OnClick = mnuSelectInactiveClick
      end
    end
    object mnuResults: TMenuItem
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
      Visible = False
      object mnuViewResults: TMenuItem
        Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074
        OnClick = mnuViewResultsClick
      end
      object mnuEnterResults: TMenuItem
        Caption = #1042#1074#1086#1076' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074
        OnClick = mnuEnterResultsClick
      end
    end
    object mnuStarts: TMenuItem
      Caption = #1057#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1103
      GroupIndex = 230
      Visible = False
      object mnuManageStart: TMenuItem
        Caption = #1042#1086#1081#1090#1080
        Enabled = False
        ShortCut = 115
        OnClick = mnuManageStartClick
      end
      object mnuStartShooters: TMenuItem
        Caption = #1059#1095#1072#1089#1090#1085#1080#1082#1080
        Enabled = False
        ShortCut = 114
        OnClick = mnuStartShootersClick
      end
      object mnuCloseStart: TMenuItem
        Caption = #1047#1072#1082#1088#1099#1090#1100
        Enabled = False
        OnClick = mnuCloseStartClick
      end
      object mnuPrintStartNumbers: TMenuItem
        Caption = #1044#1086#1087#1077#1095#1072#1090#1072#1090#1100' '#1089#1090#1072#1088#1090#1086#1074#1099#1077' '#1085#1086#1084#1077#1088#1072
        Enabled = False
        OnClick = mnuPrintStartNumbersClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mnuNewStart: TMenuItem
        Caption = #1053#1086#1074#1086#1077' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1077
        OnClick = mnuNewStartClick
      end
      object mnuOpenStart: TMenuItem
        Caption = #1042#1099#1073#1088#1072#1090#1100
        OnClick = mnuOpenStartClick
      end
      object mnuStartManager: TMenuItem
        Caption = #1052#1077#1085#1077#1076#1078#1077#1088' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1081
        ShortCut = 8308
        OnClick = mnuStartManagerClick
      end
      object mnuImportStart: TMenuItem
        Caption = #1048#1084#1087#1086#1088#1090' '#1080#1079' '#1092#1072#1081#1083#1072'...'
      end
    end
    object mnuOptions: TMenuItem
      Caption = #1057#1077#1088#1074#1080#1089
      GroupIndex = 230
      object mnuRateTable: TMenuItem
        Caption = #1058#1072#1073#1083#1080#1094#1072' '#1088#1077#1081#1090#1080#1085#1075#1072
        Enabled = False
        OnClick = mnuRateTableClick
      end
      object mnuSettings: TMenuItem
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1076#1072#1085#1085#1099#1093
        Enabled = False
        OnClick = mnuSettingsClick
      end
      object mnuAutoSave: TMenuItem
        Caption = #1040#1074#1090#1086#1089#1086#1093#1088#1072#1085#1077#1085#1080#1077' '#1076#1072#1085#1085#1099#1093
        object mnuAutoSaveOff: TMenuItem
          Caption = #1054#1090#1082#1083#1102#1095#1077#1085#1086
          Checked = True
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuAutoSaveOffClick
        end
        object mnuAutoSave5: TMenuItem
          Caption = #1050#1072#1078#1076#1099#1077' 5 '#1084#1080#1085#1091#1090
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuAutoSave5Click
        end
        object mnuAutoSave10: TMenuItem
          Caption = #1050#1072#1078#1076#1099#1077' 10 '#1084#1080#1085#1091#1090
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuAutoSave10Click
        end
        object mnuAutoSave30: TMenuItem
          Caption = #1050#1072#1078#1076#1099#1077' 30 '#1084#1080#1085#1091#1090
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuAutoSave30Click
        end
        object mnuAutoSave60: TMenuItem
          Caption = #1050#1072#1078#1076#1099#1081' '#1095#1072#1089
          GroupIndex = 1
          RadioItem = True
          OnClick = mnuAutoSave60Click
        end
      end
      object mnuEachDayBackup: TMenuItem
        Caption = #1045#1078#1077#1076#1085#1077#1074#1085#1099#1077' '#1088#1077#1079#1077#1088#1074#1085#1099#1077' '#1082#1086#1087#1080#1080
        OnClick = mnuEachDayBackupClick
      end
      object mnuPurgeDailyBackups: TMenuItem
        Caption = #1057#1090#1077#1088#1077#1090#1100' '#1077#1078#1077#1076#1085#1077#1074#1085#1099#1077' '#1088#1077#1079#1077#1088#1074#1085#1099#1077' '#1092#1072#1081#1083#1099
        OnClick = mnuPurgeDailyBackupsClick
      end
      object mnuTruncateClubs: TMenuItem
        Caption = #1054#1073#1088#1077#1079#1072#1090#1100' '#1085#1072#1079#1074#1072#1085#1080#1103' '#1082#1083#1091#1073#1086#1074' ('#1044#1057#1054')'
        OnClick = mnuTruncateClubsClick
      end
      object mnuPrinter: TMenuItem
        Caption = #1055#1088#1080#1085#1090#1077#1088'...'
        OnClick = mnuPrinterClick
      end
      object mnuAddToStartByOrder: TMenuItem
        Caption = #1047#1072#1103#1074#1083#1103#1090#1100' '#1085#1072' '#1089#1086#1088#1077#1085#1086#1074#1072#1085#1080#1103' '#1074' '#1087#1086#1088#1103#1076#1082#1077' '#1086#1090#1084#1077#1090#1082#1080
        OnClick = mnuAddToStartByOrderClick
      end
      object mnuProtocolFont: TMenuItem
        Caption = #1064#1088#1080#1092#1090' '#1076#1083#1103' '#1087#1077#1095#1072#1090#1080' '#1087#1088#1086#1090#1086#1082#1086#1083#1086#1074'...'
        OnClick = mnuProtocolFontClick
      end
      object mnuStartNumbersFont: TMenuItem
        Caption = #1064#1088#1080#1092#1090' '#1076#1083#1103' '#1087#1077#1095#1072#1090#1080' '#1089#1090#1072#1088#1090#1086#1074#1099#1093' '#1085#1086#1084#1077#1088#1086#1074'...'
        OnClick = mnuStartNumbersFontClick
      end
      object mnuSaveOnExit: TMenuItem
        Caption = #1042#1089#1077#1075#1076#1072' '#1089#1086#1093#1088#1072#1085#1103#1090#1100' '#1076#1072#1085#1085#1099#1077' '#1087#1088#1080' '#1074#1099#1093#1086#1076#1077
        OnClick = mnuSaveOnExitClick
      end
      object mnuCompareBySeries: TMenuItem
        Caption = #1056#1072#1079#1074#1086#1076#1080#1090#1100' '#1086#1076#1080#1085#1072#1082#1086#1074#1099#1077' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1087#1086' '#1087#1086#1089#1083#1077#1076#1085#1077#1081' '#1089#1077#1088#1080#1080
        OnClick = mnuCompareBySeriesClick
      end
      object mnuEmbedFontFiles: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1096#1088#1080#1092#1090#1099' '#1074' PDF'
        Enabled = False
        OnClick = mnuEmbedFontFilesClick
      end
      object mnuLanguage: TMenuItem
        Caption = #1071#1079#1099#1082' (Language)'
        object mnuRussian: TMenuItem
          Caption = #1056#1091#1089#1089#1082#1080#1081
          Checked = True
          RadioItem = True
          OnClick = mnuRussianClick
        end
        object mnuEnglish: TMenuItem
          Caption = 'English'
          RadioItem = True
          OnClick = mnuEnglishClick
        end
      end
      object mnuProtocolMakerSign: TMenuItem
        Caption = #1055#1086#1076#1087#1080#1089#1100' '#1080#1089#1087#1086#1083#1085#1080#1090#1077#1083#1103' '#1087#1088#1086#1090#1086#1082#1086#1083#1086#1074'...'
        OnClick = mnuProtocolMakerSignClick
      end
      object mnuInnerTens: TMenuItem
        Caption = #1055#1086#1083#1091#1095#1072#1090#1100' '#1082#1086#1085#1090#1088#1086#1083#1100#1085#1099#1077' '#1076#1077#1089#1103#1090#1082#1080' '#1086#1090' Sius Ascor'
        OnClick = mnuInnerTensClick
      end
      object mnuRatingDate: TMenuItem
        Caption = #1044#1072#1090#1072' '#1076#1083#1103' '#1088#1072#1089#1095#1077#1090#1072' '#1088#1077#1081#1090#1080#1085#1075#1072
        object mnuNow: TMenuItem
          Caption = #1058#1077#1082#1091#1097#1072#1103
          OnClick = mnuNowClick
        end
        object mnuSpecificDate: TMenuItem
          Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1100#1089#1082#1072#1103'...'
          OnClick = mnuSpecificDateClick
        end
      end
      object mnuStartNumbersMode: TMenuItem
        Caption = #1055#1077#1095#1072#1090#1072#1090#1100' '#1086#1076#1080#1085' '#1089#1090#1072#1088#1090#1086#1074#1099#1081' '#1085#1086#1084#1077#1088' '#1085#1072' '#1089#1090#1088#1072#1085#1080#1094#1077
        OnClick = mnuStartNumbersModeClick
      end
    end
    object mnuHelp: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      GroupIndex = 230
      object mnuAbout: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
        OnClick = mnuAboutClick
      end
    end
  end
  object OpenDataDialog: TOpenDialog
    DefaultExt = '*.wbd'
    Filter = 'WinBASE data files (*.wbd)|*.wbd'
    Options = [ofReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = #1054#1090#1082#1088#1099#1090#1100' '#1076#1072#1085#1085#1099#1077
    Left = 120
    Top = 72
  end
  object SaveDataDialog: TSaveDialog
    DefaultExt = '*.wbd'
    Filter = 'WinBASE data files|*.wbd'
    Options = [ofOverwritePrompt, ofPathMustExist, ofEnableSizing]
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1076#1072#1085#1085#1099#1077
    Left = 88
    Top = 104
  end
  object TimerAutoSave: TTimer
    Enabled = False
    OnTimer = TimerAutoSaveTimer
    Left = 48
    Top = 104
  end
  object ExportDialog: TSaveDialog
    DefaultExt = '*.shtr'
    Filter = 'WinBASE Shooters (*.shtr)|*.shtr'
    FilterIndex = 0
    Title = #1069#1082#1089#1087#1086#1088#1090' '#1074' '#1092#1072#1081#1083
    Left = 88
    Top = 72
  end
  object ImportDialog: TOpenDialog
    DefaultExt = '*.shtr'
    Filter = 'WinBASE Shooters (*.shtr)|*.shtr'
    FilterIndex = 0
    Title = #1048#1084#1087#1086#1088#1090' '#1080#1079' '#1092#1072#1081#1083#1072
    Left = 120
    Top = 104
  end
  object MergeDataDialog: TOpenDialog
    Filter = 'WinBASE data files (*.wbd)|*.wbd'
    Options = [ofReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = #1057#1080#1085#1093#1088#1086#1085#1080#1079#1080#1088#1086#1074#1072#1090#1100' '#1076#1072#1085#1085#1099#1077
    Left = 120
    Top = 136
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Device = fdPrinter
    MinFontSize = 4
    Options = [fdTrueTypeOnly, fdForceFontExist, fdNoOEMFonts, fdNoSimulations, fdNoStyleSel, fdNoVectorFonts, fdWysiwyg]
    Left = 15
    Top = 107
  end
  object pmPopup: TPopupMenu
    Left = 16
    Top = 264
    object mnuOpenShooterDataPM: TMenuItem
      Caption = #1040#1085#1082#1077#1090#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
      OnClick = mnuOpenShooterDataPMClick
    end
    object mnuShooterResultsPM: TMenuItem
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
      OnClick = mnuShooterResultsPMClick
    end
    object mnuMoveShooterPM: TMenuItem
      Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1074' '#1075#1088#1091#1087#1087#1091
    end
    object mnuAddShooterPM: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1085#1086#1074#1091#1102' '#1079#1072#1087#1080#1089#1100
      OnClick = mnuAddShooterPMClick
    end
    object mnuDeleteShooterPM: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = mnuDeleteShooterPMClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mnuAddToStartPM: TMenuItem
      Caption = #1047#1072#1103#1074#1080#1090#1100' '#1085#1072' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1077
      OnClick = mnuAddToStartPMClick
    end
  end
  object dlgSaveToPDF: TSaveDialog
    DefaultExt = '*.pdf'
    Filter = 'Adobe Acrobat PDF files (*.pdf)|*.pdf'
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1089#1087#1086#1088#1090#1089#1084#1077#1085#1086#1074' '#1074' PDF'
    Left = 88
    Top = 168
  end
  object dlgSaveRating: TSaveDialog
    DefaultExt = '*.pdf'
    Filter = 'Adobe Acrobat PDF files (*.pdf)|*.pdf'
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1088#1077#1081#1090#1080#1085#1075' '#1087#1086' '#1091#1087#1088#1072#1078#1085#1077#1085#1080#1103#1084' '#1074' PDF'
    Left = 88
    Top = 136
  end
  object dlgSaveToCSV: TSaveDialog
    DefaultExt = '*.csv'
    Filter = 'CSV files (*.csv)|*.csv'
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1089#1087#1080#1089#1086#1082' '#1089#1087#1086#1088#1090#1089#1084#1077#1085#1086#1074' '#1074' CSV'
    Left = 88
    Top = 200
  end
  object FontDialog2: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [fdTrueTypeOnly, fdForceFontExist, fdNoOEMFonts, fdNoSimulations]
    Left = 24
    Top = 144
  end
  object PrintDialog1: TPrintDialog
    Left = 120
    Top = 144
  end
end
