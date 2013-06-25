{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  nScripter SAR, NSA & NS2 game archive formats & functions

  Written by dsp2003 & Nik.
}

unit AA_nScripter;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     Generic_LZXX,
     AnimED_Graphics,
     AG_StdFmt,
     SysUtils, Classes, Windows, Forms, FileStreamJ, JUtils;

 { Supported archives implementation }
 procedure IA_SAR(var ArcFormat : TArcFormats; index : integer);
 procedure IA_NSA(var ArcFormat : TArcFormats; index : integer);
 procedure IA_NS2(var ArcFormat : TArcFormats; index : integer);
 procedure IA_NScriptDAT(var ArcFormat : TArcFormats; index : integer);

  function OA_NSA : boolean;
  function SA_NSA(Mode : integer) : boolean;
  function EA_NSA(FileRecord : TRFA) : boolean;

  function OA_SAR : boolean;
  function SA_SAR(Mode : integer) : boolean;

  function OA_NS2 : boolean;
  function SA_NS2(Mode : integer) : boolean;

  function OA_NScriptDAT : boolean;

  // вдохновление на эти функции было взято не в дебагере
  // sad but true
  // yes, we are LAZY!!!

  // во всех функциях, которые юзают эту функцию, результат не может быть больше байта
  // но если где-то ещё будет заюзана эта функция, нужно учесть, что возвращаетмый результат - байт
  function NSA_DecodeByte(Stream : TStream; var mask:byte; var storbyte: byte; len:cardinal) : byte;
  function NSA_LZSSDecode(InputStream, OutputStream : TStream; CryptLength, DecryptLength, SlideWindowIndex, SlideWindowLength : integer) : boolean;
  function NSA_SPBDecode(InputStream, OutputStream : TStream) : boolean;

type
{ nScripter archive format (uncompressed only) }

{ NSA archives uses IDIOTICAL big-endian byte order, so they must be flipped
  via EndianSwap function >_< }
 TNSAHeader = packed record
  FileCount   : word;     // File count
  HeaderSize  : longword; // Header size
 end;
// TNSADirFN  = array[1..256] of char; // Filename+full path (size varies), zero-terminated
 TNSADir    = packed record
  Compression : byte;     // Compression type. 0 - no compression, 1 - "SPB", 2 - lzss. FUCK COMPRESSIONS!
  Offset      : longword; // Same as in LNK format - Offset := Offset + HeaderSize;
  CFileSize   : longword; // compressed file size (duplicates FileSize, because AnimED do not support compressed data)
  FileSize    : longword; // uncompressed file size
 end;

{ The same rules as NSA applied to SAR, except for this format uses no compression (honto desu ka?) }
 TSARHeader = packed record
  FileCount   : word;     // File count
  HeaderSize  : longword; // Header size (SARHeader+SARDir)
 end;
// TSARDirFN  = TNSADirFN;    // Filename+full path (size varies), zero-terminated
 TSARDir    = packed record
  Offset      : longword; // Same as in LNK format - Offset := Offset + HeaderSize;
  FileSize    : longword; // File size
 end;
 
// TNS2Header = packed record
//  HeaderSize  : longword;
// end;
// TNS2Dir = packed record
//  Filename : TNSADirFN; // Filename+full path (size varies), starts and ends with " (quote symbol)
//  Filesize : longword;
// end;
// TNS2End = packed record
//  EndMark : byte; // "e"
// end;

implementation

uses AnimED_Archives;

procedure IA_SAR;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Scripter 3 / nScripter';
  Ext  := '.sar';
  Stat := $0;
  Open := OA_SAR;
  Save := SA_SAR;
  Extr := EA_RAW; // Must be EA_SAR in the future
  FLen := $FF;
  SArg := 0;
  Ver  := $20101222;
 end;
end;

procedure IA_NSA;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'nScripter';
  Ext  := '.nsa';
  Stat := $2;
  Open := OA_NSA;
  Save := SA_NSA;
  Extr := EA_NSA;
  FLen := $FF;
  SArg := 0;
  Ver  := $20101222;
 end;
end;

procedure IA_NS2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'nScripter Format 2';
  Ext  := '.ns2';
  Stat := $0;
  Open := OA_NS2;
  Save := SA_NS2;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20120316;
 end;
end;

