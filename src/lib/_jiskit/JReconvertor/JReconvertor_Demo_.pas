unit JReconvertor_Demo_;

                              {

  JReconvertor encodings unit


    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          20.06.09
                              }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    eansi: TEdit;
    eunicode: TEdit;
    esjs: TEdit;
    lansi: TLabel;
    lsjs: TLabel;
    lunicode: TLabel;
    Label1: TLabel;
    procedure eansiKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure esjsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure eansiChange(Sender: TObject);
    procedure lunicodeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateCharCodes;
  end;

var
  Form1: TForm1;

implementation

uses JReconvertor, Math;

{$R *.dfm}

var
  Unicode: WideString = 'Unicode';

function Hex(Buf: Pointer; Size: Byte = 4): String;
var
  Ch: Char;
begin
  Result := '';
  Size := Size div 2 * 2;

  while Size > 0 do
  begin
    Ch := Char(Buf^);
    if Ch < #33 then
      Ch := ' ';
    Result := Format('%s %.4x%s', [Result, Word(Buf^), Ch]);
    Buf := Pointer( DWord(Buf) + 2 );
    Dec(Size, 2)
  end;

  Result := Copy(Result, 2, $FFFF)
end;

procedure TForm1.eansiKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    esjs.Text := Ansi2JIS(eansi.Text);             
    Unicode := Ansi2Wide(eansi.Text);
    UpdateCharCodes
  end
end;

procedure TForm1.esjsKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
  begin
    eansi.Text := JIS2Ansi(esjs.Text);
    Unicode := JIS2Wide(esjs.Text);
    UpdateCharCodes
  end
end;

procedure TForm1.UpdateCharCodes;

  function Update(Str: String; MaxSize: Byte = 4): String;
  begin
    Result := Hex(@Str[1], Min(Length(Str), MaxSize))
  end;
                                      
begin
  lansi.Caption := Update(eansi.Text);
  lansi.Hint := Update(eansi.Text, 15);
  lsjs.Caption := Update(esjs.Text);
  lsjs.Hint := Update(esjs.Text, 15);

  eunicode.Text := Hex(@Unicode[1], Min(Length(Unicode) - 2, 20));
  lunicode.Caption := Hex(@Unicode[1], Min(Length(Unicode) - 2, 4));
  lunicode.Hint := Hex(@Unicode[1], Min(Length(Unicode) - 2, 30))
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Application.HintPause := 500;
  Application.HintHidePause := 30000;
  UpdateCharCodes
end;

procedure TForm1.eansiChange(Sender: TObject);
begin
  UpdateCharCodes
end;

procedure TForm1.lunicodeClick(Sender: TObject);
begin
  MessageBoxW(Handle, PWideChar(Unicode), 'Unicode string', mb_IconInformation)
end;

end.
