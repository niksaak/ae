{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Crowd Image Handling File
  
  Written by dsp2003. Specifications from w8m.
}

unit AG_Burns_EENC_PNG;

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
 TBurnsEENC = packed record
  Magic    : array[1..4] of char; // EENC/EENZ
  FileSize : longword;
 end;

function Decode_EENC_PNG(iStream, oStream : TStream) : boolean;
function Import_EENC_PNG(iStream, oStream : TStream; oStreamA : TStream = nil) : TRFI;
procedure IG_EENC_PNG(var ImFormat : TImageFormats);

implementation

procedure IG_EENC_PNG;
begin
 with ImFormat do begin
  Name := '[PNG] Burns EENC PNG';
  Ext  := '.png';
  Stat := $F;
  Open := Import_EENC_PNG;
//  Save := ;
  Ver  := $20100920;
 end;
end;

function Decode_EENC_PNG(iStream, oStream : TStream) : boolean;
var Hdr   : TBurnsEENC;
    Key   : longword;
    Piece : longword;
    i : longword;
begin

 Result := False;

 iStream.Seek(0,soBeginning);
 oStream.Seek(0,soBeginning);

 iStream.Read(Hdr,SizeOf(Hdr));
 with Hdr do begin
  if Magic <> 'EENC' then Exit;
  Key := FileSize xor $DEADBEEF;

  iStream.Read(Piece,4);
  Piece := Piece xor Key;
  if Piece <> $474E5089 then Exit; // %PNG header check

  oStream.Write(Piece,4);

  for i := 2 to (FileSize div 4) do begin
   iStream.Read(Piece,4);
   Piece := Piece xor Key;
   oStream.Write(Piece,4);
  end;
  
  // writing tail
  if (FileSize mod 4) > 0 then begin
   iStream.Read(Piece,FileSize mod 4);
   Piece := Piece xor Key;
   oStream.Write(Piece,FileSize mod 4);
  end;
  
 end; 

 Result := True;

end;

function Import_EENC_PNG;
var RFI : TRFI; TempoStream : TStream;
begin
 RFI.Valid := False;

 TempoStream := TMemoryStream.Create;

 if Decode_EENC_PNG(iStream,TempoStream) then begin
  RFI := Import_PNG(TempoStream,oStream,oStreamA);
  FreeAndNil(TempoStream);
 end;
 Result := RFI;
end;

end.