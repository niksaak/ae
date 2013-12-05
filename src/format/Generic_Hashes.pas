{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Generic library for Hash functions
  
  Written by Nik, dsp2003 & w8m.
}
unit Generic_Hashes;

interface

uses Classes, Sysutils, AnimED_Math, ZlibEx;

// Используется в движке G2 а также в движке фирмы Alcot
 function Gainax_Hash(stream : TStream; begindword : longword) : longword;

// Подсчёт хеша имени для движка Majiro
procedure Majiro_hash_init;
 function Majiro_hash(filename : string) : longword;
procedure Majiro_hash_destroy;

 function Majiro_hash64(filename : string) : int64;

// Подсчёт хэша имени для движка AD32 (Hinatabokko)
 function ADPACK32_Hash(filename : string) : word;

// Подсчёт хэша имени для движка HIMAURI Script Engine (Exodus Guilty Alternative)
 function HIMAURI_Hash(filename : string; divisor : longword) : longword;

// Moved from AA_XP3_KiriKiri2
 function sAdler32Init : longint;
 function sAdler32(Stream : TStream; var Previous : longint) : longint;

// Moved from AnimED_Math
 function CRC32(fs: TStream): Integer;
 function CRC32String(str: string) : integer;

 function Kogado_crc16(filestream : TStream) : word;

type

 array256 = array[0..$FF] of longword;

var
  Majiro_Numbers   : array of longword;

implementation

function Gainax_Hash;
var b : byte;
    i : longword;
const K : array256 = (
$00000000, $77073096, $EE0E612C, $990951BA, $076DC419, $706AF48F, $E963A535, $9E6495A3,
$0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
$1DB71064, $6AB020F2, $F3B97148, $84BE41DE, $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
$136C9856, $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
$3B6E20C8, $4C69105E, $D56041E4, $A2677172, $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
$35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
$26D930AC, $51DE003A, $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
$2802B89E, $5F058808, $C60CD9B2, $B10BE924, $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,
$76DC4190, $01DB7106, $98D220BC, $EFD5102A, $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
$7807C9A2, $0F00F934, $9609A88E, $E10E9818, $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
$6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
$65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
$4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2, $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
$4369E96A, $346ED9FC, $AD678846, $DA60B8D0, $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
$5005713C, $270241AA, $BE0B1010, $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F,
$5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,
$EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
$E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8, $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
$F00F9344, $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB, $196C3671, $6E6B06E7,
$FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC, $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
$D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
$D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
$CB61B38C, $BC66831A, $256FD2A0, $5268E236, $CC0C7795, $BB0B4703, $220216B9, $5505262F,
$C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
$9B64C2B0, $EC63F226, $756AA39C, $026D930A, $9C0906A9, $EB0E363F, $72076785, $05005713,
$95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
$86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
$88085AE6, $FF0F6A70, $66063BCA, $11010B5C, $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
$A00AE278, $D70DD2EE, $4E048354, $3903B3C2, $A7672661, $D06016F7, $4969474D, $3E6E77DB,
$AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
$BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605, $CDD70693, $54DE5729, $23D967BF,
$B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D
);
begin
 begindword := not begindword;
 for i := 1 to stream.Size do
  begin
   stream.Read(b,1);
   b := b xor Byte(begindword and $FF);
   begindword := (begindword shr 8) xor K[b];
  end;
 result := not begindword;
end;

procedure Majiro_hash_init;
var ind, temp : longword;
    bt : byte;
begin
 if Length(Majiro_Numbers) <> 0 then Majiro_hash_destroy;
 SetLength(Majiro_Numbers,256);
 for ind := 0 to 255 do begin
  temp := ind;
  for bt := 1 to 8 do
   if (temp and $1) <> 0 then temp := (temp shr 1) xor $EDB88320 else temp := (temp shr 1);
  Majiro_Numbers[ind] := temp;
 end;
end;

procedure Majiro_hash_destroy;
begin
 if Length(Majiro_Numbers) = 0 then Exit;
 SetLength(Majiro_Numbers,0);
end;

