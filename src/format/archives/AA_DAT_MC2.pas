{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  RockStar Midnight Club 2 & 3 game archive formats & functions
  
  Written by dsp2003.
}

unit AA_DAT_MC2;

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
 procedure IA_DAT_MC2v1(var ArcFormat : TArcFormats; index : integer);
 procedure IA_DAT_MC2v2(var ArcFormat : TArcFormats; index : integer);

  function OA_DAT_MC2v1 : boolean;
//  function SA_DAT_MC2v1(Mode : integer) : boolean;
  function OA_DAT_MC2v2 : boolean;
//  function SA_DAT_MC2v2(Mode : integer) : boolean;


type
 { Midnight Club 2 archives. Everything is aligned by 2048 bytes (PlayStation 2 behavior?) }
 TDATHeader = packed record
  Magic         : array[1..4] of char; // 'DAVE' - archive with normal filenames
                                        //'Dave' - with encrypted filenames
  TotalRecords  : longword;             // Number of files
  FileTableSize : longword;             // File table size
  NameTableSize : longword;             // Names table size
 end;
 
 TDATDir = packed record
  FNOffset      : longword;             // Relative filename offset in Filename Table
  Offset        : longword;             // Real offset position in archive
  FileSize      : longword;             // Size of file
  FileSize2     : longword;             // copy of filesize?
 end;

 //TDATFNDir : array of string;

implementation

uses AnimED_Archives;

procedure IA_DAT_MC2v1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'RockStar Midnight Club 2';
  Ext  := '.dat';
  Stat := $F;
  Open := OA_DAT_MC2v1;
//  Save := SA_DAT_MC2v1;
  Extr := EA_RAW;
  FLen := 0;
  SArg := 0;
  Ver  := $20100409;
 end;
end;

procedure IA_DAT_MC2v2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'RockStar Midnight Club 2 Encrypted Names';
  Ext  := '.dat';
  Stat := $F;
  Open := OA_DAT_MC2v2;
//  Save := SA_DAT_MC2v2;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := $20100409;
 end;
end;

function OA_DAT_MC2v1;
var i,j : integer;
    Hdr : TDATHeader;
    Dir : TDATDir;
    FNTable : TStream;
    b : char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'DAVE' then Exit;
   RecordsCount := TotalRecords;
  end;

  Seek(2048,soBeginning); // moving to filetable

  //Skipping the file table for now...
  Seek(Hdr.FileTableSize,soCurrent);

// Reading filename table...
  FNTable := TMemoryStream.Create;
  FNTable.CopyFrom(ArchiveStream,Hdr.NameTableSize);
  FNTable.Seek(0,soBeginning);

  //Rolling back
  Seek(2048,soBeginning);

// Reading file table...
  for i := 1 to RecordsCount do begin
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
    FNTable.Seek(FNOffset,soBeginning);

    for j := $1 to $FF do begin
     FNTable.Read(b,1);
     case b of
      #0 : break;
     '/' : b := '\'; //replacing the slash with correct one
     end;
     RFA[i].RFA_3 := RFA[i].RFA_3 + b;
    end;

   end;
  end;

  FreeAndNil(FNTable);

  Result := True;
 end;

end;

function OA_DAT_MC2v2;
var i{,j} : integer;
    Hdr : TDATHeader;
    Dir : TDATDir;
//    FNTable : TStream;
//    b : char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'Dave' then Exit;
   RecordsCount := TotalRecords;
  end;

  Seek(2048,soBeginning); // moving to filetable

//  //Skipping the file table for now...
//  Seek(Hdr.FileTableSize,soCurrent);

// Reading filename table...
//  FNTable := TMemoryStream.Create;
//  FNTable.CopyFrom(ArchiveStream,Hdr.NameTableSize);
//  FNTable.Seek(0,soBeginning);

//  //Rolling back
//  Seek(2048,soBeginning);

// Reading file table...
  for i := 1 to RecordsCount do begin
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize;
//    FNTable.Seek(FNOffset,soBeginning);

//    for j := $1 to $FF do begin
//     FNTable.Read(b,1);
//     case b of
//      #0 : break;
//     '/' : b := '\'; //replacing the slash with correct one
//     end;
//     RFA[i].RFA_3 := RFA[i].RFA_3 + b;
//    end;
    RFA[i].RFA_3 := 'File_'+inttostr(i)+'.bin';

   end;
  end;

//  FreeAndNil(FNTable);

  Result := True;
 end;

end;

end.