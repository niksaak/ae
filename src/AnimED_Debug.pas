{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Debug functions module
  Written by dsp2003.
}
unit AnimED_Debug;

interface

uses Classes, SysUtils, FileStreamJ, AnimED_Console;

procedure DumpStream(iStream : TStream; TempName : widestring; SetToZero : boolean = True);

implementation

procedure DumpStream;
var tmpStream : TStream;
    iOrigin, iSize : integer;
begin
 try
  tmpStream := TFileStreamJ.Create(TempName,fmCreate);
  iSize := iStream.Size;
  iOrigin := iStream.Position;
  case SetToZero of
   False : begin
            tmpStream.CopyFrom(iStream,iSize - iOrigin);
            iStream.Position := iOrigin;
           end;
   True  : begin
            iStream.Position := 0;
            tmpStream.CopyFrom(iStream,iSize);
            iStream.Position := 0;
           end;
  end;
  FreeAndNil(tmpStream);
 except
  LogE('Dumping stream into '+TempName+' has been failed. T_T');
 end;

end;

end.