unit PercentCube;
{
  AE - VN Tools
  © 2007-2014 WinKiller Studio & The Contributors.
  This software is free. Please see License for details.

  GUI & skin units : RAR-alike percentage cube ^3^
  Visual component version

  Originally written by dsp2003.
  Fixed and converted into component by Proger_XP.
}

{
  How to add a new skin. For example, called "matrix skin":
  * add it to TPercentCubeSkin ("pcsMatrix"),        
  * add its method ("MatrixSkin"),
  * add new skin to SetSkin (like other skins there).

  It's recommended to follow general skin naming rules :)
  
  to-do: it would be nice if somebody added margins for PaintCube drawing
}

interface

uses
  SysUtils, Classes, Controls, Graphics;

type
  // pcsCustom is set when SkinData is modified directly (without using any preset Skin).
  TPercentCubeSkin = (pcsDefault, pcsCustom, pcsIceCube, pcsBubbleGum, pcsGrayscale, pcsMatrix);

  TPercentCubeSkinData = record
    BGColor         : TColor;

    BackLeft        : TColor;
    BackRight       : TColor;

    ForeLeft        : TColor;
    ForeRight       : TColor;

    ForeTopPen      : TColor;
    ForeTopBrush    : TColor;

    ForeBottomPen   : TColor;
    ForeBottomBrush : TColor;

    ForeWireframe   : TColor;

    FontSize        : Integer;
    FontStyle       : TFontStyles;
    FontName        : TFontName;
    FontColor       : TColor;
  end;

  TPercentCube = class (TCustomControl)
  protected
    FMin: Integer;
    FMax: Integer;
    FProgress: Integer;
    FPercentFormat: String;

    FSkin: TPercentCubeSkin;
    FSkinData: TPercentCubeSkinData;
    FShowText: Boolean;
    FDrawAsCube: Boolean;
    FFixedWidth: Boolean;

    procedure Paint; override;
    procedure PaintCube(const Canvas: TCanvas);

    procedure SetMin(const Value: Integer);
    procedure SetMax(const Value: Integer);
    procedure SetProgress(const Value: Integer);
    procedure SetPercentFormat(const Value: String);

    procedure SetSkin(const Value: TPercentCubeSkin);
    procedure SetSkinData(const Value: TPercentCubeSkinData);
    procedure SetShowText(const Value: Boolean);
    procedure SetDrawAsCube(const Value: Boolean);
    procedure SetFixedWidth(const Value: Boolean);

    { Preset skins }
    function DefaultSkin: TPercentCubeSkinData;
    function IceCubeSkin: TPercentCubeSkinData;
    function BubbleGumSkin: TPercentCubeSkinData;
    function GrayscaleSkin: TPercentCubeSkinData;
    function MatrixSkin: TPercentCubeSkinData;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Reset;                                 

    property SkinData: TPercentCubeSkinData read FSkinData write SetSkinData;

    procedure SaveSkinToStream(const Stream: TStream; WriteSignature: Boolean = True);
    procedure LoadSkinFromStream(const Stream: TStream; ReadSignature: Boolean = True);

    procedure SaveSkinToFile(const FileName: String; WriteSignature: Boolean = True);
    procedure LoadSkinFromFile(const FileName: String; ReadSignature: Boolean = True);
  published
    property Min: Integer read FMin write SetMin default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Progress: Integer read FProgress write SetProgress default 0;
    { warning: when changing PercentFormat make sure it contains %f, otherwise it will be reset to default string. }
    property PercentFormat: String read FPercentFormat write SetPercentFormat;

    property Skin: TPercentCubeSkin read FSkin write SetSkin default pcsDefault;
    property ShowText: Boolean read FShowText write SetShowText default True;
    property DrawAsCube: Boolean read FDrawAsCube write SetDrawAsCube default False;
    property FixedWidth: Boolean read FFixedWidth write SetFixedWidth default False;
    
    { Standard properties }
    property Align;
    property Anchors;
    property BoundsRect;
    property Constraints;
    property Visible;

    { Standard events }
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

uses Math;

const
  DefaultPercentFormat = '%.0f%%';
  Sign: PChar = 'TPercentCube skin';

constructor TPercentCube.Create;
begin
  inherited;

  { this effectively removes blinking when drawing complex stuff }
  DoubleBuffered := True;
  ControlStyle := ControlStyle + [csOpaque]; 

  Reset
end;

