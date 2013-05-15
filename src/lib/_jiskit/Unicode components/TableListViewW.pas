unit TableListViewW;

interface

uses
  Windows, Messages, Forms, Classes, Controls, ComCtrls, Menus, TableListView,
  Graphics, CommCtrl;

type
  TTableListViewW = class (TTableListView)
  protected
    FHighlightColor: TColor;
    FHighlightTextColor: TColor;

    procedure DrawItem(Item: TListItem; Rect: TRect; State: TOwnerDrawState); override;

    procedure SetHighlightColor(const Value: TColor);
    procedure SetHighlightTextColor(const Value: TColor);
  public
    constructor Create(AOwner: TComponent); override;

    function MakeWideCaption(Str: WideString): String;  
    function StringOf(const Str: String): WideString;
  published
    property HighlightColor: TColor read FHighlightColor write SetHighlightColor default clMenuHighlight;
    property HighlightTextColor: TColor read FHighlightTextColor write SetHighlightTextColor default clBlack;
  end;

procedure Register;

implementation           

const                  
  MaxWideCaption = 600;
  WideStringPrefix = #1;
  AutoWidthImitationChar: WideChar = ' ';

type
  TWSArray = array[0..(MaxWideCaption * 2)] of WideChar;

constructor TTableListViewW.Create;
begin
  inherited;
  
  FHighlightColor := clMenuHighlight;
  FHighlightTextColor := clBlack
end;

procedure Register;
begin
  RegisterComponents('Miscellaneous', [TTableListViewW]);
end;

procedure TTableListViewW.DrawItem;
var
  Str: WideString;
  I, LeftPos: Integer;
begin              
  TControlCanvas(Canvas).UpdateTextFlags;

  if odSelected in State then
  begin
    Canvas.Brush.Color := HighlightColor;
    SetTextColor(Canvas.Handle, ColorToRGB(HighlightTextColor))
  end
    else
      Canvas.Brush.Color := Color;

  Canvas.FillRect(Rect);
  LeftPos := Rect.Left + 2;
  Str := StringOf(Item.Caption);
  TextOutW(Canvas.Handle, LeftPos + 2, Rect.Top, PWideChar(Str), Length(Str));

  if Assigned(OnDrawItem) then
    OnDrawItem(Self, Item, Rect, State);

  with Item, SubItems do
    if Count <> 0 then
      for I := 0 to Count - 1 do
      begin
        Inc(LeftPos, ListView_GetColumnWidth(Handle, I));
        Str := StringOf(SubItems[I]);
        TextOutW(Canvas.Handle, LeftPos, Rect.Top, PWideChar(Str), Length(Str))
      end
end;

function TTableListViewW.StringOf;
begin
  if Str[1] = WideStringPrefix then
    Result := PWideChar(@Str[ lstrlen(PChar(Str)) + 3 ])
    else
      Result := Str
end;

function TTableListViewW.MakeWideCaption(Str: WideString): String;
var
  AutoWidthImitation: String;
  ExtentShouldBe, PieceExtent: TSize;
begin
  AutoWidthImitation := '';
  if GetTextExtentPoint32W(Canvas.Handle, PWideChar(Str), Length(Str), ExtentShouldBe) and
     GetTextExtentPoint32W(Canvas.Handle, @AutoWidthImitationChar, 1, PieceExtent) then
    AutoWidthImitation := StringOfChar(AutoWidthImitationChar, ExtentShouldBe.cx div PieceExtent.cx)
    else
      AutoWidthImitation := StringOfChar('w', Length(Str) - 1);

  Result := WideStringPrefix + AutoWidthImitation + #0;
  SetLength(Result, MaxWideCaption);

  Str := Str + #0;
  CopyMemory(@Result[Length(AutoWidthImitation) + 4], @Str[1], Length(Str) * 2)
end;

procedure TTableListViewW.SetHighlightColor(const Value: TColor);
begin
  FHighlightColor := Value;
  Repaint
end;

procedure TTableListViewW.SetHighlightTextColor(const Value: TColor);
begin
  FHighlightTextColor := Value;
  Repaint
end;

end.
