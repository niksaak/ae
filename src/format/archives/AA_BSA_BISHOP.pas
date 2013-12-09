{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  BISHOP Engine BSArc archive format & functions

  Written by dsp2003.

  Note to future compression implementators: the format attempts to optimize
  used space by merging files with exact checksum (CRC32+MD5 pair), which
  results in duplicate entries with different filenames.
}

unit AA_BSA_BISHOP;

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
 procedure IA_BSA_BISHOP(var ArcFormat : TArcFormats; index : integer);

  function OA_BSA_BISHOP : boolean;
//  function SA_BSA_BISHOP(Mode : integer) : boolean;

type
 TBSAHdr = packed record
  Magic     : array[1..8] of char; // 'BSArc'#0#0#0
  Version   : word;
  FileCount : word;
  DirOffset : longword;
 end;
 TBSADir = packed record
  FNOffset  : longword;
  Offset    : longword;
  Filesize  : longword;
 end;
// TBSAFNDir = packed record
//  Filename : string;
// end;

implementation

uses AnimED_Archives;

procedure IA_BSA_BISHOP;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'BISHOP Engine BSArc';
  Ext  := '.bsa';
  Stat := $F;
  Open := OA_BSA_BISHOP;
//  Save := SA_BSA_BISHOP;
  Extr := EA_RAW;
  FLen := $FF;
  SArg := 0;
//  Ver  := $20120404;
  Ver  := $20121013;
 end;
end;

function OA_BSA_BISHOP;
var i,j,k,l,m : longword;
    Hdr : TBSAHdr;
    Dir : TBSADir;
    Filename : string;
    FNPath : array of string;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Magic <> 'BSArc'#0#0#0 then Exit;
   if Version <> $3 then begin
    LogE('Unknown BSArc version: '+inttostr(Version)+'. Please notify current maintainer about this!');
   end;
   RecordsCount := FileCount;

{*}Progress_Max(RecordsCount);

   k := 0;

   for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);
    // Such perverted way of reading file table is due to the nature of file table =_=
    Seek(DirOffset+(SizeOf(Dir)*(i-1)),soBeginning);

    with Dir do begin

     Read(Dir,SizeOf(Dir));

     // Setting pointer to filename table
     Seek(DirOffset+(SizeOf(Dir)*RecordsCount)+FNOffset,soBeginning);
     // Resetting filename
     SetLength(Filename,0);

     // if 0, we're dealing with path entry
     m := Offset+Filesize;
     if m > 0 then begin
      inc(k);
      with RFA[k] do begin
       RFA_1 := Offset;
       RFA_2 := FileSize;
       RFA_C := FileSize;

       // reading filename into table and merging it with path
       for l := 1 to Length(FNPath) do begin
        RFA_3 := RFA_3 + FNPath[l-1] + '\'; // '\' because of windows... =_=
       end;

       for j := 1 to $ff do begin
        SetLength(Filename,j);
        Read(FileName[j],1);
        if FileName[j] = #0 then break;
        RFA_3 := RFA_3 + FileName[j];
       end;

      end;

     end else begin
      SetLength(Filename,1);
      Read(FileName[1],1);

      // Parsing directory name
      case FileName[1] of
      #0  : break;
      '>' : begin // Adding new element
             SetLength(FNPath,Length(FNPath)+1);
             for m := 1 to $ff do begin
              // Setting length of string of FNPath[n]
              j := Length(FNPath)-1;
              SetLength(FNPath[j],m);
              Read(FNPath[j][m],1);
              if FNPath[j][m] = #0 then begin
               SetLength(FNPath[j],m-1);
               break;
              end;
             end;
            end;
      '<' : if Length(FNPath) > 0 then SetLength(FNPath,Length(FNPath)-1); // Removing the last element + Sanity check
      end;

     end;

    end;

   end;
  end;

  RecordsCount := k;

  Result := True;
 end;

end;

{function SA_BSA_BISHOP;
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
   Write(Dir,SizeOf(Dir));
   
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