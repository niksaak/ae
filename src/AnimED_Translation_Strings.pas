{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Translation library strings module

  Written by dsp2003.
}

unit AnimED_Translation_Strings;

interface

procedure InitBuiltInMessages;

const current_version        = $069417; // current localisation version

      AInformation           = $00;
      AArchive               = $01;
      AAddFields             = $02;
      AFile                  = $03;

      AEngineVersion         = $04;
      AFormatStatus          = $05;

      ARecordsInArchive      = $06;
      AFragCheckResults      = $07;
      APhysicalArcSize       = $08;
      ACalculatedSize        = $09;
      AUncompressedSize      = $0a;
      AWasted                = $0b;
      ASaved                 = $0c;
      AFragRatio             = $0d;
      ACompRatio             = $0e;
      AMissing               = $0f;
      ADamageRatio           = $10;

      aBytes                 = $11;
      aBits                  = $12;
      aKilobytes             = $13;
      aMegabytes             = $14;
      aGigabytes             = $15;
      aUnknownFormat         = $16;
      aAllFiles              = $17;
      aReserved              = $18;
      aVersion               = $19;
      aNewDirectory          = $1a;
      aCannotCreateDir       = $1b;

      AStatusReadme          = $1c;
      AStatusBuggy           = $1d;
      AStatusUnpack          = $1e;
      AStatusUntested        = $1f;
      AStatusDummy           = $20;

      AWarning               = $21;
      AUnsupportedFormat     = $22;
      AOverwriteChunks1      = $23;
      AOverwriteChunks2      = $24;
      AByteConvOverwrite     = $25;

      ALeft                  = $26;
      ARight                 = $27;
      ATop                   = $28;
      ABottom                = $29;

      ANotAFile              = $2a;

      ATruncatedFilename     = $2b;

      AStartedAt             = $2c;
      ACopiedTo              = $2d;
      AOpenedSuccessfully    = $2e;
      ACreatedSuccessfully   = $2f;
      AExtractedSuccessfully = $30;
      AAddedSuccessfully     = $31;
      ADecodedSuccessfully   = $32;

      AImportedAsAlpha       = $33;

      OInitializing          = $34;
      OExtracting            = $35;
      OConverting            = $36;
      OSaving                = $37;
      OOpening               = $38;
      OAdding                = $39;
      OExport                = $3a;
      OImport                = $3b;

      MTRawReader            = $3c;

      ICalculatingCRC32      = $3d;

      WArchiveExtract        = $3e;
      EArchiveExtract        = $3f;
      EArchiveIsBroken       = $40;
      WArchiveInvalidEntry   = $41;
      EUnableToUnpack        = $42;
      IArchiveStreamClosed   = $43;
      WArchiveStreamClosed   = $44;
      EArchiveExists         = $45;

      EInvalidDirectory      = $46;

      ICreatingOutDir        = $47;
      ECreatingOutDir        = $48;
      
      AStatusHack            = $49; // 2010.07.31

      ECannotOpenFile        = $4a; // 2010.02.02

      IReadingAudioFile      = $4b;
      WAudioConversion       = $4c;

      IImageConversionDone   = $4d;
      EImageConversion       = $4e;
      WImageConversion       = $4f;

      EImageNoAlpha          = $50;
      EImagePowerOf2         = $51;
      EImageDiffers          = $52;
      EImageDiffers2         = $53;

      IDone                  = $54;
      ICancelledByUser       = $55;
      EUnexpectedError       = $56;
      EResourceReadingError  = $57;

      EUnsupportedFormat     = $58;
      EUnsupportedOutFormat  = $59;

      EKeyFileToSelf         = $5a; // 2009.12.02

      AFormatTaggedAs        = $5b; // 2009.12.02
      AFormatTaggedAs2       = $5c; // 2009.12.02

      ENoValidKeyFile        = $5d; // 2009.12.02

      AStatusWriteOnly       = $5e; // 2010.08.01

      ECannotFindFile        = $5f; // 2010.08.21

      ESavingFile            = $60;

      WArchiveOverwriteMode  = $61;
      MArchiveOverwriteMode  = $62;

      IConvertingBytes       = $63;
      IConvertingBytesDone   = $64;
      EConvertingBytes       = $65;

      WLoggingDisabled       = $66;
      MLoggingEnabled        = $67;
      MLogCleared            = $68;

      IUnderConstruction     = $69;

      IScrDecompiling        = $6a;
      IScrExportFinished     = $6b;
      IScrImportFinished     = $6c;

      WScrCannotExport       = $6d;
      WScrCannotImport       = $6e;
      EScrCannotImport       = $6f;
      EScrCannotWriteDir     = $70;

      IReinitialization      = $71;

      AHiddenDataCheck1      = $72; // 2010.11.26
      AHiddenDataCheck2      = $73; // 2010.11.26
      AHiddenDataCheck3      = $74; // 2010.11.26

      AHiddenData404         = $75; // 2010.11.26
      AHiddenData302         = $76; // 2010.11.26

      AEndOfReport           = $77; // 2010.11.26

      AFileNoData            = $78; // 2013.03.09
      AFileIsDamaged         = $79; // 2013.03.09
      AFileIsDead            = $7a; // 2013.03.09
      AFileIsOK              = $7b; // 2013.03.09

      ICalculatingMD5        = $7c; // 2013.03.09

      AHashCRC32Confirm      = $7d; // 2013.03.09
      AHashMD5Confirm        = $7e; // 2013.03.09

      AHashHugeFileWarn      = $7f; // 2013.03.09 

      ABrowseForDirTitle     = $80; // 2010.11.26

      AFieldGroup            = $81; // 2013.03.09

      ACompTypeRAW           = $82; // 2013.03.09
      ACompTypeNone          = $83; // 2013.03.09
      ACompTypeUnknown       = $84; // 2013.03.09
      ACompTypeGenericLZSS   = $85; // 2013.03.09

      AUnknownFileType       = $86; // 2013.03.09

      CCredits               = $F0; // 2010.08.01
      CIdea                  = $F1; // 2010.08.01
      CCore                  = $F2; // 2010.08.01
      CContrib               = $F3; // 2010.08.01
      CLocalise              = $F4; // 2010.08.01
      CIncludes              = $F5; // 2010.08.01
      CSpecialThanks         = $F6; // 2010.08.01

      CAppMascotBy           = $FB; // 2012.12.03
                             //$FC is temporarily free
      CAppMessage            = $FD; // 2012.12.03

      CContinued             = $FE; // 2010.08.01

      ReadMeFile             = $FF; // 2010.08.01

