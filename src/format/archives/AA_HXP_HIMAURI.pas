{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  HIMAURI Script Engine (Abel Software) games archive format & functions
  Supported Games:
    Exodus Guilty Alternative
  
  Written by Nik & dsp2003.
}

unit AA_HXP_HIMAURI;

interface

uses AA_RFA,
     AA_GPC_SuperNEKO_X,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Generic_LZXX,
     Generic_Hashes,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
  procedure IA_HXP_HIMAURI_Him4(var ArcFormat : TArcFormats; index : integer);
  function OA_HXP_HIMAURI_Him4               : boolean;
  function SA_HXP_HIMAURI_Him4(Mode:integer) : boolean;
  function EA_HXP_HIMAURI_Him4(FileRecord : TRFA) : boolean;

  procedure IA_HXP_HIMAURI_Him5(var ArcFormat : TArcFormats; index : integer);
  function OA_HXP_HIMAURI_Him5               : boolean;
  function SA_HXP_HIMAURI_Him5(Mode:integer) : boolean;

type
{
 TSuperNEKOHeader = packed record
  Header       : array[1..4] of char;
  // "Gpc7" - SuperNEKO-X
  // "Him4" - HIMAURI
  // "Him5" - HIMAURI (for sound)
  TotalRecords : longword; // Number of files
 end;
 TSuperNEKODir = packed record
  Offset       : longword;
 end;
 TSuperNEKOTable = packed record
	CompSize     : longword; // Size of the crypted file (if 0, then file stored without encryption)
	FileSize     : longword; // Actual size of file
  FileHeader   : array[0..3] of char;
 end;}
 THim5HashEntity = packed record
   Size : cardinal;
   Offset : cardinal;
 end;

 {
 THim5FileRecord = packed record
   RecordSize : byte;
   Offset : cardinal; // Со старших разрядов
   Name : string; // нуль терминирована
 end;
 если по данному хешу больше нет файлов - пишем нуль байт
 }

implementation

uses AnimED_Archives;

procedure IA_HXP_HIMAURI_Him4;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'HIMAURI Script Engine v2.0 (Him4)';
  Ext  := '.hxp';
  Stat := $0;
  Open := OA_HXP_HIMAURI_Him4;
  Save := SA_HXP_HIMAURI_Him4;
  Extr := EA_HXP_HIMAURI_Him4;
  FLen := 0;
  SArg := 0;
  Ver  := $20091226;
 end;
end;

procedure IA_HXP_HIMAURI_Him5;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'HIMAURI Script Engine v2.0 (Him5)';
  Ext  := '.hxp';
  Stat := $0;
  Open := OA_HXP_HIMAURI_Him5;
  Save := SA_HXP_HIMAURI_Him5;
  Extr := EA_HXP_HIMAURI_Him4;
  FLen := 0;
  SArg := 0;
  Ver  := $20091227;
 end;
end;

function OA_HXP_HIMAURI_Him4;
var i         : integer;
    GPCHeader : TSuperNEKOHeader;
    GPCTable  : TSuperNEKOTable;
label StopThis;
begin
 Result := False;

 with ArchiveStream do begin

  Seek(0,soBeginning);

  Read(GPCHeader,SizeOf(GPCHeader)); // зачастую читать и писать структурированные данные проще по его размеру

  with GPCHeader do begin // упрощает запись. да, есть риск запутаться, но для небольших участков подходит идеально
   if Header <> 'Him4' then Exit;
   RecordsCount := TotalRecords; // говорим GUI сколько у нас файлов
   if TotalRecords = 0 then Exit;
//   if TotalRecords > $FFFF then goto StopThis; <--- не обязательно, т.к. 2 предыдущих проверки достаточно прочные
//   ReOffset := SizeOf(GPCHeader) + TotalRecords*SizeOf(GPCDir); <--- собственно, в функции распаковки он нам не нужен =)
  end;

{*}Progress_Max(RecordsCount);

// Читаем оффсеты =)
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
//  Read(GPCDir,SizeOf(GPCDir);
//  RFA[i].RFA_1 := GPCDir.Offset;

// Упростил код ещё сильней:
   Read(RFA[i].RFA_1,4);
  end;

