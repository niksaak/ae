{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Rune Soft archive format

  Written by Nik.
}

unit AA_G_RUNE;

interface

uses AA_RFA,
     AnimED_Config,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Generic_LZXX,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_G_Rune(var ArcFormat : TArcFormats; index : integer);

 function OA_G_Rune : boolean;
 function SA_G_Rune(Mode : integer) : boolean;
 function EA_G_Rune(FileRecord : TRFA) : boolean;
 
type
   TRuneHeader = packed record
     Magic : array[1..8] of char; // 'GML_ARC'#0
     DataOffset : cardinal; // Начало данных
     TableDecryptedLen : cardinal; // Размер расшифрованной таблицы
     TableCryptedLen : cardinal; // Размер зашифрованной таблицы
   end;

   TRuneTableHeader = packed record
     key : array[1..$100] of char; // Наверное, какой-то ключ
     FileCount : cardinal; // кол-во файлов
   end;
{
   TRuneTable = packed record
     NameLen : cardinal; // Длина имени. имя НЕ нуль терминировано
     Name : string;
     FOffset : cardinal; // Смещение относительно начала данных
     FLength : cardinal; // Размер файла
     sig : array[1..4] of char; // сигнатура файла
   end;}
// Но мы не будем юзать эту структуру ибо мы её просто там не прочитаем
   TRunePartialTable = packed record
     FOffset : cardinal; // Смещение относительно начала данных
     FLength : cardinal; // Размер файла
     sig : array[1..4] of char; // сигнатура файла
   end;
// Остальное будет читаться отдельно. Всё равно из TMemoryStream же


implementation

uses AnimED_Archives;

procedure IA_G_Rune;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Rune';
  Ext  := '.g';
  Stat := $0;
  Open := OA_G_Rune;
  Save := SA_G_Rune;
  Extr := EA_G_Rune;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_G_Rune;
var Header:TRuneHeader;
    THeader : TRuneTableHeader;
  stream, table_s : TStream;
    Table : TRunePartialTable;
    i, j, NameLen : cardinal;
begin
 Result := False;
 with ArchiveStream do begin
   Position := 0;
   Read(Header,sizeof(TRuneHeader));
 end;

 if Header.Magic <> 'GML_ARC'#0 then Exit;

 stream := TMemoryStream.Create;
 table_s := TMemoryStream.Create;

 stream.CopyFrom(ArchiveStream,Header.TableCryptedLen);
 stream.Position := 0;
 BlockXOR(stream, $FF);
 stream.Position := 0;

 GLZSSDecode_m(stream,table_s,stream.Size,$FEE,$FFF);
 FreeAndNil(stream);

 table_s.Position := 0;
 table_s.Read(THeader,sizeof(TRuneTableHeader));
 RecordsCount := THeader.FileCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   table_s.Read(NameLen,4);
   SetLength(RFA[i].RFA_3,NameLen);
   table_s.Read(RFA[i].RFA_3[1],NameLen);
   for j := 1 to Length(RFA[i].RFA_3) do if RFA[i].RFA_3[j] = '/' then RFA[i].RFA_3[j] := '\';
   table_s.Read(Table,sizeof(TRunePartialTable));
   RFA[i].RFA_1 := Header.DataOffset + Table.FOffset;
   RFA[i].RFA_2 := Table.FLength;
   RFA[i].RFA_C := Table.FLength;
   SetLength(RFA[i].RFA_T,1);
   SetLength(RFA[i].RFA_T[0],1);
   RFA[i].RFA_T[0][0] := Table.sig;
 end;

 FreeAndNil(table_s);

 SetLength(RFA[0].RFA_T,1);
 SetLength(RFA[0].RFA_T[0],1);
 SetLength(RFA[0].RFA_T[0][0],$100);
 CopyMemory(@RFA[0].RFA_T[0][0][1],@THeader.key[1],$100);

 Result := True;

end;

function EA_G_Rune;
var TempoStream, TempoStream2 : TStream;
  b : byte;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  TempoStream := TMemoryStream.Create;
  TempoStream2 := TMemoryStream.Create;
  TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  TempoStream.Position := 0;
  while TempoStream.Position < TempoStream.Size do begin
   TempoStream.Read(b,1);
   TempoStream2.Write(RFA[0].RFA_T[0][0][b+1],1);
  end;
  FreeAndNil(TempoStream);
  TempoStream2.Position := 0;
  TempoStream2.Write(FileRecord.RFA_T[0][0][1],4);
  TempoStream2.Position := 0;
  FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
  FreeAndNil(TempoStream2);
  Result := True;
 except
  { улыбаемся и машем, ага :) }
 end;
end;

function SA_G_Rune;
var Header:TRuneHeader;
    THeader : TRuneTableHeader;
    stream, table_s : TStream;
    i:cardinal;
    len : cardinal;
    Table : TRunePartialTable;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 'GML_ARC'#0;
 THeader.FileCount := RecordsCount;
 for i :=0 to 255 do
 begin
   THeader.key[i+1] := Char(i);
 end;
 UpOffset := 0;
 table_s := TMemoryStream.Create;
 table_s.Write(THeader,sizeof(THeader));
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  len := length(RFA[i].RFA_3);
  table_s.Write(len,4);
  table_s.Write(RFA[i].RFA_3[1],len);
  Table.FOffset := Upoffset;
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table.FLength := FileDataStream.Size;
  Upoffset := Upoffset + FileDataStream.Size;
  FileDataStream.Read(Table.sig[1],4);
  FreeAndNil(FileDataStream);
  table_s.Write(Table,sizeof(Table));
 end;

 table_s.Position := 0;
 Header.TableDecryptedLen := table_s.Size;
 stream := TMemoryStream.Create;
 GLZSSEncode(table_s,stream);
 Header.TableCryptedLen := stream.Size;
 Header.DataOffset := sizeof(Header) + Header.TableCryptedLen;
 stream.Position := 0;
 BlockXOR(stream, $FF);
 stream.Position := 0;

 ArchiveStream.Write(Header,sizeof(Header));
 ArchiveStream.CopyFrom(stream,stream.Size);

 FreeAndNil(table_s);
 FreeAndNil(stream);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;
 Result := True;
end;


end.