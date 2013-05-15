{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  AdvWin32 (F&C-FC01) games archive format & functions
  Supported games:
    Majokko a ra Mode - DVD Edition
    Suigetsu - Package Renewal
  
  Written by Nik.
  Fixes by dsp2003.
}

unit AA_MRG_ADVWIN32;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     Generic_LZXX,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_MRG_ADVWIN32(var ArcFormat : TArcFormats; index : integer);

 function OA_MRG_ADVWIN32 : boolean;
 function SA_MRG_ADVWIN32(Mode : integer) : boolean;
 function EA_MRG_ADVWIN32(FileRecord : TRFA) : boolean;

 procedure FC_DecdodeTable(Input, Output : TStream; len : longword; beginbyte : byte);
 procedure FC_CodeTable(Input, Output : TStream; len : longword; beginbyte : byte);
 procedure FC_DecdodeFunction(Input, Output : TStream);

 type
 TFCHeader = packed record
  MagicWord : array[1..4] of char; // MRG\0
  Flag1 : word; // флаг дешифрования таблицы (1)
  Flag2 : word; // флаг дешифрования таблицы (2)
  {
     если Flag1 == 0 && Flag2 == 1 то это получается архив с блекджеком и шлюхами
     и для каких случаев его юзать - непонятно

     в других случаях по этим флагам вычияляется байт-ключ дешифрования
     Для известных игр Flag1 == 2 && Flag2 == 1
     Но вычисленное значние равно $96 так что ХЗ начерта этот огород.
  }
  TableLen : longword; // начиная с нуля, поэтому настоящая длина -= 0x10
  FilesCount : longword; // Files Count. Nothing else.
 end;

 TFCTable = packed record
  FileName : array[1..14] of char; // Имя файла, 14 байт, записано в капсе, игра проверяет в нижнем регистре,
  // так что можно на это положить
  DecryptedSize : longword; // расшифрованный размер
  CryptFlag : word;{
  0 - нет сжатия
  1 - LZSS
  2 - Хитрожопый алгоритм + LZSS (именно в таком порядке)
  3 - Хитрожопый алгоритм
  }
  CSum : longword; // ВОЗМОЖНО, которольная сумма. На распаковку не влияет
  FileFlags : longword; // ВОЗМОЖНО, какая-то доп. инфа о файле. На распаковку не влияет
  Offset : longword; // смещение начала файла, шифрованная длина вычисляется по СЛЕДУЮЩЕЙ ЗАПИСИ
  // существует хвостовая запись "конец архива", по которой вычисляется длина последнего файла в архиве
 end;

implementation

uses AnimED_Archives;

procedure IA_MRG_ADVWIN32;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'AdvWin32';
  Ext  := '.mrg';
  Stat := $0;
  Open := OA_MRG_ADVWIN32;
  Save := SA_MRG_ADVWIN32;
  Extr := EA_MRG_ADVWIN32;
  FLen := 14;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_MRG_ADVWIN32;
var FCHeader : TFCHeader;
   Table : array of TFCTable;
   TableLen, i, j : longword;
 stream, tablestream : TStream;
