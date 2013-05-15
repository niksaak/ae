{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Scenario data formats & functions

  Written by dsp2003.
}

unit AnimED_Script;

interface

uses AnimED_Console,
     AnimED_Translation,
     AnimED_Translation_Strings,
     SysUtils, Classes, IniFiles, Forms, Windows, Controls,
     JUtils, JReconvertor, FileStreamJ;

{ Supported scripts implementation }
procedure SC3Open(FileName : widestring);
procedure SC3Import;
procedure SC3Export;

{ end }

type
{ SCR Text records -- no system data supported yet }

{ SC3 - Ever17 Scenario files format | INCOMPLETE }
 TSC3 = record
  SC3Header          : array[1..4] of char;    // 'SC3'+#0 header
  TextTableOffset    : longword;               // Text Table Beginning offset
  GraphicsListOffset : longword;               // Where's begins graphics sublist in the text table
  HeaderSize         : longword;               // Offset or size?
 end;

 TSC3TextTable = record
  Offset             : longword;               // Offset, longword, as usual.
  Text               : array[1..8192] of char; // Used for decompilation.
 end;

var SC3 : TSC3;
    SC3TextTable : array[1..4000] of TSC3TextTable;
    SCRStream : TStream;

    TotalScriptRecords : longword;
    ScriptFileName : widestring;

implementation

uses AnimED_Main;

procedure SC3Open;
var i, j, k : integer; DecodeMethod : boolean;
    TempoString : string;
label StopError;
begin

 DecodeMethod := False;

 ScriptFileName := FileName;

 with MainForm do begin

  if RB_SC3_Strip.Checked then DecodeMethod := True;
  if RB_SC3_Keep.Checked then DecodeMethod := False;

  FreeAndNil(SCRStream);

{ Cleaning from previous data }
  for i := 1 to 4000 do begin
   SC3TextTable[i].Offset := 0;
   for j := 1 to 8096 do SC3TextTable[i].Text[j] := #0;
  end;
  LB_SCRDec.Clear;

  SCRStream := TFileStreamJ.Create(ScriptFileName,fmOpenRead);

//////// HEADER CHECK CODE ////////
  with SCRStream, SC3 do begin
   Read(SC3,SizeOf(SC3));
   if SC3Header <> 'SC3'+#0 then goto StopError;
  end;
//////// HEADER CHECK CODE ////////

  with SCRStream, SC3 do begin

   Seek(TextTableOffset,soBeginning);

   Read(TotalScriptRecords,4);

   Seek(-4,soCurrent); // Back to table start

   TotalScriptRecords := (TotalScriptRecords - TextTableOffset) div 4;

   for i := 1 to TotalScriptRecords do begin
    with SC3TextTable[i] do Read(Offset,4);
   end;

   for i := 1 to TotalScriptRecords do begin
    TempoString := '';
    TempoOffset := 0;
    TempoOffset2 := 0;
    with SC3TextTable[i] do TempoOffset := Offset;
    with SC3TextTable[i+1] do TempoOffset2 := Offset;
    if TempoOffset2 = 0 then TempoOffset2 := Size;
    if TempoOffset2 <> 0 then TempoSize := TempoOffset2 - TempoOffset;
//    Log(IScrDecompiling+' '+inttostr(TempoSize));
    Seek(TempoOffset,soBeginning);
    j := 1;

  case DecodeMethod of
   { Stripping all opcodes }
   True: with SC3TextTable[i] do begin
     while j <> TempoSize do begin
      Read(Text[j],1);
      if SCRStream.Position >= TempoOffset2+1 then break;
