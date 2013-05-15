unit Credits;

{*******************************************************************************
*  TScrollingCredits version 1.2                                               *
********************************************************************************
* Author: Raoul Snyman                                                         *
* ---------------------------------------------------------------------------- *
* E-Mail: components@saturnlaboratories.gq.nu                                  *
* ---------------------------------------------------------------------------- *
* Copyright: ©2000 Saturn Laboratories, All rights reserved.                   *
* ---------------------------------------------------------------------------- *
* Description: TScrollingCredits is a component which displays scrolling       *
*              credits like at the end of movies, videos, etc.                 *
********************************************************************************
* This component is FREEWARE.                                                  *
* ---------------------------------------------------------------------------- *
* Please let me know if you find it useful!!                                   *
* ---------------------------------------------------------------------------- *
* It may be used for commercial purposes on the condition that you give me     *
* credit (i.e. place it in your credits list).                                 *
* ---------------------------------------------------------------------------- *
* If used in freeware, it's not necessary to give me credit, although it would *
* be appreciated.                                                              *
* ---------------------------------------------------------------------------- *
* If you modify this code, please send me an e-mail with a copy of the code    *
* attached, letting me know what it was that you changed/modified/added.       *
*******************************************************************************
* Modified: (first name) (last name)                                           *
*           (version), (date)                                                  *
*           (description of modification)                                      *
* Modified: Richard C. Haven         Reference: // RCH                         *
*           1.1, 17 November 2001                                              *
*           Added background bitmap and events.                                *
* Modified: Raoul Snyman             Reference: // RS                          *
*           1.1a, 26 December 2001                                             *
*           Added support for no border.                                       *
* Modified: Raoul Snyman             Reference: // RS1                         *
*           1.2, 6 March 2002                                                  *
*           Added basic formatting capabilities.                               *
*           Includes Bold, Italic, Underline and Color.                        *
*******************************************************************************}

interface

uses
   Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   ExtCtrls;

type
   TCreditEvent = procedure(Sender : TObject; CreditText : String) of object; // RCH
   TScrollingCredits = class(TGraphicControl)
   private
       FCredits: TStringList;
       FFont: TFont;
       FBackgroundColor: TColor;
       FBackgroundImage: TPicture;
       FBorderColor: TColor;
       FAnimate: Boolean;
       FInterval: Cardinal;
       FTimer: TTimer;
       YPos: Integer;
       TPos: Integer;
       FBitmap: TBitmap;  //  used to reduce flickering
       FOnShowCredit: TCreditEvent;                                     // RCH
       FAfterLastCredit: TNotifyEvent;                                  // RCH
       FVisible: Boolean;
       LastShownIndex: Integer;                                         // RCH
       FShowBorder: Boolean;                                            // RS
       procedure SetVisible(Value: Boolean);                            // RCH
       procedure ResetAnimation;                                        // RCH
       procedure BackgroundImageChanged(Sender: TObject);               // RCH
       procedure SetBackgroundImage(Value: TPicture);                   // RCH
   protected
       procedure SetCredits(Value: TStringList);
       procedure SetFont(Value: TFont);
       procedure SetBackgroundColor(Value: TColor);
       procedure SetBorderColor(Value: TColor);
       procedure SetAnimate(Value: Boolean);
       procedure SetInterval(Value: Cardinal);
       procedure DoShowCredit(const ACredit: String); virtual;          // RCH
       procedure DoAfterLastCredit; virtual;                            // RCH
       procedure SetShowBorder(Value: Boolean);                         // RS
   public
       constructor Create(AOwner: TComponent); override;
       destructor Destroy; override;
       procedure Paint; override;
       procedure TimerFired(Sender : TObject);
       procedure Reset;
   published
       property Credits: TStringList read FCredits write SetCredits;
       property CreditsFont: TFont read FFont write SetFont;
       property BackgroundColor: TColor read FBackgroundColor write SetBackgroundColor;
       property BorderColor: TColor read FBorderColor write SetBorderColor;
       property Animate: Boolean read FAnimate write SetAnimate;
       property Interval: Cardinal read FInterval write SetInterval;
       property OnShowCredit: TCreditEvent read FOnShowCredit write FOnShowCredit;  // RCH
       property AfterLastCredit: TNotifyEvent read FAfterLastCredit write FAfterLastCredit;  // RCH
       property Visible: Boolean read FVisible write SetVisible default True;  // RCH
       property BackgroundImage: TPicture read FBackgroundImage write SetBackgroundImage;  // RCH
       property ShowBorder: boolean read FShowBorder write SetShowBorder;  // RS
       property OnClick;                                                // RCH
       property OnDblClick;                                             // RCH
   end;

