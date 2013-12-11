{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.
  
  CaramelBox archives format

  Originally written by w8m.
  Ported by Nik.
}

unit AA_Dat_CaramelBox;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_DAT_CaramelBox(var ArcFormat : TArcFormats; index : integer);

 function OA_DAT_CaramelBox : boolean;
 function SA_DAT_CaramelBox(Mode : integer) : boolean;
 function EA_DAT_CaramelBox(FileRecord : TRFA) : boolean;

 procedure lzUnpack(InputStream, OutputStream : TStream; globalsize : longword);
 procedure lzBlockUnpack(InputStream, OutputStream : TStream; blocksize : word);
 function lz_num(InputStream : TStream) : longword;
 function lz_bit(InputStream : TStream) : word;

type

 TARC3Header = packed record
   Magic : array[1..4] of char; // 'arc3'
   Ver : longword; // 1 (нет длинных файлов) или 2 (есть длинные файлы и longinfo.$$$)
   Align : longword; // размер блока
   Files_offset :longword; // оффсет данных? (в блоках)
   ArcSize : longword; // размер архива (в блоках)
   Unk1 : longword; // 0
   Table_Offset : longword; // смещение таблицы (в блоках)
   Table_Size : longword; // размер таблицы (в байтах)
   Table_BlockSize : longword; // размер таблицы (в блоках)
   FilesCount : longword; // кол-во файлов
   Unk2 : longword; // 0
   Unk3 : byte; // 1
   Unk4 : byte; // 1
 end;

 TARC3FileHeader = packed record
   SizeInBlocks :longword;
   SizeInBytes1 : longword;
   SizeInBytes2 : longword;
   Date1 : longword;
   Date2 : longword;
   Method : longword;
   {
     0 - файл как есть (но, может быть обёрнут в lz)
     1 - ?
     2 - xor $FF
     3 - ?
   }
   Zero1 : longword; // 0
   Zero2 : longword; // 0
 end;

 TLZGlobalheader = packed record
   Magic : array[1..2] of char; // 'lz'
   Size : longword;
 end;

 TLZBlockheader = packed record
   Magic : array[1..2] of char; // 'ze'
   Size : word;
 end;

var
  CaramelBox_lz_word : word;
  CaramelBox_lz_numbit : byte;

implementation

uses AnimED_Archives;

procedure IA_DAT_CaramelBox;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'CaramelBox arc3';
  Ext  := '.dat';
  Stat := $F;
  Open := OA_DAT_CaramelBox;
  Save := SA_DAT_CaramelBox;
  Extr := EA_DAT_CaramelBox;
  FLen := 0;
  SArg := 0;
  Ver  := $20100204;
 end;
end;

procedure lzUnpack;
var bh : TLZBlockheader;
begin
  while OutputStream.Size < globalsize do
  begin
    CaramelBox_lz_word := 0;
    CaramelBox_lz_numbit := 0;
    InputStream.Read(bh, sizeof(bh));
    if bh.Magic <> 'ze' then break;
    bh.Size := Word(EndianSwap(Integer(bh.Size)) shr 16);
    lzBlockUnpack(InputStream, OutputStream, bh.Size);
  end;
end;

function lz_bit;
begin
  if CaramelBox_lz_numbit = 0 then
  begin
    if InputStream.Position = InputStream.Size then
      begin
        Result := 0;
        Exit;
      end;
    CaramelBox_lz_numbit := 16;
    InputStream.Read(CaramelBox_lz_word,2);
    CaramelBox_lz_word := Word(EndianSwap(Integer(CaramelBox_lz_word)) shr 16);
  end;
  Result := (CaramelBox_lz_word and $8000) shr 15;
  CaramelBox_lz_word := CaramelBox_lz_word shl 1;
  Dec(CaramelBox_lz_numbit);
end;

function lz_num;
var c : longword;
begin
  Result := 1;
  c := 1;
  while lz_bit(InputStream) = 0 do
  begin
    if c >= $20 then
    begin
      Result := 0;
      Exit;
    end;
    Inc(c);
  end;
  Dec(c);
  while c > 0 do
  begin
    Result := Result + Result + lz_bit(InputStream);
    Dec(c);
  end;
