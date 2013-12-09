{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  CEL Image Format library
  
  Format specifications contributed by Nik.

  Written by dsp2003.
}

unit AG_CEL;

interface

uses Classes, Sysutils, IniFiles,
     AnimED_Math,
     AG_Fundamental,
     AnimED_Console,
     Generic_LZXX,
     AG_RFI;

{
CP10
ENTR
...
ENTR
выравнивание
ANIM
...
ANIM
выравнивание
IMAG
Image
выравнивание
IMAG
Image
выравнивание
...
ENDC
}

type
 TCEL_CP10 = packed record
  Header          : array[1..4] of char; // CP10
  Dummy1          : longword; // 0x00000000
  ENTRQty         : word;     // count of ENTR entries
  ANIMQty         : word;     // count of ANIM entries
  IMAGQty         : word;     // count of IMAG entries
  Dummy2          : word;     // 0x0000
  Length          : longword; // (Length of cel) - 0x18
  Unknown         : longword;
 end;

 TCEL_ENTR = packed record
  Header          : array[1..4] of char; // ENTR
  OffsetNextEntry : longword;
  Number1         : longword;
  Number2         : longword; // Number1 xor $FFFF0000
  Unk1            : longword;
  xShift          : word;
  yShift          : word;
  xStretch        : longword; // use only small word
  yStretch        : longword; // use only small word
  Dummy5          : longword; // 0x00000000
  Dummy6          : longword; // 0xFFFFFFFF
  Unk2            : longword; // 0xBF000000
 end;

 TCEL_ANIM_INIT = packed record
  Header          : array[1..4] of char; // ANIM
  OffsetNextEntry : longword;
  Number          : longword;
  Unknown         : longword; //0x00000000
  NumberOfActions : longword;
 end;

 TCEL_ANIM_ACTION = packed record
  Action          : word;
  Value           : word;
 end;

 TCEL_IMAG = packed record
  Header          : array[1..4] of char; // IMAG
  OffsetNextEntry : longword;
  Number1         : longword; // порядковый номер изображения, начиная с нуля
  XDimension      : word;     // Width
  YDimension      : word;     // Height
  BitDepthFlag    : longword; // 7 - 32, 5 - 8+palette
  unk2            : longword; // 0x00000000
  CompFlag        : longword; // compression flag (1 = compressed, 0 = uncompressed)
  ImageLength     : longword;
 end;

 TCEL_LZ = packed record
  Header          : array[1..2] of char; // LZ
  UnpackedLength  : longword; // Big-endian
  Packedlength    : longword; // Big-endian
 end;

 TCEL_ENDC = packed record
  Header          : array[1..4] of char; // ENDC
  celLength       : longword;
 end;

{ Aoi Shiro CEL LZ decoding function -- alpha_test }
function CEL_LZDecoder(IStream, OStream : TStream; CryptLength : integer) : boolean;
function CEL_LZEncoder(IStream, OStream : TStream) : boolean;

