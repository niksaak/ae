{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Game archive tool information window

  Written by dsp2003.
}
unit AnimED_Archives_Info;

interface

uses AA_RFA,
  AnimED_Translation,
  AnimED_Translation_Strings,
  AnimED_FileTypes,
  AnimED_Console,
  AnimED_Skin,
  AnimED_Skin_PercentCube,
  Generic_Hashes,
  AE_Misc_MD5,
  AnimED_Misc,
  AnimED_Version,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Gauges,
  JReconvertor, JUtils, JvExStdCtrls, JvEdit, UnicodeComponents;

type
  TFileInfo_Form = class(TForm)
    PC_FileAndArchiveInfo: TPageControl;
    TS_Info_File: TTabSheet;
    B_FileInfo_OK: TButton;
    L_Arc_FilePathText: TLabelW;
    Bevel1: TBevel;
    I_Arc_Icon: TImage;
    Bevel2: TBevel;
    L_Arc_FileTypeText: TLabelW;
    L_Arc_FileHealthText: TLabelW;
    L_Arc_FileType: TLabelW;
    L_Arc_FileHealth: TLabelW;
    L_Arc_FileSizeText: TLabelW;
    L_Arc_FileSizeCText: TLabelW;
    Bevel3: TBevel;
    L_Arc_FilePath: TLabelW;
    L_Arc_FileSize: TLabelW;
    L_Arc_FileSizeC: TLabelW;
    TS_Info_Archive: TTabSheet;
    I_PercentCompression: TImage;
    L_Arc_IDS: TLabelW;
    L_Arc_EngineVersion: TLabelW;
    L_Arc_EngineVer: TLabelW;
    L_Arc_FormatSupportStat: TLabelW;
    L_Arc_FormatSup: TLabelW;
    Bevel5: TBevel;
    L_Arc_TotalRecords: TLabelW;
    L_Arc_Records: TLabelW;
    L_Arc_PhysicalArcSize: TLabelW;
    L_Arc_UncompressedFilesSize: TLabelW;
    L_Arc_CalculatedFilesSize: TLabelW;
    Bevel6: TBevel;
    L_Arc_WastedSize: TLabelW;
    L_Arc_SavedSize: TLabelW;
    L_Arc_FragRatio: TLabelW;
    L_Arc_CompRatio: TLabelW;
    L_Arc_PhysicalSize: TLabelW;
    L_Arc_UncompressedSize: TLabelW;
    L_Arc_CalculatedSize: TLabelW;
    L_Arc_Wasted: TLabelW;
    L_Arc_Saved: TLabelW;
    L_Arc_Comp: TLabelW;
    L_Arc_Frag: TLabelW;
    I_PercentFragmentation: TImage;
    L_Arc_CompTypeText: TLabelW;
    L_Arc_CompType: TLabelW;
    I_PercentDamaged: TImage;
    L_Arc_DamageRatio: TLabelW;
    L_Arc_Damage: TLabelW;
    E_Arc_FileName: TEdit;
    PC_Attributes: TPageControl;
    TS_Info_Attributes: TTabSheet;
    TS_Info_AdditionalFields: TTabSheet;
    L_Arc_CreatedText: TLabelW;
    L_Arc_Created: TLabelW;
    L_Arc_Modified: TLabelW;
    L_Arc_ModifiedText: TLabelW;
    L_Arc_OpenedText: TLabelW;
    L_Arc_Opened: TLabelW;
    Bevel4: TBevel;
    L_Arc_Attrib: TLabelW;
    CB_Arc_ReadOnly: TCheckBox;
    CB_Arc_Archive: TCheckBox;
    CB_Arc_Hidden: TCheckBox;
    CB_Arc_Compressed: TCheckBox;
    CB_Arc_Encrypted: TCheckBox;
    CB_Arc_System: TCheckBox;
    CB_Arc_Virtual: TCheckBox;
    CB_Arc_Deleted: TCheckBox;
    M_AddFields: TMemo;
    TS_Info_Hashes: TTabSheet;
    GB_MD5: TGroupBox;
    E_ArchiveMD5: TEdit;
    GB_CRC32: TGroupBox;
    E_ArchiveHex: TEdit;
    B_DoMD5: TButton;
    B_DoCRC32: TButton;
    L_Arc_MissingSize: TLabelW;
    L_Arc_Missing: TLabelW;
    procedure B_FileInfo_OKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure B_DoCRC32Click(Sender: TObject);
    procedure B_DoMD5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FileInfo_Form: TFileInfo_Form; ArchiveIsScanned : boolean;

