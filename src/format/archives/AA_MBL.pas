{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  MarbleSoft (Wanko to Kurasou) MBL v1 & v2 game archive format & functions

  Written by dsp2003.
}

unit AA_MBL;

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
 procedure IA_MBL1(var ArcFormat : TArcFormats; index : integer);
 procedure IA_MBL2(var ArcFormat : TArcFormats; index : integer);

  function OA_MBL1                   : boolean;
  function OA_MBL2                   : boolean;
  function SA_MBL(MBLMode : integer) : boolean;

type
{ MBL MarbleSoft (Ivory's Wanko to Kurasou) archive format }
{ Please note: filename is always stored as UPPERCASE }
 TMBLHeader = packed record
  TotalRecords : longword; // File count
{ ----------------------- }
  FNLength     : longword; // Length of filename field (array) [for ver2 only]
{ ----------------------- }
 end;
 TMBLDir = packed record
  Filename     : array[1..256] of char; // File name (16 chars for ver1 archive and up to 255 for ver2)
  Offset       : longword; // File offset
  FileSize     : longword; // File size
 end;
 TMBLDirEnd = packed record
  Dummy        : longword; // Dummy. For ver1 only
 end;

implementation

uses AnimED_Archives;

procedure IA_MBL1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'MarbleSoft v1';
  Ext  := '.mbl';
  Stat := $0;
  Open := OA_MBL1;
  Save := SA_MBL;
  Extr := EA_RAW;
  FLen := 16;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

procedure IA_MBL2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'MarbleSoft v2';
  Ext  := '.mbl';
  Stat := $0;
  Open := OA_MBL2;
  Save := SA_MBL;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 1;
  Ver  := $20090820;
 end;
end;

function OA_MBL1;
var i         : integer;
    MBLHeader : TMBLHeader;
    MBLDir    : TMBLDir;
    MBLDirEnd : TMBLDirEnd;
begin
 Result := False;
 with ArchiveStream do begin
  with MBLHeader do begin
   Seek(0,soBeginning);

   Read(TotalRecords,4);

   if TotalRecords = 0     then Exit;
   if TotalRecords > $FFFF then Exit;

   ReOffset := 4+(24*TotalRecords)+4;
   RecordsCount := TotalRecords;

  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with MBLDir do begin
    FillChar(Filename,SizeOf(FileName),0); //cleaning the array in order to avoid garbage
    Read(FileName,16);
    { avoiding garbage again }
//    for j := 1 to 16 do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_3 := String(PChar(@FileName));
    Read(Offset,4);

    if Offset > ArchiveStream.Size      then Exit;
    if i = 1 then if Offset <> ReOffset then Exit;

    Read(Filesize,4);

    if FileSize > ArchiveStream.Size    then Exit;

    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
   end;
  end;
  with MBLDirEnd do begin
   Read(Dummy,4);
   if Dummy <> 0 then Exit;
  end;
 end;

 Result := True;

end;

function OA_MBL2;
var i         : integer;
    MBLHeader : TMBLHeader;
    MBLDir    : TMBLDir;
begin
 Result := False;
 with ArchiveStream do begin
  with MBLHeader do begin
   Seek(0,soBeginning);
// Reading header (8 bytes)...
   Read(MBLHeader,SizeOf(MBLHeader));

   if (TotalRecords = 0) or (TotalRecords > $FFFF) then Exit;
   if (FNLength     = 0) or (FNLength     > $FF  ) then Exit;

   ReOffset := 8+((8+FNLength)*TotalRecords);
   RecordsCount := TotalRecords;

  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with MBLHeader, MBLDir do begin
    FillChar(Filename,SizeOf(FileName),0); //cleaning the array in order to avoid garbage
    Read(FileName,FNLength);
    { avoiding garbage again }
//    for j := 1 to FNLength do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_3 := String(PChar(@FileName));
    Read(Offset,4);

    if Offset > ArchiveStream.Size      then Exit;
    if i = 1 then if Offset <> ReOffset then Exit;

    Read(Filesize,4);

    if FileSize > ArchiveStream.Size then Exit;

    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
   end;
  end;
 end;

 Result := True;

end;

function SA_MBL;
var i, j, k   : integer;
    MBLHeader : TMBLHeader;
    MBLDir    : TMBLDir;
    MBLDirEnd : TMBLDirEnd;
begin
 with MBLHeader do begin
//Generating header (4/8 bytes)...
//Calculating records count...
  RecordsCount := AddedFiles.Count;
  TotalRecords := RecordsCount;
// For [ver1] archives, there's no FNLength field
  FNLength := 0; k := 0;
  case MBLMode of
   0 : begin
        // [ver1] Actually, 8 means 4+4 (MBLHeader.TotalRecords + MBLDirEnd.Dummy)
        ReOffset := 8+24*RecordsCount;
        k := 16;
       end;
   1 : begin
        // [ver2] Getting the maximal filename field size
        for i := 0 to AddedFiles.Count-1 do begin
         if Length(ExtractFileName(AddedFiles.Strings[i]))+1 > FNLength then FNLength := Length(ExtractFileName(AddedFiles.Strings[i]))+1; //+1 here in order to reproduce the zero byte
        end;
        // [ver2] 8 means File count+FNLength
        ReOffset := 8+(8+FNLength)*RecordsCount;
        k := FNLength;
       end;
  end;
 end;

 case MBLMode of
  0 : begin
       // [ver1]
       ArchiveStream.Write(MBLHeader.TotalRecords,4);
      end;
  1 : begin
       // [ver2]
       ArchiveStream.Write(MBLHeader,SizeOf(MBLHeader));
      end;
 end;

// Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with MBLDir do begin
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

   for j := 1 to k do begin
    if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j]
    else FileName[j] := #0;
   end;

   Offset := RFA[i].RFA_1;
   FileSize := RFA[i].RFA_2;
   FreeAndNil(FileDataStream);
// Writing file table entry...
   with ArchiveStream, MBLDir do begin
    Write(FileName,k);
    Write(Offset,4);
    Write(FileSize,4);
   end;
  end;
 end;

 case MBLMode of
  1 : { [ver2] };
  0 : begin
       // [ver1]
       with ArchiveStream, MBLDirEnd do begin
        Dummy := 0;
        Write(MBLDirEnd,SizeOf(MBLDirEnd));
       end;
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