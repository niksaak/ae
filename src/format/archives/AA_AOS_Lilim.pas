{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Used in Lilim games

  Written by Nik.
}

unit AA_AOS_Lilim;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     JReconvertor,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_AOS_Lilim(var ArcFormat : TArcFormats; index : integer);

 function OA_AOS_Lilim : boolean;
 function SA_AOS_Lilim(Mode : integer) : boolean;

type

  TLilimHeader = packed record
   Dummy     : longword; // 0, одновременно выступает за magic
   HeadSize  : longword; // Размер заголовка + таблица
   TableSize : longword; // Размер таблицы
  end;

  TLilimTable = packed record
   FileName  : array[1..$20] of char;
   Offset    : longword; // относительно HeadSize
   FileSize  : longword;
  end;

implementation

uses AnimED_Archives;

procedure IA_AOS_Lilim;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Lilim';
  Ext  := '.aos';
  Stat := $0;
  Open := OA_AOS_Lilim;
  Save := SA_AOS_Lilim;
  Extr := EA_RAW;
  FLen := $20;
  SArg := 0;
  Ver  := $20090902;
 end;
end;

function OA_AOS_Lilim;
var Header : TLilimHeader;
    Table : array of TLilimTable;
    i : longword;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Header,sizeof(Header));

  with Header do begin
   if Dummy <> 0 then Exit;
   if HeadSize >= Size then Exit;
   if HeadSize = 0 then Exit;
   if TableSize >= Size then Exit;
   if TableSize = 0 then Exit;
   if (TableSize mod sizeof(TLilimTable)) <> 0 then Exit;

   RecordsCount := TableSize div sizeof(TLilimTable);
   SetLength(Table, RecordsCount);
   Seek(HeadSize - TableSize,soBeginning);
   Read(Table[0],TableSize);

{*}Progress_Max(RecordsCount);
   for i := 1 to RecordsCount do begin
 {*}Progress_Pos(i);
    RFA[i].RFA_1 := Table[i-1].Offset + HeadSize;
    RFA[i].RFA_2 := Table[i-1].FileSize;
    RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
    RFA[i].RFA_C := RFA[i].RFA_2;
   end;

   SetLength(Table, 0);

  end; // with Header

 end; // with ArchiveStream

 Result := True;

end;

function SA_AOS_Lilim;
var Header : TLilimHeader;
    Table : array of TLilimTable;
    len, len2, i : longword;
    FileName, FileNamew : string;
begin
 RecordsCount := AddedFiles.Count;
 Header.Dummy := 0;
 Header.TableSize := RecordsCount*sizeof(TLilimTable);
 UpOffset := 0;

 FileName := Wide2Ansi(ExtractFileName(ArchiveFileName));
 len := length(FileName);
 if len >= $105 then len2 := len + 1 else len2 := $105;
 SetLength(FileNamew,len2);
 FillChar(FileNamew[1],len2,0);
 CopyMemory(@FileNamew[1], @FileName[1], len);
 Header.HeadSize := Header.TableSize + sizeof(Header) + len2;

 ArchiveStream.Write(Header,sizeof(Header));
 ArchiveStream.Write(FileNamew[1],len2);
 SetLength(Table, RecordsCount);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   FileName := ExtractFileName(AddedFiles.Strings[i-1]);
   len := Length(FileName);
   if len >= $20 then len := $19;
   CopyMemory(@Table[i-1].FileName[1], @FileName[1], len);
   Table[i-1].Offset := UpOffset;
   UpOffset := UpOffset + FileDataStream.Size;
   Table[i-1].FileSize := FileDataStream.Size;
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