{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Game archive data formats & functions

  Written by dsp2003.
}

unit AnimED_Archives;

interface

uses AA_RFA, // main module

     AnimED_Archives_Init,
     AnimED_Console,
     AnimED_Core_GUI,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Dialogs,
     AnimED_Directories,
     AnimED_FileTypes,
     AnimED_Translation,
     AnimED_Translation_Strings,
     AnimED_Version,
     AnimED_Progress,
     AE_Misc_MD5,

     Generic_Hashes,

     SysUtils, JUtils, ComCtrls, Classes, Windows, Forms, Controls,
     StringsW, FileStreamJ, JReconvertor;

type
 TAE_ArcFragInfo = packed record
 {
   Данная запись включает статистические данные об архиве:

   FragRatio    - коэффициент фрагментации
   CompRatio    - коэффициент сжатия
   Physical     - физический размер архива
   Uncompressed - предполагаемый несжатый размер файлов
   Wasted       - размер данных архива, не относящихся непосредственно к файлам
   Saved        - сравнительный размер данных, выгаданных из-за сжатия
   Calculated   - подсчитанный размер файлов
   Missing      - количество "пропавших" байт. Если больше нуля, значит размер
                  СЖАТЫХ данных больше, чем сам размер архива, что свидетельствует
                  либо о том что используется блочное сжатие, либо о том что архив
                  повреждён
 }
  FragRatio    : extended;
  CompRatio    : extended;
  Physical     : int64;
  Uncompressed : int64;
  Wasted       : int64;
  Saved        : int64;
  Calculated   : int64;
  Missing      : int64;
 end;

{ Archive initialisation routines were stored at MainUnit -- CONFIRM IT ASAP }
 function  Open_Archive(var FileName : widestring; SelFID : integer = 0) : boolean;
 procedure Create_Archive(FilePickerMode : integer = 0);

 procedure Extract_SingleFile(FileRecord : TRFA; FormatID : integer);
 procedure Extract_MultipleFiles(Range : array of integer; FormatID : integer);

 procedure AFAdd(IAFunc : TIAFunction);

  function Init_Archive_Formats(InitMode : integer = 0) : TStringList;

 procedure ArcDetectHiddenData;

  function ArcFragCount : TAE_ArcFragInfo;

  function ArcFragCheck : pchar;

  function ArcFmtNameCompose(ArcFormat : TArcFormats) : string;

implementation

uses AnimED_Main;

function Open_Archive;
var i, j : longword;
    DetectionList : array of byte;
const Go = 5;
      Fail = 1;
label Detected;
 procedure WriteCPUTacts(var z : longword; var IDS : string);
 begin
  LogD(inttostr(z)+' tacts for '+IDS); // DEBUG
 end;
begin

 SetLength(DetectionList,ArcFormatsCount+1); // detection list

 RFA_Flush;
 
 Result := False;
 
 with MainForm do begin
 
  Core_GUI_ArcClearInfo;
  
  if FileExists(FileName) = True then try
 { Программа попытается автоматически определить формат архива }
   ArchiveFileName := FileName;
   ArchiveStream := TFileStreamJ.Create(ArchiveFileName, fmOpenRead);

   if ArchiveStream.Size < 1 then begin
    FreeAndNil(ArchiveStream);
    exit; //cannot be smaller than 1 b
   end;

   // Попытаемся принудительно открыть как указанный формат. Если не получится,
   // воспользуемся методом перебора
   { Проверка времени работы алгоритма }
   if (SelFID > -1) and (SelFID <> ArcFormatsCount) then begin
    RFA_Flush;
    j := GetCPUTacts;
    if ArcFormats[SelFID].Open = True then begin
     j := GetCPUTacts-j;
     WriteCPUTacts(j,ArcFormats[SelFID].IDS);
     DetectionList[SelFID] := Go;
     goto Detected;
    end else begin
     j := GetCPUTacts-j;
     WriteCPUTacts(j,ArcFormats[SelFID].IDS);
     DetectionList[SelFID] := Fail;
    end;
   end;

   // Метод расширений
   for i := 0 to ArcFormatsCount do begin
    if DetectionList[i] <> Fail then begin
     if lowercase(ExtractFileExt(ArchiveFilename)) = ArcFormats[i].Ext then begin
      RFA_Flush;
      j := GetCPUTacts;
      if ArcFormats[i].Open = True then begin
       j := GetCPUTacts-j;
       WriteCPUTacts(j,ArcFormats[i].IDS);
       DetectionList[i] := Go;
       goto Detected;
      end else DetectionList[i] := Fail;
     end;
    end;
   end;

   // Метод перебора
   for i := 0 to ArcFormatsCount{-1 skipping dummy procedure} do begin
    if DetectionList[i] <> Fail then begin
     RFA_Flush;
     j := GetCPUTacts;
     if ArcFormats[i].Open = True then begin
      j := GetCPUTacts-j;
      WriteCPUTacts(j,ArcFormats[i].IDS);
      DetectionList[i] := Go;
      break; // goto Detected; is not required, since it's right after this function
     end else DetectionList[i] := Fail;
    end;

    if i <> ArcFormatsCount then begin
     j := GetCPUTacts - j;
     WriteCPUTacts(j,ArcFormats[i].IDS);
    end;

    RFA_Flush; // BOMBS AWAY ~DESU!
   end;

   Detected:

   for i := 0 to ArcFormatsCount do if DetectionList[i] = Go then begin
    LogD(ArcFormats[i].IDS+'... Detected!');
    RFA_ID := i;
    break;
   end;

   SetLength(DetectionList,0); // detection list

 { Здесь находятся функции с нестандартными вызовами, либо те что не загружаются в цикле }
