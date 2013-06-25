unit VerticalButton;

{ This is a very simple vertical speed button. It can have bugs with some glyphs
  layouts; use Spacing to make glyph shift. } 

interface

uses           dialogs,
  Windows, SysUtils, Classes, Controls, Buttons, Graphics, Themes;

type
  TVerticalButton = class (TSpeedButton)
  protected
    // note: only current locale's characters could be handled as an accel chars (&c[har]).
    FCaption: WideString;
    FAlignment: TAlignment;
    FSpacingVert: ShortInt;

    procedure Paint; override;
    function Font2API(const Font: TFont): LOGFONT;

    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;

    procedure SetCaption(const Value: WideString);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetSpacingVert(const Value: ShortInt);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property CaptionVert: WideString read FCaption write SetCaption;
    property Alignment: TAlignment read FAlignment write SetAlignment default taRightJustify;
    property SpacingVert: ShortInt read FSpacingVert write SetSpacingVert default 8;
  end;

procedure Register;

implementation

uses Forms, Menus;

procedure TVerticalButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, FCaption) and Enabled and Visible and
      (Parent <> nil) and Parent.Showing then
    begin
      Click;
      Result := 1;
    end else
      inherited
end;

constructor TVerticalButton.Create(AOwner: TComponent);
begin
  inherited;
  FAlignment := taRightJustify;
  FSpacingVert := 8
end;

function TVerticalButton.Font2API(const Font: TFont): LOGFONT;
begin
  ZeroMemory(@Result, SizeOf(Result));
  Result.lfHeight := Font.Height;
  if fsBold in Font.Style then
    Result.lfWeight := 500;
  Result.lfItalic := Byte(fsItalic in Font.Style);
  Result.lfUnderline := Byte(fsUnderline in Font.Style);
  Result.lfStrikeOut := Byte(fsStrikeOut in Font.Style);
  Result.lfCharSet := Font.Charset;
  CopyMemory(@Result.lfFaceName, @Font.Name[1], Length(Font.Name))
end;

procedure TVerticalButton.Paint;
var
  Font: LOGFONT;
  IsDown: Byte;
  R: TRect;

  function StripAccelChars(const Str: WideString): WideString;
  var
    I: Word;
  begin
    Result := Str;
    for I := 1 to Length(Str) do
      if Str[I] = cHotkeyPrefix then
        Delete(Result, I, 1)
  end;

begin
  inherited;
                                                    
  Font := Font2API(Canvas.Font);
  Font.lfFaceName := 'Sans Serif';
  Font.lfEscapement := 900;
  Canvas.Font.Handle := CreateFontIndirect(Font);

  with Canvas.TextExtent( StripAccelChars(FCaption) ) do
  begin
    R := Rect((ClientWidth - CY) div 2, 0, 0, 0);
    
    if FAlignment = taCenter then
      R.Top := ClientHeight - (ClientHeight - cx) div 2
      else if FAlignment = taLeftJustify then
        R.Top := ClientHeight
        else
          R.Top := CX
  end;

  IsDown := Byte(not Down and (FState <> bsDown));
  InflateRect(R, IsDown, IsDown + FSpacingVert);

  DrawTextW(Canvas.Handle, PWideChar(FCaption), Length(FCaption), R, DT_NOCLIP)
end;

procedure TVerticalButton.SetAlignment(const Value: TAlignment);
begin
  FAlignment := Value;
  Repaint
end;

procedure TVerticalButton.SetCaption(const Value: WideString);
begin
  FCaption := Value;
  Repaint
end;

procedure TVerticalButton.SetSpacingVert(const Value: ShortInt);
begin
  FSpacingVert := Value;;
  Repaint
end;


procedure Register;
begin
  RegisterComponents('Miscellaneous', [TVerticalButton]);
end;

end.
