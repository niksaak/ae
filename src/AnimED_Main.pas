{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Main form unit

  Written by dsp2003.
}
unit AnimED_Main;

interface

uses { Basic AE }

     AnimED_Archives,
     AnimED_Audio,
     AnimED_CommandLine,
     AnimED_Config,
     AnimED_Console,
     AnimED_Core,
     AnimED_Core_GUI,
     AnimED_Dialogs,
     AnimED_Directories,
     AnimED_Graphics,
     AnimED_FileTypes,
     AnimED_HTML,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Progress,
     AnimED_Script,
     AnimED_Skin,
     AnimED_Skin_PercentCube,
     AnimED_Translation,
     AnimED_Translation_Strings,
     AnimED_Version,
     Generic_LZXX,
     AA_RFA,
     AG_Japanese_Colours,
     AG_Fundamental,
     AG_Portable_Network_Graphics,
     AG_RFI,
     AG_StdFmt,
     AE_Misc_MD5,
     { Basic Delphi 7 components }
     Menus, ExtCtrls, Dialogs, StdCtrls, ComCtrls, Gauges, Controls,
     Buttons, ToolWin, Classes, Windows, Messages, SysUtils, Variants,
     Graphics, Forms, ShellAPI, IniFiles, ImgList, jpeg, Clipbrd,
     { Project JEDI / Visual Component Library }
     JvComponent, JvArrowButton, JvExControls,
     { PNGObject }
     PngImage,
     { TScrollingCredits}
     Credits,
     { Other non-visual }
     ZlibEx,
     { JISKit. Must be declared after basic components, since they are overriding them }
     JUtils, UnicodeDialogs, FileStreamJ, StringsW, BrowseForFolderW, JReconvertor,
     UnicodeComponents;