function Majiro_Hash;
var temp, bnumber, len : longword;
begin
 if Length(Majiro_Numbers) = 0 then Majiro_hash_init;
 bnumber := $FFFFFFFF;
 for len := 1 to Length(filename) do begin
  temp := (bnumber and $FF) xor longword(Byte(filename[len]));
  bnumber := (bnumber shr 8) xor Majiro_Numbers[temp];
 end;
 Result := not bnumber;
end;

function Majiro_Hash64;
var temp : int64; len, bt : longword;
begin
 temp := -1;
 for len := 1 to Length(filename) do begin
  temp := temp xor int64(Byte(filename[len]));
  for bt := 1 to 8 do
   if (temp and $1) <> 0 then temp := (temp shr 1) xor $42F0E1EBA9EA3693 else temp := (temp shr 1);
 end;
 Result := not temp;
end;

function ADPACK32_Hash;
var i, j, len, lwork, symb : longword;
begin
 len := Length(filename);
 lwork := 0;
 for i := 1 to len do begin
  symb := longword(Byte(filename[i])) shl 8;
  if symb = 0 then Break;
  lwork := lwork xor symb;
  for j:=1 to 8 do
   if (lwork and $8000) = 0 then lwork := lwork shl 1 else lwork := (lwork*2) xor $1021;
 end;
 Result := Word(lwork and $FFFF);
end;

{ Adler32 checksum for TStream }
function sAdler32Init;
begin
 Result := zadler32(0,'',0);
end;

function sAdler32;
var H : Pointer;
begin
 GetMem(H, Stream.Size);
 Stream.Seek(0, soBeginning);
 Stream.ReadBuffer(H^, Stream.Size);
 Previous := zadler32(Previous, H^, Stream.Size);
 FreeMem(H, Stream.Size);
 Result := Previous;
end;

{ CRC32 calculation function - begin }
function CRC32;
const
 CRCBlock = 4096;
var CRCTable: array[0..255] of LongWord;
    c: LongWord;  //!!! this must be an unsigned 32-bits var!
    Block: array[0..CRCBlock-1] of Byte;
    i,j,bytesread: Integer;
begin
// this used to be the InitCRC procedure
 for i := 0 to 255 do begin
  c := i;
  for j:= 0 to 7 do begin
   if (c and 1) = 0 then c:= (c div 2)
   else c:= (c div 2) xor $EDB88320;
  end;
  CRCTable[i] := c;
 end;
// InitCRC procedure end;
 c:=$FFFFFFFF;
 fs.Position := 0;
 for i:=0 to (fs.Size div CRCBlock)+1 do begin
  bytesread := fs.Read(Block,CRCBlock);
  for j:=0 to bytesread-1 do c := CRCTable[(c and $FF) xor Block[j]] xor (((c and $FFFFFF00) div 256) and $FFFFFF);
 end;
 Result := c xor $FFFFFFFF;
end;
{ CRC32 calculation function - end }

function CRC32String;
var tmpStream : TStream;
begin
 tmpStream := TMemoryStream.Create;
 tmpStream.Write(str[1],Length(str));
 Result := CRC32(tmpStream);
 FreeAndNil(tmpStream);
end;

function HIMAURI_Hash;
var xvalue : integer;
    idx, len : byte;
begin
 Result := 0;
 xvalue := 1;
 len := Length(filename);
 for idx := 1 to len do begin
  if filename[idx] = #0 then Break;
  Result := Result xor (Integer(ShortInt(filename[idx]))*xvalue);
  xvalue := xvalue + $1F3;
 end;
 Result := (Result shr $B) xor Result;
 Result := Result mod divisor;
end;

function Kogado_crc16;
var b, b1, b2, i : byte;
begin
  Result := $FFFF;
  while filestream.Position < filestream.Size do
  begin
    filestream.Read(b,1);
    b1 := 0;
    b2 := b;
    for i := 1 to 8 do
    begin
      b1 := (b1 shl 1) or (b2 and 1);
      b2 := b2 shr 1;
    end;
    Result := Result xor (word(b1) shl 8);
    for i := 1 to 8 do
      if (Result and $8000) <> 0 then
      begin
        Result := (Result shr 1) xor $1021;
      end
      else
      begin
        Result := Result shr 1;
      end;
  end;
end;

end.