label StopThis;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(FCHeader,SizeOf(TFCHeader));
 end;

 if (FCHeader.MagicWord <> 'MRG'+#0) or ((FCHeader.TableLen-$30) > (FCHeader.FilesCount*$20)) then Exit;

 TableLen := FCHeader.TableLen - $10;

 stream := TMemoryStream.Create;
 stream.CopyFrom(ArchiveStream,TableLen);
 tablestream := TMemoryStream.Create;

 FC_DecdodeTable(stream,tablestream,TableLen,$96);

 FreeAndNil(stream);

 SetLength(Table, FCHeader.FilesCount+1);
 tablestream.Seek(0,soBeginning);
 tablestream.Read(Table[0],TableLen);

 FreeAndNil(tablestream);

 RecordsCount := FCHeader.FilesCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  for j := 1 to 14 do if Table[i-1].FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + Table[i-1].FileName[j] else break;

  RFA[i].RFA_2 := Table[i-1].DecryptedSize;
  RFA[i].RFA_C := Table[i].Offset - Table[i-1].Offset;
  RFA[i].RFA_1 := Table[i-1].Offset;
  if (RFA[i].RFA_1 > ArchiveStream.Size) or (RFA[i].RFA_C > ArchiveStream.Size) then goto StopThis;

  case Table[i-1].CryptFlag of
   0: begin
{      RFA[i].RFA_E := false;
       RFA[i].RFA_X := $0; }
      end;
   1: begin
       RFA[i].RFA_E := true;
       RFA[i].RFA_X := $1; // LZSS
      end;
   2: begin
       RFA[i].RFA_E := true;
       RFA[i].RFA_X := $2; // Н*Ф + LZSS
      end;
   3: begin
       RFA[i].RFA_E := true;
       RFA[i].RFA_X := $3; // Неведомая ***ная Функция (Н*Ф)
      end;
  end;
 end;

 Result := True;

StopThis:
 // Be nice to memory ^_^'
 SetLength(Table, 0);
end;   

procedure FC_DecdodeTable;
var a : byte;
begin
 Input.Seek(0,soBeginning);
 Output.Seek(0,soBeginning);
 while len > 0 do begin
  Input.Read(a,1);
  asm
   mov AL, a
   rol AL, 1
   xor AL, beginbyte
   mov a, AL
  end;
  Output.Write(a,1);
  beginbyte := beginbyte + (len and $FF);
  Dec(len);
 end;
end;

procedure FC_CodeTable;
var a : byte;
begin
 Input.Seek(0,soBeginning);
 Output.Seek(0,soBeginning);
 while len > 0 do begin
  Input.Read(a,1);
  asm
   mov AL, a
   xor AL, beginbyte
   ror AL, 1
   mov a, AL
  end;
  Output.Write(a,1);
  beginbyte := beginbyte + (len and $FF);
  Dec(len);
 end;
end;

function SA_MRG_ADVWIN32;
{ AdvWin32 archive creation function }
var i, j : integer;
    FCHeader : TFCHeader;
    Table : array of TFCTable;
    stream, tablestream : TStream;
begin
 RecordsCount := AddedFiles.Count;
 with ArchiveStream do begin
  with FCHeader do begin
   MagicWord := 'MRG'+#0;
   Flag1 := 2;
   Flag2 := 1;
   TableLen := SizeOf(TFCHeader) + SizeOf(TFCTable)*(RecordsCount+1);
   FilesCount := RecordsCount;
  end;

  Write(FCHeader,SizeOf(TFCHeader));

  SetLength(Table,RecordsCount+1);

// Создаём таблицу...
  UpOffset := FCHeader.TableLen;

{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
//    FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   FillChar(Table[i-1].FileName,SizeOf(Table[i-1].FileName),0);
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   for j := 1 to 14 do if j <= length(RFA[i].RFA_3) then Table[i-1].FileName[j] := RFA[i].RFA_3[j] else break;
   Table[i-1].DecryptedSize := FileDataStream.Size;
   Table[i-1].CryptFlag := 0;
   Table[i-1].CSum := 0;
   Table[i-1].FileFlags := 0;
   Table[i-1].Offset := UpOffset;
   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   UpOffset := UpOffset + FileDataStream.Size;
   FreeAndNil(FileDataStream);
  end;

  FillChar(Table[RecordsCount],SizeOf(Table[RecordsCount].FileName)-4,0);
  Table[RecordsCount].Offset := UpOffset;

  stream := TMemoryStream.Create;
  stream.Write(Table[0],FCHeader.TableLen-$10);
  tablestream := TMemoryStream.Create;

  FC_CodeTable(stream,tablestream,FCHeader.TableLen-$10,$96);
  
  FreeAndNil(stream);
  tablestream.Seek(0,soBeginning);
  CopyFrom(tablestream,FCHeader.TableLen-$10); // пишем таблицу смещений
  FreeAndNil(tablestream);

  SetLength(Table,0);

// ну и, наконец
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;

 end; // with ArchiveStream

 Result := True;
end;

function EA_MRG_ADVWIN32;
var TempoStream, TempoStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_X of
   0 : begin // без сжатия
        FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
       end;
   1 : begin // LZSS (3-я модификация)
        TempoStream := TMemoryStream.Create;
        TempoStream2 := TMemoryStream.Create;
        TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
        TempoStream.Position := 0;
        GLZSSDecode3(TempoStream, TempoStream2, FileRecord.RFA_C, $FEE,$FFF);
        FreeAndNil(TempoStream);
        TempoStream2.Position := 0;
        FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
        FreeAndNil(TempoStream2);
       end;
   2 : begin // Н*Ф + LZSS
        TempoStream := TMemoryStream.Create;
        TempoStream2 := TMemoryStream.Create;
        TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
        TempoStream.Position := 0;
        FC_DecdodeFunction(TempoStream, TempoStream2);
        FreeAndNil(TempoStream);
        TempoStream := TMemoryStream.Create;
        TempoStream2.Position := 0;
        GLZSSDecode3(TempoStream2, TempoStream, TempoStream2.Size, $FEE,$FFF);
        FreeAndNil(TempoStream2);
        TempoStream.Position := 0;
        FileDataStream.CopyFrom(TempoStream,TempoStream.Size);
        FreeAndNil(TempoStream);
       end;
   3 : begin // Н*Ф
        TempoStream := TMemoryStream.Create;
        TempoStream2 := TMemoryStream.Create;
        TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
        TempoStream.Position := 0;
        FC_DecdodeFunction(TempoStream, TempoStream2);
        FreeAndNil(TempoStream);
        TempoStream2.Position := 0;
        FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
        FreeAndNil(TempoStream2);
       end;
  end;
  Result := True;
 except
 end;
end;

procedure FC_DecdodeFunction;
var x1, x2, x4, x5, x6, v5, v6, v14, len, len3, i, j, k, ind1 :cardinal;
    b, v15, v2 : byte;
    temparr1 : array of cardinal;
    temparr2, temparr3 : array of byte;
begin
 Input.Position := 260;
 Input.Read(x1,4);
 Input.Position := 0;
 Input.Read(x2,4);
 len := x1 xor x2;
 SetLength(temparr1,$101);
 SetLength(temparr2,$101);
 Input.Read(temparr2[0],$100);
 temparr2[$100] := 0;
 temparr1[0] := 0;
 len3 := 0;

 for i := 0 to $FF do begin
  len3 := len3 + temparr2[i];
  temparr1[i+1] := temparr2[i] + temparr1[i];
 end;

 x1 := temparr1[$100];

 case x1 of
  $0..$100     : x2 := $FF;
  $101..$200   : x2 := $1FF;
  $201..$400   : x2 := $3FF;
  $401..$800   : x2 := $7FF;
  $801..$1000  : x2 := $FFF;
  $1001..$2000 : x2 := $1FFF;
  $2001..$4000 : x2 := $3FFF;
  $4001..$8000 : x2 := $7FFF;
  else           x2 := $FFFF;
 end;

 SetLength(temparr3,len3);
 k := 0;

 for b := 0 to $FF do begin
  for j:= 1 to temparr2[b] do begin
   temparr3[k] := b;
   Inc(k);
  end;
 end;

 Input.Read(x4,4);
 x4 := EndianSwap(x4);
 x5 := $10000 div x1;
 x6 := not x2;

 v6 := $FFFFFFFF;
 v5 := 0;

 i := 0;

 while i < len do begin
  v14 := (x5 * (v6 shr 8)) shr 8;
  ind1 := (x4 - v5) div v14;
  v15 := temparr3[ind1];
  v5 :=  v5 + (v14 * temparr1[v15]);
  v6 := temparr2[v15] * v14;
  Output.Write(v15,1);
  Inc(i);
  while ((v5 xor (v5 + v6)) and $FF000000) = 0 do begin
   v5 := v5 shl 8;
   v6 := v6 shl 8;
   Input.Read(v2,1);
   x4 := v2 or (x4 shl 8);
  end;
  while (v6 and x6) = 0 do begin
   v6 := (x2 and (not v5)) shl 8;
   v5 := v5 shl 8;
   Input.Read(v2,1);
   x4 := v2 or (x4 shl 8);
  end;
 end;

 SetLength(temparr1,0);
 SetLength(temparr2,0);
 SetLength(temparr3,0);
end;

end.