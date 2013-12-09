{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.
  
  Leaf 'A' & 'Pak' formats

  Written by dsp2003 & Nik
}

unit AA_leaf_AquaPlus;

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
 procedure IA_A_LEAF(var ArcFormat : TArcFormats; index : integer);
  function OA_A_LEAF : boolean;
  function SA_A_LEAF(Mode : integer) : boolean;

 procedure IA_PAK_LEAF_KCAP(var ArcFormat : TArcFormats; index : integer);
  function OA_PAK_LEAF_KCAP : boolean;
  function SA_PAK_LEAF_KCAP(Mode : integer) : boolean;
  function EA_PAK_LEAF_KCAP(FileRecord : TRFA) : boolean;

 procedure IA_PAK_LEAF_LAC(var ArcFormat : TArcFormats; index : integer);
  function OA_PAK_LEAF_LAC : boolean;
  function SA_PAK_LEAF_LAC(Mode : integer) : boolean;

 procedure IA_PAK_LEAF_LACi(var ArcFormat : TArcFormats; index : integer);
  function OA_PAK_LEAF_LACi : boolean;
  function SA_PAK_LEAF_LACi(Mode : integer) : boolean;


type
 { LEAF (Utawarerumono) archive format }
 TLEAFAHeader = packed record
  Header       : word; // $1EAF
  TotalRecords : word; // File count
 end;
 TLEAFADir = packed record
  FileName     : array[1..23] of char; // File name
  CryptFlag    : byte; // 0 - не пожато
  Filesize     : longword; // File size
  Offset       : longword; // Same as in LNK format - Offset := Offset + HeaderSize;
 end;

 TLeadKCAPHeader = packed record
  Magic : array[1..4] of char; // 'KCAP'
  FilesCount : longword;
 end;

 TLeafKCAPTable = packed record
  CryptFlag : longword; // 1 - пожат, 0 - не пожат
  FileName : array[1..24] of char;
  FileOffset : longword;
  FileSize : longword;
 end;

 TLeafKCAPCryptSizes = packed record
  CryptedSize : longword;
  DecryptedSize : longword;
 end;

 TLeafACryptSizes = packed record
  DecryptedSize : longword;
  CryptedSize : longword;
 end;

 TLeafLACHeader = packed record
  Magic : array[1..4] of char; // 'LAC'#0
  FilesCount : longword;
 end;

 TLeafLACTable = packed record
  FileName : array[1..31] of char;
  crypt : byte; // 0 - нет 1 - да
  FileSize : longword;
  FileOffset : longword;
 end;

 TLeafLAC2Table = packed record
  Filename  : array[1..76] of char;
  Filesize_ : longword;
  FileSize  : int64; // copy of Filesize
  Offset    : int64; // absolute file offset
  Modified  : int64; // FILETIME
  Created   : int64; // FILETIME
  Opened    : int64; // FILETIME
 end;

implementation

uses AnimED_Archives;

procedure IA_A_LEAF;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'leaf / AquaPlus';
  Ext  := '.a';
  Stat := $0;
  Open := OA_A_LEAF;
  Save := SA_A_LEAF;
//  Extr := EA_RAW;
  Extr := EA_PAK_LEAF_KCAP;
  FLen := 24;
  SArg := 0;
  Ver  := $20090925;
 end;
end;

procedure IA_PAK_LEAF_KCAP;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'leaf / AquaPlus KCAP';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_LEAF_KCAP;
  Save := SA_PAK_LEAF_KCAP;
  Extr := EA_PAK_LEAF_KCAP;
  FLen := 24;
  SArg := 0;
  Ver  := $20091022;
 end;
end;

procedure IA_PAK_LEAF_LAC;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'leaf / AquaPlus LAC';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_LEAF_LAC;
  Save := SA_PAK_LEAF_LAC;
//  Extr := EA_RAW;
  Extr := EA_PAK_LEAF_KCAP;
  FLen := 31;
  SArg := 0;
  Ver  := $20090925;
 end;
end;

procedure IA_PAK_LEAF_LACi;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'leaf / AquaPlus LAC (Installer)';
  Ext  := '.lac';
  Stat := $0;
  Open := OA_PAK_LEAF_LACi;
  Save := SA_PAK_LEAF_LACi;
  Extr := EA_RAW;
  FLen := 76;
  SArg := 0;
  Ver  := $20090925;
 end;
end;

function OA_A_LEAF;
{ LEAF archive opening function }
var i : integer;
    LEAFHeader : TLEAFAHeader;
    LEAFDir    : TLEAFADir;
    CPos : longword;
    cs : TLeafACryptSizes;
