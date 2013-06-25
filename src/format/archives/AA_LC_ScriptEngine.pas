{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Nexton LC-ScriptEngine game archive format & functions
  
  Written by dsp2003.
}

unit AA_LC_ScriptEngine;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms, FileStreamJ, JUtils;

 { Supported archives implementation }
 procedure IA_LCS(var ArcFormat : TArcFormats; index : integer);

  function OA_LCS : boolean;
  function SA_LCS(Mode : integer) : boolean;

type
{ Nexton LC-ScriptEngine archive format }
 TLCSHeader = packed record
  TotalRecords : longword;             // Number of file records
 end;
 TLCSDir = packed record
  Offset       : longword;             // File offset in archive
  FileSize     : longword;             // File size
  FileName     : array[1..68] of char; // empty filled with $01
 end;

implementation

uses AnimED_Archives;

procedure IA_LCS;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Nexton LC-ScriptEngine';
  Ext  := '';
  Stat := $0;
  Open := OA_LCS;
  Save := SA_LCS;
  Extr := EA_RAW;
  FLen := 68;
  SArg := 0;
  Ver  := $20091128;
 end;
end;

function OA_LCS;
{ Nexton LC-ScriptEngine archive opening function }
var i,j : integer;
    LCSHeader : TLCSHeader;
    LCSDir    : TLCSDir;
    LSTStream, tmpStream : TStream;
begin
 Result := False;
 if FileExists(ArchiveFileName+'.lst') then begin
  LSTStream := TFileStreamJ.Create(ArchiveFileName+'.lst',fmOpenRead);
  tmpStream := TMemoryStream.Create;
  tmpStream.CopyFrom(LSTStream,LSTStream.Size);
  FreeAndNil(LSTStream);
  tmpStream.Position := 0;

  BlockXOR(tmpStream,$1);

  tmpStream.Position := 0;

  with tmpStream do begin
   with LCSHeader do begin
    Seek(0,soBeginning);
 // Reading header...
    Read(LCSHeader,SizeOf(LCSHeader));

    if TotalRecords > $FFFF then Exit;

    RecordsCount := TotalRecords;
   end;
// Reading file table...
{*}Progress_Max(RecordsCount);
   for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
    with LCSDir do begin
     Read(LCSDir,SizeOf(LCSDir));
     RFA[i].RFA_1 := Offset;
     RFA[i].RFA_2 := FileSize;
     RFA[i].RFA_C := FileSize;

     for j := 1 to length(FileName) do if FileName[j] <> #1 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;

    end;
   end;
   FreeAndNil(tmpStream);
  end;
  Result := True;
 end;

end;

function SA_LCS;
{ Nexton LC-ScriptEngine archive creation function }
var i, j : integer;
    LCSHeader : TLCSHeader;
    LCSDir    : TLCSDir;
    LSTStream : TStream;
begin
 Result := False;
 LSTStream := TFileStreamJ.Create(ArchiveFileName+'.lst',fmCreate);
 with LSTStream do begin
  with LCSHeader do begin
   RecordsCount := AddedFiles.Count;
   TotalRecords := RecordsCount;
  end;

  Write(LCSHeader,SizeOf(LCSHeader));

  RFA[1].RFA_1 := 0;
  UpOffset := 0;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with LCSDir do begin
//    FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
    UpOffset       := UpOffset + FileDataStream.Size;
    RFA[i+1].RFA_1 := UpOffset;
    RFA[i].RFA_2   := FileDataStream.Size;
    RFA[i].RFA_3   := AddedFiles.Strings[i-1]; // can store path

    FreeAndNil(FileDataStream);

    Offset         := RFA[i].RFA_1;
    FileSize       := RFA[i].RFA_2;

//    if Mode = 1 then RFA[i].RFA_3 := ChangeFileExt(RFA[i].RFA_3,''); // удаляем расширение у файла

    FillChar(FileName,SizeOf(FileName),$1);

    for j := 1 to SizeOf(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;

   end;
   Write(LCSDir,SizeOf(LCSDir));
  end;
  Seek(0,soBeginning); // перематываем поток списка на начало
  BlockXOR(LSTStream,$1); // шифруем поток
 end; // with LSTtream

 FreeAndNil(LSTStream); // освобождаем поток индекс-файла

// теперь наконец пишем сам архив =)
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

end.