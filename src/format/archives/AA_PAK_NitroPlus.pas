{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Nitro+ archive format

  Written by Nik.
}

unit AA_PAK_NitroPlus;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms,
     ZLibEx;

 { Supported archives implementation }
 procedure IA_PAK_NitroPlus_Pak1(var ArcFormat : TArcFormats; index : 
integer);
 function OA_PAK_NitroPlus_Pak1 : boolean;
 function SA_PAK_NitroPlus_Pak1(Mode : integer) : boolean;

 function EA_PAK_NitroPlus_Pak1(FileRecord : TRFA) : boolean;

 procedure IA_PAK_NitroPlus_Pak2(var ArcFormat : TArcFormats; index : 
integer);
 function OA_PAK_NitroPlus_Pak2 : boolean;
 function SA_PAK_NitroPlus_Pak2(Mode : integer) : boolean;

type
  TNitroPlusPak1Header = packed record
    Magic : cardinal; // 1
    FilesCount : cardinal;
    TableUnpackedSize : cardinal;
    TablePackedSize : cardinal;
  end;

  TNitroPlusPak2Header = packed record
    Pak1Header : TNitroPlusPak1Header; // Magic = 2
    Unk : array[1..$104] of char;
  end;

{  TNitroPlusPak1Table = packed record
    NameLen : cardinal;
    FileName : string;
    NitroPlusPak1TableFixed : TNitroPlusPak1TableFixed;
  end;}

  TNitroPlusPak1TableFixed = packed record
    FileOffset : cardinal; // от конца таблицы
    UnpackedSize : cardinal;
    UnpackedSize2 : cardinal;
    PackFlag : cardinal; // ==0 значит непожато
    PackedSize : cardinal;
  end;

implementation

uses AnimED_Archives;

procedure IA_PAK_NitroPlus_Pak1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Nitro+ Pak1';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_NitroPlus_Pak1;
  Save := SA_PAK_NitroPlus_Pak1;
  Extr := EA_PAK_NitroPlus_Pak1;
  FLen := 0;
  SArg := 0;
  Ver  := $20100413;
 end;
end;

procedure IA_PAK_NitroPlus_Pak2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Nitro+ Pak2';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_NitroPlus_Pak2;
  Save := SA_PAK_NitroPlus_Pak2;
  Extr := EA_PAK_NitroPlus_Pak1;
  FLen := 0;
  SArg := 0;
  Ver  := $20100413;
 end;
end;

function OA_PAK_NitroPlus_Pak1;
var Head : TNitroPlusPak1Header;
    Table : TNitroPlusPak1TableFixed;
    tmpStreamC, tmpStream : TStream;
    i, len : cardinal;
begin
  Result := False;
  ArchiveStream.Position := 0;
  ArchiveStream.Read(Head, sizeof(Head));
  if Head.Magic <> $1 then Exit;
  if Head.TablePackedSize = 0 then Exit;
  if Head.TableUnpackedSize = 0 then Exit;
  if Head.TablePackedSize > ArchiveStream.Size then Exit;
  tmpStreamC := TMemoryStream.Create;
  tmpStreamC.CopyFrom(ArchiveStream,Head.TablePackedSize);
  tmpStreamC.Position := 0;
  tmpStream := TMemoryStream.Create;

  ZDecompressStream(tmpStreamC, tmpStream);
  tmpStream.Position := 0;
  FreeAndNil(tmpStreamC);

  RecordsCount := Head.FilesCount;
  UpOffset := sizeof(Head) + Head.TablePackedSize;

