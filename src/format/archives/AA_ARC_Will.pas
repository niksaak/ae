{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Will Co. Engine ARC game archive format & functions
  
  Written by dsp2003, with help of w8m. ^_~
}

unit AA_ARC_Will;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AE_StringUtils,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms,
     JUtils, FileStreamJ, StringsW;

 { Supported archives implementation }
 procedure IA_ARC_Will_8(var ArcFormat : TArcFormats; index : integer);
 procedure IA_ARC_Will_12(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_Will_8 : boolean;
  function SA_ARC_Will_8(Mode : integer) : boolean;
  function OA_ARC_Will_12 : boolean;
  function SA_ARC_Will_12(Mode : integer) : boolean;

 procedure ARC_Will_SortFiles(var Input,Ext : TStringsW);

type
{ Will Co. Engine ARC format structural description }
 TARCHeader = packed record
  ExtRec     : longword;             // Количество расширений имеющихся файлов.
 end;
 TARCExtDir = packed record
  Ext        : array[1..4] of char;  // Расширение (максимум 4 символа).
  FileCount  : longword;             // Число типа LONGWORD. Кол-во файлов.
  ExtFOffset : longword;             // Оффсет, указывающий в начало списка
                                     // файлов, которым следует присвоить расширение.
 end;
 TARC8Dir = packed record
  FileName   : array[1..9] of char;  // Имя файла БЕЗ расширения.
  Filesize   : longword;             // Число типа LONGWORD. Размер файла.
  Offset     : longword;             // Число типа LONGWORD. Оффсет файла.
 end;
 TARC12Dir = packed record           // для более новых версий архива
  FileName   : array[1..13] of char; // Имя файла БЕЗ расширения.
  Filesize   : longword;             // Число типа LONGWORD. Размер файла.
  Offset     : longword;             // Число типа LONGWORD. Оффсет файла.
 end;

implementation

uses AnimED_Archives;

procedure IA_ARC_Will_8;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Will Co. ARC-8';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_Will_8;
  Save := SA_ARC_Will_8;
  Extr := EA_RAW;
  FLen := 12;
  SArg := 0;
  Ver  := $20110403;
 end;
end;

procedure IA_ARC_Will_12;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Will Co. ARC-12';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_Will_12;
  Save := SA_ARC_Will_12;
  Extr := EA_RAW;
  FLen := 16;
  SArg := 0;
  Ver  := $20110403;
 end;
end;

function OA_ARC_Will_8;
{ Will Co. ARC archive opening function }
var i,k : integer; ExtAppend : string[4];
    Hdr    : TArcHeader;
    ExtDir : array of TARCExtDir;
    Dir    : TARC8Dir;
begin
 Result := False;
 with ArchiveStream do begin
  RecordsCount := 0;
  Seek(0,soBeginning);

  Read(Hdr,SizeOf(Hdr));

  with Hdr do begin
   if ExtRec = 0 then Exit;
   if ExtRec > $FF then Exit;

   SetLength(ExtDir,ExtRec); // устанавливаем количество слотов под расширения
   for i := 0 to ExtRec-1 do begin
    Read(ExtDir[i],SizeOf(TARCExtDir));
    with ExtDir[i] do begin
     if (FileCount = 0) or (FileCount > $FFFF) then Exit;
     RecordsCount := RecordsCount+Filecount;
    end;
   end;

   ReOffset := SizeOf(Hdr)+ExtRec*SizeOf(TARCExtDir)+SizeOf(Dir)*RecordsCount;

   if ReOffset > Size then Exit;

{*}Progress_Max(RecordsCount);
// Reading filetable...

   ReOffset := 0;

   for i := 1 to RecordsCount do begin
{*} Progress_Pos(i);
    Read(Dir,SizeOf(Dir));

    with Dir, RFA[i] do begin
     if Offset = 0 then Exit;
     for k := 0 to ExtRec-1 do if Position > ExtDir[k].ExtFOffset then ExtAppend := ExtDir[k].Ext; // Working with extensions table...
     for k := 1 to SizeOf(Filename) do if FileName[k] <> #0 then RFA_3 := RFA_3 + FileName[k] else break;

     RFA_3 := RFA_3 +'.'+ExtAppend; // Working with extensions table...
     RFA_1 := Offset;
     RFA_2 := FileSize;
     RFA_C := RFA_2; // replicates filesize
    end; //with

   end; //for

  end; //with Hdr

 end; //with ArchiveStream

 Result := True;

end;

{ Will Co. Engine ARC archive creating function }
function SA_ARC_Will_8;
var i,j : integer;
    ExtList : TStringsW;
    Hdr    : TArcHeader;
    ExtDir : array of TARCExtDir;
    Dir    : TARC8Dir;
begin
 // список для расширений файлов
 ExtList := TStringsW.Create;
 // логика обработки строк и сортировки перенесена в отдельную функцию
 ARC_Will_SortFiles(AddedFilesW,ExtList);

 with Hdr, ArchiveStream do begin
  ExtRec := ExtList.Count;

  // Writing...
  Write(Hdr,SizeOf(Hdr));

  SetLength(ExtDir,ExtList.Count); // слоты под расширения

// Using the Reoffset variable for calculating the archive table sections ... OMG WTF!?
// Will Co. coders are truly lunatics! >_<
  ReOffset := SizeOf(Hdr)+ExtRec*SizeOf(TARCExtDir);

  for i := 0 to ExtRec-1 do begin
   with ExtDir[i] do begin
    for j := 1 to 4 do begin
     if j <= length(ExtList.Strings[i])-1 then Ext[j] := char(ExtList.Strings[i][j+1]) else Ext[j] := #0;
    end;
    // берём количество файлов из тега
    FileCount := ExtList.Tags[i];

    ExtFOffset := ReOffset;
    ReOffset := ReOffset + SizeOf(Dir)*FileCount; // Adding size of the future linked-to-extension filetable section. The LAST calculated value is used for the first file offset.
   end;
   // Writing...
   Write(ExtDir[i],SizeOf(ExtDir[i]));
  end;

// Creating file table...
  RFA[1].RFA_1 := ReOffset;
  UpOffset     := ReOffset;
  RecordsCount := AddedFilesW.Count;

  for i := 1 to RecordsCount do begin // unlike other archives, RecordsCount is not quite situable here
{*}Progress_Pos(i);
   with Dir do begin
    FillChar(Dir,SizeOf(Dir),0);
    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

    UpOffset := UpOffset + FileDataStream.Size;
    RFA[i+1].RFA_1 := UpOffset;
    RFA[i].RFA_2 := FileDataStream.Size;
    RFA[i].RFA_3 := ExtractFileName(AddedFilesW.Strings[i-1]);
    for j := 1 to SizeOf(Filename) do begin
     if j <= length(RFA[i].RFA_3)-length(ExtractFileExt(RFA[i].RFA_3)) then FileName[j] := RFA[i].RFA_3[j] else break;
    end;
    Offset := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
    FreeAndNil(FileDataStream);
   end;
   // Writing part of the filetable...
   Write(Dir,SizeOf(Dir));
  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;

 end; // with hdr, ArchiveStream

 Result := True;

end;

function OA_ARC_Will_12;
{ Will Co. ARC archive opening function }
var i,k : integer; ExtAppend : string[4];
    Hdr    : TArcHeader;
    ExtDir : array of TARCExtDir;
    Dir    : TARC12Dir;
begin
 Result := False;
 with ArchiveStream do begin
  RecordsCount := 0;
  Seek(0,soBeginning);

  Read(Hdr,SizeOf(Hdr));

  with Hdr do begin
   if ExtRec = 0 then Exit;
   if ExtRec > $FF then Exit;

   SetLength(ExtDir,ExtRec+1); // устанавливаем количество слотов под расширения
   for i := 1 to ExtRec do begin
    Read(ExtDir[i],SizeOf(TARCExtDir));
    with ExtDir[i] do begin
     if (FileCount = 0) or (FileCount > $FFFF) then Exit;
     RecordsCount := RecordsCount+Filecount;
    end;
   end;

   ReOffset := SizeOf(Hdr)+ExtRec*SizeOf(TARCExtDir)+SizeOf(Dir)*RecordsCount;

   if ReOffset > ArchiveStream.Size then Exit;

{*}Progress_Max(RecordsCount);
// Reading filetable...
   for i := 1 to RecordsCount do begin
{*} Progress_Pos(i);
    Read(Dir,SizeOf(Dir));

    with Dir, RFA[i] do begin
     if Offset = 0 then Exit;
     for k := 1 to ExtRec do if Position > ExtDir[k].ExtFOffset then ExtAppend := ExtDir[k].Ext; // Working with extensions table...
     for k := 1 to SizeOf(Filename) do if FileName[k] <> #0 then RFA_3 := RFA_3 + FileName[k] else break;

     RFA_3 := RFA_3 +'.'+ExtAppend; // Working with extensions table...
     RFA_1 := Offset;
     RFA_2 := FileSize;
     RFA_C := RFA_2; // replicates filesize
    end; //with

   end; //for

  end; //with Hdr

 end; //with ArchiveStream

 Result := True;

end;

{ Will Co. Engine ARC archive creating function }
function SA_ARC_Will_12;
var i,j : integer;
    ExtList : TStringsW;
    Hdr    : TArcHeader;
    ExtDir : array of TARCExtDir;
    Dir    : TARC12Dir;
begin
 // список для расширений файлов
 ExtList := TStringsW.Create;
 // логика обработки строк и сортировки перенесена в отдельную функцию
 ARC_Will_SortFiles(AddedFilesW,ExtList);

 with Hdr, ArchiveStream do begin
  ExtRec := ExtList.Count;

  // Writing...
  Write(Hdr,SizeOf(Hdr));

  SetLength(ExtDir,ExtList.Count); // слоты под расширения

// Using the Reoffset variable for calculating the archive table sections ... OMG WTF!?
// Will Co. coders are truly lunatics! >_<
  ReOffset := SizeOf(Hdr)+ExtRec*SizeOf(TARCExtDir);

  for i := 0 to ExtRec-1 do begin
   with ExtDir[i] do begin
    for j := 1 to 4 do begin
     if j <= length(ExtList.Strings[i])-1 then Ext[j] := char(ExtList.Strings[i][j+1]) else Ext[j] := #0;
    end;
    // берём количество файлов из тега
    FileCount := ExtList.Tags[i];

    ExtFOffset := ReOffset;
    ReOffset := ReOffset + SizeOf(Dir)*FileCount; // Adding size of the future linked-to-extension filetable section. The LAST calculated value is used for the first file offset.
   end;
   // Writing...
   Write(ExtDir[i],SizeOf(ExtDir[i]));
  end;

// Creating file table...
  RFA[1].RFA_1 := ReOffset;
  UpOffset     := ReOffset;
  RecordsCount := AddedFilesW.Count;

  for i := 1 to RecordsCount do begin // unlike other archives, RecordsCount is not quite situable here
{*}Progress_Pos(i);
   with Dir do begin
    FillChar(Dir,SizeOf(Dir),0);
    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

    UpOffset := UpOffset + FileDataStream.Size;
    RFA[i+1].RFA_1 := UpOffset;
    RFA[i].RFA_2 := FileDataStream.Size;
    RFA[i].RFA_3 := ExtractFileName(AddedFilesW.Strings[i-1]);
    for j := 1 to SizeOf(Filename) do begin
     if j <= length(RFA[i].RFA_3)-length(ExtractFileExt(RFA[i].RFA_3)) then FileName[j] := RFA[i].RFA_3[j] else break;
    end;
    Offset := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
    FreeAndNil(FileDataStream);
   end;
   // Writing part of the filetable...
   Write(Dir,SizeOf(Dir));
  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;

 end; // with hdr, ArchiveStream

 Result := True;

end;

procedure ARC_Will_SortFiles;
var Sorted : array of TStringsW;
    i,j : longword;
    ItemFound : boolean;
begin
 // переводим все строки в верхний регистр
 AE_UpperCaseStringsW(Input);
{ with Input do begin
  for i := 0 to Count-1 do Strings[i] := UpperCase(Strings[i]);
 end;}

 // заполняем список расширений
 for i := 0 to Input.Count-1 do begin
  ItemFound := False;
  if Ext.Count > 0 then begin
   for j := 0 to Ext.Count-1 do begin
    if ExtractFileExt(Input.Strings[i]) = Ext.Strings[j] then begin
     ItemFound := True;
     break;
    end;
   end;
  end;
  if not ItemFound then Ext.Add(ExtractFileExt(Input.Strings[i]));
 end;
 AE_SortStringsW(Ext);

 // устанавливаем количество списков для файлов по расширениям
 SetLength(Sorted,Ext.Count);
 // создаём новые сортированные списки
 for j := 0 to Ext.Count-1 do begin
  Sorted[j] := TStringsW.Create;
  for i := 0 to Input.Count-1 do begin
   if ExtractFileExt(Input.Strings[i]) = Ext.Strings[j] then Sorted[j].Add(Input.Strings[i]);
  end;
  // записываем количество файлов в теги
  Ext.Tags[j] := Sorted[j].Count;
  AE_SortStringsW(Sorted[j]);
 end;
 // очищаем входной список файлов
 Input.Clear;
 // добавляем данные из сортированных списков
 for j := 0 to Ext.Count-1 do begin
  for i := 0 to Sorted[j].Count-1 do begin
   Input.Add(Sorted[j].Strings[i]);
  end;
  FreeAndNil(Sorted[j]);
 end;
 // высвобождаем память
 SetLength(Sorted,0);

end;

end.