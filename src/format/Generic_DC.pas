{
  AED - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Generic: Direct Conversion internal structures and functions.

  Written by dsp2003.
}

unit Generic_DC;

interface

uses Classes;

type
 TDCFunction = function(iStream, oStream : TStream) : boolean;

 TDCFormats = packed record
  ID     : integer;
  IDSIn  : string;     // Описание формата входного файла
  IDSOut : string;     // Описание формата выходного файла
  ExtIn  : string;     // Расширение входного файла
  ExtOut : string;     // Расширение выходного файла
  Save   : TDCFunction; // Указатель на функцию преобразования данных
  Ver    : integer;     // Версия конвертера в виде числа $годМЕСЯЦдень. например, $20091231
 end;

 TIDCFunction = procedure(var DCF : TDCFormats; i : integer);

implementation

end.