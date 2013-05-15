object Form1: TForm1
  Left = 192
  Top = 162
  Width = 340
  Height = 195
  BorderStyle = bsSizeToolWin
  Caption = 'JReconvertor unit demo   // by Proger_XP'
  Color = clBtnFace
  Constraints.MaxHeight = 195
  Constraints.MinHeight = 190
  Constraints.MinWidth = 330
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  DesignSize = (
    332
    155)
  PixelsPerInch = 120
  TextHeight = 16
  object lansi: TLabel
    Left = 250
    Top = 72
    Width = 28
    Height = 16
    Anchors = [akTop, akRight]
    Caption = 'lansi'
  end
  object lsjs: TLabel
    Left = 250
    Top = 104
    Width = 20
    Height = 16
    Anchors = [akTop, akRight]
    Caption = 'lsjs'
  end
  object lunicode: TLabel
    Left = 250
    Top = 136
    Width = 51
    Height = 16
    Cursor = crHandPoint
    Anchors = [akTop, akRight]
    Caption = 'lunicode'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lunicodeClick
  end
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 315
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'JReconvertor converts strings of different codepages. It has sho' +
      'rtcut functions to convert between ShiftJIS <-> Unicode <-> ANSI' +
      ' codepages.'
    WordWrap = True
  end
  object eansi: TEdit
    Left = 8
    Top = 64
    Width = 233
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    Text = 'Ansi'
    OnChange = eansiChange
    OnKeyUp = eansiKeyUp
  end
  object eunicode: TEdit
    Left = 8
    Top = 128
    Width = 233
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Color = clCream
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    ReadOnly = True
    TabOrder = 1
    Text = 'Unicode'
    OnChange = eansiChange
  end
  object esjs: TEdit
    Left = 8
    Top = 96
    Width = 233
    Height = 24
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = SHIFTJIS_CHARSET
    Font.Color = clGreen
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Text = 'ShiftJIS'
    OnChange = eansiChange
    OnKeyUp = esjsKeyUp
  end
end
