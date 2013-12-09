{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Standart Image Handling File
  
  Created by Nik.
  Written by dsp2003.
}

unit AG_StdFmt;

interface

uses Classes, Sysutils, IniFiles, Graphics,
   { Please note: jpeg is a VERY heavy module }
     jpeg,
     AnimED_Math,
     AG_Fundamental,
     AnimED_Console,
     Generic_LZXX,
     AG_RFI;

type
{ Windows Bitmap - header 54 bytes (70) }
 TBMP = packed record
  BMPHeader : array[1..2] of char; // 'BM'
  FileSize  : longword;            // File size. Long word (4 bytes)
  Dummy_0   : longword;            // Dummy
  ImgOffset : longword;            // Image data offset (EXCLUDING PALETTE SIZE!)
  HeaderSize: longword;            // Info header size (normally 40)
  Width     : longword;            // Image Width
  Height    : longword;            // Image Height
  XYZ       : word;                // Number of XYZ planes (always 1)
  Bitdepth  : word;                // Bits per pixel
  CompType  : longword;            // Data compression type (0,3 - no, 1 - 8-bit RLE, 2 - 4-bit RLE)
  StreamSize: longword;            // Bitmap stream size (excluding header)
  Hres      : longword;            // Horisontal pixels per meter resolution (ignore)
  Vres      : longword;            // Vertical pixels per meter resolution (ignore)
  UsedColors: longword;            // Count of used colors. Equals 2^Bitdepth. (could be ignored)
  NeedColors: longword;            // Count of significant colors. Equals UsedColors. :) (could be ignored)
 end;

