unit JUtils;

interface

// todo: make Lower/UpperCase wrapper for Wide*Case.
// todo: reconvertion table for Lower/UpperCase?

uses StringsW, Windows, Classes;

procedure FindMask(Mask: WideString; Result: TStringsW); overload;
procedure FindMask(Mask: WideString; Result: TStrings); overload;

procedure StringsW2J(const Src: TStringsW; const Dest: TStrings);
procedure FindAll(BasePath, Mask: WideString; Result: TStringsW); overload;
procedure FindAll(BasePath, Mask: WideString; Result: TStrings); overload;

procedure FindAllRelative(BasePath, Mask: WideString; Result: TStringsW); overload;
procedure FindAllRelative(BasePath, Mask: WideString; Result: TStrings); overload;

// including trailing backslash
function ExtractFilePath(FileName: WideString): WideString; overload;
function ExtractFileName(Path: WideString): WideString; overload;

function ExtractFileExt(FileName: WideString): WideString; overload;
function ChangeFileExt(FileName, Extension: WideString): WideString; overload;

function IncludeTrailingBackslash(Path: WideString): WideString; overload;
function ExcludeTrailingBackslash(Path: WideString): WideString; overload;

// if file didn't exist, sets Result.ftLastWriteTime.dwLowDateTime to 0
function FileInfo(Path: WideString): TWin32FindDataW;
function IsDirectory(Path: WideString): Boolean;
function FileExists(Path: WideString): Boolean;
function DirectoryExists(const Directory: widestring): Boolean;

{ recursive functions }
function CopyDirectory(Source, Destination: WideString): Boolean;
function RemoveDirectory(Path: WideString): Boolean;

function ForceDirectories(Path: WideString): Boolean; overload;
function MkDir(Path: WideString): Boolean; overload;

function UpperCase(const Str: WideString): WideString; overload;
function LowerCase(const Str: WideString): WideString; overload;

procedure SetStringW(var s: WideString; buffer: PWideChar; len: word);
function ParamStrW(Index: Integer): widestring;

function RenameFile(const OldName, NewName: widestring): Boolean;

