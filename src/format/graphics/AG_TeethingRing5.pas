{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.
  
  TeethingRing5 Image Format library

  Written by Nik.
}

unit AG_TeethingRing5;

interface

uses Classes, SysUtils,
     Generic_LZXX,
     AG_Fundamental,
     AG_RFI,
     AnimED_Debug;

function Import_TR5(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
procedure IG_TR5(var ImFormat : TImageFormats);

type
 TTeethingRing5GraphicHeader = packed record
   Magic : longword; // $40000
   CryptedSize : longword;
   DecryptedSize : longword;
   DataOffset : longword;
   Dummy : longword; // 0
   Width : longword;
   Height : longword;
   BPP : longword;
   Flag : longword; // $0 обычно или $F для спрайтов персонажей
   id1 : longword; // используется для спрайтов персонажей
   id2 : longword; // используется для спрайтов персонажей
 end;

implementation

uses AnimED_Graphics;

procedure IG_TR5;
begin
 with ImFormat do begin
  Name := '[   ] TeethingRing5 Graphics';
  Ext  := '';
  Stat := $F;
  Open := Import_TR5;
  Save := nil;
  Ver  := $20100311;
 end;
end;

function Import_TR5(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    Header : TTeethingRing5GraphicHeader;
    tmpStream: TStream;
    Pixel : TARGB;
label StopThis;
begin
 RFI.Valid := False;
 InputStream.Position := 0;
 InputStream.Read(Header,sizeof(Header));
 if Header.Magic <> $40000 then goto StopThis;
// RFI.FormatID := 'TeethingRing5 Image';
 RFI.RealWidth := Header.Width;
 RFI.RealHeight := Header.Height;
 RFI.BitDepth := Header.BPP;
 InputStream.Position := Header.DataOffset;
 tmpStream := TMemoryStream.Create;
 GLZSSDecode(InputStream, tmpStream, Header.CryptedSize, $FEE, $FFF);
 tmpStream.Position := 0;

 if Header.BPP = 32 then
   begin
     VerticalFlip(tmpStream,GetScanlineLen2(Header.Width, Header.BPP),Header.Height);
     tmpStream.Position := 0;
     RFI.BitDepth := RFI.BitDepth - 8;
     RFI.ExtAlpha := True;
     while tmpStream.Position < tmpStream.Size do
     begin
       tmpStream.Read(Pixel,sizeof(Pixel));
       OutputStream.Write(Pixel,3);
       OutputStreamA.Write(Pixel.A,1);
     end;
   end
 else if Header.BPP = 8 then
   begin
     tmpStream.Read(RFI.Palette,sizeof(RFI.Palette));
     OutputStream.CopyFrom(tmpStream,tmpStream.Size-1024);
     OutputStream.Position := 0;
     VerticalFlip(OutputStream,GetScanlineLen2(Header.Width, Header.BPP),Header.Height);
   end
 else
   begin
     FreeAndNil(tmpStream);
     goto StopThis;
   end;
 OutputStream.Position := 0;
 OutputStreamA.Position := 0;
 RFI.Valid := True;
 FreeAndNil(tmpStream);
StopThis:
 Result := RFI;
end;

end.