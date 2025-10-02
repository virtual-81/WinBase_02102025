object StartListManager: TStartListManager
  Left = 191
  Top = 214
  ActiveControl = lbStarts
  Caption = #1052#1077#1085#1077#1076#1078#1077#1088' '#1089#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1081
  ClientHeight = 779
  ClientWidth = 1127
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 17
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1127
    Height = 54
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object btnAdd: TButton
      Left = 126
      Top = 10
      Width = 137
      Height = 33
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1085#1086#1074#1086#1077
      TabOrder = 0
      TabStop = False
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 282
      Top = 10
      Width = 99
      Height = 33
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 1
      TabStop = False
      OnClick = btnDeleteClick
    end
    object btnOpen: TButton
      Left = 10
      Top = 10
      Width = 99
      Height = 33
      Caption = #1054#1090#1082#1088#1099#1090#1100
      TabOrder = 2
      TabStop = False
      OnClick = btnOpenClick
    end
    object btnEdit: TButton
      Left = 398
      Top = 10
      Width = 105
      Height = 33
      Caption = #1048#1079#1084#1077#1085#1080#1090#1100
      TabOrder = 3
      TabStop = False
      OnClick = btnEditClick
    end
  end
  object lbStarts: TListBox
    Left = 0
    Top = 54
    Width = 1127
    Height = 725
    Style = lbVirtualOwnerDraw
    Align = alClient
    ItemHeight = 16
    TabOrder = 0
    OnDblClick = lbStartsDblClick
    OnDrawItem = lbStartsDrawItem
  end
end
