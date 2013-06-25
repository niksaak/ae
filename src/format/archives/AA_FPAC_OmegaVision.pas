{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  CAPE System \ OmegaVision FPAC (Shuffle!) game archive format & functions

  Specifications from Vendor.

  Written by dsp2003.
}

unit AA_FPAC_OmegaVision;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_FPAC(var ArcFormat : TArcFormats; index : integer);

 function  OA_FPAC : boolean;
 function  SA_FPAC(Mode : integer) : boolean;

type
{ FPAC archive structural description }
 TFPACHeader = packed record
  Header       : array[1..4] of char; // CAPF
  Unknown      : longword; // always $00 00 00 01, probably compression flag
  HeaderSize   : longword;
  TotalRecords : longword;
  Dummy_1      : int64;
  Dummy_2      : int64;
 end;
 TFPACDir = packed record
  Offset       : longword;
  FileSize     : longword;
  Filename     : array[1..32] of char;
 end;

implementation

uses AnimED_Archives;

procedure IA_FPAC;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'CAPE System \ OmegaVision FilePACK';
  Ext  := '.pac';
  Stat := $0;
  Open := OA_FPAC;
  Save := SA_FPAC;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_FPAC;
{ WAC archive opening function }
var i,j : integer;
    FPACHeader : TFPACHeader;
    FPACDir    : TFPACDir;

begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  with FPACHeader do begin
   Read(FPACHeader,SizeOf(FPACHeader));

   if Header <> 'CAPF' then Exit;

   RecordsCount := TotalRecords;
  end;
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with FPACDir do begin
    Read(FPACDir,SizeOf(FPACDir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize; // replicates filesize
  { Excluding archive garbage in filename ^_^ }
    for j := 1 to 32 do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;
 end;
 Result := True;

end;

function SA_FPAC;
 { WAC archive creating function }
var i, j : integer;
    FPACHeader : TFPACHeader;
    FPACDir    : TFPACDir;
begin
 RecordsCount := AddedFiles.Count;

 with FPACHeader do begin
  // Generating header
  Header          := 'CAPF';
  Unknown         := $01;
  TotalRecords    := RecordsCount;
//                   32                 + 40             *RecordsCount
  HeaderSize      := SizeOf(FPACHeader) + SizeOf(FPACDir)*RecordsCount;  
// Creating file table
  RFA[1].RFA_1    := HeaderSize;
  UpOffset        := HeaderSize;
  Dummy_1         := 0;
  Dummy_2         := 0;
 end;

// ...and writing file...
 ArchiveStream.Write(FPACHeader,SizeOf(FPACHeader));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with FPACDir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_2   := FileDataStream.Size;
   Offset         := RFA[i].RFA_1;
   FileSize       := RFA[i].RFA_2;   
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]); //FPAC do not support pathes
   for j := 1 to 32 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   FreeAndNil(FileDataStream);
// Writing header...
   ArchiveStream.Write(FPACDir,SizeOf(FPACDir));
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

end.