procedure Register;

implementation

procedure Register;
begin
 RegisterComponents('Samples', [TScrollingCredits]);
end;

constructor TScrollingCredits.Create(AOwner : TComponent);
begin
 inherited Create(AOwner);
 Width := 305;
 Height := 201;
 FCredits := TStringList.Create;
 FFont := TFont.Create;
 FTimer := TTimer.Create(Self);
 FBitmap := TBitmap.Create;
 FCredits.Add('&b&uTScrollingCredits');
 FCredits.Add('Copyright ©2000 Saturn Laboratories');
 FCredits.Add('');
 FCredits.Add('This version includes basic formatting!!');
 FCredits.Add('&bMake a line bold with &&b');
 FCredits.Add('&uMake a line underlined with &&u');
 FCredits.Add('&iMake a line italicized with &&i');
 FCredits.Add('&c255,255,0;Make a line a different color');
 FCredits.Add('&c0,255,255;with &&c[red],[green],[blue];');
 FCredits.Add('');
 FCredits.Add('And put that ampersand in with &&&&');
 FCredits.Add('');
 FCredits.Add('&bPlease let me know if you find');
 FCredits.Add('&bthis component useful.');
 FCredits.Add('components@saturnlaboratories.gq.nu');
 FFont.Color := clWhite;
 FFont.Name := 'Tahoma';
 FTimer.Interval := 50;
 FTimer.Enabled := False;
 FTimer.OnTimer := TimerFired;
 FBitmap.Width := Width;
 FBitmap.Height := Height;
 FBackgroundColor := clBlack;
 FBorderColor := clWhite;
 FAnimate := False;
 FInterval := 50;
 YPos := 4;
 TPos := 0;
 FVisible := True;                                                      // RCH
 FBackgroundImage := TPicture.Create;                                   // RCH
 FBackgroundImage.OnChange := BackgroundImageChanged;                   // RCH
 FShowBorder := True;                                                   // RS
end;

destructor TScrollingCredits.Destroy;
begin
 FBitmap.Free;
 FTimer.Free;
 FFont.Free;
 FCredits.Free;
 FBackgroundImage.Free;                                                 // RCH
 inherited Destroy;
end;

procedure TScrollingCredits.Paint;  // Major adjustment to painting method done by RCH
var I, J, X, Y, Index: Integer;     // Formatting added by RS1
    HeightOfA: Integer;
    RGB: array[1..3] of String;
    S, T, Color: String;
    Bold, Italic, Underline: Boolean;
