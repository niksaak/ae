unit UnicodeDialogs;
                          
                              {
  TOpenDialog ::
              :: Unicode  mod
  TSaveDialog ::

    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          19.08.09
                               }

interface

uses                                                        
  SysUtils, Classes, Dialogs, Windows, CommDlg, Controls, StringsW;

type
  TOpenDialogW = class (TCommonDialog)
  protected
    FOptions: TOpenOptions;        
    FOptionsEx: TOpenOptionsEx;
    FFilter: WideString;
    FFilterIndex: Integer;
    FCurrentFilterIndex: Integer;
    FInitialDir: WideString;
    FTitle: WideString;
    FDefaultExt: WideString;
    FFileName: WideString;
    FFiles: TStringsW;

    function DoExecute(Func: Pointer): Boolean;
    procedure GetFileNames(const OpenFileName: TOpenFilenameW);
 public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Execute: Boolean; override;

    property Files: TStringsW read FFiles;
  published
    property DefaultExt: WideString read FDefaultExt write FDefaultExt;
    property FileName: WideString read FFileName write FFileName;
    property Filter: WideString read FFilter write FFilter;
    property FilterIndex: Integer read FFilterIndex write FFilterIndex default 1;
    property InitialDir: WideString read FInitialDir write FInitialDir;
    property Options: TOpenOptions read FOptions write FOptions default [ofHideReadOnly, ofEnableSizing];
    property OptionsEx: TOpenOptionsEx read FOptionsEx write FOptionsEx default [];
    property Title: WideString read FTitle write FTitle;
  end;

type
  TSaveDialogW = class (TOpenDialogW)
  public
    function Execute: Boolean; override;
  end;

procedure Register;

implementation

uses Messages, Forms;

var
  MAX_PATH: Word = 65000;

// Dialogs.pas: 448
procedure CenterWindow(Wnd: HWnd);
var
  Rect: TRect;
  Monitor: TMonitor;
