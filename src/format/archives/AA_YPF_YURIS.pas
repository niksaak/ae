{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  YU-RIS Game Engine archive format & functions

  Written by dsp2003. Specifications from w8m.
}

unit AA_YPF_YURIS;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_FileTypes,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Generic_Hashes,
     Classes, Windows, Forms, Sysutils, ZlibEx,
     FileStreamJ, JUtils, JReconvertor;

 { Supported archives implementation }
 procedure IA_YPF_YURIS_v222(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v224(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v238(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v247(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v255(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v286(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v287(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v290_34(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v290_C0(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v300(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v222z(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v224z(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v238z(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v247z(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v255z(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v286z(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v287z(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v290z_34(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v290z_C0(var ArcFormat : TArcFormats; index : integer);
 procedure IA_YPF_YURIS_v300z(var ArcFormat : TArcFormats; index : integer);

 procedure IA_YPF_YURIS_Auto(var ArcFormat : TArcFormats; index : integer);

{ function OA_YPF_YURIS_v222 : boolean;
  function OA_YPF_YURIS_v224 : boolean;
  function OA_YPF_YURIS_v238 : boolean;
  function OA_YPF_YURIS_v247 : boolean;
  function OA_YPF_YURIS_v255 : boolean;
  function OA_YPF_YURIS_v286 : boolean;
  function OA_YPF_YURIS_v287 : boolean;
  function OA_YPF_YURIS_v290_34 : boolean;
  function OA_YPF_YURIS_v290_C0 : boolean;
  function OA_YPF_YURIS_v300 : boolean;}

  function OA_YPF_YURIS_Auto : boolean;

  function OA_YPF_YURIS(Mode : integer = $FFFF; ExtraKey : byte = $FF) : boolean;
  function SA_YPF_YURIS(Mode : integer) : boolean;
  function EA_YPF_YURIS(FileRecord : TRFA) : boolean;

  function YURIS_CryptLen(CurValue : byte; Version : longword) : byte;

 procedure YURIS_RecoveryRecord_Make(iStream, oStream : TStream; BlockLength : integer = $400; RewindOutput : boolean = True; Version : word = $FF);

type
 TYPFHeader = packed record
  Magic     : array[1..4] of char; // 'YPF'#0
  Version   : longword; // $122 | $FF | $F7 | $EE
  FileCount : longword;
  FTSize    : longword; // file table size. $122 - FTSize+SizeOf(Header) | $FF/$F7 - FTSize
  Dummy     : array[1..16] of byte; // #0
 end;

 TYPFDirHeader = packed record
  FNHash    : longword; // filename adler32 or crc32 checksum
  EncFNLen  : byte;     // Encrypted filename length xor $FF + проход по таблице
 end;
// TYPFFilename = array[1..256] of char;
 TYPFDir = packed record
  Filetype  : byte; // 0x0F7: 0-ybn, 1-bmp, 2-png, 3-jpg, 4-gif, 5-avi, 6-wav, 7-ogg, 8-psd
                    // 0x122: 0-ybn, 1-bmp, 2-png, 3-jpg, 4-gif, 5-wav, 6-ogg, 7-psd
  ZlibFlag  : byte; // 1 - compressed with zlib
  FileSize  : longword; // file size
  CFileSize : longword; // compressed file size
  Offset    : longword; // file offset
  CAdler32  : longword; // packed file checksum
 end;

 TYPFRecoveryRecord = packed record
  BlockSize  : longword; // length of recovery record block (usually 0x400)
  BlockNum   : longword; // number of blocks
 end;
 { word - block
   1024 - xor of every block
   if block is lesser than 1024, then fill the rest with zeroes }

const
  YURIS_FT : array[0..8] of string = ('.ybn','.bmp','.png','.jpg','.gif','.avi','.wav','.ogg','.psd');
  YURIS_FT_New : array[0..7] of string = ('.ybn','.bmp','.png','.jpg','.gif','.wav','.ogg','.psd');

  ypf_yuris_ver = $20100905;
  ypf_yuris_id  = 'YU-RIS Game Engine';
  ypf_ext = '.ypf';

implementation

uses AnimED_Archives;

procedure IA_YPF_YURIS_Auto;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' (Autodetect)';
  Ext  := ypf_ext;
  Stat := $F;
  Open := OA_YPF_YURIS_Auto;
  Save := SA_YPF_YURIS;
  Extr := EA_YPF_YURIS;
  FLen := $FF;
//  SArg := $0;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v222;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v222 (0xFF)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF00DE; // $AABCCC : A - encryption key, B - compression flag, C - version
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v224;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v224 (0xFF)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF00E0;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v238;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v238 (0xBF)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $BF00EE;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v247;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v247 (0xFF)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF00F7;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v255;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v255 (0xFF)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF00FF;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v286;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v286 (0xFF)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF011E;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v287;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v287 (0xFF)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF011F;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v290_34;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v290 (0x34)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $340122;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v290_C0;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v290 (0xC0)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $C00122;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v300;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v300 (0x28)';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $28012C;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v222z;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v222 (0xFF) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF10DE;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v224z;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v224 (0xFF) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF10E0;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v238z;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v238 (0xBF) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $BF10EE;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v247z;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v247 (0xFF) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF10F7;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v255z;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v255 (0xFF) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF10FF;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v286z;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v286 (0xFF) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF111E;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v287z;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v287 (0xFF) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $FF111F;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v290z_34;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v290 (0x34) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $341122;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v290z_C0;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v290 (0xC0) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $C01122;
  Ver  := ypf_yuris_ver;
 end;
end;

procedure IA_YPF_YURIS_v300z;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := ypf_yuris_id+' v300 (0x28) +zlib';
  Ext  := ypf_ext;
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_YPF_YURIS;
  Extr := EA_Dummy;
  FLen := $FF;
  SArg := $28112C;
  Ver  := ypf_yuris_ver;
 end;
end;

function OA_YPF_YURIS_Auto; begin Result := OA_YPF_YURIS($FFFF,$0); end;

function OA_YPF_YURIS;
var i,j,k : integer;
    XorKey : byte;
    Hdr    : TYPFHeader;
    DirHdr : TYPFDirHeader;
    Dir    : TYPFDir;
    RecRec : TYPFRecoveryRecord;
    FileName : array of char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);

  Read(Hdr,SizeOf(Hdr));

  with Hdr do begin
   if Magic <> 'YPF'#0 then Exit;
   RecordsCount := FileCount;

   if Version > Mode then Exit;

   XorKey := ExtraKey; // xorkey = $ff by default
  end;

  with RFA[0] do begin
   SetLength(RFA_T,1);
   SetLength(RFA_T[0],3);
   case Hdr.Version of
    $100..$12C: RFA_T[0][0] := 'F/N CRC32';   // filename hash
    else        RFA_T[0][0] := 'F/N Adler32'; // filename hash
   end;
   RFA_T[0][1] := 'Cmp Adler32'; // compressed data hash
   RFA_T[0][2] := 'IntFileType'; // internal file type
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin

   with RFA[i] do begin
    SetLength(RFA_T,1);
    SetLength(RFA_T[0],3);
   end;

   Read(DirHdr,SizeOf(DirHdr)); // header part of file table

   with DirHdr do begin

    RFA[i].RFA_T[0][0] := inttohex(FNHash,8);

    j := YURIS_CryptLen(EncFNLen xor $FF,Hdr.Version); // decrypting filename length

    SetLength(FileName,j);

    Read(FileName[0],j); // reading encrypted filename

    SetLength(RFA[i].RFA_3,j);

    if i = 1 then // doing it only once
     case Mode of
     $FFFF : begin // xor key autodetection mode
              XorKey := byte(FileName[j-4]) xor $2E;
//            Log('YU-RIS autodetection: v'+inttostr(Hdr.Version)+' (0x'+inttohex(XorKey,2)+')');
             end;
     else if (byte(FileName[j-4]) xor XorKey) <> $2E then Exit; // encryption check by file extension dot (mostly an hack)
     end;

    for k := 1 to j do RFA[i].RFA_3[k] := char(byte(FileName[k-1]) xor XorKey); // decrypting filename

    SetLength(FileName,0);

   end;

   Read(Dir,SizeOf(Dir)); // the rest of file table

   with Dir, RFA[i] do begin

    RFA_1 := Offset;
    RFA_2 := FileSize;
    RFA_C := CFileSize;
    RFA_X := acZlib;
    RFA_Z := boolean(ZlibFlag);
    RFA_T[0][1] := inttohex(CAdler32,8);

    case Hdr.Version of
     $100..$12C : RFA_T[0][2] := YURIS_FT_New[FileType];
     else         RFA_T[0][2] := YURIS_FT[FileType];
    end;

   end;

   if Hdr.Version { $DE..$E0 } < $E1 then Read(RecRec,SizeOf(RecRec)); // reading rr header
   
  end;

 end; // with ArchiveStream

 Result := True;

 RFA_IDS := ypf_yuris_id+' v'+inttostr(Hdr.Version)+' (0x'+inttohex(XorKey,2)+')';

end;

function SA_YPF_YURIS;
var i, j     : integer;
    Hdr      : TYPFHeader;
    DirHdr   : TYPFDirHeader;
    Dir      : TYPFDir;
    RecRec   : TYPFRecoveryRecord;
    XorKey   : byte;
    CompMode : boolean;
    Ext      : string;
    tmpStream, tmpTable, tmpName : TStream;
    NoCompress : boolean;
const DefBlockLen = $400;
begin
 Result := False;

 RecordsCount := AddedFilesW.Count;

 // preparing header
 with Hdr do begin
  Magic := 'YPF'#0;
  FileCount := RecordsCount;
  FillChar(Dummy,SizeOf(Dummy),0);

  UpOffset := (SizeOf(DirHdr)+SizeOf(Dir))*FileCount; // size of filetable without names

  for i := 1 to RecordsCount do UpOffset := UpOffset + Length(AddedFiles.Strings[i-1]); // + names

  XorKey      := Mode shr 16;                        // filename encryption
  Hdr.Version := Mode and $FFF;                      // archive version
  CompMode    := boolean((Mode and $001000) shr 12); // compression flag

  case Version of
  $DE..$E0 : UpOffset := UpOffset + SizeOf(RecRec)*FileCount; // appending size of recovery record headers
  end;

  ReOffset := UpOffset + SizeOf(Hdr);

  case Version of
     $0..$FF  : FTSize := UpOffset; // Filetable size
   $100..$122 : FTSize := ReOffset; // Filetable size + Header size
   
  end;

 end;

 tmpTable := TMemoryStream.Create; // initialising temporary file table container
 tmpTable.Size := UpOffset;        // making empty file table
 tmpTable.Seek(0,soBeginning);     // setting position to 0, just in case ^_^''

 with ArchiveStream do begin

  Write(Hdr,SizeOf(Hdr));
  CopyFrom(tmpTable,tmpTable.Size); // writing empty file table

  tmpTable.Seek(0,soBeginning);     // rewinding file table

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   // working with filename's adler32
   tmpName := TMemoryStream.Create;
   tmpName.Write(AddedFiles.Strings[i-1][1],Length(AddedFiles.Strings[i-1]));
   tmpName.Seek(0,soBeginning);

   with DirHdr do begin
    case Hdr.Version of
    $100..$12C : FNHash := CRC32(tmpName); // crc32 checksum of shift-jis filename
    else begin
          FNHash := sAdler32Init; // initialising adler32
          sAdler32(tmpName,integer(FNHash)); // adler32 checksum of shift-jis filename
         end;
    end;
    EncFNLen := Length(AddedFiles.Strings[i-1]); // setting filename length
    EncFNLen := YURIS_CryptLen(EncFNLen,Hdr.Version) xor $FF; // encrypting filename length
   end;

   tmpTable.Write(DirHdr,SizeOf(DirHdr)); // writing table entry header

   BlockXORIO(tmpName,tmpTable,XorKey,False); // encrypting filename and writing to table

   FreeAndNil(tmpName); // freeing filename stream

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead); // opening the file

   with Dir do begin

    FileSize := FileDataStream.Size; // uncompressed size of file
    Offset   := ReOffset;            // file offset in archive

    // working with Filetype field
    Ext      := lowercase(ExtractFileExt(AddedFiles.Strings[i-1]));
    case Hdr.Version of
    $100..$12C : for j := 0 to Length(YURIS_FT_New)-1 do if Ext = YURIS_FT_New[j] then begin
                  Filetype := j;
                  Break;
                 end;
    else         for j := 0 to Length(YURIS_FT)-1 do if Ext = YURIS_FT[j] then begin
                  Filetype := j;
                  Break;
                 end;
    end;

    // working with compression exceptions list
    for j := 0 to CmpExceptList.Count-1 do begin
     NoCompress := False;
     if Ext = CmpExceptList.Strings[j] then begin
      NoCompress := True;
      break;
     end;
    end; // for

    // working with file compression
    if (not CompMode) or NoCompress then begin // no compression
     ZlibFlag  := 0;
     CFileSize := FileSize;

     CAdler32 := sAdler32Init;                   // initialising file's adler32
     sAdler32(FileDataStream,integer(CAdler32)); // calculating file's adler32

     FileDataStream.Seek(0,soBeginning);         // rewinding file stream

     ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size); // writing file to archive
     ReOffset := ReOffset + FileDataStream.Size; // updating offset counter

     YURIS_RecoveryRecord_Make(FileDataStream,ArchiveStream,DefBlockLen,False,Hdr.Version); // writing recovery record

     case Hdr.Version of
     $0DE..$0E0 : begin
                   ReOffset := ReOffset + 2*SizeBlock(FileDataStream.Size,DefBlockLen) + DefBlockLen; // updating offset counter
                   // making recovery record entry for old archive format
                   RecRec.BlockSize := DefBlockLen;
                   RecRec.BlockNum  := SizeBlock(FileDataStream.Size,DefBlockLen);
                  end;
     $0E1..$12B : ReOffset := ReOffset + SizeOf(TYPFRecoveryRecord) + 2*SizeBlock(FileDataStream.Size,DefBlockLen) + DefBlockLen; // updating offset counter
     $12C       : ReOffset := ReOffset + 4; // 4 zero-bytes
     end;

    end else begin // zlib compression
     ZlibFlag := 1;

     tmpStream := TMemoryStream.Create;     // initialising compression stream

     ZCompressStream(FileDataStream,tmpStream); // compressing file

     CFileSize := tmpStream.Size;           // setting compressed file size

     CAdler32 := sAdler32Init;              // initialising file's adler32
     sAdler32(tmpStream,integer(CAdler32)); // calculating file's adler32

     tmpStream.Seek(0,soBeginning);         // rewinding compressed stream

     ArchiveStream.CopyFrom(tmpStream,tmpStream.Size); // writing compressed file to archive
     ReOffset := ReOffset + tmpStream.Size; // updating offset counter

     YURIS_RecoveryRecord_Make(tmpStream,ArchiveStream,DefBlockLen,False,Hdr.Version); // writing recovery record

     case Hdr.Version of
     $0DE..$0E0 : begin
                   ReOffset := ReOffset + 2*SizeBlock(tmpStream.Size,DefBlockLen) + DefBlockLen; // updating offset counter
                   // making recovery record entry for old archive format
                   RecRec.BlockSize := DefBlockLen;
                   RecRec.BlockNum  := SizeBlock(tmpStream.Size,DefBlockLen);
                  end;
     $0E1..$12B : ReOffset := ReOffset + SizeOf(TYPFRecoveryRecord) + 2*SizeBlock(tmpStream.Size,DefBlockLen) + DefBlockLen; // updating offset counter
     $12C       : ReOffset := ReOffset + 4; // 4 zero-bytes
     end;

     FreeAndNil(tmpStream); // freeing compression stream
    end;

   end; // with Dir

   FreeAndNil(FileDataStream); // closing the file

   // writing part of table
   tmpTable.Write(Dir,SizeOf(Dir));
   // ...and rr table entry if needed
   if Hdr.Version < $E1 then tmpTable.Write(RecRec,SizeOf(RecRec));

  end;

  tmpTable.Seek(0,soBeginning);

  Seek(SizeOf(Hdr),soBeginning); // seeking to the beginning of blank file table

  CopyFrom(tmpTable,tmpTable.Size); // writing ready file table

  FreeAndNil(tmpTable); // freeing file table stream

 end; // with ArchiveStream

 Result := True;

end;

function EA_YPF_YURIS;
var tmpStreamC : TStream;
begin
 Result := False;
 try
  case FileRecord.RFA_Z of
   True : begin
           tmpStreamC := TMemoryStream.Create;
           ArchiveStream.Position := FileRecord.RFA_1;
           tmpStreamC.Size := FileRecord.RFA_C;
           tmpStreamC.Position := 0;
           tmpStreamC.CopyFrom(ArchiveStream,FileRecord.RFA_C);
           tmpStreamC.Position := 0;

           FileDataStream.Size := FileRecord.RFA_2;
           FileDataStream.Position := 0;

           ZDecompressStream(tmpStreamC,FileDataStream);

           FreeAndNil(tmpStreamC);
          end;
  False : begin
           ArchiveStream.Position := FileRecord.RFA_1;
           FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
          end;
  end;
  Result := True;

 except
  { улыбаемся и машем }
 end;
end;

// CurValue := CurValue xor $FF;
// Before calling this function - for decoding. After - for encoding
function YURIS_CryptLen;
const LenTable : array[0..23] of byte = (
 $03,$48,$06,$35,         // $122
 $0C,$10,$11,$19,$1C,$1E, // $000..$0FF
 $09,$0B,$0D,$13,$15,$1B, // $12C
 $20,$23,$26,$29,
 $2C,$2F,$2E,$32);
var i, j : integer;
begin

 case Version of
  $122..$12B : j := 0;
  $12C       : j := 5;
  else         j := 2; // $00..$FF, $100..$121, $12D..$infinity :3
 end;

 Result := CurValue;

 for i := j to 11 do begin
  if CurValue = LenTable[i*2] then begin
   Result := LenTable[i*2+1];
   break;
  end else if CurValue = LenTable[i*2+1] then begin
   Result := LenTable[i*2];
   break;
  end;
 end;

end;

// Yes, this thingy uses recovery record
procedure YURIS_RecoveryRecord_Make;
var i,j  : longword;
    a,b  : array of byte;
    Hdr  : TYPFRecoveryRecord;
    Tail : longword;
    Hash : word;
begin
 iStream.Seek(0,soBeginning);
 if RewindOutput then oStream.Seek(0,soBeginning);

 if Version < $12C then begin

  with Hdr do begin
   BlockSize := BlockLength;
   BlockNum := SizeBlock(iStream.Size,BlockLength);
  end;

  if Version > $E0 then oStream.Write(Hdr,SizeOf(Hdr)); // writing recovery record header

  Tail := iStream.Size mod BlockLength; // getting length of tail

  SetLength(b,BlockLength); // initialising xor block

  for i := 0 to Hdr.BlockNum-1 do begin

   SetLength(a,BlockLength); // setting block buffer length

   if (Tail > 0) and (i = Hdr.BlockNum-1) then iStream.Read(a[0],Tail) else iStream.Read(a[0],BlockLength);

   Hash := sAdler32Init;
   Hash := zadler32(Hash,a[0],BlockLength);

   oStream.Write(Hash,SizeOf(Hash)); // writing block hash

   for j := 0 to BlockLength-1 do b[j] := b[j] xor a[j]; // adding to xor block

   SetLength(a,0); // setting block buffer length to zero

  end;

  oStream.Write(b[0],BlockLength); // writing xor block

 end else begin // zero recovery record

  Tail := 0;
  oStream.Write(Tail,4);

 end;

end;

end.