procedure IA_NScriptDAT;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'nScripter Encoded Script File';
  Ext  := '.dat';
  Stat := $F;
  Open := OA_NScriptDAT;
//  Save := SA_Unsupported; // temporary, must be SA_NScriptDAT
  Extr := EA_RAW;
  FLen := 0;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_NS2;
var i,j : integer;
  Hdr, Dir : longword;
  Filename : array[1..256] of char;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));

  if ((Hdr = 0) or (Hdr > ArchiveStream.Size)) then Exit;
  ReOffset := Hdr;

  i := 0;
  UpOffset := 0;

  while ArchiveStream.Position < Hdr do begin

   inc(i);

   RFA[i].RFA_3 := ''; // fixing filename fill bug
   FillChar(FileName,SizeOf(FileName),0); //cleaning the array in order to avoid garbage
   Read(Filename[1],1);
   if (Filename[1] <> 'e') and (Filename[1] <> '"') then Exit;
   // 'e' means end of file table
   if Filename[1] = 'e' then break; // out of "while"
   if Filename[1] = '"' then for j := 1 to 256 do begin
    Read(FileName[j],1);
    if FileName[j] = '"' then break; // out of "for"
   end;
   for j := 1 to length(FileName) do if FileName[j] <> '"' then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;

   Read(Dir,SizeOf(Dir));
   if Dir > ArchiveStream.Size then Exit;

   RFA[i].RFA_1 := UpOffset+ReOffset;
   RFA[i].RFA_2 := Dir;
   RFA[i].RFA_C := Dir;

   UpOffset := UpOffset + Dir;
   if UpOffset > ArchiveStream.Size then Exit;
  end;
 end;

 RecordsCount := i-1;

 Result := True;

end;

function SA_NS2;
var i, j : integer;
    Hdr, Dir : longword;
    Filename : array[1..256] of char;
    Mark : char;
begin
 RecordsCount := AddedFilesW.Count;
 ReOffset := 1+SizeOf(Hdr)+SizeOf(Dir)*RecordsCount; // 1 is a leading "e" character at the end of table
{ We have to calculate the header by checking the length of every filename, because the header size is not fixed }
 for i := 1 to RecordsCount do ReOffset := ReOffset+length(AddedFiles.Strings[i-1])+2; //+2 means quote mark bytes
 Hdr := ReOffset;

// Writing NS2 header...
 ArchiveStream.Write(Hdr,SizeOf(Hdr));

//Creating file table...
 RFA[1].RFA_1 := 0;
 UpOffset := 0;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  UpOffset := UpOffset + FileDataStream.Size;
  RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
  RFA[i].RFA_2 := FileDataStream.Size;
  RFA[i].RFA_3 := AddedFiles.Strings[i-1]; // NS2 supports pathes, but no unicode ._.

  for j := 1 to length(RFA[i].RFA_3) do FileName[j] := RFA[i].RFA_3[j];

  Dir := RFA[i].RFA_2;
  FreeAndNil(FileDataStream);

  with ArchiveStream do begin

   Mark := '"';

   Write(Mark,SizeOf(Mark)); // "
   Write(Filename,length(RFA[i].RFA_3));
   Write(Mark,SizeOf(Mark)); // "
   Write(Dir,SizeOf(Dir));

   if i = RecordsCount then begin
    Mark := 'e';
    Write(Mark,SizeOf(Mark)); // marker for end of file table
   end;

  end;

 end;
// Writing file...

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function OA_SAR;
{ nScripter standard archive opening function }
var i,j : integer;
  SARHeader : TSARHeader;
  SARDir    : TSARDir;
  Filename  : array[1..256] of char;
begin
 Result := False;
 with ArchiveStream do begin
  with SARHeader do begin
   Seek(0,soBeginning);
// Reading SAR header (6 bytes)...
   Read(SARHeader,SizeOf(SARHeader));
