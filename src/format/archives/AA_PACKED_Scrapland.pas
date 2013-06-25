{
  AE - VN Tools
  © 2007-2013 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Mercury Stream Entertainment's Scrapland Engine PACKED archive format & functions

  Written by dsp2003. Specs ffom lolibot.
}

unit AA_PACKED_Scrapland;

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
 procedure IA_PACKED_SCRAPLAND(var ArcFormat : TArcFormats; index : integer);

  function OA_PACKED_SCRAPLAND : boolean;
  function SA_PACKED_SCRAPLAND(Mode : integer) : boolean;

type
 TScrapHdr = packed record
  Magic     : array[1..4] of char; // BFPK
  Dummy     : longword;
  FileCount : longword;
 end;
 //TScrapDirFNL = longword; // Filename length
 //TScrapDirFN = array[1..256] of char; // Filename. Zero-terminated. Size varies.
 TScrapDir = packed record
  Filesize  : longword;
  Offset    : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_PACKED_SCRAPLAND;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Scrapland Engine';
  Ext  := '.packed';
  Stat := $0;
  Open := OA_PACKED_SCRAPLAND;
  Save := SA_PACKED_SCRAPLAND;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20130418;
 end;
end;

function OA_PACKED_SCRAPLAND;
var i, j, k : longword;
    Hdr : TScrapHdr;
    Dir : TScrapDir;
begin
 Result := False;

 with ArchiveStream do begin
  // Reading header and checking structure
  with Hdr do begin
   Seek(0,soBeginning);
   Read(Hdr,SizeOf(Hdr));
   if Magic <> 'BFPK' then Exit;
   if Dummy <> 0 then Exit;
   RecordsCount := FileCount;
  end;

{*}Progress_Max(RecordsCount);

  // Reading file table...
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

   Read(j,SizeOf(j));
   SetLength(RFA[i].RFA_3,j);

   Read(RFA[i].RFA_3[1],j);
   for k := 1 to j do begin
    if RFA[i].RFA_3[k] = '/' then RFA[i].RFA_3[k] := '\'; // replacing unix slash with windows (ugly, i know)
   end;

   with Dir do begin
    Read(Dir,SizeOf(Dir));

    if Offset = 0 then Exit; // cannot be < than filetable size

    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
   end;
  end;

 end;

 Result := True;

end;

function SA_PACKED_SCRAPLAND;
var i, j, k : integer;
    Hdr : TScrapHdr;
    Dir : TScrapDir;
begin
 with Hdr do begin
//Generating header...
  Magic := 'BFPK';
  Dummy := 0;
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(Hdr)+(SizeOf(Dir)+4)*RecordsCount; //+4 means filename length field
  FileCount := RecordsCount;
{ We have to calculate the header by checking the length of every filename, because the header size is not fixed }
  for i := 1 to RecordsCount do ReOffset := ReOffset+length(AddedFiles.Strings[i-1]);
 end;
// Writing header...
 ArchiveStream.Write(Hdr,SizeOf(Hdr));

//Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir, ArchiveStream do begin
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_3 := AddedFiles.Strings[i-1];

   k := length(RFA[i].RFA_3);
   for j := 1 to k do begin
    if RFA[i].RFA_3[j] = '\' then RFA[i].RFA_3[j] := '/';
   end;
   Write(k,SizeOf(k)); // writing length of filename entry
   Write(RFA[i].RFA_3[1],k); // writing filename entry


   Offset := RFA[i].RFA_1;
   FileSize := RFA[i].RFA_2;
   FreeAndNil(FileDataStream);
   Write(Dir,SizeOf(Dir));

  end;
 end;

 // Writing files...
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

end.