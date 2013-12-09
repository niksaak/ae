{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Hinatarte archives format

  Written by Nik.
}

unit AA_CAF_Hinatarte;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     SysUtils, Classes, Windows, Forms;

 procedure IA_CAF_Hinatarte(var ArcFormat : TArcFormats; index : integer);

 function OA_CAF_Hinatarte : boolean;
 function SA_CAF_Hinatarte(Mode : integer) : boolean;

 function ReplaceStr(const Srch, Replace, S: string): string;
 
type
  TCAFHeader = packed record
   Magic         : array[1..4] of char; // 'CAF0'
   Dummy         : longword;             // $0
   FileCount     : longword;             // num of files
   HeaderSize    : longword;             // header size
   TableSize     : longword;             // 20 * FileCount
   FNTableOffset : longword;             // filenames table offset
   FNTableSize   : longword;             // filenames table size
  end;

  TCAFDir = packed record
   Unknown       : longword;             // always 1
   FolderOffset  : longword;             // relative offset of file's folder (not in folder if -1)
   FNOffset      : longword;             // relative offset of filename in table
   Offset        : longword;             // relative offset in archive (real = Offset+FNTableOffset+FNTableSize)
   FileSize      : longword;             // file size
  end;

implementation

uses AnimED_Archives, AnimED_Main;

function ReplaceStr(const Srch, Replace, S: string): string;
{замена подстроки в строке}
var
 I:Integer;
 Source:string;
begin
 Source:= S;
 Result:= '';
 repeat
  I:=Pos(Srch, Source);
  if I > 0 then begin
   Result:=Result+Copy(Source,1,I-1)+Replace;
   Source:=Copy(Source,I+Length(Srch),MaxInt);
  end else Result:=Result+Source;
 until I<=0;
end;

procedure IA_CAF_Hinatarte;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Hinatarte';
  Ext  := '.caf';
  Stat := $F;
  Open := OA_CAF_Hinatarte;
  Save := SA_CAF_Hinatarte;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20091007;
 end;
end;

function OA_CAF_Hinatarte;
var Header : TCAFHeader;
    Table : array of TCAFDir;
    FileNames : array of char;
    curfolderoffset, i : longword;
    curfolder : string;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if (Header.Magic <> 'CAF0') or (Header.Dummy <> 0) then Exit;
 RecordsCount := Header.FileCount;
 SetLength(Table, RecordsCount);
 ArchiveStream.Read(Table[0],Header.TableSize);
 ArchiveStream.Position := Header.FNTableOffset;
 SetLength(FileNames,Header.FNTableSize);
 ArchiveStream.Read(FileNames[0],Header.FNTableSize);
 
 curfolderoffset := 0;
 curfolder := ReplaceStr('/','\',String(Pchar(@FileNames[0])));
 
 UpOffset := Header.FNTableOffset + Header.FNTableSize;
 
{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   if (curfolderoffset <> Table[i-1].FolderOffset) and (Table[i-1].FolderOffset <> $FFFFFFFF) then
   begin
     curfolderoffset := Table[i-1].FolderOffset;
     curfolder := ReplaceStr('/','\',String(Pchar(@FileNames[curfolderoffset])));
   end;
   RFA[i].RFA_1 := Table[i-1].Offset + UpOffset;
   RFA[i].RFA_C := Table[i-1].FileSize;
   RFA[i].RFA_2 := RFA[i].RFA_C;
   if Table[i-1].FolderOffset <> $FFFFFFFF then
     RFA[i].RFA_3 := curfolder + String(Pchar(@FileNames[Table[i-1].FNOffset]))
   else
     RFA[i].RFA_3 := String(Pchar(@FileNames[Table[i-1].FNOffset]));
 end;

 SetLength(Table, 0);
 SetLength(FileNames,0);

 Result := True;
end;

function SA_CAF_Hinatarte;
begin
 with ArchiveStream do begin
 end;
 Result := True;
end;

end.