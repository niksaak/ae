{
  AE - VN Tools
  © 2007-2014 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Version info
  
  Written by dsp2003. Parts by Vendor.
}
unit AnimED_Version;

interface

uses Windows, SysUtils, Classes;

type
  TVersionInfo = object
  private
    FVersionInfo : Pointer;
    FFileName : String;
    FLangCharSet : String;
    function GetCompanyName : String;
    function GetFileDescription : String;
    function GetFileVersion : String;
    function GetInternalName : String;
    function GetLegalCopyright : String;
    function GetOriginalFilename : String;
    function GetProductName : String;
    function GetProductVersion : String;
    procedure Init;
    procedure SetFileName(const Value : String);
    procedure Clear;
  public
    constructor Create;
    destructor Destroy;
    function GetValue(const ValueName : String; var Buffer : Pointer) : Boolean;
    function GetLocalValue(const ValueName : String) : String;
    property CompanyName : String read GetCompanyName;
    property FileDescription : String read GetFileDescription;
    property FileVersion : String read GetFileVersion;
    property InternalName : String read GetInternalName;
    property LegalCopyright : String read GetLegalCopyright;
    property OriginalFilename : String read GetOriginalFilename;
    property ProductName : String read GetProductName;
    property ProductVersion : String read GetProductVersion;
    property LangCharSet : String read FLangCharSet;
    property FileName : String read FFileName write SetFileName;
  end;

function DotReplace(Input : string) : string;

function APP_VERSION : string;

function AEGetVersion : string;

function AEGetDate(Num : integer; NoB : boolean = False) : string;

const APP_NAME = 'AE';
      APP_SUBNAME = 'VN Tools';
      APP_CODENAME = 'Nepeta';
//    APP_EDITION = 'Green Sun';
      APP_COPYRIGHT = '© 2007-2013 WinKiller Studio and The Contributors.';

implementation

function AEGetDate;
var MyY, MyM, MyD, Del : string;
begin
 Del := '/';
 MyY := inttohex(Num shr 16,4);
 MyM := inttohex((Num shr 8) and $FF,2);
 MyD := inttohex(Num and $FF,2);

 Result := MyY+Del+MyM+Del+MyD;
 if not NoB then Result := '['+Result+']';
end;

{ A little hack to replace '.' with '/' as was in the original }
function DotReplace;
var i : integer;
begin
 Result := '';
 for i := 1 to Length(Input) do begin
  case Input[i] of
   '.': Result := Result + '/';
  else Result := Result + Input[i];
  end;
 end;
end;

function APP_VERSION;
var AEVerData:TVersionInfo;
begin
 AEVerData.Create;
 Result := AEVerData.FileVersion+' '+APP_CODENAME+' ['+DotReplace(AEVerData.ProductVersion)+']';//+APP_EDITION;
 AEVerData.Destroy;
end;

function AEGetVersion;
var AEVerData:TVersionInfo;
begin
 AEVerData.Create;
 Result := AEVerData.FileVersion;
 AEVerData.Destroy;
end; 

constructor TVersionInfo.Create;
begin
 FVersionInfo := nil;
 FFileName := paramstr(0);
end;

destructor TVersionInfo.Destroy;
begin
 Clear;
end;

procedure TVersionInfo.Clear;
begin
 if FVersionInfo <> nil then FreeMem(FVersionInfo);
 FVersionInfo := nil;
end;

procedure TVersionInfo.SetFileName(const Value : String);
begin
 Clear;
 FFileName := Value;
end;

procedure TVersionInfo.Init;
type T = array [0..1] of WORD;
var Size, Fake : DWORD;
    P : ^T;
begin
 if FVersionInfo <> nil then exit;
 Size := GetFileVersionInfoSize(PChar(FFileName), Fake);
 GetMem(FVersionInfo, Size);
 try
  GetFileVersionInfo(PChar(FFileName), 0, Size, FVersionInfo);
 except
  FreeMem(FVersionInfo);
  FVersionInfo := nil;
  raise;
 end;
 GetValue('\VarFileInfo\Translation', Pointer(P));
 FLangCharSet := Format('%.4x%.4x', [P^[0], P^[1]]);
end;

function TVersionInfo.GetValue(const ValueName : String; var Buffer : Pointer) : Boolean;
var Size : UINT;
begin
 Init;
 Result := VerQueryValue(FVersionInfo, PChar(ValueName), Buffer, Size);
end;

function TVersionInfo.GetLocalValue(const ValueName : String) : String;
var P : Pointer;
begin
 Init;
 if GetValue('\StringFileInfo\' + FLangCharSet + '\' + ValueName, P) then Result := StrPas(P)
 else Result := '';
end;

function TVersionInfo.GetCompanyName : String;
begin
 Result := GetLocalValue('CompanyName');
end;

function TVersionInfo.GetFileDescription : String;
begin
 Result := GetLocalValue('FileDescription');
end;

function TVersionInfo.GetFileVersion : String;
begin
 Result := GetLocalValue('FileVersion');
end;

function TVersionInfo.GetInternalName : String;
begin
 Result := GetLocalValue('InternalName');
end;

function TVersionInfo.GetLegalCopyright : String;
begin
 Result := GetLocalValue('LegalCopyright');
end;

function TVersionInfo.GetOriginalFilename : String;
begin
 Result := GetLocalValue('OriginalFilename');
end;

function TVersionInfo.GetProductName : String;
begin
 Result := GetLocalValue('ProductName');
end;

function TVersionInfo.GetProductVersion : String;
begin
 Result := GetLocalValue('ProductVersion');
end;

end.