{
  AE - VN Tools
  © 2007-2013 WinKiller Studio and The Contributors.
  This software is free. Please see License for details.

  GUI & skin units : WinRAR-alike percentage cube ^3^

  Original non-component version

  Written by dsp2003.
  Several fixes & Matrix skin from Proger_XP.
}
unit AnimED_Skin_PercentCube;

interface

uses SysUtils, Graphics, Classes;

type
 TAE_PercentSkin = packed record
  BGColor         : TColor;      // clBtnFace // фоновый цвет

  BackLeft        : TColor;      // $00E06868
  BackRight       : TColor;      // $00FF8080

  ForeLeft        : TColor;      // $00823C96
  ForeRight       : TColor;      // $008C42C0

  ForeTopPen      : TColor;      // $008060A0 // цвет для незаполненной области
  ForeTopBrush    : TColor;      // $00A060A0 // цвет для незаполненной области

  ForeBottomPen   : TColor;      // $0064408C
  ForeBottomBrush : TColor;      // $007A408C

  ForeWireframe   : TColor;      // $00FFE0E0
  FontSize        : Integer;     // 10
  FontStyle       : TFontStyles; // [fsBold]
  FontName        : TFontName;   // Tahoma
  FontColor       : TColor;      // $0080005C, Tahoma, 10, [fsBold]
  
  TextVisible     : boolean;     // True
 end;

function pSkinDefault     : TAE_PercentSkin;
function pSkinBubbleGum   : TAE_PercentSkin;
function pSkinIceCube     : TAE_PercentSkin;
function pSkinGrayscale   : TAE_PercentSkin;
function pSkinMatrix      : TAE_PercentSkin;

procedure Skin_DrawPercentFigure(Glyph : TBitmap; Skin : TAE_PercentSkin; Percentage : integer; Width : integer = 80; Height : integer = 364);

implementation

function pSkinDefault;
begin
 with Result do begin
  BGColor         := clBtnFace;

  BackLeft        := $00E06868;
  BackRight       := $00FF8080;

  ForeLeft        := $00823C96;
  ForeRight       := $008C42C0;

  ForeTopPen      := $008060A0;
  ForeTopBrush    := $00A060A0;

  ForeBottomPen   := $0064408C;
  ForeBottomBrush := $007A408C;

  ForeWireframe   := $00FFE0E0;

  FontColor       := $0080005C;
  FontName        := 'Tahoma';
  FontStyle       := [fsBold];
  FontSize        := 10;

  TextVisible     := True;
 end;
end;

function pSkinBubbleGum;
begin
 with Result do begin
  BGColor         := clBtnFace;

  BackLeft        := $00DF8CF4;
  BackRight       := $00E7AFF5;

  ForeLeft        := $009F12C2;
  ForeRight       := $00B80DE3;

  ForeTopPen      := $00A90EE2;
  ForeTopBrush    := $00B00ED8;

  ForeBottomPen   := $00750EA0;
  ForeBottomBrush := $00830EA0;

  ForeWireframe   := $00FBEDFD;

  FontColor       := $0080005C;
  FontName        := 'Tahoma';
  FontStyle       := [fsBold];
  FontSize        := 10;

  TextVisible     := True;
 end;
end;

function pSkinIceCube;
begin
 with Result do begin
  BGColor         := clBtnFace;

  BackLeft        := $00FFDCB3;
  BackRight       := $00FFEBD3;

  ForeLeft        := $00FFBD6F;
  ForeRight       := $00FFCE95;

  ForeTopPen      := $00FFF1DD;
  ForeTopBrush    := $00FFD9AD;

  ForeBottomPen   := $00FF9C27;
  ForeBottomBrush := $00FFAF51;

  ForeWireframe   := $00FFFFFF;

  FontColor       := $00671708;
  FontName        := 'Tahoma';
  FontStyle       := [fsBold];
  FontSize        := 10;

  TextVisible     := True;
 end;
end;


function pSkinGrayscale;
begin
 with Result do begin
  BGColor         := clBtnFace;

  BackLeft        := $00909090;
  BackRight       := $00AAAAAA;

  ForeLeft        := $00717171;
  ForeRight       := $00848484;

  ForeTopPen      := $00808080;
  ForeTopBrush    := $008A8A8A;

  ForeBottomPen   := $005A5A5A;
  ForeBottomBrush := $006C6C6C;

  ForeWireframe   := $00EAEAEA;

  FontColor       := $000E0E0E;
  FontName        := 'Tahoma';
  FontStyle       := [fsBold];
  FontSize        := 10;

  TextVisible     := True;
 end;
