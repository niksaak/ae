{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Heat-Soft IES Image Format library

  Written by dsp2003.
  Thanks to Marisa-Chan for partial reversing.
}

unit AG_IES_HeatSoft;

interface

uses Classes, SysUtils,
     AG_Fundamental,
     AG_RFI;

type
 TIESHeader = packed record
  Header   : array[1..4] of char;    // IES2
  Unk_     : array[1..4] of char;    // IES2?
  Width    : longword;
  Height   : longword;
  BitDepth : longword;                // always 24 (even if 32)
  Dummy    : longword;                // always 0
  Unk0     : array[1..1024] of byte; // indexes?
  Unk1     : word;                    // always 32
  Unk2     : word;
  Unk3     : word;                    // always 32 (не всегда)
  Unk4     : word;
 end;

function Import_IES(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
function Export_IES(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_IES(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_IES;
begin
 with ImFormat do begin
  Name := '[IES] Heat-Soft IES';
  Ext  := '.ies';
  Stat := $0;
  Open := Import_IES;
  Save := Export_IES;
  Ver  := $20100311;
 end;
end;

function Import_IES(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    IES : TIESHeader;
    TempoStream : TStream;
label StopThis;
begin
 RFI.Valid := False;

 TempoStream := TMemoryStream.Create;
 with IES, InputStream do begin
  Seek(0,soBeginning);
  Read(IES,SizeOf(IES));
  if Header <> 'IES2' then goto StopThis;
  RFI.RealWidth  := Width;
  RFI.RealHeight := Height;
 end;

 with IES, TempoStream do begin
  Size := Width*Height*3;
  CopyFrom(InputStream,Size);
  Seek(0,soBeginning);
  VerticalFlip(TempoStream,GetScanlineLen2(Width,BitDepth),Height);
  Seek(0,soBeginning);
  OutputStream.CopyFrom(TempoStream,Size);
  Size := Width*Height;
  Seek(0,soBeginning);
  CopyFrom(InputStream,Size);
  Seek(0,soBeginning);
  VerticalFlip(TempoStream,GetScanlineLen2(Width,8),Height);
  Seek(0,soBeginning);
  OutputStreamA.CopyFrom(TempoStream,Size);
 end;

 RFI.RealWidth    := IES.Width;
 RFI.RealHeight   := IES.Height;
 RFI.BitDepth     := IES.BitDepth;
 RFI.ExtAlpha     := True;
 RFI.X            := 0; // to-do : should load from INI here
 RFI.Y            := 0;
 RFI.RenderWidth  := 0; // to-do : must be set if image is 32 bit
 RFI.RenderHeight := 0;
 RFI.Palette      := NullPalette; // if BitDepth > 8 then ignored
// RFI.FormatID     := 'Heat-Soft IES';
 RFI.Valid        := True;

StopThis:
 FreeAndNil(TempoStream);
 Result := RFI;
end;

function Export_IES(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
var IES : TIESHeader;
    TempMem : array of char;
begin

 IES.Header := 'IES2';
 IES.Unk_ := 'IES2';
 IES.Width := RFI.RealWidth;
 IES.Height := RFI.RealHeight;
 IES.BitDepth := $18;
 IES.Dummy := 0;
 FillChar(IES.Unk0, 1024 + 2*4, 0); // сразу и остальные unk
 // в игре оно не юзается

 InputStream.Seek(0,soBeginning);
 VerticalFlip(InputStream,GetScanlineLen2(IES.Width, IES.BitDepth),IES.Height);
 InputStream.Seek(0,soBeginning);

 OutputStream.Write(IES, sizeof(IES));
 OutputStream.CopyFrom(InputStream, InputStream.Size);

 if InputStreamA <> nil then if InputStreamA.Size > 0 then
 begin
   InputStreamA.Seek(0,soBeginning);
   VerticalFlip(InputStreamA,GetScanlineLen2(IES.Width, 8),IES.Height);
   InputStreamA.Seek(0,soBeginning);
   OutputStream.CopyFrom(InputStreamA, InputStreamA.Size);
 end
 else
 begin
   SetLength(TempMem, IES.Width * IES.Height);
   FillChar(TempMem[0], IES.Width * IES.Height, $ff);
   OutputStream.Write(TempMem[0], IES.Width * IES.Height);
   SetLength(TempMem, 0);
 end;
 Result := True;
end;

end.