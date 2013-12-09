{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Alcot games ARC archive format & functions

  Written by Nik.
}

unit AA_ARC_Alcot;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Generic_Hashes,
     SysUtils, Classes, Windows, Forms;

type
  TAlcotHeader = packed record
    Magic : array[1..4] of char; // 'ARC'#26
    ExtCount : longword; // кол-во расширений
    FilesCount : longword; // кол-во файлов (64 байта на запись)
    CryptedTable : longword; // сжатый размер таблицы (включая заголовок)
  end;

  TAlcotTableHeader = packed record
    Hash : longword; // Вычисляется по функции Gainax_Hash, заголовок НЕ включается
    Size1 : longword; // Размер первой части
    Size2 : longword; // Размер второй части
    Size3 : longword; // Размер третьей части
    DecryptedSize : longword; // == FilesCount*$40
  end;

  TAlcotTable = packed record
    Offset : longword; // Относительно конца таблицы
    Size : longword; // сабж
    Hash : longword; // он ли?
    Dummy : longword; // =0
    FileName : array[1..$30] of char; // снова сабж
  end;

 { Supported archives implementation }
 procedure IA_ARC_Alcot(var ArcFormat : TArcFormats; index : integer);

 function OA_ARC_Alcot : boolean;
 function SA_ARC_Alcot(Mode : integer) : boolean;

 function Alcot_DecodeTable(InputStream : TStream; Info : TAlcotTableHeader) : TStream;

implementation

uses AnimED_Archives;

procedure IA_ARC_Alcot;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Alcot';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_Alcot;
  Save := SA_ARC_Alcot;
  Extr := EA_RAW;
  FLen := $30;
  SArg := 0;
  Ver  := $20090828;
 end;
end;

function OA_ARC_Alcot;
var Header : TAlcotHeader;
    THeader : TAlcotTableHeader;
    exts : array[1..$20] of char;
    stream, dstream : TStream;
    i, Base : longword;
    TableArray : array of TAlcotTable;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> 'ARC'#26 then Exit;

 RecordsCount := Header.FilesCount;
 ArchiveStream.Read(exts[1],$20);
 ArchiveStream.Read(THeader,sizeof(THeader));

 stream := TMemoryStream.Create;
 stream.CopyFrom(ArchiveStream,Header.CryptedTable - $14);
 dstream := Alcot_DecodeTable(stream,THeader);
 FreeAndNil(stream);

 if dstream = nil then Exit;

 SetLength(TableArray,RecordsCount);
 dstream.Position := 0;
 dstream.Read(TableArray[0],RecordsCount*sizeof(TAlcotTable));

 Base := $30 + Header.CryptedTable;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Base + TableArray[i-1].Offset;
   RFA[i].RFA_2 := TableArray[i-1].Size;
   RFA[i].RFA_3 := String(PChar(@TableArray[i-1].FileName));
   RFA[i].RFA_C := RFA[i].RFA_2;
 end;

 SetLength(TableArray,0);
 Result := True;

end;

function Alcot_DecodeTable;
var bt, wb : byte;
    ww, ww2 : word;
    PosBlock1, PosBlock2, PosBlock3, CPos : longword;
    arr : array of byte;
begin
  Result := nil;
  if (Info.Size1 + Info.Size2 + Info.Size3) <> InputStream.Size then Exit;
  PosBlock1 := 0;
  PosBlock2 := Info.Size1;
  PosBlock3 := Info.Size2 + PosBlock2;
  Result := TMemoryStream.Create;
  SetLength(arr,InputStream.Size);
  InputStream.Position := 0;
  InputStream.Read(arr[0],InputStream.Size);
  bt := $80;
  while Result.Size < Info.DecryptedSize do
  begin
    if (arr[PosBlock1] and bt) = 0 then
    begin
      ww := arr[PosBlock3] + 1;
      Inc(PosBlock3);
      Result.Write(arr[PosBlock3],ww);
      Inc(PosBlock3,ww);
    end
    else
    begin
      CopyMemory(@ww,@arr[PosBlock2],2);
      ww2 := (ww shr $D) + 3;
      Inc(PosBlock2,2);
      CPos := Result.Position - (ww and $1FFF) - 1;
      while ww2 > 0 do
      begin
        Result.Position := CPos;
        Result.Read(wb,1);
        Result.Position := Result.Size;
        Result.Write(wb,1);
        Inc(CPos);
        Dec(ww2);
      end;
    end;
    bt := bt shr 1;
    if bt = 0 then
    begin
      bt := $80;
      Inc(PosBlock1);
    end;
  end;
  SetLength(arr,0);
