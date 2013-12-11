{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  PACKDAT archive format & functions

  Written by dsp2003 & Nik. Special thanks to w8m
}

unit AA_DAT_PACKDAT;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_DAT_PACKDAT(var ArcFormat : TArcFormats; index : integer);
 procedure IA_DAT_PACKDATe(var ArcFormat : TArcFormats; index : integer);
 function OA_DAT_PACKDAT : boolean;
 function SA_DAT_PACKDAT(Mode : integer) : boolean;
 
 function EA_DAT_PACKDAT(FileRecord : TRFA) : boolean;
 
 procedure DatDecrypt(inStream : TStream; Size, CryptFlags : longint);
 procedure DatEncrypt(inStream : TStream; Size, CryptFlags : longint);

type
{ PACKDAT archive structural description }
 TPACKDATHeader = packed record
  Header        : array[1..8] of char; // 'PACKDAT.'
  TotalRecords  : longword;
  TotalRecords2 : longword; // copy of TotalRecords
 end;
 TPACKDATDir = packed record
  Filename     : array[1..32] of char;
  Offset       : longword;
  Flags        : longword;
  FileSize     : longword;
  FileSize2    : longword; // copy of FileSize
 end;

implementation

uses AnimED_Archives;

procedure IA_DAT_PACKDAT;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'PACKDAT';
  Ext  := '.dat';
  Stat := $0;
  Open := OA_DAT_PACKDAT;
  Save := SA_DAT_PACKDAT;
  Extr := EA_DAT_PACKDAT;
  FLen := 32;
  SArg := 0;
  Ver  := $20100812;
 end;
end;

procedure IA_DAT_PACKDATe;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'PACKDAT +Encryption';
  Ext  := '.dat';
  Stat := $5;
  Open := OA_Dummy;
  Save := SA_DAT_PACKDAT;
  Extr := EA_Dummy;
  FLen := 32;
  SArg := 1;
  Ver  := $20100812;
 end;
end;

function OA_DAT_PACKDAT;
{ PACKDAT. archive opening function }
var i,j : integer;
    PACKDATHeader : TPACKDATHeader;
    PACKDATDir    : TPACKDATDir;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  with PACKDATHeader do begin
   Read(PACKDATHeader,SizeOf(PACKDATHeader));

   if Header <> 'PACKDAT.' then Exit;

   RecordsCount := TotalRecords;
  end;
{*}Progress_Max(RecordsCount);
// Reading PACKDAT filetable...

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with PACKDATDir do begin
    Read(PACKDATDir,SizeOf(PACKDATDir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize2; // replicates filesize
    SetLength(RFA[i].RFA_T,1);
    SetLength(RFA[i].RFA_T[0],1);
    RFA[i].RFA_T[0][0] := inttostr(Flags);
  { Excluding archive garbage in filename ^_^ }
    for j := 1 to 32 do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
//  if RFA[i].RFA_3 = '' then RFA[i].RFA_3 := 'Unknown_Metafile.bin';
   end;
  end;
 end;
// RecordsCount := RecordsCount - 1; //hiding the eof record from GUI ^3^
 Result := True;

end;

function SA_DAT_PACKDAT;
 { PACKDAT. archive creation function }
var i, j : integer;
    PACKDATHeader : TPACKDATHeader;
    PACKDATDir    : TPACKDATDir;
    tmpStream     : TStream;
    CryptFlags    : longint;
begin

 case Mode of
  0 : CryptFlags := $20000000;
  1 : CryptFlags := $30010000;
 else CryptFlags := $00000000;
 end;

 RecordsCount := AddedFiles.Count;

 with PACKDATHeader do begin
  // Generating header (24 bytes)...
  Header          := 'PACKDAT.';
  TotalRecords    := RecordsCount;
  TotalRecords2   := RecordsCount;
// Creating file table...
  UpOffset        := SizeOf(PACKDATHeader)+SizeOf(PACKDATDir)*RecordsCount;
  RFA[1].RFA_1    := UpOffset;
 end;

// ...and writing file...
 ArchiveStream.Write(PACKDATHeader,SizeOf(PACKDATHeader));

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with PACKDATDir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_2   := FileDataStream.Size;
   Offset         := RFA[i].RFA_1;
   Flags          := CryptFlags; //$20000000;
   FileSize       := RFA[i].RFA_2;
   FileSize2      := RFA[i].RFA_2; // Replicates filesize
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]); //PACKDAT do not support pathes

   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to 32 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;

   FreeAndNil(FileDataStream);

// Writing header...
   ArchiveStream.Write(PACKDATDir,SizeOf(PACKDATDir));
  end;
 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  case (CryptFlags and $FFFFFF) of
   0 : ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  else begin
        tmpStream := TMemoryStream.Create;
        tmpStream.CopyFrom(FileDataStream,FileDataStream.Size);
        tmpStream.Position := 0;

        DatEncrypt(tmpStream,tmpStream.Size,CryptFlags); // crypt by flag
       
        tmpStream.Position := 0;
        ArchiveStream.CopyFrom(tmpStream,tmpStream.Size);
        FreeAndNil(tmpStream);
       end;
  end;

  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function EA_DAT_PACKDAT;
var tmpStream : TStream;
   CryptFlags : longword;
begin
 Result := False;
 ArchiveStream.Position := FileRecord.RFA_1;
 CryptFlags := strtoint(FileRecord.RFA_T[0][0]); 
 
 case (CryptFlags and $FFFFFF) of
  0 : FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
 else begin
       tmpStream := TMemoryStream.Create;
       tmpStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
       tmpStream.Position := 0;
       
       DatDecrypt(tmpStream,tmpStream.Size,CryptFlags); // decrypt by flag
       
       tmpStream.Position := 0;
       FileDataStream.CopyFrom(tmpStream,tmpStream.Size);
       FreeAndNil(tmpStream);
      end;
 end;
 
 Result := True;
 
end;

procedure DatDecrypt;
var SizeD: Longint;
    data, CryptKey : longword;
begin
 if (CryptFlags and $FFFFFF) <> 0 then begin
  if (CryptFlags and $010000) <> 0 then begin
   Size := inStream.Size;
   SizeD := Size shr 2;
   CryptKey := SizeD xor (SizeD shl ((SizeD and 7) + 8));

   if SizeD > 0 then begin
    while SizeD <> 0 do begin
     inStream.Read(data,4);
     data := data xor CryptKey;
     inStream.Position := inStream.Position - 4;
     inStream.Write(data,4);
     CryptKey := (CryptKey shr (32 - (data mod 24))) or (CryptKey shl (data mod 24));
     Dec(SizeD);
    end;
   end;

  end;
 end;
end;

procedure DatEncrypt;
var SizeD: Longint;
    data, tdata, CryptKey : longword;
begin
 if (CryptFlags and $FFFFFF) <> 0 then begin
  if (CryptFlags and $010000) <> 0 then begin
   Size := inStream.Size;
   SizeD := Size shr 2;
   CryptKey := SizeD xor (SizeD shl ((SizeD and 7) + 8));
   
   if SizeD > 0 then begin
    while SizeD <> 0 do begin
     inStream.Read(tdata,4);
     data := tdata xor CryptKey;
     inStream.Position := inStream.Position - 4;
     inStream.Write(data,4);
     CryptKey := (CryptKey shr (32 - (tdata mod 24))) or (CryptKey shl (tdata mod 24));
     Dec(SizeD);
    end;
   end;
      
  end;
 end;
end;

end.