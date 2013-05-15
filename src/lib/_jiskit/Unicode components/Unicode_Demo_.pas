unit Unicode_Demo_;

                              {

  TLabel      :: Unicode  mod


    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          22.06.09
                               }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, UnicodeComponents;

type
  TForm1 = class(TForm)
    eansi: TEdit;
    lansi: TLabel;
    lunicode: TLabelW;
    esjs: TEdit;
    Label1: TLabel;
    procedure eansiChange(Sender: TObject);
    procedure esjsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses JReconvertor;

{$R *.dfm}

var
  Changing: Boolean = False;

procedure TForm1.eansiChange(Sender: TObject);
begin
  if Changing then
    Exit;

  Changing := True;
  esjs.Text := Ansi2JIS(eansi.Text);
  lansi.Caption := eansi.Text;
  lunicode.Caption := Ansi2Wide(eansi.Text);
  Changing := False
end;

procedure TForm1.esjsChange(Sender: TObject);
begin
  if Changing then
    Exit;

  Changing := True;
  eansi.Text := JIS2Ansi(esjs.Text);
  lansi.Caption := JIS2Ansi(esjs.Text);
  lunicode.Caption := JIS2Wide(esjs.Text);
  Changing := False
end;

end.
