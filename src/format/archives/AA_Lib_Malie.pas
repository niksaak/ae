{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Malie System (Popotan DVD) Lib game archive format & functions

  Written by dsp2003.
}

unit AA_Lib_Malie;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Classes, Windows, Forms, Sysutils;

 { Supported archives implementation }
 procedure IA_Lib_Malie(var ArcFormat : TArcFormats; index : integer);

  function OA_Lib_Malie : boolean;
  function SA_Lib_Malie(Mode : integer) : boolean;

type
 TLibHeader = packed record
  Header       : array[1..4] of char; // 'LIB'#0
  Version      : longword;             // always $00 01 00 00
  TotalRecords : longword;             // file count
  Unknown      : longword;             // Some random bytes? to-do: find out what is it. however, archives are working even if those are $0
 end;

 TLibDir = packed record
  FileName     : array[1..36] of char; // File name
  FileSize     : longword;              // File size
  Offset       : int64;                 // File offset
 end;

implementation

uses AnimED_Archives;

procedure IA_Lib_Malie;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Malie System';
  Ext  := '.lib';
  Stat := $0;
  Open := OA_Lib_Malie;
  Save := SA_Lib_Malie;
  Extr := EA_RAW;
  FLen := 36;
  SArg := 0;
  Ver  := $20101127;
 end;
end;

function OA_Lib_Malie;
var i,j : integer;
    Hdr : TLibHeader;
    Dir : TLibDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Header <> 'LIB'#0 then Exit;
   RecordsCount := TotalRecords;
  end;

// Reading file table...
{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

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

function SA_Lib_Malie;
var i,j : integer;
    Hdr : TLibHeader;
    Dir : TLibDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Header       := 'LIB'#0;
   TotalRecords := RecordsCount;
   Version      := $10000;
   Unknown      := 0;
   UpOffset     := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
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