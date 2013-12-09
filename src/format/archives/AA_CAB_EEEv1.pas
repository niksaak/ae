{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Wanwan, Moomoo, Usausa, Koon! CAB game archive format & functions
  
  Written by dsp2003.
}

unit AA_CAB_EEEv1;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_CAB_EEEv1(var ArcFormat : TArcFormats; index : integer);

  function OA_CAB_EEEv1 : boolean;
  function SA_CAB_EEEv1(Mode : integer) : boolean;

type
{ CAB PackDat3 Entertainment Executive Engine v1.00 UsaUsa archive format }
 TCABEEEv1Header = packed record
  Header       : array[1..8] of char; //"PackDat3"
  TotalRecords : longword; // File count
 end;
 TCABEEEv1Dir = packed record
  FileName     : array[1..256] of char; // File name
  Offset       : longword; // File offset
  Filesize     : longword; // File size
  CFilesize    : longword; // Copy of file size
 end;

implementation

uses AnimED_Archives;

procedure IA_CAB_EEEv1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Entertainment Executive Engine v1.00 PackDat3';
  Ext  := '.cab';
  Stat := $0;
  Open := OA_CAB_EEEv1;
  Save := SA_CAB_EEEv1;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_CAB_EEEv1;
{ UsaUsa archive opening function }
var i,j : integer;
    Hdr : TCABEEEv1Header;
    Dir : TCABEEEv1Dir;
begin
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);
// Reading header (12 bytes)...
   Read(Hdr,SizeOf(Hdr));
/////////// HEADER CHECK CODE ///////////
   if Header <> 'PackDat3' then Exit;
/////////// HEADER CHECK CODE ///////////
   RecordsCount := TotalRecords;
//   ReOffset := SizeOf(UsaHeader) + SizeOf(UsaDir)*RecordsCount;
  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    for j := 1 to 256 do begin
     if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    end;
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := CFileSize;
   end;
  end;
 end;
 Result := True;

end;

function SA_CAB_EEEv1;
{ UsaUsa archive creation function }
var i, j : integer;
    Hdr : TCABEEEv1Header;
    Dir : TCABEEEv1Dir;
begin
 with Hdr do begin
//Generating header (12 bytes)...
  Header := 'PackDat3';
//Calculating records count...
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  TotalRecords := RecordsCount;
 end;

 ArchiveStream.Write(Hdr,SizeOf(Hdr));

// Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin

//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2   := FileDataStream.Size;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]);
   for j := 1 to 256 do begin
    if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j]
    else FileName[j] := #0;
   end;
   Offset    := RFA[i].RFA_1;
   FileSize  := RFA[i].RFA_2;
   CFileSize := RFA[i].RFA_2;
   FreeAndNil(FileDataStream);
// Writing file table entry...
   ArchiveStream.Write(Dir,SizeOf(Dir));
  end;
 end;

 for i := 1 to RecordsCount do
  begin
{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;

 Result := True;

end;

end.