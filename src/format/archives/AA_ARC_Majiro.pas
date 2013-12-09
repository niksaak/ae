{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Majiro archive format & functions

  Specifications from Proger_XP.
  Written by dsp2003 & Nik.
}

unit AA_ARC_Majiro;

interface

uses AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Skin,
     Generic_Hashes,
     AA_RFA,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_ARC_Majiro_v1(var ArcFormat : TArcFormats; index : integer);
 procedure IA_ARC_Majiro_v2(var ArcFormat : TArcFormats; index : integer);
 procedure IA_ARC_Majiro_v3(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_Majiro_v1 : boolean;
  function OA_ARC_Majiro_v2 : boolean;
  function OA_ARC_Majiro_v3 : boolean;
  function OA_ARC_Majiro(Mode : integer) : boolean;
  
  function SA_ARC_Majiro(Mode : integer) : boolean;

// функция генерации архива должна быть построена так, что файлы в нём расположены в порядке возрастания хешей
//  function MajiroV1_hash(filename : string) : longword;

type
{ Majiro archive structural description }
 TMajiroHeader = packed record
  Magic        : array[1..16] of char; // MajiroArcVX.000 + #0
  FileCount    : longword; // zero-based
  NameTablePos : longword;
  ReOffset     : longword;
 end;
 TMajiroDir3 = packed record
  Hash63       : int64;
  Offset       : longword;
 end;
 TMajiroDir = packed record
  Hash         : longword; // Generated from filename
  Offset       : longword;
 end; 
 TMajiroDir2 = packed record
  FileSize     : longword;
 end;
  // ------ goes AFTER the FileIndex and Offset
 TMajiroDirFN = packed record
  Filename     : array[1..256] of char;
 end;

const arc_majiro_ver = $20100821;

implementation

uses AnimED_Archives;

procedure IA_ARC_Majiro_v1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Majiro ARC v1.000';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_Majiro_v1;
  Save := SA_ARC_Majiro;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 1;
  Ver  := arc_majiro_ver;
 end;
end;

procedure IA_ARC_Majiro_v2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Majiro ARC v2.000';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_Majiro_v2;
  Save := SA_ARC_Majiro;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 2;
  Ver  := arc_majiro_ver;
 end;
end;

procedure IA_ARC_Majiro_v3;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Majiro ARC v3.000';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_Majiro_v3;
  Save := SA_ARC_Majiro;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 3;
  Ver  := arc_majiro_ver;
 end;
end;

function OA_ARC_Majiro_v1;
var MiniBuffer : array[1..16] of char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(MiniBuffer,SizeOf(MiniBuffer));
  if MiniBuffer <> 'MajiroArcV1.000'#0 then Exit;
 end;
 
 Result := OA_ARC_Majiro(1);
end;

function OA_ARC_Majiro_v2;
var MiniBuffer : array[1..16] of char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(MiniBuffer,SizeOf(MiniBuffer));
  if MiniBuffer <> 'MajiroArcV2.000'#0 then Exit;
 end;

 Result := OA_ARC_Majiro(2);
end;

function OA_ARC_Majiro_v3;
var MiniBuffer : array[1..16] of char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(MiniBuffer,SizeOf(MiniBuffer));
  if MiniBuffer <> 'MajiroArcV3.000'#0 then Exit;
 end;

 Result := OA_ARC_Majiro(3);
end;

function OA_ARC_Majiro;
{ Majiro archive opening function }
var i, cb : integer;
    k : char;
    MjHeader : TMajiroHeader;
    MjDir3   : TMajiroDir3;
    MjDir    : TMajiroDir;
    MjDir2   : TMajiroDir2;
    tmpStream : TStream;
begin

 Result := False;

 with ArchiveStream do begin

  Seek(0,soBeginning);
  Read(MjHeader,SizeOf(MjHeader));

  with MjHeader do begin

   if Magic = 'MajiroArcV1.000'#0 then
   if Mode <> 1 then Exit else
   if Magic = 'MajiroArcV2.000'#0 then
   if Mode <> 2 then Exit else
   if Magic = 'MajiroArcV3.000'#0 then
   if Mode <> 3 then Exit;

   RecordsCount := FileCount;

   // создаём поле для хранения хэша
   SetLength(RFA[0].RFA_T,1);
   SetLength(RFA[0].RFA_T[0],1);
   RFA[0].RFA_T[0][0] := 'CRC32/CRC63';

{*}Progress_Max(RecordsCount);
   for i := 1 to RecordsCount do begin
{*} Progress_Pos(i);

    // создаём поле для хранения хэша
    SetLength(RFA[i].RFA_T,1);
    SetLength(RFA[i].RFA_T[0],1);

    case Mode of
    1,2 : begin
           Read(MjDir,SizeOf(MjDir));
           RFA[i].RFA_1 := MjDir.Offset;
           RFA[i].RFA_T[0][0] := inttohex(MjDir.Hash,8);
          end;
    3   : begin
           Read(MjDir3,SizeOf(MjDir3));
           RFA[i].RFA_1 := MjDir3.Offset;
           RFA[i].RFA_T[0][0] := inttohex(MjDir3.Hash63,16);
          end;
    end;

    // если имеем дело с архивами формата v2, дочитываем поле с размером файла
    if Mode > 1 then begin
     Read(MjDir2,SizeOf(MjDir2));
     RFA[i].RFA_2 := MjDir2.FileSize;
     RFA[i].RFA_C := RFA[i].RFA_2;
    end;

   end;
   
   // проверка на валидность архива
   if Mode = 1 then begin
    Read(MjDir,SizeOf(MjDir));
    if MjDir.Hash <> 0 then Exit;
    if MjDir.Offset > ArchiveStream.Size then Exit;
   end;
   
   // если имеем дело с архивами формата v1, то высчитываем размеры файлов
   if Mode = 1 then for i := 1 to RecordsCount do begin
 {*}Progress_Pos(i);
    if RFA[i+1].RFA_1 <> 0 then RFA[i].RFA_2 := RFA[i+1].RFA_1-RFA[i].RFA_1
    else RFA[i].RFA_2 := 0;
    // досчитываем размер для последнего файла
    if i = RecordsCount then RFA[i].RFA_2 := ArchiveStream.Size - RFA[i].RFA_1;
    RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
   end;

   // считываем имена файлов
   tmpStream := TMemoryStream.Create;
   Seek(NameTablePos,soBeginning);
   tmpStream.CopyFrom(ArchiveStream,ReOffset-NameTablePos);
   tmpStream.Seek(0,soBeginning);
   
   // и обрабатываем
   for i := 1 to RecordsCount do begin
 {*}Progress_Pos(i);
    k := #255; cb := 0;
    while k <> #0 do begin
     tmpStream.Read(k,1);
     RFA[i].RFA_3 := RFA[i].RFA_3 + k;
     inc(cb);
     if cb > 256 then Exit;
    end;
{    SetLength(hs,Length(RFA[i].RFA_3)-1);
    CopyMemory(@hs[1],@RFA[i].RFA_3[1],Length(RFA[i].RFA_3)-1);
    if hs = 'majiro.env' then
    begin
      hs := hs;
    end;
    hash := Majirov1_hash(hs);}// тута было тестирование хеша

{    // пишем хэши в ini-файл
    if ((RFA[i].RFA_T[0][0]) <> '0') and (RFA[i].RFA_3 <> '') then ConfS('Metadata.conf',MajiroConf,RFA[i].RFA_3,RFA[i].RFA_T[0][0]); }
   end; 

   FreeAndNil(tmpStream);

  end; // with MjHeader

 end;
 Result := True;

end;

function SA_ARC_Majiro;
var i, j : integer;
    MjHeader      : TMajiroHeader;
    MjDir3        : TMajiroDir3;
    MjDir         : TMajiroDir;
    MjDir2        : TMajiroDir2;
    HashTable     : DataArray;
begin

 Result := False;

 RecordsCount := AddedFiles.Count;

 SetLength(HashTable,RecordsCount);

 with MjHeader do begin

  FileCount := RecordsCount;

  case Mode of
   1 : begin //v1
        Magic        := 'MajiroArcV1.000'#0;
        NameTablePos := SizeOf(MjHeader)+((RecordsCount+1) * SizeOf(MjDir)); // +1 for EOF record
       end; 
   2 : begin //v2
        Magic        := 'MajiroArcV2.000'#0;
        NameTablePos := SizeOf(MjHeader)+(RecordsCount * (SizeOf(MjDir)+SizeOf(MjDir2)));
       end;
   3 : begin //v3
        Magic        := 'MajiroArcV3.000'#0;
        NameTablePos := SizeOf(MjHeader)+(RecordsCount * (SizeOf(MjDir3)+SizeOf(MjDir2)));
       end;
  end;

  UpOffset := NameTablePos;

  // инициализируем функцию хэшей
  if Mode < 3 then Majiro_hash_init;

  for i := 1 to RecordsCount do begin
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]); // MajiroArc don't stores pathes
   case Mode of
    1,2 : HashTable[i-1] := Majiro_Hash(RFA[i].RFA_3);
    3   : HashTable[i-1] := Majiro_Hash64(RFA[i].RFA_3);
   end;
   SetLength(RFA[i].RFA_T,1);
   SetLength(RFA[i].RFA_T[0],1);
   RFA[i].RFA_T[0][0] := inttohex(HashTable[i-1],16);
   UpOffset := UpOffset + Length(RFA[i].RFA_3)+1; // +1 for zero
  end; // for

  // закрываем функцию хэшей
  if Mode < 3 then Majiro_hash_destroy;

  ReOffset := UpOffset;

  for i := 1 to RecordsCount do begin

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead,False);

   with RFA[i] do begin
    RFA_1       := UpOffset;
    RFA_2       := FileDataStream.Size;
    UpOffset    := UpOffset + RFA_2;
   end;

   FreeAndNil(FileDataStream);

  end; // for

 end; // with MjHeader

 ArchiveStream.Write(MjHeader,SizeOf(MjHeader));

