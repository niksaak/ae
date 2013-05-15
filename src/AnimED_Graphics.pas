{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  EDGE Image library (format processing module)
  Written by dsp2003 & Nik.
}

unit AnimED_Graphics;

interface

uses Classes, Sysutils, Graphics, IniFiles, pngimage, FileStreamJ,
     AnimED_Console,
     AnimED_Translation,
     AnimED_Translation_Strings,
     AnimED_Math,
     AG_Fundamental,
     AG_StdFmt,
     AG_RFI,
     AG_CEL,
     AG_EAGLS,
     AG_Ethornell_BGI,
     AG_GPD,
     AG_IES_HeatSoft,
     AG_MGD,
     AG_MGF,
     AG_IKURA_GDL,
     AG_KID_Engine,
     AG_TeethingRing5,
     AG_Will_Picture_File,
     AG_ED8_EDT,
     AG_Portable_Network_Graphics,
     AG_GIF,
     AG_CPB,
     AG_Crowd,
     AG_DWQ_NNN,
     AG_DatamPolystar,
     AG_YGA_YGM,
     AG_Burns_EENC_PNG,
     AG_AtelierKaguya_PRS,
     _AG_CV2,

     AA_RFA;

function Init_Image_Formats : TStringList;
procedure IFAdd(IGFunc : TIGFunction);

function Image_Open(var RFI : TRFI; var DisplaySize : int64; FileName : widestring; var OutputStream, OutputStreamA : TStream; PRTCoords, EnableAlpha, CWPColorSwap, CWPKillAlpha : boolean; LoadSepAlpha : boolean = False) : boolean;
function Image_OpenA(var RFI, ARFI : TRFI; FileName : widestring; var OutputStreamA : TStream) : boolean;
function Image_Save(var RFI : TRFI; FileName : widestring; var InputStream, InputStreamA : TStream; FormatIndex : integer; PRTCoords, EnableAlpha, CWPColorSwap, CWPGenAlpha, JPEGProgressive : boolean; PNGCompression, JPEGQuality : integer) : boolean;
{function Image_SaveA(var RFI : TRFI; FileName : string; var InputStreamA : TStream) : boolean;}

var {RFI_Stream, RFI_StreamA : TStream; RFI_Global : TRFI; }
     IGFunctions : array of TIGFunction;
     ImFormats : array of TImageFormats;
     RFI_ID : integer;

const EDGE_HEADER = 'EDGE';

implementation

uses AnimED_Main;

procedure IFAdd(IGFunc : TIGFunction);
begin
 SetLength(IGFunctions,Length(IGFunctions)+1); // увеличиваем длину массива на единицу
 SetLength(ImFormats,Length(ImFormats)+1);   // увеличиваем длину массива на единицу
 IGFunctions[Length(IGFunctions)-1] := IGFunc; // присваиваем функцию инициализации формата в массив
 IGFunctions[Length(IGFunctions)-1](ImFormats[Length(IGFunctions)-1]); // выполняем функцию инициализации формата
end;

function Init_Image_Formats : TStringList;
var i : integer;
    FormatList : TStringList;
begin
  IFAdd(IG_BMP);
  IFAdd(IG_PRT);
  IFAdd(IG_BGI);
  IFAdd(IG_PNG);
  IFAdd(IG_GIF);
  IFAdd(IG_JPG);
  IFAdd(IG_PS2);
  IFAdd(IG_PSI);
  IFAdd(IG_TGA);
  IFAdd(IG_ZBM);
  IFAdd(IG_CWP);
  IFAdd(IG_GAX);
  IFAdd(IG_CPS);
  IFAdd(IG_CPB);
  IFAdd(IG_GPD);
  IFAdd(IG_IES);
  IFAdd(IG_TR5);
  IFAdd(IG_GGA);
  IFAdd(IG_GGD);
  IFAdd(IG_GGP);
  IFAdd(IG_CEL);
  IFAdd(IG_WIPF);
  IFAdd(IG_MGD);
  IFAdd(IG_MGF);
  IFAdd(IG_ED8);
  IFAdd(IG_EDT);
  IFAdd(IG_EAGLS);
  IFAdd(IG_DWQ_NNN);
  IFAdd(IG_YGA_YGM);
  IFADD(IG_EENC_PNG);
  IFADD(IG_PRS);
  IFADD(IG_CV2);

  FormatList := TStringList.Create;
  for i := 0 to Length(ImFormats)-1 do begin
   FormatList.Add(ArcSymbol[ImFormats[i].Stat]+' '+ImFormats[i].Name);
  end;

  Result := FormatList;
end;

function Image_Open(var RFI : TRFI; var DisplaySize : int64; FileName : widestring; var OutputStream, OutputStreamA : TStream; PRTCoords, EnableAlpha, CWPColorSwap, CWPKillAlpha : boolean; LoadSepAlpha : boolean = False) : boolean;
var {FileStream : TFileStream;} InputStream : TStream; PRT_ini : TIniFile; ARFI :TRFI;
     i : integer;
