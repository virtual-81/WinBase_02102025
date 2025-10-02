object InputResultDialog: TInputResultDialog
  Left = 312
  Top = 268
  BorderWidth = 16
  Caption = 'InputResultDialog'
  ClientHeight = 445
  ClientWidth = 627
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object lEvent: TLabel
    Left = 0
    Top = 248
    Width = 64
    Height = 13
    Caption = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077
  end
  object lGroup: TLabel
    Left = 0
    Top = 0
    Width = 35
    Height = 13
    Caption = #1043#1088#1091#1087#1087#1072
  end
  object lShooter: TLabel
    Left = 248
    Top = 0
    Width = 77
    Height = 13
    Caption = #1060#1072#1084#1080#1083#1080#1103', '#1048#1084#1103
  end
  object lDate: TLabel
    Left = 0
    Top = 305
    Width = 26
    Height = 13
    Caption = #1044#1072#1090#1072
  end
  object lRank: TLabel
    Left = 225
    Top = 305
    Width = 32
    Height = 13
    Caption = #1052#1077#1089#1090#1086
  end
  object lComp: TLabel
    Left = 344
    Top = 304
    Width = 52
    Height = 13
    Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090
  end
  object lFinal: TLabel
    Left = 449
    Top = 305
    Width = 35
    Height = 13
    Caption = #1060#1080#1085#1072#1083
  end
  object lbGroups: TListBox
    Left = 0
    Top = 16
    Width = 233
    Height = 225
    Style = lbOwnerDrawFixed
    ItemHeight = 13
    TabOrder = 0
    OnClick = lbGroupsClick
    OnDrawItem = lbGroupsDrawItem
    OnExit = lbGroupsExit
    OnKeyDown = lbGroupsKeyDown
    OnKeyPress = lbGroupsKeyPress
  end
  object lbShooters: TListBox
    Left = 248
    Top = 16
    Width = 297
    Height = 225
    Style = lbOwnerDrawFixed
    ItemHeight = 13
    TabOrder = 1
    OnClick = lbShootersClick
    OnDrawItem = lbShootersDrawItem
    OnKeyDown = lbShootersKeyDown
    OnKeyPress = lbShootersKeyPress
  end
  object cbJunior: TCheckBox
    Left = 136
    Top = 326
    Width = 81
    Height = 17
    Caption = #1070#1085#1080#1086#1088#1099
    TabOrder = 4
    OnKeyPress = cbJuniorKeyPress
  end
  object cbEvent: TComboBox
    Left = 0
    Top = 264
    Width = 545
    Height = 21
    ItemHeight = 0
    TabOrder = 2
    Text = 'cbEvent'
    OnChange = cbEventChange
    OnKeyDown = cbEventKeyDown
    OnKeyPress = cbEventKeyPress
  end
  object btnOk: TButton
    Left = 384
    Top = 376
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 8
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 465
    Top = 376
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 9
    OnClick = btnCancelClick
  end
  object edtDate: TEdit
    Left = 0
    Top = 324
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'edtDate'
    OnKeyPress = leDateKeyPress
  end
  object edtRank: TEdit
    Left = 225
    Top = 324
    Width = 100
    Height = 21
    TabOrder = 5
    Text = 'edtRank'
    OnChange = edtRankChange
    OnKeyPress = leRankKeyPress
  end
  object edtComp: TEdit
    Left = 344
    Top = 324
    Width = 99
    Height = 21
    TabOrder = 6
    Text = 'edtComp'
    OnKeyPress = leCompKeyPress
  end
  object edtFinal: TEdit
    Left = 449
    Top = 324
    Width = 96
    Height = 21
    TabOrder = 7
    Text = 'edtFinal'
    OnKeyPress = leFinalKeyPress
  end
end
