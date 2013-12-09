{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Kogado TScriptEngine v3.00 / v3.01 archive format & functions

  Originally written by w8m.
  Ported by Nik.
  Bugfixes by dsp2003.
}

unit AA_PAK_TScriptEngine;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     Generic_Hashes,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_PAK_TScriptEnginev3(var ArcFormat : TArcFormats; index : integer);

 function OA_PAK_TScriptEnginev3 : boolean;
 function SA_PAK_TScriptEnginev3(Mode : integer) : boolean;
 function EA_PAK_TScriptEnginev3(FileRecord : TRFA) : boolean;

 procedure TScriptEnginev3_decode(InputStream, OutputStream : TStream; Pack_size, Unpack_size : integer);
 procedure ResetLookupTable();
 procedure UpdateLookupTable();
 function GetNextWord(InputStream : TStream) : word;
 function LookByte_1(InputStream : TStream) : word;
 function LookByte_2(divresult : word) : word;
 procedure MTF(OutputStream : TStream; blocksize : longword);
 procedure BWT(OutputStream : TStream; blocksize : longword);

type
  TTScriptEngineHeader = packed record
    Magic : array[1..6] of char; // 'HyPack'
    Version : word;
    //для третьей версии - $300, есть ещё субверсия $301
    TableOffset : longword; // Смещение файловой таблицы
    FilesCount : longword; // Кол-во файлов
  end;

  TTScriptEngineTablev3 = packed record
    FileName : array[1..21] of char; // Имя файла без расширения
    Ext : array[1..3] of char; // Расширение файла
    FileOffset : longword; // Смещение относительно заголовка
    UnpackedSize : longword; // Несжатый размер
    PackedSize : longword; // Сжатый размер
    CryptFlag : byte;
    {
    0 - не пожато
    2 - блочно пожато функцией TScriptEnginev3_decode
    }
    With_CRC : byte; // 1
    crc16 : word; // нестандартный
    FileTime : _FILETIME;
  end;

  TTScriptEngine_Decode_Struct = packed record
    lt_flag : longword;
    lt_val : longword;
    lt_dval : longword;
    lt_mval : longword;
  end;

  TResetArray = array[1..257] of word;

var

    arr1 : array[0..$200] of word;
    arr2 : array[0..$101] of word;
    arr3 : array[0..$101] of word;
    mtf_arr : array[0..$FF] of byte;
    bwt_arr : array of longword;
    sign_1 : longword;
    sign_2 : longword;
    range : longword;
    range_2 : longword;
    decode_struct : TTScriptEngine_Decode_Struct;

const

  ResetArray : TResetArray = (
  $578, $280, $140, $F0, $A0, $78, $50, $40, $30, $28, $20, $18,
  $14, $14, $14, $14, $10, $10, $10, $10, $C, $C, $C, $C, $C, $C,
  $8, $8, $8, $8, $8, $8, $6, $6, $6, $6, $6, $6, $6, $6, $6, $6,
  $6, $6, $6, $6, $6, $6, $5, $5, $5, $5, $5, $5, $5, $5, $5, $5,
  $5, $5, $5, $5, $5, $5, $4, $4, $4, $4, $4, $4, $4, $4, $4, $4,
  $4, $4, $4, $4, $4, $4, $4, $4, $4, $4, $4, $4, $4, $4, $4, $4,
  $4, $4, $4, $4, $4, $4, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3,
  $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3,
  $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $3, $2, $2, $2, $2,
  $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2,
  $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2,
  $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2,
  $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2,
  $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2,
  $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2,
  $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2, $2,
  $2, $2, $2, $2, $2, $2, $2);

implementation

uses AnimED_Archives, AnimED_Main;

procedure IA_PAK_TScriptEnginev3;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'TScriptEngine Version 3';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_TScriptEnginev3;
  Save := SA_PAK_TScriptEnginev3;
  Extr := EA_PAK_TScriptEnginev3;
  SArg := 0;
  Ver  := $20131202;
 end;
end;

