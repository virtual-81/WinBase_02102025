object PrintShootersCardsDialog: TPrintShootersCardsDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'PrintShootersCardsDialog'
  ClientHeight = 430
  ClientWidth = 727
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object clbShooters: TCheckListBox
    Left = 52
    Top = 149
    Width = 610
    Height = 171
    ItemHeight = 14
    TabOrder = 1
    OnClick = clbShootersClick
    OnKeyPress = clbShootersKeyPress
  end
  object btnOk: TButton
    Left = 453
    Top = 342
    Width = 70
    Height = 23
    Caption = 'btnOk'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 550
    Top = 342
    Width = 69
    Height = 23
    Cancel = True
    Caption = 'btnCancel'
    ModalResult = 2
    TabOrder = 5
  end
  object cbAnonymous: TCheckBox
    Left = 67
    Top = 98
    Width = 90
    Height = 15
    Caption = 'cbAnonymous'
    TabOrder = 0
  end
  object btnSelectAll: TButton
    Left = 52
    Top = 342
    Width = 98
    Height = 23
    Caption = 'btnSelectAll'
    TabOrder = 2
    OnClick = btnSelectAllClick
  end
  object btnDeselectAll: TButton
    Left = 156
    Top = 342
    Width = 112
    Height = 23
    Caption = 'btnDeselectAll'
    TabOrder = 3
    OnClick = btnDeselectAllClick
  end
  object cbEventTitle: TCheckBox
    Left = 67
    Top = 119
    Width = 90
    Height = 16
    Caption = 'cbEventTitle'
    TabOrder = 6
  end
end