// OA_Unsupported;

// BCheck: if ((RecordsCount > 0) and (ArchiveIsBroken = False)) = True then begin
   if RecordsCount > 0 then begin

  { 065.390: Assigning format name for GUI by RFA_ID }
    if RFA_ID <> -1 then begin
     if RFA_IDS = '' then begin // fixes custom RFA_IDS set in the archive parser (for multiple subformats)
      RFA_IDS := ArcFormats[RFA_ID].IDS;
     end;
    end;

 // Обновляем GUI
    Core_GUI_ArcUpdateInfo(ArchiveStream,RecordsCount,RFA_IDS,ArchiveFileName);

    LV_ArcFileList.Clear;

 {*}Progress_Max(RecordsCount);

    LV_ArcFileList.Items.BeginUpdate; // turning the ListView off

    for i := 1 to RecordsCount do begin
  {*}Progress_Pos(i);

     with RFA[i] do Core_GUI_ArcAddItem(RFA_3,RFA_1,RFA_C,RFA_2,i);

    end;

    LV_ArcFileList.Items.EndUpdate; // turning the ListView on

    ArchiveIsOpened := True;

    // 0.6.8.414 : hidden metadata detection
    if CB_HiddenDataAutoscan.Checked then ArcDetectHiddenData;

    LogM(ExtractFileName(ArchiveFileName)+' '+AMS[AOpenedSuccessfully]);
    Result := True;
   end;
//   if RecordsCount = 0 then Log('[E] There is no files in this archive.');
  except
   FreeAndNil(ArchiveStream);
   LogE(AMS[ECannotOpenFile]);
   LV_ArcFileList.Items.EndUpdate;
   Core_GUI_ArcClearInfo;
  end else LogE(AMS[ECannotFindFile]);
 end;
 
end;

procedure Create_Archive(FilePickerMode : integer = 0);
var {i              : integer;}
    AppendExt      : string;
    FileName       : widestring;
    FileListStream : TStream;
