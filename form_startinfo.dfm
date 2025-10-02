object StartInfoDialog: TStartInfoDialog
  Left = 404
  Top = 234
  BorderIcons = [biSystemMenu]
  BorderWidth = 16
  Caption = 'StartInfoDialog'
  ClientHeight = 570
  ClientWidth = 513
  Color = clBtnFace
  Constraints.MinHeight = 535
  Constraints.MinWidth = 542
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  ShowHint = True
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 106
  TextHeight = 16
  object lChamp: TLabel
    Left = 0
    Top = 108
    Width = 503
    Height = 21
    AutoSize = False
    Caption = #1056#1072#1085#1075' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1103' ('#1076#1083#1103' '#1079#1072#1087#1080#1089#1080' '#1074' '#1073#1072#1079#1091' '#1076#1072#1085#1085#1099#1093'):'
  end
  object lTitle: TLabel
    Left = 0
    Top = 0
    Width = 219
    Height = 16
    Caption = #1053#1072#1079#1074#1072#1085#1080#1077' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1103' ('#1090#1080#1090#1091#1083')'
  end
  object cbStartNumbers: TCheckBox
    Left = 0
    Top = 167
    Width = 385
    Height = 21
    Caption = #1057#1090#1072#1088#1090#1086#1074#1099#1077' '#1085#1086#1084#1077#1088#1072
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 286
    Top = 532
    Width = 92
    Height = 30
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 6
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 394
    Top = 532
    Width = 92
    Height = 30
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 7
  end
  object cbChamp: TComboBox
    Left = 0
    Top = 128
    Width = 503
    Height = 21
    ItemHeight = 0
    TabOrder = 1
    Text = 'cbChamp'
  end
  object gbSecretery: TGroupBox
    Left = 0
    Top = 305
    Width = 503
    Height = 100
    Caption = ' '#1043#1083#1072#1074#1085#1099#1081' '#1089#1077#1082#1088#1077#1090#1072#1088#1100' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1081' '
    TabOrder = 4
    object lSecretery: TLabel
      Left = 10
      Top = 22
      Width = 95
      Height = 16
      Caption = #1060#1072#1084#1080#1083#1080#1103' '#1048'.'#1054'.'
      Layout = tlCenter
    end
    object lCategory: TLabel
      Left = 10
      Top = 62
      Width = 148
      Height = 16
      Caption = #1057#1091#1076#1077#1081#1089#1082#1072#1103' '#1082#1072#1090#1077#1075#1086#1088#1080#1103
      Layout = tlCenter
    end
    object cbSecretery: TComboBox
      Left = 167
      Top = 20
      Width = 317
      Height = 21
      ItemHeight = 0
      TabOrder = 0
      Text = 'cbSecretery'
    end
    object cbCategory: TComboBox
      Left = 167
      Top = 59
      Width = 317
      Height = 21
      ItemHeight = 0
      TabOrder = 1
      Text = 'cbCategory'
    end
  end
  object gbPlace: TGroupBox
    Left = 0
    Top = 197
    Width = 503
    Height = 100
    Caption = ' '#1052#1077#1089#1090#1086' '#1087#1088#1086#1074#1077#1076#1077#1085#1080#1103' '
    TabOrder = 3
    object lTown: TLabel
      Left = 20
      Top = 22
      Width = 42
      Height = 16
      Caption = #1043#1086#1088#1086#1076
      Layout = tlCenter
    end
    object lRange: TLabel
      Left = 20
      Top = 62
      Width = 86
      Height = 16
      Caption = #1057#1090#1088#1077#1083#1100#1073#1080#1097#1077
      Layout = tlCenter
    end
    object cbTown: TComboBox
      Left = 167
      Top = 20
      Width = 317
      Height = 21
      AutoDropDown = True
      ItemHeight = 0
      TabOrder = 0
      Text = 'cbTown'
    end
    object cbRange: TComboBox
      Left = 167
      Top = 59
      Width = 317
      Height = 21
      ItemHeight = 0
      TabOrder = 1
      Text = 'cbRange'
    end
  end
  object meName: TMemo
    Left = 0
    Top = 20
    Width = 503
    Height = 70
    Lines.Strings = (
      'meName')
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object gbJury: TGroupBox
    Left = 0
    Top = 414
    Width = 503
    Height = 109
    Caption = #1043#1083#1072#1074#1085#1099#1081' '#1089#1091#1076#1100#1103' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1081
    TabOrder = 5
    object lJury: TLabel
      Left = 20
      Top = 30
      Width = 95
      Height = 16
      Caption = #1060#1072#1084#1080#1083#1080#1103' '#1048'.'#1054'.'
    end
    object lJuryCategory: TLabel
      Left = 20
      Top = 59
      Width = 148
      Height = 16
      Caption = #1057#1091#1076#1077#1081#1089#1082#1072#1103' '#1082#1072#1090#1077#1075#1086#1088#1080#1103
    end
    object cbJury: TComboBox
      Left = 167
      Top = 20
      Width = 317
      Height = 21
      ItemHeight = 0
      TabOrder = 0
      Text = 'cbJury'
    end
    object cbJuryCategory: TComboBox
      Left = 167
      Top = 59
      Width = 317
      Height = 21
      ItemHeight = 0
      TabOrder = 1
      Text = 'cbJuryCategory'
    end
  end
end
