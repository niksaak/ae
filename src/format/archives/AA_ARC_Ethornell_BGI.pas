{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Ethornell Buriko General Interpreter archive formats & functions
  
  Written by dsp2003 & Nik.
}

unit AA_ARC_Ethornell_BGI;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     AnimED_Graphics,
     AG_Fundamental,
     AG_StdFmt,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_ARC_Ethornell_BGI(var ArcFormat : TArcFormats; index : integer);
 procedure IA_ARC_Ethornell_BGI2(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_Ethornell_BGI : boolean;
  function SA_ARC_Ethornell_BGI(Mode : integer) : boolean;

  function OA_ARC_Ethornell_BGI2 : boolean;
  function SA_ARC_Ethornell_BGI2(Mode : integer) : boolean;

  function EA_ARC_Ethornell_BGI(FileRecord : TRFA) : boolean;

  function DecodeDSC(InputStream, OutputStream : TStream) : boolean;
  function CountNumber(var STNum : longword) : longword;
  
  // Функция декодирования Compressed BG
  function CountNumber2(var STNum : longword) : longword;
  function CountData(Stream : TStream) : longword;
  function DecodeCBG(InputStream, OutputStream : TStream) : boolean;
  
type
{ Ethornell Buriko General Interpreter archive format description }
 // Version 1 - "PackFile"+$20+$20+$20+$20
 // Version 2 - "BURIKO ARC20"
 TBurikoHdr = packed record
  Header : array[1..12] of char; //"PackFile"+$20+$20+$20+$20
  TotalRecords : longword;
 end;
 TBurikoDir = packed record
  FileName : array[1..16] of char;
  Offset   : longword;
  Filesize : longword;
  Dummy    : int64;
 end;
 TBurikoDirv2 = packed record
  FileName : array[1..96] of char;
  Offset   : longword;
  Filesize : longword;
  Dummy    : array[1..3] of int64;
 end;

 TBGI_DSCHeader = packed record
   Magic : array[1..$10] of char; // 'DSC FORMAT 1.00'#0
   HelpNumber : longword; // по этому числу чегото вычисляется
   // расширяется до 6 байт словом 'SD' ($4453)
   DecryptedSize : longword; // расшифрованный размер
   PassCount : longword; // предел цикла расшифровки
   Dummy : longword; // 0
 end;
 
 TBGI_CBGHeader = packed record
    Magic : array[1..$10] of char; // 'CompressedBG___'#0
    Width : word;
    Height : word;
    BPP : longword;	// Размерность изображения
    Dummy1 : longword; // 0
    Dummy2 : longword; // 0
    ZLen : longword;
    Key : longword;
    ELen : longword;
    SCSum : byte;
    XCSum : byte;
    Dummy3 : word;
 end;

 TBGI_HuffmanTreeNode = record
   Val : boolean;
   Fr : longword;
   Left : longword;
   Right : longword;
 end;      

implementation

uses AnimED_Archives;

procedure IA_ARC_Ethornell_BGI;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Ethornell Buriko General Interpreter v1';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_Ethornell_BGI;
  Save := SA_ARC_Ethornell_BGI;
  Extr := EA_ARC_Ethornell_BGI;
  FLen := 16;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

procedure IA_ARC_Ethornell_BGI2;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Ethornell Buriko General Interpreter v2';
  Ext  := '.arc';
  Stat := $0;
  Open := OA_ARC_Ethornell_BGI2;
  Save := SA_ARC_Ethornell_BGI2;
  Extr := EA_ARC_Ethornell_BGI;
  FLen := 96;
  SArg := 0;
  Ver  := $20130816;
 end;
end;

function OA_ARC_Ethornell_BGI;
{ Burriko ARC archive opening function }
var i,j : integer;
    Hdr  : TBurikoHdr;
    Dir  : TBurikoDir;
    MiniBuffer : array[1..8] of char;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);

  with Hdr do begin
   Read(Hdr,SizeOf(Hdr));

   if Header <> 'PackFile'#32#32#32#32 then Exit;

   RecordsCount := TotalRecords;
   ReOffset := SizeOf(Hdr) + SizeOf(Dir)*RecordsCount;

  end;
{*}Progress_Max(RecordsCount);
// Reading Buriko filetable...
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin
   Read(Dir,SizeOf(Dir));
   for j := 1 to 16 do begin
    if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
   RFA[i].RFA_1 := Offset+ReOffset;
   RFA[i].RFA_2 := FileSize;
   RFA[i].RFA_C := FileSize; // replicates filesize
  end;
 end;
 // определяем компрессию
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  Position := RFA[i].RFA_1;
  Read(MiniBuffer,SizeOf(MiniBuffer));

  if MiniBuffer = 'DSC FORM' then begin
   RFA[i].RFA_E := True;
   RFA[i].RFA_X := $DC;
  end else if MiniBuffer = 'Compress' then begin
   RFA[i].RFA_E := True;
   RFA[i].RFA_X := $CB;
  end;
 end; // for
