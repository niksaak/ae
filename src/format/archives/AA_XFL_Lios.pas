{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Used in Liar Soft games
  
  Written by Nik.
}

unit AA_XFL_Lios;

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
 procedure IA_XFL_Lios(var ArcFormat : TArcFormats; index : integer);

 function OA_XFL_Lios : boolean;
 function SA_XFL_Lios(Mode : integer) : boolean;

type

 TLiosXFLHeader = packed record
  Magic      : word; // 'LB' ($424C)
  Version    : word; // 1
  TableSize  : longword;
  FilesCount : longword;
 end;

 TLiosXFLTable = packed record
  FileName   : array[1..$20] of char;
  FOffset    : longword; // отноительно файловой таблицы
  FSize      : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_XFL_Lios;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'RScripter / Lios (Liar-Soft)';
  Ext  := '.xfl';
  Stat := $0;
  Open := OA_XFL_Lios;
  Save := SA_XFL_Lios;
  Extr := EA_RAW;
  FLen := $20;
  SArg := 0;
  Ver  := $20090905;
 end;
end;

function OA_XFL_Lios;
var Header : TLiosXFLHeader;
    Table : array of TLiosXFLTable;
    i : longword;
begin
 Result := False;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if (Header.Magic <> $424C) or (Header.Version <> 1) then Exit;

 RecordsCount := Header.FilesCount;
 SetLength(Table, Header.FilesCount);
 ArchiveStream.Read(Table[0],Header.TableSize);
 UpOffset := Header.TableSize + sizeof(Header);
{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := UpOffset + Table[i-1].FOffset;
   RFA[i].RFA_2 := Table[i-1].FSize;
   RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
   RFA[i].RFA_C := RFA[i].RFA_2;
 end;
 SetLength(Table, 0);
 Result := True;
end;

function SA_XFL_Lios;
var Header : TLiosXFLHeader;
    Table : array of TLiosXFLTable;
    Name : string;
    i, len : longword;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := $424C;
 Header.Version := 1;
 Header.FilesCount := RecordsCount;
 Header.TableSize := RecordsCount*sizeof(TLiosXFLTable);
 UpOffset := 0;

 ArchiveStream.Write(Header,sizeof(Header));
 SetLength(Table, RecordsCount);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   Name := ExtractFileName(AddedFiles.Strings[i-1]);
   len := Length(Name);
   if len >= $20 then len := $19;
   CopyMemory(@Table[i-1].FileName[1], @Name[1], len);
   Table[i-1].FOffset := UpOffset;
   UpOffset := UpOffset + FileDataStream.Size;
   Table[i-1].FSize := FileDataStream.Size;
   FreeAndNil(FileDataStream);
 end;
 ArchiveStream.Write(Table[0],Header.TableSize);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
 end;
 Result := True;
end;

end.