type
  TMainForm = class(TForm)
    PageControl_Main: TPageControl;
    TS_Archiver: TTabSheet;
    TS_Audio: TTabSheet;
    TS_Image: TTabSheet;
    TS_E17_SCR: TTabSheet;
    TS_Log: TTabSheet;
    TS_About: TTabSheet;
    Timer_AlphaBlend: TTimer;
    GB_AudioStream_Setup: TGroupBox;
    TS_Options: TTabSheet;
    L_SCRTextSections: TLabelW;
    GB_SCRSetup: TGroupBox;
    GB_SCRImport: TGroupBox;
    CB_SCRSaveDir: TCheckBox;
    E_SCRDirectory: TEdit;
    CB_SCRAutoimport: TCheckBox;
    GB_ScenarioFileInfo: TGroupBox;
    L_ScenarioFileName: TLabelW;
    Bevel4: TBevel;
    L_ScenarioOffsetText: TLabelW;
    L_ScenarioOffset: TLabelW;
    L_ScenarioRecordsText: TLabelW;
    L_ScenarioRecords: TLabelW;
    Image_AniLogo: TImage;
    L_Copyright: TLabelW;
    L_WWW: TLabelW;
    L_EMail: TLabelW;
    TS_Data: TTabSheet;
    GB_DataConv: TGroupBox;
    L_UsersManual: TLabelW;
    L_ThisSoftwareIsFree: TLabelW;
    B_DataConv_Keyfile: TButton;
    PageControl_EDGE: TPageControl;
    TS_EDGE: TTabSheet;
    TS_EDGE_Setup: TTabSheet;
    GB_ImageOperations: TGroupBox;
    GB_ImagePreview: TGroupBox;
    I_EDGE_ImageA: TImage;
    GB_ImageSetup: TGroupBox;
    GB_ImageInfo: TGroupBox;
    L_ImageFileNameTitle: TLabelW;
    L_ImageSizeTitle: TLabelW;
    L_ImageSize: TLabelW;
    L_ImageFormat: TLabelW;
    L_ImageFormatTitle: TLabelW;
    L_ImageResolution: TLabelW;
    I_EDGE_Image: TImage;
    L_Image_Original: TLabelW;
    L_Image_Alpha: TLabelW;
    Bevel_Images: TBevel;
    PM_ColorSwap: TPopupMenu;
    M_EDGE_BGR: TMenuItem;
    M_EDGE_BRG: TMenuItem;
    M_EDGE_GBR: TMenuItem;
    M_EDGE_GRB: TMenuItem;
    M_EDGE_RBG: TMenuItem;
    PM_SUBAlpha_Extract: TPopupMenu;
    M_EDGE_SUBAlpha_Extract_Left: TMenuItem;
    M_EDGE_SUBAlpha_Extract_Right: TMenuItem;
    PM_SUBAlpha_Append: TPopupMenu;
    M_EDGE_SUBAlpha_Append_Left: TMenuItem;
    M_EDGE_SUBAlpha_Append_Right: TMenuItem;
    PM_SUBAlpha_Destroy: TPopupMenu;
    M_EDGE_SUBAlpha_Destroy_Left: TMenuItem;
    M_EDGE_SUBAlpha_Destroy_Right: TMenuItem;
    Bevel6: TBevel;
    SCredits: TScrollingCredits;
    PageControl_Archives: TPageControl;
    TS_ArchiveInterface: TTabSheet;
    TS_ArchiveSetup: TTabSheet;
    GB_ArchiveSetup: TGroupBox;
    GB_ArchiveCreation: TGroupBox;
    GB_ArchiveInfo: TGroupBox;
    L_FileNameTitle: TLabelW;
    L_ArchiveFormatTitle: TLabelW;
    L_ArchiveSizeTitle: TLabelW;
    L_ArchiveSize: TLabelW;
    L_ArchiveFormat: TLabelW;
    L_RecordsCountTitle: TLabelW;
    L_RecordsCount: TLabelW;
    Bevel2: TBevel;
    GB_ArchiveTool: TGroupBox;
    SB_CloseArchive: TSpeedButton;
    SB_ExtractAll: TSpeedButton;
    SB_ExtractFile: TSpeedButton;
    SB_OpenArchive: TSpeedButton;
    GB_ArchiveAddingMethod: TGroupBox;
    RB_Arc_Files: TRadioButton;
    RB_Arc_Directory: TRadioButton;
    GB_ArchiveLoading: TGroupBox;
    GB_AudioTool: TGroupBox;
    SB_Audio_Open: TSpeedButton;
    SB_Audio_Encode: TSpeedButton;
    SB_Audio_Batch: TSpeedButton;
    LV_ArcFileList: TListView;
    ImageList_Archiver: TImageList;
    GB_ImageTool: TGroupBox;
    SB_EDGE_Picture_Open: TSpeedButton;
    SB_EDGE_Picture_Save: TSpeedButton;
    SB_EDGE_Picture_SaveWOAlpha: TSpeedButton;
    SB_EDGE_Picture_SaveAlpha: TSpeedButton;
    SB_Image_Batch: TSpeedButton;
    SB_Image_GrapS: TSpeedButton;
    GB_ScenarioTool: TGroupBox;
    SB_CompileList: TSpeedButton;
    SB_SCRSaveText: TSpeedButton;
    SB_ImportSCRChunks: TSpeedButton;
    SB_ExportSCRChunks: TSpeedButton;
    SB_OpenSCR: TSpeedButton;
    GB_MiscTool: TGroupBox;
    SB_Data_Bruteforce: TSpeedButton;
    SB_Data_Process: TSpeedButton;
    PM_ArchiveTool: TPopupMenu;
    M_Arc_Extract: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    M_Arc_ExtractAll: TMenuItem;
    M_Arc_View: TMenuItem;
    M_Arc_Report: TMenuItem;
    M_Arc_Icons: TMenuItem;
    N3: TMenuItem;
    M_Arc_Properties: TMenuItem;
    P_Console: TPanel;
    L_Messageboard: TLabelW;
    PM_ArchiveToolCreate: TPopupMenu;
    M_Arc_Files: TMenuItem;
    N4: TMenuItem;
    M_Arc_Directory: TMenuItem;
    L_SCR_12345: TLabelW;
    GB_SC3: TGroupBox;
    RB_SC3_Strip: TRadioButton;
    RB_SC3_Keep: TRadioButton;
    CB_ArchiveListHumanReadable: TCheckBox;
    L_Warn_E17: TLabelW;
    ColorDialog: TColorDialog;
    N5: TMenuItem;
    M_Arc_HTMLList: TMenuItem;
    M_Arc_ListGen: TMenuItem;
    N6: TMenuItem;
    M_Arc_List: TMenuItem;
    M_Arc_CreateArchive: TMenuItem;
    M_Arc_SubFiles: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    M_Arc_SubDirectory: TMenuItem;
    M_Arc_SubList: TMenuItem;
    RB_Arc_List: TRadioButton;
    FontDialog: TFontDialog;
    M_Arc_Special: TMenuItem;
    N7: TMenuItem;
    M_Arc_FragmentationCheck: TMenuItem;
    CB_AllowArchiveOverwrite: TCheckBox;
    CB_RecursiveDirMode: TCheckBox;
    CB_ArchiveFormatList: TComboBox;
    CB_ImageFormat: TComboBox;
    PM_GrayScale: TPopupMenu;
    SM_EDGE_GS_ArithmeticMean: TMenuItem;
    SM_EDGE_GS_HDR: TMenuItem;
    SM_EDGE_GS_Red: TMenuItem;
    SM_EDGE_GS_Green: TMenuItem;
    SM_EDGE_GS_Blue: TMenuItem;
    PC_ImageToolSetup: TPageControl;
    TS_EDGE_All: TTabSheet;
    TS_EDGE_PRT: TTabSheet;
    GB_EDGE_General: TGroupBox;
    CB_ALL_ProcessAlpha: TCheckBox;
    CB_All_LoadSepAlpha: TCheckBox;
    CB_EDGE_InvertAlpha: TCheckBox;
    SM_EDGE_GS_Luma: TMenuItem;
    N10: TMenuItem;
    ImageList_EDGE: TImageList;
    E_Console: TEdit;
    OpenDialog: TOpenDialogW;
    SaveDialog: TSaveDialogW;
    SB_CreateArchive: TJvArrowButton;
    L_Mini_Log: TLabelW;
    E_ArcFileName: TEdit;
    G_Progress: TGauge;
    M_Arc_HTMLFormatList: TMenuItem;
    L_Version: TLabelW;
    N12: TMenuItem;
    M_Arc_FormatsWriteIntoConsole: TMenuItem;
    M_Arc_HTMLListDir: TMenuItem;
    N11: TMenuItem;
    SB_Data_Batch: TSpeedButton;
    TS_Script: TTabSheet;
    GB_ScriptRecompiler: TGroupBox;
    SB_SR_Open: TSpeedButton;
    SB_SR_Decompile: TSpeedButton;
    SB_SR_BatchCompile: TSpeedButton;
    SB_SR_Compile: TSpeedButton;
    CB_SR_ScriptFormat: TComboBox;
    SB_SR_BatchDecompile: TSpeedButton;
    L_AudioStreamConvSel: TLabelW;
    CB_AudioStream_FormatSelector: TComboBox;
    E_AudioStream_InputDir: TEdit;
    L_AudioStream_InputDir: TLabelW;
    B_AudioStream_InputDir: TButton;
    L_AudioStream_OutputDir: TLabelW;
    E_AudioStream_OutputDir: TEdit;
    B_AudioStream_OutputDir: TButton;
    RE_Log: TListBox;
    PM_Log: TPopupMenu;
    M_Log_ClbCpy: TMenuItem;
    M_Log_ClbCpyAll: TMenuItem;
    N13: TMenuItem;
    M_Log_Clear: TMenuItem;
    N14: TMenuItem;
    M_Log_Save: TMenuItem;
    GB_MessageLog: TGroupBox;
    CB_NoLog: TCheckBox;
    CB_LogI: TCheckBox;
    CB_LogM: TCheckBox;
    CB_LogS: TCheckBox;
    CB_LogE: TCheckBox;
    CB_LogW: TCheckBox;
    CB_LogD: TCheckBox;
    CB_BeepOnError: TCheckBox;
    CB_BeepOnWarn: TCheckBox;
    L_Arc_StatusProcessing: TLabelW;
    L_Arc_Status: TLabelW;
    E_ImageFileName: TEdit;
    N15: TMenuItem;
    M_Arc_GetHashes: TMenuItem;
    ListBox1: TListBox;
    LB_SCRDec: TListBox;
    SB_Log_Color_W: TSpeedButton;
    SB_Log_Color_E: TSpeedButton;
    SB_Log_Color_D: TSpeedButton;
    SB_Log_Color_I: TSpeedButton;
    SB_Log_Color_M: TSpeedButton;
    SB_Log_Color_S: TSpeedButton;
    SB_Log_Color_BG: TSpeedButton;
    SB_Log_Color_SEL: TSpeedButton;
    L_Log_BGColor: TLabel;
    L_Log_SelColor: TLabel;
    CB_Log_ConScheme: TComboBox;
    TB_Log_FontSize: TTrackBar;
    M_Arc_ExtRAW: TMenuItem;
    M_Arc_ExtAllRAW: TMenuItem;
    M_Arc_RAW: TMenuItem;
    L_DataConv_Mode: TLabelW;
    L_DataConv_Parameter: TLabelW;
    GB_DataConv_Value: TGroupBox;
    L_VI_8: TLabelW;
    L_VI_8Z: TLabelW;
    L_VI_HEX: TLabelW;
    L_VI_8Value: TLabelW;
    L_VI_8ZValue: TLabelW;
    L_VI_HEXValue: TLabelW;
    UD_DataConv_Value: TUpDown;
    E_DataConv_Value: TEdit;
    CB_DataConv_Mode: TComboBox;
    E_DataConv_Keyfile: TEdit;
    L_DataConv_KeyFile: TLabel;
    GB_ArchiveHiddenScan: TGroupBox;
    CB_HiddenDataAutoscanAsk: TCheckBox;
    CB_HiddenDataAutoscan: TCheckBox;
    M_Arc_HiddenDataCheck: TMenuItem;
    N16: TMenuItem;
    PC_Options: TPageControl;
    TS_PC_CoreLang: TTabSheet;
    TS_PC_SkinColour: TTabSheet;
    GB_Core: TGroupBox;
    L_ScreenSnapPixels: TLabelW;
    CB_ScreenSnap: TCheckBox;
    E_ScreenSnap: TEdit;
    UD_ScreenSnap: TUpDown;
    CB_AlphaBlendEffect: TCheckBox;
    CB_EnableDoubleBuffering: TCheckBox;
    GB_Language: TGroupBox;
    Bevel9: TBevel;
    Image_LangFlag: TImage;
    L_SelectedLanguage: TLabelW;
    L_LangAuthorValue: TLabelW;
    L_LangEMailValue: TLabelW;
    L_LangWWWValue: TLabelW;
    L_LangWWW: TLabelW;
    L_LangEMail: TLabelW;
    L_LangAuthor: TLabelW;
    CB_Language: TComboBox;
    B_DumpTranslation: TButton;
    GB_SC_Appearance: TGroupBox;
    I_SC_ButtonSkin48: TImage;
    I_SC_ButtonSkin16: TImage;
    B_IntSkinReload: TButton;
    B_IntSkinDump: TButton;
    TS_ArchiveFormats: TTabSheet;
    LV_ArcFmt: TListView;
    L_UnsupportedOS: TLabelW;
    PM_AboutBox: TPopupMenu;
    M_ShowCredits: TMenuItem;
    N17: TMenuItem;
    M_SaveAboutBox: TMenuItem;
    CB_NoAutocenter: TCheckBox;
    CB_NoDefaultSize: TCheckBox;
    CB_KeepWindowState: TCheckBox;
    TB_ImageTool_Image: TToolBar;
    TB_EDGE_Flip: TToolButton;
    ToolButton5: TToolButton;
    TB_EDGE_Negative: TToolButton;
    ToolButton2: TToolButton;
    TB_EDGE_ColorSwap: TToolButton;
    TB_EDGE_Grayscale: TToolButton;
    ToolButton3: TToolButton;
    TB_EDGE_SubAlpha_Append: TToolButton;
    TB_EDGE_SubAlpha_Extract: TToolButton;
    TB_EDGE_SubAlpha_Destroy: TToolButton;
    ToolButton1: TToolButton;
    TB_EDGE_Alpha_Flip: TToolButton;
    ToolButton6: TToolButton;
    TB_EDGE_NegativeAlpha: TToolButton;
    ToolButton4: TToolButton;
    TB_EDGE_Alpha_Append: TToolButton;
    TB_EDGE_Alpha_Extract: TToolButton;
    TB_EDGE_Alpha_Destroy: TToolButton;
    ToolButton7: TToolButton;
    TB_EDGE_Alpha_Generate: TToolButton;
    GB_PreviewColor: TGroupBox;
    SB_EDGE_JPHTML: TSpeedButton;
    CB_EDGE_PreviewColor: TColorBox;
    Bevel1: TBevel;
    Bevel3: TBevel;
    L_NepetaByCA: TLabelW;
    GB_EDGE_GrayScale: TGroupBox;
    I_EDGE_GrayScale: TImage;
    CB_EDGE_GrayScaleMode: TComboBox;
    GB_EDGE_ColourSwap: TGroupBox;
    I_EDGE_ColourSwap: TImage;
    CB_EDGE_ColourSwapMode: TComboBox;
    GB_EDGE_PNG_JPEG: TGroupBox;
    L_JPEG_Quality: TLabelW;
    L_PNG_Compression: TLabelW;
    E_JPEG_Quality: TEdit;
    UD_JPEG_Quality: TUpDown;
    E_PNG_Compression: TEdit;
    UD_PNG_Compression: TUpDown;
    CB_JPEGProgressive: TCheckBox;
    B_EDGE_JPEG_Reset: TButton;
    B_EDGE_PNG_Reset: TButton;
    CB_PRT_Coords: TCheckBox;
    GB_EDGE_Coordinate_Editor: TGroupBox;
    L_EDGE_X: TLabelW;
    L_EDGE_Y: TLabelW;
    L_EDGE_RenderWidth: TLabelW;
    L_EDGE_RenderHeight: TLabelW;
    E_EDGE_X: TEdit;
    E_EDGE_Y: TEdit;
    E_EDGE_RenderWidth: TEdit;
    E_EDGE_RenderHeight: TEdit;
    CB_PRT_Editor_Enable: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure SB_ExtractFileClick(Sender: TObject);
    procedure SB_ExtractAllClick(Sender: TObject);
    procedure CB_ArchiveFormatListChange(Sender: TObject);
    procedure Timer_AlphaBlendTimer(Sender: TObject);
    procedure SB_Audio_OpenClick(Sender: TObject);
    procedure SB_Audio_EncodeClick(Sender: TObject);
    procedure SB_Audio_BatchClick(Sender: TObject);
    procedure L_WWWClick(Sender: TObject);
    procedure L_EMailClick(Sender: TObject);
    procedure L_WWWMouseEnter(Sender: TObject);
    procedure L_WWWMouseLeave(Sender: TObject);
    procedure L_EMailMouseEnter(Sender: TObject);
    procedure L_EMailMouseLeave(Sender: TObject);
    procedure SB_OpenSCRClick(Sender: TObject);
    procedure SB_ExportSCRChunksClick(Sender: TObject);
    procedure SB_ImportSCRChunksClick(Sender: TObject);
    procedure SB_ClearLogClick(Sender: TObject);
    procedure CB_AllowArchiveOverwriteClick(Sender: TObject);
    procedure SB_CloseArchiveClick(Sender: TObject);
    procedure SB_SCRChunkEditorClick(Sender: TObject);
    procedure CB_NoLogClick(Sender: TObject);
    procedure CB_LanguageChange(Sender: TObject);
    procedure TS_AboutHide(Sender: TObject);
    procedure SB_Image_GrapSClick(Sender: TObject);
    procedure CB_ImageFormatChange(Sender: TObject);
    procedure SB_Image_BatchClick(Sender: TObject);
    procedure L_LangEMailValueClick(Sender: TObject);
    procedure L_LangEMailValueMouseEnter(Sender: TObject);
    procedure L_LangEMailValueMouseLeave(Sender: TObject);
    procedure L_LangWWWValueClick(Sender: TObject);
    procedure L_LangWWWValueMouseEnter(Sender: TObject);
    procedure L_LangWWWValueMouseLeave(Sender: TObject);
    procedure SB_Data_ProcessClick(Sender: TObject);
    procedure SB_Data_BruteforceClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure L_UsersManualClick(Sender: TObject);
    procedure L_UsersManualMouseEnter(Sender: TObject);
    procedure L_UsersManualMouseLeave(Sender: TObject);
    procedure SB_SCRSaveTextClick(Sender: TObject);
    procedure B_DataConv_KeyfileClick(Sender: TObject);
    procedure I_EDGE_ImageADblClick(Sender: TObject);
    procedure CB_ScreenSnapClick(Sender: TObject);
    procedure CB_BeepOnErrorClick(Sender: TObject);
    procedure CB_BeepOnWarnClick(Sender: TObject);
    procedure E_ScreenSnapChange(Sender: TObject);
    procedure UD_ScreenSnapChanging(Sender: TObject;
      var AllowChange: Boolean);
    procedure CB_AlphaBlendEffectClick(Sender: TObject);
    procedure SB_EDGE_Picture_OpenClick(Sender: TObject);
    procedure M_EDGE_SUBAlpha_Extract_RightClick(Sender: TObject);
    procedure SB_EDGE_Picture_SaveClick(Sender: TObject);
    procedure E_EDGE_XChange(Sender: TObject);
    procedure E_EDGE_YChange(Sender: TObject);
    procedure E_EDGE_RenderWidthChange(Sender: TObject);
    procedure E_EDGE_RenderHeightChange(Sender: TObject);
    procedure CB_PRT_Editor_EnableClick(Sender: TObject);
    procedure Image_AniLogoDblClick(Sender: TObject);
    procedure SCreditsAfterLastCredit(Sender: TObject);
    procedure M_EDGE_SUBAlpha_Extract_LeftClick(Sender: TObject);
    procedure M_EDGE_SUBAlpha_Append_LeftClick(Sender: TObject);
    procedure M_EDGE_SUBAlpha_Append_RightClick(Sender: TObject);
    procedure M_EDGE_SUBAlpha_Destroy_LeftClick(Sender: TObject);
    procedure M_EDGE_SUBAlpha_Destroy_RightClick(Sender: TObject);
    procedure SB_OpenArchiveClick(Sender: TObject);
    procedure M_EDGE_BGRClick(Sender: TObject);
    procedure M_EDGE_BRGClick(Sender: TObject);
    procedure M_EDGE_GBRClick(Sender: TObject);
    procedure M_EDGE_GRBClick(Sender: TObject);
    procedure M_EDGE_RBGClick(Sender: TObject);
    procedure SB_EDGE_Picture_SaveWOAlphaClick(Sender: TObject);
    procedure SB_EDGE_Picture_SaveAlphaClick(Sender: TObject);
    procedure SB_EDGE_MirrorClick(Sender: TObject);
    procedure LV_ArcFileListDblClick(Sender: TObject);
    { end }

    function Image_Open_GUI(FileName : widestring) : boolean;
    procedure M_Arc_PropertiesClick(Sender: TObject);
    procedure M_Arc_IconsClick(Sender: TObject);
    procedure M_Arc_SmallIconsClick(Sender: TObject);
    procedure M_Arc_ListClick(Sender: TObject);
    procedure M_Arc_ReportClick(Sender: TObject);
    procedure M_Arc_FilesClick(Sender: TObject);
    procedure M_Arc_DirectoryClick(Sender: TObject);
    procedure SB_CompileListClick(Sender: TObject);
    procedure M_Arc_HTMLListClick(Sender: TObject);
    procedure M_Arc_ListGenClick(Sender: TObject);
    procedure M_Arc_CreateFromListClick(Sender: TObject);
    procedure SB_CreateArchiveClick(Sender: TObject);
    procedure M_Arc_FragmentationCheckClick(Sender: TObject);
    procedure SM_EDGE_GS_ArithmeticMeanClick(Sender: TObject);
    procedure SM_EDGE_GS_HDRClick(Sender: TObject);
    procedure SM_EDGE_GS_RedClick(Sender: TObject);
    procedure SM_EDGE_GS_GreenClick(Sender: TObject);
    procedure SM_EDGE_GS_BlueClick(Sender: TObject);
    procedure SM_EDGE_GS_LumaClick(Sender: TObject);
    procedure E_ConsoleKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure L_Mini_LogWDblClick(Sender: TObject);
    procedure M_Arc_HTMLFormatListClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TS_AboutShow(Sender: TObject);
    procedure CB_EnableDoubleBufferingClick(Sender: TObject);
    procedure M_Arc_FormatsWriteIntoConsoleClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure M_Arc_HTMLListDirClick(Sender: TObject);
    procedure B_IntSkinReloadClick(Sender: TObject);
    procedure B_DumpTranslationClick(Sender: TObject);
    procedure SB_Data_BatchClick(Sender: TObject);
    procedure RE_LogDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure M_Log_ClbCpyClick(Sender: TObject);
    procedure M_Log_ClbCpyAllClick(Sender: TObject);
    procedure M_Log_ClearClick(Sender: TObject);
    procedure M_Log_SaveClick(Sender: TObject);
    procedure RE_LogMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure TS_ImageShow(Sender: TObject);
    procedure M_Arc_GetHashesClick(Sender: TObject);
    procedure SB_Log_Color_WClick(Sender: TObject);
    procedure SB_Log_Color_EClick(Sender: TObject);
    procedure SB_Log_Color_DClick(Sender: TObject);
    procedure SB_Log_Color_IClick(Sender: TObject);
    procedure SB_Log_Color_MClick(Sender: TObject);
    procedure SB_Log_Color_SClick(Sender: TObject);
    procedure SB_Log_Color_BGClick(Sender: TObject);
    procedure SB_Log_Color_SELClick(Sender: TObject);
    procedure CB_Log_ConSchemeChange(Sender: TObject);
    procedure TB_Log_FontSizeChange(Sender: TObject);
    procedure M_Arc_ExtRAWClick(Sender: TObject);
    procedure M_Arc_ExtAllRAWClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure E_DataConv_ValueChange(Sender: TObject);
    procedure SB_EDGE_JPHTMLClick(Sender: TObject);
    procedure TS_ArchiverShow(Sender: TObject);
    procedure M_Arc_HiddenDataCheckClick(Sender: TObject);
    procedure LV_ArcFmtChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure B_EDGE_JPEG_ResetClick(Sender: TObject);
    procedure B_EDGE_PNG_ResetClick(Sender: TObject);
    procedure PM_ArchiveToolPopup(Sender: TObject);
    procedure M_SaveAboutBoxClick(Sender: TObject);
    procedure TB_EDGE_FlipClick(Sender: TObject);
    procedure TB_EDGE_NegativeClick(Sender: TObject);
    procedure TB_EDGE_NegativeAlphaClick(Sender: TObject);
    procedure TB_EDGE_Alpha_AppendClick(Sender: TObject);
    procedure TB_EDGE_Alpha_ExtractClick(Sender: TObject);
    procedure TB_EDGE_Alpha_DestroyClick(Sender: TObject);
    procedure TB_EDGE_Alpha_GenerateClick(Sender: TObject);
    procedure TB_EDGE_Alpha_FlipClick(Sender: TObject);
    procedure L_ArchiveFormatDblClick(Sender: TObject);
    procedure L_NepetaByCAClick(Sender: TObject);
    procedure L_NepetaByCAMouseEnter(Sender: TObject);
    procedure L_NepetaByCAMouseLeave(Sender: TObject);
    procedure CB_EDGE_ColourSwapModeChange(Sender: TObject);
    procedure CB_EDGE_GrayScaleModeChange(Sender: TObject);
    procedure TB_EDGE_GrayscaleClick(Sender: TObject);
    procedure TB_EDGE_ColorSwapClick(Sender: TObject);

  private
    { Private declarations }
  protected
    { Protected declarations }
   procedure WMDropFiles (var Msg: TMessage); message wm_DropFiles;