end; // with ArchiveStream
Result := True;
end;

function OA_ARC_Ethornell_BGI2;
{ Burriko ARC version 2 archive opening function }
var i,j : integer;
    Hdr  : TBurikoHdr;
    Dir  : TBurikoDirV2;
    MiniBuffer : array[1..8] of char;
begin
 Result := False;
 with ArchiveStream do begin
  Seek(0,soBeginning);

  with Hdr do begin
   Read(Hdr,SizeOf(Hdr));

   if Header <> 'BURIKO ARC20' then Exit;

   RecordsCount := TotalRecords;
   ReOffset := SizeOf(Hdr) + SizeOf(Dir)*RecordsCount;

  end;
{*}Progress_Max(RecordsCount);
// Reading Buriko filetable...
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin
   Read(Dir,SizeOf(Dir));
   for j := 1 to 16 do begin
    if FileName[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + FileName[j] else break;
   end;
   RFA[i].RFA_1 := Offset+ReOffset;
   RFA[i].RFA_2 := FileSize;
   RFA[i].RFA_C := FileSize; // replicates filesize
  end;
 end;
 // определяем компрессию
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  Position := RFA[i].RFA_1;
  Read(MiniBuffer,SizeOf(MiniBuffer));

  if MiniBuffer = 'DSC FORM' then begin
   RFA[i].RFA_E := True;
   RFA[i].RFA_X := $DC;
  end else if MiniBuffer = 'Compress' then begin
   RFA[i].RFA_E := True;
   RFA[i].RFA_X := $CB;
  end;
 end; // for
end; // with ArchiveStream
Result := True;
end;

function SA_ARC_Ethornell_BGI;
{ Burriko ARC archive creating function }
var i, j : integer;
    Hdr : TBurikoHdr;
    Dir : TBurikoDir;
begin
 with Hdr do begin
  Header := 'PackFile'#32#32#32#32;
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;

  TotalRecords := RecordsCount;

  RFA[1].RFA_1 := 0;
  UpOffset := 0;
 end;
//Writing header
 ArchiveStream.Write(Hdr,SizeOf(Hdr));
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_2   := FileDataStream.Size;
   Offset         := RFA[i].RFA_1;
   FileSize       := RFA[i].RFA_2;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]);
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to 16 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   Dummy := 0;
   FreeAndNil(FileDataStream);
// Writing buriko filetable...
   ArchiveStream.Write(Dir,SizeOf(Dir));
  end;
 end;

//Writing file...
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function SA_ARC_Ethornell_BGI2;
{ Burriko ARC archive creating function }
var i, j : integer;
    Hdr : TBurikoHdr;
    Dir : TBurikoDirv2;
begin
 with Hdr do begin
  Header := 'BURIKO ARC20';
  RecordsCount := AddedFiles.Count;
  ReOffset := SizeOf(Hdr)+SizeOf(Dir)*RecordsCount;

  TotalRecords := RecordsCount;

  RFA[1].RFA_1 := 0;
  UpOffset := 0;
 end;
//Writing header
 ArchiveStream.Write(Hdr,SizeOf(Hdr));
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  with Dir do begin
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   UpOffset       := UpOffset + FileDataStream.Size;
   RFA[i+1].RFA_1 := UpOffset;
   RFA[i].RFA_2   := FileDataStream.Size;
   Offset         := RFA[i].RFA_1;
   FileSize       := RFA[i].RFA_2;
   RFA[i].RFA_3   := ExtractFileName(AddedFiles.Strings[i-1]);
   FillChar(FileName,SizeOf(FileName),0);
   for j := 1 to 96 do if j <= length(RFA[i].RFA_3) then FileName[j] := RFA[i].RFA_3[j] else break;
   for j := 1 to 3 do Dummy[i] := 0;
   FreeAndNil(FileDataStream);
// Writing buriko filetable...
   ArchiveStream.Write(Dir,SizeOf(Dir));
  end;
 end;

//Writing file...
 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
  ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
  FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

