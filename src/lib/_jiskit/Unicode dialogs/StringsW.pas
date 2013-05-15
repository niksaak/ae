unit StringsW;

interface

uses FileStreamJ, Classes;

type
 TStringsW = class
 protected
  FEnlargeFactor: Byte;
  FMinLength: Cardinal;

  FStrings: array of WideString;
  FTags: array of Cardinal;
  Unused: Cardinal;

  procedure Enlarge;
  procedure SetCount(Count: Cardinal); virtual;

  function Get(Index: Cardinal): WideString; virtual;
  procedure Put(Index: Cardinal; const S: WideString); virtual;

  function GetTag(Index: Cardinal): Cardinal;
  procedure PutTag(Index: Cardinal; const Tag: Cardinal); virtual;

  procedure SetFromString(Str: WideString); virtual;

    procedure BeforeRemoving(Index: Cardinal); virtual;
  public
    constructor Create; virtual;

    procedure Assign(const Other: TStringsW); overload;
    procedure Assign(const Other: TStrings); overload;
    procedure CopyTo(const Other: TStrings);

    property EnlargeFactor: Byte read FEnlargeFactor write FEnlargeFactor;
    property MinLength: Cardinal read FMinLength write FMinLength;

    function Count: Cardinal;
    procedure Clear;

    procedure Add(S: WideString; Tag: Cardinal = 0);
    procedure Insert(Index: Cardinal; S: WideString; Tag: Cardinal = 0); virtual;
    procedure Delete(Index: Cardinal); virtual;

    function IndexOf(const Str: WideString): Integer;

    property Strings[Index: Cardinal]: WideString read Get write Put; default;
    property Tags[Index: Cardinal]: Cardinal read GetTag write PutTag;

    function AsString: WideString; virtual;

    { note: Tags are not saved. }
    procedure SaveToStream(Stream: TStream); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;

    procedure SaveToFile(FileName: WideString; WriteUTFSignature: boolean = False);
    procedure LoadFromFile(FileName: WideString);
  end;

implementation

uses Windows, SysUtils;

const
  UTF8Signature = #$EF#$BB#$BF;

constructor TStringsW.Create;
begin
  inherited;

  FEnlargeFactor := 3;
  FMinLength := 4;

  SetCount(0);
  Unused := 0;
  Clear
end;

procedure TStringsW.Assign(const Other: TStringsW);
var
  I: Cardinal;
begin
  SetCount(System.Length(Other.FStrings));
  Unused := Other.Unused;

  if Count <> 0 then
    for I := 0 to Count - 1 do
    begin
      FStrings[I] := Other.FStrings[I];
      FTags[I] := Other.FTags[I]
    end
end;

procedure TStringsW.Assign(const Other: TStrings);
var
  I: Cardinal;
begin
  Clear;

  with Other do
    if Count <> 0 then
      for I := 0 to Count - 1 do
        Self.Add(Strings[I], Cardinal(Objects[I]))
end;      

procedure TStringsW.CopyTo(const Other: TStrings);
var
  I: Cardinal;
begin
  if Count <> 0 then
    for I := 0 to Count - 1 do
      Other.AddObject(Strings[I], TObject(Tags[I]));
end;

function TStringsW.Count;
begin
  Result := Cardinal(Length(FStrings)) - Unused
end;

procedure TStringsW.SetCount;
begin
  SetLength(FStrings, Count);
  SetLength(FTags, Count)
end;

procedure TStringsW.Clear;
var
  I: Cardinal;
begin
  if Count <> 0 then
    for I := 0 to Count - 1 do
      BeforeRemoving(I);

  Unused := FMinLength;
  SetCount(FMinLength)
end;

procedure TStringsW.Enlarge;
begin
  if Unused = 0 then
  begin
    Unused := Length(FStrings) * (FEnlargeFactor - 1);
    SetCount(Length(FStrings) * FEnlargeFactor)
  end
end;

