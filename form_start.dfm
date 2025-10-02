object StartForm: TStartForm
  Left = 433
  Top = 149
  BorderWidth = 8
  Caption = 'StartForm'
  ClientHeight = 597
  ClientWidth = 846
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object tcRelays: TTabControl
    Left = 0
    Top = 0
    Width = 846
    Height = 597
    Align = alClient
    TabOrder = 0
    Tabs.Strings = (
      #1057#1084#1077#1085#1072' 1'
      #1057#1084#1077#1085#1072' 2')
    TabIndex = 0
    TabStop = False
    OnChange = tcRelaysChange
    object lbShooters: TListBox
      Left = 4
      Top = 41
      Width = 838
      Height = 552
      Style = lbOwnerDrawFixed
      AutoComplete = False
      Align = alClient
      ItemHeight = 16
      TabOrder = 0
      OnClick = lbShootersClick
      OnDblClick = lbShootersDblClick
      OnDrawItem = lbShootersDrawItem
      OnKeyDown = lbShootersKeyDown
      OnKeyPress = lbShootersKeyPress
    end
    object HeaderControl1: THeaderControl
      Left = 4
      Top = 24
      Width = 838
      Height = 17
      Sections = <
        item
          ImageIndex = -1
          Text = #1060#1072#1084#1080#1083#1080#1103', '#1048#1084#1103
          Width = 250
        end
        item
          ImageIndex = -1
          Text = #1057#1090#1072#1088#1090#1086#1074#1099#1081' '#1085#1086#1084#1077#1088
          Width = 120
        end
        item
          ImageIndex = -1
          Text = #1065#1080#1090
          Width = 75
        end
        item
          ImageIndex = -1
          Text = #1056#1077#1079#1091#1083#1100#1090#1072#1090#1099
          Width = 50
        end>
      OnSectionResize = HeaderControl1SectionResize
      OnResize = HeaderControl1Resize
    end
  end
end