//   procedure UXThemeRepaint (var Msg: TMessage); message wm_StyleChanged;
  public
    { Public declarations }
  end;

{ Custom NON-object procedures & functions }
procedure PickAudioInfo;

procedure CleanupInfo_Audio;
procedure CleanupInfo_Picture;
procedure Redraw_PreviewLogo(var Image : TImage; Logo : TPNGObject);

procedure EDGE_Grayscale(Mode : integer = 0);
procedure EDGE_ColourSwap(Mode : integer = 0);
procedure EDGE_GUI_DisplayDraw(RFI : TRFI; var InputStream, InputStreamA : TStream);
procedure EDGE_SUBAlpha(var RFI : TRFI; var IOStream, IOStreamA : TStream; Operation, Mode : integer; Inverted : boolean = True);

procedure GUI_ImageTool_Measurement;
procedure GUI_ArcTool_Measurement;

procedure ValueInterpreter(Value : integer);

function WhereAreWe : widestring;

procedure Convert_MultipleImages;

{ end }

var MainForm: TMainForm;
  InputAudio, OutputAudio : TStream;
  ArchiveCRC32, TypeMode, AudioFormat, PictureFormat : integer;
  IntTempo : array[1..4] of longword;
  ArchiveIsOpened, ValidAudioFile : boolean;

  TempoOffset, TempoOffset2, TempoSize : longword;

  DefaultListColumns : TListColumns;

  CMDParsed : boolean;

  // Image-related data containers
  ImageStream, ImageStreamA : TStream;
  GUI_RFI : TRFI;

const moNone    = -1;
      moAppend  = 0;
      moExtract = 1;
      moDelete  = 2;

implementation

uses AnimED_GrapS,
     AnimED_ImagePreview, AnimED_Archives_Info;

{$R *.dfm}

// Theme repaint handler
//procedure TMainForm.UXThemeRepaint(var Msg: TMessage);
//begin
// Skin_Load('');
//end;

// Drag-n-Drop Handler
procedure TMainForm.WMDropFiles(var Msg: TMessage);
var FileName: array[0..$FFF] of widechar;
    FileNameString : widestring;
    i : integer;
    FileStatus : boolean;
begin
 DragQueryFileW(THandle(Msg.WParam), 0, FileName, SizeOf(Filename));

 FileNameString := FileName;

 OpenDialog.FileName := FileNameString;

 FileStatus := False;

 for i := 0 to File_Ext_Images.Count-1 do begin
  if lowercase(ExtractFileExt(FileNameString)) = File_Ext_Images[i] then begin
   if Image_Open_GUI(FileNameString) then begin
    TS_EDGE.Show;
    FileStatus := True;
   end;
   break;
  end;
 end;

 if FileStatus = False then begin
  Open_Archive(FileNameString,CB_ArchiveFormatList.ItemIndex);
  TS_Archiver.Show;
 end;

 DragFinish(THandle(Msg.WParam));

// MessageBox(handle,'Under construction. :-P','Drag-n-Drop feature',mb_ok);

end;

// GUI Image preview measurement fix (ugly, yeah...)
procedure GUI_ImageTool_Measurement;
begin
 with MainForm do begin
  I_EDGE_Image.Width := Bevel_Images.Left - 2;
  I_EDGE_ImageA.Left := Bevel_Images.Left + 2;
  I_EDGE_ImageA.Width := I_EDGE_Image.Width;
 end;
end;

procedure GUI_ArcTool_Measurement;
var NewWidth, i : integer;
begin
 with MainForm.LV_ArcFileList do begin
  NewWidth := Width - 25;
  for i := 1 to Columns.Count-1 do dec(NewWidth,Column[i].MinWidth);
  Column[0].Width := NewWidth;
  Column[0].MinWidth := NewWidth;
 end;
 with MainForm.LV_ArcFmt do begin
  NewWidth := Width - 25;
  for i := 1 to Columns.Count-1 do dec(NewWidth,Column[i].MinWidth);
  Column[1].Width := NewWidth;
  Column[1].MinWidth := NewWidth;
 end;
end;

procedure Convert_MultipleImages;
var i : integer; z : int64;
Img, ImgA : TStream; RFI : TRFI; FileName, SaveName : widestring;
begin
with MainForm do begin

 PickDirContents(RootDir,'*.*',smAllowDirs);

 for i := 0 to AddedFilesW.Count-1 do begin
  Img := TMemoryStream.Create;
  ImgA := TMemoryStream.Create;
  LogS(AddedFilesW.Strings[i]+' -> '+ChangeFileExt(AddedFilesW.Strings[i],ImFormats[CB_ImageFormat.ItemIndex].Ext));

  FileName := RootDir + AddedFilesW.Strings[i];

  if Image_Open(RFI,z,FileName,Img,ImgA,CB_PRT_Coords.Checked,CB_ALL_ProcessAlpha.Checked,True,True,CB_All_LoadSepAlpha.Checked) then try

   SaveName := ChangeFileExt(RootDir+AddedFilesW.Strings[i],ImFormats[CB_ImageFormat.ItemIndex].Ext);

   Image_Save(RFI,
              SaveName,
              Img,
              ImgA,
              CB_ImageFormat.ItemIndex,
              CB_PRT_Coords.Checked,
              CB_All_ProcessAlpha.Checked,
              True,
              True,
              CB_JPEGProgressive.Checked,
              UD_PNG_Compression.Position,
              UD_JPEG_Quality.Position);

  except
   FreeAndNil(Img);
   FreeAndNil(ImgA);
   LogE(AMS[EImageConversion]+' -- '+AddedFilesW.Strings[i]);
  end else LogE(AMS[EImageConversion]+' -- '+AddedFilesW.Strings[i]);
  FreeAndNil(Img);
  FreeAndNil(ImgA);
  Application.ProcessMessages; //hang fix
 end;
 FreeAndNil(AddedFilesW);
 FreeAndNil(Img);
 FreeAndNil(ImgA);

 LogI(AMS[IDone]);

end;
end;

function WhereAreWe : widestring;
begin
{ Gathering executable location }
 Result := ExtractFilePath(paramstrw(0));
end;

{ MainForm initialization code - begin }
procedure TMainForm.FormCreate(Sender: TObject);
var i : integer;
begin
{ Allowing user to drag files onto the form }
 DragAcceptFiles(Handle, True);

{ Initialises japanese colours library ^____^ }
 Init_Japanese_Colours;

{ Loads japanese colors to preview in window color picker }
 for i := 0 to Length(jColors)-1 do CB_EDGE_PreviewColor.AddItem(jColors[i].t,TObject(jColors[i].c));

{ Fixes idiotical Delphi auto-transparent color joiner bug >_< }
// KillTColor(TComponent(SB_EDGE_Negative));
// KillTColor(TComponent(SB_EDGE_Grayscale));
// KillTColor(TComponent(SB_EDGE_ColorSwap));
// KillTColor(TComponent(SB_EDGE_Alpha_Append));
// KillTColor(TComponent(SB_EDGE_Alpha_Extract));
// KillTColor(TComponent(SB_EDGE_Alpha_Destroy));
// KillTColor(TComponent(SB_EDGE_SUBAlpha_Append));
// KillTColor(TComponent(SB_EDGE_SUBAlpha_Extract));
// KillTColor(TComponent(SB_EDGE_SUBAlpha_Destroy));
// KillTColor(TComponent(SB_EDGE_Alpha_Generate));
// KillTColor(TComponent(SB_EDGE_Mirror));
// KillTColor(TComponent(SB_EDGE_Flip));
// KillTColor(TComponent(SB_EDGE_NegativeAlpha));
// KillTColor(TComponent(SB_EDGE_Alpha_Flip));

 { Initialising languages }
 InitBuiltInMessages;

 { This one fills format selection ComboBoxes }
 CB_ArchiveFormatList.Items := Init_Archive_Formats; // здесь идёт инициализация форматов архивов. да, ЗДЕСЬ
 // Заполняем список форматов архивов для списка ListView
 Core_GUI_ArcFormatsFillItems;
 CB_ArchiveFormatList.ItemIndex := 0;
 CB_ImageFormat.Items := Init_Image_Formats;
 CB_ImageFormat.ItemIndex := 0;

 { Initialising file types }
 Init_FileTypes;

 FindLangFiles;

 { Loading built-in pictures from resources }
 Skin_Load('');
 Skin_InitDefaultMinilogColors;

 { Loading configuration -- moved here at 0.6.3.346 (2008.01.26) }
 ConfigLoad;

// LogS('___AnimED Console Debugging Log___');

 if Total_Languages > 0 then LoadTranslation(WhereAreWe+LanguageList[MainForm.CB_Language.ItemIndex+1,1]);

 Application.Title := APP_NAME+' v'+APP_VERSION;
 L_Version.Caption := {AMS[AVersion]+' '+}APP_VERSION;
 L_Copyright.Caption := APP_COPYRIGHT;

 { Starting up... }
 MainForm.Caption := Application.Title + ' "' + RandomJoke + '"';

{ Display about box. Fixes random design issues... :) }
  TS_About.Show;

 Core_GUI_ArcClearInfo;
 CleanupInfo_Audio;
 CleanupInfo_Picture;

{ Allright, here we go! }
 LogM(Application.Title+' '+AMS[AStartedAt]+' '+DateToStr(Date)+' '+TimeToStr(Time)+' -- '+SystemInformation);

 // Welcome message
 LogI(AMS[CAppMessage]);

 L_UnsupportedOS.Visible := isVista78;

 CMDParsed := False;

 RFA_ID := -1;

end;
{ MainForm initialization code - end }

procedure TMainForm.SB_ExtractFileClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;
 if LV_ArcFileList.ItemIndex <> -1 then Extract_SingleFile(RFA[LV_ArcFileList.ItemIndex+1],RFA_ID);
end;

procedure TMainForm.SB_ExtractAllClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;
 if ArchiveIsOpened = True then begin
  RootDir := BrowseForFolder(pwidechar(widestring(AMS[ABrowseForDirTitle])),'',True);
  if RootDir <> '' then begin
   if DirectoryExists(RootDir) then begin
 // Important: don't forget about '\'
    RootDir := RootDir+'\';
    Extract_MultipleFiles([],RFA_ID);
   end else LogE(AMS[EInvalidDirectory]);
  end else LogI(AMS[iCancelledByUser]);
 end else LogW(AMS[WArchiveExtract]);
end;

procedure TMainForm.CB_ArchiveFormatListChange(Sender: TObject);
var Substatus : string; Status : byte;
    FmtIdx : integer;
begin
 FmtIdx := CB_ArchiveFormatList.ItemIndex; // присваиваем индекс формата

{ for i := 1 to Length(ArcFormats[FmtIdx].SFmt) do begin
  LogD(ArcFormats[FmtIdx].SFmt[i-1]);
 end;}

 Status := ArcFormats[FmtIdx].Stat;
 if Status <> $0 then begin
  case Status of
   $1 : Substatus := AMS[AStatusReadme];
   $2 : Substatus := AMS[AStatusBuggy];
   $3 : Substatus := AMS[AStatusHack];
   $5 : Substatus := AMS[AStatusWriteOnly];
   $9 : Substatus := AMS[AStatusDummy];
   $F : Substatus := AMS[AStatusUnpack];
   else Substatus := inttohex(Status,2);
  end;
  Substatus := ArcFmtNameCompose(ArcFormats[FmtIdx]) + ': ' + Substatus;
  LogW(Substatus);
//  MessageBox(handle, pchar(Substatus),pchar(AMS[AWarning]),mb_ok);
 end;
end;

procedure TMainForm.Timer_AlphaBlendTimer(Sender: TObject);
var i : integer;
begin
{ This code makes translucent appearance of main window }
 if MainForm.AlphaBlendValue = 255 then begin
  Timer_AlphaBlend.Enabled := False;
  MainForm.AlphaBlend := False;
 end;
 i := MainForm.AlphaBlendValue + 15;
 if i > 255 then i := 255;
 MainForm.AlphaBlendValue := i;
end;

procedure CleanupInfo_Audio;
begin
 with MainForm do begin
  AudioFormat := -1;
  ValidAudioFile := False;
  FreeAndNil(InputAudio);
  FreeAndNil(OutputAudio);
 end;
