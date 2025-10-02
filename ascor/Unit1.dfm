object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 488
  ClientWidth = 595
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object sgLanes: TStringGrid
    Left = 8
    Top = 64
    Width = 489
    Height = 120
    FixedCols = 0
    FixedRows = 0
    TabOrder = 0
    ColWidths = (
      64
      110
      101
      119
      64)
  end
  object btnConnect: TButton
    Left = 168
    Top = 16
    Width = 75
    Height = 25
    Caption = 'btnConnect'
    TabOrder = 1
    OnClick = btnConnectClick
  end
  object edtHost: TEdit
    Left = 16
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'edtHost'
  end
  object btnSave: TButton
    Left = 280
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 3
    OnClick = btnSaveClick
  end
  object cbFinal: TCheckBox
    Left = 392
    Top = 16
    Width = 97
    Height = 17
    Caption = #1057' '#1076#1077#1089#1103#1090#1099#1084#1080
    TabOrder = 4
    Visible = False
    OnClick = cbFinalClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 250
    OnTimer = Timer1Timer
    Left = 512
    Top = 24
  end
end