implementation

uses AnimED_Archives, AnimED_Main;

{$R *.dfm}

procedure TFileInfo_Form.B_FileInfo_OKClick(Sender: TObject);
begin
 Close;
end;

procedure TFileInfo_Form.FormShow(Sender: TObject);
var i, j, k, l, m : integer;
    TextSep, CurFN, CurFP : widestring;
begin
 LoadTranslation_Forms(FileInfo_Form);
 M_AddFields.Clear;
 M_AddFields.Lines.Add(AMS[AFileNoData]);

 with ArcFragCount do begin

  with FileInfo_Form do begin
   Caption                          := AMS[AInformation];
   TS_Info_File.Caption             := AMS[AFile];
   TS_Info_AdditionalFields.Caption := AMS[AAddFields];
   TS_Info_Archive.Caption          := AMS[AArchive];
  end;

  if RFA_IDS <> '' then begin
   L_Arc_IDS.Caption := RFA_IDS;
  end else begin
   L_Arc_IDS.Caption := AMS[AUnknownFormat];
  end;

  //L_Arc_EngineVersion.Caption := AMS[AEngineVersion]+':';

  //L_Arc_EngineVer.Caption := AEGetVersion(APP_VERSION_BIN);
  if RFA_ID <> -1 then begin
   L_Arc_EngineVer.Caption := AEGetDate(ArcFormats[RFA_ID].Ver,True); //AEGetVersion;
  end else begin
   L_Arc_EngineVer.Caption := AMS[AUnknownFileType];
  end;

  //L_Arc_FormatSupportStat.Caption := AMS[AFormatStatus]+':';
  if RFA_ID <> -1 then begin
   L_Arc_FormatSup.Caption := ArcStat[ArcFormats[RFA_ID].Stat];
  end else begin
   L_Arc_FormatSup.Caption := AMS[AUnknownFileType];
  end;

  //L_Arc_TotalRecords.Caption := AMS[ARecordsInArchive]+':';
  L_Arc_Records.Caption      := Format('%.n',[(RecordsCount)*1.0]);//inttostr(RecordsCount);

  //L_Arc_PhysicalArcSize.Caption := AMS[APhysicalArcSize]+':';
  L_Arc_PhysicalSize.Caption    := Format('%.n',[Physical*1.0])+' '+AMS[aBytes];//inttostr(Physical)+' '+AMS[aBytes];

  //L_Arc_UncompressedFilesSize.Caption := AMS[AUncompressedSize]+':';
  L_Arc_UncompressedSize.Caption      := Format('%.n',[Uncompressed*1.0])+' '+AMS[aBytes];//inttostr(Uncompressed)+' '+AMS[aBytes];

  //L_Arc_CalculatedFilesSize.Caption := AMS[ACalculatedSize]+':';
  L_Arc_CalculatedSize.Caption      := Format('%.n',[Calculated*1.0])+' '+AMS[aBytes];//inttostr(Calculated)+' '+AMS[aBytes];

  //L_Arc_WastedSize.Caption := AMS[AWasted]+':';
  L_Arc_Wasted.Caption     := Format('%.n',[Wasted*1.0])+' '+AMS[aBytes];//inttostr(Wasted)+' '+AMS[aBytes];

  //L_Arc_SavedSize.Caption := AMS[ASaved]+':';
  L_Arc_Saved.Caption     := Format('%.n',[Saved*1.0])+' '+AMS[aBytes];//inttostr(Saved)+' '+AMS[aBytes];

  //L_Arc_MissingSize.Caption := AMS[AMissing]+':';
  L_Arc_Missing.Caption     := Format('%.n',[Missing*1.0])+' '+AMS[aBytes];

  //L_Arc_CompRatio.Caption := AMS[ACompRatio]+':';
  L_Arc_Comp.Caption      := inttostr(round(CompRatio*100))+'%';

  if FragRatio*100 < 100 then l := 100 - round(FragRatio*100) else l := 0;

  if Calculated = 0 then Calculated := 1;

  m := round((Missing / Calculated)*100);

  //L_Arc_FragRatio.Caption   := AMS[AFragRatio]+':';
  L_Arc_Frag.Caption        := inttostr(l)+'%';

  //L_Arc_DamageRatio.Caption := AMS[ADamageRatio]+':';
  L_Arc_Damage.Caption      := inttostr(m)+'%';

  Skin_DrawPercentFigure(I_PercentCompression.Picture.Bitmap  ,pSkinIceCube,  round(CompRatio*100),I_PercentCompression.Width,I_PercentCompression.Height);
  Skin_DrawPercentFigure(I_PercentFragmentation.Picture.Bitmap,pSkinDefault,l,I_PercentFragmentation.Width,I_PercentFragmentation.Height);
  Skin_DrawPercentFigure(I_PercentDamaged.Picture.Bitmap      ,pSkinBubbleGum,m,I_PercentDamaged.Width,I_PercentDamaged.Height);
 end;

 with MainForm do try

  L_Arc_Created.Caption := AMS[AFileNoData];
  L_Arc_Modified.Caption := AMS[AFileNoData];
  L_Arc_Opened.Caption := AMS[AFileNoData];
  L_Arc_FileHealth.Caption := AMS[AFileNoData];
  L_Arc_FileType.Caption := AMS[AFileNoData];
  L_Arc_FilePath.Caption := AMS[AFileNoData];
  L_Arc_FileSize.Caption := AMS[AFileNoData];
  L_Arc_FileSizeC.Caption := AMS[AFileNoData];
  L_Arc_CompType.Caption := AMS[AFileNoData];
  E_Arc_FileName.Text := '';

  if LV_ArcFileList.ItemIndex <> -1 then begin

   i := LV_ArcFileList.ItemIndex+1;

   CurFN := ExtractFileName(JIS2Wide(RFA[i].RFA_3));
   CurFP := ExtractFilePath(JIS2Wide(RFA[i].RFA_3));

   E_Arc_FileName.Text     := Wide2JIS(CurFN);
   L_Arc_FilePath.Caption  := Wide2JIS(CurFP);
   L_Arc_FileSize.Caption  := inttostr(RFA[i].RFA_2 div 1024)+' '+AMS[AKilobytes]+' ('+inttostr(RFA[i].RFA_2)+' '+AMS[ABytes]+')';
   L_Arc_FileSizeC.Caption := inttostr(RFA[i].RFA_C div 1024)+' '+AMS[AKilobytes]+' ('+inttostr(RFA[i].RFA_C)+' '+AMS[ABytes]+')';
   CB_Arc_Encrypted.Checked := RFA[i].RFA_E;
   CB_Arc_Compressed.Checked := RFA[i].RFA_Z;
