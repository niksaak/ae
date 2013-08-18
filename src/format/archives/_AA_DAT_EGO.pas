{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  Studio E.Go archive formats

  Written by Nik.
}

unit AA_DAT_EGO;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_DAT_EGO_Old(var ArcFormat : TArcFormats; index : integer);
 procedure IA_DAT_EGO(var ArcFormat : TArcFormats; index : integer);

 function OA_DAT_EGO_Old : boolean;
 function OA_DAT_EGO : boolean;
 function SA_DAT_EGO_Old(Mode : integer) : boolean;
 function SA_DAT_EGO(Mode : integer) : boolean;

type
{
  TOldEGOHeader = packed record
   TableLen      : cardinal; // размер файловой таблицы
  end;

  TOldEGOTable = packed record
   TableEntryLen : cardinal; // размер элемента таблицы
   CryptLen      : cardinal; // ВОЗМЖНО! а так там 0
   FileOffset    : cardinal;
   FileSize      : cardinal;
   FileName      : string; // нуль терминировано
  end;
}
  TOldEGOHdr = packed record
   TableLen      : longword;
  end;

  TOldEGODir = packed record
   TableEntryLen : longword; // размер элемента таблицы
   CryptLen      : longword; // ВОЗМОЖНО! а так там 0
   FileOffset    : longword;
   FileSize      : longword;
  end;

  // Спецификация WindSeven-а
  TEGOHeader = packed record
   Magic         : cardinal; // 0x304B4150 ('PAK0')
   HeaderSize    : cardinal;
   NumOfDirs     : cardinal; // кол-во директорий (включая корневую директорию)
   NumOfFiles    : cardinal; // кол-во файлов
  end;

  TEGODirDescriptor = packed record
   ParentIndex   : integer; // -1 для корневой директории
   LastFileIndex : cardinal; // индекс последнего файла в массиве файлов, который находится в этой директории
  end;

  TEGOTable = packed record
   FOffset       : cardinal;
   FSsize        : cardinal;
   FAttr         : cardinal;
   FTime         : cardinal;
  end;

  {
   Далее находятся имена директорий в виде байт длины + не нультерминированная строка
   В таком же виде имена файлов
   В конце #0
  }

implementation

uses AnimED_Archives;

procedure IA_DAT_EGO_Old;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Studio E.Go Old DAT';
  Name := '[DAT] '+IDS;
  Ext  := '.dat';
  Stat := $0;
  Open := OA_DAT_EGO_Old;
  Save := SA_DAT_EGO_Old;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090916;
 end;
end;

procedure IA_DAT_EGO;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Studio E.Go DAT';
  Name := '[DAT] '+IDS;
  Ext  := '.dat';
  Stat := $F;
  Open := OA_DAT_EGO;
  Save := SA_DAT_EGO;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090916;
 end;
end;

function OA_DAT_EGO_Old;
var Header, RecNum, slen, slent : cardinal;
    TableStream : TStream;
    Table : TOldEGOTable;

    Hdr : longword; {TOldEgoHdr}
    Dir : TOldEgoDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  if (Hdr = 0) or (Hdr > ArchiveStream.Size) then Exit;
 end;

{ TOldEGODir = packed record
   TableEntryLen : longword; // размер элемента таблицы
   CryptLen      : longword; // ВОЗМОЖНО! а так там 0
   FileOffset    : longword;
   FileSize      : longword;
  end;}

 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,4);
 if (Header = 0) or (Header > (ArchiveStream.Size div 10)) then Exit;
 TableStream := TMemoryStream.Create;
 TableStream.CopyFrom(ArchiveStream,Header);
 TableStream.Position := 0;
 RecNum := 0;
 while TableStream.Position < TableStream.Size do
 begin
   TableStream.Read(Table,sizeof(Table));
   if (Table.TableEntryLen >= TableStream.Size) or (Table.FileOffset <= Header)
     or (Table.FileOffset >= ArchiveStream.Size) or (Table.FileSize >= ArchiveStream.Size) then
   begin
     FreeAndNil(TableStream);
     Exit;
   end;
   Inc(RecNum);
   RFA[RecNum].RFA_1 := Table.FileOffset;
   RFA[RecNum].RFA_2 := Table.FileSize;
   RFA[RecNum].RFA_C := Table.FileSize;
   slent := Table.TableEntryLen - sizeof(Table);
   SetLength(RFA[RecNum].RFA_3,slent);
   TableStream.Read(RFA[RecNum].RFA_3[1], slent);
   slen := 0;
   while slen < slent do
   begin
     Inc(slen);
     if RFA[RecNum].RFA_3[slen] = #0 then break;
   end;
   if slen <> slent then
   begin
     FreeAndNil(TableStream);
     Exit;
   end;
 end;
 RecordsCount := RecNum;
 FreeAndNil(TableStream);
 Result := True;
