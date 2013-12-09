{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  CycSoft NNN archive formats & functions
  
  Written by dsp2003.
}

unit AA_CycSoft_NNN;

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
 procedure IA_CycSoft_GPK(var ArcFormat : TArcFormats; index : integer);

  function OA_CycSoft_GPK : boolean;
//  function SA_CycSoft_GPK(Mode : integer) : boolean;

 procedure IA_CycSoft_VPK(var ArcFormat : TArcFormats; index : integer);

  function OA_CycSoft_VPK : boolean;
//  function SA_CycSoft_VPK(Mode : integer) : boolean;

type
{ TNNNBody = packed record
  Magic  : array[1..16] of char; // 'PNG             '
                                  // 'IF PACKTYPE==2  '
                                  // 'IF PACKTYPE==0  ' // 0 has no table file
  Magic2 : array[1..16] of char; // all #0
                                  // 'CUT THIS 108BYTE'
                                  // 'CUT THIS 64 BYTE'
  Magic3 : 
 end;
}

{ TGTBHeader = packed record
  FileCount : longword;
 end;
 TGTBFNDir = packed record
  FNOffset : longword;
 end;
 TGTBDir = packed record
  Offset : longword;
 end;
 TGTBFNDir : string;
 }

 TVTBDir = packed record
  Filename : array[1..8] of char; // no extension
  Offset   : longword;
 end;

const cycsoft_id = 'CycSoft NNN';
      cycsoft_ver = $20100419;

implementation

uses AnimED_Archives;

procedure IA_CycSoft_GPK;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := cycsoft_id+' GPK+GTB';
  Ext  := '.gpk';
  Stat := $F;
  Open := OA_CycSoft_GPK;
//  Save := SA_CycSoft_GPK;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
  Ver  := cycsoft_ver;
 end;
end;

procedure IA_CycSoft_VPK;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := cycsoft_id+' VPK+VTB';
  Ext  := '.vpk';
  Stat := $F;
  Open := OA_CycSoft_VPK;
//  Save := SA_CycSoft_VPK;
  Extr := EA_RAW;
  FLen := $8;
  SArg := 0;
  Ver  := cycsoft_ver;
 end;
end;

function OA_CycSoft_GPK;
var i,j,k : integer; b : char;
    DIRStream, TempoStream, FNTable : TStream;
begin
 Result := False;
 if FileExists(ChangeFileExt(ArchiveFileName,'.gtb')) and (LowerCase(ExtractFileExt(ArchiveFileName)) = '.gpk') then
 if ArchiveFileName <> ChangeFileExt(ArchiveFileName,'.gtb') then begin
  DIRStream := TFileStreamJ.Create(ChangeFileExt(ArchiveFileName,'.gtb'),fmOpenRead);
  TempoStream := TMemoryStream.Create;
  TempoStream.CopyFrom(DIRStream,DIRStream.Size);
  FreeAndNil(DIRStream);
  TempoStream.Position := 0;

  with TempoStream do begin
   Seek(0,soBeginning);

   Read(i,4); // reading table header
   RecordsCount := i;

   Seek(RecordsCount*4,soCurrent); // skipping filename offsets array

   for i := 1 to RecordsCount do begin // reading file offsets
    Read(j,4);
    RFA[i].RFA_1 := j;
   end;
   for i := 1 to RecordsCount-1 do begin // calculating file sizes
    RFA[i].RFA_2 := RFA[i+1].RFA_1 - RFA[i].RFA_1; // warning: might be a buggy behavior in the future
   end;
   RFA[RecordsCount].RFA_2 := ArchiveStream.Size - RFA[RecordsCount].RFA_1; // so it's changed here

   // WARNING! Hack for fast file extraction. Should be removed in read-write version!
   for i := 1 to RecordsCount do begin
    RFA[i].RFA_1 := RFA[i].RFA_1 + 64;
    RFA[i].RFA_2 := RFA[i].RFA_2 - 64;
   end;
   // END OF HACK


   for i := 1 to RecordsCount do RFA[i].RFA_C := RFA[i].RFA_2;


   FNTable := TMemoryStream.Create; // copying filenames into separate stream
   FNTable.CopyFrom(TempoStream,TempoStream.Size-TempoStream.Position);

   Seek(4,soBeginning); // moving to filename array
   
   for i := 1 to RecordsCount do begin // reading filenames
    Read(j,4);
    FNTable.Seek(j,soBeginning);
    for k := $1 to $FF do begin
     FNTable.Read(b,1);
     if b = #0 then break;
     RFA[i].RFA_3 := RFA[i].RFA_3 + b;
    end;
    // HACK FOR FAST FILE EXTRACTION
    RFA[i].RFA_3 := RFA[i].RFA_3 + '.png';
    // END OF HACK
   end;

   FreeAndNil(FNTable);

   FreeAndNil(TempoStream);
  end;

  Result := True;
 end;

end;

function OA_CycSoft_VPK;
var i : integer;
    Dir : TVTBDir;
    DIRStream, TempoStream : TStream;
begin
 Result := False;
 if FileExists(ChangeFileExt(ArchiveFileName,'.vtb')) and (LowerCase(ExtractFileExt(ArchiveFileName)) = '.vpk') then
 if ArchiveFileName <> ChangeFileExt(ArchiveFileName,'.vtb') then begin
  DIRStream := TFileStreamJ.Create(ChangeFileExt(ArchiveFileName,'.vtb'),fmOpenRead);
  TempoStream := TMemoryStream.Create;
  TempoStream.CopyFrom(DIRStream,DIRStream.Size);
  FreeAndNil(DIRStream);
  TempoStream.Position := 0;

  with TempoStream do begin
   Seek(0,soBeginning);

   if SizeMod(TempoStream.Size,SizeOf(Dir)) <> 0 then exit; // integrity check

   RecordsCount := SizeBlock(TempoStream.Size,SizeOf(Dir)) - 1; // has eof record

   for i := 1 to RecordsCount+1 do begin // reading file offsets and names
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Dir.Offset;
    RFA[i].RFA_3 := Dir.Filename;
   end;

   for i := 1 to RecordsCount do begin // calculating file sizes
    RFA[i].RFA_2 := RFA[i+1].RFA_1 - RFA[i].RFA_1; // warning: might be a buggy behavior in the future
   end;

   for i := 1 to RecordsCount do RFA[i].RFA_C := RFA[i].RFA_2;

   FreeAndNil(TempoStream);
  end;

  Result := True;
 end;

end;


end.