implementation

uses AnimED_Translation;

procedure InitBuiltInMessages;
begin
 SetLength(AMS,ReadMeFile+1); // јвтоматическа€ подгонка размера массива :3

///////// ANIMED README (USER'S MANUAL) FILENAME
 AMS[ReadMeFile]            := 'manual.htm';

///////// Fragmentation\Compression ratio dialog
 AMS[AFragCheckResults]     := 'Fragmentation check results';

 AMS[ARecordsInArchive]     := 'Records in archive';

 AMS[APhysicalArcSize]      := 'Physical archive size';
 AMS[ACalculatedSize]       := 'Calculated files size';
 AMS[AUncompressedSize]     := 'Uncompressed files size';
 AMS[AWasted]               := 'Wasted';
 AMS[ASaved]                := 'Saved';
 AMS[AFragRatio]            := 'Fragmentation ratio';
 AMS[ACompRatio]            := 'Compression ratio';
 AMS[AMissing]              := 'Missing';
 AMS[ADamageRatio]          := 'Possible damage ratio';

///////// COMMON TYPES AND MESSAGES
 AMS[AInformation]          := 'Information';
 AMS[AArchive]              := 'Archive';
 AMS[AAddFields]            := 'Additional fields';
 AMS[AFile]                 := 'File';

 AMS[AEngineVersion]        := 'Engine version';
 AMS[AFormatStatus]         := 'Format status';

 AMS[AGigabytes]            := 'Gb';
 AMS[AMegabytes]            := 'Mb';
 AMS[AKilobytes]            := 'Kb';
 AMS[Abytes]                := 'bytes';
 AMS[Abits]                 := 'bit';
 AMS[AUnknownFormat]        := 'unknown format';
 AMS[AReserved]             := 'Reserved';
 AMS[AAllFiles]             := 'All files';
 AMS[AVersion]              := 'Version';
 AMS[ANewDirectory]         := 'New directory';

 AMS[AFileNoData]           := '(no data)';
 AMS[AFileIsDamaged]        := 'Damaged';
 AMS[AFileIsDead]           := 'Dead';
 AMS[AFileIsOK]             := 'Seems OK';

 AMS[ACompTypeRAW]          := 'RAW';
 AMS[ACompTypeNone]         := 'None / Other';
 AMS[ACompTypeUnknown]      := 'Unknown';
 AMS[ACompTypeGenericLZSS]  := 'Generic LZSS';

 AMS[AUnknownFileType]      := 'Unknown';

 AMS[AHashCRC32Confirm]     := 'CRC32 hash confirmation';
 AMS[AHashMD5Confirm]       := 'MD5 digest confirmation';

 AMS[AHashHugeFileWarn]     := 'This file is large, so the operation may take very long time. Are you sure you still want to continue?';

 AMS[ABrowseForDirTitle]    := 'Please select the correct directory:';

 AMS[ALeft]                 := 'Left';
 AMS[ARight]                := 'Right';
 AMS[ATop]                  := 'Top';
 AMS[ABottom]               := 'Bottom';

 AMS[ANotAFile]             := 'not a file';

 AMS[ACannotCreateDir]      := 'Cannot create directory in the selected location.';

 AMS[ATruncatedFileName]    := 'symbols. Filename will be truncated.';

