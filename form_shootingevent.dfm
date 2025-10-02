object ShootingEventDetails: TShootingEventDetails
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  BorderWidth = 16
  Caption = 'ShootingEventDetails'
  ClientHeight = 256
  ClientWidth = 396
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object lDate: TLabel
    Left = 16
    Top = 0
    Width = 25
    Height = 13
    Caption = 'lDate'
  end
  object lEvent: TLabel
    Left = 24
    Top = 41
    Width = 30
    Height = 13
    Caption = 'lEvent'
  end
  object lTown: TLabel
    Left = 20
    Top = 144
    Width = 28
    Height = 13
    Caption = 'lTown'
  end
  object lName: TLabel
    Left = 20
    Top = 115
    Width = 29
    Height = 13
    Caption = 'lName'
  end
  object lShortName: TLabel
    Left = -4
    Top = 91
    Width = 55
    Height = 13
    Caption = 'lShortName'
  end
  object edtDate: TEdit
    Left = 64
    Top = 0
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'edtDate'
  end
  object cbEvent: TComboBox
    Left = 60
    Top = 38
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
  object edtTown: TEdit
    Left = 64
    Top = 152
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'edtTown'
  end
  object btnOk: TButton
    Left = 152
    Top = 192
    Width = 75
    Height = 25
    Caption = 'btnOk'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 256
    Top = 192
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'btnCancel'
    ModalResult = 2
    TabOrder = 4
  end
  object edtName: TEdit
    Left = 60
    Top = 115
    Width = 121
    Height = 21
    TabOrder = 5
    Text = 'edtName'
  end
  object edtShortName: TEdit
    Left = 60
    Top = 88
    Width = 121
    Height = 21
    TabOrder = 6
    Text = 'edtShortName'
  end
  object cbOther: TCheckBox
    Left = 60
    Top = 65
    Width = 97
    Height = 17
    Caption = 'cbOther'
    TabOrder = 7
    OnClick = cbOtherClick
  end
end