function OA_PAK_TScriptEnginev3;
var Header : TTScriptEngineHeader;
    Table : array of TTScriptEngineTablev3;
    i : longword;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(TTScriptEngineHeader));
 if (Header.Magic <> 'HyPack') or ((Header.Version <> $300) and (Header.Version <> $301)) then Exit;

 RecordsCount := Header.FilesCount;
 SetLength(Table,RecordsCount);
 ArchiveStream.Position := Header.TableOffset + sizeof(TTScriptEngineHeader);
 ArchiveStream.Read(Table[0],RecordsCount*sizeof(TTScriptEngineTablev3));

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with RFA[i] do begin
   // dsp2003: fix for files without extension
   RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
   if Table[i-1].Ext <> #0#0#0 then RFA_3 := RFA_3 + '.' + Table[i-1].Ext;
   RFA_1 := sizeof(TTScriptEngineHeader) + Table[i-1].FileOffset;
   RFA_2 := Table[i-1].UnpackedSize;
   RFA_C := Table[i-1].PackedSize;
   RFA_X := Table[i-1].CryptFlag;
   if RFA_X <> 0 then RFA_Z := true;
  end;
 end;
 Result := True;
end;

function SA_PAK_TScriptEnginev3;
var Header:TTScriptEngineHeader;
    Table : array of TTScriptEngineTablev3;
    DArray : array of byte;
    i : longword;
    ext : String;
    ft : TFileTimes;
    dummy : array[1..$10] of char;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 'HyPack';
 Header.Version := $300;
 Header.FilesCount := RecordsCount;

 SetLength(Table, RecordsCount);
 SetLength(DArray, RecordsCount);
 FillChar(Table[0], sizeof(Table)*RecordsCount, 0);
 FillChar(dummy[1], $10, 0);
 Upoffset := 0;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  ext := ExtractFileExt(RFA[i].RFA_3);
  while Length(ext) < 4 do ext := ext + #0;
  RFA[i].RFA_3 := ChangeFileExt(RFA[i].RFA_3, '');
  CopyMemory(@Table[i-1].FileName[1], @RFA[i].RFA_3[1], Length(RFA[i].RFA_3));
  CopyMemory(@Table[i-1].Ext[1], @ext[2], Length(ext));
  Table[i-1].FileOffset := Upoffset;
  ft := AE_GetFileTime(RFA[i].RFA_3);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table[i-1].UnpackedSize := FileDataStream.Size;
  Table[i-1].PackedSize := FileDataStream.Size;
  Table[i-1].CryptFlag := 0;
  Table[i-1].With_CRC := 1;
  Table[i-1].crc16 := Kogado_crc16(FileDataStream);
  Table[i-1].FileTime := ft[1];
  Upoffset := Upoffset + FileDataStream.Size;
  DArray[i-1] := ($10 - (Upoffset mod $10)) mod $10;
  Upoffset := Upoffset + DArray[i-1];
  FreeAndNil(FileDataStream);
 end;
 Header.TableOffset := Upoffset;

 ArchiveStream.Write(Header,sizeof(Header));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
  if DArray[i-1] <> 0 then ArchiveStream.Write(dummy[1],DArray[i-1]);
 end;
 ArchiveStream.Write(Table[0], sizeof(Table[0])*RecordsCount);
 SetLength(Table, 0);
 SetLength(DArray, 0);
 Result := True;
end;

function EA_PAK_TScriptEnginev3;
var TempoStream, TempoStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_X of
   2 : begin
        TempoStream := TMemoryStream.Create;
        TempoStream2 := TMemoryStream.Create;
        TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
        TempoStream.Position := 0;
        TScriptEnginev3_decode(TempoStream, TempoStream2, FileRecord.RFA_C, FileRecord.RFA_2);
        FreeAndNil(TempoStream);
        TempoStream2.Position := 0;
        FileDataStream.CopyFrom(TempoStream2,FileRecord.RFA_2);
        FreeAndNil(TempoStream2);
       end; 
   0 : FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  end;
  Result := True;
 except
 end;
end;

procedure TScriptEnginev3_decode;
var input_begin, input_current : longword;
    p : Pointer;
    packed_block, unpacked_block, unpacked_block_temp, next_word : word;
    b : byte;
Label gen1, err_exit;
begin
  OutputStream.Size := Unpack_size;
  input_begin := InputStream.Position;
  input_current := 0;
  arr1[$200] := $100; // последний, $201-й элемент
  p := @mtf_arr[0];
  // Заполняем mtf_arr байтами от 0 до FF
  asm
      push  edi
      push  eax
      mov   edi, p
	    mov   eax, 3020100h
