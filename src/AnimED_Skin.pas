{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  GUI & skin unit (incomplete, external skins are not supported yet)

  Written by dsp2003.
}
unit AnimED_Skin;

interface

uses AnimED_Console,
     AnimED_FileTypes,
     AnimED_Misc,
     AG_Fundamental,
     SysUtils, Graphics, Controls, Forms, ComCtrls, ExtCtrls, StdCtrls, Classes, Buttons, pngimage, jpeg;

type
 TAEConsoleSkin = packed record
  ID  : string; // skin name
  S   : TColor; // static
  W   : TColor; // warning
  I   : TColor; // info
  M   : TColor; // message
  E   : TColor; // error
  D   : TColor; // debug
  BG  : TColor; // background color
  SEL : TColor; // selection color
 end;

 TAEInterfaceSkin = packed record
  Ico_Arc_Open        : TPNGObject;
  Ico_Arc_Extract     : TPNGObject;
  Ico_Arc_Extract_ALL : TPNGObject;
  Ico_Arc_Create      : TPNGObject;
  Ico_Arc_Close       : TPNGObject;
  Ico_Audio_Open      : TPNGObject;
  Ico_Audio_Convert   : TPNGObject;
  Ico_Audio_Batch     : TPNGObject;
  Ico_Img_Open        : TPNGObject;
  Ico_Img_Convert     : TPNGObject;
  Ico_Img_Batch       : TPNGObject;
  Ico_Img_GrapS       : TPNGObject;
  Ico_SCR_Open        : TPNGObject;
  Ico_SCR_Import      : TPNGObject;
  Ico_SCR_Export      : TPNGObject;
//  Ico_SCR_Repair      : TPNGObject;
  Ico_File_Invert     : TPNGObject;
  Ico_File_Bruteforce : TPNGObject;
//  Ico_Misc_Exedit     : TPNGObject;
  Ico_Dummy           : TPNGObject;
//  Ico_Log_Clear       : TPNGObject;
  Ico_Log_Save        : TPNGObject;

  MASCOT              : TPNGObject;

  GUI_LOGO            : TPNGObject;
  GUI_LOGO_XY         : array[1..2] of integer;
  GUI_LOGO_CODENAME   : TPNGObject;

  Console             : TAEConsoleSkin;
 end;

var intImgList : TImageList;
    Skin : TAEInterfaceSkin;
    conSkins : array of TAEConsoleSkin;

         conSkinCustom   : TAEConsoleSkin; // yes, this is a variable, not a function

function conSkinClassic  : TAEConsoleSkin;
function conSkinDefault  : TAEConsoleSkin;
function conSkinTerminal : TAEConsoleSkin;
function conSkinSystem   : TAEConsoleSkin;

procedure Skin_Init_ConsoleSchemes;
procedure Skin_DrawMinilogColor(SetGlyph : TBitmap; var SetColor : TColor);
procedure Skin_SetMinilogColor(SetGlyph : TBitmap; var SetColor : TColor);
procedure Skin_UpdateMinilogColors;
procedure Skin_InitDefaultMinilogColors;

procedure Skin_Init;
procedure Skin_Load(FileName : widestring);
procedure Skin_Load_BuiltIn;
procedure Skin_Assign;
procedure Skin_DrawMainLogo;
procedure Skin_Free;

procedure Skin_DrawButtonIcon(Glyph : TBitmap; Source : TGraphic; GlyphWidth : integer = 48; GlyphHeight : integer = 48; DrawColor : TColor = clBtnFace);

procedure KillTColor(var SB : TComponent);

procedure SetDoubleBuffered(Mode : boolean; ParentForm : TForm);

procedure GradientFill(Canvas : TCanvas; F, L : TARGB; x,y,w,h : longword; Mode : integer = 0);

implementation

uses AnimED_Main, AnimED_Translation, AnimED_Translation_Strings;