end;

procedure lzBlockUnpack;
var n, dist, a : longword;
begin
  while blocksize > 0 do
  begin
    n := lz_num(InputStream);
    if n = 0 then Exit;
    Dec(n);
    while n > 0 do
    begin
      a := 1;
      repeat
        a := a + a + lz_bit(InputStream);
      until a >= $100;
      OutputStream.Write(a,1);
      Dec(blocksize);
      if blocksize = 0 then Exit;
      Dec(n);
    end;
    dist := lz_num(InputStream);
    n := lz_num(InputStream);
    if (dist = 0) or (n = 0) then Exit;
    repeat
      OutputStream.Position := OutputStream.Position - dist;
      OutputStream.Read(a,1);
      OutputStream.Position := OutputStream.Size;
      OutputStream.Write(a,1);
      Dec(n);
      Dec(blocksize);
      if blocksize = 0 then Exit;
    until n <= 0;
  end;
end;

function OA_DAT_CaramelBox;
var Header : TARC3Header;
    FileHeader : TARC3FileHeader;
    tblbegin, work, curfile, next, i, dblqty : longword;
    ind : integer;
    bwork, bwork2, bwork_s, bwork_s2 : byte;
    crazydata : array[1..6] of byte;
    str1, str2, tempstr : string;
    LoginfoRFA : TRFA;
    LoginfoStream : TStream;
    Lengths : array of longword;
    List1, List2 : TStringList;
