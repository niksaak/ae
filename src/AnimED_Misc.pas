{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Misc data & functions

  Written by dsp2003.
}

unit AnimED_Misc;

interface

uses Classes, Sysutils, Controls, StdCtrls, Windows, Forms, AnimED_Console, JReconvertor, Clipbrd, Graphics, JUtils, StringsW;

type
 TFileTimes = array[1..3] of FileTime;

 TWrapRecord = record
  Height:Integer;
  Lines: array of string;
 end;

{ Originally by Thomas Stutz
  From http://www.swissdelphicenter.ch/torry/showcode.php?id=640 }
procedure ListBoxToClipboard(ListBox: TListBox; BufferSize: Integer; CopyAll: Boolean);
procedure ClipboardToListBox(ListBox: TListbox);

{ Originally by Max Kanzler
  From http://www.delphi3000.com/articles/article_4389.asp?SK=listbox }
function WrapText(Canvas : TCanvas; Text : string; const MaxWidth : integer) : TWrapRecord;

{ Displays OS version.
  From DelphiWorld.narod.ru examples. }
function SystemInformation : string;
function isVista78 : boolean;

function AE_GetFileTime(FileName : string) : TFileTimes; overload;
function AE_GetFileTime(FileName : widestring) : TFileTimes; overload;

function FAttribToDesc(Attrib : byte) : string;

var LicenseAccepted : boolean;

implementation

uses AnimED_Main;

function FAttribToDesc;
var AttribTable : TStringList; i : integer;
    TmpString : string;
begin
 TmpString := '';
 AttribTable := TStringList.Create;
 with AttribTable do begin
  if Attrib and $1  = $1  then Add('Read Only');
  if Attrib and $2  = $2  then Add('Hidden');
  if Attrib and $4  = $4  then Add('System');
  if Attrib and $7  = $7  then Add('Long file name');
  if Attrib and $8  = $8  then Add('Volume Label');
  if Attrib and $10 = $10 then Add('Subdirectory');
  if Attrib and $20 = $20 then Add('Archive');
  if Attrib and $40 = $40 then Add('Device');
  if Attrib and $80 = $80 then Add('Unused');
 end;
 for i := 1 to AttribTable.Count do begin
  TmpString := TmpString + AttribTable.Strings[i-1];
  if i <> AttribTable.Count then TmpString := TmpString + ', ';
 end;
 Result := TmpString;
 FreeAndNil(AttribTable);
end;

function AE_GetFileTime(FileName : string) : TFileTimes; overload;
var hl : cardinal;
    Times : TFileTimes;
begin
 hl := CreateFile(PAnsiChar(FileName),GENERIC_READ,0,nil,OPEN_EXISTING,FILE_ATTRIBUTE_READONLY,0);
 GetFileTime(hl, @Times[1], @Times[2], @Times[3]);
 CloseHandle(hl);
 Result := Times;
end;

function AE_GetFileTime(FileName : widestring) : TFileTimes; overload;
var hl : cardinal;
    Times : TFileTimes;
begin
 hl := CreateFileW(PWideChar(FileName),GENERIC_READ,0,nil,OPEN_EXISTING,FILE_ATTRIBUTE_READONLY,0);
 GetFileTime(hl, @Times[1], @Times[2], @Times[3]);
 CloseHandle(hl);
 Result := Times;
end;

function SystemInformation : string;
var osplatform  : string;
    buildnumber : integer;
begin
 case Win32Platform of
    VER_PLATFORM_WIN32_WINDOWS:
    begin
      osplatform := 'Windows 9x';
      BuildNumber := Win32BuildNumber and $0000FFFF;
    end;
    VER_PLATFORM_WIN32_NT:
    begin
      osplatform := 'Windows NT';
      BuildNumber := Win32BuildNumber;
    end;
    else
    begin
      osplatform := 'Windows';
      BuildNumber := 0;
    end;
  end;
  if (Win32Platform = VER_PLATFORM_WIN32_WINDOWS) or (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    if Win32CSDVersion = '' then
         Result := Format('%s %d.%d (Build %d)', [osplatform, Win32MajorVersion, Win32MinorVersion, BuildNumber])
    else Result := Format('%s %d.%d (Build %d: %s)', [osplatform, Win32MajorVersion, Win32MinorVersion, BuildNumber, Win32CSDVersion]);
  end
  else   Result := Format('%s %d.%d', [osplatform, Win32MajorVersion, Win32MinorVersion]);
end;

{ Unsupported OS detection }
function isVista78 : boolean;
var buildnumber : integer;
begin
 case Win32Platform of
  VER_PLATFORM_WIN32_WINDOWS: BuildNumber := Win32BuildNumber and $0000FFFF;
  VER_PLATFORM_WIN32_NT: BuildNumber := Win32BuildNumber;
  else BuildNumber := 0;
 end;
 case BuildNumber of
  950,6000..9999 : Result := True;
  else Result := False;
 end;
end;

procedure ListBoxToClipboard;
var Buffer: PChar;
    Ptr: PChar;
    i: Integer;
    Line: string[255];
    Count: Integer;
begin
 if not Assigned(ListBox) then Exit;

 GetMem(Buffer, BufferSize);
 Ptr   := Buffer;
 Count := 0;
 for I := 0 to ListBox.Items.Count - 1 do begin
  Line := ListBox.Items.strings[I];
  if not CopyAll and ListBox.MultiSelect and (not ListBox.Selected[I]) then Continue;
  { Check buffer overflow }
  Count := Count + Length(Line) + 3;
  if Count = BufferSize then Break;
  { Append to buffer }
  Move(Line[1], Ptr^, Length(Line));
  Ptr    := Ptr + Length(Line);
  Ptr[0] := #13;
  Ptr[1] := #10;
  Ptr    := Ptr + 2;
 end;
 Ptr[0] := #0;
 ClipBoard.SetTextBuf(Buffer);
 FreeMem(Buffer, BufferSize);
end;

procedure ClipboardToListBox;
begin
 if not Assigned(ListBox) then Exit;
 if not Clipboard.HasFormat(CF_TEXT) then Exit;
 Listbox.Items.Text := Clipboard.AsText;
end;

function WrapText;
var S : string;
    CurrWidth : integer;
begin
 SetLength(Result.Lines,0);
 Result.Height := 0;
 CurrWidth := MaxWidth;
 Text := Text+' ';
 repeat
  S := copy(Text,1,pos(' ',Text)-1);
  Delete(Text,1,pos(' ',Text));
  if (Canvas.TextWidth(S + ' ') + CurrWidth) <= MaxWidth then begin
   with Result do Lines[High(Lines)] := Lines[High(Lines)] + ' ' + S;
   Inc(CurrWidth, Canvas.TextWidth(S + ' '));
  end else with Result do begin
   if length(Lines) > 0 then Inc(Height,Canvas.TextHeight(Lines[High(Lines)]));
   SetLength(Lines,length(Lines)+1);
   Lines[High(Lines)] := S;
   CurrWidth := Canvas.TextWidth(S);
  end;
 until length(TrimRight(Text)) = 0;
 with Result do Inc(Height,Canvas.TextHeight(Lines[High(Lines)]));
end;

end.
