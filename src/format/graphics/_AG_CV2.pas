{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Tasofro image library

  Written by dsp2003. Specifications from w8m.
}

unit _AG_CV2;

interface

uses Classes, SysUtils, IniFiles,
     AnimED_Math,
     AnimED_Console,
     AG_Fundamental,
     AG_RFI;

type
 TCV2Hdr = packed record
  Bits      : byte; // 8,16,24,32. Important: 24 = 32!
  Width     : longword;
  Height    : longword;
  FileWidth : longword;
  DUmmy     : longword;
 end;

function Import_CV2(IStream, OStream : TStream; OStreamA : TStream = nil) : TRFI;
function Export_CV2(RFI : TRFI; OStream, IStream : TStream; IStreamA : TStream = nil) : boolean;
procedure IG_CV2(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_CV2;
begin
 with ImFormat do begin
  Name := '[CV2] Tasofro Picture';
  Ext  := '.cv2';
  Stat := $0;
  Open := Import_CV2;
  Save := Export_CV2;
  Ver  := $20110820;
 end;
end;

function Import_CV2;
var RFI : TRFI;
    Hdr : TCV2Hdr;
    TempoStream : TStream;
label StopThis;
begin
 with Hdr, RFI, iStream do begin

  Valid := False;

  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  if (Bits > 32) or (Bits < 8) then goto StopThis;

  RealWidth  := Width;
  RealHeight := Height;

  case Bits of
   8     : BitDepth := 8;
   16    : BitDepth := 16;
   24,32 : BitDepth := 32;
  end;

  Seek(SizeOf(Hdr),soBeginning);

  TempoStream := TMemoryStream.Create;
  TempoStream.CopyFrom(iStream,GetScanlineLen2(Width,BitDepth)*Height);
  TempoStream.Seek(0,soBeginning);
  VerticalFlip(TempoStream,GetScanLineLen(Width,BitDepth),Height);
  TempoStream.Seek(0,soBeginning);

{ Copies alpha channel into separate non-interleaved stream and strips it from base stream }
  if oStreamA <> nil then try
   ExtractAlpha(TempoStream,oStreamA,Width,Height);
  except
  end;

  StripAlpha(TempoStream,oStream,Width,Height);
//  BitDepth := 24;
  ExtAlpha := True and (oStreamA <> nil);
  X            := 0;
  Y            := 0;
  RenderWidth  := 0;
  RenderHeight := 0;
  Palette  := GrayscalePalette;

  Valid := True;

 end;

 FreeAndNil(TempoStream);

StopThis:

 Result := RFI;
end;

function Export_CV2;
{var i : integer;
    z : byte;
    Hdr : TCV2Hdr;
    tmpStream,
    tmpStreamE : TStream;}
begin
{ iStream.Seek(0,soBeginning);
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
}
end;

end.