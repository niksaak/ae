{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  IKURA GDL SM2MPX10/SM2MPX20 and Digital Romance System archive formats & functions

  SM2MPX20 contributed by Nik.

  Written by dsp2003 & Nik.
}

unit AA_IKURA_GDL;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AE_StringUtils,
     SysUtils, Classes, Windows, Forms;

type array8   = array[0..$7]  of byte;
     array256 = array[0..$FF] of byte;

 { Supported archives implementation }
 procedure IA_SM2MPX20(var ArcFormat : TArcFormats; index : integer);
 procedure IA_SM2MPX10(var ArcFormat : TArcFormats; index : integer);
 procedure IA_DRS(var ArcFormat : TArcFormats; index : integer);

  function OA_SM2MPX20 : boolean;
//  function SA_SM2MPX20(Mode : integer) : boolean;

  function OA_SM2MPX10 : boolean;
  function SA_SM2MPX10(Mode : integer) : boolean;

  function OA_DRS : boolean;
  function SA_DRS(Mode : integer) : boolean;

  function SM2MPX20_decodeLen(arr : array8) : integer;
  function SM2MPX20_decodeFileTable(Stream: TStream; Key : array256; len : integer) : boolean;

type
{ Описание структуры формата SM2MPX10/SM2MPX20 }
 TSM2MPX20Hdr = packed record
  Magic     : array[1..8] of char; // 'SM2MPX10';
  FileCount : longword;            // fake records count
  HdrSize   : longword;            // fake header size
  Magic2    : array[1..8] of char; // 'SM2MPX20';
  DirSize   : array8;              // encrypted length of real file table
 end;

 TSM2MPX10Hdr = packed record
  Magic     : array[1..8] of char;  // Просто заголовок. Всегда равен 'SM2MPX10'
  FileCount : longword;             // Кол-во файлов в архиве
  HdrSize   : longword;             // Размер заголовка (включая Dir-секции)
  LabelName : array[1..12] of char; // Имя внутренней метки
  BaseHdrSz : longword;             // Размер заголовка (32 байта, thx 2 Traneko ;) )
 end;

 TSM2MPX10Dir = packed record
  FileName  : array[1..12] of char; // Имя файла в формате DOS
  offset    : longword;             // Оффсет. Реальный оффсет в файле
  FileSize  : longword;             // Размер файла.
 end;

 TSM2MPX10HdrEnd = packed record
  Dummy     : longword;             // Пустышка. НЕ СЧИТАЕТСЯ ТОЛЬКО В РАЗМЕРЕ, УКАЗЫВАЕМОМ В ЗАГОЛОВКЕ!!!
 end;

{ Разновидность формата SM2MPX10, не имеет заголовка как такового }
 TDRSHdr = packed record
  HdrSize   : word;                 // Размер заголовка.
 end;

 TDRSDir = record
  FileName  : array[1..12] of char; // Имя файла в формате DOS
  offset    : longword;             // Число типа LONGWORD. Оффсет файла. Реальное значение.
 end;

implementation

uses AnimED_Archives;

procedure IA_SM2MPX20;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'IKURA GDL SM2MPX 2.0';
  Ext  := '';
  Stat := $F;
  Open := OA_SM2MPX20;
//  Save := SA_SM2MPX10;
  Extr := EA_RAW;
  FLen := 12;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

procedure IA_SM2MPX10;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'IKURA GDL SM2MPX 1.0';
  Ext  := '';
  Stat := $0;
  Open := OA_SM2MPX10;
  Save := SA_SM2MPX10;
  Extr := EA_RAW;
  FLen := 12;
  SArg := 0;
  Ver  := $20110403;
 end;
end;

procedure IA_DRS;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'IKURA GDL \ Digital Romance System';
  Ext  := '';
  Stat := $0;
  Open := OA_DRS;
  Save := SA_DRS;
  Extr := EA_RAW;
  FLen := 12;
  SArg := 0;
  Ver  := $20110403;
 end;
