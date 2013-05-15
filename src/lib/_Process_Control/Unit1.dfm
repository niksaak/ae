object Form1: TForm1
  Left = 401
  Top = 210
  Width = 260
  Height = 179
  Caption = 'reh'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 160
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Refresh'
    TabOrder = 0
    OnClick = Button1Click
  end
  object ListBox1: TListBox
    Left = 16
    Top = 16
    Width = 121
    Height = 97
    ItemHeight = 13
    TabOrder = 1
  end
  object Button2: TButton
    Left = 160
    Top = 96
    Width = 75
    Height = 25
    Caption = 'Read'
    TabOrder = 2
    OnClick = Button2Click
  end
end
