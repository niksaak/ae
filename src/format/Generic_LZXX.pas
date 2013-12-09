{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  LZ/LZSS/LZ77 generic library

  Written by Nik & dsp2003 & w8m.
}
unit Generic_LZXX;

interface

uses Classes, AnimED_Math;

type
 TZLHeader = packed record
  ident     : longword; //  20 20 5A 4C
  orig_size : longword;
  comp_size : longword;
  dummy     : longword;
 end;

 TSZDDHeader = packed record
  Magic1     : array[1..4] of char; //  'SZDD'
  Magic2     : longword; // $3327F088
  Comp_mode  : byte; // Must be 'A' (0x41)
  dummy      : byte; // 0
  UnpackedSize : longword; // Big-endian
 end;

TBitstream = class
    cByte : byte;
    cMask : byte;
  public
    constructor Create;
    function GetBit(Stream : TStream) : byte;
    function GetBits(Stream : TStream; Count : integer) : longword;
end;

//для cel
//GLZDecode(IStream, OStream, CryptLength, $3EE,$3FF)

//для Pure Pure
//GLZDecode(IStream, OStream, CryptLength, $FEE,$FFF)

//для Princess Waltz
//GLZDecode(IStream, OStream, CryptLength, $1,$FFF)

function SZDDDecode(InputStream, OutputStream : TStream) : boolean;

function GLZSSEncodeSize(size : int64; EndTail : boolean = False) : int64;
// the only difference with GLZSSEncode is three extra trailing zeroes
function GLZSSEncode2(iStream, oStream : TStream; EndTrail : boolean = True) : boolean;
function GLZSSEncode(iStream, oStream : TStream) : boolean;

function GLZSSDecode(InputStream, OutputStream : TStream; CryptLength, SlidWindowIndex, SlidWindowLength : integer; FillBuffer : integer = $100) : boolean;
function GLZSSDecode_m(InputStream, OutputStream : TStream; CryptLength, SlidWindowIndex, SlidWindowLength : integer) : boolean;
function GLZSSDecode2(InputStream, OutputStream : TStream; CryptLength, SlidWindowIndex, SlidWindowLength : integer) : boolean;
function GLZSSDecode3(InputStream, OutputStream : TStream; CryptLength, SlidWindowIndex, SlidWindowLength : integer) : boolean;

function GLZSSDecode_Overture(InputStream, OutputStream : TStream; CryptLength, SlidWindowIndex, SlidWindowLength : integer; FillBuffer : integer = $100) : boolean;

function GCLZ77Decode(InputStream, OutputStream : TStream; CryptLength : integer) : boolean;
function GCLZ77Decode_2(InputStream, OutputStream : TStream; CryptLength : integer) : boolean;

