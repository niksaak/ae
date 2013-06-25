{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  AliceSoft archive formats & functions
  
  Written by Nik & dsp2003.
  Specifications from w8m.
}

unit AA_ALD_AliceSoft;

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
 procedure IA_ALD_System4(var ArcFormat : TArcFormats; index : integer);

  function OA_ALD_System4 : boolean;
//  function SA_ALD_System4(Mode : integer) : boolean;

type
 TSys4ALDHdr = packed record // находится в конце файла, неверный
  Magic     : longword; // $14C4E ('NL'+$1)
  Version   : longword; // $10
  Priority  : byte;     // $1 - $FF, порядковый номер архива одного типа
  FileCount : longword; // + 2 метафайла. не всегда указано правильное количество
  Dummy     : array[1..3] of byte; // $0, из-за выравнивания
 end;

 TSys4ALDDir = packed record // находится перед файлом
  TabElSize : longword;
  FileSize  : longword; // все файлы в архиве записаны с выравниванием по 256 байт
  FileTime  : int64;
//FileName  : array of char; // размер поля указан в TabElSize
 end;

implementation

uses AnimED_Archives;

procedure IA_ALD_System4;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Alicesoft System4';
  Ext  := '.ald';
  Stat := $F;
  Open := OA_ALD_System4;
//  Save := SA_ALD_System4;
  Extr := EA_RAW;
  SArg := 0;
  Ver  := $20110322; //$20100219;
 end;
end;

function OA_ALD_System4;
var Hdr : TSys4ALDHdr;
    Dir : TSys4ALDDir;
    i, fpos : longword;
    FileName : string;
begin
 Result := false;

 with ArchiveStream do begin

  with Hdr do begin
   Seek(-SizeOf(Hdr),soEnd); // переходим в конец файла архива минус размер от заголовка
   Read(Hdr,SizeOf(Hdr));
   if (Magic <> $14C4E) or (Version <> $10) then Exit;
   RecordsCount := FileCount;
  end;

  for i := 1 to RecordsCount do begin

   Seek(3*i,soBeginning);

   Read(fpos,3);
   fpos := fpos shl 8;

   Seek(fpos,soBeginning);

   Read(Dir,SizeOf(Dir));

   with RFA[i], Dir do begin
    SetLength(FileName,TabElSize-SizeOf(Dir)); // устанавливаем длину имени файла
    Read(FileName[1],Length(FileName));
    if FileName = '' then FileName := 'File_'+inttostr(i)+'.bin';
    RFA_1 := fpos + TabElSize;
    RFA_2 := FileSize;
    RFA_C := FileSize;
    RFA_3 := FileName;
   end;

  end;

 end;

 Result := true;

end;

end.