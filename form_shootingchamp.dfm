object ShootingChampionshipDetails: TShootingChampionshipDetails
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  BorderWidth = 16
  Caption = 'ShootingChampionshipDetails'
  ClientHeight = 259
  ClientWidth = 362
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
  object lChamp: TLabel
    Left = 24
    Top = 32
    Width = 35
    Height = 13
    Caption = 'lChamp'
  end
  object lName: TLabel
    Left = 24
    Top = 104
    Width = 29
    Height = 13
    Caption = 'lName'
  end
  object lCountry: TLabel
    Left = 24
    Top = 136
    Width = 41
    Height = 13
    Caption = 'lCountry'
  end
  object lTown: TLabel
    Left = 24
    Top = 176
    Width = 28
    Height = 13
    Caption = 'lTown'
  end
  object cbChamp: TComboBox
    Left = 80
    Top = 32
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 0
    TabOrder = 0
  end
  object cbOther: TCheckBox
    Left = 40
    Top = 64
    Width = 97
    Height = 17
    Caption = 'cbOther'
    TabOrder = 1
    OnClick = cbOtherClick
  end
  object edtName: TEdit
    Left = 80
    Top = 96
    Width = 121
    Height = 21
    TabOrder = 2
    Text = 'edtName'
  end
  object edtCountry: TEdit
    Left = 80
    Top = 136
    Width = 121
    Height = 21
    TabOrder = 3
    Text = 'edtCountry'
  end
  object edtTown: TEdit
    Left = 88
    Top = 176
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'edtTown'
  end
  object btnOk: TButton
    Left = 96
    Top = 224
    Width = 75
    Height = 25
    Caption = 'btnOk'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object btnCancel: TButton
    Left = 200
    Top = 224
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'btnCancel'
    ModalResult = 2
    TabOrder = 6
  end
end
