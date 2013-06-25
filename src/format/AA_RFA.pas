{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  RealFileAttributes (table) aka RFA(T) internal format & functions

  Written by dsp2003.
}

unit AA_RFA;

interface

uses AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Translation,
     AnimED_Translation_Strings,
     Generic_LZXX,
     SysUtils, Classes, Windows, Forms,
     FileStreamJ, JReconvertor;

type
{ RealFileAttributes record - internal universal AnimED archive type.
  Added for flexibility... :) }

 TRFA = packed record
  RFA_1 : cardinal; // File offset
  RFA_2 : cardinal; // File size (uncompressed)
  RFA_3 : string;   // File name
  RFA_C : cardinal; // Compressed file size
  RFA_E : boolean;  // Encryption flag
  RFA_Z : boolean;  // Compression flag
  RFA_X : byte;     // Compression type or XOR value ($0 - none, $FE - bzip2, $FF - zlib)
  RFA_N : array of array of int64;  // Additional fields (8 byte each)
  RFA_T : array of array of string; // Additional fields
 end;

// TSFmt = array of string; // Тип массива субформатов

 TOAFunction = function : boolean;
 TSAFunction = function(Mode : integer) : boolean;
 TEAFunction = function(FileRecord : TRFA) : boolean;

 TArcFormats = packed record
  ID   : integer; // Цифровой идентификатор формата. Генерируется автоматически
  IDS  : string;  // "Формат" - Текстовая строка с названием формата архива и\или движка
//  Name : string;  // "[DAT] Формат" - То же самое, только в версии для селектора формата
  Ext  : string;  // ".dat" - расширение файла. Максимум - 5 символов
  Stat : byte;    // Статус формата. Может быть:
                  //  $0 - обычный формат. работает чтение\запись
                  //  $1 - рекомендуется обратиться к руководству пользователя, поскольку для
                  //       работы с данным форматом требуется придерживаться определённых правил
                  //  $2 - экспериментальный\незавершённый формат, может создавать нерабочие файлы
                  //  $3 - формат-хак, предназначенный для работы с каким-то особым вариантом "настоящего"
                  //       формата (например, заточенный для конкретного случая), и непригоден для "обычных"
                  //  $5 - формат, предназначенный только для записи
                  //  $9 - формат-заглушка. не работает ни нормальное чтение, ни запись (возможна
                  //       генерация временных\отладочных файлов)
                  //  $F - формат только для чтения
//  SFmt : TSFmt;   // Массив субформатов (добавлено в 0.6.8.413)
  Open : TOAFunction; // Указатель на функцию открытия архива
  Save : TSAFunction; // Указатель на функцию сохранения архива
  Extr : TEAFunction; // Указатель на фунецию распаковки архива
  FLen : word;        // Максимальная длина имени файла для формата архива
  SArg : integer;     // Аргумент для функции сохранения архива. используется, когда в единой функции совмещено
                      // более одного под-формата
  Ver  : integer;     // Версия формата в виде числа $годМЕСЯЦдень. например, $20091231
//  By   : string;      // Информация об авторе
 end;

 TIAFunction = procedure(var AF : TArcFormats; i : integer);

function EA_RAW(FileRecord : TRFA) : boolean;
function EA_LZSS_FEE_FFF(FileRecord : TRFA) : boolean;

{ for handling unsupported and read-only/write-only archives }
procedure IA_Unsupported(var ArcFormat : TArcFormats; index : integer);
function OA_Unsupported : boolean;
function SA_Unsupported(Mode : integer) : boolean;

function OA_Dummy : boolean;
function SA_Dummy(Mode : integer) : boolean;
function EA_Dummy(FileRecord : TRFA) : boolean;

procedure OpenFileStream(var Stream : TStream; FileName : widestring; Mode : word = fmOpenRead; LogMe : boolean = True); overload;
procedure OpenFileStream(var Stream : TStream; FilePath : widestring; FileName : string; Mode : word = fmOpenRead; LogMe : boolean = True); overload;