begin
 Result := False;
 with ArchiveStream do begin

  Seek(0,soBeginning);

  with LEAFHeader do begin

   Read(LEAFHeader,SizeOf(LEAFHeader));

   if Header <> $AF1E then Exit;

   RecordsCount := TotalRecords;

   ReOffset := SizeOf(LEAFHeader) + SizeOf(LEAFDir)*RecordsCount;

  end;
{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   with LEAFDir do begin

    Read(LEAFDir,SizeOf(LEAFDir));
    RFA[i].RFA_1 := Offset+ReOffset;
    RFA[i].RFA_2 := FileSize;

    if CryptFlag <> 0 then
    begin
      RFA[i].RFA_Z := True;
      RFA[i].RFA_X := $FE;
      CPos := Position;
      Position := RFA[i].RFA_1;
      Read(cs, sizeof(cs));
      RFA[i].RFA_C := RFA[i].RFA_2 - 4;
      RFA[i].RFA_2 := cs.DecryptedSize;
      Position := CPos;
      RFA[i].RFA_1 := RFA[i].RFA_1 + 4;
    end
    else
      RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
  { Excluding archive garbage in filename ^_^ }
//    for j := 1 to 24 do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_3 := String(Pchar(@FileName[1]));

   end;

  end;

 end;

 Result := True;

end;

function SA_A_LEAF;
 { LEAF archive creating function }
var i : integer;
    LEAFHeader : TLEAFAHeader;
    LEAFDir    : TLEAFADir;
begin
 with LEAFHeader do begin

  Header := $AF1E; // $1eaf =^_^=
  RecordsCount := AddedFiles.Count;
  ReOffset     := SizeOf(LEAFHeader)+SizeOf(LEAFDir)*RecordsCount;
  TotalRecords := RecordsCount;
// Creating file table...
  RFA[1].RFA_1 := 0;
  UpOffset     := 0;
 end;

// ...and writing file...
 ArchiveStream.Write(LEAFHeader,SizeOf(LEAFHeader));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with LEAFDir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_2   := FileDataStream.Size;
   Offset         := RFA[i].RFA_1;
   FileSize       := RFA[i].RFA_2;
   CryptFlag      := 0;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]);

   FillChar(FileName,SizeOf(FileName),0);
//   for j := 1 to 24 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j];
   if Length(RFA[i].RFA_3) >= 23 then SetLength(RFA[i].RFA_3,22);
   CopyMemory(@FileName[1], @RFA[i].RFA_3[1],Length(RFA[i].RFA_3));
   FreeAndNil(FileDataStream);
// Writing header...
   ArchiveStream.Write(LEAFDir,SizeOf(LEAFDir));
  end;
 end;
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function OA_PAK_LEAF_KCAP;
var Header : TLeadKCAPHeader;
    Table : array of TLeafKCAPTable;
    i : longword;
    Sizes : TLeafKCAPCryptSizes;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> 'KCAP' then Exit;
 SetLength(Table,Header.FilesCount);
 ArchiveStream.Read(Table[0],Header.FilesCount*sizeof(TLeafKCAPTable));
 RecordsCount := Header.FilesCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Table[i-1].FileOffset;
   RFA[i].RFA_C := Table[i-1].FileSize;
   RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
   if Table[i-1].CryptFlag = 1 then
   begin
     ArchiveStream.Position := RFA[i].RFA_1;
     RFA[i].RFA_1 := RFA[i].RFA_1 + sizeof(Sizes);
     ArchiveStream.Read(Sizes,sizeof(Sizes));
     RFA[i].RFA_2 := Sizes.DecryptedSize;
     RFA[i].RFA_Z := true;
     RFA[i].RFA_X := $FE;
     RFA[i].RFA_C := RFA[i].RFA_C - 8;
   end
   else
   begin
     RFA[i].RFA_2 := RFA[i].RFA_C;
   end;
   // проверка на неправильные элементы
   if RFA[i].RFA_1 = 0 then Exit;
   if RFA[i].RFA_2 = 0 then Exit;
   if RFA[i].RFA_C = 0 then Exit;

 end;

 SetLength(Table, 0);
 Result := True;
end;

function OA_PAK_LEAF_LAC;
var Header : TLeafLACHeader;
    Table : array of TLeafLACTable;
    i, j, CSize : longword;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> 'LAC'#0 then Exit;
 SetLength(Table,Header.FilesCount);
 ArchiveStream.Read(Table[0],Header.FilesCount*sizeof(TLeafLACTable));

 ReOffset := SizeOf(TLeafLACHeader)+Header.FilesCount*SizeOf(TLeafLACTable);
 if Table[0].FileOffset <> ReOffset then
 begin
   SetLength(Table,0);
   Exit;
 end;

 RecordsCount := Header.FilesCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Table[i-1].FileOffset;
   RFA[i].RFA_C := Table[i-1].FileSize;
//   RFA[i].RFA_2 := RFA[i].RFA_C;
   j := 1;
   while Table[i-1].FileName[j] <> #0 do
   begin
     Table[i-1].FileName[j] := Char(not Byte(Table[i-1].FileName[j]));
     if j = $20 then Break;
     Inc(j);
   end;
   RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
   if Table[i-1].Crypt = 1 then
   begin
     ArchiveStream.Position := RFA[i].RFA_1;
     RFA[i].RFA_1 := RFA[i].RFA_1 + 4;
     ArchiveStream.Read(CSize,4);
     RFA[i].RFA_2 := CSize;
     RFA[i].RFA_Z := true;
     RFA[i].RFA_X := $FE;
     RFA[i].RFA_C := RFA[i].RFA_C - 4;
   end
   else
   begin
     RFA[i].RFA_2 := RFA[i].RFA_C;
   end;
 end;

 SetLength(Table, 0);
 Result := True;