{ Primary written for INTERHEART's archives }
function ZLC2Decode(InputStream, OutputStream : TStream) : boolean;

{ Primary written for Shuffle! graphics decoding }
function ZLDecode(InputStream, OutputStream : TStream) : boolean;

{ Primary written for Touhou archives decoding }
function ZunLZSSDecode(InputStream, OutputStream : TStream; ol : longword = 0) : boolean;

implementation

{ Well, it doesn't really compress anything... ^^' }
function GLZSSEncode;
begin
 Result := GLZSSEncode2(iStream,oStream,False); // made for compatibility with older drivers
end;

{ Helper function for the "compressed" data size calculation }
function GLZSSEncodeSize;
begin
 case EndTail of
 False : Result := (size div 8) + size;
  True : Result := (size div 8) + size + 3;
 end;
end;

{ Rewritten to handle several nasty formats, such as TIM2 and Will }
function GLZSSEncode2;
var cbyte, msize : byte;
    buffer       : int64;
    dsize, i     : longword;
begin

 cbyte := $FF;
 Result := True;
 
 dsize := iStream.Size div 8;
 msize := iStream.Size mod 8;
 
 for i := 1 to dsize do begin
  iStream.Read(buffer,8);
  oStream.Write(cbyte,1);
  oStream.Write(buffer,8);
 end;

 if msize > 0 then begin
  cbyte := (1 shl msize) - 1;
  iStream.Read(buffer,msize);
  oStream.Write(cbyte,1);
  oStream.Write(buffer,msize);
  cbyte := 0;
 end else if EndTrail then begin
  cbyte := 0;
  oStream.Write(cbyte,1); // $00
 end;

 if EndTrail then for i := 1 to 2 do oStream.Write(cbyte,1); // $00 00

end;

function SZDDDecode;
var Header : TSZDDHeader;
begin
  Result := False;
  InputStream.Read(Header,sizeof(Header));
  if (Header.Magic1 <> 'SZDD') or (Header.Magic2 <> $3327F088) or (Header.Comp_mode <> $41) then Exit;
  Result := GLZSSDecode(InputStream, OutputStream, InputStream.Size-sizeof(Header), $FF0, $FFF);
end;

function GLZSSDecode;
{IStream - открытый поток, стоит на начале закриптованного участка,
CryptLength - количество байт в закриптованном участке}
var SlidingWindow : array of byte; {"Скользящее окно" с переменной длиной}
    Temp1, Temp2, EAX, ECX, EDI : integer;
    AL, DI : byte;
begin
 Result := False;
 SetLength(SlidingWindow,SlidWindowLength+1);
// добавлен необязательный параметр, чтобы не создавать множество копий этой функции
 if FillBuffer <> $100 then FillChar(SlidingWindow[0],SlidWindowLength+1,FillBuffer);
//WindowIndex := $3EE; {Начальный индекс окна}
 Temp1 := 0;
{Тут я предположил, что OStream уже открыт}
 while (CryptLength > 0) do begin
  EAX := Temp1;
  EAX := EAX shr 1;
  Temp1 := EAX;
  if ((EAX and $FF00) and $100) = 0 then begin
 {Если 9-й бит равен нулю, значит управляющее слово кончилось (или не
  загружалось, при первом проходе)}
 {Читаем управляющее слово}
   AL := 0;
   InputStream.Read(AL,1);
   dec(CryptLength);
   EAX := AL or $FF00;
   Temp1 := EAX;
  end;
 {Если очередной бит управляющего слова равен 1, значит очередной байт
  пишется в выходной поток без изменений}
  if ((Temp1 and $FF) and $1) <> 0 then begin
   InputStream.Read(AL,1);
   dec(CryptLength);
   OutputStream.Write(AL,1);
   SlidingWindow[SlidWindowIndex] := AL;
   inc(SlidWindowIndex);
   SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
 {Если очередной бит управляющего слова равен 0, значит мы юзаем
  "скользящее окно" для воспроизведения байт}
  end else begin
  {
   Логика такая: читается два байта
    1) базовый (биты 0-7)
    2) разделяемый
       биты 0-3 - количество итераций (байт)
       биты 4-7 - биты 8-12 базового адреса
    Далее начиная с базового адреса в скользящем окне читается в
    выходной поток столько байт сколько указано в кол-ве итераций + 2
    Нужно учесть, что скользящее окно циклически замкнуто (после
    индекса 1023 сразу идет индекс 0)
  }
   InputStream.Read(DI,1);
   InputStream.Read(AL,1);
   dec(CryptLength,2);
   ECX := (AL and $F0) shl 4;
   EDI := DI or ECX;
   EAX := (AL and $F) + 2;
   Temp2 := EAX;
   ECX := 0;
   if EAX > 0 then begin
    while (ECX <= Temp2) do begin
     EAX := (ECX + EDI) and SlidWindowLength;
     AL := SlidingWindow[EAX];
     OutputStream.Write(AL,1);
     SlidingWindow[SlidWindowIndex] := AL;
     inc(SlidWindowIndex);
     SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
     inc(ECX);
    end;
   end;
  end;
 Result := True;
 end;

end;

function GLZSSDecode_m;
var SlidingWindow : array of byte;
    Temp1, Temp2, EAX, ECX, EDI : integer;
    AL, DI : byte;
