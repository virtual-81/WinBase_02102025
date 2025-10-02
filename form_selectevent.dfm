object SelectEventDialog: TSelectEventDialog
  Left = 397
  Top = 206
  BorderWidth = 16
  Caption = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1103
  ClientHeight = 373
  ClientWidth = 668
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 106
  TextHeight = 16
  object lbEvents: TListBox
    Left = 0
    Top = 0
    Width = 671
    Height = 326
    Style = lbOwnerDrawFixed
    AutoComplete = False
    ItemHeight = 16
    TabOrder = 0
    OnDblClick = lbEventsDblClick
    OnDrawItem = lbEventsDrawItem
  end
  object btnCancel: TButton
    Left = 571
    Top = 345
    Width = 92
    Height = 30
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 463
    Top = 345
    Width = 92
    Height = 30
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
end
