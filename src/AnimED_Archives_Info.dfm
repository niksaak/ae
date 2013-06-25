object FileInfo_Form: TFileInfo_Form
  Left = 1200
  Top = 188
  Width = 369
  Height = 505
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Information'
  Color = clBtnFace
  Constraints.MinHeight = 505
  Constraints.MinWidth = 369
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Helv'
  Font.Pitch = fpFixed
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    361
    478)
  PixelsPerInch = 96
  TextHeight = 13
  object PC_FileAndArchiveInfo: TPageControl
    Left = 6
    Top = 6
    Width = 349
    Height = 435
    ActivePage = TS_Info_File
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TS_Info_File: TTabSheet
      Caption = 'File'
      DesignSize = (
        341
        407)
      object L_Arc_FilePathText: TLabelW
        Left = 8
        Top = 128
        Width = 73
        Height = 13
        AutoSize = False
        Caption = 'File path:'
      end
      object Bevel1: TBevel
        Left = 8
        Top = 112
        Width = 321
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object I_Arc_Icon: TImage
        Left = 8
        Top = 8
        Width = 32
        Height = 32
        Center = True
        Transparent = True
      end
      object Bevel2: TBevel
        Left = 8
        Top = 48
        Width = 321
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object L_Arc_FileTypeText: TLabelW
        Left = 8
        Top = 64
        Width = 73
        Height = 13
        AutoSize = False
        Caption = 'File type:'
      end
      object L_Arc_FileHealthText: TLabelW
        Left = 8
        Top = 88
        Width = 73
        Height = 13
        AutoSize = False
        Caption = 'Health:'
      end
      object L_Arc_FileType: TLabelW
        Tag = -1
        Left = 88
        Top = 64
        Width = 241
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '(no data)'
      end
      object L_Arc_FileHealth: TLabelW
        Tag = -1
        Left = 88
        Top = 88
        Width = 241
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '(no data)'
      end
      object L_Arc_FileSizeText: TLabelW
        Left = 8
        Top = 152
        Width = 73
        Height = 13
        AutoSize = False
        Caption = 'File size:'
      end
      object L_Arc_FileSizeCText: TLabelW
        Left = 8
        Top = 176
        Width = 73
        Height = 13
        AutoSize = False
        Caption = 'Compressed:'
      end
      object Bevel3: TBevel
        Left = 8
        Top = 224
        Width = 321
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object L_Arc_FilePath: TLabelW
        Tag = -1
        Left = 88
        Top = 128
        Width = 241
        Height = 13
        AutoSize = False
        Caption = 'X:\XXXXXXXX\XXXXXXXX'
      end
      object L_Arc_FileSize: TLabelW
        Tag = -1
        Left = 88
        Top = 152
        Width = 241
        Height = 13
        AutoSize = False
        Caption = '0 Kb (0 bytes)'
      end
      object L_Arc_FileSizeC: TLabelW
        Tag = -1
        Left = 88
        Top = 176
        Width = 241
        Height = 13
        AutoSize = False
        Caption = '0 Kb (0 bytes)'
      end
      object L_Arc_CompTypeText: TLabelW
        Left = 8
        Top = 200
        Width = 73
        Height = 13
        AutoSize = False
        Caption = 'Compression:'
      end
      object L_Arc_CompType: TLabelW
        Tag = -1
        Left = 88
        Top = 200
        Width = 241
        Height = 13
        AutoSize = False
        Caption = 'None'
      end
      object E_Arc_FileName: TEdit
        Left = 80
        Top = 16
        Width = 249
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = SHIFTJIS_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object PC_Attributes: TPageControl
        Left = 4
        Top = 224
        Width = 336
        Height = 182
        ActivePage = TS_Info_Attributes
        Anchors = [akLeft, akTop, akRight, akBottom]
        Style = tsButtons
        TabOrder = 1
        object TS_Info_Attributes: TTabSheet
          Caption = 'Attributes'
          DesignSize = (
            328
            151)
          object L_Arc_CreatedText: TLabelW
            Left = 0
            Top = 0
            Width = 73
            Height = 17
            AutoSize = False
            Caption = 'Created:'
            Enabled = False
          end
          object L_Arc_Created: TLabelW
            Tag = -1
            Left = 80
            Top = 0
            Width = 244
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = '0000 / 00 / 00, 0:00'
            Enabled = False
          end
          object L_Arc_Modified: TLabelW
            Tag = -1
            Left = 80
            Top = 24
            Width = 244
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = '0000 / 00 / 00, 0:00'
            Enabled = False
          end
          object L_Arc_ModifiedText: TLabelW
            Left = 0
            Top = 24
            Width = 73
            Height = 17
            AutoSize = False
            Caption = 'Modified:'
            Enabled = False
          end
          object L_Arc_OpenedText: TLabelW
            Left = 0
            Top = 48
            Width = 73
            Height = 17
            AutoSize = False
            Caption = 'Opened:'
            Enabled = False
          end
          object L_Arc_Opened: TLabelW
            Tag = -1
            Left = 80
            Top = 48
            Width = 244
            Height = 17
            Anchors = [akLeft, akTop, akRight]
            AutoSize = False
            Caption = '0000 / 00 / 00, 0:00'
            Enabled = False
          end
          object Bevel4: TBevel
            Left = 0
            Top = 69
            Width = 328
            Height = 9
            Anchors = [akLeft, akTop, akRight]
            Shape = bsTopLine
          end
          object L_Arc_Attrib: TLabelW
            Left = 0
            Top = 80
            Width = 73
            Height = 13
            AutoSize = False
            Caption = 'Attributes:'
          end
          object CB_Arc_ReadOnly: TCheckBox
            Left = 80
            Top = 76
            Width = 78
            Height = 25
            Caption = 'Read only'
            Enabled = False
            TabOrder = 0
            WordWrap = True
          end
          object CB_Arc_Archive: TCheckBox
            Left = 80
            Top = 100
            Width = 78
            Height = 25
            Caption = 'Archive'
            Enabled = False
            TabOrder = 1
            WordWrap = True
          end
          object CB_Arc_Hidden: TCheckBox
            Left = 80
            Top = 124
            Width = 78
            Height = 25
            Caption = 'Hidden'
            Enabled = False
            TabOrder = 2
            WordWrap = True
          end
          object CB_Arc_Compressed: TCheckBox
            Left = 160
            Top = 76
            Width = 78
            Height = 25
            Caption = 'Compressed'
            Enabled = False
            TabOrder = 3
            WordWrap = True
          end
          object CB_Arc_Encrypted: TCheckBox
            Left = 160
            Top = 124
            Width = 78
            Height = 25
            Caption = 'Encrypted'
            Enabled = False
            TabOrder = 4
            WordWrap = True
          end
          object CB_Arc_System: TCheckBox
            Left = 160
            Top = 100
            Width = 78
            Height = 25
            Caption = 'System'
            Enabled = False
            TabOrder = 5
            WordWrap = True
          end
          object CB_Arc_Virtual: TCheckBox
            Left = 244
            Top = 76
            Width = 85
            Height = 25
            Caption = 'Virtual'
            Enabled = False
            TabOrder = 6
            WordWrap = True
          end
          object CB_Arc_Deleted: TCheckBox
            Left = 244
            Top = 100
            Width = 85
            Height = 25
            Caption = 'Deleted'
            Enabled = False
            TabOrder = 7
            WordWrap = True
          end
        end
        object TS_Info_AdditionalFields: TTabSheet
          Caption = 'Additional fields'
          ImageIndex = 1
          DesignSize = (
            328
            151)
          object M_AddFields: TMemo
            Left = 0
            Top = 0
            Width = 328
            Height = 151
            Anchors = [akLeft, akTop, akRight, akBottom]
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Lucida Console'
            Font.Pitch = fpFixed
            Font.Style = []
            ParentFont = False
            ReadOnly = True
            ScrollBars = ssBoth
            TabOrder = 0
          end
        end
      end
    end
    object TS_Info_Archive: TTabSheet
      Caption = 'Archive'
      ImageIndex = 1
      DesignSize = (
        341
        407)
      object I_PercentCompression: TImage
        Left = 5
        Top = 37
        Width = 76
        Height = 362
        Anchors = [akLeft, akTop, akBottom]
        Transparent = True
      end
      object L_Arc_IDS: TLabelW
        Tag = -1
        Left = 80
        Top = 8
        Width = 253
        Height = 25
        Alignment = taCenter
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Archive format IDS'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Pitch = fpFixed
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
        WordWrap = True
      end
      object L_Arc_EngineVersion: TLabelW
        Left = 80
        Top = 32
        Width = 177
        Height = 13
        AutoSize = False
        Caption = 'Engine version:'
        Transparent = True
      end
      object L_Arc_EngineVer: TLabelW
        Tag = -1
        Left = 256
        Top = 32
        Width = 77
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '[Built-in]'
        Transparent = True
      end
      object L_Arc_FormatSupportStat: TLabelW
        Left = 80
        Top = 48
        Width = 177
        Height = 13
        AutoSize = False
        Caption = 'Format status:'
        Transparent = True
      end
      object L_Arc_FormatSup: TLabelW
        Tag = -1
        Left = 256
        Top = 48
        Width = 77
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Normal'
        Transparent = True
      end
      object Bevel5: TBevel
        Left = 80
        Top = 72
        Width = 257
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object L_Arc_TotalRecords: TLabelW
        Left = 80
        Top = 80
        Width = 153
        Height = 13
        AutoSize = False
        Caption = 'Records in archive:'
        Transparent = True
      end
      object L_Arc_Records: TLabelW
        Tag = -1
        Left = 232
        Top = 80
        Width = 101
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0'
        Transparent = True
      end
      object L_Arc_PhysicalArcSize: TLabelW
        Left = 80
        Top = 96
        Width = 153
        Height = 13
        AutoSize = False
        Caption = 'Physical archive size:'
        Transparent = True
      end
      object L_Arc_UncompressedFilesSize: TLabelW
        Left = 80
        Top = 112
        Width = 153
        Height = 13
        AutoSize = False
        Caption = 'Uncompressed files size:'
        Transparent = True
      end
      object L_Arc_CalculatedFilesSize: TLabelW
        Left = 80
        Top = 128
        Width = 153
        Height = 13
        AutoSize = False
        Caption = 'Calculated files size:'
        Transparent = True
      end
      object Bevel6: TBevel
        Left = 80
        Top = 200
        Width = 257
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object L_Arc_WastedSize: TLabelW
        Left = 80
        Top = 144
        Width = 153
        Height = 13
        AutoSize = False
        Caption = 'Wasted:'
        Transparent = True
      end
      object L_Arc_SavedSize: TLabelW
        Left = 80
        Top = 160
        Width = 153
        Height = 13
        AutoSize = False
        Caption = 'Saved:'
        Transparent = True
      end
      object L_Arc_FragRatio: TLabelW
        Left = 80
        Top = 224
        Width = 209
        Height = 13
        AutoSize = False
        Caption = 'Fragmentation ratio:'
        Transparent = True
      end
      object L_Arc_CompRatio: TLabelW
        Left = 80
        Top = 208
        Width = 209
        Height = 13
        AutoSize = False
        Caption = 'Compression ratio:'
        Transparent = True
      end
      object L_Arc_PhysicalSize: TLabelW
        Tag = -1
        Left = 232
        Top = 96
        Width = 101
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0'
        Transparent = True
      end
      object L_Arc_UncompressedSize: TLabelW
        Tag = -1
        Left = 232
        Top = 112
        Width = 101
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0'
        Transparent = True
      end
      object L_Arc_CalculatedSize: TLabelW
        Tag = -1
        Left = 232
        Top = 128
        Width = 101
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0'
        Transparent = True
      end
      object L_Arc_Wasted: TLabelW
        Tag = -1
        Left = 232
        Top = 144
        Width = 101
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0'
        Transparent = True
      end
      object L_Arc_Saved: TLabelW
        Tag = -1
        Left = 232
        Top = 160
        Width = 101
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0'
        Transparent = True
      end
      object L_Arc_Comp: TLabelW
        Tag = -1
        Left = 288
        Top = 208
        Width = 45
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0%'
        Transparent = True
      end
      object L_Arc_Frag: TLabelW
        Tag = -1
        Left = 288
        Top = 224
        Width = 45
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0%'
        Transparent = True
      end
      object I_PercentFragmentation: TImage
        Left = 80
        Top = 264
        Width = 76
        Height = 135
        Anchors = [akLeft, akTop, akBottom]
        Transparent = True
      end
      object I_PercentDamaged: TImage
        Left = 155
        Top = 264
        Width = 76
        Height = 135
        Anchors = [akLeft, akTop, akBottom]
        Transparent = True
      end
      object L_Arc_DamageRatio: TLabelW
        Left = 80
        Top = 240
        Width = 209
        Height = 13
        AutoSize = False
        Caption = 'Possible damage ratio:'
      end
      object L_Arc_Damage: TLabelW
        Tag = -1
        Left = 288
        Top = 240
        Width = 45
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0%'
      end
      object L_Arc_MissingSize: TLabelW
        Left = 80
        Top = 176
        Width = 153
        Height = 13
        AutoSize = False
        Caption = 'Missing:'
        Transparent = True
      end
      object L_Arc_Missing: TLabelW
        Tag = -1
        Left = 232
        Top = 176
        Width = 101
        Height = 13
        Alignment = taRightJustify
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = '0'
        Transparent = True
      end
    end
    object TS_Info_Hashes: TTabSheet
      Caption = 'Hashes'
      ImageIndex = 2
      DesignSize = (
        341
        407)
      object GB_MD5: TGroupBox
        Left = 11
        Top = 10
        Width = 317
        Height = 47
        Anchors = [akLeft, akTop, akRight]
        Caption = ' MD5 '
        TabOrder = 0
        DesignSize = (
          317
          47)
        object E_ArchiveMD5: TEdit
          Left = 10
          Top = 17
          Width = 222
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Color = clBtnFace
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Pitch = fpFixed
          Font.Style = []
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          Text = '00000000000000000000000000000000'
        end
        object B_DoMD5: TButton
          Left = 239
          Top = 17
          Width = 70
          Height = 22
          Anchors = [akTop, akRight]
          Caption = 'Calculate'
          TabOrder = 1
          OnClick = B_DoMD5Click
        end
      end
      object GB_CRC32: TGroupBox
        Left = 11
        Top = 63
        Width = 317
        Height = 50
        Anchors = [akLeft, akTop, akRight]
        Caption = ' CRC-32 '
        TabOrder = 1
        DesignSize = (
          317
          50)
        object E_ArchiveHex: TEdit
          Left = 10
          Top = 17
          Width = 222
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 0
          Text = '00000000'
        end
        object B_DoCRC32: TButton
          Left = 239
          Top = 17
          Width = 70
          Height = 22
          Anchors = [akTop, akRight]
          Caption = 'Calculate'
          TabOrder = 1
          OnClick = B_DoCRC32Click
        end
      end
    end
  end
  object B_FileInfo_OK: TButton
    Left = 281
    Top = 447
    Width = 74
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 1
    OnClick = B_FileInfo_OKClick
  end
end
