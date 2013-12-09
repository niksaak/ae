{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  KISS Custom Reido F archive format & functions

  Written by dsp2003.
}

unit AA_ARC_KISS;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Classes, Windows, Forms, Sysutils,
     FileStreamJ, JUtils, JReconvertor;

 { Supported archives implementation }
 procedure IA_ARC_KISS(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_KISS : boolean;
  function SA_ARC_KISS(Mode : integer) : boolean;

type
 TARCHeader = packed record
  Filecount : longword;
 end;
 TARCDir = packed record
  Filename  : array[1..256] of char;
  Offset    : int64;
 end;

implementation

uses AnimED_Archives;

procedure IA_ARC_KISS;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KISS Custom Reido F';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_KISS;
  Save := SA_ARC_KISS;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20100606;
 end;
end;

function OA_ARC_KISS;
var i,j : integer;
    Hdr : TARCHeader;
    Dir : TARCDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if FileCount = 0 then Exit;
   if FileCount > $FFFF then Exit;
   RecordsCount := FileCount;
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin
   with Dir do begin

    FillChar(FileName,SizeOf(FileName),0);  //cleaning the array in order to avoid garbage

    for j := 1 to 256 do begin
     Read(FileName[j],1); {Header size is not fixed... damn!}
     if FileName[j] = #0 then begin
      RFA[i].RFA_3 := FileName;
      break;
     end;
    end;

    SetLength(RFA[i].RFA_3,Length(RFA[i].RFA_3)-1); // избавляемся от нуля
    
    Read(Offset,SizeOf(Offset));
    if Offset = 0 then Exit;
    if Offset > ArchiveStream.Size then Exit;
    RFA[i].RFA_1 := Offset;
   end;
  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   if RFA[i+1].RFA_1 <> 0 then RFA[i].RFA_2 := RFA[i+1].RFA_1-RFA[i].RFA_1 else RFA[i].RFA_2 := 0;
   RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
  end;
  RFA[RecordsCount].RFA_2 := ArchiveStream.Size - RFA[RecordsCount].RFA_1;
  RFA[RecordsCount].RFA_C := RFA[RecordsCount].RFA_2;

  Result := True;
 end;

end;

function SA_ARC_KISS;
var i,j : integer;
    Hdr : TARCHeader;
    Dir : TARCDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   FileCount := RecordsCount;
   ReOffset := SizeOf(Hdr)+SizeOf(Dir.Offset)*RecordsCount;
   for i := 1 to RecordsCount do ReOffset := ReOffset+length(ExtractFileName(AddedFiles.Strings[i-1]))+1; //+1 means zero byte
   UpOffset := ReOffset;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := AddedFiles.Strings[i-1]; // supports pathes

   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   
   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_2;
  
   with Dir do begin
    Offset := RFA[i].RFA_1;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;

    Write(Filename,length(RFA[i].RFA_3)+1);
    Write(Offset,SizeOf(Offset));
   end;

  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   // writing files
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;
  
 end;

 Result := True;

end;

end.