gen1: stosd
      add   eax, 4040404h
      jnc   gen1
      pop eax
      pop edi
  end;
  // -------------------------------------
  SetLength(bwt_arr,$10000);
  ResetLookupTable();
  while Pack_size > 0 do
  begin
    InputStream.Position := input_begin + input_current;
    Dec(Pack_size, 4);
    if Pack_size < 0 then GoTo err_exit;
    InputStream.Read(packed_block, 2);
    InputStream.Read(unpacked_block, 2);
    input_current := input_current + packed_block;
    if (unpacked_block = 0) or (packed_block <= 6) then GoTo err_exit;
    packed_block := packed_block - 4;
    Unpack_size := Unpack_size - unpacked_block;
    if Unpack_size < 0 then GoTo err_exit;
    Inc(unpacked_block, 2);
    Pack_size := Pack_size - packed_block;
    if Pack_size < 0 then GoTo err_exit;
    if packed_block = unpacked_block then
    begin
      OutputStream.CopyFrom(InputStream, packed_block);
      ResetLookupTable();
    end
    else
    begin
      InputStream.Seek(1, soCurrent);
      InputStream.Read(b, 1);
      sign_1 := b;
      sign_2 := sign_1 shr 1;
      range := $80;
      unpacked_block_temp := unpacked_block;
      
      while unpacked_block_temp > 0 do
      begin
        next_word := GetNextWord(InputStream);
        if next_word = $100 then GoTo err_exit;
        OutputStream.Write(next_word, 1);
        Dec(unpacked_block_temp);
      end;
      next_word := GetNextWord(InputStream);
      if next_word <> $100 then GoTo err_exit;
    end;
    OutputStream.Position := OutputStream.Position - unpacked_block;
    MTF(OutputStream, unpacked_block);
    OutputStream.Position := OutputStream.Position - unpacked_block;
    BWT(OutputStream, unpacked_block);
  end;
err_exit:  SetLength(bwt_arr, 0);
end;

procedure ResetLookupTable;
begin
  decode_struct.lt_val := $12;
  decode_struct.lt_flag := 0;
  CopyMemory(@arr2[0],@ResetArray[1], $202);
  UpdateLookupTable();
end;

procedure UpdateLookupTable;
var temp2, edi_2, temp3 : longword;
    temp_cnt : integer;
begin
  if decode_struct.lt_flag <> 0 then
  begin
    Inc(decode_struct.lt_dval);
    decode_struct.lt_mval := decode_struct.lt_flag;
    decode_struct.lt_flag := 0;
    Exit;
  end;
  if decode_struct.lt_val < $7d0 then
  begin
    decode_struct.lt_val := decode_struct.lt_val shl 1;
    if decode_struct.lt_val > $7d0 then decode_struct.lt_val := $7d0;
  end;
  temp_cnt := $100;
  temp2 := $1000;
  arr3[temp_cnt+1] := word(temp2);
  edi_2 := temp2;
  while temp_cnt >= 0 do
  begin
    temp3 := arr2[temp_cnt];
    temp2 := temp2 - temp3;
    temp3 := (temp3 shr 1) or 1;
    arr3[temp_cnt] := word(temp2);
    arr2[temp_cnt] := word(temp3);
    edi_2 := edi_2 - temp3;
    Dec(temp_cnt);
  end;
  // если temp2 <> 0 - косяк
  if temp2 <> 0 then
  begin
   Exit;
  end;
  decode_struct.lt_dval := edi_2 div decode_struct.lt_val;
  decode_struct.lt_flag := edi_2 mod decode_struct.lt_val;
  decode_struct.lt_mval := decode_struct.lt_val - decode_struct.lt_flag;
  //--------------------------------------------------------------------
  temp_cnt := $100;
  while temp_cnt >= 0 do
  begin
    temp2 := arr3[temp_cnt] shr 3;
    temp3 := (arr3[temp_cnt+1] - 1) shr 3;
    while temp2 <= temp3 do
    begin
      arr1[temp2] := word(temp_cnt);
      Inc(temp2);
    end;
    Dec(temp_cnt);
  end;
