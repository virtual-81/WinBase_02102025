object QualificationPointsDialog: TQualificationPointsDialog
  Left = 287
  Top = 110
  BorderWidth = 16
  Caption = #1041#1072#1083#1083#1099' '#1079#1072' '#1074#1099#1087#1086#1083#1085#1077#1085#1080#1077' '#1082#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1080
  ClientHeight = 229
  ClientWidth = 329
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object sgPoints: TStringGrid
    Left = 0
    Top = 0
    Width = 337
    Height = 233
    ColCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing]
    ScrollBars = ssVertical
    TabOrder = 0
    OnKeyPress = sgPointsKeyPress
    OnSetEditText = sgPointsSetEditText
  end
  object btnClose: TButton
    Left = 256
    Top = 248
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ModalResult = 1
    TabOrder = 1
  end
end
