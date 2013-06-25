{
  AE - VN Tools
¬© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  moonStone's mts Archive and Format Functions
  
  Written by Nik.
}

unit AA_PAK_MTS;

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
 procedure IA_PAK_MTS(var ArcFormat : TArcFormats; index : integer);

 function OA_PAK_MTS : boolean;
 function SA_PAK_MTS(Mode : integer) : boolean;
 
type
 TMTSHeader = packed record
   Magic : array[1..8] of char; // 'DATA$TOP'
   Dummy1 : array[1..$30] of char; // 0
   FilesCount : cardinal; // нужно отн€ть единицу, ибо перва€ запись - заголовок
   Dummy2 : cardinal; // 0
 end;
 
 TMTSTable = packed record
   FileName : array[1..$30] of char;
   Offset1  : cardinal; // смещение относительно FilesCount*$40 (o_O)
   Offset2  : cardinal; // смещение относительно FilesCount*$40 (O_o)
   FileSize : cardinal;
   Dummy    : cardinal; // 0
 end;

implementation

uses AnimED_Archives;

procedure IA_PAK_MTS;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Moonstone Engine';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_MTS;
  Save := SA_PAK_MTS;
  Extr := EA_RAW;
  FLen := $2F;
  SArg := 0;
  Ver  := $20100205;
 end;
end;

function OA_PAK_MTS;
var Header : TMTSHeader;
    Table : array of TMTSTable;
    i : cardinal;
begin
 Result := False;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> 'DATA$TOP' then Exit;
 SetLength(Table,Header.FilesCount-1);
 ArchiveStream.Read(Table[0],sizeof(TMTSTable)*(Header.FilesCount-1));
 RecordsCount := Header.FilesCount-1;
 UpOffset := Header.FilesCount*$40;
 
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Table[i-1].Offset1 + UpOffset;
   RFA[i].RFA_2 := Table[i-1].FileSize;
   RFA[i].RFA_C := Table[i-1].FileSize;
   RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
  end;
 SetLength(Table,0);
 Result := True;
end;

function SA_PAK_MTS;
var Header : TMTSHeader;
    Table : array of TMTSTable;
    i, curlen : cardinal;
begin
 RecordsCount := AddedFiles.Count;
 FillChar(Header,sizeof(Header),0);
 Header.Magic := 'DATA$TOP';
 Header.FilesCount := RecordsCount + 1;
 SetLength(Table,RecordsCount);
 FillChar(Table[0],RecordsCount*sizeof(TMTSTable),0);
 Upoffset := 0;
 
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  curlen := length(RFA[i].RFA_3);
  if(curlen >= $30) then curlen := $2F;

  CopyMemory(@Table[i-1].FileName[1], @RFA[i].RFA_3[1], curlen);
  Table[i-1].Offset1 := Upoffset;
  Table[i-1].Offset2 := Upoffset;
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table[i-1].FileSize := FileDataStream.Size;
  Upoffset := Upoffset + FileDataStream.Size;
  FreeAndNil(FileDataStream);
 end;
 
 ArchiveStream.Write(Header,sizeof(Header));
 ArchiveStream.Write(Table[0],RecordsCount*sizeof(TMTSTable));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 SetLength(Table, 0);
 Result := True;
end;

end.