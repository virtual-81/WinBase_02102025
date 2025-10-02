object SelectShooterDialog: TSelectShooterDialog
  Left = 212
  Top = 203
  BorderWidth = 8
  Caption = #1042#1099#1073#1077#1088#1080#1090#1077' '#1089#1087#1086#1088#1090#1089#1084#1077#1085#1072
  ClientHeight = 546
  ClientWidth = 831
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 106
  TextHeight = 16
  object lNameC: TLabel
    Left = 0
    Top = 315
    Width = 104
    Height = 16
    Caption = #1060#1072#1084#1080#1083#1080#1103', '#1048#1084#1103':'
  end
  object lName: TLabel
    Left = 138
    Top = 315
    Width = 40
    Height = 16
    Caption = 'lName'
  end
  object lBYearC: TLabel
    Left = 0
    Top = 358
    Width = 101
    Height = 16
    Caption = #1043#1086#1076' '#1088#1086#1078#1076#1077#1085#1080#1103':'
  end
  object lBYear: TLabel
    Left = 108
    Top = 358
    Width = 28
    Height = 16
    Caption = '0000'
  end
  object lBDateC: TLabel
    Left = 177
    Top = 358
    Width = 110
    Height = 16
    Caption = #1044#1072#1090#1072' '#1088#1086#1078#1076#1077#1085#1080#1103':'
  end
  object lBDate: TLabel
    Left = 286
    Top = 358
    Width = 31
    Height = 16
    Caption = '00.00'
  end
  object lISSFIDC: TLabel
    Left = 0
    Top = 335
    Width = 48
    Height = 16
    Caption = 'ISSF ID:'
  end
  object lISSFID: TLabel
    Left = 98
    Top = 335
    Width = 45
    Height = 16
    Caption = 'lISSFID'
  end
  object lQualC: TLabel
    Left = 0
    Top = 384
    Width = 106
    Height = 16
    Caption = #1050#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1103':'
  end
  object lQual: TLabel
    Left = 148
    Top = 384
    Width = 31
    Height = 16
    Caption = 'lQual'
  end
  object lRegionC: TLabel
    Left = 0
    Top = 443
    Width = 53
    Height = 16
    Caption = #1056#1077#1075#1080#1086#1085':'
  end
  object lDistrictC: TLabel
    Left = 0
    Top = 414
    Width = 43
    Height = 16
    Caption = #1054#1082#1088#1091#1075':'
  end
  object lDistrict: TLabel
    Left = 69
    Top = 414
    Width = 43
    Height = 16
    Caption = 'lDistrict'
  end
  object lRegion: TLabel
    Left = 79
    Top = 443
    Width = 47
    Height = 16
    Caption = 'lRegion'
  end
  object lTownC: TLabel
    Left = 0
    Top = 473
    Width = 45
    Height = 16
    Caption = #1043#1086#1088#1086#1076':'
  end
  object lTown: TLabel
    Left = 79
    Top = 473
    Width = 36
    Height = 16
    Caption = 'lTown'
  end
  object lClubC: TLabel
    Left = 0
    Top = 502
    Width = 34
    Height = 16
    Caption = #1050#1083#1091#1073':'
  end
  object lClub: TLabel
    Left = 69
    Top = 502
    Width = 30
    Height = 16
    Caption = 'lClub'
  end
  object lbGroups: TListBox
    Left = 0
    Top = 0
    Width = 316
    Height = 297
    Style = lbVirtualOwnerDraw
    AutoComplete = False
    ItemHeight = 13
    TabOrder = 0
    OnClick = lbGroupsClick
    OnDrawItem = lbGroupsDrawItem
    OnKeyDown = lbGroupsKeyDown
    OnKeyPress = lbGroupsKeyPress
  end
  object lbShooters: TListBox
    Left = 325
    Top = 0
    Width = 503
    Height = 297
    Style = lbVirtualOwnerDraw
    AutoComplete = False
    ItemHeight = 13
    TabOrder = 1
    OnClick = lbShootersClick
    OnDrawItem = lbShootersDrawItem
    OnKeyDown = lbShootersKeyDown
    OnKeyPress = lbShootersKeyPress
  end
  object btnOk: TButton
    Left = 630
    Top = 315
    Width = 92
    Height = 31
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 738
    Top = 315
    Width = 93
    Height = 31
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 3
  end
end
