{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Natsuiro Sagittarius ~Hamaihara Gakuen Kyuudoubu~ FJSYS archive format & functions
  
  Written by dsp2003.
}

unit AA_FJSYS;

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
 procedure IA_FJSYS(var ArcFormat : TArcFormats; index : integer);

  function OA_FJSYS : boolean;
  function SA_FJSYS(Mode : integer) : boolean;

type
{ FJSYS archive format }
 TFJSYSHeader = packed record
  Header       : array[1..8] of char;  // FJSYS+#0#0#0
  HeaderSize   : longword;              // TFJSYSHeader+(TFJSYSTable*TotalRecords)+(TFJSYSDir[variable])*TotalRecords)
  DirSize      : longword;              // TFJSYSDir size
  TotalRecords : longword;              // Number of file records
  Dummy        : array[1..64] of byte; // Zeroes
 end;

 TFJSYSTable = packed record
  FileNameOffset : longword;            // Filename offset in TFJSYSDir
  FileSize       : longword;            // File size
  Offset         : int64;              // File offset in archive
 end;

 TFJSYSDir = record
  FileName : array[1..256] of char;    // File name (size varies)
 end;

implementation

uses AnimED_Archives;

procedure IA_FJSYS;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'FJSYS';
  Ext  := '';
  Stat := $0;
  Open := OA_FJSYS;
  Save := SA_FJSYS;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_FJSYS;
{ FJSYS archive opening function }
var i,j : integer;
    FJSYSHeader  : TFJSYSHeader;
    FJSYSTable   : TFJSYSTable;
    FJSYSDir     : TFJSYSDir;
begin
 Result := False;
 with ArchiveStream do begin
  with FJSYSHeader do begin
   Seek(0,soBeginning);
   Read(FJSYSHeader,SizeOf(FJSYSHeader));

   if Header <> 'FJSYS'+#0#0#0 then Exit;

   RecordsCount := TotalRecords;
  end;
// Reading file table...
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with FJSYSTable do begin
    Read(FJSYSTable,SizeOf(FJSYSTable));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
   end;
  end;
  
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with FJSYSDir do begin
    FillChar(FileName,SizeOf(FileName),0);  //cleaning the array in order to avoid garbage
    for j := 1 to 256 do begin
     Read(FileName[j],1); {Header size is not fixed... damn!}
     if FileName[j] = #0 then break;
    end;
//    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_3 := String(PChar(@FileName));
   end;
  end;
 end;
 Result := True;

end;

function SA_FJSYS;
{ FJSYS archive creation function }
var i, j : integer;
    FJSYSHeader  : TFJSYSHeader;
    FJSYSTable   : TFJSYSTable;
    FJSYSDir     : TFJSYSDir;
    TextReOffset,
    NameReOffset : integer;  
begin

 with FJSYSHeader do begin
//Generating header...
  Header := 'FJSYS'+#0#0#0;
//Calculating records count...
  RecordsCount := AddedFiles.Count;
  ReOffset     := SizeOf(FJSYSHeader)+SizeOf(FJSYSTable)*RecordsCount;
  TotalRecords := RecordsCount;
  TextReOffset := ReOffset;
  for i := 1 to RecordsCount do ReOffset := ReOffset+length(ExtractFileName(AddedFiles.Strings[i-1]))+1; //+1 means zero byte
  inc(ReOffset); // additional zero byte
  HeaderSize   := ReOffset;
  DirSize      := ReOffset - TextReOffset;
  FillChar(Dummy,SizeOf(Dummy),0); 
 end;

 ArchiveStream.Write(FJSYSHeader,SizeOf(FJSYSHeader));

// Creating file table...
 RFA[1].RFA_1 := ReOffset;
 UpOffset := ReOffset;
 NameReOffset := 0;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with FJSYSTable do begin

//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
   RFA[i].RFA_2   := FileDataStream.Size;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]);

   FileNameOffset := NameReOffset;
   inc(NameReOffset,Length(RFA[i].RFA_3)+1);
   FileSize       := RFA[i].RFA_2;
   Offset         := RFA[i].RFA_1;
   
   FreeAndNil(FileDataStream);
// Writing file table entry...
   ArchiveStream.Write(FJSYSTable,SizeOf(FJSYSTable));
  end;
 end;

 for i := 1 to RecordsCount do begin
  with FJSYSDir, ArchiveStream do begin
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to length(RFA[i].RFA_3) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   Write(Filename,length(RFA[i].RFA_3)+1); //+1 because of zero value
  end; 
 end;
 
 i := 0;
 ArchiveStream.Write(i,1); // zero byte

 for i := 1 to RecordsCount do
  begin
{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
  end;

 Result := True;

end;

end.