object ShooterSeriesDialog: TShooterSeriesDialog
  Left = 435
  Top = 70
  Margins.Left = 2
  Margins.Top = 2
  Margins.Right = 2
  Margins.Bottom = 2
  BorderStyle = bsDialog
  BorderWidth = 16
  Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
  ClientHeight = 767
  ClientWidth = 682
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  TextHeight = 13
  object lShooter: TLabel
    Left = 0
    Top = 0
    Width = 39
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'lShooter'
  end
  object lEventShort: TLabel
    Left = 0
    Top = 24
    Width = 55
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'lEventShort'
  end
  object lEvent: TLabel
    Left = 0
    Top = 39
    Width = 30
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'lEvent'
  end
  object lRelayStr: TLabel
    Left = 0
    Top = 55
    Width = 33
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1057#1084#1077#1085#1072
  end
  object lRelay: TLabel
    Left = 39
    Top = 55
    Width = 29
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'lRelay'
  end
  object lPosStr: TLabel
    Left = 86
    Top = 55
    Width = 21
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1065#1080#1090
  end
  object lPos: TLabel
    Left = 118
    Top = 55
    Width = 20
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = 'lPos'
  end
  object lNum: TLabel
    Left = 397
    Top = 0
    Width = 18
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Alignment = taRightJustify
    Caption = '007'
  end
  object lRecordComment: TLabel
    Left = 0
    Top = 445
    Width = 130
    Height = 13
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1081' '#1086' '#1088#1077#1082#1086#1088#1076#1077': '
  end
  object edtRecordComment: TEdit
    Left = 134
    Top = 442
    Width = 237
    Height = 21
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    TabOrder = 0
    Text = 'edtRecordComment'
    OnChange = edtRecordCommentChange
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 88
    Width = 584
    Height = 342
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    ActivePage = tsMain
    TabOrder = 1
    object tsMain: TTabSheet
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1054#1089#1085#1086#1074#1085#1072#1103' '#1089#1077#1088#1080#1103
      object lTotal: TLabel
        Left = 477
        Top = 243
        Width = 25
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        AutoSize = False
        Caption = 'lTotal'
        Color = clBtnFace
        ParentColor = False
      end
      object lCompShootOff: TLabel
        Left = 12
        Top = 257
        Width = 70
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1077#1088#1077#1089#1090#1088#1077#1083#1082#1072':'
      end
      object lCompPriority: TLabel
        Left = 289
        Top = 255
        Width = 57
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1088#1080#1086#1088#1080#1090#1077#1090':'
      end
      object lDNSComment: TLabel
        Left = 89
        Top = 30
        Width = 46
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1088#1080#1095#1080#1085#1072':'
      end
      object lInnerTens: TLabel
        Left = 20
        Top = 238
        Width = 124
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1050#1086#1085#1090#1088#1086#1083#1100#1085#1099#1093' "'#1076#1077#1089#1103#1090#1086#1082'":'
      end
      object cbDNS: TComboBox
        Left = 12
        Top = 3
        Width = 186
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Style = csDropDownList
        ItemIndex = 1
        TabOrder = 0
        Text = #1053#1077#1103#1074#1082#1072'/'#1044#1080#1089#1082#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1103
        OnChange = cbDNSChange
        Items.Strings = (
          #1053#1086#1088#1084#1072#1083#1100#1085#1086
          #1053#1077#1103#1074#1082#1072'/'#1044#1080#1089#1082#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1103
          #1053#1077' '#1079#1072#1082#1086#1085#1095#1080#1083'('#1072')')
      end
      object edtCompShootOff: TEdit
        Left = 86
        Top = 254
        Width = 120
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 1
        Text = 'edtCompShootOff'
      end
      object udCompPriority: TUpDown
        Left = 398
        Top = 250
        Width = 17
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Associate = edtCompPriority
        Max = 1024
        TabOrder = 2
      end
      object edtCompPriority: TEdit
        Left = 350
        Top = 250
        Width = 48
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 3
        Text = '0'
      end
      object memDNSComment: TMemo
        Left = 161
        Top = 18
        Width = 367
        Height = 103
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Lines.Strings = (
          'memDNSComment')
        ScrollBars = ssBoth
        TabOrder = 4
      end
      object edtInnerTens: TEdit
        Left = 161
        Top = 230
        Width = 64
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 5
        Text = '0'
      end
      object udInnerTens: TUpDown
        Left = 225
        Top = 230
        Width = 14
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Associate = edtInnerTens
        Max = 10000
        TabOrder = 6
      end
    end
    object tsFinal: TTabSheet
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1060#1080#1085#1072#1083
      ImageIndex = 1
      object lFinalShootOff: TLabel
        Left = 16
        Top = 125
        Width = 70
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1077#1088#1077#1089#1090#1088#1077#1083#1082#1072':'
      end
      object lFinalPriority: TLabel
        Left = 311
        Top = 125
        Width = 57
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1055#1088#1080#1086#1088#1080#1090#1077#1090':'
      end
      object udFinalPriority: TUpDown
        Left = 434
        Top = 122
        Width = 16
        Height = 20
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Associate = edtFinalPriority
        TabOrder = 6
      end
      object edtFinalResult: TEdit
        Left = 165
        Top = 80
        Width = 111
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 3
        Text = 'edtFinalResult'
      end
      object edtFinalPriority: TEdit
        Left = 386
        Top = 122
        Width = 48
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 5
        Text = '0'
      end
      object edtFinalShootOff: TEdit
        Left = 165
        Top = 122
        Width = 118
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 4
        Text = 'edtFinalShootOff'
      end
      object sgFinal: TStringGrid
        Left = 165
        Top = 18
        Width = 253
        Height = 41
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        DefaultColWidth = 51
        DefaultRowHeight = 19
        FixedCols = 0
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -14
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing]
        ParentFont = False
        ScrollBars = ssNone
        TabOrder = 1
        OnClick = sgFinalClick
        OnGetEditText = sgFinalGetEditText
        OnKeyDown = sgFinalKeyDown
        OnKeyPress = sgFinalKeyPress
        OnSetEditText = sgFinalSetEditText
      end
      object rbFinalShots: TRadioButton
        Left = 16
        Top = 18
        Width = 111
        Height = 17
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1060#1080#1085#1072#1083#1100#1085#1099#1077' '#1074#1099#1089#1090#1088#1077#1083#1099':'
        TabOrder = 0
        OnClick = rbFinalShotsClick
      end
      object rbFinalResult: TRadioButton
        Left = 16
        Top = 82
        Width = 111
        Height = 16
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1056#1077#1079#1091#1083#1100#1090#1072#1090' '#1092#1080#1085#1072#1083#1072':'
        TabOrder = 2
        OnClick = rbFinalResultClick
      end
    end
    object tsPoints: TTabSheet
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = #1041#1072#1083#1083#1099', '#1082#1086#1084#1072#1085#1076#1099
      ImageIndex = 2
      object lManualPoints: TLabel
        Left = 16
        Top = 39
        Width = 187
        Height = 13
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1099#1077' '#1073#1072#1083#1083#1099' '#1079#1072' '#1082#1086#1084#1072#1085#1076#1091':'
      end
      object cbTeamPoints: TCheckBox
        Left = 16
        Top = 17
        Width = 142
        Height = 17
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1082#1086#1084#1072#1085#1076#1091
        TabOrder = 0
      end
      object cbTeamForPoints: TComboBox
        Left = 146
        Top = 13
        Width = 229
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 1
        Text = 'cbTeamForPoints'
      end
      object edtManualPoints: TEdit
        Left = 256
        Top = 39
        Width = 119
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 2
      end
      object cbForTeam: TCheckBox
        Left = 16
        Top = 63
        Width = 142
        Height = 17
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1050#1086#1084#1072#1085#1076#1085#1086#1077' '#1087#1077#1088#1074#1077#1085#1089#1090#1074#1086
        TabOrder = 3
      end
      object cbTeamForResults: TComboBox
        Left = 174
        Top = 63
        Width = 228
        Height = 21
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        TabOrder = 4
        Text = 'cbTeamForResults'
      end
      object cbDistrictPoints: TCheckBox
        Left = 16
        Top = 78
        Width = 142
        Height = 17
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1086#1082#1088#1091#1075
        TabOrder = 5
      end
      object cbOutOfRank: TCheckBox
        Left = 174
        Top = 94
        Width = 142
        Height = 17
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1042#1085#1077' '#1082#1086#1085#1082#1091#1088#1089#1072
        TabOrder = 6
      end
      object cbRegionPoints: TCheckBox
        Left = 16
        Top = 94
        Width = 142
        Height = 17
        Margins.Left = 2
        Margins.Top = 2
        Margins.Right = 2
        Margins.Bottom = 2
        Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1088#1077#1075#1080#1086#1085
        TabOrder = 7
      end
    end
  end
end