begin
  GetWindowRect(Wnd, Rect);
  if Application.MainForm <> nil then
  begin
    if Assigned(Screen.ActiveForm) then
      Monitor := Screen.ActiveForm.Monitor
      else
        Monitor := Application.MainForm.Monitor;
  end
  else
    Monitor := Screen.Monitors[0];
  SetWindowPos(Wnd, 0,
    Monitor.Left + ((Monitor.Width - Rect.Right + Rect.Left) div 2),
    Monitor.Top + ((Monitor.Height - Rect.Bottom + Rect.Top) div 3),
    0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
end;

// Dialogs.pas: 610
function ExplorerHook(Wnd: HWnd; Msg: UINT; WParam: WPARAM; LParam: LPARAM): UINT; stdcall;
begin
  Result := 0;
  if (Msg = WM_NOTIFY) and (POFNotify(LParam)^.hdr.code = CDN_INITDONE) then
    CenterWindow(GetWindowLong(Wnd, GWL_HWNDPARENT))
end;

constructor TOpenDialogW.Create;
begin
  inherited;
  FFiles := TStringsW.Create
end;

destructor TOpenDialogW.Destroy;
begin
  FFiles.Free;
  inherited
end;

function TOpenDialogW.DoExecute;
const
  MultiSelectBufferSize = High(Word) - 16;
  OpenOptions: array [TOpenOption] of DWORD = (
    OFN_READONLY, OFN_OVERWRITEPROMPT, OFN_HIDEREADONLY,
    OFN_NOCHANGEDIR, OFN_SHOWHELP, OFN_NOVALIDATE, OFN_ALLOWMULTISELECT,
    OFN_EXTENSIONDIFFERENT, OFN_PATHMUSTEXIST, OFN_FILEMUSTEXIST,
    OFN_CREATEPROMPT, OFN_SHAREAWARE, OFN_NOREADONLYRETURN,
    OFN_NOTESTFILECREATE, OFN_NONETWORKBUTTON, OFN_NOLONGNAMES,
    OFN_EXPLORER, OFN_NODEREFERENCELINKS, OFN_ENABLEINCLUDENOTIFY,
    OFN_ENABLESIZING, OFN_DONTADDTORECENT, OFN_FORCESHOWHIDDEN);

  OpenOptionsEx: array [TOpenOptionEx] of DWORD = (OFN_EX_NOPLACESBAR);
var
  Option: TOpenOption;
  OptionEx: TOpenOptionEx;
  OpenFilename: TOpenFilenameW;

  function AllocFilterStr(const S: WideString): WideString;
  var
    I: Word;
  begin
    Result := S + #0;
    for I := 1 to Length(Result) do
      if Result[I] = '|' then
        Result[I] := #0
  end;

  function ExtractFileExt(FN: WideString): WideString;
  var
    I: Word;
  begin
    Result := '';
    for I := Length(FN) downto 1 do
      if FN[I] = '.' then
        Result := Copy(FN, I + 1, $FF)
  end;

var
  TempFilter, TempFilename, TempExt: WideString;
begin
  FFiles.Clear;
  FillChar(OpenFileName, SizeOf(OpenFileName), 0);
  with OpenFilename do
  begin
    lStructSize := SizeOf(OpenFilename);

    hInstance := SysInit.HInstance;
    TempFilter := AllocFilterStr(FFilter);
    lpstrFilter := PWideChar(TempFilter);
    nFilterIndex := FFilterIndex;
    FCurrentFilterIndex := FFilterIndex;

    nMaxFile := MAX_PATH;
    SetLength(TempFilename, nMaxFile + 2);
//    TempFilename := FFileName;
//    CopyMemory(@TempFileName[1], PWideChar(FFileName), Length(FFileName));
    lstrcpyw(PWideChar(TempFilename), PWideChar(FFileName));
    lpstrFile := PWideChar(TempFilename);
    if (FInitialDir = '') and ForceCurrentDirectory then
      lpstrInitialDir := '.'
    else
      lpstrInitialDir := PWideChar(FInitialDir);
    lpstrTitle := PWideChar(FTitle);
    Flags := OFN_ENABLEHOOK;
    FlagsEx := 0;

    for Option := Low(Option) to High(Option) do
      if Option in FOptions then
        Flags := Flags or OpenOptions[Option];
    if NewStyleControls then
    begin
      Flags := Flags xor OFN_EXPLORER;
      if (Win32MajorVersion >= 5) and (Win32Platform = VER_PLATFORM_WIN32_NT) or { Win2k }
      ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and (Win32MajorVersion >= 4) and (Win32MinorVersion >= 90)) then { WinME }
        for OptionEx := Low(OptionEx) to High(OptionEx) do
          if OptionEx in FOptionsEx then
            FlagsEx := FlagsEx or OpenOptionsEx[OptionEx]; 
    end
    else
      Flags := Flags and not OFN_EXPLORER;
    TempExt := FDefaultExt;
    if (TempExt = '') and (Flags and OFN_EXPLORER = 0) then
    begin
      TempExt := ExtractFileExt(FFilename);
      Delete(TempExt, 1, 1);
    end;
    if TempExt <> '' then lpstrDefExt := PWideChar(TempExt);
    if not (ofOldStyleDialog in FOptions) and NewStyleControls then
      lpfnHook := ExplorerHook;

    if Template <> nil then
    begin
      Flags := Flags or OFN_ENABLETEMPLATE;
      lpTemplateName := PWideChar(Template);
    end;
    hWndOwner := Application.Handle;
    Result := TaskModalDialog(Func, OpenFileName);
    if Result then
    begin
      GetFileNames(OpenFilename);
      if (Flags and OFN_EXTENSIONDIFFERENT) <> 0 then
        Include(FOptions, ofExtensionDifferent) else
        Exclude(FOptions, ofExtensionDifferent);
      if (Flags and OFN_READONLY) <> 0 then
        Include(FOptions, ofReadOnly) else
        Exclude(FOptions, ofReadOnly);
      FFilterIndex := nFilterIndex;
    end;
  end;
end;                    

procedure TOpenDialogW.GetFileNames;

  function Entrail(Path: WideString): WideString;
  begin                     
    Result := Path;
    if Result[Length(Result)] <> '\' then
      Result := Result + '\'
  end;

  procedure ExtractFileNames(Chain: PWideChar);
  var
    Dir: WideString;
  begin
    while Word(Pointer(Chain)^) <> 0 do
    begin
      if Dir = '' then
        Dir := Chain
        else
          FFiles.Add(Entrail(Dir) + Chain);
      Chain := PWideChar(DWord(Chain) + lstrlenw(Chain) * 2 + 2)
    end;

    if FFiles.Count = 0 then
      FFiles.Add(Dir) // only one file selected
  end;

begin
  if ofAllowMultiSelect in FOptions then
    ExtractFileNames(OpenFilename.lpstrFile)
    else
      FFiles.Add(OpenFilename.lpstrFile);
  FFileName := FFiles[0]
end;

function TOpenDialogW.Execute;
begin
  Result := DoExecute(@GetOpenFileNameW)
end;                                           


function TSaveDialogW.Execute;
begin
  Result := DoExecute(@GetSaveFileNameW)
end;


procedure Register;
begin
  RegisterComponents('JISKit', [TOpenDialogW, TSaveDialogW]);
end;

end.