{ SysUtils' functions overloading }
{function ExtractFilePath(FileName: String): String; overload;
function ExtractFileName(Path: String): String; overload;

function ExtractFileExt(FileName: String): String; overload;
function ChangeFileExt(FileName, Extension: String): String; overload;

function IncludeTrailingBackslash(Path: String): String; overload;
function ExcludeTrailingBackslash(Path: String): String; overload;

function ForceDirectories(Path: String): Boolean; overload;
function MkDirW(Path: String): Boolean; overload;

function UpperCase(const Str: String): String; overload;
function LowerCase(const Str: String): String; overload;}

implementation

uses JReconvertor, SysUtils;

// override SysUtils.FindClose
function FindClose(Handle: DWord): Boolean;
begin
  Result := Windows.FindClose(Handle)
end;

procedure FindMask(Mask: WideString; Result: TStringsW);
var
  SR: TWin32FindDataW;
  Handle: DWord;
begin
  Handle := FindFirstFileW(PWideChar(Mask), SR);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    repeat
      if (WideString(SR.cFileName) <> '.') and (WideString(SR.cFileName) <> '..') then
        Result.Add(SR.cFileName, SR.dwFileAttributes)
    until not FindNextFileW(Handle, SR);
    FindClose(Handle)
  end
end;

procedure FindAll(BasePath, Mask: WideString; Result: TStringsW);
var
  I: DWord;
  S: TStringsW;
begin
  BasePath := IncludeTrailingBackslash(BasePath);

  S := TStringsW.Create;
  FindMask(BasePath + Mask, S);

  if S.Count <> 0 then
    for I := 0 to S.Count - 1 do
      if S.Tags[I] and FILE_ATTRIBUTE_DIRECTORY = 0 then
        Result.Add(BasePath + S[I])
        else
          FindAll(BasePath + S[I], Mask, Result);

  S.Free
end;

procedure FindAllRelative(BasePath, Mask: WideString; Result: TStringsW);
var
  I: DWord;
begin
  BasePath := IncludeTrailingBackslash(BasePath);
  FindAll(BasePath, Mask, Result);

  if Result.Count <> 0 then
    for I := 0 to Result.Count - 1 do
      Result[I] := Copy(Result[I], Length(BasePath) + 1, Length(Result[I]))
end;


procedure StringsW2J;
var
  I: Word;
begin
  if Src.Count <> 0 then
    for I := 0 to Src.Count - 1 do
      Dest.Add( Wide2JIS(Src[I]) )
end;

procedure FindMask(Mask: WideString; Result: TStrings);
var
  S: TStringsW;
begin
  S := TStringsW.Create;
  try
    FindMask(Mask, S);
    StringsW2J(S, Result)
  finally
    S.Free
  end
end;

procedure FindAll(BasePath, Mask: WideString; Result: TStrings);
var
  S: TStringsW;
begin
  S := TStringsW.Create;
  try
    FindAll(BasePath, Mask, S);
    StringsW2J(S, Result)
  finally
    S.Free
  end
end;

procedure FindAllRelative(BasePath, Mask: WideString; Result: TStrings);
var
  S: TStringsW;
begin
  S := TStringsW.Create;
  try
    FindAllRelative(BasePath, Mask, S);
    StringsW2J(S, Result)
  finally
    S.Free
  end
end;


function ExtractFilePath(FileName: WideString): WideString;
var
  I: Word;
begin
  Result := '';
  I := Length(FileName);
  if I = 0 then Exit;
  while (I >= 1) and (FileName[I] <> '\') do
    Dec(I);
  Result := Copy(FileName, 1, I)
end;

function IncludeTrailingBackslash(Path: WideString): WideString;
begin
  Result := Path;
  if (Result = '') or (Result[Length(Result)] <> '\') then
    Result := Result + '\'
end;

function ExcludeTrailingBackslash(Path: WideString): WideString;
begin
  Result := Path;
  if (Result <> '') and (Result[Length(Result)] = '\') then
    Result := Copy(Result, 1, Length(Result) - 1)
end;

function ExtractFileName(Path: WideString): WideString;
var
  I: Word;
begin
  Result := '';
  if Length(Path) = 0 then Exit;
  for I := Length(Path) downto 0 do
    if Path[I] = '\' then
    begin
      Result := Copy(Path, I + 1, Length(Path));
      Exit
    end;

  Result := Path
end;

function ExtractFileExt(FileName: WideString): WideString;
var
  I: Word;
begin
  Result := '';
  if Length(FileName) = 0 then Exit;
  for I := Length(FileName) downto 0 do
    if FileName[I] = '\' then
      Break
      else if FileName[I] = '.' then
      begin
        Result := Copy(FileName, I, Length(FileName));
        Exit;
      end;
end;

function ChangeFileExt(FileName, Extension: WideString): WideString;
var
  I: Word;
begin
  if Length(FileName) = 0 then begin
   Result := Extension;
   Exit;
  end;
  for I := Length(FileName) downto 1 do
    if FileName[I] = '\' then
      Break
      else if FileName[I] = '.' then
      begin
        Result := Copy(FileName, 1, I - 1) + Extension;
        Exit
      end;

  Result := FileName + Extension;
end;

// dsp2003: added unicode version of file renaming function
function RenameFile;
begin
 Result := MoveFileW(PWideChar(OldName), PWideChar(NewName));
end;

function FileInfo;
var
  Handle: DWord;
begin
  Handle := FindFirstFileW(PWideChar( ExcludeTrailingBackslash(Path) ), Result);
  if Handle <> INVALID_HANDLE_VALUE then
    FindClose(Handle)
    else
      Result.ftLastWriteTime.dwLowDateTime := 0
end;

function IsDirectory;
var
  Info: TWin32FindDataW;
begin
  Info := FileInfo(Path);
  Result := (Info.ftLastWriteTime.dwLowDateTime <> 0) and (Info.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0)
end;

function FileExists;
var
  Info: TWin32FindDataW;
begin
  Info := FileInfo(Path);
  Result := (Info.ftLastWriteTime.dwLowDateTime <> 0) and (Info.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0)
end;

// dsp2003: added unicode version of directory existance check function
function DirectoryExists;
var
  Code: Integer;
begin
  Code := GetFileAttributesW(PWideChar(Directory));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

function CopyDirectory;
var
  Files: TStringsW;
  I: DWord;
begin
  Result := False;

  Source := IncludeTrailingBackslash(Source);
  Destination := IncludeTrailingBackslash(Destination);

  Files := TStringsW.Create;
  FindAllRelative(Source, '*.*', Files);

  if Files.Count <> 0 then
    for I := 0 to Files.Count - 1 do
    begin
      if not IsDirectory( ExtractFilePath(Files[I]) ) then
        ForceDirectories( ExtractFilePath(Files[I]) );
      if not CopyFileW( PWideChar(Source + Files[I]), PWideChar(Destination + Files[I]), False ) then
        Exit
    end;

  Result := True
end;

function RemoveDirectory;
var
  SR: TWin32FindDataW;
  Handle: DWord;
begin
  Result := False;
  Path := IncludeTrailingBackslash(Path);

  Handle := FindFirstFileW(PWideChar(Path + '*.*'), SR);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    repeat
      if (WideString(SR.cFileName) <> '.') and (WideString(SR.cFileName) <> '..') and
         (SR.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY <> 0) then
        RemoveDirectory(Path + SR.cFileName)
        else
          DeleteFileW(PWideChar(Path + SR.cFileName))
    until not FindNextFileW(Handle, SR);
    FindClose(Handle)
  end;

  Result := True
end;

function ForceDirectories(Path: WideString): Boolean;
var
  I: Word;
begin
  Result := True;
  Path := IncludeTrailingBackslash(Path);

  for I := 1 to Length(Path) do
    if Path[I] = '\' then
      try
        CreateDirectoryW(PWideChar(Copy(Path, 1, I)), NIL)
      except
        Result := False;
        Break
      end
end;

function MkDir(Path: WideString): Boolean;
begin
  Result := CreateDirectoryW(PWideChar(Path), NIL)
end;

function UpperCase(const Str: WideString): WideString;
var
  I: Word;
begin
  Result := Str;

  for I := 1 to Length(Result) do
    if (Result[I] >= WideChar('a')) and (Result[I] <= WideChar('z')) then
      Dec(Result[I], 32)
end;

function LowerCase(const Str: WideString): WideString;
var
  I: Word;
begin
  Result := Str;

  for I := 1 to Length(Result) do
    if (Result[I] >= WideChar('A')) and (Result[I] <= WideChar('Z')) then
      Inc(Result[I], 32)
end;

procedure SetStringW(var s: WideString; buffer: PWideChar; len: word);
begin
 SetLength(s,len*2);
 if buffer <> nil then Move(buffer^, s[1], len);
end;

// dsp2003:
// BUG: The following version of ParamStrW has been commented out cause the file
// association with AE makes the archive unopenable. The cause is still unknown.
{function ParamStrW;
var
  I, CurrentIndex: Word;
  CmdLine: WideString;
  Join: Boolean;
begin
  if Index = 0 then
  begin
    SetLength(Result, 500);
    SetLength(Result, GetModuleFileNameW(0, @Result[1], 500));
    Exit
  end;

  CmdLine := GetCommandLineW;

  Result := '';
  Join := False;
  CurrentIndex := 0;

  for I := 1 to Length(CmdLine) do
    if CmdLine[I] = '"' then
      Join := not Join
      else if (CmdLine[I] = ' ') and not Join then
        Inc(CurrentIndex)
        else if CurrentIndex = Index then
          Result := Result + CmdLine[I]
          else if CurrentIndex > Index then
            Exit
end;}

// dsp2003:
// An attempt to rewrite the paramstrw
function ParamStrW;
var
 i : Word;
 CurIndex : int64;
 CmdLine : WideString;
 parstrWide : WideString;
 Join: Boolean;
begin
 case Index of
 0 :  begin
       SetLength(parstrWide,$FFF);
       SetLength(parstrWide,GetModuleFileNameW(0, @parstrWide[1], $FFF));
       Result := parstrWide;
      end;
 else begin
       CurIndex := 0;
       CmdLine := GetCommandLineW;
       Join := False;
       parstrWide := ''; // cleanup

       for i := 1 to Length(CmdLine) do begin

        case CmdLine[i] of
         '"' : Join := not Join; // trigger
         ' ' : begin
                if Join then parstrWide := parstrWide + CmdLine[i]; // including space
                if not Join then inc(CurIndex); // ...or increasing index
               end;
         else  parstrWide := parstrWide + CmdLine[i];
        end;

        if Index > CurIndex then parstrWide := ''; // cleanup

        if Index < CurIndex then begin
         Result := parstrWide;
         Exit;
        end;

       end;

       if Index = CurIndex then Result := parstrWide;

      end;
 end;

end;

{ SysUtils' functions overloading }


{function ExtractFilePath(FileName: String): String;
begin
  Result := SysUtils.ExtractFilePath(FileName)
end;

function ExtractFileName(Path: String): String;
begin
  Result := SysUtils.ExtractFileName(Path)
end;

function ExtractFileExt(FileName: String): String;
begin
  Result := SysUtils.ExtractFileExt(FileName)
end;

function ChangeFileExt(FileName, Extension: String): String;
begin
  Result := SysUtils.ChangeFileExt(FileName, Extension)
end;

function IncludeTrailingBackslash(Path: String): String;
begin
  Result := SysUtils.IncludeTrailingBackslash(Path)
end;

function ExcludeTrailingBackslash(Path: String): String;
begin
  Result := SysUtils.ExcludeTrailingBackslash(Path)
end;        

function ForceDirectories(Path: String): Boolean; overload;
begin
  Result := SysUtils.ForceDirectories(Path)
end;

function MkDirW(Path: String): Boolean; overload;
begin
  System.MkDir(Path);
  Result := True
end;

function UpperCase(const Str: String): String;
begin
  Result := SysUtils.UpperCase(Str)
end;

function LowerCase(const Str: String): String;
begin
  Result := SysUtils.LowerCase(Str)
end; }

end.