begin
 Result := False;
 SetLength(SlidingWindow,SlidWindowLength+1);
 FillChar(SlidingWindow[0],SlidWindowLength+1,$20);
 Temp1 := 0;
 while (CryptLength > 0) do begin
  EAX := Temp1;
  EAX := EAX shr 1;
  Temp1 := EAX;
  if ((EAX and $FF00) and $100) = 0 then begin
   AL := 0;
   InputStream.Read(AL,1);
   dec(CryptLength);
   EAX := AL or $FF00;
   Temp1 := EAX;
  end;
  if ((Temp1 and $FF) and $1) <> 0 then begin
   InputStream.Read(AL,1);
   dec(CryptLength);
   OutputStream.Write(AL,1);
   SlidingWindow[SlidWindowIndex] := AL;
   inc(SlidWindowIndex);
   SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
  end else begin
   InputStream.Read(DI,1);
   InputStream.Read(AL,1);
   dec(CryptLength,2);
   ECX := (AL and $F0) shl 4;
   EDI := DI or ECX;
   EAX := ((not AL) and $F) + 2;
   Temp2 := EAX;
   ECX := 0;
   if EAX > 0 then begin
    while (ECX <= Temp2) do begin
     EAX := (ECX + EDI) and SlidWindowLength;
     AL := SlidingWindow[EAX];
     OutputStream.Write(AL,1);
     SlidingWindow[SlidWindowIndex] := AL;
     inc(SlidWindowIndex);
     SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
     inc(ECX);
    end;
   end;
  end;
 Result := True;
 end;

end;

function GLZSSDecode2;
{IStream - открытый поток, стоит на начале закриптованного участка,
CryptLength - количество байт в закриптованном участке}
var SlidingWindow : array of byte; {"Скользящее окно" с переменной длиной}
    Temp1, Temp2, EAX, ECX, EDI : integer;
    AL, DI : byte;
begin
 Result := False;
 SetLength(SlidingWindow,SlidWindowLength+1);
//WindowIndex := $3EE; {Начальный индекс окна}
 Temp1 := 0;
{Тут я предположил, что OStream уже открыт}
 while (CryptLength > 0) do begin
  EAX := Temp1;
  EAX := EAX shr 1;
  Temp1 := EAX;
  if ((EAX and $FF00) and $100) = 0 then begin
 {Если 9-й бит равен нулю, значит управляющее слово кончилось (или не
  загружалось, при первом проходе)}
 {Читаем управляющее слово}
   AL := 0;
   InputStream.Read(AL,1);
   dec(CryptLength);
   EAX := AL or $FF00;
   Temp1 := EAX;
  end;
 {Если очередной бит управляющего слова равен 1, значит очередной байт
  пишется в выходной поток без изменений}
  if ((Temp1 and $FF) and $1) <> 0 then begin
   InputStream.Read(AL,1);
   dec(CryptLength);
   OutputStream.Write(AL,1);
   SlidingWindow[SlidWindowIndex] := AL;
   inc(SlidWindowIndex);
   SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
 {Если очередной бит управляющего слова равен 0, значит мы юзаем
  "скользящее окно" для воспроизведения байт}
  end else begin
  {
   Логика такая: читается два байта
    1) базовый (биты 0-7)
    2) разделяемый
       биты 0-3 - количество итераций (байт)
       биты 4-7 - биты 8-12 базового адреса
    Далее начиная с базового адреса в скользящем окне читается в
    выходной поток столько байт сколько указано в кол-ве итераций + 2
    Нужно учесть, что скользящее окно циклически замкнуто (после
    индекса 1023 сразу идет индекс 0)
  }
   InputStream.Read(DI,1);
   InputStream.Read(AL,1);
   dec(CryptLength,2);
  
   EDI := ((DI shl 8) or AL) shr 4;
   EAX := (AL and $F) + 2;
   Temp2 := EAX;
   ECX := 0;
  
   if EAX > 0 then begin
    while (ECX < Temp2) do begin
     EAX := (ECX + EDI) and SlidWindowLength;
     AL := SlidingWindow[EAX];
     OutputStream.Write(AL,1);
     SlidingWindow[SlidWindowIndex] := AL;
     inc(SlidWindowIndex);
     SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
     inc(ECX);
    end;
   end;
  end;
  Result := True;
 end;
end;

function GLZSSDecode3;
{IStream - открытый поток, стоит на начале закриптованного участка,
CryptLength - количество байт в закриптованном участке}
var SlidingWindow : array of byte; {"Скользящее окно" с переменной длиной}
    Temp1, Temp2, EAX, ECX, EDI : integer;
    AX : word;
    AL : byte;