label ValidImage, StopThis;
begin
 Result := False;
 OpenedImageName := FileName;
 try
  InputStream := TFileStreamJ.Create(FileName,fmOpenRead);
//  InputStream := TMemoryStream.Create;
//  InputStream.CopyFrom(FileStream,FileStream.Size);
//  FreeAndNil(FileStream);

{ Getting the file stream size here, otherwise we'll never get it in other places %) }
  DisplaySize := InputStream.Size;

  if not EnableAlpha then FreeAndNil(OutputStreamA);
  
  for i := 0 to Length(ImFormats)-1 do
  begin
    if @ImFormats[i].Open <> nil then RFI := ImFormats[i].Open(InputStream,OutputStream,OutputStreamA);
    if RFI.Valid then begin
     RFI_ID := i;
     goto ValidImage;
    end;
  end;
  if CWPKillAlpha then FreeAndNil(OutputStreamA);

  goto StopThis;

  ValidImage:

  MainForm.L_ImageFormat.Caption := ImFormats[RFI_ID].Name;

  if FileExists(ChangeFileExt(FileName,'.ini')) and PRTCoords then begin
   PRT_ini := TIniFile.Create(ChangeFileExt(FileName,'.ini'));
   Import_Info(RFI,PRT_ini);
  end;

{ Подгружает альфа-канал из отдельной битмапсы }
  if EnableAlpha and (FileExists(ChangeFileExt(FileName,'')+'a.bmp') and LoadSepAlpha) then Image_OpenA(RFI,ARFI,ChangeFileExt(FileName,'')+'a.bmp',OutputStreamA);

  Result := True;
 StopThis:
 except
  Result := False;
 end;
 FreeAndNil(InputStream);

end;

function Image_OpenA(var RFI, ARFI : TRFI; FileName : widestring; var OutputStreamA : TStream) : boolean;
var TempoStream, TempoStreamA, NulStream : TStream;
    blank : int64;
begin
 Result := False;
{ Инициализируем поток для альфа-канала }
 TempoStream  := TMemoryStream.Create;
 TempoStreamA := TMemoryStream.Create;
 NulStream    := TMemoryStream.Create; // will not be used, but required...

 if Image_Open(ARFI,blank,FileName,TempoStream,NulStream,False,False,False,False) then begin
{ Если размеры "альфы" и изображения не равны, тогда посылаем всё нафиг }
  if (ARFI.RealWidth = RFI.RealWidth) and (ARFI.RealHeight = RFI.RealHeight) then begin
 { Независимо от цвета, преобразуем в 32-битный... }
   RAW_AnyToTrueColor(TempoStream,nil,TempoStreamA,ARFI.RealWidth,ARFI.RealHeight,ARFI.BitDepth,ARFI.Palette);
 { Обнуляем временный поток }
   TempoStream.Size := 0;
 { ...а затем в Grayscale (медленно, зато надёжно :) }
   RAW_TrueColorToGrayScale(TempoStreamA,TempoStream,ARFI.RealWidth,ARFI.RealHeight,32);
   TempoStream.Seek(0,soBeginning);
   OutputStreamA.CopyFrom(TempoStream,TempoStream.Size);
   RFI.ExtAlpha := True;
   Result := True;
  end;
 end;
 FreeAndNil(TempoStream);
 FreeAndNil(TempoStreamA);
 FreeAndNil(NulStream);
end;

function Image_Save;
var OutputStream : TStream;
    FileStream : TFileStream;
    PRT_ini : TIniFile;
begin
 Result := False;
 OutputStream := TMemoryStream.Create;
 PNGCompression_PNG := PNGCompression;
 JPGCompression_JPG := JPEGQuality;
 Progressive := JPEGProgressive;
 SavingImageName := FileName;
 if @ImFormats[FormatIndex].Save = nil then
 begin
   LogE(AMS[EUnsupportedFormat]);
   Exit;
 end;
 FileStream := TFileStreamJ.Create(FileName,fmCreate);
 if EnableAlpha then
   ImFormats[FormatIndex].Save(RFI,OutputStream,InputStream,InputStreamA)
 else
   ImFormats[FormatIndex].Save(RFI,OutputStream,InputStream,nil);

 if ((RFI.RenderWidth > 0) or (RFI.RenderHeight > 0)) or ((RFI.X > 0) or (RFI.Y > 0)) then
  begin
   PRT_ini := TIniFile.Create(ChangeFileExt(FileName,'.ini'));
   Export_Info(RFI,PRT_ini);
  end;
 OutputStream.Seek(0,soBeginning);
 FileStream.CopyFrom(OutputStream,OutputStream.Size);
 FreeAndNil(FileStream);
 FreeAndNil(OutputStream);
 Result := True;
end;

end.