// А вот теперь читаем и генерируем всё остальное
  for i := 1 to RecordsCount do begin
   with RFA[i] do begin
    Seek(RFA_1,soBeginning); // переходим по указанному в RFA_1 оффсету
    RFA_1 := RFA_1 + 8; // исправляем оффсет для чтения оболочкой =)
    Read(GPCTable,SizeOf(GPCTable));
    RFA_2 := GPCTable.FileSize;
    case GPCTable.CompSize of // использовать кэйс в данном случае более красиво =)
     0 : RFA_C := RFA_2;
     else begin
           RFA_C := GPCTable.CompSize;
           RFA_E := True; // говорим ядру что файл сжат
           RFA_X := $FD; // $FD -- идентификатор LZSS
          end;
    end; // case

    RFA_3 := 'File_'+inttostr(i); // генерируем имя файла

    case GPCTable.FileHeader[integer(RFA_E)] of // 0..1..2..3. 1-й байт указывает на
     'B' : RFA_3 := RFA_3 + '.bmp';
     'R' : RFA_3 := RFA_3 + '.wav';
     #0  : RFA_3 := RFA_3 + '.tga';
    end;

   end; // with RFA[i]

  end; // for i := 1 to RecordsCount

 end; // with ArchiveStream

 Result := True;

end;

function OA_HXP_HIMAURI_Him5;
var i : cardinal;
    GPCHeader : TSuperNEKOHeader;
    GPCTable  : TSuperNEKOTable;
    HashTable : array of THim5HashEntity;
    RSize : byte;
label StopThis;
begin
 Result := False;

 with ArchiveStream do begin

  Seek(0,soBeginning);
  Read(GPCHeader,SizeOf(GPCHeader));

  if GPCHeader.Header <> 'Him5' then Exit;
  RecordsCount := 0;

{*}Progress_Max(GPCHeader.TotalRecords);

  SetLength(HashTable, GPCHeader.TotalRecords);
  Read(HashTable[0], GPCHeader.TotalRecords*sizeof(THim5HashEntity));

  for i := 1 to GPCHeader.TotalRecords do begin
{*}Progress_Pos(i);
   Seek(HashTable[i-1].Offset,soBeginning);
   while HashTable[i-1].Size > 1 do
   begin
     Inc(RecordsCount);
     Read(RSize, 1);
     Read(RFA[RecordsCount].RFA_1, 4);
     RFA[RecordsCount].RFA_1 := EndianSwap(RFA[RecordsCount].RFA_1);
     SetLength(RFA[RecordsCount].RFA_3, RSize - 6);
     Read(RFA[RecordsCount].RFA_3[1], RSize - 6);
     Seek(1,soCurrent);
     HashTable[i-1].Size := HashTable[i-1].Size - RSize;
   end;
  end;

// А вот теперь читаем и генерируем всё остальное
  for i := 1 to RecordsCount do begin
   with RFA[i] do begin
    Seek(RFA_1,soBeginning); // переходим по указанному в RFA_1 оффсету
    RFA_1 := RFA_1 + 8; // исправляем оффсет для чтения оболочкой =)
    Read(GPCTable,SizeOf(GPCTable));
    RFA_2 := GPCTable.FileSize;
    case GPCTable.CompSize of // использовать кэйс в данном случае более красиво =)
     0 : RFA_C := RFA_2;
     else begin
           RFA_C := GPCTable.CompSize;
           RFA_E := True; // говорим ядру что файл сжат
           RFA_X := $FD; // $FD -- идентификатор LZSS
          end;
    end; // case
{
    case GPCTable.FileHeader[integer(RFA_E)] of // 0..1..2..3. 1-й байт указывает на
     'B' : RFA_3 := RFA_3 + '.bmp';
     'R' : RFA_3 := RFA_3 + '.wav';
     #0  : RFA_3 := RFA_3 + '.tga';
    end;}

   end; // with RFA[i]

  end; // for i := 1 to RecordsCount

 end; // with ArchiveStream
 SetLength(HashTable, 0);
 Result := True;

end;

function SA_HXP_HIMAURI_Him4;
var i : integer;
    GPCHeader : TSuperNEKOHeader;
    GPCDir    : TSuperNEKODir;
    GPCTable  : TSuperNEKOTable;
begin
 with ArchiveStream do begin
  with GPCHeader do begin
   Header := 'Him4';
   RecordsCount := AddedFiles.Count;
   ReOffset := SizeOf(GPCHeader) + SizeOf(GPCDir)*RecordsCount;
   TotalRecords := RecordsCount;
  end;

  Write(GPCHeader,SizeOf(GPCHeader));

// Создаём таблицу...
  RFA[1].RFA_1 := ReOffset;
  UpOffset := ReOffset;

