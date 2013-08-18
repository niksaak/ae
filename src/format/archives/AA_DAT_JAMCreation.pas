{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Anime Script System by JAMCreation

  Written by Nik & dsp2003.
}

unit AA_DAT_JAMCreation;

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
 procedure IA_DAT_JAMCreation(var ArcFormat : TArcFormats; index : integer);

 function OA_DAT_JAMCreation : boolean;
 function SA_DAT_JAMCreation(Mode : integer) : boolean;

type
  TJAMCreationHeader = packed record
    Magic : array[1..4] of char; // 'pack'
    FileCount : word;
  end;

  TJAMCreationTable = packed record
    FileName : array[1..$10] of char;
    Offset   : longword;
    FileSize : longword;
  end;

implementation

uses AnimED_Archives;

procedure IA_DAT_JAMCreation;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'JAMCreation Anime Script System';
  Ext  := '.dat';
  Stat := $0;
  Open := OA_DAT_JAMCreation;
  Save := SA_DAT_JAMCreation;
  Extr := EA_RAW;
  FLen := $10;
  SArg := 0;
  Ver  := $20091016;
 end;
end;

function OA_DAT_JAMCreation;
var Hdr   : TJAMCreationHeader;
    Table : array of TJAMCreationTable;
    i     : cardinal;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  if Hdr.Magic <> 'pack' then Exit;
  RecordsCount := Hdr.FileCount;
  SetLength(Table,RecordsCount);
  Read(Table[0],RecordsCount*sizeof(TJAMCreationTable));
 end;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_1 := Table[i-1].Offset;
  RFA[i].RFA_2 := Table[i-1].FileSize;
  RFA[i].RFA_C := Table[i-1].FileSize;
  RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
 end;
 SetLength(Table,0);

 Result := True;
end;

function SA_DAT_JAMCreation;
var i,j : integer;
    Hdr : TJAMCreationHeader;
    Dir : TJAMCreationTable;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'pack';
   FileCount := RecordsCount;
   UpOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;

   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_2;

   with Dir do begin
    Offset   := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   end;

   // пишем кусок таблицы
   Write(Dir,SizeOf(Dir));

  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;

 end; // with ArchiveStream

 Result := True;

end;

end.