function conSkinClassic;
begin
 with Result do begin
  ID := 'Classic';
  S := clBlack;
  W := clMaroon;
  I := clNavy;
  M := clGreen;
  E := clRed;
  D := $0052A4FF;
  BG := clWhite;
  SEL := BG xor $00FFFFFF;
 end;
end;

function conSkinDefault;
begin
 with Result do begin
  ID  := 'Modern';
  S   := $FFFFFF;
  W   := $91C8FF;
  I   := $BFFFDB;
  M   := $CEF5FF;
  E   := $8080FF;
  D   := $D3D3D3;
  BG  := $6F6F6F;
  SEL := $FFFFFF;
 end;
end;

function conSkinTerminal;
begin
 with Result do begin
  ID  := 'Terminal';
  S   := $FFFFFF;
  W   := $DFF7FF;
  I   := $FFF1D7;
  M   := $FFF4EA;
  E   := $D9D9FF;
  D   := $B3FFD9;
  BG  := $C08000;
  SEL := $FFFFFF;
 end;
end;

function conSkinSystem;
begin
 with Result do begin
  ID := 'System';
  S := clWindowText;
  W := clInactiveCaption;
  I := clHotLight;
  M := clHighLight;
  E := clGradientActiveCaption;
  D := clActiveCaption;
  BG := clHighlightText;
  SEL := BG xor $00FFFFFF;
 end;
end;

procedure Skin_Init_ConsoleSchemes;
var i : longword;
begin
 SetLength(conSkins,5);
 conSkins[0] := conSkinClassic;
 conSkins[1] := conSkinDefault;
 conSkins[2] := conSkinTerminal;
 conSkins[3] := conSkinSystem;
 conSkins[4] := conSkinCustom; // custom user scheme

 with MainForm.CB_Log_ConScheme do begin
  for i := 0 to Length(conSkins)-1 do Items.Add(conSkins[i].ID);
  ItemIndex := Items.Count - 1;
 end;

end;

procedure Skin_DrawMinilogColor;
var GetGlyph : TBitmap;
begin
 GetGlyph := TBitmap.Create;
 with GetGlyph do begin
  Width := 8;
  Height := Width;
  TransparentColor := clNone;
  with Canvas do begin
   Brush.Color := SetColor;
   Pen.Color := SetColor;
   FillRect(Rect(0,0,Width,Height));
  end;
  SetGlyph.Assign(GetGlyph);
  FreeAndNil(GetGlyph);
 end;
end;

procedure Skin_SetMinilogColor;
begin
 MainForm.ColorDialog.Color := SetColor;
 if MainForm.ColorDialog.Execute then begin
  SetColor := MainForm.ColorDialog.Color;
  Skin_DrawMinilogColor(SetGlyph,SetColor);
 end;
end;

procedure KillTColor(var SB : TComponent);
begin
 if SB is TSpeedButton then try
  (SB as TSpeedButton).Glyph.TransparentColor := clNone;
 except
 end;
end;

procedure SetDoubleBuffered(Mode : boolean; ParentForm : TForm);
var i : integer;
begin
 with ParentForm do begin
  DoubleBuffered := Mode;
  for i := 0 to pred(ComponentCount) do try
   // Note: This will not work with stupid TRichEdit... =.=
   if Components[i] is TWinControl then TWinControl(Components[i]).DoubleBuffered := Mode;
  except
   { Улыбаемся и машем }
  end;
 end;
end;

procedure Skin_Load(FileName : widestring);
begin
 try
  Skin_Free;
  Skin_Init;
  if FileName <> '' then
   try
   { to-do : write external skins handling code }
   except
    LogE(AMS[EUnexpectedError]);
   end
  else
   try
    Skin_Load_BuiltIn;
   except
    LogE(AMS[EUnexpectedError]);
   end;
  Skin_Assign;
//  Skin_Free;
 except
  LogE(AMS[EUnexpectedError]);
 end;
end;

