{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Ethornell Buriko General Interpreter Image Format library

  Written by dsp2003.
}

unit AG_Ethornell_BGI;

interface

uses Classes, SysUtils, IniFiles,
     AG_Fundamental,
     AG_RFI;

type
 { Buriko General Interpreter Bitmap }
 TBGIBitmap = packed record
  Width      : word;                // Image Width
  Height     : word;                // Image Height
  Bitdepth   : word;                // Bits per pixel
  Dummy1     : word;                // $0
  Dummy2     : int64;               // $0
 end;

function Import_BGIBitmap(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
procedure IG_BGI(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_BGI;
begin
 with ImFormat do begin
  Name := '[BMP] BGI Bitmap';
  Ext  := '.bmp';
  Stat := $F;
  Open := Import_BGIBitmap;
  Save := nil;
  Ver  := $20100311;
 end;
end;

function Import_BGIBitmap(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var BGIBitmap : TBGIBitmap;
//    Palette : TPalette;
    TempoStream : TStream;
    RFI : TRFI;
begin
 RFI.Valid := False;
 Result := RFI;

 with BGIBitmap, InputStream do begin
  Seek(0,soBeginning);
  Read(BGIBitmap,SizeOf(BGIBitmap));
  if Dummy1 <> 0 then Exit;
  if Dummy2 <> 0 then Exit;
  if InputStream.Size <> SizeOf(BGIBitmap)+Width*Height*(BitDepth div 8) then Exit;

  RFI.RealWidth  := Width;
  RFI.RealHeight := Height;
  RFI.BitDepth   := BitDepth;
  RFI.ExtAlpha   := BitDepth = 32;
 end;

 TempoStream := TMemoryStream.Create;
 TempoStream.CopyFrom(InputStream,GetScanlineLen(RFI.RealWidth,RFI.BitDepth)*RFI.RealHeight);
 TempoStream.Seek(0,soBeginning);
 VerticalFlip(TempoStream,GetScanlineLen(RFI.RealWidth,RFI.BitDepth),RFI.RealHeight);
 { Converting into internal non-interleaved data container }
 DeInterleaveStream(TempoStream,OutputStream,GetScanlineLen(RFI.RealWidth,RFI.BitDepth),GetScanlineGap(RFI.RealWidth,RFI.BitDepth),RFI.RealHeight);
{ Copies alpha channel into separate non-interleaved stream and strips it from base stream }
 if (RFI.BitDepth > 24) and (OutputStreamA <> nil) then begin
  ExtractAlpha(TempoStream,OutputStreamA,RFI.RealWidth,RFI.RealHeight);
  StripAlpha(TempoStream,OutputStream,RFI.RealWidth,RFI.RealHeight);
  RFI.BitDepth := 24;
 end;
 FreeAndNil(TempoStream);
 { Will read alpha from appended stream, even if BitDepth is 32-bit itself }
 if RFI.ExtAlpha = True then begin
  InputStream.Position := 0;
  OutputStreamA.CopyFrom(InputStream,RFI.RealWidth*RFI.RealHeight);
 end;

// RFI.BitDepth := PRT.BitDepth;
 RFI.ExtAlpha := RFI.ExtAlpha and (OutputStreamA <> nil);
// RFI.Palette  := Palette; // if BitDepth > 8 then ignored

 RFI.Valid := True;

 Result := RFI;
end;

end.