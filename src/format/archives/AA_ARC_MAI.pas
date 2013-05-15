{
  AE - VN Tools
  © 2007-2012 WinKiller Studio. Open Source.
  This software is free. Please see License for details.

  MAI (Hime Musha) archive format & functions

  Written by dsp2003.
}

unit AA_ARC_MAI;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Classes, Windows, Forms, Sysutils,
     FileStreamJ, JUtils, JReconvertor;

 { Supported archives implementation }
 procedure IA_ARC_MAI(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_MAI : boolean;
//  function SA_ARC_MAI(Mode : integer) : boolean;

  function MAI_UnRLE(iStream, oStream : TStream; StartPos, EndPos : int64; Mode : byte = 3) : boolean;

type
 TARCHdr = packed record
  Magic     : array[1..4] of char; // 'MAI'#10
  ArcSize   : longword;             // Размер файла архива
  FileCount : longword;             // Кол-во файлов
  DirFlags  : word;                 // $100 - нет директорий. $200 - есть
  DirCount  : word;                 // Кол-во записей директорий
 end;

 TARCDir = packed record
  Filename  : array[1..16] of char;
  Offset    : longword;
  Filesize  : longword;
 end;

 TARCDirRec = packed record
  DirName   : array[1..3] of char;
  Dummy     : byte;                 // Всегда равен 0
  DirPos    : longword;             // Начало директории в файловой таблице
 end;

 // Графика 'CM','BM','MA','AM'
 TxMHdr = packed record
  Magic    : array[1..2] of char;       // 0-1
  Filesize : longword;                  // 2-5
  Width    : word;                      // 6-7
  Height   : word;                      // 8-9
 end;

 TCMHdr = packed record
//CommonHdr : TMAIGraphCommHdr;         // 0-9
  Dummy0    : word;                     // 10-11
  BitDepth  : byte;                     // 12
  Unk0      : byte; // 1, флаг сжатия?  // 13
  Unk1      : byte; // 1                // 14
  Unk2      : byte; // 0                // 15
  DataPos   : longword; // 32           // 16-19
  DataSize  : longword;                 // 20-23
  Dummy     : int64; // выравнивание    // 24-31
 end;

 TAMHdr = packed record
//CommonHdr : TMAIGraphCommHdr;         // 0-9
  AWidth    : word;                     // 10-11
  AHeight   : word;                     // 12-13
  Dummy     : array[1..6] of byte; // 0 // 14-19
  BitDepth  : byte;                     // 20
  Unk0      : byte; // 1                // 21
  Unk1      : byte; // 2                // 22
  Unk2      : byte; // 0                // 23
  Unk3      : byte; // 1                // 24
  Unk4      : byte; // 0                // 25
  DataPos   : longword;                 // 26-29
  DataSize  : longword;                 // 30-33
  ADataPos  : longword;                 // 34-37
  ADataSize : longword;                 // 38-41
  Unk5      : word;                     // 42-43
  Dummy1    : longword; // выравнивание // 44-47
 end;

implementation

uses AnimED_Archives;

procedure IA_ARC_MAI;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'MAI (Hime Musha)';
  Ext  := '.arc';
  Stat := $F;
  Open := OA_ARC_MAI;
//Save := SA_ARC_MAI;
  Extr := EA_RAW;
  FLen := 16;
  SArg := 0;
  Ver  := $20110426;
 end;
end;

function OA_ARC_MAI;
var i,j : integer;
    Hdr  : TARCHdr;
    Dir  : TARCDir;
    DRec : array of TARCDirRec;
    minihead : array[1..2] of char;
    // debug
{    xMHdr : TxMHdr;
    CMHdr : TCMHdr;
    AMHdr : TAMHdr;
    tmpFile : TStream;}
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'MAI'#10 then Exit;
   RecordsCount := FileCount;

{*}Progress_Max(RecordsCount);

// Reading file table...
   for i := 1 to RecordsCount do begin

 {*}Progress_Pos(i);

    with Dir, RFA[i] do begin
     Read(Dir,SizeOf(Dir));
     RFA_1 := Offset;
     RFA_2 := FileSize;
     RFA_C := FileSize;
     for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
    end;

   end;

   // Работам с директориями
   if DirFlags = $200 then begin

    // +1 для "пустой" записи
    SetLength(DRec,DirCount+1);

    // Сперва читаем настоящие, затем устанавливаем пустую
    for j := 0 to DirCount-1 do begin
     Read(DRec[j],SizeOf(TArcDirRec));
     if DRec[j].DirPos > FileCount then Exit;
     if DRec[j].Dummy <> 0 then Exit;
    end;
    DRec[DirCount].DirPos := Hdr.FileCount;

    // Прибавляем директории к именам
    for j := 0 to DirCount-1 do begin
     for i := DRec[j].DirPos to DRec[j+1].DirPos-1 do begin
      RFA[i+1].RFA_3 := DRec[j].DirName + '\' + RFA[i+1].RFA_3;
     end;
    end;

   end;
   
   for i := 1 to RecordsCount do with RFA[i] do begin
    Seek(RFA_1,soBeginning);
    Read(minihead,sizeof(minihead));
    if minihead = 'RI' then RFA_3 := RFA_3 + '.wav';
    if minihead = 'Og' then RFA_3 := RFA_3 + '.ogg';
    if minihead = 'CM' then RFA_3 := RFA_3 + '.cmp';
    if minihead = 'AM' then RFA_3 := RFA_3 + '.ami';

    // Debug
{   if minihead = 'CM' then begin
     seek(-2,soCurrent);
     Read(xMHdr,SizeOf(xMHdr));
     Read(CMHdr,SizeOf(CMHdr));
     OpenFileStream(tmpFile,'C:\TEMP\'+ExtractFileName(RFA_3),fmCreate);
     MAI_UnRLE(ArchiveStream,tmpFile,RFA_1+CMHdr.DataPos,RFA_1+CMHdr.DataPos+CMHdr.DataSize,3);
     FreeAndNil(tmpFile);
    end;

    // Debug
    if minihead = 'AM' then begin
     seek(-2,soCurrent);
     Read(xMHdr,SizeOf(xMHdr));
     Read(AMHdr,SizeOf(AMHdr));
     OpenFileStream(tmpFile,'C:\TEMP\'+ExtractFileName(RFA_3),fmCreate);
     MAI_UnRLE(ArchiveStream,tmpFile,RFA_1+AMHdr.DataPos,RFA_1+AMHdr.DataPos+AMHdr.DataSize,3);
     MAI_UnRLE(ArchiveStream,tmpFile,RFA_1+AMHdr.ADataPos,RFA_1+AMHdr.ADataPos+AMHdr.ADataSize,1);
     FreeAndNil(tmpFile);
    end; }

   end;
   
  end;
 end;

 Result := True;

end;

{function SA_ARC_MAI;
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

  for i := 1 to RecordsCount do begin

{*}{Progress_Pos(i);

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

  for i := 1 to RecordsCount do begin
{*}{Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;}


function MAI_UnRLE(iStream, oStream : TStream; StartPos, EndPos : int64; Mode : byte = 3) : boolean;
var n : byte;
    a, i : longword;
begin
 if (iStream <> nil) and (oStream <> nil) then try
  iStream.Seek(StartPos,soBeginning);
  while iStream.Position < EndPos do begin
   a := 0;
   iStream.Read(a,1); // читаем управляющий код
   n := a and $7F;
   if (a and $80) <> 0 then begin
    iStream.Read(a,Mode); // читаем пиксель
    for i := 0 to n-1 do oStream.Write(a,Mode); // повторяем пиксель n раз
   end else begin
    // читаем и пишем пиксели n раз
    for i := 0 to n-1 do begin
     iStream.Read(a,Mode);
     oStream.Write(a,Mode);
    end; // for
   end; // if
  end; // while
  Result := True;
 except
  Result := False;
 end; // iStream/oStream
end;

end.