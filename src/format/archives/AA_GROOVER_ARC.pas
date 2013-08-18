{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Groover (Green Green) engine archive functons

  Written by Nik.
}

unit AA_GROOVER_ARC;

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

 procedure IA_GROOVER_ARC_mode1(var ArcFormat : TArcFormats; index : integer);

 function OA_GROOVER_ARC_mode1 : boolean;
 function SA_GROOVER_ARC_mode1(Mode : integer) : boolean;
 
type

	TGROOVERMainHeader = packed record
	  Magic : array[1..4] of char; // 'ARC1'
	  Mode : cardinal; // <>1 (определяет кол-во файлов) для архивов скриптов (mode 0),  1 для остальных (mode 1)
	end;
	
	TGROOVERMode1Header = packed record
	  Magic : array[1..4] of char; // 'DATA'
	  TableOffset : cardinal; // относительное смещение файловой таблицы (нужно прибавить 0x10)
	end;
	
	TGROOVERMode1TableHeader = packed record
	  Magic : array[1..4] of char; // 'HEAD'
	  TableLength : cardinal; // размер файловой таблицы
	end;
	
	TGROOVERMode1Table = packed record
	  Filename : array[1..$108] of char;
	  Length : cardinal;
	  Offset : cardinal;
	  DateTimes : TFileTimes;
	end;

implementation

uses AnimED_Archives;

procedure IA_GROOVER_ARC_mode1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'GROOVER';
  Ext  := '.arc';
  Stat := $F;
  Open := OA_GROOVER_ARC_mode1;
  Save := SA_GROOVER_ARC_mode1;
  Extr := EA_RAW;
  FLen := $FFFF;
  SArg := 0;
  Ver  := $20091231;
 end;
end;

function OA_GROOVER_ARC_mode1;
var Header : TGROOVERMainHeader;
    SHeader : TGROOVERMode1Header;
    THeader : TGROOVERMode1TableHeader;
    Table : array of TGROOVERMode1Table;
    i : cardinal;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if (Header.Magic <> 'ARC1') and (Header.Mode <> 1) then Exit;
 
 ArchiveStream.Read(SHeader,sizeof(SHeader));
 if (SHeader.Magic <> 'DATA') then Exit;

 ArchiveStream.Position := ArchiveStream.Position + SHeader.TableOffset;
 ArchiveStream.Read(THeader,sizeof(THeader));

 if THeader.Magic <> 'HEAD' then Exit;

 RecordsCount := THeader.TableLength div sizeof(TGROOVERMode1Table);
 SetLength(Table,RecordsCount);
 ArchiveStream.Read(Table[0],RecordsCount*sizeof(Table[0]));

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Table[i-1].Offset;
   RFA[i].RFA_2 := Table[i-1].Length;
   RFA[i].RFA_C := RFA[i].RFA_2;
   RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
 end;

 SetLength(Table,0);
 Result := True;

end;

function SA_GROOVER_ARC_mode1;
begin
  Result := false;
end;

end.