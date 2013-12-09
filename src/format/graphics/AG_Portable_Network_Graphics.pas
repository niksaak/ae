{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Portable Network Graphics Image Format handler library

  Written by dsp2003.
}

unit AG_Portable_Network_Graphics;

interface

uses Classes, SysUtils, Graphics,
     AnimED_Math,
     AG_Fundamental,
     AG_StdFmt,
     AG_RFI;

{ Opens\Generates Portable Network Graphics-compatible files }
function Import_PNG(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil; NoConv : boolean = False) : TRFI;
function Import_PNG_Auto(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
function Export_PNG(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil; Compression : integer = 9) : boolean;
function Export_PNG_Auto(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_PNG(var ImFormat : TImageFormats);

var
   PNGCompression_PNG : integer;
   NoConv : boolean;

implementation

uses AnimED_Graphics, pngimage;

procedure IG_PNG;
begin
 with ImFormat do begin
  Name := '[PNG] Portable Network Graphics';
  Ext  := '.png';
  Stat := $0;
  Open := Import_PNG_Auto;
  Save := Export_PNG_Auto;
  Ver  := $20100311;
 end;
end;

function Export_PNG_Auto(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
begin
  Result := Export_PNG(RFI, OutputStream, InputStream, InputStreamA, PNGCompression_PNG);
end;

function Import_PNG_Auto(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
begin
  Result := Import_PNG(InputStream, OutputStream, OutputStreamA);
end;

function Import_PNG;
var i,j : integer; k : byte;
    MiniBuffer : array[1..4] of char;
    ImportPNG : TPNGObject;
    RFI : TRFI;
    Pixel : longword;
label StopThis;
begin
 RFI.Valid := False;

 InputStream.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 InputStream.Read(MiniBuffer,4);
 if MiniBuffer <> #137+'PNG' then goto StopThis;

 InputStream.Seek(0,soBeginning);

 ImportPNG := TPNGObject.Create;
 ImportPNG.CompressionLevel := 0; // speeds up the process incredibly ;)

 ImportPNG.LoadFromStream(InputStream);

 RFI.RealWidth := ImportPNG.Header.Width;
 RFI.RealHeight := ImportPNG.Header.Height;
 RFI.BitDepth := 24; //TempoPNG.Header.BitDepth;

{ Reading base stream from TBitmap instead of idiotical PNG Object (stupid
  errorneous scanline handling, goddamn it!) }

 for j := RFI.RealHeight-1 downto 0 do begin
  for i := 0 to RFI.RealWidth-1 do begin
//   with pRGBLine(TempoPNG.Scanline[j])^[i] do begin
//    Pixel := rgbtRed shl 16 + rgbtGreen shl 8 + rgbtBlue;
   Pixel := ImportPNG.Pixels[i,j];
   if not NoConv then Pixel := EndianSwap(Pixel shl 8);
//   else Pixel := Pixel shl 8;
   OutputStream.Write(Pixel,3);
//   end;
  end;
 end;

{ Reading alpha from PNG Object }
 if (ImportPNG.TransparencyMode = ptmPartial) and (OutputStreamA <> nil) then begin
{ PNG alpha is stored in the SAME manner as PRT alpha, omfg! lol }
  for j := RFI.RealHeight-1 downto 0 do begin
   for i := 0 to RFI.RealWidth-1 do begin
    k := ImportPNG.AlphaScanline[j]^[i];
    if NoConv then k := k xor $FF;
    OutputStreamA.Write(k,1);
   end;
  end;
  RFI.ExtAlpha := True;
 end else RFI.ExtAlpha := False;
 RFI.X := 0;
 RFI.Y := 0;
 RFI.RenderWidth := 0;
 RFI.RenderHeight := 0;

// RFI.FormatID := 'Portable Network Graphics';
 RFI.Valid := True;

 try
  if ImportPNG <> nil then FreeAndNil(ImportPNG);
 except
 end;
 
StopThis:
 Result := RFI;
end;

function Export_PNG;
var TempoStream : TStream;
    TempoPNG : TPNGObject;
    TempoBMP : TBitmap;
    i, j : integer; k : byte;
begin
 InputStream.Seek(0,soBeginning);
 if (InputStreamA <> nil) and (InputStreamA.Size > 0) then InputStreamA.Seek(0,soBeginning);

 Result := False;

 TempoBMP    := TBitmap.Create;
 TempoPNG    := TPNGObject.Create;
 TempoPNG.CompressionLevel := Compression;
 TempoStream := TMemoryStream.Create;

 Export_BMP(RFI,TempoStream,InputStream);
 TempoStream.Seek(0,soBeginning);
 TempoBMP.LoadFromStream(TempoStream);
 FreeAndNil(TempoStream);
 TempoPNG.Assign(TempoBMP);
 FreeAndNil(TempoBMP);

 if ((InputStreamA <> nil) and (InputStreamA.Size > 0)) and (RFI.BitDepth > 16) then
  begin
   InputStreamA.Seek(0,soBeginning);
   TempoPNG.CreateAlpha;
 { PNG alpha is stored in the SAME manner as PRT alpha, omfg! lol }
   for j := RFI.RealHeight-1 downto 0 do begin
    for i := 0 to RFI.RealWidth-1 do begin
     InputStreamA.Read(k,1);
     TempoPNG.AlphaScanline[j]^[i] := k;
    end;
   end;
  end; 

 OutputStream.Seek(0,soBeginning);
 TempoPNG.SaveToStream(OutputStream);
 FreeAndNil(TempoPNG);

 Result := True;

end;

end.