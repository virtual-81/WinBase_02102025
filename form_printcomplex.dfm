object PrintComplexDialog: TPrintComplexDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'PrintComplexDialog'
  ClientHeight = 832
  ClientWidth = 662
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 17
  object lTitle: TLabel
    Left = 32
    Top = 177
    Width = 145
    Height = 17
    Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082' '#1087#1088#1086#1090#1086#1082#1086#1083#1072':'
  end
  object cblEvents: TCheckListBox
    Left = 35
    Top = 345
    Width = 598
    Height = 239
    ItemHeight = 17
    TabOrder = 4
  end
  object gbPointsFor: TGroupBox
    Left = 261
    Top = 33
    Width = 158
    Height = 137
    Caption = 'gbPointsFor'
    TabOrder = 1
    object rbTeams: TRadioButton
      Left = 21
      Top = 32
      Width = 107
      Height = 21
      Caption = 'rbTeams'
      TabOrder = 0
    end
    object rbRegions: TRadioButton
      Left = 21
      Top = 62
      Width = 107
      Height = 22
      Caption = 'rbRegions'
      TabOrder = 1
    end
    object rbDistricts: TRadioButton
      Left = 21
      Top = 91
      Width = 107
      Height = 23
      Caption = 'rbDistricts'
      TabOrder = 2
    end
  end
  object gbType: TGroupBox
    Left = 32
    Top = 33
    Width = 222
    Height = 137
    Caption = 'gbType'
    TabOrder = 0
    object rbGroups: TRadioButton
      Left = 21
      Top = 32
      Width = 97
      Height = 21
      Caption = 'rbGroups'
      TabOrder = 0
    end
    object rbEvents: TRadioButton
      Left = 21
      Top = 62
      Width = 97
      Height = 22
      Caption = 'rbEvents'
      TabOrder = 1
    end
  end
  object btnPrint: TButton
    Left = 40
    Top = 617
    Width = 98
    Height = 33
    Caption = 'btnPrint'
    Default = True
    TabOrder = 5
    OnClick = btnPrintClick
  end
  object btnSave: TButton
    Left = 147
    Top = 617
    Width = 97
    Height = 33
    Caption = 'btnSave'
    TabOrder = 6
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 523
    Top = 617
    Width = 99
    Height = 33
    Cancel = True
    Caption = 'btnCancel'
    ModalResult = 2
    TabOrder = 7
  end
  object gbAgeGroup: TGroupBox
    Left = 437
    Top = 33
    Width = 196
    Height = 133
    Caption = 'gbAgeGroup'
    TabOrder = 2
    object rbYouths: TRadioButton
      Left = 19
      Top = 33
      Width = 138
      Height = 20
      Caption = 'rbYouths'
      TabOrder = 0
    end
    object rbJuniors: TRadioButton
      Left = 19
      Top = 63
      Width = 138
      Height = 21
      Caption = 'rbJuniors'
      TabOrder = 1
    end
    object rbAdults: TRadioButton
      Left = 19
      Top = 91
      Width = 138
      Height = 21
      Caption = 'rbAdults'
      TabOrder = 2
    end
  end
  object memoTitle: TMemo
    Left = 39
    Top = 202
    Width = 583
    Height = 125
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object btnHTML: TButton
    Left = 256
    Top = 617
    Width = 89
    Height = 33
    Caption = 'btnHTML'
    TabOrder = 8
    OnClick = btnHTMLClick
  end
end