end;

function OA_SM2MPX20;
{ SM2MPX20 archive opening function }
var i,j : integer;
    Hdr : TSM2MPX20Hdr;
    Dir : TSM2MPX10Dir;
    DecodeStream : TStream;
    DecodeLength : integer;
const K : array256 = (
      $5D,$13,$DE,$A5, $08,$29,$95,$D2, $CD,$3C,$7C,$01, $D6,$99,$39,$8E,
      $24,$11,$EA,$70, $DF,$FD,$16,$61, $EA,$7F,$E3,$40, $BB,$0A,$8A,$B3,
      $6A,$24,$09,$10, $07,$6A,$18,$7E, $31,$D5,$5D,$57, $E4,$3D,$E3,$D1,
      $93,$1B,$C9,$DE, $77,$93,$37,$50, $26,$B2,$96,$41, $67,$F4,$01,$B2,
      $45,$09,$F6,$72, $62,$D8,$52,$42, $8E,$C5,$7C,$36, $98,$2F,$E0,$5E,
      $64,$3D,$9F,$A6, $3E,$DB,$84,$FB, $6E,$FF,$3B,$AF, $0D,$31,$BD,$1F,
      $17,$4A,$0F,$93, $C1,$7C,$2C,$65, $0C,$92,$40,$66, $9A,$79,$16,$7D,
      $C0,$00,$D4,$91, $DE,$DC,$E6,$A9, $EB,$EF,$38,$52, $54,$CA,$A8,$42,
      $07,$70,$BB,$3A, $CA,$5C,$8E,$31, $D2,$C6,$10,$AE, $91,$23,$6F,$76,
      $CF,$EB,$D0,$67, $FC,$9E,$43,$A4, $C5,$09,$F6,$F2, $E5,$C6,$A9,$62,
      $3E,$02,$61,$31, $28,$82,$61,$EC, $09,$E8,$56,$D7, $26,$33,$D2,$90,
      $B8,$86,$FB,$F0, $43,$2A,$85,$32, $23,$D5,$DD,$57, $67,$2D,$A7,$C8,
      $E3,$88,$6B,$3E, $81,$F6,$8B,$DF, $D8,$81,$79,$AA, $00,$B3,$26,$14,
      $A4,$59,$BE,$F3, $58,$87,$92,$9C, $2D,$DC,$56,$48, $83,$07,$8C,$BD,
      $1F,$8A,$40,$2A, $7E,$BE,$F6,$52, $68,$18,$E1,$EC, $C8,$AA,$55,$4A,
      $BA,$ED,$7F,$3A, $E6,$BD,$54,$2A, $0D,$A5,$C7,$8F, $E1,$5D,$3F,$87
      );
begin

 Result := False;
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);
   Read(Hdr,SizeOf(Hdr));

   if Magic <> 'SM2MPX10' then Exit;
   if Magic2 <> 'SM2MPX20' then Exit;

   RecordsCount := FileCount;

  end;

 // Reading fake file table...
  with Dir do begin
   Read(Dir,SizeOf(Dir));
   for j := 1 to 12 do if FileName[j] <> #0 then RFA[1].RFA_3 := RFA[1].RFA_3 + FileName[j] else break;
   RFA[1].RFA_1 := Offset;
   RFA[1].RFA_2 := FileSize;
   RFA[1].RFA_C := FileSize; // replicates filesize

   Seek(Offset+FileSize,soBeginning); // переходим на часть с шифрованными данными

   Seek(52,soCurrent); // ВРЕМЕННО: пропускаем 52 неизвестных байта

  end;

  DecodeLength := SM2MPX20_decodeLen(Hdr.DirSize); // переназначаю в переменную для более чёткой отладки

  RecordsCount := RecordsCount + DecodeLength div SizeOf(Dir); // не забываем об одном "фейковом" файле ^_~

  // decoding
  DecodeStream := TMemoryStream.Create;

  DecodeStream.CopyFrom(ArchiveStream,DecodeLength);

  DecodeStream.Seek(0,soBeginning); //перематываем поток

  SM2MPX20_decodeFileTable(DecodeStream,K,DecodeLength);

  DecodeStream.Seek(0,soBeginning); //и снова

 // Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 2 to RecordsCount do begin
{*}Progress_Pos(i);
   with Dir, DecodeStream do begin
    Read(Dir,SizeOf(Dir));
    for j := 1 to SizeOf(Filename) do if Filename[j] <> #0 then RFA[i].RFA_3:=RFA[i].RFA_3+FileName[j] else break;
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize; // replicates filesize
   end;
  end;

  FreeAndNil(DecodeStream);

 end;
 Result := True;

