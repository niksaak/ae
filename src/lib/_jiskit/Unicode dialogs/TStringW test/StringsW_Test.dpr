program StringsW_Test;

{$APPTYPE CONSOLE}

uses
  SysUtils, StringsW;

const
  WIDE: WideString = #$3041#$707D#$2000#$0441;
  CYCLES = 100;
  TAG_MARGIN = 150; // a random value to check TStringsW tag value correctness

var
  S: TStringsW;
  I, J: Byte;
  Str: WideString;
  Error: Boolean = False;

function Assert(Success: Boolean; Msg: String): Boolean;
begin
  Error := not Success;
  Result := Success;
  if not Result then
  begin
    WriteLn('Assertion error:');
    WriteLn(#9 + Msg);
    ReadLn
  end
end;

begin
  S := TStringsW.Create;
  try
    { First test case }
    if Assert(S.Count = 0, 'Create: Count <> 0') then
    begin
      S.Add(WIDE);
      if Assert(S.Count = 1, 'Add: Count <> 1') and Assert(S[0] = WIDE, 'Add: Added <> WIDE') then
      begin
        S.Clear;
        if Assert(S.Count = 0, 'Clear: Count <> 0') and Assert(S.Strings[0] = '', 'Clear: Strings[0] <> ''''') then
          WriteLn('First OK')
      end
    end;

    { Second test case }
    if not Error then
    begin
      S.Add(WIDE);
      S.Delete(0);
      if Assert(S.Count = 0, 'Delete: Count <> 0') and Assert(S.Strings[0] = '', 'Delete: Strings[0] <> ''''') then
        WriteLn('Second OK')
    end;

    { Third test case }
    if not Error then
    begin
      for I := 0 to CYCLES - 1 do
      begin
        Str := WIDE + IntToStr(I);
        S.Add(Str, I + TAG_MARGIN);
        if not Assert(S.Count = I + 1, Format('Add: Count <> %d', [I + 1])) or
           not Assert(S[I] = Str, Format('Add: Strings[%d] <> expected', [I])) then
          Break
      end;

      if not Error then
        for I := 1 to 5 do
        begin
          S.Delete(CYCLES div 2);
          if Assert(S.Count = CYCLES - I, Format('Delete: Count <> %d', [CYCLES - I])) then
          begin
            for J := 0 to CYCLES div 2 - 1 do
              if not Assert(S.Strings[J] = WIDE + IntToStr(J), Format('Delete: Strings[%d] <> expected', [J])) or
                 not Assert(S.Tags[J] = J + TAG_MARGIN, Format('Delete: Tags[%d] <> %d', [J, J + TAG_MARGIN])) then
                Break;
            for J := CYCLES div 2 to S.Count - 1 do
              if not Assert(S.Strings[J] = WIDE + IntToStr(J + I), Format('Delete: Strings[%d] <> expected', [J])) or
                 not Assert(S.Tags[J] = J + I + TAG_MARGIN, Format('Delete: Tags[%d] <> %d', [J, J + I + TAG_MARGIN])) then
                Break
          end;

          if Error then
            Break
        end;

      if not Error then
        S.Clear
    end;
                          
    { Fourth test case }
    if not Error then
    begin
      S.Add(WIDE);
      S.Delete(1000);
      if Assert(S.Count = 1, 'Delete(1000): Count <> 1') and Assert(S[0] = WIDE, 'delete(1000): Strings[0] <> WIDE') then
      begin
        S.Delete(0);
        if Assert(S.Count = 0, 'Delete(0): Count <> 0') and Assert(S[0] = '', 'delete(0): Strings[0] <> ''''') then
        begin
          S.Delete(0);
          if Assert(S.Count = 0, 'Delete(0): Count <> 0') and Assert(S[0] = '', 'delete(0): Strings[0] <> ''''') then
            WriteLn('Fourth OK')
        end
      end
    end
  finally
    S.Free
  end
end.
