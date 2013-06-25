{
  AE - VN Tools
  © 2007-2012 WinKiller Studio. Open Source.
  This software is free. Please see License for details.

  Crowd Image Handling File
  
  Written by dsp2003, Nik & Marisa-chan.
}

unit AG_Crowd;

interface

uses Classes, Sysutils, IniFiles,
     AnimED_Math,
     AG_Fundamental,
     AnimED_Console,
     Generic_LZXX,
     AG_StdFmt,
     AG_Portable_Network_Graphics,
     AG_RFI;

type

{ Crowd Portable Network Graphics }
 TCWDP = packed record
  CWDPHeader: array[1..4]  of char; // header
  Chunk2    : array[1..17] of char; // Unique
  IDATChunk : array[1..4]  of char; // IDATChunk
 end;

{ CROWD image format - header 56 bytes }
 TCWL = record
  CWLHeader : array[1..28] of char;  // 'cwd format  - version 1.00 -'
  CWLGarbage : array[1..28] of byte; // WTF!? Inverted?! XORed?!! ANDed?!!! SOMEBODY, HELP ME!!!!
 end;

{ Crowd's ZBM processing functions }
function Decode_ZBM(iStream, oStream : TStream) : boolean;
function Encode_ZBM(iStream, oStream : TStream) : boolean;
{ ...this part is for easier conversion between another formats }
function Import_ZBM(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
function Export_ZBM(RFI : TRFI; oStream, iStream : TStream; iStreamA : TStream = nil) : boolean;
procedure IG_ZBM(var ImFormat : TImageFormats);

{ Crowd's CWP processing functions }
function Decode_CWP(iStream, oStream : TStream) : boolean;
function Encode_CWP(iStream, oStream : TStream) : boolean;
{ ...this part is for easier conversion between another formats }
function Import_CWP(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
function Export_CWP(RFI : TRFI; oStream, iStream : TStream; iStreamA : TStream = nil) : boolean;
procedure IG_CWP(var ImFormat : TImageFormats);

{ Crowd's GAX processing functions }
function Transcode_GAX(iStream, oStream : TStream; Mode : boolean = False) : boolean;
function Import_GAX(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
function Export_GAX(RFI : TRFI; oStream, iStream : TStream; iStreamA : TStream = nil) : boolean;
procedure IG_GAX(var ImFormat : TImageFormats);

//var
//  ColorSwap, GenAlpha, KillAlpha : boolean;
//  CWPCompression_Crowd : integer;

implementation

procedure IG_ZBM;
begin
 with ImFormat do begin
  Name := '[ZBM] Crowd''s Encrypted BMP';
  Ext  := '.zbm';
  Stat := $0;
  Open := Import_ZBM;
  Save := Export_ZBM;
  Ver  := $20100311;
 end;
end;

procedure IG_CWP;
begin
 with ImFormat do begin
  Name := '[CWP] Crowd''s Obfuscated PNG';
  Ext  := '.cwp';
  Stat := $0;
  Open := Import_CWP;
  Save := Export_CWP;
  Ver  := $20100311;
 end;
end;

procedure IG_GAX;
begin
 with ImFormat do begin
  Name := '[GAX] Crowd''s Encrypted PNG';
  Ext  := '.gax';
  Stat := $0;
  Open := Import_GAX;
  Save := Export_GAX;
  Ver  := $20120620;
 end;
end;


function Decode_ZBM;
var i : integer; j : byte;
begin
 Result := False;
 iStream.Seek(0,soBeginning);
 oStream.Seek(0,soBeginning);
 iStream.Read(j,1);
 if char(j xor $FF) = 'B' then begin
  iStream.Read(j,1);
  if char(j xor $FF) = 'M' then begin
   iStream.Seek(0,soBeginning);
   for i := 1 to 100 do begin
    iStream.Read(j,1);
    j := j xor $FF;
    oStream.Write(j,1);
   end;
   oStream.CopyFrom(iStream,iStream.Size-iStream.Position);
   Result := True;
  end;
 end;
end;

function Encode_ZBM;
var i : integer; j : byte;
begin
 Result := False;
 iStream.Seek(0,soBeginning);
 oStream.Seek(0,soBeginning);
 for i := 1 to 100 do begin
  iStream.Read(j,1);
  j := j xor $FF;
  oStream.Write(j,1);
 end;
 oStream.CopyFrom(iStream,iStream.Size-iStream.Position);
 Result := True;
end;

function Import_ZBM;
var RFI : TRFI; tmpStream : TStream;
begin
 RFI.Valid := False;
 tmpStream := TMemoryStream.Create;
 if Decode_ZBM(iStream,tmpStream) then
  begin
   RFI := Import_BMP(tmpStream,oStream,oStreamA);
//   RFI.FormatID := 'Crowd''s Windows Bitmap';
  end;
 Result := RFI;
 FreeAndNil(tmpStream);
end;

function Export_ZBM;
var tmpStream : TStream;
begin
 Result := False;
 iStream.Seek(0,soBeginning);
 if iStreamA <> nil then iStreamA.Seek(0,soBeginning);

 tmpStream := TMemoryStream.Create;
 Export_BMP(RFI,tmpStream,iStream,iStreamA);
 Encode_ZBM(tmpStream,oStream);
 FreeAndNil(tmpStream);
 Result := True;
end;

function Decode_CWP;
var PNGHeader : TPNGHeader;
    PNGFooter : TPNGFooter;
    k : integer;
    MiniBuffer : array[1..4] of char;
label StopThis;
begin
 iStream.Seek(0,soBeginning);
 oStream.Seek(0,soBeginning);
 k := 0;
 Result := False;

 iStream.Read(MiniBuffer,4);
{ Header check code }
 if MiniBuffer <> 'CWDP' then goto StopThis;
 with oStream do begin
  with PNGHeader do begin
 { Reconstructing PNG header }
   PNGHeader := #137+'PNG';
   Chunk1    := #13#10#26#10;
   IHDRChunk := #0#0#0#13;
   IHDR      := 'IHDR';
   iStream.Read(Chunk2,17);
   iStream.Read(IDATChunk,4);
   IDAT      := 'IDAT';
  end;
  with PNGFooter do begin
   IEND      := 'IEND';
   IENDChunk := #174#66#96#130;
  end;
//-----------------------------------
  Write(PNGHeader,SizeOf(PNGHeader));
  CopyFrom(iStream,iStream.Size-iStream.Position);
  Write(k,3); //writing required #0#0#0 values
  Write(PNGFooter,SizeOf(PNGFooter));
  Result := True;
 end;
StopThis: 
end;

function Encode_CWP;
var CWDP : TCWDP;
    MiniBuffer : array[1..4] of char;
label StopThis;
begin
 iStream.Seek(0,soBeginning);
 oStream.Seek(0,soBeginning);
 Result := False;

 iStream.Read(MiniBuffer,4);
{ Header check code }
 if MiniBuffer <> #137+'PNG' then goto StopThis;
 with CWDP do begin
  with iStream do begin
 { Working with the PNG data }
   Seek(0,soBeginning);
 { Reconstructing CWDP header }
   CWDPHeader := 'CWDP';
   Seek(16,soCurrent); // Skipping the unnecessary data
   Read(Chunk2,17);
 { Detecting the IDAT chunk position }
   Seek(4,soCurrent);
   Read(MiniBuffer,4);
   if MiniBuffer <> 'IDAT' then
   while MiniBuffer <> 'IDAT' do begin
    Seek(-3,soCurrent); // Rolling back to detect the header
    Read(MiniBuffer,4);
   end;
   Seek(-8,soCurrent); // Rolling back to read the IDAT chunk
   Read(IDATChunk,4);
   Seek(4,soCurrent); // Skipping the IDAT header
  end;
//-----------------------------------
  with oStream do begin
   Write(CWDPHeader,4);
   Write(Chunk2,17);
   Write(IDATChunk,4);
   CopyFrom(iStream,iStream.Size-iStream.Position-11); //11 is a #0#0#0+IEND+IENDChunk
   Result := True;
  end;
 end;
StopThis: 
end;

function Import_CWP;
var RFI : TRFI; tmpStream : TStream;
begin
 RFI.Valid := False;

 tmpStream := TMemoryStream.Create;

 if Decode_CWP(iStream,tmpStream) then begin
  RFI := Import_PNG(tmpStream,oStream,oStreamA,True); // True = Colour swapping
  //if KillAlpha then
  RFI.ExtAlpha := False;
{  if ColorSwap then try
   SwapColors(oStream,RFI.RealWidth,RFI.RealHeight,RFI.BitDepth,scBGR);
  except
  end;}
//  RFI.FormatID := 'Crowd''s Portable Network Graphics';
  FreeAndNil(tmpStream);
 end;
 Result := RFI;
end;

function Export_CWP;
var tmpStream, tmpStreamA, tmpStreamO : TStream;
    i : integer; j : byte; RGB : TRGB; ARGB : TARGB;
begin
 iStream.Seek(0,soBeginning);
 if iStreamA <> nil then iStreamA.Seek(0,soBeginning);

 Result := False;
// if ColorSwap then
 try
  tmpStream := TMemoryStream.Create;
  case RFI.BitDepth of
   24 : for i := 1 to RFI.RealWidth*RFI.RealHeight do begin
         iStream.Read(RGB,3);
         RGB := SwapColors24(RGB,scBGR);
         tmpStream.Write(RGB,3);
        end;
   32 : for i := 1 to RFI.RealWidth*RFI.RealHeight do begin
         iStream.Read(ARGB,4);
         ARGB := SwapColors32(ARGB,scBGR);
         tmpStream.Write(ARGB,4);
        end;
  end;
  tmpStream.Seek(0,soBeginning);
 except
  tmpStream.Size := 0;
  iStream.Seek(0,soBeginning);
  tmpStream.CopyFrom(iStream,iStream.Size);
  tmpStream.Seek(0,soBeginning);
 end;
// if GenAlpha then
//  begin
 tmpStreamA := TMemoryStream.Create;
 j := 0;
 for i := 1 to RFI.RealWidth*RFI.RealHeight do tmpStreamA.Write(j,1);
 RFI.ExtAlpha := True;
//  end;
 tmpStreamO := TMemoryStream.Create;
 Export_PNG(RFI,tmpStreamO,tmpStream,tmpStreamA,PNGCompression_PNG);
 FreeAndNil(tmpStream);
 FreeAndNil(tmpStreamA);
 tmpStreamO.Seek(0,soBeginning);
 Encode_CWP(tmpStreamO,oStream);
 FreeAndNil(tmpStreamO);
 Result := True;
end;

function Transcode_GAX;
var i,p,p_in,p_out,m : byte;
    s : array[0..$F] of byte;
begin
 // True  -> Encoding
 // False -> Decoding
 if Mode then begin
  s[$0] := byte('A');
  s[$1] := byte('E');
  s[$2] := byte(' ');
  s[$3] := byte('V');
  s[$4] := byte('N');
  s[$5] := byte(' ');
  s[$6] := byte('T');
  s[$7] := byte('O');
  s[$8] := byte('O');
  s[$9] := byte('L');
  s[$a] := byte('S');
  s[$b] := byte(' ');
  s[$c] := byte('>');
  s[$d] := byte(':');
  s[$e] := byte('3');
  s[$f] := byte(' ');
  oStream.Write(s,sizeof(s));
 end else begin
  // Sanity check
  if iStream.Size - iStream.Position > $10 then begin
   // Initializing salt key
   iStream.Read(s,sizeof(s));
  end else Exit;
 end;

 while iStream.Position < iStream.Size do begin

  // Salt
  for i := 0 to $f do begin
   // Too much salt checkup
   if iStream.Position = iStream.Size then Break;
   iStream.Read(m,1);
   //m := m xor s[i];
   //// Pepper
   //if i = $e then p := m;

   // Pepper in
   if i = $e then p_in := m;
   m := m xor s[i];
   // Pepper out
   if i = $e then p_out := m;

   oStream.Write(m,1);
  end;

  // True  -> encoding
  // False -> decoding
  if Mode then p := p_in else p := p_out;

  case (p and $7) of
  0 : begin
       s[$0] := s[$0] + p;
       s[$3] := s[$3] + p + $2;
       s[$4] := s[$2] + p + $b;
       s[$8] := s[$6] + $7;
      end;
  1 : begin
       s[$2] := s[$9] + s[$a];
       s[$6] := s[$7] + s[$f];
       s[$8] := s[$8] + s[$1];
       s[$f] := s[$5] + s[$3];
      end;
  2 : begin
       s[$1] := s[$1] + s[$2];
       s[$5] := s[$5] + s[$6];
       s[$7] := s[$7] + s[$8];
       s[$a] := s[$a] + s[$b];
      end;
  3 : begin
       s[$9] := s[$2] + s[$1];
       s[$b] := s[$6] + s[$5];
       s[$c] := s[$8] + s[$7];
       s[$d] := s[$b] + s[$a];
      end;
  4 : begin
       s[$0] := s[$1] + $6f;
       s[$3] := s[$4] + $47;
       s[$4] := s[$5] + $11;
       s[$e] := s[$f] + $40;
      end;
  5 : begin
       s[$2] := s[$2] + s[$a];
       s[$4] := s[$5] + s[$c];
       s[$6] := s[$8] + s[$e];
       s[$8] := s[$b] + s[$0];
      end;
  6 : begin
       s[$9] := s[$b] + s[$1];
       s[$b] := s[$d] + s[$3];
       s[$d] := s[$f] + s[$5];
       s[$f] := s[$9] + s[$7];
       s[$1] := s[$9] + s[$5];
       s[$2] := s[$a] + s[$6];
       s[$3] := s[$b] + s[$7];
       s[$4] := s[$c] + s[$8];
      end;
  else
      begin
       s[$1] := s[$9] + s[$5];
       s[$2] := s[$a] + s[$6];
       s[$3] := s[$b] + s[$7];
       s[$4] := s[$c] + s[$8];
      end;
  end;
 end;
 Result := True;
end;

function Import_GAX;
var RFI : TRFI; tmpStream : TStream;
    Header : longword;
begin
 RFI.Valid := False;

 tmpStream := TMemoryStream.Create;
 iStream.Seek(0,soBeginning);
 iStream.Read(Header,SizeOf(Header));
 if Header <> $01000000 then Exit;

 if Transcode_GAX(iStream,tmpStream) then begin
  RFI := Import_PNG(tmpStream,oStream,oStreamA);
  FreeAndNil(tmpStream);
 end;
 Result := RFI;
end;

function Export_GAX;
var tmpStream : TStream; hdr : longword;
begin
 Result := False;
 iStream.Seek(0,soBeginning);
 if iStreamA <> nil then iStreamA.Seek(0,soBeginning);

 tmpStream := TMemoryStream.Create;
 Export_PNG(RFI,tmpStream,iStream,iStreamA);

 hdr := $01000000;
 oStream.Write(hdr,sizeof(hdr));
 tmpStream.Seek(0,soBeginning);
 Transcode_GAX(tmpStream,oStream,True);
 FreeAndNil(tmpStream);
 Result := True;
end;

end.