object RateTableForm: TRateTableForm
  Left = 113
  Top = 62
  BorderWidth = 8
  Caption = 'RateTableForm'
  ClientHeight = 698
  ClientWidth = 1031
  Color = clBtnFace
  Constraints.MinHeight = 492
  Constraints.MinWidth = 615
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 16
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1031
    Height = 698
    ActivePage = tsBonus
    Align = alClient
    HotTrack = True
    MultiLine = True
    TabOrder = 0
    TabStop = False
    object tsTable: TTabSheet
      BorderWidth = 8
      Caption = '  '#1041#1072#1083#1083#1099' '#1079#1072' '#1079#1072#1085#1103#1090#1099#1077' '#1084#1077#1089#1090#1072' (F7)   '
      object Splitter2: TSplitter
        Left = 0
        Top = 228
        Width = 1007
        Height = 10
        Cursor = crVSplit
        Align = alTop
        ExplicitWidth = 1002
      end
      object lbChamps: TListBox
        Left = 0
        Top = 0
        Width = 1007
        Height = 228
        Align = alTop
        ItemHeight = 16
        TabOrder = 0
        OnClick = lbChampsClick
      end
      object sgTable: TStringGrid
        Left = 0
        Top = 238
        Width = 1007
        Height = 413
        Align = alClient
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing, goThumbTracking]
        TabOrder = 1
        OnKeyDown = sgTableKeyDown
        OnSelectCell = sgTableSelectCell
      end
    end
    object tsBonus: TTabSheet
      BorderWidth = 8
      Caption = '   '#1044#1086#1073#1072#1074#1083#1077#1085#1080#1103' '#1079#1072' '#1088#1077#1079#1091#1083#1100#1090#1072#1090' (F3)   '
      ImageIndex = 1
      OnResize = tsBonusResize
      DesignSize = (
        1007
        651)
      object lMinResult: TLabel
        Left = 492
        Top = 512
        Width = 356
        Height = 100
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = #1052#1080#1085#1080#1084#1072#1083#1100#1085#1072#1081' '#1088#1077#1079#1091#1083#1100#1090#1072#1090', '#1087#1088#1080' '#1082#1086#1090#1086#1088#1086#1084' '#1085#1072#1095#1080#1089#1083#1103#1077#1090#1089#1103' '#1088#1077#1081#1090#1080#1085#1075
        WordWrap = True
      end
      object lBonus: TLabel
        Left = 440
        Top = 14
        Width = 83
        Height = 16
        Caption = #1041#1077#1079' '#1076#1077#1089#1103#1090#1099#1093':'
      end
      object lBonus10: TLabel
        Left = 751
        Top = 11
        Width = 78
        Height = 16
        Caption = #1057' '#1076#1077#1089#1103#1090#1099#1084#1080':'
      end
      object lbEvents: TListBox
        Left = 0
        Top = 14
        Width = 434
        Height = 638
        ItemHeight = 16
        TabOrder = 0
        OnClick = lbEventsClick
        OnKeyDown = lbEventsKeyDown
      end
      object btnBack: TButton
        Left = 492
        Top = 436
        Width = 445
        Height = 30
        Caption = #1042#1077#1088#1085#1091#1090#1100
        TabOrder = 1
        OnClick = btnBackClick
      end
      object edtMinResult: TEdit
        Left = 886
        Top = 508
        Width = 90
        Height = 24
        TabOrder = 2
        Text = 'edtMinResult'
        OnChange = meMinResultChange
        OnKeyDown = meMinResultKeyDown
      end
      object vleBonus: TValueListEditor
        Left = 440
        Top = 64
        Width = 305
        Height = 366
        KeyOptions = [keyEdit, keyAdd, keyDelete, keyUnique]
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goTabs, goThumbTracking]
        TabOrder = 3
        TitleCaptions.Strings = (
          #1056#1077#1079#1091#1083#1100#1090#1072#1090
          #1041#1072#1083#1083#1099)
        OnKeyDown = vleBonusKeyDown
        OnSelectCell = vleBonusSelectCell
        ColWidths = (
          180
          119)
      end
      object vleBonus10: TValueListEditor
        Left = 751
        Top = 64
        Width = 234
        Height = 366
        KeyOptions = [keyEdit, keyAdd, keyDelete, keyUnique]
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goTabs, goThumbTracking]
        TabOrder = 4
        TitleCaptions.Strings = (
          #1056#1077#1079#1091#1083#1100#1090#1072#1090
          #1041#1072#1083#1083#1099)
        OnKeyDown = vleBonus10KeyDown
        OnSelectCell = vleBonus10SelectCell
        ColWidths = (
          180
          48)
      end
    end
    object tsTiming: TTabSheet
      BorderWidth = 8
      Caption = '   '#1057#1088#1086#1082#1080' '#1080#1089#1090#1077#1095#1077#1085#1080#1103' (F4)   '
      ImageIndex = 2
      object sgTimings: TStringGrid
        Left = 0
        Top = 0
        Width = 1007
        Height = 651
        Align = alClient
        ColCount = 3
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goTabs]
        TabOrder = 0
        OnKeyDown = sgTimingsKeyDown
        OnSelectCell = sgTimingsSelectCell
        RowHeights = (
          24
          24
          24
          24
          24)
      end
    end
  end
end
