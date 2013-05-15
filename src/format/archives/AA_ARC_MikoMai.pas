{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Miko Mai archive format & functions
  
  Written by dsp2003.
}

unit AA_ARC_MikoMai;

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
 procedure IA_ARC_MikoMai(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_MikoMai : boolean;
  function SA_ARC_MikoMai(Mode : integer) : boolean;

type
 TARCXHdr = packed record
  Magic     : array[1..4] of char; // 'ARCX'
  FileCount : longword;
  Version   : longword; // 0x10
  FTLength  : longword; // file table length
 end;

 TARCXDir = packed record
  Filename  : array[1..100] of char; // Shift-JIS file name
  Offset    : longword;
  CFileSize : longword; // compressed file size
  FileSize  : longword; // file size
  Unk       : array[1..7] of byte; // ?
  CompFlag  : byte;     // file compression flag
  Dummy     : int64;    // $0
 end;

implementation

uses AnimED_Archives;

procedure IA_ARC_MikoMai;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Miko Mai ARCX';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_MikoMai;
  Save := SA_ARC_MikoMai;
  Extr := EA_LZSS_FEE_FFF;
  FLen := 100;
  SArg := 0;
  Ver  := $20100818;
 end;
end;

function OA_ARC_MikoMai;
var i,j : integer;
    Hdr : TARCXHdr;
    Dir : TARCXDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'ARCX' then Exit;
   if Version <> $10 then Exit;
   RecordsCount := FileCount;
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := CFileSize;
    if FileSize <> CFileSize then RFA[i].RFA_Z := True;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

  Result := True;
 end;

end;

function SA_ARC_MikoMai;
var i   : integer;
    Hdr : TARCXHdr;
    Dir : TARCXDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic        := 'ARCX';
   FileCount    := RecordsCount;
   Version      := $10;
   FTLength     := SizeOf(Dir)*RecordsCount;
   UpOffset     := SizeOf(Hdr)+FTLength;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);

   // filling fields with zeroes
   FillChar(Dir,SizeOf(Dir),#0);

   with Dir do begin
    CopyMemory(@Filename[1],@AddedFiles.Strings[i-1][1],Length(AddedFiles.Strings[i-1]));

    Offset := UpOffset;
    Filesize := FileDataStream.Size;
    CFilesize := Filesize;

    FreeAndNil(FileDataStream);

    UpOffset := UpOffset + Filesize;
   end;

   // пишем кусок таблицы
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;

end.