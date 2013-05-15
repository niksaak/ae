unit JReconvertor;

{ JReconvertor encodings unit
  by Proger_XP
  www.solelo.com/p4s
  mailme -@- smtp.ru
  20.06.09                   }

interface

uses Windows;

const
 CP_ANSI     = CP_ACP;
 CP_OEM      = CP_OEMCP;
 CP_SHIFTJIS = 932;

function Ansi2Wide(Ansi: String): WideString;
function JIS2Wide(ShiftJIS: String): WideString;

function Ansi2JIS(Ansi: String): String;
function JIS2Ansi(ShiftJIS: String): String;

function Wide2Ansi(Wide: WideString): String;
function Wide2JIS (Wide: WideString): String;

function WideSizeInBytes(Wide: String): Word;
function GetMinimumBufSize(SrcCodepage: DWord; Str: String): DWord; overload;
function GetMinimumBufSize(DestCodepage: DWord; Wide: WideString): DWord; overload;

function ToWide(SrcCodepage: DWord; Str: String; BufSIze: Integer = -1): WideString;
function FromWide(DestCodepage: DWord; Str: WideString; BufSIze: Integer = -1): String;

implementation

//var

function WideSizeInBytes;
begin
 { wide char is 2 bytes long + 2 bytes for two terminating #0-charas }
 Result := Length(Wide) * 2 + 2
end;

function GetMinimumBufSize(SrcCodepage: DWord; Str: String): DWord;
begin
 Result := MultiByteToWideChar(SrcCodepage, 0, PChar(Str), -1, NIL, 0)
end;

function GetMinimumBufSize(DestCodepage: DWord; Wide: WideString): DWord;
begin
 Result := WideCharToMultiByte(DestCodepage, 0, PWideChar(Wide), -1, NIL, 0, NIL, NIL)
end;

function ToWide;
begin
 if BufSize = -1 then
    BufSize := GetMinimumBufSize(SrcCodepage, Str);
 SetLength(Result, BufSIze * 2);
 MultiByteToWideChar(SrcCodepage, 0, PChar(Str), -1, PWideChar(Result), BufSIze);
 SetLength(Result, BufSize - 1)
end;

function FromWide;
begin
 if BufSize = -1 then
    BufSize := GetMinimumBufSize(DestCodepage, Str);
 SetLength(Result, BufSIze);
 WideCharToMultiByte(DestCodepage, 0, PWideChar(Str), -1, PChar(Result), BufSIze, NIL, NIL);
 SetLength(Result, BufSize - 1)
end;

function Ansi2Wide;
begin
 Result := ToWide(CP_ANSI, Ansi)
end;

function JIS2Wide;
begin
 Result := ToWide(CP_SHIFTJIS, ShiftJIS)
end;

function Ansi2JIS;
var Wide: WIdeString;
begin
 Wide := Ansi2Wide(Ansi);
 Result := Wide2JIS(Wide)
end;

function JIS2Ansi;
var Wide: WIdeString;
begin
 Wide := JIS2Wide(ShiftJIS);
 Result := Wide2JIS(Wide)
end;

function Wide2Ansi;
begin
 Result := FromWide(CP_ANSI, Wide)
end;

function Wide2JIS;
begin
 Result := FromWide(CP_SHIFTJIS, Wide)
end;

end.