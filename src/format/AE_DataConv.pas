{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  An attempt to rewrite data conversion unit... \('~')_

  To-do: move the most of AE_Math.pas code here

  Written by dsp2003.
}
unit AE_DataConv;

interface

uses Classes, SysUtils;

procedure DataConv_BXORK(iStream, oStream, kStream : TStream; iPos, iSize, oPos, oSize : int64);

implementation

procedure DataConv_BXORK;
var Key : array of byte;
    i,j,k,l,LastChunk,XorKey : longword;
begin
 iStream.Seek(iPos,soBeginning);
 oStream.Seek(oPos,soBeginning);

 with kStream do begin
  Seek(0,soBeginning);
  // устанавливаем длину ключа
  SetLength(Key,Size);
  // читаем зацикленный ключ в память
  Read(Key[0],Size);
 end;

 LastChunk := iSize mod 4;
 
 i := 0;

 for j := 1 to (iSize div 4) do begin
  xorkey := 0; // сбрасываем мини-ключ
  for k := 0 to 3 do begin
   xorkey := xorkey + Key[i] shl (k*8);
   inc(i);
   if i > Length(Key)-1 then i := i - Length(Key);
  end;
  iStream.Read(l,4);
  l := l xor xorkey;
  oStream.Write(l,4);
 end;

 if LastChunk > 0 then begin
  xorkey := 0; // сбрасываем мини-ключ
  for k := 0 to LastChunk-1 do begin
   xorkey := xorkey + Key[i] shl (k*8);
   inc(i);
   if i > Length(Key)-1 then i := i - Length(Key);
  end; 
  iStream.Read(l,LastChunk);
  l := l xor xorkey;
  oStream.Write(l,LastChunk);
 end;
 
end;

end.