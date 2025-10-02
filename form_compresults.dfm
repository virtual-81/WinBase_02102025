object CompetitionResultsForm: TCompetitionResultsForm
  Left = 330
  Top = 174
  Margins.Left = 2
  Margins.Top = 2
  Margins.Right = 2
  Margins.Bottom = 2
  Caption = 'CompetitionResultsForm'
  ClientHeight = 603
  ClientWidth = 849
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  TextHeight = 13
  object pnlListBox: TPanel
    Left = 0
    Top = 33
    Width = 849
    Height = 570
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 847
    ExplicitHeight = 562
    object HeaderControl1: THeaderControl
      Left = 0
      Top = 0
      Width = 849
      Height = 17
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Sections = <
        item
          ImageIndex = -1
          MaxWidth = 60
          MinWidth = 20
          Text = #1052#1077#1089#1090#1086
          Width = 40
        end
        item
          ImageIndex = -1
          MaxWidth = 100
          MinWidth = 20
          Text = #1057#1090#1072#1088#1090#1086#1074#1099#1081' '#1085#1086#1084#1077#1088
          Width = 40
        end
        item
          ImageIndex = -1
          MaxWidth = 60
          MinWidth = 20
          Text = #1065#1080#1090
          Width = 40
        end
        item
          ImageIndex = -1
          MaxWidth = 400
          MinWidth = 20
          Text = #1060#1072#1084#1080#1083#1080#1103', '#1048#1084#1103
          Width = 140
        end
        item
          ImageIndex = -1
          MaxWidth = 120
          MinWidth = 20
          Text = #1056#1077#1075#1080#1086#1085
          Width = 60
        end
        item
          ImageIndex = -1
          MaxWidth = 400
          MinWidth = 40
          Text = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
          Width = 200
        end
        item
          ImageIndex = -1
          MaxWidth = 160
          MinWidth = 20
          Width = 80
        end
        item
          ImageIndex = -1
          MaxWidth = 160
          MinWidth = 20
          Text = #1041#1072#1083#1083#1099
          Width = 60
        end>
      OnSectionResize = HeaderControl1SectionResize
      OnResize = HeaderControl1Resize
      ExplicitWidth = 847
    end
    object lbShooters: TListBox
      Left = 0
      Top = 17
      Width = 849
      Height = 553
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Style = lbOwnerDrawVariable
      AutoComplete = False
      Align = alClient
      ItemHeight = 13
      TabOrder = 1
      OnClick = lbShootersClick
      OnDblClick = lbShootersDblClick
      OnDrawItem = lbShootersDrawItem
      OnMeasureItem = lbShootersMeasureItem
      ExplicitWidth = 847
      ExplicitHeight = 545
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 0
    Width = 849
    Height = 33
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alTop
    FullRepaint = False
    TabOrder = 1
    ExplicitWidth = 847
    object btnResetResults: TButton
      Left = 20
      Top = 7
      Width = 109
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'btnResetResults'
      TabOrder = 0
      OnClick = btnResetResultsClick
    end
    object btnResetFinal: TButton
      Left = 141
      Top = 7
      Width = 103
      Height = 19
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'btnResetFinal'
      TabOrder = 1
      OnClick = btnResetFinalClick
    end
  end
end
