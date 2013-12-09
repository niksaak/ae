{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Farbrausch WZ4 PAK archive format & functions
  
  Written by dsp2003.
}

unit AA_PAK_farbrausch;

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
 procedure IA_PAK_wz4(var ArcFormat : TArcFormats; index : integer);

  function OA_PAK_wz4 : boolean;
  function SA_PAK_wz4(Mode : integer) : boolean;

type
 TPAKHdr = packed record
  Magic     : longword; // $deadbeef
  FileCount : longword;
  HdrSize   : longword; // PAKHdr+PAKDir+Names
  Dummy     : longword; // $0
 end;

 TPAKDir = packed record
  FNOffset  : longword;
  Offset    : longword;
  CFileSize : longword;
  FileSize  : longword;
  Dummy     : longword; // $0
 end;

implementation

uses AnimED_Archives;

procedure IA_PAK_wz4;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Farbrausch WZ4';
  Name := '[PAK] '+IDS;
  Ext  := '.pak';
  Stat := $F;
  Open := OA_PAK_wz4;
//  Save := SA_PAK_wz4;
  Extr := EA_RAW;
  FLen := $FFFF;
  SArg := 0;
  Ver  := $20110213;
 end;
end;

function OA_PAK_wz4;
var i,j : integer;
    Hdr : TPAKHdr;
    Dir : TPAKDir;
    tmpDir : TStream;
    FileName : array[1..$FF] of widechar;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> $deadbeef then Exit;
   if Dummy <> 0 then Exit;

   RecordsCount := FileCount;

   Seek(0,soBeginning);

   tmpDir := TMemoryStream.Create;
   tmpDir.CopyFrom(ArchiveStream,HdrSize);

   Seek(SizeOf(Hdr),soBeginning);
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := CFileSize;
    
    widestring(FileName) := '';
    tmpDir.Seek(FNOffset,soBeginning);
    
    for j := 1 to
    
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

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