{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.
  
  Alcot's CPB Image Format library

  Written by Nik.
}

unit AG_CPB;

interface

uses Classes, SysUtils,
     ZLibEx,
     AG_Fundamental,
     AG_RFI;

     // Функция портирована
function Import_CPB(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
procedure IG_CPB(var ImFormat : TImageFormats);

type
 TCBPHeader_type0_v1 = packed record
   Magic : array[1..4] of char; // 'CPB'#26
   imgtype : byte; // 0
   BPP : byte;
   StructFlag : word; // $1
   MaxBlockSize : longword; // наверное
   Width : word;
   height : word;
   aCSize : longword;
   gCSize : longword;
   rCSize : longword;
   bCSize : longword;
 end;
 
 TCBPHeader_type0_v2 = packed record
   Magic : array[1..4] of char; // 'CPB'#26
   imgtype : byte; // 0
   BPP : byte;
   StructFlag : word; // $100
   Width : word;
   MaxBlockSize : longword; // наверное
   height : word;
   aCSize : longword;
   gCSize : longword;
   rCSize : longword;
   bCSize : longword;
 end;

implementation

uses AnimED_Graphics;

procedure IG_CPB;
begin
 with ImFormat do begin
  Name := '[CPB] Alcot Image';
  Ext  := '.cmp';
  Stat := $F;
  Open := Import_CPB;
  Save := nil;
  Ver  := $20100311;
 end;
end;

function Import_CPB(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    Head1 : TCBPHeader_type0_v1;
    PHead2 : ^TCBPHeader_type0_v2;
    tmpStream, bStream, gStream, rStream : TStream;
    Pixel: TRGB;
    i : longword;
label StopThis;
begin
 RFI.Valid := False;
 InputStream.Position := 0;
 InputStream.Read(Head1,sizeof(Head1));
 if Head1.Magic <> 'CPB'#26 then goto StopThis;
// RFI.FormatID := 'Alcot Image';
 if Head1.imgtype = 0 then
 begin
   RFI.RealHeight := Head1.height;
   RFI.BitDepth := Head1.BPP;
   if Head1.StructFlag = 1 then
   begin
     RFI.RealWidth := Head1.Width;
   end
   else if Head1.StructFlag = $100 then
   begin
     PHead2 := @Head1;
     RFI.RealWidth := PHead2^.Width;
   end
   else goto StopThis;

   OutputStream.Size := RFI.RealWidth*RFI.RealHeight*(RFI.BitDepth shr 3);
   tmpStream := TMemoryStream.Create;

   if Head1.aCSize <> 0 then
   begin
     RFI.ExtAlpha := True;
     RFI.BitDepth := RFI.BitDepth - 8;
     InputStream.Position := InputStream.Position + 4;
     tmpStream.CopyFrom(InputStream,Head1.aCSize-4);
     tmpStream.Position := 0;
     ZDecompressStream(tmpStream, OutputStreamA);
     OutputStreamA.Position := 0;
     VerticalFlip(OutputStreamA,GetScanLineLen2(RFI.RealWidth,8),RFI.RealHeight);
   end;

   tmpStream.Size := 0;
   InputStream.Position := InputStream.Position + 4;
   tmpStream.CopyFrom(InputStream, Head1.bCSize-4);
   tmpStream.Position := 0;
   bStream := TMemoryStream.Create;
   ZDecompressStream(tmpStream, bStream);

   tmpStream.Size := 0;
   InputStream.Position := InputStream.Position + 4;
   tmpStream.CopyFrom(InputStream, Head1.gCSize-4);
   tmpStream.Position := 0;
   gStream := TMemoryStream.Create;
   ZDecompressStream(tmpStream, gStream);

   tmpStream.Size := 0;
   InputStream.Position := InputStream.Position + 4;
   tmpStream.CopyFrom(InputStream, Head1.rCSize-4);
   tmpStream.Position := 0;
   rStream := TMemoryStream.Create;
   ZDecompressStream(tmpStream, rStream);

   FreeAndNil(tmpStream);

   bStream.Position := 0;
   gStream.Position := 0;
   rStream.Position := 0;
   for i := 1 to RFI.RealWidth*RFI.RealHeight do
   begin
     bStream.Read(Pixel.B,1);
     gStream.Read(Pixel.G,1);
     rStream.Read(Pixel.R,1);
     OutputStream.Write(Pixel,sizeof(Pixel));
   end;
   OutputStream.Position := 0;
   FreeAndNil(bStream);
   FreeAndNil(gStream);
   FreeAndNil(rStream);
   VerticalFlip(OutputStream,GetScanLineLen2(RFI.RealWidth,RFI.BitDepth),RFI.RealHeight);
   RFI.Valid := True;
 end
 else
 begin
   goto StopThis;
{   case Head1.imgtype of
     1:
     begin
     end;

     3:
     begin
     end;

     else goto StopThis;
   end;      } // Не на чем тестировать десу
 end;

StopThis:
 Result := RFI;
end;

end.