end;

function OA_DAT_EGO;
var Header : TEGOHeader;
    i, j, dind, cdindex : cardinal;
    blen : byte;
    NamesStream : TStream;
    DirTable : array of TEGODirDescriptor;
    DirNamesTable : array of string;
    CurDirName : string;
    FilesTable : array of TEGOTable;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> $304B4150 then Exit;
 SetLength(DirTable, Header.NumOfDirs);
 SetLength(DirNamesTable, Header.NumOfDirs);
 SetLength(FilesTable, Header.NumOfFiles);
 ArchiveStream.Read(DirTable[0],Header.NumOfDirs*sizeof(TEGODirDescriptor));
 ArchiveStream.Read(FilesTable[0],Header.NumOfFiles*sizeof(TEGOTable));
 NamesStream := TMemoryStream.Create;
 NamesStream.CopyFrom(ArchiveStream,Header.HeaderSize -
   sizeof(Header) - Header.NumOfDirs*sizeof(TEGODirDescriptor) -
   Header.NumOfFiles*sizeof(TEGOTable) - 1);
 NamesStream.Position := 0;
 RecordsCount := Header.NumOfFiles;

 for i := 1 to Header.NumOfDirs-1 do
 begin
   NamesStream.Read(blen,1);
   SetLength(DirNamesTable[i],blen);
   NamesStream.Read(DirNamesTable[i][1],blen);
 end;

 dind := DirTable[0].LastFileIndex + 1;
 j := 0;
 CurDirName := '';
{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   while i >= dind do
   begin
     Inc(j);
     dind := DirTable[j].LastFileIndex + 1;
     cdindex := j;
     CurDirName := '';
     while cdindex <> 0 do
     begin
       CurDirName := DirNamesTable[cdindex]+'\'+CurDirName;
       cdindex := DirTable[cdindex].ParentIndex;
     end;
   end;
   RFA[i].RFA_1 := FilesTable[i-1].FOffset;
   RFA[i].RFA_2 := FilesTable[i-1].FSsize;
   RFA[i].RFA_C := RFA[i].RFA_2;
   NamesStream.Read(blen,1);
   SetLength(RFA[i].RFA_3,blen);
   NamesStream.Read(RFA[i].RFA_3[1],blen);
   RFA[i].RFA_3 := CurDirName + RFA[i].RFA_3;
 end;
 SetLength(DirTable,0);
 SetLength(DirNamesTable,0);
 SetLength(FilesTable,0);
 FreeAndNil(NamesStream);
 Result := True;
end;

function SA_DAT_EGO_Old;
var i, filesoffs : cardinal;
    Table : TOldEGOTable;
begin
 RecordsCount := AddedFiles.Count;
 UpOffset := 0;
 filesoffs := 0;
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   RFA[i].RFA_3 := AddedFiles.Strings[i-1] + #0;
   RFA[i].RFA_1 := filesoffs;
   RFA[i].RFA_2 := FileDataStream.Size;
   filesoffs := filesoffs + RFA[i].RFA_2;
   UpOffset := UpOffset + $10 + Length(RFA[i].RFA_3);
   FreeAndNil(FileDataStream);
 end;
 ArchiveStream.Write(UpOffset,4);
 UpOffset := UpOffset + 4;
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   Table.TableEntryLen := $10 + Length(RFA[i].RFA_3);
   table.CryptLen := 0;
   table.FileOffset := UpOffset + RFA[i].RFA_1;
   table.FileSize := RFA[i].RFA_2;
   ArchiveStream.Write(Table,sizeof(Table));
   ArchiveStream.Write(RFA[i].RFA_3[1],Length(RFA[i].RFA_3));
 end;
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
 end;
 Result := True;
end;

function SA_DAT_EGO;
begin
 Result := True;
end;

end.