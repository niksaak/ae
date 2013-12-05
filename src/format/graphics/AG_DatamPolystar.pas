{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Datam Polystar PS2 Image formats

  Written by dsp2003.
}

unit AG_DatamPolystar;

interface

uses Classes, Sysutils, Windows,
     AnimED_Math,
     AG_Fundamental,
     AnimED_Console,
     AG_RFI;

type
 { PurePure PS2 Image } 
 TPS2Header = packed record
  Magic   : array[1..8] of char; // [image2]
  Width   : longword;
  Height  : longword;
  BitFlag : longword; // 0 - 32 bit, 2 - 8 bit grayscale, 3 - 16 bit 1555
  Unk1    : longword;
  Unk2    : longword;
  Unk3    : longword;
 end;

 { Private Nurse Maria PS2 Image }
 TPSIHeader = packed record
  Width    : word;
  Height   : word;
  BitDepth : word; // usually 32 bit
  Dummy    : array[1..2042] of byte; // $0
 end;

function Import_PSI(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
//function Export_PSI(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_PSI(var ImFormat : TImageFormats);

function Import_PS2(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
//function Export_PS2(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_PS2(var ImFormat : TImageFormats);

implementation

procedure IG_PSI;
begin
 with ImFormat do begin
  Name := '[PSI] Datam Polystar / PlayStation Image';
  Ext  := '.psi';
  Stat := $F;
  Open := Import_PSI;
//  Save := Export_PSI;
  Ver  := $20100709;
 end;
end;

procedure IG_PS2;
begin
 with ImFormat do begin
  Name := '[PS2] Datam Polystar / PlayStation 2 Image';
  Ext  := '.ps2';
  Stat := $F;
  Open := Import_PS2;
//  Save := Export_TGA;
  Ver  := $20100703;
 end;
end;

function Import_PSI;
var i,j : integer;
    ARGB : TARGB;
    RFI : TRFI;
    Hdr : TPSIHeader;
    tmpStream : TStream;
    Palette : TPalette;
begin
 RFI.Valid := False;

 with Hdr do try
  j := 0;
  InputStream.Seek(0,soBeginning);
  InputStream.Read(Hdr,SizeOf(Hdr));
  for i := 1 to SizeOf(Dummy) do j := j + Dummy[i];
  if j <> 0 then Exit;

  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(InputStream,GetScanlineLen2(Width,BitDepth)*Height);
  tmpStream.Seek(0,soBeginning);
  VerticalFlip(tmpStream,GetScanlineLen2(Width,BitDepth),Height);
  tmpStream.Seek(0,soBeginning);

  OutputStream.Size := tmpStream.Size;

  case BitDepth of
  32 : for i := 1 to tmpStream.Size div 4 do begin
        tmpStream.Read(ARGB,SizeOf(ARGB));

        ARGB := SwapColors32(ARGB,scBGR);

        OutputStream.Write(ARGB,SizeOf(ARGB));
       end;
  else begin
        MessageBox(0,pchar('Processing stopped. The following bit depth is not implemented: '+inttostr(BitDepth)),'AG_DatamPolystar.pas - Import_PSI - Debug',mb_ok);
        FreeAndNil(tmpStream);
        Exit;
       end;
  end;

  OutputStreamA.Size := Width*Height;

  tmpStream.Seek(0,soBeginning);

   for i := 1 to OutputStreamA.Size do begin

   tmpStream.Read(ARGB,SizeOf(ARGB));

   case ARGB.A of
    $0 : ; // doing nothing
    $80 : ARGB.A := (ARGB.A * 2) - 1;
    else ARGB.A := (ARGB.A * 2) + 1;
   end;

   OutputStreamA.Write(ARGB.A,1);

  end;

  FreeAndNil(tmpStream);

  RFI.RealWidth    := Width;
  RFI.RealHeight   := Height;
  RFI.ExtAlpha     := True;
  RFI.BitDepth     := BitDepth;
  RFI.X            := 0;
  RFI.Y            := 0;
  RFI.RenderWidth  := 0;
  RFI.RenderHeight := 0;
  case BitDepth of
   8  : RFI.Palette := Palette; // if BitDepth > 8 then ignored
   32 : RFI.Palette := NullPalette;
  end;

  RFI.Valid := True;

 except
  FreeAndNil(tmpStream);
  Exit;
 end;

 Result := RFI;
end;


function Import_PS2;
var i : integer;
    ARGB : TARGB;
    RGB : TRGB;
    RGB16 : word;
    RFI : TRFI;
    Hdr : TPS2Header;
    tmpStream : TStream;
    BitDepth : integer;
    Palette : TPalette;
begin
 RFI.Valid := False;

 with Hdr do try

  InputStream.Seek(0,soBeginning);
  InputStream.Read(Hdr,SizeOf(Hdr));
  if Magic <> '[image2]' then Exit;

  case BitFlag of
   0 : BitDepth := 32;
   2 : begin
        BitDepth := 8;
        InputStream.Read(Palette,SizeOf(Palette));
       end;
   3 : BitDepth := 16;
  end;

  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(InputStream,GetScanlineLen2(Width,BitDepth)*Height);
  tmpStream.Seek(0,soBeginning);
  VerticalFlip(tmpStream,GetScanlineLen2(Width,BitDepth),Height);
  tmpStream.Seek(0,soBeginning);

  OutputStream.Size := tmpStream.Size;

  case BitFlag of
  0 : begin
       for i := 1 to tmpStream.Size div 4 do begin
        tmpStream.Read(ARGB,SizeOf(ARGB));

        inc(ARGB.B,25);
        inc(ARGB.G,25);
        inc(ARGB.R,25);

        ARGB := SwapColors32(ARGB,scBGR);

        OutputStream.Write(ARGB,SizeOf(ARGB));
       end;
      end;
  3 : begin
       OutputStream.Size := GetScanlineLen2(Width,24)*Height;
       for i := 1 to tmpStream.Size div 2 do begin
        tmpStream.Read(RGB16,SizeOf(RGB16));

        RGB := RGB1555toRGB(RGB16);
        RGB := SwapColors24(RGB,scBGR);

        OutputStream.Write(RGB,SizeOf(RGB));
        BitDepth := 24;
       end;
      end;
  else OutputStream.CopyFrom(tmpStream,OutputStream.Size);
  end;

  if BitFlag = 0 then begin

   OutputStreamA.Size := Width*Height;

   tmpStream.Seek(0,soBeginning);

   for i := 1 to OutputStreamA.Size do begin

    tmpStream.Read(ARGB,SizeOf(ARGB));

    case ARGB.A of
     $0 : ; // doing nothing
     $80 : ARGB.A := (ARGB.A * 2) - 1;
     else ARGB.A := (ARGB.A * 2) + 1;
    end;

    OutputStreamA.Write(ARGB.A,1);

   end;

  end;

  FreeAndNil(tmpStream);

  RFI.RealWidth    := Width;
  RFI.RealHeight   := Height;
  case BitFlag of
   2,3 : RFI.ExtAlpha := False;
   0   : RFI.ExtAlpha := True
  end;
  RFI.BitDepth     := BitDepth;
  RFI.X            := 0;
  RFI.Y            := 0;
  RFI.RenderWidth  := 0;
  RFI.RenderHeight := 0;
  case BitDepth of
   8  : RFI.Palette := Palette; // if BitDepth > 8 then ignored
   32 : RFI.Palette := NullPalette;
  end;

  RFI.Valid := True;

 except
  FreeAndNil(tmpStream);
  Exit;
 end;

 Result := RFI;
end;

{function Export_TGA(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
var TGA : TTGA;
    Palette : TTGAPalette;
    TempoStream : TStream;
    TempoPalette : TPalette;
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);

 TempoStream := TMemoryStream.Create;

 with TGA do begin
{ Generating TGA-compatible file }
{  IDLength   := 0; // could be changed if there's will be an commentary
{ Marking the TGA as paletted or not }
{  if RFI.BitDepth > 8 then
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
  PaletteEntrySize := 24; // RGB scheme is preferred instead of ARGB.
                          // Unfortunately, drops single color transparency. :]

{ Please note: "Render" sizes must be stored into INI file for back-conversion
  into PRTs instead of X/Y fields (otherwise it screws the image and doesn't
  allows to edit it) }
//  X := RFI.X;
//  Y := RFI.Y;
{  X := 0;
  Y := 0;
  Width := RFI.RealWidth;
  Height := RFI.RealHeight;
  BitDepth := RFI.BitDepth;
  ImageDescriptor := 0;

{ TGA uses 3-byte palette instead of 4-byte }
{  Palette := ARGBPtoRGBP(RFI.Palette);

{ Combining data & saving bitmap stream... }

{  if (InputStreamA <> nil) and (InputStreamA.Size <> 0) then
   begin
 // Input image stream,alpha stream,output stream,width,height,bits,palette,prtalpha,interleaved
    TempoPalette := RGBPtoARGBP(Palette);
    RAW_AnyToTrueColor(InputStream,InputStreamA,TempoStream,Width,Height,BitDepth,TempoPalette);
    BitDepth := 32;
   end
  else TempoStream.CopyFrom(InputStream,InputStream.Size);
 end;

 OutputStream.Write(TGA,SizeOf(TGA));
 if GetPaletteSize(RFI.BitDepth) <> 0 then OutputStream.Write(Palette,GetPaletteColors(RFI.BitDepth)*3);

 TempoStream.Seek(0,soBeginning);
 OutputStream.CopyFrom(TempoStream,TempoStream.Size);
 FreeAndNil(TempoStream);

 Result := True;
end;}

end.