function EA_ARC_Ethornell_BGI;
var TempoStream, TempoStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  // фикс для распаковки файлов нулевой длины
  if (FileRecord.RFA_C > 0) and (FileRecord.RFA_1 <= ArchiveStream.Size) then begin
   ArchiveStream.Position := FileRecord.RFA_1;
   case FileRecord.RFA_E of
    True: begin
           TempoStream := TMemoryStream.Create;
           TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
           TempoStream.Position := 0;
           TempoStream2 := TMemoryStream.Create;
           case FileRecord.RFA_X of
            $CB : DecodeCBG(TempoStream, TempoStream2);
            $DC : DecodeDSC(TempoStream, TempoStream2);
           end;
           TempoStream2.Position := 0;
           FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
           FreeAndNil(TempoStream2);
           FreeAndNil(TempoStream);
          end;
  { Файл не шифрован\не сжат... }
    False: FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
   end;
  end;
 except
  { улыбаемся и машем }
 end;
 Result := True;

end;

function CountNumber;
var HNum, work, work2, work3 : longword;
begin
  work := 20021 * (STNum and $FFFF);
  HNum := (((STNum and $FFFF0000) shr 16) or $44530000) * 20021;
  work2 := STNum * 346 + HNum;
  work2 := work2 + (work shr 16);
  work := work and $FFFF;
  work3 := work2 and $FFFF;
  Result := work2 and $7FFF;
  work3 := work3 shl 16;
  STNum := work + work3 + 1;
end;

function DecodeDSC;
var Header : TBGI_DSCHeader;
    STNum, Counted, cnt, cnt2, dcnt2, cnt3, cnta1, i, worknum,
      worknum2, cnta2, w10, w11, sav, wcnt1, wcnt2,
      wword, condit, scnta2, count16, wc, bufc, ecnt, bufc2, n2,
      incnt, passcnt, dbufc1, j, coucbyte, w9, outpos, cntout : longword;
    Si12, Si34, w17, w18 : integer;
    BufArr : array[0..$FFB] of longword;
    Arr1 : array[0..512] of longword;
    Arr2 : array[0..1023] of longword;
    INBuf : array of byte;
    wbyte, stbyte, cbyte, cbyte2, cbyte3, rb : byte;
    word16 : word;
begin
  Result := false;
  InputStream.Read(Header, sizeof(Header));
  if Header.Magic <> 'DSC FORMAT 1.00'#0 then Exit;
  FillChar(BufArr[0], $3FF0, 0);
  SetLength(INBuf, InputStream.Size - sizeof(Header));
  InputStream.Read(INBuf[0], InputStream.Size - sizeof(Header));

  // Генерация BufArr
  FillChar(Arr1[0], 513*4, 0);
  FillChar(Arr2[0], 1024*4, 0);
  STNum := Header.HelpNumber;
  cnt := 0;
  cnt2 := 0;
  while cnt < 512 do
  begin
    Counted := CountNumber(STNum);
    wbyte := Byte(Counted and $FF);
    wbyte := INBuf[cnt] - wbyte;
    if wbyte <> 0 then
    begin
      Arr1[cnt2] := cnt + (wbyte shl 16);
      Inc(cnt2);
    end;
    Inc(cnt);
  end;
  dcnt2 := cnt2;
  
  // сортировка десу
  if (cnt2-1) > 0 then
  begin
    cnta1 := 0;
    cnt3 := 1;
    while (cnt3-1)<(cnt2-1) do
    begin
      for i := cnt3 to cnt2-1 do
      begin
        worknum := Arr1[cnta1];
        worknum2 := Arr1[i];
        if worknum2 < worknum then
        begin
          Arr1[cnta1] := worknum2;
          Arr1[i] := worknum;
        end;
      end;
      Inc(cnta1);
      Inc(cnt3);
    end;
  end;

  Si12 := 1;
  Si34 := 1;
  w10 := 0;
  w11 := 0;
  ecnt := 0;
  condit := 0;
  
  if cnt2 > 0 then
  begin
    cnta2 := 0;
    while true do
    begin
      worknum := w10 xor $200;
      sav := worknum;
      wcnt1 := w11;
      wcnt2 := worknum;
      wword := (Arr1[wcnt1] shr 16) and $FFFF;
      scnta2 := wcnt2;
      count16 := 0;
      while condit = wword do
      begin
        bufc := 4*Arr2[cnta2];
        wc := Arr1[wcnt1] and $1FF;
        Inc(cnta2);
        BufArr[bufc] := 0;
        BufArr[bufc+1] := wc; 
        Inc(count16);
        Inc(wcnt1);
        Inc(ecnt);
        wword := (Arr1[wcnt1] shr 16) and $FFFF;
      end;
      w17 := si34 - count16;
      w18 := 2*w17;
      if count16 < si34 then
      begin
        si34 := w17;
        while si34 <> 0 do
        begin
           bufc2 := 4*Arr2[cnta2];
           Inc(cnta2);
           n2 := 2;
           BufArr[bufc2] := 1;
           Inc(bufc2,2);
           while n2 > 0 do
           begin
             Arr2[wcnt2] := si12;
             BufArr[bufc2] := si12;
             Inc(wcnt2);
             Inc(bufc2);
             Inc(si12);
             Dec(n2);
           end;
           Dec(si34);
        end;
      end;
      w11 := ecnt;
      si34 := w18;
      Inc(condit);
      if ecnt >= dcnt2 then Break;
      w10 := sav;
      cnta2 := scnta2;
    end;
  end;
  // \ Генерация BufArr

  incnt := $200;
  cbyte := 0;
  passcnt := 0;

  while passcnt < Header.PassCount do
  begin
    dbufc1 := 0;
    repeat
      if cbyte = 0 then
      begin
        cbyte := 8;
        cbyte2 := INBuf[incnt];
        Inc(incnt);
      end;
      Dec(cbyte);
      dbufc1 := BufArr[2+(Byte(cbyte2 shr 7) + dbufc1*4)];
      cbyte2 := cbyte2 * 2;
    until BufArr[dbufc1*4] = 0;
    word16 := Word(BufArr[dbufc1*4+1]);
    if (word16 and $100) <> 0 then
    begin
      w9 := cbyte2 shr (8-cbyte);
      cbyte3 := cbyte;
      if cbyte < 12 then
      begin
        j := ((11 - cbyte) shr 3) +1;
        coucbyte := cbyte + 8*j;
        while j <> 0 do
        begin
          w9 := INBuf[incnt] + (w9 shl 8);
          inc(incnt);
          Dec(j);
        end;
      end;
      cbyte := coucbyte - 12;
      cbyte2 := Byte(Byte(w9) shl (8-cbyte));
      outpos := OutputStream.Position - 2 - (w9 shr cbyte);
      cntout := (word16 and $FF) + 2;
      while cntout > 0 do
      begin
        OutputStream.Position := outpos;
        OutputStream.Read(rb,1);
        OutputStream.Position := OutputStream.Size;
        OutputStream.Write(rb,1);
        Inc(outpos);
        Dec(cntout);
      end;
    end
    else
    begin
      OutputStream.Write(word16,1);
    end;
    Inc(passcnt);
  end;
 SetLength(INBuf, 0);
 Result := true;