procedure RFA_Flush;

procedure TruncFNCheck(FileName : string; Size : integer);

//procedure SFmtAdd(SFmt : TSFmt; Fmt : string);

var RFA_ID          : integer; // Format identifier (unique)
    RFA_IDS         : string; // Format identifier string
//  RFA             : array[0..$FFFF] of TRFA; // FAT array
    RFA             : array of TRFA; // FAT array

    IAFunctions     : array of TIAFunction;
    ArcFormats      : array of TArcFormats;

    ArcFormatsCount : integer;

    FileDataStream, ArchiveStream : TStream;
    RecordsCount, ReOffset, UpOffset : longword;
    GlobalOffset    : int64;

    ArchiveFileName : widestring;

{ Compression types }
const acNone    = $00; // None
      acNSASPB  = $01; // nScripter SPBitmap
      acNSALZSS = $02; // nScripter LZSS
      acUnknown = $7F; // Any unknown / custom type
      acBGICBM  = $CB; // BGI Compressed BG
      acBGIDSC  = $DC; // BGI DSC 1.00
      acLZSS    = $FD; // LZSS or alike
      acBZip2   = $FE; // BZip2
      acZlib    = $FF; // Zlib or PKZip

{ Archive stats constant array }
      ArcStat : array [0..$F] of string = ('Normal','ReadMe','Buggy','Hack','4','Write-Only','6','7','8','Dummy','A','B','C','D','E','Read-only');
      ArcSymbol : array [0..$F] of char = ('+',     '*',     '!',    '#',   '4','>',         '6','7','8',' ',    'A','B','C','D','E','-'        );

implementation

uses AnimED_Archives, AnimED_Main;

{procedure SFmtAdd;
begin
 SetLength(SFmt,Length(SFmt)+1);
 SFmt[Length(SFmt)-1] := Fmt;
end;}

procedure OpenFileStream(var Stream : TStream; FileName : widestring; Mode : word = fmOpenRead; LogMe : boolean = True); overload;
var msg : widestring;
begin
 case Mode of
  fmOpenRead      : msg := AMS[OImport];
  fmOpenReadWrite : msg := AMS[OOpening];
  fmCreate        : msg := AMS[OSaving];
 end;
 if LogMe then LogS(msg+' '+FileName);
 Stream := TFileStreamJ.Create(FileName,Mode);
end;

procedure OpenFileStream(var Stream : TStream; FilePath : widestring; FileName : string; Mode : word = fmOpenRead; LogMe : boolean = True); overload;
var msg : widestring;
begin
 case Mode of
  fmOpenRead      : msg := AMS[OImport];
  fmOpenReadWrite : msg := AMS[OOpening];
  fmCreate        : msg := AMS[OSaving];
 end;
 if LogMe then LogS(msg+' '+FileName);
 Stream := TFileStreamJ.Create(FilePath+JIS2Wide(FileName),Mode);
end;

procedure TruncFNCheck;
begin
 if length(FileName) > Size then LogW(FileName+' > '+inttostr(Size)+AMS[ATruncatedFileName]);
end;

procedure RFA_Flush;
var i, j : integer;
begin
 if Length(RFA) > 0 then begin
  RecordsCount := 0;
  GlobalOffset := 0;
  RFA_ID := -1;
  RFA_IDS := '';
  { clearing additional fields }
  for i := 0 to $FFFF do begin
  // freeing memory
   for j := 0 to Length(RFA[i].RFA_T)-1 do if Length(RFA[i].RFA_T[j]) > 0 then SetLength(RFA[i].RFA_T[j],0);
   if Length(RFA[i].RFA_T) > 0 then SetLength(RFA[i].RFA_T,0);
   for j := 0 to Length(RFA[i].RFA_N)-1 do if Length(RFA[i].RFA_N[j]) > 0 then SetLength(RFA[i].RFA_N[j],0);
   if Length(RFA[i].RFA_N) > 0 then SetLength(RFA[i].RFA_N,0);
  end;
  SetLength(RFA,0);
 end;

 SetLength(RFA,$10000);