label ExFileList, FileListEnd;
begin

 with MainForm do begin
 
  if ArcFormats[CB_ArchiveFormatList.ItemIndex].Stat > $0 then
  if ArcFormats[CB_ArchiveFormatList.ItemIndex].Stat <> $5 then // write-only needs no warnings
  if MessageBox(handle,
   pchar(AMS[AFormatTaggedAs]+' "'+ArcStat[ArcFormats[CB_ArchiveFormatList.ItemIndex].Stat]+'". '+AMS[AFormatTaggedAs2]),
   pchar(ArcFormats[CB_ArchiveFormatList.ItemIndex].IDS),
   mb_yesno) <> idYes then Exit;

  { Previous data cleanup }
  Core_GUI_ArcClearInfo;

  // инициализируем unicode список файлов
  AddedFilesW := TStringsW.Create;
  // ...и его ANSI/Shift-JIS копию
  AddedFiles := TStringList.Create;

  { File picker modes:

   0 - Create from files
   1 - Create from directory
   2 - Create from list }

  case FilePickerMode of

  0 : if ODialog_Files(AddedFilesW) then begin

       RootDir := ExtractFilePath(AddedFilesW.Strings[0]);

       AddedFilesSync(True);
      {for i := 0 to AddedFilesW.Count-1 do if AddedFilesW.Strings[i] <> '' then begin
        AddedFilesW.Strings[i] := ExtractFileName(AddedFilesW.Strings[i]);
        AddedFiles.Add(Wide2JIS(AddedFilesW.Strings[i]));
       end;}

      end else begin
       LogI(AMS[ICancelledByUser]);
       Exit;
      end;

  1 : case CB_RecursiveDirMode.Checked of
       True  : PickDirContents(RootDir,'*',smAllowDirs);
       False : PickDirContents(RootDir,'*',smFilesOnly);
      end;

  2 : if ODialog_File(FileName) then try
       RootDir := ExtractFilePath(FileName);
       FileListStream := TFileStreamJ.Create(FileName,fmOpenRead);

       AddedFilesW.LoadFromStream(FileListStream);

       AddedFilesSync;
       {for i := 0 to AddedFilesW.Count-1 do if AddedFilesW.Strings[i] <> '' then AddedFiles.Add(Wide2JIS(AddedFilesW.Strings[i]));}

       FreeAndNil(FileListStream);
      except
       FreeAndNil(FileListStream);
      end else begin
       LogI(AMS[iCancelledByUser]);
       Exit;
      end;
  end; // case

  { Moved here from bunch of other modules }
  try Progress_Max(AddedFilesW.Count,pColWrite); except end;
  
  if SDialog_File(FileName) then begin
   if (((FileName <> '') and (FileExists(FileName) = False)) or CB_AllowArchiveOverwrite.Checked) then begin
    if CB_AllowArchiveOverwrite.Checked then LogI('Archive overwriting mode is active.');
    { Here goes the archive format extension appender }
    if ExtractFileExt(FileName) = '' then AppendExt := ArcFormats[CB_ArchiveFormatList.ItemIndex].Ext;
    FileName := FileName+AppendExt;
    { Creating archive, activating stream }
    ArchiveFileName := FileName;
    ArchiveStream := TFileStreamJ.Create(ArchiveFileName, fmCreate);
    { Here goes the archive format selector definitions }

    { Executing saving function by format index ^_^ }
    { Moved here from bunch of other modules }
    if ArcFormats[CB_ArchiveFormatList.ItemIndex].Save(ArcFormats[CB_ArchiveFormatList.ItemIndex].SArg) then LogI(AMS[iDone]) else LogE(AMS[eSavingFile]);

    FreeAndNil(ArchiveStream);

   end else LogE(AMS[EArchiveExists]);
  end else LogI(AMS[ICancelledByUser]);
 end; // with MainForm
end;

procedure Extract_SingleFile;
var FileName : widestring;
begin
 if ArchiveStream <> nil then with MainForm do begin
  FileName := JIS2Wide(FileRecord.RFA_3);
  if (FileName <> '') and (FileRecord.RFA_1 <= ArchiveStream.Size) then begin
   FileName := ExtractFileName(FileName); // M3956's SaveDialog filename assign fix ~ NP:Kana Ueda - Namida no Komoriuta
   if SDialog_File(FileName) then begin
    try
     LogS(AMS[OExtracting]+' '+FileName);

     ForceDirectories(ExtractFilePath(FileName));

     FileDataStream := TFileStreamJ.Create(FileName,fmCreate);

   { THIS IS THE ACTUAL EXTRACTION CALL }
     if FileRecord.RFA_C <> 0 then begin // File size check. If 0, then no extraction is actually performed
      if FormatID <> -1 then ArcFormats[FormatID].Extr(FileRecord) else EA_RAW(FileRecord);
     end;
   { ---------------------------------- }
    except
     LogE(AMS[EArchiveExtract]+' '+FileName+'.');
    end;
    FreeAndNil(FileDataStream);
    LogI(AMS[IDone]);
   end else LogI(AMS[ICancelledByUser]);
  end else LogW(AMS[WArchiveInvalidEntry]);
 end else LogW(AMS[WArchiveExtract]);
end;

procedure Extract_MultipleFiles;
var i: integer;
    FileNameW : widestring;
