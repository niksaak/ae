{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  GIF Image Format handler library

  Written by dsp2003.
}

unit AG_GIF;

interface

uses Classes, SysUtils, Graphics,
     AnimED_Math,
     AG_Fundamental,
     AG_StdFmt,
     AG_RFI;

{ Opens\Generates Portable Network Graphics-compatible files }
function Import_GIF(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
//function Export_GIF(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_GIF(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics, gifimage;

procedure IG_GIF;
begin
 with ImFormat do begin
  Name := '[GIF] Graphics Interchange File';
  Ext  := '.gif';
  Stat := $F;
  Open := Import_GIF;
  //Save := Export_GIF;
  Ver  := $20130511;
 end;
end;

function Import_GIF;
var i,j : integer; k : byte;
    MiniBuffer : array[1..4] of char;
    ImportGIF : TGIFImage;
    RFI : TRFI;
    Pixel : longword;
label StopThis;
begin
 RFI.Valid := False;

 InputStream.Seek(0,soBeginning);
 OutputStream.Seek(0,soBeginning);
 InputStream.Read(MiniBuffer,4);
 if MiniBuffer <> 'GIF8' then goto StopThis;

 InputStream.Seek(0,soBeginning);

 ImportGIF := TGIFImage.Create;
 ImportGIF.LoadFromStream(InputStream);

 RFI.RealWidth := ImportGIF.Width;
 RFI.RealHeight := ImportGIF.Height;
 RFI.BitDepth := 24;

{ Reading base stream from TBitmap instead of idiotical PNG Object (stupid
  errorneous scanline handling, goddamn it!) }

 for j := RFI.RealHeight-1 downto 0 do begin
  for i := 0 to RFI.RealWidth-1 do begin
   Pixel := ImportGif.Images.SubImages[0].ActiveColorMap.Colors[ImportGif.Images.SubImages[0].Pixels[i,j]];
   Pixel := EndianSwap(Pixel shl 8);
   //ImportGif.Images.SubImages[0].Pixels[i,j]);
   OutputStream.Write(Pixel,3);
  end;
 end;

 RFI.ExtAlpha := False;
 RFI.X := 0;
 RFI.Y := 0;
 RFI.RenderWidth := 0;
 RFI.RenderHeight := 0;

 RFI.Valid := True;

 try
  if ImportGIF <> nil then FreeAndNil(ImportGIF);
 except
 end;
 
StopThis:
 Result := RFI;
end;

{function Export_PNG;
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
{   for j := RFI.RealHeight-1 downto 0 do begin
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

end;}

end.