{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Image Format library

  Written by dsp2003.
}

unit AG_RFI;

interface

uses AG_Fundamental, Classes, SysUtils;

type

{ TRFI = packed record
  Width     : longword; // Image Width
  Height    : longword; // Image Height
  BitDepth  : byte;     // Stream bitdepth (can be 32,24,16,8,4,2,1. If 32 and BitDepthA = 0 - contains alpha)
  BitDepthA : byte;     // Alpha stream bitdepth (can be 8,4,2,0. If 0 - no alpha in secondary stream)
  X         : longword; // X coordinate
  Y         : longword; // Y coordinate
  RWidth    : longword; // Extra width
  RHeight   : longword; // Extra height
  Palette   : TPalette; // 4*256
 end;}


 TRFI = packed record
  RealWidth    : word;     // Image width
  RealHeight   : word;     // Image height
  BitDepth     : word;     // Bitdepth -- if > 8 then Palette is not used
  ExtAlpha     : boolean;  // Uses external alpha or not
  X            : word;     // Coordinate X extra
  Y            : word;     // Coordinate Y extra
  RenderWidth  : word;     // Extra width
  RenderHeight : word;     // Extra height
  Palette      : TPalette; // 4*256
//  FormatID     : string;   // Keeps here info about the input image format for GUI
//  Comment      : array[0..255] of char; // Keeps here internal file commentary
                                      // (not supported by the most of formats)
  Valid        : boolean;  // Used as return value of the functions
 end;

 TImageBuf = packed record
  Image : TStream;
  Alpha : TStream;
  ImAttrib : TRFI;
 end;

TOGFunction = function(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
TSGFunction = function(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;

 TImageFormats = packed record
//  ID   : integer;
//  IDS  : string;
  Name : string;  // "[DAT] Формат" - То же самое, только в версии для селектора формата
  Ext  : string;  // ".dat" - расширение файла. Максимум - 5 символов
  Stat : byte;    // Статус формата. Может быть:
                  //  $0 - обычный формат. работает чтение\запись
                  //  $1 - рекомендуется обратиться к руководству пользователя, поскольку для
                  //       работы с данным форматом требуется придерживаться определённых правил
                  //  $2 - экспериментальный\незавершённый формат
                  //  $9 - формат-заглушка. не работает ни нормальное чтение, ни запись (возможна
                  //       генерация временных\отладочных файлов)
                  //  $F - формат только для чтения
  Open : TOGFunction; // Указатель на функцию открытия изображения
  Save : TSGFunction; // Указатель на функцию сохранения изображения
  Ver  : integer;     // Версия формата в виде числа $годМЕСЯЦдень. например, $20091231
 end;

TIGFunction = procedure(var ImFormat : TImageFormats);

var
 ImageBuffer : array of TImageBuf;
 OpenedImageName : string; // путь до открытого изображения
 SavingImageName : string; // путь до сохраняемого изображения

{ Helper procedure for ImageBuffer initialisation }
procedure RFI_Init(NumOfImages : integer);

{ Helper procedure for RFI cleanup }
procedure RFI_Clear(var RFI : TRFI);

implementation

procedure RFI_Init;
var i : integer;
begin
 SetLength(ImageBuffer,NumOfImages);
 for i := 0 to NumOfImages-1 do begin
  with ImageBuffer[i] do begin
   Image := TMemoryStream.Create;
   Alpha := TMemoryStream.Create;
  end;
 end;
end;

procedure RFI_Clear;
var i : integer;
begin
 FillChar(RFI,SizeOf(RFI),0);
 for i := 0 to length(ImageBuffer)-1 do try
  FillChar(ImageBuffer[i].ImAttrib,SizeOf(ImageBuffer[i].ImAttrib),0);
  FreeAndNil(ImageBuffer[i].Image);
  FreeAndNil(ImageBuffer[i].Alpha);
 except
 end;
 SetLength(ImageBuffer,0);
end;

end.