end;

function EA_PAK_LEAF_KCAP;
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

function SA_PAK_LEAF_KCAP;
var Header : TLeadKCAPHeader;
    Table : array of TLeafKCAPTable;
    i, curlen : longword;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 'KCAP';
 Header.FilesCount := RecordsCount;
 SetLength(Table,RecordsCount);
 FillChar(Table[0],RecordsCount*sizeof(TLeafKCAPTable),0);
 Upoffset := sizeof(Header) + RecordsCount*sizeof(TLeafKCAPTable);
 
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  curlen := length(RFA[i].RFA_3);
  if(curlen >= $18) then curlen := $17;

  CopyMemory(@Table[i-1].FileName[1], @RFA[i].RFA_3[1], curlen);
  Table[i-1].CryptFlag := 0;
  Table[i-1].FileOffset := Upoffset;
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table[i-1].FileSize := FileDataStream.Size;
  Upoffset := Upoffset + FileDataStream.Size;
  FreeAndNil(FileDataStream);
 end;

 ArchiveStream.Write(Header,sizeof(Header));
 ArchiveStream.Write(Table[0],RecordsCount*sizeof(TLeafKCAPTable));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;
SetLength(Table, 0);   
 Result := True;
end;

function SA_PAK_LEAF_LAC;
var Header : TLeafLACHeader;
    Table : array of TLeafLACTable;
    i, j, curlen : longword;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 'LAC'#0;
 Header.FilesCount := RecordsCount;
 SetLength(Table,RecordsCount);
 FillChar(Table[0],RecordsCount*sizeof(TLeafLACTable),0);
 Upoffset := sizeof(Header) + RecordsCount*sizeof(TLeafLACTable);
 
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  curlen := length(RFA[i].RFA_3);
  if(curlen >= $1F) then curlen := $1E;

  CopyMemory(@Table[i-1].FileName[1], @RFA[i].RFA_3[1], curlen);
  for j := 1 to curlen do
  begin
    Table[i-1].FileName[j] := Char(Byte(Table[i-1].FileName[j]) xor $FF);
  end;
  Table[i-1].FileOffset := Upoffset;
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table[i-1].FileSize := FileDataStream.Size;
  Upoffset := Upoffset + FileDataStream.Size;
  FreeAndNil(FileDataStream);
 end;

 ArchiveStream.Write(Header,sizeof(Header));
 ArchiveStream.Write(Table[0],RecordsCount*sizeof(TLeafLACTable));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;
SetLength(Table, 0);   
 Result := True;
end;

function OA_PAK_LEAF_LACi;
var Header : TLeafLACHeader;
    Table : array of TLeafLAC2Table;
    i : longword;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(Header));
 if Header.Magic <> 'LAC'#0 then Exit;
 SetLength(Table,Header.FilesCount);
 ArchiveStream.Read(Table[0],Header.FilesCount*sizeof(TLeafLAC2Table));

 ReOffset := SizeOf(TLeafLACHeader)+Header.FilesCount*SizeOf(TLeafLAC2Table);
 if Table[0].Offset <> ReOffset then Exit;

 RecordsCount := Header.FilesCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   RFA[i].RFA_1 := Table[i-1].Offset;
   RFA[i].RFA_C := Table[i-1].FileSize;
   RFA[i].RFA_2 := RFA[i].RFA_C;
   RFA[i].RFA_3 := String(Pchar(@Table[i-1].FileName[1]));
 end;

 SetLength(Table, 0);
 Result := True;
end;

function SA_PAK_LEAF_LACi;
var Header : TLeafLACHeader;
    Table : array of TLeafLAC2Table;
    i, curlen : longword;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 'LAC'#0;
 Header.FilesCount := RecordsCount;
 SetLength(Table,RecordsCount);
 FillChar(Table[0],RecordsCount*sizeof(TLeafLAC2Table),0);
 Upoffset := sizeof(Header) + RecordsCount*sizeof(TLeafLAC2Table);
 
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  RFA[i].RFA_3 := AddedFiles.Strings[i-1];
  curlen := length(RFA[i].RFA_3);
  if(curlen >= 77) then curlen := 76;

  CopyMemory(@Table[i-1].FileName[1], @RFA[i].RFA_3[1], curlen);
  Table[i-1].Offset := Upoffset;
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  Table[i-1].FileSize := FileDataStream.Size;
  Table[i-1].Filesize_ := FileDataStream.Size;
  Table[i-1].Modified := $01C542F72FCD6370; // simulated date and time ^_^
  Table[i-1].Created  := $01C542F72FCD6370; // again
  Table[i-1].Opened   := $01C542F72FCD6370; // and again
  Upoffset := Upoffset + FileDataStream.Size;
  FreeAndNil(FileDataStream);
 end;

 ArchiveStream.Write(Header,sizeof(Header));
 ArchiveStream.Write(Table[0],RecordsCount*sizeof(TLeafLAC2Table));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;
SetLength(Table, 0);   
 Result := True;
end;

end.