///////// Messageboxes

 AMS[AStatusReadme]         := 'Please refer to readme for details about this format.';
 AMS[AStatusBuggy]          := 'The current implementation of this format is buggy and is known to produce files broken or unrecognizable by the original engine.';
 AMS[AStatusUnpack]         := 'The current implementation of this format is read-only.';
 AMS[AStatusUntested]       := 'The current implementation of this format is untested.';
 AMS[AStatusDummy]          := 'This format is Dummy.';
 AMS[AStatusHack]           := 'The current implementation of this format is a hacked version of the original format and it''s behavior has been designed for an specifical case, so it may produce broken or incorrect data, either on loading or saving.';
 AMS[AStatusWriteOnly]      := 'This format is a variation of the base format with minor differences in structure. For this reason it is skipped during archive format detection and considered "write-only".';

 AMS[AWarning]              := 'Warning';
 AMS[AUnsupportedFormat]    := 'The format you''ve selected is not implemented yet. Because of that the output file will be blank. Sorry. :)';
 AMS[AOverwriteChunks1]     := 'PLEASE NOTE: This operation will overwrite the existant chunks.';
 AMS[AOverwriteChunks2]     := 'Do you REALLY want to continue?';
 AMS[AByteConvOverwrite]    := 'Do you wish to overwrite original file? If not, then separate ".converted" version will be writed.';

 AMS[AFormatTaggedAs]       := 'This format is tagged as';
 AMS[AFormatTaggedAs2]      := 'Do you still wish to continue?';

///////// GrapS Unit MESSAGES

 AMS[MTRawReader]           := 'the RAW image reader tool';

