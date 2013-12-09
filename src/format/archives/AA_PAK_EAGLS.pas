{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Tech-Arts [E]nhanced [A]dventure [G]ame [L]anguage [S]ystem archive format & functions
  Written by dsp2003 & Nik.
}

unit AA_PAK_EAGLS;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     Classes, Windows, Forms, Sysutils, JUtils;

 { Supported archives implementation }
 procedure IA_PAK_EAGLS(var ArcFormat : TArcFormats; index : integer);
 procedure IA_PAK_EAGLS2011(var ArcFormat : TArcFormats; index : integer);

  function OA_PAK_EAGLS : boolean;
  function SA_PAK_EAGLS(Mode : integer) : boolean;

  function OA_PAK_EAGLS2011 : boolean;
  function SA_PAK_EAGLS2011(Mode : integer) : boolean;

 procedure IDX_XOR(Input, Output : TStream; BeginNumber, Len : longword; DecryptKey : string);

type
 TIDXDir = packed record
  FileName : array[1..20] of char;
  Offset   : longword;
  FileSize : longword;
 end;

 TIDXDir2011 = packed record
  FileName : array[1..24] of char;
  Offset   : int64;
  FileSize : int64;
 end;

implementation

uses AnimED_Archives;

const keyMonoMono = '1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik,9ol.0p;/-@:^[]'; // Mono Gokoro Mono Musu me

procedure IA_PAK_EAGLS;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Tech-Arts EAGLS';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_EAGLS;
  Save := SA_PAK_EAGLS;
  Extr := EA_RAW;
  FLen := 20;
  SArg := 0;
  Ver  := $20090913;
 end;
end;

procedure IA_PAK_EAGLS2011;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Tech-Arts EAGLS 2011';
  Ext  := '.pak';
  Stat := $0;
  Open := OA_PAK_EAGLS2011;
  Save := SA_PAK_EAGLS2011;
  Extr := EA_RAW;
  FLen := 18;
  SArg := 0;
  Ver  := $20110629;
 end;
end;


function OA_PAK_EAGLS;
var i : integer; j : longword;
    Dir : TIDXDir;
    DIRStream, tmpStream : TStream;
const PAK_Ext : array [1..2] of string = ('.pak','.idx');
begin
 Result := False;

 for i := 1 to Length(PAK_Ext) do if not FileExists(ChangeFileExt(ArchiveFileName,PAK_Ext[i])) then Exit;

 // финт ушами. закрываем неправильный файл и открываем .pak вне зависимости от того, какой был открыт в данный момент
 if lowercase(ExtractFileExt(ArchiveFileName)) <> PAK_Ext[1] then begin
  FreeAndNil(ArchiveStream);
  ArchiveFileName := ChangeFileExt(ArchiveFileName, PAK_Ext[1]);
  OpenFileStream(ArchiveStream,ArchiveFileName,fmOpenRead);
 end;

 OpenFileStream(DIRStream,ChangeFileExt(ArchiveFileName,PAK_Ext[2]),fmOpenRead);
 tmpStream := TMemoryStream.Create;
 tmpStream.CopyFrom(DIRStream,DIRStream.Size-4);
 DIRStream.Read(j,4); // читаем BeginNumber
 FreeAndNil(DIRStream);
 tmpStream.Seek(0,soBeginning);
 DIRStream := TMemoryStream.Create;
 IDX_XOR(tmpStream,DIRStream,j,tmpStream.Size,keyMonoMono);
 FreeAndNil(tmpStream);

 with DirStream do begin
  Seek(0,soBeginning);

//Reading file table...
  i := 0; // filecount to 0
  while DirStream.Position < DirStream.Size do begin
   with Dir, RFA[i+1] do begin
    Read(Dir,SizeOf(Dir));
    if FileName[1] = #0 then case i of
      0 : Exit; // если первое имя содержит нуль в первом символе, значит архив битый
     else break; // если файл содержит нуль в первом символе, значит таблица кончилась
    end;
    if i = 0 then if Offset <> $174B then Exit;
    RFA_1 := Offset - $174B;
    RFA_2 := FileSize;
    RFA_C := FileSize;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
    inc(i); // filecount increasing
   end;
  end;
  RecordsCount := i; // filecount

  FreeAndNil(DirStream);
 end;

 Result := True;

end;

function SA_PAK_EAGLS;
var i,j : integer;
    Dir : TIDXDir;
    Dummy : array of byte;
    dirStream, tmpStream : TStream;
begin
 Result := False;

 OpenFileStream(dirStream,ChangeFileExt(ArchiveFileName,'.idx'),fmCreate);
 tmpStream := TMemoryStream.Create;

 RecordsCount := AddedFiles.Count;
 UpOffset := $174B; // It's MAGIC *ROFL*

