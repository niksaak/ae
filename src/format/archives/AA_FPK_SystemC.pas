{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.
  
  INTERHEART's SystemC

  Written by Nik.
}

unit AA_FPK_SystemC;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     Generic_LZXX,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_FPK_SystemC(var ArcFormat : TArcFormats; index : integer);

 function OA_FPK_SystemC : boolean;
 function SA_FPK_SystemC(Mode : integer) : boolean;
 
 function EA_FPK_SystemC(FileRecord : TRFA) : boolean;

type
 TSystemCTable = packed record
   Offset : longword;
   Size : longword;
   FileName : array[1..$18] of char;
 end;

 TSystemCSecretTable = packed record
   TableElem : TSystemCTable;
   unk : longword;
 end;

 TSystemCSecretDescriptor = packed record
   key : longword;
   TableOffset : longword;
 end;

 TSystemCZLC2Header = packed record
   Magic : array[1..4] of char;
   UpackedSize : longword;
 end;

implementation

uses AnimED_Archives, AnimED_Main;

procedure IA_FPK_SystemC;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'SystemC';
  Ext  := '.fpk';
  Stat := $0;
  Open := OA_FPK_SystemC;
  Save := SA_FPK_SystemC;
  Extr := EA_FPK_SystemC;
  FLen := $18;
  SArg := 0;
  Ver  := $20090926;
 end;
end;

function OA_FPK_SystemC;
var filesCouns : integer;
    Table : array of TSystemCTable;
    STable : array of TSystemCSecretTable;
    Secret : TSystemCSecretDescriptor;
    stream : TStream;
    work, i : longword;
    ZLC2 : TSystemCZLC2Header;
begin
 Result := False;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(filesCouns,4);
 if ((filesCouns and $7FFFFFFF) > 16777215) or (filesCouns = 0) then Exit;
 if filesCouns > 0 then
 begin
   if (filesCouns*sizeof(TSystemCTable)) >= (ArchiveStream.Size div 10) then Exit;
   RecordsCount := filesCouns;
   SetLength(Table,RecordsCount);
   ArchiveStream.Read(Table[0],RecordsCount*sizeof(TSystemCTable));

{*}Progress_Max(RecordsCount);
   for i := 1 to RecordsCount do begin
{*}  Progress_Pos(i);
     if (Table[i-1].Offset+Table[i-1].Size > ArchiveStream.Size) then
     begin
       SetLength(Table,0);
       Exit;
     end;
     RFA[i].RFA_1 := Table[i-1].Offset;
     if RFA[i].RFA_1 = 0 then Exit; // определение некорректного архива
     RFA[i].RFA_C := Table[i-1].Size;
     ArchiveStream.Position := RFA[i].RFA_1;
     ArchiveStream.Read(ZLC2,sizeof(ZLC2));
     if ZLC2.Magic = 'ZLC2' then
     begin
       RFA[i].RFA_2 := ZLC2.UpackedSize;
       RFA[i].RFA_C := RFA[i].RFA_C - 8;
       RFA[i].RFA_1 := RFA[i].RFA_1 + 8;
       RFA[i].RFA_Z := true;
       RFA[i].RFA_X := acLZSS;
     end
     else
       RFA[i].RFA_2 := RFA[i].RFA_C;
     begin
     end;
     RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
   end;
   SetLength(Table,0);
 end
 else
 begin
   RecordsCount := (filesCouns and $FFFFFF);
   ArchiveStream.Position := ArchiveStream.Size - sizeof(Secret);
   ArchiveStream.Read(Secret,sizeof(Secret));
   if Secret.TableOffset >= (ArchiveStream.Size - RecordsCount*sizeof(TSystemCSecretTable)) then Exit;
   ArchiveStream.Position := Secret.TableOffset;
   stream := TMemoryStream.Create;
   stream.CopyFrom(ArchiveStream,RecordsCount*sizeof(TSystemCSecretTable));
   stream.Position := 0;
   while stream.Position < stream.Size do
   begin
     stream.Read(work,4);
     work := work xor Secret.key;
     Stream.Position := stream.Position - 4;
     stream.Write(work,4);
   end;
   stream.Position := 0;
   SetLength(STable,RecordsCount);
   stream.Read(STable[0],RecordsCount*sizeof(TSystemCSecretTable));
   FreeAndNil(stream);

{*}Progress_Max(RecordsCount);
   for i := 1 to RecordsCount do begin
{*}  Progress_Pos(i);
     if (STable[i-1].TableElem.Offset+STable[i-1].TableElem.Size > ArchiveStream.Size) then
     begin
       SetLength(STable,0);
       Exit;
     end;
     RFA[i].RFA_1 := STable[i-1].TableElem.Offset;
     if RFA[i].RFA_1 = 0 then Exit; // определение некорректного архива
     RFA[i].RFA_C := STable[i-1].TableElem.Size;
     ArchiveStream.Position := RFA[i].RFA_1;
     ArchiveStream.Read(ZLC2,sizeof(ZLC2));
     if ZLC2.Magic = 'ZLC2' then
     begin
       RFA[i].RFA_2 := ZLC2.UpackedSize;
       RFA[i].RFA_C := RFA[i].RFA_C - 8;
       RFA[i].RFA_1 := RFA[i].RFA_1 + 8;
       RFA[i].RFA_Z := true;
       RFA[i].RFA_X := acLZSS;
     end
     else
       RFA[i].RFA_2 := RFA[i].RFA_C;
     begin
     end;
     RFA[i].RFA_3 := String(Pchar(@STable[i-1].TableElem.FileName[1]));
   end;
   SetLength(STable,0);
 end;

 Result := True;
end;

function SA_FPK_SystemC;
var Table : array of TSystemCTable;
    i, curlen : longword;
begin
 RecordsCount := AddedFiles.Count;
 SetLength(Table,RecordsCount);
 FillChar(Table[0],RecordsCount*sizeof(TSystemCTable),0);
 Upoffset := 4 + RecordsCount*sizeof(TSystemCTable);
 
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  curlen := length(RFA[i].RFA_3);
  if(curlen >= 24) then curlen := 23;

  CopyMemory(@Table[i-1].FileName[1], @RFA[i].RFA_3[1], curlen);
  Table[i-1].Offset := Upoffset;
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table[i-1].Size := FileDataStream.Size;
  Upoffset := Upoffset + FileDataStream.Size;
  FreeAndNil(FileDataStream);
 end;

 ArchiveStream.Write(RecordsCount,4);
 ArchiveStream.Write(Table[0],RecordsCount*sizeof(TSystemCTable));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;
 Result := True;
end;

function EA_FPK_SystemC;
var TempoStream, TempoStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_Z of
   True  : begin
            TempoStream := TMemoryStream.Create;
            TempoStream2 := TMemoryStream.Create;
            TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
            TempoStream.Position := 0;
            ZLC2Decode(TempoStream, TempoStream2);
            FreeAndNil(TempoStream);
            TempoStream2.Position := 0;
            FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
            FreeAndNil(TempoStream2);            
           end;
   False : FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  end;
  Result := True;
 except
 end;
end;

end.