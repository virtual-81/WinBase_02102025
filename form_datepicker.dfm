object DatePickerDialog: TDatePickerDialog
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'DatePickerDialog'
  ClientHeight = 255
  ClientWidth = 677
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 13
  object MonthCalendar1: TMonthCalendar
    Left = 36
    Top = 0
    Width = 566
    Height = 131
    Date = 40049.000000000000000000
    ShowToday = False
    TabOrder = 0
    TabStop = True
  end
  object btnOk: TButton
    Left = 29
    Top = 203
    Width = 68
    Height = 23
    Caption = 'btnOk'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 116
    Top = 203
    Width = 68
    Height = 23
    Cancel = True
    Caption = 'btnCancel'
    ModalResult = 2
    TabOrder = 2
  end
end
