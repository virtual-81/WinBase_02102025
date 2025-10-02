object PrintProtocolDialog: TPrintProtocolDialog
  Left = 251
  Top = 212
  BorderStyle = bsDialog
  BorderWidth = 16
  Caption = 'PrintProtocolDialog'
  ClientHeight = 479
  ClientWidth = 393
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 224
    Top = 439
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOkClick
  end
  object gbResults: TGroupBox
    Left = 0
    Top = 176
    Width = 393
    Height = 129
    Caption = ' '#1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1087#1077#1095#1072#1090#1080' '
    TabOrder = 1
    object cbFinal: TCheckBox
      Left = 16
      Top = 24
      Width = 177
      Height = 17
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1092#1080#1085#1072#1083#1072
      TabOrder = 0
    end
    object cbReport: TCheckBox
      Left = 16
      Top = 48
      Width = 177
      Height = 17
      Caption = #1058#1077#1093#1085#1080#1095#1077#1089#1082#1080#1081' '#1086#1090#1095#1077#1090
      TabOrder = 1
    end
    object cbTeams: TCheckBox
      Left = 16
      Top = 72
      Width = 177
      Height = 17
      Caption = #1050#1086#1084#1072#1085#1076#1085#1086#1077' '#1087#1077#1088#1074#1077#1085#1089#1090#1074#1086
      TabOrder = 2
    end
    object cbTeamPoints: TCheckBox
      Left = 16
      Top = 96
      Width = 177
      Height = 17
      Caption = #1050#1086#1084#1072#1085#1076#1085#1099#1077' '#1073#1072#1083#1083#1099
      TabOrder = 3
    end
    object cbRegionPoints: TCheckBox
      Left = 199
      Top = 25
      Width = 177
      Height = 17
      Caption = #1041#1072#1083#1083#1099' '#1088#1077#1075#1080#1086#1085#1072#1084
      TabOrder = 4
    end
    object cbDistrictPoints: TCheckBox
      Left = 200
      Top = 48
      Width = 177
      Height = 17
      Caption = #1041#1072#1083#1083#1099' '#1086#1082#1088#1091#1075#1072#1084
      TabOrder = 5
    end
    object cbPrintJury: TCheckBox
      Left = 199
      Top = 71
      Width = 191
      Height = 17
      Caption = #1055#1077#1095#1072#1090#1072#1090#1100' "'#1057#1091#1076#1100#1103' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1081'"'
      TabOrder = 6
    end
    object cbPrintSecretery: TCheckBox
      Left = 176
      Top = 96
      Width = 214
      Height = 17
      Caption = #1055#1077#1095#1072#1090#1072#1090#1100' "'#1057#1077#1082#1088#1077#1090#1072#1090#1100' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1081'"'
      TabOrder = 7
    end
  end
  object btnCancel: TButton
    Left = 318
    Top = 439
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 4
  end
  object gbFormat: TGroupBox
    Left = 0
    Top = 128
    Width = 393
    Height = 41
    Caption = ' '#1060#1086#1088#1084#1072#1090' '#1087#1088#1086#1090#1086#1082#1086#1083#1072' '
    TabOrder = 0
    object rbRus: TRadioButton
      Left = 16
      Top = 16
      Width = 113
      Height = 17
      Caption = #1056#1086#1089#1089#1080#1081#1089#1082#1080#1081
      TabOrder = 0
      OnClick = rbRusClick
    end
    object rbInt: TRadioButton
      Left = 200
      Top = 13
      Width = 113
      Height = 17
      Caption = #1052#1077#1078#1076#1091#1085#1072#1088#1086#1076#1085#1099#1081
      TabOrder = 1
      OnClick = rbIntClick
    end
  end
  object gbGroups: TGroupBox
    Left = 0
    Top = 384
    Width = 393
    Height = 41
    Caption = #1043#1088#1091#1087#1087#1099' '#1082#1086#1084#1072#1085#1076
    TabOrder = 2
    object cbGroups: TCheckBox
      Left = 16
      Top = 16
      Width = 361
      Height = 17
      Caption = #1055#1077#1095#1072#1090#1072#1090#1100' '#1087#1086' '#1075#1088#1091#1087#1087#1072#1084
      TabOrder = 0
    end
  end
end
