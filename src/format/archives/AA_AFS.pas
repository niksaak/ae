{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  PlayStation 2 AFS game archive format & functions
  
  Special thanks to Nik.
  Written by dsp2003.
}

unit AA_AFS;

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
 procedure IA_AFSv1(var ArcFormat : TArcFormats; index : integer);
 procedure IA_AFSv2(var ArcFormat : TArcFormats; index : integer);
 procedure IA_AFSv3(var ArcFormat : TArcFormats; index : integer);

  function OA_AFS : boolean;
  function SA_AFS(Mode : integer) : boolean;

type
{ AFS }
 TAFSHeader = packed record
  Magic     : array[1..4] of char; // AFS+#0
  FileCount : longword;
 end;
 TAFSDir = packed record
  Offset   : longword;
  Filesize : longword;
 end;
 TAFSEntry = packed record
  Filename : array[1..32] of char;
  Filetype : longword;
  Unk_0    : word;
  Unk_1    : word;
  Unk_2    : word;
  Unk_3    : word;
  Dummy    : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_AFSv1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'PlayStation 2 (w/o header)';
  Ext  := '.afs';
  Stat := $0;
  Open := OA_AFS;
  Save := SA_AFS;
  Extr := EA_RAW;
  FLen := 0;
  SArg := 1;
  Ver  := $20110329;
 end;
end;

procedure IA_AFSv2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'PlayStation 2';
  Ext  := '.afs';
  Stat := $0;
  Open := OA_AFS;
  Save := SA_AFS;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 0;
  Ver  := $20110329;
 end;
end;

procedure IA_AFSv3;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'PlayStation 2 (Native)';
  Ext  := '.afs';
  Stat := $0;
  Open := OA_AFS;
  Save := SA_AFS;
  Extr := EA_RAW;
  FLen := 32;
  SArg := 2;
  Ver  := $20110329;
 end;
end;

function OA_AFS;
{ AFS archive opening function }
var i,j : integer;
    Hdr : TAFSHeader;
    Dir : TAFSDir;
    Ent : TAFSEntry;
    DivedSize, DivSTable : integer;
begin
 Result := False;
 with ArchiveStream do begin
  with Hdr do begin
   Seek(0,soBeginning);
   Read(Magic,SizeOf(Magic));
   if Magic <> 'AFS'+#0 then Exit;
   Read(FileCount,SizeOf(FileCount));
   RecordsCount := FileCount+1;
  end;
// Reading file table...

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := RFA[i].RFA_2; // replicates filesize
   end;

  end;

  DivedSize := SizeDiv(RFA[RecordsCount-1].RFA_1+RFA[RecordsCount-1].RFA_2,$800);
  DivSTable := DivedSize + SizeDiv(RecordsCount*SizeOf(Ent),$800);

  if RFA[RecordsCount].RFA_1 > 0 then begin
   Seek(RFA[RecordsCount].RFA_1,soBeginning);
   for i := 1 to RecordsCount-1 do begin
    with Ent do begin
     Read(Ent,SizeOf(Ent));
     for j := 1 to 32 do case FileName[j] of
      #0  : break;
      '/' : RFA[i].RFA_3 := RFA[i].RFA_3 + '\';
      else RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j];
     end;
    end;
   end;
//   RFA[RecordsCount].RFA_3 := 'AFS_Entry_Table_Metafile';
  end else if DivSTable <= ArchiveStream.Size then begin
   Seek(DivedSize,SoBeginning);
   for i := 1 to RecordsCount-1 do begin
    with Ent do begin
     Read(Ent,SizeOf(Ent));
     for j := 1 to 32 do case FileName[j] of
      #0  : break;
      '/' : RFA[i].RFA_3 := RFA[i].RFA_3 + '\';
      else RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j];
     end;
    end;
   end;
//   RFA[RecordsCount].RFA_3 := 'AFS_Entry_Table_Metafile';
  end else begin
   for i := 1 to RecordsCount-1 do RFA[i].RFA_3 := 'File_'+inttostr(i);
   RFA[RecordsCount].RFA_3 := 'EOF_Dummy';
  end;

 end;

 RecordsCount := RecordsCount - 1; //hiding the eof record from GUI ^3^

 Result := True;

