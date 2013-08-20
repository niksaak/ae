{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  SuperNEKO-X Engine (CodePink/Stone Heads) games archive format & functions
  Supported games:
    SexFriend
  
  Written by Nik & dsp2003.
}

unit AA_GPC_SuperNEKO_X;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Generic_LZXX,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
  procedure IA_GPC_SuperNEKO_X(var ArcFormat : TArcFormats; index : integer);

  function OA_GPC_SuperNEKO_X               : boolean;
  function SA_GPC_SuperNEKO_X(Mode:integer) : boolean;
  function EA_GPC_SuperNEKO_X(FileRecord : TRFA) : boolean;

type

 TSuperNEKOHeader = packed record
  Header       : array[1..4] of char;
  // "Gpc7" - SuperNEKO-X
  // "Him4" - HIMAURI
  TotalRecords : longword; // Number of files
 end;
 TSuperNEKODir = packed record
  Offset       : longword;
 end;
 TSuperNEKOTable = packed record
	CompSize     : longword; // Size of the crypted file (if 0, then file stored without encryption)
	FileSize     : longword; // Actual size of file
  FileHeader   : array[0..3] of char;
 end;

implementation

uses AnimED_Archives;

procedure IA_GPC_SuperNEKO_X;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'CodePink';
  Ext  := '.gpc';
  Stat := $0;
  Open := OA_GPC_SuperNEKO_X;
  Save := SA_GPC_SuperNEKO_X;
  Extr := EA_GPC_SuperNEKO_X;
  FLen := 0;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_GPC_SuperNEKO_X;
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
   if Header <> 'Gpc7' then Exit;
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

function SA_GPC_SuperNEKO_X;
var i : integer;
    GPCHeader : TSuperNEKOHeader;
    GPCDir    : TSuperNEKODir;
    GPCTable  : TSuperNEKOTable;
begin
 with ArchiveStream do begin
  with GPCHeader do begin
   Header := 'Gpc7';
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

function EA_GPC_SuperNEKO_X;
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
          GCLZ77Decode(TempoStream, OutStream, FileRecord.RFA_C);
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