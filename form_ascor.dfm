object SiusForm: TSiusForm
  Left = 0
  Top = 0
  Caption = 'SiusForm'
  ClientHeight = 470
  ClientWidth = 639
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object lHost: TLabel
    Left = 24
    Top = 16
    Width = 24
    Height = 13
    Caption = 'lHost'
  end
  object btnConnect: TButton
    Left = 216
    Top = 8
    Width = 105
    Height = 25
    Caption = 'btnConnect'
    TabOrder = 1
    OnClick = btnConnectClick
  end
  object sgShooters: TStringGrid
    Left = 24
    Top = 79
    Width = 569
    Height = 354
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    TabOrder = 4
  end
  object btnSave: TButton
    Left = 518
    Top = 8
    Width = 75
    Height = 25
    Caption = 'btnSave'
    TabOrder = 3
    OnClick = btnSaveClick
  end
  object cbHost: TComboBox
    Left = 65
    Top = 16
    Width = 145
    Height = 21
    ItemHeight = 0
    TabOrder = 0
    Text = 'cbHost'
    OnKeyPress = cbHostKeyPress
  end
  object btnLoad: TButton
    Left = 334
    Top = 7
    Width = 70
    Height = 24
    Caption = 'btnLoad'
    TabOrder = 2
    OnClick = btnLoadClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 250
    OnTimer = Timer1Timer
    Left = 424
    Top = 32
  end
end
