object ManageStartForm: TManageStartForm
  Left = 446
  Top = 136
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'ManageStartForm'
  ClientHeight = 603
  ClientWidth = 746
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Position = poDefault
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 186
    Width = 746
    Height = 417
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 744
    ExplicitHeight = 409
    object HeaderControl1: THeaderControl
      Left = 1
      Top = 1
      Width = 744
      Height = 17
      Sections = <
        item
          ImageIndex = -1
          Text = #1053#1086#1084#1077#1088
          Width = 50
        end
        item
          ImageIndex = -1
          Text = #1048#1085#1092#1086
          Width = 50
        end
        item
          ImageIndex = -1
          Text = #1041#1072#1083#1083#1099
          Width = 75
        end
        item
          AllowClick = False
          ImageIndex = -1
          Text = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077
          Width = 350
        end
        item
          ImageIndex = -1
          Text = #1057#1084#1077#1085
          Width = 60
        end
        item
          ImageIndex = -1
          Text = #1052#1077#1089#1090
          Width = 60
        end
        item
          ImageIndex = -1
          Text = #1059#1095#1072#1089#1090#1085#1080#1082#1086#1074
          Width = 80
        end
        item
          ImageIndex = -1
          Text = #1057#1086#1093#1088#1072#1085#1077#1085#1086
          Width = 100
        end
        item
          ImageIndex = -1
          Text = #1057#1090#1072#1090#1091#1089
          Width = 50
        end>
      OnSectionResize = HeaderControl1SectionResize
      ExplicitWidth = 742
    end
    object lbEvents: TListBox
      Left = 1
      Top = 18
      Width = 744
      Height = 398
      Style = lbOwnerDrawFixed
      AutoComplete = False
      Align = alClient
      PopupMenu = pmEvent
      TabOrder = 0
      OnClick = lbEventsClick
      OnDblClick = lbEventsDblClick
      OnDrawItem = lbEventsDrawItem
      OnKeyDown = lbEventsKeyDown
      OnMouseDown = lbEventsMouseDown
      ExplicitWidth = 742
      ExplicitHeight = 390
    end
  end
  object pnlStart: TPanel
    Left = 0
    Top = 0
    Width = 746
    Height = 96
    Align = alTop
    FullRepaint = False
    TabOrder = 1
    OnResize = pnlStartResize
    ExplicitWidth = 744
    object lNameC: TLabel
      Left = 16
      Top = 8
      Width = 109
      Height = 13
      Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1088#1086#1090#1086#1082#1086#1083#1072':'
    end
    object lName: TLabel
      Left = 135
      Top = 8
      Width = 125
      Height = 13
      Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1087#1088#1086#1090#1086#1082#1086#1083#1072
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlBottom
    end
    object lChampC: TLabel
      Left = 16
      Top = 24
      Width = 101
      Height = 13
      Caption = #1056#1072#1085#1075' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1103':'
    end
    object lChamp: TLabel
      Left = 135
      Top = 24
      Width = 86
      Height = 13
      Caption = #1057#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1077
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlBottom
    end
    object lNumsC: TLabel
      Left = 16
      Top = 40
      Width = 100
      Height = 13
      Caption = #1057#1090#1072#1088#1090#1086#1074#1099#1077' '#1085#1086#1084#1077#1088#1072':'
    end
    object lStartNumbers: TLabel
      Left = 135
      Top = 40
      Width = 33
      Height = 13
      Caption = #1045#1057#1058#1068
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlBottom
    end
    object lTownC: TLabel
      Left = 16
      Top = 56
      Width = 35
      Height = 13
      Caption = #1043#1086#1088#1086#1076':'
    end
    object lRangeC: TLabel
      Left = 16
      Top = 73
      Width = 68
      Height = 13
      Caption = #1057#1090#1088#1077#1083#1100#1073#1080#1097#1077':'
    end
    object lTown: TLabel
      Left = 135
      Top = 56
      Width = 36
      Height = 13
      Caption = #1043#1086#1088#1086#1076
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlBottom
    end
    object lRange: TLabel
      Left = 135
      Top = 73
      Width = 74
      Height = 13
      Caption = #1057#1090#1088#1077#1083#1100#1073#1080#1097#1077
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlBottom
    end
    object btnChangeInfo: TButton
      Left = 664
      Top = 31
      Width = 98
      Height = 26
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
      TabOrder = 0
      OnClick = btnChangeInfoClick
    end
    object btnPrint: TButton
      Left = 584
      Top = 64
      Width = 178
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100' '#1089#1090#1072#1088#1090#1086#1074#1099#1093' '#1085#1086#1084#1077#1088#1086#1074
      TabOrder = 1
      OnClick = btnPrintClick
    end
    object btnImportApplications: TButton
      Left = 400
      Top = 64
      Width = 178
      Height = 25
      Caption = #1048#1084#1087#1086#1088#1090' '#1079#1072#1103#1074#1086#1082
      TabOrder = 2
      OnClick = btnImportApplicationsClick
    end
  end
  object pnlTeams: TPanel
    Left = 0
    Top = 96
    Width = 746
    Height = 49
    Align = alTop
    TabOrder = 2
    OnResize = pnlTeamsResize
    ExplicitWidth = 744
    object lTeamsC: TLabel
      Left = 79
      Top = 8
      Width = 50
      Height = 13
      Caption = #1050#1086#1084#1072#1085#1076#1099':'
    end
    object lTeams: TLabel
      Left = 135
      Top = 8
      Width = 63
      Height = 13
      Caption = '10 '#1082#1086#1084#1072#1085#1076
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lPerTeamC: TLabel
      Left = 10
      Top = 24
      Width = 119
      Height = 13
      Caption = #1059#1095#1072#1089#1090#1085#1080#1082#1086#1074' '#1074' '#1082#1086#1084#1072#1085#1076#1077':'
    end
    object lPerTeam: TLabel
      Left = 135
      Top = 27
      Width = 8
      Height = 13
      Caption = '3'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnTeams: TButton
      Left = 664
      Top = 16
      Width = 98
      Height = 25
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
      TabOrder = 0
      OnClick = btnTeamsClick
    end
  end
  object pnlQPoints: TPanel
    Left = 0
    Top = 145
    Width = 746
    Height = 41
    Align = alTop
    TabOrder = 3
    OnResize = pnlQPointsResize
    ExplicitWidth = 744
    object lQPointsC: TLabel
      Left = 24
      Top = 8
      Width = 281
      Height = 13
      Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1077' '#1082#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1086#1085#1085#1099#1093' '#1085#1086#1088#1084#1072#1090#1080#1074#1086#1074':'
    end
    object lQualificationPoints: TLabel
      Left = 312
      Top = 8
      Width = 137
      Height = 13
      Caption = #1073#1072#1083#1083#1099' '#1085#1077' '#1091#1089#1090#1072#1085#1086#1074#1083#1077#1085#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnQualificationPoints: TButton
      Left = 664
      Top = 8
      Width = 98
      Height = 26
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
      TabOrder = 0
      OnClick = btnQualificationPointsClick
    end
  end
  object pmEvent: TPopupMenu
    OnPopup = pmEventPopup
    Left = 40
    Top = 288
    object mnuRelays: TMenuItem
      Caption = #1057#1084#1077#1085#1099
      ShortCut = 13
      OnClick = mnuRelaysClick
    end
    object mnuTens: TMenuItem
      Caption = #1050#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1103' '#1089' '#1076#1077#1089#1103#1090#1099#1084#1080
      Checked = True
      OnClick = mnuTensClick
    end
    object mnuShooters: TMenuItem
      Caption = #1059#1095#1072#1089#1090#1085#1080#1082#1080
      ShortCut = 114
      OnClick = mnuShootersClick
    end
    object mnuLots: TMenuItem
      Caption = #1046#1077#1088#1077#1073#1100#1077#1074#1082#1072
      ShortCut = 115
      OnClick = mnuLotsClick
    end
    object mnuResults: TMenuItem
      Caption = #1042#1074#1086#1076' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074
      ShortCut = 116
      OnClick = mnuResultsClick
    end
    object mnuShootOff: TMenuItem
      Caption = #1055#1077#1088#1077#1089#1090#1088#1077#1083#1082#1080' '#1080' '#1082#1086#1084#1084#1077#1085#1090#1072#1088#1080#1080
      ShortCut = 113
      OnClick = mnuShootOffClick
    end
    object mnuPoints: TMenuItem
      Caption = #1058#1072#1073#1083#1080#1094#1072' '#1073#1072#1083#1083#1086#1074'...'
      ShortCut = 120
      OnClick = mnuPointsClick
    end
    object mnuFinal: TMenuItem
      Caption = #1060#1080#1085#1072#1083
      OnClick = mnuFinalClick
    end
    object mnuProtNo: TMenuItem
      Caption = #1053#1086#1084#1077#1088' '#1087#1088#1086#1090#1086#1082#1086#1083#1072'...'
      OnClick = mnuProtNoClick
    end
    object mnuSave: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' '#1073#1072#1079#1091
      OnClick = mnuSaveClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnuChangeInfo: TMenuItem
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100' '#1096#1072#1087#1082#1091'...'
      OnClick = mnuChangeInfoClick
    end
    object mnuDeleteInfo: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1096#1072#1087#1082#1091
      OnClick = mnuDeleteInfoClick
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object mnuAddEvent: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1091#1087#1088#1072#1078#1085#1077#1085#1080#1077'...'
      OnClick = mnuAddEventClick
    end
    object mnuPrintPointsTable: TMenuItem
      Caption = #1055#1077#1095#1072#1090#1100' '#1090#1072#1073#1083#1080#1094#1099' '#1082#1086#1084#1087#1083#1077#1082#1089#1085#1086#1075#1086' '#1087#1077#1088#1074#1077#1085#1089#1090#1074#1072
      OnClick = mnuPrintPointsTableClick
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object mnuPrintShooters: TMenuItem
      Caption = #1055#1077#1095#1072#1090#1100' '#1089#1087#1080#1089#1082#1072' '#1089#1090#1088#1077#1083#1082#1086#1074
      OnClick = mnuPrintShootersClick
    end
    object mnuPrintStartList: TMenuItem
      Caption = #1055#1077#1095#1072#1090#1100' '#1089#1090#1072#1088#1090#1086#1074#1086#1075#1086' '#1087#1088#1086#1090#1086#1082#1086#1083#1072
      ShortCut = 117
      OnClick = mnuPrintStartListClick
    end
    object mnuExportStartList: TMenuItem
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1089#1090#1072#1088#1090#1086#1074#1086#1075#1086' '#1083#1080#1089#1090#1072' '#1074' Sius Ascor'
      OnClick = mnuExportStartListClick
    end
    object mnuAcquire: TMenuItem
      Caption = #1055#1086#1083#1091#1095#1080#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1080#1079' SiusData'
      OnClick = mnuAcquireClick
    end
    object mnuAcquireFinal: TMenuItem
      Caption = #1055#1086#1083#1091#1095#1080#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1092#1080#1085#1072#1083#1072' '#1080#1079' SiusData'
      OnClick = mnuAcquireFinalClick
    end
    object mnuPrintResults: TMenuItem
      Caption = #1055#1077#1095#1072#1090#1100' '#1087#1088#1086#1090#1086#1082#1086#1083#1072' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074
      ShortCut = 119
      OnClick = mnuPrintResultsClick
    end
    object mnuPrintFinalNumbers: TMenuItem
      Caption = #1055#1077#1095#1072#1090#1100' '#1092#1080#1085#1072#1083#1100#1085#1099#1093' '#1085#1086#1084#1077#1088#1086#1074
      OnClick = mnuPrintFinalNumbersClick
    end
    object mnuPrintCards: TMenuItem
      Caption = #1055#1077#1095#1072#1090#1100' '#1091#1095#1077#1090#1085#1099#1093' '#1082#1072#1088#1090#1086#1095#1077#1082
      OnClick = mnuPrintCardsClick
    end
    object mnuPrintFinalCards: TMenuItem
      Caption = #1055#1077#1095#1072#1090#1100' '#1092#1080#1085#1072#1083#1100#1085#1099#1093' '#1082#1072#1088#1090#1086#1095#1077#1082
      OnClick = mnuPrintFinalCardsClick
    end
    object mnuSaveStartListToPDF: TMenuItem
      Caption = #1057#1093#1088#1072#1085#1080#1090#1100' '#1089#1090#1072#1088#1090#1086#1074#1099#1081' '#1087#1088#1086#1090#1086#1082#1086#1083'...'
      OnClick = mnuSaveStartListToPDFClick
    end
    object mnuSaveResultsPDF: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1088#1086#1090#1086#1082#1086#1083' '#1089' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1072#1084#1080'...'
      OnClick = mnuSaveResultsPDFClick
    end
    object mnuSaveAllResults: TMenuItem
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074#1089#1077' '#1087#1088#1086#1090#1086#1082#1086#1083#1099' '#1074' PDF...'
      OnClick = mnuSaveAllResultsClick
    end
    object mnuCSV: TMenuItem
      Caption = #1069#1082#1089#1087#1086#1088#1090' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074' '#1074' CSV...'
      OnClick = mnuCSVClick
    end
    object N7: TMenuItem
      Caption = '-'
    end
    object mnuDelete: TMenuItem
      AutoHotkeys = maManual
      AutoLineReduction = maManual
      Caption = #1059#1076#1072#1083#1080#1090#1100
      ShortCut = 46
      OnClick = mnuDeleteClick
    end
  end
end
