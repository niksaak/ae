{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  elf's archive formats & functions
  
  * Words Worth XP EAC & AWF
  * AI6 ARC
  
  Written by dsp2003. AI6 specifications from w8m.
}

unit AA_elf;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Generic_LZXX,
     Classes, Windows, Forms, Sysutils,
     FileStreamJ, JUtils, JReconvertor;

type
 T256name = array[1..256] of char;

{TElfGenericHeader = packed record
  FileCount : longword;
 end;}

 TEACDir = packed record
  FileName : array[1..16] of char; // File name
  FileSize : longword;
  Offset   : longword;
 end;

 TAWFDir = packed record
  FileName  : array[1..32] of char; // File name
  Offset    : longword;
  FileSize  : longword;
  LoopStart : longword; // $FFFFFFFF - no loop
  LoopEnd   : longword;
  Dummy     : longword;
 end;

 TARCDir = packed record
  FileName  : T256Name; // Encrypted filename
  Dummy     : longword; // Taken from filename for easier detection
  CFileSize : longword; // big-endian
  FileSize  : longword; // big-endian
  Offset    : longword; // big-endian
 end;

 { Supported archives implementation }
 procedure IA_EAC_elf(var ArcFormat : TArcFormats; index : integer);
 procedure IA_AWF_elf(var ArcFormat : TArcFormats; index : integer);
 procedure IA_ARC_AI6(var ArcFormat : TArcFormats; index : integer);

  function OA_EAC_elf : boolean;
  function SA_EAC_elf(Mode : integer) : boolean;
  function OA_AWF_elf : boolean;
  function SA_AWF_elf(Mode : integer) : boolean;
  function OA_ARC_AI6 : boolean;
  function SA_ARC_AI6(Mode : integer) : boolean;

  function AI6_FNCodec(Input : T256Name; Mode : longword) : T256Name;

implementation

uses AnimED_Archives;

procedure IA_EAC_elf;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Elf';
  Ext  := '.eac';
  Stat := $0;
  Open := OA_EAC_elf;
  Save := SA_EAC_elf;
  Extr := EA_RAW;
  FLen := 16;
  SArg := 0;
  Ver  := $20100324;
 end;
end;

procedure IA_AWF_elf;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Elf Wave Files';
  Ext  := '.awf';
  Stat := $1;
  Open := OA_AWF_elf;
  Save := SA_AWF_elf;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20100324;
 end;
end;

procedure IA_ARC_AI6;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Elf AI6';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_AI6;
  Save := SA_ARC_AI6;
  Extr := EA_LZSS_FEE_FFF;
  FLen := $FF;
  SArg := 0;
  Ver  := $20110227;
 end;
end;

function OA_EAC_elf;
var i,j : integer;
    Hdr : longword;
    Dir : TEacDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  if Hdr = 0 then Exit;
  if Hdr > $FFFF then Exit;
  RecordsCount := Hdr;

  // Reading file table...
  for i := 1 to RecordsCount do begin
   with Dir do begin
    Read(Dir,SizeOf(Dir));

    if Offset = 0 then Exit;
    if FileSize > ArchiveStream.Size then Exit;

    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

  Result := True;

 end;

end;

function SA_EAC_elf;
var i,j : integer;
    Hdr : longword;
    Dir : TEACDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  Hdr := RecordsCount;
  UpOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  
  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);

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

function OA_AWF_elf;
var i,j : integer;
    Hdr : longword;
    Dir : TAWFDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  if Hdr = 0 then Exit;
  if Hdr > $FFFF then Exit;
  RecordsCount := Hdr;

  // initialising additonal fields
  SetLength(RFA[0].RFA_T,1);
  SetLength(RFA[0].RFA_T[0],2);
  RFA[0].RFA_T[0][0] := 'Loop Start';
  RFA[0].RFA_T[0][1] := 'Loop End__';

  // Reading file table...
  for i := 1 to RecordsCount do begin

   SetLength(RFA[i].RFA_T,1);
   SetLength(RFA[i].RFA_T[0],2);

   with Dir do begin
    Read(Dir,SizeOf(Dir));

    if Offset = 0 then Exit;
    if Dummy > 0 then Exit;
    if FileSize > ArchiveStream.Size then Exit;

    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;

    RFA[i].RFA_T[0][0] := inttostr(LoopStart);
    RFA[i].RFA_T[0][1] := inttostr(LoopEnd);

    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

  Result := True;

 end;

end;

function SA_AWF_elf;
var i,j : integer;
    Hdr : longword;
    Dir : TAWFDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  Hdr := RecordsCount;
  UpOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);

   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   
   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   
   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_2;
  
   with Dir do begin
    Offset    := RFA[i].RFA_1;
    FileSize  := RFA[i].RFA_2;
    LoopStart := $FFFFFFFF; // extra fields not supported yet T_T'
    LoopEnd   := 0;         // extra fields not supported yet =_='
    Dummy     := 0;
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

function OA_ARC_AI6;
var i : integer;
    Hdr : longword;
    Dir : TARCDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  if Hdr > $FFFF then Exit;

  RecordsCount := Hdr;

// Reading file table...
  for i := 1 to RecordsCount do begin
   with Dir, RFA[i] do begin        // Проверки на структуру
    Read(Dir,SizeOf(Dir));          if Dummy <> 0 then Exit;
    RFA_1 := EndianSwap(Offset);    if RFA_1 > ArchiveStream.Size then Exit; if RFA_1 = 0 then Exit;
    RFA_2 := EndianSwap(FileSize);
    RFA_C := EndianSwap(CFileSize); if RFA_C > ArchiveStream.Size then Exit;
    if RFA_2 <> RFA_C then RFA_Z := True; // Проверка на сжатый файл
    FileName := AI6_FNCodec(FileName,0);
    RFA_3 := string(FileName);
//  for j := 1 to SizeOf(FileName) do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
   end;
  end;

  Result := True;
 end;

end;

function SA_ARC_AI6;
var i,j : integer;
    Hdr : longword;
    Dir : TARCDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;
  Hdr := RecordsCount;
  UpOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   with RFA[i] do begin
    RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
    RFA_1 := UpOffset;
    RFA_2 := FileDataStream.Size;
    RFA_C := RFA_2;
    FreeAndNil(FileDataStream);
    UpOffset := UpOffset + RFA_2;
    with Dir do begin
     Offset   := EndianSwap(RFA_1);
     FileSize := EndianSwap(RFA_2);
     CFileSize := FileSize;
     FillChar(FileName,SizeOf(FileName),0);
     for j := 1 to Length(FileName) do if j <= length(RFA_3) then FileName[j] := RFA_3[j] else break;
     Filename := AI6_FNCodec(FileName,1);
    end;
    // пишем кусок таблицы
    ArchiveStream.Write(Dir,SizeOf(Dir));
   end;
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

function AI6_FNCodec;
var i,j : longword;
begin
 j := 1;
 for i := 1 to 256 do begin
  if Input[i] = #0 then break;
  inc(j);
 end;
 for i := 1 to j-1 do begin
  case Mode of
  0 : Input[i] := char(byte(Input[i]) - j); // Decryption
  1 : Input[i] := char(byte(Input[i]) + j); // Encryption
  end;
  dec(j);
 end;
 Result := Input;
end;

end.