function Import_CEL(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
procedure IG_CEL(var ImFormat : TImageFormats);

implementation

procedure IG_CEL;
begin
 with ImFormat do begin
  Name := '[CEL] Success Image';
  Ext  := '.cel';
  Stat := $F;
  Open := Import_CEL;
  Save := nil;
  Ver  := $20100311;
 end;
end;

{ Формат CEL использует довольно мудрёный способ представления данных. }
function Import_CEL;
var i,j : integer;
    RFI : TRFI;
    CEL_Header : TCEL_CP10;
    CEL_ENTR   : array of TCEL_ENTR;
    CEL_ANIM   : array of TCEL_ANIM_INIT;
    CEL_ANIMA  : array of array of TCEL_ANIM_ACTION;
    CEL_IMAG   : array of TCEL_IMAG;
    CEL_LZ     : TCEL_LZ;
    CEL_ENDC   : TCEL_ENDC;
    TempoStream : TStream;
    TempoStream2 : TStream;
label StopThis;
begin
// RFI.Valid := False;
 with CEL_Header, InputStream do begin
  Seek(0,soBeginning);
  Read(CEL_Header,SizeOf(CEL_Header));
  if Header <> 'CP10' then goto StopThis;

  SetLength(CEL_ENTR,ENTRQty);
  SetLength(CEL_ANIM,ANIMQty);
  SetLength(CEL_ANIMA,ANIMQty);
  SetLength(CEL_IMAG,IMAGQty);

/////////////////////////////////////////////////////////////////////////////////////////
  RFI_Init(IMAGQty); // Устанавливаем кол-во слотов в буфере для изображений
/////////////////////////////////////////////////////////////////////////////////////////

  for i := 0 to ENTRQty-1 do begin
   Read(CEL_ENTR[i],SizeOf(CEL_ENTR[i]));
   Seek(CEL_ENTR[i].OffsetNextEntry,soBeginning);
  end;

  for i := 0 to ANIMQty-1 do begin
   Read(CEL_ANIM[i],SizeOf(CEL_ANIM[i]));
   SetLength(CEL_ANIMA[i],CEL_ANIM[i].NumberOfActions);
   for j := 0 to CEL_ANIM[i].NumberOfActions-1 do begin
    Read(CEL_ANIMA[i][j],SizeOf(CEL_ANIMA[i][j]));
   end;
   Seek(CEL_ANIM[i].OffsetNextEntry,soBeginning);
  end;

  TempoStream := TMemoryStream.Create;

  for i := 0 to IMAGQty-1 do begin
   Read(CEL_IMAG[i],SizeOf(CEL_IMAG[i]));

   LogD(CEL_IMAG[i].Header+'|'+inttostr(CEL_IMAG[i].OffsetNextEntry)+'|'+inttostr(CEL_IMAG[i].Number1)+'|'+inttostr(CEL_IMAG[i].XDimension)+'x'+inttostr(CEL_IMAG[i].YDimension)+'|'+inttostr(CEL_IMAG[i].BitDepthFlag)+'|'+inttostr(CEL_IMAG[i].unk2)+'|'+inttostr(CEL_IMAG[i].CompFlag)+'|'+inttostr(CEL_IMAG[i].ImageLength));

   TempoStream.Size := 0; // обнуляем временный поток

   case CEL_IMAG[i].CompFlag of
   0: TempoStream.CopyFrom(InputStream,CEL_IMAG[i].ImageLength);
   1: begin
       FillChar(CEL_LZ,SizeOf(CEL_LZ),0); // обнуляем LZ-буфер, на всякий случай ;)
       Read(CEL_LZ,SizeOf(CEL_LZ));
       CEL_LZ.UnpackedLength := EndianSwap(CEL_LZ.UnpackedLength);
       CEL_LZ.PackedLength := EndianSwap(CEL_LZ.PackedLength);
       CEL_LZDecoder(InputStream,TempoStream,CEL_LZ.PackedLength);
      end;
   end;

   with ImageBuffer[i].ImAttrib do begin
    RealWidth    := CEL_IMAG[i].XDimension;
    RealHeight   := CEL_IMAG[i].YDimension;
    X            := 0; // to-do : should load from INI here
    Y            := 0;
    RenderWidth  := 0; // to-do : must be set if image is 32 bit
    RenderHeight := 0;
//    FormatID     := 'Aoi Shiro CEL';
    Valid        := True;

    TempoStream.Seek(0,soBeginning);

    case CEL_IMAG[i].BitDepthFlag of
     5 : begin
          TempoStream.Read(Palette,SizeOf(Palette));
          TempoStream2 := TMemoryStream.Create;
          TempoStream2.CopyFrom(TempoStream,TempoStream.Size-SizeOf(Palette));
          TempoStream.Size := 0;
          TempoStream2.Position := 0;
          TempoStream.CopyFrom(TempoStream2,TempoStream2.Size);
          TempoStream.Position := 0;
          FreeAndNil(TempoStream2);
          BitDepth     := 8;
          ExtAlpha     := False;
          VerticalFlip(TempoStream,GetScanLineLen2(RealWidth,8),RealHeight);
          TempoStream.Seek(0,soBeginning);
          ImageBuffer[i].Image.CopyFrom(TempoStream,TempoStream.Size);
         end;
     7 : begin
          Palette := NullPalette; // if BitDepth > 8 then ignored
          BitDepth     := 24;
          ExtAlpha     := True;

          VerticalFlip(TempoStream,GetScanLineLen2(RealWidth,32),RealHeight);
          TempoStream.Seek(0,soBeginning);

          ExtractAlpha(TempoStream,ImageBuffer[i].Alpha,RealWidth,RealHeight);
          StripAlpha(TempoStream,ImageBuffer[i].Image,RealWidth,RealHeight);
         end;
    end;
   end;

   Seek(CEL_IMAG[i].OffsetNextEntry,soBeginning);
  end;

  FreeAndNil(TempoStream);

  LogD(inttostr(IMAGQty)+' images found in CEL file.');
  Read(CEL_ENDC,SizeOf(CEL_ENDC));
 end;

 try
  ImageBuffer[0].Image.Position := 0;
  RFI := ImageBuffer[0].ImAttrib; // загружаем первый кадр (тестирование) :)
  OutputStream.CopyFrom(ImageBuffer[0].Image,ImageBuffer[0].Image.Size);
 except
 end;

 try
  ImageBuffer[0].Alpha.Position := 0;
  OutputStreamA.CopyFrom(ImageBuffer[0].Alpha,ImageBuffer[0].Alpha.Size);
 except
 end;

StopThis:
 Result := RFI;

 RFI_Clear(RFI);
end;

{ A wrapper to LZ decode function }
function CEL_LZDecoder;
begin
 Result := GLZSSDecode(IStream,OStream,CryptLength,$3EE,$3FF); // $3EE $3FF
end;

{ A wrapper to LZ "encode" function }
function CEL_LZEncoder;
begin
 Result := GLZSSEncode(IStream,OStream);
end;

end.