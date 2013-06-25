{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  XP3 KiriKiri2 game archive format & functions

  Specifications and Adler32 code from Proger_XP.

  Written by dsp2003.
}

unit AA_XP3_KiriKiri2;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_FileTypes,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Progress,
     Generic_Hashes,
     JReconvertor,
     FileStreamJ,
     ZLibEx,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_XP3_KrKr2(var ArcFormat : TArcFormats; index : integer);
 procedure IA_XP3_KrKr2C(var ArcFormat : TArcFormats; index : integer);
 procedure IA_XP3_KrKr2N(var ArcFormat : TArcFormats; index : integer);
 procedure IA_XP3_KrKr2NC(var ArcFormat : TArcFormats; index : integer);
 procedure IA_XP3_KrKr2N2(var ArcFormat : TArcFormats; index : integer);
 procedure IA_XP3_KrKr2N2C(var ArcFormat : TArcFormats; index : integer);

  function OA_XP3_KrKr2 : boolean;
  function SA_XP3_KrKr2(Mode : integer) : boolean;
  function EA_XP3_KrKr2(FileRecord : TRFA) : boolean;

type
 { KiriKiri2/KAG3 archive format }
 TKrKrHeader = packed record
  Header   : array[1..11] of char;        // $58 $50 $33 $0D $0A $20 $0A $1A $8B $67 $01
  FTOffset : int64;                       // File table offset. If = $17 then read NewHeader
 end;

 // header in newer versions of XP3
 TKrKrNewHeader = packed record
  Check    : longword;                    // $01
  Check2   : longword;                    // $80
  Dummy    : array[1..5] of byte;         // zeroes
  FTOffset : int64;
 end;

 TKrKrFTHdrCheck = packed record
  Check    : byte;                        // always $01. if $00, then the table is uncompressed 
 end;

 TKrKrFTHeader = packed record
  CompSize : int64;                       // File table compressed stream size
  Size     : int64;                       // File table uncompressed stream size
 end;

 TKrKrFTHeaderNoComp = packed record
  Size     : int64;
 end;

 { File table segments }
 TKrKrDir = packed record
  HDR_File  : array[1..4] of char;        // 'File'
  DirLength : int64;                      // dir entry length
  HDR_Info  : array[1..4] of char;        // 'info'
  InfoLength: int64;                      // info entry length
  Encrypted : longword;                   // encrypted?
  FileSize  : int64;                      // uncompressed size
  CompSize  : int64;                      // compressed file size
  FNLength  : word;                       // file name length
 end;

 TKrKrDirFName = packed record
  Filename  : array[1..1024] of widechar; // wide string. using / for path
 end;

 TKrKrDirSegHdr = packed record
  HDR_Segm   : array[1..4] of char;       // 'segm'
  segmLength : int64;                     // number of segments = segmLength / 28
 end;

 TKrKrDirSeg = packed record
  Compressed : longword;                  // compressed flag
  Offset     : int64;                     // absolute segment offset
  SegSize    : int64;                     // uncompressed segment size
  SegCompSize: int64;                     // compressed segment size
 end;

 TKrKrDirAdler = packed record
  HDR_Adlr : array[1..4] of char;         // 'adlr'
  Check    : longword;                    // always $04
  Dummy    : longword;                    // dummy
  Checksum : longword;                    // adler32 checksum
 end;

 TKrKrDirTime = packed record
  HDR_Time : array[1..4] of char;        // 'time'
  Time     : int64;
 end;

const xp3_kirikiri2_ver = $20110303;

implementation

uses AnimED_Archives;

procedure IA_XP3_KrKr2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KiriKiri2/KAG3';
  Ext  := '.xp3';
  Stat := $0;
  Open := OA_XP3_KrKr2;
  Save := SA_XP3_KrKr2;
  Extr := EA_XP3_KrKr2;
  FLen := 1024;
  SArg := 0;
  Ver  := xp3_kirikiri2_ver;
 end;
end;