end;

function OA_SM2MPX10;
{ SM2MPX10 archive opening function }
var i,j : integer;
    Hdr    : TSM2MPX10Hdr;
    Dir    : TSM2MPX10Dir;
    HdrEnd : TSM2MPX10HdrEnd;
begin
 Result := False;
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);

   Read(Hdr,SizeOf(Hdr));

   if Magic <> 'SM2MPX10' then Exit;

   RecordsCount := FileCount;
   ReOffset := SizeOf(Hdr) + SizeOf(Dir)*RecordsCount;

 { дополнительные поля в нулевой записи для вывода метаданных ^_^ }
   SetLength(RFA[0].RFA_T,1);
   SetLength(RFA[0].RFA_T[0],2);
   RFA[0].RFA_T[0][0] := 'SM2MPX10 internal label';
   RFA[0].RFA_T[0][1] := LabelName;

  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    for j := 1 to SizeOf(Filename) do if Filename[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + Filename[j] else break;
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize; // replicates filesize
   end;
  end;
  Read(HdrEnd.Dummy,4);
 end;
 Result := True;

end;

function SA_SM2MPX10;
 { SM2MPX10 archive creating function }
var i, j : integer;
    Hdr    : TSM2MPX10Hdr;
    Dir    : TSM2MPX10Dir;
    HdrEnd : TSM2MPX10HdrEnd;
begin
 with Hdr do begin
  Magic := 'SM2MPX10';
  RecordsCount := AddedFilesW.Count;
  ReOffset := SizeOf(Hdr)+SizeOf(HdrEnd)+SizeOf(Dir)*RecordsCount;
  FileCount := RecordsCount;
  HdrSize := ReOffset;
  LabelName := 'AE VN TOOLS ';
  BaseHdrSz := SizeOf(Hdr); // 32
 end;

 ArchiveStream.Write(Hdr,SizeOf(Hdr));

 // формат чувствителен к порядку следования файлов
 AE_LowerCaseStringsW(AddedFilesW);
 AE_SortStringsW(AddedFilesW);
 AE_UpperCaseStringsW(AddedFilesW);
 AddedFilesSync;

// Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);
   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to 12 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;

   Offset := RFA[i].RFA_1;
   FileSize := RFA[i].RFA_2;
   FreeAndNil(FileDataStream);
// Writing file table entry...
   ArchiveStream.Write(Dir,SizeOf(Dir));
  end;
 end;
 HdrEnd.Dummy := 0;
 { Writing 4 bytes dummy here, DON'T EVER TRY TO DELETE IT! }
 ArchiveStream.Write(HdrEnd.Dummy,4);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;
 Result := True;
end;

function OA_DRS;
{ Digital Romance System archives opening function }
var i,j : integer;
    Hdr : TDRSHdr;
    Dir : TDRSDir;
begin
 Result := False;
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);
   Read(HdrSize,SizeOf(Hdr));
   RecordsCount := HdrSize div SizeOf(Dir);
   ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
// Records count = RecordsCount, including dummy
  end;
/////////// HEADER CHECK CODE ///////////
  if (RecordsCount > $FFFF) or (RecordsCount = 0) then Exit;
  Seek(SizeOf(Hdr)+(RecordsCount-1)*SizeOf(Dir),soBeginning);
  Read(Dir,SizeOf(Dir));
  if Dir.Offset <> Size then Exit;
/////////// HEADER CHECK CODE ///////////
  Seek(SizeOf(Hdr),soBeginning); //rewinding
  for i := 1 to RecordsCount do begin
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    for j := 1 to SizeOf(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_1 := Offset;
   end;
  end;
 end;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  if RFA[i+1].RFA_1 <> 0 then RFA[i].RFA_2 := RFA[i+1].RFA_1-RFA[i].RFA_1
  else RFA[i].RFA_2 := 0;
  RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
 end;
 RecordsCount := RecordsCount - 1; //hiding the eof record from GUI ^3^
 Result := True;

end;

function SA_DRS;
{ Headerless SM archive creating function }
var i, j : integer;
    Hdr : TDRSHdr;
    Dir : TDRSDir;
begin
 with ArchiveStream do begin
  RecordsCount := AddedFilesW.Count+1; // DRS has 1 extra record. EOF & filesize.
  ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;

  Hdr.HdrSize := ReOffset-SizeOf(Hdr);

  // формат чувствителен к порядку следования файлов
  AE_LowerCaseStringsW(AddedFilesW);
  AE_SortStringsW(AddedFilesW);
  AE_UpperCaseStringsW(AddedFilesW);
  AddedFilesSync;

  // Creating file table...
  RFA[1].RFA_1 := ReOffset;
  UpOffset := ReOffset;
// Writing header...
  Write(Hdr,SizeOf(Hdr));

  for i := 1 to RecordsCount-1 do begin
{*}Progress_Pos(i);
   with Dir do begin
    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);
    UpOffset       := UpOffset + FileDataStream.Size;
    RFA[i+1].RFA_1 := UpOffset; // the RecordsCount value is used, but it must NOT contain any filenames.
    RFA[i].RFA_2   := FileDataStream.Size;
    RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]);
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to 12 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
    Offset := RFA[i].RFA_1;
    FreeAndNil(FileDataStream);
   end;
