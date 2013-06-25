{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  IKURA GDL Image Formats library

  Contributions by Traneko & Nik.

  Written by dsp2003 & Nik.
}

unit AG_IKURA_GDL;

interface

uses Classes, SysUtils, IniFiles,
     AnimED_Math,
     AnimED_Console,
     AG_Portable_Network_Graphics,
     AG_Fundamental,
     AG_RFI;

type
 TGGDHeader = packed record
  ColorMode : longword; // FULL | TRUE | HIGH | 256G ... поксорено на $FF
 end;
 TGGD1 = packed record // Everything else
  Width     : word;     // Image Width
  Height    : word;     // Image Height
 end;
 TGGD2 = packed record // 256G
  Width     : longword; // Image Width
  Height    : longword; // Image Height
  Unknown   : array[1..32] of byte;
  Palette   : TPalette;
 end;
 TGGA = packed record
  Header     : array[1..8] of char; // GGA00000
  Width      : word;
  Height     : word;
  Field_C    : longword;
  HeaderSize : longword;
  CompSize   : longword;
 end;

 { Encrypted PNGs }
 TGGP = packed record
  GGPHeader    : array[0..7] of char; // "GGPFAIKE", master string
  BitdepthC    : longword;            // 0 : use image's value | 32 : ARGB | 24 : RGB | don't used
  XORMask      : array[0..7] of byte; // sub string
  Offset       : longword; // image stream beginning offset
  Length       : longword; // length of image stream
  RegionOffset : longword; // offset of region fields start
  RegionLength : longword; // size of region fields
 end;

 TGGxRegion = packed record
  destX  : word;
  destY  : word; // destination position
  X      : word; // source bounds
  Y      : word; // source bounds
  Width  : word; // source bounds
  Height : word; // source bounds
 end;

{ Opens\Generates GGA-compatible files }
function Decode_GGA(IStream, OStream : TStream; CryptLength : integer; Width : word) : boolean;
function Encode_GGA(IStream, OStream : TStream; CryptLength : integer) : boolean;

function Import_GGA(IStream, OStream : TStream; OStreamA : TStream = nil) : TRFI;
function Export_GGA(RFI : TRFI; OStream, IStream : TStream; IStreamA : TStream = nil) : boolean;
procedure IG_GGA(var ImFormat : TImageFormats);

function Decode_GGD(iStream, oStream : TStream; CryptLength : integer) : boolean;
function Encode_GGD(IStream, OStream : TStream; CryptLength : integer) : boolean;

function Import_GGD(iStream, oStream : TStream; OStreamA : TStream = nil) : TRFI;
function Export_GGD(RFI : TRFI; OStream, IStream : TStream; IStreamA : TStream = nil) : boolean;
procedure IG_GGD(var ImFormat : TImageFormats);

{ GGP decoder }
function Decode_GGP(IStream, OStream : TStream) : boolean;

