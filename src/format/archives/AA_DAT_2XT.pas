{
  AE - VN Tools
  © 2007-2012 WinKiller Studio. Open Source.
  This software is free. Please see License for details.

  2XT - SEVEN WONDER Adventure Engine PAC2 format & functions
  
  Written by dsp2003.
}

unit AA_DAT_2XT;

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
 procedure IA_DAT_2XT(var ArcFormat : TArcFormats; index : integer);

  function OA_DAT_2XT : boolean;
  function SA_DAT_2XT(Mode : integer) : boolean;

type
 TDATHdr = packed record
  Magic     : array[1..12] of char; // 'GAMEDAT PAC2'
  FileCount : longword;
 end;
 TDatDirFN = packed record
  FileName  : array[1..32] of char;
 end;
 TDATDir = packed record
  Offset    : longword; // real offset = offset + sizeof(hdr)+sizeof(dir+dirfn)*FileCount
  FileSize  : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_DAT_2XT;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := '2XT - SEVEN WONDER Adventure Engine PAC2';
  Ext  := '.dat';
  Stat := $0;
  Open := OA_DAT_2XT;
  Save := SA_DAT_2XT;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20120321;
 end;
end;

function OA_DAT_2XT;
var i,j : integer;
    Hdr : TDATHdr;
    Dir : TDATDir;
    DirFN : TDATDirFN;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'GAMEDAT PAC2' then Exit;
   RecordsCount := FileCount;
   ReOffset := SizeOf(Hdr) + (SizeOf(DirFN) + SizeOf(Dir)) * RecordsCount;
  end;

{*}Progress_Max(RecordsCount);

// Reading file table...
  for i := 1 to RecordsCount do begin
   with DirFN,RFA[i] do begin
    Read(DirFN,SizeOf(DirFN));
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
 {*}Progress_Pos(i);
   end;
  end;

  for i := 1 to RecordsCount do begin
   with Dir,RFA[i] do begin
    Read(Dir,SizeOf(Dir));
    RFA_1 := Offset + ReOffset;
    RFA_2 := FileSize;
    RFA_C := FileSize;
 {*}Progress_Pos(i);
   end;

  end;

  Result := True;
 end;

end;

function SA_DAT_2XT;
var i,j : integer;
    Hdr : TDATHdr;
    Dir : TDATDir;
    DirFN : TDATDirFN;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'GAMEDAT PAC2';
   FileCount := RecordsCount;
   //UpOffset  := SizeOf(Hdr)+(SizeOf(DirFN)+SizeOf(Dir))*RecordsCount;
   UpOffset := 0;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   with DirFN,RFA[i] do begin
    RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

    RFA_1 := UpOffset;
    RFA_2 := FileDataStream.Size;

    FreeAndNil(FileDataStream);

    UpOffset := UpOffset + RFA_2;

    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA_3) then FileName[j] := RFA_3[j] else break;
   end;

   // пишем кусок таблицы имён
   Write(DirFN,SizeOf(DirFN));
   
  end;
  
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with Dir,RFA[i] do begin
    Offset   := RFA_1;
    Filesize := RFA_2;  
   end;
   // пишем кусок таблицы
   Write(Dir,SizeOf(Dir));
  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
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