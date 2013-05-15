object Form1: TForm1
  Left = 192
  Top = 162
  Width = 452
  Height = 365
  BorderStyle = bsSizeToolWin
  Caption = 'JUtils demo   //  by Proger_XP'
  Color = clBtnFace
  Constraints.MinHeight = 365
  Constraints.MinWidth = 452
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    444
    325)
  PixelsPerInch = 120
  TextHeight = 16
  object path: TLabelW
    Left = 8
    Top = 16
    Width = 393
    Height = 16
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'JUtils. ExtractFileDirectory'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 152
    Width = 108
    Height = 16
    Caption = 'Recursive search:'
  end
  object files: TMemo
    Left = 8
    Top = 42
    Width = 425
    Height = 103
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      'JUtils. FindMask result')
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object BitBtn1: TBitBtn
    Left = 408
    Top = 8
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    TabOrder = 1
    OnClick = BitBtn1Click
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000074120000741200000000000000000000E7E7E7E7E7E7
      E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7
      E7E7E7E7E7E7E7E7E7E74D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D
      4D4D4D4D4D4D4D4D4D4D4DE7E7E7E7E7E7E7E7E7E7E7E7E7E7E74D4D4D4D4D4D
      4DA6A64DA6A64DA6A64DA6A64DA6A64DA6A64DA6A64DA6A64DA6A64D4D4DE7E7
      E7E7E7E7E7E7E7E7E7E74D4D4D4DFFFF4D4D4D4DA6A64DA6A64DA6A64DA6A64D
      A6A64DA6A64DA6A64DA6A64DA6A64D4D4DE7E7E7E7E7E7E7E7E74D4D4DFFFFFF
      4DFFFF4D4D4D4DA6A64DA6A64DA6A64DA6A64DA6A64DA6A64DA6A64DA6A64DA6
      A64D4D4DE7E7E7E7E7E74D4D4D4DFFFFFFFFFF4DFFFF4D4D4D4DA6A64DA6A64D
      A6A64DA6A64DA6A64DA6A64DA6A64DA6A64DA6A64D4D4DE7E7E74D4D4DFFFFFF
      4DFFFFFFFFFF4DFFFF4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D4D
      4D4D4D4D4D4D4D4D4D4D4D4D4D4DFFFFFFFFFF4DFFFFFFFFFF4DFFFFFFFFFF4D
      FFFFFFFFFF4DFFFF4D4D4DE7E7E7E7E7E7E7E7E7E7E7E7E7E7E74D4D4DFFFFFF
      4DFFFFFFFFFF4DFFFFFFFFFF4DFFFFFFFFFF4DFFFFFFFFFF4D4D4DE7E7E7E7E7
      E7E7E7E7E7E7E7E7E7E74D4D4D4DFFFFFFFFFF4DFFFF4D4D4D4D4D4D4D4D4D4D
      4D4D4D4D4D4D4D4D4D4D4DE7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E74D4D4D
      4D4D4D4D4D4DE7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E74D4D
      4D4D4D4D4D4D4DE7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7
      E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E74D4D4D4D4D4DE7E7E7E7E7E7E7E7E7
      E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E74D4D4DE7E7E7E7E7E7E7E7E74D4D
      4DE7E7E74D4D4DE7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7
      E7E7E7E7E74D4D4D4D4D4D4D4D4DE7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7
      E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7
      E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7
      E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7E7}
  end
  object anything: TMemo
    Left = 8
    Top = 176
    Width = 425
    Height = 153
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Lines.Strings = (
      'JUtils. FindAll result')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
    WordWrap = False
  end
  object relative: TCheckBox
    Left = 296
    Top = 152
    Width = 137
    Height = 17
    Alignment = taLeftJustify
    Anchors = [akTop, akRight]
    Caption = 'Relative recursion'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object odw: TOpenDialogW
    FilterIndex = 0
    Options = []
    Left = 360
    Top = 8
  end
end
