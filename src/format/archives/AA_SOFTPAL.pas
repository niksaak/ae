{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  SOFTPAL \ UnisonSoft archive formats & functions

  Forget-Me-Not BIN
  Peace@Pieces \ Peace@Pieces Fandisk 059
  Chu x Chu Idol \ Chu x Chu Paradise PAC
  Flyable Heart PAC
  Chu x Chu Idol 2 PAC

  Specifications of 059 by w8m.
  Written by dsp2003.
}

unit AA_SOFTPAL;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_SOFTPAL_BIN(var ArcFormat : TArcFormats; index : integer);
  function OA_SOFTPAL_BIN : boolean;
  function SA_SOFTPAL_BIN(Mode : integer) : boolean;

 procedure IA_SOFTPAL_PAC16(var ArcFormat : TArcFormats; index : integer);
  function OA_SOFTPAL_PAC16 : boolean;
  function SA_SOFTPAL_PAC16(Mode : integer) : boolean;

 procedure IA_SOFTPAL_PAC32(var ArcFormat : TArcFormats; index : integer);
  function OA_SOFTPAL_PAC32 : boolean;
  function SA_SOFTPAL_PAC32(Mode : integer) : boolean;

 procedure IA_SOFTPAL_PAC32_2k10(var ArcFormat : TArcFormats; index : integer);
  function OA_SOFTPAL_PAC32_2k10 : boolean;
  function SA_SOFTPAL_PAC32_2k10(Mode : integer) : boolean;

 procedure IA_SOFTPAL_059(var ArcFormat : TArcFormats; index : integer);
  function OA_SOFTPAL_059 : boolean;
//  function SA_SOFTPAL_059(Mode : integer) : boolean;

type
{ Forget-Me-Not BIN archive format }
 TBINHeader = packed record
  Magic     : array[1..8] of char; // 'ACPXPK01'
  Filecount : longword;
 end;
 TBINDir = packed record
  Filename  : array[1..32] of char;
  Offset    : longword;
  Filesize  : longword;
 end;
{ SOFTPAL ADV SYSTEM PAC archive format }
 TSOFTPALHdr = packed record
  FileCount : longword; // File count
  Dummy     : array[1..258] of byte; // zeroes
  Checker   : array[1..380] of word; // probably for checking? Most contain TotalRecords value
 end;
 TSOFTPALHdr2k10 = packed record
  Magic     : array[1..4] of char; // 'PAC '
  Dummy0    : longword; // $0
  FileCount : longword; // File count
  Dummy1    : array[1..256] of byte; // $0
  Checker   : array[1..892] of word;
 end;
 TSOFTPALDir = packed record
  FileName  : array[1..16] of char; // File name
  Filesize  : longword; // File size
  Offset    : longword; // File offset
 end;
 TSOFTPALDir32 = packed record
  FileName  : array[1..32] of char; // File name
  FileSize  : longword; // File size
  Offset    : longword; // File offset
 end;
 T059Header = packed record
  Magic : array[1..5] of char; // 'VAFSH'
  Dummy : array[1..11] of byte; // Random trash, usually $32, unused
 end;

implementation

uses AnimED_Archives;

procedure IA_SOFTPAL_059;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'SOFTPAL Peace@Pieces';
  Ext  := '.059';
  Stat := $F;
  Open := OA_SOFTPAL_059;
//  Save := SA_SOFTPAL_059;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20100702;
 end;
end;

procedure IA_SOFTPAL_BIN;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'SOFTPAL Forget-Me-Not';
  Ext  := '.bin';
  Stat := $0;
  Open := OA_SOFTPAL_BIN;
  Save := SA_SOFTPAL_BIN;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20090930;
 end;
end;

procedure IA_SOFTPAL_PAC16;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'SOFTPAL ADV SYSTEM PAC-16';
  Ext  := '.pac';
  Stat := $0;
  Open := OA_SOFTPAL_PAC16;
  Save := SA_SOFTPAL_PAC16;
  Extr := EA_RAW;
  FLen := 16;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

procedure IA_SOFTPAL_PAC32;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'SOFTPAL ADV SYSTEM PAC-32';
  Ext  := '.pac';
  Stat := $0;
  Open := OA_SOFTPAL_PAC32;
  Save := SA_SOFTPAL_PAC32;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20100521;
 end;
end;

procedure IA_SOFTPAL_PAC32_2k10;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'SOFTPAL ADV SYSTEM PAC-32 2010';
  Ext  := '.pac';
  Stat := $0;
  Open := OA_SOFTPAL_PAC32_2k10;
  Save := SA_SOFTPAL_PAC32_2k10;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20110312;
 end;
end;

function OA_SOFTPAL_059;
var i : integer;
    Hdr : T059Header;
    Dir : longword;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'VAFSH' then Exit;
  end;

  Read(Dir,SizeOf(Dir)); // читаем первый оффсет. он нам понадобится для вычисления примерного количества файлов
  
  RecordsCount := (Dir - SizeOf(Hdr)) div 4;

  Seek(-4,soCurrent); // откатываемся назад

  for i := 1 to RecordsCount do begin
   Read(Dir,SizeOf(Dir));
   
   RFA[i].RFA_1 := Dir;
   RFA[i].RFA_3 := 'File_'+inttostr(i)+' ['+inttostr(Dir)+'].bin';
  
   if Dir >= ArchiveStream.Size then begin
    RecordsCount := i;
    Break;
   end;
  end;

{*}Progress_Max(RecordsCount);  
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   if RFA[i+1].RFA_1 <> 0 then RFA[i].RFA_2 := RFA[i+1].RFA_1-RFA[i].RFA_1
   else RFA[i].RFA_2 := 0;
   RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
  end;

  RecordsCount := RecordsCount - 1; //прячем eof-запись от GUI ^3^

  Result := True;
  
 end;

