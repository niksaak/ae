{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  WAC (Seikai no Senki) game archive format & functions
  
  Specifications from Vendor.

  Written by dsp2003.
}

unit AA_WAC;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_WAC(var ArcFormat : TArcFormats; index : integer);

 function  OA_WAC : boolean;
 function  SA_WAC(Mode : integer) : boolean;

type
{ WAC archive structural description }
 TWACHeader = packed record
  Header       : array[1..16] of char; // Nimrod1.00 + #0#0#0#0#0#0
  DirOffset    : longword;
  DirSize      : longword;
  HeaderSize   : longword;
  TotalRecords : longword;
 end;
 TWACDir = packed record
  FNLength     : longword;
  Filename     : array[1..256] of char;
  FileSize     : longword;
  CFileSize    : longword; // copy of filesize? No compression ever used?
  Offset       : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_WAC;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Nimrod 1.00';
  Ext  := '.wac';
  Stat := $0;
  Open := OA_WAC;
  Save := SA_WAC;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_WAC;
{ WAC archive opening function }
var i,j : integer;
    WACHeader : TWACHeader;
    WACDir    : TWACDir;
begin
 with ArchiveStream do begin
  Seek(0,soBeginning);
// Reading header (32 bytes)...
  with WACHeader do begin
   Read(WACHeader,SizeOf(WACHeader));

   if Header <> 'Nimrod1.00'#0#0#0#0#0#0 then Exit;

   RecordsCount := TotalRecords;
   ArchiveStream.Position := DirOffset;
  end;
{*}Progress_Max(RecordsCount);
// Reading WAC filetable...
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with WACDir do begin
    Read(WACDir,SizeOf(WACDir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := CFileSize; // replicates filesize
  { Excluding archive garbage in filename ^_^ }
    for j := 1 to FNLength do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;
 end;
 Result := True;

end;

function SA_WAC;
 { WAC archive creation function }
var i, j : integer;
    WACHeader : TWACHeader;
    WACDir    : TWACDir;
begin
 RecordsCount := AddedFiles.Count;

 with WACHeader do begin
  // Generating header (32 bytes)...
  Header          := 'Nimrod1.00'+#0+#0+#0+#0+#0+#0;
  DirOffset       := SizeOf(WACHeader);
  // Calculating the future directory table offset
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   DirOffset      := DirOffset + FileDataStream.Size;
   FreeAndNil(FileDataStream);
  end;
  DirSize         := SizeOf(WACDir)*AddedFiles.Count;
  HeaderSize      := SizeOf(WACHeader);
  TotalRecords    := RecordsCount;
// Creating file table...
  RFA[1].RFA_1    := SizeOf(WACHeader);
  UpOffset        := SizeOf(WACHeader);
 end;

// ...and writing file...
 ArchiveStream.Write(WACHeader,SizeOf(WACHeader));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with WACDir do begin
   FNLength := 256; // constant ...mmm, probably ^_^
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   FileSize  := RFA[i].RFA_2;
   CFileSize := RFA[i].RFA_2;
   Offset    := RFA[i].RFA_1;
   RFA[i].RFA_3 := AddedFiles.Strings[i-1]+#0; //WAC supports pathes
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to 256 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   FreeAndNil(FileDataStream);
// Writing header...
   ArchiveStream.Write(WACDir,SizeOf(WACDir));
  end;
 end;

 Result := True;

end;

end.