//  I_Arc_Icon.Picture.Bitmap.FreeImage;
   if RFA[i].RFA_E then ImageList_Archiver.GetBitmap(5,I_Arc_Icon.Picture.Bitmap) else ImageList_Archiver.GetBitmap(Skin_GetImageIndex(ExtractFileExt(RFA[i].RFA_3)),I_Arc_Icon.Picture.Bitmap);


   case (RFA[i].RFA_1 > ArchiveStream.Size) of
    True  : L_Arc_FileHealth.Caption := AMS[AFileIsDamaged];
    False : case (RFA[i].RFA_2 = 0) of
             True  : L_Arc_FileHealth.Caption := AMS[AFileIsDead];
             False : L_Arc_FileHealth.Caption := AMS[AFileIsOK];
            end;
   end;

   L_Arc_CompType.Caption := AMS[ACompTypeRAW];

   if RFA[i].RFA_Z then case RFA[i].RFA_X of
    acNone    : L_Arc_CompType.Caption := AMS[ACompTypeNone];
    acNSASPB  : L_Arc_CompType.Caption := 'nScripter SPB';
    acNSALZSS : L_Arc_CompType.Caption := 'nScripter LZSS';
    acLZSS    : L_Arc_CompType.Caption := AMS[ACompTypeGenericLZSS];
    acBZip2   : L_Arc_CompType.Caption := 'BZip2';
    acZlib    : L_Arc_CompType.Caption := 'Zlib';
           else L_Arc_CompType.Caption := AMS[ACompTypeUnknown];
   end;

   try
    L_Arc_FileType.Caption := FileTypes(Skin_GetImageIndex(ExtractFileExt(RFA[i].RFA_3)));
   except
    L_Arc_FileType.Caption := AMS[AUnknownFileType];
   end;

 { заполняем доп. поля }

   M_AddFields.Clear;

   if (Length(RFA[0].RFA_T) > 0) and (Length(RFA[1].RFA_T) > 0) then begin
    if (Length(RFA[0].RFA_T[0]) > 0) and (Length(RFA[1].RFA_T[0]) > 0) then begin

     for j := 0 to Length(RFA[i].RFA_T)-1 do begin
      M_AddFields.Lines.Add(AMS[AFieldGroup]+' #'+inttostr(j));
      for k := 0 to Length(RFA[i].RFA_T[j])-1 do begin
       M_AddFields.Lines.Add(RFA[0].RFA_T[j][k]+' : '+RFA[i].RFA_T[j][k]);
       if k = Length(RFA[i].RFA_T[j])-1 then begin
        TextSep := '';
        try
         //for m := 0 to Length(RFA[0].RFA_T[j][k]+' : '+RFA[i].RFA_T[j][k])-1 do TextSep := TextSep + '-';
         SetLength(TextSep,Length(RFA[0].RFA_T[j][k]+' : '+RFA[i].RFA_T[j][k]));
         FillChar(TextSep[1],Length(TextSep),'-');

         M_AddFields.Lines.Add(TextSep);
        finally
        end;
       end;
      end;
     end;

    end;
   end else if Length(RFA[i].RFA_T) = 0 then M_AddFields.Lines.Add(AMS[AFileNoData]);

