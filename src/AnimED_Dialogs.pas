{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Open\Save Dialog wrapper module
  
  Written by dsp2003.
}
unit AnimED_Dialogs;

interface

uses Classes, SysUtils, Dialogs, AnimED_Translation, StringsW;

{ open multiple files }
function ODialog_Files  (var FileNames : TStringsW) : boolean;

{ open single file }
function ODialog_File   (var FileName : widestring; Filter : integer = 0; Index : integer = 0; WindowTitle : widestring = '') : boolean;

{ wrappers for ODialog_File }
function ODialog_Archive(var FileName : widestring;                       Index : integer = 0) : boolean;
function ODialog_Image  (var FileName : widestring;                       Index : integer = 0) : boolean;

{ save file }
function SDialog_File   (var FileName : widestring; Filter : integer = 0; Index : integer = 0; WindowTitle : widestring = '') : boolean;

{ wrappers for SDialog_File }
function SDialog_Archive(var FileName : widestring;                       Index : integer = 0) : boolean;
function SDialog_Image  (var FileName : widestring;                       Index : integer = 0) : boolean;

function ODialog_DefaultOptions : TOpenOptions;
function SDialog_DefaultOptions : TOpenOptions;

var DialogFilters : array[0..4] of widestring;
{ 0 - all files,
  1 - archives,
  2 - images [unused]
  3 - reserved
  4 - reserved }

implementation

uses AnimED_Main;

function ODialog_Files;
var tmpStream : TStream;
begin
 with MainForm do begin
  OpenDialog.Filter  := DialogFilters[0];
  OpenDialog.Options := [ofHideReadOnly,ofEnableSizing,ofForceShowHidden,ofAllowMultiSelect];
  OpenDialog.Title   := 'Select files...'; //ODialog_Title_Files;
//  OpenDialog.Files   := FileNames;
  Result             := OpenDialog.Execute;
  // Assigning filenames
  if Result <> False then begin
   tmpStream := TMemoryStream.Create;
   OpenDialog.Files.SaveToStream(tmpStream);
   if tmpStream.Size = 0 then Result := False else Result := True;
   tmpStream.Position := 0;
   FileNames.LoadFromStream(tmpStream);
   FreeAndNil(tmpStream);
  end;
 end;
end;

function ODialog_File;
begin
 with MainForm do begin
  OpenDialog.Filter      := DialogFilters[Filter];
  OpenDialog.FilterIndex := Index;
  OpenDialog.Options     := ODialog_DefaultOptions;
  OpenDialog.Title       := WindowTitle;
  if FileName <> ''    then OpenDialog.FileName := FileName;
  Result                 := OpenDialog.Execute;
  FileName               := OpenDialog.FileName;
 end;
end;

function ODialog_Archive;
begin
 Result := ODialog_File(FileName,1,Index,'Select archive to open...'{ODialog_Title_Archive});
end;

function ODialog_Image;
begin
 Result := ODialog_File(FileName,2,Index,'Select image to open...'{ODialog_Title_Image});
end;

function SDialog_File;
begin
 with MainForm do begin
  SaveDialog.Filter      := DialogFilters[Filter];
  SaveDialog.FilterIndex := Index;
  SaveDialog.Options     := SDialog_DefaultOptions;
  SaveDialog.Title       := WindowTitle;
  if FileName <> ''    then SaveDialog.FileName := FileName;
  Result                 := SaveDialog.Execute;
  FileName               := SaveDialog.FileName;
 end;
end;

function SDialog_Archive;
begin
 Result := SDialog_File(FileName,1,Index,'Save archive as...'{SDialog_Title_Archive});
end;

function SDialog_Image;
begin
 Result := SDialog_File(FileName,2,Index,'Save image as...'{SDialog_Title_Image});
end;

function ODialog_DefaultOptions;
begin
 Result := [ofHideReadOnly,ofEnableSizing,ofForceShowHidden];
end;

function SDialog_DefaultOptions;
begin
 Result := [ofOverwritePrompt,ofHideReadOnly,ofEnableSizing,ofForceShowHidden];
end;

end.