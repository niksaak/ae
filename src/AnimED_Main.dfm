object MainForm: TMainForm
  Left = 404
  Top = 243
  Width = 675
  Height = 623
  AlphaBlend = True
  AlphaBlendValue = 0
  Color = clBtnFace
  Constraints.MinHeight = 623
  Constraints.MinWidth = 675
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Helv'
  Font.Pitch = fpFixed
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poNone
  ShowHint = True
  SnapBuffer = 15
  OnClose = FormClose
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    667
    596)
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl_Main: TPageControl
    Left = 8
    Top = 8
    Width = 649
    Height = 513
    ActivePage = TS_Archiver
    Anchors = [akLeft, akTop, akRight, akBottom]
    MultiLine = True
    Style = tsButtons
    TabOrder = 0
    object TS_Archiver: TTabSheet
      Caption = 'Archive Tool'
      OnShow = TS_ArchiverShow
      DesignSize = (
        641
        482)
      object PageControl_Archives: TPageControl
        Left = 0
        Top = 96
        Width = 641
        Height = 389
        ActivePage = TS_ArchiveInterface
        Anchors = [akLeft, akTop, akRight, akBottom]
        Style = tsButtons
        TabOrder = 0
        object TS_ArchiveInterface: TTabSheet
          Caption = 'Info && Preview'
          DesignSize = (
            633
            358)
          object GB_ArchiveInfo: TGroupBox
            Left = 0
            Top = 293
            Width = 633
            Height = 65
            Anchors = [akLeft, akRight, akBottom]
            Caption = ' Opened archive info '
            TabOrder = 0
            OnDblClick = L_ArchiveFormatDblClick
            DesignSize = (
              633
              65)
            object L_FileNameTitle: TLabelW
              Left = 2
              Top = 13
              Width = 87
              Height = 15
              Alignment = taRightJustify
              AutoSize = False
              Caption = 'File name:'
            end
            object L_ArchiveFormatTitle: TLabelW
              Left = 1
              Top = 40
              Width = 88
              Height = 17
              Alignment = taRightJustify
              AutoSize = False
              Caption = 'Format:'
              Transparent = True
              OnDblClick = L_ArchiveFormatDblClick
            end
            object L_ArchiveSizeTitle: TLabelW
              Left = 400
              Top = 32
              Width = 85
              Height = 17
              Alignment = taRightJustify
              Anchors = [akTop, akRight]
              AutoSize = False
              Caption = 'File size:'
              Transparent = True
              OnDblClick = L_ArchiveFormatDblClick
            end
            object L_ArchiveSize: TLabelW
              Tag = -1
              Left = 498
              Top = 32
              Width = 129
              Height = 17
              Alignment = taRightJustify
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = '0 bytes'
              Transparent = True
              OnDblClick = L_ArchiveFormatDblClick
            end
            object L_ArchiveFormat: TLabelW
              Tag = -1
              Left = 96
              Top = 40
              Width = 297
              Height = 17
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'unknown format'
              Transparent = True
              OnDblClick = L_ArchiveFormatDblClick
            end
            object L_RecordsCountTitle: TLabelW
              Left = 400
              Top = 48
              Width = 85
              Height = 17
              Alignment = taRightJustify
              Anchors = [akTop, akRight]
              AutoSize = False
              Caption = 'Records:'
              Transparent = True
              OnDblClick = L_ArchiveFormatDblClick
            end
            object L_RecordsCount: TLabelW
              Tag = -1
              Left = 498
              Top = 48
              Width = 129
              Height = 19
              Alignment = taRightJustify
              Anchors = [akTop, akRight]
              AutoSize = False
              Caption = '0'
              Transparent = True
              OnDblClick = L_ArchiveFormatDblClick
            end
            object Bevel2: TBevel
              Left = 1
              Top = 29
              Width = 631
              Height = 2
              Anchors = [akLeft, akTop, akRight]
              Shape = bsTopLine
            end
            object Bevel1: TBevel
              Left = 400
              Top = 30
              Width = 2
              Height = 33
              Anchors = [akRight, akBottom]
              Shape = bsLeftLine
            end
            object E_ArcFileName: TEdit
              Tag = -3
              Left = 96
              Top = 13
              Width = 529
              Height = 16
              AutoSize = False
              BorderStyle = bsNone
              Color = clBtnFace
              Font.Charset = SHIFTJIS_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Pitch = fpFixed
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              Text = '---'
            end
          end
          object LV_ArcFileList: TListView
            Left = 0
            Top = 6
            Width = 633
            Height = 284
            Anchors = [akLeft, akTop, akRight, akBottom]
            Columns = <
              item
                AutoSize = True
                Caption = 'Name and path'
                MinWidth = 342
              end
              item
                AutoSize = True
                Caption = 'Size'
                MaxWidth = 74
                MinWidth = 74
              end
              item
                AutoSize = True
                Caption = 'Compressed'
                MaxWidth = 74
                MinWidth = 74
              end
              item
                AutoSize = True
                Caption = 'Offset'
                MaxWidth = 74
                MinWidth = 74
              end
              item
                AutoSize = True
                Caption = 'ID'
                MaxWidth = 42
                MinWidth = 42
              end>
            Font.Charset = SHIFTJIS_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Pitch = fpFixed
            Font.Style = []
            GridLines = True
            IconOptions.Arrangement = iaLeft
            ReadOnly = True
            RowSelect = True
            ParentFont = False
            PopupMenu = PM_ArchiveTool
            ShowWorkAreas = True
            SmallImages = ImageList_Archiver
            TabOrder = 1
            ViewStyle = vsReport
            OnDblClick = LV_ArcFileListDblClick
          end
        end
        object TS_ArchiveSetup: TTabSheet
          Caption = 'Setup'
          ImageIndex = 1
          DesignSize = (
            633
            358)
          object GB_ArchiveSetup: TGroupBox
            Left = 0
            Top = 0
            Width = 633
            Height = 358
            Anchors = [akLeft, akTop, akRight, akBottom]
            Caption = ' Archive tool setup '
            TabOrder = 0
            DesignSize = (
              633
              358)
            object GB_ArchiveAndFileWriting: TGroupBox
              Left = 8
              Top = 192
              Width = 617
              Height = 152
              Anchors = [akLeft, akTop, akRight, akBottom]
              Caption = ' Archive and file writing '
              TabOrder = 0
              DesignSize = (
                617
                152)
              object GB_ArchiveAddingMethod: TGroupBox
                Left = 312
                Top = 16
                Width = 297
                Height = 121
                Anchors = [akLeft, akTop, akRight]
                Caption = ' Default adding files method '
                TabOrder = 0
                DesignSize = (
                  297
                  121)
                object RB_Arc_Files: TRadioButton
                  Left = 8
                  Top = 19
                  Width = 281
                  Height = 22
                  Anchors = [akLeft, akTop, akRight]
                  Caption = 'Get from files (2500 max)'
                  Checked = True
                  TabOrder = 0
                  TabStop = True
                  WordWrap = True
                end
                object RB_Arc_Directory: TRadioButton
                  Left = 8
                  Top = 45
                  Width = 281
                  Height = 20
                  Anchors = [akLeft, akTop, akRight]
                  Caption = 'Get from directory'
                  TabOrder = 1
                  WordWrap = True
                end
                object RB_Arc_List: TRadioButton
                  Left = 8
                  Top = 71
                  Width = 281
                  Height = 18
                  Anchors = [akLeft, akTop, akRight]
                  Caption = 'Get from list'
                  TabOrder = 2
                  WordWrap = True
                end
              end
              object GB_ArcFileOverwritingMode: TGroupBox
                Left = 8
                Top = 16
                Width = 297
                Height = 121
                Caption = ' File overwriting mode '
                TabOrder = 1
                DesignSize = (
                  297
                  121)
                object RB_ArcFileExtrOverwrite: TRadioButton
                  Left = 8
                  Top = 16
                  Width = 281
                  Height = 25
                  Anchors = [akLeft, akTop, akRight]
                  Caption = 'Overwrite existant'
                  Checked = True
                  TabOrder = 0
                  TabStop = True
                  WordWrap = True
                end
                object RB_ArcFileExtrRename: TRadioButton
                  Left = 8
                  Top = 40
                  Width = 281
                  Height = 25
                  Anchors = [akLeft, akTop, akRight]
                  Caption = 'Rename new file by adding index at the end'
                  TabOrder = 1
                  WordWrap = True
                end
                object RB_ArcFileExtrSkip: TRadioButton
                  Left = 8
                  Top = 64
                  Width = 281
                  Height = 25
                  Anchors = [akLeft, akTop, akRight]
                  Caption = 'Skip for existant files'
                  TabOrder = 2
                  WordWrap = True
                end
                object RB_ArcFileExtrAbort: TRadioButton
                  Left = 8
                  Top = 88
                  Width = 281
                  Height = 25
                  Anchors = [akLeft, akTop, akRight]
                  Caption = 'Abort extraction'
                  TabOrder = 3
                end
              end
            end
            object GB_ArchiveLoading: TGroupBox
              Left = 8
              Top = 16
              Width = 617
              Height = 89
              Anchors = [akLeft, akTop, akRight]
              Caption = ' Archive loading and saving '
              TabOrder = 1
              DesignSize = (
                617
                89)
              object CB_ArchiveListHumanReadable: TCheckBox
                Left = 8
                Top = 16
                Width = 601
                Height = 17
                Anchors = [akLeft, akTop, akRight]
                Caption = 'Show human-readable file sizes instead of hexadecimal values'
                TabOrder = 0
              end
              object CB_AllowArchiveOverwrite: TCheckBox
                Left = 8
                Top = 40
                Width = 601
                Height = 17
                Caption = 
                  'Allow overwriting (prevents some stupid people from killing orig' +
                  'inal archives)'
                Checked = True
                State = cbChecked
                TabOrder = 1
                WordWrap = True
                OnClick = CB_AllowArchiveOverwriteClick
              end
              object CB_RecursiveDirMode: TCheckBox
                Left = 8
                Top = 60
                Width = 601
                Height = 25
                Anchors = [akLeft, akTop, akRight]
                Caption = 
                  'Use recursive directory scanning mode (i.e. search for files in ' +
                  'subdirectories && store pathes if possible)'
                Checked = True
                State = cbChecked
                TabOrder = 2
                WordWrap = True
              end
            end
            object GB_ArchiveHiddenScan: TGroupBox
              Left = 8
              Top = 112
              Width = 617
              Height = 73
              Anchors = [akLeft, akTop, akRight]
              Caption = ' Hidden archive metadata scanning '
              TabOrder = 2
              DesignSize = (
                617
                73)
              object CB_HiddenDataAutoscanAsk: TCheckBox
                Left = 8
                Top = 40
                Width = 601
                Height = 25
                Anchors = [akLeft, akTop, akRight]
                Caption = 'Ask for user'#39's confirmation before performing the action'
                Checked = True
                State = cbChecked
                TabOrder = 0
                WordWrap = True
              end
              object CB_HiddenDataAutoscan: TCheckBox
                Left = 8
                Top = 16
                Width = 601
                Height = 25
                Anchors = [akLeft, akTop, akRight]
                Caption = 'Enable autoscan and recover on loading'
                TabOrder = 1
                WordWrap = True
              end
            end
          end
        end
        object TS_ArchiveFormats: TTabSheet
          Caption = 'Formats'
          ImageIndex = 2
          DesignSize = (
            633
            358)
          object LV_ArcFmt: TListView
            Left = 0
            Top = 6
            Width = 633
            Height = 352
            Anchors = [akLeft, akTop, akRight, akBottom]
            Columns = <
              item
                AutoSize = True
                Caption = 'ID'
                MaxWidth = 24
                MinWidth = 24
              end
              item
                Caption = 'Description'
                MinWidth = 256
                Width = 256
              end
              item
                AutoSize = True
                Caption = 'Ext'
                MaxWidth = 42
                MinWidth = 42
              end
              item
                Alignment = taCenter
                AutoSize = True
                Caption = 'Status'
                MaxWidth = 64
                MinWidth = 64
              end
              item
                Alignment = taCenter
                AutoSize = True
                Caption = 'FN Length'
                MaxWidth = 64
                MinWidth = 64
              end
              item
                Alignment = taCenter
                AutoSize = True
                Caption = 'Comptype'
                MaxWidth = 72
                MinWidth = 72
              end
              item
                Alignment = taCenter
                AutoSize = True
                Caption = 'Modified'
                MaxWidth = 78
                MinWidth = 78
              end>
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Pitch = fpFixed
            Font.Style = []
            GridLines = True
            ReadOnly = True
            RowSelect = True
            ParentFont = False
            TabOrder = 0
            ViewStyle = vsReport
            OnChange = LV_ArcFmtChange
          end
        end
      end
      object GB_ArchiveTool: TGroupBox
        Tag = -1
        Left = 0
        Top = 1
        Width = 641
        Height = 92
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        ParentColor = False
        TabOrder = 1
        DesignSize = (
          641
          92)
        object SB_CloseArchive: TSpeedButton
          Left = 533
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akTop, akRight]
          Caption = 'Close archive'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_CloseArchiveClick
        end
        object SB_ExtractAll: TSpeedButton
          Left = 215
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Extract all files'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_ExtractAllClick
        end
        object SB_ExtractFile: TSpeedButton
          Left = 109
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Extract selected'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_ExtractFileClick
        end
        object SB_OpenArchive: TSpeedButton
          Left = 3
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Open archive'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_OpenArchiveClick
        end
        object SB_CreateArchive: TJvArrowButton
          Left = 414
          Top = 7
          Width = 118
          Height = 83
          Anchors = [akTop, akRight]
          DropDown = PM_ArchiveToolCreate
          Caption = 'Create archive'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          FillFont.Charset = DEFAULT_CHARSET
          FillFont.Color = clWindowText
          FillFont.Height = -9
          FillFont.Name = 'Lucida Console'
          FillFont.Style = []
          Layout = blGlyphTop
          ParentFont = False
          OnClick = SB_CreateArchiveClick
        end
      end
      object CB_ArchiveFormatList: TComboBox
        Tag = -1
        Left = 280
        Top = 96
        Width = 361
        Height = 19
        Hint = 'Sets the output archive format'
        AutoDropDown = True
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 32
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ItemHeight = 11
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnChange = CB_ArchiveFormatListChange
      end
    end
    object TS_Audio: TTabSheet
      Caption = 'Audio Tool'
      ImageIndex = 1
      DesignSize = (
        641
        482)
      object GB_AudioStream_Setup: TGroupBox
        Left = 4
        Top = 96
        Width = 633
        Height = 385
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = ' Direct audio converter setup '
        TabOrder = 0
        DesignSize = (
          633
          385)
        object L_AudioStreamConvSel: TLabelW
          Left = 8
          Top = 16
          Width = 617
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Select the conversion chain you want to perform:'
        end
        object L_AudioStream_InputDir: TLabelW
          Left = 8
          Top = 64
          Width = 617
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Input directory:'
          Enabled = False
          Visible = False
        end
        object L_AudioStream_OutputDir: TLabelW
          Left = 8
          Top = 104
          Width = 617
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Output directory:'
          Enabled = False
          Visible = False
        end
        object CB_AudioStream_FormatSelector: TComboBox
          Left = 8
          Top = 32
          Width = 617
          Height = 19
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          Enabled = False
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          ItemHeight = 11
          ItemIndex = 0
          ParentFont = False
          TabOrder = 0
          Text = 'KID Engine WAF MSADPCM <-> RIFF Wave MSADPCM'
          Items.Strings = (
            'KID Engine WAF MSADPCM <-> RIFF Wave MSADPCM')
        end
        object E_AudioStream_InputDir: TEdit
          Left = 8
          Top = 80
          Width = 593
          Height = 19
          Anchors = [akLeft, akTop, akRight]
          Enabled = False
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          Text = 'E_AudioStream_InputDir'
          Visible = False
        end
        object B_AudioStream_InputDir: TButton
          Left = 600
          Top = 80
          Width = 25
          Height = 20
          Anchors = [akTop, akRight]
          Caption = '...'
          Enabled = False
          TabOrder = 2
          Visible = False
        end
        object E_AudioStream_OutputDir: TEdit
          Left = 8
          Top = 120
          Width = 593
          Height = 19
          Anchors = [akLeft, akTop, akRight]
          Enabled = False
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          Text = 'E_AudioStream_OutputDir'
          Visible = False
        end
        object B_AudioStream_OutputDir: TButton
          Left = 600
          Top = 120
          Width = 25
          Height = 20
          Anchors = [akTop, akRight]
          Caption = '...'
          Enabled = False
          TabOrder = 4
          Visible = False
        end
      end
      object GB_AudioTool: TGroupBox
        Tag = -1
        Left = 0
        Top = 1
        Width = 641
        Height = 92
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        ParentColor = False
        TabOrder = 1
        DesignSize = (
          641
          92)
        object SB_Audio_Open: TSpeedButton
          Left = 3
          Top = 7
          Width = 105
          Height = 83
          AllowAllUp = True
          Anchors = [akLeft, akTop, akBottom]
          BiDiMode = bdLeftToRight
          Caption = 'Open audio file'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ParentBiDiMode = False
          ShowHint = True
          OnClick = SB_Audio_OpenClick
        end
        object SB_Audio_Encode: TSpeedButton
          Left = 109
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Convert file to...'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_Audio_EncodeClick
        end
        object SB_Audio_Batch: TSpeedButton
          Left = 533
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akTop, akRight, akBottom]
          Caption = 'Batch conversion'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_Audio_BatchClick
        end
      end
    end
    object TS_Image: TTabSheet
      Caption = 'Image Tool'
      ImageIndex = 2
      OnShow = TS_ImageShow
      DesignSize = (
        641
        482)
      object PageControl_EDGE: TPageControl
        Left = 0
        Top = 96
        Width = 641
        Height = 389
        ActivePage = TS_EDGE
        Anchors = [akLeft, akTop, akRight, akBottom]
        Style = tsButtons
        TabOrder = 0
        object TS_EDGE: TTabSheet
          Caption = 'Info && Preview'
          DesignSize = (
            633
            358)
          object GB_ImageOperations: TGroupBox
            Left = 0
            Top = 248
            Width = 435
            Height = 43
            Anchors = [akLeft, akRight, akBottom]
            Caption = ' Operations '
            TabOrder = 0
            DesignSize = (
              435
              43)
            object TB_ImageTool_Image: TToolBar
              Left = 8
              Top = 15
              Width = 425
              Height = 26
              Align = alNone
              Anchors = [akLeft, akTop, akRight]
              EdgeBorders = []
              Flat = True
              Images = ImageList_EDGE
              TabOrder = 0
              Transparent = False
              object TB_EDGE_Flip: TToolButton
                Left = 0
                Top = 0
                Hint = 'Flip image'
                Caption = 'Flip'
                ImageIndex = 25
                OnClick = TB_EDGE_FlipClick
              end
              object ToolButton5: TToolButton
                Tag = -1
                Left = 23
                Top = 0
                Width = 8
                Caption = 'ToolButton5'
                ImageIndex = 22
                Style = tbsSeparator
              end
              object TB_EDGE_Negative: TToolButton
                Left = 31
                Top = 0
                Hint = 'Invert colours of current image'
                Caption = 'Negative'
                ImageIndex = 26
                OnClick = TB_EDGE_NegativeClick
              end
              object ToolButton2: TToolButton
                Tag = -1
                Left = 54
                Top = 0
                Width = 8
                Caption = 'ToolButton2'
                ImageIndex = 18
                Style = tbsSeparator
              end
              object TB_EDGE_ColorSwap: TToolButton
                Left = 62
                Top = 0
                Hint = 'Swap colour channels via selected method...'
                Caption = 'Colour swap'
                DropdownMenu = PM_ColorSwap
                ImageIndex = 0
                Style = tbsDropDown
                OnClick = TB_EDGE_ColorSwapClick
              end
              object TB_EDGE_Grayscale: TToolButton
                Left = 98
                Top = 0
                Hint = 'Convert image to grayscale via selected method...'
                Caption = 'Grayscale'
                DropdownMenu = PM_GrayScale
                ImageIndex = 24
                Style = tbsDropDown
                OnClick = TB_EDGE_GrayscaleClick
              end
              object ToolButton3: TToolButton
                Tag = -1
                Left = 134
                Top = 0
                Width = 8
                Caption = 'ToolButton3'
                ImageIndex = 18
                Style = tbsSeparator
              end
              object TB_EDGE_SubAlpha_Append: TToolButton
                Left = 142
                Top = 0
                Hint = 'Append sub-alpha from alpha space (4th colour channel)'
                Caption = 'Add sub-alpha'
                DropdownMenu = PM_SUBAlpha_Append
                ImageIndex = 19
                Style = tbsDropDown
                OnClick = M_EDGE_SUBAlpha_Append_RightClick
              end
              object TB_EDGE_SubAlpha_Extract: TToolButton
                Left = 178
                Top = 0
                Hint = 'Move sub-alpha into alpha space (4th colour channel)'
                Caption = 'Move sub-alpha'
                DropdownMenu = PM_SUBAlpha_Extract
                ImageIndex = 22
                Style = tbsDropDown
                OnClick = M_EDGE_SUBAlpha_Extract_RightClick
              end
              object TB_EDGE_SubAlpha_Destroy: TToolButton
                Left = 214
                Top = 0
                Hint = 'Delete sub-alpha from the current image'
                Caption = 'Delete sub-alpha'
                DropdownMenu = PM_SUBAlpha_Destroy
                ImageIndex = 20
                Style = tbsDropDown
                OnClick = M_EDGE_SUBAlpha_Destroy_RightClick
              end
              object ToolButton1: TToolButton
                Tag = -1
                Left = 250
                Top = 0
                Width = 8
                Caption = 'ToolButton1'
                ImageIndex = 18
                Style = tbsSeparator
              end
              object TB_EDGE_Alpha_Flip: TToolButton
                Left = 258
                Top = 0
                Hint = 'Flip alpha channel image'
                Caption = 'Flip alpha'
                ImageIndex = 17
                OnClick = TB_EDGE_Alpha_FlipClick
              end
              object ToolButton6: TToolButton
                Tag = -1
                Left = 281
                Top = 0
                Width = 8
                Caption = 'ToolButton6'
                ImageIndex = 22
                Style = tbsSeparator
              end
              object TB_EDGE_NegativeAlpha: TToolButton
                Left = 289
                Top = 0
                Hint = 'Invert colours of current image'#39's alpha'
                Caption = 'Negative alpha'
                ImageIndex = 18
                OnClick = TB_EDGE_NegativeAlphaClick
              end
              object ToolButton4: TToolButton
                Tag = -1
                Left = 312
                Top = 0
                Width = 8
                Caption = 'ToolButton4'
                ImageIndex = 22
                Style = tbsSeparator
              end
              object TB_EDGE_Alpha_Append: TToolButton
                Left = 320
                Top = 0
                Hint = 'Import alpha channel from grayscale image'
                Caption = 'Import alpha'
                ImageIndex = 14
                OnClick = TB_EDGE_Alpha_AppendClick
              end
              object TB_EDGE_Alpha_Extract: TToolButton
                Left = 343
                Top = 0
                Hint = 'Save alpha channel as grayscale image'
                Caption = 'Save alpha'
                ImageIndex = 15
                OnClick = TB_EDGE_Alpha_ExtractClick
              end
              object TB_EDGE_Alpha_Destroy: TToolButton
                Left = 366
                Top = 0
                Hint = 'Delete alpha channel from the current image'
                Caption = 'Delete alpha'
                ImageIndex = 16
                OnClick = TB_EDGE_Alpha_DestroyClick
              end
              object ToolButton7: TToolButton
                Tag = -1
                Left = 389
                Top = 0
                Width = 8
                Caption = 'ToolButton7'
                ImageIndex = 22
                Style = tbsSeparator
              end
              object TB_EDGE_Alpha_Generate: TToolButton
                Left = 397
                Top = 0
                Hint = 'Generate grayscale alpha image by comparing two pictures'
                Caption = 'Generate alpha'
                ImageIndex = 21
                OnClick = TB_EDGE_Alpha_GenerateClick
              end
            end
          end
          object GB_ImagePreview: TGroupBox
            Left = 0
            Top = 0
            Width = 633
            Height = 247
            Anchors = [akLeft, akTop, akRight, akBottom]
            Caption = ' Preview (double-click spawns the preview window) '
            TabOrder = 1
            DesignSize = (
              633
              247)
            object I_EDGE_ImageA: TImage
              Tag = -1
              Left = 318
              Top = 32
              Width = 310
              Height = 210
              Anchors = [akTop, akRight, akBottom]
              Center = True
              IncrementalDisplay = True
              Proportional = True
              Stretch = True
              OnDblClick = I_EDGE_ImageADblClick
            end
            object I_EDGE_Image: TImage
              Tag = -1
              Left = 3
              Top = 32
              Width = 310
              Height = 210
              Anchors = [akLeft, akTop, akBottom]
              Center = True
              IncrementalDisplay = True
              Proportional = True
              Stretch = True
              OnDblClick = I_EDGE_ImageADblClick
            end
            object L_Image_Original: TLabelW
              Left = 8
              Top = 15
              Width = 97
              Height = 17
              AutoSize = False
              Caption = 'Image:'
              Transparent = True
            end
            object L_Image_Alpha: TLabelW
              Left = 528
              Top = 15
              Width = 97
              Height = 17
              Alignment = taRightJustify
              Anchors = [akTop, akRight]
              AutoSize = False
              Caption = 'Alpha:'
              Transparent = True
            end
            object Bevel_Images: TBevel
              Left = 315
              Top = 6
              Width = 2
              Height = 240
              Anchors = [akTop, akBottom]
              Shape = bsLeftLine
            end
          end
          object GB_ImageInfo: TGroupBox
            Left = 0
            Top = 293
            Width = 633
            Height = 65
            Anchors = [akLeft, akRight, akBottom]
            Caption = ' Current file info '
            TabOrder = 2
            DesignSize = (
              633
              65)
            object L_ImageFileNameTitle: TLabelW
              Left = 8
              Top = 13
              Width = 81
              Height = 15
              Alignment = taRightJustify
              AutoSize = False
              Caption = 'File name:'
              Transparent = True
            end
            object L_ImageSizeTitle: TLabelW
              Left = 404
              Top = 32
              Width = 81
              Height = 15
              Alignment = taRightJustify
              Anchors = [akTop, akRight]
              AutoSize = False
              Caption = 'File size:'
              Transparent = True
            end
            object L_ImageSize: TLabelW
              Tag = -1
              Left = 488
              Top = 32
              Width = 139
              Height = 15
              Alignment = taRightJustify
              Anchors = [akTop, akRight]
              AutoSize = False
              Caption = '0 bytes'
              Transparent = True
            end
            object L_ImageFormat: TLabelW
              Tag = -1
              Left = 96
              Top = 40
              Width = 297
              Height = 15
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'unknown format'
              Transparent = True
            end
            object L_ImageFormatTitle: TLabelW
              Left = 8
              Top = 40
              Width = 81
              Height = 15
              Alignment = taRightJustify
              AutoSize = False
              Caption = 'Format:'
              Transparent = True
            end
            object L_ImageResolution: TLabelW
              Tag = -1
              Left = 408
              Top = 48
              Width = 219
              Height = 15
              Alignment = taRightJustify
              Anchors = [akTop, akRight]
              AutoSize = False
              Caption = '0x0 0 bits'
              Transparent = True
            end
            object Bevel6: TBevel
              Tag = -1
              Left = 1
              Top = 29
              Width = 630
              Height = 2
              Anchors = [akLeft, akTop, akRight]
              Shape = bsTopLine
            end
            object Bevel3: TBevel
              Left = 400
              Top = 30
              Width = 2
              Height = 33
              Anchors = [akRight, akBottom]
              Shape = bsLeftLine
            end
            object E_ImageFileName: TEdit
              Left = 96
              Top = 13
              Width = 529
              Height = 15
              Anchors = [akLeft, akTop, akRight]
              BorderStyle = bsNone
              Color = clBtnFace
              Font.Charset = SHIFTJIS_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Tahoma'
              Font.Pitch = fpFixed
              Font.Style = []
              ParentFont = False
              ReadOnly = True
              TabOrder = 0
              Text = '---'
            end
          end
          object GB_PreviewColor: TGroupBox
            Left = 440
            Top = 248
            Width = 193
            Height = 43
            Anchors = [akRight, akBottom]
            Caption = ' Preview background colour '
            TabOrder = 3
            DesignSize = (
              193
              43)
            object SB_EDGE_JPHTML: TSpeedButton
              Left = 8
              Top = 15
              Width = 22
              Height = 22
              Hint = 'Generate HTML version of the Japanese Colour Palette Table'
              Flat = True
              Glyph.Data = {
                E6010000424DE60100000000000036000000280000000C0000000C0000000100
                180000000000B0010000130B0000130B00000000000000000000FF08FF6F0808
                6F08086F08086F08086F08086F08086F08086F08086F08086F0808FF08FFB108
                08CC7240CA7140C87040C56F40C26D40BF6C40BD6A40BA6940B76840B566406F
                0808B10808CE7340CC7240CA7140C87040C56F40C26D40BF6C40BD6A40BA6940
                B768406F0808B10808D07440CE7340CC7240CA7140C87040C56F40C26D40BF6C
                40BD6A40BA69406F0808B10808D27540D07440CE7340CC7240CA7140C87040C5
                6F40C26D40BF6C40BD6A406F0808B10808D47640D27540D07440CE7340CC7240
                CA7140C87040C56F40C26D40BF6C406F0808B10808D67740F3F1EDECEAE6E5E2
                DEDEDBD7D7D4D0CFCCC8C5C2BEBFBCB7C26D406F0808B10808D97940F3F1EDEC
                EAE6E5E2DEE0DEDA6A3C006A3C00CCC9C5C5C2BEC56F406F0808B10808DB7A40
                F5F3EFEEECE8EAE7E3E3E0DC9F5A009F5A00D2CFCBCFCCC8C870406F0808B108
                08DE7B40F8F6F2F3F1EDECEAE6E7E5E1D47800D47800D9D6D2D7D4D0CA71406F
                0808B10808E07C40F8F6F2F5F3EFF1EFEBECEAE6E7E5E1E3E0DCE0DEDADEDBD7
                CC72406F0808FF08FFB10808B10808B10808B10808B10808B10808B10808B108
                08B10808B10808FF08FF}
              Layout = blGlyphTop
              ParentShowHint = False
              ShowHint = True
              OnClick = SB_EDGE_JPHTMLClick
            end
            object CB_EDGE_PreviewColor: TColorBox
              Left = 35
              Top = 15
              Width = 150
              Height = 22
              NoneColorColor = clWindow
              Selected = clCream
              Style = [cbIncludeDefault, cbCustomColor, cbPrettyNames]
              Anchors = [akLeft, akTop, akRight]
              BiDiMode = bdLeftToRight
              DropDownCount = 16
              ItemHeight = 16
              ParentBiDiMode = False
              TabOrder = 0
            end
          end
        end
        object TS_EDGE_Setup: TTabSheet
          Caption = 'Setup'
          ImageIndex = 1
          DesignSize = (
            633
            358)
          object GB_ImageSetup: TGroupBox
            Left = 0
            Top = 0
            Width = 633
            Height = 358
            Anchors = [akLeft, akTop, akRight, akBottom]
            Caption = ' Image tool setup '
            TabOrder = 0
            DesignSize = (
              633
              358)
            object PC_ImageToolSetup: TPageControl
              Left = 8
              Top = 16
              Width = 617
              Height = 336
              ActivePage = TS_EDGE_All
              Anchors = [akLeft, akTop, akRight, akBottom]
              Style = tsButtons
              TabOrder = 0
              object TS_EDGE_All: TTabSheet
                Caption = 'All'
                DesignSize = (
                  609
                  305)
                object GB_EDGE_General: TGroupBox
                  Left = 0
                  Top = 0
                  Width = 609
                  Height = 89
                  Anchors = [akLeft, akTop, akRight]
                  Caption = ' General '
                  TabOrder = 0
                  object CB_ALL_ProcessAlpha: TCheckBox
                    Left = 8
                    Top = 17
                    Width = 593
                    Height = 17
                    Caption = 'Process alpha image data (enable alpha loading && saving)'
                    Checked = True
                    State = cbChecked
                    TabOrder = 0
                    WordWrap = True
                  end
                  object CB_All_LoadSepAlpha: TCheckBox
                    Left = 8
                    Top = 42
                    Width = 593
                    Height = 15
                    Caption = 
                      'Load alpha from supplied bmp files (i.e. "file.jpg + filea.bmp" ' +
                      'combos)'
                    Checked = True
                    State = cbChecked
                    TabOrder = 1
                    WordWrap = True
                  end
                  object CB_EDGE_InvertAlpha: TCheckBox
                    Left = 8
                    Top = 67
                    Width = 593
                    Height = 15
                    Caption = 'Handle SUBalpha as inverted image (varies from game to game)'
                    TabOrder = 2
                    WordWrap = True
                  end
                end
                object GB_EDGE_GrayScale: TGroupBox
                  Left = 0
                  Top = 96
                  Width = 609
                  Height = 47
                  Anchors = [akLeft, akTop, akRight]
                  Caption = ' Default grayscaling method '
                  TabOrder = 1
                  DesignSize = (
                    609
                    47)
                  object I_EDGE_GrayScale: TImage
                    Left = 9
                    Top = 18
                    Width = 16
                    Height = 16
                  end
                  object CB_EDGE_GrayScaleMode: TComboBox
                    Left = 32
                    Top = 16
                    Width = 569
                    Height = 21
                    Style = csDropDownList
                    Anchors = [akLeft, akTop, akRight]
                    ItemHeight = 13
                    ItemIndex = 0
                    TabOrder = 0
                    Text = 'Arithmetic Mean'
                    OnChange = CB_EDGE_GrayScaleModeChange
                    Items.Strings = (
                      'Arithmetic Mean'
                      'Classic Luma'
                      'HDR \ Luma (More natural)'
                      'Red channel only'
                      'Green channel only'
                      'Blue channel only')
                  end
                end
                object GB_EDGE_ColourSwap: TGroupBox
                  Left = 0
                  Top = 147
                  Width = 609
                  Height = 47
                  Anchors = [akLeft, akTop, akRight]
                  Caption = ' Default colour swapping method '
                  TabOrder = 2
                  DesignSize = (
                    609
                    47)
                  object I_EDGE_ColourSwap: TImage
                    Left = 9
                    Top = 18
                    Width = 16
                    Height = 16
                  end
                  object CB_EDGE_ColourSwapMode: TComboBox
                    Left = 32
                    Top = 16
                    Width = 569
                    Height = 21
                    Style = csDropDownList
                    Anchors = [akLeft, akTop, akRight]
                    ItemHeight = 13
                    ItemIndex = 0
                    TabOrder = 0
                    Text = 'RGB -> BGR'
                    OnChange = CB_EDGE_ColourSwapModeChange
                    Items.Strings = (
                      'RGB -> BGR'
                      'RGB -> BRG'
                      'RGB -> GBR'
                      'RGB -> GRB'
                      'RGB -> RBG')
                  end
                end
                object GB_EDGE_PNG_JPEG: TGroupBox
                  Left = 0
                  Top = 200
                  Width = 609
                  Height = 89
                  Anchors = [akLeft, akTop, akRight]
                  Caption = ' PNG && JPEG '
                  TabOrder = 3
                  DesignSize = (
                    609
                    89)
                  object L_JPEG_Quality: TLabelW
                    Left = 8
                    Top = 40
                    Width = 457
                    Height = 17
                    Alignment = taRightJustify
                    Anchors = [akLeft, akTop, akRight]
                    AutoSize = False
                    Caption = 'JPEG saving quality (1 - bad quality, 100 - big filesize):'
                  end
                  object L_PNG_Compression: TLabelW
                    Left = 8
                    Top = 64
                    Width = 457
                    Height = 17
                    Alignment = taRightJustify
                    Anchors = [akLeft, akTop, akRight]
                    AutoSize = False
                    Caption = 'PNG saving compression ratio (0 - no compression, 9 - maximum):'
                  end
                  object E_JPEG_Quality: TEdit
                    Left = 472
                    Top = 37
                    Width = 41
                    Height = 20
                    Anchors = [akTop, akRight]
                    AutoSize = False
                    ReadOnly = True
                    TabOrder = 0
                    Text = '100'
                  end
                  object UD_JPEG_Quality: TUpDown
                    Left = 513
                    Top = 37
                    Width = 12
                    Height = 20
                    Anchors = [akTop, akRight]
                    Associate = E_JPEG_Quality
                    Min = 1
                    Position = 100
                    TabOrder = 1
                    Thousands = False
                  end
                  object E_PNG_Compression: TEdit
                    Left = 472
                    Top = 61
                    Width = 41
                    Height = 20
                    Anchors = [akTop, akRight]
                    AutoSize = False
                    ReadOnly = True
                    TabOrder = 2
                    Text = '5'
                  end
                  object UD_PNG_Compression: TUpDown
                    Left = 513
                    Top = 61
                    Width = 12
                    Height = 20
                    Anchors = [akTop, akRight]
                    Associate = E_PNG_Compression
                    Max = 9
                    Position = 5
                    TabOrder = 3
                    Thousands = False
                  end
                  object CB_JPEGProgressive: TCheckBox
                    Left = 8
                    Top = 17
                    Width = 593
                    Height = 17
                    Anchors = [akLeft, akTop, akRight]
                    Caption = 'Save progressive JPEG files (useful for web pages)'
                    TabOrder = 4
                  end
                  object B_EDGE_JPEG_Reset: TButton
                    Left = 528
                    Top = 37
                    Width = 73
                    Height = 20
                    Anchors = [akTop, akRight]
                    Caption = 'Reset'
                    TabOrder = 5
                    OnClick = B_EDGE_JPEG_ResetClick
                  end
                  object B_EDGE_PNG_Reset: TButton
                    Left = 528
                    Top = 61
                    Width = 73
                    Height = 20
                    Anchors = [akTop, akRight]
                    Caption = 'Reset'
                    TabOrder = 6
                    OnClick = B_EDGE_PNG_ResetClick
                  end
                end
              end
              object TS_EDGE_PRT: TTabSheet
                Caption = 'PRT'
                ImageIndex = 2
                DesignSize = (
                  609
                  305)
                object CB_PRT_Coords: TCheckBox
                  Left = 0
                  Top = 5
                  Width = 609
                  Height = 25
                  Anchors = [akLeft, akTop, akRight]
                  Caption = 
                    'Load and save PRT XY rendering coordinates as ini files along wi' +
                    'th image files'
                  Checked = True
                  State = cbChecked
                  TabOrder = 0
                  WordWrap = True
                end
                object GB_EDGE_Coordinate_Editor: TGroupBox
                  Left = 0
                  Top = 31
                  Width = 609
                  Height = 90
                  Anchors = [akLeft, akTop, akRight]
                  Caption = ' PRT Coordinate Editor '
                  TabOrder = 1
                  object L_EDGE_X: TLabelW
                    Tag = -1
                    Left = 8
                    Top = 40
                    Width = 25
                    Height = 13
                    Alignment = taRightJustify
                    AutoSize = False
                    Caption = 'X :'
                    Enabled = False
                  end
                  object L_EDGE_Y: TLabelW
                    Tag = -1
                    Left = 8
                    Top = 64
                    Width = 25
                    Height = 13
                    Alignment = taRightJustify
                    AutoSize = False
                    Caption = 'Y :'
                    Enabled = False
                  end
                  object L_EDGE_RenderWidth: TLabelW
                    Tag = -1
                    Left = 76
                    Top = 40
                    Width = 75
                    Height = 13
                    Alignment = taRightJustify
                    AutoSize = False
                    Caption = 'RenderWidth :'
                    Enabled = False
                  end
                  object L_EDGE_RenderHeight: TLabelW
                    Tag = -1
                    Left = 76
                    Top = 64
                    Width = 75
                    Height = 13
                    Alignment = taRightJustify
                    AutoSize = False
                    Caption = 'RenderHeight :'
                    Enabled = False
                  end
                  object E_EDGE_X: TEdit
                    Tag = -1
                    Left = 36
                    Top = 37
                    Width = 37
                    Height = 21
                    Enabled = False
                    TabOrder = 0
                    Text = '0'
                    OnChange = E_EDGE_XChange
                  end
                  object E_EDGE_Y: TEdit
                    Tag = -1
                    Left = 36
                    Top = 61
                    Width = 37
                    Height = 21
                    Enabled = False
                    TabOrder = 1
                    Text = '0'
                    OnChange = E_EDGE_YChange
                  end
                  object E_EDGE_RenderWidth: TEdit
                    Tag = -1
                    Left = 156
                    Top = 37
                    Width = 37
                    Height = 21
                    Enabled = False
                    TabOrder = 2
                    Text = '0'
                    OnChange = E_EDGE_RenderWidthChange
                  end
                  object E_EDGE_RenderHeight: TEdit
                    Tag = -1
                    Left = 156
                    Top = 61
                    Width = 37
                    Height = 21
                    Enabled = False
                    TabOrder = 3
                    Text = '0'
                    OnChange = E_EDGE_RenderHeightChange
                  end
                  object CB_PRT_Editor_Enable: TCheckBox
                    Left = 9
                    Top = 16
                    Width = 184
                    Height = 17
                    BiDiMode = bdLeftToRight
                    Caption = 'Allow editing'
                    ParentBiDiMode = False
                    TabOrder = 4
                    OnClick = CB_PRT_Editor_EnableClick
                  end
                end
              end
            end
          end
        end
      end
      object GB_ImageTool: TGroupBox
        Tag = -1
        Left = 0
        Top = 1
        Width = 641
        Height = 92
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        ParentColor = False
        TabOrder = 1
        DesignSize = (
          641
          92)
        object SB_EDGE_Picture_Open: TSpeedButton
          Left = 3
          Top = 7
          Width = 105
          Height = 83
          AllowAllUp = True
          Anchors = [akLeft, akTop, akBottom]
          BiDiMode = bdLeftToRight
          Caption = 'Open picture file'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ParentBiDiMode = False
          ShowHint = True
          OnClick = SB_EDGE_Picture_OpenClick
        end
        object SB_EDGE_Picture_Save: TSpeedButton
          Left = 109
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Save picture...'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_EDGE_Picture_SaveClick
        end
        object SB_EDGE_Picture_SaveWOAlpha: TSpeedButton
          Left = 215
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Save w/o alpha...'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_EDGE_Picture_SaveWOAlphaClick
        end
        object SB_EDGE_Picture_SaveAlpha: TSpeedButton
          Left = 321
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Save alpha...'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_EDGE_Picture_SaveAlphaClick
        end
        object SB_Image_Batch: TSpeedButton
          Left = 427
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akTop, akRight, akBottom]
          Caption = 'Batch conversion'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_Image_BatchClick
        end
        object SB_Image_GrapS: TSpeedButton
          Left = 533
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akTop, akRight, akBottom]
          Caption = 'GrapS - RAW reader'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_Image_GrapSClick
        end
      end
      object CB_ImageFormat: TComboBox
        Tag = -1
        Left = 280
        Top = 96
        Width = 361
        Height = 19
        Hint = 'Sets the output image format'
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 256
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ItemHeight = 11
        ParentFont = False
        TabOrder = 2
        OnChange = CB_ImageFormatChange
      end
    end
    object TS_Script: TTabSheet
      Caption = 'Script Tool'
      ImageIndex = 8
      DesignSize = (
        641
        482)
      object GB_ScriptRecompiler: TGroupBox
        Tag = -1
        Left = 0
        Top = 1
        Width = 641
        Height = 92
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        DesignSize = (
          641
          92)
        object SB_SR_Open: TSpeedButton
          Left = 3
          Top = 7
          Width = 105
          Height = 83
          AllowAllUp = True
          Anchors = [akLeft, akTop, akBottom]
          BiDiMode = bdLeftToRight
          Caption = 'Open script file'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ParentBiDiMode = False
          ShowHint = True
        end
        object SB_SR_Decompile: TSpeedButton
          Left = 109
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Save decompiled'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
        end
        object SB_SR_BatchCompile: TSpeedButton
          Left = 533
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akTop, akRight, akBottom]
          Caption = 'Batch compile'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
        end
        object SB_SR_Compile: TSpeedButton
          Left = 427
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akTop, akRight, akBottom]
          Caption = 'Compile'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
        end
        object SB_SR_BatchDecompile: TSpeedButton
          Left = 215
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akTop, akRight, akBottom]
          Caption = 'Batch decompile'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
        end
      end
      object CB_SR_ScriptFormat: TComboBox
        Tag = -1
        Left = 280
        Top = 96
        Width = 361
        Height = 19
        Hint = 'Sets the output script format'
        AutoDropDown = True
        Style = csDropDownList
        Anchors = [akTop, akRight]
        DropDownCount = 32
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ItemHeight = 11
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
      end
      object ListBox1: TListBox
        Left = 0
        Top = 120
        Width = 641
        Height = 360
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 2
      end
    end
    object TS_Data: TTabSheet
      Caption = 'Data Tool'
      ImageIndex = 7
      DesignSize = (
        641
        482)
      object GB_DataConv: TGroupBox
        Left = 0
        Top = 96
        Width = 641
        Height = 384
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = ' Data converter options '
        TabOrder = 0
        DesignSize = (
          641
          384)
        object L_DataConv_Mode: TLabelW
          Left = 8
          Top = 16
          Width = 441
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Mode selection:'
        end
        object L_DataConv_Parameter: TLabelW
          Left = 456
          Top = 16
          Width = 73
          Height = 17
          Anchors = [akTop, akRight]
          AutoSize = False
          Caption = 'Parameter:'
        end
        object L_DataConv_KeyFile: TLabel
          Left = 8
          Top = 62
          Width = 81
          Height = 20
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Key file:'
        end
        object B_DataConv_Keyfile: TButton
          Left = 504
          Top = 59
          Width = 25
          Height = 21
          Hint = 'Hit this to select any "key" file'
          Anchors = [akTop, akRight]
          Caption = '...'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnClick = B_DataConv_KeyfileClick
        end
        object GB_DataConv_Value: TGroupBox
          Left = 536
          Top = 11
          Width = 97
          Height = 69
          Anchors = [akTop, akRight]
          Caption = ' Value '
          Color = clBtnFace
          ParentColor = False
          TabOrder = 1
          object L_VI_8: TLabelW
            Tag = -1
            Left = 8
            Top = 32
            Width = 49
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = '8 bit (+):'
          end
          object L_VI_8Z: TLabelW
            Tag = -1
            Left = 8
            Top = 48
            Width = 49
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = '8 bit (+/-):'
          end
          object L_VI_HEX: TLabelW
            Tag = -1
            Left = 8
            Top = 16
            Width = 49
            Height = 13
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'HEX:'
          end
          object L_VI_8Value: TLabelW
            Tag = -1
            Left = 64
            Top = 32
            Width = 25
            Height = 13
            AutoSize = False
            Caption = '255'
          end
          object L_VI_8ZValue: TLabelW
            Tag = -1
            Left = 64
            Top = 48
            Width = 25
            Height = 13
            AutoSize = False
            Caption = '-1'
          end
          object L_VI_HEXValue: TLabelW
            Tag = -1
            Left = 64
            Top = 16
            Width = 25
            Height = 13
            AutoSize = False
            Caption = 'FF'
          end
        end
        object UD_DataConv_Value: TUpDown
          Tag = -1
          Left = 513
          Top = 32
          Width = 16
          Height = 21
          Anchors = [akTop, akRight]
          Associate = E_DataConv_Value
          Max = 255
          TabOrder = 2
          Thousands = False
        end
        object E_DataConv_Value: TEdit
          Tag = -1
          Left = 456
          Top = 32
          Width = 57
          Height = 21
          Anchors = [akTop, akRight]
          MaxLength = 3
          TabOrder = 3
          Text = '0'
          OnChange = E_DataConv_ValueChange
        end
        object CB_DataConv_Mode: TComboBox
          Left = 8
          Top = 32
          Width = 441
          Height = 21
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          DropDownCount = 16
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 4
          Text = 'NOT (X = X XOR $FF)'
          Items.Strings = (
            'NOT (X = X XOR $FF)'
            'XOR'
            'AND'
            'OR'
            'SHL'
            'SHR'
            'X = 256 - X'
            'Cyclic SHL 4'
            'Cyclic SHR 4'
            'Key file crypt'
            'Zlib decompression')
        end
        object E_DataConv_Keyfile: TEdit
          Tag = -1
          Left = 96
          Top = 59
          Width = 409
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 5
        end
      end
      object GB_MiscTool: TGroupBox
        Tag = -1
        Left = 0
        Top = 1
        Width = 641
        Height = 92
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        ParentColor = False
        TabOrder = 1
        DesignSize = (
          641
          92)
        object SB_Data_Bruteforce: TSpeedButton
          Left = 109
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Bruteforce bytes'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_Data_BruteforceClick
        end
        object SB_Data_Process: TSpeedButton
          Left = 3
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Process data'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_Data_ProcessClick
        end
        object SB_Data_Batch: TSpeedButton
          Left = 215
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Batch processing'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_Data_BatchClick
        end
      end
    end
    object TS_E17_SCR: TTabSheet
      Caption = 'E17 SCR Tool'
      ImageIndex = 3
      DesignSize = (
        641
        482)
      object L_SCRTextSections: TLabelW
        Left = 0
        Top = 96
        Width = 329
        Height = 17
        AutoSize = False
        Caption = 'Decompiled text sections:'
      end
      object L_SCR_12345: TLabelW
        Tag = -2
        Left = 3
        Top = 112
        Width = 336
        Height = 11
        Caption = '123456789012345678901234567890123456789012345678'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
      end
      object L_Warn_E17: TLabelW
        Left = 368
        Top = 416
        Width = 273
        Height = 49
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = 
          'Please note: this tool was created for Ever17 only and cannot ha' +
          'ndle any other script formats.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
      object GB_SCRSetup: TGroupBox
        Left = 368
        Top = 96
        Width = 273
        Height = 193
        Anchors = [akTop, akRight]
        Caption = ' Setup '
        TabOrder = 0
        object GB_SCRImport: TGroupBox
          Left = 8
          Top = 16
          Width = 257
          Height = 97
          Caption = ' Import '
          TabOrder = 0
          object CB_SCRSaveDir: TCheckBox
            Left = 8
            Top = 40
            Width = 241
            Height = 25
            Caption = 'Save copy into directory:'
            Checked = True
            State = cbChecked
            TabOrder = 0
            WordWrap = True
          end
          object E_SCRDirectory: TEdit
            Tag = -1
            Left = 8
            Top = 72
            Width = 241
            Height = 21
            TabOrder = 1
            Text = 'G:\Desktop\For Test'
          end
          object CB_SCRAutoimport: TCheckBox
            Left = 8
            Top = 16
            Width = 241
            Height = 25
            Caption = 'Automatically import on loading'
            Checked = True
            State = cbChecked
            TabOrder = 2
            WordWrap = True
          end
        end
        object GB_SC3: TGroupBox
          Left = 8
          Top = 120
          Width = 257
          Height = 65
          Caption = ' KID Engine SC3 Decompilation '
          TabOrder = 1
          object RB_SC3_Strip: TRadioButton
            Left = 8
            Top = 16
            Width = 241
            Height = 17
            Caption = 'Decode and strip all opcodes (readable text)'
            Checked = True
            TabOrder = 0
            TabStop = True
          end
          object RB_SC3_Keep: TRadioButton
            Left = 8
            Top = 40
            Width = 241
            Height = 17
            Caption = 'Decode and keed all opcodes (recompilation)'
            TabOrder = 1
          end
        end
      end
      object GB_ScenarioFileInfo: TGroupBox
        Left = 368
        Top = 294
        Width = 273
        Height = 116
        Anchors = [akTop, akRight]
        Caption = ' Scenario file info '
        TabOrder = 1
        object L_ScenarioFileName: TLabelW
          Tag = -1
          Left = 8
          Top = 16
          Width = 257
          Height = 17
          AutoSize = False
          Caption = '---'
          ParentShowHint = False
          ShowHint = True
        end
        object Bevel4: TBevel
          Left = 2
          Top = 36
          Width = 269
          Height = 5
          Shape = bsTopLine
        end
        object L_ScenarioOffsetText: TLabelW
          Left = 8
          Top = 48
          Width = 257
          Height = 17
          AutoSize = False
          Caption = 'Text chunks beginning offset:'
        end
        object L_ScenarioOffset: TLabelW
          Tag = -1
          Left = 8
          Top = 64
          Width = 257
          Height = 17
          Alignment = taRightJustify
          AutoSize = False
          Caption = '---'
        end
        object L_ScenarioRecordsText: TLabelW
          Left = 8
          Top = 80
          Width = 257
          Height = 17
          AutoSize = False
          Caption = 'Total text record definitions:'
        end
        object L_ScenarioRecords: TLabelW
          Tag = -1
          Left = 8
          Top = 96
          Width = 257
          Height = 17
          Alignment = taRightJustify
          AutoSize = False
          Caption = '---'
        end
      end
      object GB_ScenarioTool: TGroupBox
        Tag = -1
        Left = 0
        Top = 1
        Width = 641
        Height = 92
        Anchors = [akLeft, akTop, akRight]
        Color = clBtnFace
        ParentColor = False
        TabOrder = 2
        DesignSize = (
          641
          92)
        object SB_CompileList: TSpeedButton
          Left = 427
          Top = 7
          Width = 105
          Height = 83
          AllowAllUp = True
          Anchors = [akTop, akRight, akBottom]
          BiDiMode = bdLeftToRight
          Caption = 'Compile from list'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ParentBiDiMode = False
          ShowHint = True
          OnClick = SB_CompileListClick
        end
        object SB_SCRSaveText: TSpeedButton
          Left = 533
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akTop, akRight, akBottom]
          Caption = 'Save text'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_SCRSaveTextClick
        end
        object SB_ImportSCRChunks: TSpeedButton
          Left = 215
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Import data chunks'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_ImportSCRChunksClick
        end
        object SB_ExportSCRChunks: TSpeedButton
          Left = 109
          Top = 7
          Width = 105
          Height = 83
          Anchors = [akLeft, akTop, akBottom]
          Caption = 'Export data chunks'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          OnClick = SB_ExportSCRChunksClick
        end
        object SB_OpenSCR: TSpeedButton
          Left = 3
          Top = 7
          Width = 105
          Height = 83
          AllowAllUp = True
          Anchors = [akLeft, akTop, akBottom]
          BiDiMode = bdLeftToRight
          Caption = 'Open scenario file'
          Flat = True
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -9
          Font.Name = 'Lucida Console'
          Font.Pitch = fpFixed
          Font.Style = []
          Layout = blGlyphTop
          ParentFont = False
          ParentShowHint = False
          ParentBiDiMode = False
          ShowHint = True
          OnClick = SB_OpenSCRClick
        end
      end
      object LB_SCRDec: TListBox
        Left = 0
        Top = 128
        Width = 361
        Height = 354
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ItemHeight = 11
        ParentFont = False
        TabOrder = 3
      end
    end
    object TS_Options: TTabSheet
      Caption = 'Options'
      ImageIndex = 6
      DesignSize = (
        641
        482)
      object PC_Options: TPageControl
        Left = 0
        Top = 0
        Width = 641
        Height = 485
        ActivePage = TS_PC_CoreLang
        Anchors = [akLeft, akTop, akRight, akBottom]
        MultiLine = True
        Style = tsButtons
        TabOrder = 0
        object TS_PC_CoreLang: TTabSheet
          Caption = 'Core / Language'
          DesignSize = (
            633
            454)
          object GB_Core: TGroupBox
            Left = 0
            Top = 1
            Width = 633
            Height = 316
            Anchors = [akLeft, akTop, akRight, akBottom]
            Caption = ' Core '
            TabOrder = 0
            DesignSize = (
              633
              316)
            object L_ScreenSnapPixels: TLabelW
              Left = 561
              Top = 93
              Width = 56
              Height = 14
              Anchors = [akTop, akRight]
              AutoSize = False
              Caption = 'pixels'
              Enabled = False
            end
            object CB_ScreenSnap: TCheckBox
              Left = 8
              Top = 89
              Width = 481
              Height = 25
              Anchors = [akLeft, akTop, akRight]
              Caption = 'Snap application window to screen borders at'
              TabOrder = 0
              OnClick = CB_ScreenSnapClick
            end
            object E_ScreenSnap: TEdit
              Tag = -1
              Left = 498
              Top = 91
              Width = 41
              Height = 21
              Anchors = [akTop, akRight]
              Enabled = False
              TabOrder = 1
              Text = '25'
              OnChange = E_ScreenSnapChange
            end
            object UD_ScreenSnap: TUpDown
              Left = 539
              Top = 91
              Width = 12
              Height = 21
              Anchors = [akTop, akRight]
              Associate = E_ScreenSnap
              Enabled = False
              Min = 1
              Max = 75
              Position = 25
              TabOrder = 2
              OnChanging = UD_ScreenSnapChanging
            end
            object CB_AlphaBlendEffect: TCheckBox
              Left = 8
              Top = 112
              Width = 617
              Height = 27
              Anchors = [akLeft, akTop, akRight]
              Caption = 
                'Enable alpha blending appearance of main window during the loadi' +
                'ng'
              Checked = True
              State = cbChecked
              TabOrder = 3
              OnClick = CB_AlphaBlendEffectClick
            end
            object CB_EnableDoubleBuffering: TCheckBox
              Left = 8
              Top = 138
              Width = 617
              Height = 25
              Anchors = [akLeft, akTop, akRight]
              Caption = 
                'Enable double buffering for GUI rendering (reduce flickering, ma' +
                'y be incompatible with "Modern" Themes)'
              Checked = True
              State = cbChecked
              TabOrder = 4
              WordWrap = True
              OnClick = CB_EnableDoubleBufferingClick
            end
            object CB_NoAutocenter: TCheckBox
              Left = 8
              Top = 17
              Width = 617
              Height = 25
              Anchors = [akLeft, akTop, akRight]
              Caption = 
                'Remember application window screen position (x,y coordinates). T' +
                'urn off auto-centering'
              Checked = True
              State = cbChecked
              TabOrder = 5
              WordWrap = True
              OnClick = CB_EnableDoubleBufferingClick
            end
            object CB_NoDefaultSize: TCheckBox
              Left = 8
              Top = 65
              Width = 617
              Height = 25
              Anchors = [akLeft, akTop, akRight]
              Caption = 'Remember application window proportions (width and height)'
              Checked = True
              State = cbChecked
              TabOrder = 6
              WordWrap = True
              OnClick = CB_EnableDoubleBufferingClick
            end
            object CB_KeepWindowState: TCheckBox
              Left = 8
              Top = 41
              Width = 617
              Height = 25
              Caption = 
                'Remember application window state (minimized, normal or maximize' +
                'd)'
              Checked = True
              State = cbChecked
              TabOrder = 7
            end
          end
          object GB_Language: TGroupBox
            Left = 0
            Top = 324
            Width = 633
            Height = 129
            Anchors = [akLeft, akRight, akBottom]
            Caption = ' Language '
            TabOrder = 1
            DesignSize = (
              633
              129)
            object Bevel9: TBevel
              Left = 1
              Top = 59
              Width = 631
              Height = 6
              Anchors = [akLeft, akTop, akRight]
              Shape = bsTopLine
            end
            object Image_LangFlag: TImage
              Left = 10
              Top = 34
              Width = 16
              Height = 16
              Center = True
            end
            object L_SelectedLanguage: TLabelW
              Left = 8
              Top = 16
              Width = 617
              Height = 17
              Alignment = taRightJustify
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'Selected language file:'
            end
            object L_LangAuthorValue: TLabelW
              Tag = -1
              Left = 96
              Top = 67
              Width = 529
              Height = 17
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'WinKiller Studio'
            end
            object L_LangEMailValue: TLabelW
              Tag = -1
              Left = 96
              Top = 85
              Width = 529
              Height = 17
              Cursor = crHandPoint
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'mailto:winkillerstudio@gmail.com'
              OnClick = L_LangEMailValueClick
              OnMouseEnter = L_LangEMailValueMouseEnter
              OnMouseLeave = L_LangEMailValueMouseLeave
            end
            object L_LangWWWValue: TLabelW
              Tag = -1
              Left = 96
              Top = 103
              Width = 529
              Height = 17
              Cursor = crHandPoint
              Anchors = [akLeft, akTop, akRight]
              AutoSize = False
              Caption = 'http://wks.arai-kibou.ru'
              OnClick = L_LangWWWValueClick
              OnMouseEnter = L_LangWWWValueMouseEnter
              OnMouseLeave = L_LangWWWValueMouseLeave
            end
            object L_LangWWW: TLabelW
              Left = 8
              Top = 103
              Width = 81
              Height = 17
              Alignment = taRightJustify
              AutoSize = False
              Caption = 'WWW:'
            end
            object L_LangEMail: TLabelW
              Left = 8
              Top = 86
              Width = 81
              Height = 17
              Alignment = taRightJustify
              AutoSize = False
              Caption = 'E-mail:'
            end
            object L_LangAuthor: TLabelW
              Left = 8
              Top = 67
              Width = 81
              Height = 17
              Alignment = taRightJustify
              AutoSize = False
              Caption = 'Author:'
            end
            object CB_Language: TComboBox
              Tag = -1
              Left = 32
              Top = 32
              Width = 593
              Height = 21
              Style = csDropDownList
              Anchors = [akLeft, akTop, akRight]
              ItemHeight = 13
              ItemIndex = 0
              TabOrder = 0
              Text = 'English (built-in)'
              OnChange = CB_LanguageChange
              Items.Strings = (
                'English (built-in)')
            end
            object B_DumpTranslation: TButton
              Left = 336
              Top = 96
              Width = 289
              Height = 25
              Anchors = [akTop, akRight]
              Caption = '[ Debug ] Dump translation'
              TabOrder = 1
              OnClick = B_DumpTranslationClick
            end
          end
        end
        object TS_PC_SkinColour: TTabSheet
          Caption = 'Skin / Colour scheme'
          ImageIndex = 1
          DesignSize = (
            633
            454)
          object GB_SC_Appearance: TGroupBox
            Left = 0
            Top = 0
            Width = 633
            Height = 453
            Anchors = [akLeft, akTop, akRight, akBottom]
            Caption = ' Appearance '
            TabOrder = 0
            DesignSize = (
              633
              453)
            object I_SC_ButtonSkin48: TImage
              Left = 8
              Top = 16
              Width = 240
              Height = 240
            end
            object I_SC_ButtonSkin16: TImage
              Left = 32
              Top = 264
              Width = 192
              Height = 96
            end
            object B_IntSkinReload: TButton
              Left = 336
              Top = 388
              Width = 289
              Height = 25
              Anchors = [akRight, akBottom]
              Caption = '[ Debug ] Reload internal skin'
              TabOrder = 0
              OnClick = B_IntSkinReloadClick
            end
            object B_IntSkinDump: TButton
              Left = 336
              Top = 420
              Width = 289
              Height = 25
              Anchors = [akRight, akBottom]
              Caption = '[ Debug ] Save internal skin'
              Enabled = False
              TabOrder = 1
            end
          end
        end
      end
    end
    object TS_Log: TTabSheet
      Caption = 'Console'
      ImageIndex = 4
      DesignSize = (
        641
        482)
      object E_Console: TEdit
        Tag = -3
        Left = 0
        Top = 461
        Width = 641
        Height = 19
        Anchors = [akLeft, akRight, akBottom]
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnKeyDown = E_ConsoleKeyDown
      end
      object RE_Log: TListBox
        Left = 0
        Top = 96
        Width = 641
        Height = 363
        Style = lbOwnerDrawVariable
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ItemHeight = 9
        MultiSelect = True
        ParentFont = False
        PopupMenu = PM_Log
        TabOrder = 1
        OnDrawItem = RE_LogDrawItem
        OnMeasureItem = RE_LogMeasureItem
      end
      object GB_MessageLog: TGroupBox
        Left = 0
        Top = 1
        Width = 641
        Height = 92
        Anchors = [akLeft, akTop, akRight]
        Caption = ' Display and store to log '
        Color = clBtnFace
        ParentColor = False
        TabOrder = 2
        DesignSize = (
          641
          92)
        object SB_Log_Color_W: TSpeedButton
          Tag = -1
          Left = 64
          Top = 16
          Width = 17
          Height = 16
          Flat = True
          Layout = blGlyphTop
          OnClick = SB_Log_Color_WClick
        end
        object SB_Log_Color_E: TSpeedButton
          Tag = -1
          Left = 64
          Top = 34
          Width = 17
          Height = 16
          Flat = True
          Layout = blGlyphTop
          OnClick = SB_Log_Color_EClick
        end
        object SB_Log_Color_D: TSpeedButton
          Tag = -1
          Left = 64
          Top = 52
          Width = 17
          Height = 16
          Flat = True
          Layout = blGlyphTop
          OnClick = SB_Log_Color_DClick
        end
        object SB_Log_Color_I: TSpeedButton
          Tag = -1
          Left = 64
          Top = 70
          Width = 17
          Height = 16
          Flat = True
          Layout = blGlyphTop
          OnClick = SB_Log_Color_IClick
        end
        object SB_Log_Color_M: TSpeedButton
          Tag = -1
          Left = 240
          Top = 16
          Width = 17
          Height = 16
          Flat = True
          Layout = blGlyphTop
          OnClick = SB_Log_Color_MClick
        end
        object SB_Log_Color_S: TSpeedButton
          Tag = -1
          Left = 240
          Top = 34
          Width = 17
          Height = 16
          Flat = True
          Layout = blGlyphTop
          OnClick = SB_Log_Color_SClick
        end
        object SB_Log_Color_BG: TSpeedButton
          Tag = -1
          Left = 240
          Top = 52
          Width = 17
          Height = 16
          Flat = True
          Layout = blGlyphTop
          OnClick = SB_Log_Color_BGClick
        end
        object SB_Log_Color_SEL: TSpeedButton
          Tag = -1
          Left = 240
          Top = 70
          Width = 17
          Height = 16
          Flat = True
          Layout = blGlyphTop
          OnClick = SB_Log_Color_SELClick
        end
        object L_Log_BGColor: TLabel
          Left = 264
          Top = 52
          Width = 145
          Height = 17
          AutoSize = False
          Caption = 'Background color'
          Transparent = True
        end
        object L_Log_SelColor: TLabel
          Left = 264
          Top = 70
          Width = 145
          Height = 17
          AutoSize = False
          Caption = 'Selection color'
          Transparent = True
        end
        object CB_NoLog: TCheckBox
          Left = 488
          Top = 69
          Width = 145
          Height = 18
          Hint = 
            'Disable logging system (no error messages will be displayed at a' +
            'll)'
          Alignment = taLeftJustify
          Anchors = [akTop, akRight]
          Caption = 'Nothing (turn off)'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          WordWrap = True
          OnClick = CB_NoLogClick
        end
        object CB_LogI: TCheckBox
          Left = 88
          Top = 69
          Width = 145
          Height = 17
          Caption = 'Information'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object CB_LogM: TCheckBox
          Left = 264
          Top = 15
          Width = 145
          Height = 17
          Caption = 'Normal messages'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object CB_LogS: TCheckBox
          Left = 264
          Top = 33
          Width = 145
          Height = 17
          Caption = 'Static messages'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object CB_LogE: TCheckBox
          Left = 88
          Top = 33
          Width = 145
          Height = 17
          Caption = 'Errors'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object CB_LogW: TCheckBox
          Left = 88
          Top = 15
          Width = 145
          Height = 17
          Caption = 'Warnings'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object CB_LogD: TCheckBox
          Left = 88
          Top = 51
          Width = 145
          Height = 17
          Caption = 'Debug messages'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
        object CB_BeepOnError: TCheckBox
          Left = 8
          Top = 33
          Width = 49
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Beep!'
          Checked = True
          State = cbChecked
          TabOrder = 7
          OnClick = CB_BeepOnErrorClick
        end
        object CB_BeepOnWarn: TCheckBox
          Left = 8
          Top = 15
          Width = 49
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Beep!'
          TabOrder = 8
          OnClick = CB_BeepOnWarnClick
        end
        object CB_Log_ConScheme: TComboBox
          Tag = -1
          Left = 416
          Top = 14
          Width = 217
          Height = 21
          Style = csDropDownList
          Anchors = [akTop, akRight]
          ItemHeight = 13
          TabOrder = 9
          OnChange = CB_Log_ConSchemeChange
        end
        object TB_Log_FontSize: TTrackBar
          Left = 416
          Top = 40
          Width = 217
          Height = 17
          Anchors = [akTop, akRight]
          Max = 72
          Min = 1
          Position = 8
          TabOrder = 10
          ThumbLength = 10
          OnChange = TB_Log_FontSizeChange
        end
      end
    end
    object TS_About: TTabSheet
      Caption = 'About...'
      ImageIndex = 5
      OnHide = TS_AboutHide
      OnShow = TS_AboutShow
      DesignSize = (
        641
        482)
      object Image_AniLogo: TImage
        Left = 0
        Top = 0
        Width = 640
        Height = 482
        Cursor = crHelp
        Anchors = [akLeft, akTop, akRight, akBottom]
        PopupMenu = PM_AboutBox
        OnDblClick = Image_AniLogoDblClick
      end
      object L_Copyright: TLabelW
        Tag = -1
        Left = 208
        Top = 16
        Width = 416
        Height = 17
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = #169' 2007-2013 WinKiller Studio and The Contributors.'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -9
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
      object L_WWW: TLabelW
        Tag = -1
        Left = 16
        Top = 16
        Width = 193
        Height = 13
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'http://wks.arai-kibou.ru/'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -9
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
        Transparent = True
        OnClick = L_WWWClick
        OnMouseEnter = L_WWWMouseEnter
        OnMouseLeave = L_WWWMouseLeave
      end
      object L_EMail: TLabelW
        Tag = -1
        Left = 16
        Top = 32
        Width = 193
        Height = 17
        Cursor = crHandPoint
        AutoSize = False
        Caption = 'mailto:winkillerstudio@gmail.com'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -9
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
        Transparent = True
        OnClick = L_EMailClick
        OnMouseEnter = L_EMailMouseEnter
        OnMouseLeave = L_EMailMouseLeave
      end
      object L_UsersManual: TLabelW
        Left = 16
        Top = 48
        Width = 193
        Height = 17
        Cursor = crHandPoint
        AutoSize = False
        Caption = '> User'#39's Manual <'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -9
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        OnClick = L_UsersManualClick
        OnMouseEnter = L_UsersManualMouseEnter
        OnMouseLeave = L_UsersManualMouseLeave
      end
      object L_ThisSoftwareIsFree: TLabelW
        Left = 208
        Top = 32
        Width = 416
        Height = 17
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'This software is free. Please see License for details.'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -9
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentColor = False
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
      object SCredits: TScrollingCredits
        Tag = -1
        Left = 16
        Top = 80
        Width = 609
        Height = 313
        Cursor = crHelp
        Credits.Strings = (
          '&b&uTScrollingCredits'
          'Copyright '#169'2000 Saturn Laboratories'
          ''
          'This version includes basic formatting!!'
          '&bMake a line bold with &&b'
          '&uMake a line underlined with &&u'
          '&iMake a line italicized with &&i'
          '&c255,255,0;Make a line a different color'
          '&c0,255,255;with &&c[red],[green],[blue];'
          ''
          'And put that ampersand in with &&&&'
          ''
          '&bPlease let me know if you find'
          '&bthis component useful.'
          'components@saturnlaboratories.gq.nu')
        CreditsFont.Charset = DEFAULT_CHARSET
        CreditsFont.Color = clWindowText
        CreditsFont.Height = -13
        CreditsFont.Name = 'Tahoma'
        CreditsFont.Style = []
        BackgroundColor = clWindow
        BorderColor = 180634
        Animate = False
        Interval = 22
        AfterLastCredit = SCreditsAfterLastCredit
        Visible = False
        ShowBorder = False
        OnDblClick = Image_AniLogoDblClick
      end
      object L_Version: TLabelW
        Tag = -1
        Left = 16
        Top = 456
        Width = 233
        Height = 16
        Alignment = taCenter
        AutoSize = False
        Caption = 'Version X.X.X.XXX'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -9
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
      object L_UnsupportedOS: TLabelW
        Left = 16
        Top = 64
        Width = 609
        Height = 17
        Alignment = taCenter
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 
          'WARNING: Your operating system is UNSUPPORTED. Errors are likely' +
          ' to occur.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -9
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        Visible = False
      end
      object L_NepetaByCA: TLabelW
        Tag = -1
        Left = 232
        Top = 464
        Width = 392
        Height = 17
        Cursor = crHandPoint
        Alignment = taRightJustify
        Anchors = [akRight, akBottom]
        AutoSize = False
        Caption = 'Nepeta by CountAile. Used with purrmission. :33'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -9
        Font.Name = 'Lucida Console'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
        Transparent = True
        OnClick = L_NepetaByCAClick
        OnMouseEnter = L_NepetaByCAMouseEnter
        OnMouseLeave = L_NepetaByCAMouseLeave
      end
    end
  end
  object P_Console: TPanel
    Tag = -1
    Left = -2
    Top = 529
    Width = 671
    Height = 69
    Anchors = [akLeft, akRight, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Color = clWhite
    TabOrder = 1
    OnDblClick = L_Mini_LogWDblClick
    DesignSize = (
      671
      69)
    object L_Mini_Log: TLabelW
      Tag = -1
      Left = 16
      Top = 4
      Width = 638
      Height = 31
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoSize = False
      Caption = 'L_Mini_Log'
      Color = clWhite
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Lucida Console'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
      WordWrap = True
      OnDblClick = L_Mini_LogWDblClick
    end
    object L_Messageboard: TLabelW
      Left = 456
      Top = 44
      Width = 199
      Height = 9
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Application messageboard'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clActiveCaption
      Font.Height = -9
      Font.Name = 'Lucida Console'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      Transparent = True
      OnDblClick = L_Mini_LogWDblClick
    end
    object G_Progress: TGauge
      Tag = -1
      Left = 16
      Top = 28
      Width = 638
      Height = 11
      Hint = 'Group archive operations progress indicator'
      Anchors = [akLeft, akRight, akBottom]
      Color = clWhite
      ForeColor = 13665296
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Lucida Console'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      Progress = 50
      ShowHint = True
      Visible = False
    end
    object L_Arc_StatusProcessing: TLabelW
      Left = 16
      Top = 44
      Width = 55
      Height = 9
      Caption = 'Processing:'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Lucida Console'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      Visible = False
      OnDblClick = L_Mini_LogWDblClick
    end
    object L_Arc_Status: TLabelW
      Tag = -1
      Left = 216
      Top = 44
      Width = 241
      Height = 9
      Alignment = taCenter
      AutoSize = False
      Caption = '0 / 0'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Lucida Console'
      Font.Pitch = fpFixed
      Font.Style = []
      ParentFont = False
      Visible = False
      OnDblClick = L_Mini_LogWDblClick
    end
  end
  object Timer_AlphaBlend: TTimer
    Interval = 1
    OnTimer = Timer_AlphaBlendTimer
    Left = 614
    Top = 511
  end
  object PM_ColorSwap: TPopupMenu
    Images = ImageList_EDGE
    TrackButton = tbLeftButton
    Left = 428
    Top = 511
    object M_EDGE_BGR: TMenuItem
      Caption = 'RGB -> BGR'
      SubMenuImages = ImageList_EDGE
      ImageIndex = 0
      OnClick = M_EDGE_BGRClick
    end
    object M_EDGE_BRG: TMenuItem
      Caption = 'RGB -> BRG'
      SubMenuImages = ImageList_EDGE
      ImageIndex = 1
      OnClick = M_EDGE_BRGClick
    end
    object M_EDGE_GBR: TMenuItem
      Caption = 'RGB -> GBR'
      SubMenuImages = ImageList_EDGE
      ImageIndex = 2
      OnClick = M_EDGE_GBRClick
    end
    object M_EDGE_GRB: TMenuItem
      Caption = 'RGB -> GRB'
      SubMenuImages = ImageList_EDGE
      ImageIndex = 3
      OnClick = M_EDGE_GRBClick
    end
    object M_EDGE_RBG: TMenuItem
      Caption = 'RGB -> RBG'
      SubMenuImages = ImageList_EDGE
      ImageIndex = 4
      OnClick = M_EDGE_RBGClick
    end
  end
  object PM_SUBAlpha_Extract: TPopupMenu
    Images = ImageList_EDGE
    Left = 484
    Top = 511
    object M_EDGE_SUBAlpha_Extract_Left: TMenuItem
      Caption = 'Left'
      ImageIndex = 7
      OnClick = M_EDGE_SUBAlpha_Extract_LeftClick
    end
    object M_EDGE_SUBAlpha_Extract_Right: TMenuItem
      Caption = 'Right'
      ImageIndex = 8
      OnClick = M_EDGE_SUBAlpha_Extract_RightClick
    end
  end
  object PM_SUBAlpha_Append: TPopupMenu
    Images = ImageList_EDGE
    Left = 456
    Top = 511
    object M_EDGE_SUBAlpha_Append_Left: TMenuItem
      Caption = 'Left'
      ImageIndex = 5
      OnClick = M_EDGE_SUBAlpha_Append_LeftClick
    end
    object M_EDGE_SUBAlpha_Append_Right: TMenuItem
      Caption = 'Right'
      ImageIndex = 6
      OnClick = M_EDGE_SUBAlpha_Append_RightClick
    end
  end
  object PM_SUBAlpha_Destroy: TPopupMenu
    Images = ImageList_EDGE
    Left = 512
    Top = 511
    object M_EDGE_SUBAlpha_Destroy_Left: TMenuItem
      Caption = 'Left'
      ImageIndex = 9
      OnClick = M_EDGE_SUBAlpha_Destroy_LeftClick
    end
    object M_EDGE_SUBAlpha_Destroy_Right: TMenuItem
      Caption = 'Right'
      ImageIndex = 10
      OnClick = M_EDGE_SUBAlpha_Destroy_RightClick
    end
  end
  object ImageList_Archiver: TImageList
    DrawingStyle = dsTransparent
    ShareImages = True
    Left = 295
    Top = 511
    Bitmap = {
      494C010113001800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000006000000001002000000000000060
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E7B59000B27F7300B27F7300B27F7300B27F7300B27F
      7300B27F7300B27F730000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000B27F7300B27F7300B27F7300B27F7300B27F7300B27F7300B27F7300B27F
      7300B27F73000000000000000000000000000000000000000000000000000000
      00000000000000000000E7B59000FFF8F000FFF8F000FFF8F000FFF8F000FFF8
      F000FFF8F000B27F73000000000000000000000000000000000000000000C4A8
      B3007C68AA007263B4006A60BB00645DC200605CC6005D5AC9005B59CB005A59
      CC005958CD000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00B27F73000000000000000000000000000000000000000000000000000000
      00000000000000000000E7B59000FFF8F000A67A7500A67A7500A67A7500A67A
      7500FFF8F000B27F73000000000000000000000000000000000000000000C7A9
      B000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF005959CD000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000FFFFFF00E7B59000E7B59000FFFFFF00E7B59000E7B59000E7B59000FFFF
      FF00B27F73000000000000000000000000000000000000000000000000000000
      00000000000000000000E7B59000FFF8F000FFF8F000FFF8F000FFF8F000FFF8
      F000FFF8F000B27F73000000000000000000000000000000000000000000C9AA
      AE00FFFFFF00B5A2C300ADA0CB00FFFFFF00A29CD6009F9BD9009D9ADB00FFFF
      FF005A59CC000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00B27F73000000000000000000000000000000000000000000E7B59000B27F
      7300B27F7300B27F7300B27F7300B27F7300B27F7300B27F7300A67A7500A67A
      7500FFF8F000B27F73000000000000000000000000000000000000000000CFAC
      A800FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF005C5ACA000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000FFFFFF00E7B59000E7B59000E7B59000FFFFFF00E7B59000E7B59000FFFF
      FF00B27F73000000000000000000000000000000000000000000E7B59000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B27F7300FFF8F000FFF8
      F000FFF8F000B27F73000000000000000000000000000000000000000000D7AF
      A000FFFFFF00C1A7B700B7A3C100AFA1C800FFFFFF00A59DD300A29CD600FFFF
      FF005E5BC8000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00B27F73000000000000000000000000000000000000000000E7B59000FFFF
      FF00E7B59000E7B59000E7B59000E7B59000FFFFFF00B27F7300A67A7500A67A
      7500FFF8F000B27F73000000000000000000000000000000000000000000DBB1
      9C00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00615CC5000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000FFFFFF00E7B59000E7B59000FFFFFF00E7B59000E7B59000E7B59000FFFF
      FF00B27F73000000000000000000000000000000000000000000E7B59000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B27F7300FFF8F000FFF8
      F000FFF8F000B27F73000000000000000000000000000000000000000000DEB2
      9900FFFFFF00CFACA800C6A9B200FFFFFF00B5A3C300AFA0C900AA9FCD00FFFF
      FF00665EC0000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00B27F73000000000000000000000000000000000000000000E7B59000FFFF
      FF00E7B59000E7B59000E7B59000E7B59000FFFFFF00B27F7300FFF8F000FFF8
      F000FFF8F000B27F73000000000000000000000000000000000000000000E2B3
      9500FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF006C61BA000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000E7B5
      9000E7B59000E7B59000E7B59000FFFFFF00E7B59000E7B59000E7B59000FFFF
      FF00B27F73000000000000000000000000000000000000000000E7B59000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00B27F7300E7B59000E7B5
      9000E7B59000B27F73000000000000000000000000000000000000000000E5B4
      9200E1B39600DBB19C00D5AFA200FFFFFF00C8AAAF00C0A7B800B9A4BF00FFFF
      FF007565B1000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E7B59000E7B59000E7B59000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00B27F73000000000000000000000000000000000000000000E7B59000FFFF
      FF00FFFFFF00FFFFFF00E7B59000E7B59000FFFFFF00B27F7300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E4B49300E0B29700DCB19B00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00816AA5000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E7B59000E7B59000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00B27F73000000000000000000000000000000000000000000E7B59000E7B5
      9000E7B59000FFFFFF00FFFFFF00FFFFFF00FFFFFF00B27F7300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E3B49400E0B29700FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF008C6F99000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E7B59000E7B59000E7B59000E7B59000E7B59000E7B5
      9000B27F7300000000000000000000000000000000000000000000000000E7B5
      9000E7B59000FFFFFF00FFFFFF00FFFFFF00FFFFFF00B27F7300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E4B49300E1B39600DDB19A00DAB09D00D8AFA000D5AE
      A30098748D000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000E7B59000E7B59000E7B59000E7B59000E7B59000B27F7300000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000CB4FF000CB4FF000CB4FF000CB4FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8000000080000000000000000000008080000080800000000000000000000080
      0000008000000000000000000000000000000000000000000000000000007A7A
      7A00525252005252520052525200525252005252520052525200525252005252
      5200525252000000000000000000000000000000000000000000000000007A7A
      7A00525252005252520052525200525252005252520052525200525252005252
      5200525252000000000000000000000000000000000000000000000000000000
      0000000000000FB8FF0043DEFF0043DEFF0043DEFF0043DEFF000FB8FF000000
      0000000000000000000000000000000000000000000000000000000080000000
      FF000000FF00000080000080800000FFFF0000FFFF00008080000080000000FF
      000000FF00000080000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A0080FFFF0080FFFF0080FFFF0080FFFF0080FFFF0080FFFF0080FFFF0080FF
      FF00525252000000000000000000000000000000000000000000000000000000
      00000000000012BCFF004EE1FF004EE1FF004EE1FF004EE1FF0012BCFF000000
      0000000000000000000000000000000000000000000000000000000080000000
      FF000000FF00000080000080800000FFFF0000FFFF00008080000080000000FF
      000000FF00000080000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FF000000FF000000FF000000FF000000FF000000FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A0080FFFF00408080004080800000FFFF00008080000080800080FFFF0080FF
      FF005252520000000000000000000000000000000000000000000000000015C0
      FF0015C0FF0015C0FF005AE4FF005AE4FF005AE4FF005AE4FF0015C0FF0015C0
      FF0015C0FF000000000000000000000000000000000000000000000080000000
      FF000000FF00000080000080800000FFFF0000FFFF00008080000080000000FF
      000000FF00000080000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000D700000000FF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A0080FFFF000080800000FFFF0000FFFF0000FFFF00008080000080800080FF
      FF0052525200000000000000000000000000000000000000000018C4FF0065E7
      FF0065E7FF0065E7FF0065E7FF0065E7FF0065E7FF0065E7FF0065E7FF0065E7
      FF0065E7FF0018C4FF0000000000000000000000000000000000000080000000
      FF000000FF00000080000080800000FFFF0000FFFF00008080000080000000FF
      000000FF00000080000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000D70000FFFFFF000000FF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A0080FFFF00008080000080800000FFFF004080800000FFFF000080800080FF
      FF0052525200000000000000000000000000000000000000000019C7FF006FE9
      FF006FE9FF006FE9FF006FE9FF006FE9FF006FE9FF006FE9FF006FE9FF006FE9
      FF006FE9FF0019C7FF0000000000000000000000000000000000000080000000
      FF000000FF00000080000080800000FFFF0000FFFF00008080000080000000FF
      000000FF00000080000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF0000D70000FFFFFF00FFFFFF000000FF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A0080FFFF0080FFFF00008080004080800000FFFF0000FFFF0080FFFF0080FF
      FF005252520000000000000000000000000000000000000000001BCAFF0078EC
      FF0078ECFF0078ECFF0078ECFF0078ECFF0078ECFF0078ECFF0078ECFF0078EC
      FF0078ECFF001BCAFF0000000000000000000000000000000000000080000000
      FF000000FF00000080000080800000FFFF0000FFFF00008080000080000000FF
      000000FF00000080000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF0000D70000FFFFFF00FFFFFF00FFFFFF000000FF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A0080FFFF004080800080FFFF004080800000FFFF000080800080FFFF0080FF
      FF005252520000000000000000000000000000000000000000001ECDFF0081EF
      FF0081EFFF0081EFFF0081EFFF0081EFFF0081EFFF0081EFFF0081EFFF0081EF
      FF0081EFFF001ECDFF0000000000000000000000000000000000000000000000
      800000008000000000000080800000FFFF0000FFFF00008080000080000000FF
      000000FF00000080000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A0080FFFF000080800000FFFF0000FFFF0000808000008080000080800080FF
      FF005252520000000000000000000000000000000000000000000000000020D0
      FF0020D0FF0020D0FF008BF1FF008BF1FF008BF1FF008BF1FF0020D0FF0020D0
      FF0020D0FF000000000000000000000000000000000000000000000000000000
      000000000000000000000080800000FFFF0000FFFF00008080000080000000FF
      000000FF00000080000000000000000000000000000000000000000000007A7A
      7A007A7A7A007A7A7A007A7A7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A007A7A7A007A7A7A007A7A7A0000FFFF0000FFFF00008080000080800080FF
      FF00525252000000000000000000000000000000000000000000000000000000
      00000000000022D3FF0094F4FF0094F4FF0094F4FF0094F4FF0022D3FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000080800000FFFF0000FFFF0000808000000000000080
      0000008000000000000000000000000000000000000000000000000000000000
      00007A7A7A007A7A7A007A7A7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000000000
      00007A7A7A007A7A7A007A7A7A000080800000FFFF00008080000080800080FF
      FF00525252000000000000000000000000000000000000000000000000000000
      00000000000025D6FF009EF7FF009EF7FF009EF7FF009EF7FF0025D6FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000080800000FFFF0000FFFF0000808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007A7A7A007A7A7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000000000
      0000000000007A7A7A007A7A7A0080FFFF0080FFFF0080FFFF0080FFFF0080FF
      FF00525252000000000000000000000000000000000000000000000000000000
      0000000000000000000027D9FF0027D9FF0027D9FF0027D9FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000008080000080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007A7A7A007A7A7A007A7A7A007A7A7A007A7A7A007A7A
      7A00525252000000000000000000000000000000000000000000000000000000
      000000000000000000007A7A7A007A7A7A007A7A7A007A7A7A007A7A7A007A7A
      7A00525252000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006F08
      08006F0808006F0808006F0808006F0808006F0808006F0808006F0808006F08
      08006F0808000000000000000000000000000000000000000000000000005555
      0000555500005555000055550000555500005555000055550000555500005555
      0000555500000000000000000000000000000000000000000000000000000000
      6F0000006F0000006F0000006F0000006F0000006F0000006F0000006F000000
      6F0000006F000000000000000000000000000000000000000000000000008888
      1200888912008989120089891200898913008989130089891300898913008989
      1300898913000000000000000000000000000000000000000000B1080800CC72
      4000CA714000C8704000C56F4000C26D4000BF6C4000BD6A4000BA694000B768
      4000B56640006F0808000000000000000000000000000000000077770000AEAE
      0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE
      0000AEAE000055550000000000000000000000000000000000000000A8000000
      D9000000D9000000D9000000D9000000D9000000D9000000D9000000D9000000
      D9000000D90000006F000000000000000000000000000000000088881200EFF0
      F000F0F6F600F6F7F700F7F7F700FAFAFA00FEFEFE00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008989130000000000000000000000000000000000B1080800CE73
      4000CC724000CA714000C8704000C56F4000C26D4000BF6C4000BD6A4000BA69
      4000B76840006F0808000000000000000000000000000000000077770000AEAE
      0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE
      0000AEAE000055550000000000000000000000000000000000000000A8000000
      D9000000D9000000D9000000D9000000D9000000D9000000D9000000D9000000
      D9000000D90000006F000000000000000000000000000000000088881200EFEF
      EF00EFF0F000F0F5F500E2EFE400DCECDC00FAFAFA00FEFEFE00FFFFFF00FFFF
      FF00FFFFFF008989130000000000000000000000000000000000B1080800D074
      4000CE734000CC724000CA714000C8704000C56F4000C26D4000BF6C4000BD6A
      4000BA6940006F0808000000000000000000000000000000000077770000AEAE
      0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE
      0000AEAE000055550000000000000000000000000000000000000000A8000000
      D9000000D9000000D9000000D9000000D9000000D9000000D9000000D9000000
      D9000000D90000006F000000000000000000000000000000000088881200ECEF
      EF00EFEFEF00DBE9DD0079C87C0065BF6500D8EBD800FAFAFA00FEFEFE00FFFF
      FF00FFFFFF008989130000000000000000000000000000000000B1080800D275
      4000D0744000CE734000CC724000CA714000C8704000C56F4000C26D4000BF6C
      4000BD6A40006F0808000000000000000000000000000000000077770000AEAE
      0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE
      0000AEAE000055550000000000000000000000000000000000000000A8000000
      D9000000D9000000D9000000D9000000D9000000D9000000D9000000D9000000
      D9000000D90000006F000000000000000000000000000000000087881100E7EC
      EC00DAE8DC0079C4790021A5210021A5210068C06800D7EAD700FAFAFA00FEFE
      FE00FFFFFF008989130000000000000000000000000000000000B1080800D476
      4000D2754000D0744000CE734000CC724000CA714000C8704000C56F4000C26D
      4000BF6C40006F0808000000000000000000000000000000000077770000AEAE
      0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE0000AEAE
      0000AEAE000055550000000000000000000000000000000000000000A8000000
      D9000000D9000000D9000000D9000000D9000000D9000000D9000000D9000000
      D9000000D90000006F000000000000000000000000000000000087871100E7E7
      E700B9DBBC0021A5210045B2450054B7540021A5210067C06700D8EBD800FAFA
      FA00FEFEFE008989130000000000000000000000000000000000B1080800D677
      4000F3F1ED00ECEAE600E5E2DE00DEDBD700D7D4D000CFCCC800C5C2BE00BFBC
      B700C26D40006F0808000000000000000000000000000000000077770000AEAE
      0000DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDB
      DB00AEAE000055550000000000000000000000000000000000000000A8000000
      D900DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDB
      DB000000D90000006F000000000000000000000000000000000087871100E2E7
      E700B9D7B90041B14300B1D9B400C3DFC30054B7540021A5210065BF6500DCEC
      DC00FAFAFA008989130000000000000000000000000000000000B1080800D979
      4000F3F1ED00ECEAE600E5E2DE00E0DEDA006A3C00006A3C0000CCC9C500C5C2
      BE00C56F40006F0808000000000000000000000000000000000077770000AEAE
      0000DBDBDB00DBDBDB00DBDBDB00DBDBDB005555000055550000DBDBDB00DBDB
      DB00AEAE000055550000000000000000000000000000000000000000A8000000
      D900DBDBDB00DBDBDB00DBDBDB00DBDBDB0000006F0000006F00DBDBDB00DBDB
      DB000000D90000006F000000000000000000000000000000000087871100DEE7
      E700D1E1D500B1D6B200E8EBEB00ECEFEF00C4DFC40051B6510021A52100C5E4
      C500F7F7F7008989120000000000000000000000000000000000B1080800DB7A
      4000F5F3EF00EEECE800EAE7E300E3E0DC009F5A00009F5A0000D2CFCB00CFCC
      C800C87040006F0808000000000000000000000000000000000077770000AEAE
      0000DBDBDB00DBDBDB00DBDBDB00DBDBDB005555000055550000DBDBDB00DBDB
      DB00AEAE000055550000000000000000000000000000000000000000A8000000
      D900DBDBDB00DBDBDB00DBDBDB00DBDBDB0000006F0000006F00DBDBDB00DBDB
      DB000000D90000006F000000000000000000000000000000000087871100DEE1
      E100DEE7E700E2E7E700E7E7E700E8ECEC00ECEFEF00C8E1C8004CB44C00C1E4
      C500F6F7F7008989120000000000000000000000000000000000B1080800DE7B
      4000F8F6F200F3F1ED00ECEAE600E7E5E100D4780000D4780000D9D6D200D7D4
      D000CA7140006F0808000000000000000000000000000000000077770000AEAE
      0000DBDBDB00DBDBDB00DBDBDB00DBDBDB005555000055550000DBDBDB00DBDB
      DB00AEAE000055550000000000000000000000000000000000000000A8000000
      D900DBDBDB00DBDBDB00DBDBDB00DBDBDB0000006F0000006F00DBDBDB00DBDB
      DB000000D90000006F000000000000000000000000000000000087871000DEDE
      DE00DEE1E100DEE7E700E2E7E700E7E7E700E7ECEC00ECEFEF00CEE3CE00E4EC
      E500F0F6F6008889120000000000000000000000000000000000B1080800E07C
      4000F8F6F200F5F3EF00F1EFEB00ECEAE600E7E5E100E3E0DC00E0DEDA00DEDB
      D700CC7240006F0808000000000000000000000000000000000077770000AEAE
      0000DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDB
      DB00AEAE000055550000000000000000000000000000000000000000A8000000
      D900DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDBDB00DBDB
      DB000000D90000006F000000000000000000000000000000000087871000DEDE
      DE00DEDEDE00DEE1E100DEE7E700E2E7E700E7E7E700E7ECEC00ECEFEF00EFEF
      EF00EFF0F000888812000000000000000000000000000000000000000000B108
      0800B1080800B1080800B1080800B1080800B1080800B1080800B1080800B108
      0800B10808000000000000000000000000000000000000000000000000007777
      0000777700007777000077770000777700007777000077770000777700007777
      0000777700000000000000000000000000000000000000000000000000000000
      A8000000A8000000A8000000A8000000A8000000A8000000A8000000A8000000
      A8000000A8000000000000000000000000000000000000000000000000008787
      1000878710008787110087871100878711008787110087881100888812008888
      1200888812000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000B3
      B300008080000080800000808000008080000080800000808000008080000080
      8000008080000000000000000000000000000000000000000000000000000000
      CA00000080000000800000008000000080000000800000008000000080000000
      8000000080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000B3
      B30040AEFF003FACFF003DACFF003FAEFF0045AFFF004AABFF0060B3FF0076B2
      FF00008080000000000000000000000000000000000000000000000000000000
      CA00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000008000000000000000000000000000000000000000000000000000009B
      9B00009B9B00009B9B00009B9B00009B9B00009B9B00009B9B00009B9B00009B
      9B00009B9B000000000000000000000000000000000000000000000000000000
      00000000000080808000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C00000000000000000000000000000000000000000000000000000B3
      B30003AEFF0002B1FF0013B8FF0040CCFF005DC8FF0077BCFF009EC6FF00B3CC
      FF00008080000000000000000000000000000000000000000000000000000000
      CA00FFFFFF00FFFFFF000000FF000000FF000000FF000000FF00FFFFFF00FFFF
      FF0000008000000000000000000000000000000000000000000000C6C60000EA
      EA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EA
      EA0000EAEA00009B9B0000000000000000000000000000000000000000000000
      00000000000080808000FFFFFF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C00000000000000000000000000000000000000000000000000000B3
      B30000AFFF000DC4FF0015D0FF0032E6FF0041F2FF0051E0FF008BDAFF00A8DA
      FF00008080000000000000000000000000000000000000000000000000000000
      CA00FFFFFF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFF
      FF0000008000000000000000000000000000000000000000000000C6C60000EA
      EA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EA
      EA0000EAEA00009B9B0000000000000000000000000000000000000000000000
      00000000000080808000FFFFFF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C00000000000000000000000000000000000000000000000000000B3
      B3000FBAFF000FC0FF0018C8FF003ADDFF005DF2FF0073FCFF0091F6FF009DF9
      FF00008080000000000000000000000000000000000000000000000000000000
      CA00FFFFFF000000FF00FFFFFF000000FF00FFFFFF00FFFFFF000000FF00FFFF
      FF0000008000000000000000000000000000000000000000000000C6C60000EA
      EA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EA
      EA0000EAEA00009B9B0000000000000000000000000000000000000000000000
      00000000000080808000FFFFFF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C00000000000000000000000000000000000000000000000000000B3
      B3003EC1FF003DCAFF004BD5FF0060D4FF0074D8FF007EE2FF007AF0FF0086F4
      FF00008080000000000000000000000000000000000000000000000000000000
      CA00FFFFFF000000FF00FFFFFF00FFFFFF000000FF00FFFFFF000000FF00FFFF
      FF0000008000000000000000000000000000000000000000000000C6C60000EA
      EA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EA
      EA0000EAEA00009B9B0000000000000000000000000000000000808080000000
      00000000000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C00000000000000000000000000000000000000000000000000000B3
      B30046EDFF0052F6FF0052FBFF005AFEFF0058FDFF0063F7FF0061F8FF0060FF
      FF00008080000000000000000000000000000000000000000000000000000000
      CA00FFFFFF000000FF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF00FFFF
      FF0000008000000000000000000000000000000000000000000000C6C60000EA
      EA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EA
      EA0000EAEA00009B9B000000000000000000000000000000000080808000C0C0
      C000C0C0C0008080800080808000808080008080800080808000808080008080
      80008080800000000000000000000000000000000000000000000000000000B3
      B30027D7FF0033E3FF0038DDFF002FC8FF0063E1FF006EEEFF0060EEFF003CE2
      FF00008080000000000000000000000000000000000000000000000000000000
      CA00FFFFFF00FFFFFF000000FF000000FF000000FF000000FF00FFFFFF00FFFF
      FF0000008000000000000000000000000000000000000000000000C6C60000EA
      EA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EAEA0000EA
      EA0000EAEA00009B9B000000000000000000000000000000000080808000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000000000
      00000000000000000000000000000000000000000000000000000000000000B3
      B30000B3B30000B3B30000B3B30016D3FF0023D6FF003BD8FF004AD3FF0035C7
      FF00008080000000000000000000000000000000000000000000000000000000
      CA000000CA000000CA000000CA00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000008000000000000000000000000000000000000000000000C6C60000EA
      EA0000EAEA0000EAEA0000EAEA0000EAEA0000C6C60000C6C60000C6C60000C6
      C60000EAEA00009B9B000000000000000000000000000000000080808000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000B3B30000B3B30000B3B30001DDFF0001DFFF0003E0FF0004DDFF0010D7
      FF00008080000000000000000000000000000000000000000000000000000000
      00000000CA000000CA000000CA00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000800000000000000000000000000000000000000000000000000000C6
      C60000C6C60000C6C60000C6C60000C6C60000DDDD0000DDDD0000DDDD0000DD
      DD0000C6C600000000000000000000000000000000000000000080808000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000B3B30000B3B30000E7FF0000E9FF0003ECFF0005F5FF0011FB
      FF00008080000000000000000000000000000000000000000000000000000000
      0000000000000000CA000000CA00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000080000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000C6C60000C6C60000C6C60000C6
      C60000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000B3B30000B3B30000B3B30000B3B30000B3B30000B3
      B300008080000000000000000000000000000000000000000000000000000000
      000000000000000000000000CA000000CA000000CA000000CA000000CA000000
      CA00000080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007A7A
      7A00525252005252520052525200525252005252520052525200525252005252
      5200525252000000000000000000000000000000000000000000000000007A7A
      7A00525252005252520052525200525252005252520052525200525252005252
      52005252520000000000000000000000000000000000000000000000000000B9
      0000005E0000005E0000005E0000005E0000005E0000005E0000005E0000005E
      0000005E0000000000000000000000000000000000000000000000000000C663
      0000663300006633000066330000663300006633000066330000663300006633
      0000663300000000000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A00E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0
      E0005252520000000000000000000000000000000000000000000000000000B9
      0000C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FF
      C600005E0000000000000000000000000000000000000000000000000000C663
      0000FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A00E0E0E0004A4A4A004A4A4A00E0E0E0004A4A4A004A4A4A004A4A4A00E0E0
      E0005252520000000000000000000000000000000000000000000000000000B9
      0000C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FF
      C600005E0000000000000000000000000000000000000000000000000000C663
      0000FFCD9B008040000080400000FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A00E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0
      E0005252520000000000000000000000000000000000000000000000000000B9
      0000C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600005E0000C6FFC600C6FF
      C600005E0000000000000000000000000000000000000000000000000000C663
      0000FFCD9B008040000080400000FFCD9B008040000080400000FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A00E0E0E0004A4A4A004A4A4A004A4A4A00E0E0E0004A4A4A004A4A4A00E0E0
      E0005252520000000000000000000000000000000000000000000000000000B9
      0000C6FFC600005E0000C6FFC600C6FFC600005E0000C6FFC600005E0000C6FF
      C600005E0000000000000000000000000000000000000000000000000000C663
      0000FFCD9B00FFCD9B0080400000FFCD9B008040000080400000FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A00E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0
      E0005252520000000000000000000000000000000000000000000000000000B9
      0000C6FFC600C6FFC600005E0000C6FFC600005E0000C6FFC600C6FFC600C6FF
      C600005E0000000000000000000000000000000000000000000000000000C663
      0000FFCD9B00FFCD9B0080400000FFCD9B00FFCD9B0080400000FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A00E0E0E0004A4A4A004A4A4A00E0E0E0004A4A4A004A4A4A004A4A4A00E0E0
      E0005252520000000000000000000000000000000000000000000000000000B9
      0000C6FFC600C6FFC600C6FFC600005E0000C6FFC600C6FFC600C6FFC600C6FF
      C600005E0000000000000000000000000000000000000000000000000000C663
      0000FFCD9B00FFCD9B008040000080400000FFCD9B0080400000FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000007A7A
      7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A00E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0E000E0E0
      E0005252520000000000000000000000000000000000000000000000000000B9
      0000C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FFC600C6FF
      C600005E0000000000000000000000000000000000000000000000000000C663
      0000FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD9B008040000080400000FFCD
      9B00663300000000000000000000000000000000000000000000000000007A7A
      7A007A7A7A007A7A7A007A7A7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000007A7A
      7A007A7A7A007A7A7A007A7A7A00E0E0E0004A4A4A004A4A4A004A4A4A00E0E0
      E0005252520000000000000000000000000000000000000000000000000000B9
      000000B9000000B9000000B90000C6FFC600C6FFC600C6FFC600C6FFC600C6FF
      C600005E0000000000000000000000000000000000000000000000000000C663
      0000C6630000C6630000C6630000FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000000000
      00007A7A7A007A7A7A007A7A7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000000000
      00007A7A7A007A7A7A007A7A7A00E0E0E000E0E0E000E0E0E000E0E0E000E0E0
      E000525252000000000000000000000000000000000000000000000000000000
      000000B9000000B9000000B90000C6FFC600C6FFC600C6FFC600C6FFC600C6FF
      C600005E00000000000000000000000000000000000000000000000000000000
      0000C6630000C6630000C6630000FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000000000
      0000000000007A7A7A007A7A7A00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00525252000000000000000000000000000000000000000000000000000000
      0000000000007A7A7A007A7A7A00E0E0E000E0E0E000E0E0E000E0E0E000E0E0
      E000525252000000000000000000000000000000000000000000000000000000
      00000000000000B9000000B90000C6FFC600C6FFC600C6FFC600C6FFC600C6FF
      C600005E00000000000000000000000000000000000000000000000000000000
      000000000000C6630000C6630000FFCD9B00FFCD9B00FFCD9B00FFCD9B00FFCD
      9B00663300000000000000000000000000000000000000000000000000000000
      000000000000000000007A7A7A007A7A7A007A7A7A007A7A7A007A7A7A007A7A
      7A00525252000000000000000000000000000000000000000000000000000000
      000000000000000000007A7A7A007A7A7A007A7A7A007A7A7A007A7A7A007A7A
      7A00525252000000000000000000000000000000000000000000000000000000
      0000000000000000000000B9000000B9000000B9000000B9000000B9000000B9
      0000005E00000000000000000000000000000000000000000000000000000000
      00000000000000000000C6630000C6630000C6630000C6630000C6630000C663
      0000663300000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000600000000100010000000000000300000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFF0000FFFFFC03FFFF0000
      E007FC03E0070000E007FC03E0070000E007FC03E0070000E007C003E0070000
      E007C003E0070000E007C003E0070000E007C003E0070000E007C003E0070000
      E007C003E0070000F007C03FF0070000F807C03FF8070000FC07E03FFC070000
      FFFFF03FFFFF0000FFFFFFFFFFFF0000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FC3FE667E007E007F81FC003E007E007F81FC003E007E007E007C003E007E007
      C003C003E007E007C003C003E007E007C003C003E007E007C003E403E007E007
      E007FC03E007E007F81FFC27F007F007F81FFC3FF807F807FC3FFE7FFC07FC07
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      E007E007E007E007C003C003C003C003C003C003C003C003C003C003C003C003
      C003C003C003C003C003C003C003C003C003C003C003C003C003C003C003C003
      C003C003C003C003C003C003C003C003C003C003C003C003E007E007E007E007
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      E007E007FFFFF803E007E007E007F803E007E007C003F803E007E007C003F803
      E007E007C003F803E007E007C003C003E007E007C003C003E007E007C003C01F
      E007E007C003C01FF007F007E007C01FF807F807FF0FC01FFC07FC07FFFFC01F
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      E007E007E007E007E007E007E007E007E007E007E007E007E007E007E007E007
      E007E007E007E007E007E007E007E007E007E007E007E007E007E007E007E007
      E007E007E007E007F007F007F007F007F807F807F807F807FC07FC07FC07FC07
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object PM_ArchiveTool: TPopupMenu
    Images = ImageList_Archiver
    OnPopup = PM_ArchiveToolPopup
    Left = 579
    Top = 511
    object M_Arc_Extract: TMenuItem
      Caption = 'Extract selected'
      Default = True
      ImageIndex = 8
      OnClick = SB_ExtractFileClick
    end
    object M_Arc_ExtractAll: TMenuItem
      Caption = 'Extract all files'
      ImageIndex = 9
      OnClick = SB_ExtractAllClick
    end
    object M_Arc_RAW: TMenuItem
      Caption = 'RAW Mode'
      ImageIndex = 10
      object M_Arc_ExtRAW: TMenuItem
        Caption = 'Extract selected'
        ImageIndex = 8
        OnClick = M_Arc_ExtRAWClick
      end
      object M_Arc_ExtAllRAW: TMenuItem
        Caption = 'Extract all files'
        ImageIndex = 9
        OnClick = M_Arc_ExtAllRAWClick
      end
    end
    object N10: TMenuItem
      Tag = -1
      Caption = '-'
    end
    object M_Arc_ListGen: TMenuItem
      Caption = 'Generate file order list'
      ImageIndex = 16
      OnClick = M_Arc_ListGenClick
    end
    object N12: TMenuItem
      Caption = '-'
    end
    object M_Arc_CreateArchive: TMenuItem
      Caption = 'Create archive...'
      ImageIndex = 12
      object M_Arc_SubFiles: TMenuItem
        Caption = '...from files'
        ImageIndex = 0
        OnClick = M_Arc_FilesClick
      end
      object N8: TMenuItem
        Tag = -1
        Caption = '-'
      end
      object M_Arc_SubDirectory: TMenuItem
        Caption = '...from directory'
        ImageIndex = 6
        OnClick = M_Arc_DirectoryClick
      end
      object N9: TMenuItem
        Tag = -1
        Caption = '-'
      end
      object M_Arc_SubList: TMenuItem
        Caption = '...from list'
        ImageIndex = 16
        OnClick = M_Arc_CreateFromListClick
      end
    end
    object N2: TMenuItem
      Tag = -1
      Caption = '-'
    end
    object M_Arc_Special: TMenuItem
      Caption = 'Special...'
      ImageIndex = 13
      object M_Arc_HTMLList: TMenuItem
        Caption = 'Generate HTML file list'
        ImageIndex = 16
        OnClick = M_Arc_HTMLListClick
      end
      object N11: TMenuItem
        Caption = '-'
      end
      object M_Arc_HTMLListDir: TMenuItem
        Caption = 'Generate HTML file list from directory'
        ImageIndex = 6
        OnClick = M_Arc_HTMLListDirClick
      end
      object N1: TMenuItem
        Tag = -1
        Caption = '-'
      end
      object M_Arc_HTMLFormatList: TMenuItem
        Caption = '[Debug] Generate HTML format list'
        ImageIndex = 17
        OnClick = M_Arc_HTMLFormatListClick
      end
      object M_Arc_FormatsWriteIntoConsole: TMenuItem
        Caption = '[Debug] Write format list into console'
        ImageIndex = 17
        OnClick = M_Arc_FormatsWriteIntoConsoleClick
      end
      object N15: TMenuItem
        Caption = '-'
      end
      object M_Arc_GetHashes: TMenuItem
        Caption = 'Calculate archive'#39's CRC32 and MD5 hashes'
        ImageIndex = 1
        OnClick = M_Arc_GetHashesClick
      end
      object N7: TMenuItem
        Tag = -1
        Caption = '-'
      end
      object M_Arc_HiddenDataCheck: TMenuItem
        Caption = '[Debug] Hidden data check'
        ImageIndex = 18
        OnClick = M_Arc_HiddenDataCheckClick
      end
      object N16: TMenuItem
        Caption = '-'
      end
      object M_Arc_FragmentationCheck: TMenuItem
        Caption = '[Debug] Fragmentation check'
        ImageIndex = 13
        OnClick = M_Arc_FragmentationCheckClick
      end
    end
    object N5: TMenuItem
      Tag = -1
      Caption = '-'
    end
    object M_Arc_View: TMenuItem
      Caption = 'View as...'
      ImageIndex = 7
      object M_Arc_Icons: TMenuItem
        AutoCheck = True
        Caption = 'Icons'
        RadioItem = True
        OnClick = M_Arc_IconsClick
      end
      object M_Arc_Report: TMenuItem
        AutoCheck = True
        Caption = 'Report'
        Checked = True
        RadioItem = True
        OnClick = M_Arc_ReportClick
      end
    end
    object N3: TMenuItem
      Tag = -1
      Caption = '-'
    end
    object M_Arc_Properties: TMenuItem
      Caption = 'Properties'
      ImageIndex = 11
      OnClick = M_Arc_PropertiesClick
    end
  end
  object PM_ArchiveToolCreate: TPopupMenu
    Images = ImageList_Archiver
    TrackButton = tbLeftButton
    Left = 549
    Top = 511
    object M_Arc_Files: TMenuItem
      Caption = 'Create from files'
      ImageIndex = 0
      OnClick = M_Arc_FilesClick
    end
    object N4: TMenuItem
      Tag = -1
      Caption = '-'
    end
    object M_Arc_Directory: TMenuItem
      Caption = 'Create from directory'
      ImageIndex = 6
      OnClick = M_Arc_DirectoryClick
    end
    object N6: TMenuItem
      Tag = -1
      Caption = '-'
    end
    object M_Arc_List: TMenuItem
      Caption = 'Create from list'
      ImageIndex = 16
      OnClick = M_Arc_CreateFromListClick
    end
  end
  object ColorDialog: TColorDialog
    Color = clCream
    Options = [cdFullOpen]
    Left = 231
    Top = 511
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Lucida Console'
    Font.Style = []
    Left = 200
    Top = 511
  end
  object PM_GrayScale: TPopupMenu
    Images = ImageList_EDGE
    Left = 393
    Top = 511
    object SM_EDGE_GS_ArithmeticMean: TMenuItem
      Caption = 'Arithmetic mean'
      ImageIndex = 24
      OnClick = SM_EDGE_GS_ArithmeticMeanClick
    end
    object SM_EDGE_GS_Luma: TMenuItem
      Caption = 'Classic Luma'
      ImageIndex = 24
      OnClick = SM_EDGE_GS_LumaClick
    end
    object SM_EDGE_GS_HDR: TMenuItem
      Caption = 'HDR \ Luma (More natural)'
      ImageIndex = 24
      OnClick = SM_EDGE_GS_HDRClick
    end
    object SM_EDGE_GS_Red: TMenuItem
      Caption = 'Red channel only'
      ImageIndex = 11
      OnClick = SM_EDGE_GS_RedClick
    end
    object SM_EDGE_GS_Green: TMenuItem
      Caption = 'Green channel only'
      ImageIndex = 12
      OnClick = SM_EDGE_GS_GreenClick
    end
    object SM_EDGE_GS_Blue: TMenuItem
      Caption = 'Blue channel only'
      ImageIndex = 13
      OnClick = SM_EDGE_GS_BlueClick
    end
  end
  object ImageList_EDGE: TImageList
    BlendColor = clFuchsia
    DrawingStyle = dsTransparent
    ShareImages = True
    Left = 262
    Top = 511
    Bitmap = {
      494C01011B001D00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000008000000001002000000000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000FFFFFF00ECECEC00ECECEC00ECEC
      EC00ECECEC00ECECEC00ECECEC00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000FFFFFF00F6EA0000F6EA0000F6EA
      0000F6EA0000F6EA0000F6EA0000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000000000000000
      0000FFFFFF00000000000000000000000000FFFFFF00D4D4D400D4D4D400D4D4
      D400D4D4D400D4D4D400D4D4D400FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000FFFFFF00D5B70100D5B70100D5B7
      0100D5B70100D5B70100D5B70100FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000000000000000
      000000000000000000000000000000000000FFFFFF00C4C4C400C4C4C400C4C4
      C400C4C4C400C4C4C400C4C4C400FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000FFFFFF00FF9D0900FF9D0900FF9D
      0900FF9D0900FF9D0900FF9D0900FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00ACACAC00ACACAC00ACAC
      AC00ACACAC00ACACAC00ACACAC00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00DE900000DE900000DE90
      0000DE900000DE900000DE900000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0094949400949494009494
      9400949494009494940094949400FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00F6880000F6880000F688
      0000F6880000F6880000F6880000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000EC8B0000EC8B0000EC8B
      0000EC8B0000EC8B0000EC8B000000000000FFFFFF0080808000808080008080
      8000808080008080800080808000FFFFFF00000000001BCB38001BCB38001BCB
      38001BCB38001BCB38001BCB3800000000000000000000000000000000000000
      000000000000000000000000000000000000000000000915FF000915FF000915
      FF000915FF000915FF000915FF0000000000FFFFFF00F6710000F6710000F671
      0000F6710000F6710000F6710000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000ECD90000ECD90000ECD9
      0000ECD90000ECD90000ECD9000000000000FFFFFF0060606000606060006060
      6000606060006060600060606000FFFFFF0000000000159F2C00159F2C00159F
      2C00159F2C00159F2C00159F2C00000000000000000000000000000000000000
      000000000000000000000000000000000000000000002A48FE002A48FE002A48
      FE002A48FE002A48FE002A48FE0000000000FFFFFF00E6540000E6540000E654
      0000E6540000E6540000E6540000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000EC380000EC380000EC
      380000EC380000EC380000EC380000000000FFFFFF0040404000404040004040
      40004040400040404000FFFFFF0000000000000000001BCB38001BCB38001BCB
      38001BCB38001BCB38001BCB3800000000000000000000000000000000000000
      000000000000000000000000000000000000000000000062F6000062F6000062
      F6000062F6000062F6000062F60000000000FFFFFF00B1530300B1530300B153
      0300B1530300B1530300FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000EC8B0000EC8B0000EC
      8B0000EC8B0000EC8B0000EC8B0000000000FFFFFF0020202000202020002020
      200020202000FFFFFF000000000000000000000000001DD93C001DD93C001DD9
      3C001DD93C001DD93C001DD93C00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000216FFF00216FFF00216F
      FF00216FFF00216FFF00216FFF0000000000FFFFFF00E6490000E6490000E649
      0000E6490000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000ECD90000ECD90000EC
      D90000ECD90000ECD90000ECD90000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000001DD93C001DD93C001DD9
      3C001DD93C001DD93C001DD93C00000000000000000000000000000000000000
      000000000000000000000000000000000000000000000977FF000977FF000977
      FF000977FF000977FF000977FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000C2EC0000C2EC0000C2
      EC0000C2EC0000C2EC0000C2EC00000000000000000000000000000000000000
      000000000000000000000000000000000000000000001AC436001AC436001AC4
      36001AC436001AC436001AC43600000000000000000000000000000000000000
      00000000000000000000000000000000000000000000098EFF00098EFF00098E
      FF00098EFF00098EFF00098EFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000008BEC00008BEC00008B
      EC00008BEC00008BEC00008BEC00000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000025E3440025E3440025E3
      440025E3440025E3440025E34400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000019ABFF0019ABFF0019AB
      FF0019ABFF0019ABFF0019ABFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000053EC000053EC000053
      EC000053EC000053EC0000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000019BD340019BD340019BD
      340019BD340019BD340000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000004EACFC004EACFC004EAC
      FC004EACFC004EACFC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000003800EC003800EC003800
      EC003800EC000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000000000001DD93C001DD93C001DD9
      3C001DD93C000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000019B6FF0019B6FF0019B6
      FF0019B6FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000350DFF00350DFF00000000000000
      00000000000000000000350DFF00350DFF000000000000000000000000000000
      0000000000000000000000000000000000000000000015768100157681001576
      8100157681001576810015768100157681000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000B0501000B0501000B050
      1000B0501000B0501000B0501000000000000000000000000000000000000000
      000000000000000000000000000000000000350DFF00350DFF00350DFF000000
      000000000000350DFF00350DFF00350DFF000000000000000000000000000000
      0000000000000000000000000000000000001576810005E5F30005E5F30005E5
      F30005E5F30005E5F30015768100157681000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E18D5500D67A3C00D67A3C00D67A
      3C00D67A3C00D67A3C00D67A3C00B05010000000000000000000000000000000
      00000000000000000000000000000000000000000000350DFF00350DFF00350D
      FF00350DFF00350DFF00350DFF00000000000000000000000000000000000000
      00000000000000000000000000001576810005E5F30005E5F30005E5F30005E5
      F30005E5F3001576810005E5F300157681000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E18D5500D67A3C00D67A3C00D67A
      3C00D67A3C00D67A3C00D67A3C00B05010000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00350DFF00350D
      FF00350DFF00350DFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF001576810005E5F30005E5F30005E5F30005E5F30005E5
      F3001576810005E5F30005E5F300157681000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E18D5500D67A3C00D67A3C00D67A
      3C00D67A3C00D67A3C00D67A3C00B05010000000000000000000FFFFFF008080
      80008080800080808000808080008080800080808000FFFFFF00350DFF00350D
      FF00350DFF00350DFF0000000000000000000000000000000000FFFFFF008080
      8000808080008080800015768100157681001576810015768100157681001576
      810005E5F30005E5F30005E5F300157681000000000000000000FFFFFF008080
      80008080800080808000808080008080800080808000FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00000000000000000000000000FFFFFF008080
      800080808000808080008080800080808000E18D5500D67A3C00C0C0C000C0C0
      C000C0C0C000C0C0C000D67A3C00B05010000000000000000000000000000000
      00000000000000000000000000000000000080808000350DFF00350DFF00350D
      FF00350DFF00350DFF00350DFF00000000000000000000000000000000000000
      0000000000000000000000000000000000001576810005E5F30005E5F30005E5
      F30005E5F30005E5F30005E5F300157681000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E18D5500D67A3C00C0C0C000C0C0
      C000B0501000C0C0C000D67A3C00B050100000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000350DFF00350DFF00350DFF000000
      000000000000350DFF00350DFF00350DFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000008080800015768100157681001576
      810005E5F30005E5F30005E5F3001576810000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000E18D5500D67A3C00C0C0C000C0C0
      C000B0501000C0C0C000D67A3C00B050100000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF0000000000350DFF00350DFF00000000000000
      00000000000000000000350DFF00350DFF0000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00001576810015768100157681000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000E18D5500E18D5500E18D
      5500E18D5500E18D5500E18D55000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF0000000000FFFFFF00FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF0000000000FFFFFF00FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF0000000000FFFFFF00FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF0000000000FFFFFF00FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000350DFF00350DFF00000000000000
      00000000000000000000350DFF00350DFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000350DFF00350DFF00350DFF000000
      000000000000350DFF00350DFF00350DFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000FFFFFF0000000000000000000000
      0000000000000000000000000000FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000350DFF00350DFF00350D
      FF00350DFF00350DFF00350DFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000FFFFFF0000000000FFFFFF000000
      000000000000FFFFFF0000000000FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000350DFF00350D
      FF00350DFF00350DFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000FFFFFF0000000000FFFFFF000000
      000000000000FFFFFF0000000000FFFFFF000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000350DFF00350D
      FF00350DFF00350DFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF000000000000000000FFFFFF008080
      8000808080008080800080808000808080008080800000FF000000FF000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000350DFF00350DFF00350D
      FF00350DFF00350DFF00350DFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000000000FFFFFF000000
      000000000000FFFFFF0000000000FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF000000000000FF
      000000FF000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000350DFF00350DFF00350DFF000000
      000000000000350DFF00350DFF00350DFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000080808000FFFFFF000000000000FF
      000000FF000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF0000000000350DFF00350DFF00000000000000
      00000000000000000000350DFF00350DFF0000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000000000000000
      0000000000000000000000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000000000000000
      00000000000000000000FFFFFF000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF0000000000FFFFFF0000000000000000000000
      000000000000FFFFFF00000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF0000000000FFFFFF00FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000015768100157681001576
      8100157681001576810015768100157681000000000000000000000000000000
      00000000000000000000000000000000000000000000B0501000B0501000B050
      1000B0501000B0501000B050100000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000FFFFFF00DFFFD900DFFFD900DFFF
      D900DFFFD900DFFFD900DFFFD900FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFDED900FFDED900FFDE
      D900FFDED900FFDED900FFDED900FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000001576810005E5F30005E5F30005E5
      F30005E5F30005E5F30015768100157681000000000000000000000000000000
      000000000000000000000000000000000000E18D5500D67A3C00D67A3C00D67A
      3C00D67A3C00D67A3C00D67A3C00B0501000FFFFFF0000000000000000000000
      0000FFFFFF00000000000000000000000000FFFFFF00B7FFA900B7FFA900FFFF
      FF00FFFFFF00B7FFA900B7FFA900FFFFFF00FFFFFF0000000000000000000000
      0000FFFFFF00000000000000000000000000FFFFFF00FFB5A900FFFFFF00FFFF
      FF00FFFFFF00FFB5A900FFB5A900FFFFFF000000000000000000000000000000
      00000000000000000000000000001576810005E5F30005E5F30005E5F30005E5
      F30005E5F3001576810005E5F300157681000000000000000000000000000000
      000000000000000000000000000000000000E18D5500D67A3C00D67A3C00D67A
      3C00D67A3C00D67A3C00D67A3C00B0501000FFFFFF0000000000000000000000
      000000000000000000000000000000000000FFFFFF009CFF8900FFFFFF009CFF
      89009CFF8900FFFFFF009CFF8900FFFFFF00FFFFFF0000000000000000000000
      000000000000000000000000000000000000FFFFFF00FF9A8900FFFFFF00FF9A
      8900FF9A8900FFFFFF00FF9A8900FFFFFF000000000000000000000000000000
      000000000000000000001576810005E5F30005E5F30005E5F30005E5F30005E5
      F3001576810005E5F30005E5F300157681000000000000000000000000000000
      000000000000000000000000000000000000E18D5500D67A3C00D67A3C00D67A
      3C00D67A3C00D67A3C00D67A3C00B05010000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0074FF5900FFFFFF0074FF
      5900FFFFFF00FFFFFF0074FF5900FFFFFF000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FF715900FFFFFF00FFFF
      FF00FFFFFF00FF715900FF715900FFFFFF000000000000000000000000000000
      0000000000000000000015768100157681001576810015768100157681001576
      810005E5F30005E5F30005E5F300157681000000000000000000000000000000
      000000000000000000000000000000000000E18D5500D67A3C00C0C0C000C0C0
      C000C0C0C000C0C0C000D67A3C00B05010000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF004CFF2900FFFFFF004CFF
      29004CFF29004CFF29004CFF2900FFFFFF000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FF472900FFFFFF00FF47
      2900FF472900FFFFFF00FF472900FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000001576810005E5F30005E5F30005E5
      F30005E5F30005E5F30005E5F300157681000000000000000000000000000000
      000000000000000000000000000000000000E18D5500D67A3C00C0C0C000C0C0
      C000B0501000C0C0C000D67A3C00B050100000000000EC8B0000EC8B0000EC8B
      0000EC8B0000EC8B0000EC8B000000000000FFFFFF002BFF01002BFF0100FFFF
      FF00FFFFFF00FFFFFF002BFF0100FFFFFF0000000000EC8B0000EC8B0000EC8B
      0000EC8B0000EC8B0000EC8B000000000000FFFFFF00FF250100FFFFFF00FFFF
      FF00FFFFFF00FF250100FF250100FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000015768100157681001576
      810005E5F30005E5F30005E5F3001576810000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000E18D5500D67A3C00C0C0C000C0C0
      C000B0501000C0C0C000D67A3C00B050100000000000ECD90000ECD90000ECD9
      0000ECD90000ECD90000ECD9000000000000FFFFFF0020C0000020C0000020C0
      000020C0000020C0000020C00000FFFFFF0000000000ECD90000ECD90000ECD9
      0000ECD90000ECD90000ECD9000000000000FFFFFF00C01B0000C01B0000C01B
      0000C01B0000C01B0000C01B0000FFFFFF0000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00001576810015768100157681000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF000000000000000000E18D5500E18D5500E18D
      5500E18D5500E18D5500E18D5500000000000000000000EC380000EC380000EC
      380000EC380000EC380000EC380000000000FFFFFF0015800000158000001580
      00001580000015800000FFFFFF00000000000000000000EC380000EC380000EC
      380000EC380000EC380000EC380000000000FFFFFF0080120000801200008012
      00008012000080120000FFFFFF000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000EC8B0000EC8B0000EC
      8B0000EC8B0000EC8B0000EC8B0000000000FFFFFF000B4000000B4000000B40
      00000B400000FFFFFF0000000000000000000000000000EC8B0000EC8B0000EC
      8B0000EC8B0000EC8B0000EC8B0000000000FFFFFF0040090000400900004009
      000040090000FFFFFF00000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000ECD90000ECD90000EC
      D90000ECD90000ECD90000ECD90000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000ECD90000ECD90000EC
      D90000ECD90000ECD90000ECD90000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000C2EC0000C2EC0000C2
      EC0000C2EC0000C2EC0000C2EC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000C2EC0000C2EC0000C2
      EC0000C2EC0000C2EC0000C2EC00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000008BEC00008BEC00008B
      EC00008BEC00008BEC00008BEC00000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000000000008BEC00008BEC00008B
      EC00008BEC00008BEC00008BEC00000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000000000000000000000000000000000000053EC000053EC000053
      EC000053EC000053EC0000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00000000000053EC000053EC000053
      EC000053EC000053EC0000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000003800EC003800EC003800
      EC003800EC000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000000000003800EC003800EC003800
      EC003800EC000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000FFFFFF00D9D9FF00D9D9FF00D9D9
      FF00D9D9FF00D9D9FF00D9D9FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFFFF0000000000000000000000
      0000FFFFFF00000000000000000000000000FFFFFF00A9A9FF00FFFFFF00A9A9
      FF00A9A9FF00FFFFFF00A9A9FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF00FF000000FF000000FF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000FF000000FF00FFFFFF0000000000000000000000
      000000000000000000000000000000000000FFFFFF008989FF00FFFFFF008989
      FF008989FF00FFFFFF008989FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF00FF000000FF000000FF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000FF000000FF000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF005959FF00FFFFFF00FFFF
      FF00FFFFFF005959FF005959FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000FF000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF002929FF00FFFFFF002929
      FF002929FF00FFFFFF002929FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF00FFFFFF00FFFFFF000000
      FF000000FF00FFFFFF00FFFFFF000000FF0000000000EC8B0000EC8B0000EC8B
      0000EC8B0000EC8B0000EC8B000000000000FFFFFF000101FF00FFFFFF00FFFF
      FF00FFFFFF000101FF000101FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF0000000000ECD90000ECD90000ECD9
      0000ECD90000ECD90000ECD9000000000000FFFFFF000000C0000000C0000000
      C0000000C0000000C0000000C000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000EC380000EC380000EC
      380000EC380000EC380000EC380000000000FFFFFF0000008000000080000000
      80000000800000008000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000EC8B0000EC8B0000EC
      8B0000EC8B0000EC8B0000EC8B0000000000FFFFFF0000004000000040000000
      400000004000FFFFFF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000ECD90000ECD90000EC
      D90000ECD90000ECD90000ECD90000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000C2EC0000C2EC0000C2
      EC0000C2EC0000C2EC0000C2EC00000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF0000000000008BEC00008BEC00008B
      EC00008BEC00008BEC00008BEC00000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00000000000053EC000053EC000053
      EC000053EC000053EC0000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00000000003800EC003800EC003800
      EC003800EC000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FAEFFB00F6DFF700F2D1F400EFC4
      F200ECB9EF00EAB1EE00E8ABEC00E7A8EC00E7A7EC00E8AAEC00EAB0ED00ECB8
      EF00EFC3F100F2CFF400F6DDF700FAEDFA0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F4DFED00EECFE400E9BFDB00E4B1
      D400E0A5CD00DD9CC800DB95C400DA91C200D991C200DB94C400DD9BC700E0A4
      CC00E4B0D300E8BDDA00EECDE300F3DDEC0000FF000000FF000000FF0000FFFF
      FF00FFFFFF0000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF0000FFFF
      FF00FFFFFF0000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00ECD2D80000008000DEAFBA00D8A0
      AD0000008000CE879800800000008000000080000000CA7F9000CD869700D291
      A0000055000000550000E4BEC600EBCFD60000FF000000FF000000FF0000FFFF
      FF00FFFFFF0000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF0000FFFF
      FF00FFFFFF0000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EACFC50000008000DCB1A000D6A3
      8F0000008000CC8C730080000000C7806500C780640080000000CC8B72000055
      0000D5A18D00DCAF9E0000550000E9CDC30000FF0000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF0000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000FF0000FF00FF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00EFDABB0000008000000080000000
      8000DEB16F00DBA96000800000008000000080000000D8A25400DBA85F000055
      0000E2B97E000055000000550000EFD8B80000FF0000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF0000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000FF0000FF00FF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F7E9B30000008000F3DD8800F1D7
      740000008000EDCD4F0080000000EBC73800EBC6370080000000EDCC4D000055
      0000F1D77200F3DC8600F5E29B00F7E8B00000FF000000FF000000FF0000FFFF
      FF00FFFFFF0000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF0000FFFF
      FF00FFFFFF0000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F8F5AD0000008000000080000000
      8000F2EC5600F0E94200800000008000000080000000EFE72D00F0E93F00F2EB
      54000055000000550000F7F39400F8F5AA0000FF000000FF000000FF0000FFFF
      FF00FFFFFF0000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF0000FFFF
      FF00FFFFFF0000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E4F0AA00DDEC9400D6E97E00CFE5
      6700C7E15100C0DD3A00B9D92400B3D61000B2D60E00B8D92200BFDD3700C7E0
      4E00CEE46400D5E87B00DCEC9100E3F0A70000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CFEBAA00C3E59400B6E07E00AADB
      67009DD5510091D03B0085CB25007AC7120079C6100083CA22008FCF38009CD5
      4E00A8DA6500B5DF7B00C1E59100CEEAA80000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C0E8B300000080009EDC8B008ED6
      7700000080006ECB500060C6400000550000005500005FC63E006CCA4E008000
      00008000000080000000ADE19C00BEE8B00000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00BEF0CE00000080009AE7B4008AE3
      A700000080006ADC90000055000057D8810057D781000055000069DC8E008000
      000087E3A50098E7B20080000000BCEFCD0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C1F7E80000008000000080000000
      80007CEFCF006FEDCA00005500005EEBC40000550000005500006DEDCA008000
      00008000000080000000ACF5E100BFF7E70000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C7FBFB0000008000A3F9FA0092F8
      F9000000800078F6F7000055000069F5F60069F5F6006EF5F70076F6F7008000
      000090F7F900A1F9F90080000000C5FBFB0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00D3EFFF0000008000000080000000
      800094D9FF008AD5FF0082D3FF00005500000055000081D2FF0088D5FF008000
      00008000000080000000BFE8FF00D1EFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00E1E9FF00D1DCFF00C1D1FF00B4C6
      FF00A8BDFF009EB6FF0098B1FF0094AEFF0094AEFF0097B1FF009DB5FF00A6BC
      FF00B2C5FF00C0CFFF00CFDBFF00DFE7FF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00F4F1FF00EAE1FF00E0D3FF00D8C7
      FF00D1BCFF00CBB4FF00C7AEFF00C5ABFF00C5AAFF00C7ADFF00CBB3FF00D0BB
      FF00D7C5FF00DFD1FF00E9DFFF00F3EFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FF0000FF00FF00FF00FF00FF00FF00FF00
      FF00FF00FF00FF00FF00FF00FF00FF00FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FAEFFB00F6DFF700F2D1F400EFC4
      F200ECB9EF00EAB1EE00E8ABEC00E7A8EC00E7A7EC00E8AAEC00EAB0ED00ECB8
      EF00EFC3F100F2CFF400F6DDF700FAEDFA00FAEFFB00F6DFF700F2D1F400EFC4
      F200ECB9EF00EAB1EE00E8ABEC00E7A8EC00E7A7EC00E8AAEC00EAB0ED00ECB8
      EF00EFC3F100F2CFF400F6DDF700FAEDFA00FAEFFB00F6DFF700F2D1F400EFC4
      F200ECB9EF00EAB1EE00E8ABEC00E7A8EC00E7A7EC00E8AAEC00EAB0ED00ECB8
      EF00EFC3F100F2CFF400F6DDF700FAEDFA00FAEFFB00F6DFF700F2D1F400EFC4
      F200ECB9EF00EAB1EE00E8ABEC00E7A8EC00E7A7EC00E8AAEC00EAB0ED00ECB8
      EF00EFC3F100F2CFF400F6DDF700FAEDFA00F4DFED00EECFE400E9BFDB00E4B1
      D400E0A5CD00DD9CC800DB95C400DA91C200D991C200DB94C400DD9BC700E0A4
      CC00E4B0D300E8BDDA00EECDE300F3DDEC00F4DFED00EECFE400E9BFDB00E4B1
      D400E0A5CD00DD9CC800DB95C400DA91C200D991C200DB94C400DD9BC700E0A4
      CC00E4B0D300E8BDDA00EECDE300F3DDEC00F4DFED00EECFE400E9BFDB00E4B1
      D400E0A5CD00DD9CC800DB95C400DA91C200D991C200DB94C400DD9BC700E0A4
      CC00E4B0D300E8BDDA00EECDE300F3DDEC00F4DFED00EECFE400E9BFDB00E4B1
      D400E0A5CD00DD9CC800DB95C400DA91C200D991C200DB94C400DD9BC700E0A4
      CC00E4B0D300E8BDDA00EECDE300F3DDEC00ECD2D80080000000800000008000
      0000D292A100CE879800CB8091000055000000550000CA7F9000CD8697000000
      8000D79EAB00DDADB80000008000EBCFD600ECD2D80080000000800000008000
      0000D292A100CE87980000008000C97C8D00C97C8D0000008000CD869700D291
      A0000055000000550000E4BEC600EBCFD600ECD2D800E5C0C800005500000055
      0000D292A100CE879800800000008000000080000000CA7F9000CD8697000000
      8000D79EAB00DDADB80000008000EBCFD600ECD2D800E5C0C800005500000055
      0000D292A100CE87980000008000C97C8D00C97C8D0000008000CD8697008000
      00008000000080000000E4BEC600EBCFD600EACFC50080000000DCB1A000D6A3
      8F0080000000CC8C730000550000C7806500C780640000550000CC8B72000000
      8000D5A18D00DCAF9E0000008000E9CDC300EACFC50080000000DCB1A000D6A3
      8F0080000000CC8C730000008000C7806500C780640000008000CC8B72000055
      0000D5A18D00DCAF9E0000550000E9CDC300EACFC50000550000DCB1A000D6A3
      8F0000550000CC8C730080000000C7806500C780640080000000CC8B72000000
      8000D5A18D00DCAF9E0000008000E9CDC300EACFC50000550000DCB1A000D6A3
      8F0000550000CC8C730000008000C7806500C780640000008000CC8B72008000
      0000D5A18D00DCAF9E0080000000E9CDC300EFDABB0080000000800000008000
      0000DEB16F00DBA9600000550000D79F4E000055000000550000DBA85F000000
      80000000800000008000EACDA400EFD8B800EFDABB0080000000800000008000
      0000DEB16F00DBA96000000080000000800000008000D8A25400DBA85F000055
      0000E2B97E000055000000550000EFD8B800EFDABB0000550000E6C493000055
      000000550000DBA96000800000008000000080000000D8A25400DBA85F000000
      80000000800000008000EACDA400EFD8B800EFDABB0000550000E6C493000055
      000000550000DBA96000000080000000800000008000D8A25400DBA85F008000
      00008000000080000000EACDA400EFD8B800F7E9B30080000000F3DD8800F1D7
      740080000000EDCD4F0000550000EBC73800EBC63700ECC93F00EDCC4D000000
      8000F1D77200F3DC860000008000F7E8B000F7E9B30080000000F3DD8800F1D7
      740080000000EDCD4F0000008000EBC73800EBC6370000008000EDCC4D000055
      0000F1D77200F3DC8600F5E29B00F7E8B000F7E9B30000550000F3DD8800F1D7
      7400EFD26100EDCD4F0080000000EBC73800EBC6370080000000EDCC4D000000
      8000F1D77200F3DC860000008000F7E8B000F7E9B30000550000F3DD8800F1D7
      7400EFD26100EDCD4F0000008000EBC73800EBC6370000008000EDCC4D008000
      0000F1D77200F3DC860080000000F7E8B000F8F5AD0080000000800000008000
      0000F2EC5600F0E94200EFE72F000055000000550000EFE72D00F0E93F000000
      80000000800000008000F7F39400F8F5AA00F8F5AD0080000000800000008000
      0000F2EC5600F0E94200000080000000800000008000EFE72D00F0E93F00F2EB
      54000055000000550000F7F39400F8F5AA00F8F5AD00F7F39700005500000055
      0000F2EC5600F0E94200800000008000000080000000EFE72D00F0E93F000000
      80000000800000008000F7F39400F8F5AA00F8F5AD00F7F39700005500000055
      0000F2EC5600F0E94200000080000000800000008000EFE72D00F0E93F008000
      00008000000080000000F7F39400F8F5AA00E4F0AA00DDEC9400D6E97E00CFE5
      6700C7E15100C0DD3A00B9D92400B3D61000B2D60E00B8D92200BFDD3700C7E0
      4E00CEE46400D5E87B00DCEC9100E3F0A700E4F0AA00DDEC9400D6E97E00CFE5
      6700C7E15100C0DD3A00B9D92400B3D61000B2D60E00B8D92200BFDD3700C7E0
      4E00CEE46400D5E87B00DCEC9100E3F0A700E4F0AA00DDEC9400D6E97E00CFE5
      6700C7E15100C0DD3A00B9D92400B3D61000B2D60E00B8D92200BFDD3700C7E0
      4E00CEE46400D5E87B00DCEC9100E3F0A700E4F0AA00DDEC9400D6E97E00CFE5
      6700C7E15100C0DD3A00B9D92400B3D61000B2D60E00B8D92200BFDD3700C7E0
      4E00CEE46400D5E87B00DCEC9100E3F0A700CFEBAA00C3E59400B6E07E00AADB
      67009DD5510091D03B0085CB25007AC7120079C6100083CA22008FCF38009CD5
      4E00A8DA6500B5DF7B00C1E59100CEEAA800CFEBAA00C3E59400B6E07E00AADB
      67009DD5510091D03B0085CB25007AC7120079C6100083CA22008FCF38009CD5
      4E00A8DA6500B5DF7B00C1E59100CEEAA800CFEBAA00C3E59400B6E07E00AADB
      67009DD5510091D03B0085CB25007AC7120079C6100083CA22008FCF38009CD5
      4E00A8DA6500B5DF7B00C1E59100CEEAA800CFEBAA00C3E59400B6E07E00AADB
      67009DD5510091D03B0085CB25007AC7120079C6100083CA22008FCF38009CD5
      4E00A8DA6500B5DF7B00C1E59100CEEAA800C0E8B300000080009EDC8B008ED6
      7700000080006ECB500060C6400000550000005500005FC63E006CCA4E008000
      00008000000080000000ADE19C00BEE8B000C0E8B300000080009EDC8B008ED6
      7700000080006ECB500060C6400000550000005500005FC63E006CCA4E008000
      00008000000080000000ADE19C00BEE8B000C0E8B300000080009EDC8B008ED6
      7700000080006ECB500060C6400000550000005500005FC63E006CCA4E008000
      00008000000080000000ADE19C00BEE8B000C0E8B300000080009EDC8B008ED6
      7700000080006ECB500060C6400000550000005500005FC63E006CCA4E008000
      00008000000080000000ADE19C00BEE8B000BEF0CE00000080009AE7B4008AE3
      A700000080006ADC90000055000057D8810057D781000055000069DC8E008000
      000087E3A50098E7B20080000000BCEFCD00BEF0CE00000080009AE7B4008AE3
      A700000080006ADC90000055000057D8810057D781000055000069DC8E008000
      000087E3A50098E7B20080000000BCEFCD00BEF0CE00000080009AE7B4008AE3
      A700000080006ADC90000055000057D8810057D781000055000069DC8E008000
      000087E3A50098E7B20080000000BCEFCD00BEF0CE00000080009AE7B4008AE3
      A700000080006ADC90000055000057D8810057D781000055000069DC8E008000
      000087E3A50098E7B20080000000BCEFCD00C1F7E80000008000000080000000
      80007CEFCF006FEDCA00005500005EEBC40000550000005500006DEDCA008000
      00008000000080000000ACF5E100BFF7E700C1F7E80000008000000080000000
      80007CEFCF006FEDCA00005500005EEBC40000550000005500006DEDCA008000
      00008000000080000000ACF5E100BFF7E700C1F7E80000008000000080000000
      80007CEFCF006FEDCA00005500005EEBC40000550000005500006DEDCA008000
      00008000000080000000ACF5E100BFF7E700C1F7E80000008000000080000000
      80007CEFCF006FEDCA00005500005EEBC40000550000005500006DEDCA008000
      00008000000080000000ACF5E100BFF7E700C7FBFB0000008000A3F9FA0092F8
      F9000000800078F6F7000055000069F5F60069F5F6006EF5F70076F6F7008000
      000090F7F900A1F9F90080000000C5FBFB00C7FBFB0000008000A3F9FA0092F8
      F9000000800078F6F7000055000069F5F60069F5F6006EF5F70076F6F7008000
      000090F7F900A1F9F90080000000C5FBFB00C7FBFB0000008000A3F9FA0092F8
      F9000000800078F6F7000055000069F5F60069F5F6006EF5F70076F6F7008000
      000090F7F900A1F9F90080000000C5FBFB00C7FBFB0000008000A3F9FA0092F8
      F9000000800078F6F7000055000069F5F60069F5F6006EF5F70076F6F7008000
      000090F7F900A1F9F90080000000C5FBFB00D3EFFF0000008000000080000000
      800094D9FF008AD5FF0082D3FF00005500000055000081D2FF0088D5FF008000
      00008000000080000000BFE8FF00D1EFFF00D3EFFF0000008000000080000000
      800094D9FF008AD5FF0082D3FF00005500000055000081D2FF0088D5FF008000
      00008000000080000000BFE8FF00D1EFFF00D3EFFF0000008000000080000000
      800094D9FF008AD5FF0082D3FF00005500000055000081D2FF0088D5FF008000
      00008000000080000000BFE8FF00D1EFFF00D3EFFF0000008000000080000000
      800094D9FF008AD5FF0082D3FF00005500000055000081D2FF0088D5FF008000
      00008000000080000000BFE8FF00D1EFFF00E1E9FF00D1DCFF00C1D1FF00B4C6
      FF00A8BDFF009EB6FF0098B1FF0094AEFF0094AEFF0097B1FF009DB5FF00A6BC
      FF00B2C5FF00C0CFFF00CFDBFF00DFE7FF00E1E9FF00D1DCFF00C1D1FF00B4C6
      FF00A8BDFF009EB6FF0098B1FF0094AEFF0094AEFF0097B1FF009DB5FF00A6BC
      FF00B2C5FF00C0CFFF00CFDBFF00DFE7FF00E1E9FF00D1DCFF00C1D1FF00B4C6
      FF00A8BDFF009EB6FF0098B1FF0094AEFF0094AEFF0097B1FF009DB5FF00A6BC
      FF00B2C5FF00C0CFFF00CFDBFF00DFE7FF00E1E9FF00D1DCFF00C1D1FF00B4C6
      FF00A8BDFF009EB6FF0098B1FF0094AEFF0094AEFF0097B1FF009DB5FF00A6BC
      FF00B2C5FF00C0CFFF00CFDBFF00DFE7FF00F4F1FF00EAE1FF00E0D3FF00D8C7
      FF00D1BCFF00CBB4FF00C7AEFF00C5ABFF00C5AAFF00C7ADFF00CBB3FF00D0BB
      FF00D7C5FF00DFD1FF00E9DFFF00F3EFFF00F4F1FF00EAE1FF00E0D3FF00D8C7
      FF00D1BCFF00CBB4FF00C7AEFF00C5ABFF00C5AAFF00C7ADFF00CBB3FF00D0BB
      FF00D7C5FF00DFD1FF00E9DFFF00F3EFFF00F4F1FF00EAE1FF00E0D3FF00D8C7
      FF00D1BCFF00CBB4FF00C7AEFF00C5ABFF00C5AAFF00C7ADFF00CBB3FF00D0BB
      FF00D7C5FF00DFD1FF00E9DFFF00F3EFFF00F4F1FF00EAE1FF00E0D3FF00D8C7
      FF00D1BCFF00CBB4FF00C7AEFF00C5ABFF00C5AAFF00C7ADFF00CBB3FF00D0BB
      FF00D7C5FF00DFD1FF00E9DFFF00F3EFFF00424D3E000000000000003E000000
      2800000040000000800000000100010000000000000400000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000F700FFF7810000000300FFE3BF000000
      7700FFF71F0000007F00FFF7BF000000FF00FFF7FF000000000000F700000000
      000000FF00000000000000F700000000000100F700010000000300F700030000
      000700F70007000000FF00E300FF000000FD00F700FD000001F801FF01F80000
      03FD03FF03FD0000078107FF07810000FF3CFF80FFFFFF81FF18FF00FFFFFF00
      FF81FE00FFFFFF00C003C000C001C000C003C000C001C00000010000003F0000
      00180000003F0000003C0031003F0001003F003F003F003F003F003F003F003F
      003F003F003F003F003F003F003F003F007F007F007F007F00FF00FF00FF00FF
      01FF01FF01FF01FF03FF03FF03FF03FFFF3CFFF78100FFFFFF18FFE3BF00FFE7
      FF81FFF71F00FFE7FFC3FFF7BF00C001FFC3FFF7FF00C001008100F700000027
      001800FF00000027003C00F70000003F00FF00F70001003F00FF00F70003003F
      00FF00F70007003F00FF00E300FF003F00FF00F700FD007F00FF01FF01F800FF
      01FF03FF03FD01FF03FF07FF078103FFF700F700FF80FF8103000300FF00FF00
      77007700FE00FF007F007F00FC00FF00FF00FF00FC00FF000000000000000000
      00000000008000000000000000F100810001000100FF00FF0003000300FF00FF
      0007000700FF00FF00FF00FF00FF00FF00FD00FD00FF00FF01F801F800FF00FF
      03FD03FD01FF01FF0781078103FF03FF000000000000F7000000000000000300
      00000000000077000000000000007F00000000000000FF000000000000000000
      0000000000000000000000000000000000000000000000010000000000000003
      000000000000000700000000000000FF00000000000000FD00000000000001F8
      00000000000003FD000000000000078100000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object OpenDialog: TOpenDialogW
    FilterIndex = 0
    Options = []
    Left = 134
    Top = 511
  end
  object SaveDialog: TSaveDialogW
    FilterIndex = 0
    Options = []
    Left = 166
    Top = 511
  end
  object PM_Log: TPopupMenu
    Images = ImageList_Archiver
    Left = 360
    Top = 512
    object M_Log_ClbCpy: TMenuItem
      Caption = 'Copy to clipboard'
      ImageIndex = 16
      OnClick = M_Log_ClbCpyClick
    end
    object M_Log_ClbCpyAll: TMenuItem
      Caption = 'Copy all to clipboard'
      ImageIndex = 17
      OnClick = M_Log_ClbCpyAllClick
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object M_Log_Save: TMenuItem
      Caption = 'Save console as...'
      ImageIndex = 10
      OnClick = M_Log_SaveClick
    end
    object N13: TMenuItem
      Caption = '-'
    end
    object M_Log_Clear: TMenuItem
      Caption = 'Clear console'
      ImageIndex = 18
      OnClick = M_Log_ClearClick
    end
  end
  object PM_AboutBox: TPopupMenu
    Images = ImageList_Archiver
    Left = 328
    Top = 512
    object M_ShowCredits: TMenuItem
      Caption = 'Show credits'
      ImageIndex = 1
      OnClick = Image_AniLogoDblClick
    end
    object N17: TMenuItem
      Caption = '-'
    end
    object M_SaveAboutBox: TMenuItem
      Caption = 'Save bitmap'
      SubMenuImages = ImageList_Archiver
      ImageIndex = 4
      OnClick = M_SaveAboutBoxClick
    end
  end
end
