{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  ROOT archive format & functions
  
  Written by Nik.
  Some optimisations & code cleanup by dsp2003.
}

unit AA_PAK_DataPack5;

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
 procedure IA_PAK_DataPack5(var ArcFormat : TArcFormats; index : integer);

 function OA_PAK_DataPack5 : boolean;
 function SA_PAK_DataPack5(Mode : integer) : boolean;
 
type
 TDataPack5Header = packed record
  Magic1        : array[1..$10] of char; // "DataPack5\0\0\0\0\0\0\0"
  Magic2        : array[1..$10] of char; // "GsPackFile5\0\0\0\0\0"
  Dummy         : array[1..$10] of char; // Нули
  Unk           : word;                  // обычно 1
  TableElemFlag : word;                  // Обычно 5
  {
    Вроде как это флаг размера элемента файловой таблицы
    Если он == 5, то юзается TDataPack5Table, если нет, то TDataPack5Table_simple
  }
  TableLen      : cardinal; // Размер сжатой файловой таблицы
  {
    Вроде как если не указано, значит таблица не сжата
  }
  Dummy2        : cardinal; // Нули
  FilesCount    : cardinal; // Сабж
  DataOffset    : cardinal; // Смещение начала данных (обычно, начиная с 0x800)
  TableOffset   : cardinal; // Смещение начала таблицы
 end;

  // Если TableElemFlag != 5 то юзать её
 TDataPack5Table_simple = packed record
  FileName      : array[1..$40] of char; // Снова Сабж
  FOffset       : cardinal;              // Смещение начала файла от точки DataOffset
  FSize         : cardinal;              // Размер файла
 end;
 
 TDataPack5Table = packed record
  FileData      : TDataPack5Table_simple;
  Unk1          : cardinal; // Обычно 1
  Unk2          : cardinal; // Обычно 1
  FileMetaData  : array[1..24] of byte; // хз чего
 end;

implementation

uses AnimED_Archives;

procedure IA_PAK_DataPack5;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'DataPack5 / ROOT';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_DataPack5;
  Save := SA_PAK_DataPack5;
  Extr := EA_RAW;
  FLen := $40;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_PAK_DataPack5;
var Header : TDataPack5Header;
    Table : array of TDataPack5Table;
    i, j : longword;
    stream, tablestream : TStream;
    ext : boolean;
    extarr : array[1..4] of char;
label StopThis;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Header,SizeOf(TDataPack5Header));
 end;

 if (Header.Magic1  <> 'DataPack5'#0#0#0#0#0#0#0) or
// (Header.Magic2     <> 'GsPackFile5'#0#0#0#0#0) or // по всей видимости, это просто метка
 (Header.TableLen    > ArchiveStream.Size) or
 (Header.DataOffset  > ArchiveStream.Size) or
 (Header.TableOffset > ArchiveStream.Size)
  then goto StopThis;

 tablestream := TMemoryStream.Create;
 tablestream.Position := 0;

 if Header.TableLen = 0 then begin
  ArchiveStream.Position := Header.TableOffset;
  if Header.TableElemFlag = 5 then
    tablestream.CopyFrom(ArchiveStream,Header.FilesCount*SizeOf(TDataPack5Table))
  else
    tablestream.CopyFrom(ArchiveStream,Header.FilesCount*SizeOf(TDataPack5Table_simple));
 end else begin
  stream := TMemoryStream.Create;
  ArchiveStream.Position := Header.TableOffset;
  stream.CopyFrom(ArchiveStream,Header.TableLen);
  stream.Position := 0;
  GLZSSDecode(stream, tablestream, stream.Size, $FEE,$FFF);
  FreeAndNil(stream);
 end;

 SetLength(Table, Header.FilesCount);
 tablestream.Position := 0;

 if Header.TableElemFlag = 5 then begin
  if tablestream.Size > Header.FilesCount*SizeOf(TDataPack5Table) then goto StopThis;
  tablestream.Read(Table[0],tablestream.Size);
 end else begin
  if tablestream.Size > Header.FilesCount*SizeOf(TDataPack5Table_simple) then goto StopThis;
  FillChar(Table[0],Header.FilesCount*SizeOf(TDataPack5Table),0);
  for i := 1 to Header.FilesCount do tablestream.Read(Table[i-1].FileData,SizeOf(TDataPack5Table_simple));
 end;

 FreeAndNil(tablestream);

 RecordsCount := Header.FilesCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_2 := Table[i-1].FileData.FSize;
  RFA[i].RFA_C := Table[i-1].FileData.FSize;
  RFA[i].RFA_1 := Table[i-1].FileData.FOffset + Header.DataOffset;
  ext := true;
  
  for j := 1 to $40 do
  if Table[i-1].FileData.FileName[j] <> #0 then begin
   RFA[i].RFA_3 := RFA[i].RFA_3 + Table[i-1].FileData.FileName[j];
   if Table[i-1].FileData.FileName[j] = '.' then ext := false;
  end else break;

  if ext then begin
   ArchiveStream.Position := RFA[i].RFA_1;
   ArchiveStream.Read(extarr,4);
   if extarr = 'OggS' then RFA[i].RFA_3 := RFA[i].RFA_3 + '.ogg' else
    if extarr = 'Scw5' then RFA[i].RFA_3 := RFA[i].RFA_3 + '.x'
  end;

  if RFA[i].RFA_1 > ArchiveStream.Size then goto StopThis;

 end;

 Result := True;

StopThis:
 // Be nice to memory ^_^'
 SetLength(Table, 0);
end;

function SA_PAK_DataPack5;
{DataPack archive creation function }
var i : integer;
    Header : TDataPack5Header;
    Table : array of TDataPack5Table_simple;
    tsize, stringlen, dummysize : cardinal;
    DumymArr : array of byte;
begin
 RecordsCount := AddedFiles.Count;
 ArchiveStream.Position := 0;
 with ArchiveStream do begin
  with Header do begin
   Magic1 := 'DataPack5'#0#0#0#0#0#0#0;
   Magic2 := 'GsPackFile5'#0#0#0#0#0;
   FillChar(Dummy,$10,0);
   Unk := 1;
   TableElemFlag := 0;
   TableLen := 0;
   Dummy2 := 0;
   FilesCount := RecordsCount;
   TableOffset := $100;
   tsize := SizeOf(TDataPack5Table_simple)*RecordsCount;
   dummysize := SizeMod(tsize, $100);
   DataOffset := $100 + tsize + dummysize;
   stringlen := SizeOf(TDataPack5Header);
  end;

  Write(Header,stringlen);

  SetLength(DumymArr, $100);
  FillChar(DumymArr[0],$100,0);
  Write(DumymArr[0],$100 - SizeOf(TDataPack5Header));

  SetLength(Table,RecordsCount);

// Создаём таблицу...
  UpOffset := 0;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   FillChar(Table[i-1].FileName,SizeOf(Table[i-1].FileName),0);
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   RFA[i].RFA_3 := ChangeFileExt(RFA[i].RFA_3,'');
   stringlen := length(RFA[i].RFA_3);
   if(stringlen > $40) then
      stringlen := $40;
   Move(RFA[i].RFA_3[1],Table[i-1].FileName,stringlen);
   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   Table[i-1].FOffset := UpOffset;
   Table[i-1].FSize := FileDataStream.Size;
   UpOffset := UpOffset + FileDataStream.Size;
   FreeAndNil(FileDataStream);
  end;

  Write(Table[0],tsize);
  Write(DumymArr[0],dummysize);

  SetLength(Table,0);
  SetLength(DumymArr, 0);

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

end.