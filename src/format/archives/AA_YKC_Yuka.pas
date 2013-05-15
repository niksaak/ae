{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Yuka Compiller archive format

  Written by Nik.
}

unit AA_YKC_Yuka;

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
 procedure IA_YKC_Yuka(var ArcFormat : TArcFormats; index : integer);

 function OA_YKC_Yuka : boolean;
 function SA_YKC_Yuka(Mode : integer) : boolean;

type
  TYukaHeader = packed record
    Magic       : array[1..8] of char; //YKC001#0#0
    Unk1        : cardinal; //$18 по всем архивам
    Dummy       : cardinal; //Нуль десу
    TableOffset : cardinal; //Смещение файловой таблицы
    TableLen    : cardinal; //Длина файловой таблицы
  end;

  TYukaTable = packed record
    NameOffset    : cardinal; //Смещение имени (ужснахъ, как это потом читать >_<)
    NameLen       : cardinal; //Длина имени. Имя нуль-терминировано
    FileOffset    : cardinal; //Смещение файла
    FileLen       : cardinal; //Длина файла
    MysteryNumber : cardinal; //Вообще, везде нуль
    // Но знаю я японцев, а также здравый смысл. Неспроста оно тут, неспроста 
  end;

implementation

uses AnimED_Archives;

procedure IA_YKC_Yuka;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Yuka Compiller';
  Ext  := '.ykc';
  Stat := $0;
  Open := OA_YKC_Yuka;
  Save := SA_YKC_Yuka;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_YKC_Yuka;
var Header : TYukaHeader;
    Table : Array of TYukaTable;
    stream : TStream;
    i, MinNameOffset, NamesLen : cardinal;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(TYukaHeader));
 if (Header.Magic <> 'YKC001'#0#0) or ((Header.TableLen mod $14) <> 0) then Exit;
 RecordsCount := Header.TableLen div $14;

 SetLength(Table,RecordsCount);
 ArchiveStream.Position := Header.TableOffset;
 ArchiveStream.Read(Table[0],Header.TableLen);
 MinNameOffset := 0;
 NamesLen := 0;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Table[i-1].FileOffset;
   RFA[i].RFA_2 := Table[i-1].FileLen;
   RFA[i].RFA_C := Table[i-1].FileLen;
{   RFA[i].RFA_E := false;
   RFA[i].RFA_Z := false;
   RFA[i].RFA_X := $0;}
   if (MinNameOffset = 0) or (MinNameOffset > Table[i-1].NameOffset) then MinNameOffset := Table[i-1].NameOffset;
   NamesLen := NamesLen + Table[i-1].NameLen;
 end;

// SetLength(Names, NamesLen);
 ArchiveStream.Position := MinNameOffset;
 stream := TMemoryStream.Create;
 stream.CopyFrom(ArchiveStream,NamesLen);
// ArchiveStream.Read(Names[0],NamesLen);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   SetLength(RFA[i].RFA_3,Table[i-1].NameLen);
   stream.Position := Table[i-1].NameOffset-MinNameOffset;
   stream.Read(RFA[i].RFA_3[1],Table[i-1].NameLen)
//   CopyMemory(@RFA[i].RFA_3[1],@Names[],Table[i-1].NameLen);
 end;

 SetLength(Table,0);
 FreeAndNil(stream);

 Result := True;
 
end;

function SA_YKC_Yuka;
var Header : TYukaHeader;
    Table : Array of TYukaTable;
    stream : TStream;
    i, CurLen : cardinal;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 'YKC001'#0#0;
 Header.Unk1 := $18;
 Header.Dummy := 0;
 Header.TableLen := RecordsCount*sizeof(TYukaTable);

 SetLength(Table,RecordsCount);
 stream := TMemoryStream.Create;

 UpOffset := sizeof(TYukaHeader);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
//  FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  RFA[i].RFA_1 := UpOffset;
  RFA[i].RFA_2 := FileDataStream.Size;
  Table[i-1].FileOffset := UpOffset;
  Table[i-1].FileLen := FileDataStream.Size;
  UpOffset := UpOffset + FileDataStream.Size;
  Table[i-1].MysteryNumber := 0;
  FreeAndNil(FileDataStream);
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  CurLen := length(RFA[i].RFA_3);
  stream.Write(RFA[i].RFA_3[1],CurLen);
  stream.Write(Header.Dummy,1);
  Table[i-1].NameOffset := UpOffset;
  Table[i-1].NameLen := CurLen+1;
  UpOffset := UpOffset + Table[i-1].NameLen;
 end;

 Header.TableOffset := UpOffset;
 ArchiveStream.Write(Header,sizeof(TYukaHeader));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
//  FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 stream.Position := 0;
 ArchiveStream.CopyFrom(stream,stream.Size);
 ArchiveStream.Write(Table[0],Header.TableLen);
 SetLength(Table,0);
 FreeAndNil(stream);

 Result := True;

end;

end.