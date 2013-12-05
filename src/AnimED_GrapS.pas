{
  AE - VN Tools
  © 2007-2013 WinKiller Studio. Open Source.
  This software is free. Please see License for details.

  GrapS - the RAW image reader tool

  Written by dsp2003 & Nik.
}
unit AnimED_GrapS;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, ClipBrd, ShellAPI,

  Process_Control, JUtils, FileStreamJ, JReconvertor,

  AG_Fundamental,
  AnimED_Dialogs,
  AnimED_Graphics,
  AnimED_Translation_Strings,
  AnimED_Math,
  AnimED_Misc,
  AnimED_Version,
  AG_StdFmt, UnicodeComponents;

type
  TGrapSForm = class(TForm)
    I_Graps_View: TImage;
    MainMenu_GrapS: TMainMenu;
    M_Graps_File: TMenuItem;
    M_Graps_OpenFile: TMenuItem;
    M_Graps_Sep1: TMenuItem;
    M_Graps_SaveAsBMP: TMenuItem;
    M_Graps_Sep2: TMenuItem;
    M_Graps_Exit: TMenuItem;
    GB_Graps_Image: TGroupBox;
    L_Graps_Width: TLabelW;
    E_Graps_Width: TEdit;
    L_Graps_Height: TLabelW;
    E_Graps_Height: TEdit;
    L_Graps_Bitdepth: TLabelW;
    CB_Graps_Bitdepth: TComboBox;
    L_Graps_CalcStrSizeHEX: TLabelW;
    Bevel_Graps_1: TBevel;
    TrackBar_Graps_Width: TTrackBar;
    TrackBar_Graps_Height: TTrackBar;
    Bevel_Graps_2: TBevel;
    CB_Graps_Stretch: TCheckBox;
    Memo_Graps_HowTo: TMemo;
    M_Graps_Help: TMenuItem;
    PC_Graps_Controls: TPageControl;
    TS_Graps_FileMode: TTabSheet;
    TS_Graps_ProcessList: TTabSheet;
    GB_Graps_Seek: TGroupBox;
    L_Graps_Offset: TLabelW;
    L_Graps_SeekStep: TLabelW;
    L_Graps_FinalOffsetText: TLabelW;
    L_Graps_FinalOffset: TLabelW;
    E_Graps_Offset: TEdit;
    B_Graps_Back2: TButton;
    B_Graps_BackSeek: TButton;
    B_Graps_JumpUp: TButton;
    B_Graps_NextSeek: TButton;
    B_Graps_Next2: TButton;
    E_Graps_Step: TEdit;
    B_Graps_Back1: TButton;
    B_Graps_Next1: TButton;
    B_Graps_Reset: TButton;
    B_Graps_JumpDown: TButton;
    CB_Graps_ProcessList: TGroupBox;
    LB_Graps_ProcessList: TListBox;
    E_Graps_ProcStart: TEdit;
    B_Graps_CopyProcMem: TButton;
    L_Graps_ProcAddressStart: TLabelW;
    L_Graps_ProcMemError: TLabelW;
    B_Graps_ProcListRefresh: TButton;
    E_Graps_StreamSizeValue: TEdit;
    E_Graps_ProcMemAmount: TEdit;
    L_Graps_StreamSizeValue: TLabelW;
    L_Graps_ProcMemCpy: TLabelW;
    B_Graps_MemCpyFromCalc: TButton;
    B_Graps_MemAddrPaste: TButton;
    CB_Graps_MemoryAutoCpy: TCheckBox;
    E_Graps_CpyAutoRef: TEdit;
    UD_Graps_AutoMemRef: TUpDown;
    T_Graps_AutoMemRef: TTimer;
    CB_Graps_Interleaved: TCheckBox;
    procedure M_Graps_ExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure M_Graps_OpenFileClick(Sender: TObject);
    procedure E_Graps_WidthChange(Sender: TObject);
    procedure E_Graps_HeightChange(Sender: TObject);
    procedure CB_Graps_BitdepthChange(Sender: TObject);
    procedure E_Graps_OffsetChange(Sender: TObject);
    procedure B_Graps_JumpUpClick(Sender: TObject);
    procedure B_Graps_Next2Click(Sender: TObject);
    procedure B_Graps_Back2Click(Sender: TObject);
    procedure B_Graps_BackSeekClick(Sender: TObject);
    procedure B_Graps_NextSeekClick(Sender: TObject);
    procedure TrackBar_Graps_WidthChange(Sender: TObject);
    procedure TrackBar_Graps_HeightChange(Sender: TObject);
    procedure B_Graps_JumpDownClick(Sender: TObject);
    procedure B_Graps_Back1Click(Sender: TObject);
    procedure B_Graps_Next1Click(Sender: TObject);
    procedure B_Graps_ResetClick(Sender: TObject);
    procedure M_Graps_SaveAsBMPClick(Sender: TObject);
    procedure CB_Graps_StretchClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure M_Graps_HelpClick(Sender: TObject);
    procedure TS_Graps_ProcessListShow(Sender: TObject);
    procedure B_Graps_CopyProcMemClick(Sender: TObject);

    {}
    procedure ReadRAWAndWriteBMP(iStream : TStream; iPos : int64);
    {}
    procedure CalcSize;
    procedure E_Graps_StreamSizeValueChange(Sender: TObject);
    procedure B_Graps_MemCpyFromCalcClick(Sender: TObject);
    procedure B_Graps_MemAddrPasteClick(Sender: TObject);
    procedure CB_Graps_MemoryAutoCpyClick(Sender: TObject);
    procedure UD_Graps_AutoMemRefClick(Sender: TObject; Button: TUDBtnType);
    procedure T_Graps_AutoMemRefTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormPaint(Sender: TObject);

  private
    { Private declarations }
   pc : TProcessControl;
  public
    { Public declarations }
  protected
   procedure WMDropFiles (var Msg: TMessage); message wm_DropFiles;
  end;

