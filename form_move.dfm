object MoveShootersDialog: TMoveShootersDialog
  Left = 0
  Top = 0
  ActiveControl = lbGroups
  BorderIcons = []
  Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100
  ClientHeight = 269
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 13
  object lPrompt: TLabel
    Left = 86
    Top = 24
    Width = 36
    Height = 13
    Caption = 'lPrompt'
  end
  object lbGroups: TListBox
    Left = 195
    Top = 71
    Width = 118
    Height = 94
    ItemHeight = 13
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 172
    Top = 195
    Width = 73
    Height = 24
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 289
    Top = 195
    Width = 73
    Height = 24
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
end
