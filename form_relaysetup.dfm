object RelaysSetupDialog: TRelaysSetupDialog
  Left = 227
  Top = 269
  BorderStyle = bsDialog
  BorderWidth = 16
  Caption = 'RelaysSetupDialog'
  ClientHeight = 482
  ClientWidth = 491
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object sbAdd: TSpeedButton
    Left = 8
    Top = 192
    Width = 23
    Height = 22
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000130B0000130B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0033333333B333
      333B33FF33337F3333F73BB3777BB7777BB3377FFFF77FFFF77333B000000000
      0B3333777777777777333330FFFFFFFF07333337F33333337F333330FFFFFFFF
      07333337F33333337F333330FFFFFFFF07333337F33333337F333330FFFFFFFF
      07333FF7F33333337FFFBBB0FFFFFFFF0BB37777F3333333777F3BB0FFFFFFFF
      0BBB3777F3333FFF77773330FFFF000003333337F333777773333330FFFF0FF0
      33333337F3337F37F3333330FFFF0F0B33333337F3337F77FF333330FFFF003B
      B3333337FFFF77377FF333B000000333BB33337777777F3377FF3BB3333BB333
      3BB33773333773333773B333333B3333333B7333333733333337}
    NumGlyphs = 2
    OnClick = btnAddClick
  end
  object sbDelete: TSpeedButton
    Left = 40
    Top = 192
    Width = 23
    Height = 22
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      04000000000000010000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333000000000
      3333333777777777F3333330F777777033333337F3F3F3F7F3333330F0808070
      33333337F7F7F7F7F3333330F080707033333337F7F7F7F7F3333330F0808070
      33333337F7F7F7F7F3333330F080707033333337F7F7F7F7F3333330F0808070
      333333F7F7F7F7F7F3F33030F080707030333737F7F7F7F7F7333300F0808070
      03333377F7F7F7F773333330F080707033333337F7F7F7F7F333333070707070
      33333337F7F7F7F7FF3333000000000003333377777777777F33330F88877777
      0333337FFFFFFFFF7F3333000000000003333377777777777333333330777033
      3333333337FFF7F3333333333000003333333333377777333333}
    NumGlyphs = 2
    OnClick = btnDeleteClick
  end
  object lbRelays: TListBox
    Left = 0
    Top = 0
    Width = 193
    Height = 185
    Ctl3D = True
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 0
    OnClick = lbRelaysClick
    OnDblClick = lbRelaysDblClick
    OnKeyDown = lbRelaysKeyDown
  end
  object gbStartTime1: TGroupBox
    Left = 224
    Top = 64
    Width = 265
    Height = 81
    Caption = '1 '#1086#1095#1077#1088#1077#1076#1100
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 2
    object lDate1: TLabel
      Left = 8
      Top = 16
      Width = 29
      Height = 13
      Caption = #1044#1072#1090#1072':'
    end
    object lTime1: TLabel
      Left = 32
      Top = 48
      Width = 49
      Height = 13
      Caption = #1053#1072#1095#1072#1083#1086' '#1074':'
    end
    object dtDate: TDateTimePicker
      Left = 88
      Top = 16
      Width = 113
      Height = 21
      Date = 38724.023923240700000000
      Time = 38724.023923240700000000
      TabOrder = 0
      OnKeyPress = dtDateKeyPress
    end
    object dtTime: TDateTimePicker
      Left = 88
      Top = 48
      Width = 113
      Height = 21
      Date = 38724.024888599500000000
      Format = 'H:mm'
      Time = 38724.024888599500000000
      Kind = dtkTime
      TabOrder = 1
      OnKeyPress = dtTimeKeyPress
    end
  end
  object btnClose: TButton
    Left = 414
    Top = 368
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    TabOrder = 5
    TabStop = False
    OnClick = btnCloseClick
  end
  object gbFinal: TGroupBox
    Left = 224
    Top = 288
    Width = 265
    Height = 81
    Caption = ' '#1060#1080#1085#1072#1083' '
    TabOrder = 4
    object lFinalDate: TLabel
      Left = 16
      Top = 18
      Width = 26
      Height = 13
      Caption = #1044#1072#1090#1072
    end
    object lFinalTime: TLabel
      Left = 16
      Top = 50
      Width = 33
      Height = 13
      Caption = #1042#1088#1077#1084#1103
    end
    object dtFinalDate: TDateTimePicker
      Left = 88
      Top = 16
      Width = 114
      Height = 21
      Date = 38738.912116238410000000
      Time = 38738.912116238410000000
      TabOrder = 0
      OnKeyPress = dtFinalDateKeyPress
    end
    object dtFinalTime: TDateTimePicker
      Left = 88
      Top = 48
      Width = 114
      Height = 21
      Date = 38738.912438865700000000
      Format = 'H:mm'
      Time = 38738.912438865700000000
      Kind = dtkTime
      TabOrder = 1
      OnKeyPress = dtFinalTimeKeyPress
    end
  end
  object gbPos: TGroupBox
    Left = 224
    Top = 8
    Width = 265
    Height = 49
    Caption = #1065#1080#1090#1099
    TabOrder = 1
    object edtPos: TEdit
      Left = 16
      Top = 16
      Width = 233
      Height = 21
      TabOrder = 0
      OnKeyPress = edtPosKeyPress
    end
  end
  object gbStartTime2: TGroupBox
    Left = 224
    Top = 152
    Width = 265
    Height = 81
    Caption = '2 '#1086#1095#1077#1088#1077#1076#1100
    TabOrder = 3
    object lDate2: TLabel
      Left = 52
      Top = 16
      Width = 29
      Height = 13
      Caption = #1044#1072#1090#1072':'
    end
    object lTime2: TLabel
      Left = 8
      Top = 48
      Width = 49
      Height = 13
      Caption = #1053#1072#1095#1072#1083#1086' '#1074':'
    end
    object dtDate2: TDateTimePicker
      Left = 88
      Top = 16
      Width = 113
      Height = 21
      Date = 38724.023923240700000000
      Time = 38724.023923240700000000
      TabOrder = 0
      OnKeyPress = dtDate2KeyPress
    end
    object dtTime2: TDateTimePicker
      Left = 88
      Top = 48
      Width = 113
      Height = 21
      Date = 38724.024888599500000000
      Format = 'H:mm'
      Time = 38724.024888599500000000
      Kind = dtkTime
      TabOrder = 1
      OnKeyPress = dtTime2KeyPress
    end
  end
  object cbFinal: TCheckBox
    Left = 224
    Top = 239
    Width = 97
    Height = 17
    Caption = #1060#1080#1085#1072#1083
    TabOrder = 6
    OnClick = cbFinalClick
  end
  object cbNewFinalFormat: TCheckBox
    Left = 224
    Top = 262
    Width = 200
    Height = 17
    Caption = #1053#1086#1074#1099#1081' '#1092#1086#1088#1084#1072#1090' ('#1042#1055'-60/'#1055#1055'-60)'
    TabOrder = 7
    OnClick = cbNewFinalFormatClick
  end
end
