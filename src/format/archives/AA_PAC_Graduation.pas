{
  AE - VN Tools
© 2007-2013 WinKiller Studio and The Contributors
  This software is free. Please see License for details.

  Graduation PAC game archive format & functions

  Written by dsp2003.
}

unit AA_PAC_Graduation;

interface

uses AA_RFA,
     AnimED_Console,
     AnimED_Math,
     AnimED_Misc,
     AnimED_Directories,
     AnimED_Progress,
     AnimED_Translation,
     Classes, Windows, Forms, Sysutils;

 { Supported archives implementation }
 procedure IA_PAC_Graduation(var ArcFormat : TArcFormats; index : integer);

  function OA_PAC_Graduation : boolean;
//function SA_PAC_Graduation(Mode : integer) : boolean;

type
 TGradPAC = packed record
  Offset : longword;
 end;

implementation

uses AnimED_Archives;

procedure IA_PAC_Graduation;
begin
 with ArcFormat do begin
  ID   := index;
  IDS  := 'Graduation';
  Ext  := '.pac';
  Stat := $F;
  Open := OA_PAC_Graduation;
//  Save :=
  Extr := EA_RAW;
  FLen := 0;
  SArg := 0;
  Ver  := $20090918;
 end;
end;

function OA_PAC_Graduation;
var i : integer;
    MiniBuf : array[1..2] of char;
    GradPAC : TGradPAC;
begin
 Result := False;

 with ArchiveStream do begin

  Seek(0,soBeginning);

  Read(GradPAC,SizeOf(GradPAC));

  if GradPAC.Offset <> $800 then Exit;

  i := 0;

  while GradPAC.Offset <> ArchiveStream.Size do begin

   inc(i);

   RFA[i].RFA_1 := GradPAC.Offset;

   Read(GradPAC,SizeOf(GradPAC));

   RFA[i].RFA_2 := GradPAC.Offset - RFA[i].RFA_1;

   RFA[i].RFA_C := RFA[i].RFA_2;

  end;

  RecordsCount := i;

  for i := 1 to RecordsCount do begin

   Position := RFA[i].RFA_1;

   Read(MiniBuf,2);

   case MiniBuf[1] of
    'B': RFA[i].RFA_3 := ChangeFileExt(ExtractFileName(ArchiveFileName),'')+'_'+inttohex(i,4)+'.bmp';
    else RFA[i].RFA_3 := ChangeFileExt(ExtractFileName(ArchiveFileName),'')+'_'+inttohex(i,4)+'.bin';
   end;

  end;

  Result := True;
 end;

end;

end.