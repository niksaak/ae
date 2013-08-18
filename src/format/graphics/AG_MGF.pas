{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  Popotan DVD MGF/PNG Image Format library

  Written by dsp2003.
}

unit AG_MGF;

interface

uses Classes, SysUtils,
     AG_Portable_Network_Graphics,
     AG_Fundamental,
     AG_RFI;

type
 TMGFHeader = array[1..8] of char; // 'MalieGF'#0

function Import_MGF(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
//function Export_MGF(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_MGF(var ImFormat : TImageFormats);

implementation

uses AnimED_Graphics;

procedure IG_MGF;
begin
 with ImFormat do begin
  Name := '[MGF] Popotan DVD MGF/PNG with metadata';
  Ext  := '.mgf';
  Stat := $F;
  Open := Import_MGF;
  Save := nil;
  Ver  := $20100311;
 end;
end;

function Import_MGF(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    MGF : TMGFHeader;
    TempoStream : TStream;
begin
 RFI.Valid := False;

 with InputStream do begin
  Seek(0,soBeginning);
  Read(MGF,SizeOf(MGF));
  if MGF <> 'MalieGF'#0 then Exit;

  MGF := #$89#$50#$4E#$47#$0D#$0A#$1A#$0A;

  Seek(8,soBeginning);
  TempoStream := TMemoryStream.Create;
  TempoStream.Write(MGF,SizeOf(MGF));
  TempoStream.CopyFrom(InputStream,InputStream.Size-InputStream.Position);
  RFI := Import_PNG(TempoStream,OutputStream,OutputStreamA);
//  RFI.FormatID := 'Popotan DVD MGF/PNG with metadata';
  FreeAndNil(TempoStream);
 end;

 Result := RFI;
end;

end.