//    New method (compatible with Japanese and Chinese scripts)
    { If there's an printable symbol, then we'll store it as printable,
      without any curly braces. This will fix Shift-JIS and Chinese codepage
      issues :) }
      if byte(Text[j]) > 31 then TempoString := TempoString + Text[j] else begin

      case byte(Text[j]) of
    { 1 is an "Enter" byte }
    { 2 marks text string as skipable by player. Used together with 3 }
    { 3 is an "Wait for player's click" byte }
    { 12 marks text string as unskipable by player. Used together with 3 }
    { 14 displays new text window }
       0, 6..10, 12,14, 17..31 : ;// TempoString := TempoString + inttostr(byte(Text[j]));
       1, 2, 3 : TempoString := TempoString + #13#10;
    { 4 & 5 is the text color opcode, full size equals to 4 bytes (5:x:x)+#0
    (#0 is ignored during decompilation, but must be regenerated}
       4,5 : begin
              for k := 1 to 2 do begin
               inc(j); Read(Text[j],1);
              end;
              Seek(1,soCurrent); inc(j); // skipping zero byte
             end;
    { 13 is a voice file identifier }
       13 : begin
             TempoString := TempoString + #13#10;
             TempoString := TempoString + '{';
             while byte(Text[j]) <> 0 do begin
              inc(j); Read(Text[j],1);
              if byte(Text[j]) <> 0 then TempoString := TempoString + Text[j];
             end;
             TempoString := TempoString + '}';
             Tempostring := TempoString + #13#10;
            end;
    { 11 is a selector branch }
    { 16 appends new string to previous (16:x) }
       11, 16 : begin
                 TempoString := TempoString + '{'+ inttostr(byte(Text[j]));
                 TempoString := TempoString + ':';
                 inc(j); Read(Text[j],1);
                 TempoString := TempoString + inttostr(byte(Text[j]));
                 TempoString := TempoString + '}';
                 TempoString := TempoString + #13#10;
                end;
      end;
      inc(j);
     end;
    end;
    LB_SCRDec.Items.Add(inttostr(i)+' : '+#13#10+TempoString);
   end;
  { Keeping opcodes }
  False: with SC3TextTable[i] do begin
      while j <> TempoSize do begin
       Read(Text[j],1);
       if SCRStream.Position >= TempoOffset2+1 then break;
//     New method (compatible with Japanese and Chinese scripts)
       if byte(Text[j]) > 31 then TempoString := TempoString + Text[j] else begin
      { 0.6.4 - introduced opcode decompilation routine }
        TempoString := TempoString + '{'+ inttostr(byte(Text[j]));

        case byte(Text[j]) of
        { 1 is an "Enter" byte }
        { 2 marks text string as skipable by player. Used together with 3 }
        { 3 is an "Wait for player's click" byte }
        { 12 marks text string as unskipable by player. Used together with 3 }
        { 14 displays new text window }
         0..3, 6..10, 12,14, 17..31 : ;// TempoString := TempoString + inttostr(byte(Text[j]));

        { 4 & 5 is the text color opcode, full size equals to 4 bytes (5:x:x)+#0
         (#0 is ignored during decompilation, but must be regenerated}
         4,5 : begin
                TempoString := TempoString + ':';
                for k := 1 to 2 do begin
                 inc(j); Read(Text[j],1);
                 TempoString := TempoString + inttostr(byte(Text[j]));
                 if k < 2 then TempoString := TempoString + ',';
                end;
                Seek(1,soCurrent); inc(j); // skipping zero byte
               end;
        { 13 is a voice file identifier }
         13 : begin
               TempoString := TempoString + ':';
               while byte(Text[j]) <> 0 do begin
                inc(j); Read(Text[j],1);
                if byte(Text[j]) <> 0 then TempoString := TempoString + Text[j];
               end;
              end;
        { 11 is a selector branch }
        { 16 appends new string to previous (16:x) }
         11, 16 : begin
                   TempoString := TempoString + ':';
                   inc(j); Read(Text[j],1);
                   TempoString := TempoString + inttostr(byte(Text[j]));
                  end;
        end;
        TempoString := TempoString + '}';
        inc(j);
       end;
      end;
      LB_SCRDec.Items.Add(inttostr(i)+' : '+TempoString);
      LB_SCRDec.Items.Add(#160);
     end;

   end;

  end;

  L_ScenarioFileName.Caption := ExtractFileName(ScriptFileName);
  L_ScenarioOffset.Caption := inttostr(TextTableOffset);
  L_ScenarioRecords.Caption := inttostr(TotalScriptRecords);

  LogM(ScriptFileName+' '+AMS[AOpenedSuccessfully]);
  if CB_SCRAutoimport.Checked then SC3Import;
 end;
 Exit;
 end;

StopError:

LogE(AMS[EUnsupportedFormat]);
FreeAndNil(SCRStream);

end;

procedure SC3Export;
var ChunkStream : TFileStream;
    i : integer;
    TempoString : string;
label ShowError, StopThis;
begin

with MainForm do begin

if SCRStream <> nil then begin

if MessageBox(handle, pchar(AMS[AOverwriteChunks1]+#10#13+AMS[AOverwriteChunks2]),pchar(AMS[AWarning]),mb_okcancel) = MrCancel then goto ShowError;

 TempoString := '';
 TempoOffset := 0;
 TempoOffset2 := 0;

 FreeAndNil(ChunkStream);
 ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_000',fmCreate);
 SCRStream.Seek(0,soBeginning);
 ChunkStream.CopyFrom(SCRStream,SC3.TextTableOffset);
 FreeAndNil(ChunkStream);
 SCRStream.Seek(SC3.TextTableOffset+(TotalScriptRecords*4),soBeginning);
 for i := 1 to TotalScriptRecords do begin
  case i of
     0..9 : begin
             LogS(AMS[OExport]+' '+ExtractFileName(ScriptFileName)+'_chunk_00'+inttostr(i));
             ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_00'+inttostr(i),fmCreate);
            end;
   10..99 : begin
             LogS(AMS[OExport]+' '+ExtractFileName(ScriptFileName)+'_chunk_0'+inttostr(i));
             ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_0'+inttostr(i),fmCreate);
            end;
      else begin
            LogS(AMS[OExport]+' '+ExtractFileName(ScriptFileName)+'_chunk_'+inttostr(i));
            ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_'+inttostr(i),fmCreate);
           end;
  end;

  with SC3TextTable[i] do TempoOffset := Offset;
  with SC3TextTable[i+1] do TempoOffset2 := Offset;
  if TempoOffset2 = 0 then TempoOffset2 := SCRStream.Size;
  if TempoOffset2 <> 0 then TempoSize := TempoOffset2 - TempoOffset;
  ChunkStream.CopyFrom(SCRStream,TempoSize);
  FreeAndNil(ChunkStream);
 end;
 LogI(AMS[IScrExportFinished]);
end
else LogW(AMS[WScrCannotExport]);
goto StopThis;
ShowError:
LogI(AMS[ICancelledByUser]);
StopThis:

end;

end;

procedure SC3Import;
var DeChunkStream, ChunkStream : TFileStream;
    i : integer;
    OldChunkFormat : boolean;
    ChunkPrefix, TempoString : string;
label StopWithError, StopThis;
begin

OldChunkFormat := False;

with MainForm do begin

if SCRStream <> nil then begin

 TempoString := '';
 TempoOffset := 0;
 TempoOffset2 := 0;

 FreeAndNil(ChunkStream);
 FreeAndNil(DeChunkStream);

 { Checking for existance of the required chunks }
 if (not FileExists(ScriptFileName+'_chunk_000')) and FileExists(ScriptFileName+'_chunk_0') then OldChunkFormat := True;

 LogM('Old chunks format : '+booltostr(OldChunkFormat,True));

 case OldChunkFormat of
  True :  for i := 0 to TotalScriptRecords do begin
           if not FileExists(ScriptFileName+'_chunk_'+inttostr(i)) then goto StopWithError;
          end;
 False :  for i := 0 to TotalScriptRecords do begin
           case i of
              0..9 : if not FileExists(ScriptFileName+'_chunk_00'+inttostr(i)) then goto StopWithError;
            10..99 : if not FileExists(ScriptFileName+'_chunk_0'+inttostr(i)) then goto StopWithError;
                else if not FileExists(ScriptFileName+'_chunk_'+inttostr(i)) then goto StopWithError;
           end;
          end;
 end;

 DeChunkStream := TFileStream.Create(ScriptFileName+'_compiled',fmCreate);

 case OldChunkFormat of
  True : ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_0',fmOpenRead);
 False : ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_000',fmOpenRead);
 end;

 DeChunkStream.CopyFrom(ChunkStream,ChunkStream.Size);
 FreeAndNil(ChunkStream);

{ There's a *** 4 bytes *** for each table item }
 TempoOffset := DeChunkStream.Size+(TotalScriptRecords*4);

 for i := 1 to TotalScriptRecords do begin

  ChunkPrefix := '';

  case OldChunkFormat of
   True : ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_'+inttostr(i),fmOpenRead);
  False : begin
           case i of
              0..9 : ChunkPrefix := '_chunk_00';
            10..99 : ChunkPrefix := '_chunk_0';
                else ChunkPrefix := '_chunk_';
           end;
           ChunkStream := TFileStream.Create(ScriptFileName+ChunkPrefix+inttostr(i),fmOpenRead);
          end;
  end;

  SC3TextTable[i].Offset := TempoOffset;

  DeChunkStream.Write(SC3TextTable[i].Offset,4);

  TempoOffset := TempoOffset + ChunkStream.Size;

  FreeAndNil(ChunkStream);
 end;

 for i := 1 to TotalScriptRecords do begin

  case OldChunkFormat of
   True : begin
           LogS(AMS[OImport]+'('+inttostr(i)+')... '+ExtractFileName(ScriptFileName)+'_chunk_'+inttostr(i));
           ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_'+inttostr(i),fmOpenRead);
          end;
  False : begin
            case i of
             0..9 : begin
                     LogS(AMS[OImport]+'('+inttostr(i)+')... '+ExtractFileName(ScriptFileName)+'_chunk_00'+inttostr(i));
                     ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_00'+inttostr(i),fmOpenRead);
                    end;
           10..99 : begin
                     LogS(AMS[OImport]+'('+inttostr(i)+')... '+ExtractFileName(ScriptFileName)+'_chunk_0'+inttostr(i));
                     ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_0'+inttostr(i),fmOpenRead);
                    end;
               else begin
                     LogS(AMS[OImport]+'('+inttostr(i)+')... '+ExtractFileName(ScriptFileName)+'_chunk_'+inttostr(i));
                     ChunkStream := TFileStream.Create(ScriptFileName+'_chunk_'+inttostr(i),fmOpenRead);
                    end;
           end;
          end; 
  end;

  DeChunkStream.CopyFrom(ChunkStream,ChunkStream.Size);
  FreeAndNil(ChunkStream);
 end;
 LogI(AMS[IScrImportFinished]+' '+ScriptFileName+'_compiled" '+AMS[ACreatedSuccessfully]);
 if (CB_SCRSaveDir.Checked and (length(E_SCRDirectory.Text) > 0)) = True then
  begin
   try
    FreeAndNil(DeChunkStream);
    if not DirectoryExists(E_SCRDirectory.Text) then CreateDirectoryW(pwidechar(widestring(E_SCRDirectory.Text)),nil);
    if CopyFileW(pwidechar(ScriptFileName+'_compiled'),pwidechar(E_SCRDirectory.Text+'\'+ExtractFileName(ScriptFileName)),False) then LogM('...'+AMS[ACopiedTo]+' '+E_SCRDirectory.Text+'\'+ExtractFileName(ScriptFileName));
   except
    LogE(AMS[EScrCannotWriteDir]);
   end;
  end;
end
else LogW(AMS[WScrCannotImport]);
FreeAndNil(DeChunkStream);
goto StopThis;
StopWithError:
LogE(AMS[EScrCannotImport]);
StopThis:

end;

end;

//procedure TMainForm.B_TextCompilerTestClick(Sender: TObject);
//var i,skip:integer; StringOfByte : string[3];
//begin
//i := 0;
//skip := 0;
//StringOfByte := '';
//
//while i <= length(Edit1.Text) do
// begin
//  StringOfByte := '';
//
//  if skip > 0 then i := i + skip;
//  if skip = 0 then i := i + 1;
//
//  skip := 0;
//  if Edit1.Text[i] = '{' then begin
//   if Edit1.Text[i+1] <> '}' then begin
//    if Edit1.Text[i+2] <> '}' then begin
//     if Edit1.Text[i+3] <> '}' then begin
//       StringOfByte := Edit1.Text[i+1]+Edit1.Text[i+2]+Edit1.Text[i+3];
//       skip := 5;
//      end
//     else begin
//      StringOfByte := Edit1.Text[i+1]+Edit1.Text[i+2];
//      skip := 4;
//     end;
//    end
//    else begin
//     StringOfByte := Edit1.Text[i+1];
//     skip := 3;
//    end;
//   end
//  else Edit2.Text := Edit2.Text + Edit1.Text[i];
//   if StringOfByte <> '' then Edit2.Text := Edit2.Text + char(strtoint(StringOfByte));
//  end
// else Edit2.Text := Edit2.Text + Edit1.Text[i];
// end;
//end;

end.