var
  GrapsForm: TGrapsForm;
  Image_Width,
  Image_Height,
  Image_Bitdepth : longword;
  fStream, oStream, tmpStream : TStream;
  Image_ControlSize : integer;
  Image_BMP : TBMP;
  ImageName : widestring;
  GlobalOffset : longint;
  Palette : TPalette;

const GRAPS_VERSION = $20130308;
      GRAPS_BUILD   = 27;

implementation

uses AnimED_Main, AnimED_Translation;

{$R *.dfm}

// Drag-n-Drop Handler
procedure TGrapsForm.WMDropFiles(var Msg: TMessage);
var FileName: array[0..$FFF] of widechar;
begin
 DragQueryFileW(THandle(Msg.WParam), 0, FileName, SizeOf(Filename));

 ImageName := FileName;

 try
  FreeAndNil(fStream);

  fStream := TFileStreamJ.Create(ImageName,fmOpenRead);
  ReadRAWAndWriteBMP(fStream,strtoint(E_Graps_Offset.Text));
 except
  FreeAndNil(fStream);
 end;

 DragFinish(THandle(Msg.WParam));

end;

procedure TGrapsForm.CalcSize;
begin
 try
  Image_Width := strtoint(E_Graps_Width.Text);
  Image_Height := strtoint(E_Graps_Height.Text);
  Image_Bitdepth := strtoint(CB_Graps_BitDepth.Text);

  Image_ControlSize := GetScanLineLen(Image_Width,Image_BitDepth)*Image_Height;

  E_Graps_StreamSizeValue.Text := inttohex(Image_ControlSize,8);
 except
  E_Graps_Width.Text := inttostr(TrackBar_Graps_Width.Position);
  E_Graps_Height.Text := inttostr(TrackBar_Graps_Height.Position);
  CalcSize;
 end;
end;

procedure TGrapSForm.M_Graps_ExitClick(Sender: TObject);
begin
 CB_Graps_MemoryAutoCpy.Checked := False;
 T_Graps_AutoMemRef.Enabled := False;
 if fStream <> nil then FreeAndNil(fStream);
 GrapSForm.Close;
end;

procedure TGrapSForm.FormCreate(Sender: TObject);
begin
{ Allowing user to drag files onto the form }
 DragAcceptFiles(Handle, True);

{ duplicated from Translation Module in order to set the built-in translation }
 Caption := Application.Title+' - GrapS - '+AMS[MTRawReader];