///////// W,I,M,E MESSAGES

 AMS[ICalculatingCRC32]     := 'Calculating CRC32, please wait...';
 AMS[ICalculatingMD5]       := 'Calculating MD5 digest, please wait...';

 AMS[WArchiveExtract]       := 'Open the archive file first!';
 AMS[EArchiveExtract]       := 'Error while extracting';
 AMS[EArchiveIsBroken]      := 'Archive is broken or unsupported.';
 AMS[WArchiveInvalidEntry]  := 'The file entry is not valid and cannot be extracted.';
 AMS[EUnableToUnpack]       := 'Unable to unpack';
 AMS[IArchiveStreamClosed]  := 'Archive stream is closed.';
 AMS[WArchiveStreamClosed]  := 'Archive stream is closed. Already!';
 AMS[EArchiveExists]        := 'The archive is already exists and cannot be overwritten. Please use a different filename and\or location.';

 AMS[AHiddenDataCheck1]     := 'A hidden (probably deleted or garbage) data has been found in this archive.';
 AMS[AHiddenDataCheck2]     := 'Do you wish it to be listed in the GUI, so you would be able to extract it?';
 AMS[AHiddenDataCheck3]     := 'Note: the unknown data will be appended to the end of file list.';

 AMS[AHiddenData404]        := 'No hidden data found in this archive.';
 AMS[AHiddenData302]        := 'gap(s) found in this archive at the following offsets';

 AMS[AEndOfReport]          := 'End of report.';

 AMS[EInvalidDirectory]     := 'Invalid directory specified!';

 AMS[ICreatingOutDir]       := 'Creating output directory...';
 AMS[ECreatingOutDir]       := 'Cannot create output directory!';

 AMS[ECannotOpenFile]       := 'Cannot open the file. Make sure it is not used by other applications.';
 AMS[ECannotFindFile]       := 'Cannot find the file.';

 AMS[IReadingAudioFile]     := 'Reading audio file...';
 AMS[WAudioConversion]      := 'Open the audio file first!';

 AMS[IImageConversionDone]  := 'Image was succesfully converted.';
 AMS[EImageConversion]      := 'Error while converting image.';
 AMS[WImageConversion]      := 'Open the image file first!';

 AMS[EImageNoAlpha]         := 'This image doesn''t contain alpha.';
 AMS[EImagePowerOf2]        := 'The image proportions is not the power of 2 and cannot be splitted or merged.';
 AMS[EImageDiffers]         := 'Cannot compare images with different proportions.';
 AMS[EImageDiffers2]        := 'Unsupported format or alpha width && height differs from image''s.';

 AMS[IDone]                 := 'Done.';
 AMS[ICancelledByUser]      := 'Cancelled by user.';
 AMS[EUnexpectedError]      := 'Unexpected error.';
 AMS[EResourceReadingError] := 'Error while reading PNG resources.';

 AMS[EUnsupportedFormat]    := 'Unsupported format.';
 AMS[EUnsupportedOutFormat] := 'The format you''ve selected as output is not (yet) implemented.';

 AMS[EKeyFileToSelf]        := 'You are trying to decode/encode key file using the same file as target. This operation is not allowed.';

 AMS[ENoValidKeyFile]       := 'No valid keyfile specified.';

 AMS[ESavingFile]           := 'Error while saving';

 AMS[WArchiveOverwriteMode] := 'Archive overwriting mode is active. Please be careful.';
 AMS[MArchiveOverwriteMode] := 'Archive overwriting mode is deactivated.';

 AMS[IConvertingBytes]      := 'Converting file bytes. Please wait...';
 AMS[IConvertingBytesDone]  := 'File bytes converted.';
 AMS[EConvertingBytes]      := 'Error while trying to convert file bytes.';

 AMS[WLoggingDisabled]      := 'Logging has been disabled. Bye, bye! :(';
 AMS[MLoggingEnabled]       := 'Logging has been enabled. I have a lot of things to say! :)';
 AMS[MLogCleared]           := 'Debugging log cleared at';

 AMS[IUnderConstruction]    := 'This option is under construction.';

 AMS[IScrDecompiling]       := 'Decompiling records...';
 AMS[IScrExportFinished]    := 'Exporting finished.';
 AMS[IScrImportFinished]    := 'Importing finished.';

 AMS[WScrCannotExport]      := 'Cannot export -- no file is opened.';
 AMS[WScrCannotImport]      := 'Cannot import -- no file is opened.';
 AMS[EScrCannotImport]      := 'Cannot import -- some chunk files are missing!';
 AMS[EScrCannotWriteDir]    := 'Cannot create output directory and write compiled file.';

 AMS[IReinitialization]     := 'Reinitialization completed.';

 AMS[AStartedAt]            := 'started at';
 AMS[ACopiedTo]             := 'copied to';
 AMS[AOpenedSuccessfully]   := 'opened successfully.';
 AMS[ACreatedSuccessfully]  := 'created successfully.';
 AMS[AExtractedSuccessfully]:= 'extracted successfully.';
 AMS[AAddedSuccessfully]    := 'added successfully.';
 AMS[ADecodedSuccessfully]  := 'decoded successfully.';

 AMS[AImportedAsAlpha]      := 'imported as alpha.';

 AMS[OInitializing]         := 'Initializing...';
 AMS[OExtracting]           := 'Extracting...';
 AMS[OConverting]           := 'Converting...';
 AMS[OSaving]               := 'Saving...';
 AMS[OOpening]              := 'Opening...';
 AMS[OAdding]               := 'Adding...';
 AMS[OExport]               := 'Exporting...';
 AMS[OImport]               := 'Importing...';

 AMS[CCredits]              := '&b&uCredits';
 AMS[CIdea]                 := '&bIdea && graphics';
 AMS[CCore]                 := '&bCore';
 AMS[CContrib]              := '&bContributors';
 AMS[CLocalise]             := '&bLocalisation staff';
 AMS[CIncludes]             := '&bIncluded components && misc reference stuff';
 AMS[CSpecialThanks]        := '&bSpecial thanks to...';

 AMS[CAppMascotBy]          := 'Nepeta Leijon sprite by CountAile. Used with purrmission. :33'; // $FB; // 2012.12.03
 AMS[CAppMessage]           := ':33 < *the gorgeous cat monster pounces on unsuspecting prey*'; // $FD; // 2012.12.03

 AMS[CContinued]            := 'To be continued! :)';

 ContribAdd('Alexander Blade');
 ContribAdd('Animeshnik');
 ContribAdd('dsp2003');
 ContribAdd('HatsuneTakumi');
 ContribAdd('Katta');
 ContribAdd('Korg');
 ContribAdd('Marisa-Chan');
 ContribAdd('Nik');
 ContribAdd('p4s');
 ContribAdd('Traneko');
 ContribAdd('Vendor');
 ContribAdd('w8m');

 TransAdd('Ivo Kolarov [Bulgarian]');
 TransAdd('Ivo Zhelev [Bulgarian]');
 TransAdd('LukeЃ && JakoЖ && WiZ [Hungarian]');
 TransAdd('Marco Romeo [Italian]');
 TransAdd('Sora Kekko [Italian]');
 TransAdd('Thuriel [Spanish]');
 TransAdd('katta aka M3956 [Ukrainian]');

 CompoAdd('&bJISKit component suite');
 CompoAdd('p4s aka Proger_XP');
 CompoAdd('&uhttp://vn.i-forge.net/tools/');
 CompoAdd('');
 CompoAdd('&bJVCL component library');
 CompoAdd('Project JEDI');
 CompoAdd('&uhttp://jvcl.sourceforge.net');
 CompoAdd('');
 CompoAdd('&bPortable Network Graphics object library');
 CompoAdd('Gustavo Huffenbacher Daud');
 CompoAdd('&ugubadaud@terra.com.br');
 CompoAdd('&uhttp://pngdelphi.sourceforge.net');
 CompoAdd('');
 CompoAdd('&bGIF Graphics Object library v2.2.5');
 CompoAdd('Finn Tolderlund');
 CompoAdd('&uhttp://www.tolderlund.eu/');
 CompoAdd('');
 CompoAdd('&bTScrollingCredits component');
 CompoAdd('Raoul Snyman / Saturn Laboratories');
 CompoAdd('&uhttp://www.saturnlaboratories.co.za');
 CompoAdd('&ucomponents@saturnlaboratories.gq.nu');
 CompoAdd('');
 CompoAdd('&bzlibEx 1.2.3');
 CompoAdd('Brent Sherwood \ base2 technologies');
 CompoAdd('&uhttp://www.base2ti.com');

 SetLength(Joke,0); // resetting length

 JokeAdd(AMS[CAppMessage]);
 JokeAdd('GLUB GLUB. Gone fishing.');
 JokeAdd('UgUU~! ^m^');
 JokeAdd('So long, and thanks for all the fish.');
 JokeAdd('Rule #1: Don''t Panic!');
 JokeAdd('Dear, sweet, precious Nepeta...');
 JokeAdd('What are you doing, Dave...?');
 JokeAdd('That was the plan, to give you a boner. And you''ve got one!');
 JokeAdd('No lusi were harmed in making of this film.');
 JokeAdd('Don''t drink sopor slime, kids! :33');
 JokeAdd('Presented by SkaiaNet');
 JokeAdd('Sponsored by CrockerCorp');

 JokeAdd('Cracked by Bill Gilbert');
 JokeAdd('100% pure native x86 code. Beware of crappy .NET fakes.');
 JokeAdd('There''s no Easter Eggs. Go away!');

 JokeAdd('A long time ago, in a galaxy far far away...');

 JokeAdd('Brought to you by well-trained slowpokes.');

 FillCredits; // Preparing credits. Must be done after jokes, otherwise it will not work normally

end;

end.