end;

function SA_AFS;
{ PlayStation 2 AFS archive creation function }
var i,j,k : longword;
    Hdr : TAFSHeader;
    Dir : TAFSDir;
    Ent : TAFSEntry;
    Dummy : array of byte;
begin

 with ArchiveStream do begin
  with Hdr do begin
 //Generating header (8 bytes)...
   Magic := 'AFS'+#0;
 //Calculating records count...
   RecordsCount := AddedFiles.Count+1; // The EOF entry or AFSEntry table
   ReOffset := SizeDiv(SizeOf(Hdr)+(SizeOf(Dir)*RecordsCount),$800);
   FileCount := RecordsCount-1;
  end;

  Write(Hdr,SizeOf(Hdr));

// Creating file table...
  RFA[1].RFA_1 := ReOffset;
  UpOffset := ReOffset;

  for i := 1 to RecordsCount - 1 do begin
{*}Progress_Pos(i);
   with Dir do begin
    OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

    UpOffset       := UpOffset + SizeDiv(FileDataStream.Size,$800);
    RFA[i+1].RFA_1 := UpOffset; // the RecordsCount+1 value will not be used, so it's not important
    RFA[i].RFA_2   := FileDataStream.Size;
    RFA[i].RFA_3   := AddedFiles.Strings[i-1];
    Offset         := RFA[i].RFA_1;
    FileSize       := RFA[i].RFA_2;
    FreeAndNil(FileDataStream);
 // Writing file table entry...
    ArchiveStream.Write(Dir,SizeOf(Dir));
   end;
  end;

  with Dir do begin
   Offset := 0;
   FileSize := 0;
  // Explaination: "Native" PS2 AFS files have an empty EOF record
   if Mode = 0 then with Dir do begin
    Offset := RFA[RecordsCount].RFA_1;
    FileSize := SizeOf(Ent)*(RecordsCount-1);
   end;
  end;

  Write(Dir,SizeOf(Dir));

  // дописываем выравнивание
  SetLength(Dummy,SizeMod(SizeOf(Hdr)+(SizeOf(Dir)*RecordsCount),$800));
  Write(Dummy[0],Length(Dummy));

  for i := 1 to RecordsCount-1 do begin
{*}Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   CopyFrom(FileDataStream,FileDataStream.Size);

   // дописываем выравнивание
   SetLength(Dummy,SizeMod(FileDataStream.Size,$800));
   Write(Dummy[0],Length(Dummy));

   FreeAndNil(FileDataStream);
  end;

  case Mode of
  0,2: begin
        k := 0;
        for i := 1 to RecordsCount - 1 do begin
      {*}Progress_Pos(i);
         with Ent do begin
          //FillChar(Filename,SizeOf(Filename),0);
          FillChar(Ent,SizeOf(Ent),0);

          for j := 1 to 32 do if j <= length(RFA[i].RFA_3) then case RFA[i].RFA_3[j] of
           '\' : FileName[j] := '/';
           else FileName[j] := RFA[i].RFA_3[j];
          end else break;

          //Filetype := 0;
          //Unk_0 := 0;
          //Unk_1 := 0;
          //Unk_2 := 0;
          //Unk_3 := 0;
          // Грибочки, грибочки, грибочки!!! *CRAZY*
          case k of
           0 : begin Dummy := RFA[i div 2+1].RFA_1; inc(k); end;
           1 : begin Dummy := RFA[i div 2+2].RFA_2; dec(k); end;
           else Dummy := 0;
          end;
         end;
         Write(Ent,SizeOf(Ent));
        end; // for
        // дописываем выравнивание
        SetLength(Dummy,SizeMod(SizeOf(Ent)*(RecordsCount-1),$800));
        Write(Dummy[0],Length(Dummy));
       end;
  1  : { Mode 1 writes no Entry Header } ;
  end; // case
 end; // with ArchiveStream

 Result := True;

end;

end.