{ GrapS has it's own icon. This example shows how to load alternative icons
  from resources. }
 try
  GrapSForm.Icon.Handle := LoadIcon(MainInstance,'ZGRAPSICON');
 except
 end;
end;

procedure TGrapSForm.ReadRAWAndWriteBMP;
var Dummy : array of byte;
begin
 Memo_Graps_HowTo.Visible := False;
 try
  CalcSize;

//  if tmpStream <> nil then FreeAndNil(tmpStream);

  tmpStream := TMemoryStream.Create;

  L_Graps_FinalOffset.Caption := inttostr(iStream.Size);

//  if iPos-Image_ControlSize > iStream.Size then E_Offset.Text := inttostr(iStream.Size-Image_ControlSize);

  FillChar(Image_BMP,SizeOf(Image_BMP),0);
  with Image_BMP do begin
   BMPHeader  := 'BM';
   FileSize   := 54 + Image_ControlSize;
   ImgOffset  := 54;
   HeaderSize := 40;
   Width      := Image_Width;
   Height     := Image_Height;
   XYZ        := 1;
   Bitdepth   := Image_Bitdepth;
   StreamSize := Image_ControlSize;
  end;

  tmpStream.Seek(0,soBeginning);

  with Image_BMP, tmpStream do begin

   Write(Image_BMP,SizeOf(Image_BMP));

   iStream.Seek(iPos,soBeginning);

   // 8 bit fix
   if BitDepth = 8 then begin
    Palette := GrayscalePalette;
    Write(Palette,SizeOf(Palette));
   end;

 { проверка на окончание файла и подсчёт }
   if Image_ControlSize > iStream.Size - iPos then begin
    if iPos <= iStream.Size then begin
     CopyFrom(iStream,iStream.Size - iPos);

     SetLength(Dummy,Image_ControlSize - (iStream.Size - iPos));

     Write(Dummy[0],Length(Dummy));
    end;// else E_Offset.Text := '0';
   end else CopyFrom(iStream,Image_ControlSize);

 { HEX view code }
//   iStream.Seek(iPos,soBeginning);

   tmpStream.Seek(0,soBeginning);
   I_Graps_View.Picture.Bitmap.LoadFromStream(tmpStream);
  end;
 except
  if Image_ControlSize > iStream.Size-iStream.Position then
// writing missing data as zeroes
   SetLength(Dummy,Image_ControlSize - (iStream.Size - iStream.Position));

  tmpStream.Write(Dummy[0],Length(Dummy));

  tmpStream.Seek(0,soBeginning);
  I_Graps_View.Picture.Bitmap.LoadFromStream(tmpStream);

 end;

 SetLength(Dummy,0);
 FreeAndNil(tmpStream);

end;

procedure TGrapSForm.M_Graps_OpenFileClick(Sender: TObject);
begin
 if ODialog_File(ImageName) then begin
  try
   FreeAndNil(fStream);

   fStream := TFileStreamJ.Create(ImageName,fmOpenRead);
   ReadRAWAndWriteBMP(fStream,strtoint(E_Graps_Offset.Text));
  except
   FreeAndNil(fStream);
  end;
 end;
end;

procedure TGrapSForm.E_Graps_WidthChange(Sender: TObject);
begin
try
 TrackBar_Graps_Width.Position := strtoint(E_Graps_Width.Text);
 CalcSize;
 if fStream <> nil then ReadRAWAndWriteBMP(fStream,strtoint(E_Graps_Offset.Text));
except
 E_Graps_Width.Text := inttostr(TrackBar_Graps_Width.Position);
end; 
end;

procedure TGrapSForm.E_Graps_HeightChange(Sender: TObject);
begin
try
 TrackBar_Graps_Height.Position := strtoint(E_Graps_Height.Text);
 CalcSize;
 if fStream <> nil then ReadRAWAndWriteBMP(fStream,strtoint(E_Graps_Offset.Text));
except
 E_Graps_Height.Text := inttostr(TrackBar_Graps_Height.Position);
end;
end;

procedure TGrapSForm.CB_Graps_BitdepthChange(Sender: TObject);
begin
 CalcSize;
 if fStream <> nil then ReadRAWAndWriteBMP(fStream,strtoint(E_Graps_Offset.Text));