begin
 Result := False;
 SetLength(SlidingWindow,SlidWindowLength+1);
//WindowIndex := $3EE; {Начальный индекс окна}
 Temp1 := 0;
{Тут я предположил, что OStream уже открыт}
 while (CryptLength > 0) do begin
  EAX := Temp1;
  EAX := EAX shr 1;
  Temp1 := EAX;
  if ((EAX and $FF00) and $100) = 0 then begin
 {Если 9-й бит равен нулю, значит управляющее слово кончилось (или не
  загружалось, при первом проходе)}
 {Читаем управляющее слово}
   AL := 0;
   InputStream.Read(AL,1);
   dec(CryptLength);
   EAX := AL or $FF00;
   Temp1 := EAX;
  end;
 {Если очередной бит управляющего слова равен 1, значит очередной байт
  пишется в выходной поток без изменений}
  if ((Temp1 and $FF) and $1) <> 0 then begin
   InputStream.Read(AL,1);
   dec(CryptLength);
   OutputStream.Write(AL,1);
   SlidingWindow[SlidWindowIndex] := AL;
   inc(SlidWindowIndex);
   SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
 {Если очередной бит управляющего слова равен 0, значит мы юзаем
  "скользящее окно" для воспроизведения байт}
  end else begin
  {
   Логика такая: читается два байта
    1) базовый (биты 0-7)
    2) разделяемый
       биты 0-3 - количество итераций (байт)
       биты 4-7 - биты 8-12 базового адреса
    Далее начиная с базового адреса в скользящем окне читается в
    выходной поток столько байт сколько указано в кол-ве итераций + 2
    Нужно учесть, что скользящее окно циклически замкнуто (после
    индекса 1023 сразу идет индекс 0)
  }
   InputStream.Read(AX,2);
   dec(CryptLength,2);

   EDI := AX and $FFF;
   EAX := (AX shr $C) + 3;
   Temp2 := EAX;
   ECX := 0;
  
   if EAX > 0 then begin
    while (ECX < Temp2) do begin
     EAX := (ECX + EDI) and SlidWindowLength;
     AL := SlidingWindow[EAX];
     OutputStream.Write(AL,1);
     SlidingWindow[SlidWindowIndex] := AL;
     inc(SlidWindowIndex);
     SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
     inc(ECX);
    end;
   end;
  end;
  Result := True;
 end;
end;

// Модификация первой функции, для движка Overture
function GLZSSDecode_Overture;
var SlidingWindow : array of byte;
    Temp1, Temp2, EAX, ECX, EDI : integer;
    AL, DI : byte;
begin
 Result := False;
 SetLength(SlidingWindow,SlidWindowLength+1);
 if FillBuffer <> $100 then FillChar(SlidingWindow[0],SlidWindowLength+1,FillBuffer);
 Temp1 := 0;
 while (CryptLength > 0) do begin
  EAX := Temp1;
  EAX := EAX shr 1;
  Temp1 := EAX;
  if ((EAX and $FF00) and $100) = 0 then begin
   AL := 0;
   InputStream.Read(AL,1);
   dec(CryptLength);
   EAX := AL or $FF00;
   Temp1 := EAX;
  end;
  if ((Temp1 and $FF) and $1) <> 0 then begin
   InputStream.Read(AL,1);
   dec(CryptLength);
   OutputStream.Write(AL,1);
   SlidingWindow[SlidWindowIndex] := AL;
   inc(SlidWindowIndex);
   SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
  end else begin
   InputStream.Read(DI,1);
   InputStream.Read(AL,1);
   dec(CryptLength,2);
   ECX := (AL and $F) shl 8;
   EDI := DI or ECX;
   EAX := (AL shr 4) + 2;
   Temp2 := EAX;
   ECX := 0;
   if EAX > 0 then begin
    while (ECX <= Temp2) do begin
     EAX := (ECX + EDI) and SlidWindowLength;
     AL := SlidingWindow[EAX];
     OutputStream.Write(AL,1);
     SlidingWindow[SlidWindowIndex] := AL;
     inc(SlidWindowIndex);
     SlidWindowIndex := SlidWindowIndex and SlidWindowLength;
     inc(ECX);
    end;
   end;
  end;
 Result := True;
 end;

