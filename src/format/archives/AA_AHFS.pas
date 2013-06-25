{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  BloodOver AHFS game archive format & functions

  Written by dsp2003.
  Specifications from Vendor / Honyaku-Subs.
}

unit AA_AHFS;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Classes, Windows, Forms, Sysutils;

 { Supported archives implementation }
 procedure IA_AHFS(var ArcFormat : TArcFormats; index : integer);

  function OA_AHFS : boolean;
  function SA_AHFS(Mode : integer) : boolean;

type
 TAHFSHeader = packed record
  Header       : array[1..4] of char; // AHFS
  TotalRecords : longword;             // file count
  ReOffset     : longword;             // block data beginning
 end;

{ TAHFSDirFn = packed record
  FileName : array[1..256] of char;    // for files > 1 add '|'($7C) at the beginning, and '/' (2F) at the end
 end;}
 
 TAHFSDir = packed record
  FileSize     : longword;             // file size
  Offset       : longword;             // relative file offset (offset := offset + ReOffset)
 end;

 // write "?" (3F) at the end of filetable

implementation

uses AnimED_Archives;

procedure IA_AHFS;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'BloodOver AHFS';
  Ext  := '';
  Stat := $0;
  Open := OA_AHFS;
  Save := SA_AHFS;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090910;
 end;
end;

function OA_AHFS;
var i : integer; c : char;
    Hdr : TAHFSHeader;
    Dir : TAHFSDir;
    tblStream  : TStream;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
 end;
  
 with Hdr do begin
  if Header <> 'AHFS' then Exit;
  RecordsCount := TotalRecords;

// Reading file table...
  tblStream := TMemoryStream.Create;

  with tblStream do begin
   CopyFrom(ArchiveStream,ReOffset-SizeOf(Hdr));
   Position := 0;

{*}Progress_Max(RecordsCount);

   for i := 1 to RecordsCount do begin

 {*}Progress_Pos(i);

    c := #0; // resetting 'c'
    while c <> '/' do begin
     Read(c,1);
     case c of
     '/','|' : ; // skipping the symbols ^_^
     else RFA[i].RFA_3 := RFA[i].RFA_3 + c;
     end;
    end;
    Read(Dir,SizeOf(Dir));
    with Dir do begin
     RFA[i].RFA_1 := Offset   + ReOffset;
     RFA[i].RFA_2 := FileSize;
     RFA[i].RFA_C := FileSize;
    end;
   end;

   Read(c,1);
   FreeAndNil(tblStream);
   
   if c <> #$3F then Exit;

  end;
 end;

 Result := True;

end;

function SA_AHFS;
var i,j : integer; c : char;
    Hdr : TAHFSHeader;
    Dir : TAHFSDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  UpOffset := 0; j := 0;

  for i := 1 to RecordsCount do begin
  
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   
   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := FileDataStream.Size;
   RFA[i].RFA_C := RFA[i].RFA_2;
   UpOffset     := UpOffset + RFA[i].RFA_2;
   
   FreeAndNil(FileDataStream);
   
   case i of
     1 : RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1])+'/';
    else RFA[i].RFA_3 := '|'+ExtractFileName(AddedFiles.Strings[i-1])+'/';
   end;

   j := j + Length(RFA[i].RFA_3);
  
  end;

  with Hdr do begin
   Header       := 'AHFS';
   TotalRecords := RecordsCount;
   ReOffset     := SizeOf(Hdr) + j + SizeOf(Dir)*RecordsCount + 1; // +1 is for '?' byte
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);
  
   with Dir do begin
    Offset   := RFA[i].RFA_1;
    FileSize := RFA[i].RFA_2;
   end;

   Write(RFA[i].RFA_3[1],Length(RFA[i].RFA_3));

   // пишем кусок таблицы
   Write(Dir,SizeOf(Dir));
   
  end;
  
  c := #$3F;
  
  Write(c,1);

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;

end.