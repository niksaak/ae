{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Application project file
  
  Written by dsp2003.
}

program AnimED;

uses
  Forms,
  AnimED_Main in 'AnimED_Main.pas' {MainForm},
  AnimED_GrapS in 'AnimED_GrapS.pas' {GrapSForm},
  AnimED_ImagePreview in 'AnimED_ImagePreview.pas' {PreviewForm},
  AnimED_Archives_Info in 'AnimED_Archives_Info.pas' {FileInfo_Form};

{$R *.res}
{$R AE_Extras.res}

begin
  Application.Initialize;
  Application.Title := '';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPreviewForm, PreviewForm);
  Application.CreateForm(TGrapSForm, GrapSForm);
  Application.CreateForm(TFileInfo_Form, FileInfo_Form);
  Application.Run;
end.
