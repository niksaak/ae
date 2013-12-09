{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  TIM2 Engine archive format & functions
  
  Supported games:

  * Mimikko Yomekko
  * Onegai Goshujin-sama!

  Written by dsp2003.
}

unit AA_TIM2_ARC;

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
 procedure IA_TIM2_ARC1(var ArcFormat : TArcFormats; index : integer);
 procedure IA_TIM2_ARC2(var ArcFormat : TArcFormats; index : integer);

  function OA_TIM2_ARC1 : boolean;
  function OA_TIM2_ARC2 : boolean;

  function OA_TIM2_ARC(Mode : integer) : boolean;
  function SA_TIM2_ARC(Mode : integer) : boolean;

  function EA_TIM2_ARC(FileRecord : TRFA) : boolean;

  function ARC2_CompDecision(Filename : widestring) : boolean;
  function ARC2_EncDecision(Filename : widestring) : boolean;

type
 TARCXHdr = packed record
  Magic     : array[1..4] of char; // 'ARC1' или 'ARC2'
  FileCount : longword;
 end;

 TARCXDir = packed record
  Offset    : longword;
  FileSize  : longword;
  FNLength  : byte;
//FileName  : array of char; // размер варьируется, xor $FF для 'ARC2'
 end;

implementation

uses AnimED_Archives;

const tim2_id = 'TIM2 Engine ARC';

procedure IA_TIM2_ARC1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := tim2_id+'1';
  Ext  := '';
  Stat := $2;
  Open := OA_TIM2_ARC1;
  Save := SA_TIM2_ARC;
  Extr := EA_TIM2_ARC;
  FLen := $FF;
  SArg := $0;
  Ver  := $20110418;
 end;
end;

procedure IA_TIM2_ARC2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := tim2_id+'2';
  Ext  := '';
  Stat := $2;
  Open := OA_TIM2_ARC2;
  Save := SA_TIM2_ARC;
  Extr := EA_TIM2_ARC;
  FLen := $FF;
  SArg := $FF;
  Ver  := $20110418;
 end;
end;

function OA_TIM2_ARC1; begin Result := OA_TIM2_ARC($00); end;
function OA_TIM2_ARC2; begin Result := OA_TIM2_ARC($FF); end;

function OA_TIM2_ARC;
var i,j : longword;
    Hdr : TARCXHdr;
    Dir : TARCXDir;
    Filename : array[1..$FF] of char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if (Magic <> 'ARC1') and (Magic <> 'ARC2') then Exit;
   if (Magic = 'ARC1') and (Mode = $FF) then Exit;
   if (Magic = 'ARC2') and (Mode = $0) then Exit;
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
    if Mode = $FF then for j := 1 to FNLength do Filename[j] := char(byte(Filename[j]) xor $FF);

    RFA[i].RFA_3 := Filename;
    SetLength(RFA[i].RFA_3,FNLength); // fixing #0 symbols in the name

    // ogg files aren't encrypted
    if ARC2_EncDecision(RFA[i].RFA_3) then begin
     if Mode = $FF then RFA[i].RFA_E := True;
     RFA[i].RFA_X := Mode;
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

 case Mode of
 $00 : RFA_IDS := tim2_id+'1';
 $FF : RFA_IDS := tim2_id+'2';
 end;

end;

function SA_TIM2_ARC;
var i,j : integer;
    Hdr : TARCXHdr;
    Dir : TARCXDir;
    tmpStream : TStream;
    tmpExt : string;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   case Mode of
    $0 : Magic := 'ARC1';
   $FF : Magic := 'ARC2';
   end;
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

    if Mode = $FF then for j := 1 to FNLength do RFA[i].RFA_3[j] := char(byte(RFA[i].RFA_3[j]) xor $FF);
   end;

   // пишем кусок таблицы
   Write(Dir,SizeOf(Dir));
   Write(RFA[i].RFA_3[1],Dir.FNLength);

  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   if (Mode = $FF) and ARC2_EncDecision(AddedFilesW.Strings[i-1]) then begin
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

function EA_TIM2_ARC;
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
  raise Exception.Create('Error in AA_TIM2_ARC.pas extractor.');
 end;
end;

function ARC2_CompDecision;
const NoComp : array[1..3] of string = ('.png','.ogg','.jpg');
var i : byte;
begin
 Result := True;
 for i := 1 to Length(NoComp) do begin
  if lowercase(ExtractFileExt(Filename)) <> NoComp[i] then begin
   Result := False;
   break;
  end;
 end;
end;

function ARC2_EncDecision;
const NoEnc : array[1..1] of string = ('.ogg');
var i : byte;
begin
 Result := True;
 for i := 1 to Length(NoEnc) do begin
  if lowercase(ExtractFileExt(Filename)) <> NoEnc[i] then begin
   Result := False;
   break
  end;
 end;
end;

end.
