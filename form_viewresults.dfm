object ViewForm: TViewForm
  Left = 126
  Top = 56
  Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074
  ClientHeight = 544
  ClientWidth = 774
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 265
    Top = 0
    Width = 6
    Height = 525
    Color = clBtnFace
    ParentColor = False
    ExplicitHeight = 529
  end
  object pnlResults: TPanel
    Left = 271
    Top = 0
    Width = 503
    Height = 525
    Align = alClient
    BevelOuter = bvNone
    Constraints.MinHeight = 128
    Constraints.MinWidth = 180
    Ctl3D = True
    ParentColor = True
    ParentCtl3D = False
    TabOrder = 0
    ExplicitHeight = 529
    object lbResults: TListBox
      Left = 0
      Top = 82
      Width = 503
      Height = 447
      Style = lbOwnerDrawFixed
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      DragMode = dmAutomatic
      ItemHeight = 16
      MultiSelect = True
      TabOrder = 0
      OnDrawItem = lbResultsDrawItem
      OnKeyDown = lbResultsKeyDown
      OnMouseDown = lbResultsMouseDown
      OnMouseMove = lbResultsMouseMove
    end
    object HeaderControl1: THeaderControl
      Left = 0
      Top = 65
      Width = 503
      Height = 17
      Sections = <
        item
          AllowClick = False
          ImageIndex = -1
          Text = #1060#1072#1084#1080#1083#1080#1103', '#1048#1084#1103
          Width = 175
        end
        item
          AllowClick = False
          ImageIndex = -1
          Text = #1052#1077#1089#1090#1086
          Width = 50
        end
        item
          AllowClick = False
          ImageIndex = -1
          Text = #1056#1077#1079#1091#1083#1100#1090#1072#1090
          Width = 70
        end
        item
          AllowClick = False
          ImageIndex = -1
          Text = #1057#1091#1084#1084#1072
          Width = 60
        end
        item
          AllowClick = False
          ImageIndex = -1
          Text = #1056#1077#1081#1090#1080#1085#1075
          Width = 60
        end>
      OnSectionResize = HeaderControl1SectionResize
      OnResize = HeaderControl1Resize
    end
    object pnlInfo: TPanel
      Left = 0
      Top = 0
      Width = 503
      Height = 65
      Cursor = crHandPoint
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      OnClick = pnlInfoClick
      object lChamp: TLabel
        Left = 104
        Top = 8
        Width = 77
        Height = 13
        Caption = '< '#1085#1077' '#1074#1099#1073#1088#1072#1085#1086' >'
        OnClick = pnlInfoClick
      end
      object lEvent: TLabel
        Left = 104
        Top = 24
        Width = 77
        Height = 13
        Caption = '< '#1085#1077' '#1074#1099#1073#1088#1072#1085#1086' >'
        OnClick = pnlInfoClick
      end
      object lDate: TLabel
        Left = 104
        Top = 40
        Width = 77
        Height = 13
        Caption = '< '#1085#1077' '#1074#1099#1073#1088#1072#1085#1086' >'
        OnClick = pnlInfoClick
      end
      object lChamp1: TLabel
        Left = 21
        Top = 8
        Width = 76
        Height = 13
        Caption = #1057#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1077':'
        OnClick = pnlInfoClick
      end
      object lEvent1: TLabel
        Left = 30
        Top = 24
        Width = 67
        Height = 13
        Caption = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077':'
        OnClick = pnlInfoClick
      end
      object lDate1: TLabel
        Left = 69
        Top = 43
        Width = 29
        Height = 13
        Caption = #1044#1072#1090#1072':'
        OnClick = pnlInfoClick
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 525
    Width = 774
    Height = 19
    Panels = <>
    ExplicitTop = 529
    ExplicitWidth = 953
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 265
    Height = 525
    Align = alLeft
    DragMode = dmAutomatic
    Indent = 19
    ReadOnly = True
    RightClickSelect = True
    SortType = stData
    TabOrder = 2
    OnChange = TreeView1Change
    OnCompare = TreeView1Compare
    OnDragDrop = TreeView1DragDrop
    OnDragOver = TreeView1DragOver
    OnKeyDown = TreeView1KeyDown
    OnMouseDown = TreeView1MouseDown
    ExplicitHeight = 529
  end
  object pmResult: TPopupMenu
    Left = 376
    Top = 272
    object mnuDelete: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = mnuDeleteClick
    end
  end
  object pmChamp: TPopupMenu
    AutoPopup = False
    Left = 48
    Top = 336
    object mnuChampProps: TMenuItem
      Caption = #1057#1074#1086#1081#1089#1090#1074#1072' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1103
      ShortCut = 115
      OnClick = mnuChampPropsClick
    end
    object mnuAddResultsToChamp: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099
      ShortCut = 117
      OnClick = mnuAddResultsToChampClick
    end
  end
end
