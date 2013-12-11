{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  KLEIN Pure Pure PAK archive format & functions

  Written by dsp2003.
}

unit AA_PAK_PurePure;

interface

uses AA_RFA,
     Generic_LZXX,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_PAK_PurePure(var ArcFormat : TArcFormats; index : integer);

  function OA_PAK_PurePure : boolean;
  function SA_PAK_PurePure(Mode : integer) : boolean;

type
{ KLEIN PurePure archive format (uncompressed only) }
 TPAKPurePureHeader = packed record
  Header       : array[1..4] of char; //"PACK"
  TotalRecords : longword; // File count
  CFlag        : longword; // Data compression flag (LZ\RLE)
  Dummy        : longword; // Dummy
 end;
 TPAKPurePureDir = packed record
  FileName     : array[1..64] of char; // File name
  Filesize     : longword; // File size
  CFilesize    : longword; // Compressed file size
  Offset       : longword; // File offset
 end;

implementation

uses AnimED_Archives;

procedure IA_PAK_PurePure;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KLEIN PurePure';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_PurePure;
  Save := SA_PAK_PurePure;
  Extr := EA_LZSS_FEE_FFF;
  FLen := 64;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_PAK_PurePure;
{ PurePure archive opening function }
var i,j : integer;
    PureHeader    : TPAKPurePureHeader;
    PureDir       : TPAKPurePureDir;
begin
 with ArchiveStream do begin
  with PureHeader do begin
   Seek(0,soBeginning);
// Reading header (16 bytes)...
   Read(PureHeader,SizeOf(PureHeader));

   if (Header <> 'PACK') or ((Dummy <> 0) or (CFlag > 1)) then Exit;

   RecordsCount := TotalRecords;
// File records in archive = RecordsCount
   ReOffset := 16 + 76*RecordsCount;
// Header and filetable size = ReOffset
  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with PureDir do begin
    Read(PureDir,SizeOf(PureDir));
    for j := 1 to 64 do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3+FileName[j] else break;
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := CFileSize;
    RFA[i].RFA_Z := boolean(PureHeader.CFlag);
    RFA[i].RFA_X := $FD; // lzss
   end;
  end;
 end;

 Result := True;

end;

function SA_PAK_PurePure;
{ PurePure archive creation function }
var i, j : integer;
    PureHeader    : TPAKPurePureHeader;
    PureDir       : TPAKPurePureDir;
begin
 with PureHeader do begin
//Generating header (16 bytes)...
  Header := 'PACK';
//Calculating records count...
  RecordsCount := AddedFiles.Count;
  ReOffset := 32+4+20*RecordsCount;
//Filetable & header size = ReOffset-4
//Filetable & header size + chunk = ReOffset
//Records count = RecordsCount
  TotalRecords := RecordsCount;
  CFlag := 0; //AE don't have implemented LZSS compression
  Dummy := 0;
 end;

 ArchiveStream.Write(PureHeader,SizeOf(PureHeader));

// Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with PureDir do begin
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);

   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to 64 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   Offset := RFA[i].RFA_1;
   FileSize := RFA[i].RFA_2;
   CFileSize := RFA[i].RFA_2;
   FreeAndNil(FileDataStream);
// Writing file table entry...
   ArchiveStream.Write(PureDir,SizeOf(PureDir));
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