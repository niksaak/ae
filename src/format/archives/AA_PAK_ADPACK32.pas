{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  ADPACK32 PAK (Hinatabokko) archive format & functions

  Specifications from Vendor.

  Written by dsp2003.
}

unit AA_PAK_ADPACK32;

interface

uses AA_RFA,
     Generic_Hashes,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_PAK_ADPACK32(var ArcFormat : TArcFormats; index : integer);

  function OA_PAK_ADPACK32 : boolean;
  function SA_PAK_ADPACK32(Mode : integer) : boolean;

type
{ FPAC archive structural description }
 TADPACK32Header = packed record
  Header       : array[1..8] of char; // ADPACK32
  Version      : longword; // always $010000
  TotalRecords : longword;
 end;
 TADPACK32Dir = packed record
  Filename     : array[1..26] of char;
  Hash         : word;
  Offset       : longword;
 end;

implementation

uses AnimED_Archives;

const ADPACK32Conf = 'ADPack32';

procedure IA_PAK_ADPACK32;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'ADPACK32 (Hinatabokko)';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_ADPACK32;
  Save := SA_PAK_ADPACK32;
  Extr := EA_RAW;
  FLen := 26;
  SArg := 0;
  Ver  := $20090905;
 end;
end;

function OA_PAK_ADPACK32;
{ WAC archive opening function }
var i,j : integer;
    ADPACK32Header : TADPACK32Header;
    ADPACK32Dir    : TADPACK32Dir;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  with ADPACK32Header do begin
   Read(ADPACK32Header,SizeOf(ADPACK32Header));

   if (Header <> 'ADPACK32') and (Version <> $010000) then Exit;

   RecordsCount := TotalRecords;
   UpOffset := SizeOf(ADPACK32Header);
  end;

{*}Progress_Max(RecordsCount);
// Reading ADPACK32 filetable...
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with ADPACK32Dir do begin
    Read(ADPACK32Dir,SizeOf(ADPACK32Dir));
  { Excluding archive garbage in filename ^_^ }
    for j := 1 to 26 do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_1 := Offset;
//    if (Hash <> 0) and (RFA[i].RFA_3 <> '') then ConfS('Metadata.conf',ADPack32Conf,RFA[i].RFA_3,Hash);

    SetLength(RFA[i].RFA_T,1);
    SetLength(RFA[i].RFA_T[0],1);
    RFA[i].RFA_T[0][0] := inttostr(Hash);

//    if (Hash <> 0) and (RFA[i].RFA_3 = '') then MessageBox(0, pchar('Zero hash detected!'#13#10#13#10+inttostr(i)+' : '+inttohex(hash,4)),'ADPACK32',mb_ok);
   end;
  end;

 { Now calculating file sizes }
  for i := 1 to RecordsCount do begin
   if RFA[i+1].RFA_1 <> 0 then RFA[i].RFA_2 := RFA[i+1].RFA_1-RFA[i].RFA_1
   else RFA[i].RFA_2 := 0;
   RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
  end;

 end;
 RecordsCount := RecordsCount - 1;
 Result := True;

end;

function SA_PAK_ADPACK32;
 { WAC archive creating function }
var i, j : integer;
    ADPACK32Header : TADPACK32Header;
    ADPACK32Dir    : TADPACK32Dir;
begin
 RecordsCount := AddedFiles.Count+1;

 with ADPACK32Header do begin
  Header          := 'ADPACK32';
  Version         := $010000;
  TotalRecords    := RecordsCount;
// Creating file table...
  UpOffset        := SizeOf(ADPACK32Header) + SizeOf(ADPACK32Dir)*RecordsCount;
  RFA[1].RFA_1    := UpOffset;
 end;

// ...and writing file...
 ArchiveStream.Write(ADPACK32Header,SizeOf(ADPACK32Header));

 for i := 1 to RecordsCount-1 do begin
{*}Progress_Pos(i);
  with ADPACK32Dir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]); //ADPACK32 do not support pathes
   Hash           := ADPack32_Hash(RFA[i].RFA_3);

   FillChar(FileName,SizeOf(FileName),0);

   for j := 1 to 26 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;

   Offset         := RFA[i].RFA_1;
   FreeAndNil(FileDataStream);
// Writing header...
   ArchiveStream.Write(ADPACK32Dir,SizeOf(ADPACK32Dir));
  end;
 end;
{ EOF record fix }
 with ADPACK32Dir do begin
  Offset := UpOffset;
  Hash := 0;
  FillChar(FileName,SizeOf(FileName),0);
  ArchiveStream.Write(ADPACK32Dir,SizeOf(ADPACK32Dir));
 end;
// Writing file...

 for i := 1 to RecordsCount-1 do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;
end;

end.