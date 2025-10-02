object TeamSelectDialog: TTeamSelectDialog
  Left = 505
  Top = 349
  ActiveControl = edtTeam
  BorderStyle = bsToolWindow
  Caption = #1050#1086#1084#1072#1085#1076#1072
  ClientHeight = 181
  ClientWidth = 201
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object edtTeam: TEdit
    Left = 0
    Top = 160
    Width = 201
    Height = 21
    TabOrder = 0
    Text = 'edtTeam'
    OnChange = edtTeamChange
    OnKeyDown = edtTeamKeyDown
  end
  object lbTeams: TListBox
    Left = 0
    Top = 0
    Width = 201
    Height = 160
    IntegralHeight = True
    ItemHeight = 13
    TabOrder = 1
    OnClick = lbTeamsClick
    OnDblClick = lbTeamsDblClick
    OnKeyDown = lbTeamsKeyDown
  end
end
