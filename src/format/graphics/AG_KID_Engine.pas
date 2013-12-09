{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  CPS\PRT Kid Engine image format library

  Written by Nik & dsp2003.
}

unit AG_KID_Engine;

interface

uses Classes, SysUtils, Windows, IniFiles,
     AG_Fundamental,
     AG_RFI;

type
 TCPSHdr = record
  ID          : array [0..3] of char;
  CPSFileSize : Longword;
  Version     : word;
  CompType    : word;
  UnpSize     : longword;
  PRTSubHead  : array[0..2] of char;
 end;

 TNullLW = array[0..0] of longword;
 TNullB  = array[0..0] of byte;

{ Hacked in-memory GCPS. Not usable without preload.dll - header 101 = 20 bytes, header 102 = 36 bytes }
 TPRT = packed record
  Header     : array[1..4] of char; // PRT+#0
  HeaderType : word;                // 101 (0x65) - 8-bit or w\o alpha header, 102 (0x66) - 24-bit or w\ alpha header
  Bitdepth   : word;                // Bits per pixel
  Offset1    : word;                // PRT header size \ palette beginning offset
  Offset2    : word;                // Picture data beginning offset
  Width      : word;                // Image Width
  Height     : word;                // Image Height
  UsesAlpha  : longword;            // Uses alpha or not (0x0000 - false, 0x0001 - true)
 end;
 TPRTSub = packed record
// Optional canvas data (not writed if HeaderType < 102)
  X          : longword;            // X render coordinate
  Y          : longword;            // Y render coordinate
  RealWidth  : longword;            // Real Image Width
  RealHeight : longword;            // Real Image Height
 end;

{ Opens\Generates KID Engine PRT-compatible files }
function Decode_CPS(sIn: TStream; var sOut: TStream ): boolean;

