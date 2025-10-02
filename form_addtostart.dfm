object AddToStartDialog: TAddToStartDialog
  Left = 469
  Top = 102
  BorderWidth = 8
  Caption = #1047#1072#1103#1074#1082#1072' '#1085#1072' '#1089#1086#1088#1077#1085#1086#1074#1072#1085#1080#1103
  ClientHeight = 519
  ClientWidth = 830
  Color = clBtnFace
  Constraints.MinHeight = 369
  Constraints.MinWidth = 775
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    830
    519)
  PixelsPerInch = 106
  TextHeight = 16
  object lShooter: TLabel
    Left = 177
    Top = 0
    Width = 102
    Height = 16
    Caption = #1051#1040#1055#1050#1048#1053', '#1070#1088#1080#1081
    Transparent = True
    Layout = tlCenter
  end
  object lYear: TLabel
    Left = 177
    Top = 30
    Width = 28
    Height = 16
    Caption = '1974'
    Transparent = True
    Layout = tlCenter
  end
  object lNameC: TLabel
    Left = 58
    Top = 0
    Width = 101
    Height = 16
    Alignment = taRightJustify
    Caption = #1060#1072#1084#1080#1083#1080#1103', '#1048#1084#1103
    Transparent = True
    Layout = tlCenter
  end
  object lYearC: TLabel
    Left = 61
    Top = 30
    Width = 98
    Height = 16
    Alignment = taRightJustify
    Caption = #1043#1086#1076' '#1088#1086#1078#1076#1077#1085#1080#1103
    Transparent = True
    Layout = tlCenter
  end
  object lCountry: TLabel
    Left = 177
    Top = 49
    Width = 179
    Height = 16
    Caption = #1052#1086#1089#1082#1086#1074#1089#1082#1072#1103' '#1086#1073#1083#1072#1089#1090#1100' ('#1052#1057#1054')'
    Transparent = True
  end
  object lCountryC: TLabel
    Left = 9
    Top = 49
    Width = 150
    Height = 16
    Alignment = taRightJustify
    Caption = #1057#1090#1088#1072#1085#1072', '#1086#1073#1083#1072#1089#1090#1100', '#1082#1088#1072#1081
    Transparent = True
    Layout = tlCenter
  end
  object lTown: TLabel
    Left = 177
    Top = 69
    Width = 57
    Height = 16
    Caption = #1043#1086#1088#1086#1076#1086#1082
    Transparent = True
    Layout = tlCenter
  end
  object lTownC: TLabel
    Left = 117
    Top = 69
    Width = 42
    Height = 16
    Alignment = taRightJustify
    Caption = #1043#1086#1088#1086#1076
    Transparent = True
    Layout = tlCenter
  end
  object lClub: TLabel
    Left = 177
    Top = 89
    Width = 74
    Height = 16
    Caption = #1050#1083#1091#1073#1077#1096#1085#1080#1082
    Transparent = True
    Layout = tlCenter
  end
  object lClubC: TLabel
    Left = 88
    Top = 89
    Width = 71
    Height = 16
    Alignment = taRightJustify
    Caption = #1050#1083#1091#1073' ('#1044#1057#1054')'
    Transparent = True
    Layout = tlCenter
  end
  object lDateC: TLabel
    Left = 337
    Top = 30
    Width = 107
    Height = 16
    Alignment = taRightJustify
    Caption = #1044#1072#1090#1072' '#1088#1086#1078#1076#1077#1085#1080#1103
    Transparent = True
    Layout = tlCenter
  end
  object lDate: TLabel
    Left = 463
    Top = 30
    Width = 31
    Height = 16
    Caption = '03.10'
    Transparent = True
    Layout = tlCenter
  end
  object lNumC: TLabel
    Left = 35
    Top = 108
    Width = 124
    Height = 16
    Alignment = taRightJustify
    Caption = #1057#1090#1072#1088#1090#1086#1074#1099#1081' '#1085#1086#1084#1077#1088
    Transparent = True
    Layout = tlCenter
  end
  object lNum: TLabel
    Left = 177
    Top = 108
    Width = 31
    Height = 16
    Cursor = crHandPoint
    Caption = 'lNum'
    OnClick = lNumClick
    OnMouseEnter = lNumMouseEnter
    OnMouseLeave = lNumMouseLeave
  end
  object pnlEvents: TPanel
    Left = 0
    Top = 217
    Width = 832
    Height = 261
    BevelOuter = bvNone
    Constraints.MinHeight = 148
    TabOrder = 0
    object lbEvents: TListBox
      Left = 0
      Top = 21
      Width = 832
      Height = 240
      Style = lbOwnerDrawFixed
      AutoComplete = False
      Align = alClient
      ExtendedSelect = False
      ItemHeight = 13
      TabOrder = 0
      OnDrawItem = lbEventsDrawItem
      OnKeyDown = lbEventsKeyDown
      OnMouseDown = lbEventsMouseDown
      OnMouseMove = lbEventsMouseMove
    end
    object HeaderControl1: THeaderControl
      Left = 0
      Top = 0
      Width = 832
      Height = 21
      FullDrag = False
      Enabled = False
      Sections = <
        item
          AllowClick = False
          ImageIndex = -1
          MaxWidth = 50
          MinWidth = 50
          Text = #1047#1072#1103#1074#1083#1077#1085
          Width = 50
        end
        item
          AllowClick = False
          ImageIndex = -1
          MaxWidth = 50
          MinWidth = 50
          Text = #1047#1072#1103#1074#1080#1090#1100
          Width = 50
        end
        item
          AllowClick = False
          ImageIndex = -1
          MinWidth = 32
          Text = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077
          Width = 250
        end
        item
          AllowClick = False
          ImageIndex = -1
          MaxWidth = 50
          MinWidth = 50
          Text = #1042'/'#1082
          Width = 50
        end
        item
          AllowClick = False
          ImageIndex = -1
          MaxWidth = 100
          MinWidth = 100
          Text = #1050#1086#1084#1072#1085#1076#1099
          Width = 100
        end
        item
          ImageIndex = -1
          Text = #1056#1077#1075#1080#1086#1085#1099
          Width = 50
        end
        item
          ImageIndex = -1
          Text = #1054#1082#1088#1091#1075#1072
          Width = 50
        end
        item
          AllowClick = False
          ImageIndex = -1
          MaxWidth = 100
          MinWidth = 100
          Text = #1054#1095#1082#1080
          Width = 100
        end>
      OnSectionResize = HeaderControl1SectionResize
      OnResize = HeaderControl1Resize
    end
  end
  object btnOk: TButton
    Left = 10
    Top = 489
    Width = 92
    Height = 30
    Anchors = [akLeft, akBottom]
    Caption = 'OK'
    TabOrder = 1
    TabStop = False
    OnClick = btnOkClick
  end
  object btnEdit: TButton
    Left = 724
    Top = 79
    Width = 103
    Height = 31
    Caption = #1048#1079#1084#1077#1085#1080#1090#1100'...'
    TabOrder = 2
    TabStop = False
    OnClick = btnEditClick
  end
  object cbPrintStartNumbers: TCheckBox
    Left = 503
    Top = 494
    Width = 327
    Height = 20
    TabStop = False
    Anchors = [akRight, akBottom]
    Caption = #1040#1074#1090#1086#1084#1072#1090#1080#1095#1077#1089#1082#1080' '#1087#1077#1095#1072#1090#1072#1090#1100' '#1089#1090#1072#1088#1090#1086#1074#1099#1077' '#1085#1086#1084#1077#1088#1072
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = cbPrintStartNumbersClick
  end
  object btnCancel: TButton
    Left = 118
    Top = 489
    Width = 92
    Height = 30
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 4
    TabStop = False
    OnClick = btnCancelClick
  end
  object btnPrint: TButton
    Left = 361
    Top = 489
    Width = 121
    Height = 30
    Anchors = [akRight, akBottom]
    Caption = #1055#1077#1095#1072#1090#1100' '#1085#1086#1084#1077#1088#1072
    TabOrder = 5
    TabStop = False
    OnClick = btnPrintClick
  end
end