end;

function OA_SOFTPAL_BIN;
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

function SA_SOFTPAL_BIN;
var i,j : integer;
    Hdr : TBINHeader;
    Dir : TBINDir;
begin
 Result := False;
 
 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

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
   Write(Dir,SizeOf(Dir));
   
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

function OA_SOFTPAL_PAC16;
var i,j : integer;
    Hdr : TSOFTPALHdr;
    Dir : TSOFTPALDir;
begin
 Result := False;
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);
// Reading header...
   Read(Hdr,SizeOf(Hdr));

   j := 0;
   for i := 1 to SizeOf(Dummy) do j := j + Dummy[i];
   if j <> 0 then Exit;
   if FileCount = 0 then Exit;

   RecordsCount := FileCount;
  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    if Offset = 0 then exit;
    for j := 1 to Length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    RFA[i].RFA_1 := Offset;
   end;
  end;
 end;

 Result := True;

end;

function SA_SOFTPAL_PAC16;
var i, j : integer;
    SOFTPALHeader : TSOFTPALHdr;
    SOFTPALDir    : TSOFTPALDir;
begin
 with SOFTPALHeader do begin
//Generating header...
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(SOFTPALHeader)+SizeOf(SOFTPALDir)*RecordsCount;
  FileCount := RecordsCount;
  FillChar(Dummy,SizeOf(Dummy),0);
  FillChar(Checker,SizeOf(Checker),0);
  { Generating developer's mushrooms }
  Checker[2] := FileCount;
  for i := 1 to 189 do Checker[i*2+2] := FileCount;
 end;

 ArchiveStream.Write(SOFTPALHeader,SizeOf(SOFTPALHeader));

// Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with SOFTPALDir do begin
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2   := FileDataStream.Size;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]); // directories not supported

   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j];
   FileSize  := RFA[i].RFA_2;
   Offset    := RFA[i].RFA_1;
   FreeAndNil(FileDataStream);
// Writing file table entry...
   ArchiveStream.Write(SOFTPALDir,SizeOf(SOFTPALDir));
  end;
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function OA_SOFTPAL_PAC32;
var i,j : integer;
    Hdr : TSOFTPALHdr;
    Dir : TSOFTPALDir32;
begin
 Result := False;
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);
// Reading header...
   Read(Hdr,SizeOf(Hdr));

   j := 0;
   for i := 1 to SizeOf(Dummy) do j := j + Dummy[i];
   if j <> 0 then Exit;
   if FileCount = 0 then Exit;

   RecordsCount := FileCount;
  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    if Offset = 0 then exit;
    for j := 1 to Length(FileName) do begin
     if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    end;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    RFA[i].RFA_1 := Offset;
   end;
  end;
 end;

 Result := True;

end;

function SA_SOFTPAL_PAC32;
var i, j : integer;
    Hdr : TSOFTPALHdr;
    Dir : TSOFTPALDir32;
begin
 with Hdr do begin
//Generating header...
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  FileCount := RecordsCount;
  FillChar(Dummy,SizeOf(Dummy),0);
  FillChar(Checker,SizeOf(Checker),0);
  { Generating developer's mushrooms }
  Checker[2] := FileCount;
  for i := 1 to 189 do Checker[i*2+2] := FileCount;
 end;

 ArchiveStream.Write(Hdr,SizeOf(Hdr));

// Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2   := FileDataStream.Size;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]); // directories not supported

   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j];
   FileSize  := RFA[i].RFA_2;
   Offset    := RFA[i].RFA_1;
   FreeAndNil(FileDataStream);
// Writing file table entry...
   ArchiveStream.Write(Dir,SizeOf(Dir));
  end;
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function OA_SOFTPAL_PAC32_2k10;
var i,j : integer;
    Hdr : TSOFTPALHdr2k10;
    Dir : TSOFTPALDir32;
begin
 Result := False;
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);
// Reading header...
   Read(Hdr,SizeOf(Hdr));
   if Magic <> 'PAC ' then Exit;
   if Dummy0 <> 0 then Exit;
   j := 0;
   for i := 1 to SizeOf(Dummy1) do j := j + Dummy1[i];
   if j <> 0 then Exit;
   if FileCount = 0 then Exit;

   RecordsCount := FileCount;
  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    if Offset = 0 then exit;
    for j := 1 to Length(FileName) do begin
     if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    end;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    RFA[i].RFA_1 := Offset;
   end;
  end;
 end;

 Result := True;

end;

function SA_SOFTPAL_PAC32_2k10;
var i, j : integer;
    Hdr : TSOFTPALHdr2k10;
    Dir : TSOFTPALDir32;
begin
 with Hdr do begin
//Generating header...
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  Magic := 'PAC ';
  FileCount := RecordsCount;
  Dummy0 := 0;
  FillChar(Dummy1,SizeOf(Dummy1),0);
  FillChar(Checker,SizeOf(Checker),0);
  { Generating developer's mushrooms }
  Checker[2] := FileCount;
  for i := 1 to 445 do Checker[i*2+2] := FileCount;
 end;

 ArchiveStream.Write(Hdr,SizeOf(Hdr));

// Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2   := FileDataStream.Size;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]); // directories not supported

   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j];
   FileSize  := RFA[i].RFA_2;
   Offset    := RFA[i].RFA_1;
   FreeAndNil(FileDataStream);
// Writing file table entry...
   ArchiveStream.Write(Dir,SizeOf(Dir));
  end;
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

end.