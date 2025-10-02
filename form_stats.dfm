object ShooterStatsDialog: TShooterStatsDialog
  Left = 322
  Top = 110
  BorderWidth = 16
  Caption = 'ShooterStatsDialog'
  ClientHeight = 320
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TButton
    Left = 224
    Top = 216
    Width = 75
    Height = 25
    Cancel = True
    Caption = #1047#1072#1082#1088#1099#1090#1100
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object lbStats: TListBox
    Left = 0
    Top = 0
    Width = 297
    Height = 209
    Style = lbVirtualOwnerDraw
    AutoComplete = False
    ItemHeight = 16
    TabOrder = 1
    OnDrawItem = lbStatsDrawItem
  end
  object HeaderControl1: THeaderControl
    Left = 0
    Top = 0
    Width = 564
    Height = 17
    FullDrag = False
    Sections = <
      item
        ImageIndex = -1
        Text = #1059#1087#1088#1072#1078#1085#1077#1085#1080#1077
        Width = 150
      end
      item
        AutoSize = True
        ImageIndex = -1
        Text = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1086#1074
        Width = 207
      end
      item
        AutoSize = True
        ImageIndex = -1
        Text = #1056#1077#1081#1090#1080#1085#1075
        Width = 207
      end>
    OnSectionResize = HeaderControl1SectionResize
  end
  object btnCopy: TButton
    Left = 0
    Top = 215
    Width = 75
    Height = 25
    Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
    TabOrder = 3
    OnClick = btnCopyClick
  end
end