end;

procedure Redraw_PreviewLogo(var Image : TImage; Logo : TPNGObject);
begin
 with MainForm,Image do try
  Picture.Bitmap.PixelFormat := pf32bit;
  Picture.Bitmap.Width := Width;
  Picture.Bitmap.Height := Height;
  Canvas.Pen.Color := CB_EDGE_PreviewColor.Selected;
  Canvas.Brush.Color := CB_EDGE_PreviewColor.Selected;
  Canvas.FillRect(Rect(0,0,Width,Height));
  Canvas.Draw((Width div 2)-(Logo.Width div 2), (Height div 2)-(Logo.Height div 2),Logo);
  Repaint;
 except
  LogE(AMS[EResourceReadingError]);
 end;
end;

procedure CleanupInfo_Picture;
begin
 with MainForm do begin
  FreeAndNil(ImageStream);
  FreeAndNil(ImageStreamA);
  PictureFormat := -1;
  E_ImageFileName.Text := '---';
  L_ImageFormat.Caption := AMS[AUnknownFormat];
  L_ImageSize.Caption := '0 '+AMS[ABytes];
  L_ImageResolution.Caption := '0x0 0 '+AMS[ABits];
  Redraw_PreviewLogo(I_EDGE_Image,Skin.GUI_LOGO);
  Redraw_PreviewLogo(I_EDGE_ImageA,Skin.GUI_LOGO_CODENAME);
 end;
end;

procedure TMainForm.SB_Audio_OpenClick(Sender: TObject);
var FileName : widestring;
begin

 CleanupInfo_Audio;

 FreeAndNil(InputAudio);

 if ODialog_File(FileName) then with InputAudio, SimpleWaveInfo do try
  InputAudio := TFileStream.Create(FileName,fmOpenRead);

  PickAudioInfo;

  if ValidAudioFile = True then begin
   Read(Channels,2);
   Read(Frequency,2);
   Open_AudioFile(AudioFormat);
  end else begin
   LogE(AMS[EUnsupportedFormat]);
   FreeAndNil(InputAudio);
  end;

 except
  LogE(AMS[EUnexpectedError]);
  FreeAndNil(InputAudio);
 end else LogI(AMS[ICancelledByUser]);
end;

procedure TMainForm.SB_Audio_EncodeClick(Sender: TObject);
var FileName : widestring;
begin
 if InputAudio <> nil then begin
  FileName := ExtractFileName(OpenDialog.FileName);

  if lowercase(ExtractFileExt(FileName)) = '.waf' then FileName := ChangeFileExt(FileName, '.wav')
  else FileName := ChangeFileExt(FileName, '.waf');

  if SDialog_File(FileName) then Convert_AudioFile(AudioFormat,FileName)
  else LogI(AMS[ICancelledByUser]);

 end else LogW(AMS[WAudioConversion]);
end;

procedure TMainForm.SB_Audio_BatchClick(Sender: TObject);
begin
 RootDir := BrowseForFolder(pwidechar(widestring(AMS[ABrowseForDirTitle])),'',True);
 if RootDir <> '' then begin
  if DirectoryExists(RootDir) then begin
// Important: don't forget about '\'
   RootDir := RootDir+'\';
   Convert_MultipleAudios;
  end else LogE(AMS[EInvalidDirectory]);
 end else LogI(AMS[iCancelledByUser]);
end;

procedure PickAudioInfo;
begin
 with InputAudio, SimpleWaveInfo, MainForm do begin
 { Gathering wave or waf file information }
 LogI(AMS[IReadingAudioFile]);
 Seek(0,soBeginning);
 Read(WAVEHeader,22);
 Seek(0,soBeginning);
 Read(WAFHeader,6);

 AudioFormat := -1;

 if WAVEHeader[1]+WAVEHeader[2]+WAVEHeader[3]+WAVEHeader[4]+WAVEHeader[9]+WAVEHeader[10]+WAVEHeader[11]+WAVEHeader[12] = 'RIFFWAVE' then
  begin
   AudioFormat := 0;
   ValidAudioFile := True;
   Seek(22,soBeginning);
  end;
 if WAFHeader[1]+WAFHeader[2]+WAFHeader[3] = 'WAF' then
  begin
   AudioFormat := 1;
   ValidAudioFile := True;
   Seek(6,soBeginning);
  end;
 end;
end;

procedure TMainForm.L_WWWClick(Sender: TObject);
begin
 ShellExecute(handle, nil, 'http://wks.arai-kibou.ru/', nil, nil, sw_shownormal);
end;

procedure TMainForm.L_EMailClick(Sender: TObject);
begin
 ShellExecute(handle, nil, 'mailto:winkillerstudio@gmail.com', nil, nil, sw_shownormal);
end;

procedure TMainForm.L_WWWMouseEnter(Sender: TObject);
begin
 L_WWW.Font.Color := $00234AFC;
end;

procedure TMainForm.L_WWWMouseLeave(Sender: TObject);
begin
 L_WWW.Font.Color := clBlack;
end;

procedure TMainForm.L_EMailMouseEnter(Sender: TObject);
begin
 L_EMail.Font.Color := $00234AFC;
end;

procedure TMainForm.L_EMailMouseLeave(Sender: TObject);
begin
 L_EMail.Font.Color := clBlack;
end;

procedure TMainForm.SB_OpenSCRClick(Sender: TObject);
var FileName : widestring;
begin
 if ODialog_File(FileName) then SC3Open(FileName) else LogI(AMS[ICancelledByUser]);
end;

procedure TMainForm.SB_ExportSCRChunksClick(Sender: TObject);
begin
 SC3Export;
end;

procedure TMainForm.SB_ImportSCRChunksClick(Sender: TObject);
begin
 SC3Import;
end;

procedure TMainForm.SB_ClearLogClick(Sender: TObject);
begin

end;

// This part of code has left here as an future reference for
// the author. Please do not delete those lines, o-ne-ga-i. ^_^

{procedure TMainForm.Button_Restore_SCR_DEF_CONFClick(Sender: TObject);
var TempoFile : TFileStream; TempoRes : TCustomMemoryStream;
begin
 try
  TempoFile := TFileStream.Create(WhereAreWe+'scr_def.conf',fmCreate);
  TempoRes  := TResourceStream.Create(HInstance,'SCR_DEF','TXT');
  TempoFile.CopyFrom(TempoRes,TempoRes.Size);
  TempoRes.Free;
  TempoFile.Free;
  Log(ISCRDefCreation);
 except
  Log(ESCRDefCreation);
 end;
end; }

procedure TMainForm.CB_AllowArchiveOverwriteClick(Sender: TObject);
begin
 if CB_AllowArchiveOverwrite.Checked then LogW(AMS[WArchiveOverwriteMode])
 else LogM(AMS[MArchiveOverwriteMode]);
end;

procedure TMainForm.SB_CloseArchiveClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;
 Core_GUI_ArcClearInfo;
end;

procedure TMainForm.SB_SCRChunkEditorClick(Sender: TObject);
begin
 DummyProcedure;
end;

procedure TMainForm.CB_NoLogClick(Sender: TObject);
begin
 if CB_NoLog.Checked then LogW(AMS[WLoggingDisabled])
 else LogM(AMS[MLoggingEnabled]);
end;

procedure TMainForm.CB_LanguageChange(Sender: TObject);
begin
{ This one fixes false translation loading }
 if FileExists(WhereAreWe+LanguageList[CB_Language.ItemIndex+1,1]) and (Total_Languages > 0) then
  begin
   LoadTranslation(WhereAreWe+LanguageList[CB_Language.ItemIndex+1,1]);
   Init_Archive_Formats(1);
   Core_GUI_ArcUpdateInfo(ArchiveStream,RecordsCount,RFA_IDS);
   LogI(AMS[IReinitialization]);
  end;
end;

procedure TMainForm.TS_AboutHide(Sender: TObject);
begin
 SCredits.Visible := False;
 SCredits.Animate := False;
// Scredits.Left := -500;
end;

procedure TMainForm.SB_Image_GrapSClick(Sender: TObject);
begin
 GrapSForm.Position := poScreenCenter;
 GrapSForm.Show;
 MainForm.Hide;
end;

procedure TMainForm.CB_ImageFormatChange(Sender: TObject);
begin
 if @ImFormats[CB_ImageFormat.ItemIndex].Save = nil then LogE(AMS[AUnsupportedFormat]);
end;

procedure TMainForm.SB_Image_BatchClick(Sender: TObject);
begin
 TS_EDGE.Show;
 RootDir := BrowseForFolder(pwidechar(widestring(AMS[ABrowseForDirTitle])),'',True);
 if RootDir <> '' then begin
  if DirectoryExists(RootDir) then begin
// Important: don't forget about '\'
   RootDir := RootDir+'\';
   Convert_MultipleImages;
  end else LogE(AMS[EInvalidDirectory]);
 end else LogI(AMS[iCancelledByUser]);
end;

procedure TMainForm.L_LangEMailValueClick(Sender: TObject);
begin
 ShellExecuteW(handle, nil, pwidechar(L_LangEMailValue.Caption), nil, nil, sw_shownormal);
end;

procedure TMainForm.L_LangEMailValueMouseEnter(Sender: TObject);
begin
 L_LangEMailValue.Font.Color := clHighlight;
end;

procedure TMainForm.L_LangEMailValueMouseLeave(Sender: TObject);
begin
 L_LangEMailValue.Font.Color := clWindowText;
end;

procedure TMainForm.L_LangWWWValueClick(Sender: TObject);
begin
 ShellExecuteW(handle, nil, pwidechar(L_LangWWWValue.Caption), nil, nil, sw_shownormal);
end;

procedure TMainForm.L_LangWWWValueMouseEnter(Sender: TObject);
begin
 L_LangWWWValue.Font.Color := clHighlight;
end;

procedure TMainForm.L_LangWWWValueMouseLeave(Sender: TObject);
begin
 L_LangWWWValue.Font.Color := clWindowText;
end;

procedure TMainForm.SB_Data_ProcessClick(Sender: TObject);
var iStream, kStream, oStream : TStream;
    Mode, Value : byte;
    FileName, kFileName : widestring;
begin

 Mode  := CB_DataConv_Mode.ItemIndex;
 Value := UD_DataConv_Value.Position;

 if ODialog_File(FileName) then begin

  // initialisation decision code
  case Mode of
   bcKey : begin
            kFileName := E_DataConv_KeyFile.Text;

            if kFileName = FileName then begin
             LogE(AMS[EKeyFileToSelf]);
             Exit;
            end;

            if FileExists(kFileName) then try
             kStream := TFileStreamJ.Create(kFileName,fmOpenRead);
            except
             LogE(kFileName+' : '+AMS[ECannotOpenFile]);
             Exit;
            end else begin
             LogE(AMS[ENoValidKeyFile]);
             Exit;
            end;
           end;
  end;

  iStream := TFileStreamJ.Create(FileName,fmOpenRead);
  oStream := TFileStreamJ.Create(FileName+'~',fmCreate);

  case Mode of
   bcZlib : ZDecompressStream(iStream,oStream);
   bcKey  : begin
             BlockConvIO(iStream,oStream,kStream,Value,Mode);
             FreeAndNil(kStream);
            end;
   else     BlockConvIO(iStream,oStream,kStream,Value,Mode);
  end;

  FreeAndNil(iStream);
  FreeAndNil(oStream);

  LogI(AMS[IDone]);
 end else begin
  LogI(AMS[ICancelledByUser]);
 end;

end;

procedure ValueInterpreter(Value : integer);
begin
 with MainForm do begin
  L_VI_HEXValue.Caption := inttohex(Value,2);
  L_VI_8Value.Caption := inttostr(Value);
  case Value of
   0..127 : L_VI_8ZValue.Caption := inttostr(Value);
   128..255 : L_VI_8ZValue.Caption := inttostr(Value-256);
  end;
 end; 
end;

procedure TMainForm.SB_Data_BruteforceClick(Sender: TObject);
var InputFileStream, MemoryDataStream : TStream;
    i : integer;
    FileName : widestring;
begin
 if ODialog_File(FileName) then for i := 1 to $FF do try
  InputFileStream := TFileStream.Create(FileName,fmOpenRead);
  MemoryDataStream := TMemoryStream.Create;
  BlockXORIO(InputFileStream,MemoryDataStream,i);
  FreeAndNil(InputFileStream);
  MemoryDataStream.Seek(0,soBeginning);
  InputFileStream := TFileStream.Create(FileName+'.'+inttostr(i),fmCreate);
  LogS(AMS[OSaving]+FileName+'.'+inttostr(i));
  InputFileStream.CopyFrom(MemoryDataStream,MemoryDataStream.Size);
  FreeAndNil(MemoryDataStream);
  FreeAndNil(InputFileStream);
 except
  FreeAndNil(MemoryDataStream);
  FreeAndNil(InputFileStream);
  LogE(AMS[EConvertingBytes]);
 end else LogI(AMS[ICancelledByUser]);
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 ConfigSave;
end;

procedure TMainForm.L_UsersManualClick(Sender: TObject);
begin
 ShellExecute(handle, nil, pchar(string(WhereAreWe)+AMS[ReadMeFile]), nil, nil, sw_shownormal);
end;

procedure TMainForm.L_UsersManualMouseEnter(Sender: TObject);
begin
// L_UsersManual.Font.Color := $00D2540F;
// L_UsersManual.Font.Color := $00006FEC;
// L_UsersManual.Font.Color := $00CF6CFF;
 L_UsersManual.Font.Color := $00234AFC;
