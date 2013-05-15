{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Neko de Pink archive format & functions

  Written by dsp2003.
}

unit AA_DET_NekodePink;

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
 procedure IA_DET_NekodePink(var ArcFormat : TArcFormats; index : integer);

  function OA_DET_NekodePink : boolean;
//  function SA_DET_NekodePink(Mode : integer) : boolean;

type
 TATMDir = packed record
  FNOffset  : longword; // Filename offset in the filename table (.nme)
  Offset    : longword; // File offset in the data segment (.det)
  CFileSize : longword; // Size of file in the data segment (.det)
  Hash      : longword; // Compressed data hash?
  Filesize  : longword; // Uncompressed file size?
 end;

implementation

uses AnimED_Archives;

procedure IA_DET_NekodePink;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Neko de Pink';
  Ext  := '.det';
  Stat := $F;
  Open := OA_DET_NekodePink;
//  Save := SA_DET_NekodePink;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20110202;
 end;
end;

function OA_DET_NekodePink;
{ GTA III/VC IMG archive opening function }
var i,j : integer;
    Dir : TATMDir;
    ATMStream, NMEStream, tmpStream : TStream;
    FileName : array[1..$FF] of char;
const NdP_Ext : array [1..3] of string = ('.det','.atm','.nme');
begin
 Result := False;

 for i := 1 to Length(NdP_Ext) do if not FileExists(ChangeFileExt(ArchiveFileName,NdP_Ext[i])) then Exit;

 // финт ушами. закрываем неправильный файл и открываем .det вне зависимости от того, какой был открыт в данный момент
 if lowercase(ExtractFileExt(ArchiveFileName)) <> NdP_Ext[1] then begin
  FreeAndNil(ArchiveStream);
  ArchiveFileName := ChangeFileExt(ArchiveFileName,NdP_Ext[1]);
  OpenFileStream(ArchiveStream,ArchiveFileName,fmOpenRead);
 end;

 OpenFileStream(tmpStream,ChangeFileExt(ArchiveFileName,NdP_Ext[2]),fmOpenRead);
 ATMStream := TMemoryStream.Create;
 ATMStream.CopyFrom(tmpStream,tmpStream.Size);
 ATMStream.Seek(0,soBeginning);
 FreeAndNil(tmpStream);

 OpenFileStream(tmpStream,ChangeFileExt(ArchiveFileName,NdP_Ext[3]),fmOpenRead);
 NMEStream := TMemoryStream.Create;
 NMEStream.CopyFrom(tmpStream,tmpStream.Size);
 NMEStream.Seek(0,soBeginning);
 FreeAndNil(tmpStream);

 with ATMStream do begin
  if ((Size-4) mod SizeOf(Dir)) <> 0 then Exit; // -4 cause of Hash value at the end of file

  RecordsCount := ((Size-4) div SizeOf(Dir));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := CFileSize;

    NMEStream.Seek(FNOffset,soBeginning);

    RFA[i].RFA_3 := ''; // fixing filename fill bug
    FillChar(FileName,SizeOf(FileName),0);  //cleaning the array in order to avoid garbage
    for j := 1 to length(FileName) do begin
     NMEStream.Read(FileName[j],1);
     if FileName[j] = #0 then break;
    end;
    RFA[i].RFA_3 := FileName;
   end;
  end;

  FreeAndNil(NMEStream);
  FreeAndNil(ATMStream);
 end;

 Result := True;

end;

{function SA_IMG_GTA3v1;
var i,j : integer;
    Dummy : array of byte;
    Dir : TIMGDir;
    dirStream : TStream;
begin
 Result := False;

 dirStream := TFileStreamJ.Create(ChangeFileExt(ArchiveFileName,'.dir'),fmCreate);

 RecordsCount := AddedFiles.Count;
 UpOffset := 0;

{*}{Progress_Max(RecordsCount);

 for i := 1 to RecordsCount do begin

{*}{Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

  RFA[i].RFA_1 := UpOffset;
  RFA[i].RFA_2 := SizeDiv(FileDataStream.Size,2048);

  UpOffset := UpOffset + RFA[i].RFA_2;

  with Dir do begin
   Offset   := RFA[i].RFA_1 div 2048;
   FileSize := RFA[i].RFA_2 div 2048;
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
  end;

  // пишем кусок таблицы
  dirStream.Write(Dir,SizeOf(Dir));
  with ArchiveStream do begin
  // пишем файл в архив
   CopyFrom(FileDataStream,FileDataStream.Size);
  // пишем массив-пустышку
   SetLength(Dummy,SizeMod(FileDataStream.Size,2048));
   Write(Dummy[0],Length(Dummy));
  end;
  // высвобождаем поток файла
  FreeAndNil(FileDataStream);
 end;
 // высвобождаем поток файла заголовка
 FreeAndNil(dirStream);

 Result := True;

end;}

end.