end;

function GCLZ77Decode_2;
var
	bt, bt2, lzbyte : byte;
	dec_from_ptr, count_1, i : longword;
	readword : word;
	begin_position, point, buffer : longword;
	arr : array[0..2047] of byte;
begin
	buffer := 2048;
	begin_position := InputStream.Position;
//	SetLength(arr,buffer);
	repeat
	  InputStream.Read(bt,1);
		if bt >= $20 then
		begin
			if (bt and $80) <> 0 then
			begin
				count_1 := (bt shr 5) and 3;
				dec_from_ptr := (bt and $1F) shl 8;
				InputStream.Read(bt2,1);
				dec_from_ptr := dec_from_ptr or bt2;
			end
			else if (bt and $60) = $20 then
			begin
				dec_from_ptr := (bt shr 2) and 7;
				count_1 := bt and 3;
			end
			else if (bt and $60) = $40 then
			begin
        dec_from_ptr := 0;
        InputStream.Read(dec_from_ptr,1);
        count_1 := (bt and $1F) + 4;
			end
			else
			begin
        dec_from_ptr := 0;
        InputStream.Read(dec_from_ptr,1);
        dec_from_ptr := (longword(bt and $1F) shl 8 ) or dec_from_ptr;
        InputStream.Read(bt2,1);
        if bt2 = 254 then
        begin
					InputStream.Read(readword,2);
					readword := EndianSwap(readword) shr 16;
					count_1 := readword + 258;
        end
        else if bt2 = 255 then
        begin
					InputStream.Read(count_1,4);
					count_1 := EndianSwap(count_1);
        end
        else
        begin
          count_1 := longword(bt2) + 4;
        end;
			end;
			count_1 := count_1 + 3;
			if count_1 > 0 then
			begin
				OutputStream.Seek(0,soEnd);
				point := OutputStream.Position - (dec_from_ptr + 1);
				for i:=count_1 downto 1 do
				begin
					OutputStream.Position := point;
					point := point + 1;
					OutputStream.Read(lzbyte,1);
					OutputStream.Seek(0,soEnd);
					OutputStream.Write(lzbyte,1);
				end;
				OutputStream.Seek(0,soEnd);
			end;
		end
		else
		begin
			count_1 := 0;
			case bt of
				$1D:
					begin
					InputStream.Read(count_1,1);
					count_1 := count_1 + 30;
					end;
				$1E:
					begin
					InputStream.Read(readword,2);
					readword := EndianSwap(readword) shr 16;
					count_1 := readword + 286;
					end;
				$1F:
					begin
					InputStream.Read(count_1,4);
					count_1 := EndianSwap(count_1);
					end;
				else
					begin
					count_1 := bt + 1;
					end;
        end;
			while count_1 > buffer do
			begin
				InputStream.Read(arr,buffer);
				OutputStream.Write(arr,buffer);
				count_1 := count_1 - buffer;
			end;
      i := count_1;
			if count_1 > 0 then
			begin
				InputStream.Read(arr,count_1);
				OutputStream.Write(arr,i);
			end;
		end;
	until (InputStream.Position - begin_position) >= CryptLength;
//  SetLength(arr,0);
	Result := true;
end;

function GCLZ77Decode;
var
	bt, bt2, bt3, lzbyte : byte;
	dec_from_ptr, count_1, i : longword;
	readword : word;
	begin_position, point, buffer : longword;
	arr : array[0..2047] of byte;
begin
	buffer := 2048;
	begin_position := InputStream.Position;