// Converting endian
   SARHeader.FileCount := EndianSwap16(FileCount);
   SARHeader.HeaderSize := EndianSwap(HeaderSize);

   if ((FileCount = 0) or (HeaderSize > ArchiveStream.Size)) or (HeaderSize = 0) then Exit;

   ReOffset := HeaderSize;
   RecordsCount := FileCount;

  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with SARDir do begin
    RFA[i].RFA_3 := ''; // fixing filename fill bug
    FillChar(FileName,SizeOf(FileName),0); //cleaning the array in order to avoid garbage
    for j := 1 to 256 do begin
     Read(FileName[j],1); {Header size is not fixed... damn!}
     if FileName[j] = #0 then break;
    end;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j];
    Read(SARDir,SizeOf(SARDir));
    Offset := EndianSwap(Offset);
    FileSize := EndianSwap(FileSize);
    if Offset > ArchiveStream.Size then Exit;
    if FileSize > ArchiveStream.Size then Exit;
    RFA[i].RFA_1 := Offset+ReOffset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
   end;
  end;
 end;

 Result := True;

end;

{ A bit reedited from NSA creation function (same format, just simplier ~nya! ^_^ ) }
function SA_SAR;
var i, j : integer;
    SARHeader : TSARHeader;
    SARDir    : TSARDir;
    Filename  : array[1..256] of char;
begin
 with SARHeader do begin
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(SARHeader)+SizeOf(SARDir)*RecordsCount;
  FileCount := EndianSwap16(RecordsCount);
{ We have to calculate the header by checking the length of every filename, because the header size is not fixed }
  for i := 1 to RecordsCount do ReOffset := ReOffset+length(AddedFiles.Strings[i-1])+1; //+1 means zero byte
  HeaderSize := EndianSwap(ReOffset);
 end;

// Writing SAR Header...
 ArchiveStream.Write(SARHeader,SizeOf(SARHeader));

//Creating file table...
 RFA[1].RFA_1 := 0;
 UpOffset := 0;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  with SARDir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_3 := AddedFiles.Strings[i-1]+#0; // SAR supports pathes

   for j := 1 to length(RFA[i].RFA_3) do begin
    if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j]
    else FileName[j] := #0;
   end;

   Offset   := EndianSwap(RFA[i].RFA_1);
   FileSize := EndianSwap(RFA[i].RFA_2);
   FreeAndNil(FileDataStream);

   with ArchiveStream do begin
    Write(Filename,length(RFA[i].RFA_3));
    Write(SARDir,SizeOf(SARDir));
   end;

  end;

 end;
// Writing file...

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function OA_NSA;
{ nScripter plain (uncompressed) archive opening function }
var NSAHeader : TNSAHeader;
    NSADir    : TNSADir;
    Filename  : array[1..256] of char;
    i, z : longword;
begin
 Result := False;
 with ArchiveStream do begin
  with NSAHeader do begin
   Seek(0,soBeginning);
// Reading NSA header (6 bytes)...
   Read(NSAHeader,SizeOf(NSAHeader));
// Converting endian
   NSAHeader.FileCount := EndianSwap16(FileCount);
   NSAHeader.HeaderSize := EndianSwap(HeaderSize);

   if ((FileCount = 0) or (HeaderSize > ArchiveStream.Size)) or (HeaderSize = 0) then Exit;

   ReOffset := HeaderSize;
   RecordsCount := FileCount;

  end;
// Reading file table...

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with NSADir do begin
    RFA[i].RFA_3 := ''; // fixing filename fill bug
    FillChar(FileName,length(FileName),0); //cleaning the array in order to avoid garbage
    for z := 1 to length(Filename) do begin
     Read(FileName[z],1); {Header size is not fixed... damn!}
     if FileName[z] = #0 then break;
    end;
    for z := 1 to length(FileName) do if FileName[z] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[z] else break;
    Read(NSADir,SizeOf(NSADir));
    Offset    := EndianSwap(Offset);
    CFileSize := EndianSwap(CFileSize);
    FileSize  := EndianSwap(FileSize);
    if Offset > ArchiveStream.Size then Exit;
    if FileSize = CFileSize then if FileSize > ArchiveStream.Size then Exit;
    RFA[i].RFA_1 := Offset+ReOffset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := CFileSize;
    RFA[i].RFA_X := Compression;
    if Filesize <> CFileSize then RFA[i].RFA_Z := True else RFA[i].RFA_Z := False;
   end;
  end;
 end;

 Result := True;

end;

function SA_NSA;
var i, j      : integer;
    NSAHeader : TNSAHeader;
    NSADir    : TNSADir;
    Filename  : array[1..256] of char;