{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   if (tmpStream.Size - tmpStream.Position) < sizeof(Table) then
   begin
     FreeAndNil(tmpStream);
     Exit;
   end;
   tmpStream.Read(len, 4);
   SetLength(RFA[i].RFA_3, len);
   tmpStream.Read(RFA[i].RFA_3[1], len);
   tmpStream.Read(Table, sizeof(Table));
   RFA[i].RFA_1 := UpOffset + Table.FileOffset;
   RFA[i].RFA_2 := Table.UnpackedSize;
   RFA[i].RFA_C := Table.PackedSize;
   if (RFA[i].RFA_1 > ArchiveStream.Size) or (RFA[i].RFA_2 > 
ArchiveStream.Size) then Exit;
   if Table.PackedSize = 0 then RFA[i].RFA_C := Table.UnpackedSize;
   if Table.PackFlag <> 0 then
   begin
     RFA[i].RFA_Z := True;
     RFA[i].RFA_X := acZlib;
   end;
  end;
  FreeAndNil(tmpStream);
  Result := True;
end;

function OA_PAK_NitroPlus_Pak2;
var Head : TNitroPlusPak2Header;
    Table : TNitroPlusPak1TableFixed;
    tmpStreamC, tmpStream : TStream;
    i, len : cardinal;
begin
  Result := False;
  ArchiveStream.Position := 0;
  ArchiveStream.Read(Head, sizeof(Head));
  if Head.Pak1Header.Magic <> $2 then Exit;
  tmpStreamC := TMemoryStream.Create;
  tmpStreamC.CopyFrom(ArchiveStream,Head.Pak1Header.TablePackedSize);
  tmpStreamC.Position := 0;
  tmpStream := TMemoryStream.Create;

  ZDecompressStream(tmpStreamC, tmpStream);
  tmpStream.Position := 0;
  FreeAndNil(tmpStreamC);

  RecordsCount := Head.Pak1Header.FilesCount;
  UpOffset := sizeof(Head) + Head.Pak1Header.TablePackedSize;

{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   if (tmpStream.Size - tmpStream.Position) < sizeof(Table) then
   begin
     FreeAndNil(tmpStream);
     Exit;
   end;
   tmpStream.Read(len, 4);
   SetLength(RFA[i].RFA_3, len);
   tmpStream.Read(RFA[i].RFA_3[1], len);
   tmpStream.Read(Table, sizeof(Table));
   RFA[i].RFA_1 := UpOffset + Table.FileOffset;
   RFA[i].RFA_2 := Table.UnpackedSize;
   RFA[i].RFA_C := Table.PackedSize;
   if (RFA[i].RFA_1 > ArchiveStream.Size) or (RFA[i].RFA_C > 
ArchiveStream.Size) then Exit;
   if Table.PackedSize = 0 then RFA[i].RFA_C := Table.UnpackedSize;
   if Table.PackFlag <> 0 then
   begin
     RFA[i].RFA_Z := True;
     RFA[i].RFA_X := acZlib;
   end;
  end;
  FreeAndNil(tmpStream);
  Result := True;
end;

function SA_PAK_NitroPlus_Pak1;
var Header : TNitroPlusPak1Header;
    Table : TNitroPlusPak1TableFixed;
    tmpStreamC, tmpStream : TStream;
    i, len : cardinal;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := $1;
 Header.FilesCount := RecordsCount;
 UpOffset := 0;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  
OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(FileDataStream, FileDataStream.Size);
  tmpStream.Position  := 0;
  tmpStreamC := TMemoryStream.Create;
  ZCompressStream(tmpStream, tmpStreamC);
  RFA[i].RFA_1 := UpOffset;
  RFA[i].RFA_2 := tmpStream.Size;
  RFA[i].RFA_C := tmpStreamC.Size;
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  UpOffset := UpOffset + tmpStreamC.Size;
  FreeAndNil(FileDataStream);
  FreeAndNil(tmpStreamC);
  FreeAndNil(tmpStream);
  { Nik: Да, разработчики дебилы. Ну вы посудите, кто, как не идиот
    помещает пожатый поток файловой таблицы при возможности пожатия
    файлов ПЕРЕД файлами?!
    
    dsp2003: Yes, developers of this engine are assholes. Why? Well,
    think about it: who in sane mind would put compressed file table
    before the files themselves when they CAN be compressed in the
    first place?!
  }
 end;

 tmpStream := TMemoryStream.Create;
 tmpStreamC := TMemoryStream.Create;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  len := length(RFA[i].RFA_3);
  tmpStream.Write(len,4);
  tmpStream.Write(RFA[i].RFA_3[1],len);
  Table.FileOffset := RFA[i].RFA_1;
  Table.UnpackedSize := RFA[i].RFA_2;
  Table.PackedSize := RFA[i].RFA_C;
  Table.PackFlag := 1;
  Table.UnpackedSize2 := Table.UnpackedSize;
  tmpStream.Write(Table,sizeof(Table));
 end;

 tmpStream.Position := 0;
 ZCompressStream(tmpStream, tmpStreamC);
 Header.TablePackedSize := tmpStreamC.Size;
 Header.TableUnpackedSize := tmpStream.Size;
 ArchiveStream.Write(Header,sizeof(Header));
 tmpStreamC.Position := 0;
 ArchiveStream.CopyFrom(tmpStreamC, tmpStreamC.Size);
 FreeAndNil(tmpStreamC);
 FreeAndNil(tmpStream);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  
OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(FileDataStream, FileDataStream.Size);
  tmpStream.Position  := 0;
  tmpStreamC := TMemoryStream.Create;
  ZCompressStream(tmpStream, tmpStreamC);
  tmpStreamC.Position  := 0;
  ArchiveStream.CopyFrom(tmpStreamC,tmpStreamC.Size);
  FreeAndNil(FileDataStream);
  FreeAndNil(tmpStreamC);
  FreeAndNil(tmpStream);
 end;

 Result := True;
end;

function SA_PAK_NitroPlus_Pak2;
var Header : TNitroPlusPak2Header;
    Table : TNitroPlusPak1TableFixed;
    tmpStreamC, tmpStream : TStream;
    i, len : cardinal;
begin
 FillChar(Header, sizeof(Header), 0);
 RecordsCount := AddedFiles.Count;
 Header.Pak1Header.Magic := $2;
 Header.Pak1Header.FilesCount := RecordsCount;
 UpOffset := 0;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  
OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(FileDataStream, FileDataStream.Size);
  tmpStream.Position  := 0;
  tmpStreamC := TMemoryStream.Create;
  ZCompressStream(tmpStream, tmpStreamC);
  RFA[i].RFA_1 := UpOffset;
  RFA[i].RFA_2 := tmpStream.Size;
  RFA[i].RFA_C := tmpStreamC.Size;
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  UpOffset := UpOffset + tmpStreamC.Size;
  FreeAndNil(FileDataStream);
  FreeAndNil(tmpStreamC);
  FreeAndNil(tmpStream);
  {facepalm.jpg, дубль два}
 end;

 tmpStream := TMemoryStream.Create;
 tmpStreamC := TMemoryStream.Create;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  len := length(RFA[i].RFA_3);
  tmpStream.Write(len,4);
  tmpStream.Write(RFA[i].RFA_3[1],len);
  Table.FileOffset := RFA[i].RFA_1;
  Table.UnpackedSize := RFA[i].RFA_2;
  Table.PackedSize := RFA[i].RFA_C;
  Table.PackFlag := 1;
  Table.UnpackedSize2 := Table.UnpackedSize;
  tmpStream.Write(Table,sizeof(Table));
 end;

 tmpStream.Position := 0;
 ZCompressStream(tmpStream, tmpStreamC);
 Header.Pak1Header.TablePackedSize := tmpStreamC.Size;
 Header.Pak1Header.TableUnpackedSize := tmpStream.Size;
 ArchiveStream.Write(Header,sizeof(Header));
 tmpStreamC.Position := 0;
 ArchiveStream.CopyFrom(tmpStreamC, tmpStreamC.Size);
 FreeAndNil(tmpStreamC);
 FreeAndNil(tmpStream);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  
OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(FileDataStream, FileDataStream.Size);
  tmpStream.Position  := 0;
  tmpStreamC := TMemoryStream.Create;
  ZCompressStream(tmpStream, tmpStreamC);
  tmpStreamC.Position  := 0;
  ArchiveStream.CopyFrom(tmpStreamC,tmpStreamC.Size);
  FreeAndNil(FileDataStream);
  FreeAndNil(tmpStreamC);
  FreeAndNil(tmpStream);
 end;

 Result := True;
end;

function EA_PAK_NitroPlus_Pak1;
var TempoStream, TempoStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then
 begin
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_X of
   acZlib  : begin
            TempoStream := TMemoryStream.Create;
            TempoStream2 := TMemoryStream.Create;
            TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
            TempoStream.Position := 0;
            ZDecompressStream(TempoStream, TempoStream2);
            FreeAndNil(TempoStream);
            TempoStream2.Position := 0;
            FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
            FreeAndNil(TempoStream2);
           end;
   else
   begin
     FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
   end;
  end;
  Result := True;
 end;
end;

end.
