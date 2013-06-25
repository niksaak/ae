{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  Palette PACK2 archive format & functions

  Written by Nik.
}

unit AA_PAK_PACK2;

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
 procedure IA_PAK_PACK2(var ArcFormat : TArcFormats; index : integer);

 function OA_PAK_PACK2 : boolean;
 function SA_PAK_PACK2(Mode : integer) : boolean;

type
 TPack2Header = packed record
  ver : byte; // 5
  Magic : array[1..5] of char; // 'PACK2'
  FilesCount : cardinal;
 end;
{
 TPack2Table = packed record
  NameLen : byte;
  FileName : string;
  FileOffset : cardinal;
  FileSize : cardinal;
 end;}// Полностью запись выглядит так

 TPack2PartialTable = packed record
  FileOffset : cardinal;
  FileSize : cardinal;
 end;

implementation

uses AnimED_Archives;

procedure IA_PAK_PACK2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'PACK2';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_PACK2;
  Save := SA_PAK_PACK2;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_PAK_PACK2;
var Header : TPack2Header;
    Table : TPack2PartialTable;
    Len : byte;
    i, j : cardinal;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(TPack2Header));

 if (Header.Magic <> 'PACK2') or (Header.ver <> 5) then Exit;
  
 RecordsCount := Header.FilesCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   ArchiveStream.Read(Len,1);
   SetLength(RFA[i].RFA_3,Len);
   ArchiveStream.Read(RFA[i].RFA_3[1],Len);
   for j := 1 to Len do RFA[i].RFA_3[j] := char(byte(RFA[i].RFA_3[j]) xor $FF);
   ArchiveStream.Read(Table,sizeof(TPack2PartialTable));
   RFA[i].RFA_1 := Table.FileOffset;
   RFA[i].RFA_2 := table.FileSize;
   RFA[i].RFA_C := Table.FileSize;
 end;

 Result := True;

end;

function SA_PAK_PACK2;
var Header : TPack2Header;
    Table : TPack2PartialTable;
    LBytes : array of byte;
    Len : cardinal;
    i, j : cardinal;
begin
 RecordsCount := AddedFiles.Count;
 Header.ver := 5;
 Header.Magic := 'PACK2';
 Header.FilesCount := RecordsCount;

 ArchiveStream.Write(Header,sizeof(TPack2Header));
 SetLength(LBytes,RecordsCount);

 Upoffset := sizeof(TPack2Header);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  Len := Length(RFA[i].RFA_3);
  for j := 1 to Len do RFA[i].RFA_3[j] := char(byte(RFA[i].RFA_3[j]) xor $FF);
  if Len >= $FF then LBytes[i-1] := $FF else LBytes[i-1] := Byte(Len);
  Upoffset := Upoffset + 9 + LBytes[i-1]; // длина имени(байт) + имя + sizeof(TPack2PartialTable)
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
//  FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.Write(LBytes[i-1],1);
  ArchiveStream.Write(RFA[i].RFA_3[1],LBytes[i-1]);
  Table.FileSize := FileDataStream.Size;
  Table.FileOffset := Upoffset;
  Upoffset := Upoffset + Table.FileSize;
  ArchiveStream.Write(Table,sizeof(TPack2PartialTable));
  FreeAndNil(FileDataStream);
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 SetLength(LBytes,0);  
 Result := True;
end;

end.