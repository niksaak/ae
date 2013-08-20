{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  "Game Script Player for Win32" by HyperWorks

  Written by Nik.
}

unit AA_PAK_ScriptPlayer;

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
 procedure IA_PAK_ScriptPlayer(var ArcFormat : TArcFormats; index : integer);

 function OA_PAK_ScriptPlayer : boolean;
 function SA_PAK_ScriptPlayer(Mode : integer) : boolean;

type
  TScriptPlayerHeader = packed record
    Magic : array[1..4] of char; //'pack'
    TableSize : cardinal; // размер файловой таблицы
  end;

{  TScriptPlayerTable = packed record
    FOffset : cardinal;
    FLength : cardinal;
    NameLen : byte;
    FName : string;
  end;} // Настоящий элемент таблицы

  TScriptPlayerPartialTable = packed record
    FOffset : cardinal;
    FLength : cardinal;
  end;

implementation

uses AnimED_Archives;

procedure IA_PAK_ScriptPlayer;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Game Script Player';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_ScriptPlayer;
  Save := SA_PAK_ScriptPlayer;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090829;
 end;
end;

function OA_PAK_ScriptPlayer;
var Header : TScriptPlayerHeader;
    Table : TScriptPlayerPartialTable;
    skip : cardinal;
    NameLen : byte;
    stream : TStream;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header, sizeof(Header));

 if (Header.Magic <> 'pack') or (Header.TableSize >= ArchiveStream.Size) then Exit;

 stream := TMemoryStream.Create;
 stream.CopyFrom(ArchiveStream,Header.TableSize);
 stream.Position := 0;

 RecordsCount := 0;

{*}Progress_Max(100);
 while stream.Read(Table,sizeof(Table)) > 0 do
 begin
{*}Progress_Pos(Trunc((stream.Position / stream.size)*100));
   if (Table.FOffset = 0) and (Table.FLength = 0) then break;
   Inc(RecordsCount);
   RFA[RecordsCount].RFA_1 := Table.FOffset;
   RFA[RecordsCount].RFA_2 := Table.FLength;
   RFA[RecordsCount].RFA_C := Table.FLength;
   stream.Read(NameLen,1);
   SetLength(RFA[RecordsCount].RFA_3,NameLen);
   stream.Read(RFA[RecordsCount].RFA_3[1],NameLen);
   skip := SizeMod(sizeof(Table)+NameLen+1,8);
   if skip = 0 then skip := 8;
   stream.Position := stream.Position + skip;
 end;
 Progress_Pos(100);

 FreeAndNil(stream);

 Result := True;

end;

function SA_PAK_ScriptPlayer;
var Header : TScriptPlayerHeader;
    Table : TScriptPlayerPartialTable;
    i : cardinal;
    NameLen : byte;
    stream : TStream;
    Dummy : array[0..7] of byte;
begin
 Header.Magic := 'pack';
 FillChar(Dummy[0],8,0);
 UpOffset := sizeof(Header);
 RecordsCount := AddedFiles.Count;
 stream := TMemoryStream.Create;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   RFA[i].RFA_C := Length(RFA[i].RFA_3);
   RFA[i].RFA_1 := 1 + Sizeof(Table) + RFA[i].RFA_C;
   RFA[i].RFA_2 := SizeMod(RFA[i].RFA_1,8);
   if RFA[i].RFA_2 = 0 then RFA[i].RFA_2 := 8;
   UpOffset := UpOffset + RFA[i].RFA_1 + RFA[i].RFA_2;
 end;
 Header.TableSize := UpOffset;
 UpOffset := UpOffset + 8;
 ArchiveStream.Write(Header,Sizeof(Header));
 ArchiveStream.Position := UpOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1]);
   Table.FOffset := UpOffset;
   Table.FLength := FileDataStream.Size;
   ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
   stream.Write(Table,sizeof(Table));
   NameLen := Byte(RFA[i].RFA_C);
   stream.Write(NameLen,1);
   stream.Write(RFA[i].RFA_3[1],NameLen);
   stream.Write(Dummy[0],RFA[i].RFA_2);
   RFA[i].RFA_1 := SizeMod(FileDataStream.Size,8);
   UpOffset := UpOffset + Table.FLength + RFA[i].RFA_1;
   ArchiveStream.Write(Dummy[0],RFA[i].RFA_1);
   FreeAndNil(FileDataStream);
 end;

 stream.Write(Dummy[0],8);
 stream.Position := 0;
 ArchiveStream.Position := Sizeof(Header);
 ArchiveStream.CopyFrom(stream,stream.Size);
 FreeAndNil(stream);

 Result := True;
end;

end.