{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Will Co. Picture File Image Format library

  Written by dsp2003 & Nik.
}

unit AG_Will_Picture_File;

interface

uses Classes, SysUtils,

     Generic_LZXX,
     AG_Fundamental,
     AG_RFI;

type
 TWIPFHdr = packed record
  Magic    : array[1..4] of char;  // WIPF
  ImgCount : word;                  // number of image frames
  BitDepth : word;                  // bit depth
 end;

 TWIPFImg = packed record  
  Width    : longword;              // Width
  Height   : longword;              // Height
  X        : longword;              // X coordinate
  Y        : longword;              // Y coordinate
  Z        : longword;              // ??
  CompSize : longword;              // size of compressed stream
 end;


function Import_WIPF(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
function Export_WIPF(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_WIPF(var ImFormat : TImageFormats);

function WILL_LZDecoder(IStream, OStream : TStream; CryptLength : integer) : boolean;

implementation

uses AnimED_Graphics;

procedure IG_WIPF;
begin
 with ImFormat do begin
  Name := '[WIP] Will Co. Picture File [Single img only]';
  Ext  := '.wip';
  Stat := $0;
  Open := Import_WIPF;
  Save := Export_WIPF;
  Ver  := $20101027;
 end;
end;

function Import_WIPF;
var i, k, l, m : integer;
    RFI           : TRFI;
    WIPF          : TWIPFHdr;
    WIPFImages    : array of TWIPFImg;
    TempoStream   : TStream;
    PixelA        : TARGB;
    Pixel         : TRGB;
label StopThis;
begin

 with WIPF, InputStream do begin
  Seek(0,soBeginning);
  Read(WIPF,SizeOf(WIPF));
  if Magic <> 'WIPF' then goto StopThis;

  SetLength(WIPFImages,ImgCount);

  RFI_Init(ImgCount);

  for i := 0 to ImgCount-1 do Read(WIPFImages[i],SizeOf(WIPFImages[i]));

  for i := 0 to ImgCount-1 do begin

   with ImageBuffer[i].ImAttrib do begin

    RealWidth    := WIPFImages[i].Width;
    RealHeight   := WIPFImages[i].Height;
    BitDepth     := WIPF.BitDepth;
    X            := WIPFImages[i].X; // to-do : should load from INI here
    Y            := WIPFImages[i].Y;
    RenderWidth  := 0; // to-do : must be set if image is 32 bit
    RenderHeight := 0;
//    FormatID     := 'Will Co. Picture File';
    Valid        := True;

  { Explaination:

    Any WIPF file is an planar image stream. }

    // читаем палитру
    if BitDepth = 8 then Read(Palette,SizeOf(Palette));

    TempoStream := TMemoryStream.Create;

    WILL_LZDecoder(InputStream,TempoStream,WIPFImages[i].CompSize);

/// Собираем изображение
    k := 0;
    for l := 0 to RealHeight-1 do begin
     for m := 0 to RealWidth-1 do begin
      with TempoStream, PixelA do begin
       Position := k;
       Read(B,1);
       if BitDepth >= 24 then begin
        Position := k+(RealWidth*RealHeight);
        Read(G,1);
        Position := k+(RealWidth*RealHeight*2);
        Read(R,1);
       end;
       if BitDepth = 32 then begin
        Position := k+(RealWidth*RealHeight*3);
        Read(A,1);
       end; 
       inc(k);
       Pixel := ARGBtoRGB(PixelA);
      end;
  /// Пишем пиксель
      case BitDepth of
       8  : ImageBuffer[i].Image.Write(Pixel.B,1);
       24 : ImageBuffer[i].Image.Write(Pixel,3);
       32 : ImageBuffer[i].Image.Write(PixelA,4);
      else raise Exception.Create('[AG_Will_Picture_File.pas] Debug error: unprogrammed BitDepth value detected.'#10#10'Value = '+inttostr(BitDepth));
      end;
     end;
    end;

    FreeAndNil(TempoStream);

    VerticalFlip(ImageBuffer[i].Image,GetScanLineLen2(RealWidth,BitDepth),RealHeight);

   end;

  end;

 end;

 try
  ImageBuffer[0].Image.Position := 0;
  RFI := ImageBuffer[0].ImAttrib; // загружаем первый кадр (тестирование) :)
  OutputStream.CopyFrom(ImageBuffer[0].Image,ImageBuffer[0].Image.Size);
 except
 end;


StopThis:

 Result := RFI;

 RFI_Clear(RFI);

end;

{ A wrapper to LZ decode function }
function WILL_LZDecoder;
begin
 Result := GLZSSDecode2(IStream,OStream,CryptLength,$1,$FFF);
end;

function Export_WIPF(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
var Hdr : TWIPFHdr;
    Img : TWIPFImg;
    Palette : TPalette;
    tmpStream, tmpStream2 : TStream;
    Pixel  : TRGB;
    PixelA : TARGB;
    k, l, m : integer;
begin
 InputStream.Seek(0,soBeginning);
 if InputStreamA <> nil then InputStreamA.Seek(0,soBeginning);

 tmpStream := TMemoryStream.Create;
 tmpStream2 := TMemoryStream.Create;

 with Hdr do begin

  if (InputStreamA <> nil) and (InputStreamA.Size > 0) then
   begin
    Palette := RFI.Palette;
 // Input image stream,alpha stream,output stream,width,height,bits,palette
    with RFI do begin
     RAW_AnyToTrueColor(InputStream,InputStreamA,tmpStream,RealWidth,RealHeight,BitDepth,Palette);
     BitDepth := 32;
    end;
   end
  else tmpStream.CopyFrom(InputStream,InputStream.Size);

  tmpStream.Seek(0,soBeginning);

  Magic    := 'WIPF';
  ImgCount := 1; // no multipage image support yet
  BitDepth := RFI.BitDepth;

 end;
 
 with Img do begin
  Width       := RFI.RealWidth;
  Height      := RFI.RealHeight;
  X           := RFI.X;
  Y           := RFI.Y;
  Z           := 0;
  CompSize    := GLZSSEncodeSize(tmpStream.Size); // (tmpStream.Size div 8) + tmpStream.Size + 3;
 end;

 VerticalFlip(tmpStream,GetScanlineLen2(RFI.RealWidth,RFI.BitDepth),RFI.RealHeight);

 tmpStream.Seek(0,soBeginning);
 tmpStream2.Size := tmpStream.Size;

/// Разбираем изображение
 k := 0;
 for l := 0 to RFI.RealHeight-1 do begin
  for m := 0 to RFI.RealWidth-1 do begin
// Читаем пиксель
   case RFI.BitDepth of
    8  : tmpStream.Read(Pixel.B,1);
    24 : tmpStream.Read(Pixel,3);
    32 : tmpStream.Read(PixelA,4);
   else raise Exception.Create('[AG_Will_Picture_File.pas] Debug error: unprogrammed BitDepth value detected.'#10#10'Value = '+inttostr(RFI.BitDepth));
   end;
// Унифицируем пиксель    
   case RFI.BitDepth of
    8, 24 : PixelA := RGBtoARGB(Pixel);
   end;
      
   with tmpStream2, PixelA do begin
    Position := k;
    Write(B,1);
    if RFI.BitDepth >= 24 then begin
     Position := k+(RFI.RealWidth*RFI.RealHeight);
     Write(G,1);
     Position := k+(RFI.RealWidth*RFI.RealHeight*2);
     Write(R,1);
    end;
    if RFI.BitDepth = 32 then begin
     Position := k+(RFI.RealWidth*RFI.RealHeight*3);
     Write(A,1);
    end;
    inc(k);
   end;
  end;
 end;

 tmpStream2.Seek(0,soBeginning);
 
 tmpStream.Size := 0;

 GLZSSEncode(tmpStream2,tmpStream);

 FreeAndNil(tmpStream2);

{ Combining data & saving bitmap stream... }
 OutputStream.Write(Hdr,SizeOf(Hdr));
 OutputStream.Write(Img,SizeOf(Img));

 if RFI.BitDepth = 8 then OutputStream.Write(RFI.Palette,SizeOf(RFI.Palette));

 tmpStream.Seek(0,soBeginning);
 OutputStream.CopyFrom(tmpStream,tmpStream.Size);
 FreeAndNil(tmpStream);

 Result := True;
end;

end.