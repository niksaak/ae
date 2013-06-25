{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Trouble Witches KCAP game archive format & functions

  Format specifications by Marisa-Chan.
  Written by dsp2003.
}

unit AA_PACK_TroubleWitches;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Generic_Hashes,
     Classes, Windows, Forms, Sysutils;

 { Supported archives implementation }
 procedure IA_PACK_TroubleWitches(var ArcFormat : TArcFormats; index : integer);

  function OA_PACK_TroubleWitches : boolean;
  function SA_PACK_TroubleWitches(Mode : integer) : boolean;

type
 TTWKCAPHeader = packed record
  Magic     : array[1..4] of char; // 'KCAP'
  FileCount : longword;
 end;

 TTWKCAPDir = packed record
  Filename  : array[1..64] of char; // File name with path
  FNCRC32   : longword;              // File name CRC32, excluding zero bytes
  FileCRC32 : longword;              // File CRC32
  Offset    : longword;              // Offset
  FileSize  : longword;              // File size
 end;

implementation

uses AnimED_Archives;

procedure IA_PACK_TroubleWitches;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'TroubleWitches KCAP';
  Ext  := '.pack';
  Stat := $0;
  Open := OA_PACK_TroubleWitches;
  Save := SA_PACK_TroubleWitches;
  Extr := EA_RAW;
  FLen := 64;
  SArg := 0;
  Ver  := $20091022;
 end;
end;

function OA_PACK_TroubleWitches;
var i,j : integer;
    Hdr : TTWKCAPHeader;
    Dir : TTWKCAPDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'KCAP' then Exit;
   RecordsCount := FileCount;
  end;

  SetLength(RFA[0].RFA_T,1);
  SetLength(RFA[0].RFA_T[0],2);
  RFA[0].RFA_T[0][0] := 'F.n. CRC32';
  RFA[0].RFA_T[0][1] := 'File CRC32';

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    if Offset    = 0 then Exit;
    if FileSize  = 0 then Exit;
    if FNCRC32   = 0 then Exit;
    if FileCRC32 = 0 then Exit;
    
    SetLength(RFA[i].RFA_T,1);
    SetLength(RFA[i].RFA_T[0],2);
    
    RFA[i].RFA_T[0][0] := inttohex(FNCRC32,8);
    RFA[i].RFA_T[0][1] := inttohex(FileCRC32,8);
    
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

  Result := True;
 end;

end;

function SA_PACK_TroubleWitches;
var i,j : integer;
    Hdr : TTWKCAPHeader;
    Dir : TTWKCAPDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'KCAP';
   FileCount := RecordsCount;
   UpOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := AddedFiles.Strings[i-1]; // Pathes are supported

   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;

   UpOffset := UpOffset + RFA[i].RFA_2;
  
   with Dir do begin
    FNCRC32  := CRC32String(RFA[i].RFA_3);
    FileCRC32:= CRC32(FileDataStream);
    Offset   := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   end;

   FreeAndNil(FileDataStream);

   // пишем кусок таблицы
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
  end;
  
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