end;

procedure TMainForm.L_UsersManualMouseLeave(Sender: TObject);
begin
 L_UsersManual.Font.Color := clBlack;
end;

procedure TMainForm.SB_SCRSaveTextClick(Sender: TObject);
var FileName : widestring;
begin
 FileName := ChangeFileExt(ScriptFileName,'.txt');
 if SDialog_File(FileName) then LB_SCRDec.Items.SaveToFile(FileName);
end;

procedure TMainForm.B_DataConv_KeyfileClick(Sender: TObject);
var FileName : widestring;
begin
 if ODialog_File(FileName) then if FileName <> '' then E_DataConv_Keyfile.Text := FileName;
end;

procedure TMainForm.I_EDGE_ImageADblClick(Sender: TObject);
var PreviewStream : TStream;
    TempoPNG : TPNGObject;
begin
 if (ImageStream <> nil) and (ImageStream.Size > 0) then with PreviewForm do
  begin
   PreviewStream := TMemoryStream.Create;
   if Export_PNG(GUI_RFI,PreviewStream,ImageStream,ImageStreamA,0) then
    begin
     PreviewStream.Seek(0,soBeginning);
     TempoPNG := TPNGObject.Create;
     TempoPNG.CompressionLevel := 0; // we don't need to compress our preview, right?
     TempoPNG.LoadFromStream(PreviewStream);
     TempoPNG.Transparent := True;
     with I_LargePreview do begin
      Picture.Bitmap.PixelFormat := pf32bit;
      Picture.Bitmap.Width := I_EDGE_Image.Picture.Width;
      Picture.Bitmap.Height := I_EDGE_Image.Picture.Height;
      Canvas.Pen.Color := CB_EDGE_PreviewColor.Selected;
      Canvas.Brush.Color := CB_EDGE_PreviewColor.Selected;
      Canvas.FillRect(Rect(0,0,Picture.Bitmap.Width,Picture.Bitmap.Height));
      Canvas.Draw(0,0,TempoPNG);
     end;
     FreeAndNil(TempoPNG);
    end;
   FreeAndNil(PreviewStream);

   Width := I_EDGE_Image.Picture.Width;
   if I_EDGE_Image.Picture.Width > Screen.Width then PreviewForm.Width := Screen.Width;
   if I_EDGE_Image.Picture.Width < 320 then PreviewForm.Width := 320;

   Height := I_EDGE_Image.Picture.Height;
   if I_EDGE_Image.Picture.Height > Screen.Height then PreviewForm.Height := Screen.Height;
   if I_EDGE_Image.Picture.Height < 240 then PreviewForm.Height := 240;

   Color := CB_EDGE_PreviewColor.Selected;
   Position := poScreenCenter;
   if Visible then Close else Show;
  end;
end;

procedure TMainForm.CB_ScreenSnapClick(Sender: TObject);
begin
 MainForm.ScreenSnap := CB_ScreenSnap.Checked;
 E_ScreenSnap.Enabled := CB_ScreenSnap.Checked;
 UD_ScreenSnap.Enabled := CB_ScreenSnap.Checked;
 L_ScreenSnapPixels.Enabled := CB_ScreenSnap.Checked;
 MainForm.SnapBuffer := UD_ScreenSnap.Position;
end;

procedure TMainForm.CB_BeepOnErrorClick(Sender: TObject);
begin
 DoErrorBeep := CB_BeepOnError.Checked;
end;

procedure TMainForm.CB_BeepOnWarnClick(Sender: TObject);
begin
 DoWarnBeep := CB_BeepOnWarn.Checked;
end;

procedure TMainForm.E_ScreenSnapChange(Sender: TObject);
begin
 SnapBuffer := UD_ScreenSnap.Position;
end;

procedure TMainForm.UD_ScreenSnapChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
 SnapBuffer := UD_ScreenSnap.Position;
end;

procedure TMainForm.CB_AlphaBlendEffectClick(Sender: TObject);
begin
 if Timer_AlphaBlend.Enabled then AlphaBlend := CB_AlphaBlendEffect.Checked;
end;

procedure TMainForm.SB_EDGE_Picture_OpenClick(Sender: TObject);
var FileName : widestring;
begin
 TS_EDGE.Show;
 if ODialog_File(FileName) then Image_Open_GUI(FileName);
end;

function TMainForm.Image_Open_GUI;
var DisplaySize : int64; FileStream : TStream;
begin
 FreeAndNil(ImageStream);
 FreeAndNil(ImageStreamA);

 ImageStream := TMemoryStream.Create;
 ImageStreamA := TMemoryStream.Create;

 if Image_Open(GUI_RFI,DisplaySize,FileName,ImageStream,ImageStreamA,CB_PRT_Coords.Checked,CB_ALL_ProcessAlpha.Checked,True,True,CB_All_LoadSepAlpha.Checked) then begin
  EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
  E_EDGE_X.Text := inttostr(GUI_RFI.X);
  E_EDGE_Y.Text := inttostr(GUI_RFI.Y);
  E_EDGE_RenderWidth.Text := inttostr(GUI_RFI.RenderWidth);
  E_EDGE_RenderHeight.Text := inttostr(GUI_RFI.RenderHeight);
  E_ImageFileName.Text := Wide2Jis(OpenDialog.Filename);
  L_ImageSize.Caption := inttostr(DisplaySize)+' '+AMS[ABytes];
  LogM(Filename+' '+AMS[AOpenedSuccessfully]);
  Result := True;
 end
 else
  begin
   CleanupInfo_Picture;
   LogE(AMS[EUnsupportedFormat]);
   Result := False;
  end;
 FreeAndNil(FileStream);
end;

procedure EDGE_GUI_DisplayDraw(RFI : TRFI; var InputStream, InputStreamA : TStream);
var DisplayStream : TStream; RFIA : TRFI;
    RWidth, RHeight, RBitDepth : integer;
begin
 with MainForm do try
  DisplayStream := TMemoryStream.Create;
  Export_BMP(RFI,DisplayStream,InputStream,nil);

  RBitDepth := RFI.BitDepth;

  RWidth := GUI_RFI.RealWidth;
  RHeight := GUI_RFI.RealHeight;

  if RFI.ExtAlpha and ((InputStreamA <> nil) and (InputStreamA.Size > 0)) then
   begin
    L_ImageResolution.Caption := inttostr(RWidth)+'x'+inttostr(RHeight)+' '+inttostr(RBitDepth)+' '+AMS[Abits]+' + 8 '+AMS[Abits]+' alpha';
   end
  else L_ImageResolution.Caption := inttostr(RWidth)+'x'+inttostr(RHeight)+' '+inttostr(RBitDepth)+' '+AMS[Abits];

  DisplayStream.Seek(0,soBeginning);
  I_EDGE_Image.Picture.Bitmap.LoadFromStream(DisplayStream);
  I_EDGE_Image.Repaint;
  if ((InputStreamA <> nil) and (InputStreamA.Size > 0)) and RFI.ExtAlpha then
   try
    FreeAndNil(DisplayStream);
    DisplayStream := TMemoryStream.Create;
    RFIA := RFI;
    RFIA.BitDepth := 8;
    RFIA.Palette := GrayscalePalette;
    RFIA.ExtAlpha := False;
    Export_BMP(RFIA,DisplayStream,InputStreamA);
    DisplayStream.Seek(0,soBeginning);
    I_EDGE_ImageA.Picture.Bitmap.LoadFromStream(DisplayStream);
    I_EDGE_ImageA.Repaint;
   except
    Redraw_PreviewLogo(I_EDGE_ImageA,Skin.GUI_LOGO_CODENAME);
   end
  else
   try
    Redraw_PreviewLogo(I_EDGE_ImageA,Skin.GUI_LOGO_CODENAME);
   except
   end;
 except
  LogE(AMS[EUnsupportedFormat]);
  Redraw_PreviewLogo(I_EDGE_Image,Skin.GUI_LOGO);
  Redraw_PreviewLogo(I_EDGE_ImageA,Skin.GUI_LOGO_CODENAME);
 end;

 FreeAndNil(DisplayStream);
end;

procedure EDGE_SUBAlpha(var RFI: TRFI; var IOStream,IOStreamA : TStream; Operation, Mode : integer; Inverted : boolean = True);
var TempoStream : TStream;
begin
{ Проверка на чётность размеров изображения + проверка режима -- moNone (-1), moAppend (0), moExtract (1), moDelete (2) }
 if ((Mode > moAppend) and ((RFI.RealWidth mod 2 = 0) and ((Operation = apLeft) or (Operation = apRight))) or ((RFI.RealHeight mod 2 = 0) and ((Operation = apTop) or (Operation = apBottom)))) or (Mode < moExtract) then begin
  if IOStreamA = nil then IOStreamA := TMemoryStream.Create;
  TempoStream := TMemoryStream.Create;
  IOStream.Seek(0,soBeginning);
  IOStreamA.Seek(0,soBeginning);
  case Mode of
    moAppend: begin
               AppendAlpha2(IOStream,IOStreamA,TempoStream,RFI.RealWidth,RFI.RealHeight,RFI.BitDepth,Operation,Inverted);
               case Operation of
                apLeft, apRight : RFI.RealWidth  := RFI.RealWidth  * 2;
                apTop, apBottom : RFI.RealHeight := RFI.RealHeight * 2;
               end;
               RFI.ExtAlpha := False;
              end;
   moExtract, moDelete: begin
               IOStreamA.Size := 0;
               if Mode = moExtract then ExtractAlpha2(IOStream,IOStreamA,RFI.RealWidth,RFI.RealHeight,RFI.BitDepth,Operation,Inverted);
               RFI.ExtAlpha := True;
               StripAlpha2(IOStream,TempoStream,RFI.RealWidth,RFI.RealHeight,RFI.BitDepth,Operation);
               if Mode = moDelete then
                begin
                 FreeAndNil(IOStreamA);
                 RFI.ExtAlpha := False;
                end;
               case Operation of
                apLeft, apRight : RFI.RealWidth  := RFI.RealWidth  div 2;
                apTop, apBottom : RFI.RealHeight := RFI.RealHeight div 2;
               end;
              end;
  end;
  RFI.BitDepth := 24;
  TempoStream.Seek(0,soBeginning);
  IOStream.Size := 0;
  IOStream.CopyFrom(TempoStream,TempoStream.Size);
  FreeAndNil(TempoStream);
 end else LogE(AMS[EImagePowerOf2]);
end;

procedure TMainForm.M_EDGE_BRGClick(Sender: TObject);
begin
 EDGE_ColourSwap(scBRG);
end;

procedure EDGE_Grayscale(Mode : integer = 0);
var TempoStream : TStream;
begin
 if ImageStream <> nil then
  with MainForm do begin
   ImageStream.Seek(0,soBeginning);
   TempoStream := TMemoryStream.Create;
   RAW_AnyToTrueColor(ImageStream,nil,TempoStream,GUI_RFI.RealWidth,GUI_RFI.RealHeight,GUI_RFI.BitDepth,GUI_RFI.Palette,False);
   GUI_RFI.BitDepth := 24; // don't forget it again!! >_<
   TempoStream.Seek(0,soBeginning);
   ImageStream.Size := 0;
   RAW_TrueColorToGrayScale(TempoStream,ImageStream,GUI_RFI.RealWidth,GUI_RFI.RealHeight,GUI_RFI.BitDepth,Mode);
   GUI_RFI.BitDepth := 8;
   GUI_RFI.Palette := GrayscalePalette;
   FreeAndNil(TempoStream);
   EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
  end
 else LogW(AMS[WImageConversion]);
end;

procedure EDGE_ColourSwap(Mode : integer = 0);
var i : integer;
begin
 if (ImageStream <> nil) and (ImageStream.Size > 0) then begin
  case GUI_RFI.BitDepth of
       8 : for i := 0 to 255 do GUI_RFI.Palette.Palette[i] := SwapColors32(GUI_RFI.Palette.Palette[i],Mode);
   24,32 : SwapColors(ImageStream,GUI_RFI.RealWidth,GUI_RFI.RealHeight,GUI_RFI.BitDepth,Mode);
  end;
  EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.SB_EDGE_Picture_SaveClick(Sender: TObject);
var FileName : widestring;
begin
 TS_EDGE.Show;
 if (ImageStream <> nil) and (ImageStream.Size > 0) then begin
  FileName := ChangeFileExt(OpenDialog.FileName,ImFormats[CB_ImageFormat.ItemIndex].Ext);
  if SDialog_File(FileName) then begin
   Image_Save(GUI_RFI,FileName,ImageStream,ImageStreamA,CB_ImageFormat.ItemIndex,CB_PRT_Coords.Checked,CB_All_ProcessAlpha.Checked,True,True,CB_JPEGProgressive.Checked,UD_PNG_Compression.Position,UD_JPEG_Quality.Position);
  end else LogI(AMS[ICancelledByUser]);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.E_EDGE_XChange(Sender: TObject);
var x : integer;
begin
 x := GUI_RFI.X;
 try
  GUI_RFI.X := strtoint(E_EDGE_X.Text);
 except
  GUI_RFI.X := x;
  E_EDGE_X.Text := inttostr(x);
 end;
end;

procedure TMainForm.E_EDGE_YChange(Sender: TObject);
var y : integer;
begin
 y := GUI_RFI.Y;
 try
  GUI_RFI.Y := strtoint(E_EDGE_Y.Text);
 except
  GUI_RFI.Y := y;
  E_EDGE_Y.Text := inttostr(y);
 end;
