unit UnicodeComponents;

                              {

  TLabel      :: Unicode  mod


    by Proger_XP
      www.solelo.com/p4s
        mailme -@- smtp.ru
          22.06.09
                               }

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Windows, Graphics;

type
  TLabelW = class (TLabel)
  protected                                                     
    FCaption: WideString;

    procedure DoDrawText(var Rect: TRect; Flags: Longint); override;
    procedure SetCaption(Value: WideString);
  published
    property Caption: WideString read FCaption write SetCaption;
  end;

procedure Register;

implementation

procedure TLabelW.SetCaption(Value: WideString);
begin
  FCaption := Value;
  AdjustBounds;
  Repaint
end;

// StdCtrls: 1449
procedure TLabelW.DoDrawText;
var
  Text: WideString;
begin
  Text := Caption;      
  if (Flags and DT_CALCRECT <> 0) and ((Text = '') or ShowAccelChar and
    (Text[1] = '&') and (Text[2] = #0)) then Text := Text + ' ';
  if not ShowAccelChar then Flags := Flags or DT_NOPREFIX;
  Flags := DrawTextBiDiModeFlags(Flags);
  Canvas.Font := Font;
  if not Enabled then
  begin
    OffsetRect(Rect, 1, 1);
    Canvas.Font.Color := clBtnHighlight;
    DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text), Rect, Flags);
    OffsetRect(Rect, -1, -1);
    Canvas.Font.Color := clBtnShadow;
    DrawTextW(Canvas.Handle, PWideChar(Text), Length(Text), Rect, Flags);
  end
  else
    DrawTextW(Canvas.Handle, pwidechar(text), Length(Text), Rect, Flags)
end;

procedure Register;
begin
  RegisterComponents('JISKit', [TLabelW]);
end;

end.


