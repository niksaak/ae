{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  TIM2 Engine (Mimikko Yomekko) archive format & functions

  Written by dsp2003.
}

unit AA_TIM2_ARC2;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Generic_LZXX,
     Classes, Windows, Forms, Sysutils,
     FileStreamJ, JUtils, JReconvertor;

 { Supported archives implementation }
// procedure IA_TIM2_ARC1(var ArcFormat : TArcFormats; index : integer);
 procedure IA_TIM2_ARC2(var ArcFormat : TArcFormats; index : integer);

  function OA_TIM2_ARC : boolean;
  function SA_TIM2_ARC(Mode : integer) : boolean;

  function EA_TIM2_ARC(FileRecord : TRFA) : boolean;

type
 TARC2Header = packed record
  Magic     : array[1..4] of char; // 'ARC2'
  FileCount : longword;
 end;
 
 TARC2Dir = packed record
  Offset    : longword;
  FileSize  : longword;
  FNLength  : byte;
//  FileName  : array of char; // size varies, xored by $FF
 end;

implementation

uses AnimED_Archives;

procedure IA_TIM2_ARC2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'TIM2 Engine (Mimikko Yomekko)';
  Ext  := '';
  Stat := $2;
  Open := OA_TIM2_ARC;
  Save := SA_TIM2_ARC;
  Extr := EA_TIM2_ARC;
  FLen := $FF;
  SArg := 0;
  Ver  := $20100613;
 end;
end;

function OA_TIM2_ARC;
var i,j : longword;
    Hdr : TARC2Header;
    Dir : TARC2Dir;
    Filename : array[1..$FF] of char;
    Mode : byte;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   Mode := 0;
   if Magic <> 'ARC1' then begin
    Mode := $FF;
    if Magic <> 'ARC2' then Exit;
   end;
   RecordsCount := FileCount;
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    if FNLength = 0 then Exit;
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    FillChar(FileName,$FF,0);
    Read(FileName[1],FNLength); // reading file name
    for j := 1 to FNLength do Filename[j] := char(byte(Filename[j]) xor Mode);

    RFA[i].RFA_3 := Filename;
    SetLength(RFA[i].RFA_3,FNLength); // fixing #0 symbols in the name

    // ogg files aren't encrypted
    if lowercase(ExtractFileExt(RFA[i].RFA_3)) <> '.ogg' then begin
     if Mode > 0 then RFA[i].RFA_E := True;
     RFA[i].RFA_X := Mode;
//   ogg and png files aren't compressed
//   this code is removed due to different compression detection
//   if lowercase(ExtractFileExt(RFA[i].RFA_3)) <> '.png' then RFA[i].RFA_Z := True;
    end;

   end;
  end;

  // the compressed (real) size of file is not set, damn!
  for i := 1 to RecordsCount-1 do begin
  {*}Progress_Pos(i);
   if RFA[i+1].RFA_1 <> 0 then RFA[i].RFA_C := RFA[i+1].RFA_1-RFA[i].RFA_1
   else RFA[i].RFA_C := 0;
  end;
  RFA[RecordsCount].RFA_C := ArchiveStream.Size - RFA[RecordsCount].RFA_1;

  for i := 1 to RecordsCount do begin
   if RFA[i].RFA_2 <> RFA[i].RFA_C then RFA[i].RFA_Z := True;
  end;

  Result := True;

 end;

end;

function SA_TIM2_ARC;
var i,j : integer;
    Hdr : TARC2Header;
    Dir : TARC2Dir;
    tmpStream : TStream;
    tmpExt : string;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'ARC2';
   FileCount := RecordsCount;
   ReOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
   for i := 1 to RecordsCount do ReOffset := ReOffset+length(AddedFiles.Strings[i-1]);
   UpOffset  := ReOffset;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := AddedFiles.Strings[i-1]; // supports pathes

   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;

   tmpExt := lowercase(ExtractFileExt(AddedFilesW.Strings[i-1]));

// removed cause of no compression support
{   if tmpExt <> '.ogg' then begin
    if tmpExt <> '.png' then begin
     RFA[i].RFA_C := RFA[i].RFA_2 + (RFA[i].RFA_2 div 8);
    end else RFA[i].RFA_C := RFA[i].RFA_2;
   end else} RFA[i].RFA_C := RFA[i].RFA_2;

   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_C;

   with Dir do begin
    Offset   := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
    FNLength := Length(RFA[i].RFA_3);

    for j := 1 to FNLength do RFA[i].RFA_3[j] := char(byte(RFA[i].RFA_3[j]) xor $FF);
   end;

   // пишем кусок таблицы
   Write(Dir,SizeOf(Dir));
   Write(RFA[i].RFA_3[1],Dir.FNLength);

  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   tmpExt := lowercase(ExtractFileExt(AddedFilesW.Strings[i-1]));

   if tmpExt <> '.ogg' then begin // ogg files are processed as RAW

    tmpStream := TMemoryStream.Create;
    
    tmpStream.Size := FileDataStream.Size;

    BlockXORIO(FileDataStream,tmpStream,$FF); // xoring source data

    tmpStream.Seek(0,soBeginning); // rewind stream

// removed due to no compression support
{    if tmpExt <> '.png' then begin // png files aren't compressed
     GLZSSEncode(tmpStream,ArchiveStream); // storing "compressed" file to archive
    end else} CopyFrom(tmpStream,tmpStream.Size); // storing xored file to archive

    FreeAndNil(tmpStream);

   end else CopyFrom(FileDataStream,FileDataStream.Size); // no encryption

   FreeAndNil(FileDataStream); // freeing file stream
  end;

 end; // with ArchiveStream

 Result := True;

end;

function EA_TIM2_ARC2;
var TempoStream, TempoStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_E of
   True : begin
           TempoStream := TMemoryStream.Create;
           TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
           TempoStream.Position := 0;
           if FileRecord.RFA_Z then begin
            TempoStream2 := TMemoryStream.Create;
            GLZSSDecode(TempoStream, TempoStream2, FileRecord.RFA_C, $FEE,$FFF);
            FreeAndNil(TempoStream);
            TempoStream2.Position := 0;
            BlockXOR(TempoStream2,$FF);
            TempoStream2.Position := 0;
            FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
            FreeAndNil(TempoStream2);
           end else begin
            BlockXOR(TempoStream,$FF);
            TempoStream.Position := 0;
            FileDataStream.CopyFrom(TempoStream,TempoStream.Size);
            FreeAndNil(TempoStream);
           end;
          end;
   False : FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  end;
  Result := True;
 except
  raise Exception.Create('Error in AA_TIM2_ARC.pas / TIM2/ARC2 extractor.');
 end;
end;

end.