end;

function CountNumber2;
var work, work2, work3 : longword;
begin
  work := 20021 * (STNum and $FFFF);
  work2 := 20021 * (STNum shr $10);
  work3 := 346 * STNum + work2 + (work shr $10);
  STNum := (work3 shl $10) + (work and $FFFF) + 1;
  Result := work3 and $7FFF;
end;

function CountData;
var cur : byte;
    shift : longword;
begin
  cur := $FF;
  shift := 0;
  Result := 0;
  while (cur and $80) <> 0 do
  begin
    Stream.Read(cur,1);
    Result := Result or ((cur and $7F) shl shift);
    shift := shift + 7;
  end;
end;

function DecodeCBG;
var Header : TBGI_CBGHeader;
    INBuf : array of byte;
    i, j, HuffKeyNum, FTotal, nodes, min, frec, root, mask, node, len, line, x, y, pos : longword;
    Fr : array[0..255] of longword;
    HummfArr, DummyArr : array of byte;
    workb, workb2, zero, colors : byte;
    NodesArr : array[0..510] of TBGI_HuffmanTreeNode;
    ch : array[0..1] of longword;
    HuffmStream, TMPStream : TStream;
    BMPHdr : TBMP;
begin
  Result := false;
  InputStream.Position := 0;
  InputStream.Read(Header, sizeof(Header));
  if Header.Magic <> 'CompressedBG___'#0 then Exit;
  TMPStream := TMemoryStream.Create;
  TMPStream.Size := Header.Width * Header.Height * (Header.BPP shr 3);
  TMPStream.Position := 0;
  HuffKeyNum := Header.Key;
  for i:=1 to Header.ELen do
  begin
    workb := Byte(CountNumber2(HuffKeyNum) and $FF);
    InputStream.Read(workb2,1);
    workb2 := workb2 - workb;
    InputStream.Position := InputStream.Position - 1;
    InputStream.Write(workb2,1);
  end;
  InputStream.Position := $30;
  for i:=0 to 255 do
  begin
    Fr[i] := CountData(InputStream);
  end;
  FTotal := 0;
  for i := 0 to 255 do
  begin
    NodesArr[i].Val := Fr[i] > 0;
    NodesArr[i].Fr := Fr[i];
    NodesArr[i].Left := i;
    NodesArr[i].Right := i;

    FTotal := FTotal + Fr[i];
  end;
  for i := 256 to 510 do
  begin
    NodesArr[i].Val := false;
    NodesArr[i].Fr := 0;
    NodesArr[i].Left := $FFFFFFFF;
    NodesArr[i].Right := $FFFFFFFF;
  end;

  for nodes := 256 to 510 do
  begin
		frec := 0;
		for i := 0 to 1 do
    begin
      min := $FFFFFFFF;
      ch[i] := $FFFFFFFF;
      for j := 0 to nodes-1 do
        if NodesArr[j].Val and (NodesArr[j].Fr < min) then
        begin
          min := NodesArr[j].Fr;
          ch[i] := j;
        end;
      if ch[i] <> $FFFFFFFF then
      begin
        NodesArr[ch[i]].Val := false;
        frec := frec + NodesArr[ch[i]].Fr;
      end;
    end;
    NodesArr[nodes].Val := true;
    NodesArr[nodes].Fr := frec;
    NodesArr[nodes].Left := ch[0];
    NodesArr[nodes].Right := ch[1];
    if frec = FTotal then break;
  end;

