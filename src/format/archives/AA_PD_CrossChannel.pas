{
  AE - VN Tools
  © 2007-2013 WinKiller Studio. Open Source.
  This software is free. Please see License for details.

  Cross+Channel PackOnly\PackPlus PD archive format & functions

  Written by dsp2003.
}

unit AA_PD_CrossChannel;

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
 procedure IA_PD_PackOnly(var ArcFormat : TArcFormats; index : integer);
 procedure IA_PD_PackPlus(var ArcFormat : TArcFormats; index : integer);

  function OA_PD : boolean;
  function SA_PD(PDmode:integer) : boolean;

type
{ PD Cross+Channel format structural description. Based on the information by
  Edward Keyes. http://sekai.insani.org/ }
 TPDHeader = packed record
  Header       : array[1..8] of char;   // PackOnly or PackPlus
  Dummy        : array[1..56] of byte;  // Dummy. 56 bytes
  TotalRecords : int64;                  // 8-byte! File count.
{ The value duplicates were dummy for file count. AE now supports > 4GB archives. }
 end;
 TPDDir = packed record
  FileName     : array[1..128] of char; // Filename (128 symbols max)
  Offset       : int64;                  // 8-byte! File offset. Real archive offset.
  FileSize     : int64;                  // 8-byte! File size.
 end;

implementation

uses AnimED_Archives;

procedure IA_PD_PackOnly;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Cross+Channel PackOnly';
  Ext  := '.pd';
  Stat := $0;
  Open := OA_PD;
  Save := SA_PD;
  Extr := EA_RAW;
  FLen := 128;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

procedure IA_PD_PackPlus;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Cross+Channel PackPlus';
  Ext  := '.pd';
  Stat := $0;
  Open := OA_PD;
  Save := SA_PD;
  Extr := EA_RAW;
  FLen := 128;
  SArg := 1;
  Ver  := $20090820;
 end;
end;

function OA_PD;
{ Cross+Channel PD archive opening function }
var i,j : integer;
    PDHeader : TPDHeader;
    PDDir    : TPDDir;
    IsPackPlus : boolean;
begin
 with ArchiveStream do begin
  with PDHeader do begin
   Seek(0,soBeginning);
// Reading PD header (8 bytes)...
   Read(PDHeader,SizeOf(PDHeader));

   if (Header <> 'PackOnly') and (Header <> 'PackPlus') then Exit;

   { PackPlus archives contains XOR $FF encryption. This one switches the data reading mode. }
   if Header = 'PackPlus' then IsPackPlus := True else IsPackPlus := False;

   RecordsCount := TotalRecords;
// File records in archive = RecordsCount
   { PD Header is 72 bytes. File record is 128+8+8 = 144. }
   ReOffset := 72 + 144*RecordsCount;
// Header & table size = ReOffset
  end;
{*}Progress_Max(RecordsCount);
//Reading PD filetable...
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with PDDir do begin
    Read(PDDir,SizeOf(PDDir));
    for j := 1 to 128 do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
    if IsPackPlus then begin
     RFA[i].RFA_E := True;
     RFA[i].RFA_X := $FF;
    end;
   end;
  end;
 end;
 Result := True;

end;

function SA_PD;
 { PD Cross+Channel archive creating function }
var i, j: integer;
    PDHeader : TPDHeader;
    PDDir    : TPDDir;
    tmpStream : TStream;
begin
 with PDHeader do begin
// Generating header (72 bytes)...
  case PDmode of
   0: Header := 'PackOnly';
   1: Header := 'PackPlus';
  end;
  for i := 1 to 56 do Dummy[i] := 0;
  RecordsCount := AddedFiles.Count;
  ReOffset := 72+144*RecordsCount;
//Filetable & header size = ReOffset
//Calculating records count...
//Records count = RecordsCount
  TotalRecords := RecordsCount;
 end;

// Writing header
 ArchiveStream.Write(PDHeader,SizeOf(PDHeader));

//Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with PDDir do begin
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   Offset := RFA[i].RFA_1;
   FileSize := RFA[i].RFA_2;
   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to 128 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   FreeAndNil(FileDataStream);
// Writing filetable entry...
   ArchiveStream.Write(PDDir,SizeOf(PDDir));
  end;
 end;
// Compatibility mode check
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  if PDmode = 0 then ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size)
  else begin
   tmpStream := TMemoryStream.Create;
   BlockXORIO(FileDataStream,tmpStream,$FF);
   tmpStream.Position := 0;
   ArchiveStream.CopyFrom(tmpStream,tmpStream.Size);
   FreeAndNil(tmpStream);
  end;
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;


end.