object StartListShootersForm: TStartListShootersForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'StartListShootersForm'
  ClientHeight = 465
  ClientWidth = 786
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object hcShooters: THeaderControl
    Left = 0
    Top = 49
    Width = 786
    Height = 17
    Align = alNone
    FullDrag = False
    HotTrack = True
    Sections = <
      item
        ImageIndex = -1
        Text = #1053#1086#1084#1077#1088
        Width = 60
      end
      item
        ImageIndex = -1
        Text = #1060#1072#1084#1080#1083#1080#1103', '#1048#1084#1103', '#1054#1090#1095#1077#1089#1090#1074#1086
        Width = 150
      end
      item
        ImageIndex = -1
        Text = #1044#1072#1090#1072' '#1088#1086#1078#1076#1077#1085#1080#1103
        Width = 95
      end
      item
        ImageIndex = -1
        Text = #1054#1082#1088#1091#1075
        Width = 75
      end
      item
        ImageIndex = -1
        Text = #1056#1077#1075#1080#1086#1085', '#1043#1086#1088#1086#1076
        Width = 125
      end
      item
        ImageIndex = -1
        Text = #1050#1083#1091#1073
        Width = 125
      end
      item
        ImageIndex = -1
        Text = #1050#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1103
        Width = 75
      end
      item
        ImageIndex = -1
        Text = #1047#1072#1103#1074#1086#1082
        Width = 60
      end
      item
        ImageIndex = -1
        Text = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1103
        Width = 150
      end>
    OnSectionClick = hcShootersSectionClick
    OnSectionResize = hcShootersSectionResize
  end
  object lbShooters: TListBox
    Left = 256
    Top = 111
    Width = 385
    Height = 217
    Style = lbVirtualOwnerDraw
    AutoComplete = False
    ItemHeight = 16
    MultiSelect = True
    TabOrder = 1
    OnClick = lbShootersClick
    OnDblClick = lbShootersDblClick
    OnDrawItem = lbShootersDrawItem
    OnKeyDown = lbShootersKeyDown
    OnKeyPress = lbShootersKeyPress
  end
  object sbHorz: TScrollBar
    Left = 64
    Top = 288
    Width = 121
    Height = 17
    PageSize = 0
    TabOrder = 2
    OnChange = sbHorzChange
  end
  object btnPrint: TButton
    Left = 16
    Top = 8
    Width = 75
    Height = 25
    Caption = 'btnPrint'
    TabOrder = 3
    OnClick = btnPrintClick
  end
  object btnSave: TButton
    Left = 112
    Top = 8
    Width = 75
    Height = 25
    Caption = 'btnSave'
    TabOrder = 4
    OnClick = btnSaveClick
  end
end
