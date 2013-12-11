{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  F&C Overture Engine archive format & functions
  
  Written by dsp2003 & w8m.
}

unit AA_MRG_Overture;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     AE_DataConv,
     Generic_LZXX,
     Classes, Windows, Forms, Sysutils,
     FileStreamJ, JUtils, JReconvertor;

type

 TMRGHdr = packed record
  Magic     : array[1..4] of char; // 'MRG'#0
  VerMajor  : word; // 1
  VerMinor  : word; // 2
  HdrSize   : longword; // (FileCount + 1) * $57 + $10
  FileCount : longword;
 end;

 TMRGDir = packed record
  Filename  : array[1..64] of char; // Filename
  Check     : byte; // 0
  Filesize  : longword; // Uncompressed
  CFlags    : word; // 0 - encrypted, 1 - lzss, 2 - arcoder, 3 - arcoder + lzss
  FileTime  : int64;
  Offset    : longword;
  Dummy     : longword;
 end;

 T256Array = array[0..$FF] of byte;

 { Supported archives implementation }
 procedure IA_MRG_Overture(var ArcFormat : TArcFormats; index : integer);

  function OA_MRG_Overture : boolean;
//  function SA_MRG_Overture(Mode : integer) : boolean;
  function EA_MRG_Overture(FileRecord : TRFA) : boolean;

  function Overture_Hash(Filename : string) : longword;
  function Overture_CodeTable(k0, k1 : longword) : T256Array;
  function Overture_ArDecoder(iStream, oStream : TStream; iPos, oPos : int64) : boolean;
 procedure Overture_HashCodec(iStream, oStream : TStream; iPos, iSize, oPos, oSize : int64; Hash1, Hash2 : longword);

implementation

uses AnimED_Archives;

procedure IA_MRG_Overture;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'F&C Advanced System "Overture"';
  Ext  := '.mrg';
  Stat := $F;
  Open := OA_MRG_Overture;
//  Save := SA_MRG_Overture;
  Extr := EA_MRG_Overture;
  FLen := 64;
  SArg := 0;
  Ver  := $20110617;
 end;
end;

function OA_MRG_Overture;
const TableHash = $285EE76F;
var i,j : integer;
    Hdr : TMRGHdr;
    Dir : TMRGDir;
    Tbl : TStream;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'MRG'#0 then Exit;
   if VerMajor <> 1 then Exit;
   if VerMinor <> 2 then Exit;
   RecordsCount := FileCount;
  end;

{*}Progress_Max(RecordsCount);

  Tbl := TMemoryStream.Create;

  Overture_HashCodec(ArchiveStream,Tbl,Position,Hdr.HdrSize-SizeOf(Hdr),0,0,TableHash,Overture_Hash(ExtractFileName(ArchiveFileName)));

  Tbl.Seek(0,soBeginning);

// Читаем файловую таблицу, включая EOF-запись
  for i := 1 to RecordsCount+1 do begin

{*}Progress_Pos(i);

   with RFA[i], Dir do begin
    Tbl.Read(Dir,SizeOf(Dir));
    RFA_X := CFlags;
    case CFlags of
     0 : RFA_E := True;
    else RFA_Z := True;
    end;
    RFA_1 := Offset;
    RFA_2 := FileSize;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;

   end;

  end;

  // Заполняем сжатые размеры файлов
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   if RFA[i+1].RFA_1 <> 0 then RFA[i].RFA_C := RFA[i+1].RFA_1-RFA[i].RFA_1
   else RFA[i].RFA_C := 0;
  end;

  Result := True;
 end;

end;

