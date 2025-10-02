object SettingsForm: TSettingsForm
  Left = 324
  Top = 186
  BorderWidth = 8
  Caption = 'SettingsForm'
  ClientHeight = 562
  ClientWidth = 788
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pcSettings: TPageControl
    Left = 0
    Top = 0
    Width = 788
    Height = 562
    ActivePage = tsEvents
    Align = alClient
    TabOrder = 0
    TabStop = False
    OnChange = pcSettingsChange
    object tsGeneral: TTabSheet
      Caption = '  '#1054#1073#1097#1080#1077'  '
      ImageIndex = 3
      OnResize = tsGeneralResize
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lName: TLabel
        Left = 16
        Top = 27
        Width = 30
        Height = 13
        Caption = 'lName'
      end
      object edtName: TEdit
        Left = 64
        Top = 24
        Width = 121
        Height = 24
        TabOrder = 0
        Text = 'edtName'
      end
    end
    object tsEvents: TTabSheet
      Caption = '  '#1059#1087#1088#1072#1078#1085#1077#1085#1080#1103'  '
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object hcEvents: THeaderControl
        Left = 0
        Top = 41
        Width = 782
        Height = 17
        Sections = <
          item
            ImageIndex = -1
            Text = #1053#1072#1079#1074#1072#1085#1080#1077
            Width = 250
          end
          item
            ImageIndex = -1
            Text = #1050#1086#1076
            Width = 125
          end
          item
            ImageIndex = -1
            Text = 'MQS'
            Width = 50
          end
          item
            ImageIndex = -1
            Text = #1044#1088#1086#1073#1085#1099#1077' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1099' '#1074' '#1092#1080#1085#1072#1083#1077
            Width = 50
          end
          item
            ImageIndex = -1
            Text = #1060#1080#1085#1072#1083#1100#1085#1099#1093' '#1084#1077#1089#1090
            Width = 50
          end
          item
            ImageIndex = -1
            Text = #1055#1086#1083#1086#1078#1077#1085#1080#1081', '#1089#1077#1088#1080#1081
            Width = 50
          end
          item
            ImageIndex = -1
            Text = #1042#1088#1077#1084#1103' '#1085#1072' '#1089#1084#1077#1085#1091
            Width = 125
          end>
        OnSectionResize = hcEventsSectionResize
      end
      object lbEvents: TListBox
        Left = 0
        Top = 58
        Width = 782
        Height = 479
        Style = lbOwnerDrawFixed
        Align = alClient
        Ctl3D = True
        ItemHeight = 13
        ParentCtl3D = False
        TabOrder = 1
        OnClick = lbEventsClick
        OnDblClick = lbEventsDblClick
        OnDrawItem = lbEventsDrawItem
        OnKeyDown = lbEventsKeyDown
      end
      object pnlEvents: TPanel
        Left = 0
        Top = 0
        Width = 780
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        ExplicitWidth = 782
        object btnAddEvent: TButton
          Left = 8
          Top = 8
          Width = 97
          Height = 25
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100
          TabOrder = 0
          TabStop = False
          OnClick = btnAddEventClick
        end
        object btnDeleteEvent: TButton
          Left = 112
          Top = 8
          Width = 89
          Height = 25
          Caption = #1059#1076#1072#1083#1080#1090#1100
          Enabled = False
          TabOrder = 1
          TabStop = False
          OnClick = btnDeleteEventClick
        end
        object btnCopyEvent: TButton
          Left = 208
          Top = 13
          Width = 85
          Height = 20
          Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
          Enabled = False
          TabOrder = 2
        end
      end
    end
    object tsChampionships: TTabSheet
      Caption = '  '#1057#1086#1088#1077#1074#1085#1086#1074#1072#1085#1080#1103'  '
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object hcChampionships: THeaderControl
        Left = 0
        Top = 41
        Width = 782
        Height = 17
        Sections = <
          item
            ImageIndex = -1
            Text = #1053#1072#1079#1074#1072#1085#1080#1077
            Width = 400
          end
          item
            ImageIndex = -1
            Text = 'MQS'
            Width = 64
          end>
        OnSectionResize = hcChampionshipsSectionResize
      end
      object pnlChamps: TPanel
        Left = 0
        Top = 0
        Width = 782
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object btnAddChamp: TButton
          Left = 8
          Top = 8
          Width = 97
          Height = 25
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100
          TabOrder = 0
          TabStop = False
          OnClick = btnAddChampClick
        end
        object btnDeleteChamp: TButton
          Left = 110
          Top = 11
          Width = 88
          Height = 25
          Caption = #1059#1076#1072#1083#1080#1090#1100
          Enabled = False
          TabOrder = 1
          TabStop = False
          OnClick = btnDeleteChampClick
        end
        object btnCopyChamp: TButton
          Left = 215
          Top = 15
          Width = 91
          Height = 21
          Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
          Enabled = False
          TabOrder = 2
          OnClick = btnCopyChampClick
        end
      end
      object lbChampionships: TListBox
        Left = 0
        Top = 58
        Width = 782
        Height = 479
        Style = lbOwnerDrawFixed
        Align = alClient
        ItemHeight = 16
        TabOrder = 2
        OnClick = lbChampionshipsClick
        OnDblClick = lbChampionshipsDblClick
        OnDrawItem = lbChampionshipsDrawItem
        OnKeyDown = lbChampionshipsKeyDown
        OnMouseDown = lbChampionshipsMouseDown
        OnMouseMove = lbChampionshipsMouseMove
      end
    end
    object tsQualifications: TTabSheet
      Caption = '  '#1050#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1080'  '
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lbQualifications: TListBox
        Left = 0
        Top = 58
        Width = 782
        Height = 479
        Style = lbOwnerDrawFixed
        Align = alClient
        ItemHeight = 16
        TabOrder = 0
        OnClick = lbQualificationsClick
        OnDblClick = lbQualificationsDblClick
        OnDrawItem = lbQualificationsDrawItem
        OnKeyDown = lbQualificationsKeyDown
        OnMouseDown = lbQualificationsMouseDown
        OnMouseMove = lbQualificationsMouseMove
      end
      object pnlQuals: TPanel
        Left = 0
        Top = 0
        Width = 780
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitWidth = 782
        object btnAddQual: TButton
          Left = 8
          Top = 8
          Width = 97
          Height = 25
          Hint = #1044#1086#1073#1072#1074#1083#1077#1085#1080#1077' '#1085#1086#1074#1086#1081' '#1082#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1080
          Caption = #1044#1086#1073#1072#1074#1080#1090#1100
          TabOrder = 0
          TabStop = False
          OnClick = btnAddQualClick
        end
        object btnDeleteQual: TButton
          Left = 112
          Top = 8
          Width = 89
          Height = 25
          Hint = #1059#1076#1072#1083#1077#1085#1080#1077' '#1082#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1080
          Caption = #1059#1076#1072#1083#1080#1090#1100
          TabOrder = 1
          TabStop = False
          OnClick = btnDeleteQualClick
        end
        object btnMoveUpQual: TButton
          Left = 224
          Top = 8
          Width = 145
          Height = 25
          Hint = #1055#1077#1088#1077#1084#1077#1097#1077#1085#1080#1077' '#1074#1099#1073#1088#1099#1085#1085#1086#1081' '#1082#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1080' '#1085#1072' '#1086#1076#1085#1091' '#1089#1090#1088#1086#1082#1091' '#1074#1099#1096#1077' '#1074' '#1089#1087#1080#1089#1082#1077
          Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1074#1074#1077#1088#1093
          TabOrder = 2
          TabStop = False
          OnClick = btnMoveUpQualClick
        end
        object btnMoveDownQual: TButton
          Left = 376
          Top = 8
          Width = 145
          Height = 25
          Hint = #1055#1077#1088#1077#1084#1077#1097#1077#1085#1080#1077' '#1074#1099#1073#1088#1099#1085#1085#1086#1081' '#1082#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1080' '#1085#1072' '#1086#1076#1085#1091' '#1089#1090#1088#1086#1082#1091' '#1085#1080#1078#1077' '#1074' '#1089#1087#1080#1089#1082#1077
          Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100' '#1074#1085#1080#1079
          TabOrder = 3
          TabStop = False
          OnClick = btnMoveDownQualClick
        end
      end
      object hcQualifications: THeaderControl
        Left = 0
        Top = 41
        Width = 780
        Height = 17
        Sections = <
          item
            ImageIndex = -1
            Text = #1053#1072#1079#1074#1072#1085#1080#1077
            Width = 250
          end
          item
            ImageIndex = -1
            Text = #1055#1088#1080#1089#1074#1072#1080#1074#1072#1077#1090#1089#1103' '#1089' '#1088#1077#1079#1091#1083#1100#1090#1072#1090#1086#1084
            Width = 250
          end>
        ExplicitWidth = 782
      end
    end
    object tsSocieties: TTabSheet
      Caption = #1044#1057#1054
      ImageIndex = 4
      OnResize = tsSocietiesResize
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object btnAddSoc: TButton
        Left = 3
        Top = 3
        Width = 75
        Height = 25
        Caption = 'btnAddSoc'
        TabOrder = 0
        OnClick = btnAddSocClick
      end
      object btnDeleteSoc: TButton
        Left = 84
        Top = 3
        Width = 87
        Height = 25
        Caption = 'btnDeleteSoc'
        TabOrder = 1
        OnClick = btnDeleteSocClick
      end
      object btnMoveSocUp: TButton
        Left = 177
        Top = 3
        Width = 104
        Height = 25
        Caption = 'btnMoveSocUp'
        TabOrder = 2
        OnClick = btnMoveSocUpClick
      end
      object btnMoveSocDown: TButton
        Left = 306
        Top = 3
        Width = 127
        Height = 25
        Caption = 'btnMoveSocDown'
        TabOrder = 3
        OnClick = btnMoveSocDownClick
      end
      object lbSocieties: TListBox
        Left = 3
        Top = 48
        Width = 670
        Height = 457
        ItemHeight = 16
        TabOrder = 4
        OnClick = lbSocietiesClick
        OnDblClick = lbSocietiesDblClick
        OnKeyDown = lbSocietiesKeyDown
      end
    end
  end
end