end;

procedure TMainForm.E_EDGE_RenderWidthChange(Sender: TObject);
var RenderWidth : integer;
begin
 RenderWidth := GUI_RFI.RenderWidth;
 try
  GUI_RFI.RenderWidth := strtoint(E_EDGE_RenderWidth.Text);
 except
  GUI_RFI.RenderWidth := RenderWidth;
  E_EDGE_RenderWidth.Text := inttostr(RenderWidth);
 end;
end;

procedure TMainForm.E_EDGE_RenderHeightChange(Sender: TObject);
var RenderHeight : integer;
begin
 RenderHeight := GUI_RFI.RenderHeight;
 try
  GUI_RFI.RenderHeight := strtoint(E_EDGE_RenderHeight.Text);
 except
  GUI_RFI.RenderHeight := RenderHeight;
  E_EDGE_RenderHeight.Text := inttostr(RenderHeight);
 end;
end;

procedure TMainForm.CB_PRT_Editor_EnableClick(Sender: TObject);
var Enabled : boolean;
begin
 Enabled := CB_PRT_Editor_Enable.Checked;
 L_EDGE_X.Enabled := Enabled;
 E_EDGE_X.Enabled := Enabled;
 L_EDGE_Y.Enabled := Enabled;
 E_EDGE_Y.Enabled := Enabled;
 L_EDGE_RenderWidth.Enabled := Enabled;
 E_EDGE_RenderWidth.Enabled := Enabled;
 L_EDGE_RenderHeight.Enabled := Enabled;
 E_EDGE_RenderHeight.Enabled := Enabled;
end;

procedure TMainForm.Image_AniLogoDblClick(Sender: TObject);
var tmpBmp : TBitmap;
begin
 if not SCredits.Visible then begin
  tmpBMP := TBitmap.Create;
  tmpBMP.Width := SCredits.Width;
  tmpBMP.Height := SCredits.Height;
  tmpBMP.Canvas.Draw(-SCredits.Left,-Scredits.Top,Image_AniLogo.Picture.Bitmap);

  SCredits.BackgroundImage.Assign(tmpBMP);
  FreeAndNil(tmpBMP);
 end;
 FillCredits; // Makes "joke" messages to appear randomly
 SCredits.Visible := not SCredits.Visible;
 SCredits.Animate := not SCredits.Animate;
end;

procedure TMainForm.SCreditsAfterLastCredit(Sender: TObject);
begin
 Image_AniLogoDBlClick(nil);
end;

procedure TMainForm.M_EDGE_SUBAlpha_Extract_LeftClick(Sender: TObject);
begin
 if ImageStreamA = nil then ImageStreamA := TMemoryStream.Create;
 if ImageStream <> nil then begin
  EDGE_SUBAlpha(GUI_RFI,ImageStream,ImageStreamA,apLeft,moExtract,CB_EDGE_InvertAlpha.Checked);
  EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.M_EDGE_SUBAlpha_Extract_RightClick(Sender: TObject);
begin
 if ImageStreamA = nil then ImageStreamA := TMemoryStream.Create;
 if ImageStream <> nil then begin
  EDGE_SUBAlpha(GUI_RFI,ImageStream,ImageStreamA,apRight,moExtract,CB_EDGE_InvertAlpha.Checked);
  EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.M_EDGE_SUBAlpha_Append_LeftClick(Sender: TObject);
begin
 if ImageStream <> nil then begin
  if (ImageStreamA <> nil) and (ImageStreamA.Size > 0) then begin
   EDGE_SUBAlpha(GUI_RFI,ImageStream,ImageStreamA,apLeft,moAppend,CB_EDGE_InvertAlpha.Checked);
   FreeAndNil(ImageStreamA);
   EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
  end else LogE(AMS[EImageNoAlpha]);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.M_EDGE_SUBAlpha_Append_RightClick(Sender: TObject);
begin
 if ImageStream <> nil then begin
  if (ImageStreamA <> nil) and (ImageStreamA.Size > 0) then begin
   EDGE_SUBAlpha(GUI_RFI,ImageStream,ImageStreamA,apRight,moAppend,CB_EDGE_InvertAlpha.Checked);
   FreeAndNil(ImageStreamA);
   EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
  end else LogE(AMS[EImageNoAlpha]);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.M_EDGE_SUBAlpha_Destroy_LeftClick(Sender: TObject);
begin
 if ImageStream <> nil then begin
  EDGE_SUBAlpha(GUI_RFI,ImageStream,ImageStreamA,apLeft,moDelete,CB_EDGE_InvertAlpha.Checked);
  EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.M_EDGE_SUBAlpha_Destroy_RightClick(Sender: TObject);
begin
 if ImageStream <> nil then begin
  EDGE_SUBAlpha(GUI_RFI,ImageStream,ImageStreamA,apRight,moDelete,CB_EDGE_InvertAlpha.Checked);
  EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
 end else LogW(AMS[WImageConversion]);

end;

procedure TMainForm.SB_OpenArchiveClick(Sender: TObject);
var FileNameString : widestring;
begin
 TS_ArchiveInterface.Show;
 if ODialog_Archive(FileNameString) then Open_Archive(FileNameString,CB_ArchiveFormatList.ItemIndex) else LogI(AMS[ICancelledByUser]);
end;

procedure TMainForm.M_EDGE_BGRClick(Sender: TObject);
begin
 EDGE_ColourSwap(scBGR);
end;

procedure TMainForm.M_EDGE_GBRClick(Sender: TObject);
begin
 EDGE_ColourSwap(scGBR);
end;

procedure TMainForm.M_EDGE_GRBClick(Sender: TObject);
begin
 EDGE_ColourSwap(scGRB);
end;

procedure TMainForm.M_EDGE_RBGClick(Sender: TObject);
begin
 EDGE_ColourSwap(scRBG);
end;

procedure TMainForm.SB_EDGE_Picture_SaveWOAlphaClick(Sender: TObject);
var {FileStream : TStream;}
    FileName : widestring;
begin
 TS_EDGE.Show;
 if (ImageStream <> nil) and (ImageStream.Size > 0) then begin
   FileName := ChangeFileExt(OpenDialog.FileName,ImFormats[CB_ImageFormat.ItemIndex].Ext);
   if SDialog_Image(FileName) then begin
    Image_Save(GUI_RFI,FileName,ImageStream,ImageStreamA,CB_ImageFormat.ItemIndex,CB_PRT_Coords.Checked,False,True,True,CB_JPEGProgressive.Checked,UD_PNG_Compression.Position,UD_JPEG_Quality.Position);
   { FreeAndNil(FileStream);}
   end else LogI(AMS[ICancelledByUser]);
  end
 else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.SB_EDGE_Picture_SaveAlphaClick(Sender: TObject);
begin
 TS_EDGE.Show;
 TB_EDGE_Alpha_ExtractClick(nil);
end;

procedure TMainForm.SB_EDGE_MirrorClick(Sender: TObject);
begin
 DummyProcedure;
end;

procedure TMainForm.LV_ArcFileListDblClick(Sender: TObject);
begin
 if LV_ArcFileList.ItemIndex <> -1 then Extract_SingleFile(RFA[LV_ArcFileList.ItemIndex+1],RFA_ID);
end;

procedure TMainForm.M_Arc_PropertiesClick(Sender: TObject);
begin
 //if LV_ArcFileList.ItemIndex <> -1 then
 FileInfo_Form.TS_Info_File.Show;
 FileInfo_Form.ShowModal;
end;

procedure TMainForm.M_Arc_IconsClick(Sender: TObject);
begin
 LV_ArcFileList.ViewStyle := vsList;
end;

procedure TMainForm.M_Arc_SmallIconsClick(Sender: TObject);
begin
 LV_ArcFileList.ViewStyle := vsSmallIcon;
end;

procedure TMainForm.M_Arc_ListClick(Sender: TObject);
begin
 LV_ArcFileList.ViewStyle := vsList;
end;

procedure TMainForm.M_Arc_ReportClick(Sender: TObject);
begin
 LV_ArcFileList.ViewStyle := vsReport;
end;

procedure TMainForm.M_Arc_FilesClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;
 if ArcFormats[CB_ArchiveFormatList.ItemIndex].Stat < $F then begin
  Core_GUI_ArcClearInfo;
  Create_Archive(0);
  FreeAndNil(ArchiveStream);
 end else LogE(AMS[EUnsupportedFormat]);
end;

procedure TMainForm.M_Arc_DirectoryClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;
 if ArcFormats[CB_ArchiveFormatList.ItemIndex].Stat < $F then begin
  Core_GUI_ArcClearInfo;

  RootDir := BrowseForFolder(pwidechar(widestring(AMS[ABrowseForDirTitle])),'',True);
  if RootDir <> '' then begin
   if DirectoryExists(RootDir) then begin
 // Important: don't forget about '\'
    RootDir := RootDir+'\';
    Create_Archive(1);
   end else LogE(AMS[EInvalidDirectory]);
  end else LogI(AMS[iCancelledByUser]);
  FreeAndNil(ArchiveStream);
 end else LogE(AMS[EUnsupportedFormat]);
end;

procedure TMainForm.SB_CompileListClick(Sender: TObject);
var i : integer; List : TStringList;
    FileName : widestring;
