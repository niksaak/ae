{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Atelier Kaguya PRS Image formats

  Written by dsp2003.
}

unit AG_AtelierKaguya_PRS;

interface

uses Classes, Sysutils, Windows,
     AnimED_Math,
     AG_Fundamental,
     AnimED_Console,
     AG_RFI;

type
 TPRSHeader = packed record
  Magic   : array[1..2] of char; // 'AP'
  Width   : longword;
  Height  : longword;
  BitDepth: word; // 24 (32 bit)
 end;

function Import_PRS(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
//function Export_PRS(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_PRS(var ImFormat : TImageFormats);

implementation

procedure IG_PRS;
begin
 with ImFormat do begin
  Name := '[PRS] Atelier Kaguya Picture Stream';
  Ext  := '.prs';
  Stat := $F;
  Open := Import_PRS;
//  Save := Export_PRS;
  Ver  := $20120620;
 end;
end;

function Import_PRS;
var RFI : TRFI;
    Hdr : TPRSHeader;
    tmpStream : TStream;
begin
 RFI.Valid := False;

 with Hdr do try
  iStream.Seek(0,soBeginning);
  iStream.Read(Hdr,SizeOf(Hdr));
  if Hdr.Magic <> 'AP' then Exit;

  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(iStream,GetScanlineLen2(Width,32)*Height);
  tmpStream.Seek(0,soBeginning);

  ExtractAlpha(tmpStream,oStreamA,Width,Height);
  StripAlpha(tmpStream,oStream,Width,Height);
  BitDepth := 24;

  FreeAndNil(tmpStream);

  RFI.RealWidth    := Width;
  RFI.RealHeight   := Height;
  RFI.ExtAlpha     := True;
  RFI.BitDepth     := BitDepth;
  RFI.X            := 0;
  RFI.Y            := 0;
  RFI.RenderWidth  := 0;
  RFI.RenderHeight := 0;
  RFI.Palette := NullPalette;
  
  RFI.Valid := True;

 except
  FreeAndNil(tmpStream);
  Exit;
 end;

 Result := RFI;
end;

end.