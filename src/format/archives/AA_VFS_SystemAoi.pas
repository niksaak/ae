{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  SystemAoi archive format & functions
  
  Written by dsp2003. Specifications from w8m.
}

unit AA_VFS_SystemAoi;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Classes, Windows, Forms, Sysutils,
     FileStreamJ, JUtils, JReconvertor;

 { Supported archives implementation }
 procedure IA_VFS_SystemAoi_v2(var ArcFormat : TArcFormats; index : integer);

  function OA_VFS_SystemAoi_v2 : boolean;
  function SA_VFS_SystemAoi_v2(Mode : integer) : boolean;

type
 TVFSHdr = packed record
  Magic    : array[1..2] of char; // 'VF'
  Version  : word;                 // $200
  FileCount: word;                 // File count
  FTRecLen : word;                 // File table record length ( SizeOf(TVFSDir) )
  FTSize   : longword;             // FileCount * FTRecLen = Filetable size
  ArcSize  : longword;             // Archive file size
 end;

 TVFSDir = packed record
  FNOffset : longword; // Filename offset. Real value = FNOffset * 2 (Unicode)
  FAttrib  : word;     // File attributes
  FDOSDate : word;     // DOS date stamp
  FDOSTime : word;     // DOS time stamp
  Offset   : longword; // File offset
  FileSize : longword; // File size
  CFileSize: longword; // Compressed file size (unused, equal to FileSize)
  VolumeID : char;     // Archive volume identifier for multipart archives. #0 for single  
 end;

 //TVFSFNHdr = packed record
 // FNTblSize : int64; // real size = FNTblSize*2 (Unicode)
 //end;
 // Filename : array of widechar;

 TAGFLZBlock = packed record
  Opcode  : byte;
  Repeats : byte;
  Length  : word;
 end;

implementation

uses AnimED_Archives;

procedure IA_VFS_SystemAoi_v2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'SystemAoi Game System v2.00';
  Ext  := '.vfs';
  Stat := $0;
  Open := OA_VFS_SystemAoi_v2;
  Save := SA_VFS_SystemAoi_v2;
  Extr := EA_RAW;
  FLen := $7FFF;
  SArg := 0;
  Ver  := $20100816;
 end;
end;

function OA_VFS_SystemAoi_v2;
var i         : integer;
    Hdr       : TVFSHdr;
    Dir       : TVFSDir;
    FNDirSize : int64;
    FNTable   : TStream;
    FileName  : widestring;
    FNChr     : widechar;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if (Magic <> 'VF') and (Magic <> 'VL') then Exit; // archive type check
   if Version <> $200 then Exit; // version check
   RecordsCount := FileCount;
   if FTRecLen <> SizeOf(Dir) then Exit; // structure check
   if FTSize <> FTRecLen * FileCount then Exit; // integrity check
// probably too strict, so let's comment this for now
// if ArcSize <> ArchiveStream.Size then Exit; // integrity check
  end;

  Seek(SizeOf(Hdr)+SizeOf(Dir)*Hdr.FileCount,soBeginning); // skipping to filename table
  Read(FNDirSize,SizeOf(FNDirSize));
  FNDirSize := FNDirSize * 2; // cause we're dealing with unicode
  if FNDirSize > Size then Exit; // integrity check
  FNTable := TMemoryStream.Create;
  FNTable.CopyFrom(ArchiveStream,FNDirSize);
  Seek(SizeOf(Hdr),soBeginning); // returning to file table

  with RFA[0] do begin
   SetLength(RFA_T,2);
   SetLength(RFA_T[0],1); // Multivolume archive VolumeID
   SetLength(RFA_T[1],3); // DOS File Attrib Fields
   RFA_T[0][0] := 'Multipart archive Volume ID';
   RFA_T[1][0] := 'DOS File Attr';
   RFA_T[1][1] := 'DOS File Date';
   RFA_T[1][2] := 'DOS File Time';
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin

   with Dir, RFA[i] do begin

    Read(Dir,SizeOf(Dir));

    RFA_1 := Offset;
    RFA_2 := FileSize;
    RFA_C := CFileSize;

    SetLength(RFA_T,2);
    SetLength(RFA_T[0],1); // Multivolume archive VolumeID
    SetLength(RFA_T[1],3); // DOS File Attrib Fields

    RFA_T[0][0] := VolumeID;

    RFA_T[1][0] := FAttribToDesc(FAttrib);
    RFA_T[1][1] := inttohex(FDOSDate,4);
    RFA_T[1][2] := inttohex(FDOSTime,4);

    FNTable.Seek(FNOffset*2,soBeginning);

    // resetting Filename char buffer
    Filename := '';
    FNChr := #$FFFF;

    // reading filename, 2 bytes per cycle...
    while FNChr <> #$0 do begin
     FNTable.Read(FNChr,2);
     FileName := FileName + FNChr;
    end;

    RFA_3 := Wide2JIS(Filename); // assigning name to RFA table

   end;
  end;

  FreeAndNil(FNTable);

  Result := True;
 end;

end;

function SA_VFS_SystemAoi_v2;
var i         : integer;
    Hdr       : TVFSHdr;
    Dir       : TVFSDir;
    FNDirSize : int64;
    FNTable   : TStream;
    FNChr     : widechar;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFilesW.Count;

  with Hdr do begin
   Magic        := 'VF';
   Version      := $200;
   FileCount    := RecordsCount;
   FTRecLen     := SizeOf(Dir);
   FTSize       := FileCount * FTRecLen;

   // Calculating future starting offset for the file table
   // Header + (Table entry + Trailing zero word of name table) * Number of records + EOT zero word + Filename table length entry (int64)
   UpOffset     := SizeOf(Hdr) + (SizeOf(Dir) + 2) * RecordsCount + 2 + SizeOf(FNDirSize);

   for i := 1 to RecordsCount do UpOffset := UpOffset + Length(AddedFilesW.Strings[i-1])*2;

   ArcSize      := 0; // must be calculated later
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  FNChr := #$0;
  FNTable := TMemoryStream.Create;

  with Dir do begin
   // constant fields (not changed for every file)
   FAttrib  := $20;   // simulating "archive" attribute
   FDOSDate := $3CD4; // simulating file date
   FDosTime := $0D80; // simulating file time
   VolumeID := #0;    // AnimED do not support multipart archive creation

   for i := 1 to RecordsCount do begin
 {*}Progress_Pos(i);
    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);

    FNOffset := FNTable.Size div 2;
    Offset := UpOffset;
    FileSize := FileDataStream.Size;
    CFileSize:= FileSize;

    FNTable.Write(AddedFilesW.Strings[i-1][1],Length(AddedFilesW.Strings[i-1])*2);
    FNTable.Write(FNChr,2); // writing trailing zero
    if i = RecordsCount then FNTable.Write(FNChr,2); // writing finalizing zero

    UpOffset := UpOffset + FileDataStream.Size; // updating offset

    Write(Dir,SizeOf(Dir));
    
    FreeAndNil(FileDataStream);

   end;
  end;

  // writing Filenames Table
  FNDirSize := FNTable.Size;
  FNTable.Seek(0,SoBeginning);
  Write(FNDirSize,SizeOf(FNDirSize));
  CopyFrom(FNTable,FNTable.Size);

  // writing files...
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;

  // writing archive size field
  Hdr.ArcSize := ArchiveStream.Size;
  Seek(0,soBeginning);
  Write(Hdr,SizeOf(Hdr)); // updating header

 end; // with ArchiveStream

 Result := True;

end;

end.