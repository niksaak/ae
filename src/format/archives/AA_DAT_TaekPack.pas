{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Samsung DVD-Karaoke MIDI archive format & functions
  
  Written by dsp2003.
}

unit AA_DAT_TaekPack;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_DAT_TaekPack(var ArcFormat : TArcFormats; index : integer);

 function OA_DAT_TaekPack : boolean;

type
{ Temporary component. Don't forget to delete it soon. :) }
 TDVDMIDI = packed record
  DVDMIDIHeader : array[1..14] of char;
  Unknown       : array[1..26] of byte;
  TotalRecords  : longword;
  Unknown2      : array[1..288] of byte;
 end;
 TDVDMIDIDir = record
  Filename      : array[1..16] of char;
  Offset        : longword;
  Filesize      : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_DAT_TaekPack;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'TeakPack 0.01 DVD MIDI';
  Ext  := '.dat';
  Stat := $F;
  Open := OA_DAT_TaekPack;
//  Save := ;
  Extr := EA_RAW;
  FLen := 16;
  SArg := 0;
  Ver  := $20091027;
 end;
end;

{ This function was created for my mom, who wanted to extract MIDI data from
  Samsung DVD-KaraOke files. :) Leaved here as bonus. }
function OA_DAT_TaekPack;
var i,j : integer;
    DVDMIDI : TDVDMIDI;
    DVDMIDIDir : TDVDMIDIDir;
label StopThis;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(DVDMIDI,SizeOf(DVDMIDI));

  if DVDMIDI.DVDMIDIHeader <> 'TaekPack 0.01'#0 then Exit;

  RecordsCount := DVDMIDI.TotalRecords;

{*}Progress_Max(RecordsCount);

// Reading filetable...
  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   with DVDMIDIDir do begin
    Read(DVDMIDIDir,SizeOf(DVDMIDIDir));
    for j := 1 to 16 do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
    RFA[i].RFA_1 := offset;
    RFA[i].RFA_2 := FileSize;
    RFA[i].RFA_C := FileSize; // replicates filesize
   end;
  end;
 end;
 Result := True;

end;


end.