{function SA_MRG_Overture;
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

{*}{Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}{Progress_Pos(i);

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
{*}{Progress_Pos(i);
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

end;}

function EA_MRG_Overture;
var tmpStream,tmpStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try

  with FileRecord do begin

   ArchiveStream.Seek(RFA_1,soBeginning);

   if RFA_X <= $3 then begin

    tmpStream := TMemoryStream.Create;

    case RFA_X of
    $0 : Overture_HashCodec(ArchiveStream,tmpStream,RFA_1,RFA_C,0,0,Overture_Hash(ExtractFileName(ArchiveFileName)),Overture_Hash(RFA_3));
    $1 : GLZSSDecode_Overture(ArchiveStream,tmpStream,RFA_C,$FEE,$FFF);
    $2 : Overture_ArDecoder(ArchiveStream,tmpStream,RFA_1,0);
    $3 : begin
          tmpStream2 := TMemoryStream.Create;
          Overture_ArDecoder(ArchiveStream,tmpStream2,RFA_1,0);
          tmpStream2.Seek(0,soBeginning);
          GLZSSDecode_Overture(tmpStream2,tmpStream,tmpStream2.Size,$FEE,$FFF);
          FreeAndNil(tmpStream2);
         end;
    end;

    tmpStream.Seek(0,soBeginning);
    FileDataStream.CopyFrom(tmpStream,tmpStream.Size);
    FreeAndNil(tmpStream);

   end;

  end;

  Result := True;
 except
 end;
end;

function Overture_Hash(Filename : string) : longword;
var i : longword; a : byte;
begin
 Result := 0;
 for i := 1 to Length(Filename) do begin
  a := byte(Filename[i]);
  if (a >= $61) and (a <= $7a) then a := a - $20;
  if i = 1 then Result := a;
  if (a <> $2e) then Result := Result * $41 + a;
 end;
end;

procedure Overture_HashCodec(iStream, oStream : TStream; iPos, iSize, oPos, oSize : int64; Hash1, Hash2 : longword);
var Key : T256Array;
    kStream : TStream;
begin
 kStream := TMemoryStream.Create;
 Key := Overture_CodeTable(Hash1,Hash2);
 kStream.Write(Key[0],SizeOf(Key));
 DataConv_BXORK(iStream,oStream,kStream,iPos,iSize,oPos,oSize);
 FreeAndNil(kStream);
end;

{
  Для кодирования таблицы : $285EE76F, Хэш имени архива
  Для кодирования файлов : Хэш имени архива, Хэш имени файла
}
function Overture_CodeTable(k0, k1 : longword) : T256Array;
var i, tmp : longword; t : T256Array;
begin
 for i := 0 to $FF do begin
  tmp := ((k1 shl 16) or (k1 shr 16)) + k0 + k1;
  k0 := k1;
  k1 := tmp;
  t[i] := k1;
 end;
 Result := t;
end;

function Overture_ArDecoder(iStream, oStream : TStream; iPos, oPos : int64) : boolean;
var tab1: array{[0..$FF]} of word;
    tab2: array{[0..$107]} of byte;
    lookup: array{[0..$FEFF]} of byte;
    z : byte;
    a, i, low, high, value, max, len, size, mul : longword;
begin
 // Инициализируем размеры массивов здесь, чтобы не расходовать память понапрасну
 SetLength(tab1,$100);
 SetLength(tab2,$108);
 SetLength(lookup,$FF00);

 iStream.Seek(iPos,soBeginning);
 oStream.Seek(oPos,soBeginning);

 iStream.Read(tab2[0],Length(tab2));

 size := tab2[3] xor tab2[$107];
 size := (size shl 8) + (tab2[2] xor tab2[$106]);
 size := (size shl 8) + (tab2[1] xor tab2[$105]);
 size := (size shl 8) + (tab2[0] xor tab2[$104]);

 len := 0;
 for i := 0 to $FF do begin
  tab1[i] := len;
  a := len + tab2[4 + i];

  while len <> a do begin
   lookup[len] := i;
   len := len + 1;
  end;

 end;

 if len = 0 then begin Result := False; Exit; end;

 max := 8;
 a := (len - 1) shr 8;

 while a <> 0 do begin
  a := a shr 1;
  max := max + 1;
 end;

 max := (1 shl max) - 1;
 mul := $10000 div len;

 value := tab2[$104];
 value := (value shl 8) + tab2[$105];
 value := (value shl 8) + tab2[$106];
 value := (value shl 8) + tab2[$107];
 low := 0;
 high := $FFFFFFFF;

 for i := 1 to size do begin

  high := ((high shr 8) * mul) shr 8;
  a := (value - low) div high;

  if a >= len then begin Result := False; Exit; end;

  a := lookup[a];
  oStream.Write(a,1);

  low := low + high * tab1[a];
  high := high * tab2[4 + a];

  while (((high + low) xor low) and $FF000000) = 0 do begin
   iStream.Read(z,1);
   value := (value shl 8) + z;
   low := low shl 8;
   high := high shl 8;
  end;

  while high <= max do begin
   high := (not low) and max;
   iStream.Read(z,1);
   value := (value shl 8) + z;
   low := low shl 8;
   high := high shl 8;
  end;

 end;

 // Освобождаем память
 SetLength(tab1,0);
 SetLength(tab2,0);
 SetLength(lookup,0);

 Result := True;

end;

end.