procedure IA_XP3_KrKr2C;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KiriKiri2/KAG3 +zlib';
  Ext  := '.xp3';
  Stat := $5;
  Open := OA_Dummy; // in order to skip detection
  Save := SA_XP3_KrKr2;
  Extr := EA_Dummy; // in order to skip detection
  FLen := 1024;
  SArg := 1;
  Ver  := xp3_kirikiri2_ver;
 end;
end;

procedure IA_XP3_KrKr2N;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KiriKiri2/KAG3 New';
  Ext  := '.xp3';
  Stat := $5;
  Open := OA_Dummy; // in order to skip detection
  Save := SA_XP3_KrKr2;
  Extr := EA_Dummy; // in order to skip detection
  FLen := 1024;
  SArg := 2;
  Ver  := xp3_kirikiri2_ver;
 end;
end;

procedure IA_XP3_KrKr2NC;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KiriKiri2/KAG3 New +zlib';
  Ext  := '.xp3';
  Stat := $5;
  Open := OA_Dummy; // in order to skip detection
  Save := SA_XP3_KrKr2;
  Extr := EA_Dummy; // in order to skip detection
  FLen := 1024;
  SArg := 3;
  Ver  := xp3_kirikiri2_ver;
 end;
end;

procedure IA_XP3_KrKr2N2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KiriKiri2/KAG3 New-2';
  Ext  := '.xp3';
  Stat := $5;
  Open := OA_Dummy; // in order to skip detection
  Save := SA_XP3_KrKr2;
  Extr := EA_Dummy; // in order to skip detection
  FLen := 1024;
  SArg := 4;
  Ver  := xp3_kirikiri2_ver;
 end;
end;

procedure IA_XP3_KrKr2N2C;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'KiriKiri2/KAG3 New-2 +zlib';
  Ext  := '.xp3';
  Stat := $5;
  Open := OA_Dummy; // in order to skip detection
  Save := SA_XP3_KrKr2;
  Extr := EA_Dummy; // in order to skip detection
  FLen := 1024;
  SArg := 5;
  Ver  := xp3_kirikiri2_ver;
 end;
end;

function OA_XP3_KrKr2;
{ XP3 archive opening function }
var i,j,s : integer;
    KrKrHeader : TKrKrHeader;
    NewHeader  : TKrKrNewHeader;
    FTHdrCheck : TKrKrFTHdrCheck;
    FTHeader   : TKrKrFTHeader;
    FTHeaderNC : TKrKrFTHeaderNoComp;
    Dir        : TKrKrDir;
    DirFName   : TKrKrDirFName;
    DirSegHdr  : TKrKrDirSegHdr;
    DirSeg     : TKrKrDirSeg;
    DirAdler   : TKrKrDirAdler;
    DirTime    : TKrKrDirTime;
    tmpStreamC,
    tmpStream  : TStream;
    tmpFNWide  : widestring;
