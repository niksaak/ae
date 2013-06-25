{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  GXP AVG Engine V2 archive format & functions
  
  Written by dsp2003.
}

unit AA_GXP_AVGEngineV2;

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
 procedure IA_GXP_AVGEv2(var ArcFormat : TArcFormats; index : integer);

  function OA_GXP_AVGEv2 : boolean;
  function SA_GXP_AVGEv2(Mode : integer) : boolean;
  function EA_GXP_AVGEv2(FileRecord : TRFA) : boolean;

 procedure GXPDeCode(iStream, oStream : TStream; Length : longword);

type
 TGXPHdr = packed record
  Magic     : array[1..4] of char; // "GXP"#0
  Version   : longword; // $64 // Version 1.00
  Check     : longword; // $10 20 30 40
  Unknown0  : longword; // $1 (possibly an encryption flag?)
  Dummy     : longword; // $0
  Unknown1  : longword; // $1 (possibly an encryption flag?)
  FileCount : longword; // Number of files in archive
  FTSize    : longword; // Size of file table
  DataSize  : int64;    // Size of files, excluding file table
  FTOffsEnd : int64;    // End offset of file table
 end;

 TGXPDir = packed record
  FTLength  : longword; // obfuscated, read first
  Filesize  : int64;    // obfuscated, read everything else after
  FNLength  : longword; // Unicode filename length (x2)
  DateTime  : TDateTime;
  Offset    : int64;
  // Filename : widestring;
 end;

 TGXPFilename = packed record
  Filename  : array[1..1024] of widechar; // wide string. using / for path
 end;

implementation

uses AnimED_Archives;

procedure IA_GXP_AVGEv2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'AVG Engine v2 GXP';
  Ext  := '.gxp';
  Stat := $F;
  Open := OA_GXP_AVGEv2;
  Save := SA_GXP_AVGEv2;
  Extr := EA_GXP_AVGEv2;
  FLen := $FF;
  SArg := 0;
  Ver  := $20121111;
 end;
end;

function OA_GXP_AVGEv2;
var i,j : longword;
    Hdr : TGXPHdr;
    Dir : TGXPDir;
    DirFN : TGXPFilename;
    tmpFNWide : widestring;
    FTStream, FDStream : TStream;
begin
 Result := False;

 with ArchiveStream do begin

  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));

  with Hdr do begin

   if Magic <> 'GXP'#0 then Exit;
   if Version <> $64 then logW('AVG Engine v2 GXP: Unknown version detected: '+inttostr(Version));
   if Check <> $10203040 then Exit;
   RecordsCount := FileCount;

   // Decoding file table...
   FTStream := TMemoryStream.Create;
   FDStream := TMemoryStream.Create;
   FTStream.Copyfrom(ArchiveStream,FTSize);
   FTStream.Seek(0,soBeginning);

{*}Progress_Max(RecordsCount);

   for i := 1 to RecordsCount do begin
    GXPDeCode(FTStream,FDStream,4); // decoding length
    FTStream.Seek(-4,soCurrent);    // rewind encoded table
    FDStream.Seek(-4,soCurrent);    // rewind decoded table
    FDStream.Read(j,4);             // reading length of decoded table
    FDStream.Seek(-4,soCurrent);    // rewind decoded table
    GXPDeCode(FTStream,FDStream,j); // decode rest of the table entry
   end;

   FDStream.Seek(0,soBeginning);
   FreeAndNil(FTStream);

// Reading file table...
   for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

    with Dir,RFA[i] do begin
     FDStream.Read(Dir,SizeOf(Dir));
     RFA_1 := Offset + FTOffsEnd;
     RFA_2 := FileSize;
     RFA_C := FileSize;

     // работаем с именем файла
     FillChar(DirFN,SizeOf(DirFN),0);
     FDStream.Read(DirFN,FTLength-SizeOf(Dir)); // пудинг! >_<
     tmpFNWide := '';
     for j := 1 to FNLength do begin
      // преобразуем слэш в "нормальный"
      case DirFN.Filename[j] of
              '/': tmpFNWide := tmpFNWide + '\';
              #0 : break;
              else tmpFNWide := tmpFNWide + DirFN.Filename[j];
      end;
     end;
     // преобразуем имя файла в Shift-JIS. да, юникода у нас никогда не было ^^'
     RFA_3 := Wide2JIS(tmpFNWide);

    end;

   end;

  end;

  Result := True;
 end;

end;

function SA_GXP_AVGEv2;
{var i,j : integer;
    Dummy : array of byte;
    Hdr : TGXPHdr;
    Dir : TGXPDir;
    Filename : widestring; }
begin
 Result := False;

{ with ArchiveStream do begin

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


  for i := 1 to RecordsCount do begin
{*}{Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;

 end; // with ArchiveStream

 Result := True; }

end;

function EA_GXP_AVGEv2;
var tmpStream : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  tmpStream := TMemoryStream.Create;
  GXPDeCode(ArchiveStream,tmpStream,FileRecord.RFA_C);

  tmpStream.Seek(0,soBeginning);
  FileDataStream.CopyFrom(tmpStream,tmpStream.Size);
  FreeAndNil(tmpStream);

  Result := True;
 except
 end;
end;

// This function do not control/check seeking. Use with care.
procedure GXPDeCode;
const key : array [$0..$16] of byte = ($40,$21,$28,$38,$A6,$6E,$43,$A5,$40,$21,$28,$38,$A6,$43,$A5,$64,$3E,$65,$24,$20,$46,$6E,$74);
var i,j : longword;
begin
 for i := 0 to Length-1 do begin
  iStream.Read(j,1);
  j := j xor (key[i mod 23] xor i);
  oStream.Write(j,1);
 end;
end;

end.