object RelayPositionDialog: TRelayPositionDialog
  Left = 432
  Top = 175
  BorderWidth = 16
  Caption = #1050#1072#1088#1090#1086#1095#1082#1072' '#1091#1095#1072#1089#1090#1085#1080#1082#1072
  ClientHeight = 408
  ClientWidth = 335
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object lEvent: TLabel
    Left = 0
    Top = 16
    Width = 30
    Height = 13
    Caption = 'lEvent'
  end
  object lEventShort: TLabel
    Left = 0
    Top = 0
    Width = 55
    Height = 13
    Caption = 'lEventShort'
  end
  object lShooter: TLabel
    Left = 0
    Top = 32
    Width = 39
    Height = 13
    Caption = 'lShooter'
  end
  object lPos: TLabel
    Left = 8
    Top = 110
    Width = 24
    Height = 13
    Caption = #1065#1080#1090':'
    Layout = tlCenter
  end
  object lPos2: TLabel
    Left = 8
    Top = 138
    Width = 89
    Height = 13
    Caption = #1065#1080#1090' (2-'#1103' '#1086#1095#1077#1088#1077#1076#1100')'
    Layout = tlCenter
  end
  object lRelay: TLabel
    Left = 8
    Top = 82
    Width = 36
    Height = 13
    Caption = #1057#1084#1077#1085#1072':'
    Layout = tlCenter
  end
  object btnOk: TButton
    Left = 168
    Top = 336
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 10
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 256
    Top = 336
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 11
    OnClick = btnCancelClick
  end
  object cbDistrictPoints: TCheckBox
    Left = 0
    Top = 296
    Width = 145
    Height = 17
    Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1086#1082#1088#1091#1075
    TabOrder = 8
    OnClick = cbDistrictPointsClick
  end
  object cbForTeam: TCheckBox
    Left = 0
    Top = 250
    Width = 145
    Height = 17
    Caption = #1050#1086#1084#1072#1085#1076#1085#1086#1077' '#1087#1077#1088#1074#1077#1085#1089#1090#1074#1086
    TabOrder = 5
  end
  object cbOutOfRank: TCheckBox
    Left = 0
    Top = 319
    Width = 145
    Height = 17
    Caption = #1042#1085#1077' '#1082#1086#1085#1082#1091#1088#1089#1072
    TabOrder = 9
    OnClick = cbOutOfRankClick
  end
  object cbRegionPoints: TCheckBox
    Left = 0
    Top = 273
    Width = 145
    Height = 17
    Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1088#1077#1075#1080#1086#1085
    TabOrder = 7
    OnClick = cbRegionPointsClick
  end
  object cbTeamForPoints: TComboBox
    Left = 152
    Top = 221
    Width = 153
    Height = 21
    ItemHeight = 0
    TabOrder = 4
    Text = 'cbTeamForPoints'
    OnChange = cbTeamForPointsChange
  end
  object cbTeamForResults: TComboBox
    Left = 153
    Top = 248
    Width = 153
    Height = 21
    ItemHeight = 0
    TabOrder = 6
    Text = 'cbTeamForResults'
  end
  object cbTeamPoints: TCheckBox
    Left = 0
    Top = 226
    Width = 145
    Height = 17
    Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1082#1086#1084#1072#1085#1076#1091
    TabOrder = 3
    OnClick = cbTeamPointsClick
  end
  object edtPos: TEdit
    Left = 136
    Top = 108
    Width = 145
    Height = 21
    TabOrder = 1
    Text = 'edtPos'
    OnKeyPress = edtPosKeyPress
  end
  object edtPos2: TEdit
    Left = 136
    Top = 136
    Width = 145
    Height = 21
    TabOrder = 2
    Text = 'edtPos2'
    OnKeyPress = edtPos2KeyPress
  end
  object edtRelay: TEdit
    Left = 136
    Top = 72
    Width = 145
    Height = 21
    TabOrder = 0
    Text = 'edtRelay'
    OnKeyPress = edtRelayKeyPress
  end
end
