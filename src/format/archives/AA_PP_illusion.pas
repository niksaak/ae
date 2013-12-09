{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  illusion PP archive format & functions

  Written by dsp2003. Specifications from w8m & Alamar.
}

unit AA_PP_illusion;

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

type
 TPPHdr = packed record
  Version   : byte; // $3 //xor $34
  FileCount : longword;   //xor $DE022C34
 end;

 TPPDir = packed record
  Filename  : array[1..260] of char;
  Filesize  : longword;
  Offset    : longword;
 end;

 TPPHdrCheck = longword; // TPPHdr + TPPDir*FileCount + TPPHdrCheck //xor $DE022C34

 TKey8dw = array[0..7]  of longword;
 TKey8w  = array[0..7]  of word;
 TKey16b = array[0..15] of byte;

 { Supported archives implementation }
 procedure IA_PP_illusion_JS3(var ArcFormat : TArcFormats; index : integer);

  function OA_PP_illusion : boolean;
  function SA_PP_illusion(Mode : integer) : boolean;
  function EA_PP_illusion(FileRecord : TRFA) : boolean;

 procedure PP_TableCrypt(iStream, oStream : TStream; Size : longword);
// procedure PP_FileCrypt_v0(iStream, oStream : TStream; Size : longword);
// procedure PP_FileCrypt_v1(iStream, oStream : TStream; Size : longword; Key : TKey8dw);
 procedure PP_FileCrypt_v3(iStream, oStream : TStream; Size : longword; Key : TKey8w);

const
// Key_AHMFull   : TKey8w  = ($717E,$0E78,$AFE7,$8FA7,$9E1F,$C5E3,$0008,$713A);
// Key_DGFull    : TKey8w  = ($2110,$8BD0,$5063,$D8F6,$7311,$A15A,$9132,$A8E9);
// Key_HakoTrial : TKey8dw = ($21107311,$8BD0A15A,$50639132,$D8F6A8E9,$F9807240,$8D6E79EC,$A12B7236,$9267B676);
// Key_HakoFull  : TKey8w  = ($CBEE,$1675,$3533,$4CE6,$2F68,$936D,$F40D,$0539);
 Key_JS3Full   : TKey8w  = ($00CA,$006E,$000D,$00B3,$009C,$0036,$001E,$00E8);
// Key_SMSweets  : TKey8w  = ($3F86,$B8D5,$4AB4,$06F4,$70F6,$078A,$2F26,$3572);

// Key_Null      : TKey8w  = ($0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000);

 Key_AllTable  : TKey16b = ($FA,$49,$7B,$1C,$F9,$4D,$83,$0A,$3A,$E3,$87,$C2,$BD,$1E,$A6,$FE);

 KeyByte = $34;
 KeyDWord = $DE022C34;

 illusion_pp_ver = $20100828;

implementation

uses AnimED_Archives;

procedure IA_PP_illusion_JS3;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'illusion PP v3 (Jinko Shoujo 3)';
  Ext  := '.pp';
  Stat := $0;
  Open := OA_PP_illusion;
  Save := SA_PP_illusion;
  Extr := EA_PP_illusion;
  FLen := 260;
  SArg := $3;
  Ver  := illusion_pp_ver;
 end;
end;

function OA_PP_illusion;
var i,j : integer;
    Hdr : TPPHdr;
    Dir : TPPDir;
    HdrCheck : TPPHdrCheck;
    CryptTable, Table : TStream;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Version xor KeyByte <> 3 then Exit; // Only JS3 archives are currently supported
   RecordsCount := FileCount xor KeyDWord;
   ReOffset := SizeOf(Hdr)+SizeOf(HdrCheck)+SizeOf(Dir)*RecordsCount;
  end;

  CryptTable := TMemoryStream.Create;
  try
   CryptTable.CopyFrom(ArchiveStream,SizeOf(Dir)*RecordsCount);
  except
   FreeAndNil(CryptTable);
   Exit;
  end; 

  Read(HdrCheck,SizeOf(HdrCheck));
  
  if HdrCheck xor KeyDWord <> ReOffset then begin
   FreeAndNil(CryptTable);
   Exit;
  end;

  CryptTable.Seek(0,soBeginning);

  Table := TMemoryStream.Create;
  PP_TableCrypt(CryptTable,Table,CryptTable.Size); // decoding

  FreeAndNil(CryptTable);
  
  Table.Seek(0,soBeginning);

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
    Table.Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    RFA[i].RFA_X := Hdr.Version xor KeyByte;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

  FreeAndNil(Table);

  Result := True;
 end;

