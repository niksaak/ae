unit JISDialogs_Demo_;

                              {
  TOpenDialog ::
              :: ShiftJIS mod
  TSaveDialog ::
  
    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          19.06.09
                               }

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CommDlg, JISDialogs, FileStreamJ, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Button2: TButton;
    odj: TOpenDialogJ;
    sdj: TSaveDialogJ;
    files: TMemo;
    Image1: TImage;
    Image2: TImage;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure filesDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);    {
var                                   
  dataw: topenfilenamew;
begin
  zeromemory(@dataw, sizeof(dataw));
  dataw.lStructSize := sizeof(dataw);
  dataw.hWndOwner := handle;
  dataw.hInstance := hinstance;

  getmem(dataw.lpstrFilter, 80);
  zeromemory(dataw.lpstrFilter, 80);
  dataw.nMaxCustFilter := 40;
  dataw.nFilterIndex := 0;

  getmem(dataw.lpstrFile, 80);
  zeromemory(dataw.lpstrFile, 80);
  dataw.nMaxFile := 40;

  dataw.lpstrFileTitle := NIL;
  dataw.lpstrInitialDir := NIL;
  dataw.lpstrTitle := NIL;
  dataw.Flags := 0;
  dataw.nFileOffset := 0;
  dataw.nFileExtension := 0;
  dataw.lpstrDefExt := NIL;
  getopenfilenamew(dataw);

  exit;                                 }

begin
  if odj.Execute then
  begin
    Label1.Caption := odj.FileName;
    files.Lines.Assign(odj.Files);
    Width := Label1.Width + 24;
    Position := poScreenCenter
  end
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if sdj.Execute then
  begin
    Label1.Caption := sdj.FileName;
    files.Lines.Assign(sdj.Files);
    Width := Label1.Width + 24;
    Position := poScreenCenter
  end
end;

procedure TForm1.filesDblClick(Sender: TObject);
var
  F: TFileStreamJ;
  Name: String;
  FN, Msg: PWideChar;

  function Exists: Boolean;
  var
    FindData: TWin32FindDataW;
  begin
    Result := FindFirstFileW(FN, FindData) <> INVALID_HANDLE_VALUE
  end;
                                       
begin
  Name := files.Lines[0];
  FN := F.JIS2Wide(PChar(Name)); // notice this method is used on not yet created class

  if Exists then
  begin
    F := TFileStreamJ.Create(Name, fmOpenRead);
    Msg := 'FileStreamJ: File was successfully opened.'
  end
    else
    begin
      F := TFileStreamJ.Create(Name, fmCreate);
      Msg := 'FileStreamJ: File was successfully created.'
    end;
  F.Free;

  MessageBoxW(Handle, Msg, FN, mb_IconInformation);
  FreeMem(FN, lstrlenw(FN) * 2 + 2)
end;

end.