begin
 Result := False;

 with ArchiveStream do begin

  with KrKrHeader do begin
   Seek(0,soBeginning);
   Read(KrKrHeader,SizeOf(KrKrHeader));
   // как обычно, проверяем заголовок...
   if Header <> 'XP3'#13#10#32#10#26#139#103#1 then Exit;

   if FTOffset = $17 then begin
    Read(NewHeader,SizeOf(NewHeader));
    FTOffset := NewHeader.FTOffset;
   end;

   Seek(FTOffset,soBeginning); // переходим на начало файловой таблицы
  end;

  Read(FTHdrCheck,SizeOf(FTHdrCheck)); // проверяем, сжата ли файловая таблица

  tmpStream := TMemoryStream.Create;

  case FTHdrCheck.Check of
  
  $0 : begin // читаем несжатый заголовок
        Read(FTHeaderNC,SizeOf(FTHeaderNC)); // читаем заголовок
        // копируем таблицу во временный поток...
        tmpStream.CopyFrom(ArchiveStream,FTHeaderNC.Size);
       end;
      
  $1 : begin // читаем сжатый заголовок
        Read(FTHeader,SizeOf(FTHeader)); // читаем заголовок
        // копируем таблицу во временный поток...
        tmpStreamC := TMemoryStream.Create;
        tmpStreamC.CopyFrom(ArchiveStream,FTHeader.CompSize);
        tmpStreamC.Position := 0;
        // ...и распаковываем
        ZDecompressStream(tmpStreamC, tmpStream);
        FreeAndNil(tmpStreamC);
       end;
  end;
  
  tmpStream.Position := 0;

  // устанавливаем счётчик количества файлов
  i := 0;

  // читаем файловую таблицу...
  while tmpStream.Position < tmpStream.Size do begin
   with tmpStream do begin
    inc(i); // увеличиваем счётчик
    Read(Dir,SizeOf(Dir));
    with Dir, RFA[i] do begin
     // примечание: мета-плагин использует данные из TRFA лишь косвенно.
     // точнее, только имя файла. остальное нужно для корректного
     // отображения в файловой таблице GUI
     // RFA_1 := 0;
     RFA_2 := FileSize;
     RFA_C := CompSize;
     RFA_E := boolean(Encrypted);
     if FileSize <> CompSize then begin
      RFA_Z := True;
      RFA_X := $FF;
     end;
     // работаем с именем файла
     FillChar(DirFName,SizeOf(DirFName),0);
     Read(DirFName,FNLength*2);
     tmpFNWide := '';
     s := 0;
     for j := 1 to FNLength do begin
      // преобразуем слэш в "нормальный", а также избегаем неправильных символов
      case DirFName.Filename[j] of
              '/': tmpFNWide := tmpFNWide + '\';
              '$': begin
                    inc(s);
                    tmpFNWide := tmpFNWide + DirFName.Filename[j];
                   end;
     //  #$0..#$19 : { ничего не делаем };
              else tmpFNWide := tmpFNWide + DirFName.Filename[j];
      end;
     end;
     // преобразуем имя файла в Shift-JIS. да, юникода у нас никогда не было ^^'
     if (s < 6) and (FNLength <> 356) then begin
      RFA_3 := Wide2JIS(tmpFNWide);
     end else RFA_3 := '_XP3_Protection_Dummy.txt';

     //Устанавливаем заголовки для кастомных полей
     with RFA[0] do begin
      SetLength(RFA_T,1);
      SetLength(RFA_T[0],4);
      RFA_T[0][0] := 'Seg isComp';
      RFA_T[0][1] := 'Seg Offset';
      RFA_T[0][2] := 'Seg Size';
      RFA_T[0][3] := 'Seg CompSize';
     end;

     //читаем заголовок сегментов
     Read(DirSegHdr,SizeOf(DirSegHdr));

     // устанавливаем длину для динамического массива с дополнительными полями ^_^
     SetLength(RFA_T,round(DirSegHdr.segmLength / SizeOf(DirSeg)));

     // устанавливаем нужное нам количество полей для массива
     for j := 0 to Length(RFA_T)-1 do SetLength(RFA_T[j],4);

     for j := 1 to round(DirSegHdr.segmLength / SizeOf(DirSeg)) do begin
      Read(DirSeg,SizeOf(DirSeg));
      // присваиваем дополнительные поля
      RFA_T[j-1][0] := inttostr(DirSeg.Compressed);
      RFA_T[j-1][1] := inttostr(DirSeg.Offset);
      RFA_T[j-1][2] := inttostr(DirSeg.SegSize);
      RFA_T[j-1][3] := inttostr(DirSeg.SegCompSize);

      // этим хитрым способом мы указываем оффсет первого блока как оффсет файла. естественно, только для GUI
      if j = 1 then RFA_1 := DirSeg.Offset;
     end;
    end;
    // считываем Adler. просто считываем, он нам здесь нахрен не сдался
    Read(DirAdler,SizeOf(DirAdler));
   end;
  end;

  FreeAndNil(tmpStream);

  RecordsCount := i; // устанавливаем количество файлов

 end;
 // вроде всё...
 Result := True;

end;

