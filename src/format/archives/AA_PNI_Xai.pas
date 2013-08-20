{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Xai Puni Mo E~ru! archive format & functions
  
  Written by dsp2003 & Nik.
}

unit AA_PNI_Xai;

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
 procedure IA_PNI_Xai(var ArcFormat : TArcFormats; index : integer);

  function OA_PNI_Xai : boolean;
//function SA_PNI_Xai(Mode : integer) : boolean;

  function XaiLZDecode(iStream,oStream : TStream) : boolean;

type
 TPNIDir = packed record
  Filename : array[1..8] of char;
  Offset   : array[1..8] of char; // hex representation of longword. Oh my gosh-- /)_<
 end;
 // File table ends with 'END_ffff'+'ffffffff'

implementation

uses AnimED_Archives;

procedure IA_PNI_Xai;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Xai Puni Mo E~ru!';
  Ext  := '.pni'; // .dat
  Stat := $F;
  Open := OA_PNI_Xai;
//  Save := SA_PNI_Xai;
  Extr := EA_RAW;
  FLen := 8;
  SArg := 0;
  Ver  := $20120304;
 end;
end;

function OA_PNI_Xai;
var i,j : integer;
    Dir : TPNIDir;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);

  i := 0;

  while Position < Size do begin
  
   inc(i);

   with Dir,RFA[i] do begin

    Read(Dir,SizeOf(Dir));

    for j := 1 to length(FileName) do if FileName[j] = #0 then Exit else RFA_3 := RFA_3 + FileName[j];

    try
     RFA_1 := strtoint('$'+Offset); // attempting to convert hex offset
    except
     Exit; // on error: not an valid archive
    end;

    if RFA_1 > Size then begin
     if RFA_1 = $ffffffff then begin // encountered end of table
      ReOffset := Position; // remembering end of filetable
      RecordsCount := i-1; // removing eof entry
      break;
     end else Exit;
    end;

   end;

  end;

{*}Progress_Max(RecordsCount);

  UpOffset := ReOffset;

  for i := 1 to RecordsCount do begin
   with RFA[i] do begin
    RFA_1 := RFA_1 + ReOffset;
    if i = RecordsCount then begin
     RFA_2 := Size                    - RFA_1;
    end else begin
     RFA_2 := RFA[i+1].RFA_1+ReOffset - RFA_1;
    end;
    RFA_C := RFA_2;
   end;
  end;

  Result := True;
 end;

end;


function XaiLZDecode;
var bt, e, q, inv : byte;
 i, j, pcnt : integer;
 pixbuf : array[0..2] of byte;
begin
 Result := False;
 iStream.Seek(0,soBeginning);
 oStream.Seek(0,soBeginning);
 while iStream.Position < iStream.Size do begin
  for i := 1 to 7 do begin
   if byte(bt and 1) <> 0 then begin
    iStream.Read(pixbuf,3);
    inv := pixbuf[0];
    pixbuf[0] := pixbuf[2];
    pixbuf[2] := inv;
    iStream.Read(e,1);
    iStream.Read(q,1);
    pcnt := (e shr 8) + q;
    for j := 1 to pcnt do begin
     oStream.Write(pixbuf,3);
    end;
   end else begin
    iStream.Read(pixbuf,3);
    inv := pixbuf[0];
    pixbuf[0] := pixbuf[2];
    pixbuf[2] := inv;
    oStream.Write(pixbuf,3);
   end;
   bt := bt shl 1;
  end;
 end;
 Result := True;
end;


{function SA_PNI_Xai;
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

{*}{Progress_Max(RecordsCount);

  for i := 1 to RecordsCount do begin

{*}{Progress_Pos(i);

   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   with Dir,RFA[i] do begin
    RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

    RFA_1 := UpOffset;
    RFA_2 := SizeDiv(FileDataStream.Size,2048);

    FreeAndNil(FileDataStream);

    UpOffset := UpOffset + RFA_2;

    Offset   := RFA_1 div 2048;
    FileSize := RFA_2 div 2048;
    FillChar(FileName,SizeOf(FileName),0);
    for j := 1 to Length(FileName) do if j <= length(RFA_3) then FileName[j] := RFA_3[j] else break;
   end;

   // пишем кусок таблицы
   ArchiveStream.Write(Dir,SizeOf(Dir));
   
  end;

  // дописываем выравнивание
  SetLength(Dummy,SizeMod(SizeOf(Hdr)+SizeOf(Dir)*RecordsCount,2048));
  Write(Dummy[0],Length(Dummy));

  for i := 1 to RecordsCount do begin
{*}{Progress_Pos(i);
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

end;}

end.