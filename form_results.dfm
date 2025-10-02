object ShooterResultsForm: TShooterResultsForm
  Left = 173
  Top = 192
  Caption = 'ShooterResultsForm'
  ClientHeight = 519
  ClientWidth = 773
  Color = clWindow
  Constraints.MinWidth = 630
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object HeaderControl1: THeaderControl
    Tag = 1
    Left = 0
    Top = 0
    Width = 773
    Height = 17
    Sections = <
      item
        ImageIndex = -1
        MinWidth = 50
        Text = #1044#1072#1090#1072
        Width = 100
      end
      item
        AllowClick = False
        ImageIndex = -1
        MinWidth = 100
        Text = #1057#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1077', '#1091#1087#1088#1072#1078#1085#1077#1085#1080#1077
        Width = 300
      end
      item
        ImageIndex = -1
        MinWidth = 25
        Text = #1052#1077#1089#1090#1086
        Width = 50
      end
      item
        ImageIndex = -1
        MinWidth = 25
        Text = #1056#1077#1079#1091#1083#1100#1090#1072#1090
        Width = 75
      end
      item
        AllowClick = False
        ImageIndex = -1
        MinWidth = 25
        Text = #1042#1089#1077#1075#1086
        Width = 50
      end
      item
        ImageIndex = -1
        MinWidth = 25
        Text = #1056#1077#1081#1090#1080#1085#1075
        Width = 75
      end>
    OnSectionClick = HeaderControl1SectionClick
    OnSectionResize = HeaderControl1SectionResize
    OnResize = HeaderControl1Resize
  end
  object lbResults: TListBox
    Tag = 1
    Left = 0
    Top = 17
    Width = 773
    Height = 419
    Style = lbOwnerDrawFixed
    Align = alClient
    BorderStyle = bsNone
    Color = clWhite
    ItemHeight = 13
    TabOrder = 1
    OnDblClick = lbResultsDblClick
    OnDrawItem = lbResultsDrawItem
    OnKeyDown = lbResultsKeyDown
    ExplicitHeight = 399
  end
  object pnlFilter: TPanel
    Tag = 1
    Left = 0
    Top = 436
    Width = 773
    Height = 83
    Align = alBottom
    BevelOuter = bvNone
    BorderStyle = bsSingle
    TabOrder = 2
    Visible = False
    OnResize = pnlFilterResize
    ExplicitTop = 416
    object btnCloseFilter: TSpeedButton
      Left = 742
      Top = 8
      Width = 23
      Height = 22
      Caption = 'X'
      OnClick = btnCloseFilterClick
    end
    object clbFilter: TCheckListBox
      Left = 9
      Top = 9
      Width = 552
      Height = 56
      OnClickCheck = clbFilterClickCheck
      BevelInner = bvSpace
      BevelOuter = bvNone
      BevelKind = bkFlat
      BorderStyle = bsNone
      ItemHeight = 13
      TabOrder = 0
      OnKeyDown = clbFilterKeyDown
    end
  end
  object MainMenu1: TMainMenu
    AutoHotkeys = maManual
    Left = 408
    Top = 112
    object mnuResults: TMenuItem
      Tag = 1
      Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
      GroupIndex = 4
      object mnuAdd1: TMenuItem
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100
        ShortCut = 16462
        OnClick = mnuAdd1Click
      end
      object mnuDelete1: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100
        ShortCut = 46
        OnClick = mnuDelete1Click
      end
      object mnuFilter1: TMenuItem
        Caption = #1060#1080#1083#1100#1090#1088' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074'...'
        ShortCut = 115
        OnClick = mnuFilter1Click
      end
      object mnuStats: TMenuItem
        Caption = #1057#1090#1072#1090#1080#1089#1090#1080#1082#1072'...'
        OnClick = mnuStatsClick
      end
      object mnuPrint: TMenuItem
        Caption = #1055#1077#1095#1072#1090#1100'...'
        OnClick = mnuPrintClick
      end
      object mnuSaveToPDF: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' PDF...'
        OnClick = mnuSaveToPDFClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuMark: TMenuItem
        Caption = #1054#1090#1084#1077#1090#1080#1090#1100'/'#1089#1085#1103#1090#1100
        OnClick = mnuMarkClick
      end
      object mnuMarkAll: TMenuItem
        Caption = #1054#1090#1084#1077#1090#1080#1090#1100'/'#1089#1085#1103#1090#1100' '#1074#1089#1077
        OnClick = mnuMarkAllClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mnuClose: TMenuItem
        Caption = #1047#1072#1082#1088#1099#1090#1100
        OnClick = mnuCloseClick
      end
    end
  end
  object SaveToPDFDialog: TSaveDialog
    DefaultExt = '*.pdf'
    Filter = 'Adobe PDF (*.pdf)|*.pdf'
    FilterIndex = 0
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' PDF'
    Left = 48
    Top = 64
  end
end
