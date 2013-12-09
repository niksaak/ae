{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Blade Engine PKD archive format & functions

  Written by Nik & dsp2003.
}

unit AA_PKD_Blade_Engine;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_PKD_BladeEngine(var ArcFormat : TArcFormats; index : integer);

 function OA_PKD_BladeEngine : boolean;
 function SA_PKD_BladeEngine(Mode : integer) : boolean;

type
 TBladeEngineHeader = packed record
  Magic      : longword; //"PACK"
  FilesCount : longword;
 end;

 TBladeEngineTable = packed record
  FileName   : array[1..$80] of char;
  FLength    : longword;
  FOffset    : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_PKD_BladeEngine;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Blade Engine';
  Ext  := '.pkd';
  Stat := $0;
  Open := OA_PKD_BladeEngine;
  Save := SA_PKD_BladeEngine;
  Extr := EA_RAW;
  FLen := $80;
  SArg := 0;
  Ver  := $20091114;
 end;
end;

function OA_PKD_BladeEngine;
var Header : TBladeEngineHeader;
    Table  : TBladeEngineTable;
    stream : TStream;
    i      : longword;
label StopThis;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Header,SizeOf(TBladeEngineHeader));
 end;

 // if Header <> 'PACK' then goto StopThis;
 if Header.Magic <> $4B434150 then Exit;
 
 RecordsCount := Header.FilesCount;
 
 stream := TMemoryStream.Create;
 stream.CopyFrom(ArchiveStream,RecordsCount*Sizeof(TBladeEngineTable));
 stream.Position := 0;
 BlockXOR(stream, $C5);
 stream.Position := 0;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  stream.Read(Table,sizeof(TBladeEngineTable));
  with RFA[i] do begin
   RFA_3 := String(PChar(@Table.FileName));
   RFA_1 := Table.FOffset;
   if RFA_1 > ArchiveStream.Size then Exit;
   RFA_2 := Table.FLength;
   if RFA_2 > ArchiveStream.Size then Exit;
   RFA_C := Table.FLength;
   RFA_E := True;
// RFA_Z := false;
// RFA_X := $0;
// RFA_Z по умолчанию всегда False
// RFA_X имеет два назначения - идентификатор сжатия И идентификатор XOR'а.
// Следовательно, писать новую функцию распаковки для него НЕ нужно. Достаточно
// лишь указать:
   RFA_X := $C5;
  end; // with RFA[i]
 end;

 Result := True;

end;

function SA_PKD_BladeEngine;
var Dir : TBladeEngineTable;
    Hdr : TBladeEngineHeader;
    tmpStream : TStream;
    i, j, l : longword;
begin

 RecordsCount := AddedFiles.Count;

 with Hdr do begin
  Magic := $4B434150;
  FilesCount := RecordsCount;
 end;

 UpOffset := RecordsCount * SizeOf(TBladeEngineTable) + SizeOf(TBladeEngineHeader);

 tmpStream := TMemoryStream.Create;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  l := Length(AddedFiles.Strings[i-1]);

  with Dir do begin
   if l > $80 then l := $80;
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to l do FileName[j] := AddedFiles.Strings[i-1][j];

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   FLength := FileDataStream.Size;
   FOffset := UpOffset;
   UpOffset := UpOffset + FLength;
   FreeAndNil(FileDataStream);
   tmpStream.Write(Dir,SizeOf(Dir));
  end;
 end;

 tmpStream.Position := 0;
 BlockXOR(tmpStream, $C5);
 tmpStream.Position := 0;

 with ArchiveStream do begin
  Write(Hdr,SizeOf(Hdr));
  CopyFrom(tmpStream,RecordsCount * SizeOf(TBladeEngineTable));
  FreeAndNil(tmpStream);

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   tmpStream := TMemoryStream.Create;

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   tmpStream.CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);

   tmpStream.Seek(0,soBeginning);
   BlockXORIO(tmpStream, ArchiveStream, $C5, False);
{   tmpStream.Seek(0,soBeginning);
   CopyFrom(tmpStream,tmpStream.Size);}
   FreeAndNil(tmpStream);
  end;

 end;
 Result := True;
// Поток архива освобождается ВНЕ функции создания, поэтому закомментировано.
// Заметка: если несколько раз попытаться освободить уже освобождённый поток,
// можно легко нарваться на исключение =_=
// FreeAndNil(ArchiveStream);
end;

end.