procedure TPercentCube.Reset;
begin
  FMin := 0;
  FMax := 100;
  FProgress := 0;
  Skin := pcsDefault;
  FPercentFormat := DefaultPercentFormat;
  FDrawAsCube := False;
  FShowText := True;
  FFixedWidth := False
end;

procedure TPercentCube.SetMin;
begin
  FMin := Value;
  Repaint
end;

procedure TPercentCube.SetMax;
begin
  FMax := Value;
  Repaint
end;

procedure TPercentCube.SetProgress;
begin
  FProgress := Value;
  Repaint
end;

procedure TPercentCube.SetPercentFormat;
begin
  if Value <> '' then
  begin
    FPercentFormat := Value;
    Repaint
  end
end;

procedure TPercentCube.SetShowText;
begin
  FShowText := Value;
  Repaint
end;

procedure TPercentCube.SetDrawAsCube;
begin
  FDrawAsCube := Value;
  Repaint
end;

procedure TPercentCube.SetFixedWidth;
begin
  FFixedWidth := Value;
  Repaint
end;

procedure TPercentCube.SetSkin;
begin
  FSkin := Value;

  case Skin of
  pcsCustom: Exit;
  pcsBubbleGum: FSkinData := BubbleGumSkin;
  pcsIceCube: FSkinData := IceCubeSkin;
  pcsGrayscale: FSkinData := GrayscaleSkin;
  pcsMatrix: FSkinData := MatrixSkin
    else
      FSkinData := DefaultSkin
  end;

  Repaint
end;

procedure TPercentCube.SetSkinData;
begin
  FSkinData := Value;
  FSkin := pcsCustom;
  Repaint
end;

procedure TPercentCube.SaveSkinToFile;
var
  S: TFileStream;
begin
  S := TFileStream.Create(FileName, fmCreate);
  try
    SaveSkinToStream(S, WriteSignature)
  finally
    S.Free
  end
end;

procedure TPercentCube.LoadSkinFromFile;
var
  S: TFileStream;
begin
  S := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadSkinFromStream(S, ReadSignature)
  finally
    S.Free
  end
end;    

procedure TPercentCube.SaveSkinToStream;
begin
  if WriteSignature then
    Stream.Write(Sign[0], Length(Sign));
  Stream.Write(FSkinData, SizeOf(FSkinData))
end;

procedure TPercentCube.LoadSkinFromStream;
var
  SignRead: array of Char;
begin
  if ReadSignature then
  begin
    SetLength(SignRead, Length(Sign));
    Stream.Read(SignRead[0], Length(SignRead));
    if String(SignRead) <> Sign then
      raise Exception.CreateFmt('TPercentCube: skin has invalid signature, should be %s but was read: %s', [Sign, String(SignRead)])
  end;
    
  Stream.Read(FSkinData, SizeOf(FSkinData));
  FSkin := pcsCustom;
  Repaint
end;

procedure TPercentCube.Paint;
begin
  PaintCube(Canvas)
end;

procedure TPercentCube.PaintCube;
var
  Percent: Single;
  PercentDraw, Width, Height: Integer;
  PercentText: String;

  function FmtPercent(const Percent: Single): String;
  begin
    Result := Format(FPercentFormat, [Percent])
  end;

