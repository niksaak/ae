{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Audio stream formats and functions

  Written by dsp2003.
}

unit AS_Audio;

interface

uses Generic_DC,
     SysUtils, Classes, Windows, Forms;

var AC_ID        : integer; // Format identifier (unique)
    AC_IDS       : string; // Format identifier string

    IACFunctions : array of TIDCFunction;
    ACFormats    : array of TDCFormats;

    ACFormatsCount : integer;

    FileDataStream : TStream;

    ArchiveFileName : widestring;

implementation

uses AnimED_Main;

procedure AC_Flush;
var i, j : integer;
begin
 RecordsCount := 0;
 RFA_ID := -1;
 RFA_IDS := '';
 { clearing additional fields }
 for i := 0 to $FFFF do begin
 // freeing memory
  for j := 0 to Length(RFA[i].RFA_T)-1 do SetLength(RFA[i].RFA_T[j],0);
  SetLength(RFA[i].RFA_T,0);
 end;

 FillChar(RFA,SizeOf(RFA),0);
end;

end.