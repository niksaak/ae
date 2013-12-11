{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  Audio data formats & functions [obsolete]
  
  Written by dsp2003 & katta aka M3956.
}

unit AnimED_Audio;

interface

uses AnimED_Console,
     AnimED_Translation,
     AnimED_Translation_Strings,
     AnimED_Directories,
     SysUtils, Classes, JUtils, FileStreamJ;

 procedure Open_AudioFile(Format:integer);
 procedure Convert_AudioFile(Format:integer; AudioFileName:widestring);
 procedure Convert_MultipleAudios;

type
{ Electronic Arts Interchange File Format }
 TRIFF = packed record
  RIFFHeader     : array[1..4] of char; // 'RIFF'
  RIFFDataLength : longword;            // Data block size
 end;

 TWaveBaseHeader = packed record
  WaveHeader     : array[1..4] of char; // 'WAVE'
  Fmt            : array[1..4] of char; // 'fmt '
  FmtDataLength  : longword;            // Format block size
 end;

 TWaveFormatHeader = packed record
  FmtFormat      : word;                // Format identifier (1 - PCM, 2 - ADPCM, 3 - MSADPCM, 26447 - Ogg)
  Channels       : word;                // Number of channels (1 - Mono, 2 - Stereo, 4 - quadro, 6 - Dolby Digital 5.1)
  Frequency      : word;                // Frequency in Hz
  AvgStreamSpeed : word;                // Channels*Frequency*(Bitdepth div 8)
  BlockAlign     : word;                // Channels*(Bitdepth div 8); bitdepth = Bits per sample * channels
  {Moved out by M3956 & dsp2003}
  {FormatSpecific : array of byte;       // Specific format data. Size varies.}
 end;

 TFactChunk = packed record
  Fact           : array[1..4] of char; // 'fact'
  Fact_Unknown   : longword;            // Usually #4
  Fact_Unknown2  : longword;            // Probably copy of filesize
 end;

 TDataChunk = packed record
  Data           : array[1..4] of char; // 'data'
  DataLength     : longword;            // Pure stream size
 end;

{ Riff Wave and WAF audio format headers -- for extraction \ conversion only }
 TSimpleWaveInfo = record
  WAVEHeader     : array[1..22] of char;
  WAFHeader      : array[1..6] of char;
  Channels       : word; // Total channels
  Frequency      : word;
 end;

 TWAFHeader = packed record {56 bytes for msadpcm total, by M3956}
  Header         : array[1..4] of char;  // 'WAF'#0
  Dummy_0        : word;                 // Commonly null
  Channels       : word;                 // Number of channels (1 - Mono, 2 - Stereo, 4 - quadro, 6 - Dolby Digital 5.1)
  Frequency      : word;                 // Frequency in Hz
  AvgStreamSpeed : word;                 // Channels*Frequency*(Bitdepth div 8)
  BlockAlign     : word;                 // Channels*(Bitdepth div 8); bitdepth = Bits per sample * channels
  FormatSpecific : array[1..38] of byte; // Specific format data. 38 for WAF MS ADPCM
  DataLength     : longword;             // Pure stream size
 end;

var
  // External
  SimpleWaveInfo        : TSimpleWaveInfo;
  // WFE
  RIFFH                 : TRIFF;
  WaveBaseH             : TWaveBaseHeader;
  WaveFormatH           : TWaveFormatHeader;
  WaveFormatSpecificH   : array of byte;
  WaveFormatSpecificL   : integer;
  WaveFormatSpecificS   : array[1..40] of byte;
  FactC                 : TFactChunk;
  DataC                 : TDataChunk;
  DataOffset            : int64;
  // WAF
  WAFH                  : TWAFHeader;

implementation

uses AnimED_Main;

procedure Open_AudioFile(Format : integer);
begin
 InputAudio.Seek(0,soBeginning);

 if Format = 0 then begin
  with InputAudio do begin
   Read(RIFFH,SizeOf(RIFFH));
   Read(WaveBaseH,SizeOf(WaveBaseH));
   Read(WaveFormatH,SizeOf(WaveFormatH));
   WaveFormatSpecificL := WaveBaseH.FmtDataLength-SizeOf(WaveFormatH);
   SetLength(WaveFormatSpecificH,WaveFormatSpecificL);
   Read(WaveFormatSpecificH[0],WaveFormatSpecificL);
   Read(FactC,SizeOf(FactC));
   if (FactC.Fact <> 'fact') then Seek(-SizeOf(FactC),soCurrent);
   Read(DataC,SizeOf(DataC));
   DataOffset := Position;
  end;
 end;

 if Format = 1 then with InputAudio do Read(WAFH,SizeOf(WAFH));

 LogM(ExtractFileName(MainForm.OpenDialog.FileName)+' '+AMS[AOpenedSuccessfully]);
end;

procedure Convert_AudioFile(Format : integer;AudioFileName : widestring);
label StopThis;
var i : integer;
begin
 FreeAndNil(OutputAudio);

// PLEASE NOTE! UNCOMMENT OR DELETE THIS AFTER YOU'LL WRITE STABLE CODE!!! 
//
 if Format = -1 then begin
  LogE(AMS[EUnsupportedFormat]);
  goto StopThis;
 end;

 InputAudio.Seek(0,soBeginning);

 OutputAudio := TFileStream.Create(AudioFileName,fmCreate);

{ Riff Wave to WAF }
 case format of
 -1,0: with WAFH, OutputAudio do begin
   {M3956: #32 is ' ' after WAVEfmt and #50 is lobyte(loword(FmtDataLength)) for msadpcm}
   if WaveFormatH.FmtFormat = 2 then {M3956: afaik, msadpcm is only uses 0x0002 tag in WFE}
    begin
     { Generating waf header }
     Header := 'WAF'#0;
     Dummy_0 := $0000;

     { Reading chunks... }
     Channels := WaveFormatH.Channels;
     Frequency := WaveFormatH.Frequency;
     AvgStreamSpeed := WaveFormatH.AvgStreamSpeed;
     BlockAlign := WaveFormatH.BlockAlign;
     if WaveFormatSpecificL = 40 then begin {M3956:there is only 40 bytes FormatSpecific in default msadpcm}
      for i := 1 to 40 do begin
       if i < 7 then FormatSpecific[i] := WaveFormatSpecificH[i-1];
       if i > 8 then FormatSpecific[i-2] := WaveFormatSpecificH[i-1];
      end;
     end;
     DataLength := DataC.DataLength;

     { Skipping header }
     InputAudio.Seek(DataOffset,soBeginning);

     { Writing stream... }
     Write(Header,4);
     Write(Dummy_0,2);
     Write(Channels,2);
     Write(Frequency,2);
     Write(AvgStreamSpeed,2);
     Write(BlockAlign,2);
     Write(FormatSpecific,38);
     Write(DataLength,4);

     { We skipped the header and do not wish to get "out of range" error }
     CopyFrom(InputAudio,DataLength);
     FreeAndNil(InputAudio);
     FreeAndNil(OutputAudio);
    end
   else
    begin
     LogE('Only MS ADPCM RIFF Waves are supported.');
     FreeAndNil(OutputAudio);
     FreeAndNil(InputAudio);
    end;
 end;

{ WAF to Riff Wave }
  1 : with OutputAudio do begin

   { Generating RIFF header... }
   RIFFH.RIFFHeader := 'RIFF';
   RIFFH.RIFFDataLength := WAFH.DataLength+70;

   { Generating WAVEfmt header... }
   WaveBaseH.WaveHeader := 'WAVE';
   WaveBaseH.Fmt := 'fmt'#32;
   WaveBaseH.FmtDataLength := 50;

   WaveFormatH.FmtFormat := 2;
   WaveFormatH.Channels := WAFH.Channels;
   WaveFormatH.Frequency := WAFH.Frequency;
   WaveFormatH.AvgStreamSpeed := WAFH.AvgStreamSpeed;
   WaveFormatH.BlockAlign := WAFH.BlockAlign;

   { Reading chunks... }
   for i := 1 to 40 do begin
    if i < 7 then WaveFormatSpecificS[i] := WAFH.FormatSpecific[i];
    if i > 6 then WaveFormatSpecificS[i+2] := WAFH.FormatSpecific[i];
   end;
   WaveFormatSpecificS[7] := 32;
   WaveFormatSpecificS[8] := 0;

   { Generating "data" header... }
   DataC.Data := 'data';
   DataC.DataLength := WAFH.DataLength;

   { Skipping header }
   InputAudio.Seek(56,soBeginning);

   { Writing stream... }

   Write(RIFFH,8);
   Write(WaveBaseH,12);
   Write(WaveFormatH,10);
   Write(WaveFormatSpecificS,40);
   Write(DataC,8);

   { We've skipped the header and do not wish to catch "out of range" error }
   CopyFrom(InputAudio,DataC.DataLength);
   FreeAndNil(InputAudio);
   FreeAndNil(OutputAudio);

  end;
 end;
StopThis:
end;

procedure Convert_MultipleAudios;
var i : integer; TemporaryName : string;
label StopThis;
begin

 PickDirContents(RootDir,'*.wa*',smFilesOnly);

 for i := 0 to AddedFilesW.Count-1 do
  begin
   InputAudio := TFileStreamJ.Create(RootDir+AddedFilesW.Strings[i],fmOpenRead);

   PickAudioInfo;

   Open_AudioFile(AudioFormat);

   if lowercase(ExtractFileExt(AddedFilesW.Strings[i])) = '.wav' then TemporaryName := ChangeFileExt(AddedFilesW.Strings[i],'.waf');
   if lowercase(ExtractFileExt(AddedFilesW.Strings[i])) = '.waf' then TemporaryName := ChangeFileExt(AddedFilesW.Strings[i],'.wav');

   LogI(AddedFilesW.Strings[i]+' -> '+TemporaryName);
   Convert_AudioFile(AudioFormat,RootDir+TemporaryName);
  end;

  LogI(AMS[IDone]);

StopThis:

end;

end.