{ Draws translucent graphics (hack for TSpeedButton & other native Delphi 7 components). ^___^ }
procedure Skin_DrawButtonIcon(Glyph : TBitmap; Source : TGraphic; GlyphWidth : integer = 48; GlyphHeight : integer = 48; DrawColor : TColor = clBtnFace);
begin
 with Glyph do begin
  Create;
  Width := GlyphWidth;
  Height := GlyphHeight;
{ Fixing color "bug" }
  Canvas.Pen.Color := DrawColor;
  Canvas.Brush.Color := DrawColor;
  Canvas.FillRect(Rect(0,0,GlyphWidth,GlyphHeight));
  Canvas.Draw(0,0,Source);
 end;
end;

procedure Skin_InitDefaultMinilogColors;
begin
 Skin.Console := conSkinDefault;
end;

procedure Skin_UpdateMinilogColors;
begin
 with MainForm, Skin.Console do begin
 { Console colors }
  L_Arc_StatusProcessing.Font.Color := S;
  L_Arc_Status.Font.Color := S;

  L_MessageBoard.Font.Color := M;

  RE_Log.Color             := BG;
  RE_Log.Font.Color        := S;

  L_Mini_Log.Color         := BG;
  L_Mini_Log.Font.Color    := S;

  P_Console.Color          := BG;

  E_Console.Color          := BG;
  E_Console.Font.Color     := S;

  Skin_DrawMinilogColor(SB_Log_Color_S.Glyph,S);
  Skin_DrawMinilogColor(SB_Log_Color_W.Glyph,W);
  Skin_DrawMinilogColor(SB_Log_Color_I.Glyph,I);
  Skin_DrawMinilogColor(SB_Log_Color_M.Glyph,M);
  Skin_DrawMinilogColor(SB_Log_Color_E.Glyph,E);
  Skin_DrawMinilogColor(SB_Log_Color_D.Glyph,D);
  Skin_DrawMinilogColor(SB_Log_Color_BG.Glyph,BG);
  Skin_DrawMinilogColor(SB_Log_Color_SEL.Glyph,SEL);
 end;
end;

procedure Skin_Assign;
begin
 with MainForm, Skin do try
  ImageList_EDGE.GetIcon(24,I_EDGE_GrayScale.Picture.Icon);
  ImageList_EDGE.GetIcon(0,I_EDGE_ColourSwap.Picture.Icon);
 { Game Archive (Un)Packer buttons }
  Skin_DrawButtonIcon(SB_OpenArchive.Glyph,Ico_Arc_Open);
  Skin_DrawButtonIcon(SB_ExtractFile.Glyph,Ico_Arc_Extract);
  Skin_DrawButtonIcon(SB_ExtractALL.Glyph,Ico_Arc_Extract_ALL);
