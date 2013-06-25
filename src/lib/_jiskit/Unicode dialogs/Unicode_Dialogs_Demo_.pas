unit Unicode_Dialogs_Demo_;

                              {
  TOpenDialog ::
              :: Unicode  mod
  TSaveDialog ::

    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          19.08.09
                               }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CommDlg, UnicodeDialogs, JUtils, ExtCtrls,
  UnicodeComponents, Buttons;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    files: TMemo;
    Image1: TImage;
    Image2: TImage;
    odw: TOpenDialogW;
    LabelW1: TLabelW;
    sdw: TSaveDialogW;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses StringsW;

var
  LastUsedDialog: TOpenDialogW;
  StringsFile: String;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  List: TStringsW;
begin
  if odw.Execute then
  begin
    LastUsedDialog := odw;

    LabelW1.Caption := odw.FileName;
    files.Lines.Clear;

    List := odw.Files;
    try
      StringsW2J(List, files.Lines)
    finally
      List.Free
    end;

    Width := LabelW1.Width + 24;
    Position := poScreenCenter
  end
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  List: TStringsW;
begin
  if sdw.Execute then
  begin                                 
    LastUsedDialog := sdw;

    LabelW1.Caption := sdw.FileName;  
    files.Lines.Clear;

    List := sdw.Files;
    try
      StringsW2J(List, files.Lines)
    finally
      List.Free
    end;

    Width := LabelW1.Width + 24;
    Position := poScreenCenter
  end
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  LastUsedDialog.Files.SaveToFile(StringsFile)
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  LastUsedDialog := odw;
  StringsFile := ExtractFilePath(ParamStr(0)) + 'TStrings SaveToFile test.txt'
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var
  Strings: TStringsW;
begin
  if FileExists(StringsFile) then
  begin
    Strings := TStringsW.Create;
    try
      Strings.LoadFromFile(StringsFile);
      files.Lines.Clear;
      StringsW2J(Strings, files.Lines)
    finally
      Strings.Free
    end
  end
    else
      MessageBox(Handle, 'Save some strings first.', 'TStringsW.LoadFromFile test', mb_IconStop)
end;

end.