end;

procedure TGrapSForm.E_Graps_OffsetChange(Sender: TObject);
begin
 try
  if strtoint(E_Graps_Offset.Text) < 0 then E_Graps_Offset.Text := '0';
  if fStream <> nil then ReadRAWAndWriteBMP(fStream,strtoint(E_Graps_Offset.Text));
 except
 end;
end;

procedure TGrapSForm.B_Graps_JumpUpClick(Sender: TObject);
begin
 E_Graps_Offset.Text := inttostr(strtoint(E_Graps_Offset.Text)+Image_ControlSize);
end;

procedure TGrapSForm.B_Graps_Next2Click(Sender: TObject);
begin
 E_Graps_Offset.Text := inttostr(strtoint(E_Graps_Offset.Text)+Image_Bitdepth);
end;

procedure TGrapSForm.B_Graps_Back2Click(Sender: TObject);
begin
 E_Graps_Offset.Text := inttostr(strtoint(E_Graps_Offset.Text)-Image_Bitdepth);
end;

procedure TGrapSForm.B_Graps_BackSeekClick(Sender: TObject);
begin
 E_Graps_Offset.Text := inttostr(strtoint(E_Graps_Offset.Text)-strtoint(E_Graps_Step.Text));
end;

procedure TGrapSForm.B_Graps_NextSeekClick(Sender: TObject);
begin
 E_Graps_Offset.Text := inttostr(strtoint(E_Graps_Offset.Text)+strtoint(E_Graps_Step.Text));
end;

procedure TGrapSForm.TrackBar_Graps_WidthChange(Sender: TObject);
begin
 E_Graps_Width.Text := inttostr(TrackBar_Graps_Width.Position);
end;

procedure TGrapSForm.TrackBar_Graps_HeightChange(Sender: TObject);
begin
 E_Graps_Height.Text := inttostr(TrackBar_Graps_Height.Position);
end;

procedure TGrapSForm.B_Graps_JumpDownClick(Sender: TObject);
begin
 E_Graps_Offset.Text := inttostr(strtoint(E_Graps_Offset.Text)-Image_ControlSize);
end;

procedure TGrapSForm.B_Graps_Back1Click(Sender: TObject);
begin
 E_Graps_Offset.Text := inttostr(strtoint(E_Graps_Offset.Text)-(Image_Bitdepth div 8));
end;

procedure TGrapSForm.B_Graps_Next1Click(Sender: TObject);
begin
 E_Graps_Offset.Text := inttostr(strtoint(E_Graps_Offset.Text)+(Image_Bitdepth div 8));
end;

procedure TGrapSForm.B_Graps_ResetClick(Sender: TObject);
begin
 E_Graps_Offset.Text := '0';
end;

procedure TGrapSForm.M_Graps_SaveAsBMPClick(Sender: TObject);
var FileName : widestring;
    newFileStream : TStream;
begin
 FileName := ImageName + '_offset_' + E_Graps_Offset.Text + '_bitres_' + CB_Graps_BitDepth.Text + '.bmp';

 if I_Graps_View.Picture.Bitmap <> nil then begin
  if SDialog_Image(FileName) then begin
   newFileStream := TFileStreamJ.Create(FileName,fmCreate);
   I_Graps_View.Picture.Bitmap.SaveToStream(newFileStream);
   FreeAndNil(newFileStream);
  end;
 end;

end;

procedure TGrapSForm.CB_Graps_StretchClick(Sender: TObject);
begin
 I_Graps_View.Stretch := CB_Graps_Stretch.Checked;
end;

procedure TGrapSForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 CB_Graps_MemoryAutoCpy.Checked := False;
 T_Graps_AutoMemRef.Enabled := False;
 if fStream <> nil then FreeAndNil(fStream);
 MainForm.Position := poScreenCenter;
 MainForm.Show;
end;

