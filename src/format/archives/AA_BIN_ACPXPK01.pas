{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Escude ACPXPK01 archive format & functions

  Written by dsp2003.
}

unit AA_BIN_ACPXPK01;

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
 procedure IA_BIN_ACPXPK01(var ArcFormat : TArcFormats; index : integer);

  function OA_BIN_ACPXPK01 : boolean;
  function SA_BIN_ACPXPK01(Mode : integer) : boolean;

type
 TBINHeader = packed record
  Magic     : array[1..8] of char; // 'ACPXPK01'
  FileCount : longword;
 end;
 
 TBINDir = packed record
  Filename  : array[1..32] of char;
  Offset    : longword;
  Filesize  : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_BIN_ACPXPK01;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Escu:de ACPXPK01';
  Ext  := '.bin';
  Stat := $0;
  Open := OA_BIN_ACPXPK01;
  Save := SA_BIN_ACPXPK01;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20100612;
 end;
end;

function OA_BIN_ACPXPK01;
var i,j : integer;
    Hdr : TBINHeader;
    Dir : TBINDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'ACPXPK01' then Exit;
   RecordsCount := FileCount;
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

  Result := True;
 end;

end;

function SA_BIN_ACPXPK01;
var i,j : integer;
    Hdr : TBINHeader;
    Dir : TBINDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFilesW.Count;

  with Hdr do begin
   Magic     := 'ACPXPK01';
   FileCount := RecordsCount;
   UpOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

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
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
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