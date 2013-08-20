{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  NEJII Archives (Rolling Star, Shining Star, Shining Star Lily's)
  
  Written by Nik.
}

unit AA_NEJII;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Generic_LZXX,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_NEJII(var ArcFormat : TArcFormats; index : integer);

 function OA_NEJII : boolean;
 function SA_NEJII(Mode : integer) : boolean;
 function EA_NEJII(FileRecord : TRFA) : boolean;
 
type
 TNEJIIHeader = packed record
   Magic : cardinal; // $00314B52 ('RK1'#0)
   FilesCount : cardinal;
   TableOffset : cardinal;
 end;
 
 TNEJIITable = packed record
   FileName : array[1..$10] of char;
   CryptedSize : cardinal;
   DecryptedSize : cardinal;
   CryptFlag : cardinal; // если = 1 то файл пожат
   FileOffset : cardinal;
 end;

implementation

uses AnimED_Archives;

procedure IA_NEJII;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'NEJII';
  Ext  := '.dat';
  {Архивы имеют расширения:
  .cdt - изображения
  .vdt - озвучка
  .ovd - BGM
  .pdt - звуки
  .dat - скрипты
  но всё это один и тот же формат}
  Stat := $0;
  Open := OA_NEJII;
  Save := SA_NEJII;
  Extr := EA_NEJII;
  FLen := $10;
  SArg := 0;
  Ver  := $20091001;
 end;
end;

function OA_NEJII;
var Header : TNEJIIHeader;
    Table : array of TNEJIITable;
    i : cardinal;
begin
 Result := False;
 ArchiveStream.Position := ArchiveStream.Size - 12;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> $00314B52 then Exit;
 SetLength(Table,Header.FilesCount);
 ArchiveStream.Position := Header.TableOffset;
 ArchiveStream.Read(Table[0],sizeof(TNEJIITable)*Header.FilesCount);
 RecordsCount := Header.FilesCount;
 
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Table[i-1].FileOffset;
   RFA[i].RFA_2 := Table[i-1].DecryptedSize;
   RFA[i].RFA_C := Table[i-1].CryptedSize;
   if Table[i-1].CryptFlag = 1 then
   begin
     RFA[i].RFA_Z := True;
     RFA[i].RFA_X := acLZSS;
   end;
   RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
  end;
 SetLength(Table,0);
 Result := True;
end;

function SA_NEJII;
var Header : TNEJIIHeader;
    Table : array of TNEJIITable;
    i, curlen : cardinal;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := $00314B52;
 Header.FilesCount := RecordsCount;
 SetLength(Table,RecordsCount);
 FillChar(Table[0],RecordsCount*sizeof(TNEJIITable),0);
 Upoffset := 0;
 
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  curlen := length(RFA[i].RFA_3);
  if(curlen >= $10) then curlen := $F;

  CopyMemory(@Table[i-1].FileName[1], @RFA[i].RFA_3[1], curlen);
  Table[i-1].CryptFlag := 0;
  Table[i-1].FileOffset := Upoffset;
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table[i-1].CryptedSize := FileDataStream.Size;
  Table[i-1].DecryptedSize := FileDataStream.Size;
  Upoffset := Upoffset + FileDataStream.Size;
  FreeAndNil(FileDataStream);
 end;

 Header.TableOffset := Upoffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;
 ArchiveStream.Write(Table[0],RecordsCount*sizeof(TNEJIITable));
 ArchiveStream.Write(Header,sizeof(Header));
 SetLength(Table, 0);
 Result := True;
end;

function EA_NEJII;
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
            GLZSSDecode(TempoStream, TempoStream2, FileRecord.RFA_C, $FEE,$FFF);
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