object PreviewForm: TPreviewForm
  Left = 255
  Top = 304
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsNone
  ClientHeight = 213
  ClientWidth = 328
  Color = clBtnFace
  Constraints.MinHeight = 240
  Constraints.MinWidth = 320
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object I_LargePreview: TImage
    Left = 0
    Top = 0
    Width = 328
    Height = 213
    Align = alClient
    AutoSize = True
    Center = True
    IncrementalDisplay = True
    Proportional = True
    Stretch = True
    OnDblClick = I_LargePreviewDblClick
    OnMouseDown = Shape_BGMouseDown
  end
end
