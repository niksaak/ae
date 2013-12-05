{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Gleam of Force Archive Format

  Written by Nik.
}

unit AA_DAT_GoF;

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
 procedure IA_DAT_GoF(var ArcFormat : TArcFormats; index : integer);

 function OA_DAT_GoF : boolean;
 function SA_DAT_GoF(Mode : integer) : boolean;

 procedure GoF_Table_obfuscator(stream : TStream; FilesCount : longword);
 
type
  TGofHeader = packed record
    Magic : longword; // 1
    FilesCount : longword; // поксорено на $E3DF59AC
  end;
  {Размер элемента - $44 (68)}

  TGofTable = packed record
    FileName : Array[1..$3C] of char;
    FileOffset : longword;
    FileSize : longword;
  end;

implementation

uses AnimED_Archives;

procedure IA_DAT_GoF;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Gleam of Force';
  Ext  := '.dat';
  Stat := $0;
  Open := OA_DAT_GoF;
  Save := SA_DAT_GoF;
  Extr := EA_RAW;
  FLen := $3C;
  SArg := 0;
  Ver  := $20090924;
 end;
end;

procedure GoF_Table_obfuscator;
var    i,j, ml : longword;
       bt : byte;
begin
 for i:=1 to FilesCount do
 begin
   for j:=1 to $3B do
   begin
     ml := (i-1)*(j-1)*3 + $3D;
     stream.Read(bt,1);
     stream.Position := stream.Position - 1;
     bt := bt xor Byte(ml and $FF);
     stream.Write(bt,1);
   end;
   stream.Position := stream.Position + 5;
   stream.Read(ml,4);
   stream.Position := stream.Position - 4;
   ml := ml xor $E3DF59AC;
   stream.Write(ml,4);
 end;
end;

function OA_DAT_GoF;
var Header : TGofHeader;
    TableStream : TStream;
    i : longword;
    FileName : Array[1..$3C] of char;
begin
 Result := False;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 Header.FilesCount := Header.FilesCount xor $E3DF59AC;
 if (Header.Magic <> 1) or (Header.FilesCount = 0) or ((Header.FilesCount*$44)>=ArchiveStream.Size) then Exit;
 TableStream := TMemoryStream.Create;
 TableStream.CopyFrom(ArchiveStream,Header.FilesCount*$44);
 TableStream.Position := 0;
 GoF_Table_obfuscator(TableStream,Header.FilesCount);
 TableStream.Position := 0;
 RecordsCount := Header.FilesCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   TableStream.Read(FileName[1],$3C);
   TableStream.Read(RFA[i].RFA_1,4);
   TableStream.Read(RFA[i].RFA_C,4);
   RFA[i].RFA_2 := RFA[i].RFA_C;
   RFA[i].RFA_3 := String(Pchar(@FileName[1]));
 end;
 FreeAndNil(TableStream);
 Result := True;
end;

function SA_DAT_GoF;
var Header : TGofHeader;
    Table : TGofTable;
    i, curlen: longword;
    TableStream : TStream;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 1;
 Header.FilesCount := RecordsCount xor $E3DF59AC;
 Upoffset := sizeof(Header) + RecordsCount*sizeof(Table);
 TableStream := TMemoryStream.Create;
 
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
  curlen := length(RFA[i].RFA_3);
  if(curlen >= $3C) then curlen := $3B;
  FillChar(Table,$3C,0);
  CopyMemory(@Table.FileName[1], @RFA[i].RFA_3[1], curlen);
  Table.FileOffset := Upoffset;
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table.FileSize := FileDataStream.Size;
  Upoffset := Upoffset + FileDataStream.Size;
  FreeAndNil(FileDataStream);
  TableStream.Write(Table,sizeof(Table));
 end;
 
 TableStream.Position := 0;
 GoF_Table_obfuscator(TableStream,RecordsCount);
 TableStream.Position := 0;
 ArchiveStream.Write(Header,sizeof(Header));
 ArchiveStream.CopyFrom(TableStream,TableStream.Size);
 FreeAndNil(TableStream);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;
 Result := True;
end;

end.