begin
 if Visible
  then
   begin
    inherited Paint;
    with FBitmap do
     begin
      Width := Self.Width;
      Height := Self.Height;
      Canvas.Font := FFont;
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := FBackgroundColor;
      if (FBackgroundImage.Graphic <> nil) and (not FBackgroundImage.Graphic.Empty)  // RCH
       then Canvas.StretchDraw(Canvas.ClipRect, FBackgroundImage.Graphic)  // RCH
       else Canvas.FillRect(Rect(0, 0, Width, Height));                 // RCH
      Canvas.Brush.Style := bsClear;
      if FAnimate
       then
        begin
         Y := TPos;
         HeightOfA := Canvas.TextHeight('A');
         for I := 0 to FCredits.Count - 1 do
          begin
           S := FCredits.Strings[I];                                    // RS1
           T := '';                                                     // RS1
           J := 1;                                                      // RS1
           Bold := False;                                               // RS1
           Italic := False;                                             // RS1
           Underline := False;                                          // RS1
           Color := ColorToString(FFont.Color);                         // RS1
           while J <= Length(S) do                                      // RS1
            if S[J] = '&'                                               // RS1
             then                                                       // RS1
              begin                                                     // RS1
               Inc(J);                                                  // RS1
               case S[J] of                                             // RS1
                'B', 'b' : Bold := True;                                // RS1
                'I', 'i' : Italic := True;                              // RS1
                'U', 'u' : Underline := True;                           // RS1
                '&' : T := T + '&';                                     // RS1
                'C', 'c' : begin                                        // RS1
                            Inc(J);                                     // RS1
                            RGB[1] := '';                               // RS1
                            RGB[2] := '';                               // RS1
                            RGB[3] := '';                               // RS1
                            Index := 1;                                 // RS1
                            while (S[J] <> ';') and (J <= Length(S)) do  // RS1
                             begin                                      // RS1
                              if S[J] = ','                             // RS1
                               then                                     // RS1
                                begin                                   // RS1
                                 Inc(J);                                // RS1
                                 Inc(Index);                            // RS1
                                end                                     // RS1
                               else                                     // RS1
                                begin                                   // RS1
                                 RGB[Index] := RGB[Index] + S[J];       // RS1
                                 Inc(J);                                // RS1
                                end;                                    // RS1
                             end;                                       // RS1
                            Color := '$00' + IntToHex(StrToInt(RGB[3]), 2)   // RS1
                                           + IntToHex(StrToInt(RGB[2]), 2)   // RS1
                                           + IntToHex(StrToInt(RGB[1]), 2);  // RS1
                           end;                                         // RS1
               end;                                                     // RS1
               Inc(J);                                                  // RS1
              end                                                       // RS1
             else                                                       // RS1
              begin                                                     // RS1
               T := T + S[J];                                           // RS1
               Inc(J);                                                  // RS1
              end;                                                      // RS1
           Canvas.Font := FFont;                                        // RS1
           Canvas.Font.Color := StringToColor(Color);                   // RS1
           if Bold                                                      // RS1
            then Canvas.Font.Style := [fsBold];                         // RS1
           if Italic                                                    // RS1
            then Canvas.Font.Style := Canvas.Font.Style + [fsItalic];   // RS1
           if Underline                                                 // RS1
            then Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];  // RS1
           X := (Width div 2) - (Canvas.TextWidth(T) div 2);
           if (Y + HeightOfA) > 0
            then
             begin
              Canvas.TextOut(X, Y, T);
              if I > LastShownIndex
               then
                begin
                 DoShowCredit(T);
                 LastShownIndex := I;
                end;
             end;
           Inc(Y, HeightOfA);
           if Y > Height
            then Break;
          end;
        end
       else
        begin
         Y := 0;
         HeightOfA := Canvas.TextHeight('A');
         for I := 0 to FCredits.Count - 1 do
          begin
           S := FCredits.Strings[I];                                    // RS1
           T := '';                                                     // RS1
           J := 1;                                                      // RS1
           Bold := False;                                               // RS1
           Italic := False;                                             // RS1
           Underline := False;                                          // RS1
           Color := ColorToString(FFont.Color);                         // RS1
           while J <= Length(S) do                                      // RS1
            if S[J] = '&'                                               // RS1
             then                                                       // RS1
              begin                                                     // RS1
               Inc(J);                                                  // RS1
               case S[J] of                                             // RS1
                'B', 'b' : Bold := True;                                // RS1
                'I', 'i' : Italic := True;                              // RS1
                'U', 'u' : Underline := True;                           // RS1
                '&' : T := T + '&';                                     // RS1
                'C', 'c' : begin                                        // RS1
                            Inc(J);                                     // RS1
                            RGB[1] := '';                               // RS1
                            RGB[2] := '';                               // RS1
                            RGB[3] := '';                               // RS1
                            Index := 1;                                 // RS1
                            while (S[J] <> ';') and (J <= Length(S)) do  // RS1
                             begin                                      // RS1
                              if S[J] = ','                             // RS1
                               then                                     // RS1
                                begin                                   // RS1
                                 Inc(J);                                // RS1
                                 Inc(Index);                            // RS1
                                end                                     // RS1
                               else                                     // RS1
                                begin                                   // RS1
                                 RGB[Index] := RGB[Index] + S[J];       // RS1
                                 Inc(J);                                // RS1
                                end;                                    // RS1
                             end;                                       // RS1
                            Color := '$00' + IntToHex(StrToInt(RGB[3]), 2)   // RS1
                                           + IntToHex(StrToInt(RGB[2]), 2)   // RS1
                                           + IntToHex(StrToInt(RGB[1]), 2);  // RS1
                           end;                                         // RS1
               end;                                                     // RS1
               Inc(J);                                                  // RS1
              end                                                       // RS1
             else                                                       // RS1
              begin                                                     // RS1
               T := T + S[J];                                           // RS1
               Inc(J);                                                  // RS1
              end;                                                      // RS1
           Canvas.Font := FFont;                                        // RS1
           Canvas.Font.Color := StringToColor(Color);                   // RS1
           if Bold                                                      // RS1
            then Canvas.Font.Style := [fsBold];                         // RS1
           if Italic                                                    // RS1
            then Canvas.Font.Style := Canvas.Font.Style + [fsItalic];   // RS1
           if Underline                                                 // RS1
            then Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];  // RS1
           X := (Width div 2) - (Canvas.TextWidth(T) div 2);
           Canvas.TextOut(X, YPos + Y, T);
           Y := Y + HeightOfA;
          end;
        end;
      if FShowBorder                                                    // RS
       then                                                             // RS
        begin                                                           // RS
         Canvas.Pen.Color := FBorderColor;                              // RS
         Canvas.Rectangle(0, 0, Width, Height);                         // RS
        end;                                                            // RS
     end;
    Self.Canvas.Draw(0, 0, FBitmap); //  this reduces flickering by drawing all at once
   end
  else
   if csDesigning in ComponentState
    then Self.Canvas.FrameRect(Rect(0, 0, Width, Height));
