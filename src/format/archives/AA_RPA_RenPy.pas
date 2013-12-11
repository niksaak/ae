{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Ren'Py RPA archive format & functions
  Written by dsp2003 & Nik.
}

unit AA_RPA_RenPy;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Classes, Windows, Forms, Sysutils,
     ZLibEx;

 { Supported archives implementation }
 procedure IA_RPA_RenPy(var ArcFormat : TArcFormats; index : integer);

  function OA_RPA_RenPy : boolean;
//  function SA_RPA_RenPy(Mode : integer) : boolean;
  function EA_RPA_RenPy(FileRecord : TRFA) : boolean;
  procedure SkipIndex(stream : TStream);

type
 TRPAHeader = packed record
  Header      : array[1..7] of char; // 'RPA-3.0'
  Padding_0   : char;                // space
  TableOffset : array[1..16] of char; // filetable offset
  Padding_1   : char;                // space
  Key         : array[1..8] of char; // key
  Ending      : char;                 // $0A
 end;
{
80 02 7D - типа хедер (80 - magic, 02 - тип протокола, 7D - хз :) )
71 01 - глобальный индекс обьекта

28 - указатель 1/много элементов (если много, то он есть)

loop[
     55 - текстовое поле
     1 байт - его длина
     само поле (имя файла)
     длина индекса 71(1 байт) или 72(4 байта) + индекс (02 - базовый, следующий = +3), записан с младших байт (т.е. по нормальному :) )

     5D - опкод-указатель того, что далее содержимое массива(?)
     длина+индекс (базовый 03 и далее +=3)

     4A - 4-х байтовое поле
     4 байт (с младших байт) - оффсет (нужен ксор по ключу)

     4A - 4-х байтовое поле
     4 байт (с младших байт) - длина, включая первые 16 байт (нужен ксор по ключу)

     (В ранних версиях этого поля нет)
     55 - текстовое поле
     1 байт - его длина (всегда 10)
     16 первых байт файла

     87 (поздние версии) или 86 (ранние версии) -
       закрыли массив (нужно учитывать, что перед опкодом закрытия массива может встретиться "лишний индекс", хз зачем он нужен)
     длина+индекс (базовый 04 и далее +=3)

     61 закрыли элемент
]

75 2E - закрыли обьект
}

implementation

uses AnimED_Archives;

procedure IA_RPA_RenPy;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Ren''Py v3.0';
  Ext  := '.rpa';
  Stat := $F;
  Open := OA_RPA_RenPy;
//  Save := SA_RPA_RenPy;
  Extr := EA_RPA_RenPy;
  FLen := $FF;
  SArg := 0;
  Ver  := $20091122;
 end;
end;

procedure SkipIndex(stream : TStream);
var b : byte;
begin
  stream.Read(b,1);
  if b = $72 then b := 4 else b := 1;
  stream.Position := stream.Position + b;
end;

function OA_RPA_RenPy;
var i, key : integer;
    Hdr : TRPAHeader;
    tmpStream, tmpStreamC : TStream;
    w : word;
    b : byte;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Hdr,SizeOf(Hdr));
  with Hdr do begin
   if Header <> 'RPA-3.0' then Exit;
  
   Seek(hextoint(TableOffset),soBeginning);
  
   // копируем заголовок во временный поток...
   tmpStreamC := TMemoryStream.Create;
   tmpStreamC.CopyFrom(ArchiveStream,ArchiveStream.Size-ArchiveStream.Position);
   tmpStreamC.Position := 0;

   tmpStream := TMemoryStream.Create;
   // ...и распаковываем
   ZDecompressStream(tmpStreamC, tmpStream);

   FreeAndNil(tmpStreamC);

{ Debug }
{  tmpStream.Position := 0;
   tmpStreamC := TFileStream.Create(ArchiveFileName+'.filetable',fmCreate);
   tmpStreamC.CopyFrom(tmpStream,tmpStream.Size);
   FreeAndNil(tmpStreamC);}
   
  end;
 end;
 key := hextoint(Hdr.Key);
 with tmpStream do begin
  Seek(0,soBeginning);
  Read(w,2);
  Read(b,1);
  if (w <> $280) and (b <> $7D) then
  begin
   FreeAndNil(tmpStream);
   Exit;
  end;
  RecordsCount := 0;
  Position := Position + 2;
  Read(b,1);
  if b <> $28 then Position := Position - 1;
  while true do begin
   Read(b,1);
   if ((b = $75) or (b = $73)) then begin
    if Position >= Size-1 then break else Position := Position + 2;
   end;
   Inc(RecordsCount);
   tmpStream.Read(b,1);
   SetLength(RFA[RecordsCount].RFA_3,b);
   Read(RFA[RecordsCount].RFA_3[1],b);
   for i := 1 to b do if RFA[RecordsCount].RFA_3[i] = '/' then RFA[RecordsCount].RFA_3[i] := '\';
   SkipIndex(tmpStream);
   Position := Position + 1;
   SkipIndex(tmpStream);
   Position := Position + 1;
   Read(RFA[RecordsCount].RFA_1,4);
   RFA[RecordsCount].RFA_1 := RFA[RecordsCount].RFA_1 xor key;
   Position := Position + 1;
   Read(RFA[RecordsCount].RFA_2,4);
   RFA[RecordsCount].RFA_2 := RFA[RecordsCount].RFA_2 xor key;
   RFA[RecordsCount].RFA_C := RFA[RecordsCount].RFA_2;
   SetLength(RFA[RecordsCount].RFA_T,1);
   SetLength(RFA[RecordsCount].RFA_T[0],1);
   Read(b,1);
   if b = $55 then begin
    Read(b,1);
    SetLength(RFA[RecordsCount].RFA_T[0][0],b);
    Read(RFA[RecordsCount].RFA_T[0][0][1],b);
    Read(b,1);
   end else RFA[RecordsCount].RFA_T[0][0] := '';
   if (b <> $87) and (b <> $86) then begin
    if b = $72 then b := 4 else b := 1;
    Position := Position + b + 1;
   end;
   SkipIndex(tmpStream);
   Position := Position + 1;
  end;
 end;

 FreeAndNil(tmpStream);   

 Result := True;
 
end;

function EA_RPA_RenPy;
begin
 with FileRecord, FileDataStream do begin
  ArchiveStream.Position := RFA_1;
  if Length(RFA_T[0][0]) > 0 then Write(RFA_T[0][0][1],Length(RFA_T[0][0]));
  CopyFrom(ArchiveStream,RFA_C-Length(RFA_T[0][0]));
 end; 
 Result := True;
end;

end.