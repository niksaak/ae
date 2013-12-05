{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  GPD OmegaVision (Shuffle!) Image Format library
  
  Format specifications contributed by Nik & Vendor.

  Written by dsp2003.
}

unit AG_GPD;

interface

uses Classes, SysUtils,
     Generic_LZXX,
     AG_Fundamental,
     AG_RFI;

type
 TGPDHeader = packed record
  Header    : array[1..4] of char; // ' DPG'
  VersionId : int64;                // always 01
  Width     : longword;
  Height    : longword;
  Bitdepth  : longword;
  Dummy     : int64;                // 00
  Unknown   : longword;             // always 64
  LZSize    : longword;             // filesize - 272
  LZSizeMem : longword;             // filesize - 272 + padding (208) ??
  Unknown2  : longword;             // ?? always small integer
  Dummy2    : array[1..16] of byte; // 00
 end;

function Import_GPD(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
function Export_GPD(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_GPD(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_GPD;
begin
 with ImFormat do begin
  Name := '[GPD] OmegaVision GPD';
  Ext  := '.gpd';
  Stat := $0;
  Open := Import_GPD;
  Save := Export_GPD;
  Ver  := $20100311;
 end;
end;

function Import_GPD(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    GPD : TGPDHeader;
    TempoStream : TStream;
label StopThis;
begin
 RFI.Valid := False;

 TempoStream := TMemoryStream.Create;
 with GPD, InputStream do begin
  Seek(0,soBeginning);
  Read(GPD,SizeOf(GPD));
  if Header <> ' DPG' then goto StopThis;
  RFI.RealWidth  := Width;
  RFI.RealHeight := Height;
  if ZLDecode(InputStream,TempoStream) then begin
   TempoStream.Seek(0,soBeginning);
   VerticalFlip(TempoStream,GetScanlineLen(Width,BitDepth),Height);
   TempoStream.Seek(0,soBeginning);
 { Copies alpha channel into separate non-interleaved stream and strips it from base stream }
   if ((BitDepth > 24) and (OutputStreamA <> nil)) then begin
 { Cleanup of the stream - fixes 32-bit image loading }
    OutputStream.Size := 0;
  { ---end }
    ExtractAlpha(TempoStream,OutputStreamA,Width,Height);
    StripAlpha(TempoStream,OutputStream,Width,Height);
    BitDepth := 24;
   end else OutputStream.CopyFrom(TempoStream,TempoStream.Size); //DeInterleaveStream(TempoStream,OutputStream,GetScanlineLen(Width,BitDepth),GetScanlineGap(Width,BitDepth),Height);
  end;
 end;

 RFI.RealWidth    := GPD.Width;
 RFI.RealHeight   := GPD.Height;
 RFI.BitDepth     := GPD.BitDepth;
 if (OutputStreamA <> nil) and (OutputStreamA.Size > 0) then RFI.ExtAlpha := True else RFI.ExtAlpha := False;
 RFI.X            := 0; // to-do : should load from INI here
 RFI.Y            := 0;
 RFI.RenderWidth  := 0; // to-do : must be set if image is 32 bit
 RFI.RenderHeight := 0;
 RFI.Palette      := NullPalette; // if BitDepth > 8 then ignored
// RFI.FormatID     := 'OmegaVision GPD';
 RFI.Valid        := True;

StopThis:
 FreeAndNil(TempoStream);
 Result := RFI;
end;

function Export_GPD(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
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
  Header    := ' DPG';
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
 OutputStream.Write(GPD,SizeOf(GPD));
 OutputStream.Write(ZL,SizeOf(ZL));

 ZLTempoStream.Seek(0,soBeginning);
 OutputStream.CopyFrom(ZLTempoStream,ZLTempoStream.Size);
 FreeAndNil(ZLTempoStream);

 Result := True;
end;

end.