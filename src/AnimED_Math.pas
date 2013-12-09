{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Math unit

  Uses code samples from
  http://sources.ru/delphi/algorithms/hextoint_inttobin_bintoint.shtml

  Written by dsp2003 & w8m.
}
unit AnimED_Math;

interface

uses Classes, SysUtils;

{ MATH functions }
function Involution(Base, InvolutionValue: extended) : extended;
{function ByteConverter(a, b : integer; operation : byte) : byte; }

procedure BlockConvIO(InputStream, OutputStream, KeyStream : TStream; Value, Mode : byte);

procedure BlockXORDirect(InputStream : TStream; value : byte); // works directly with given stream
procedure BlockXOR(InputStream : TStream; value : byte); // makes some in-memory copying
procedure BlockXORIO(InputStream, OutputStream : TStream; value : byte; RewindOutput : boolean = True);

procedure BlockXORKey(InputStream, KeyStream : TStream);
procedure BlockXORKeyIO(InputStream, OutputStream, KeyStream : TStream; RewindOutput : boolean = True);

procedure BlockSHx(InputStream : TStream; value, Mode : byte);
procedure BlockSHxIO(InputStream, OutputStream : TStream; value, Mode : byte; RewindOutput : boolean = True);

{ Функции округления размера и вычисления остатка для записи файлов }
function SizeDiv(Size,BlockSize : longword) : longword;
function SizeMod(Size,BlockSize : longword) : longword;
function SizeBlock(Size,BlockSize : longword) : longword;

{ ISF-related functions }
function CharToBase36(i : char) : byte;
function Base36ToChar(i : byte) : char;

function EndianSwap(const a: integer): integer;
function EndianSwap16(inp:word): word;

function HexToInt(HexStr : string) : Int64;
function IntToBin(IValue : Int64; NumBits : word = 64) : string;
function BinToInt(BinStr : string) : Int64;
function Base10(Base2:Integer) : integer; assembler;

function IntToNum(i : int64) : string;

type DataArray = array of int64;

procedure ShellSort(var item: DataArray; n:integer);
procedure BubbleSort(var item: DataArray; n: integer);

function GetCPUTacts : int64;

const

{ operations for byte converter }
  bcInvert = $0; // Invert
  bcXOR    = $1; // XORing
  bcAND    = $2; // ANDing
  bcOR     = $3; // ORing
  bcSHL    = $4; // Circular bitwise left-shift
  bcSHR    = $5; // Circular bitwise right-shift
  bc256m   = $6; // 256 - value
  bcCM     = $7; // b=b*4 encode
  bcCD     = $8; // b=b*4 decode
  bcKey    = $9; // key mode
  bcZlib   = $A; // Zlib decode

{ This is the implementation of base36 table }
  charTable = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

implementation

{ Возвращает текущее количество тактов процессора. Спасибо w8m за подсказку }
function GetCPUTacts;
asm
 rdtsc
end;

{ Возвращает число, недостающее до выравнивания по блоку }
function SizeMod;
begin
 Result := 0;
 if (Size mod BlockSize) <> 0 then Result := BlockSize - (Size mod BlockSize);
end;

{ Возвращает число, выровненное по размеру блока (в большую сторону) }
function SizeDiv;
begin
 Result := Size + SizeMod(Size,BlockSize);
end;

{ Возвращает размер в количестве блоков }
function SizeBlock;
begin
 Result := SizeDiv(Size,BlockSize) div BlockSize;
end;

{ A collection wrapper of block conversions. Heir of ConvertBytes }
procedure BlockConvIO;
begin
 case Mode of
  bcInvert : BlockXORIO(InputStream,OutputStream,$FF);
  bcXOR    : BlockXORIO(InputStream,OutputStream,Value);
  bcAND    : ; //to-do: recreate or get rid?
  bcOR     : ; //to-do: recreate or get rid?
  bcSHL    : BlockSHxIO(InputStream,OutputStream,Value,bcSHL);
  bcSHR    : BlockSHxIO(InputStream,OutputStream,Value,bcSHR);
  bc256m   : ; //to-do: recreate or get rid?
  bcCM     : BlockSHxIO(InputStream,OutputStream,$2,bcSHL);
  bcCD     : BlockSHxIO(InputStream,OutputStream,$2,bcSHR);
  bcKey    : BlockXORKeyIO(InputStream,OutputStream,KeyStream);
 end;