begin
 List := TStringList.Create;
 if ODialog_File(FileName) then begin
  List.LoadFromFile(FileName);
  for i := 0 to List.Count-1 do try
   SC3Open(ExtractFilePath(Filename)+List.Strings[i]+'\'+List.Strings[i]+'.scr');
   Application.ProcessMessages;
  except
   {to-do: do nothing}
  end;
  LogM('Batch compilation finished. Totally there were '+inttostr(List.Count)+' file(s).');
 end else LogI(AMS[ICancelledByUser]);
 FreeAndNil(List);
end;

procedure TMainForm.M_Arc_HTMLListClick(Sender: TObject);
var FileName : widestring;
begin
 if ArchiveStream <> nil then begin
  FileName := ChangeFileExt(ExtractFileName(ArchiveFileName),'.htm');
  if SDialog_File(FileName) then begin
   if ExtractFileExt(FileName) = '' then ChangeFileExt(FileName,'.htm');
   HTML_Arc_MakeFileList(FileName);
  end else LogI(AMS[iCancelledByUser]);
 end else LogW(AMS[wArchiveExtract]);
end;

procedure TMainForm.M_Arc_ListGenClick(Sender: TObject);
var ListGen : TStringsW;
    i,j : integer; OldName, FilteredName, FileName : widestring;
begin
if ArchiveStream <> nil then begin
 FileName := '!'+JIS2Wide(ChangeFileExt(ExtractFileName(ArchiveFileName),'.txt'));
 if SDialog_File(FileName) then begin
  ListGen := TStringsW.Create;
  with ListGen do try
   for i := 1 to RecordsCount do begin
    FilteredName := '';

    OldName := JIS2Wide(RFA[i].RFA_3);

    for j := 1 to Length(OldName) do if OldName[j] <> #$0 then FilteredName := FilteredName + OldName[j] else break;

    Add(FilteredName);
   end;
   ListGen.SaveToFile(ChangeFileExt(FileName,'.txt'));
   FreeAndNil(ListGen);
  except
   FreeAndNil(ListGen);
  end;
 end else LogI(AMS[iCancelledByUser]);
end else LogW(AMS[wArchiveExtract]);
end;

procedure TMainForm.M_Arc_CreateFromListClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;
 if ArcFormats[CB_ArchiveFormatList.ItemIndex].Stat < $F then begin
  Core_GUI_ArcClearInfo;
  Create_Archive(2);
  FreeAndNil(ArchiveStream);
 end else LogE(AMS[EUnsupportedFormat]);
end;

procedure TMainForm.SB_CreateArchiveClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;

 if ArcFormats[CB_ArchiveFormatList.ItemIndex].Stat < $F then begin

  Core_GUI_ArcClearInfo;

  if RB_Arc_List.Checked then Create_Archive(2);
  if RB_Arc_Files.Checked then Create_Archive(0);

  if RB_Arc_Directory.Checked then begin
   RootDir := BrowseForFolder(pwidechar(widestring(AMS[ABrowseForDirTitle])),'',True);
   if RootDir <> '' then begin
    if DirectoryExists(RootDir) then begin
  // Important: don't forget about '\'
     RootDir := RootDir+'\';
     Create_Archive(1);
    end else LogE(AMS[EInvalidDirectory]);
   end else LogI(AMS[iCancelledByUser]);
  end;

  FreeAndNil(ArchiveStream);
 end else LogE(AMS[EUnsupportedFormat]);
end;

procedure TMainForm.M_Arc_FragmentationCheckClick(Sender: TObject);
begin
 if ArchiveIsOpened then begin
//  LogM(AMS[AFragCheckResults]+#10#10+ArcFragCheck);
  MessageBox(handle,ArcFragCheck,pchar(AMS[AFragCheckResults]),mb_ok);
 end;
end;

procedure TMainForm.SM_EDGE_GS_ArithmeticMeanClick(Sender: TObject);
begin
 EDGE_GrayScale(0);
end;

procedure TMainForm.SM_EDGE_GS_HDRClick(Sender: TObject);
begin
 EDGE_GrayScale(2);
end;

procedure TMainForm.SM_EDGE_GS_RedClick(Sender: TObject);
begin
 EDGE_GrayScale(3);
end;

procedure TMainForm.SM_EDGE_GS_GreenClick(
  Sender: TObject);
begin
 EDGE_GrayScale(4);
end;

procedure TMainForm.SM_EDGE_GS_BlueClick(Sender: TObject);
begin
 EDGE_GrayScale(5);
end;

procedure TMainForm.SM_EDGE_GS_LumaClick(Sender: TObject);
begin
 EDGE_GrayScale(1);
end;

procedure TMainForm.E_ConsoleKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key = VK_RETURN then begin
  ParseCommand(E_Console.Text);
  E_Console.Text := '';
 end;
end;

procedure TMainForm.L_Mini_LogWDblClick(Sender: TObject);
begin
 TS_Log.Show;
end;

procedure TMainForm.M_Arc_HTMLFormatListClick(Sender: TObject);
var FileName : widestring;
begin
 FileName := 'ArcFormats.htm';
 if SDialog_File(FileName) then begin
  if ExtractFileExt(FileName) = '' then ChangeFileExt(FileName,'.htm');
  HTML_Arc_MakeFormatList(FileName);
 end else LogI(AMS[iCancelledByUser]);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
 if TS_About.Visible then Skin_DrawMainLogo;
 GUI_ArcTool_Measurement;
 if TS_Image.Visible then GUI_ImageTool_Measurement;
end;

procedure TMainForm.TS_AboutShow(Sender: TObject);
begin
 Skin_DrawMainLogo;
end;

procedure TMainForm.CB_EnableDoubleBufferingClick(Sender: TObject);
begin
 SetDoubleBuffered(CB_EnableDoubleBuffering.Checked,MainForm);
end;

procedure TMainForm.M_Arc_FormatsWriteIntoConsoleClick(Sender: TObject);
begin
 Core_Debug_WriteSupportedArchiveFormats;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
 if not CMDParsed then begin
  ParseCommandLine; // to-do: normal command line is not supported yet
  CMDParsed := True;
 end;

 SetDoubleBuffered(CB_EnableDoubleBuffering.Checked,MainForm);
 SetDoubleBuffered(CB_EnableDoubleBuffering.Checked,GrapSForm);
 SetDoubleBuffered(CB_EnableDoubleBuffering.Checked,FileInfo_Form);

end;

procedure TMainForm.M_Arc_HTMLListDirClick(Sender: TObject);
var FileName : widestring;
begin
 RootDir := BrowseForFolder(pwidechar(widestring(AMS[ABrowseForDirTitle])),'',True);
 if RootDir <> '' then begin
  PickDirContents(RootDir,'*',smAllowDirs);
  if SDialog_File(FileName) then begin
   if ExtractFileExt(FileName) = '' then ChangeFileExt(FileName,'.htm');
   HTML_Dir_MakeFileList(FileName);
  end else LogI(AMS[iCancelledByUser]);
 end else LogI(AMS[iCancelledByUser]);
end;

procedure TMainForm.B_IntSkinReloadClick(Sender: TObject);
begin
 Skin_Load('');
end;

procedure TMainForm.B_DumpTranslationClick(Sender: TObject);
var TestIni : TINIFile; i : integer; c, FileName : widestring;
begin
 c := 'Lang';
 Filename := CB_Language.Text+'.lang';
 if SDialog_File(FileName) then begin

  TestIni := TINIFile.Create(Filename);

  with TestIni do begin

   WriteString(c,'LangFlag','Dummy');
   WriteString(c,'FontFace',MainForm.Font.Name);
   WriteInteger(c,'FontSize',MainForm.Font.Size);

///////// OPTIONS CONTROLS
   WriteString(c,'Translator',L_LangAuthorValue.Caption);
   WriteString(c,'TranslatorWWW',L_LangWWWValue.Caption);
   WriteString(c,'TranslatorEMail',L_LangEMailValue.Caption);

///////// COMMON CONTROLS
   WriteString(c,'L_Mini_Log.Hint',L_Mini_Log.Hint);

   for i := 0 to pred(ComponentCount) do begin
    if Components[i].Tag <> -1 then try
     if Components[i] is TTabSheet    then if (Components[I] as TTabSheet).Caption <> ''    then WriteString(c,Components[i].Name,(Components[i] as TTabSheet).Caption);
     if Components[i] is TGroupBox    then if (Components[I] as TGroupBox).Caption <> ''    then WriteString(c,Components[i].Name,(Components[i] as TGroupBox).Caption);
     if Components[i] is TSpeedButton then begin
      if (Components[i] as TSpeedButton).Caption <> '' then WriteString(c,Components[i].Name,        (Components[i] as TSpeedButton).Caption);
      if (Components[i] as TSpeedButton).Hint    <> '' then WriteString(c,Components[i].Name+'.Hint',(Components[i] as TSpeedButton).Hint);
     end;
     if Components[i] is TToolButton then begin
      if (Components[i] as TToolButton).Caption  <> '' then WriteString(c,Components[i].Name,        (Components[i] as TToolButton).Caption);
      if (Components[i] as TToolButton).Hint     <> '' then WriteString(c,Components[i].Name+'.Hint',(Components[i] as TToolButton).Hint);
     end;
     if Components[i] is TButton      then begin
      if (Components[i] as TButton).Caption <> ''      then WriteString(c,Components[i].Name,        (Components[i] as TButton).Caption);
      if (Components[i] as TButton).Hint    <> ''      then WriteString(c,Components[i].Name+'.Hint',(Components[i] as TButton).Hint);
     end;
     if Components[i] is TRadioButton then begin
      if (Components[i] as TRadioButton).Caption <> '' then WriteString(c,Components[i].Name,        (Components[i] as TRadioButton).Caption);
      if (Components[i] as TRadioButton).Hint    <> '' then WriteString(c,Components[i].Name+'.Hint',(Components[i] as TRadioButton).Hint);
     end;
     if Components[i] is TCheckBox    then begin
      if (Components[i] as TCheckBox).Caption <> ''    then WriteString(c,Components[i].Name,        (Components[i] as TCheckBox).Caption);
      if (Components[i] as TCheckBox).Hint    <> ''    then WriteString(c,Components[i].Name+'.Hint',(Components[i] as TCheckBox).Hint);
     end;
     if Components[i] is TLabel      then if (Components[I] as TLabel).Caption <> ''       then WriteString(c,Components[i].Name,(Components[i] as TLabel).Caption);
     if Components[i] is TLabelW     then if (Components[I] as TLabelW).Caption <> ''      then WriteString(c,Components[i].Name,(Components[i] as TLabelW).Caption);
     if Components[i] is TMenuItem   then if (Components[i] as TMenuItem).Caption <> ''    then WriteString(c,Components[i].Name,(Components[i] as TMenuItem).Caption);
    except
    end;
   end;

   // Dumping messages
   for i := 0 to Length(AMS)-1 do WriteString(c,inttohex(i,4),AMS[i]);

  end;

  FreeAndNil(TestIni);
 end;
end;

procedure TMainForm.SB_Data_BatchClick(Sender: TObject);
var iStream, kStream, oStream : TStream;
    Mode, Value : byte;
    FileName, kFileName : widestring;
    i : integer;
begin

 Mode  := CB_DataConv_Mode.ItemIndex;
 Value := UD_DataConv_Value.Position;

 RootDir := BrowseForFolder(pwidechar(widestring(AMS[ABrowseForDirTitle])),'',True);
 if RootDir <> '' then begin
  if DirectoryExists(RootDir) then begin
// Important: don't forget about '\'
   RootDir := RootDir+'\';

   with MainForm do begin

    PickDirContents(RootDir,'*.*',smAllowDirs);

    Progress_Max(AddedFilesW.Count,pColConvert);

    for i := 0 to AddedFilesW.Count-1 do begin

     FileName := RootDir+AddedFilesW.Strings[i];

     // initialisation decision code
     case Mode of
      bcKey : begin
               kFileName := E_DataConv_KeyFile.Text;

               if kFileName = FileName then begin
                LogE(AMS[EKeyFileToSelf]);
                Exit;
               end;

               if FileExists(kFileName) then try
                kStream := TFileStreamJ.Create(kFileName,fmOpenRead);
               except
                LogE(kFileName+' : '+AMS[ECannotOpenFile]);
                Exit;
               end else begin
                LogE(AMS[ENoValidKeyFile]);
                Exit;
               end;
              end;
     end;

     iStream := TFileStreamJ.Create(FileName,fmOpenRead);
     oStream := TFileStreamJ.Create(FileName+'~',fmCreate);

     case Mode of
      bcZlib : ZDecompressStream(iStream,oStream);
      bcKey  : begin
                BlockConvIO(iStream,oStream,kStream,Value,Mode);
                FreeAndNil(kStream);
               end;
      else     BlockConvIO(iStream,oStream,kStream,Value,Mode);
     end;

     FreeAndNil(iStream);
     FreeAndNil(oStream);
     LogI(FileName+' -> '+FileName+'~');

     Progress_Pos(i+1);
     
    end;
   end;

  end else LogE(AMS[EInvalidDirectory]);
 end else LogI(AMS[iCancelledByUser]);

end;

procedure TMainForm.RE_LogDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var WrapRecord : TWrapRecord;
    i,y : integer;
    ItemColor : TColor;
begin
{ with (Control as TListBox).Canvas do begin
  Font.Color := L_Mini_Log.Font.Color;
  Brush.Color := L_Mini_Log.Color;
  FillRect(Rect);
  TextOut(Rect.Left, Rect.Top, (Control as TListBox).Items[Index]);
 end;}
 with Control as TListBox do begin
  if Index < Items.Count then ItemColor := TColor(Items.Objects[Index]) else ItemColor := Skin.Console.S;
  Canvas.Font.Assign(Font); // wrap-text
  If odSelected In State then begin
   Canvas.Font.Color := Skin.Console.BG;
   Canvas.Brush.Color := Skin.Console.SEL;
  end else begin
   Canvas.Font.Color := ItemColor;
  end;
  Canvas.FillRect(Rect);

  WrapRecord := AnimED_Misc.WrapText(Canvas,Items[Index],ClientWidth);
  y := Rect.Top;

  for i := Low(WrapRecord.Lines) to High(WrapRecord.Lines) do begin
   Canvas.TextOut(Rect.Left,y,WrapRecord.Lines[i]);
//  Canvas.TextOut(Rect.Left + 2, Rect.Top, Items[Index]);
   Inc(y,Canvas.TextHeight(WrapRecord.Lines[i]));
  end;

 end;
end;

procedure TMainForm.M_Log_ClbCpyClick(Sender: TObject);
begin
 ListBoxToClipBoard(RE_Log,$FFFFFF,False);
end;

procedure TMainForm.M_Log_ClbCpyAllClick(Sender: TObject);
begin
 ListBoxToClipBoard(RE_Log,$FFFFFF,True);
end;

procedure TMainForm.M_Log_ClearClick(Sender: TObject);
begin
 RE_Log.Clear;
// LogM(AMS[MLogCleared]+' '+DateToStr(Date)+' '+TimeToStr(Time));
end;

procedure TMainForm.M_Log_SaveClick(Sender: TObject);
var FileName : widestring;
    LogFileStream : TStream;
begin
 if SDialog_File(FileName) then begin
  FileName := ChangeFileExt(FileName,'.log');
  LogFileStream := TFileStreamJ.Create(FileName,fmCreate);
  RE_Log.Items.SaveToStream(LogFileStream);
  FreeAndNil(LogFileStream);
 end;
end;

procedure TMainForm.RE_LogMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
var WrapRecord:TWrapRecord;
begin
 with Control as TListBox do begin
  Canvas.Font.Assign(Font);
  WrapRecord := AnimED_Misc.WrapText(Canvas,Items[Index],ClientWidth);
  if WrapRecord.Height < ItemHeight then WrapRecord.Height := ItemHeight;
 end;
 Height := WrapRecord.Height;
end;

procedure TMainForm.TS_ImageShow(Sender: TObject);
begin
 GUI_ImageTool_Measurement;
end;

procedure TMainForm.M_Arc_GetHashesClick(Sender: TObject);
begin
 if LV_ArcFileList.ItemIndex <> -1 then with FileInfo_Form do begin
  B_DoCRC32Click(nil);
  B_DoMD5Click(nil);
  TS_Info_Hashes.Visible := True;
  ShowModal;
 end;
end;

procedure TMainForm.SB_Log_Color_WClick(Sender: TObject);
begin
 Skin_SetMinilogColor(SB_Log_Color_W.Glyph,Skin.Console.W);
end;

procedure TMainForm.SB_Log_Color_EClick(Sender: TObject);
begin
 Skin_SetMinilogColor(SB_Log_Color_E.Glyph,Skin.Console.E);
end;

procedure TMainForm.SB_Log_Color_DClick(Sender: TObject);
begin
 Skin_SetMinilogColor(SB_Log_Color_D.Glyph,Skin.Console.D);
end;

procedure TMainForm.SB_Log_Color_IClick(Sender: TObject);
begin
 Skin_SetMinilogColor(SB_Log_Color_I.Glyph,Skin.Console.I);
end;

procedure TMainForm.SB_Log_Color_MClick(Sender: TObject);
begin
 Skin_SetMinilogColor(SB_Log_Color_M.Glyph,Skin.Console.M);
end;

procedure TMainForm.SB_Log_Color_SClick(Sender: TObject);
begin
 Skin_SetMinilogColor(SB_Log_Color_S.Glyph,Skin.Console.S);
 Skin_UpdateMinilogColors;
end;

procedure TMainForm.SB_Log_Color_BGClick(Sender: TObject);
begin
 Skin_SetMinilogColor(SB_Log_Color_BG.Glyph,Skin.Console.BG);
 Skin_UpdateMinilogColors;
end;

procedure TMainForm.SB_Log_Color_SELClick(Sender: TObject);
begin
 Skin_SetMinilogColor(SB_Log_Color_SEL.Glyph,Skin.Console.SEL);
 Skin_UpdateMinilogColors;
end;

procedure TMainForm.CB_Log_ConSchemeChange(Sender: TObject);
begin
 Skin.Console := conSkins[CB_Log_ConScheme.ItemIndex];
 Skin_UpdateMinilogColors;
 RE_Log.Clear;
 LogM(AMS[MLogCleared]+' '+DateToStr(Date)+' '+TimeToStr(Time)); 
end;

procedure TMainForm.TB_Log_FontSizeChange(Sender: TObject);
begin
 RE_Log.Font.Size := TB_Log_FontSize.Position;
end;

procedure TMainForm.M_Arc_ExtRAWClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;
 if LV_ArcFileList.ItemIndex <> -1 then Extract_SingleFile(RFA[LV_ArcFileList.ItemIndex+1],-1);
end;

procedure TMainForm.M_Arc_ExtAllRAWClick(Sender: TObject);
begin
 TS_ArchiveInterface.Show;
 if ArchiveIsOpened = True then begin
  RootDir := BrowseForFolder(pwidechar(widestring(AMS[ABrowseForDirTitle])),'',True);
  if RootDir <> '' then begin
   if DirectoryExists(RootDir) then begin
 // Important: don't forget about '\'
    RootDir := RootDir+'\';
    Extract_MultipleFiles([],-1);//,not CB_Arc_OldANSINamesCompatMode.Checked);
   end else LogE(AMS[EInvalidDirectory]);
  end else LogI(AMS[iCancelledByUser]);
 end else LogW(AMS[WArchiveExtract]);
end;

procedure TMainForm.FormPaint(Sender: TObject);
begin
 DragAcceptFiles(Handle, True); //fixes incompatibility with coordinate handler
 GUI_ArcTool_Measurement;
 if TS_Image.Visible then GUI_ImageTool_Measurement;
end;

procedure TMainForm.E_DataConv_ValueChange(Sender: TObject);
begin
 ValueInterpreter(UD_DataConv_Value.Position);
end;

procedure TMainForm.SB_EDGE_JPHTMLClick(Sender: TObject);
var FileName : widestring;
begin
 FileName := 'AE_JColour_Table.htm';
 if SDialog_File(FileName) then begin
  if ExtractFileExt(FileName) = '' then ChangeFileExt(FileName,'.htm');
  HTML_Img_MakeColorList(FileName);
 end else LogI(AMS[iCancelledByUser]);
end;

procedure TMainForm.TS_ArchiverShow(Sender: TObject);
begin
 GUI_ArcTool_Measurement;
end;

procedure TMainForm.M_Arc_HiddenDataCheckClick(Sender: TObject);
begin
 ArcDetectHiddenData;
end;

procedure TMainForm.LV_ArcFmtChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
 { Checking the format selector before assigning data }
 if LV_ArcFmt.ItemIndex <> -1 then try
  CB_ArchiveFormatList.ItemIndex := LV_ArcFmt.ItemIndex;
 except
  CB_ArchiveFormatList.ItemIndex := 0;
 end;
end;

procedure TMainForm.B_EDGE_JPEG_ResetClick(Sender: TObject);
begin
 { Setting JPEG quality to "100%" }
 UD_JPEG_Quality.Position := 100;
end;

procedure TMainForm.B_EDGE_PNG_ResetClick(Sender: TObject);
begin
 { Setting PNG compression to "Normal" }
 UD_PNG_Compression.Position := 5;
end;

procedure TMainForm.PM_ArchiveToolPopup(Sender: TObject);
begin
 { Ensures that we have at least one item selected when attempting to call properties dialogue}
 if LV_ArcFileList.Selected = nil then begin
  if LV_ArcFileList.Items.Count > 0 then begin
   LV_ArcFileList.Selected := LV_ArcFileList.Items.Item[0];
  end;
 end;
end;

procedure TMainForm.M_SaveAboutBoxClick(Sender: TObject);
var Filename : widestring;
    fStream : TStream;
begin
 Filename := 'AE_AboutBox.bmp';
 if SDialog_File(Filename,0,0) then begin
  fStream := TFileStreamJ.Create(Filename,fmCreate);
  Image_AniLogo.Picture.Bitmap.SaveToStream(fStream);
  FreeAndNil(fStream);
 end;
end;

procedure TMainForm.TB_EDGE_FlipClick(Sender: TObject);
begin
 if (ImageStream <> nil) and (ImageStream.Size > 0) then begin
  VerticalFlip(ImageStream,GetScanlineLen2(GUI_RFI.RealWidth,GUI_RFI.BitDepth),GUI_RFI.RealHeight);
  EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.TB_EDGE_NegativeClick(Sender: TObject);
begin
 if ImageStream <> nil then begin
  ImageStream.Seek(0,soBeginning);
  BlockXOR(ImageStream,$FF);
{ Updating the preview in main window }
  EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.TB_EDGE_NegativeAlphaClick(Sender: TObject);
begin
 if (ImageStreamA <> nil) and (ImageStreamA.Size > 0) then
  begin
   BlockXOR(ImageStreamA,$FF);
 { Updating the preview in main window }
   EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
  end
 else LogE(AMS[EImageNoAlpha]);
end;

procedure TMainForm.TB_EDGE_Alpha_AppendClick(Sender: TObject);
var ARFI : TRFI;
    FileName : widestring;
begin
{ Проверяем, открыто ли главное изображение }
 if (ImageStream <> nil) and (ImageStream.Size > 0) then begin
  if ODialog_File(FileName) then begin
 { Инициализируем поток для альфа-канала }
   if ImageStreamA <> nil then ImageStreamA.Size := 0;
   if ImageStreamA = nil then ImageStreamA := TMemoryStream.Create;
   if Image_OpenA(GUI_RFI,ARFI,FileName,ImageStreamA) then begin
    LogI(Filename+' '+AMS[AImportedAsAlpha]);
    EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
   end else LogE(AMS[EImageDiffers2]);
  end;
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.TB_EDGE_Alpha_ExtractClick(Sender: TObject);
var RFIA : TRFI; TempoStream : TMemoryStream; AlphaStream : TFileStream;
    FileName : widestring;
begin
 if ImageStream <> nil then begin
  if ((ImageStreamA <> nil) and (ImageStreamA.Size > 0)) and GUI_RFI.ExtAlpha then begin
   FileName := ChangeFileExt(OpenDialog.FileName,'')+'a.bmp';
   if SDialog_File(FileName) then begin
    TempoStream := TMemoryStream.Create;
    AlphaStream := TFileStreamJ.Create(FileName,fmCreate);
    RFIA := GUI_RFI;
    RFIA.BitDepth := 8;
    RFIA.ExtAlpha := False;
    RFIA.Palette := GrayscalePalette;
    if Export_BMP(RFIA,TempoStream,ImageStreamA) then begin
     TempoStream.Seek(0,SoBeginning);
     AlphaStream.CopyFrom(TempoStream,TempoStream.Size);
     LogM(FileName+' '+AMS[ACreatedSuccessfully])
    end else LogE(AMS[ESavingFile]+' '+FileName);
    FreeAndNil(AlphaStream);
    FreeAndNil(TempoStream);
   end else LogI(AMS[ICancelledByUser]);
  end else LogE(AMS[EImageNoAlpha]);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.TB_EDGE_Alpha_DestroyClick(Sender: TObject);
begin
 if ImageStream <> nil then begin
  if (ImageStreamA <> nil) and GUI_RFI.ExtAlpha then begin
    FreeAndNil(ImageStreamA);
    GUI_RFI.ExtAlpha := False;
    EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
   end else LogE(AMS[EImageNoAlpha]);
  end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.TB_EDGE_Alpha_GenerateClick(Sender: TObject);
var Image1, Image2, ImageA : TStream; RFI1, RFI2 : TRFI; i : int64;
    Tempo1, Tempo2 : TStream;
    FileName : widestring;
begin
 Tempo1 := TMemoryStream.Create;
 Tempo2 := TMemoryStream.Create;
 Image1 := TMemoryStream.Create;
 Image2 := TMemoryStream.Create;
 ImageA := TMemoryStream.Create;

 if ODialog_File(FileName) then begin
  if Image_Open(RFI1,i,FileName,Image1,ImageA,False,False,False,False) then begin
   if ODialog_File(FileName) then begin
    if Image_Open(RFI2,i,FileName,Image2,ImageA,False,False,False,False) then begin
     if (RFI1.RealWidth = RFI2.RealWidth) and (RFI1.RealHeight = RFI2.RealHeight) then begin
      if RFI1.BitDepth <> 24 then begin
       RAW_AnyToTrueColor(Image1,nil,Tempo1,RFI1.RealWidth,RFI1.RealHeight,RFI1.BitDepth,RFI1.Palette,False);
       Image1.Size := 0;
       Tempo1.Seek(0, soBeginning);
       Image1.CopyFrom(Tempo1,Tempo1.Size);
      end;
      if RFI2.BitDepth <> 24 then begin
       RAW_AnyToTrueColor(Image2,nil,Tempo2,RFI2.RealWidth,RFI2.RealHeight,RFI2.BitDepth,RFI2.Palette,False);
       Image2.Size := 0;
       Tempo2.Seek(0, soBeginning);
       Image2.CopyFrom(Tempo2,Tempo2.Size);
      end;
      if ImageA <> nil then ImageA.Size := 0 else ImageA := TMemoryStream.Create;
      GenerateAlpha2(Image1,Image2,ImageA,RFI1.RealWidth,RFI1.RealHeight);
      RFI1.BitDepth := 8;
      RFI1.Palette := GrayScalePalette;
      GUI_RFI := RFI1;
    { Freeing GUI image streams }
      FreeAndNil(ImageStream);
      FreeAndNil(ImageStreamA);
      ImageA.Seek(0,soBeginning);
      ImageStream := TMemoryStream.Create;
      ImageStream.CopyFrom(ImageA,ImageA.Size);

      E_ImageFileName.Text := Ansi2Jis(AMS[ANotAFile]);
      L_ImageSize.Caption := AMS[ANotAFile];

      EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);

     end else LogE(AMS[EImageDiffers]);
    end else LogE(AMS[EUnsupportedFormat]);
   end else LogI(AMS[ICancelledByUser]);
  end else LogE(AMS[EUnsupportedFormat]);
 end else LogI(AMS[ICancelledByUser]);

 FreeAndNil(Tempo2);
 FreeAndNil(Tempo1);
 FreeAndNil(ImageA);
 FreeAndNil(Image2);
 FreeAndNil(Image1);

