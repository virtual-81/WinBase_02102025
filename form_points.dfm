object PointsSetupDialog: TPointsSetupDialog
  Left = 322
  Top = 110
  ActiveControl = sgPoints
  BorderIcons = []
  BorderWidth = 16
  Caption = 'PointsSetupDialog'
  ClientHeight = 540
  ClientWidth = 838
  Color = clBtnFace
  Constraints.MinHeight = 369
  Constraints.MinWidth = 583
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 106
  TextHeight = 16
  object btnClose: TButton
    Left = 619
    Top = 485
    Width = 92
    Height = 31
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ModalResult = 1
    TabOrder = 0
  end
  object btnLoad: TButton
    Left = 383
    Top = 485
    Width = 92
    Height = 31
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 1
    OnClick = btnLoadClick
  end
  object btnSave: TButton
    Left = 481
    Top = 485
    Width = 93
    Height = 31
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 2
    OnClick = btnSaveClick
  end
  object btnAdd: TButton
    Left = 176
    Top = 485
    Width = 92
    Height = 31
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 3
    OnClick = btnAddClick
  end
  object btnDelete: TButton
    Left = 274
    Top = 485
    Width = 93
    Height = 31
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 4
    OnClick = btnDeleteClick
  end
  object TabControl1: TTabControl
    Left = 72
    Top = 16
    Width = 689
    Height = 257
    TabOrder = 5
    Tabs.Strings = (
      #1056#1077#1075#1080#1086#1085#1099
      #1054#1082#1088#1091#1075#1072
      #1050#1086#1084#1072#1085#1076#1099
      #1050#1086#1084#1072#1085#1076#1099' '#1074' '#1091#1087#1088#1072#1078#1085#1077#1085#1080#1080)
    TabIndex = 0
    OnChange = TabControl1Change
    object sgPoints: TStringGrid
      Left = 4
      Top = 27
      Width = 681
      Height = 226
      Align = alClient
      Ctl3D = True
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing]
      ParentCtl3D = False
      TabOrder = 0
      OnKeyDown = sgPointsKeyDown
      OnKeyPress = sgPointsKeyPress
      OnSetEditText = sgPointsSetEditText
    end
  end
  object SavePointsDialog: TSaveDialog
    DefaultExt = '*.points'
    Filter = 'WinBASE event points (*.points)|*.points'
    FilterIndex = 0
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1073#1072#1083#1083#1099' '#1074' '#1092#1072#1081#1083
    Left = 216
    Top = 321
  end
  object LoadPointsDialog: TOpenDialog
    DefaultExt = '*.points'
    Filter = 'WinBASE event points (*.points)|*.points'
    FilterIndex = 0
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Title = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1073#1072#1083#1083#1099
    Left = 248
    Top = 321
  end
end