//	SetLength(arr,buffer);
	repeat
	  InputStream.Read(bt,1);
		if bt >= $20 then
		begin
			if (bt and $80) <> 0 then
			begin
				count_1 := (bt shr 5) and 3;
				dec_from_ptr := (bt and $1F) shl 8;
				InputStream.Read(bt2,1);
				dec_from_ptr := dec_from_ptr or bt2;
			end
			else if (bt and $60) = $20 then
			begin
				dec_from_ptr := (bt shr 2) and 7;
				count_1 := bt and 3;
			end
			else if (bt and $60) = $40 then
			begin
				dec_from_ptr := (bt and $1F) shl 8;
				InputStream.Read(bt2,1);
				dec_from_ptr := dec_from_ptr or bt2;
				count_1 := 0;
				InputStream.Read(count_1,1);
				count_1 := count_1 + 4;
			end
			else
			begin
				dec_from_ptr := (bt and $1F) shl 8;
				InputStream.Read(bt2,1);
				dec_from_ptr := dec_from_ptr or bt2;
				InputStream.Read(bt2,1);
				InputStream.Read(bt3,1);
				count_1 := bt2 shl 8;
				count_1 := count_1 or bt3;
				InputStream.Read(bt2,1);
				InputStream.Read(bt3,1);
				count_1 := (count_1 shl 16) or (bt2 shl 8) or bt3;
			end;
			count_1 := count_1 + 3;
			if count_1 > 0 then
			begin
				OutputStream.Seek(0,soEnd);
				point := OutputStream.Position - (dec_from_ptr + 1);
				for i:=count_1 downto 1 do
				begin
					OutputStream.Position := point;
					point := point + 1;
					OutputStream.Read(lzbyte,1);
					OutputStream.Seek(0,soEnd);
					OutputStream.Write(lzbyte,1);
				end;
				OutputStream.Seek(0,soEnd);
			end;
		end
		else
		begin
			count_1 := 0;
			case bt of
				$1D:
					begin
					InputStream.Read(count_1,1);
					count_1 := count_1 + 30;
					end;
				$1E:
					begin
					InputStream.Read(readword,2);
					readword := EndianSwap(readword) shr 16;
					count_1 := readword + 286;
					end;
				$1F:
					begin
					InputStream.Read(count_1,4);
					count_1 := EndianSwap(count_1);
					end;
				else
					begin
					count_1 := bt + 1;
					end;
        end;
			while count_1 > buffer do
			begin
				InputStream.Read(arr,buffer);
				OutputStream.Write(arr,buffer);
				count_1 := count_1 - buffer;
			end;
      i := count_1;
			if count_1 > 0 then
			begin
				InputStream.Read(arr,count_1);
				OutputStream.Write(arr,i);
			end;
		end;
	until (InputStream.Position - begin_position) >= CryptLength;
//  SetLength(arr,0);
	Result := true;
end;

function ZLDecode(InputStream, OutputStream : TStream) : boolean;
var header : TZLHeader;
    compressed_size, dec_count, i, iterations_count, oldpos : longword;
    bb, uprbit_counter, uprbyte : byte;
    pos : longword;
    w : word;
begin
 result := False;
 //
 try
  InputStream.Read(header,sizeof(header));
 except
  // result := False;  // easy debug, man!
  exit;
 end;

 if header.ident<>$4C5A2020 then begin
  result := False;
  exit;
 end;

 pos:=0;
 uprbit_counter:=0;
 uprbyte:=0;
 compressed_size:=header.comp_size;

 repeat
  if uprbit_counter=0 then begin            // управляющие биты кончились?
   InputStream.Read(uprbyte,sizeof(uprbyte)); // читаем управляющий байт
   uprbit_counter := 8;                     // Счётчик управляющих бит на максимум
   inc(pos,sizeof(uprbyte));
  end;

 if uprbyte>=128 then begin  // нет
  InputStream.Read(bb,sizeof(bb));
  inc(pos,sizeof(bb));
  OutputStream.write(bb,sizeof(bb));
 end else begin // да
  InputStream.Read(w,sizeof(w)); // читаем из входного потока слово
  inc(pos,sizeof(w));
  dec_count:=w;
  iterations_count:=w and $000F;
  inc(iterations_count,2);
  dec_count:=dec_count shr 4; // биты 4-15 - вычитаемое количество байт
  dec_count:=dec_count+1;
  OutputStream.Seek(OutputStream.Position-dec_count,soFromBeginning); // смещаем указатель
  for i:=1 to iterations_count do begin
   OutputStream.Read(bb,sizeof(bb));
   oldpos := OutputStream.Position;
   OutputStream.Seek(OutputStream.Size,soFromBeginning);
   OutputStream.write(bb,sizeof(bb));
   if i<>iterations_count then OutputStream.Seek(oldpos,soFromBeginning);
  end;
 end;

 uprbyte:= uprbyte shl 1; // сдвигаем управляющий байт
 dec(uprbit_counter);     // вычитаем счётчик

 until pos>=compressed_size;
 result := True;