end;

function GetNextWord;
var look1, tmp1, tmp2 : word;
    mulres : longword;
begin
  look1 := LookByte_1(InputStream);
  look1 := LookByte_2(look1);
  tmp1 := arr3[look1];
  tmp2 := arr3[look1+1];
  mulres := range_2 * tmp1;
  sign_2 := sign_2 - mulres;
  if tmp2 < $1000 then
  begin
    tmp2 := tmp2 - tmp1;
    range := range_2 * tmp2;
  end
  else
  begin
    range := range - mulres;
  end;
  Result := look1;
  if look1 <> $100 then
  begin
    if decode_struct.lt_mval = 0 then UpdateLookupTable();
    Dec(decode_struct.lt_mval);
    arr2[look1] := arr2[look1] + word(decode_struct.lt_dval);
  end;
end;

function LookByte_1;
var range_tmp : longword;
    sign_tmp : longword;
    b : byte;
begin
  Result := 0;
  if range = 0 then Exit;
  range_tmp := range;
  sign_tmp := sign_2;
  while range_tmp <= $800000 do
  begin
    sign_tmp := (sign_tmp shl 8) or ((sign_1 shl 7) and $FF);
    if InputStream.Position >= InputStream.Size then Exit;
    InputStream.Read(b,1);
    sign_1 := b;
    sign_tmp := sign_tmp + (b shr 1);
    range_tmp := range_tmp shl 8;
  end;
  sign_2 := sign_tmp;
  range := range_tmp;
  range_2 := range_tmp shr $C;
  Result := sign_tmp div range_2;
  if Result >= $1000 then Result := $FFF;
end;

function LookByte_2;
var tmp, tmp2, tmp3 : longword;
begin
  tmp2 := divresult shr 3;
  tmp := arr1[tmp2];
  tmp2 := arr1[tmp2+1] + 1;

  tmp3 := tmp + 1;
  while tmp3 < tmp2 do
  begin
    tmp3 := (tmp + tmp2) shr 1;
    if divresult >= arr3[tmp3] then
      tmp := tmp3
    else
      tmp2 := tmp3;
    tmp3 := tmp + 1;
  end;
  Result := word(tmp);
end;

procedure MTF;
var b, b2, b3 : byte;
begin
  while blocksize > 0 do
  begin
    OutputStream.Read(b,1);
    b2 := mtf_arr[b];
    while b > 0 do
    begin
      b3 := mtf_arr[b-1];
      mtf_arr[b] := b3;
      Dec(b);
    end;
    mtf_arr[0] := b2;
    OutputStream.Seek(-1, soCurrent);
    OutputStream.Write(b2,1);
    Dec(blocksize);
  end;
end;

procedure BWT;
var tmparr : array of longword;
    tmpblocksize, tmppos, tmp, tmp2 : longword;
    bindex : word;
    i : integer;
    b : byte;
begin
  Dec(blocksize,2);
  tmpblocksize := blocksize;
  OutputStream.Seek(2, soCurrent);
  tmppos := OutputStream.Position;
  SetLength(tmparr, $100);
  FillChar(tmparr[0],$400,0);
  while blocksize <> 0 do
  begin
    OutputStream.Read(b,1);
    Inc(tmparr[b]);
    Dec(blocksize);
  end;
  tmp := 0;
  for i := 0 to $FF do
  begin
    tmp := tmp + tmparr[i];
    tmparr[i] := tmp;
  end;
  i := tmpblocksize - 1;
  while i >= 0 do
  begin
    OutputStream.Position := tmppos+i;
    OutputStream.Read(b,1);
    Dec(tmparr[b]);
    tmp := tmparr[b];
    tmp2 := (i shl 8) + longword(b);
    bwt_arr[tmp] := tmp2;
    Dec(i);
  end;
  SetLength(tmparr, 0);
  OutputStream.Position := tmppos-2;
  OutputStream.Read(bindex,2);
  OutputStream.Seek(-2, soCurrent);
  for i := 1 to tmpblocksize do
  begin
    tmp := bwt_arr[bindex];
    OutputStream.Write(tmp,1);
    bindex := tmp shr 8;
  end;
end;

end.