//  Skin_DrawButtonIcon(SB_CreateArchive.Glyph,Ico_Arc_Create);
//  ImageList_Archiver.GetBitmap(12,SB_CreateArchiveSubMenu.Glyph);

  Skin_DrawButtonIcon(SB_CreateArchive.Glyph,Ico_Arc_Create);
  Skin_DrawButtonIcon(SB_CloseArchive.Glyph,Ico_Arc_Close);
  {Audio Converter buttons}
  Skin_DrawButtonIcon(SB_Audio_Open.Glyph,Ico_Audio_Open);
  Skin_DrawButtonIcon(SB_Audio_Encode.Glyph,Ico_Audio_Convert);
  Skin_DrawButtonIcon(SB_Audio_Batch.Glyph,Ico_Audio_Batch);
  {Image Converter buttons}
  Skin_DrawButtonIcon(SB_EDGE_Picture_Open.Glyph,Ico_Img_Open);
  Skin_DrawButtonIcon(SB_EDGE_Picture_Save.Glyph,Ico_Img_Convert);
  Skin_DrawButtonIcon(SB_EDGE_Picture_SaveWOAlpha.Glyph,Ico_Img_Convert);
  Skin_DrawButtonIcon(SB_EDGE_Picture_SaveAlpha.Glyph,Ico_Img_Convert);

  Skin_DrawButtonIcon(SB_Image_Batch.Glyph,Ico_Img_Batch);
  Skin_DrawButtonIcon(SB_Image_GrapS.Glyph,Ico_Img_GrapS);
  { SCR Tool buttons }
  Skin_DrawButtonIcon(SB_OpenSCR.Glyph,Ico_SCR_Open);
  Skin_DrawButtonIcon(SB_ImportSCRChunks.Glyph,Ico_SCR_Import);
  Skin_DrawButtonIcon(SB_ExportSCRChunks.Glyph,Ico_SCR_Export);
  Skin_DrawButtonIcon(SB_CompileList.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB_RestoreSCRDEF.Glyph,Icon_SCR_Repair);
  { Misc | Options buttons }
  Skin_DrawButtonIcon(SB_Data_Process.Glyph,Ico_File_Invert);
  Skin_DrawButtonIcon(SB_Data_Bruteforce.Glyph,Ico_File_Bruteforce);
  Skin_DrawButtonIcon(SB_Data_Batch.Glyph,Ico_Dummy);

//  Skin_DrawButtonIcon(SB_Exedit.Glyph,Ico_Misc_Exedit);

//  Skin_DrawButtonIcon(SB11.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB10.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB9.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB8.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB7.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB6.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB5.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB4.Glyph,Ico_Dummy);

//  Skin_DrawButtonIcon(SB2.Glyph,Ico_Dummy);
//  Skin_DrawButtonIcon(SB1.Glyph,Ico_Dummy);

  { Log buttons }
//  Skin_DrawButtonIcon(SB_ClearLog.Glyph,Ico_Log_Clear);
//  Skin_DrawButtonIcon(SB_SaveLog.Glyph,Ico_Log_Save);

  Skin_UpdateMinilogColors;

  { Credits background }
//  SCredits2.BackgroundImage.Assign(GUI_BACK_CREDITS);

  Skin_DrawMainLogo;

  { Interface icons }

  { Reassigning duplicated icons }
  Skin_DrawButtonIcon(SB_SCRSaveText.Glyph,Ico_Log_Save);

 except
  LogE(AMS[EResourceReadingError]);
 end;
end;

procedure Skin_DrawMainLogo;
var DrawX, DrawY, DrawW, DrawH, i,j,k,l : integer;
    tmpBMP : TBitmap; // double buffer
begin
 with MainForm, Skin do begin

  tmpBMP := TBitmap.Create;

  DrawW := Image_AniLogo.Width;
  DrawH := Image_AniLogo.Height;

  tmpBMP.Width := DrawW;
  tmpBMP.Height := DrawH;

  // устанавливаем размеры полотна. если этого не сделать, картинка при
  // изменении размера будет "обрезана"
  Image_AniLogo.Picture.Bitmap.Width := DrawW;
  DrawX := 16;
  L_Version.Left := Image_AniLogo.Left + DrawX;
  // L_Version2.Left := L_Version1.Left+1;
  Image_AniLogo.Picture.Bitmap.Height := DrawH;
  DrawY := DrawH - DrawX - GUI_LOGO.Height; // отнимаем текущий размер логотипа (64)
  SCredits.Height := DrawH - SCredits.Top*2;
  SCredits.Width := (DrawW div 2) + (DrawW div 4) - SCredits.Left*2;
  L_Version.Top := DrawH+Image_AniLogo.Top-DrawX;
  // L_Version2.Top := L_Version1.Top+1;

  // создаём фоновую заливку
  with tmpBmp do begin

   //GradientFillrectH(tmpBmp.Canvas,InttoARGB($7fffff),InttoARGB($ff7f),0,0,DrawW,DrawH);

   GradientFill(Canvas,InttoARGB($A7E7F5),InttoARGB($7CD8F2),0,0,DrawW,(DrawH div 2)+1);

   randomize;

   Canvas.Pen.Color := $45C4E9;
   Canvas.Brush.Color := $A7E7F5;

   for l := 1 to Random(Random(50)) do begin

    i := Random(DrawW);
    j := Random(DrawH div 2);
    k := Random(Random(500));

    Canvas.Pen.Width := Random(Random(15));

    case (Canvas.Pen.Width mod 2) of
     0: Canvas.Ellipse(i,j,i+k,j+k);
     1: Canvas.Rectangle(i,j,i+k,j+k);
    // 2: Canvas.Draw(i,j,Application.Icon);
    end;

   end;

   Canvas.Pen.Width := 0;

   GradientFill(Canvas,InttoARGB($45C4E9),InttoARGB($8CCFE8),0,(DrawH div 2),DrawW,(DrawH div 2)+1);

   // Drawing mascot sprite :3
   Canvas.Draw((DrawW div 2)-(DrawW div 8),36,MASCOT);

   // AE logo
   Canvas.Draw(DrawX,DrawY,GUI_LOGO);

  end;

  Image_AniLogo.Canvas.Draw(0,0,tmpBMP);

  FreeAndNil(tmpBMP);

