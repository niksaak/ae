{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Configuration functions unit + TIniFile wrapper
  
  Written by dsp2003.
}
unit AnimED_Config;

interface

uses Classes, Forms, SysUtils, IniFiles, Graphics, JUtils;

procedure ConfigLoad;
procedure ConfigSave;

{ function ConfL(IniFileName,IniSection,IniKey : string) : integer;
procedure ConfS(IniFileName,IniSection,IniKey : string; IniValue : string ); overload;
procedure ConfS(IniFileName,IniSection,IniKey : string; IniValue : integer); overload;}

implementation

uses AnimED_Main, AnimED_Skin, AnimED_Console, AnimED_Translation, AnimED_Translation_Strings;

const Conf = 'Config';

procedure ConfigLoad;
var AnimED_Config : TIniFile; ConfName : string;
begin
 try
  ConfName := ChangeFileExt(ExtractFileName(paramstrw(0)),'.conf');
  AnimED_Config := TIniFile.Create(WhereAreWe+ConfName);
  with AnimED_Config, MainForm do
   begin
  { Game Archive Tool }
    CB_AllowArchiveOverwrite.Checked    := ReadBool(conf,'AllowArchiveOverwrite',True);
    RB_Arc_Files.Checked                := ReadBool(conf,'GetFromFiles',True);
    RB_Arc_Directory.Checked            := ReadBool(conf,'GetFromDirectory',False);
    RB_Arc_List.Checked                 := ReadBool(conf,'GetFromList',False);
    CB_RecursiveDirMode.Checked         := ReadBool(conf,'RecursiveDirMode',True);
    CB_ArchiveListHumanReadable.Checked := ReadBool(conf,'HumanReadableFileSizes',False);

    CB_HiddenDataAutoscan.Checked       := ReadBool(conf,'HiddenDataAutoscan',False);
    CB_HiddenDataAutoscanAsk.Checked    := ReadBool(conf,'HiddenDataAutoscanAsk',True);

    try    CB_ArchiveFormatList.ItemIndex := ReadInteger(conf,'LastArchiveFormat',0);
    except CB_ArchiveFormatList.ItemIndex := 0; end;

    { Image Tool (EDGE) }
    CB_ALL_ProcessAlpha.Checked         := ReadBool(conf,'EDGE_All_ProcessAlpha',True);
    CB_All_LoadSepAlpha.Checked         := ReadBool(conf,'EDGE_All_LoadSepAlpha',True);
    CB_EDGE_InvertAlpha.Checked         := ReadBool(conf,'EDGE_All_InvertAlpha',False);

    try    CB_EDGE_GrayScaleMode.ItemIndex := ReadInteger(conf,'EDGE_GrayScaleMode',0);
    except CB_EDGE_GrayScaleMode.ItemIndex := 0; end;
    try    CB_EDGE_ColourSwapMode.ItemIndex := ReadInteger(conf,'EDGE_ColourSwapMode',0);
    except CB_EDGE_ColourSwapMode.ItemIndex := 0; end;

    CB_JPEGProgressive.Checked          := ReadBool(conf,'EDGE_JPEG_Progressive',True);
    UD_JPEG_Quality.Position            := ReadInteger(conf,'EDGE_JPEG_Quality',100);
    UD_PNG_Compression.Position         := ReadInteger(conf,'EDGE_PNG_Compression',9);

    CB_PRT_Coords.Checked               := ReadBool(conf,'EDGE_PRT_Coords',True);

    //CB_CWP_GenerateAlpha.Checked        := ReadBool(conf,'EDGE_CWP_GenerateAlpha',True);
    //CB_CWP_KillAlpha.Checked            := ReadBool(conf,'EDGE_CWP_KillAlpha',True);
    //CB_CWP_ColorSwap.Checked            := ReadBool(conf,'EDGE_CWP_ColorSwap',True);

    CB_EDGE_PreviewColor.Selected       := ReadInteger(conf,'EDGE_PreviewColor',clCream);
    try    CB_EDGE_PreviewColor.ItemIndex := ReadInteger(conf,'EDGE_PreviewColorIndex',0);
    except CB_EDGE_PreviewColor.ItemIndex := 0; end;

    try    CB_ImageFormat.ItemIndex     := ReadInteger(conf,'LastImageFormat',0);
    except CB_ImageFormat.ItemIndex     := 0; end;

  { Scenario Tool }
    CB_SCRAutoimport.Checked            := ReadBool(conf,'AutoImport',True);
    CB_SCRSaveDir.Checked               := ReadBool(conf,'SaveSCRCopy',True);
  { G:\Desktop\For Test -- this is my default test directory. You can change it,
    since your Desktop is not located at the G: drive and you don't even have a
    G: drive in the first place... ;) }
    E_SCRDirectory.Text                 := ReadString(conf,'SaveSCRCopyPath','G:\Desktop\For Test');

  { Misc Tool }
    try    CB_DataConv_Mode.ItemIndex   := ReadInteger(conf,'DataConvMode',0);
    except CB_DataConv_Mode.ItemIndex   := 0; end;
    try    UD_DataConv_Value.Position   := ReadInteger(conf,'DataConvValue',0);
    except UD_DataConv_Value.Position   := 0; end;

    E_DataConv_Keyfile.Text             := ReadString(conf,'DataConvKeyfile','');

  { Options }
    try    CB_Language.ItemIndex        := ReadInteger(conf,'LastLanguage',0);
    except CB_Language.ItemIndex        := 0; end;

    CB_ScreenSnap.Checked               := ReadBool(conf,'ScreenSnap',False);
    
    try    UD_ScreenSnap.Position       := ReadInteger(conf,'ScreenSnapValue',25);
    except UD_ScreenSnap.Position       := 25; end;

    CB_AlphaBlendEffect.Checked         := ReadBool(conf,'AlphaBlendEffect',True);
    Timer_AlphaBlend.Enabled            := CB_AlphaBlendEffect.Checked;
    if not CB_AlphaBlendEffect.Checked then AlphaBlendValue := 255;
    // устанавливаем двойную буферизацию для рендеринга компонентов
    CB_EnableDoubleBuffering.Checked    := ReadBool(conf,'EnableDoubleBuffering',True);

    CB_NoLog.Checked                    := ReadBool(conf,'TurnOffLogging',False);

    CB_LogS.Checked                     := ReadBool(conf,'LogS',True);
    CB_LogW.Checked                     := ReadBool(conf,'LogW',True);
    CB_LogI.Checked                     := ReadBool(conf,'LogI',True);
    CB_LogM.Checked                     := ReadBool(conf,'LogM',True);
    CB_LogE.Checked                     := ReadBool(conf,'LogE',True);
    CB_LogD.Checked                     := ReadBool(conf,'LogD',True);

    CB_BeepOnError.Checked              := ReadBool(conf,'BeepOnError',True);
    CB_BeepOnWarn.Checked               := ReadBool(conf,'BeepOnWarn',False);

    with conSkinCustom do begin
     ID := 'Autosaved user scheme'; // needs translation
     S := ReadInteger(conf,'LogSColor',conSkinDefault.S);
     W := ReadInteger(conf,'LogWColor',conSkinDefault.W);
     I := ReadInteger(conf,'LogIColor',conSkinDefault.I);
     M := ReadInteger(conf,'LogMColor',conSkinDefault.M);
     E := ReadInteger(conf,'LogEColor',conSkinDefault.E);
     D := ReadInteger(conf,'LogDColor',conSkinDefault.D);
    BG := ReadInteger(conf,'LogBGColor',conSkinDefault.BG);
   SEL := ReadInteger(conf,'LogSELColor',conSkinDefault.SEL);
    end;

    CB_NoAutocenter.Checked    := ReadBool(conf,'KeepMWCoords',True);
    CB_KeepWindowState.Checked := ReadBool(conf,'KeepMWState',True);
    CB_NoDefaultSize.Checked   := ReadBool(conf,'KeepMWProps',True);

    { Main window }
{    if CB_NoAutocenter.Checked then begin
     MainForm.Position    := poDesigned;
     MainForm.Left        := ReadInteger(conf,'MainWinX',MainForm.Left);
     MainForm.Top         := ReadInteger(conf,'MainWinY',MainForm.Top);
    end;}
    if CB_NoDefaultSize.Checked then begin
     MainForm.Width       := ReadInteger(conf,'MainWinW',MainForm.Width);
     MainForm.Height      := ReadInteger(conf,'MainWinH',MainForm.Height);
    end;
    if CB_KeepWindowState.Checked then begin
     MainForm.WindowState := TWindowState(ReadInteger(conf,'MainWinS',integer(MainForm.WindowState)));
    end;

    Skin.Console := conSkinCustom;
    Skin_Init_ConsoleSchemes;
    Skin_UpdateMinilogColors;

   end;
 except
