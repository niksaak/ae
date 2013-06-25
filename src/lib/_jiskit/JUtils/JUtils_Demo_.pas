unit JUtils_Demo_;

                              {

  Unicode     ::        utils


    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          20.08.09
                               }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnicodeDialogs, StdCtrls, Buttons, UnicodeComponents;

type
  TForm1 = class(TForm)
    files: TMemo;
    BitBtn1: TBitBtn;
    odw: TOpenDialogW;
    anything: TMemo;
    path: TLabelW;
    Label1: TLabel;
    relative: TCheckBox;
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses JReconvertor, JUtils;

{$R *.dfm}

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  if odw.Execute then
  begin                                         
//    messageboxw(0, pwidechar(lowerCase(odw.FileName)), '', 0);exit;
    path.Caption := ExtractFilePath(odw.FileName);
    files.Lines.Clear;
    FindMask(path.Caption + '*.*', files.Lines);
    anything.Lines.Clear;
    if relative.Checked then
      FindAllRelative(path.Caption, '*.*', anything.Lines)
      else
        FindAll(path.Caption, '*.*', anything.Lines)
  end
end;

end.
