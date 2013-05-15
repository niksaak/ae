{
  AE - VN Tools
  © 2007-2013 WinKiller Studio & The Contributors.
  This software is free. Please see license for details.

  Process Memory Reader test application
  Written by Nik.
}
program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Process_Control in 'Process_Control.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
