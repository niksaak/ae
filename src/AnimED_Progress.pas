{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Progressbar handlers
  Written by dsp2003.
}

unit AnimED_Progress;

interface

uses Graphics, Windows, SysUtils, Classes, Forms;

const pcolDefault = $00D08410;
      pcolConvert = $00008BE8;
      pcolWrite   = $00C080FF; //to-do: find it =_=
                               //update: FOUND ! ^__^

procedure Progress_Max(i : integer; ColorMode : TColor = pcolDefault);
procedure Progress_Pos(i : integer);
//procedure Progress_Col(ColorMode : TColor);

implementation

uses AnimED_Main;

var ProgressMod : integer;

procedure Progress_Max;
begin
 with MainForm do begin
  G_Progress.MaxValue := i;
  G_Progress.ForeColor := ColorMode;
 end;
 ProgressMod := i div 128;
 if ProgressMod = 0 then ProgressMod := 1;
end;

procedure Progress_Pos;
begin

 with MainForm do begin
  G_Progress.Progress := i;

  if ProgressMod = 0 then ProgressMod := 1; // divide by zero fix

  if i mod ProgressMod = 0 then begin
   L_Arc_Status.Caption := Format('%d / %d',[i,G_Progress.MaxValue]);
   L_Arc_Status.Repaint;
   L_Arc_StatusProcessing.Repaint;
   Application.ProcessMessages;
  end;

  with G_Progress do begin
   case Visible of
   False : if ((Progress <> MinValue) and (Progress <> MaxValue)) and (Progress <> 0) then
            begin
             Visible := True;
             L_Arc_StatusProcessing.Visible := True;
             L_Arc_Status.Visible := True;
            end;
   True  : if ((Progress = MinValue) or (Progress = MaxValue)) or (Progress = 0) then
            begin
             Visible := False;
             L_Arc_StatusProcessing.Visible := False;
             L_Arc_Status.Visible := False;
            end;
   end;
  end; // with G_Progress

 end; // with MainForm

end;

end.