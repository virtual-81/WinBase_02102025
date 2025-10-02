object PreferedEventsEditor: TPreferedEventsEditor
  Left = 0
  Top = 0
  BorderWidth = 8
  Caption = 'PreferedEventsEditor'
  ClientHeight = 447
  ClientWidth = 519
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object lEvents: TLabel
    Left = 32
    Top = 24
    Width = 86
    Height = 13
    Caption = #1042#1089#1077' '#1091#1087#1088#1072#1078#1085#1077#1085#1080#1103':'
  end
  object lPrefered: TLabel
    Left = 352
    Top = 24
    Width = 92
    Height = 13
    Caption = #1055#1088#1077#1076#1087#1086#1095#1080#1090#1072#1077#1084#1099#1077':'
  end
  object btnAdd: TButton
    Left = 216
    Top = 112
    Width = 49
    Height = 25
    Caption = '>>'
    TabOrder = 0
    OnClick = btnAddClick
  end
  object btnRemove: TButton
    Left = 216
    Top = 152
    Width = 49
    Height = 25
    Caption = '<<'
    TabOrder = 1
    OnClick = btnRemoveClick
  end
  object lbEvents: TListBox
    Left = 24
    Top = 48
    Width = 161
    Height = 337
    ItemHeight = 13
    TabOrder = 2
    OnClick = lbEventsClick
  end
  object lbPrefered: TListBox
    Left = 336
    Top = 48
    Width = 153
    Height = 337
    ItemHeight = 13
    TabOrder = 3
    OnClick = lbPreferedClick
  end
end
