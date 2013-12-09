{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Unicorn-A SZS archive format & functions
  
  Written by dsp2003.
}

unit AA_SZS_UnicornA;

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
 procedure IA_SZS_UnicornA(var ArcFormat : TArcFormats; index : integer);

  function OA_SZS_UnicornA : boolean;
  function SA_SZS_UnicornA(Mode : integer) : boolean;


type
 TSZSHdr = packed record
  Magic     : array[1..8] of char; // 'SZS100__'
  Dummy     : longword;
  FileCount : longword;
 end;
 
 TSZSDir = packed record
  Filename  : array[1..256] of char;
  Offset    : int64;
  Filesize  : int64;
 end;

implementation

uses AnimED_Archives;

procedure IA_SZS_UnicornA;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Unicorn-A SZS v1.00';
  Ext  := '.szs';
  Stat := $F;
  Open := OA_SZS_UnicornA;
  Save := SA_SZS_UnicornA;
  Extr := EA_RAW;
  FLen := 256;
  SArg := $90;
  Ver  := $20100731;
 end;
end;

function OA_SZS_UnicornA;
var i,j : integer;
    Hdr : TSZSHdr;
    Dir : TSZSDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'SZS100__' then Exit;
   if Dummy <> 0 then Exit;
   RecordsCount := FileCount;
  end;

{*}Progress_Max(RecordsCount);

// Reading file table...
  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);    

   with Dir,RFA[i] do begin
    Read(Dir,SizeOf(Dir));
    RFA_1 := Offset;
    RFA_2 := FileSize;
    RFA_C := FileSize;
    RFA_E := True;
    RFA_X := $90;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
   end;

  end;

  Result := True;
 end;

end;

function SA_SZS_UnicornA;
var i,j : integer;
    Hdr : TSZSHdr;
    Dir : TSZSDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'SZS100__';
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