begin
 with MainForm do begin
{*}Progress_Max(RecordsCount);
  for i := 1 to RecordsCount do begin
   if ArchiveStream <> nil then begin
    if ((RFA[i].RFA_3 <> '') and (RFA[i].RFA_C <= ArchiveStream.Size)) then begin
     FileNameW := JIS2Wide(RFA[i].RFA_3);
     LogS(AMS[OExtracting]+' '+FileNameW);
     try
    { Creating the extraction path if not already exists - NSA handling fix }
      ForceDirectories(ExtractFilePath(RootDir+FileNameW));

      //DEBUG
      if FileExists(RootDir+FileNameW) then LogW('File already exists. Overwriting...');

      FileDataStream := TFileStreamJ.Create(RootDir+FileNameW,fmCreate);

    { THIS IS THE ACTUAL EXTRACTION CALL }
      if RFA[i].RFA_C <> 0 then begin // File size check. If 0, then no extraction is actually performed
       if FormatID <> -1 then ArcFormats[FormatID].Extr(RFA[i]) else EA_RAW(RFA[i]);
      end;
    { ---------------------------------- }

   {*}Progress_Pos(i);
     except
      LogE(AMS[EUnableToUnpack]+' '+FileNameW);
     end;
    end else LogW(AMS[WArchiveInvalidEntry]);
    FreeAndNil(FileDataStream);
   end;
   Application.ProcessMessages;
  end;
  LogI(AMS[IDone]);
 end;

end;

function ArcFragCount;
var i : integer;
begin
 if ArchiveStream <> nil then with Result do begin
  Calculated   := 0;
  Uncompressed := 0;
  Physical := ArchiveStream.Size;
  for i := 1 to RecordsCount do begin
   inc(Calculated,  RFA[i].RFA_C);
   inc(Uncompressed,RFA[i].RFA_2);
  end;
  if Uncompressed = 0 then Uncompressed := 1;
  if Calculated   = 0 then Calculated   := 1;
  FragRatio := Calculated / Physical;
  CompRatio := Physical / Uncompressed;
  Wasted := Physical - Calculated;
  if Wasted < 0 then Wasted := 0; // little fix
  if Calculated > Physical then Missing := Calculated - Physical else Missing := 0;
  Saved := Uncompressed - Physical - Wasted - Missing;
  if Saved < 0 then Saved := 0; // another little fix
 end;
end;

function ArcFragCheck : pchar;
var ArcFragInfo : TAE_ArcFragInfo;
begin
 Result := '';
 ArcFragInfo := ArcFragCount;
 if ArchiveIsOpened then with ArcFragInfo do begin
  Result := pchar('' +
  AMS[APhysicalArcSize] +' : '+inttostr(Physical)+' '+AMS[aBytes]+#10    +
  AMS[ACalculatedSize]  +' : '+inttostr(Calculated)+' '+AMS[aBytes]+#10    +
  AMS[AUncompressedSize]+' : '+inttostr(Uncompressed)+' '+AMS[aBytes]+#10#10 +
  AMS[AWasted]          +' : '+inttostr(Wasted)+' '+AMS[aBytes]+#10    +
  AMS[ASaved]           +' : '+inttostr(Saved)+' '+AMS[aBytes]+#10#10 +
  AMS[AFragRatio]       +' : '+inttostr(100 - round(FragRatio*100))+'%'#10 +
  AMS[ACompRatio]       +' : '+inttostr(round(CompRatio*100))+'%'#10 +
  AMS[AMissing]         +' : '+inttostr(Missing)+' '+AMS[aBytes]);
 end;
end;

procedure ArcDetectHiddenData;
type Tint64d = array[1..2] of int64;
var tmpTable, gapTable : array of Tint64d;
    k : Tint64d;
    i, j : longword;
    YesNo : byte;
