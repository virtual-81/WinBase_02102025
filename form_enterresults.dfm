object EnterResultsForm: TEnterResultsForm
  Left = 144
  Top = 180
  Caption = #1042#1074#1086#1076' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074
  ClientHeight = 542
  ClientWidth = 801
  Color = clBtnFace
  Constraints.MinHeight = 320
  Constraints.MinWidth = 400
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 65
    Width = 801
    Height = 477
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object HeaderControl1: THeaderControl
      Left = 0
      Top = 0
      Width = 801
      Height = 17
      Sections = <
        item
          ImageIndex = -1
          Text = #1060#1072#1084#1080#1083#1080#1103', '#1048#1084#1103
          Width = 250
        end
        item
          ImageIndex = -1
          Text = #1044#1072#1090#1072
          Width = 75
        end
        item
          ImageIndex = -1
          Text = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077
          Width = 150
        end
        item
          ImageIndex = -1
          Text = #1070#1085#1080#1086#1088#1099
          Width = 50
        end
        item
          ImageIndex = -1
          Text = #1052#1077#1089#1090#1086
          Width = 50
        end
        item
          ImageIndex = -1
          Text = #1050#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1103
          Width = 50
        end
        item
          ImageIndex = -1
          Text = #1060#1080#1085#1072#1083
          Width = 50
        end>
      OnSectionResize = HeaderControl1SectionResize
      OnResize = HeaderControl1Resize
    end
    object ListBox1: TListBox
      Left = 0
      Top = 17
      Width = 801
      Height = 460
      Style = lbVirtualOwnerDraw
      Align = alClient
      BorderStyle = bsNone
      ItemHeight = 16
      TabOrder = 1
      OnDblClick = ListBox1DblClick
      OnDrawItem = ListBox1DrawItem
      OnKeyDown = ListBox1KeyDown
      OnKeyPress = ListBox1KeyPress
    end
  end
  object pnlInfo: TPanel
    Left = 0
    Top = 0
    Width = 801
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lChamp: TLabel
      Left = 8
      Top = 12
      Width = 77
      Height = 13
      Caption = #1057#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1077':'
    end
    object lYear: TLabel
      Left = 74
      Top = 36
      Width = 23
      Height = 13
      Caption = #1043#1086#1076':'
    end
    object lCountry: TLabel
      Left = 576
      Top = 12
      Width = 41
      Height = 13
      Caption = #1057#1090#1088#1072#1085#1072':'
    end
    object lTown: TLabel
      Left = 576
      Top = 36
      Width = 35
      Height = 13
      Caption = #1043#1086#1088#1086#1076':'
    end
    object cbChamp: TComboBox
      Left = 104
      Top = 8
      Width = 137
      Height = 21
      DropDownCount = 16
      ItemHeight = 0
      TabOrder = 0
      Text = 'cbChamp'
    end
    object edtYear: TEdit
      Left = 104
      Top = 32
      Width = 57
      Height = 21
      TabOrder = 1
      Text = 'edtYear'
    end
    object edtCountry: TEdit
      Left = 672
      Top = 8
      Width = 121
      Height = 21
      TabOrder = 2
      Text = 'edtCountry'
    end
    object edtTown: TEdit
      Left = 672
      Top = 32
      Width = 121
      Height = 21
      TabOrder = 3
      Text = 'edtTown'
    end
  end
end