function Import_GGP(IStream, OStream : TStream; OStreamA : TStream = nil) : TRFI;
procedure IG_GGP(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_GGA;
begin
 with ImFormat do begin
  Name := '[GGA] IKURA GDL GGA';
  Ext  := '.gga';
  Stat := $0;
  Open := Import_GGA;
  Save := Export_GGA;
  Ver  := $20100311;
 end;
end;

procedure IG_GGD;
begin
 with ImFormat do begin
  Name := '[GGD] IKURA GDL GGD';
  Ext  := '.ggd';
  Stat := $0;
  Open := Import_GGD;
  Save := Export_GGD;
  Ver  := $20100311;
 end;
end;

procedure IG_GGP;
begin
 with ImFormat do begin
  Name := '[GGP] IKURA GDL GGP';
  Ext  := '.ggp';
  Stat := $F;
  Open := Import_GGP;
  Save := nil;
  Ver  := $20100311;
 end;
end;

function Import_GGA;
var RFI : TRFI;
    GGA : TGGA;
    TempoStream : TStream;
label StopThis;
begin
 with GGA, RFI, iStream do begin

  Valid := False;

  Seek(0,soBeginning);
  Read(GGA,SizeOf(GGA));
  if Header <> 'GGA00000' then goto StopThis;

  RealWidth  := Width;
  RealHeight := Height;
//  BitDepth   := 32; // GGA is always 32 bit

  Seek(HeaderSize,soBeginning);

  TempoStream := TMemoryStream.Create;

  Decode_GGA(iStream,TempoStream,CompSize,Width);
  VerticalFlip(TempoStream,GetScanLineLen(Width,32),Height);

  TempoStream.Seek(0,soBeginning);
{ Copies alpha channel into separate non-interleaved stream and strips it from base stream }
  if oStreamA <> nil then begin
   ExtractAlpha(TempoStream,oStreamA,Width,Height);
//   BlockXOR(oStreamA,$FF);
  end;

  StripAlpha(TempoStream,oStream,Width,Height);
  BitDepth := 24;
  ExtAlpha := True and (oStreamA <> nil);
  X            := 0;
  Y            := 0;
  RenderWidth  := 0;
  RenderHeight := 0;
  Palette  := NullPalette;

  Valid := True;

 end;

 FreeAndNil(TempoStream);

StopThis:

 Result := RFI;
end;

function Export_GGA;
var i : integer;
    z : byte;
    GGA : TGGA;
    tmpStream,
    tmpStreamE : TStream;
begin
 iStream.Seek(0,soBeginning);
 if iStreamA <> nil then iStreamA.Seek(0,soBeginning);

 tmpStream := TMemoryStream.Create;
 tmpStreamE := TMemoryStream.Create;

 with GGA, RFI do begin

  RAW_AnyToTrueColor(iStream,iStreamA,tmpStream,RealWidth,RealHeight,BitDepth,Palette);

  tmpStream.Seek(0,soBeginning);

  VerticalFlip(tmpStream,GetScanLineLen(RealWidth,32),RealHeight);

  tmpStream.Seek(0,soBeginning);

  Encode_GGA(tmpStream,tmpStreamE,tmpStream.Size);

  Header     := 'GGA00000';
  Width      := RealWidth;
  Height     := RealHeight;
  Field_C    := $11200000;
  HeaderSize := $30;
  CompSize   := tmpStreamE.Size;
 end;

 FreeAndNil(tmpStream);

 tmpStreamE.Seek(0,soBeginning);

 with oStream do begin
  Write(GGA,SizeOf(GGA));
  z := 0;
  for i := 1 to 48-SizeOf(GGA) do Write(z,1);
  CopyFrom(tmpStreamE,tmpStreamE.Size);
 end;

 FreeAndNil(tmpStreamE);

end;

function Import_GGD;
var RFI : TRFI;
    GGD : TGGDHeader;
    GGD1 : TGGD1;
    GGD2 : TGGD2;
    TempoStream, TempoStream2 : TStream;
begin
 with GGD, RFI, iStream do begin

  Valid := False;

  Seek(0,soBeginning);
  Read(GGD,SizeOf(GGD));

  ColorMode := ColorMode xor $FFFFFFFF;

  case ColorMode of
   {FULL} $4C4C5546 : BitDepth := 24;
   {TRUE} $45555254 : BitDepth := 24;
   {HIGH} $48474948 : BitDepth := 16;
   {256G} $47363532 : BitDepth := 8;
  else Exit;
  end;

  case ColorMode of
   $4C4C5546,
   $45555254,
   $48474948 : begin
                Read(GGD1,SizeOf(GGD1));
                RealWidth := GGD1.Width;
                RealHeight := GGD1.Height;
               end;
   $47363532 : begin
                Read(GGD2,SizeOf(GGD2));
                RealWidth := GGD2.Width;
                RealHeight := GGD2.Height;
                Palette := GGD2.Palette;
               end;
  end;

  // Выравнивание ширины изображения

  TempoStream := TMemoryStream.Create;

  TempoStream.Size := IStream.Size-IStream.Position;

  TempoStream.CopyFrom(IStream,IStream.Size-IStream.Position);

  TempoStream.Position := 0;

  TempoStream2 := TMemoryStream.Create;

  Decode_GGD(TempoStream,TempoStream2,GetScanlineLen(RealWidth,BitDepth)*RealHeight);

  TempoStream.Size := 0;

  TempoStream2.Position := 0;

  DeinterleaveStream(TempoStream2,TempoStream,GetScanLineLen(RealWidth,BitDepth),GetScanLineGap(RealWidth,BitDepth),RealHeight);

  FreeAndNil(TempoStream2);

  TempoStream.Position := 0;

  VerticalFlip(TempoStream,GetScanLineLen2(RealWidth,BitDepth),RealHeight);

  TempoStream.Position := 0;

  OStream.Size := TempoStream.Size;
  OStream.CopyFrom(TempoStream,TempoStream.Size);

  ExtAlpha := False and (OStreamA <> nil);

  X            := 0;
  Y            := 0;
  RenderWidth  := 0;
  RenderHeight := 0;
  Palette  := GrayscalePalette;

  Valid := True;

 end;

 FreeAndNil(TempoStream);

 Result := RFI;
end;

function Export_GGD;
var GGD : TGGDHeader; GGD1 : TGGD1;
    tmpStream,
    tmpStreamE : TStream;
begin
 iStream.Seek(0,soBeginning);
 if iStreamA <> nil then iStreamA.Seek(0,soBeginning);

 tmpStream := TMemoryStream.Create;
 tmpStreamE := TMemoryStream.Create;

 with GGD, GGD1, RFI do begin

  case BitDepth of
   32 : ColorMode := $4C4C5546; {FULL}
   24 : ColorMode := $45555254; {TRUE}
   16 : ColorMode := $48474948; {HIGH}
   8  : ColorMode := $47363532; {256G}
  else Exit;
  end;

  ColorMode := ColorMode xor $FFFFFFFF;

  case BitDepth of
   32 : begin
         RAW_AnyToTrueColor(iStream,iStreamA,tmpStream,RealWidth,RealHeight,BitDepth,Palette,False);
         BitDepth := 24;
        end;
  else begin
        tmpStream.Size := iStream.Size;
        tmpStream.CopyFrom(iStream,iStream.Size);
       end;
  end;

  tmpStream.Seek(0,soBeginning);

  InterleaveStream(tmpStream,tmpStreamE,Width,Height,BitDepth);

  tmpStream.Size := 0;

  VerticalFlip(tmpStreamE,GetScanLineLen(RealWidth,BitDepth),RealHeight);

  tmpStreamE.Seek(0,soBeginning);

  Encode_GGD(tmpStreamE,tmpStream,tmpStreamE.Size);

  Width      := RealWidth;
  Height     := RealHeight;
 end;

 FreeAndNil(tmpStreamE);

 tmpStream.Seek(0,soBeginning);

 with oStream do begin
  Write(GGD,SizeOf(GGD));
  Write(GGD1,SizeOf(GGD1));
  CopyFrom(tmpStream,tmpStream.Size);
 end;

 FreeAndNil(tmpStream);

end;

function Decode_GGD;
var TmpPosition, i : cardinal;
    ctrlbyte : byte;
    buf : array[0..7] of byte;
begin
  while iStream.Position < iStream.Size do begin
   iStream.Read(ctrlbyte,1);
   case ctrlbyte of
   0 : begin
        iStream.Read(buf[0],1);
        oStream.Position := oStream.Position - 3;
        oStream.Read(buf[1],3);
        for i:= 1 to buf[0] do begin
         oStream.Write(buf[1],3);
        end;
       end;
   1 : begin
        iStream.Read(buf[0],2);
        TmpPosition := oStream.Position - buf[1]*3;
        for i:= 1 to buf[0] do begin
         oStream.Position := TmpPosition;
         oStream.Read(buf[2],3);
         oStream.Position := oStream.Size;
         oStream.Write(buf[2],3);
         Inc(TmpPosition,3);
        end;
       end;
   2 : begin
        iStream.Read(buf[0],3);
        TmpPosition := oStream.Position - ((Word(buf[2]) shl 8) or buf[1])*3;
        for i:= 1 to buf[0] do begin
         oStream.Position := TmpPosition;
         oStream.Read(buf[3],3);
         oStream.Position := oStream.Size;
         oStream.Write(buf[3],3);
         Inc(TmpPosition,3);
        end;
       end;
   3 : begin
        iStream.Read(buf[0],1);
        oStream.Position := oStream.Position - buf[0]*3;
        oStream.Read(buf[1],3);
        oStream.Position := oStream.Size;
        oStream.Write(buf[1],3);
       end;
   4 : begin
        iStream.Read(buf[0],2);
        oStream.Position := oStream.Position - ((Word(buf[1]) shl 8) or buf[0])*3;
        oStream.Read(buf[2],3);
        oStream.Position := oStream.Size;
        oStream.Write(buf[2],3);
       end;
  else begin
        for i:= 0 to ctrlbyte-5 do begin
         iStream.Read(buf[0],3);
         oStream.Write(buf[0],3);
        end;
       end;
  end;
 end;
end;

{ GGA decoder function. Written by Nik. }
function Decode_GGA(IStream, OStream : TStream; CryptLength : integer; Width : word) : boolean;
var i, j, hsize, TempDst, TempDst2 : integer;
    arr : array[0..3] of byte;
    ctrlb, l, h: byte;
begin

 Result := False;
 
 hsize := IStream.Position;
 while IStream.Position - hsize < CryptLength do begin
	IStream.Read(ctrlb,1);
	case ctrlb of
	 $0: begin
        Ostream.Position := OStream.Position - 4;
        Ostream.Read(arr,4);
        i := 0;
        IStream.Read(i,1);
        for j:=i downto 1 do Ostream.Write(arr,4);
       end;
   $1: begin
        Ostream.Position := OStream.Position - 4;
        Ostream.Read(arr,4);
        IStream.Read(h,1);
        IStream.Read(l,1);
        i := (l shl 8) or h;
        for j:=i downto 1 do Ostream.Write(arr,4);
       end;
	 $2: begin
        IStream.Read(l,1);
        TempDst := OStream.Position;
        OStream.Position := OStream.Position - (l shl 2);
        Ostream.Read(arr,4);
        OStream.Position := TempDst;
        Ostream.Write(arr,4);
       end;
   $3: begin
        IStream.Read(h,1);
        IStream.Read(l,1);
        i := (l shl 8) or h;
        TempDst := OStream.Position;
        OStream.Position := OStream.Position - (i shl 2);
        Ostream.Read(arr,4);
        OStream.Position := TempDst;
        Ostream.Write(arr,4);
       end;
	 $4: begin
        IStream.Read(l,1);
        TempDst2 := OStream.Position - (l shl 2);
        i := 0;
        IStream.Read(i,1);
        for j:=i downto 1 do begin
         TempDst := OStream.Position;
         OStream.Position := TempDst2;
         TempDst2 := TempDst2 + 4;
         Ostream.Read(arr,4);
         OStream.Position := TempDst;
         Ostream.Write(arr,4);
        end;
       end;
   $5: begin
        IStream.Read(l,1);
        TempDst2 := OStream.Position - (l shl 2);
        IStream.Read(h,1);
        IStream.Read(l,1);
        i := (l shl 8) or h;
        for j:=i downto 1 do begin
         TempDst := OStream.Position;
         OStream.Position := TempDst2;
         TempDst2 := TempDst2 + 4;
         Ostream.Read(arr,4);
         OStream.Position := TempDst;
         Ostream.Write(arr,4);
        end;
       end;
	 $6: begin
        IStream.Read(h,1);
        IStream.Read(l,1);
        i := (l shl 8) or h;
        TempDst2 := OStream.Position - (i shl 2);
        i := 0;
        IStream.Read(i,1);
        for j:=i downto 1 do begin	
         TempDst := OStream.Position;
         OStream.Position := TempDst2;
         TempDst2 := TempDst2 + 4;
         Ostream.Read(arr,4);
         OStream.Position := TempDst;
         Ostream.Write(arr,4);
        end;
       end;
	 $7: begin
        IStream.Read(h,1);
        IStream.Read(l,1);
        i := (l shl 8) or h;
        TempDst2 := OStream.Position - (i shl 2);
        IStream.Read(h,1);
        IStream.Read(l,1);
        i := (l shl 8) or h;
        for j:=i downto 1 do begin	
         TempDst := OStream.Position;
         OStream.Position := TempDst2;
         TempDst2 := TempDst2 + 4;
         Ostream.Read(arr,4);
         OStream.Position := TempDst;
         Ostream.Write(arr,4);
        end;
       end;
	 $8: begin
        TempDst := OStream.Position;
        OStream.Position := OStream.Position - 4;
        Ostream.Read(arr,4);
        OStream.Position := TempDst;
        Ostream.Write(arr,4);
       end;
	 $9: begin
        TempDst := OStream.Position;
        OStream.Position := OStream.Position - (Width * 4);
        Ostream.Read(arr,4);
        OStream.Position := TempDst;
        Ostream.Write(arr,4);
       end;
	 $A: begin
        TempDst := OStream.Position;
        OStream.Position := OStream.Position - (Width * 4 + 4);
        Ostream.Read(arr,4);
        OStream.Position := TempDst;
        Ostream.Write(arr,4);
       end;
	 $B: begin
        TempDst := OStream.Position;
        OStream.Position := OStream.Position - (Width * 4 - 4);
        Ostream.Read(arr,4);
        OStream.Position := TempDst;
        Ostream.Write(arr,4);
       end;
   else begin
         i := ctrlb - 11;
         for j:=i downto 1 do begin
          Istream.Read(arr,4);
          Ostream.Write(arr,4);
         end;
	 end;
  end;
 end;
 
 Result := True;
 
end;

function Encode_GGA;
var arr : array[0..$3CF] of byte;
    cbyte : byte;
begin
 cbyte := $FF;
 while CryptLength > $3D0 do begin
  OStream.Write(cbyte,1);
  Istream.Read(arr,$3D0);
  OStream.Write(arr,$3D0);
  CryptLength := CryptLength - $3D0;
 end;
 cbyte := (CryptLength div 4) + $0B;
 OStream.Write(cbyte,1);
 Istream.Read(arr,CryptLength);
 OStream.Write(arr,CryptLength);
end;

function Encode_GGD;
var arr : array[0..$2F0] of byte;
    cbyte : byte;
begin
 cbyte := $FF;
 while CryptLength > $2F1 do begin
  OStream.Write(cbyte,1);
  Istream.Read(arr,$2F1);
  OStream.Write(arr,$2F1);
  CryptLength := CryptLength - $2F1;
 end;
 cbyte := (CryptLength div 3) + 5;
 OStream.Write(cbyte,1);
 Istream.Read(arr,CryptLength);
 OStream.Write(arr,CryptLength);
end;

function Decode_GGP;
var GGP    : TGGP;
    GGxDir : array of TGGxRegion;
    i, j : integer;
label StopThis;
begin
 Result := False;
 IStream.Seek(0,soBeginning);
 IStream.Read(GGP,SizeOf(GGP));
 if GGP.GGPHeader <> 'GGPFAIKE' then goto StopThis;
 with GGP do begin
  j := RegionLength div SizeOf(TGGxRegion);
  SetLength(GGxDir,j);
  for i := 0 to j-1 do IStream.Read(GGxDir[i],SizeOf(GGxDir[i])); // reading animation/sprite properties
  for i := 0 to Length-1 do begin
   IStream.Read(j,1);
   j := j xor (byte(GGPHeader[i mod 8]) xor XORMask[i mod 8]);
   OStream.Write(j,1);
  end;
 end;
 Result := True;
StopThis:
end;

function Import_GGP;
var RFI : TRFI;
    TempoStream : TStream;
label StopThis;
begin
 with RFI, IStream do begin
  Valid := False;
  Seek(0,soBeginning);
  TempoStream := TMemoryStream.Create;
  if not Decode_GGP(IStream,TempoStream) then goto StopThis;
  TempoStream.Position := 0;
  RFI := Import_PNG(TempoStream,OStream,OStreamA);
 end;

StopThis:
 FreeAndNil(TempoStream);
 Result := RFI;
end;


end.