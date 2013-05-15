{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  File types & compression file types exception list

  Written by dsp2003.
}
unit AnimED_FileTypes;

interface

uses Classes, SysUtils;

procedure Init_FileTypes;

function FileTypes(Index : integer) : string;
function Skin_GetImageIndex(Extension : string) : integer;

var File_Ext_Script,
    File_Ext_Music,
    File_Ext_Streams,
    File_Ext_Images,
    File_Ext_Archive,
    File_Ext_RealArchive,
    File_Ext_3DModel,
    File_Ext_Other,
    File_Ext_Binary,
    CmpExceptList : TStringList;

implementation

function FileTypes;
begin
 case Index of
  1,16 : Result := 'Script';
  2    : Result := 'Digital audio';
  3    : Result := 'Synthesized music';
  4    : Result := 'Image or texture';
  14   : Result := '3D Model';
 else    Result := 'File';
 end;
end;

function Skin_GetImageIndex;
var ext : string[4]; i : integer;
begin
 Result := 0;

 ext := lowercase(Extension);

 for i := 0 to File_Ext_Script.Count     -1 do if ext = File_Ext_Script.Strings[i]      then begin Result := 16; Exit; end;
 for i := 0 to File_Ext_Streams.Count    -1 do if ext = File_Ext_Streams.Strings[i]     then begin Result := 2;  Exit; end;
 for i := 0 to File_Ext_Music.Count      -1 do if ext = File_Ext_Music.Strings[i]       then begin Result := 3;  Exit; end;
 for i := 0 to File_Ext_Images.Count     -1 do if ext = File_Ext_Images.Strings[i]      then begin Result := 4;  Exit; end;
 for i := 0 to File_Ext_Other.Count      -1 do if ext = File_Ext_Other.Strings[i]       then begin Result := 5;  Exit; end;
 for i := 0 to File_Ext_Archive.Count    -1 do if ext = File_Ext_Archive.Strings[i]     then begin Result := 6;  Exit; end;
 for i := 0 to File_Ext_RealArchive.Count-1 do if ext = File_Ext_RealArchive.Strings[i] then begin Result := 6;  Exit; end;
 for i := 0 to File_Ext_3dModel.Count    -1 do if ext = File_Ext_3dModel.Strings[i]     then begin Result := 14; Exit; end;

end;

