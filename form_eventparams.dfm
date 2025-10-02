object EventParamsDialog: TEventParamsDialog
  Left = 325
  Top = 160
  BorderStyle = bsDialog
  BorderWidth = 16
  Caption = 'EventParamsDialog'
  ClientHeight = 764
  ClientWidth = 710
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object lRelayTime: TLabel
    Left = 140
    Top = 506
    Width = 102
    Height = 16
    Caption = #1042#1088#1077#1085#1103' '#1085#1072' '#1089#1084#1077#1085#1091
    Layout = tlCenter
  end
  object lCode: TLabel
    Left = 10
    Top = 10
    Width = 211
    Height = 16
    Caption = #1050#1086#1076' '#1089#1087#1086#1088#1090#1080#1074#1085#1086#1081' '#1082#1083#1072#1089#1089#1080#1092#1080#1082#1072#1094#1080#1080
  end
  object lName: TLabel
    Left = 10
    Top = 47
    Width = 117
    Height = 16
    Caption = #1055#1086#1083#1085#1086#1077' '#1085#1072#1079#1074#1072#1085#1080#1077
  end
  object lShortName: TLabel
    Left = 20
    Top = 69
    Width = 96
    Height = 16
    Caption = #1040#1073#1073#1088#1077#1074#1080#1072#1090#1091#1088#1072
  end
  object lMQSResult: TLabel
    Left = 23
    Top = 334
    Width = 102
    Height = 16
    Caption = 'MQS '#1088#1077#1079#1091#1083#1100#1090#1072#1090
  end
  object lMinRatedResult: TLabel
    Left = -2
    Top = 367
    Width = 253
    Height = 16
    Caption = #1052#1080#1085#1080#1084#1072#1083#1100#1085#1099#1081' '#1088#1077#1081#1090#1080#1085#1075#1086#1074#1099#1081' '#1088#1077#1079#1091#1083#1100#1090#1072#1090
  end
  object lFinalPlaces: TLabel
    Left = 0
    Top = 398
    Width = 188
    Height = 16
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1092#1080#1085#1072#1083#1100#1085#1099#1093' '#1084#1077#1089#1090
  end
  object lFinalShots: TLabel
    Left = 0
    Top = 421
    Width = 228
    Height = 16
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1092#1080#1085#1072#1083#1100#1085#1099#1093' '#1074#1099#1089#1090#1088#1077#1083#1086#1074
  end
  object lStages: TLabel
    Left = 0
    Top = 453
    Width = 154
    Height = 16
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1087#1086#1083#1086#1078#1077#1085#1080#1081
  end
  object lSeries: TLabel
    Left = 0
    Top = 482
    Width = 215
    Height = 16
    Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1089#1077#1088#1080#1081' '#1085#1072' '#1087#1086#1083#1086#1078#1077#1085#1080#1077
  end
  object lQResults: TLabel
    Left = 423
    Top = 89
    Width = 212
    Height = 16
    Caption = #1050#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1086#1085#1085#1099#1077' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099
  end
  object cbFinalFracs: TCheckBox
    Left = 418
    Top = 532
    Width = 298
    Height = 21
    Caption = #1044#1088#1086#1073#1085#1099#1077' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1074' '#1092#1080#1085#1072#1083#1077
    TabOrder = 4
  end
  object btnOk: TButton
    Left = 491
    Top = 591
    Width = 92
    Height = 31
    Caption = 'OK'
    Default = True
    TabOrder = 5
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 608
    Top = 591
    Width = 92
    Height = 31
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 6
  end
  object dtRelayTime: TDateTimePicker
    Left = 295
    Top = 512
    Width = 101
    Height = 24
    Date = 38754.027730879600000000
    Time = 38754.027730879600000000
    Kind = dtkTime
    TabOrder = 2
  end
  object gbType: TGroupBox
    Left = 20
    Top = 118
    Width = 375
    Height = 131
    Caption = ' '#1058#1080#1087' '#1091#1087#1088#1072#1078#1085#1077#1085#1080#1103' '
    TabOrder = 0
    object rbRegular: TRadioButton
      Left = 20
      Top = 31
      Width = 119
      Height = 21
      Caption = #1054#1073#1099#1095#1085#1086#1077
      TabOrder = 0
    end
    object rbRapidFire: TRadioButton
      Left = 158
      Top = 30
      Width = 119
      Height = 20
      Caption = #1052#1055'-8'
      TabOrder = 1
    end
    object rbCenterFire: TRadioButton
      Left = 20
      Top = 49
      Width = 119
      Height = 21
      Caption = #1052#1055'-5'
      TabOrder = 2
    end
    object rbMovingTarget: TRadioButton
      Left = 158
      Top = 49
      Width = 119
      Height = 21
      Caption = #1052#1042'-12, '#1042#1055'-12'
      TabOrder = 3
    end
    object rbCFP2013: TRadioButton
      Left = 20
      Top = 78
      Width = 130
      Height = 20
      Caption = #1052#1055'-5 (2013)'
      TabOrder = 4
    end
    object rb3P2013: TRadioButton
      Left = 158
      Top = 78
      Width = 139
      Height = 20
      Caption = #1052#1042'-6, '#1052#1042'-5 (2013)'
      TabOrder = 5
    end
    object rbMT2013: TRadioButton
      Left = 20
      Top = 98
      Width = 139
      Height = 21
      Caption = #1042#1055'-11 (2013)'
      TabOrder = 6
    end
  end
  object gbWeaponType: TGroupBox
    Left = 20
    Top = 256
    Width = 375
    Height = 70
    Caption = ' '#1058#1080#1087' '#1086#1088#1091#1078#1080#1103' '
    TabOrder = 1
    object rbRifle: TRadioButton
      Left = 20
      Top = 30
      Width = 119
      Height = 20
      Caption = #1042#1080#1085#1090#1086#1074#1082#1072
      TabOrder = 0
    end
    object rbPistol: TRadioButton
      Left = 158
      Top = 30
      Width = 168
      Height = 20
      Caption = #1055#1080#1089#1090#1086#1083#1077#1090
      TabOrder = 1
    end
    object rbMoving: TRadioButton
      Left = 20
      Top = 49
      Width = 168
      Height = 21
      Caption = #1044#1074#1080#1078#1091#1097#1072#1103#1089#1103' '#1084#1080#1096#1077#1085#1100
      TabOrder = 2
    end
  end
  object cbCompareBySeries: TCheckBox
    Left = 418
    Top = 502
    Width = 297
    Height = 21
    Caption = #1057#1088#1072#1074#1085#1080#1074#1072#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1087#1086' '#1089#1077#1088#1080#1103#1084
    TabOrder = 3
  end
  object btnDeleteResults: TButton
    Left = 0
    Top = 551
    Width = 159
    Height = 31
    Caption = #1059#1076#1072#1083#1080#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099
    TabOrder = 7
    OnClick = btnDeleteResultsClick
  end
  object edtCode: TEdit
    Left = 219
    Top = 10
    Width = 149
    Height = 24
    TabOrder = 8
    Text = 'edtCode'
  end
  object edtName: TEdit
    Left = 148
    Top = 43
    Width = 149
    Height = 24
    TabOrder = 9
    Text = 'edtName'
  end
  object edtShortName: TEdit
    Left = 148
    Top = 76
    Width = 149
    Height = 24
    TabOrder = 10
    Text = 'edtShortName'
  end
  object edtMQSResult: TEdit
    Left = 246
    Top = 334
    Width = 149
    Height = 24
    TabOrder = 11
    Text = 'edtMQSResult'
  end
  object edtMinRatedResult: TEdit
    Left = 246
    Top = 361
    Width = 149
    Height = 24
    TabOrder = 12
    Text = 'edtMinRatedResult'
  end
  object edtFinalPlaces: TEdit
    Left = 246
    Top = 394
    Width = 149
    Height = 24
    TabOrder = 13
    Text = 'edtFinalPlaces'
  end
  object edtFinalShots: TEdit
    Left = 246
    Top = 423
    Width = 149
    Height = 24
    TabOrder = 14
    Text = 'edtFinalShots'
  end
  object edtStages: TEdit
    Left = 246
    Top = 453
    Width = 149
    Height = 24
    TabOrder = 15
    Text = 'edtStages'
  end
  object edtSeries: TEdit
    Left = 246
    Top = 482
    Width = 149
    Height = 24
    TabOrder = 16
    Text = 'edtSeries'
  end
  object sgQualifications: TStringGrid
    Left = 418
    Top = 112
    Width = 292
    Height = 354
    ColCount = 3
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing]
    ScrollBars = ssVertical
    TabOrder = 17
    RowHeights = (
      24
      24
      24
      24
      24)
  end
  object cbCompareByFinal: TCheckBox
    Left = 418
    Top = 474
    Width = 297
    Height = 21
    Caption = #1057#1088#1072#1074#1085#1080#1074#1072#1090#1100' '#1090#1086#1083#1100#1082#1086' '#1092#1080#1085#1072#1083#1099
    TabOrder = 18
  end
end