function Import_CPS(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
procedure IG_CPS(var ImFormat : TImageFormats);

function Import_PRT(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
function Export_PRT(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_PRT(var ImFormat : TImageFormats);

{ Imports\exports info from\to extra ini file (required for PRT files conversion) }
procedure Import_Info(var RFI: TRFI; var INI : TIniFile);
procedure Export_Info(var RFI: TRFI; var INI : TIniFile);

implementation

uses AnimED_Graphics;

procedure IG_CPS;
begin
 with ImFormat do begin
  Name := '[CPS] KID Engine CPS';
  Ext  := '.cps';
  Stat := $F;
  Open := Import_CPS;
  Save := nil;
  Ver  := $20100311;
 end;
end;

procedure IG_PRT;
begin
 with ImFormat do begin
  Name := '[PRT] KID Engine PRT v1.02';
  Ext  := '.prt';
  Stat := $0;
  Open := Import_PRT;
  Save := Export_PRT;
  Ver  := $20100311;
 end;
end;

function Import_PRT(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var i : integer;
    RFI : TRFI;
    PRT : TPRT;
    PRTSub : TPRTSub;
    Palette : TPalette;
    TempoStream : TStream;
label StopThis;
begin
 RFI.Valid := False;

 with PRT, InputStream do begin
   Seek(0,soBeginning);
 { Reads 1.01 version of PRTHeader (20 bytes) }
   Read(PRT,SizeOf(PRT));
   if Header <> 'PRT'+#0 then goto StopThis;
 { Reads 1.02 version subheader (16 bytes) }
   if HeaderType = 102 then Read(PRTSub,SizeOf(PRTSub));
 { Reading palette table (0..255) if BitDepth < High Color (16 bit) }
   if BitDepth < 16 then for i := 0 to GetPaletteColors(BitDepth)-1 do Read(Palette.Palette[i],4);
 { PRT stores both render & real image sizes. If real sizes = 0, then they're equals to render sizes. }
   if (HeaderType = 102) and ((PRTSub.RealWidth <> 0) and (PRTSub.RealHeight <> 0)) then
    begin
     RFI.RealWidth  := PRTSub.RealWidth;
     RFI.RealHeight := PRTSub.RealHeight;
    end
   else
    begin
     RFI.RealWidth := Width;
     RFI.RealHeight := Height;
    end;
   TempoStream := TMemoryStream.Create;
   TempoStream.CopyFrom(InputStream,GetScanlineLen(RFI.RealWidth,BitDepth)*RFI.RealHeight);
   TempoStream.Seek(0,soBeginning);
 { Converting into internal non-interleaved data container }
   DeInterleaveStream(TempoStream,OutputStream,GetScanlineLen(RFI.RealWidth,BitDepth),GetScanlineGap(RFI.RealWidth,BitDepth),RFI.RealHeight);
 { Copies alpha channel into separate non-interleaved stream and strips it from base stream }
   if (BitDepth > 24) and (OutputStreamA <> nil) then
    begin
     ExtractAlpha(TempoStream,OutputStreamA,Width,Height);
     StripAlpha(TempoStream,OutputStream,Width,Height);
     BitDepth := 24;
    end;
   FreeAndNil(TempoStream);
 { Will read alpha from appended stream, even if BitDepth is 32-bit itself }
   if UsesAlpha = 1 then
    begin
     OutputStreamA.CopyFrom(InputStream,RFI.RealWidth*RFI.RealHeight);
     VerticalFlip(OutputStreamA,RFI.RealWidth,RFI.RealHeight);
    end;
  end;

 RFI.BitDepth := PRT.BitDepth;
 RFI.ExtAlpha := boolean(PRT.UsesAlpha) and (OutputStreamA <> nil);
 if PRT.HeaderType = 102 then
  begin
   RFI.X            := PRTSub.X; // to-do : should load from INI here
   RFI.Y            := PRTSub.Y;
   RFI.RenderWidth  := PRT.Width; // to-do : must be set if image is 32 bit
   RFI.RenderHeight := PRT.Height;
  end
 else
  begin
   RFI.X            := 0;
   RFI.Y            := 0;
   RFI.RenderWidth  := 0;
   RFI.RenderHeight := 0;
  end;
 RFI.Palette  := Palette; // if BitDepth > 8 then ignored

// case PRT.HeaderType of
//  101 : RFI.FormatID := 'KID Engine PRT v1.01';
//  102 : RFI.FormatID := 'KID Engine PRT v1.02';
// end;

 RFI.Valid := True;

StopThis:
 Result := RFI;
end;

function Export_PRT(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
var PRT : TPRT;
    PRTSub : TPRTSub;
    Palette : TPalette;
    TempoStream : TStream;
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);

 TempoStream := TMemoryStream.Create;

 with PRT do begin
{ Generating PRT-compatible file }
  Header     := 'PRT'+#0;
{ AnimED always creates v1.02 of PRT, since v1.01 provides lesser functionality }
  HeaderType := 102;
  BitDepth   := RFI.BitDepth;
  Offset1    := SizeOf(PRT)+SizeOf(PRTSub);
  Offset2    := Offset1+GetPaletteSize(BitDepth);

  if (RFI.RenderWidth > 0) and (RFI.RenderHeight > 0) then
   begin
    Width      := RFI.RenderWidth;
    Height     := RFI.RenderHeight;
    with PRTSub do begin
     RealWidth  := RFI.RealWidth;
     RealHeight := RFI.RealHeight;
    end;
   end
  else
   begin
    Width      := RFI.RealWidth;
    Height     := RFI.RealHeight;
    with PRTSub do begin
     RealWidth  := 0;
     RealHeight := 0;
    end;
   end;

  UsesAlpha  := integer((InputStreamA <> nil) and (InputStreamA.Size > 0));
  with PRTSub do begin
   X          := RFI.X;
   Y          := RFI.Y;
  end;

 end;

{Because we're working with PRT (KID Engine) format, there's must be check code
 in order to get the correct image size, since AnimED will not enlarge the data
 to fit the renderer's field size. Reading the Width, Height & coordinates from
 separate INI file must be implemented outside of this function. }
 Palette    := RFI.Palette;

 InterleaveStream(InputStream,TempoStream,RFI.RealWidth,RFI.RealHeight,RFI.BitDepth);

{ Combining data & saving bitmap stream... }
 OutputStream.Write(PRT,SizeOf(PRT));
 OutputStream.Write(PRTSub,SizeOf(PRTSub));
 if GetPaletteSize(RFI.BitDepth) <> 0 then OutputStream.Write(Palette,GetPaletteSize(RFI.BitDepth));

 TempoStream.Seek(0,soBeginning);
 OutputStream.CopyFrom(TempoStream,TempoStream.Size);
 FreeAndNil(TempoStream);

{ PRT alpha channel doesn't requires interleaving... }
 if ((InputStreamA <> nil) and (InputStreamA.Size > 0)) then
  begin
 { ...but requires vertical flip ;) }
   VerticalFlip(InputStreamA,RFI.RealWidth,RFI.RealHeight);
   InputStreamA.Seek(0,soBeginning);
   OutputStream.CopyFrom(InputStreamA,InputStreamA.Size);
  end;
 Result := True;
end;

{ Imports\exports info from\to extra ini file (required for PRT files conversion) }
procedure Import_Info(var RFI: TRFI; var INI : TIniFile);
var TempoRFI : TRFI;
begin
 with TempoRFI, INI do
  begin
   RenderWidth  := ReadInteger(EDGE_HEADER,'RenderWidth',0);
   RenderHeight := ReadInteger(EDGE_HEADER,'RenderHeight',0);
   X            := ReadInteger(EDGE_HEADER,'X',0);
   Y            := ReadInteger(EDGE_HEADER,'Y',0);
  end;
 with TempoRFI do
  begin
   if RenderWidth > 0  then RFI.RenderWidth  := RenderWidth;
   if RenderHeight > 0 then RFI.RenderHeight := RenderHeight;
   if X > 0          then RFI.X := X;
   if Y > 0          then RFI.Y := Y;
  end;
end;

procedure Export_Info(var RFI: TRFI; var INI : TIniFile);
begin
 with RFI, INI do
  begin
   WriteInteger(EDGE_HEADER,'RenderWidth',RenderWidth);
   WriteInteger(EDGE_HEADER,'RenderHeight',RenderHeight);
   WriteInteger(EDGE_HEADER,'X',X);
   WriteInteger(EDGE_HEADER,'Y',Y);
  end;
end;

function Decode_CPS(sIn: TStream; var sOut: TStream): boolean;
Var a, b, d, f: Longword;
    s_OrigPos: Int64;
    pGet, pPut: Pointer;
    pGetB, pPutB, pPutPrevB: ^byte;
    pCPSHdr: ^TCPSHdr;
    NullLW: ^TNullLW;
    NullB: ^TNullB;
    c, z, y, x1, x2, w, UnpSize: longword;

label done, bug;

begin
 s_OrigPos := sIn.Position;
 sIn.Position := 0;                   
 pGet := AllocMem(sIn.Size);
 sIn.Read(pGet^,sIn.Size);
 sIn.Position := s_OrigPos;
 pCPSHdr := pGet;

 if (pCPSHdr^.Version <> $66) or (StrComp(pCPSHdr^.ID, PChar('CPS')) <> 0) then begin
  FreeMem(pGet);
  goto bug;
 end;

 { decryption part }
 NullLW := pGet;
 f := NullLW[pCPSHdr^.CPSFileSize div 4 - 1] - $7534682;

 if f <> 0 then begin
  a := $10;
  d := 4;
  b := NullLW[f div 4] + f + $3786425; 
  if (pCPSHdr^.CPSFileSize - 4) > $10 then repeat
   if a <> f then NullLW[d] := NullLW[d] - (pCPSHdr^.CPSFileSize + b);
   b := b * $41C64E6D + $9B06;
   a := a + 4;
   d := d + 1;
  until a >= (pCPSHdr^.CPSFileSize - 4);
 end;

 { unpacking part }
 NullLW[pCPSHdr^.CPSFileSize div 4 - 1] := 0;

 UnpSize := pCPSHdr^.UnpSize;
 pPut := AllocMem(UnpSize + $10);
 pGetB := pGet;
 pPutB := pPut;
 Inc(pGetB, SizeOf(TCPSHdr));

 if (pCPSHdr^.CompType and 1) <> 0 then begin
  w := 0;
  repeat
   c := pGetB^;
   inc(pGetB);
   if (c and $80) <> 0 then if ( c and $40 ) <> 0 then begin
    z := c and $1F + 2;
    if (c and $20) <> 0 then begin
     inc(z,(pGetB^ shl 5));
     inc(pGetB);
    end;
    c := pGetB^;
    inc(pGetB);
    x1 := 0;                                
    while(x1 < z) do if w <= UnpSize then begin
     pPutB^ := c;
     inc(pPutB);
     inc(w);
     inc(x1);
    end else goto done;
   end else begin
    pPutPrevB := pPutB;
    dec(pPutPrevB,(((c and 3) shl 8) + pGetB^ + 1));
    z := ((c shr 2) and $0F) + 2;
    inc(pGetB);
    x1 := 0;
    while x1 < z do if w <= UnpSize then begin
     pPutB^ := pPutPrevB^;
     inc(pPutB);
     inc(pPutPrevB);
     inc(w);
     inc(x1);
    end else goto done;
   end else if (c and $40) <> 0 then begin
    x2 := 0;
    z := (c and $3F) + 2;
    y := pGetB^ + 1;
    inc(pGetB);
    while x2 < y do begin
     x1 := 0;
     NullB := pointer(pGetB);
     while x1 < z do if w <= UnpSize then begin
      pPutB^ := NullB[x1];
      inc(pPutB);
      inc(x1);
      inc(w);
     end else goto done;
     inc(x2);
    end;
    inc(pGetB,z);
   end else begin
    z := (c and $1F) + 1;
    if (c and $20) <> 0 then begin
     inc(z,(pGetB^ shl 5));
     inc(pGetB);
    end;
    x1 := 0;
    while x1 < z do if w <= UnpSize then begin
     pPutB^ := pGetB^;
     inc(pPutB);
     inc(pGetB);
     inc(x1);
     inc(w);
    end else goto done;
   end;
  until w >= UnpSize;
 end else if (pCPSHdr^.CompType and 2) <> 0 then begin // Method 2, not supported
  FreeMem(pGet);
  FreeMem(pPut);
  goto bug;
 end else CopyMemory(pPut, pGetB, UnpSize);

done:    
 sOut := TMemoryStream.Create;
 sOut.WriteBuffer(pPut^, UnpSize);
 FreeMem(pGet);
 FreeMem(pPut);
bug:
 if UnpSize > 0 then Result := True else Result := False;
end;

function Import_CPS(InputStream, OutputStream, OutputStreamA : TStream) : TRFI;
var RFI : TRFI; TempoStream : TStream;
begin
 RFI.Valid := False;
 TempoStream := TMemoryStream.Create;
 if Decode_CPS(InputStream,TempoStream) then begin
  RFI := Import_PRT(TempoStream,OutputStream,OutputStreamA);
  FreeAndNil(TempoStream);
 end;
 Result := RFI;
end;

end.