end;

procedure BlockXOR;
var tmpStream : TStream;
begin
 tmpStream := TMemoryStream.Create;
 BlockXORIO(InputStream,tmpStream,value);
 InputStream.Position := 0;
 tmpStream.Position := 0;
// InputStream.Size := tmpStream.Size;
 InputStream.CopyFrom(tmpStream,tmpStream.Size);
 FreeAndNil(tmpStream);
end;

{ делает ксор потока в самого себя }
procedure BlockXORDirect;
var i,j,LastChunk,XorKey : integer;
begin
 // перематываем поток на начало
 InputStream.Position := 0;

 // It's ugly. Really ugly... =_= ...but fast
 xorkey := value shl 24 + value shl 16 + value shl 8 + value;
 // Decryption in progress...
 LastChunk := InputStream.Size mod 4;
 for i := 1 to (InputStream.Size div 4) do begin
  InputStream.Read(j,4);
  InputStream.Position := InputStream.Position - 4;
  j := j xor xorkey;
  InputStream.Write(j,4);
 end;

 if LastChunk > 0 then begin
  InputStream.Read(j,LastChunk);
  InputStream.Position := InputStream.Position - LastChunk;
  j := j xor xorkey;              //  8 16 24 32 40 48 56 64
  InputStream.Write(j,LastChunk); // FF FF FF FF FF FF FF FF
 end;

end;

procedure BlockXORIO;
var i,j,LastChunk,XorKey : integer;
begin
 // перематываем поток на начало
 InputStream.Position := 0;
 if RewindOutput then OutputStream.Position := 0;

 // It's ugly. Really ugly... =_= ...but fast
 xorkey := value shl 24 + value shl 16 + value shl 8 + value;
 // Decryption in progress...
 LastChunk := InputStream.Size mod 4;
 for i := 1 to (InputStream.Size div 4) do begin
  InputStream.Read(j,4);
  j := j xor xorkey;
  OutputStream.Write(j,4);
 end;

 if LastChunk > 0 then begin
  InputStream.Read(j,LastChunk);
  j := j xor xorkey;               //  8 16 24 32 40 48 56 64
  OutputStream.Write(j,LastChunk); // FF FF FF FF FF FF FF FF
 end;

end;

procedure BlockXORKey;
var tmpStream : TStream;
begin
 tmpStream := TMemoryStream.Create;
 BlockXORKeyIO(InputStream,tmpStream,KeyStream);
 InputStream.Size := 0;
 tmpStream.Position := 0;
 InputStream.CopyFrom(tmpStream,tmpStream.Size);
 FreeAndNil(tmpStream);
end;

procedure BlockXORKeyIO;
var Key : array of byte;
    i,j,k,l,LastChunk,XorKey : integer;
begin
 InputStream.Position := 0;
 if RewindOutput then OutputStream.Position := 0;
 KeyStream.Position := 0;
 // устанавливаем длину ключа
 SetLength(Key,KeyStream.Size);
 // читаем зацикленный ключ в память
 KeyStream.Read(Key[0],KeyStream.Size);

 LastChunk := InputStream.Size mod 4;
 
 i := 0;

 for j := 1 to (InputStream.Size div 4) do begin
  xorkey := 0; // сбрасываем мини-ключ
  for k := 0 to 3 do begin
   xorkey := xorkey + Key[i] shl (k*8);
   inc(i);
   if i > Length(Key)-1 then i := i - Length(Key);
  end;
  InputStream.Read(l,4);
  l := l xor xorkey;
  OutputStream.Write(l,4);
 end;

 if LastChunk > 0 then begin
  xorkey := 0; // сбрасываем мини-ключ
  for k := 0 to LastChunk-1 do begin
   xorkey := xorkey + Key[i] shl (k*8);
   inc(i);
   if i > Length(Key)-1 then i := i - Length(Key);
  end; 
  InputStream.Read(l,LastChunk);
  l := l xor xorkey;
  OutputStream.Write(l,LastChunk);
 end;
 
