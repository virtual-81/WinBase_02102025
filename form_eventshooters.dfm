object EventShootersForm: TEventShootersForm
  Left = 395
  Top = 193
  Caption = 'EventShootersForm'
  ClientHeight = 446
  ClientWidth = 789
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 789
    Height = 42
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnPrint: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #1055#1077#1095#1072#1090#1100
      TabOrder = 0
      OnClick = btnPrintClick
    end
    object btnPDF: TButton
      Left = 104
      Top = 11
      Width = 121
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074' PDF'
      TabOrder = 1
      OnClick = btnPDFClick
    end
  end
end
