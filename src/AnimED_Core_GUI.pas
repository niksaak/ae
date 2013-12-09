{
  AE - VN Tools
  © 2007-2013 WinKiller Studio. Open Source.
  This software is free. Please see License for details.

  GUI Core module
  Written by dsp2003.
}
unit AnimED_Core_GUI;

interface

uses AnimED_Console,
     AnimED_Graps,
     AnimED_Misc,
     AnimED_Math,
     AnimED_FileTypes,
     AnimED_Progress,
     AnimED_Translation,
     AnimED_Translation_Strings,
     AnimED_Version,
     AnimED_Archives_Info,
     AA_RFA,
     Classes, SysUtils, Forms, JReconvertor;

procedure Core_GUI_ArcUpdateInfo(ArcStream : TStream; ArcFileCount : longword = 0; ArcFmtName : string = ''; ArcFilename : widestring = '');
procedure Core_GUI_ArcAddItem(Filename : string; Offset, CFileSize, FileSize, FileID : int64);
procedure Core_GUI_ArcClearInfo;

procedure Core_GUI_ArcFormatsAddItem(ID : integer; Desc, Ext, Stat : string; FNLen : integer; Comptype, Lastmod : string);
procedure Core_GUI_ArcFormatsFillItems;

implementation

uses AnimED_Main;

procedure Core_GUI_ArcFormatsAddItem(ID : integer; Desc, Ext, Stat : string; FNLen : integer; Comptype, Lastmod : string);

// function SetArcFmtIcon(Status : string) : integer;
// begin
//  Result := 0;
//  if Status = 'Write-only' then Result := 8;
// end;

var ListViewStrings : TStringList;
//    i : integer;
begin

 with MainForm do begin

  ListViewStrings := TStringList.Create;

  with ListViewStrings do begin
   Add(Desc);
   Add(Ext);
   Add(Stat);
   Add(inttostr(FNLen));
   Add(Comptype);
   Add(Lastmod);
  end;

  LV_ArcFmt.AddItem(inttostr(ID),nil); // parent item

  LV_ArcFmt.Items.Item[LV_ArcFmt.Items.Count-1].SubItems := ListViewStrings; //adding child subitems
 // LV_ArcFmt.Items.Item[i-1].ImageIndex := SetArcFmtIcon(Stat); //assigning icon index for file type

  ListViewStrings.Free;

 end;

end;

procedure Core_GUI_ArcFormatsFillItems;
var i : integer;
    ProcAddr, ProcAddrRAW : longword;
    ProcStat : string;
begin
 ProcAddrRAW := longword(@EA_RAW);

 for i := 0 to Length(ArcFormats)-1 do with ArcFormats[i] do begin

  ProcAddr := longword(@Extr);
  if ProcAddr <> ProcAddrRAW then ProcStat := 'Custom' else ProcStat := 'RAW';

  Core_GUI_ArcFormatsAddItem(ID,IDS,Ext,ArcStat[Stat],FLen,ProcStat,AEGetDate(Ver,True));
 end;

end;

procedure Core_GUI_ArcUpdateInfo;
begin
 with MainForm do begin

  if ArcFilename <> '' then begin
   E_ArcFileName.Text := Wide2Jis(ArcFileName);
   E_ArcFileName.Repaint;
  end;

  L_RecordsCount.Caption := inttostr(ArcFileCount);

  if ArcStream <> nil then
   L_ArchiveSize.Caption := inttonum(ArcStream.Size)+' '+AMS[Abytes]
  else
   L_ArchiveSize.Caption := '0 '+AMS[Abytes];

  if ArcFmtName <> '' then
   L_ArchiveFormat.Caption := ArcFmtName
  else
   L_ArchiveFormat.Caption := AMS[AUnknownFormat];

 end;
end;

procedure Core_GUI_ArcAddItem;

 function ViewAs(z : int64) : string;
 var l,n : integer; HSName : string;
 begin
  l := 0;
  n := z;
  while z > 1024 do begin
   z := z div 1024; inc(l);
  end;
  case l of
   0: HSName := AMS[ABytes];
   1: HSName := AMS[AKiloBytes];
   2: HSName := AMS[AMegaBytes];
   3: HSName := AMS[AGigaBytes];
  end;
  Result := inttostr(n div round(Involution(1024,l)))+' '+Wide2JIS(HSName);
 end;

var ListViewStrings : TStringList;
    i : integer;
begin

 with MainForm do begin

  ListViewStrings := TStringList.Create;

//ListViewStrings.Clear;

  case CB_ArchiveListHumanReadable.Checked of
   False: begin
           ListViewStrings.Add(inttohex(FileSize,8)); //size
           ListViewStrings.Add(inttohex(CFileSize,8)); //compressed
          end;
   True:  begin
           ListViewStrings.Add(ViewAs(FileSize)); //size
           ListViewStrings.Add(ViewAs(CFileSize)); //compressed
          end;
  end;

  ListViewStrings.Add(inttohex(Offset,8)); //offset
  ListViewStrings.Add(inttohex(FileID,4)); // id

  LV_ArcFileList.AddItem(Filename,nil);   //name

  i := LV_ArcFileList.Items.Count;

  LV_ArcFileList.Items.Item[i-1].SubItems := ListViewStrings; //adding subitems
  LV_ArcFileList.Items.Item[i-1].ImageIndex := Skin_GetImageIndex(ExtractFileExt(Filename)); //assigning icon index for file type

  ListViewStrings.Free;

 end;

end;

procedure Core_GUI_ArcClearInfo;
var tmpString : string;
begin
 with MainForm do begin
  LV_ArcFileList.Clear;

  RFA_Flush;

{ Freeing ArchiveStream. Must be here to kick any TStream lockups }
  if ArchiveStream <> nil then begin
   FreeAndNil(ArchiveStream);
   LogI(AMS[IArchiveStreamClosed]);
  end;

{ Cleaning information dialog }
{ SetLength(tmpString,3);
  FillChar(tmpString[1],3,'-');
  E_ArcFileName.Text      := tmpString;
  L_ArchiveSize.Caption   := '0 '+AMS[ABytes];
  L_ArchiveFormat.Caption := AMS[AUnknownFormat];
  L_RecordsCount.Caption  := '0';}

  Core_GUI_ArcUpdateInfo(nil,0);

  Progress_Max(0);
  Progress_Pos(0);

  if FileInfo_Form <> nil then with FileInfo_Form do begin
   SetLength(tmpString,32);
   FillChar(tmpString[1],Length(tmpString),'0');
   E_ArchiveMD5.Text := tmpString;
   SetLength(tmpString,8);
   FillChar(tmpString[1],Length(tmpString),'0');
   E_ArchiveHEX.Text := tmpString;
  end;

  ArchiveIsOpened := False;
 end;
end;


end.