begin
  with Canvas, SkinData do
  begin
    if Max - Min <= 0 then
      Percent := 0
      else
        Percent := (Progress - Min) / (Max - Min) * 100;

    try
      PercentText := FmtPercent(Percent)
    except
      FPercentFormat := DefaultPercentFormat;
      PercentText := FmtPercent(Percent)
    end;

    { Drawing background }

    Pen.Color := BGColor;
    Brush.Color := BGColor;

    Rectangle(0, 0, Self.Width, Self.Height);

    { Determining cube dimensions }

    if FShowText then
    begin
      Pen.Color   := FontColor;
      Brush.Color := BGColor;

      Font.Size  := FontSize;
      Font.Style := FontStyle;
      Font.Name  := FontName;
      Font.Color := FontColor;

      Width := Self.Width - TextWidth(FmtPercent(100.0)) - 8
    end
      else
        Width := Self.Width;

    if FFixedWidth then
      Width := 30;

    if not FDrawAsCube then
      Height := Self.Height
      else
        if Width > Self.Height then
        begin
          Height := Self.Height;
          Width := Height
        end
          else
            Height := Width;

    PercentDraw := Height - 11 - Round(((Height - 11) / 100) * Percent);

    { Drawing percentage text }
    if FShowText then
      TextOut(Width + 4, Math.Min(Height - TextHeight(PercentText), PercentDraw - 3), PercentText);

    { Drawing indicator's first layer }

    Pen.Color   := BackLeft; // $00E06868; //background layer color 1
    Brush.Color := BackLeft; // $00E06868; //background layer color 1

    Polygon([
      Point(0, 5),
      Point(Width div 2, 10),
      Point(Width div 2, Height - 11),
      Point(0, Height - 6)
    ]);

    Pen.Color   := BackRight; // $00FF8080; //background layer color 2
    Brush.Color := BackRight; // $00FF8080; //background layer color 2

    Polygon([
      Point(0, 5),
      Point(Width div 2, 0),
      Point(Width, 5),
      Point(Width, Height - 6),
      Point(Width div 2, Height - 11),
      Point(Width div 2, 10)
    ]);

    { Drawing indicator's second layer }

    Pen.Color   := ForeLeft; // $00823C96; //secondary layer color 1
    Brush.Color := ForeLeft; // $00823C96; //secondary layer color 1

    Polygon([
      Point(0, 5  + PercentDraw),
      Point(Width div 2, 10 + PercentDraw),
      Point(Width div 2, Height - 11),
      Point(0, Height - 6)
    ]);

    Pen.Color   := ForeRight; // $008C42C0; //secondary layer color 2
    Brush.Color := ForeRight; // $008C42C0; //secondary layer color 2

    Polygon([
      Point(Width div 2, Height - 11),
      Point(Width div 2, 10 + PercentDraw),
      Point(Width, 5 + PercentDraw),
      Point(Width, Height - 6)
    ]);

    Pen.Color   := ForeTopPen;   // $008060A0; //secondary layer upper pen color
    Brush.Color := ForeTopBrush; // $00A060A0; //secondary layer upper fill color

    Polygon([
      Point(0, 5  + PercentDraw),
      Point(Width div 2,      PercentDraw),
      Point(Width, 5  + PercentDraw),
      Point(Width div 2, 10 + PercentDraw)
    ]);

    Pen.Color   := ForeBottomPen;   // $0064408C; //secondary layer lower pen color
    Brush.Color := ForeBottomBrush; // $007A408C; //secondary layer lower fill color

    Polygon([
      Point(0, Height - 6),
      Point(Width div 2, Height - 11),
      Point(Width, Height - 6),
      Point(Width div 2, Height - 1)
    ]);

    { Drawing indicator's layer 3 }

    Pen.Color   := ForeWireframe; // $00FFE0E0; //third layer pen color
    Brush.Color := ForeWireframe; // $00FFE0E0;

    Polyline([
      Point(0, 5),
      Point(Width div 2, 0),
      Point(Width, 5),
      Point(Width div 2, 10),
      Point(0, 5),
      Point(0, Height - 6),
      Point(Width div 2, Height - 1),
      Point(Width, Height - 6),
      Point(Width, 5),
      Point(Width div 2, 10),
      Point(Width div 2, Height - 1)
    ])
  end
end;


{ Preset skins }      

function TPercentCube.DefaultSkin;
begin
  with Result do 
  begin
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

    FontColor      := $0080005C;
    FontName       := 'Tahoma';
    FontStyle      := [fsBold];
    FontSize       := 10
  end
end;

function TPercentCube.IceCube;
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
 end;
end;

function TPercentCube.BubbleGumSkin;
begin
  with Result do
  begin
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

    FontColor      := $0080005C;
    FontName       := 'Tahoma';
    FontStyle      := [fsBold];
    FontSize       := 10
  end
end;

function TPercentCube.GrayscaleSkin;
begin
  with Result do
  begin
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

    FontColor      := $000E0E0E;
    FontName       := 'Tahoma';
    FontStyle      := [fsBold];
    FontSize       := 10
  end
end;                        

function TPercentCube.MatrixSkin;
begin
  with Result do
  begin
    BGColor         := clBlack;

    BackLeft        := $003300;
    BackRight       := $003300;

    ForeLeft        := clGreen;
    ForeRight       := clGreen;

    ForeTopPen      := $00CC00;
    ForeTopBrush    := $00CC00;

    ForeBottomPen   := clLime;
    ForeBottomBrush := $00CC00;

    ForeWireframe   := clLime;

    FontColor      := clRed;
    FontName       := 'Courier New';
    FontStyle      := [fsBold];
    FontSize       := 9
  end
end;


procedure Register;
begin
  RegisterComponents('Miscellaneous', [TPercentCube]);
end;

end.