function SA_XP3_KrKr2;
var i, j, k : integer;
    KrKrHeader : TKrKrHeader;
    NewHeader  : TKrKrNewHeader;
    FTHdrCheck : TKrKrFTHdrCheck;
    FTHeader   : TKrKrFTHeader;
    FTHeaderNC : TKrKrFTHeaderNoComp;
    Dir        : TKrKrDir;
    DirFName   : TKrKrDirFName;
    DirSegHdr  : TKrKrDirSegHdr;
    DirSeg     : TKrKrDirSeg;
    DirAdler   : TKrKrDirAdler;
    tmpStreamC,
    tmpStream  : TStream;
    ChecksumInt: longint;
    NoCompress, CompMode : boolean;
begin
 with ArchiveStream do begin

  with KrKrHeader do begin
   Header := 'XP3'#13#10#32#10#26#139#103#1;
   FTOffset := 0; // будет просчитан в последнюю очередь ^_^
  end;

  case Mode of
  1,3,5 : CompMode := True;
  0,2,4 : CompMode := False;
  end;

  case Mode of
  0,1 : { ничего не делаем };
  2..5 : begin // генерируем заголовок нового типа
          KrKrHeader.FTOffset := $17;
          with NewHeader do begin
           Check  := $1;
           Check2 := $80;
           FillChar(Dummy,SizeOf(Dummy),0);
           FTOffset := 0; // будет просчитан в последнюю очередь ^_^
          end;
         end;
  end;

  Write(KrKrHeader,SizeOf(KrKrHeader));

  case Mode of
   0,1 : { ничего не делаем };
   2..5 : Write(NewHeader,SizeOf(NewHeader)); // пишем "новый" тип заголовка
  end;

  ReOffset := Size;

 end; //with ArchiveStream

 // формируем файловую таблицу...
 tmpStream := TMemoryStream.Create;

 with tmpStream do begin

  RecordsCount := AddedFilesW.Count;

  for i := 1 to RecordsCount do begin

