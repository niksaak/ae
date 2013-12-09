{
  AE - VN Tools
  © 2007-2014 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Process Memory Reader

  Written by Nik.
}
unit Process_control;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
     StdCtrls, Tlhelp32;

type
     TProcDataElement = ^TProcData;

     TProcData = record
       Data : PROCESSENTRY32;
       Next : TProcDataElement;
     end;

     TProcessControl = class
       private
         ProcData : TProcDataElement;

         LastError : string;
         LastErrorCode : integer;

         procedure SetError(code : integer);
       public
         constructor Create(); {Создание объекта}
         destructor Destroy();override; {Полное удаление}

         procedure Clear();

         function Refresh() : boolean; {Обновляет список процессов}
         function GetLastError() : string; {Получить последнюю ошибку}
         function ReadMemory(id, beginOffset, Length : longword; var OutStream : TStream) : boolean;
         {пытается прочесть память}
         function GetProcessList(var list : TStringList) : boolean;
     end;

implementation

constructor TProcessControl.Create;
begin
  ProcData := nil;
  SetError(0);
end;

destructor TProcessControl.Destroy;
begin
  Clear();
end;

procedure TProcessControl.Clear;
var NextProcData : TProcDataElement;
begin
  while ProcData <> nil do
  begin
    NextProcData := ProcData;
    ProcData := ProcData.Next;
    Dispose(NextProcData);
  end;
  SetError(0);
end;

procedure TProcessControl.SetError;
begin
  LastErrorCode := code;
  case code of
     0 : LastError := '';
{    -1 : LastError := 'Ошибка создания списка процессов.';
    -2 : LastError := 'Ошибка чтения памяти процесса.';
    -3 : LastError := 'Нужно создать список процессов.';
    -4 : LastError := 'Неверные входные данные.';
    -5 : LastError := 'Невозможно получить доступ к процессу.';}
    
    -1 : LastError := 'Error creating process list.';
    -2 : LastError := 'Error reading memory of process.';
    -3 : LastError := 'Requires process list creation.';
    -4 : LastError := 'Wrong input data.';
    -5 : LastError := 'Unable to gain access to the process.';
    
  end;
end;

function TProcessControl.GetLastError;
begin
  Result := LastError;
end;

function TProcessControl.Refresh;
var shandle : longword;
    ReProcData : PROCESSENTRY32;
    NextProcData, LastProcData : TProcDataElement;
begin
  shandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
  Result := false;
  if shandle = INVALID_HANDLE_VALUE then
  begin
    SetError(-1);
    Exit;
  end;
  Clear();
  FillChar(ReProcData,sizeof(ReProcData),0);
  ReProcData.dwSize := sizeof(ReProcData);
  if not Process32First(shandle,ReProcData) then
  begin
    SetError(-1);
    Exit;
  end;
  New(ProcData);
  LastProcData := ProcData;
  ProcData.Data := ReProcData;
  ProcData.Next := nil;
  FillChar(ReProcData,sizeof(ReProcData),0);
  ReProcData.dwSize := sizeof(ReProcData);
  while Process32Next(shandle,ReProcData) do
  begin
    New(NextProcData);
    LastProcData.Next := NextProcData;
    LastProcData := NextProcData;
    LastProcData.Data := ReProcData;
    LastProcData.Next := nil;
    FillChar(ReProcData,sizeof(ReProcData),0);
    ReProcData.dwSize := sizeof(ReProcData);
  end;
  CloseHandle(shandle);
  SetError(0);
  Result := true;
end;

function TProcessControl.GetProcessList;
var NextProcData : TProcDataElement;
begin
  Result := false;
  if list = nil then begin SetError(-4); Exit; end;
  if ProcData = nil then begin SetError(-3); Exit; end;

  NextProcData := ProcData;
  list.Clear;
  while NextProcData <> nil do
  begin
    list.Add(String(PChar(@NextProcData.Data.szExeFile[0])));
    NextProcData := NextProcData.Next;
  end;
  SetError(0);
  Result := true;
end;

function TProcessControl.ReadMemory;
var NextProcData : TProcDataElement;
    i, ActualLen : longword;
    mem : array of byte;
//    err : string;
    handle : longword;
begin
  NextProcData := ProcData;
  i := 0;
  Result := false;
  while (NextProcData <> nil) and (i < id) do
  begin
    NextProcData := NextProcData.Next;
    Inc(i);
  end;
  if NextProcData = nil then begin SetError(-4); Exit; end;
  handle := OpenProcess(PROCESS_VM_READ,false,NextProcData.Data.th32ProcessID);
  if handle = INVALID_HANDLE_VALUE then
  begin
    SetError(-5);
    Exit;
  end;
  SetLength(mem,Length);
//  if not Toolhelp32ReadProcessMemory(NextProcData.Data.th32ProcessID, @BeginOffset, mem[0], Length, ActualLen) then
//  if not ReadProcessMemory(handle, @BeginOffset, @mem[0], Length, ActualLen) then
  if not ReadProcessMemory(handle, Pointer(BeginOffset), @mem[0], Length, ActualLen) then
  begin
    SetError(-2);
    SetLength(mem,0);
    CloseHandle(handle);
    Exit;
  end;

  OutStream := TMemoryStream.Create;
  OutStream.Write(mem[0], ActualLen);
//  if OutStream <> nil then FreeAndNil(OutStream);
  SetLength(mem,0);
  CloseHandle(handle);
  SetError(0);
  Result := true;
end;

end.
 