// ShellSort(HashTable,RecordsCount);
 BubbleSort(HashTable,RecordsCount);

 with ArchiveStream do begin

  for j := 1 to RecordsCount do begin
   for i := 1 to RecordsCount do begin
    if HashTable[j-1] = hextoint(RFA[i].RFA_T[0][0]) then begin
     case Mode of
     1,2 : begin
            MjDir.Hash    := HashTable[j-1];
            MjDir.Offset  := RFA[i].RFA_1;
           end;
     3   : begin
            MjDir3.Hash63 := HashTable[j-1];
            MjDir3.Offset := RFA[i].RFA_1;
           end;
     end;
     if Mode > 1 then MjDir2.FileSize := RFA[i].RFA_2;
     Break;
    end;
   end;
//   Debug
//   MessageBox(0,pchar(inttohex(HashTable[j-1],8)+' : '+RFA[i].RFA_T[0][0]+' - ['+inttostr(Length(RFA[i].RFA_T[0][0]))+']'),pchar(inttostr(i)),mb_ok);
   case Mode of
    1,2 : Write(MjDir,SizeOf(MjDir));
    3   : Write(MjDir3,SizeOf(MjDir3));
   end;
   if Mode > 1 then Write(MjDir2,SizeOf(MjDir2));
  end;

  // дописываем пустой элемент
  if Mode = 1 then begin
   MjDir.Hash := 0;
   MjDir.Offset := UpOffset;
   Write(MjDir,SizeOf(MjDir));
  end;

  // пишем имена файлов
  for j := 1 to RecordsCount do begin
   for i := 1 to RecordsCount do begin
    if HashTable[j-1] = hextoint(RFA[i].RFA_T[0][0]) then begin
     Write(RFA[i].RFA_3[1],Length(RFA[i].RFA_3)+1); // +1 for zero
     Break;
    end;
   end;
  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;

 end; // with ArchiveStream

 Result := True;

end;

{function MajiroV1_Hash;
var ind, temp, bnumber, len : longword;
    numbers : array of longword;
    bt : byte;
begin
 // нужно переместить генерацию массива за эту функцию, так как этот массив постоянен
 SetLength(numbers,256);
 for ind := 0 to 255 do begin
  temp := ind;
  for bt := 1 to 8 do
   if (temp and $1) <> 0 then temp := (temp shr 1) xor $EDB88320 else temp := (temp shr 1);
  numbers[ind] := temp;
 end;
 bnumber := $FFFFFFFF;
 for len := 1 to Length(filename) do begin
  temp := (bnumber and $FF) xor longword(Byte(filename[len]));
  bnumber := (bnumber shr 8) xor numbers[temp];
 end;
 Result := not bnumber;
 SetLength(numbers,0);
end;}

end.