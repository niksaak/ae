{
  AE - VN Tools
  (c) 2010-2013 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Delayed Memory Stream class

  Written by Nik.
}
unit DelayedMemoryStream;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
     StdCtrls;

type

     TDelayedMemoryStream = class(TStream)
       protected
         HoldedStream : TMemoryStream;
         DelayedSource : TStream;
         DelayedOffset : Int64;
         DelayedSize : Int64;
       private
         procedure DelayEnd();
 //        procedure SetPos();
       protected
         procedure SetSize(const NewSize: Int64); override;
//         function GetSize: Int64; override;
       public
         constructor Create(inStream : TStream; Offset, Size : Int64);
         destructor Destroy; override;
         function Read(var Buffer; Count: Longint): Longint; override;
         function Write(const Buffer; Count: Longint): Longint; override;
         function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
     end;

implementation

constructor TDelayedMemoryStream.Create;
begin
  HoldedStream := nil;
  DelayedSource := inStream;
  DelayedOffset := Offset;
  DelayedSize := Size;
  self.Size := DelayedSize;
end;

destructor TDelayedMemoryStream.Destroy;
begin
  if HoldedStream <> nil then
  begin
    FreeAndNil(HoldedStream);
  end;
end;

function TDelayedMemoryStream.Read(var Buffer; Count: Longint): Longint;
begin
  DelayEnd();
  if HoldedStream = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := HoldedStream.Read(Buffer, Count);
end;

function TDelayedMemoryStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  DelayEnd();
  if HoldedStream = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := HoldedStream.Seek(Offset,Origin);
end;

procedure TDelayedMemoryStream.SetSize(const NewSize: Int64);
begin
//  DelayEnd();
  if HoldedStream = nil then
  begin
    Exit;
  end;
  HoldedStream.SetSize(NewSize);
end;

function TDelayedMemoryStream.Write(const Buffer; Count: Longint): Longint;
begin
  DelayEnd();
  if HoldedStream = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := HoldedStream.Write(Buffer, Count);
end;

procedure TDelayedMemoryStream.DelayEnd;
begin
  if HoldedStream <> nil then Exit;
  if (DelayedSource = nil) or ((DelayedOffset + DelayedSize) > DelayedSource.Size) then Exit;
  HoldedStream := TMemoryStream.Create;
  DelayedSource.Position := DelayedOffset;
  try
    HoldedStream.CopyFrom(DelayedSource,DelayedSize);
  except
    FreeAndNil(HoldedStream);
    HoldedStream := nil;
  end;
  HoldedStream.Position := 0;
end;

end.
 