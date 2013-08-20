{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Directory scanner module
  
  Written by dsp2003.
}
unit AnimED_Directories;

interface

uses Classes, SysUtils, JUtils, StringsW, JReconvertor;

procedure PickDirContents(Path, Filter : widestring; Mode : boolean; JISMode : boolean = True);
procedure ScanDir(StartDir, Mask : widestring; List: TStrings; ListW : TStringsW; Mode : boolean; JISMode : boolean = True);
function StringStrip(DirName : widestring; SLength : word) : widestring;
procedure AddedFilesSync(ExtractNames : boolean = False);

var AddedFiles : TStringList;
    AddedFilesW : TStringsW;
    RootDir : widestring;

const smFilesOnly    = False;
      smAllowDirs    = True;

implementation

procedure AddedFilesSync;
var i : longword;
begin
 if AddedFilesW <> nil then
  if AddedFiles <> nil then
   if AddedFilesW.Count > 0 then begin
    AddedFiles.Clear;
    for i := 0 to AddedFilesW.Count-1 do begin
     if ExtractNames then AddedFilesW.Strings[i] := ExtractFileName(AddedFilesW.Strings[i]);
     AddedFiles.Add(Wide2JIS(AddedFilesW.Strings[i]));
    end;
   end; 
end;

function StringStrip;
var i : integer; s : widestring;
begin
 for i := SLength+1 to Length(DirName) do s := s + DirName[i];
 Result := s;
end;

// now those two procedures are wrappers for JUtils functions
procedure PickDirContents;
begin
 if AddedFiles <> nil then FreeAndNil(AddedFiles);
 if AddedFilesW <> nil then FreeAndNil(AddedFilesW);

 AddedFiles := TStringList.Create;
 AddedFilesW := TStringsW.Create;

 ScanDir(Path,Filter,AddedFiles,AddedFilesW,Mode,JISMode);
end;

procedure ScanDir;
var tmpStringsW : TStringsW;
    i : integer;
begin
 if StartDir[Length(StartDir)] <> '\' then StartDir := StartDir + '\';

 tmpStringsW := TStringsW.Create;

 case Mode of
  smFilesOnly : FindMask(StartDir+Mask,tmpStringsW);
  smAllowDirs : FindAllRelative(StartDir,Mask,tmpStringsW);
 end;

 for i := 0 to tmpStringsW.Count - 1 do begin
  ListW.Add(tmpStringsW.Strings[i]);
  case JISMode of
   True  : List.Add(Wide2JIS(tmpStringsW.Strings[i]));
   False : List.Add(tmpStringsW.Strings[i]);
  end;
 end;

 FreeAndNil(tmpStringsW);
end;

end.