end;

procedure BlockSHx;
var tmpStream : TStream;
begin
 tmpStream := TMemoryStream.Create;
 BlockSHxIO(InputStream,tmpStream,value,Mode);
 InputStream.Size := 0;
 tmpStream.Position := 0;
 InputStream.CopyFrom(tmpStream,tmpStream.Size);
 FreeAndNil(tmpStream);
end;

procedure BlockSHxIO;
var i,j,LastChunk : integer;
    MiniBuffer : array[1..4] of byte;
begin
 // перематываем поток на начало
 InputStream.Position := 0;
 if RewindOutput then OutputStream.Position := 0;

 // Decryption in progress...
 LastChunk := InputStream.Size mod 4;

 for i := 1 to (InputStream.Size div 4) do begin
  InputStream.Read(MiniBuffer,4);
  for j := 1 to 4 do case Mode of
   bcSHL : MiniBuffer[j] := (MiniBuffer[j] shl value) or (MiniBuffer[j] shr (8-value));
   bcSHR : MiniBuffer[j] := (MiniBuffer[j] shr value) or (MiniBuffer[j] shl (8-value));
  end;
  OutputStream.Write(MiniBuffer,4);
 end;

 if LastChunk > 0 then begin
  InputStream.Read(MiniBuffer,LastChunk);
  for j := 1 to LastChunk do case Mode of
   bcSHL : MiniBuffer[j] := (MiniBuffer[j] shl value) or (MiniBuffer[j] shr (8-value));
   bcSHR : MiniBuffer[j] := (MiniBuffer[j] shr value) or (MiniBuffer[j] shl (8-value));
  end;
  OutputStream.Write(MiniBuffer,LastChunk);
 end;
end;

