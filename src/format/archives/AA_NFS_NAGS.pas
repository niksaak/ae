{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  NAGS NFS archive format & functions
  
  Written by dsp2003.
}

unit AA_NFS_NAGS;

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
 procedure IA_NFS_NAGS(var ArcFormat : TArcFormats; index : integer);

  function OA_NFS_NAGS : boolean;
  function SA_NFS_NAGS(Mode : integer) : boolean;

type
 TNFSHeader = packed record
  FileCount : longword;             // num of files. first byte used as xor key for filetable
 end;

 TNFSDir = packed record
  Filename : array[1..24] of char; // File name
  Offset   : longword;
  FileSize : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_NFS_NAGS;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Noname Adventure Game System';
  Ext  := '.nfs';
  Stat := $0;
  Open := OA_NFS_NAGS;
  Save := SA_NFS_NAGS;
  Extr := EA_RAW;
  FLen := 24;
  SArg := 0;
  Ver  := $20100425;
 end;
end;

function OA_NFS_NAGS;
var i,j : integer;
    Hdr : TNFSHeader;
    Dir : TNFSDir;
    Tbl : TStream;
    k : byte;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if FileCount = 0 then Exit;
   if FileCount > $FFFF then Exit;
   if SizeOf(Dir)*Filecount >= ArchiveStream.Size then Exit;
   RecordsCount := FileCount;
  end;
 end;

 k := RecordsCount and $000000FF;

 Tbl := TMemoryStream.Create;
 with Tbl do try
  CopyFrom(ArchiveStream,SizeOf(Dir)*RecordsCount);
  BlockXORDirect(Tbl,k);
  Seek(0,soBeginning);

// Reading file table...
  for i := 1 to RecordsCount do begin
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    if i = 1 then if Offset <> 0 then exit; // filetable check
    RFA[i].RFA_1 := Offset+SizeOf(Hdr)+(SizeOf(Dir)*RecordsCount);
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;
 except
  FreeAndNil(Tbl);
  Exit;
 end;

 FreeAndNil(Tbl);

 Result := True;

end;

function SA_NFS_NAGS;
var i,j : integer;
    Hdr : TNFSHeader;
    Dir : TNFSDir;
    Tbl : TStream;
    k : byte;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   FileCount := RecordsCount;
   UpOffset  := 0;
   k := RecordsCount and $000000FF;
  end;

  Write(Hdr,SizeOf(Hdr));

 end;

 Tbl := TMemoryStream.Create;

{*}Progress_Max(RecordsCount);

 with Tbl do begin

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   
   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   
   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_2;
  
   with Dir do begin
    Offset   := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   end;

   // пишем кусок таблицы
   Write(Dir,SizeOf(Dir));

  end;
  
  BlockXORDirect(Tbl,k);
  
  Seek(0,soBeginning);

 end; // with Tbl

 with ArchiveStream do begin
 
  CopyFrom(Tbl,Tbl.Size);
  
  FreeAndNil(Tbl);
 
  for i := 1 to RecordsCount do begin
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;

end.