//  Dec(nodes);
  root := nodes;
  mask := $80;
  InputStream.Read(workb,1);
  SetLength(HummfArr, Header.ZLen);
  for i := 0 to Header.ZLen-1 do
  begin
    node := root;
    while node >= 256 do
    begin
      if (workb and mask) <> 0 then
      begin
        node := NodesArr[node].Right;
      end
      else
      begin
        node := NodesArr[node].Left;
      end;
      mask := mask shr 1;
      if mask = 0 then
      begin
        InputStream.Read(workb,1);
        mask := $80;
      end;
    end;
    HummfArr[i] := Byte(Node);
  end;

  zero := 0;
  HuffmStream := TMemoryStream.Create;
  HuffmStream.Write(HummfArr[0],header.ZLen);
  HuffmStream.Position := 0;

  while HuffmStream.Position < header.ZLen do
  begin
    len := CountData(HuffmStream);
    if zero <> 0 then
    begin
      if len > 0 then
      begin
        SetLength(DummyArr,len);
        FillChar(DummyArr[0],len,0);
        TMPStream.Write(DummyArr[0],len);
      end;
    end
    else
    begin
      TMPStream.CopyFrom(HuffmStream,len);
    end;
    zero := zero xor 1;
  end;

  colors := header.BPP shr 3;
  line := Header.Width * colors;
  pos := 0;
  for y := 0 to Header.Height-1 do
  begin
    for x := 0 to Header.Width-1 do
    begin
      for i :=0 to colors-1 do
      begin
        if (x = 0) and (y = 0) then workb := 0
        else if y = 0 then
        begin
          TMPStream.Position := pos - colors;
          TMPStream.Read(workb,1);
        end
        else if x = 0 then
        begin
          TMPStream.Position := pos - line;
          TMPStream.Read(workb,1);
        end
        else
        begin
          TMPStream.Position := pos - colors;
          TMPStream.Read(workb,1);
          TMPStream.Position := pos - line;
          TMPStream.Read(workb2,1);
          workb := (workb + workb2) shr 1
        end;
        TMPStream.Position := pos;
        TMPStream.Read(workb2,1);
        workb := workb + workb2;
        TMPStream.Position := pos;
        TMPStream.Write(workb,1);
        Inc(pos);
      end;
    end;
  end;

  FreeAndNil(HuffmStream);
  SetLength(DummyArr,0);
  SetLength(HummfArr,0);
  TMPStream.Position := 0;
  VerticalFlip(TMPStream, GetScanlineLen2(Header.Width, Header.BPP), Header.Height);

  with BMPHdr do begin
   BMPHeader  := 'BM';
   FileSize   := OutputStream.Size + sizeof(TBMP);
   Dummy_0    := 0;
   ImgOffset  := sizeof(TBMP);
   HeaderSize := 40;
   Width      := Header.Width;
   Height     := Header.Height;
   XYZ        := 1;
   Bitdepth   := Header.BPP;
   CompType   := 0;
   StreamSize := Header.Width*Header.Height*(Header.BPP shr 3);
   Hres       := 0;
   Vres       := 0;
   UsedColors := 0;
   NeedColors := 0;
  end; // with BMPHdr
  OutputStream.Write(BMPHdr,sizeof(TBMP));
  TMPStream.Position := 0;
  OutputStream.CopyFrom(TMPStream,TMPStream.Size);
  FreeAndNil(TMPStream);
  Result := true;
end;

end.