// Writing file table
   Write(Dir,SizeOf(Dir));
  end;

{ EOF record fix }
  with Dir do begin
   Offset := UpOffset;
   FillChar(FileName,SizeOf(FileName),0);
   Write(Dir,SizeOf(Dir));
  end;
// Writing file...
{*}Progress_Max(RecordsCount-1);
  for i := 1 to RecordsCount-1 do begin { Don't forget about EOF record! }
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;
 end;

 Result := True;

end;

function SM2MPX20_decodeLen;
var i, dword1, dword2 : cardinal;
begin
 Result := 0; // Если 0 и останется, тогда ошибка архива

 arr[0] := arr[0] - $6B;
 arr[1] := arr[1] + $53;
 arr[2] := arr[2] + $90;
 arr[3] := arr[3] + $6C;
 arr[4] := arr[4] - $78;
 arr[5] := arr[5] + $EA;
 arr[6] := arr[6] + $8E;
 arr[7] := arr[7] + $F1;

 dword1 := 0;
 dword2 := 0;

 for i := 0 to 3 do dword1 := dword1 or (arr[i] shl (8*i));
 for i := 4 to 7 do dword2 := dword2 or (arr[i] shl (8*(i-4)));
 dword2 := dword2 - $C0;

 if (dword1 <> 0) then begin
  dword1 := dword1*20;
  if dword1 = dword2 then Result := dword2;
 end;

end;

function SM2MPX20_decodeFileTable;
var b, ind : byte;
begin
 ind := $C0;
 while len > 0 do begin
  Stream.Read(b,1);
  Stream.Position := Stream.Position - 1;
  b := b + Key[ind];
  Inc(ind);
  Dec(len);
  Stream.Write(b,1);
 end;
 Result := True;
end;

end.