//  Image_AniLogo.Canvas.Draw(GUI_LOGO_XY[1]+131,GUI_LOGO_XY[2]-40,GUI_LOGO_CODENAME);

  // "transparent background" for scrolling credits
  if SCredits.Visible then begin
   tmpBMP := TBitmap.Create;
   tmpBMP.Width := SCredits.Width;
   tmpBMP.Height := SCredits.Height;
   tmpBMP.Canvas.Draw(-SCredits.Left,-Scredits.Top,Image_AniLogo.Picture.Bitmap);

   SCredits.BackgroundImage.Assign(tmpBMP);
   FreeAndNil(tmpBMP);
  end;

 end;
end;

procedure Skin_Init;
begin
 with Skin do try
{ Initialising tool buttons }
  Ico_Arc_Open        := TPNGObject.Create;
  Ico_Arc_Extract     := TPNGObject.Create;
  Ico_Arc_Extract_ALL := TPNGObject.Create;
  Ico_Arc_Create      := TPNGObject.Create;
  Ico_Arc_Close       := TPNGObject.Create;
  {Audio Converter buttons}
  Ico_Audio_Open      := TPNGObject.Create;
  Ico_Audio_Convert   := TPNGObject.Create;
  Ico_Audio_Batch     := TPNGObject.Create;
  {Image Converter buttons}
  Ico_Img_Open        := TPNGObject.Create;
  Ico_Img_Convert     := TPNGObject.Create;
  Ico_Img_Batch       := TPNGObject.Create;
  Ico_Img_GrapS       := TPNGObject.Create;
  { SCR Tool buttons }
  Ico_SCR_Open        := TPNGObject.Create;
  Ico_SCR_Import      := TPNGObject.Create;
  Ico_SCR_Export      := TPNGObject.Create;
//  Icon_SCR_Repair     := TPNGObject.Create;
  { Misc | Options buttons }
  Ico_File_Invert     := TPNGObject.Create;
  Ico_File_Bruteforce := TPNGObject.Create;
//  Icon_Misc_Exedit    := TPNGObject.Create;
  { Dummy buttons }
  Ico_Dummy           := TPNGObject.Create;
  { Log buttons }
//  Ico_Log_Clear       := TPNGObject.Create;
  Ico_Log_Save        := TPNGObject.Create;
  { Misc GUI icons }

  { AE logo }
  MASCOT              := TPNGObject.Create;
  GUI_LOGO            := TPNGObject.Create;
  GUI_LOGO_CODENAME   := TPNGObject.Create;
 except
  LogE(AMS[EUnexpectedError]);
 end;
end;

