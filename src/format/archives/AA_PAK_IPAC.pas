{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Heat-Soft IPAC archive format & functions

  Special thanks to Marisa-Chan.
  Written by dsp2003.
}

unit AA_PAK_IPAC;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Progress,
     AnimED_Directories,
     Generic_LZXX,
     Classes, Windows, Forms, Sysutils;

 { Supported archives implementation }
 procedure IA_PAK_IPAC(var ArcFormat : TArcFormats; index : integer);

  function OA_PAK_IPAC : boolean;
  function SA_PAK_IPAC(Mode : integer) : boolean;
  function EA_PAK_IPAC(FileRecord : TRFA) : boolean;

type
 TIPACHeader = packed record
  Magic     : array[1..4] of char; // 'IPAC'
  FileCount : word;                 // File count
  Check     : word;                 // $77CF
 end;
 
 TIPACDir = packed record
  Filename  : array[1..36] of char; // File name
  Offset    : longword;
  FileSize  : longword;
 end;

 TIEL1Header = packed record
  Magic     : array[1..4] of char; // 'IEL1'
  OrigSize  : longword;            // uncompressed size. Compressed size = FileSize - Size(IEL1Header)
 end;

implementation

uses AnimED_Archives;

procedure IA_PAK_IPAC;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Heat-Soft IPAC';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_IPAC;
  Save := SA_PAK_IPAC;
  Extr := EA_PAK_IPAC;
  FLen := 36;
  SArg := 0;
  Ver  := $20091014;
 end;
end;

function OA_PAK_IPAC;
var i,j : integer;
    Hdr : TIPACHeader;
    Dir : TIPACDir;
    CLZ : TIEL1Header;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'IPAC' then Exit;
   if Check <> $77CF then Exit;
   RecordsCount := FileCount;
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;
  
// Parsing compressed data...
  for i := 1 to RecordsCount do begin
   Seek(RFA[i].RFA_1,soBeginning);
   Read(CLZ,SizeOf(CLZ));
   if CLZ.Magic = 'IEL1' then begin
    RFA[i].RFA_2 := CLZ.OrigSize;
    RFA[i].RFA_Z := True;
    RFA[i].RFA_X := acLZSS;
   end;
  end;

  Result := True;
 end;

end;

function SA_PAK_IPAC;
var i,j : integer;
    Hdr : TIPACHeader;
    Dir : TIPACDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'IPAC';
   FileCount := RecordsCount;
   Check     := $77CF;
   UpOffset  := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]); // формат не поддерживает путей

   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   
   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_2;
  
   with Dir do begin
    Offset   := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   end;

   // пишем кусок таблицы
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
  end;
  
  for i := 1 to RecordsCount do begin
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;

function EA_PAK_IPAC;
var tmpStream, tmpStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_Z of
   True  : begin
            ArchiveStream.Position := ArchiveStream.Position + 8; // skipping the header
            tmpStream := TMemoryStream.Create;
            tmpStream2 := TMemoryStream.Create;
            tmpStream.Size := FileRecord.RFA_C-8; // speeding up the process
            tmpStream.CopyFrom(ArchiveStream,FileRecord.RFA_C-8);
            tmpStream.Position := 0;
            GLZSSDecode(tmpStream, tmpStream2, tmpStream.Size, $FEE,$FFF,$20);
            FreeAndNil(tmpStream);
            tmpStream2.Position := 0;
            FileDataStream.CopyFrom(tmpStream2,tmpStream2.Size);
            FreeAndNil(tmpStream2);            
           end; 
   False : FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  end;
  Result := True;
 except
 end;
end;

end.