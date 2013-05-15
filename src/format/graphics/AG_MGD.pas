{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  MGD/PNG FJSYS Image Format library

  Written by dsp2003 & w8m.
}

unit AG_MGD;

interface

uses Classes, SysUtils,
     AG_Portable_Network_Graphics,
     AG_Fundamental,
     AG_RFI;

type
 TMGDHdr = packed record
  Magic     : array[1..4] of char; // 'MGD'#32
  MetaSize  : word; // $5C
 end;
 TMGDDatHdr = packed record
  Unk0      : word; // $1
  Dummy     : longword; // $0
  Width     : word;
  Height    : word;
  Size      : longword; // размер распакованного потока
  PackSize  : longword; // сжатый размер
  CompType  : longword; // $0 - без, $1 - sgd, $2 - png
//----
  Unk97     : longword; // ?
  Unk98     : longword; // $40 00 00 00
  DummyL    : int64;    // $0
  Unk99     : longword; // $2  
  DummyM    : int64;    // $0
  DataSize  : longword; // размер сжатых данных (на 4 меньше чем PackSize)
  AlphaSize : longword; // размер альфы
 end;

function Import_MGD(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
//function Export_MGD(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_MGD(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_MGD;
begin
 with ImFormat do begin
  Name := '[MGD] FJSYS MGD/PNG with metadata';
  Ext  := '.mgd';
  Stat := $F;
  Open := Import_MGD;
  Save := nil;
  Ver  := $20100311;
 end;
end;

function Import_MGD(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    MGD : TMGDHdr;
    TempoStream : TStream;
begin
 RFI.Valid := False;

 with MGD, InputStream do begin
  Seek(0,soBeginning);
  Read(MGD,SizeOf(MGD));
  if Magic <> 'MGD'#32 then Exit;
  Seek(MetaSize+4,soBeginning);
  TempoStream := TMemoryStream.Create;
  TempoStream.CopyFrom(InputStream,InputStream.Size-InputStream.Position);
  RFI := Import_PNG(TempoStream,OutputStream,OutputStreamA);
  FreeAndNil(TempoStream);
 end;

 Result := RFI;
end;

end.