begin
 with NSAHeader do begin
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(NSAHeader)+13*RecordsCount;
{ Explaination: FileCount is word (01 02), but ConvEndian will return (02 01 00 00),
  so we must exclude those 2 false zeroes by shifting it in right }
  FileCount := EndianSwap(RecordsCount) shr 16;
{ We have to calculate the header by checking the length of every filename,
  because the header size is not fixed }
  for i := 1 to RecordsCount do ReOffset := ReOffset+length(AddedFiles.Strings[i-1])+1; //+1 means zero byte
  HeaderSize := EndianSwap(ReOffset);
//Full header size = ReOffset
 end;

// Writing NSA Header...
 ArchiveStream.Write(NSAHeader,SizeOf(NSAHeader));

//Creating file table...
 RFA[1].RFA_1 := 0;
 UpOffset := 0;
{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  with NSADir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_3 := AddedFiles.Strings[i-1]+#0; //NSA supports pathes

   for j := 1 to length(RFA[i].RFA_3) do begin
    if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j]
    else FileName[j] := #0;
   end;

   Compression := 0;                        // AnimED uses no compression
   Offset      := EndianSwap(RFA[i].RFA_1);
   CFileSize   := EndianSwap(RFA[i].RFA_2); // AnimED uses no compression
   FileSize    := EndianSwap(RFA[i].RFA_2);
   FreeAndNil(FileDataStream);

   with ArchiveStream do begin
    Write(Filename,length(RFA[i].RFA_3));
    Write(NSADir,SizeOf(NSADir));                                      
   end;

  end;
 end;
// Writing file...

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function NSA_DecodeByte;
var i : cardinal;
    res : byte;
begin
 res := 0;
 if len <> 0 then begin
  for i := 0 to len-1 do begin
   if mask = 0 then begin
    mask := $80;
    stream.Read(storbyte,1);
   end;
   res := res shl 1;
   if (storbyte and mask) <> 0 then inc(res);
   mask := mask shr 1;
  end;
 end;
 Result := res;
end;

function NSA_LZSSDecode;
var SlidingWindow : array of byte;
  i : integer;
  data, flag, mask, storbyte, w_index, length : byte;
begin
 SetLength(SlidingWindow,SlideWindowLength+1);
 mask := 0;
 storbyte := 0;

 while InputStream.Position < InputStream.Size do begin
  flag := NSA_DecodeByte(InputStream,mask,storbyte,1);
  if (flag and 1) <> 0 then begin
   data := NSA_DecodeByte(InputStream,mask,storbyte,8);
   OutputStream.Write(data,1);
   SlidingWindow[SlideWindowIndex] := data;
   Inc(SlideWindowIndex);
   SlideWindowIndex := SlideWindowIndex and SlideWindowLength;
  end else begin
   w_index := NSA_DecodeByte(InputStream,mask,storbyte,8);
   length := NSA_DecodeByte(InputStream,mask,storbyte,4) + 2;

   if (OutputStream.Position + length) > DecryptLength then length := (DecryptLength - OutputStream.Position);

   for i := 0 to length-1 do begin
    data := SlidingWindow[w_index];
    SlidingWindow[SlideWindowIndex] := data;
    Inc(SlideWindowIndex);
    Inc(w_index);
    SlideWindowIndex := SlideWindowIndex and SlideWindowLength;
    w_index := w_index and SlideWindowLength;
    OutputStream.Write(data,1);
   end;

  end;

 end;

 SetLength(SlidingWindow,0);
 Result := true;
end;

function NSA_SPBDecode;
var w, h, imagesize, forsize, scanline, alignedscanline, tind, j, l : cardinal;
  flag, flag2, mask, storbyte, i, k, data, temp : byte;
  temparr : array of byte;
  tindexes : array[1..3] of cardinal;
  BMPHdr : TBMP;
  c : boolean;