end;

procedure TMainForm.TB_EDGE_Alpha_FlipClick(Sender: TObject);
begin
 if (ImageStream <> nil) and (ImageStream.Size > 0) then begin
  if (ImageStreamA <> nil) and (ImageStreamA.Size > 0) then begin
   VerticalFlip(ImageStreamA,GetScanlineLen2(GUI_RFI.RealWidth,8),GUI_RFI.RealHeight);
   EDGE_GUI_DisplayDraw(GUI_RFI,ImageStream,ImageStreamA);
  end else LogE(AMS[EImageNoAlpha]);
 end else LogW(AMS[WImageConversion]);
end;

procedure TMainForm.L_ArchiveFormatDblClick(Sender: TObject);
begin
 { Ensures that we have at least one item selected when attempting to call properties dialogue}
 { Commented out by design :P }
{ if LV_ArcFileList.Selected = nil then begin
  if LV_ArcFileList.Items.Count > 0 then begin
   LV_ArcFileList.Selected := LV_ArcFileList.Items.Item[0];
  end;
 end;}
 FileInfo_Form.TS_Info_Archive.Show;
 FileInfo_Form.ShowModal;
end;

procedure TMainForm.L_NepetaByCAClick(Sender: TObject);
begin
 ShellExecute(handle, nil, 'http://countaile.deviantart.com/', nil, nil, sw_shownormal);
end;

procedure TMainForm.L_NepetaByCAMouseEnter(Sender: TObject);
begin
 L_NepetaByCA.Font.Color := $00234AFC;
end;

procedure TMainForm.L_NepetaByCAMouseLeave(Sender: TObject);
begin
 L_NepetaByCA.Font.Color := clWhite;
end;

procedure TMainForm.CB_EDGE_ColourSwapModeChange(Sender: TObject);
begin
 ImageList_EDGE.GetIcon(CB_EDGE_ColourSwapMode.ItemIndex,I_EDGE_ColourSwap.Picture.Icon);
end;

procedure TMainForm.CB_EDGE_GrayScaleModeChange(Sender: TObject);
var m : byte;
begin
 case CB_EDGE_GrayScaleMode.ItemIndex of
  3 : m := 11;
  4 : m := 12;
  5 : m := 13;
 else m := 24;
 end;
 ImageList_EDGE.GetIcon(m,I_EDGE_GrayScale.Picture.Icon);
end;

procedure TMainForm.TB_EDGE_GrayscaleClick(Sender: TObject);
begin
 EDGE_GrayScale(CB_EDGE_GrayScaleMode.ItemIndex);
end;

procedure TMainForm.TB_EDGE_ColorSwapClick(Sender: TObject);
begin
 EDGE_ColourSwap(CB_EDGE_ColourSwapMode.ItemIndex);
end;

end.