begin
 Result := False;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header, Sizeof(Header));

 Header.Ver := EndianSwap(Header.Ver);
 Header.Align := EndianSwap(Header.Align);
 Header.Files_offset := EndianSwap(Header.Files_offset);
 Header.ArcSize := EndianSwap(Header.ArcSize);
 Header.Unk1 := EndianSwap(Header.Unk1);
 Header.Table_Offset := EndianSwap(Header.Table_Offset);
 Header.Table_Size := EndianSwap(Header.Table_Size);
 Header.Table_BlockSize := EndianSwap(Header.Table_BlockSize);
 Header.FilesCount := EndianSwap(Header.FilesCount);
 Header.Unk2 := EndianSwap(Header.Unk2);

 if (Header.Magic <> 'arc3') or (Header.Ver < 1)
     or (Header.Ver > 2) or (Header.Align = 0) then Exit;
 tblbegin := Header.Table_Offset * Header.Align;
 if tblbegin >= ArchiveStream.Size then Exit;
 ArchiveStream.Position := tblbegin;
 
 RecordsCount := Header.FilesCount;
{*}Progress_Max(RecordsCount);
 
 work := Header.Table_Size;
 curfile := 0;
 SetLength(str1,3);
 LoginfoRFA.RFA_3 := '';
 while work > 0 do
 begin
   Inc(curfile);
{*}Progress_Pos(curfile);
   ArchiveStream.Read(bwork_s,1);
   bwork_s := bwork_s - $F0;
   if (bwork_s <= 0) or (bwork_s = $F) or ((work - 7) < bwork_s) then break;
   work := work - bwork_s - 7;
   SetLength(tempstr, bwork_s);
   ArchiveStream.Read(tempstr[1], bwork_s);
   CopyMemory(@str1[1], @tempstr[1],3);
   SetLength(str2, bwork_s-3);
   CopyMemory(@str2[1], @tempstr[4], bwork_s-3);
   ArchiveStream.Read(crazydata[1],6);
   RFA[curfile].RFA_3 := str2 + '.' + str1;
   if RFA[curfile].RFA_3 = 'longinfo.$$$' then
   begin
     LoginfoRFA.RFA_3 := 'longinfo.$$$';
     LoginfoRFA.RFA_1 := (crazydata[1] shl 16) + (crazydata[2] shl 8) + crazydata[3];
     Dec(curfile);
{*}  Progress_Max(RecordsCount-1);
{*}  Progress_Pos(curfile);
   end
   else
   begin
     RFA[curfile].RFA_1 := (crazydata[1] shl 16) + (crazydata[2] shl 8) + crazydata[3];
   end;
   next := (crazydata[4] shl 16) + (crazydata[5] shl 8) + crazydata[6];
   if next = 0 then next := Header.Table_Size;
   bwork_s2 := bwork_s;
   while true do
   begin
     if (ArchiveStream.Position - tblbegin) >= next then
     begin
       if (ArchiveStream.Position - tblbegin) > next then Exit;
       break;
     end;
     Inc(curfile);
{*}  Progress_Pos(curfile);
     if work < 4 then
     begin
       work := 0;
       break;
     end;
     work := work - 4;
     
     ArchiveStream.Read(bwork,1);
     bwork2 := (bwork and $F0) shr 4;
     bwork := bwork and $F;
     if bwork2 = $F then
     begin
       if bwork <> $F then Exit;
       tempstr[bwork_s] := Chr(Ord(tempstr[bwork_s])+1);
     end
     else
     begin
       if (bwork_s2 < (bwork + bwork2)) then
       begin
         SetLength(tempstr, bwork + bwork2);
         bwork_s2 := bwork + bwork2;
       end;
       if (work < bwork) or ((bwork + bwork2) = 0) or ((bwork + bwork2) >= $E) then Exit;
       work := work - bwork;
       ArchiveStream.Read(tempstr[bwork2+1],bwork);
       bwork_s := bwork + bwork2;
     end;
     ArchiveStream.Read(crazydata[1],3);
     CopyMemory(@str1[1], @tempstr[1],3);
     SetLength(str2, bwork_s-3);
     CopyMemory(@str2[1], @tempstr[4], bwork_s-3);
     RFA[curfile].RFA_3 := str2 + '.' + str1;
     if RFA[curfile].RFA_3 = 'longinfo.$$$' then
     begin
       LoginfoRFA.RFA_3 := 'longinfo.$$$';
       LoginfoRFA.RFA_1 := (crazydata[1] shl 16) + (crazydata[2] shl 8) + crazydata[3];
       Dec(curfile);
{*}    Progress_Max(RecordsCount-1);
{*}    Progress_Pos(curfile);
     end
     else
     begin
       RFA[curfile].RFA_1 := (crazydata[1] shl 16) + (crazydata[2] shl 8) + crazydata[3];
     end;
   end;
 end;

 if LoginfoRFA.RFA_3 = 'longinfo.$$$' then
 begin
   Dec(RecordsCount);
   ArchiveStream.Position := (Header.Files_offset + LoginfoRFA.RFA_1)*Header.Align;
   ArchiveStream.Read(FileHeader, sizeof(FileHeader));
   LoginfoRFA.RFA_1 := ArchiveStream.Position;
   FileHeader.SizeInBlocks := EndianSwap(FileHeader.SizeInBlocks);
   FileHeader.SizeInBytes1 := EndianSwap(FileHeader.SizeInBytes1);
   FileHeader.SizeInBytes2 := EndianSwap(FileHeader.SizeInBytes2);
   FileHeader.Date1 := EndianSwap(FileHeader.Date1);
   FileHeader.Date2 := EndianSwap(FileHeader.Date2);
   FileHeader.Method := EndianSwap(FileHeader.Method);

   LoginfoRFA.RFA_2 := FileHeader.SizeInBytes1;  // могу и ошибаться
   LoginfoRFA.RFA_C := FileHeader.SizeInBytes2;  // могу и ошибаться
   LoginfoRFA.RFA_X := FileHeader.Method;
   if FileHeader.Method > 0 then LoginfoRFA.RFA_E := true;
   FileDataStream := TMemoryStream.Create;
   EA_DAT_CaramelBox(LoginfoRFA);
   LoginfoStream := FileDataStream;
   FileDataStream := nil;
   LoginfoStream.Position := 0;
   LoginfoStream.Read(dblqty,4);
   SetLength(Lengths,dblqty*2+1);
   LoginfoStream.Read(Lengths[0],dblqty*8);
   Lengths[dblqty*2] := LoginfoStream.Size - (dblqty*8 + 4);
   List1 := TStringList.Create;
   List2 := TStringList.Create;
   for i := 0 to dblqty-1 do
   begin
     SetLength(tempstr, Lengths[i*2+1] - Lengths[i*2]);
     LoginfoStream.Read(tempstr[1],Length(tempstr));
     List1.Insert(i,tempstr);
     SetLength(tempstr, Lengths[i*2+2] - Lengths[i*2+1]);
     LoginfoStream.Read(tempstr[1],Length(tempstr));
     List2.Insert(i,tempstr);
   end;
 end;

 for i := 1 to RecordsCount do
 begin
   ArchiveStream.Position := (Header.Files_offset + RFA[i].RFA_1)*Header.Align;
   ArchiveStream.Read(FileHeader, sizeof(FileHeader));
   RFA[i].RFA_1 := ArchiveStream.Position;
   FileHeader.SizeInBlocks := EndianSwap(FileHeader.SizeInBlocks);
   FileHeader.SizeInBytes1 := EndianSwap(FileHeader.SizeInBytes1);
   FileHeader.SizeInBytes2 := EndianSwap(FileHeader.SizeInBytes2);
   FileHeader.Date1 := EndianSwap(FileHeader.Date1);
   FileHeader.Date2 := EndianSwap(FileHeader.Date2);
   FileHeader.Method := EndianSwap(FileHeader.Method);
{   if (FileHeader.Method = 1) then begin MessageBox(0, 'Обнаружен метод 1', 'Неопознанный метод', 0); Exit; end;
   if (FileHeader.Method = 3) then begin MessageBox(0, 'Обнаружен метод 3', 'Неопознанный метод', 0); Exit; end;}

   RFA[i].RFA_2 := FileHeader.SizeInBytes1;  // могу и ошибаться
   RFA[i].RFA_C := FileHeader.SizeInBytes2;  // могу и ошибаться
   RFA[i].RFA_X := FileHeader.Method;
   if FileHeader.Method > 0 then RFA[i].RFA_E := true;
   if LoginfoRFA.RFA_3 = 'longinfo.$$$' then
   begin
     ind := List1.IndexOf(RFA[i].RFA_3);
     if ind <> -1 then RFA[i].RFA_3 := List2[ind];
   end;
 end;

 if LoginfoRFA.RFA_3 = 'longinfo.$$$' then
 begin
   FreeAndNil(List1);
   FreeAndNil(List2);
 end;
 
 Result := True;

