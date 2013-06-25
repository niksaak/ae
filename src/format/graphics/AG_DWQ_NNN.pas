{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  NNN DWQ BlackCyc Image Format library

  Written by dsp2003.
}

unit AG_DWQ_NNN;

interface

uses Classes, SysUtils,
     AG_StdFmt,
     AG_Portable_Network_Graphics,
     AG_Fundamental,
     AG_RFI;

type
 TDWQJPEGHeader = packed record
  Header    : array[1..4]  of char; // 'JPEG'              | 'PNG'+#32
  Dummy0    : array[1..12] of char; // FillChar #32;       |
  Dummy1    : array[1..16] of char; // #32 (jpeg)          | #0 (png)
  ImageSize : longword;
  Width     : longword;
  Height    : longword;
  Dummy2    : array[1..4] of char; // FillChar #32;
  PackType  : array[1..16] of char; // 'PACKTYPE=5' , #32  | 'PACKTYPE=8A'
 end;

function IM_DWQ_NNN(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
//function EX_DWQ_NNN(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_DWQ_NNN(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_DWQ_NNN;
begin
 with ImFormat do begin
  Name := '[DWQ] NNN BlackCyc JPEG/PNG wrapper';
  Ext  := '.dwq';
  Stat := $F;
  Open := IM_DWQ_NNN;
  Save := nil;
  Ver  := $20100504;
 end;
end;

function IM_DWQ_NNN(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    DWQ : TDWQJPEGHeader;
    TempoStream : TStream;
begin
 RFI.Valid := False;

 with DWQ, InputStream do begin
  Seek(0,soBeginning);
  Read(DWQ,SizeOf(DWQ));
  if Header <> 'JPEG' then
   if Header <> 'PNG'#32 then Exit;
  TempoStream := TMemoryStream.Create;
  TempoStream.CopyFrom(InputStream,InputStream.Size-InputStream.Position);
   if Header = 'JPEG' then RFI := Import_JPG(TempoStream,OutputStream,OutputStreamA);
   if Header = 'PNG'#32 then RFI := Import_PNG(TempoStream,OutputStream,OutputStreamA);
  FreeAndNil(TempoStream);
 end;

 Result := RFI;
end;

end.