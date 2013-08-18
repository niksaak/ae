{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Unreal Engine 3 INI collection archive format & functions
  
  Written by dsp2003.
}

unit AA_INI_UnrealEngine3;

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
 procedure IA_INI_UnrealEngine3(var ArcFormat : TArcFormats; index : integer);

  function OA_INI_UnrealEngine3 : boolean;
  function SA_INI_UnrealEngine3(Mode : integer) : boolean;

implementation

uses AnimED_Archives;

procedure IA_INI_UnrealEngine3;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Unreal Engine 3 INI collection';
  Ext  := '.ini';
  Stat := $3;
  Open := OA_INI_UnrealEngine3;
  Save := SA_INI_UnrealEngine3;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20100725;
 end;
end;

function OA_INI_UnrealEngine3;
var Version   : longword;
    EntrySize : longword;
    FileSize  : longword;
    FileName  : string;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Version,SizeOf(Version));
  if Version <> 30 then Exit;

  RecordsCount := 0;

  while Position < Size do begin
   inc(RecordsCount);                                 // increasing file count
   Read(EntrySize,SizeOf(EntrySize));                 // reading size of filename
   if EntrySize+Position > Size then Exit;            // if size exceeds archive, exiting
   SetLength(FileName,EntrySize-1);                   // setting length of filename string
   Read(FileName[1],EntrySize-1);                     // reading filename
   Seek(1,soCurrent);                                 // skipping zero byte
   Read(FileSize,SizeOf(FileSize));                   // reading size of file
   if FileSize+Position > Size then Exit;             // if size exceeds archive, exiting
   with RFA[RecordsCount] do begin
    RFA_1 := Position;                                // setting the current offset for RFA
    RFA_2 := FileSize-1;                              // setting the filesize for RFA, excluding zero byte
    RFA_C := FileSize-1;                              // setting the filesize for RFA, excluding zero byte
    SetLength(RFA_3,EntrySize-4);                     // setting length of filename without '..\' part
    CopyMemory(@RFA_3[1], @FileName[4], EntrySize-4); // setting the filename for RFA
   end;
   Seek(FileSize,soCurrent);                          // skipping the current file contents
  end;

  Result := True;
 end;

end;

function SA_INI_UnrealEngine3;
var Version   : longword;
    EntrySize : longword;
    FileSize  : longword;
    FileName  : string;
    Dummy     : byte;
    i         : integer;
begin
 Result := False;

 Version := 30; // version number
 Dummy := 0;    // dummy byte

 with ArchiveStream do begin
  Write(Version,SizeOf(Version)); // writing version
  RecordsCount := AddedFiles.Count; // setting number of files

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   FileName := '..\'+AddedFiles.Strings[i-1]; // putting filename together
   FileSize := FileDataStream.Size+1; // giving size of file + 1 zero byte

   EntrySize := Length(FileName)+1; // setting length of filename field + 1 zero byte

   Write(EntrySize,4);             // writing size of entry
   Write(FileName[1],EntrySize-1); // writing filename
   Write(Dummy,1);                 // writing leading zero byte
   Write(FileSize,4);              // writing size of file

   CopyFrom(FileDataStream,FileDataStream.Size); // writing the file itself
   
   Write(Dummy,1);                 // writing leading zero byte

   FreeAndNil(FileDataStream);     // releasing file

  end;

 end; // with ArchiveStream

 Result := True;

end;

end.