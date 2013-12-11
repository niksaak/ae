{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.
  
  Written by Nik.
  
  Supported games:
	Archives v1 [lass] Ao to Ao no Shizuku -a calling from tears-
	Not supported yet [lass] 3days -Michiteyuku Koku no Kanata de-
	Not supported yet [Rosebleu] Stellar Theater
}

unit AA_DAT_NEKOPACK;

interface

uses AA_RFA,

     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     SysUtils, Classes, Windows, Forms;

 procedure IA_DAT_Nekopackv1(var ArcFormat : TArcFormats; index : integer);

 function OA_DAT_Nekopackv1: boolean;
 function SA_DAT_Nekopackv1(Mode : integer) : boolean;
 
type
// Удивительно много где засветился данный двиг
// Имеет также много вариаций

	TNekopackArchiveHeaderVer1 = packed record
	  Magic : array[1..8] of char; //'NEKOPACK'
	  Version : longword; // $CB
	  Dummy : longword; // $0
	  FilesCount : longword; // Сабж
	end;
{	
	TNekopackArchiveTableVer1
	  XorByte : byte;
	  NameLen : byte;
	  Name : string;
	  FOffset : longword;
	  FLength : longword;
	end;}
// Это полная запись таблицы, но вместо будет две записи ниже
	
	TNekopackArchiveTableMetaVer1 = packed record
	  XorByte : byte; // ксорит имя
	  NameLen : byte; // длина имени
	end;
	
	TNekopackArchiveTableFileDataVer1 = packed record
	  FOffset : longword; // смещение
	  FLength : longword; // длина
	end;

implementation

uses AnimED_Archives;

procedure IA_DAT_Nekopackv1;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'NEKOPACK Version 1';
  Ext  := '.dat';
  Stat := $F;
  Open := OA_DAT_Nekopackv1;
  Save := SA_DAT_Nekopackv1;
  Extr := EA_RAW;
  FLen := $80;
  SArg := 0;
  Ver  := $20090820;
 end;
end;

function OA_DAT_Nekopackv1;
var Header : TNekopackArchiveHeaderVer1;
    Meta : TNekopackArchiveTableMetaVer1;
    FData : TNekopackArchiveTableFileDataVer1;
    i, j : longword;
begin
 Result := false;
 ArchiveStream.Position := 0;
 ArchiveStream.Read(Header,sizeof(TNekopackArchiveHeaderVer1));

 if (Header.Magic <> 'NEKOPACK') or (Header.Version <> $CB) then Exit;

 RecordsCount := Header.FilesCount;

{*}Progress_Max(RecordsCount);
 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   ArchiveStream.Read(Meta,sizeof(TNekopackArchiveTableMetaVer1));
   SetLength(RFA[i].RFA_3,Meta.NameLen);
   ArchiveStream.Read(RFA[i].RFA_3[1],Meta.NameLen);
   if Meta.XorByte <> 0 then
   begin
     for j := 1 to Meta.NameLen do
     begin
       RFA[i].RFA_3[j] := Char(Byte(RFA[i].RFA_3[j]) xor Meta.XorByte);
     end;
   end;
   ArchiveStream.Read(FData,sizeof(TNekopackArchiveTableFileDataVer1));
   RFA[i].RFA_1 := FData.FOffset;
   RFA[i].RFA_2 := FData.FLength;
   RFA[i].RFA_C := FData.FLength;
 end;
 
 Result := True;

end;

function SA_DAT_Nekopackv1;
var Header : TNekopackArchiveHeaderVer1;
    Meta : array of TNekopackArchiveTableMetaVer1;
    FData : TNekopackArchiveTableFileDataVer1;
    i, Len : longword;
//    stream : TStream;
begin
 RecordsCount := AddedFiles.Count;
 Header.Magic := 'NEKOPACK';
 Header.Version := $CB;
 Header.Dummy := 0;
 Header.FilesCount := RecordsCount;

 ArchiveStream.Write(Header,sizeof(TNekopackArchiveHeaderVer1));

 SetLength(Meta,RecordsCount);
// stream := TMemoryStream.Create;
 UpOffset := Sizeof(TNekopackArchiveHeaderVer1);

 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   Meta[i-1].XorByte := 0;
   RFA[i].RFA_3 := AddedFiles.Strings[i-1];
   Len := Length(RFA[i].RFA_3);
   if Len > $FF then Len := $FF;
   Meta[i-1].NameLen := Byte(Len);
   UpOffset := UpOffset + 10 + Len; // 10 = sizeof(TNekopackArchiveTableFileDataVer1) + sizeof(TNekopackArchiveTableMetaVer1);
 end;

 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   ArchiveStream.Write(Meta[i-1],sizeof(TNekopackArchiveTableMetaVer1));
   ArchiveStream.Write(RFA[i].RFA_3[1],Meta[i-1].NameLen);
//   FileDataStream := TFileStream.Create(GetFolder+AddedFiles.Strings[i-1],fmOpenRead);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   FData.FOffset := UpOffset;
   FData.FLength := FileDataStream.Size;
   UpOffset := UpOffset + FData.FLength;
   FreeAndNil(FileDataStream);
   ArchiveStream.Write(FData,sizeof(TNekopackArchiveTableFileDataVer1));
 end;

 SetLength(Meta,0);

 for i := 1 to RecordsCount do
 begin
{*}Progress_Pos(i);
   OpenFileStream(FileDataStream,RootDir+AddedFilesW.Strings[i-1],fmOpenRead);
   ArchiveStream.CopyFrom(FileDataStream,FileDataStream.Size);
   FreeAndNil(FileDataStream);
 end;

 Result := True;

end;

end.