{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Command line parser
  
  Written by dsp2003.
}

unit AnimED_CommandLine;

interface

uses AnimED_Archives,
     AnimED_FileTypes,
     AnimED_Misc, SysUtils, Windows, Forms, JUtils;

procedure ParseCommandLine;

implementation

uses AnimED_Main;

procedure ParseCommandLine;
var parse : widestring;
    FileStatus : boolean;
    i : integer;
begin
 FileStatus := False;

// MessageBoxW(0,pwidechar(GetCommandLineW),'Test',mb_ok);

 with MainForm do begin
  parse := paramstrw(1);
  if parse <> '' then begin

   OpenDialog.FileName := parse;

   for i := 0 to File_Ext_Images.Count-1 do begin
    if lowercase(ExtractFileExt(parse)) = File_Ext_Images[i] then begin
     if Image_Open_GUI(parse) then begin
      TS_EDGE.Show;
      FileStatus := True;
     end;
     break;
    end;
   end;

   if FileStatus = False then begin
    Open_Archive(parse,CB_ArchiveFormatList.ItemIndex);
    TS_Archiver.Show;
   end;
  end;
//if paramstr(1) = '' then begin
// '--archive' : CommandLine_OpenArchive(paramstr(2));
// '--audio'   : CommandLine_OpenAudio(paramstr(2));
// '--image'   : CommandLine_OpenImage(paramstr(2));
// '--script'  : CommandLine_openScript(paramstr(2));

// MessageBox(handle,pchar('Invalid command line has been specified. Usage:'+#10#13#10#13+ExtractFileName(Application.ExeName)+' open_as filename'),pchar(Application.Title),mb_ok);
 end;
end;

end.