begin
 // checking if archive is opened
 if (ArchiveStream <> nil) and (ArchiveFileName <> '') then begin

  SetLength(tmpTable,RecordsCount+1);

  // copying offsets and file sizes from RFA
  for i := 1 to RecordsCount do begin
   tmpTable[i-1][1] := RFA[i].RFA_1; // offset
   tmpTable[i-1][2] := RFA[i].RFA_C; // compressed (real) file size
  end;

  // workaround for the last table entry
  tmpTable[RecordsCount][1] := ArchiveStream.Size;
  tmpTable[RecordsCount][2] := 0;

  // bubble sort variation :3
  for i := 0 to RecordsCount-1 do begin
   for j := 0 to RecordsCount-1 do begin
    if tmpTable[i][1] < tmpTable[j][1] then begin
     k := tmpTable[i];
     tmpTable[i] := tmpTable[j];
     tmpTable[j] := k;
    end; 
   end;
  end;

  SetLength(gapTable,0);

  // calculating gaps and anomalies
  for i := 0 to RecordsCount-1 do begin
   j := tmpTable[i+1][1] - tmpTable[i][1]; // subtracting bigger offset from smaller offset
   if j > tmpTable[i][2] then begin
    SetLength(gapTable,Length(gapTable)+1); // increasing number of gap slots
    gapTable[Length(gapTable)-1][1] := tmpTable[i][1] + j; // starting offset of the gap
    gapTable[Length(gapTable)-1][2] := j - tmpTable[i][2]; // size of the gap
   end;
  end;

  // freeing memory
  SetLength(tmpTable,0);

  // showing the info
  if Length(gapTable) > 0 then begin
   Log(inttostr(Length(gapTable))+' '+AMS[AHiddenData302]+':');
   Log('');
   for i := 0 to Length(gapTable)-1 do Log(inttohex(gapTable[i][1],8)+' : '+inttostr(gapTable[i][2])+' '+AMS[ABytes]);
   Log('');
   Log(AMS[AEndOfReport]);
   with MainForm do begin

    if not CB_HiddenDataAutoscanAsk.Checked then begin
     YesNo := mrOK;
    end else begin
     YesNo := MessageBoxW(handle,pwidechar(widestring(AMS[AHiddenDataCheck1]+#10+AMS[AHiddenDataCheck2]+#10#10+AMS[AHiddenDataCheck3])),pwidechar(widestring(Application.Title)),mb_okcancel);
    end;

    if YesNo = mrOK then begin

     for i := 0 to Length(gapTable)-1 do begin

      Core_GUI_ArcAddItem('_recovered_'+inttohex(i,4)+'.bin',gapTable[i][1],gapTable[i][2],gapTable[i][2],0);

      with RFA[RecordsCount+i+1] do begin
       RFA_1 := gapTable[i][1];
       RFA_2 := gapTable[i][2];
       RFA_C := gapTable[i][2];
       RFA_3 := '_recovered_'+inttohex(i,4)+'.bin';
      end;

     end;

     RecordsCount := RecordsCount + Length(gapTable);

     Core_GUI_ArcUpdateInfo(ArchiveStream,RecordsCount,RFA_IDS);

    end;
   end;
  end else begin
   Log(AMS[AHiddenData404]);
  end;

  // freeing memory
  SetLength(gapTable,0);

 end;
end;

procedure AFAdd(IAFunc : TIAFunction);
begin
 SetLength(IAFunctions,Length(IAFunctions)+1); // увеличиваем длину массива на единицу
 SetLength(ArcFormats,Length(ArcFormats)+1);   // увеличиваем длину массива на единицу
 IAFunctions[Length(IAFunctions)-1] := IAFunc; // присваиваем функцию инициализации формата в массив
 IAFunctions[Length(IAFunctions)-1](ArcFormats[Length(IAFunctions)-1],Length(IAFunctions)-1); // выполняем функцию инициализации формата
end;

function Init_Archive_Formats(InitMode : integer = 0) : TStringList;
var i : longword; ArcFilter : string;
    FormatList : TStringList;
label ReInit;
begin
 FormatList := TStringList.Create;
 Result := FormatList; // если обломаемся, перешлём пустой список
 if InitMode = 1 then goto ReInit;

 { This is the mostly important thing - format descriptions table. }
 Init_ArcFormatList;

 ArcFormatsCount := Length(ArcFormats)-1; // we must remove dummy format from
                                          // being listed in archive formats later

 for i := 0 to ArcFormatsCount do FormatList.Add(ArcSymbol[ArcFormats[i].Stat]+' '+ArcFmtNameCompose(ArcFormats[i]));

 Result := FormatList;

ReInit:

 ///////// Known file types for OpenFileDialog
 ArcFilter := '';

 for i := 0 to ArcFormatsCount-1 {-1 because excluding dummy} do begin
  ArcFilter := ArcFilter + ArcFormats[i].IDS;
  ArcFilter := ArcFilter + ' (*' + ArcFormats[i].Ext + ')' + '|' + '*' + ArcFormats[i].Ext;
  if i <> ArcFormatsCount-1 then ArcFilter := ArcFilter + '|';
 end;

 ArcFilter := AMS[AAllFiles] + ' (*)|*|' + ArcFilter;

 DialogFilters[1] := ArcFilter;

end;

// Вспомогательная функция, созданная как заменитель полей "Name"
function ArcFmtNameCompose;
var AppExt : string;
begin
 with ArcFormat do begin
  if Length(Ext) > 0 then AppExt := UpperCase(Copy(Ext, 2, Length(Ext)));
  if Length(AppExt) < 3 then while Length(AppExt) < 3 do AppExt := AppExt + ' ';
  Result := '['+AppExt+'] '+IDS;
 end;
end;

end.