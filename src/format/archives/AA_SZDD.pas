{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Microsoft's SZDD archive-with-single-file format & functions

  Written by dsp2003.
}

unit AA_SZDD;

interface

uses AA_RFA,
     Generic_LZXX,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms, JReconvertor;

 { Supported archives implementation }
 procedure IA_SZDD(var ArcFormat : TArcFormats; index : integer);

  function OA_SZDD : boolean;
  
  function EA_SZDD(FileRecord : TRFA) : boolean;

implementation

uses AnimED_Archives;

procedure IA_SZDD;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Microsoft SZDD';
  Ext  := '';
  Stat := $F;
  Open := OA_SZDD;
//  Save :=
  Extr := EA_SZDD;
  FLen := 0;
  SArg := 0;
  Ver  := $20090908;
 end;
end;

function OA_SZDD;
{ Ever17 DAT archive opening function }
var SZDD : TSZDDHeader;
begin

 Result := False;

 with ArchiveStream do begin

  Seek(0,soBeginning);

  with SZDD, RFA[1] do begin

   Read(SZDD,SizeOf(SZDD));

   if Magic1 <> 'SZDD' then Exit;

   RecordsCount := 1;

   RFA_1 := 0;
   RFA_2 := UnpackedSize;
   RFA_C := Size;
   RFA_3 := Wide2JIS(ExtractFileName(ArchiveFileName));
   RFA_X := $FD;
   RFA_Z := True;

  end;

 end;

 Result := True;

end;

function EA_SZDD;
var tmpStream, unpStream : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  tmpStream.Position := 0;
  unpStream := TMemoryStream.Create;
  if SZDDDecode(tmpStream, unpStream) then begin
   unpStream.Position := 0;
   FileDataStream.CopyFrom(unpStream,unpStream.Size);
  end else raise Exception.Create('SZDD extraction failed.');
 finally
  FreeAndNil(unpStream);
  FreeAndNil(tmpStream);
 end;
 Result := True;
end;

end.