{ Original Targa (required things only) }
 TTGA = packed record
  IDLength         : byte; // ID field length (usually 0)
{ Little notice: if Paletted = 0, but ImageType = 1, we're dealing with
  UNMAPPED GRAYSCALE IMAGE - it DOESN'T HAVE PALETTE AT ALL!! }
  Paletted         : byte; // Uses palette (True) or not (False)
  ImageType        : byte; // Image type (0 - dummy, 1 - paletted, 2 - true-color, 3 - b&w, 9,10,11 - RLE (not supported)
  PaletteIndex     : word; // Beginning position of the palette (always 0)
  PaletteLength    : word; // Number of palette entries (1 - 2; 4 - 16; 8 - 256; 16,24,32 - 0)
  PaletteEntrySize : byte; // Size of palette entry in BITS (usually 24)
  X                : word; // X render coordinate
  Y                : word; // Y render coordinate
  Width            : word; // Image width
  Height           : word; // Image height
  BitDepth         : byte; // Bits per pixel
  ImageDescriptor  : byte; // Not used, always 0
 end;

{ Portable Network Graphics - head only. PNGs opened & saved via PNGObject library }
 TPNGHeader = packed record
  PNGHeader : array[1..4]  of char; // #137 + 'PNG'
  Chunk1    : array[1..4]  of char; // #13+#10+#26+#10
  IHDRChunk : array[1..4]  of char; // #0+#0+#0+#13
  IHDR      : array[1..4]  of char; // 'IHDR'
  Chunk2    : array[1..17] of char; // Unique
  IDATChunk : array[1..4]  of char; // IDATChunk
  IDAT      : array[1..4]  of char; // 'IDAT'
 end;
// #0,#0,#0
 TPNGFooter = packed record
  IEND      : array[1..4]  of char; // 'IEND'
  IENDChunk : array[1..4]  of char; // #174+#66+#96+#130
 end;

{ Crowd Portable Network Graphics }
 TCWDP = packed record
  CWDPHeader: array[1..4]  of char; // header
  Chunk2    : array[1..17] of char; // Unique
  IDATChunk : array[1..4]  of char; // IDATChunk
 end;

{ CROWD image format - header 56 bytes }
 TCWL = record
  CWLHeader : array[1..28] of char;  // 'cwd format  - version 1.00 -'
  CWLGarbage : array[1..28] of byte; // WTF!? Inverted?! XORed?!! ANDed?!!! SOMEBODY, HELP ME!!!!
 end;

{ Opens\Generates Windows Bitmap-compatible files }
function Import_BMP(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
function Export_BMP(RFI : TRFI; oStream, iStream : TStream; iStreamA : TStream = nil) : boolean;
procedure IG_BMP(var ImFormat : TImageFormats);

{ Opens\Generates TrueVision Targa-compatible files }
function Import_TGA(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
function Export_TGA(RFI : TRFI; oStream, iStream : TStream; iStreamA : TStream = nil) : boolean;
procedure IG_TGA(var ImFormat : TImageFormats);

{ Opens\Generates Joint Photography Experts Group-compatible files }
function Import_JPG(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
//function Export_JPG(RFI : TRFI; oStream, iStream : TStream; Quality : integer = 100; Progressive : boolean = True) : boolean;
function Export_JPG(RFI : TRFI; oStream, iStream : TStream; iStreamA : TStream = nil) : boolean;
procedure IG_JPG(var ImFormat : TImageFormats);

var
  JPGCompression_JPG : integer;
  Progressive : boolean;

implementation

procedure IG_BMP;
begin
 with ImFormat do begin
  Name := '[BMP] Windows Bitmap';
  Ext  := '.bmp';
  Stat := $0;
  Open := Import_BMP;
  Save := Export_BMP;
  Ver  := $20100311;
 end;
end;

procedure IG_TGA;
begin
 with ImFormat do begin
  Name := '[TGA] TrueVision Targa';
  Ext  := '.tga';
  Stat := $0;
  Open := Import_TGA;
  Save := Export_TGA;
  Ver  := $20100311;
 end;
end;

procedure IG_JPG;
begin
 with ImFormat do begin
  Name := '[JPG] Joint Photography Experts Group';
  Ext  := '.jpg';
  Stat := $0;
  Open := Import_JPG;
  Save := Export_JPG;
  Ver  := $20100311;
 end;
end;

function Import_BMP(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
var i : integer;
    BMP : TBMP;
    RFI : TRFI;
    Palette : TPalette;
    tmpStream : TStream;
label StopThis;
begin
 tmpStream := TMemoryStream.Create;
 RFI.Valid := False;
 with BMP, iStream do
  begin
   Seek(0,soBeginning);
 { Reads full BitmapInfoHeader (54 bytes) }
   Read(BMP,SizeOf(BMP));
 { Header checking code }
   if (BMPHeader <> 'BM') or (HeaderSize <> 40) then goto StopThis;
   case CompType of
    0,3 : ;
   else goto StopThis;
   end; // AnimED do not support RLE-encoded BMP files (yet)
 { Reading palette table (0..255) if BitDepth < High Color (16 bit) }
   if BitDepth < 16 then for i := 0 to GetPaletteColors(BitDepth)-1 do Read(Palette.Palette[i],4);
   tmpStream.CopyFrom(iStream,GetScanlineLen(Width,BitDepth)*Height);
   tmpStream.Seek(0,soBeginning);
 { Converting into internal non-interleaved data container }
   DeInterleaveStream(tmpStream,oStream,GetScanlineLen(Width,BitDepth),GetScanlineGap(Width,BitDepth),Height);
 { Copies alpha channel into separate non-interleaved stream and strips it from base stream }
   if (BitDepth > 24) and (oStreamA <> nil) then
    begin
   { Cleanup of the stream - fixes 32-bit image loading }
     oStream.Size := 0;
   { ---end }
     ExtractAlpha(tmpStream,oStreamA,Width,Height);
     StripAlpha(tmpStream,oStream,Width,Height);
     BitDepth := 24;
    end;
  end;

 RFI.RealWidth    := BMP.Width;
 RFI.RealHeight   := BMP.Height;
 RFI.BitDepth := BMP.BitDepth;
 if (oStreamA <> nil) and (oStreamA.Size > 0) then RFI.ExtAlpha := True else RFI.ExtAlpha := False;
 RFI.X        := 0; // to-do : should load from INI here
 RFI.Y        := 0;
 RFI.RenderWidth        := 0; // to-do : must be set if image is 32 bit
 RFI.RenderHeight        := 0;
 RFI.Palette  := Palette; // if BitDepth > 8 then ignored
// RFI.FormatID := 'Windows Bitmap';
 RFI.Valid    := True;

StopThis:
 FreeAndNil(tmpStream);
 Result := RFI;
end;

function Export_BMP(RFI : TRFI; oStream, iStream : TStream; iStreamA : TStream = nil) : boolean;
var BMP : TBMP;
    Palette : TPalette;
    tmpStream : TStream;
begin
 iStream.Seek(0,soBeginning);
 if iStreamA <> nil then iStreamA.Seek(0,soBeginning);

 tmpStream := TMemoryStream.Create;
 with BMP do begin
{ Generating BMP-compatible file }
  BMPHeader  := 'BM';
{ Getting the filesize by formula - Length_Of_Interleaved_Scanline * Height +
  Size of BMP header (+size of palette if < 16 bits). Please note: ANY alpha-
  chanelled PRT file will be converted into 32-bit BMP\TGA-compatible stream. }
  Filesize   := GetScanlineLen(RFI.RealWidth,RFI.BitDepth)*RFI.RealHeight+SizeOf(BMP);
  Dummy_0    := 0;
  ImgOffset  := SizeOf(BMP);
{ Appending the size of palette to Filesize & image data offset }
  case RFI.BitDepth of
   1,4,8 : begin
            Filesize  := Filesize  + GetPaletteSize(RFI.BitDepth);
            ImgOffset := ImgOffset + GetPaletteSize(RFI.BitDepth);
           end;
  end;
  HeaderSize := 40; //always equals 40 in this library ;P
{ Because we're working with PRT (KID Engine) format, there's must be check code
  in order to get the correct image size, since AnimED will not enlarge the data
  to fit the renderer's field size. Storing the Width, Height & coordinates into
  separate INI file must be implemented outside of this function. }
  Width      := RFI.RealWidth;
  Height     := RFI.RealHeight;
  XYZ        := 1; //always 1
  BitDepth   := RFI.BitDepth;
  CompType   := 0; //no compression schemes is supported right now
  StreamSize := Filesize - SizeOf(BMP);
  Hres       := 0; //always 0
  Vres       := 0; //always 0
  UsedColors := 0; //always 0
  NeedColors := 0; //always 0
  Palette    := RFI.Palette;

  if (iStreamA <> nil) and (iStreamA.Size > 0) then
   begin
 // Input image stream,alpha stream,output stream,width,height,bits,palette,prtalpha,interleaved
    RAW_AnyToTrueColor(iStream,iStreamA,tmpStream,Width,Height,BitDepth,Palette);
    BitDepth := 32;
   end
  else InterleaveStream(iStream,tmpStream,Width,Height,BitDepth);
  tmpStream.Seek(0,soBeginning);

{ Combining data & saving bitmap stream... }
  oStream.Write(BMP,SizeOf(BMP));
  if GetPaletteSize(BitDepth) > 0 then oStream.Write(Palette,GetPaletteSize(BitDepth));

  oStream.CopyFrom(tmpStream,tmpStream.Size);
  FreeAndNil(tmpStream);
  Result := True;
 end;
end;

function Import_TGA(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
var i : integer;
    TGA : TTGA;
    RGB : TRGB;
    Palette : TPalette;
    tmpStream : TStream;
    RFI : TRFI;
label StopThis;
begin
 RFI.Valid := False;

 tmpStream := TMemoryStream.Create;
 with TGA, iStream do
  begin
   Seek(0,soBeginning);
 { Reads TGA header (18 bytes) }
   Read(TGA,SizeOf(TGA));

 { TGA Header check code }
   if (Paletted > 1) or (PaletteIndex > 0) then goto StopThis;

 { Grayscale TGA image check }
   if (Paletted = 0) and (ImageType = 1) then Palette := GrayscalePalette;

 { Reading the TGA ID comment }
//   if IDLength > 0 then Read(RFI.Comment,IDLength);

   if PaletteEntrySize > 0 then
    case PaletteEntrySize of
     24 : for i := 0 to GetPaletteColors(BitDepth)-1 do
           begin
          { Reading TGA palette and converting into BMP-compatible }
            Read(RGB,3);
            Palette.Palette[i] := RGBtoARGB(RGB);
           end;
   { I'm not sure if this part of code will be used }
     32 : for i := 0 to GetPaletteColors(BitDepth)-1 do Read(Palette.Palette[i],4);
    end;

   tmpStream.CopyFrom(iStream,GetScanlineLen2(Width,BitDepth)*Height);
   tmpStream.Seek(0,soBeginning);   
   
 { Copies alpha channel into separate non-interleaved stream and strips it from base stream }
   if (BitDepth > 24) and (oStreamA <> nil) then
    begin
     oStream.Size := 0;
     ExtractAlpha(tmpStream,oStreamA,Width,Height);
     StripAlpha(tmpStream,oStream,Width,Height);
     BitDepth := 24;
    end
   else begin
  { Copying into internal non-interleaved data container }
    oStream.CopyFrom(tmpStream,tmpStream.Size);
   end;
  end;

 RFI.RealWidth    := TGA.Width;
 RFI.RealHeight   := TGA.Height;
 RFI.BitDepth     := TGA.BitDepth;
 if oStreamA.Size <> 0 then RFI.ExtAlpha := True else RFI.ExtAlpha := False;
 RFI.X            := TGA.X;
 RFI.Y            := TGA.Y;
 RFI.RenderWidth  := 0;
 RFI.RenderHeight := 0;
 RFI.Palette      := Palette; // if BitDepth > 8 then ignored
// RFI.FormatId     := 'TrueVision Targa';

 RFI.Valid := True;

StopThis:
 FreeAndNil(tmpStream);
 Result := RFI;
end;

function Export_TGA(RFI : TRFI; oStream, iStream : TStream; iStreamA : TStream = nil) : boolean;
var TGA : TTGA;
    Palette : TTGAPalette;
    tmpStream : TStream;
    TempoPalette : TPalette;
begin
 iStream.Seek(0,soBeginning);
 if iStreamA <> nil then iStreamA.Seek(0,soBeginning);

 tmpStream := TMemoryStream.Create;

 with TGA do begin
{ Generating TGA-compatible file }
  IDLength   := 0; // could be changed if there's will be an commentary
{ Marking the TGA as paletted or not }
  if RFI.BitDepth > 8 then
   begin
    Paletted := 0;
    ImageType := 2;
   end
  else
   begin
    Paletted := 1;
    ImageType := 1;
   end;
  PaletteIndex := 0;
  PaletteLength := GetPaletteColors(RFI.BitDepth);
  if Paletted > 0 then begin // fix for PaletteEntrySize by w8m
   PaletteEntrySize := 24; // RGB scheme is preferred instead of ARGB.
                           // Unfortunately, drops single color transparency. :]
  end;
{ Please note: "Render" sizes must be stored into INI file for back-conversion
  into PRTs instead of X/Y fields (otherwise it screws the image and doesn't
  allows to edit it) }
//  X := RFI.X;
//  Y := RFI.Y;
  X := 0;
  Y := 0;
  Width := RFI.RealWidth;
  Height := RFI.RealHeight;
  BitDepth := RFI.BitDepth;
  ImageDescriptor := 0;

{ TGA uses 3-byte palette instead of 4-byte }
  Palette := ARGBPtoRGBP(RFI.Palette);

{ Combining data & saving bitmap stream... }

  if (iStreamA <> nil) and (iStreamA.Size <> 0) then
   begin
 // Input image stream,alpha stream,output stream,width,height,bits,palette,prtalpha,interleaved
    TempoPalette := RGBPtoARGBP(Palette);
    RAW_AnyToTrueColor(iStream,iStreamA,tmpStream,Width,Height,BitDepth,TempoPalette);
    BitDepth := 32;
   end
  else tmpStream.CopyFrom(iStream,iStream.Size);
 end;

 oStream.Write(TGA,SizeOf(TGA));
 if GetPaletteSize(RFI.BitDepth) <> 0 then oStream.Write(Palette,GetPaletteColors(RFI.BitDepth)*3);

 tmpStream.Seek(0,soBeginning);
 oStream.CopyFrom(tmpStream,tmpStream.Size);
 FreeAndNil(tmpStream);

 Result := True;
end;

function Import_JPG;
var MiniBuffer : array[1..3] of char;
    TempoJPG : TJPEGImage;
    TempoBMP : TBitmap;
    tmpStream : TStream;
    RFI : TRFI;
label StopThis;
begin
 RFI.Valid := False;

 iStream.Seek(0,soBeginning);
 oStream.Seek(0,soBeginning);

 iStream.Read(MiniBuffer,SizeOf(MiniBuffer));

 if MiniBuffer <> #$FF#$D8#$FF then goto StopThis;
 iStream.Seek(0,soBeginning);

 TempoJPG := TJPEGImage.Create;
 TempoBMP := TBitmap.Create;
 TempoJPG.LoadFromStream(iStream);
 TempoBMP.Assign(TempoJPG);
 FreeAndNil(TempoJPG);

 tmpStream := TMemoryStream.Create;

 TempoBMP.SaveToStream(tmpStream);
 FreeAndNil(TempoBMP);

 RFI := Import_BMP(tmpStream,oStream);
// RFI.FormatID := 'Joint Photography Experts Group';
 RFI.Valid := True;

 FreeAndNil(tmpStream);

StopThis:
 Result := RFI;
end;

function Export_JPG;
var TempoJPG : TJPEGImage;
    TempoBMP : TBitmap;
    tmpStream : TStream;
begin
 Result := False;
 iStream.Seek(0,soBeginning);
 oStream.Seek(0,soBeginning);
 tmpStream := TMemoryStream.Create;
 Export_BMP(RFI,tmpStream,iStream);
 tmpStream.Seek(0,soBeginning);
 TempoBMP := TBitmap.Create;
 TempoBMP.LoadFromStream(tmpStream);
 FreeAndNil(tmpStream);
 TempoJPG := TJPEGImage.Create;
 TempoJPG.ProgressiveEncoding := Progressive;
 TempoJPG.CompressionQuality := JPGCompression_JPG;
 TempoJPG.Assign(TempoBMP);
 FreeAndNil(TempoBMP);
 TempoJPG.SaveToStream(oStream);
 FreeAndNil(TempoJPG);
 Result := True;
end;

end.