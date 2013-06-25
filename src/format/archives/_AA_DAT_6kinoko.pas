{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  RockStar GTA III\VC\SA game archive format & functions
  
  Written by dsp2003.
  
  
  0x3B204EC5
}

unit AA_IMG_GTA3;

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
 procedure IA_IMG_GTA3v1(var ArcFormat : TArcFormats; index : integer);

  function OA_IMG_GTA3v1 : boolean;
  function SA_IMG_GTA3v1(Mode : integer) : boolean;

type
 T6KinokoHdr = packed record
  FileCount : word;
  FTSize    : longword;
 end;

 T6KinokoDir = packed record
  Offset    : longword;
  FileSize  : longword;
  FNLength  : byte;
 end;
 // Filename : string;

w8m: Каждый байт файлов поксорен на старотовый оффсет файла
w8m: xor_key = (offset shr 1) or $23

implementation

uses AnimED_Archives;

procedure IA_IMG_GTA3v2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'RockStar GTA San Andreas Archive (.img)';
  Name := '[IMG] RockStar GTA San Andreas';
  Ext  := '.img';
  Stat := $0;
  Open := OA_IMG_GTA3v2;
  Save := SA_IMG_GTA3v2;
  Extr := EA_RAW;
  FLen := 24;
  SArg := 0;
  Ver  := $20100731;
 end;
end;

function OA_IMG_GTA3v2;
var i,j : integer;
    Hdr : TIMGHdr;
    Dir : TIMGDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'VER2' then Exit;
   RecordsCount := FileCount;
  end;

// Reading file table...
  for i := 1 to RecordsCount do begin    
   with Dir do begin
    Read(Dir,SizeOf(Dir));
    RFA[i].RFA_1 := Offset   * 2048;
    RFA[i].RFA_2 := FileSize * 2048;
    RFA[i].RFA_C := FileSize * 2048;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
  end;

  Result := True;
 end;

end;

function SA_IMG_GTA3v2;
var i,j : integer;
    Dummy : array of byte;
    Hdr : TIMGHdr;
    Dir : TIMGDir;
begin
 Result := False;

 with ArchiveStream do begin

  RecordsCount := AddedFiles.Count;

  with Hdr do begin
   Magic     := 'VER2';
   FileCount := RecordsCount;
   UpOffset  := SizeDiv(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048);
  end;

  Write(Hdr,SizeOf(Hdr));

{*}Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);
   
   RFA[i].RFA_1 := UpOffset;
   RFA[i].RFA_2 := SizeDiv(FileDataStream.Size,2048);
   
   FreeAndNil(FileDataStream);

   UpOffset := UpOffset + RFA[i].RFA_2;
  
   with Dir do begin
    Offset   := RFA[i].RFA_1 div 2048;
    FileSize := RFA[i].RFA_2 div 2048;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   end;

   // пишем кусок таблицы
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
  end;

  SetLength(Dummy,SizeMod(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048));

  // дописываем выравнивание
  Write(Dummy[0],Length(Dummy));

  for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
   // пишем файл в архив
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   CopyFrom(FileDataStream,FileDataStream.Size);
   // пишем массив-пустышку
   SetLength(Dummy,SizeMod(FileDataStream.Size,2048));
   Write(Dummy[0],Length(Dummy));
   // высвобождаем поток файла
   FreeAndNil(FileDataStream);
  end;
  
 end; // with ArchiveStream

 Result := True;

end;

{ Period parameters }
const
  cN  = 624;
  cM  = 397;
  cMA = $9908b0df; // constant vector a
  cUM = $80000000; // most significant w-r bits
  cLM = $7fffffff; // least significant r bits

{ Tempering parameters }
  cB = $9d2c5680;
  cC = $efc60000;

var mti : longword;
    tab : array[0..$26F] of longword;

procedure TouhouHashInit(a : longword);
var i : longword;
begin
 tab[0] = a;
 for i := 1 to cN-1 do begin
  a := ((a shr 30) xor a) * 0x6C078965 + i;
  tab[i] := a;
 end;
end;

function genrand_MT19937: longword;
const a01 : array[0..1] of longword = (0, cMA);
var y: longword;
    kk: integer;
begin
 if mti >= cN then begin
  for kk:=0 to cN-cM-1 do begin
   y := (tab[kk] and cUM) or (tab[kk+1] and cLM);
   tab[kk] := tab[kk+cM] xor (y shr 1) xor a01[y and $00000001];
  end;
  for kk:= cN-cM to cN-2 do begin
   y := (tab[kk] and cUM) or (tab[kk+1] and cLM);
   tab[kk] := tab[kk+(cM-cN)] xor (y shr 1) xor a01[y and $00000001];
  end;
  y := (tab[cN-1] and cUM) or (tab[0] and cLM);
  tab[cN-1] := tab[cM-1] xor (y shr 1) xor a01[y and $00000001];
  mti := 0;
 end;
 y := tab[mti]; inc(mti);
 y := y xor (y shr 11);
 y := y xor (y shl 7)  and cB;
 y := y xor (y shl 15) and cC;
 y := y xor (y shr 18);
 Result := y;
end;

ZunDecode

a = 0xC5; b = 0x89; c = 0x49; for(i = 0; i < n; i++) { filetab[i] ^= genrand_MT19937; filetab[i] ^= a; a += b; b += c; }

end.