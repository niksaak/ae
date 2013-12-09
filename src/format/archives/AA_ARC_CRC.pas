{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Casual Romance Club archive format & functions
  
  Written by dsp2003.
}

unit AA_ARC_CRC;

interface

uses AA_RFA,
     Generic_LZXX,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Classes, Windows, Forms, Sysutils,
     FileStreamJ, JUtils, JReconvertor;

 { Supported archives implementation }
 procedure IA_ARC_CRC(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_CRC : boolean;
  function SA_ARC_CRC(Mode : integer) : boolean;
  function EA_ARC_CRC(FileRecord : TRFA) : boolean;

type
 TARCHeader = packed record
  FileCount : longword;
 end;
 
 TARCDir = packed record
  Filename  : array[1..20] of char;
  FileSize  : longword;
  CFileSize : longword;
  Offset    : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_ARC_CRC;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Casual Romance Club';
  Ext  := '.arc';
  Stat := $2;
  Open := OA_ARC_CRC;
  Save := SA_ARC_CRC;
  Extr := EA_ARC_CRC;
  FLen := 20;
  SArg := 0;
  Ver  := $20100510;
 end;
end;

function OA_ARC_CRC;
var i,j : integer;
    Hdr : TARCHeader;
    Dir : TARCDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   RecordsCount := FileCount;
   if RecordsCount = 0 then Exit;
   if RecordsCount > $FFFFF then Exit;
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    if Offset = 0 then Exit;
    if Offset > ArchiveStream.Size then Exit;
    if CFileSize > ArchiveStream.Size then Exit;
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := CFileSize;
    RFA[i].RFA_Z := True;
    for j := 1 to length(FileName) do if FileName[j] <> #$FF then RFA[i].RFA_3 := RFA[i].RFA_3 + char(byte(FileName[j]) xor $FF) else break;
   end;
  end;

  Result := True;
 end;

end;

function SA_ARC_CRC;
var i,j : integer;
    Hdr : TARCHeader;
    Dir : TARCDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   FileCount := RecordsCount;
   UpOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_C := RFA[i].RFA_2 + (RFA[i].RFA_2 div 8);

   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_C;

   with Dir do begin
    Offset   := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
    CFileSize := RFA[i].RFA_C;
    FillChar(FileName,SizeOf(FileName),$FF);
    for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := char(byte(RFA[i].RFA_3[j]) xor $FF) else break;
   end;

   // пишем кусок таблицы
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
  end;
  
  for i := 1 to RecordsCount do begin
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
//   CopyFrom(FileDataStream,FileDataStream.Size);
   GLZSSEncode(FileDataStream,ArchiveStream);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;

 end; // with ArchiveStream

 Result := True;

end;

function EA_ARC_CRC;
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

end.