end;

function SA_ARC_Alcot;
var Header : TAlcotHeader;
    THeader : TAlcotTableHeader;
    exts : array[1..$20] of char;
    cexts : array of string;
    curext : string;
    stream, dstream, namesstr : TStream;
    i, elen, celen, ind, work : longword;
    extadd : boolean;
    TableArray : array of TAlcotTable;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 'ARC'#26;
 Header.FilesCount := RecordsCount;
 THeader.DecryptedSize := RecordsCount*$40;
 THeader.Size2 := 0;
 THeader.Size1 := (((THeader.DecryptedSize div $100) + 1) div 8) + 1;
 if (THeader.DecryptedSize mod $100) = 0 then
   THeader.Size3 := (THeader.DecryptedSize div $100) + THeader.DecryptedSize
 else
   THeader.Size3 := (THeader.DecryptedSize div $100) + THeader.DecryptedSize + 1;
 Header.CryptedTable := THeader.Size1 + THeader.Size3 + sizeof(THeader);

 UpOffset := 0;

 SetLength(cexts,0);
 SetLength(TableArray,RecordsCount);
 FillChar(TableArray[0],sizeof(TAlcotTable)*RecordsCount,0);
 FillChar(exts[1],$20,0);
 dstream := TMemoryStream.Create;
 dstream.Write(TableArray[0],THeader.Size1);
 elen := 0;
 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   RFA[i].RFA_3 := AddedFiles.Strings[i-1];
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   namesstr := TMemoryStream.Create;
   work := Length(RFA[i].RFA_3);
   namesstr.Write(RFA[i].RFA_3[1],work);
   namesstr.Position := 0;
   TableArray[i-1].Hash := Gainax_Hash(namesstr,0);
   FreeAndNil(namesstr);
   TableArray[i-1].Offset := UpOffset;
   TableArray[i-1].Size := FileDataStream.Size;
   UpOffset := UpOffset + FileDataStream.Size;
   FreeAndNil(FileDataStream);
   CopyMemory(@TableArray[i-1].FileName, @RFA[i].RFA_3[1], work);
   curext := ExtractFileExt(RFA[i].RFA_3);
   extadd := true;
   celen := elen;
   while celen > 0 do
   begin
     if curext = cexts[celen-1] then
     begin
       extadd := false;
       break;
     end;
   end;
   if extadd then
   begin
     SetLength(cexts,elen+1);
     cexts[elen] := curext;
     Inc(elen);
   end;
 end;
 ind := 1;
 Header.ExtCount := elen;
 for i := 0 to elen-1 do
 begin
   celen := Length(cexts[i]);
   if(ind + celen > $20) then break;
   CopyMemory(@exts[ind],@cexts[i][1],celen);
   ind := ind + celen;
 end;

 stream := TMemoryStream.Create;
 stream.Write(TableArray[0],sizeof(TAlcotTable)*RecordsCount);
 stream.Position := 0;
 work := $FFFFFFFF;
 while (stream.Position + $100) < stream.Size do
 begin
   dstream.Write(work,1);
   dstream.CopyFrom(stream,$100);
//   stream.Position := stream.Position + $100;
 end;
 work := stream.Size - stream.Position - 1;
 dstream.Write(work,1);
 dstream.CopyFrom(stream,work+1);
 FreeAndNil(stream);
 dstream.Position := 0;
 THeader.Hash := Gainax_Hash(dstream,0);
 dstream.Position := 0;
 ArchiveStream.Write(Header,sizeof(Header));
 ArchiveStream.Write(exts[1],$20);
 ArchiveStream.Write(THeader,sizeof(THeader));
 ArchiveStream.CopyFrom(dstream,dstream.Size);
 FreeAndNil(dstream);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
 end;

 SetLength(TableArray,0);
 SetLength(cexts,0);
 Result := True;
end;

end.