{*}Progress_Max(RecordsCount);

 for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

  RFA[i].RFA_1 := UpOffset;
  RFA[i].RFA_2 := FileDataStream.Size;

  UpOffset := UpOffset + RFA[i].RFA_2;

  with Dir do begin
   Offset   := RFA[i].RFA_1;
   FileSize := RFA[i].RFA_2;
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
  end;

  // пишем кусок таблицы
  tmpStream.Write(Dir,SizeOf(Dir));
  // пишем файл в архив
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  // высвобождаем поток файла
  FreeAndNil(FileDataStream);
 end;

 // устанавливаем длину пустышки
 SetLength(Dummy,SizeMod(tmpStream.Size,280000));

 tmpStream.Write(Dummy[0],Length(Dummy));
 tmpStream.Position := 0;

 IDX_XOR(tmpStream,dirStream,RecordsCount,tmpStream.Size,keyMonoMono);

 FreeAndNil(tmpStream);

 dirStream.Write(RecordsCount,4); // ага, пишем сюда количество файлов в архиве ^_^

 // высвобождаем поток файла заголовка
 FreeAndNil(dirStream);

 Result := True;

end;

function OA_PAK_EAGLS2011;
var i : integer; j : longword;
    Dir : TIDXDir2011;
    DIRStream, tmpStream : TStream;
const PAK_Ext : array [1..2] of string = ('.pak','.idx');
begin
 Result := False;

 for i := 1 to Length(PAK_Ext) do if not FileExists(ChangeFileExt(ArchiveFileName,PAK_Ext[i])) then Exit;

 // финт ушами. закрываем неправильный файл и открываем .pak вне зависимости от того, какой был открыт в данный момент
 if lowercase(ExtractFileExt(ArchiveFileName)) <> PAK_Ext[1] then begin
  FreeAndNil(ArchiveStream);
  ArchiveFileName := ChangeFileExt(ArchiveFileName, PAK_Ext[1]);
  OpenFileStream(ArchiveStream,ArchiveFileName,fmOpenRead);
 end;

 OpenFileStream(DIRStream,ChangeFileExt(ArchiveFileName,PAK_Ext[2]),fmOpenRead);
 tmpStream := TMemoryStream.Create;
 tmpStream.CopyFrom(DIRStream,DIRStream.Size-4);
 DIRStream.Read(j,4); // читаем BeginNumber
 FreeAndNil(DIRStream);
 tmpStream.Seek(0,soBeginning);
 DIRStream := TMemoryStream.Create;
 IDX_XOR(tmpStream,DIRStream,j,tmpStream.Size,keyMonoMono);
 FreeAndNil(tmpStream);

 with DirStream do begin
  Seek(0,soBeginning);

//Reading file table...
  i := 0; // filecount to 0
  while DirStream.Position < DirStream.Size do begin
   with Dir, RFA[i+1] do begin
    Read(Dir,SizeOf(Dir));
    if FileName[1] = #0 then case i of
      0 : Exit; // если первое имя содержит нуль в первом символе, значит архив битый
     else break; // если файл содержит нуль в первом символе, значит таблица кончилась
    end;
    if i = 0 then if Offset <> $174B then Exit;
    RFA_1 := Offset - $174B;
    RFA_2 := FileSize;
    RFA_C := FileSize;
    for j := 1 to length(FileName) do if FileName[j] <> #0 then RFA_3 := RFA_3 + FileName[j] else break;
    inc(i); // filecount increasing
   end;
  end;
  RecordsCount := i; // filecount

  FreeAndNil(DirStream);
 end;

 Result := True;

end;

function SA_PAK_EAGLS2011;
var i,j : integer;
    Dir : TIDXDir2011;
    Dummy : array of byte;
    dirStream, tmpStream : TStream;
begin
 Result := False;

 OpenFileStream(dirStream,ChangeFileExt(ArchiveFileName,'.idx'),fmCreate);
 tmpStream := TMemoryStream.Create;

 RecordsCount := AddedFiles.Count;
 UpOffset := $174B; // It's MAGIC *ROFL*

{*}Progress_Max(RecordsCount);

 for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);

  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

  RFA[i].RFA_3 := ExtractFileName(AddedFiles.Strings[i-1]);

  RFA[i].RFA_1 := UpOffset;
  RFA[i].RFA_2 := FileDataStream.Size;

  UpOffset := UpOffset + RFA[i].RFA_2;

  with Dir do begin
   Offset   := RFA[i].RFA_1;
   FileSize := RFA[i].RFA_2;
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to Length(FileName) do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
  end;

  // пишем кусок таблицы
  tmpStream.Write(Dir,SizeOf(Dir));
  // пишем файл в архив
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  // высвобождаем поток файла
  FreeAndNil(FileDataStream);
 end;

 // устанавливаем длину пустышки
 SetLength(Dummy,SizeMod(tmpStream.Size,280000));

 tmpStream.Write(Dummy[0],Length(Dummy));
 tmpStream.Position := 0;

 IDX_XOR(tmpStream,dirStream,RecordsCount,tmpStream.Size,keyMonoMono);

 FreeAndNil(tmpStream);

 dirStream.Write(RecordsCount,4); // ага, пишем сюда количество файлов в архиве ^_^

 // высвобождаем поток файла заголовка
 FreeAndNil(dirStream);

 Result := True;

end;

procedure IDX_XOR;
var i, key, DivNum : longword;
    bt : byte;
begin
 DivNum := Length(DecryptKey);
 for i := 1 to Len do begin
  Input.Read(bt,1);
  BeginNumber := (BeginNumber * $343FD) + $269EC3;
  key := (BeginNumber shr $10) and $7FFF;
  key := key mod DivNum;
  bt := bt xor Byte(DecryptKey[key+1]);
  Output.Write(bt,1);
 end;
end;

end.