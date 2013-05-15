{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Touhou series archive code and functions

  Initial code by Katta.
  Ported by Nik.
}

unit AA_DAT_Touhou;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Generic_Hashes,

     Generic_LZXX,
     SysUtils, Classes, Windows, Forms;

 procedure IA_DAT_Touhou7(var ArcFormat : TArcFormats; index : integer);

 function OA_DAT_Touhou7 : boolean;
 function SA_DAT_Touhou7(Mode : integer) : boolean;
 function EA_DAT_Touhou7(FileRecord : TRFA) : boolean;
 
type

	TTouhou7Header = packed record
	  Magic : array[1..4] of char;
	  FilesCount : cardinal;
	  TableOffset : cardinal;
	  TableUnpackedSize : cardinal;
	end;
	
	TTouhou7Table = packed record
	// FileName : string; // нуль терминированная строка
	  Offset : cardinal;
	  Size : cardinal;
	  Flags : cardinal;
	end;

implementation

uses AnimED_Archives;

procedure IA_DAT_Touhou7;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Touhou 7 (Perfect Cherry Blossom)';
  Ext  := '.dat';
  Stat := $F;
  Open := OA_DAT_Touhou7;
  Save := SA_DAT_Touhou7;
  Extr := EA_DAT_Touhou7;
  FLen := $FFFF;
  SArg := 0;
  Ver  := $20091231;
 end;
end;

function OA_DAT_Touhou7;
var Header : TTouhou7Header;
    Table : TTouhou7Table;
    stream, tablestream : TStream;
    i, entrypos : cardinal;
    buf : array[1..$50] of char;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> 'PBG4' then Exit;
 
 RecordsCount := Header.FilesCount;
 
 ArchiveStream.Position := Header.TableOffset;
 
 tablestream := TMemoryStream.Create;
 stream := TMemoryStream.Create;
 stream.CopyFrom(ArchiveStream,ArchiveStream.Size - Header.TableOffset);
 stream.Position := 0;
 ZunLZSSDecode(stream, tablestream, Header.TableUnpackedSize);
 FreeAndNil(stream);

 entrypos := 0;
 tablestream.Position := 0;
{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   if (tablestream.Size - tablestream.Position) >= $50 then
     tablestream.Read(buf[1],$50)
   else
     tablestream.Read(buf[1],tablestream.Size - tablestream.Position);
   RFA[i].RFA_3 := String(Pchar(@buf[1]));
   tablestream.Position := entrypos + Length(RFA[i].RFA_3) + 1;
   entrypos := tablestream.Position + 12;
   tablestream.Read(Table, sizeof(Table));
   RFA[i].RFA_1 := Table.Offset;
   RFA[i].RFA_2 := Table.Size;
   RFA[i].RFA_Z := true;
   RFA[i].RFA_X := $FE;
   if i > 1 then RFA[i-1].RFA_C := RFA[i].RFA_1 - RFA[i-1].RFA_1;
 end;
 RFA[RecordsCount].RFA_C := RFA[RecordsCount].RFA_1 - RFA[RecordsCount-1].RFA_1;

 FreeAndNil(tablestream);
 Result := True;

end;

function SA_DAT_Touhou7;
begin
  Result := false;
end;

function EA_DAT_Touhou7;
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
            ZunLZSSDecode(TempoStream, TempoStream2, FileRecord.RFA_2);
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