{
  AE - VN Tools
¬© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  DX3 game archive format & functions
  
  Written by dsp2003.
}

unit AA_DX3;

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
 procedure IA_DX3(var ArcFormat : TArcFormats; index : integer);

  function OA_DX3 : boolean;
  function SA_DX3(Mode : integer) : boolean;

type
 TDXHdr = packed record
  Magic      : array[1..2] of char; // 'DX'
  Version    : word; // $3
  TableSize  : longword; // Full size of FAT
  HdrSize    : longword; // $18
  FTOffset   : longword; // FileCount = (TreeOffset - DirOffset) div $2C;
  DirOffset  : longword; // 
  TreeOffset : longword; // 
 end;

 TDXDir = packed record
  FNOffset   : longword;
  FAttrib    : longword; // $10 - directory
  FTime0     : int64;
  FTime1     : int64;
  FTime2     : int64;
  Offset     : longword;
  FileSize   : longword;
  PackFlag   : longword; // -1 - raw
 end;
 
 TDXTree = packed record
  LOffset    : longword; // list offset
  POffset    : longword; // parent offset, -1 - root
  FileCount  : longword; // files in directory
  CLOffset   : longword; // child list offset
 end;

implementation

uses AnimED_Archives;

procedure IA_IMG_GTA3v2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'RockStar GTA San Andreas';
  Ext  := '.img';
  Stat := $0;
  Open := OA_IMG_GTA3v2;
  Save := SA_IMG_GTA3v2;
  Extr := EA_RAW;
  FLen := 24;
  SArg := 0;
  Ver  := $20100731;
 end;
end;

function OA_IMG_GTA3v1;
{ GTA III/VC IMG archive opening function }
var i,j : integer;
    Dir : TIMGDir;
    DIRStream, tmpStream : TStream;
const IMG_Ext : array [1..2] of string = ('.img','.dir');
begin
 Result := False;

 for i := 1 to Length(IMG_Ext) do if not FileExists(ChangeFileExt(ArchiveFileName,IMG_Ext[i])) then Exit;

 // финт ушами. закрываем неправильный файл и открываем .img вне зависимости от того, какой был открыт в данный момент
 if lowercase(ExtractFileExt(ArchiveFileName)) <> IMG_Ext[1] then begin
  FreeAndNil(ArchiveStream);
  ArchiveFileName := ChangeFileExt(ArchiveFileName,IMG_Ext[1]);
  OpenFileStream(ArchiveStream,ArchiveFileName,fmOpenRead);
 end;

 OpenFileStream(tmpStream,ChangeFileExt(ArchiveFileName,IMG_Ext[2]),fmOpenRead);
 DIRStream := TMemoryStream.Create;
 DIRStream.CopyFrom(tmpStream,tmpStream.Size);
 DIRStream.Seek(0,soBeginning);
 FreeAndNil(tmpStream);

 with DIRStream do begin
  if (Size mod SizeOf(Dir)) <> 0 then Exit;
// Reading file table...
  i := 0; // filecount to 0
  while Position < Size do begin
   inc(i); // filecount increasing
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset   * 2048;
    RFA[i].RFA_2 := FileSize * 2048;
    RFA[i].RFA_C := FileSize * 2048;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;
  RecordsCount := i; // filecount

  FreeAndNil(DIRStream);
 end;

 Result := True;

end;

function OA_IMG_GTA3v2;
var i,j : integer;
    Hdr : TIMGHdr;
    Dir : TIMGDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'VER2' then Exit;
   RecordsCount := FileCount;
  end;

{*}Progress_Max(RecordsCount);

// Reading file table...
  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);    

   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset   * 2048;
    RFA[i].RFA_2 := FileSize * 2048;
    RFA[i].RFA_C := FileSize * 2048;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;

  end;

  Result := True;
 end;

end;

function SA_IMG_GTA3v1;
var i,j : integer;
    Dummy : array of byte;
    Dir : TIMGDir;
    dirStream : TStream;
begin
 Result := False;

 dirStream := TFileStreamJ.Create(ChangeFileExt(ArchiveFileName,'.dir'),fmCreate);

 RecordsCount := AddedFiles.Count;
 UpOffset := 0;

{*}Progress_Max(RecordsCount);

 for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

  RFA[i].RFA_1 := UpOffset;
  RFA[i].RFA_2 := SizeDiv(FileDataStream.Size,2048);

  UpOffset := UpOffset + RFA[i].RFA_2;

  with Dir do begin
   Offset   := RFA[i].RFA_1 div 2048;
   FileSize := RFA[i].RFA_2 div 2048;
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
  end;

  // пишем кусок таблицы
  dirStream.Write(Dir,SizeOf(Dir));
  with ArchiveStream do begin
  // пишем файл в архив
   CopyFrom(FileDataStream,FileDataStream.Size);
  // пишем массив-пустышку
   SetLength(Dummy,SizeMod(FileDataStream.Size,2048));
   Write(Dummy[0],Length(Dummy));
  end;
  // высвобождаем поток файла
  FreeAndNil(FileDataStream);
 end;
 // высвобождаем поток файла заголовка
 FreeAndNil(dirStream);

 Result := True;

end;

function SA_IMG_GTA3v2;
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

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

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

  // дописываем выравнивание
  SetLength(Dummy,SizeMod(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048));
  Write(Dummy[0],Length(Dummy));

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
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

end;

end.