end;

procedure TScrollingCredits.SetCredits(Value : TStringList);
begin
 FCredits.Assign(Value);
 Paint;
end;

procedure TScrollingCredits.SetFont(Value : TFont);
begin
 FFont.Assign(Value);
 Invalidate;
end;

procedure TScrollingCredits.SetBackgroundColor(Value : TColor);
begin
 FBackgroundColor := Value;
 Invalidate;
end;

procedure TScrollingCredits.SetBorderColor(Value : TColor);
begin
 FBorderColor := Value;
 Invalidate;
end;

procedure TScrollingCredits.SetAnimate(Value : Boolean);
begin
 TPos := Height + Canvas.TextHeight('A');
 FAnimate := Value;
 FTimer.Enabled := Value;
 Paint;
end;

procedure TScrollingCredits.TimerFired(Sender : TObject);
begin
 Canvas.Font := FFont;
 if TPos < (0 - (FCredits.Count * Canvas.TextHeight('A')))
  then
   begin
    DoAfterLastCredit;
    ResetAnimation;
   end
  else Dec(TPos);
 Paint;
end;

procedure TScrollingCredits.ResetAnimation;
begin
 TPos := Height;                     //      start down below the visible window again
 LastShownIndex := -1;
end;

procedure TScrollingCredits.SetInterval(Value : Cardinal);
begin
 FInterval := Value;
 FTimer.Interval := Value;
end;

procedure TScrollingCredits.Reset;
begin
 Canvas.Font := FFont;
 TPos := Height + Canvas.TextHeight('A');
end;

procedure TScrollingCredits.DoAfterLastCredit;
begin
 if Assigned(FAfterLastCredit)
  then FAfterLastCredit(Self);
end;

procedure TScrollingCredits.DoShowCredit(const ACredit : string);
begin
 if Assigned(FOnShowCredit)
  then FOnShowCredit(Self, ACredit);
end;

procedure TScrollingCredits.SetVisible(Value : Boolean);
begin
 if Visible <> Value
  then
   begin
    FVisible := Value;
    if Value
     then FTimer.Enabled := Animate
     else FTimer.Enabled := False;
    ResetAnimation;
    if Parent <> nil
     then Parent.Invalidate;
   end;
end;

procedure TScrollingCredits.BackgroundImageChanged(Sender : TObject);
begin
 Self.Invalidate;
end;

procedure TScrollingCredits.SetBackgroundImage(Value : TPicture);
begin
 FBackgroundImage.Assign(Value);
 Self.Invalidate;
end;

procedure TScrollingCredits.SetShowBorder(Value: Boolean);
begin
 FShowBorder := Value;
 Self.Invalidate;
end;

end.