end;

function SA_PP_illusion;
var i,j : integer;
    Hdr : TPPHdr;
    Dir : TPPDir;
    HdrCheck : TPPHdrCheck;
    Table : TStream;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Version   := $3 xor KeyByte;
   FileCount := RecordsCount xor KeyDWord;
   ReOffset  := SizeOf(Hdr)+SizeOf(HdrCheck)+SizeOf(Dir)*RecordsCount;
   UpOffset  := ReOffset;
  end;

  Write(Hdr,SizeOf(Hdr));

  Table := TMemoryStream.Create;

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);

   with Dir do begin
    FillChar(Filename,SizeOf(Filename),0);
    for j := 1 to Length(FileName) do if j <= length(AddedFiles.Strings[i-1]) then FileName[j] := AddedFiles.Strings[i-1][j] else break;
//    CopyMemory(@Filename[1],@AddedFiles.Strings[i-1][1],Length(AddedFiles.Strings[i-1]));

    Offset := UpOffset;
    FileSize := FileDataStream.Size;

    FreeAndNil(FileDataStream);

    UpOffset := UpOffset + FileDataStream.Size;
   end;

   // пишем кусок таблицы
   Table.Write(Dir,SizeOf(Dir));

  end;

  Table.Seek(0,soBeginning);

  PP_TableCrypt(Table,ArchiveStream,Table.Size); // crypting and writing file table

  HdrCheck := ReOffset xor KeyDWord;

  Write(HdrCheck,SizeOf(HdrCheck));

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   case Mode of
   $3 : PP_FileCrypt_v3(FileDataStream,ArchiveStream,FileDataStream.Size,Key_JS3Full);
   else CopyFrom(FileDataStream,FileDataStream.Size);
   end;
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;

function EA_PP_illusion;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try

  ArchiveStream.Seek(FileRecord.RFA_1,soBeginning);

  case FileRecord.RFA_X of
  $3 : PP_FileCrypt_v3(ArchiveStream,FileDataStream,FileRecord.RFA_C,Key_JS3Full);
  else FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  end;

  Result := True;
 except
 end;
end;

procedure PP_TableCrypt;
var buf : array of byte;
    table : TKey16b;
    i,p : longword;
begin
 table := Key_AllTable;

 SetLength(buf,Size);
 iStream.Read(buf[0],Size);

 for i := 0 to Size - 1 do begin
  p := i and $7;
  inc(table[p],table[8 + p]);
  buf[i] := buf[i] xor table[p];
 end;

 oStream.Write(buf[0],Size);

 SetLength(buf,0); // освобождаем память
end;

procedure PP_FileCrypt_v3;
var buf : array of word;
    KeyTable : TKey8w;
    i : longword;
begin
 KeyTable := Key;

 SetLength(buf,Size div 2);
 iStream.ReadBuffer(buf[0],Length(buf)*2);

 for i := 0 to (Size div 2) - 1 do begin
  inc(KeyTable[i and 3],KeyTable[i and 3 + 4]);
  buf[i] := buf[i] xor KeyTable[i and 3];
 end;

 oStream.WriteBuffer(buf[0],Length(buf)*2);

 SetLength(buf,0); // освобождаем память

 if Size mod 2 <> 0 then oStream.CopyFrom(iStream,1); // копируем оставшийся байт
end;

end.