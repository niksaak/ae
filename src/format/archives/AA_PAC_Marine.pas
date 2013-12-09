{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  PAC Marine archive format & functions
  
  Written by dsp2003.
}

unit AA_PAC_Marine;

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
 procedure IA_PAC_Marine(var ArcFormat : TArcFormats; index : integer);

  function OA_PAC_Marine : boolean;
//  function SA_PAC_Marine(Mode : integer) : boolean;


type
 TPACHdr = packed record
  FileCount : word;
  FNSize    : byte;
  HdrSize   : longword;
 end;
 TPACDir = packed record
  // Filename : string;
  Offset    : longword;
  CFilesize : longword;
  Filesize  : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_PAC_Marine;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Marine PAC';
  Ext  := '.pac';
  Stat := $F;
  Open := OA_PAC_Marine;
//  Save := SA_PAC_Marine;
  Extr := EA_RAW;
  FLen := 24;
  SArg := 0;
  Ver  := $20120403;
 end;
end;

function OA_PAC_Marine;
var i,j : integer;
    Hdr : TPACHdr;
    Dir : TPACDir;
    Filename : string;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if FileCount = 0 then Exit;
   if FNSize = 0 then Exit;
   if HdrSize > ArchiveStream.Size then Exit;
   RecordsCount := FileCount;
  end;

{*}Progress_Max(RecordsCount);

// Reading file table...
  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);    

   with Hdr,Dir,RFA[i] do begin
    SetLength(Filename,FNSize);
    Read(Filename[1],FNSize);
    Read(Dir,SizeOf(Dir));
    // Integrity check
    if Offset+HdrSize > Size then Exit;
    if Offset+HdrSize = 0 then Exit;
    if FileSize > Size then Exit;
    if FileSize = 0 then Exit;
    // eof Integrity check
    RFA_1 := Offset+HdrSize;
    RFA_2 := FileSize;
    RFA_C := FileSize;
    for j := 1 to length(FileName) do begin
     if j = 1 then if FileName[j] < #32 then Exit;
     if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
    end;
   end;

  end;

  Result := True;
 end;

end;

{function SA_IMG_GTA3v2;
var i,j : integer;
    Dummy : array of byte;
    Hdr : TIMGHdr;
    Dir : TIMGDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'VER2';
   FileCount := RecordsCount;
   UpOffset  := SizeDiv(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048);
  end;

  Write(Hdr,SizeOf(Hdr));

{*}{Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}{Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   with Dir,RFA[i] do begin
    RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

    RFA_1 := UpOffset;
    RFA_2 := SizeDiv(FileDataStream.Size,2048);

    FreeAndNil(FileDataStream);

    UpOffset := UpOffset + RFA_2;

    Offset   := RFA_1 div 2048;
    FileSize := RFA_2 div 2048;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA_3) then FileName[j] := RFA_3[j] else break;
   end;

   // пишем кусок таблицы
   Write(Dir,SizeOf(Dir));
   
  end;

  // дописываем выравнивание
  SetLength(Dummy,SizeMod(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048));
  Write(Dummy[0],Length(Dummy));

  for i := 1 to RecordsCount do begin
{*}{Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // пишем массив-пустышку
   SetLength(Dummy,SizeMod(FileDataStream.Size,2048));
   Write(Dummy[0],Length(Dummy));
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;}

end.