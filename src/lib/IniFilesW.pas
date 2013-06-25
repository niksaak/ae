unit IniFilesW;

interface      

// todo: add TIniFileW

uses
  Classes, Windows, SysUtils, IniFiles;

type
  TMemIniFileW = class (TMemIniFile)
  protected                           
    FFileName: WideString;

    procedure LoadValues;
  public                       
    constructor Create(const FileName: WideString);

    procedure UpdateFile; override;
    procedure Rename(const FileName: WideString; Reload: Boolean);

    property FileName: WideString read FFileName;
  end;

implementation

uses FileStreamW, JUtils;

constructor TMemIniFileW.Create;
begin
  inherited Create('');

  FFileName := FileName;
  LoadValues;
end;                

procedure TMemIniFileW.LoadValues;
var
  List: TStringList;
  F: TFileStreamW;
begin
  if (FileName <> '') and FileExists(FileName) then
  begin
    List := TStringList.Create;
    F := TFileStreamW.Create(FIleName, fmOpenRead);

    try
      List.LoadFromStream(F);
      SetStrings(List);
    finally
      F.Free;
      List.Free
    end
  end
    else
      Clear
end;

procedure TMemIniFileW.Rename;
begin
  FFileName := FileName;
  if Reload then
    LoadValues
end;

procedure TMemIniFileW.UpdateFile;
var
  List: TStringList;
  F: TFileStreamW;
begin
  List := TStringList.Create;
  F := TFileStreamW.Create(FIleName, fmCreate);

  try
    GetStrings(List);
    List.SaveToStream(F);
  finally
    F.Free;
    List.Free
  end;
end;

end.