// FillChar(RFA,SizeOf(RFA),0);
end;

{ Эта функция распаковывает несжатые, либо зашифрованные по алгоритму XOR файлы.
  Её полное название ExtractArchive_RAW, бывшая Extract_ReadArchiveAndWriteStream }
function EA_RAW;
var TempoStream : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then begin
  // fixes zero-length files extraction
  if (FileRecord.RFA_C > 0) and (FileRecord.RFA_1 <= ArchiveStream.Size) then begin
   ArchiveStream.Position := FileRecord.RFA_1;
   FileDataStream.Size := FileRecord.RFA_C; // file fragmentation fix
   FileDataStream.Position := 0;
   case FileRecord.RFA_E of
  { Explaination: since 0.6.3.345, RFA_C contains actual filesize }
    True: begin
           TempoStream := TMemoryStream.Create;
//           TempoStream.Size := FileRecord.RFA_C;
           TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
           TempoStream.Position := 0;

           // Speeding up the code ^_^
           BlockXOR(TempoStream,FileRecord.RFA_X);

           TempoStream.Position := 0;
           FileDataStream.CopyFrom(TempoStream,TempoStream.Size);
           FreeAndNil(TempoStream);
          end;
  { File is not encrypted... }
    False: FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
   end;
  end;
 end else raise Exception.Create('Debug: internal error. ArchiveStream or FileDataStream is NIL.');
 Result := True;
end;

function EA_LZSS_FEE_FFF;
var tmpStream : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_Z of
   True  : begin
            tmpStream := TMemoryStream.Create;
            GLZSSDecode(ArchiveStream,tmpStream,FileRecord.RFA_C,$FEE,$FFF);

            tmpStream.Seek(0,soBeginning);
            FileDataStream.CopyFrom(tmpStream,tmpStream.Size);
            FreeAndNil(tmpStream);

           end;
   False : FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  end;
  Result := True;
 except
 end;
end;

procedure IA_Unsupported;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Dummy - normally, you should not see this';
  Ext  := '.dbg';
  Stat := $9;
//  SFmtAdd(SFmt,'Test');
  Open := OA_Unsupported;
  Save := SA_Unsupported;
  Extr := EA_RAW;
  SArg := 0;
 end;
end;

function OA_Dummy;
begin
 Result := False;
end;

function SA_Dummy;
begin
 Result := False;
end;

function EA_Dummy;
begin
 Result := False;
end;

function OA_Unsupported;
var ASig : array[0..3] of char; ArFor : string;
begin
 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(ASig,4);
  if ASig = 'Rar!' then ArFor := 'WinRAR archive' else
   if (ASig[0]+ASig[1]) = '7z' then ArFor := '7-Zip archive' else
    if (ASig[0]+ASig[1]) = 'PK' then ArFor := 'PKZip archive' else
     if (ASig[0]+ASig[1]) = 'MZ' then  ArFor := 'MS-DOS, OS/2 or Win32 executable or library' else
      if (ASig[1]+ASig[2]+ASig[3]) = 'ELF' then ArFor := 'Executable Linux File or library' else
       if ASig = 'RIFF' then ArFor := 'Electronic Arts Interchange File Format' else ArFor := '';
 end;

 if ArFor <> '' then LogE('Sorry, but you cannot open '+ArFor+' with this application.') else LogE(AMS[EArchiveIsBroken]);
 Result := False;
 RFA_IDS := AMS[AUnknownFormat];
 FreeAndNil(ArchiveStream);
end;

function SA_Unsupported;
 { "Dummy" archive creation function }
begin
 LogE(AMS[EUnsupportedOutFormat]);
 Result := True;
 FreeAndNil(ArchiveStream);
end;

end.