end;

function ZLC2Decode;
var compressed_size, dec_count, i, iterations_count, oldpos : longword;
    bb, uprbit_counter, uprbyte : byte;
    pos : longword;
    w1, w2 : byte;
begin
// result := False;

 pos:=0;
 uprbit_counter:=0;
 uprbyte:=0;
 compressed_size:=InputStream.Size;

 repeat
  if uprbit_counter=0 then begin            // управляющие биты кончились?
   InputStream.Read(uprbyte,sizeof(uprbyte)); // читаем управляющий байт
   uprbit_counter := 8;                     // Счётчик управляющих бит на максимум
   inc(pos,sizeof(uprbyte));
  end;

 if (uprbyte and $80) = 0 then begin  // нет
  InputStream.Read(bb,sizeof(bb));
  inc(pos,sizeof(bb));
  OutputStream.write(bb,sizeof(bb));
 end else begin // да
  InputStream.Read(w1,sizeof(w1));
  InputStream.Read(w2,sizeof(w2)); // читаем из входного потока слово
  inc(pos,2);
  iterations_count := w2 and $0F;
  inc(iterations_count,3);
  dec_count:=((longword(w2) and $F0) shl 4) or w1;
  OutputStream.Seek(OutputStream.Position-dec_count,soFromBeginning);
  for i:=1 to iterations_count do begin
   OutputStream.Read(bb,sizeof(bb));
   oldpos := OutputStream.Position;
   OutputStream.Seek(OutputStream.Size,soFromBeginning);
   OutputStream.write(bb,sizeof(bb));
   if i<>iterations_count then OutputStream.Seek(oldpos,soFromBeginning);
  end;
 end;

 uprbyte:= uprbyte shl 1; // сдвигаем управляющий байт
 dec(uprbit_counter);     // вычитаем счётчик

 until pos>=compressed_size;
// result := True;
end;

function ZunLZSSDecode;
var db, ds, do_, oo, c, bt, dr, dc : longword;
    d : array[0..8191] of byte;
    bsr : TBitstream;
begin
		db := 13;
		ds := 8191; // 2**$db - 1
    Result := true;
		if((InputStream.Size < 8) or (ol < 2)) then Exit;
		do_ := 1;
		oo := 0;

    Fillchar(d, 8192, $78);
		bsr := TBitstream.Create;
		while true do
    begin
      if bsr.GetBit(InputStream) > 0 then
      begin
        if oo >= ol then Break;
        bt := Byte(bsr.GetBits(InputStream, 8));
        Inc(oo);
        OutputStream.Write(bt, 1);
        d[do_] := bt;
        Inc(do_);
        do_ := do_ and ds;
      end
      else
      begin
        dr := bsr.GetBits(InputStream, db);
        if dr = 0 then Break;
        dc := bsr.GetBits(InputStream, 4) + 3;
        for c := 1 to dc do
        begin
          if oo >= ol then Break;
          bt := d[dr];
          Inc(dr);
          dr := dr and ds;
          Inc(oo);
          OutputStream.Write(bt, 1);
          d[do_] := bt;
          Inc(do_);
          do_ := do_ and ds;
        end;
      end;
    end;
    bsr.Destroy;
end;

constructor TBitstream.Create;
begin
  cByte := 0;
  cMask := 0;
end;

function TBitstream.GetBit;
begin
  if cMask = 0 then
  begin
    if Stream.Position < Stream.Size then
      Stream.Read(cByte,1)
    else
      cByte := 0;
    cMask := $80
  end;
  Result := cByte and cMask;
  cMask := cMask shr 1;
end;

function TBitstream.GetBits;
var lmask : longword;
    outbit : byte;
begin
  Result := 0;
  if Count < 0 then Exit;
  lmask := (1 shl Count) shr 1;
  while lmask <> 0 do
  begin
    outbit := GetBit(Stream);
    if outbit <> 0 then Result := Result or lmask;
    lmask := lmask shr 1;
  end;
end;

end.