procedure Init_FileTypes;
begin

 try
  if File_Ext_Script      <> NIL then FreeAndNil(File_Ext_Script);
  if File_Ext_Music       <> NIL then FreeAndNil(File_Ext_Music);
  if File_Ext_Streams     <> NIL then FreeAndNil(File_Ext_Streams);
  if File_Ext_Images      <> NIL then FreeAndNil(File_Ext_Images);
  if File_Ext_Archive     <> NIL then FreeAndNil(File_Ext_Archive);
  if File_Ext_RealArchive <> NIL then FreeAndNil(File_Ext_RealArchive);
  if File_Ext_3DModel     <> NIL then FreeAndNil(File_Ext_3DModel);
  if File_Ext_Other       <> NIL then FreeAndNil(File_Ext_Other);
  if File_Ext_Binary      <> NIL then FreeAndNil(File_Ext_Binary);
  if CmpExceptList        <> NIL then FreeAndNil(CmpExceptList);
 except
  { to-do: do nothing}
 end;

 File_Ext_Script  := TStringList.Create;
 with File_Ext_Script do begin
  Add('._bp');
  Add('.bat');
  Add('.bdt');
  Add('.bt');
  Add('.cmd');
  Add('.csv');
  Add('.h');
  Add('.ini');
  Add('.inf');
  Add('.ipl');
  Add('.isf');
  Add('.ks');
  Add('.lst');
  Add('.mjo');
  Add('.nps');
  Add('.org');
  Add('.scr');
  Add('.scx');
  Add('.tjs');
  Add('.txt');
  Add('.wsc');
  Add('.ybn');
  Add('.ygm');
  Add('.ymn');
 end;

 File_Ext_Music   := TStringList.Create;
 with File_Ext_Music  do begin
  Add('.it');
  Add('.mid');
  Add('.mo3');
  Add('.mod');
  Add('.rmi');
  Add('.s3m');
  Add('.xm');
 end;

 File_Ext_Streams := TStringList.Create;
 with File_Ext_Streams do begin
  Add('.aac');
  Add('.adx');
  Add('.aog');
  Add('.ape');
  Add('.avi');
  Add('.eog');
  Add('.fla');
  Add('.flac');
  Add('.mkv');
  Add('.mp1');
  Add('.mp2');
  Add('.mp3');
  Add('.mpa');
  Add('.mpc');
  Add('.mpe');
  Add('.mpg');
  Add('.mpp');
  Add('.ogg');
  Add('.waf');
  Add('.wav');
  Add('.wma');
  Add('.wmv');
  Add('.wpd');
 end;

 File_Ext_Images  := TStringList.Create;
 with File_Ext_Images  do begin
  Add('.agf');
  Add('.bmp');
  Add('.cel');
  Add('.cps');
  Add('.cv2');
  Add('.cwl');
  Add('.cwp');
  Add('.dds');
  Add('.gax');
  Add('.gg0');
  Add('.gg1');
  Add('.gg2');
  Add('.gg3');
  Add('.gg4');
  Add('.gg5');
  Add('.ggd');
  Add('.ggp');
  Add('.gpd');
  Add('.gr');
  Add('.gif');
  Add('.ies');
  Add('.jp2');
  Add('.jpc');
  Add('.jpe');
  Add('.jpeg');
  Add('.jpg');
  Add('.mgf');
  Add('.mgd');
  Add('.msk');
  Add('.pgd');
  Add('.png');
  Add('.prs');
  Add('.prt');
  Add('.ps2');
  Add('.psi');
  Add('.psp');
  Add('.psd');
  Add('.tga');
  Add('.txd');
  Add('.wif');
  Add('.wip');
  Add('.zbm');
 end;

 File_Ext_Archive := TStringList.Create;
 with File_Ext_Archive do begin
  Add('.sar');
  Add('.nsa');
  Add('.pd');
  Add('.pck');
  Add('.pac');
  Add('.a');
  Add('.iso');
  Add('.img');
  Add('.bin');
  Add('.mds');
  Add('.mdf');
  Add('.ccd');
  Add('.vdi');
  Add('.cdi');
  Add('.afs');
 end;

 File_Ext_RealArchive := TStringList.Create;
 with File_Ext_RealArchive do begin
  Add('.7z');
  Add('.arj');
  Add('.cab');
  Add('.rar');
  Add('.zip');
 end;

 File_Ext_3DModel := TStringList.Create;
 with File_Ext_3DModel do begin
  Add('.3ds');
  Add('.col');
  Add('.dff');
  Add('.xx');
  Add('.xa');
 end;

 File_Ext_Other   := TStringList.Create;
 with File_Ext_Other   do begin
  Add('.db');
  Add('.lnk');
 end;

 File_Ext_Binary  := TStringList.Create;
 with File_Ext_Binary do begin
  Add('.exe');
  Add('.elf');
  Add('.dll');
  Add('.so');
 end;

 CmpExceptList    := TStringList.Create;
 // Заполняем список расширений файлов, запрещённых к сжатию.
 // Эмулируем "умное" сжатие KiriKiri2/KAG3 SDK ^_^
 // Moved from AA_XP3_KiriKiri2, since it's also used in AA_YPF_YURIS
 with CmpExceptList do begin
  Add('.jpg');
  Add('.png');
  Add('.tlg');
  AddStrings(File_Ext_RealArchive); // отключаем сжатие для архивов
  AddStrings(File_Ext_Streams);     // отключаем сжатие для потокового аудио и видео
 end;

end;

end.