{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  RPD Rejet archive format & functions
  
  Written by dsp2003.
}

unit AA_RPD_Rejet;

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
 procedure IA_RPD_Rejet(var ArcFormat : TArcFormats; index : integer);

  function OA_RPD_Rejet : boolean;
  function SA_RPD_Rejet(Mode : integer) : boolean;

type
 TRPDHdr = packed record
  TableSize : longword;
  Filecount : longword; // xor $FF
 end;

 TRPDDir = packed record // xor $FF
//FNLength  : longword;
//Filename  : string;
  Filesize  : longword;
  Offset    : longword;
  Dummy     : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_RPD_Rejet;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Rejet';
  Ext  := '.rpd';
  Stat := $0;
  Open := OA_RPD_Rejet;
  Save := SA_RPD_Rejet;
  Extr := EA_RAW;
  FLen := 24;
  SArg := 0;
  Ver  := $20111022;
 end;
end;

function OA_RPD_Rejet;
var i,j,k : longword;
    Hdr : TRPDHdr;
    Dir : TRPDDir;
    Filename : string;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if TableSize > Size then Exit;
   RecordsCount := FileCount xor $FFFFFFFF;
   if RecordsCount = 0 then Exit;
   if RecordsCount > $FFFFF then Exit;
  end;

{*}Progress_Max(RecordsCount);

// Reading file table...
  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   with Dir,RFA[i] do begin
    Read(k,SizeOf(k));
    k := k xor $FFFFFFFF;
    SetLength(Filename,k);
    Read(Filename[1],k);

    Read(Dir,SizeOf(Dir));
    RFA_1 := Offset   xor $FFFFFFFF;
    RFA_2 := FileSize xor $FFFFFFFF;
    RFA_C := RFA_2;
    RFA_E := True;
    RFA_X := $FF;

    for j := 1 to length(FileName) do begin
     case char(byte(FileName[j]) xor $FF) of
      '/' : RFA_3 := RFA_3 + '\';
      else  RFA_3 := RFA_3 + char(byte(FileName[j]) xor $FF);
     end;
    end;
   end;

  end;

  Result := True;

 end;

end;

function SA_RPD_Rejet;
var i,j,k : longword;
    Hdr : TRPDHdr;
    Dir : TRPDDir;
    Filename : string;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFilesW.Count;

  with Hdr do begin
   ReOffset  := SizeOf(Hdr)+(SizeOf(Dir)+SizeOf(k))*RecordsCount;
 { We have to calculate the header by checking the length of every filename }
   for i := 1 to RecordsCount do inc(ReOffset,Length(AddedFiles.Strings[i-1]));
   TableSize := ReOffset-4; // -4 means size of TableSize field
   FileCount := RecordsCount xor $FFFFFFFF;
   UpOffset := ReOffset;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

   with Dir do begin
 {*}Progress_Pos(i);

    FillChar(Dir,SizeOf(Dir),$FF);

    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

    // формат поддерживает пути
    Filename := AddedFiles.Strings[i-1];

    for j := 1 to Length(Filename) do begin
     case FileName[j] of
      '\' : Filename[j] := char(byte('/') xor $FF);
      else  Filename[j] := char(byte(Filename[j]) xor $FF);
     end;
    end;
    Offset   := UpOffset xor $FFFFFFFF;
    FileSize := FileDataStream.Size xor $FFFFFFFF;

    UpOffset := UpOffset + FileDataStream.Size;

    FreeAndNil(FileDataStream);
   end;

   // пишем кусок таблицы
   k := Length(Filename) xor $FFFFFFFF;

   Write(k,SizeOf(k));
   Write(Filename[1],Length(Filename));

   Write(Dir,SizeOf(Dir));

  end;

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   BlockXORIO(FileDataStream,ArchiveStream,$FF,False);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;

end.