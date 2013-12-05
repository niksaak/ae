{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Core module
  Written by dsp2003.
}
unit AnimED_Core;

interface

uses AnimED_Console,
     AnimED_Graps,
     AnimED_Misc,
     AnimED_Translation,
     AnimED_Version,
     AA_RFA,
     Classes, SysUtils, Forms;

procedure Core_Debug_WriteSupportedArchiveFormats;

procedure Core_Command_42;
procedure Core_Command_Credits;
procedure Core_Command_Derp;
procedure Core_Command_FreeSpace;
procedure Core_Command_Help;
procedure Core_Command_Version;

implementation

procedure Core_Command_Credits;
var i : integer;
begin
 LogM('');
 LogM('This build contain the work of the following people:');
 LogM('');
 for i := 0 to Length(Contrib)-1 do LogM(Contrib[i]);
 LogM('');
end;

procedure Core_Command_42;
begin
 LogE('Wakarimasen, goshujin-sama! ^~^');
end;

procedure Core_Command_Derp;
var i : integer;
const derp = 'DERP HURR DURR';
begin
 randomize;
 for i := 0 to Random(100) do begin
  case i mod 5 of
   0 : Log(derp);
   1 : LogW(derp);
   2 : LogI(derp);
   3 : LogM(derp);
   4 : LogE(derp);
   5 : LogD(derp);
  end;
 end;
end;

procedure Core_Command_Help;
begin
 LogI('');
 LogI('Implemented commands:');
 LogI('');
 LogI('d:arc   |        -');
 LogI('clear   | cls    - clear console window');
 LogI('credits | credit - show some info about the contributors');
 LogI('freespace        - display amount of free space on every logical drive');
 LogI('exit    | quit   - terminate program');
 LogI('help    | man    - display this help screen');
 LogI('version | ver    - display version info');
 LogI('');
end;

procedure Core_Command_Version;
begin
 LogM('');
 LogM(Application.Title);
 LogM(APP_COPYRIGHT);
 LogM('');
 LogM('This build contain the following internal applications:');
 LogM('GrapS '+AEGetDate(GRAPS_VERSION,True));
 LogM('');
 LogM('You are using '+SystemInformation);
 LogM('');
end;

procedure Core_Command_FreeSpace;
var i : longword; j, k : int64;
begin
 LogS('');
 LogS('Drv: Total Mb \ Free Mb');
 for i := 1 to 26 do begin
  j := DiskFree(i);
  k := DiskSize(i);
  if ((j <> -1) and (k <> -1)) then try
   LogS(char(i+$40)+': '+Format('%10d Mb \ %10d Mb',[k div $100000,j div $100000]));
  except
  end;
 end;
end;

procedure Core_Debug_WriteSupportedArchiveFormats;
var i,j,k,l,m,n,o,p : integer; ArcState : string;

 procedure WriteArcState(Stat : byte; var Incl : integer);
 var i : integer;
 begin
  for i := 0 to Length(ArcFormats)-1 do begin
   if ArcFormats[i].Stat = Stat then begin
    ArcState := AEGetDate(ArcFormats[i].Ver)+' : '+ArcFormats[i].IDS;
    Log(ArcState);
    inc(Incl);
   end;
  end;
 end;

begin
 j := 0; k := 0; l := 0; m := 0; n := 0; o := 0; p := 0;
 Log('');
 Log('[Debug mode] Listing implemented formats:');
 Log('');
 Log('Full support:');
 Log('');
 WriteArcState($0,j);
 LogD('');
 LogD('Full support, write-only sub-formats:');
 LogD('');
 WriteArcState($5,o);
 LogM('');
 LogM('Full support, see instructions for details:');
 LogM('');
 WriteArcState($1,k);
 LogW('');
 LogW('Full support, but buggy or broken:');
 LogW('');
 WriteArcState($2,l);
 Log('');
 Log('Hacked behavior:');
 Log('');
 WriteArcState($3,p);
 LogI('');
 LogI('Dummy or work-in-progress:');
 LogI('');
 WriteArcState($9,m);
 LogE('');
 LogE('Read-only:');
 LogE('');
 WriteArcState($F,n);
 Log ('');
 Log ('Statistics:');
 Log ('');
 Log ('Full   : '+inttostr(j));
 LogD('W / O  : '+inttostr(o));
 LogM('ReadMe : '+inttostr(k));
 LogW('Buggy  : '+inttostr(l));
 LogI('Dummy  : '+inttostr(m));
 LogE('R / O  : '+inttostr(n));
 Log ('Hacked : '+inttostr(p));
 Log ('');
 Log ('Total  : '+inttostr(Length(ArcFormats)-1));
 Log ('');
 Log ('Everything together:');
 Log ('');
 for i := 0 to Length(ArcFormats)-1 do begin
  ArcState := AEGetDate(ArcFormats[i].Ver)+' : '+ArcFormats[i].IDS;

  if ArcFormats[i].Stat <> $0 then
   case ArcFormats[i].Stat of
    $1 : LogM(ArcState);
    $2 : LogW(ArcState);
    $9 : LogI(ArcState);
    $F : LogE(ArcState);
    else LogD(ArcState);
   end
  else Log(ArcState);

 end;
 Log('');
end;

end.