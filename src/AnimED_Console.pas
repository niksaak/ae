{
  AE - VN Tools
  © 2007-2013 WinKiller Studio. Open Source.
  This software is free. Please see License for details.

  Console unit
  
  Written by dsp2003.
}
unit AnimED_Console;

interface

uses Graphics, SysUtils, Forms, Classes, Dialogs;

var DoErrorBeep, DoWarnBeep : boolean; MessageNumberInc, MaxMessageCount: int64;

procedure Log(Text : string; LogType : char = #$0);
procedure LogS(Text : string);
procedure LogW(Text : string);
procedure LogI(Text : string);
procedure LogM(Text : string);
procedure LogE(Text : string);
procedure LogD(Text : string);

procedure DummyProcedure;

procedure ParseCommand(command : string);

type
 TConsoleCommand = packed record
  CommandName   : string;
  ShortName     : string;
  Description   : string;
  CallProcedure : procedure;
 end;

implementation

uses AnimED_Core,
     AnimED_Main,
     AnimED_Translation,
     AnimED_Translation_Strings,
     AnimED_Skin,
     AnimED_Misc,
     AnimED_Version,
     AnimED_GrapS;

{ dummy procedure }
procedure DummyProcedure; begin LogI(AMS[IUnderConstruction]); end;

{ wrappers }
procedure LogS; begin if MainForm.CB_LogS.Checked then Log(Text,'S'); end;
procedure LogW; begin if MainForm.CB_LogW.Checked then Log(Text,'W'); end;
procedure LogI; begin if MainForm.CB_LogI.Checked then Log(Text,'I'); end;
procedure LogM; begin if MainForm.CB_LogM.Checked then Log(Text,'M'); end;
procedure LogE; begin if MainForm.CB_LogE.Checked then Log(Text,'E'); end;
procedure LogD; begin if MainForm.CB_LogD.Checked then Log(Text,'D'); end;

{ Debugging log procedure - begin
  Please note: Label_Mini_Log is also connected to this procedure }
procedure Log;
var ColorW : TColor;
begin
 if LogType = #0 then LogType := 'S';
 with MainForm do begin
  if not CB_NoLog.Checked then begin
   with Skin.Console do try
    case LogType of
     'D': begin ColorW := D; end;
     'E': begin ColorW := E; if DoErrorBeep then Beep; end; //Error
     'W': begin ColorW := W; if DoWarnBeep then Beep; end; //Warning
     'I': begin ColorW := I; end; //Info
     'M': begin ColorW := M; end; //Message
     else begin ColorW := S; end; //Normal text
    end;
   except
    ColorW := clWindowText;
   { Do nothing, since the logging is got broken }
   end;
   with L_Mini_Log do try
    Caption := '{'+TimeToStr(Time)+'}'+' : '+Text;
    Font.Color := ColorW;
//    RE_Log.Items.Add(Caption);
    RE_Log.Items.AddObject(Caption, Pointer(ColorW));
   except
    RE_Log.Clear;
   { Do nothing, since the logging is got broken }
   end;
  end;
  Repaint;
//  Application.ProcessMessages;
 end;

end;

{ Debugging log procedure - end }

procedure ParseCommand;
//var {ComParts : TStringList;}
//    i : integer;
begin
// ComParts := TStringList.Create;

{var str1, str2 : string;
      beginoffset, length : longword
...
SetLength(str2,length);
CopyMemory(@str2[1],@str1[beginoffset],length); }

// i := 0;
// while i < Length(command) do begin
//  inc(i);
//  if command[i] = #$20 then begin
//   SetLength(ComParts.Items[i],

// end;
 command := lowercase(command);

 if command <> '' then LogS('> '+command);

 if (command = 'what is the answer to life, the universe, and everything?') or (command = '42') then Core_Command_42;

 if (command = 'derp')                             then Core_Command_Derp;
 if (command = 'clear')   or (command = 'cls')     then MainForm.RE_Log.Clear;
 if (command = 'credit')  or (command = 'credits') then Core_Command_Credits;
 if (command = 'version') or (command = 'ver')     then Core_Command_Version;
 if (command = 'exit')    or (command = 'quit')    then Application.Terminate;
 if (command = 'help')    or (command = 'man')     then Core_Command_Help;
 if (command = 'freespace')                        then Core_Command_FreeSpace;

 if (command = 'd:arc')                            then Core_Debug_WriteSupportedArchiveFormats;

end;

end.