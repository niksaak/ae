unit FileStreamJ;

                              {

  TFileStream :: ShiftJIS mod
  

    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          19.06.09
                              }

interface

uses                                   
  Classes, Windows, SysUtils;

type
  TFileStreamJ = class (TFileStream)
  public
    function JIS2Wide(S: PAnsiChar): PWideChar;
    constructor Create(const FileName: String; Mode: Word); overload;
    constructor Create(const FileName: WideString; Mode: Word); overload;
  end;

implementation

// SysUtils.pas: 4788
function FileOpenW(const FileName: WideString; Mode: LongWord): Integer;
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := -1;
  if ((Mode and 3) <= $02) and
    ((Mode and $F0) <= $40) then
    Result := Integer(CreateFileW(PWideChar(FileName), AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0));
end;

// SysUtils.pas: 4853
function FileCreateW(const FileName: WideString): Integer;
begin
  Result := Integer(CreateFileW(PWideChar(FileName), GENERIC_READ or GENERIC_WRITE,
    0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0));
end;


function TFileStreamJ.JIS2Wide;
var
  BufSize: DWord;
begin                                                           
  BufSize := MultiByteToWideChar(932, 0, S, -1, NIL, 0) * 2;
  GetMem(Result, BufSize);
  MultiByteToWideChar(932, 0, S, -1, Result, BufSize)
end;

constructor TFileStreamJ.Create(const FileName: String; Mode: Word);
var
  FN: PWideChar;
begin
  FN := JIS2Wide(PChar(FileName));
  try
    Create(WideString(FN), Mode)
  finally
    FreeMem(FN, lstrlenw(FN) * 2 + 2)
  end
end;              

constructor TFileStreamJ.Create(const FileName: WideString; Mode: Word);
begin
  if Mode = fmCreate then
  begin
    inherited Create(FileCreateW(FileName));
    if FHandle < 0 then
      raise EFCreateError.CreateFmt('TFileStreamJ: Cannot create file "%s". %s', [ExpandFileName(FileName), SysErrorMessage(GetLastError)])
  end
    else
    begin
      inherited Create(FileOpenW(FileName, Mode));
      if FHandle < 0 then
        raise EFOpenError.CreateFmt('TFileStreamJ: Cannot open file "%s". %s', [ExpandFileName(FileName), SysErrorMessage(GetLastError)])
    end
end;

end.
