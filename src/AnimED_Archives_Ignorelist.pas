{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Hardcoded ignore list of filenames (temporary solution)

  Written by dsp2003.
}

unit AnimED_Archives_Ignorelist;

uses JUtils, StringsW;

interface

function IgnoreList : TStringsW;
function IgnoreListConfirm(FileName : widestring) : boolean;

implementation

uses AnimED_Main;

function IgnoreList;
begin
 Result := TStringsW.Create;
 with Result do
  Add('thumbs.db');
 end;
end;

function IgnoreListConfirm;
var i : integer;
    List : TStringsW;
begin
 List := IgnoreList;

 for i := 0 to List.Count-1 do begin
  Result := FileName = List[i];
  if Result then Exit;
 end;

end;

end.