object ShooterDetailsDialog: TShooterDetailsDialog
  Left = 265
  Top = 205
  HorzScrollBar.Visible = False
  VertScrollBar.Tracking = True
  ActiveControl = edtSurname
  BorderIcons = [biSystemMenu]
  BorderWidth = 8
  Caption = 'ShooterDetailsDialog'
  ClientHeight = 444
  ClientWidth = 766
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 713
    Height = 385
    ActivePage = tsMain
    TabOrder = 0
    object tsMain: TTabSheet
      BorderWidth = 16
      Caption = #1054#1089#1085#1086#1074#1085#1099#1077' '#1076#1072#1085#1085#1099#1077
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lSportClub: TLabel
        Left = 347
        Top = 267
        Width = 24
        Height = 13
        Caption = #1050#1083#1091#1073
      end
      object lTown: TLabel
        Left = 16
        Top = 240
        Width = 30
        Height = 13
        Caption = #1043#1086#1088#1086#1076
      end
      object lISSFId: TLabel
        Left = 8
        Top = 131
        Width = 37
        Height = 13
        Caption = 'ISSF ID'
      end
      object lStepName: TLabel
        Left = 8
        Top = 46
        Width = 47
        Height = 13
        Caption = #1054#1090#1095#1077#1089#1090#1074#1086
      end
      object lName: TLabel
        Left = 8
        Top = 27
        Width = 22
        Height = 13
        Caption = #1048#1084#1103
      end
      object lSurname: TLabel
        Left = 8
        Top = 3
        Width = 49
        Height = 13
        Caption = #1060#1072#1084#1080#1083#1080#1103
      end
      object lGender: TLabel
        Left = 2
        Top = 104
        Width = 20
        Height = 13
        Caption = #1055#1086#1083
        Transparent = True
      end
      object lQualification: TLabel
        Left = 272
        Top = 132
        Width = 78
        Height = 13
        Caption = #1050#1074#1072#1083#1080#1092#1080#1082#1072#1094#1080#1103':'
      end
      object lDistrict: TLabel
        Left = 36
        Top = 208
        Width = 30
        Height = 13
        Alignment = taRightJustify
        Caption = #1054#1082#1088#1091#1075
      end
      object lRegion2: TLabel
        Left = 6
        Top = 184
        Width = 60
        Height = 13
        Alignment = taRightJustify
        Caption = #1056#1077#1075#1080#1086#1085' '#1076#1086#1087'.'
      end
      object lRegion1: TLabel
        Left = 30
        Top = 165
        Width = 36
        Height = 13
        Alignment = taRightJustify
        Caption = #1056#1077#1075#1080#1086#1085
      end
      object lBYear: TLabel
        Left = 33
        Top = 80
        Width = 71
        Height = 13
        Alignment = taRightJustify
        Caption = #1043#1086#1076' '#1088#1086#1078#1076#1077#1085#1080#1103
      end
      object lBDate: TLabel
        Left = 234
        Top = 80
        Width = 127
        Height = 13
        Caption = #1044#1072#1090#1072' '#1088#1086#1078#1076#1077#1085#1080#1103' ('#1044#1044'.'#1052#1052')'
      end
      object lBFull: TLabel
        Left = 8
        Top = 80
        Width = 120
        Height = 13
        Alignment = taRightJustify
        Caption = #1044#1072#1090#1072' '#1088#1086#1078#1076#1077#1085#1080#1103' ('#1044#1044'.'#1052#1052'.'#1043#1043#1043#1043')'
      end
      object sbDeletePhoto: TSpeedButton
        Left = 638
        Top = 208
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
        OnClick = btnDeletePhotoClick
      end
      object sbAddPhoto: TSpeedButton
        Left = 561
        Top = 208
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
        OnClick = btnAddPhotoClick
      end
      object sbPrevImage: TSpeedButton
        Left = 512
        Top = 208
        Width = 23
        Height = 22
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3333333333333333333333333333333333333333333333333333333333333333
          3333333333333FF3333333333333003333333333333F77F33333333333009033
          333333333F7737F333333333009990333333333F773337FFFFFF330099999000
          00003F773333377777770099999999999990773FF33333FFFFF7330099999000
          000033773FF33777777733330099903333333333773FF7F33333333333009033
          33333333337737F3333333333333003333333333333377333333333333333333
          3333333333333333333333333333333333333333333333333333333333333333
          3333333333333333333333333333333333333333333333333333}
        NumGlyphs = 2
      end
      object sbNextImage: TSpeedButton
        Left = 590
        Top = 208
        Width = 23
        Height = 22
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3333333333333333333333333333333333333333333333333333333333333333
          3333333333333333333333333333333333333333333FF3333333333333003333
          3333333333773FF3333333333309003333333333337F773FF333333333099900
          33333FFFFF7F33773FF30000000999990033777777733333773F099999999999
          99007FFFFFFF33333F7700000009999900337777777F333F7733333333099900
          33333333337F3F77333333333309003333333333337F77333333333333003333
          3333333333773333333333333333333333333333333333333333333333333333
          3333333333333333333333333333333333333333333333333333}
        NumGlyphs = 2
      end
      object lSociety: TLabel
        Left = 8
        Top = 280
        Width = 37
        Height = 13
        Caption = 'lSociety'
      end
      object edtSurname: TEdit
        Left = 80
        Top = 0
        Width = 401
        Height = 21
        TabOrder = 0
        Text = 'edtSurname'
        OnKeyPress = OnControlKeyPress
      end
      object edtTown: TEdit
        Left = 72
        Top = 240
        Width = 121
        Height = 21
        TabOrder = 15
        Text = 'edtTown'
        OnKeyPress = OnControlKeyPress
      end
      object edtSportClub: TEdit
        Left = 377
        Top = 264
        Width = 121
        Height = 21
        TabOrder = 17
        Text = 'edtSportClub'
        OnKeyPress = OnControlKeyPress
      end
      object edtISSFID: TEdit
        Left = 80
        Top = 128
        Width = 121
        Height = 21
        TabOrder = 7
        Text = 'edtISSFID'
        OnKeyPress = OnControlKeyPress
      end
      object edtStepName: TEdit
        Left = 72
        Top = 48
        Width = 121
        Height = 21
        TabOrder = 2
        Text = 'edtStepName'
        OnKeyPress = OnControlKeyPress
      end
      object edtName: TEdit
        Left = 72
        Top = 24
        Width = 401
        Height = 21
        TabOrder = 1
        Text = 'edtName'
        OnKeyPress = OnControlKeyPress
      end
      object rbMale: TRadioButton
        Left = 90
        Top = 104
        Width = 73
        Height = 17
        Caption = #1052#1091#1078#1089#1082#1086#1081
        TabOrder = 5
        OnKeyPress = OnControlKeyPress
      end
      object rbFemale: TRadioButton
        Left = 170
        Top = 104
        Width = 73
        Height = 17
        Caption = #1046#1077#1085#1089#1082#1080#1081
        TabOrder = 6
        OnKeyPress = OnControlKeyPress
      end
      object edtDistrictFull: TEdit
        Left = 136
        Top = 206
        Width = 362
        Height = 21
        TabOrder = 14
        OnKeyPress = OnControlKeyPress
      end
      object edtBirthDate: TEdit
        Left = 368
        Top = 72
        Width = 65
        Height = 21
        TabOrder = 5
        Text = '99.99'
        OnKeyPress = OnControlKeyPress
        ReadOnly = True
        TabStop = False
      end
      object edtBirthYear: TEdit
        Left = 120
        Top = 72
        Width = 65
        Height = 21
        TabOrder = 4
        Text = '9999'
        OnKeyPress = OnControlKeyPress
        ReadOnly = True
        TabStop = False
      end
      object edtBirthFull: TEdit
        Left = 136
        Top = 72
        Width = 121
        Height = 21
        TabOrder = 3
        Text = '31.12.1981'
        OnKeyPress = OnControlKeyPress
      end
      object edtRegionAbbr1: TEdit
        Left = 72
        Top = 157
        Width = 58
        Height = 21
        TabOrder = 9
        OnChange = edtRegionAbbr1Change
        OnKeyPress = OnControlKeyPress
      end
      object edtRegionAbbr2: TEdit
        Left = 72
        Top = 184
        Width = 58
        Height = 21
        TabOrder = 11
        OnChange = edtRegionAbbr2Change
        OnKeyPress = OnControlKeyPress
      end
      object edtDistrictAbbr: TEdit
        Left = 72
        Top = 211
        Width = 58
        Height = 21
        TabOrder = 13
        OnChange = edtDistrictAbbrChange
        OnKeyPress = OnControlKeyPress
      end
      object edtRegionFull2: TEdit
        Left = 136
        Top = 184
        Width = 362
        Height = 21
        TabOrder = 12
        OnKeyPress = OnControlKeyPress
      end
      object edtRegionFull1: TEdit
        Left = 136
        Top = 157
        Width = 362
        Height = 21
        TabOrder = 10
        OnKeyPress = OnControlKeyPress
      end
      object cbQualification: TComboBox
        Left = 366
        Top = 128
        Width = 131
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 8
        OnKeyPress = OnControlKeyPress
      end
      object pnlPhoto: TPanel
        Left = 512
        Top = 0
        Width = 153
        Height = 202
        Cursor = crHandPoint
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Caption = #1053#1077#1090' '#1092#1086#1090#1086
        Ctl3D = False
        ParentColor = True
        ParentCtl3D = False
        TabOrder = 18
        OnClick = pnlPhotoClick
      end
      object cbSociety: TComboBox
        Left = 72
        Top = 277
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 16
      end
    end
    object tsAdd: TTabSheet
      BorderWidth = 16
      Caption = #1044#1086#1087#1086#1083#1085#1080#1090#1077#1083#1100#1085#1086
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lPhone: TLabel
        Left = 56
        Top = 16
        Width = 59
        Height = 13
        Caption = #1058#1077#1083#1077#1092#1086#1085'('#1099')'
      end
      object lWeapon: TLabel
        Left = 104
        Top = 144
        Width = 39
        Height = 13
        Caption = #1054#1088#1091#1078#1080#1077
      end
      object lAddress: TLabel
        Left = 80
        Top = 52
        Width = 31
        Height = 13
        Caption = #1040#1076#1088#1077#1089
      end
      object lCoaches: TLabel
        Left = 64
        Top = 184
        Width = 45
        Height = 13
        Caption = #1058#1088#1077#1085#1077#1088#1099
      end
      object lPassport: TLabel
        Left = 68
        Top = 86
        Width = 43
        Height = 13
        Caption = #1055#1072#1089#1087#1086#1088#1090
      end
      object edtPhone: TEdit
        Left = 160
        Top = 16
        Width = 121
        Height = 21
        TabOrder = 0
        Text = 'edtPhone'
      end
      object meWeapon: TMemo
        Left = 160
        Top = 144
        Width = 185
        Height = 37
        Lines.Strings = (
          'meWeapon')
        TabOrder = 3
      end
      object meAddress: TMemo
        Left = 160
        Top = 43
        Width = 185
        Height = 42
        Lines.Strings = (
          'meAddress')
        TabOrder = 1
      end
      object meCoaches: TMemo
        Left = 160
        Top = 184
        Width = 185
        Height = 50
        Lines.Strings = (
          'meCoaches')
        TabOrder = 4
      end
      object mePassport: TMemo
        Left = 160
        Top = 89
        Width = 185
        Height = 49
        Lines.Strings = (
          'mePassport')
        TabOrder = 2
      end
    end
    object tsRemarks: TTabSheet
      BorderWidth = 16
      Caption = #1050#1086#1084#1084#1077#1085#1090#1072#1088#1080#1080
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object meRemarks: TMemo
        Left = 0
        Top = 0
        Width = 673
        Height = 325
        Align = alClient
        Lines.Strings = (
          'meRemarks')
        TabOrder = 0
      end
    end
  end
  object btnClose: TButton
    Left = 585
    Top = 407
    Width = 75
    Height = 25
    Caption = #1047#1072#1082#1088#1099#1090#1100
    ModalResult = 1
    TabOrder = 1
    TabStop = False
  end
  object OpenDialog1: TOpenDialog
    Options = [ofReadOnly, ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Title = #1054#1090#1082#1088#1099#1090#1100' '#1080#1079#1086#1073#1088#1072#1078#1077#1085#1080#1077
    Left = 720
    Top = 128
  end
end
