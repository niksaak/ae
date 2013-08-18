{
  AE - VN Tools
В© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Crass:
  Name:        RPM ADV SYSTEM
  Description: system developed by rpm ENTERTAINMENT CREATIONAL STUDIO

  Currently supported games (archive_version#filenames_length ('decryption key')):
    [Ciel] Fault!! - arc_v2#32 ('FT')

	~~~ Ciel Limted Collector's Box - Tony Illustration Games ~~~
		After... -Story Edition- - arc_v2#24 ('after')
		After Sweet Kiss - arc_v2#24 ('aftersk')
		ARCANA ~Hikari to Yami noExtaxis~ - arc_v1#24 ('arcana')
		Mitama ~Shinobi~ - arc_v1#24 ('arcana')
		Shinshou Genmukan - arc_v2#32 ('HAMA')
		Sora no Iro, Mizu no Iro - arc_v2#32 ('HAMA')
    +
    After... -Story Edition- + After Sweet Kiss Title Programm - arc_v2#24 ('afterse_title')

    [Libre] Reincarnation * Shinsengumi! - arc_v2#32 ('RC')
    [AXL] Koisuru Otome to Shugo no Tate - The Code Name is "Shield 9" - arc_v2#32 ('KOITATE')
    [AXL] Like a Butler - arc_v2#32 ('LB')

    Installation Archives - arc_v2#32 ('inst')


    ----- non Ciel ---

	--------------------------------------------------------------

  Written by Nik.
}

unit AA_ARC_RPM;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Generic_LZXX,
     SysUtils, Classes, Windows, Forms;

 { Supported archives implementation }
 procedure IA_ARC_RPM(var ArcFormat : TArcFormats; index : integer);

  function OA_ARC_RPM               : boolean;
{  function SA_ARC_RPM(Mode:integer) : boolean; }
{  function EA_ARC_RPM(FileRecord : TRFA) : boolean; }
  
  function RPM_DecodeTable(InputStream, OutputStream : TStream; FCount:integer) : integer;

type

 TRPMHeader_v1 = packed record
  FilesCount       : longword;
 end;

{ TRPMHeader_v2 = packed record
  FilesCount       : longword;
  CryptFlag       : longword;
 end;}  // Идея с "Читаем v2 и не паримся не проканала"
 
 TGameType = record
	KeyValue : string;
	FileNameLen : integer;
	BeginIndex : integer;
 end;
 
 TRPMTable = packed record
//  FileName   : string[32];
  DecryptedSize : longword;
  CryptedSize : longword;
  FileOffset : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_ARC_RPM;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'RPM ADV SYSTEM';
  Ext  := '.arc';
  Stat := $F;
  Open := OA_ARC_RPM;
  Save := SA_Unsupported;
  Extr := EA_LZSS_FEE_FFF;
  FLen := 32;
  SArg := 0;
  Ver  := $20090827;
 end;
end;

function OA_ARC_RPM;
var Header : TRPMHeader_v1;
	Table : TRPMTable;
	i, j, fnamelen : integer;
	stream : TStream;
	name : array[1..32] of char;
begin
 Result := False;

 with ArchiveStream do begin
  Seek(0,soBeginning);
  Read(Header,SizeOf(Header));
//если флаХа нет, то архивы версии 1
//if (Header.CryptFlag <> 1) and (Header.CryptFlag <> 0) then kf := 1;
 end;

 if Header.FilesCount = 0 then Exit;
 RecordsCount := Header.FilesCount;

 stream := TMemoryStream.Create;
 fnamelen := RPM_DecodeTable(ArchiveStream,stream, RecordsCount);
 if fnamelen = 0 then Exit;

 stream.Seek(0,soBeginning);
{*}Progress_Max(RecordsCount);

 for i := 1 to RecordsCount do begin
{*}Progress_Pos(i);
  stream.Read(name,fnamelen);
  for j := 1 to fnamelen do if name[j] <> #0 then RFA[i].RFA_3 := RFA[i].RFA_3 + name[j] else break;
  stream.Read(Table,12);
  RFA[i].RFA_2 := Table.DecryptedSize;
  RFA[i].RFA_C := Table.CryptedSize;
  RFA[i].RFA_1 := Table.FileOffset;
//    if (RFA[i].RFA_C > RFA[i].RFA_2) or (RFA[i].RFA_1 > ArchiveStream.Size) then
{ Проверку выше нельзя использовать, потому что в исходных архивах были файлы,
сжатый размер которых больше чем несжатый}
//    if (RFA[i].RFA_1 > ArchiveStream.Size) then
  if (RFA[i].RFA_1 > ArchiveStream.Size) or (RFA[i].RFA_C > ArchiveStream.Size) then begin
   Progress_Max(1);
   Progress_Pos(1);
   Exit;
  end;
  if RFA[i].RFA_2 <> RFA[i].RFA_C then begin
   RFA[i].RFA_Z := true;
   RFA[i].RFA_X := $FD; // $FD -- идентификатор LZSS
  end;
 end;

 Result := True;

end;

function RPM_DecodeTable;
var	KeyArr : array of TGameType;
    memarr : array of byte;
    fname : array[1..32] of byte;
    GameType : TGameType;
    i, j, k, b, zpos : byte;
    iszero, res : boolean;
    len, ii : integer;
begin
	Result := 0;

	k := 11;
  SetLength(KeyArr,k);

	GameType.KeyValue    := 'after'; // After...
	GameType.FileNameLen := 24;
	GameType.BeginIndex  := 8;
	KeyArr[0] := GameType;

	GameType.KeyValue    := 'aftersk'; // After Sweet Kiss
	GameType.FileNameLen := 24;
	GameType.BeginIndex  := 8;
	KeyArr[1] := GameType;

	GameType.KeyValue    := 'afterse_title'; // Тайтл-программа для игр цикла After
	GameType.FileNameLen := 24;
	GameType.BeginIndex  := 8;
	KeyArr[2] := GameType;

	GameType.KeyValue    := 'HAMA'; // Sora no Iro, Mizu no Iro и Shinshou Genmukan
	GameType.FileNameLen := 32;
	GameType.BeginIndex  := 8;
	KeyArr[3] := GameType;

	GameType.KeyValue    := 'arcana'; // ARCANA, Mitama а также демки этих игр
	GameType.FileNameLen := 24;
	GameType.BeginIndex  := 4;
	KeyArr[4] := GameType;

	GameType.KeyValue    := 'inst'; // Инсталляционные архивы
	GameType.FileNameLen := 32;
	GameType.BeginIndex  := 8;
	KeyArr[5] := GameType;

	GameType.KeyValue    := 'FT'; // Fault!!
	GameType.FileNameLen := 32;
	GameType.BeginIndex  := 8;
	KeyArr[6] := GameType;

	GameType.KeyValue := 'while'; // ?
	GameType.FileNameLen := 32;
	GameType.BeginIndex := 8;
	KeyArr[7] := GameType;

	GameType.KeyValue    := 'RS'; // Reincarnation * Shinsengumi!
	GameType.FileNameLen := 32;
	GameType.BeginIndex  := 8;
	KeyArr[8] := GameType;

	GameType.KeyValue    := 'KOITATE'; // Koisuru Otome to Shugo no Tate - The Code Name is "Shield 9"
	GameType.FileNameLen := 32;
	GameType.BeginIndex  := 8;
	KeyArr[9] := GameType;

	GameType.KeyValue    := 'LB'; // Like a Butler
	GameType.FileNameLen := 32;
	GameType.BeginIndex  := 8;
	KeyArr[10] := GameType;

  res := false;
  zpos := 0;
	
	while k > 0 do begin
	 With KeyArr[k-1] do begin
    InputStream.Seek(BeginIndex, soBeginning);
		res := false;
		iszero := false;
		j := 1;
		for i := 1 to FileNameLen do begin
		 if j > Length(KeyValue) then j := 1;
     InputStream.Read(fname[i],1);
     fname[i] := fname[i] + byte(KeyValue[j]);
     if (fname[i] = 0) and (not iszero) then begin
      res := true;
			iszero := true;
      zpos := i;
     end;
     if (iszero) and (fname[i] <> 0) then begin
      res := false;
			break;
		 end;
		Inc(j);
	 end;
	end;
	if res and (zpos > 3) then begin
   if (char(fname[zpos-4]) = '.') or (char(fname[zpos-3]) = '.') then begin
    GameType := KeyArr[k-1];
		break;
   end else res := false;
	end;
	Dec(k);
 end;

 SetLength(KeyArr,0);

 if res then begin
  Log('RPM archive file table decrypted by key "' + GameType.KeyValue + '"');
  InputStream.Seek(GameType.BeginIndex, soBeginning);
  len := FCount*(GameType.FileNameLen + 12);
  SetLength(memarr,len);
  InputStream.Read(memarr[0], len);

  j := 1;
  for ii := 0 to len-1 do begin
   b := memarr[ii];
   if j > Length(GameType.KeyValue) then j := 1;
   b := b + byte(GameType.KeyValue[j]);
   OutputStream.Write(b,1);
   Inc(j);
  end;
  Result := GameType.FileNameLen;
  SetLength(memarr,0);
 end;
end;

{function SA_ARC_RPM;
begin
 Result := false;
end;}

{function EA_ARC_RPM;
var TempoStream, TempoStream2 : TStream;
begin
 Result := False;
 if ((ArchiveStream <> nil) and (FileDataStream <> nil)) = True then try
  ArchiveStream.Position := FileRecord.RFA_1;
  case FileRecord.RFA_E of
   True  : begin
            TempoStream := TMemoryStream.Create;
            TempoStream2 := TMemoryStream.Create;
            TempoStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
            TempoStream.Position := 0;
            GLZSSDecode(TempoStream, TempoStream2, FileRecord.RFA_C, $FEE,$FFF);
            FreeAndNil(TempoStream);
            TempoStream2.Position := 0;
            FileDataStream.CopyFrom(TempoStream2,TempoStream2.Size);
            FreeAndNil(TempoStream2);            
           end; 
   False : FileDataStream.CopyFrom(ArchiveStream,FileRecord.RFA_C);
  end;
  Result := True;
 except
 end;
end;}

end.