{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with GPCDir do begin
//    FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
    UpOffset       := UpOffset + FileDataStream.Size + 8; // прибавляем к оффсету файла размер доп. заголовка
    RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
    RFA[i].RFA_2   := FileDataStream.Size;
    Offset         := RFA[i].RFA_1;
    FreeAndNil(FileDataStream);

    Write(GPCDir,SizeOf(GPCDir)); // пишем таблицу смещений

   end;
  end;

// ну и, наконец
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

   GPCTable.CompSize := 0;
   GPCTable.FileSize := RFA[i].RFA_2;

   Write(GPCTable.CompSize,4); // первое поле доп заголовка, 0
   Write(GPCTable.FileSize,4); // второе поле доп заголовка, размер нашего файла

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   CopyFrom(FileDataStream,FileDataStream.Size);

   FreeAndNil(FileDataStream);
  end;

 end; // with ArchiveStream

 Result := True;
end;

function SA_HXP_HIMAURI_Him5;
var i, j, k, toffset, thash : cardinal;
    GPCHeader : TSuperNEKOHeader;
    GPCTable  : TSuperNEKOTable;
    HashTable : array of THim5HashEntity;
    indexes : array of cardinal;
    RSize : byte;
    stream : TStream;
begin
 with ArchiveStream do begin
  with GPCHeader do begin
   Header := 'Him5';
   TotalRecords := $200; // hash divisor
   SetLength(HashTable, TotalRecords);
   FillChar(HashTable[0], $200*4, 0);
   RecordsCount := AddedFiles.Count;
   ReOffset := SizeOf(GPCHeader) + SizeOf(HashTable[0])*TotalRecords;
  end;

  thash := HIMAURI_Hash('s010'#0, GPCHeader.TotalRecords);

  Write(GPCHeader,SizeOf(GPCHeader));

{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
    RFA[i].RFA_3 := AddedFiles.Strings[i-1];
    RFA[i].RFA_2   := FileDataStream.Size;
    RFA[i].RFA_C   := HIMAURI_Hash(RFA[i].RFA_3 + #0, GPCHeader.TotalRecords);
    FreeAndNil(FileDataStream);
  end;

  for i := 0 to $1FF do
  begin
    HashTable[i].Offset := ReOffset;
    for j := 1 to RecordsCount do
    begin
      if RFA[j].RFA_C = i then
      begin
        if HashTable[i].Size = 0 then HashTable[i].Size := 1;
        HashTable[i].Size := HashTable[i].Size + 6 + Length(RFA[j].RFA_3);
      end;
    end; // for j
    ReOffset := ReOffset + HashTable[i].Size;
  end; // for i

  stream := TMemoryStream.Create;
  RSize := 0;
  SetLength(indexes, RecordsCount);
  k := 0;

  for i := 0 to $1FF do
  begin
    if HashTable[i].Size <> 0 then
    begin
      for j := 1 to RecordsCount do
      begin
        if RFA[j].RFA_C = i then
        begin
          indexes[k] := j;
          Inc(k);
          RSize := 6 + Length(RFA[j].RFA_3);
          stream.Write(RSize, 1);
          toffset := EndianSwap(ReOffset);
          ReOffset := ReOffset + 8 + RFA[j].RFA_2;
          stream.Write(toffset, 4);
          stream.Write(RFA[j].RFA_3[1], Length(RFA[j].RFA_3));
          RSize := 0;
          stream.Write(RSize, 1);
        end;
      end;
      stream.Write(RSize, 1);
    end;
  end;

  Write(HashTable[0], SizeOf(HashTable[0])*GPCHeader.TotalRecords);
  stream.Position := 0;
  CopyFrom(stream, stream.Size);
  FreeAndNil(stream);

// ну и, наконец
  for i := 0 to RecordsCount-1 do begin
{*}Progress_Pos(i);

   GPCTable.CompSize := 0;
   GPCTable.FileSize := RFA[indexes[i]].RFA_2;

   Write(GPCTable,8);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[indexes[i]-1],fmOpenRead);

   CopyFrom(FileDataStream,FileDataStream.Size);

   FreeAndNil(FileDataStream);
  end;

 end; // with ArchiveStream

 SetLength(indexes, 0);
 SetLength(HashTable, 0);
 Result := True;
end;

function EA_HXP_HIMAURI_Him4;
var TempoStream, OutStream : TStream;
begin
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then begin
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_E of
   True: begin
          TempoStream := TMemoryStream.Create;
          TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
          TempoStream.Position := 0;

          OutStream := TMemoryStream.Create;
          GCLZ77Decode_2(TempoStream, OutStream, FileRecord.RFA_C);
          TempoStream.Position := 0;
          OutStream.Position := 0;
          FileDataStream.CopyFrom(OutStream,OutStream.Size);
          FreeAndNil(TempoStream);
          FreeAndNil(OutStream);
         end;
   False: FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  end;
 end
 else raise Exception.Create('Debug: internal error. ArchiveStream or FileDataStream is NIL.');
 Result := True;
end;

end.