procedure Skin_Free;
begin
 with Skin do try
  FreeAndNil(Ico_Arc_Open);
  FreeAndNil(Ico_Arc_Extract);
  FreeAndNil(Ico_Arc_Extract_ALL);
  FreeAndNil(Ico_Arc_Create);
  FreeAndNil(Ico_Arc_Close);
  {Audio Converter buttons}
  FreeAndNil(Ico_Audio_Open);
  FreeAndNil(Ico_Audio_Convert);
  FreeAndNil(Ico_Audio_Batch);
  {Image Converter buttons}
  FreeAndNil(Ico_Img_Open);
  FreeAndNil(Ico_Img_Convert);
  FreeAndNil(Ico_Img_Batch);
  FreeAndNil(Ico_Img_GrapS);
  { SCR Tool buttons }
  FreeAndNil(Ico_SCR_Open);
  FreeAndNil(Ico_SCR_Import);
  FreeAndNil(Ico_SCR_Export);
//  FreeAndNil(Ico_SCR_Repair);
  { Misc | Options buttons }
  FreeAndNil(Ico_File_Invert);
  FreeAndNil(Ico_File_Bruteforce);
//  FreeAndNil(Ico_Misc_Exedit);
  { Dummy buttons }
  FreeAndNil(Ico_Dummy);
  { Log buttons }
//  FreeAndNil(Ico_Log_Clear);
  FreeAndNil(Ico_Log_Save);
  { Misc GUI icons }

  { AE logo }
  FreeAndNil(MASCOT);

  FreeAndNil(GUI_LOGO);
  FreeAndNil(GUI_LOGO_CODENAME);

 except
  LogE(AMS[EUnexpectedError]);
 end;
end;

procedure Skin_Load_BuiltIn;
var //TempoJPEGStream : TStream;
    i,j : longword;
    tmpbmp       : TBitmap;
//    _MASCOT      : TJPEGImage;
    _MASCOT,
    _MASCOT_MASK : TPNGObject;
begin
{
  This code uses built-in resources. They're stored in the Extras.res.

  Please note: this code uses MODIFIED version of the PNG Object library,
  so the direct PNG resource calling will NOT cause an error.

  In the LoadFromResourceName function the RT_RCDATA was used by default.
  I've added 'PNG' resource section check at the first place.
}
 with Skin do try
{ Game Archive (Un)Packer buttons }
  Ico_Arc_Open.LoadFromResourceName(HInstance,'Ico_Arc_Open');
  Ico_Arc_Extract.LoadFromResourceName(HInstance,'Ico_Arc_Extract');
  Ico_Arc_Extract_ALL.LoadFromResourceName(HInstance,'Ico_Arc_Extract_ALL');
  Ico_Arc_Create.LoadFromResourceName(HInstance,'Ico_Arc_Create');
  Ico_Arc_Close.LoadFromResourceName(HInstance,'Ico_Arc_Close');
  {Audio Converter buttons}
  Ico_Audio_Open.LoadFromResourceName(HInstance,'Ico_Audio_Open');
  Ico_Audio_Convert.LoadFromResourceName(HInstance,'Ico_Audio_Convert');
  Ico_Audio_Batch.LoadFromResourceName(HInstance,'Ico_Audio_Batch');
  {Image Converter buttons}
  Ico_Img_Open.LoadFromResourceName(HInstance,'Ico_Img_Open');
  Ico_Img_Convert.LoadFromResourceName(HInstance,'Ico_Img_Convert');
  Ico_Img_Batch.LoadFromResourceName(HInstance,'Ico_Img_Batch');
  Ico_Img_GrapS.LoadFromResourceName(HInstance,'Ico_Img_GrapS');
  { SCR Tool buttons }
  Ico_SCR_Open.LoadFromResourceName(HInstance,'Ico_SCR_Open');
  Ico_SCR_Import.LoadFromResourceName(HInstance,'Ico_SCR_Import');
  Ico_SCR_Export.LoadFromResourceName(HInstance,'Ico_SCR_Export');
  { Misc | Options buttons }
  Ico_File_Invert.LoadFromResourceName(HInstance,'Ico_File_Invert');
  Ico_File_Bruteforce.LoadFromResourceName(HInstance,'Ico_File_Bruteforce');
  { Dummy buttons }
  Ico_Dummy.LoadFromResourceName(HInstance,'Ico_Dummy');
  { Log buttons }
