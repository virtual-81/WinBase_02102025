object FinalDialog: TFinalDialog
  Left = 422
  Top = 181
  VertScrollBar.Visible = False
  BorderStyle = bsDialog
  Caption = 'FinalDialog'
  ClientHeight = 266
  ClientWidth = 431
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    431
    266)
  PixelsPerInch = 96
  TextHeight = 13
  object sgShooters: TStringGrid
    Left = 0
    Top = 0
    Width = 431
    Height = 97
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing]
    ParentFont = False
    ScrollBars = ssHorizontal
    TabOrder = 0
    OnKeyDown = sgShootersKeyDown
    OnKeyPress = sgShootersKeyPress
    OnSetEditText = sgShootersSetEditText
    RowHeights = (
      24
      24
      24
      24
      24)
  end
  object btnClose: TButton
    Left = 341
    Top = 224
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ModalResult = 1
    TabOrder = 1
  end
  object cbShortForm: TCheckBox
    Left = 56
    Top = 224
    Width = 225
    Height = 17
    Caption = #1058#1086#1083#1100#1082#1086' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1092#1080#1085#1072#1083#1100#1085#1099#1093' '#1089#1077#1088#1080#1081
    TabOrder = 2
    OnClick = cbShortFormClick
  end
  object sgSeries: TStringGrid
    Left = 88
    Top = 48
    Width = 320
    Height = 120
    FixedCols = 0
    FixedRows = 0
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing]
    ParentFont = False
    TabOrder = 3
    OnKeyDown = sgSeriesKeyDown
    OnKeyPress = sgSeriesKeyPress
  end
  object cbSmart: TCheckBox
    Left = 56
    Top = 241
    Width = 249
    Height = 17
    Caption = #1059#1089#1082#1086#1088#1077#1085#1085#1099#1081' '#1074#1074#1086#1076' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074' '#1074#1099#1089#1090#1088#1077#1083#1086#1074
    TabOrder = 4
  end
end
