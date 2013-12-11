{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.
  
  Hinatabokko images

  Originally written by w8m.
  Ported by Nik.
}

unit AG_ED8_EDT;

interface

uses Classes, SysUtils,
     AG_Fundamental,
     AnimED_Math,
     Windows,
     AG_RFI,
     AA_RFA;

function ShrBit(InputStream : TStream) : byte;
function CountBits(InputStream : TStream) : longword;
function Accumulate4b(InData, count : longword; InputStream : TStream) : longword;
procedure WriteBit(bit : byte; OutputStream : TStream);

function Import_ED8(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
function Export_ED8(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_ED8(var ImFormat : TImageFormats);

function Import_EDT(InputStream, OutputStream : TStream; OutputStreamA : TStream = nil) : TRFI;
function Export_EDT(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
procedure IG_EDT(var ImFormat : TImageFormats);

type
 TED8Header = packed record
   Magic : array[1..10] of char; // '.8Bit'#8D#5D#8C#CB#0
   Unk1 : longword; // $100
   Width : word;
   Height : word;
   PaletteSize : longword;
   PackedSize : longword;
 end;
 
 TEDTHeader = packed record
   Magic : array[1..10] of char; // '.TRUE'#8D#5D#8C#CB#0
   Unk1 : longword; // $100
   Width : word;
   Height : word;
   PaletteSize : integer; // всегда -1, изображение-то .TRUE
   Dummy : longword; // 0
   ActualPackedSize : longword; // запакованные данные
   ExcessSize : longword; // пиксели, которые запаковать не удалось
 end;

 TEDTDiffHeader = packed record
   Magic : array[1..10] of char; // '.EDT_DIFF'#0
   ColorMask : TARGB;
   SourceName : array[1..$40] of char; // имя исходного EDT
 end;

 TED8HelpArray = array[0..13] of integer;

var

  LeftBits : byte;
  TempBits : byte;

const

  HelpArr : TED8HelpArray = (-$10,$1,-$20,-$F,$11,$2,-$1F,$21,-$1E,-$E,$12,$22,$3,-$D);

implementation

uses AnimED_Graphics;

procedure IG_ED8;
begin
 with ImFormat do begin
  Name := '[ED8] Hinatabokko ED8';
  Ext  := '.ed8';
  Stat := $0;
  Open := Import_ED8;
  Save := Export_ED8;
  Ver  := $20100311;
 end;
end;

procedure IG_EDT;
begin
 with ImFormat do begin
  Name := '[EDT] Hinatabokko EDT';
  Ext  := '.edt';
  Stat := $0;
  Open := Import_EDT;
  Save := Export_EDT;
  Ver  := $20100311;
 end;
end;

function Import_ED8;
var Head : TED8Header;
    Palette : TTGAPalette;
    temp, outdata : longword;
    outputsize, intdata, breakcond, tmppos : integer;
    b : byte;
begin
 Result.Valid := False;
 InputStream.Position := 0;
 InputStream.Read(Head,sizeof(Head));
 if (Head.Magic <> '.8Bit'#$8D#$5D#$8C#$CB#0) then Exit;
 LeftBits := 0;
// Result.FormatID := 'Hinatabokko ED8 Image';
 FillChar(Palette.Palette[0], $300, 0);
 InputStream.Read(Palette.Palette[0], Head.PaletteSize * 3);
 Result.Palette := RGBPtoARGBP(Palette);
 Result.RealWidth := Head.Width;
 Result.RealHeight := Head.Height;
 Result.BitDepth := 8;
 Result.ExtAlpha := false;
 outputsize := Head.Width * Head.Height;
 while outputsize > 0 do
 begin
   Dec(outputsize);
   outdata := Accumulate4b(0,8,InputStream);
   OutputStream.Write(outdata,1);
   outdata := ShrBit(InputStream);
   if outdata = 0 then
   begin
     breakcond := -1;
     while outputsize > 0 do
     begin
       temp := 0;
       if ShrBit(InputStream) = 1 then
       begin
         if ShrBit(InputStream) = 1 then
         begin
           temp := (temp shl 1) + ShrBit(InputStream) + 1;
         end;
         temp := (temp shl 1) + ShrBit(InputStream) + 1;
       end;
       temp := (temp shl 1) + ShrBit(InputStream);
       if temp = breakcond then Break;
       breakcond := temp;
       temp := CountBits(InputStream);
       if breakcond >= 2 then Inc(temp);
       outputsize := outputsize - temp;
       if outputsize < 0 then Exit;
       intdata := HelpArr[breakcond];
       tmppos := ((intdata and $F) * (-Head.Width)) + (intdata div 16);
       while temp > 0 do
       begin
         OutputStream.Position := OutputStream.Position + tmppos;
         OutputStream.Read(b,1);
         OutputStream.Position := OutputStream.Size;
         OutputStream.Write(b,1);
         Dec(temp);
       end;
     end;
   end;
 end;
 OutputStream.Position := 0;
 BlockXOR(OutputStream, $FF);
 OutputStream.Position := 0;
 VerticalFlip(OutputStream, GetScanlineLen2(Head.Width, 8), Head.Height);
 Result.Valid := True;
end;

function ShrBit;
begin
  if LeftBits = 0 then
  begin
    InputStream.Read(TempBits,1);
    LeftBits := 8;
  end;
  Result := TempBits and 1;
  TempBits := TempBits shr 1;
  Dec(LeftBits);
end;

function CountBits;
var bit, count : byte;
begin
   count := 0;
   bit := 1;
   while (count < $20) and (bit = 1) do
   begin
     Inc(count);
     bit := ShrBit(InputStream);
   end;
   Result := 1;
   Dec(count);
   if(count <> 0) then Result := Accumulate4b(Result, count, InputStream);
end;

function Accumulate4b;
begin
  Result := InData;
  while count > 0 do
  begin
    Result := (Result shl 1) + ShrBit(InputStream);
    Dec(count);
  end;
end;

function Export_ED8(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
var Head : TED8Header;
    Palette : TTGAPalette;
    TempStream, TempStream2 : TStream;
    i, sv : longword;
    b : byte;
    rgb : TRGB;
begin

  LeftBits := 0;
  TempBits := 0;
  Head.Magic := '.8Bit'#$8D#$5D#$8C#$CB#0;
  Head.Unk1 := $100;
  Head.Width := RFI.RealWidth;
  Head.Height := RFI.RealHeight;
  Head.PaletteSize := $100;

  TempStream := TMemoryStream.Create;
  TempStream2 := TMemoryStream.Create;

  sv := 0;
  for i := 0 to 255 do
  begin
    CopyMemory(@Palette.Palette[i], @sv, 3);
    sv := sv + $10101;
  end;

  if (InputStreamA = nil) or (InputStreamA.Size = 0) then
  begin
    InputStream.Position := 0;
    if RFI.BitDepth = 8 then
    begin
      TempStream.CopyFrom(InputStream, InputStream.Size);
    end
    else
    begin
      while InputStream.Position < InputStream.Size do
      begin
        InputStream.Read(rgb, 3);
        sv := (rgb.B + rgb.G + rgb.R) div 3;
        TempStream.Write(sv, 1);
      end;
    end;
  end
  else
  begin
    InputStreamA.Position := 0;
    TempStream.CopyFrom(InputStreamA, InputStreamA.Size);
  end;

  TempStream.Position := 0;
  BlockXOR(TempStream, $FF);
  TempStream.Position := 0;
  VerticalFlip(TempStream, GetScanlineLen2(Head.Width, 8), Head.Height);
  TempStream.Position := 0;

  while TempStream.Position < TempStream.Size do
  begin
    TempStream.Read(b, 1);
    for i := 1 to 8 do
    begin
      WriteBit(((b shr 7) and 1), TempStream2);
      b := b shl 1;
    end;
    WriteBit(1, TempStream2);
  end;
  WriteBit(1, TempStream2);

  Head.PackedSize := TempStream2.Size;

  OutputStream.Write(Head, sizeof(head));
  OutputStream.Write(Palette, sizeof(Palette));
  TempStream2.Position := 0;
  OutputStream.CopyFrom(TempStream2, TempStream2.Size);

  FreeAndNil(TempStream);
  FreeAndNil(TempStream2);
  Result := True;
end;

procedure WriteBit;
begin
  TempBits := ((TempBits shr 1) and $7F) or ((bit shl 7) and $80);
  Inc(LeftBits);
  if LeftBits = 8 then
  begin
    OutputStream.Write(TempBits, 1);
    TempBits := 0;
    LeftBits := 0;
  end;
end;


function Import_EDT;
var Head : TEDTHeader;
    Diff : TEDTDiffHeader;
    outdata, i, j, scanline : longword;
    outputsize, intdata, intdata2, excess : integer;
    b, b2 : byte;
    HArr : array[0..$1F] of integer;
    ppacked, pexcess : TStream;
    diffstream, adiffstream, idiffstream : TStream;
    str : String;
    px, mask : TRGB;
    drfi, arfi : TRFI;
begin
 Result.Valid := False;
 InputStream.Position := 0;
 InputStream.Read(Head,sizeof(Head));
 if (Head.Magic <> '.TRUE'#$8D#$5D#$8C#$CB#0) then Exit;
 LeftBits := 0;
// Result.FormatID := 'Hinatabokko EDT Image';
 Result.RealWidth := Head.Width;
 Result.RealHeight := Head.Height;
 Result.BitDepth := 24;
 Result.ExtAlpha := false;
// bignum := Int64($0AAAAAAAB) * Int64(Head.ExcessSize);
// excess := Integer(bignum shr 33) * 3;
 
 if ((excess mod 3) <> 0) or (excess = 0) then Exit;
 outputsize := Head.Height * Head.Width;
 diffstream := nil;

 InputStream.Read(Diff,sizeof(Diff));
 if Diff.Magic <> '.EDT_DIFF'#0 then
 begin
   InputStream.Position := InputStream.Position - sizeof(Diff);
 end
 else
 begin
   str := ExtractFilePath(OpenedImageName) + String(PChar(@Diff.SourceName)) + '.edt';
   if FileExists(str) then
   begin
     OpenFileStream(idiffstream, str);
     adiffstream := TMemoryStream.Create;
     diffstream := TMemoryStream.Create;
     drfi := Import_EDT(idiffstream, diffstream, adiffstream);
     if drfi.Valid then
     begin
       FreeAndNil(idiffstream);
     end
     else
     begin
       FreeAndNil(idiffstream);
       FreeAndNil(adiffstream);
       FreeAndNil(diffstream);
     end;
     LeftBits := 0;
   end;
 end;

 str := ExtractFilePath(OpenedImageName) + ChangeFileExt(ExtractFileName(OpenedImageName),'') + '_.ed8';
 if FileExists(str) and (OutputStreamA <> nil) then
 begin
   OpenFileStream(idiffstream, str);
   arfi := Import_ED8(idiffstream, OutputStreamA, nil);
   if arfi.Valid then
   begin
     Result.ExtAlpha := True;
   end;
   FreeAndNil(idiffstream);
   LeftBits := 0;
 end;

 ppacked := TMemoryStream.Create;
 pexcess := TMemoryStream.Create;
 ppacked.CopyFrom(InputStream, Head.ActualPackedSize);
 pexcess.CopyFrom(InputStream, Head.ExcessSize);
 ppacked.Position := 0;
 pexcess.Position := 0;

 intdata := Head.Width * -$0C;
 scanline := Head.Width * 3;
 i := 0;
 while intdata <> 0 do
 begin
   intdata2 := intdata - 9;
   for j := 1 to 7 do
   begin
     HArr[i] := intdata2;
     intdata2 := intdata2 + 3;
     Inc(i);
   end;
   intdata := intdata + scanline;
 end;
 intdata := -$C;
 while intdata <> 0 do
 begin
   HArr[i] := intdata;
   Inc(intdata,3);
   Inc(i);
 end;

 pexcess.Read(px, sizeof(px));
 OutputStream.Write(px, sizeof(px));
 Dec(outputsize);

 while outputsize > 0 do
 begin
   outdata := ShrBit(ppacked);
   if outdata = 1 then
   begin
     outdata := ShrBit(ppacked);
     if outdata = 0 then
     begin
       intdata := HArr[Accumulate4b(0, 5, ppacked)];
       if OutputStream.Position < (0-intdata) then
       begin
         FreeAndNil(ppacked);
         FreeAndNil(pexcess);
         Exit;
       end;
       intdata2 := CountBits(ppacked);
       Dec(outputsize, intdata2);
       for i := 1 to intdata2 do
       begin
         OutputStream.Position := OutputStream.Position + intdata;
         OutputStream.Read(px, sizeof(px));
         OutputStream.Position := OutputStream.Size;
         OutputStream.Write(px, sizeof(px));
       end;
     end
     else
     begin
       intdata2 := -3;
       outdata := ShrBit(ppacked);
       if outdata = 1 then
       begin
         intdata2 := HArr[($11191718 shr ((Accumulate4b(0,2, ppacked) shl 3)) and $FF)];
         if OutputStream.Position < (0-intdata) then
         begin
           FreeAndNil(ppacked);
           FreeAndNil(pexcess);
           Exit;
         end;
       end;
       for i := 1 to 3 do
       begin
         OutputStream.Position := OutputStream.Position + intdata2;
         OutputStream.Read(b, 1);
         OutputStream.Position := OutputStream.Size;
         if b < 2 then
           b := 2
         else if b > $FD then b := $FD;
         outdata := ShrBit(ppacked);
         if outdata = 1 then
         begin
           b2 := 1 + Byte(ShrBit(ppacked));
           outdata := ShrBit(ppacked);
           if outdata = 0 then
             b := b - b2
           else
             b := b + b2;
         end;
         OutputStream.Write(b, 1);
       end;
     end;
   end
   else
   begin
     pexcess.Read(px, sizeof(px));
     OutputStream.Write(px, sizeof(px));
     Dec(outputsize);
   end;
 end;
 OutputStream.Position := 0;
 VerticalFlip(OutputStream, GetScanlineLen2(Head.Width, 24), Head.Height);
 FreeAndNil(ppacked);
 FreeAndNil(pexcess);

 if diffstream <> nil then
 begin
   mask := ARGBtoRGB(Diff.ColorMask);
   diffstream.Position := 0;
   adiffstream.Position := 0;
   OutputStream.Position := 0;
   while diffstream.Position < diffstream.Size do
   begin
     OutputStream.Read(px, sizeof(px));
     if (px.B = mask.B) and (px.G = mask.G) and (px.R = mask.R) then
     begin
       OutputStream.Position := OutputStream.Position - 3;
       diffstream.Read(px, sizeof(px));
       OutputStream.Write(px, sizeof(px));
     end
     else
       diffstream.Position := diffstream.Position + 3;
   end;
//   OutputStream := diffstream;
   FreeAndNil(adiffstream);
   FreeAndNil(diffstream);
 end;

 Result.Valid := True;
end;

function Export_EDT(RFI : TRFI; OutputStream, InputStream : TStream; InputStreamA : TStream = nil) : boolean;
var Head : TEDTHeader;
    TempStream, TempStream2 : TStream;
    i, sz : longword;
    b : byte;
    rgb : TRGB;
    str: String;
    arfi : TRFI;
begin

  if (RFI.ExtAlpha = true) and (InputStreamA <> nil) then
  begin
    str := ExtractFilePath(SavingImageName) + ChangeFileExt(ExtractFileName(SavingImageName),'') + '_.ed8';
    arfi.RealWidth := RFI.RealWidth;
    arfi.RealHeight := RFI.RealHeight;
    arfi.BitDepth := 8;
    arfi.ExtAlpha := False;
    arfi.Valid := True;
    TempStream := TMemoryStream.Create;
    Export_ED8(arfi, TempStream, InputStreamA, nil);
    TempStream.Position := 0;
    OpenFileStream(TempStream2, str, fmCreate);
    TempStream2.CopyFrom(TempStream, TempStream.Size);
    FreeAndNil(TempStream);
    FreeAndNil(TempStream2);
  end;

  LeftBits := 0;
  TempBits := 0;
  Head.Magic := '.TRUE'#$8D#$5D#$8C#$CB#0;
  Head.Unk1 := $100;
  Head.Width := RFI.RealWidth;
  Head.Height := RFI.RealHeight;
  Head.PaletteSize := -1;
  Head.Dummy := 0;

  TempStream := TMemoryStream.Create;
  TempStream2 := TMemoryStream.Create;
  InputStream.Position := 0;
  if RFI.BitDepth = 8 then
  begin
    while InputStream.Position < InputStream.Size do
    begin
      InputStream.Read(b, 1);
      rgb.B := b;
      rgb.G := b;
      rgb.R := b;
      TempStream.Write(rgb, 3);
    end;
  end
  else
  begin
    TempStream.CopyFrom(InputStream, InputStream.Size);
  end;

  TempStream.Position := 0;
  VerticalFlip(TempStream, GetScanlineLen2(Head.Width, 24), Head.Height);
  TempStream.Position := 0;

  sz := (TempStream.Size div 3) + 1;
  b := 0;

  for i := 1 to sz do
  begin
    TempStream2.Write(b, 1);
  end;

  Head.ActualPackedSize := TempStream2.Size;
  Head.ExcessSize := TempStream.Size;

  OutputStream.Write(Head, sizeof(head));
  TempStream2.Position := 0;
  OutputStream.CopyFrom(TempStream2, TempStream2.Size);
  OutputStream.CopyFrom(TempStream, TempStream.Size);

  FreeAndNil(TempStream);
  FreeAndNil(TempStream2);
  Result := True;
end;

end.