{*}Progress_Pos(i);
   // открываем файл...
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);

   with Dir do begin
    // пишем в лог
 {*}Progress_Pos(i);

    FNLength := Length(AddedFilesW.Strings[i-1]);

    // присваиваем имя файла
    for j := 1 to FNLength do begin
     // преобразуем слэш
     case AddedFilesW.Strings[i-1][j] of
      '\': DirFName.Filename[j] := '/';
      else DirFName.Filename[j] := AddedFilesW.Strings[i-1][j];
     end;
    end;

    HDR_File   := 'File';
    DirLength  := SizeOf(Dir) - (SizeOf(HDR_File)+SizeOF(DirLength)) + (Length(AddedFilesW.Strings[i-1])*2) + SizeOf(DirSegHdr) + SizeOf(DirSeg) + SizeOf(DirAdler);
    HDR_Info   := 'info';
    InfoLength := 22 + FNLength*2;
    Encrypted  := 0;
    FileSize   := FileDataStream.Size;

    with DirSegHdr do begin
     HDR_segm   := 'segm';
     segmLength := SizeOf(DirSeg);
    end;

    // устанавливаем оффсет сегмента файла здесь
    DirSeg.Offset := ReOffset;

    with DirAdler do begin
     HDR_Adlr := 'adlr';
     Check    := $4;
     Dummy    := 0;
     // инициализируем Adler
     Checksum := sAdler32Init;
    end;

    FileDataStream.Seek(0,soBeginning);
    ChecksumInt := DirAdler.Checksum;
    sAdler32(FileDataStream,ChecksumInt); // adler32 checksum
    DirAdler.Checksum := (ChecksumInt + $0100000000) and $00FFFFFFFF;

    FileDataStream.Seek(0,soBeginning);

    NoCompress := False;
    for k := 0 to CmpExceptList.Count-1 do begin
     if lowercase(ExtractFileExt(DirFName.FileName)) = CmpExceptList.Strings[k] then begin
      NoCompress := True;
      break;
     end;
    end;

    if (not CompMode) or NoCompress then begin // режим 0 - без сжатия
     CompSize := FileSize;
     // пишем файл в архив
     ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
     ReOffset := ReOffset + FileDataStream.Size;
     DirSeg.Compressed := 0;
    end else begin // режим 1 - zlib-сжатие :)
     ZCompressStream(FileDataStream,ArchiveStream); // сжимаем файл и пишем в архив
     CompSize := ArchiveStream.Size - ReOffset;

     ReOffset := ReOffset + CompSize;

     DirSeg.Compressed := 1;

    end;

    with DirSeg do begin
     SegSize := FileSize;
     SegCompSize := CompSize;
    end;

    // пишем всё что нагенерировали ^^;
    Write(Dir,      SizeOf(Dir));
    Write(DirFName, FNLength*2);
    Write(DirSegHdr,SizeOf(DirSegHdr));
    Write(DirSeg,   SizeOf(DirSeg));
    Write(DirAdler, SizeOf(DirAdler));

   end; // with Dir

  end; // for i to...

 end; // with tmpStream

 tmpStream.Seek(0,soBeginning);

 case Mode of
 0..3 : begin
         // сжимаем файловую таблицу
         tmpStreamC := TMemoryStream.Create;
         ZCompressStream(tmpStream,tmpStreamC);
         tmpStreamC.Seek(0,soBeginning);
         // генерируем её заголовок
         FTHdrCheck.Check := $1;
         with FTHeader do begin
          CompSize := tmpStreamC.Size;
          Size     := tmpStream.Size;
         end;
         FreeAndNil(tmpStream);
        end;
 4..5 : begin
         FTHdrCheck.Check := $0;
         FTHeaderNC.Size := tmpStream.Size;
        end;
 end;

 with ArchiveStream do begin

  case Mode of
   0,1 : KrKrHeader.FTOffset := Position;
   2..5 : NewHeader.FTOffset := Position;
  end;

  // пишем заголовок
  Write(FTHdrCheck,SizeOf(FTHdrCheck));

  case Mode of
  0..3 : begin
          Write(FTHeader,SizeOf(FTHeader));
          CopyFrom(tmpStreamC,tmpStreamC.Size);
          FreeAndNil(tmpStreamC);
         end;
  4,5  : begin
          Write(FTHeaderNC,SizeOf(FTHeaderNC));
          CopyFrom(tmpStream,tmpStream.Size);
          FreeAndNil(tmpStream);
         end;
  end;

  Seek(0,soBeginning);

  Write(KrKrHeader,SizeOf(KrKrHeader));

  case Mode of
   0..1 : {ничего не делаем};
   2..5 : Write(NewHeader,SizeOf(NewHeader));
  end;

 end;

 Result := True;

end;

function EA_XP3_KrKr2;
var i : integer;
    tmpStreamC,
    tmpStream  : TStream;
begin
 Result := False;
 for i := 0 to Length(FileRecord.RFA_T)-1 do try
  case boolean(strtoint(FileRecord.RFA_T[i][0])) of
   True : begin
           tmpStreamC := TMemoryStream.Create;
           tmpStream  := TMemoryStream.Create;
           ArchiveStream.Position := strtoint(FileRecord.RFA_T[i][1]);
           tmpStreamC.Size := strtoint(FileRecord.RFA_T[i][3]);
           tmpStreamC.CopyFrom(ArchiveStream,strtoint(FileRecord.RFA_T[i][3]));
           tmpStreamC.Position := 0;

           ZDecompressStream(tmpStreamC,tmpStream);

           tmpStream.Position := 0;
           FileDataStream.CopyFrom(tmpStream,tmpStream.Size);

           FreeAndNil(tmpStream);
           FreeAndNil(tmpStreamC);           
          end;
  False : begin
           ArchiveStream.Position := strtoint(FileRecord.RFA_T[i][1]);
           FileDataStream.CopyFrom(ArchiveStream,strtoint(FileRecord.RFA_T[i][2]));
          end;
  end;
  Result := True;

 except
  { улыбаемся и машем }
 end;
end;

end.