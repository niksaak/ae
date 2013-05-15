{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Crowd Engine 3 PCK archive format & functions

  Written by dsp2003.
}

unit AA_PCK_Crowd_Engine_3;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_PCK_CROWD3(var ArcFormat : TArcFormats; index : integer);

  function OA_PCK_CROWD3 : boolean;
  function SA_PCK_CROWD3(Mode : integer) : boolean;

type
{ Crowd Engine 3 PCK structural description }
 TPCKHdr = packed record
  FileCount : longword; // Total number of files
 end;
 TPCKDir = packed record
  Dummy     : longword; // Dummy. Used for checking the format :)
  Offset    : longword; // Offset in the archive
  Filesize  : longword; // Filesize
 end;
 TPCKDirFN = array[1..256] of char; // Filename. Zero-terminated. Size varies.

implementation

uses AnimED_Archives;

procedure IA_PCK_CROWD3;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Crowd Engine 3 Pack';
  Ext  := '.pck';
  Stat := $0;
  Open := OA_PCK_CROWD3;
  Save := SA_PCK_CROWD3;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20101222;
 end;
end;

function OA_PCK_CROWD3;
{ Crowd 3 Pack archive opening function }
var i,j : integer;
    Hdr : TPCKHdr;
    Dir : TPCKDir;
    Filename  : TPCKDirFN;
begin
 Result := False;
 ReOffset := 0;
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);
// Reading PCK eader (4 bytes)...
   Read(FileCount,4);
   RecordsCount := FileCount;
  end;
// Reading file table...

  if RecordsCount = 0 then Exit;
  if RecordsCount > $FFFF then Exit;

  for i := 1 to RecordsCount do begin
   with Dir do begin
    Read(Dummy,4);

    if Dummy <> $00 then Exit;

    Read(offset,4);
    Read(FileSize,4);

    if offset = 0 then Exit;

    RFA[i].RFA_1 := Offset+ReOffset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
   end;
  end;
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_3 := ''; // fixing filename fill bug
   FillChar(FileName,SizeOf(FileName),0);  //cleaning the array in order to avoid garbage
   for j := 1 to length(FileName) do begin
    Read(FileName[j],1); {Header size is not fixed... damn!}
    if FileName[j] = #0 then break;
   end;
   for j := 1 to length(FileName) do begin
    if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j];
   end;
  end;
 end;

 Result := True;

end;

function SA_PCK_CROWD3;
var i, j : integer;
    Hdr      : TPCKHdr;
    Dir      : TPCKDir;
    Filename : TPCKDirFN;
begin
 with Hdr do begin
//Generating header (4 bytes)...
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  FileCount := RecordsCount;
{ We have to calculate the header by checking the length of every filename, because the header size is not fixed }
  for i := 1 to RecordsCount do ReOffset := ReOffset+length(ExtractFileName(AddedFiles.Strings[i-1]))+1; //+1 means zero byte
 end;
// Writing header...
 ArchiveStream.Write(Hdr,SizeOf(Hdr));

//Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1])+#0;

   Offset := RFA[i].RFA_1;
   FileSize := RFA[i].RFA_2;
   FreeAndNil(FileDataStream);
   ArchiveStream.Write(Dir,SizeOf(Dir));
  end;
 end;
//Writing file...

 for i := 1 to RecordsCount do begin
  with ArchiveStream do begin
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to length(RFA[i].RFA_3) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   Write(Filename,length(RFA[i].RFA_3));
  end;
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

end.