procedure TStringsW.Add;
begin
  Enlarge;

  FStrings[Count] := S;
  FTags[Count] := Tag;
  Dec(Unused)
end;

procedure TStringsW.Insert;
var
  I: Cardinal;
begin
  Enlarge;
  Dec(Unused);

  if Count <> 1 then
    for I := Count - 2 downto Index do
    begin
      FStrings[I + 1] := FStrings[I];
      FTags[I + 1] := FTags[I]
    end;

  FStrings[Index] := S;
  FTags[Index] := Tag
end;

procedure TStringsW.Delete;
var
  I: Cardinal;
begin
  if Index < Count then
  begin
    BeforeRemoving(Index);

    for I := Index to Count do
    begin
      FStrings[I] := FStrings[I + 1];
      FTags[I] := FTags[I + 1]
    end;
    Inc(Unused)
  end
end;

function TStringsW.Get;
begin
  if Index < Count then
    Result := FStrings[Index]
end;

procedure TStringsW.Put;
begin
  if Index < Count then
    FStrings[Index] := S
end;

function TStringsW.GetTag;
begin
  if Index < Count then
    Result := FTags[Index]
    else
      Result := 0
end;

procedure TStringsW.PutTag;
begin
  if Index < Count then
    FTags[Index] := Tag
end;

procedure TStringsW.SaveToStream;
var
  Str: UTF8String;
begin
  Str := UTF8Encode(AsString);
  Stream.Write(Str[1], Length(Str))
end;

procedure TStringsW.LoadFromStream;
var Size: Cardinal;
  Str: UTF8String;
  Sign: array[1..3] of Char;
begin
  Stream.Read(Sign, SizeOf(Sign));
  if Sign <> UTF8Signature then Stream.Seek(0,soBeginning);
  Size := Stream.Size - Stream.Position;
  SetLength(Str, Size);
  Stream.Read(Str[1], Size);
  SetFromString(UTF8Decode(Str))
end;

function TStringsW.AsString;
var
  I, LastStr: Cardinal;
begin
  Result := '';

  if Count <> 0 then
  begin
    LastStr := 0;
    for I := 0 to Count - 1 do
      Inc(LastStr, Length(FStrings[I]) + 1);

    SetLength(Result, LastStr);
    LastStr := 1;

    for I := 0 to Count - 1 do
    begin
      CopyMemory(@Result[LastStr], @FStrings[I][1], Length(FStrings[I]) * 2);
      Inc(LastStr, Length(FStrings[I]));
      Result[LastStr] := #10;
      Inc(LastStr);
    end;
  end;
end;

procedure TStringsW.SetFromString;
var
  Current, Started, StrLength : Cardinal;

  procedure Flush;
  begin
    if Current > Started then
    Add(Copy(Str, Started, Current - Started));
    Started := Current + 1;
  end;
begin
  Started := 1;

  StrLength := Length(Str);

  for Current := 1 to StrLength do begin
   if (Str[Current] = #10) or (Str[Current] = #13) then Flush;
  end;

  Current := StrLength;
  Flush;
end;

procedure TStringsW.LoadFromFile;
var Stream: TFileStreamJ;
begin
 Stream := TFileStreamJ.Create(FileName, fmOpenRead);
 try
  LoadFromStream(Stream);
 finally
  Stream.Free;
 end;
end;

procedure TStringsW.SaveToFile;
var
  S: TFileStreamJ;
begin
  S := TFileStreamJ.Create(FileName, fmCreate);
  try
   if WriteUTFSignature then S.Write(UTF8Signature, Length(UTF8Signature));
   SaveToStream(S);
  finally
   S.Free;
  end;
end;

procedure TStringsW.BeforeRemoving(Index: Cardinal);
begin
end;

function TStringsW.IndexOf(const Str: WideString): Integer;
begin
  if Count <> 0 then
    for Result := 0 to Count - 1 do
      if FStrings[Result] = Str then 
        Exit;

  Result := -1;
end;

end.