//  Log('[E] Loading config file has failed.');
 end;
 FreeAndNil(AnimED_Config);
end;

procedure ConfigSave;
var AnimED_Config : TIniFile; ConfName : string;
begin
 try
  ConfName := ChangeFileExt(ExtractFileName(paramstrw(0)),'.conf');
  AnimED_Config := TIniFile.Create(WhereAreWe+ConfName);
  with AnimED_Config, MainForm do
   begin
    { Game Archive Tool }

    WriteBool(conf,'AllowArchiveOverwrite',CB_AllowArchiveOverwrite.Checked);
    WriteBool(conf,'GetFromFiles',RB_Arc_Files.Checked);
    WriteBool(conf,'GetFromDirectory',RB_Arc_Directory.Checked);
    WriteBool(conf,'GetFromList',RB_Arc_List.Checked);
    WriteBool(conf,'RecursiveDirMode',CB_RecursiveDirMode.Checked);
    WriteBool(conf,'HumanReadableFileSizes',CB_ArchiveListHumanReadable.Checked);

    WriteBool(conf,'HiddenDataAutoscan',CB_HiddenDataAutoscan.Checked);
    WriteBool(conf,'HiddenDataAutoscanAsk',CB_HiddenDataAutoscanAsk.Checked);

    WriteInteger(conf,'LastArchiveFormat',CB_ArchiveFormatList.ItemIndex);

    { Image Tool (EDGE) }
    WriteBool(conf,'EDGE_All_ProcessAlpha',CB_ALL_ProcessAlpha.Checked);
    WriteBool(conf,'EDGE_All_LoadSepAlpha',CB_All_LoadSepAlpha.Checked);
    WriteBool(conf,'EDGE_All_InvertAlpha',CB_EDGE_InvertAlpha.Checked);

    WriteInteger(conf,'EDGE_GrayScaleMode',CB_EDGE_GrayScaleMode.ItemIndex);
    WriteInteger(conf,'EDGE_ColourSwapMode',CB_EDGE_ColourSwapMode.ItemIndex);

    WriteBool(conf,'EDGE_JPEG_Progressive',CB_JPEGProgressive.Checked);
    WriteInteger(conf,'EDGE_JPEG_Quality',UD_JPEG_Quality.Position);
    WriteInteger(conf,'EDGE_PNG_Compression',UD_PNG_Compression.Position);

    WriteBool(conf,'EDGE_PRT_Coords',CB_PRT_Coords.Checked);

    //WriteBool(conf,'EDGE_CWP_GenerateAlpha',CB_CWP_GenerateAlpha.Checked);
    //WriteBool(conf,'EDGE_CWP_KillAlpha',CB_CWP_KillAlpha.Checked);
    //WriteBool(conf,'EDGE_CWP_ColorSwap',CB_CWP_ColorSwap.Checked);
    WriteInteger(conf,'EDGE_PreviewColor',CB_EDGE_PreviewColor.Selected);
    WriteInteger(conf,'EDGE_PreviewColorIndex',CB_EDGE_PreviewColor.ItemIndex);

    WriteInteger(conf,'LastImageFormat',CB_ImageFormat.ItemIndex);

    { Scenario Tool }
    WriteBool(conf,'AutoImport',CB_SCRAutoimport.Checked);
    WriteBool(conf,'SaveSCRCopy',CB_SCRSaveDir.Checked);
    WriteString(conf,'SaveSCRCopyPath',E_SCRDirectory.Text);

    { Misc Tool }
    WriteInteger(conf,'DataConvMode',CB_DataConv_Mode.ItemIndex);
    WriteInteger(conf,'DataConvValue',UD_DataConv_Value.Position);
    WriteString(conf,'DataConvKeyfile',E_DataConv_Keyfile.Text);

    { Options tabsheet }
    WriteInteger(conf,'LastLanguage',CB_Language.ItemIndex);

     { Main window }
    //WriteInteger(conf,'MainWinX',MainForm.Left);
    //WriteInteger(conf,'MainWinY',MainForm.Top);
    WriteInteger(conf,'MainWinW',MainForm.Width);
    WriteInteger(conf,'MainWinH',MainForm.Height);
    WriteInteger(conf,'MainWinS',integer(MainForm.WindowState));

    //WriteBool(conf,'KeepMWCoords',CB_NoAutocenter.Checked);
    WriteBool(conf,'KeepMWState',CB_KeepWindowState.Checked);
    WriteBool(conf,'KeepMWProps',CB_NoDefaultSize.Checked);

    WriteBool(conf,'ScreenSnap',CB_ScreenSnap.Checked);
    WriteInteger(conf,'ScreenSnapValue',UD_ScreenSnap.Position);
    WriteBool(conf,'AlphaBlendEffect',CB_AlphaBlendEffect.Checked);
    WriteBool(conf,'EnableDoubleBuffering',CB_EnableDoubleBuffering.Checked);

    WriteBool(conf,'TurnOffLogging',CB_NoLog.Checked);

    WriteBool(conf,'LogS',CB_LogS.Checked);
    WriteBool(conf,'LogW',CB_LogW.Checked);
    WriteBool(conf,'LogI',CB_LogI.Checked);
    WriteBool(conf,'LogM',CB_LogM.Checked);
    WriteBool(conf,'LogE',CB_LogE.Checked);
    WriteBool(conf,'LogD',CB_LogD.Checked);

    WriteBool(conf,'BeepOnError',CB_BeepOnError.Checked);
    WriteBool(conf,'BeepOnWarn',CB_BeepOnWarn.Checked);

    with Skin.Console do begin
     WriteInteger(conf,'LogSColor',S);
     WriteInteger(conf,'LogWColor',W);
     WriteInteger(conf,'LogIColor',I);
     WriteInteger(conf,'LogMColor',M);
     WriteInteger(conf,'LogEColor',E);
     WriteInteger(conf,'LogDColor',D);
     WriteInteger(conf,'LogBGColor',BG);
     WriteInteger(conf,'LogSELColor',SEL);
    end;


   end;
 except
//  Log('[E] Saving config file has failed.');
 end;
 FreeAndNil(AnimED_Config);
end;

{function ConfL(IniFileName,IniSection,IniKey : string) : integer;
var IniFile : TIniFile;
begin
 IniFile := TIniFile.Create(WhereAreWe+IniFileName);
 Result := IniFile.ReadInteger(IniSection,IniKey,0);
end;

procedure ConfS(IniFileName,IniSection,IniKey : string; IniValue : string ); overload;
var IniFile : TIniFile;
begin
 IniFile := TIniFile.Create(WhereAreWe+IniFileName);
 IniFile.WriteString(IniSection,IniKey,IniValue);
end;

procedure ConfS(IniFileName,IniSection,IniKey : string; IniValue : integer); overload;
var IniFile : TIniFile;
begin
 IniFile := TIniFile.Create(WhereAreWe+IniFileName);
 IniFile.WriteInteger(IniSection,IniKey,IniValue);
end;}

end.