{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.
  
  Tech-Arts EAGLS Encrypted Bitmap Image Format library

  Written by dsp2003 & Nik.
}

unit AG_EAGLS;

interface

uses Classes, SysUtils,
     Generic_LZXX,
     AG_Portable_Network_Graphics,
     AG_Fundamental,
     AG_StdFmt,
     AG_RFI;

function Import_EAGLS(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
procedure IG_EAGLS(var ImFormat : TImageFormats);

function GRDecrypt(Input, Output : TStream; key : byte; compkey : int64; DecryptKey : string) : boolean;

type
  KeyArrType = array[0..1] of int64;

implementation

uses AnimED_Graphics;

const EngineKey = 'EAGLS_SYSTEM';
      // ключ - три числа
      //Mono Gokoro Mono Musu me  -   $0E BC8F 5E4789C9
      //Henshin Ni!2   -   $10 41A7 834E0B5F
      Keys : KeyArrType = ($0EBC8F5E4789C9,
                           $1041A7834E0B5F);
                           
procedure IG_EAGLS;
begin
 with ImFormat do begin
  Name := '[   ] Tech-Arts EAGLS';
  Ext  := '';
  Stat := $F;
  Open := Import_EAGLS;
  Save := nil;
  Ver  := $20100311;
 end;
end;

function Import_EAGLS(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
var RFI : TRFI;
    tmpStream, tmpStream2 : TStream;
    key : byte;
    BMWord, i : word;
    DecrSucc : boolean;
label NoCrypt;
begin
 RFI.Valid := False;

 with InputStream do begin
  Seek(0,soBeginning);

  tmpStream := TMemoryStream.Create;

  InputStream.Position := 1;
  InputStream.Read(BMWord,2);

  InputStream.Position := 0;

  tmpStream.CopyFrom(InputStream,InputStream.Size);
  InputStream.Seek(-1,soCurrent);
  InputStream.Read(key,1); // читаем байт-ключ

  tmpStream.Position := 0;

  tmpStream2 := TMemoryStream.Create;

  if BMWord = $4D42 then goto NoCrypt;
{
  if not GRDecrypt(tmpStream,tmpStream2,key,Henshin2Key,EngineKey) then
   if not GRDecrypt(tmpStream,tmpStream2,key,MonoMonoKey,EngineKey) then Exit;}

  for i := 1 to Length(Keys) do
  begin
    tmpStream.Position := 0;
    tmpStream2.Position := 0;
    DecrSucc := GRDecrypt(tmpStream,tmpStream2,key,Keys[i-1],EngineKey);
    if DecrSucc then Break;
  end;
  if not DecrSucc then begin
   FreeAndNil(tmpStream);
   FreeAndNil(tmpStream2);
   Exit;
  end;

  tmpStream.Position := 0;
  tmpStream2.Position := 0;

  { DEBUG }
{  fStream := TFileStream.Create('C:\TEMP\eagls_decoded_1.bin',fmCreate);
  fStream.CopyFrom(tmpStream2,tmpStream2.Size);
  FreeAndNil(fStream);

  fStream := TFileStream.Create('C:\TEMP\eagls_decoded_2.bin',fmCreate);
  fStream.CopyFrom(tmpStream,tmpStream.Size);
  FreeAndNil(fStream);

  tmpStream.Position := 0;
  tmpStream2.Position := 0;}
  { END OF DEBUG }

  tmpStream.CopyFrom(tmpStream2,tmpStream2.Size);
  tmpStream.Position := 0;

  tmpStream2.Size := 0;

NoCrypt:

  GLZSSDecode(tmpStream,tmpStream2,tmpStream.Size,$FEE,$FFF);

  FreeAndNil(tmpStream);

  tmpStream2.Position := 0;

  { DEBUG }
{  fStream := TFileStream.Create('C:\TEMP\eagls_decoded_3.bin',fmCreate);
  fStream.CopyFrom(tmpStream2,tmpStream2.Size);
  FreeAndNil(fStream);

  tmpStream2.Position := 0; }
  { END OF DEBUG }

  RFI := Import_BMP(tmpStream2,OutputStream,OutputStreamA);

  FreeAndNil(tmpStream2);
 end;

 Result := RFI;
end;

// key - последний байт файла
function GRDecrypt;
var i, klen, bmulkey : longword;
    w64 : int64;
    longkey, wi : integer;
    bt, btkey, shkey : byte;
    flo : double;
    BMWord, lmulkey : word;
begin
  Result := false;
  bmulkey := longword(compkey and $FFFFFFFF);
  compkey := compkey shr $20;
  lmulkey := Word(compkey and $FFFF);
  compkey := compkey shr $10;
  shkey := Byte(compkey and $FF);
  klen := Length(DecryptKey);
//  longkey := key xor $75BD924  - mono gokoro mono musu me
//                     $834E0B5F - henshin 2
  longkey := key xor $075BD924;
  for i := 1 to $174B do begin
   Input.Read(bt,1);
   w64 := bmulkey * Int64(longkey);
   longkey := longkey * lmulkey;
   if w64 >= 0 then wi := (Integer(w64 shr $20) shr shkey) * $7FFFFFFF
   else wi := (1 - (Integer(Abs(w64) shr $20) shr shkey)) * $7FFFFFFF;

   longkey := longkey - wi;
   if longkey < 0 then longkey := longkey + $7FFFFFFF;

   flo := longkey;

   flo := flo * 256 * 4.656612875245794e-10;
   btkey := Byte(Trunc(flo)) mod klen;
   if btkey < klen then bt := bt xor Byte(DecryptKey[btkey+1]);
   Output.Write(bt,1);
   if i = 3 then
   begin
     Output.Position := 1;
     Output.Read(BMWord,2);
     if BMWord <> $4D42 then Exit;
   end;
  end;
  Result := true;
end;

end.