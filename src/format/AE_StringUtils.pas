{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Helper WideString Utils
  Written by dsp2003 & w8m.
}
unit AE_StringUtils;

interface

uses SysUtils, Math, StringsW, JUtils;

// функции дл€ сортировки строк
 function AE_CompareStringsW(First,Second : widestring) : integer;
procedure AE_SortStringsW(var InSort : TStringsW);
procedure AE_UpperCaseStringsW(var Input : TStringsW);
procedure AE_LowerCaseStringsW(var Input : TStringsW);

implementation

function AE_CompareStringsW;
var i : longword;
begin
 for i := 1 to min(Length(First),Length(Second)) do begin
  if word(First[i]) <> word(Second[i]) then begin
   Result := word(First[i]) - word(Second[i]); Exit;
  end;
 end;
 Result := Length(First) - Length(Second);
end;

// внутренн€€ функци€ сортировки
procedure AE_SortStringsW;
var k,l : longword;
    Tempo : widestring;
begin
 with InSort do begin
  for k := 0 to Count-1 do for l := 0 to Count-1 do begin
   if AE_CompareStringsW(Strings[k],Strings[l]) < 0 then begin // да, именно меньше (<)! иначе будет обратна€ сортировка
    Tempo := Strings[k];
    Strings[k] := Strings[l];
    Strings[l] := Tempo;
   end;
  end;
 end;
end;

procedure AE_UpperCaseStringsW;
var i : longword;
begin
 with Input do begin
  for i := 0 to Count-1 do Strings[i] := UpperCase(Strings[i]);
 end;
end;

procedure AE_LowerCaseStringsW;
var i : longword;
begin
 with Input do begin
  for i := 0 to Count-1 do Strings[i] := LowerCase(Strings[i]);
 end;
end;

end.