{   for j := 0 to Length(RFA[0].RFA_T)-1 do begin
    for k := 0 to (Length(RFA[0].RFA_T[j])-1) div 2 do begin
     M_AddFields.Lines.Add(RFA[0].RFA_T[j][k*2]+' : '+RFA[0].RFA_T[j][k*2+1]);
     TextSep := '';
     for m := 0 to Length(RFA[0].RFA_T[j][k*2]+' : '+RFA[0].RFA_T[j][k*2+1])-1 do TextSep := TextSep + '-';
     M_AddFields.Lines.Add(TextSep);
    end;
   end;}

  end;

 except
  { улыбаемся и машем }
 end;
end;

procedure TFileInfo_Form.FormCreate(Sender: TObject);
begin
 ArchiveIsScanned := False;
end;

procedure TFileInfo_Form.FormResize(Sender: TObject);
var l, m : integer;
begin
 with ArcFragCount do begin
  if FragRatio*100 < 100 then l := 100 - round(FragRatio*100) else l := 0;
  if Calculated = 0 then Calculated := 1;
  m := round((Missing / Calculated)*100);

  Skin_DrawPercentFigure(I_PercentCompression.Picture.Bitmap  ,pSkinIceCube,  round(CompRatio*100),I_PercentCompression.Width,I_PercentCompression.Height);
  Skin_DrawPercentFigure(I_PercentFragmentation.Picture.Bitmap,pSkinDefault,l,I_PercentFragmentation.Width,I_PercentFragmentation.Height);
  Skin_DrawPercentFigure(I_PercentDamaged.Picture.Bitmap      ,pSkinBubbleGum,m,I_PercentDamaged.Width,I_PercentDamaged.Height);
 end;
end;

procedure TFileInfo_Form.B_DoCRC32Click(Sender: TObject);
begin
//Sanity check
 if ArchiveStream <> nil then begin
  if ArchiveStream.Size > 64 * 1024 then if MessageBox(handle,pchar(AMS[AHashHugeFileWarn]),pchar(AMS[AHashCRC32Confirm]),mb_yesno) <> mrYes then Exit;
  LogI(AMS[ICalculatingCRC32]);
  E_ArchiveHex.Text := inttohex(CRC32(ArchiveStream),8);
  LogI(AMS[IDone]);
 end else LogW(AMS[WArchiveExtract]);
end;

procedure TFileInfo_Form.B_DoMD5Click(Sender: TObject);
begin
//Sanity check
 if ArchiveStream <> nil then begin
  if ArchiveStream.Size > 64 * 1024 then if MessageBox(handle,pchar(AMS[AHashHugeFileWarn]),pchar(AMS[AHashMD5Confirm]),mb_yesno) <> mrYes then Exit;
  LogI(AMS[ICalculatingMD5]);
  E_ArchiveMD5.Text := MD5DigestToStr(MD5Stream(ArchiveStream));
  LogI(AMS[IDone]);
 end else LogW(AMS[WArchiveExtract]);
end;

end.