//  Ico_Log_Clear.LoadFromResourceName(HInstance,'Ico_Log_Clear');
  Ico_Log_Save.LoadFromResourceName(HInstance,'Ico_Log_Save');

  { Mascot }
//  _MASCOT      := TJPEGImage.Create;
  _MASCOT      := TPNGObject.Create;
  _MASCOT_MASK := TPNGObject.Create;

  _MASCOT_MASK.LoadFromResourceName(HInstance,'MASCOT_M');
  _MASCOT.LoadFromResourceName(HInstance,'MASCOT');

//  TempoJPEGStream := TResourceStream.Create(HInstance, 'MASCOT', 'PNG');
//  _MASCOT.LoadFromStream(TempoJPEGStream);
  TmpBMP := TBitmap.Create;
//  TmpBMP.Assign(_MASCOT);
//  FreeAndNil(TempoJPEGStream);
  TmpBMP.Width := _MASCOT.Width;
  TmpBMP.Height := _MASCOT.Height;
  TmpBMP.Canvas.Draw(0,0,_MASCOT);
  MASCOT.Assign(TmpBMP);
//  MASCOT.Assign(_MASCOT);
  FreeAndNil(TmpBmp);
  MASCOT.CreateAlpha;
  for j := 0 to MASCOT.Height do begin
   for i := 0 to MASCOT.Width do begin
    MASCOT.AlphaScanline[j]^[i] := _MASCOT_MASK.Pixels[i,j];
   end;
  end;

  FreeAndNil(_MASCOT);
  FreeAndNil(_MASCOT_MASK);

  { AE logo }
  GUI_LOGO.LoadFromResourceName(HInstance,'LOGO');
  { logo coordinates - 1x, 2y }
  GUI_LOGO_XY[1] := 371;
  GUI_LOGO_XY[2] := 102;
  GUI_LOGO_CODENAME.LoadFromResourceName(HInstance,'LOGO_CODENAME');

 except
  LogE(AMS[EResourceReadingError]);
 end;
end;

{
  Функция рисования градиентной заливки

  F - начальный цвет
  L - конечный цвет
  x,y - начальные координаты
  w,h - ширина и высота для заливки

  Mode:
  0 - сверху вниз (по умолчанию)
  1 - слева направо
}
procedure GradientFill(Canvas : TCanvas; F, L : TARGB; x,y,w,h : longword; Mode : integer = 0);
var C : TARGB;
    i : longword;
begin
 case Mode of
 // Vertical fill (default)
 0: for i := 0 to h do begin
     C.R := F.R + round((L.R - F.R) * ((i+1) / h));
     C.G := F.G + round((L.G - F.G) * ((i+1) / h));
     C.B := F.B + round((L.B - F.B) * ((i+1) / h));
     Canvas.Pen.Color := ARGBtoInt(C);
     Canvas.MoveTo(x,y+i);
     Canvas.LineTo(x+w,y+i);
    end;
 // Horisontal fill
 1: for i := 0 to w do begin
     C.R := F.R + round((L.R - F.R) * ((i+1) / w));
     C.G := F.G + round((L.G - F.G) * ((i+1) / w));
     C.B := F.B + round((L.B - F.B) * ((i+1) / w));
     Canvas.Pen.Color := ARGBtoInt(C);
     Canvas.MoveTo(x+i,y);
     Canvas.LineTo(x+i,y+h);
    end;
 end;
end;

end.