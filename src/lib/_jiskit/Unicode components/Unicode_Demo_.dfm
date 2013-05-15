object Form1: TForm1
  Left = 192
  Top = 162
  Width = 234
  Height = 241
  BorderStyle = bsSizeToolWin
  Caption = 'Demo   // by Proger_XP'
  Color = clBtnFace
  Constraints.MaxHeight = 241
  Constraints.MinHeight = 241
  Constraints.MinWidth = 234
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    226
    201)
  PixelsPerInch = 120
  TextHeight = 16
  object lansi: TLabel
    Left = 8
    Top = 160
    Width = 114
    Height = 16
    Caption = 'An ordinary TLabel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lunicode: TLabelW
    Left = 8
    Top = 184
    Width = 111
    Height = 16
    Caption = 'TLabelW example'
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clMaroon
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 209
    Height = 81
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Unicode components behave exactly like their VCL (that is, ANSI)' +
      ' counterparts, except that they accept Unicode strings as a valu' +
      'e for their properties.'
    WordWrap = True
  end
  object eansi: TEdit
    Left = 8
    Top = 96
    Width = 209
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = 'put here some ANSI string'
    OnChange = eansiChange
  end
  object esjs: TEdit
    Left = 8
    Top = 128
    Width = 209
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clGreen
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = 'Insert some ShiftJIS text here'
    OnChange = esjsChange
  end
end
