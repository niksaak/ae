{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  YGA Yumemiru Game Maker Image Format library

  Written by dsp2003.
}

unit AG_YGA_YGM;

interface

uses Classes, SysUtils,
     Generic_LZXX,
     AG_Fundamental,
     AG_RFI;

type
 TYGAHeader = packed record
  Magic     : array[1..4] of char; // 'yga'#0
  Width     : longword; // Image Width
  Height    : longword; // Image Height
  Unknown   : longword; // usually '1'. probably a compression flag?
  DataSize  : longword; // Size of uncompressed data
  CDataSize : longword; // Size of compressed data
 end;

function Import_YGA_YGM(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
//function Export_YGA_YGM(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_YGA_YGM(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_YGA_YGM;
begin
 with ImFormat do begin
  Name := '[YGA] Yumemiru Game Maker';
  Ext  := '.yga';
  Stat := $F;
  Open := Import_YGA_YGM;
//  Save := Export_YGA_YGM;
  Ver  := $20100601;
 end;
end;

function Import_YGA_YGM(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    Hdr : TYGAHeader;
    TempoStream : TStream;
label StopThis;
begin
 RFI.Valid := False;

 TempoStream := TMemoryStream.Create;
 with Hdr, InputStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  if Magic <> 'yga'#0 then goto StopThis;
  RFI.RealWidth  := Width;
  RFI.RealHeight := Height;
  if GLZSSDecode(InputStream,TempoStream,InputStream.Size-SizeOf(Hdr),$FEE,$FFF) then begin
   TempoStream.Seek(0,soBeginning);
   VerticalFlip(TempoStream,GetScanlineLen(Width,32),Height);
   TempoStream.Seek(0,soBeginning);
 { Copies alpha channel into separate non-interleaved stream and strips it from base stream }
   if OutputStreamA <> nil then begin
 { Cleanup of the stream - fixes 32-bit image loading }
    OutputStream.Size := 0;
  { ---end }
    ExtractAlpha(TempoStream,OutputStreamA,Width,Height);
    StripAlpha(TempoStream,OutputStream,Width,Height);
   end else OutputStream.CopyFrom(TempoStream,TempoStream.Size); //DeInterleaveStream(TempoStream,OutputStream,GetScanlineLen(Width,BitDepth),GetScanlineGap(Width,BitDepth),Height);
  end;
 end;

 RFI.RealWidth    := Hdr.Width;
 RFI.RealHeight   := Hdr.Height;
 RFI.BitDepth     := 24;
 if (OutputStreamA <> nil) and (OutputStreamA.Size > 0) then RFI.ExtAlpha := True else RFI.ExtAlpha := False;
 RFI.X            := 0; // to-do : should load from INI here
 RFI.Y            := 0;
 RFI.RenderWidth  := 0; // to-do : must be set if image is 32 bit
 RFI.RenderHeight := 0;
 RFI.Palette      := NullPalette; // if BitDepth > 8 then ignored
 RFI.Valid        := True;

StopThis:
 FreeAndNil(TempoStream);
 Result := RFI;
end;

{function Export_GPD(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
var GPD : TGPDHeader;
    ZL : TZLHeader;
    Palette : TPalette;
    TempoStream, ZLTempoStream : TStream;
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);

 TempoStream := TMemoryStream.Create;
 ZLTempoStream := TMemoryStream.Create;

 with GPD do begin

  if (InputStreamA <> nil) and (InputStreamA.Size > 0) then
   begin
    Palette := RFI.Palette;
 // Input image stream,alpha stream,output stream,width,height,bits,palette,prtalpha,interleaved
    RAW_AnyToTrueColor(InputStream,InputStreamA,TempoStream,Width,Height,BitDepth,Palette);
    BitDepth := 32;
   end
  else TempoStream.CopyFrom(InputStream,InputStream.Size);
  TempoStream.Seek(0,soBeginning);

{ Generating GPD-compatible file }
{  Header    := ' DPG';
  VersionId := 1;
  Width     := RFI.RealWidth;
  Height    := RFI.RealHeight;
  Bitdepth  := RFI.BitDepth;
  Dummy     := 0;
  Unknown   := 64;
  LZSize    := 0;
  LZSizeMem := 0;
  Unknown2  := 0;
  FillChar(Dummy2,16,0);
 end;

 VerticalFlip(TempoStream,GetScanlineLen2(RFI.RealWidth,RFI.BitDepth),RFI.RealHeight);

 TempoStream.Seek(0,soBeginning);

 GLZSSEncode(TempoStream,ZLTempoStream);

 FreeAndNil(TempoStream);

 with ZL do begin
  ident:=$4C5A2020;
  orig_size := RFI.RealWidth * RFI.RealHeight * (trunc(RFI.BitDepth / 8));
  comp_size := ZLTempoStream.Size;
  dummy := 0;
 end;

{ Combining data & saving bitmap stream... }
{ OutputStream.Write(GPD,SizeOf(GPD));
 OutputStream.Write(ZL,SizeOf(ZL));

 ZLTempoStream.Seek(0,soBeginning);
 OutputStream.CopyFrom(ZLTempoStream,ZLTempoStream.Size);
 FreeAndNil(ZLTempoStream);

 Result := True;
end;}

end.