begin

 InputStream.Read(w,2);
 w := EndianSwap(w shl 16);

 InputStream.Read(h,2);
 h := EndianSwap(h shl 16);

 imagesize := w*h;
 forsize := imagesize div 4;
 if (imagesize mod 4) > 1 then Inc(forsize);
 scanline := w*3; // 24-bit
 alignedscanline := (scanline + 3) and $FFFFFFFC;

 SetLength(temparr,(imagesize+4)*4);
 tind := 0;
 storbyte := 0;
 mask := 0;

 for i := 1 to 3 do begin
  tindexes[i] := tind;
  data := NSA_DecodeByte(InputStream,mask,storbyte,8);
  temparr[tind] := data;
  Inc(tind);
  for j := 1 to forsize do begin
   flag := NSA_DecodeByte(InputStream,mask,storbyte,3);
   flag2 := 0;
   c := true;
   case flag of
    0 : begin
         temparr[tind] := data;
         temparr[tind+1] := data;
         temparr[tind+2] := data;
         temparr[tind+3] := data;
         Inc(tind,4);
         c := false;
        end;
    7 : flag2 := NSA_DecodeByte(InputStream,mask,storbyte,1) + 1;
   else flag2 := flag + 2;
   end;

   if c then for k := 1 to 4 do begin
    if flag2 = 8 then data := NSA_DecodeByte(InputStream,mask,storbyte,8) else begin
     temp := NSA_DecodeByte(InputStream,mask,storbyte,flag2);
     if (temp and $1) <> 0 then
      data := data + (temp shr 1) + 1
     else
      data := data - (temp shr 1);
    end;
    temparr[tind] := data;
    Inc(tind);
   end;
  end;
 end;

 with OutputStream do begin

  Position := sizeof(TBMP) + alignedscanline * (h-1);

  for j := 1 to h do begin
   if (j and 1) = 0 then begin
    for l := 1 to w do begin
     Write(temparr[tindexes[1]],1);
     Write(temparr[tindexes[2]],1);
     Write(temparr[tindexes[3]],1);
     Inc(tindexes[1]);
     Inc(tindexes[2]);
     Inc(tindexes[3]);
     Position := Position - 6;
    end;
    Position := Position - (alignedscanline - 3);
   end else begin
    for l := 1 to w do begin
     Write(temparr[tindexes[1]],1);
     Write(temparr[tindexes[2]],1);
     Write(temparr[tindexes[3]],1);
     Inc(tindexes[1]);
     Inc(tindexes[2]);
     Inc(tindexes[3]);
    end;
    Position := Position - (alignedscanline + 3);
   end;
  end;

  Position := 0;
  
  with BMPHdr do begin
   BMPHeader  := 'BM';
   FileSize   := Size;
   Dummy_0    := 0;
   ImgOffset  := sizeof(TBMP);
   HeaderSize := 40;
   Width      := w;
   Height     := h;
   XYZ        := 1;
   Bitdepth   := 24;
   CompType   := 0;
   StreamSize := imagesize*3;
   Hres       := 0;
   Vres       := 0;
   UsedColors := 0;
   NeedColors := 0;
   Write(BMPHdr,sizeof(TBMP));
  end; // with BMPHdr
  
 end; // with OutputStream

 SetLength(temparr,0);
 Result := true;
end;

function EA_NSA;
var TempoStream, TempoStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_X of
     0 : FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
   1,2 : begin 
          TempoStream := TMemoryStream.Create;
          TempoStream2 := TMemoryStream.Create;
          TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
          TempoStream.Position := 0;
          case FileRecord.RFA_X of
           1 : NSA_SPBDecode(TempoStream, TempoStream2);
           2 : NSA_LZSSDecode(TempoStream, TempoStream2, FileRecord.RFA_C, FileRecord.RFA_2, $EF,$FF);
          end; 
          FreeAndNil(TempoStream);
          TempoStream2.Position := 0;
          FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
          FreeAndNil(TempoStream2);
         end;
  end;       
  Result := True;
 except
 end;
end;

function OA_NScriptDAT;
{ nScripter script file opening function }
var ScriptName : widestring;
begin
 Result := False;

 ScriptName := LowerCase(ExtractFileName(ArchiveFileName));

 if (ScriptName = 'nscript.dat') or (ScriptName = 'pscript.dat') then with ArchiveStream do begin
  Seek(0,soBeginning);
  RecordsCount := 1;
  with RFA[1] do begin
   RFA_1 := 0;
   RFA_2 := Size;
   if ScriptName = 'nscript.dat' then RFA_3 := '0.txt' else RFA_3 := '0.utf';
   RFA_C := Size;
   RFA_E := True;
   RFA_X := $84;
  end;

  Result := True;
 end;

end;

end.