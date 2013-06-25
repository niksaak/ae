{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  Image preview form module

  Written by dsp2003.
}
unit AnimED_ImagePreview;

interface

uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls;

type
 TPreviewForm = class(TForm)
  I_LargePreview: TImage;
  procedure Shape_BGMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  procedure I_LargePreviewDblClick(Sender: TObject);
  procedure FormShow(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var PreviewForm: TPreviewForm;

implementation

{$R *.dfm}

uses AnimED_Main;

procedure TPreviewForm.Shape_BGMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ReleaseCapture;
 SendMessage(Self.Handle, WM_SYSCOMMAND, $F012, 0);
end;

procedure TPreviewForm.I_LargePreviewDblClick(Sender: TObject);
begin
 if Self.WindowState = wsMaximized then Self.Close else Self.WindowState := wsMaximized;
end;

procedure TPreviewForm.FormShow(Sender: TObject);
begin
 Self.Caption := Application.Title + ' - [NyaView ^_^]';
 Self.WindowState := wsNormal;
end;

end.