procedure TGrapSForm.M_Graps_HelpClick(Sender: TObject);
begin
 MessageBoxW(handle, pwidechar(Ansi2Wide('GrapS - '+AMS[MTRawReader]+#10#10'Intrenal build '+inttostr(GRAPS_BUILD)+' - '+AEGetDate(GRAPS_VERSION))), pwidechar(Ansi2Wide(MainForm.TS_About.Caption)), mb_ok);
end;

procedure TGrapSForm.TS_Graps_ProcessListShow(Sender: TObject);
var list : TStringList;
    i : longword;
begin
 if pc = nil then pc := TProcessControl.Create;
 pc.Refresh;
 list := TStringList.Create;
 pc.GetProcessList(list);
 LB_Graps_ProcessList.Clear;
 for i := 0 to list.Count-1 do begin
  LB_Graps_ProcessList.Items.Add(list[i]);
 end;
 list.Destroy;
end;

procedure TGrapSForm.B_Graps_CopyProcMemClick(Sender: TObject);
var i, j : longword;
begin
 if LB_Graps_ProcessList.ItemIndex <> -1 then begin

  try
   i := LB_Graps_ProcessList.ItemIndex;

   try
    if E_Graps_ProcStart.Text <> '' then j := hextoint(E_Graps_ProcStart.Text) else begin
     E_Graps_ProcStart.Text := '0';
     j := 0;
    end;
   except
    E_Graps_ProcStart.Text := '0';
    j := 0;
   end;

   if E_Graps_ProcMemAmount.Text = '0' then E_Graps_ProcMemAmount.Text := E_Graps_StreamSizeValue.Text;

   ImageName := LB_Graps_ProcessList.Items.Strings[i];

   if fStream <> nil then FreeAndNil(fStream);
   fStream := TMemoryStream.Create;

{   Image_Width := strtoint(E_Width.Text);
   Image_Height := strtoint(E_Height.Text);
   Image_Bitdepth := strtoint(CB_BitDepth.Text);

   Image_ControlSize := GetScanLineLen(Image_Width,Image_BitDepth)*Image_Height;}

   pc.ReadMemory(i,j,Image_ControlSize,fStream);

   L_Graps_ProcMemError.Caption := pc.GetLastError;

   fStream.Position := 0;

   ReadRAWAndWriteBMP(fStream,0);
  except
   L_Graps_ProcMemError.Caption := 'Incorrect value in the input box.';
  end;
 end else L_Graps_ProcMemError.Caption := 'Please select process!';

end;

procedure TGrapSForm.E_Graps_StreamSizeValueChange(Sender: TObject);
begin
 L_Graps_StreamSizeValue.Caption := inttostr(hextoint(E_Graps_StreamSizeValue.Text));
end;

procedure TGrapSForm.B_Graps_MemCpyFromCalcClick(Sender: TObject);
begin
 E_Graps_ProcMemAmount.Text := E_Graps_StreamSizeValue.Text;
end;

procedure TGrapSForm.B_Graps_MemAddrPasteClick(Sender: TObject);
var Clip : TClipBoard;
begin
 Clip := TClipBoard.Create;
 with TClipboard(Clip) do if HasFormat(CF_TEXT) then E_Graps_ProcStart.Text := AsText;
 Clip.Free;
end;

procedure TGrapSForm.CB_Graps_MemoryAutoCpyClick(Sender: TObject);
begin
 T_Graps_AutoMemRef.Interval := UD_Graps_AutoMemRef.Position;
 T_Graps_AutoMemRef.Enabled := CB_Graps_MemoryAutoCpy.Checked;
end;

procedure TGrapSForm.UD_Graps_AutoMemRefClick(Sender: TObject;
  Button: TUDBtnType);
begin
 T_Graps_AutoMemRef.Interval := UD_Graps_AutoMemRef.Position;
end;

procedure TGrapSForm.T_Graps_AutoMemRefTimer(Sender: TObject);
begin
 B_Graps_CopyProcMem.Click;
end;

procedure TGrapSForm.FormShow(Sender: TObject);
var i : longword;
begin
 E_Graps_WidthChange(nil);
  { Loading instruction strings }
 if TransFile <> nil then begin
  LoadTranslation_Forms(GrapSForm);
  Memo_Graps_HowTo.Clear;
  for i := 1 to 6 do with Memo_Graps_HowTo.Lines do begin
   Add(LS('Memo_Graps_HowTo'+inttostr(i)));
   Add('');
  end;
 end;
 Memo_Graps_HowTo.WordWrap := True;
end;

procedure TGrapSForm.FormPaint(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
end;

end.
