object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 619
  ClientWidth = 845
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 845
    Height = 21
    AutoSize = True
    ButtonHeight = 19
    ButtonWidth = 74
    Caption = 'ToolBar1'
    DrawingStyle = dsGradient
    Flat = False
    Indent = 4
    List = True
    ShowCaptions = True
    TabOrder = 0
    object tbShooters: TToolButton
      Left = 4
      Top = 2
      AutoSize = True
      Caption = #1057#1087#1086#1088#1090#1089#1084#1077#1085#1099
      ImageIndex = 0
      OnClick = tbShootersClick
    end
    object tbResults: TToolButton
      Left = 82
      Top = 2
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
      ImageIndex = 1
      OnClick = tbResultsClick
    end
  end
  object pnlResults: TPanel
    Left = 16
    Top = 320
    Width = 625
    Height = 265
    BevelOuter = bvNone
    BorderWidth = 4
    FullRepaint = False
    TabOrder = 1
    object lChamp1: TLabel
      Left = 159
      Top = 32
      Width = 77
      Height = 13
      Caption = #1057#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1077':'
    end
    object lChamp: TLabel
      Left = 155
      Top = 32
      Width = 81
      Height = 13
      Caption = '< '#1085#1077' '#1074#1099#1073#1088#1072#1085#1086' >'
    end
    object lEvent: TLabel
      Left = 155
      Top = 48
      Width = 81
      Height = 13
      Caption = '< '#1085#1077' '#1074#1099#1073#1088#1072#1085#1086' >'
    end
    object lEvent1: TLabel
      Left = 169
      Top = 48
      Width = 67
      Height = 13
      Caption = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077':'
    end
    object lDate1: TLabel
      Left = 206
      Top = 67
      Width = 30
      Height = 13
      Caption = #1044#1072#1090#1072':'
    end
    object lDate: TLabel
      Left = 155
      Top = 64
      Width = 81
      Height = 13
      Caption = '< '#1085#1077' '#1074#1099#1073#1088#1072#1085#1086' >'
    end
    object Splitter2: TSplitter
      Left = 52
      Top = 4
      Width = 8
      Height = 257
      OnMoved = Splitter2Moved
      ExplicitLeft = 81
      ExplicitTop = 9
      ExplicitHeight = 143
    end
    object tvResults: TTreeView
      Left = 4
      Top = 4
      Width = 48
      Height = 257
      Align = alLeft
      Indent = 19
      TabOrder = 0
    end
  end
  object pnlShooters: TPanel
    Left = 8
    Top = 24
    Width = 633
    Height = 281
    BevelOuter = bvNone
    BorderWidth = 8
    FullRepaint = False
    TabOrder = 2
    object Splitter1: TSplitter
      Left = 129
      Top = 25
      Width = 8
      Height = 248
      OnCanResize = Splitter1CanResize
      OnMoved = Splitter1Moved
      ExplicitTop = 8
      ExplicitHeight = 265
    end
    object lbGroups: TListBox
      Left = 8
      Top = 25
      Width = 121
      Height = 248
      Align = alLeft
      Constraints.MinWidth = 100
      ItemHeight = 13
      TabOrder = 0
      OnClick = lbGroupsClick
      ExplicitTop = 8
      ExplicitHeight = 265
    end
    object cbEvents: TComboBox
      Left = 143
      Top = 8
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbEventsChange
    end
    object HeaderControl1: THeaderControl
      Left = 8
      Top = 8
      Width = 617
      Height = 17
      FullDrag = False
      HotTrack = True
      Sections = <>
      ExplicitTop = 3
    end
  end
end
