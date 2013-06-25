{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Futurama: The Game (PlayStation 2) archive format & functions

  Written by dsp2003.
}

unit AA_IMG_Futurama;

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
 procedure IA_IMG_Futurama(var ArcFormat : TArcFormats; index : integer);

  function OA_IMG_Futurama : boolean;
//  function SA_IMG_Futurama(Mode : integer) : boolean;

type
 TIMGHdr = packed record
  DirSize  : longword;
 end;
 TIMGFldr = packed record
// Filename : array[1..256] of char;
  TblSegSize : longword;
 end;
 TIMGDir = packed record
// Filename : array[1..256] of char
  Filesize : longword;
  Offset   : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_IMG_Futurama;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Futurama: The Game (PlayStation 2)';
  Ext  := '.img';
  Stat := $F;
  Open := OA_IMG_Futurama;
//  Save := SA_IMG_Futurama;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20111022;
 end;
end;

function OA_IMG_Futurama;
var i,j : integer;
    Hdr : TIMGHdr;
    Dir : TIMGDir;
    FileName : string;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if DirSize > ArchiveStream.Size then Exit;
   if DirSize = 0 then Exit;
  end;

// Reading file table...
  i := 0;
  while ArchiveStream.Position < Hdr.DirSize do begin
   inc(i);
   with Dir, RFA[i] do begin

    SetLength(FileName,255);

    for j := 1 to 255 do begin
     Read(FileName[j],1); {Header size is not fixed... damn!}
     if FileName[j] = #0 then begin
      SetLength(Filename,j-1);
      RFA_3 := FileName;
      break;
     end;
    end;

    Read(Dir,SizeOf(Dir));
    if Offset = 0 then Exit;
    if Offset > ArchiveStream.Size then Exit;
    RFA_1 := Offset;
    RFA_2 := FileSize;
    RFA_C := FileSize;
   end;
  end;
  
  RecordsCount := i;

  Result := True;
 end;

end;

{function SA_ARC_KISS;
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

{*}{Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}{Progress_Pos(i);

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
{*}{Progress_Pos(i);
   // writing files
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;
  
 end;

 Result := True;

end;}

end.