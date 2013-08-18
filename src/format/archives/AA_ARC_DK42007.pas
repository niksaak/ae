{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Dragon Knight 4 (Remake 2007) game archive format & functions
  
  Written by dsp2003. Specifications from w8m & Varg.
}

unit AA_ARC_DK42007;

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
 procedure IA_ARC_DK42007(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_DK42007 : boolean;
//  function SA_ARC_DK42007(Mode : integer) : boolean;

type
 TARCHdr = packed record
  FileCount : longword;
 end;

 TARCDir = packed record
  Filename  : array[1..256] of char; // encrypted
  CFileSize : longword; // xor $1663E1E9
  Offset    : longword; // xor $1BB6625C
 end;

implementation

uses AnimED_Archives;

procedure IA_ARC_DK42007;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Dragon Knight 4 (Remake 2007)';
  Ext  := '.arc';
  Stat := $F;
  Open := OA_ARC_DK42007;
//  Save := SA_ARC_DK42007;
  Extr := EA_LZSS_FEE_FFF;
  FLen := 256;
  SArg := 0;
  Ver  := $20110422;
 end;
end;

function OA_ARC_DK42007;
var i,j : integer;
    Hdr : TARCHdr;
    Dir : TARCDir;
    l : char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if FileCount > $7FFF then Exit;
   RecordsCount := FileCount;
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);
  
   with Dir, RFA[i] do begin
    Read(Dir,SizeOf(Dir));
    RFA_1 := Offset   xor $1BB6625C; if RFA_1 > Size then Exit;
    RFA_2 := CFileSize xor $1663E1E9; if RFA_2 > Size then Exit;
    RFA_C := RFA[i].RFA_2;
    for j := 1 to length(FileName) do begin
     l := char(byte(FileName[j]) xor $29);
     if l <> #0 then RFA_3 := RFA_3 + l else break;
    end;
   end;

  end;

  Result := True;
 end;

end;

{function SA_ARC_DK42007;
var i,j : integer;
    Dummy : array of byte;
    Hdr : TARCHdr;
    Dir : TARCDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   FileCount := RecordsCount;
   UpOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  end;

  Write(Hdr,SizeOf(Hdr));

  for i := 1 to RecordsCount do begin

{*}{Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   
   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := SizeDiv(FileDataStream.Size,2048);
   
   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_2;
  
   with Dir do begin
    Offset   := RFA[i].RFA_1 div 2048;
    FileSize := RFA[i].RFA_2 div 2048;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   end;

   // пишем кусок таблицы
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
  end;


  for i := 1 to RecordsCount do begin
{*}{Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;}

end.