end;

function pSkinMatrix;
begin
  with Result do
  begin
    BGColor         := clBlack;

    BackLeft        := $00003300;
    BackRight       := $00003300;

    ForeLeft        := clGreen;
    ForeRight       := clGreen;

    ForeTopPen      := $0000CC00;
    ForeTopBrush    := $0000CC00;

    ForeBottomPen   := clLime;
    ForeBottomBrush := $0000CC00;

    ForeWireframe   := clLime;

    FontColor      := clRed;
    FontName       := 'Courier New';
    FontStyle      := [fsBold];
    FontSize       := 9;
    
    TextVisible    := True;
  end
end;

procedure Skin_DrawPercentFigure;
var Percent, PercentDraw : integer; PercentText : string;
begin
 with Skin do begin
 // Glyph.Create;
  Glyph.Width := Width;
  Glyph.Height := Height;
  Glyph.TransparentColor := BGColor;

  Percent := Percentage;

  if Percent > 100 then Percent := 100;
  if Percent < 0   then Percent := 0;

  PercentDraw := Height - 11 - round(((Height-11)/100)*Percent);

  PercentText := inttostr(Percentage)+' %';

{ Drawing background }

  with Glyph.Canvas do begin

   Pen.Color := BGColor;
   Brush.Color := BGColor;

   Rectangle(0,0,Width,Height);

 { Drawing indicator's first layer }

   Pen.Color   := BackLeft; // $00E06868; //background layer color 1
   Brush.Color := BackLeft; // $00E06868; //background layer color 1

   Polygon([
    Point(0 ,5),
    Point(15,10),
    Point(15,Height-11),
    Point(0 ,Height-6)
   ]);

   Pen.Color   := BackRight; // $00FF8080; //background layer color 2
   Brush.Color := BackRight; // $00FF8080; //background layer color 2

   Polygon([
    Point(0 ,5),
    Point(15,0),
    Point(30,5),
    Point(30,Height-6),
    Point(15,Height-11),
    Point(15,10)
   ]);

 { Drawing indicator's second layer }

   Pen.Color   := ForeLeft; // $00823C96; //secondary layer color 1
   Brush.Color := ForeLeft; // $00823C96; //secondary layer color 1

   Polygon([
    Point(0 ,5 +PercentDraw),
    Point(15,10+PercentDraw),
    Point(15,Height-11),
    Point(0 ,Height-6)
   ]);

   Pen.Color   := ForeRight; // $008C42C0; //secondary layer color 2
   Brush.Color := ForeRight; // $008C42C0; //secondary layer color 2

   Polygon([
    Point(15,Height-11),
    Point(15,10+PercentDraw),
    Point(30,5+PercentDraw),
    Point(30,Height-6)
   ]);

   Pen.Color   := ForeTopPen;   // $008060A0; //secondary layer upper pen color
   Brush.Color := ForeTopBrush; // $00A060A0; //secondary layer upper fill color

   Polygon([
    Point(0 ,5 +PercentDraw),
    Point(15,   PercentDraw),
    Point(30,5 +PercentDraw),
    Point(15,10+PercentDraw)
   ]);

   Pen.Color   := ForeBottomPen;   // $0064408C; //secondary layer lower pen color
   Brush.Color := ForeBottomBrush; // $007A408C; //secondary layer lower fill color

   Polygon([
    Point(0 ,Height-6),
    Point(15,Height-11),
    Point(30,Height-6),
    Point(15,Height-1)
   ]);

 { Drawing indicator's layer 3 }

   Pen.Color   := ForeWireframe; // $00FFE0E0; //third layer pen color
   Brush.Color := ForeWireframe; // $00FFE0E0;

   Polyline([
    Point(0,5),
    Point(15,0),
    Point(30,5),
    Point(15,10),
    Point(0,5),
    Point(0,Height-6),
    Point(15,Height-1),
    Point(30,Height-6),
    Point(30,5),
    Point(15,10),
    Point(15,Height-1)
   ]);

 { And the last, but not the least. Drawing percentage text :3 }
   if TextVisible then begin

    Pen.Color   := Skin.FontColor; // $0080005C;
    Brush.Color := BGColor;

    Font.Size  := Skin.FontSize;  // 10;
    Font.Style := Skin.FontStyle; // [fsBold];
    Font.Name  := Skin.FontName;  // 'Tahoma';
    Font.Color := Skin.FontColor; // Pen.Color;

    TextOut(32,PercentDraw-3,PercentText);
   end;

  end;
 end;
end;

end.