end;

function SA_DAT_CaramelBox;
begin
 Result := True;
end;

function EA_DAT_CaramelBox;
var TempoStream, OutStream : TStream;
    gh : TLZGlobalheader;
begin
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then begin
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_X of
   2: begin
          TempoStream := TMemoryStream.Create;
          TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
          TempoStream.Position := 0;
          BlockXORDirect(TempoStream, $FF);
          TempoStream.Position := 0;
          FileDataStream.CopyFrom(TempoStream,TempoStream.Size);
          FreeAndNil(TempoStream);
         end;
   0, 1, 3: begin
          TempoStream := TMemoryStream.Create;
          TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
          TempoStream.Position := 0;
          TempoStream.Read(gh,sizeof(gh));
          if gh.Magic = 'lz' then
          begin
            gh.Size := EndianSwap(gh.Size);
            OutStream := TMemoryStream.Create;
            lzUnpack(TempoStream,OutStream, gh.Size);
            OutStream.Position := 0;
            FileDataStream.CopyFrom(OutStream,OutStream.Size);
            FreeAndNil(OutStream);
          end
          else
          begin
            TempoStream.Position := 0;
            FileDataStream.CopyFrom(TempoStream,TempoStream.Size);
          end;
          FreeAndNil(TempoStream);
         end;
  end;
 end
 else raise Exception.Create('Debug: internal error. ArchiveStream or FileDataStream is NIL.');
 Result := True;
end;

end.