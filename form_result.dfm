object EditResultDialog: TEditResultDialog
  Left = 346
  Top = 195
  ActiveControl = edtDate
  BorderIcons = []
  BorderStyle = bsDialog
  BorderWidth = 16
  Caption = #1047#1072#1087#1080#1089#1100' '#1086' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1077
  ClientHeight = 305
  ClientWidth = 481
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
  object lEvent: TLabel
    Left = 0
    Top = 62
    Width = 64
    Height = 13
    Caption = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077
  end
  object lChamp: TLabel
    Left = 0
    Top = 30
    Width = 73
    Height = 13
    Caption = #1057#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1077
  end
  object lDate: TLabel
    Left = 8
    Top = 0
    Width = 79
    Height = 13
    Caption = #1044#1072#1090#1072' ('#1076#1076'.'#1084#1084'.'#1075#1075')'
  end
  object lCountry: TLabel
    Left = 24
    Top = 96
    Width = 36
    Height = 13
    Caption = #1057#1090#1088#1072#1085#1072
  end
  object lTown: TLabel
    Left = 16
    Top = 128
    Width = 30
    Height = 13
    Caption = #1043#1086#1088#1086#1076
  end
  object lRank: TLabel
    Left = 32
    Top = 184
    Width = 32
    Height = 13
    Caption = #1052#1077#1089#1090#1086
  end
  object lComp: TLabel
    Left = 8
    Top = 216
    Width = 104
    Height = 13
    Caption = #1054#1089#1085#1086#1074#1085#1086#1081' '#1088#1077#1079#1091#1083#1100#1090#1072#1090
  end
  object lFinal: TLabel
    Left = 16
    Top = 240
    Width = 35
    Height = 13
    Caption = #1060#1080#1085#1072#1083
  end
  object btnOk: TButton
    Left = 312
    Top = 256
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 9
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 400
    Top = 256
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 10
  end
  object cbJunior: TCheckBox
    Left = 120
    Top = 152
    Width = 361
    Height = 17
    Caption = #1070#1085#1080#1086#1088#1099
    TabOrder = 5
    OnKeyDown = cbJuniorKeyDown
  end
  object cbEvent: TComboBox
    Left = 120
    Top = 56
    Width = 361
    Height = 21
    ItemHeight = 13
    TabOrder = 2
    OnChange = cbEventChange
    OnKeyDown = cbEventKeyDown
    OnKeyPress = edtDateKeyPress
  end
  object cbChampionship: TComboBox
    Left = 120
    Top = 24
    Width = 361
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    OnKeyDown = cbChampionshipKeyDown
    OnKeyPress = edtDateKeyPress
  end
  object edtDate: TEdit
    Left = 120
    Top = 0
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'edtDate'
    OnKeyDown = leDateKeyDown
    OnKeyPress = edtDateKeyPress
  end
  object edtCountry: TEdit
    Left = 120
    Top = 96
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'edtCountry'
    OnKeyDown = leCountryKeyDown
    OnKeyPress = edtDateKeyPress
  end
  object edtTown: TEdit
    Left = 120
    Top = 128
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'edtTown'
    OnKeyDown = leTownKeyDown
    OnKeyPress = edtDateKeyPress
  end
  object edtRank: TEdit
    Left = 120
    Top = 184
    Width = 121
    Height = 21
    TabOrder = 6
    Text = 'edtRank'
    OnKeyDown = leRankKeyDown
    OnKeyPress = edtDateKeyPress
  end
  object edtComp: TEdit
    Left = 120
    Top = 216
    Width = 121
    Height = 21
    TabOrder = 7
    Text = 'edtComp'
    OnKeyDown = leCompKeyDown
    OnKeyPress = edtDateKeyPress
  end
  object edtFinal: TEdit
    Left = 120
    Top = 240
    Width = 121
    Height = 21
    TabOrder = 8
    Text = 'edtFinal'
    OnKeyDown = leFinalKeyDown
    OnKeyPress = edtDateKeyPress
  end
end
