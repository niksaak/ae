{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  KID Engine LNK game archive format & functions
  
  Written by dsp2003.

  var sum : byte;
  
  // calculating sum value for decoding
  for i := 1 to Length(Filename) do begin
   sum := sum + Filename[i];
  end;

  // decoding the file
  for(...) do begin
   data[i] := data[i] - sum;
   sum := sum * 0x6D - 0x25;
  end;
}

unit AA_DAT_LNK;

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
 procedure IA_DAT(var ArcFormat : TArcFormats; index : integer);

  function OA_DAT : boolean;
  function SA_DAT(Mode : integer) : boolean;

type
{ DAT (LNK) structural description }
 TDATHdr = packed record
  Magic     : array[1..4] of char;     // Просто заголовок. Всегда равен 'LNK'#0.
  FileCount : longword;                // Числа типа LONGWORD записываются в файл задом наперёд.
  Dummy     : int64;                   // Пустышка.
 end;
 TDATDir = packed record
  Offset    : longword;             // Число типа LONGWORD. Чтобы получить настоящую позицию в файле, offset = offset+16+32*(TotalRecords).
  FileSize2 : longword;             // Число типа LONGWORD, умножено на 2. Чтобы получить настоящий размер, делим на 2.
  FileName  : array[1..24] of char; // Имя файла. Не более 24 символов. Если короче 24, оставшееся место заполняется #00.
 end;

implementation

uses AnimED_Archives;

procedure IA_DAT;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KID Engine LiNK';
  Ext  := '.dat';
  Stat := $0;
  Open := OA_DAT;
  Save := SA_DAT;
  Extr := EA_RAW;
  FLen := 24;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_DAT;
{ Ever17 DAT archive opening function }
var i,j : integer;
    Hdr : TDATHdr;
    Dir : TDATDir;
begin
 Result := False;
 with ArchiveStream do begin

  Seek(0,soBeginning);

  with Hdr do begin
   Read(Hdr,SizeOf(Hdr));
   if Magic <> 'LNK'#0 then Exit;
   RecordsCount := FileCount;
   ReOffset := SizeOf(Hdr) + SizeOf(Dir)*RecordsCount;
  end;

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   with Dir,RFA[i] do begin
    Read(Dir,SizeOf(Dir));

    RFA_1 := Offset+ReOffset;
    RFA_2 := FileSize2 div 2;
    RFA_C := RFA_2; // replicates filesize
    for j := 1 to 24 do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
   end;

  end;

 end;

 Result := True;

end;

function SA_DAT;
 { Ever17 DAT archive creating function }
var i, j : integer;
    Hdr : TDATHdr;
    Dir : TDATDir;
begin
 with Hdr do begin
// Generating header (16 bytes)...
  Magic := 'LNK'#0;
  RecordsCount := AddedFiles.Count;
  ReOffset := 16+32*RecordsCount;
  FileCount := RecordsCount;
  Dummy := 0;
// Creating file table...
  RFA[1].RFA_1 := 0;
  UpOffset := 0;
 end;

// ...and writing file...
 ArchiveStream.Write(Hdr,SizeOf(Hdr));

 for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

  with Dir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_2   := FileDataStream.Size;
   Offset         := RFA[i].RFA_1;
   FileSize2      := RFA[i].RFA_2*2;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]);
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to 24 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   FreeAndNil(FileDataStream);
// Writing header...
   ArchiveStream.Write(Dir,SizeOf(Dir));
  end;

 end;

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

end.