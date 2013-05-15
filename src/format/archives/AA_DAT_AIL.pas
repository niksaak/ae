{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  AIL DAT archive format & functions
  
  Written by dsp2003.
}

unit AA_DAT_AIL;

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
 procedure IA_DAT_AIL(var ArcFormat : TArcFormats; index : integer);

  function OA_DAT_AIL : boolean;
//function SA_DAT_AIL(Mode : integer) : boolean;

{
For reference only, cause the archive uses simple data structures.

type
 TDATHdr = packed record
  FileCount : longword;
 end;

 TDATDir = packed record
  Filesize  : longword;
 end;

 TDATEnd = packed record
  Unknown   : longword;
 end
}

implementation

uses AnimED_Archives;

procedure IA_DAT_AIL;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'AIL';
  Ext  := '.dat';
  Stat := $F;
  Open := OA_DAT_AIL;
//  Save := SA_DAT_AIL;
  Extr := EA_RAW;
  FLen := 0;
  SArg := 0;
  Ver  := $20110107;
 end;
end;

function OA_DAT_AIL;
var i,j,k,Hdr,Dir,Unk : longword;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  
  if (Hdr = 0) or (Hdr > $FFFF) then Exit;

  RecordsCount := Hdr;

  ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount+SizeOf(Unk);

  UpOffset := ReOffset;

  k := 0; // resetting the file entry counter

// Reading file table...
  for i := 1 to RecordsCount do begin
   Read(Dir,SizeOf(Dir));
   if Dir > 0 then begin
    inc(k);
    RFA[k].RFA_1 := UpOffset;
    RFA[k].RFA_2 := Dir;
    RFA[k].RFA_C := Dir;
    RFA[k].RFA_3 := 'File_'+inttohex(i,4)+'_'+inttohex(k,4)+'.png';
    UpOffset := UpOffset + Dir;
   end;
  end;

  RecordsCount := k;

  Read(Unk,SizeOf(Unk)); // just in case...

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

//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
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

  SetLength(Dummy,SizeMod(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048));

  // дописываем выравнивание
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