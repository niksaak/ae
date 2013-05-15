{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Tech Engine (Farland Symphony) archive formats & functions
  
  Written by dsp2003.
}

unit AA_PAC_Tech;

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
 procedure IA_PAC_Tech(var ArcFormat : TArcFormats; index : integer);

  function OA_PAC_Tech : boolean;
  function SA_PAC_Tech(Mode : integer) : boolean;
  function EA_PAC_Tech(FileRecord : TRFA) : boolean;

type
 TPACHeader = packed record
  Header    : array[1..8] of char; // 'PAC_FILE'
  Dummy     : byte;                // #0
  FileCount : longword;            // file count
 end;
 
 TPACDir = packed record
  Filename  : array[1..16] of char; // file name
  Offset    : longword;             // file offset (real offset = offset + 4)
 end;

 TIEL1Header = packed record
  Magic     : array[1..4] of char; // 'IEL1'
  OrigSize  : longword;            // uncompressed size. Compressed size = FileSize - Size(IEL1Header)
 end;

implementation

uses AnimED_Archives;

procedure IA_PAC_Tech;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Tech Engine (Farland Symphony)';
  Ext  := '.pac';
  Stat := $0;
  Open := OA_PAC_Tech;
  Save := SA_PAC_Tech;
  Extr := EA_PAC_Tech;
  FLen := 16;
  SArg := 0;
  Ver  := $20100507;
 end;
end;

function OA_PAC_Tech;
var i,j : integer;
    Hdr : TPACHeader;
    Dir : TPACDir;
    CLZ : TIEL1Header;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Header <> 'PAC_FILE' then Exit;
   if Dummy <> 0 then Exit;
   RecordsCount := FileCount;
  end;
{*}Progress_Max(RecordsCount);

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
{*}Progress_Pos(i);
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset + 4;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

  // calculating file sizes
  for i := 1 to RecordsCount-1 do begin
   if RFA[i+1].RFA_1 <> 0 then RFA[i].RFA_C := RFA[i+1].RFA_1-RFA[i].RFA_1
   else RFA[i].RFA_C := 0;
   RFA[i].RFA_2 := RFA[i].RFA_C; // replicates filesize
  end;

  RFA[RecordsCount].RFA_C := ArchiveStream.Size - RFA[RecordsCount].RFA_1;
  RFA[RecordsCount].RFA_2 := RFA[RecordsCount].RFA_C;

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

function SA_PAC_Tech;
var i,j : integer;
    Hdr : TPACHeader;
    Dir : TPACDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Header       := 'PAK_FILE';
   Dummy        := 0;
   FileCount    := RecordsCount;
   UpOffset     := SizeOf(Hdr)+(SizeOf(Dir)*RecordsCount)-4;
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   
   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   
   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_2;
  
   with Dir do begin
    Offset   := RFA[i].RFA_1;
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

function EA_PAC_Tech;
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