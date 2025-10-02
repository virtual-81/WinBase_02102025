object StartListStatsDialog: TStartListStatsDialog
  Left = 0
  Top = 0
  Caption = 'StartListStatsDialog'
  ClientHeight = 353
  ClientWidth = 725
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 120
  TextHeight = 17
  object btnCopy: TButton
    Left = 21
    Top = 304
    Width = 98
    Height = 32
    Caption = 'btnCopy'
    TabOrder = 0
    OnClick = btnCopyClick
  end
  object btnOk: TButton
    Left = 605
    Top = 304
    Width = 97
    Height = 32
    Caption = 'btnOk'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 21
    Top = 11
    Width = 681
    Height = 273
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 2
  end
end