{ AWESOME(ly stupid) byte converter function }
{function ByteConverter(a, b : integer; operation : byte) : byte;}
{var i,j : integer; }
{begin
 case operation of
  bcInvert: Result := ByteConverter(a,$FF,bcXOR);
  bcXOR:    Result := a xor b;
  bcAND:    Result := a and b;
  bcOR:     Result := a or b;
  bcSHL:    Result := (a shl b) or (a shr (8-b));
  bcSHR:    Result := (a shr b) or (a shl (8-b));
  bc256m:   Result := 256 - a;
  bcCM:     Result := ByteConverter(a,2,bcSHL); {begin a := a * $4; if a > $FF then while a > $FF do a := a - $FF; ByteConverter := a; end;}
{  bcCD:     Result := ByteConverter(a,2,bcSHR); {begin for i := 0 to 63 do begin for j := 0 to 3 do begin if a = i*4+j then b := (a+$FF*j) div 4; end; end; ByteConverter := b; end;}
{ else Result := 0;
 end;
end;}

{ helper macro to convert ('0'..'9','A'..'Z') to (0..35) }
function CharToBase36;
begin
 Result := pos(i,CharTable)-1; //-1 here because the pos function returns [1..???]
end;

function Base36ToChar;
begin
 Result := CharTable[i+1]; //+1 here because i is in range [0..35]
end;

function Involution;
begin
 Result := exp(InvolutionValue*ln(Base));
end;

{ Invert bytes using assembly. Duplicated from PNGImage.pas }
function EndianSwap;
asm
  bswap eax
end;

function EndianSwap16;
asm
  bswap eax
  shr   eax, 16
end;

{ ======================================= }
{ Преобразование значения HexString в Int64 }
{ Замечание: Последний символ может быть 'H' для Hex  }
{        т.е. '00123h' или '00123H'    }
{ В случае неправильной HexString будет возвращён 0 }
{ ======================================= }
function HexToInt;
var RetVar : Int64;
    i : byte;
begin

{ case HexStr[length(HexStr)] of
  'h','H' : Delete(HexStr,length(HexStr),1);
 end;

 try
  Result := strtoint('$'+HexStr);
 except
  Result := 0;
 end; }

 HexStr := UpperCase(HexStr);
// if HexStr[length(HexStr)] = 'H' then Delete(HexStr,length(HexStr),1);
 RetVar := 0;
 for i := 1 to length(HexStr) do begin
  RetVar := RetVar shl 4;
  case HexStr[i] of
  '0'..'9' : RetVar := RetVar + (byte(HexStr[i]) - 48);
  'A'..'F' : RetVar := RetVar + (byte(HexStr[i]) - 55);
  'G'..'Z', '!'..'/', ':'..'@' : ;// skipping dots and other trash
  else begin
        Retvar := 0;
        break;
       end;
  end;
 end;
 Result := RetVar;
end;

{ =================================================
  Преобразование значения Int64 в бинарную строку
  NumBits может быть 64,32,16,8 для указания
  представления возвращаемого значения (Int64,
  DWord, Word или Byte) (по умолчанию = 64).
  Обычно NumBits требуется только для отрицательных
  входных значений.
  ================================================= }

function IntToBin;
var RetVar : string;
begin
 RetVar := '';

 case NumBits of
  32 : IValue := longword(IValue);
  16 : IValue := word(IValue);
   8 : IValue := byte(IValue);
 end;

 while IValue <> 0 do begin
  Retvar := char(48 + (IValue and 1)) + RetVar;
  IValue := IValue shr 1;
 end;

 if RetVar = '' then Retvar := '0';
 Result := RetVar;
end;

{ =======================================================
  Преобразование бинарной строки в значение Int64
  Замечание: Последний символ может быть 'B' для Binary
         т.е. '001011b' или '001011B'
  В случае неправильной бинарной строки будет возвращён 0
  ======================================================= }
function BinToInt;
var i : byte;
    RetVar : Int64;
begin
 BinStr := UpperCase(BinStr);
 if BinStr[length(BinStr)] = 'B' then Delete(BinStr,length(BinStr),1);
 RetVar := 0;
 for i := 1 to length(BinStr) do begin
  if not (BinStr[i] in ['0','1']) then begin
   RetVar := 0;
   Break;
  end;
  RetVar := (RetVar shl 1) + (byte(BinStr[i]) and 1) ;
 end;
 Result := RetVar;
end;

// преобразование 32-битного целого в бинарное число
function Base10(Base2 : integer) : integer; assembler;
asm
  cmp    eax,100000000 // проверяем верхний предел
  jb     @1            // ok
  mov    eax,-1        // флаг ошибки
  jmp    @exit         // выходим с -1
@1:
  push   ebx           // сохраняем регистры
  push   esi
  xor    esi,esi       // результат = 0
  mov    ebx,10        // делим по основанию 10
  mov    ecx,8
@2:
  mov    edx,0
  div    ebx
  add    esi,edx
  ror    esi,4
  loop @2
  mov    eax,esi       // результат функции
  pop    esi           // восстанавливаем регистры
  pop    ebx
@exit:
end;

{ Небольшая вспомогательная функция для отображения "читабельных человеком"
  чисел. Обёртка для Format. }
function IntToNum;
begin
 Result := Format('%.n',[i*1.0]);
end;

procedure BubbleSort;
var i,j : integer; k : int64;
begin
 for i := 0 to n-1 do begin
  for j := 0 to n-1 do begin
   if item[i] < item[j] then begin
    k := item[i];
    item[i] := item[j];
    item[j] := k;
   end;
  end;
 end;
end;

procedure ShellSort;
const a : array[1..5] of byte = (9,5,3,2,1);
var i,j,k,gap : integer;
    temp : longword;
begin
 for k := 1 to 5 do begin
  gap := a[k];
  for i := gap to n-1 do begin
   temp := item[i];
   j := i - gap;
   while (temp < item[j]) and (j>=0) do begin
    item[j+gap] := item[j];
    j := j - gap;
   end;
   item[j+gap] := temp;
  end;
 end;
end;

end.