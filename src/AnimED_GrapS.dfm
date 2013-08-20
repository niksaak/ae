object GrapSForm: TGrapSForm
  Left = 416
  Top = 300
  AutoScroll = False
  ClientHeight = 541
  ClientWidth = 703
  Color = clBtnFace
  Constraints.MinHeight = 560
  Constraints.MinWidth = 594
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -9
  Font.Name = 'Lucida Console'
  Font.Style = []
  Menu = MainMenu_GrapS
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnShow = FormShow
  DesignSize = (
    703
    541)
  PixelsPerInch = 96
  TextHeight = 9
  object I_Graps_View: TImage
    Left = 248
    Top = 0
    Width = 454
    Height = 540
    Hint = 'Double-click to save...'
    Anchors = [akLeft, akTop, akRight, akBottom]
    ParentShowHint = False
    ShowHint = True
    OnDblClick = M_Graps_SaveAsBMPClick
  end
  object Memo_Graps_HowTo: TMemo
    Left = 256
    Top = 8
    Width = 439
    Height = 524
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderStyle = bsNone
    Color = clBtnFace
    DragMode = dmAutomatic
    Lines.Strings = (
      'How to use:'
      ''
      
        'Open (or drag-n-drop) any file that (possibly) contain UNCOMPRES' +
        'SED bitmap data (game or software memory dumps, for example).'
      ''
      
        'Next, use trackbars or enter desirable bitmap size and set bits ' +
        'per pixel resolution (be careful. You will get no image if the s' +
        'ize is overruned).'
      ''
      'Use seeking controls to search the correct image offset.'
      ''
      
        'When you'#39'll get what you want, double-click the view to save BMP' +
        ' file. ^_^'
      ''
      'P.S. You can also search directly in application'#39's memory. ^_~')
    ReadOnly = True
    TabOrder = 1
    WordWrap = False
  end
  object GB_Graps_Image: TGroupBox
    Left = 8
    Top = 256
    Width = 233
    Height = 249
    Caption = ' Image properties '
    TabOrder = 0
    object L_Graps_Width: TLabelW
      Left = 8
      Top = 16
      Width = 217
      Height = 17
      AutoSize = False
      Caption = 'Enter image width:'
    end
    object L_Graps_Height: TLabelW
      Left = 8
      Top = 75
      Width = 217
      Height = 11
      AutoSize = False
      Caption = 'Enter image height:'
    end
    object L_Graps_Bitdepth: TLabelW
      Left = 8
      Top = 136
      Width = 153
      Height = 17
      AutoSize = False
      Caption = 'Select bit resolution:'
    end
    object L_Graps_CalcStrSizeHEX: TLabelW
      Left = 8
      Top = 181
      Width = 113
      Height = 28
      AutoSize = False
      Caption = 'Calculated size (HEX):'
      WordWrap = True
    end
    object Bevel_Graps_1: TBevel
      Left = 1
      Top = 173
      Width = 231
      Height = 2
      Shape = bsTopLine
    end
    object Bevel_Graps_2: TBevel
      Left = 1
      Top = 215
      Width = 231
      Height = 2
      Shape = bsTopLine
    end
    object L_Graps_StreamSizeValue: TLabelW
      Left = 123
      Top = 200
      Width = 99
      Height = 9
      AutoSize = False
      Caption = '0'
    end
    object E_Graps_Width: TEdit
      Left = 8
      Top = 32
      Width = 217
      Height = 17
      TabOrder = 0
      Text = '1'
      OnChange = E_Graps_WidthChange
    end
    object E_Graps_Height: TEdit
      Left = 8
      Top = 88
      Width = 217
      Height = 17
      TabOrder = 1
      Text = '1'
      OnChange = E_Graps_HeightChange
    end
    object CB_Graps_Bitdepth: TComboBox
      Left = 168
      Top = 132
      Width = 57
      Height = 17
      Style = csDropDownList
      ItemHeight = 9
      ItemIndex = 3
      TabOrder = 2
      Text = '32'
      OnChange = CB_Graps_BitdepthChange
      Items.Strings = (
        '8'
        '16'
        '24'
        '32')
    end
    object TrackBar_Graps_Width: TTrackBar
      Left = 8
      Top = 49
      Width = 217
      Height = 25
      Max = 8192
      Min = 1
      Position = 1
      TabOrder = 3
      ThumbLength = 10
      TickMarks = tmTopLeft
      OnChange = TrackBar_Graps_WidthChange
    end
    object TrackBar_Graps_Height: TTrackBar
      Left = 8
      Top = 105
      Width = 217
      Height = 25
      Max = 8192
      Min = 1
      Position = 1
      TabOrder = 4
      ThumbLength = 10
      TickMarks = tmTopLeft
      OnChange = TrackBar_Graps_HeightChange
    end
    object CB_Graps_Stretch: TCheckBox
      Left = 8
      Top = 224
      Width = 217
      Height = 17
      Caption = 'Stretch for viewer'
      TabOrder = 5
      OnClick = CB_Graps_StretchClick
    end
    object E_Graps_StreamSizeValue: TEdit
      Left = 120
      Top = 178
      Width = 105
      Height = 17
      MaxLength = 16
      ReadOnly = True
      TabOrder = 6
      Text = '0'
      OnChange = E_Graps_StreamSizeValueChange
    end
    object CB_Graps_Interleaved: TCheckBox
      Left = 8
      Top = 152
      Width = 217
      Height = 17
      Caption = 'Interleaved image stream'
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 7
    end
  end
  object PC_Graps_Controls: TPageControl
    Left = 0
    Top = 0
    Width = 248
    Height = 256
    ActivePage = TS_Graps_FileMode
    BiDiMode = bdLeftToRight
    HotTrack = True
    ParentBiDiMode = False
    Style = tsButtons
    TabOrder = 2
    object TS_Graps_FileMode: TTabSheet
      Caption = 'File Mode'
      object GB_Graps_Seek: TGroupBox
        Left = 4
        Top = 2
        Width = 233
        Height = 223
        Caption = ' Seek control '
        TabOrder = 0
        object L_Graps_Offset: TLabelW
          Left = 8
          Top = 16
          Width = 217
          Height = 17
          AutoSize = False
          Caption = 'Enter beginning offset:'
        end
        object L_Graps_SeekStep: TLabelW
          Left = 8
          Top = 56
          Width = 217
          Height = 17
          AutoSize = False
          Caption = 'Seeking step (for << and >>):'
        end
        object L_Graps_FinalOffsetText: TLabelW
          Left = 8
          Top = 168
          Width = 217
          Height = 17
          AutoSize = False
          Caption = 'Ending offset:'
        end
        object L_Graps_FinalOffset: TLabelW
          Left = 120
          Top = 184
          Width = 105
          Height = 9
          Alignment = taRightJustify
          AutoSize = False
          Caption = '0'
        end
        object E_Graps_Offset: TEdit
          Left = 8
          Top = 32
          Width = 217
          Height = 17
          TabOrder = 0
          Text = '0'
          OnChange = E_Graps_OffsetChange
        end
        object B_Graps_Back2: TButton
          Left = 38
          Top = 120
          Width = 17
          Height = 17
          Caption = '<'
          TabOrder = 1
          OnClick = B_Graps_Back2Click
        end
        object B_Graps_BackSeek: TButton
          Left = 56
          Top = 120
          Width = 17
          Height = 17
          Caption = '<<'
          TabOrder = 2
          OnClick = B_Graps_BackSeekClick
        end
        object B_Graps_JumpUp: TButton
          Left = 72
          Top = 96
          Width = 89
          Height = 17
          Caption = '^ Size ^'
          TabOrder = 3
          OnClick = B_Graps_JumpUpClick
        end
        object B_Graps_NextSeek: TButton
          Left = 160
          Top = 120
          Width = 17
          Height = 17
          Caption = '>>'
          TabOrder = 5
          OnClick = B_Graps_NextSeekClick
        end
        object B_Graps_Next2: TButton
          Left = 178
          Top = 120
          Width = 17
          Height = 17
          Caption = '>'
          TabOrder = 6
          OnClick = B_Graps_Next2Click
        end
        object E_Graps_Step: TEdit
          Left = 8
          Top = 72
          Width = 217
          Height = 17
          TabOrder = 7
          Text = '1024'
        end
        object B_Graps_Back1: TButton
          Left = 20
          Top = 120
          Width = 17
          Height = 17
          Caption = '.'
          TabOrder = 8
          OnClick = B_Graps_Back1Click
        end
        object B_Graps_Next1: TButton
          Left = 196
          Top = 120
          Width = 17
          Height = 17
          Caption = '.'
          TabOrder = 9
          OnClick = B_Graps_Next1Click
        end
        object B_Graps_Reset: TButton
          Left = 88
          Top = 120
          Width = 57
          Height = 17
          Caption = 'RESET'
          TabOrder = 10
          OnClick = B_Graps_ResetClick
        end
        object B_Graps_JumpDown: TButton
          Left = 72
          Top = 145
          Width = 89
          Height = 16
          Caption = 'v Size v'
          TabOrder = 4
          OnClick = B_Graps_JumpDownClick
        end
      end
    end
    object TS_Graps_ProcessList: TTabSheet
      Caption = 'Process List Mode'
      ImageIndex = 1
      OnShow = TS_Graps_ProcessListShow
      object CB_Graps_ProcessList: TGroupBox
        Left = 4
        Top = 2
        Width = 233
        Height = 225
        Caption = ' Process list and seeking '
        TabOrder = 0
        object L_Graps_ProcAddressStart: TLabelW
          Left = 8
          Top = 132
          Width = 217
          Height = 11
          AutoSize = False
          Caption = 'Memory address (HEX):'
        end
        object L_Graps_ProcMemError: TLabelW
          Left = 8
          Top = 119
          Width = 217
          Height = 9
          Alignment = taCenter
          AutoSize = False
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clRed
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Style = []
          ParentFont = False
        end
        object L_Graps_ProcMemCpy: TLabelW
          Left = 8
          Top = 165
          Width = 161
          Height = 11
          AutoSize = False
          Caption = 'Amount to copy (HEX):'
        end
        object LB_Graps_ProcessList: TListBox
          Left = 8
          Top = 14
          Width = 193
          Height = 105
          ItemHeight = 9
          TabOrder = 0
        end
        object E_Graps_ProcStart: TEdit
          Left = 8
          Top = 144
          Width = 104
          Height = 17
          MaxLength = 16
          TabOrder = 1
          Text = '0'
        end
        object B_Graps_CopyProcMem: TButton
          Left = 176
          Top = 144
          Width = 49
          Height = 50
          Caption = 'Grab memory'
          TabOrder = 2
          WordWrap = True
          OnClick = B_Graps_CopyProcMemClick
        end
        object B_Graps_ProcListRefresh: TButton
          Left = 204
          Top = 14
          Width = 21
          Height = 106
          Caption = 'REFRESH'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Lucida Console'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          WordWrap = True
          OnClick = TS_Graps_ProcessListShow
        end
        object E_Graps_ProcMemAmount: TEdit
          Left = 8
          Top = 177
          Width = 104
          Height = 17
          MaxLength = 16
          TabOrder = 4
          Text = '0'
        end
        object B_Graps_MemCpyFromCalc: TButton
          Left = 112
          Top = 177
          Width = 57
          Height = 17
          Caption = 'Get'
          TabOrder = 5
          OnClick = B_Graps_MemCpyFromCalcClick
        end
        object B_Graps_MemAddrPaste: TButton
          Left = 112
          Top = 144
          Width = 57
          Height = 17
          Caption = 'Paste'
          TabOrder = 6
          OnClick = B_Graps_MemAddrPasteClick
        end
        object CB_Graps_MemoryAutoCpy: TCheckBox
          Left = 8
          Top = 195
          Width = 161
          Height = 28
          Caption = 'Automatically grab every...'
          TabOrder = 7
          WordWrap = True
          OnClick = CB_Graps_MemoryAutoCpyClick
        end
        object E_Graps_CpyAutoRef: TEdit
          Left = 176
          Top = 200
          Width = 39
          Height = 17
          ReadOnly = True
          TabOrder = 8
          Text = '500'
        end
        object UD_Graps_AutoMemRef: TUpDown
          Left = 215
          Top = 200
          Width = 12
          Height = 17
          Associate = E_Graps_CpyAutoRef
          Min = 5
          Max = 32767
          Increment = 5
          Position = 500
          TabOrder = 9
          OnClick = UD_Graps_AutoMemRefClick
        end
      end
    end
  end
  object MainMenu_GrapS: TMainMenu
    Left = 317
    Top = 144
    object M_Graps_File: TMenuItem
      Caption = ' File '
      object M_Graps_OpenFile: TMenuItem
        Caption = 'Open...'
        OnClick = M_Graps_OpenFileClick
      end
      object M_Graps_Sep1: TMenuItem
        Caption = '-'
      end
      object M_Graps_SaveAsBMP: TMenuItem
        Caption = 'Save as BMP...'
        OnClick = M_Graps_SaveAsBMPClick
      end
      object M_Graps_Sep2: TMenuItem
        Caption = '-'
      end
      object M_Graps_Exit: TMenuItem
        Caption = 'Return to AE'
        OnClick = M_Graps_ExitClick
      end
    end
    object M_Graps_Help: TMenuItem
      Caption = ' ? '
      OnClick = M_Graps_HelpClick
    end
  end
  object T_Graps_AutoMemRef: TTimer
    Enabled = False
    Interval = 500
    OnTimer = T_Graps_AutoMemRefTimer
    Left = 317
    Top = 191
  end
end
