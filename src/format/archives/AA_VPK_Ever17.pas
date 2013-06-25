{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Ever17 Xbox 360 DYNAPACK archive format & functions

  Written by dsp2003.
}

unit AA_VPK_Ever17;

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
 procedure IA_VPK_Ever17(var ArcFormat : TArcFormats; index : integer);

  function OA_VPK_Ever17 : boolean;
//  function SA_VPK_Ever17(Mode : integer) : boolean;

type
 TVPKHdr = packed record
  Magic : array[1..8] of char; // 'DYNAPACK'
  Filecount : longword; // $6
 end;

 TVPKDir = packed record
  Filesize : longword;
  FileName : array[1..255] of char;
 end;

 { Notice: Filename consist absolute path and some garbage. Must discard/recreate.

   C:\Users\izutsu_sana\Desktop\VPK0926_FIX\ }

implementation

uses AnimED_Archives;

procedure IA_VPK_Ever17;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Ever17 Xbox 360 DYNAPACK';
  Ext  := '.vpk';
  Stat := $F;
  Open := OA_VPK_Ever17;
//  Save := SA_VPK_Ever17;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20120121;
 end;
end;

function OA_VPK_Ever17;
var j : integer;
    Hdr : TVPKHdr;
    Dir : TVPKDir;
const VPKPath = 'C:\Users\izutsu_sana\Desktop\VPK0926_FIX\';
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'DYNAPACK' then Exit;
  end;

  RecordsCount := 0;

  while Position < Size do begin
   inc(RecordsCount);
   Read(Dir,SizeOf(Dir));
   with Dir,RFA[RecordsCount] do begin
    if FileSize+Position > Size then Exit;
    RFA_1 := Position;
    RFA_2 := FileSize;
    RFA_C := FileSize;
    for j := length(VPKPath)+1 to length(FileName) do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
    Seek(FileSize,soCurrent);
   end;
  end;

  if Hdr.FileCount <> RecordsCount then LogW('Number of files in header ('+inttostr(Hdr.FileCount)+') and the actual number of detected files ('+inttostr(RecordsCount)+') doesn''t match.');

  Result := True;
 end;

end;

{function SA_IMG_GTA3v2;
var i,j : integer;
    Dummy : array of byte;
    Hdr : TIMGHdr;
    Dir : TIMGDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'VER2';
   FileCount := RecordsCount;
   UpOffset  := SizeDiv(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048);
  end;

  Write(Hdr,SizeOf(Hdr));

{*}{Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}{Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   with Dir,RFA[i] do begin
    RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

    RFA_1 := UpOffset;
    RFA_2 := SizeDiv(FileDataStream.Size,2048);

    FreeAndNil(FileDataStream);

    UpOffset := UpOffset + RFA_2;

    Offset   := RFA_1 div 2048;
    FileSize := RFA_2 div 2048;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA_3) then FileName[j] := RFA_3[j] else break;
   end;

   // пишем кусок таблицы
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
  end;

  // дописываем выравнивание
  SetLength(Dummy,SizeMod(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048));
  Write(Dummy[0],Length(Dummy));

  for i := 1 to RecordsCount do begin
{*}{Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // пишем массив-пустышку
   SetLength(Dummy,SizeMod(FileDataStream.Size,2048));
   Write(Dummy[0],Length(Dummy));
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;}

end.