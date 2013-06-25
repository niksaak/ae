{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.
  
  Giga's TPF Archive

  Written by Nik.
}

unit AA_TPF_Giga;

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
 procedure IA_TPF_Giga(var ArcFormat : TArcFormats; index : integer);

 function OA_TPF_Giga : boolean;
 function SA_TPF_Giga(Mode : integer) : boolean;
 function EA_TPF_Giga(FileRecord : TRFA) : boolean;

type
  TGigaTPFHeader = packed record
    Magic : array[1..8] of char; //'TPF FILE'
    Dummy : cardinal; // 0
    FilesCount : cardinal;
  end;

  TGigaTPFTable = packed record
    FileName : array[1..$20] of char;
    Zero : byte; // 0
    EntityNum1 : byte; // порядковый номер записи, после $FF идёт 0 и по новой
    EntityNum2 : byte; // == EntityNum1
    CryptFlag : byte; // 1 - LZSS, 0 - нет
    Offset : cardinal;
    CryptedLen : cardinal; // для LZSS не юзается
    UncryptedLen : cardinal;
  end;
  {
  Существует хвостовая запись, учитывающаяся в FilesCount
  Вместо имени 'TPF FILE' 4 раза
  Offset - конец архива, размеры нулевые
  }


implementation

uses AnimED_Archives;

procedure IA_TPF_Giga;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Giga';
  Ext  := '.tpf';
  Stat := $F;
  Open := OA_TPF_Giga;
  Save := SA_TPF_Giga;
  Extr := EA_TPF_Giga;
  FLen := $20;
  SArg := 0;
  Ver  := $20091008;
 end;
end;

function OA_TPF_Giga;
var Header : TGigaTPFHeader;
    Table : array of TGigaTPFTable;
    i : cardinal;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> 'TPF FILE' then Exit;
 SetLength(Table,Header.FilesCount);
 ArchiveStream.Read(Table[0],Header.FilesCount*sizeof(TGigaTPFTable));
 if Table[Header.FilesCount-1].FileName <> 'TPF FILETPF FILETPF FILETPF FILE' then
 begin
   SetLength(Table,0);
   Exit;
 end;

 RecordsCount := Header.FilesCount-1;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Table[i-1].Offset;
   RFA[i].RFA_2 := Table[i-1].UncryptedLen;
   RFA[i].RFA_C := Table[i].Offset - Table[i-1].Offset;
   RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
   case Table[i-1].CryptFlag of
     1:begin
         RFA[i].RFA_Z := true;
         RFA[i].RFA_X := $FE;
       end;
//   2:begin end;  
   end;
 end;

 SetLength(Table, 0);
 Result := True;
end;

function SA_TPF_Giga;
begin
 Result := True;
end;

function EA_TPF_Giga;
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