{*******************************************************}
{                                                       }
{       Borland Delphi Visual Component Library         }
{                                                       }
{  Copyright (c) 1995-2001 Borland Software Corporation }
{                                                       }
{*******************************************************}
{  Fix for icon masking by dsp2003. For Delphi 7 only.  }
{*******************************************************}

unit ImgList;

{$R-,T-,H+,X+}

interface

uses Windows, Classes, Graphics, CommCtrl;

type

{ TChangeLink }

  TCustomImageList = class;

  TChangeLink = class(TObject)
  private
    FSender: TCustomImageList;
    FOnChange: TNotifyEvent;
  public
    destructor Destroy; override;
    procedure Change; dynamic;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Sender: TCustomImageList read FSender write FSender;
  end;

{ TCustomImageList }

  TDrawingStyle = (dsFocus, dsSelected, dsNormal, dsTransparent);
  TImageType = (itImage, itMask);
  TResType = (rtBitmap, rtCursor, rtIcon);
  TOverlay = 0..3;
  TLoadResource = (lrDefaultColor, lrDefaultSize, lrFromFile,
    lrMap3DColors, lrTransparent, lrMonoChrome);
  TLoadResources = set of TLoadResource;
  TImageIndex = type Integer;

  TCustomImageList = class(TComponent)
  private
    FHeight: Integer;
    FWidth: Integer;
    FAllocBy: Integer;
    FHandle: HImageList;
    FDrawingStyle: TDrawingStyle;
    FMasked: Boolean;
    FShareImages: Boolean;
    FImageType: TImageType;
    FBkColor: TColor;
    FBlendColor: TColor;
    FClients: TList;
    FBitmap: TBitmap;
    FMonoBitmap: TBitmap;
    FChanged: Boolean;
    FUpdateCount: Integer;
    FOnChange: TNotifyEvent;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure InitBitmap;
    procedure CheckImage(Image: TGraphic);
    procedure CopyImages(Value: HImageList; Index: Integer = -1);
    procedure CreateImageList;
    function Equal(IL: TCustomImageList): Boolean;
    procedure FreeHandle;
    function GetCount: Integer;
    function GetBitmapHandle(Bitmap: HBITMAP): HBITMAP;
    function GetBkColor: TColor;
    function GetHandle: HImageList;
    function GetImageHandle(Image, ImageDDB: TBitmap): HBITMAP;
    procedure InsertImage(Index: Integer; Image, Mask: TBitmap; MaskColor: TColor);
    function InternalGetInstRes(Instance: THandle; ResType: TResType;
      Name: PChar; Width: Integer; LoadFlags: TLoadResources;
      MaskColor: TColor): Boolean;
    procedure SetBkColor(Value: TColor);
    procedure SetDrawingStyle(Value: TDrawingStyle);
    procedure SetHandle(Value: HImageList);
    procedure SetHeight(Value: Integer);
    procedure SetNewDimensions(Value: HImageList);
    procedure SetWidth(Value: Integer);
    procedure ReadD2Stream(Stream: TStream);
    procedure ReadD3Stream(Stream: TStream);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    procedure Change; dynamic;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
      Style: Cardinal; Enabled: Boolean = True); virtual;
    procedure GetImages(Index: Integer; Image, Mask: TBitmap);
    procedure HandleNeeded;
    procedure Initialize; virtual;
    procedure ReadData(Stream: TStream); virtual;
    procedure WriteData(Stream: TStream); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateSize(AWidth, AHeight: Integer);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add(Image, Mask: TBitmap): Integer;
    function AddIcon(Image: TIcon): Integer;
    function AddImage(Value: TCustomImageList; Index: Integer): Integer;
    procedure AddImages(Value: TCustomImageList);
    function AddMasked(Image: TBitmap; MaskColor: TColor): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Draw(Canvas: TCanvas; X, Y, Index: Integer;
      Enabled: Boolean = True); overload;
    procedure Draw(Canvas: TCanvas; X, Y, Index: Integer;
      ADrawingStyle: TDrawingStyle; AImageType: TImageType;
      Enabled: Boolean = True); overload;
    procedure DrawOverlay(Canvas: TCanvas; X, Y: Integer;
      ImageIndex: Integer; Overlay: TOverlay; Enabled: Boolean = True); overload;
    procedure DrawOverlay(Canvas: TCanvas; X, Y: Integer;
      ImageIndex: Integer; Overlay: TOverlay; ADrawingStyle: TDrawingStyle;
      AImageType: TImageType; Enabled: Boolean = True); overload;
    function FileLoad(ResType: TResType; const Name: string;
      MaskColor: TColor): Boolean;
    function GetBitmap(Index: Integer; Image: TBitmap): Boolean;
    function GetHotSpot: TPoint; virtual;
    procedure GetIcon(Index: Integer; Image: TIcon); overload;
    procedure GetIcon(Index: Integer; Image: TIcon; ADrawingStyle: TDrawingStyle;
      AImageType: TImageType); overload;
    function GetImageBitmap: HBITMAP;
    function GetMaskBitmap: HBITMAP;
    function GetResource(ResType: TResType; const Name: string;
      Width: Integer; LoadFlags: TLoadResources; MaskColor: TColor): Boolean;
    function GetInstRes(Instance: THandle; ResType: TResType; const Name: string;
      Width: Integer; LoadFlags: TLoadResources; MaskColor: TColor): Boolean; overload;
    function GetInstRes(Instance: THandle; ResType: TResType; ResID: DWORD;
      Width: Integer; LoadFlags: TLoadResources; MaskColor: TColor): Boolean; overload;
    function HandleAllocated: Boolean;
    procedure Insert(Index: Integer; Image, Mask: TBitmap);
    procedure InsertIcon(Index: Integer; Image: TIcon);
    procedure InsertMasked(Index: Integer; Image: TBitmap; MaskColor: TColor);
    procedure Move(CurIndex, NewIndex: Integer);
    function Overlay(ImageIndex: Integer; Overlay: TOverlay): Boolean;
    procedure RegisterChanges(Value: TChangeLink);
    function ResourceLoad(ResType: TResType; const Name: string;
      MaskColor: TColor): Boolean;
    function ResInstLoad(Instance: THandle; ResType: TResType;
      const Name: string; MaskColor: TColor): Boolean;
    procedure Replace(Index: Integer; Image, Mask: TBitmap);
    procedure ReplaceIcon(Index: Integer; Image: TIcon);
    procedure ReplaceMasked(Index: Integer; NewImage: TBitmap; MaskColor: TColor);
    procedure UnRegisterChanges(Value: TChangeLink);
    property Count: Integer read GetCount;
    property Handle: HImageList read GetHandle write SetHandle;
  public
    property AllocBy: Integer read FAllocBy write FAllocBy default 4;
    property BlendColor: TColor read FBlendColor write FBlendColor default clNone;
    property BkColor: TColor read GetBkColor write SetBkColor default clNone;
    property DrawingStyle: TDrawingStyle read FDrawingStyle write SetDrawingStyle default dsNormal;
    property Height: Integer read FHeight write SetHeight default 16;
    property ImageType: TImageType read FImageType write FImageType default itImage;
    property Masked: Boolean read FMasked write FMasked default True;
    property ShareImages: Boolean read FShareImages write FShareImages default False;
    property Width: Integer read FWidth write SetWidth default 16;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses
  SysUtils, Consts, Forms, ActiveX;

{ TCustomImageList }

const
  DrawingStyles: array[TDrawingStyle] of Longint = (ILD_FOCUS, ILD_SELECTED,
    ILD_NORMAL, ILD_TRANSPARENT);
  Images: array[TImageType] of Longint = (0, ILD_MASK);
  
function GetRGBColor(Value: TColor): DWORD;
begin
  Result := ColorToRGB(Value);
  case Result of
    clNone: Result := CLR_NONE;
    clDefault: Result := CLR_DEFAULT;
  end;
end;

function GetColor(Value: DWORD): TColor;
begin
  case Value of
    CLR_NONE: Result := clNone;
    CLR_DEFAULT: Result := clDefault;
  else
    Result := TColor(Value);
  end;
end;

constructor TCustomImageList.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWidth := 16;
  FHeight := 16;
  Initialize;
end;

constructor TCustomImageList.CreateSize(AWidth, AHeight: Integer);
begin
  inherited Create(nil);
  FWidth := AWidth;
  FHeight := AHeight;
  Initialize;
end;

destructor TCustomImageList.Destroy;
begin
  while FClients.Count > 0 do
    UnRegisterChanges(TChangeLink(FClients.Last));
  FBitmap.Free;
  FreeHandle;
  FClients.Free;
  FClients := nil;
  if FMonoBitmap <> nil then FMonoBitmap.Free;
  inherited Destroy;
end;

procedure TCustomImageList.Initialize;
const
  MaxSize = 32768;
begin
  FClients := TList.Create;
  if (Height < 1) or (Height > MaxSize) or (Width < 1) then
    raise EInvalidOperation.Create(SInvalidImageSize);
  AllocBy := 4;
  Masked := True;
  DrawingStyle := dsNormal;
  ImageType := itImage;
  FBkColor := clNone;
  FBlendColor := clNone;
  FBitmap := TBitmap.Create;
  InitBitmap;
end;

function TCustomImageList.HandleAllocated: Boolean;
begin
  Result := FHandle <> 0;
end;

procedure TCustomImageList.HandleNeeded;
begin
  if FHandle = 0 then CreateImageList;
end;

procedure TCustomImageList.InitBitmap;
var
  ScreenDC: HDC;
begin
  ScreenDC := GetDC(0);
  try
    with FBitmap do
    begin
      Handle := CreateCompatibleBitmap(ScreenDC, Self.Width, Self.Height);
      Canvas.Brush.Color := clBlack;
      Canvas.FillRect(Rect(0, 0, Width, Height));
    end;
  finally
    ReleaseDC(0, ScreenDC);
  end;
  if FMonoBitmap <> nil then
  begin
    FMonoBitmap.Free;
    FMonoBitmap := nil;
  end;
end;

procedure TCustomImageList.SetNewDimensions(Value: HImageList);
var
  AHeight, AWidth: Integer;
begin
  AWidth := Width;
  AHeight := Height;
  ImageList_GetIconSize(Value, AWidth, AHeight);
  FWidth := AWidth;
  FHeight := AHeight;
  InitBitmap;
end;

procedure TCustomImageList.SetWidth(Value: Integer);
begin
  if Value <> Width then
  begin
    FWidth := Value;
    if HandleAllocated then ImageList_SetIconSize(FHandle, Width, Height);
    Clear;
    InitBitmap;
    Change;
  end;
end;

procedure TCustomImageList.SetHeight(Value: Integer);
begin
  if Value <> Height then
  begin
    FHeight := Value;
    if HandleAllocated then ImageList_SetIconSize(FHandle, Width, Height);
    Clear;
    InitBitmap;
    Change;
  end;
end;

procedure TCustomImageList.SetHandle(Value: HImageList);
begin
  FreeHandle;
  if Value <> 0 then
  begin
    SetNewDimensions(Value);
    FHandle := Value;
    Change;
  end;
end;

function TCustomImageList.GetBitmapHandle(Bitmap: HBITMAP): HBITMAP;
begin
  if Bitmap <> 0 then
    Result := Bitmap else
    Result := FBitmap.Handle;
end;

function TCustomImageList.GetHandle: HImageList;
begin
  HandleNeeded;
  Result := FHandle;
end;

function TCustomImageList.GetImageHandle(Image, ImageDDB: TBitmap): HBITMAP;
begin
  CheckImage(Image);
  if Image <> nil then
    if Image.HandleType = bmDDB then
      Result := Image.Handle
    else
    begin
      ImageDDB.Assign(Image);
      ImageDDB.HandleType := bmDDB;
      Result := ImageDDB.Handle;
    end
  else Result := FBitmap.Handle;
end;

procedure TCustomImageList.FreeHandle;
begin
  if HandleAllocated and not ShareImages then
    ImageList_Destroy(Handle);
  FHandle := 0;
  Change;
end;

procedure TCustomImageList.CreateImageList;
const
  Mask: array[Boolean] of Longint = (0, ILC_MASK);
begin
  FHandle := ImageList_Create(Width, Height, ILC_COLORDDB or Mask[Masked],
    AllocBy, AllocBy);
  if not HandleAllocated then raise EInvalidOperation.Create(SInvalidImageList);
  if FBkColor <> clNone then BkColor := FBkColor;
end;

function TCustomImageList.GetImageBitmap: HBITMAP;
var
  Info: TImageInfo;
begin
  if (Count > 0) and ImageList_GetImageInfo(Handle, 0, Info) then
  begin
    Result := Info.hbmImage;
    DeleteObject(Info.hbmMask);
  end
  else Result := 0;
end;

function TCustomImageList.GetMaskBitmap: HBITMAP;
var
  Info: TImageInfo;
begin
  if (Count > 0) and ImageList_GetImageInfo(Handle, 0, Info) then
  begin
    Result := Info.hbmMask;
    DeleteObject(Info.hbmImage);
  end
  else Result := 0;
end;

function TCustomImageList.Add(Image, Mask: TBitmap): Integer;
var
  ImageDDB, MaskDDB: TBitmap;
begin
  ImageDDB := TBitmap.Create;
  try
    MaskDDB := TBitmap.Create;
    try
      HandleNeeded;
      Result := ImageList_Add(FHandle, GetImageHandle(Image, ImageDDB),
        GetImageHandle(Mask, MaskDDB));
    finally
      MaskDDB.Free;
    end;
  finally
    ImageDDB.Free;
  end;
  Change;
end;

function TCustomImageList.AddMasked(Image: TBitmap; MaskColor: TColor): Integer;
var
  ImageDDB: TBitmap;
begin
  ImageDDB := TBitmap.Create;
  try
    if Masked and (MaskColor <> -1) then
    begin
      with TBitmap.Create do
      try
        Assign(Image);
        TransparentColor := MaskColor;
        Self.HandleNeeded;
        Result := ImageList_Add(Self.FHandle, GetImageHandle(Image, ImageDDB),
          GetBitmapHandle(MaskHandle));
      finally
        Free;
      end;
    end
    else Result := ImageList_Add(Handle, GetImageHandle(Image, ImageDDB), 0);
  finally
    ImageDDB.Free;
  end;
  Change;
end;

function TCustomImageList.AddIcon(Image: TIcon): Integer;
begin
  if Image = nil then
    Result := Add(nil, nil)
  else
  begin
    CheckImage(Image);
    Result := ImageList_AddIcon(Handle, Image.Handle);
  end;
  Change;
end;

function TCustomImageList.GetBitmap(Index: Integer; Image: TBitmap): Boolean;
begin
  Result := (Image <> nil) and HandleAllocated and (Index > -1) and (Index < Count);
  if Result then
    with Image do
    begin
      Height := FHeight;
      Width := FWidth;
      Draw(Canvas, 0, 0, Index);
    end;
end;

procedure TCustomImageList.GetIcon(Index: Integer; Image: TIcon);
begin
  GetIcon(Index, Image, DrawingStyle, ImageType);
end;

procedure TCustomImageList.GetIcon(Index: Integer; Image: TIcon;
  ADrawingStyle: TDrawingStyle; AImageType: TImageType);
begin
  if (Image <> nil) and HandleAllocated then
    Image.Handle := ImageList_GetIcon(Handle, Index,
      DrawingStyles[ADrawingStyle] or Images[AImageType]);
end;

function TCustomImageList.GetCount: Integer;
begin
  if HandleAllocated then Result := ImageList_GetImageCount(Handle)
  else Result := 0;
end;

procedure TCustomImageList.Replace(Index: Integer; Image, Mask: TBitmap);
var
  ImageDDB, MaskDDB: TBitmap;
begin
  ImageDDB := TBitmap.Create;
  try
    MaskDDB := TBitmap.Create;
    try
      if HandleAllocated and not ImageList_Replace(Handle, Index,
        GetImageHandle(Image, ImageDDB), GetImageHandle(Mask, MaskDDB)) then
          raise EInvalidOperation.Create(SReplaceImage);
    finally
      MaskDDB.Free;
    end;
  finally
    ImageDDB.Free;
  end;
  Change;
end;

procedure TCustomImageList.ReplaceMasked(Index: Integer; NewImage: TBitmap; MaskColor: TColor);
var
  TempIndex: Integer;
  Image, Mask: TBitmap;
begin
  if HandleAllocated then
  begin
    CheckImage(NewImage);
    TempIndex := AddMasked(NewImage, MaskColor);
    if TempIndex <> -1 then
    try
      Image := TBitmap.Create;
      try
        with Image do
        begin
          Height := FHeight;
          Width := FWidth;
        end;
        Mask := TBitmap.Create;
        try
          with Mask do
          begin
            Monochrome := True;
            Height := FHeight;
            Width := FWidth;
          end;
          ImageList_Draw(Handle, TempIndex, Image.Canvas.Handle, 0, 0, ILD_NORMAL);
          ImageList_Draw(Handle, TempIndex, Mask.Canvas.Handle, 0, 0, ILD_MASK);
          if not ImageList_Replace(Handle, Index, Image.Handle, Mask.Handle) then
            raise EInvalidOperation.Create(SReplaceImage);
        finally
          Mask.Free;
        end;
      finally
        Image.Free;
      end;
    finally
      Delete(TempIndex);
    end
    else raise EInvalidOperation.Create(SReplaceImage);
  end;
  Change;
end;

procedure TCustomImageList.ReplaceIcon(Index: Integer; Image: TIcon);
begin
  if HandleAllocated then
    if Image = nil then Replace(Index, nil, nil)
    else begin
      CheckImage(Image);
      if ImageList_ReplaceIcon(Handle, Index, Image.Handle) = -1 then
        raise EInvalidOperation.Create(SReplaceImage);
    end;
  Change;
end;

procedure TCustomImageList.Delete(Index: Integer);
begin
  if Index >= Count then raise EInvalidOperation.Create(SImageIndexError);
  if HandleAllocated then ImageList_Remove(Handle, Index);
  Change;
end;

procedure TCustomImageList.Clear;
begin
  Delete(-1);
end;

procedure TCustomImageList.SetBkColor(Value: TColor);
begin
  if HandleAllocated then ImageList_SetBkColor(FHandle, GetRGBColor(Value))
  else FBkColor := Value;                   
  Change;
end;

function TCustomImageList.GetBkColor: TColor;
begin
  if HandleAllocated then Result := GetColor(ImageList_GetBkColor(Handle))
  else Result := FBkColor;
end;

procedure TCustomImageList.DoDraw(Index: Integer; Canvas: TCanvas; X, Y: Integer;
  Style: Cardinal; Enabled: Boolean);

// FIX!
  procedure ScrambleBitmap(var BMP: TBitmap);
  const
    RMask = $0000FF;
    RAMask = $FFFF00;
    GMask = $00FF00;
    GAMask = $FF00FF;
    BMask = $FF0000;
    BAMask = $00FFFF;
  var
    R, C: integer;
    Color: LongWord;
  begin
    with Bmp.Canvas do
    begin
      for C := 0 to Bmp.Height - 1 do
        for R := 0 to Bmp.Width - 1 do
        begin
          Color := Pixels[R, C];
          if ((Color = 0) or (Color = $FFFFFF)) then
            Continue;
          if (((Color and RMask > $7F) and (Color and RAMask > $0)) or
            ((Color and GMask > $7F00) and (Color and GAMask > $0)) or
            ((Color and BMask > $7F000) and (Color and BAMask > $0))) then
            Pixels[R, C] := $FFFFFF
          else
            Pixels[R, C] := 0;
        end;
    end;
  end;
// END OF FIX!

const
  ROP_DSPDxax = $00E20746;
var
  R: TRect;
  DestDC, SrcDC: HDC;
begin
  if HandleAllocated then
  begin
    if Enabled then
      ImageList_DrawEx(Handle, Index, Canvas.Handle, X, Y, 0, 0,
        GetRGBColor(BkColor), GetRGBColor(BlendColor), Style)
    else
    begin
      if FMonoBitmap = nil then
      begin
        FMonoBitmap := TBitmap.Create;
        with FMonoBitmap do
        begin
          // Monochrome := True; // FIX!
          Width := Self.Width;
          Height := Self.Height;
        end;
      end;
      { Store masked version of image temporarily in FBitmap }
      FMonoBitmap.Canvas.Brush.Color := clWhite;
      FMonoBitmap.Canvas.FillRect(Rect(0, 0, Self.Width, Self.Height));
      ImageList_DrawEx(Handle, Index, FMonoBitmap.Canvas.Handle, 0,0,0,0,
        CLR_NONE, 0, ILD_NORMAL);
      ScrambleBitmap(FMonoBitmap); // FIX!
      R := Rect(X, Y, X+Width, Y+Height);
      SrcDC := FMonoBitmap.Canvas.Handle;
      BitBlt(SrcDC, 0, 0, Width, Height, SrcDC, 0, 0, DSTINVERT); // FIX!
      { Convert Black to clBtnHighlight }
      Canvas.Brush.Color := clBtnHighlight;
      DestDC := Canvas.Handle;
      Windows.SetTextColor(DestDC, clWhite);
      Windows.SetBkColor(DestDC, clBlack);
      BitBlt(DestDC, X+1, Y+1, Width, Height, SrcDC, 0, 0, ROP_DSPDxax);
      { Convert Black to clBtnShadow }
      Canvas.Brush.Color := clBtnShadow;
      DestDC := Canvas.Handle;
      Windows.SetTextColor(DestDC, clWhite);
      Windows.SetBkColor(DestDC, clBlack);
      BitBlt(DestDC, X, Y, Width, Height, SrcDC, 0, 0, ROP_DSPDxax);
    end;
  end;
end;

procedure TCustomImageList.Draw(Canvas: TCanvas; X, Y, Index: Integer;
  Enabled: Boolean);
begin
  Draw(Canvas, X, Y, Index, DrawingStyle, ImageType, Enabled);
end;

procedure TCustomImageList.Draw(Canvas: TCanvas; X, Y, Index: Integer;
  ADrawingStyle: TDrawingStyle; AImageType: TImageType; Enabled: Boolean);
begin
  if HandleAllocated then
    DoDraw(Index, Canvas, X, Y, DrawingStyles[ADrawingStyle] or
      Images[AImageType], Enabled);
end;

procedure TCustomImageList.DrawOverlay(Canvas: TCanvas; X, Y: Integer;
  ImageIndex: Integer; Overlay: TOverlay; Enabled: Boolean);
begin
  DrawOverlay(Canvas, X, Y, ImageIndex, Overlay, dsNormal, itImage, Enabled);
end;

procedure TCustomImageList.DrawOverlay(Canvas: TCanvas; X, Y: Integer;
  ImageIndex: Integer; Overlay: TOverlay; ADrawingStyle: TDrawingStyle;
  AImageType: TImageType; Enabled: Boolean);
var
  Index: Integer;
begin
  if HandleAllocated then
  begin
    Index := IndexToOverlayMask(Overlay + 1);
    DoDraw(ImageIndex, Canvas, X, Y, DrawingStyles[ADrawingStyle] or
      Images[AImageType] or ILD_OVERLAYMASK and Index, Enabled);
  end;
end;

function TCustomImageList.Overlay(ImageIndex: Integer; Overlay: TOverlay): Boolean;
begin
  if HandleAllocated then
    Result := ImageList_SetOverlayImage(Handle, ImageIndex, Overlay + 1)
  else Result := False;
end;

procedure TCustomImageList.CopyImages(Value: HImageList; Index: Integer = -1);
var
  I: Integer;
  Image, Mask: TBitmap;
  ARect: TRect;
begin
  ARect := Rect(0, 0, Width, Height);
  BeginUpdate;
  try
    Image := TBitmap.Create;
    try
      with Image do
      begin
        Height := FHeight;
        Width := FWidth;
      end;
      Mask := TBitmap.Create;
      try
        with Mask do
        begin
          Monochrome := True;
          Height := FHeight;
          Width := FWidth;
        end;
        for I := 0 to ImageList_GetImageCount(Value) - 1 do
          if (Index = -1) or (Index = I) then
          begin
            with Image.Canvas do
            begin
              FillRect(ARect);
              ImageList_Draw(Value, I, Handle, 0, 0, ILD_NORMAL);
            end;
            with Mask.Canvas do
            begin
              FillRect(ARect);
              ImageList_Draw(Value, I, Handle, 0, 0, ILD_MASK);
            end;
            Add(Image, Mask);
          end;
      finally
        Mask.Free;
      end;
    finally
      Image.Free;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TCustomImageList.GetImages(Index: Integer; Image, Mask: TBitmap);
var
  R: TRect;
begin
  R := Rect(0, 0, Width, Height);
  with Image.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(R);
    ImageList_Draw(Self.Handle, Index, Handle, 0, 0, ILD_NORMAL);
  end;
  with Mask.Canvas do
  begin
    Brush.Color := clWhite;
    FillRect(R);
    ImageList_Draw(Self.Handle, Index, Handle, 0, 0, ILD_MASK);
  end;
end;

procedure TCustomImageList.InsertImage(Index: Integer; Image, Mask: TBitmap;
  MaskColor: TColor);
var
  I: Integer;
  OldImage, OldMask: TBitmap;
  TempList: TCustomImageList;
begin
  BeginUpdate;
  try
    OldImage := TBitmap.Create;
    try
      with OldImage do
      begin
        Height := FHeight;
        Width := FWidth;
      end;
      OldMask := TBitmap.Create;
      try
        with OldMask do
        begin
          Monochrome := True;
          Height := FHeight;
          Width := FWidth;
        end;
        TempList := TCustomImageList.CreateSize(5, 5);
        try
          TempList.Assign(Self);
          Clear;
          if Index > TempList.Count then
            raise EInvalidOperation.Create(SImageIndexError);
          for I := 0 to Index - 1 do
          begin
            TempList.GetImages(I, OldImage, OldMask);
            Add(OldImage, OldMask);
          end;
          if MaskColor <> -1 then
            AddMasked(Image, MaskColor) else
            Add(Image, Mask);
          for I := Index to TempList.Count - 1 do
          begin
            TempList.GetImages(I, OldImage, OldMask);
            Add(OldImage, OldMask);
          end;
        finally
          TempList.Free;
        end;
      finally
        OldMask.Free;
      end;
    finally
      OldImage.Free;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TCustomImageList.Insert(Index: Integer; Image, Mask: TBitmap);
begin
  InsertImage(Index, Image, Mask, -1);
end;

procedure TCustomImageList.InsertMasked(Index: Integer; Image: TBitmap;
  MaskColor: TColor);
begin
  InsertImage(Index, Image, nil, MaskColor);
end;

procedure TCustomImageList.InsertIcon(Index: Integer; Image: TIcon);
var
  I: Integer;
  TempList: TCustomImageList;
  Icon: TIcon;
begin
  Icon := nil;
  TempList := nil;
  BeginUpdate;
  try
    TempList := TCustomImageList.CreateSize(5, 5);
    TempList.Assign(Self);
    Clear;
    if Index > TempList.Count then raise EInvalidOperation.Create(SImageIndexError);
    Icon := TIcon.Create;
    for I := 0 to Index - 1 do
    begin
      TempList.GetIcon(I, Icon);
      AddIcon(Icon);
    end;
    AddIcon(Image);
    for I := Index to TempList.Count - 1 do
    begin
      TempList.GetIcon(I, Icon);
      AddIcon(Icon);
    end;
  finally
    EndUpdate;
    Icon.Free;
    TempList.Free;
  end;
end;

procedure TCustomImageList.Move(CurIndex, NewIndex: Integer);
var
  Image, Mask: TBitmap;
begin
  if CurIndex <> NewIndex then
  begin
    Image := TBitmap.Create;
    try
      with Image do
      begin
        Height := FHeight;
        Width := FWidth;
      end;
      Mask := TBitmap.Create;
      try
        with Mask do
        begin
          Height := FHeight;
          Width := FWidth;
        end;
        GetImages(CurIndex, Image, Mask);
        Delete(CurIndex);
        Insert(NewIndex, Image, Mask);
      finally
        Mask.Free;
      end;
    finally
      Image.Free;
    end;
  end;
end;

function TCustomImageList.AddImage(Value: TCustomImageList; Index: Integer): Integer;
begin
  if Value <> nil then
  begin
    Result := Count;
    CopyImages(Value.Handle, Index);
  end else
    Result := -1;
end;

procedure TCustomImageList.AddImages(Value: TCustomImageList);
begin
  if Value <> nil then CopyImages(Value.Handle);
end;

procedure TCustomImageList.Assign(Source: TPersistent);
var
  ImageList: TCustomImageList;
begin
  if Source = nil then FreeHandle
  else if Source is TCustomImageList then
  begin
    Clear;
    ImageList := TCustomImageList(Source);
    Masked := ImageList.Masked;
    ImageType := ImageList.ImageType;
    DrawingStyle := ImageList.DrawingStyle;
    ShareImages := ImageList.ShareImages;
    SetNewDimensions(ImageList.Handle);
    if not HandleAllocated then HandleNeeded
    else ImageList_SetIconSize(Handle, Width, Height);
    BkColor := GetColor(ImageList_GetBkColor(ImageList.Handle));
    BlendColor := ImageList.BlendColor;
    AddImages(ImageList);
  end
  else inherited Assign(Source);
end;

procedure TCustomImageList.AssignTo(Dest: TPersistent);
var
  ImageList: TCustomImageList;
begin
  if Dest is TCustomImageList then
  begin
    ImageList := TCustomImageList(Dest);
    ImageList.Masked := Masked;
    ImageList.ImageType := ImageType;
    ImageList.DrawingStyle := DrawingStyle;
    ImageList.ShareImages := ShareImages;
    ImageList.BlendColor := BlendColor;
    with ImageList do
    begin
      Clear;
      SetNewDimensions(Self.Handle);
      if not HandleAllocated then HandleNeeded
      else ImageList_SetIconSize(Handle, Width, Height);
      BkColor := GetColor(ImageList_GetBkColor(Self.Handle));
      AddImages(Self);
    end;
  end
  else inherited AssignTo(Dest);
end;

procedure TCustomImageList.CheckImage(Image: TGraphic);
begin
  if Image <> nil then
    with Image do
      if (Height < FHeight) or (Width < FWidth) then
        raise EInvalidOperation.Create(SInvalidImageSize);
end;

procedure TCustomImageList.SetDrawingStyle(Value: TDrawingStyle);
begin
  if Value <> DrawingStyle then
  begin
    FDrawingStyle := Value;
    Change;
  end;
end;

function TCustomImageList.GetHotSpot: TPoint;
begin
  Result := Point(0, 0);
end;

function TCustomImageList.GetInstRes(Instance: THandle; ResType: TResType;
  ResID: DWORD; Width: Integer; LoadFlags: TLoadResources;
  MaskColor: TColor): Boolean;
begin
  Result := InternalGetInstRes(Instance, ResType, PChar(ResID), Width,
    LoadFlags, MaskColor);
end;

function TCustomImageList.GetInstRes(Instance: THandle; ResType: TResType;
  const Name: string; Width: Integer; LoadFlags: TLoadResources;
  MaskColor: TColor): Boolean;
begin
  Result := InternalGetInstRes(Instance, ResType, PChar(Name), Width,
    LoadFlags, MaskColor);
end;

function TCustomImageList.InternalGetInstRes(Instance: THandle;
  ResType: TResType; Name: PChar; Width: Integer; LoadFlags: TLoadResources;
  MaskColor: TColor): Boolean;
const
  ResMap: array [TResType] of Integer = (IMAGE_BITMAP, IMAGE_CURSOR, IMAGE_ICON);
var
  hImage: HImageList;
  Flags: Integer;
begin
  Flags := 0;
  if lrDefaultColor in LoadFlags then Flags := Flags or LR_DEFAULTCOLOR;
  if lrDefaultSize in LoadFlags then Flags := Flags or LR_DEFAULTSIZE;
  if lrFromFile in LoadFlags then Flags := Flags or LR_LOADFROMFILE;
  if lrMap3DColors in LoadFlags then Flags := Flags or LR_LOADMAP3DCOLORS;
  if lrTransparent in LoadFlags then Flags := Flags or LR_LOADTRANSPARENT;
  if lrMonoChrome in LoadFlags then Flags := Flags or LR_MONOCHROME;
  hImage := ImageList_LoadImage(Instance, Name, Width, AllocBy, MaskColor,
    ResMap[ResType], Flags);
  if hImage <> 0 then
  begin
    CopyImages(hImage);
    ImageList_Destroy(hImage);
    Result := True;
  end
  else Result := False;
end;

function TCustomImageList.GetResource(ResType: TResType; const Name: string;
  Width: Integer; LoadFlags: TLoadResources; MaskColor: TColor): Boolean;
begin
  Result := GetInstRes(MainInstance, ResType, Name, Width, LoadFlags, MaskColor);
end;

function TCustomImageList.ResInstLoad(Instance: THandle; ResType: TResType;
  const Name: string; MaskColor: TColor): Boolean;
begin
  Result := GetInstRes(Instance, ResType, Name, Width, [], MaskColor);
end;

function TCustomImageList.ResourceLoad(ResType: TResType; const Name: string;
  MaskColor: TColor): Boolean;
var
  LibModule: PLibModule;
begin
  Result := False;
  if HInstance = MainInstance then
    Result := GetInstRes(MainInstance, ResType, Name, Width, [], MaskColor)
  else
  begin
    LibModule := LibModuleList;
    while LibModule <> nil do
      with LibModule^ do
      begin
        Result := GetInstRes(ResInstance, ResType, Name, Width, [], MaskColor);
        if not Result and (Instance <> ResInstance) then
          Result := GetInstRes(Instance, ResType, Name, Width, [], MaskColor);
        if Result then Exit;
        LibModule := LibModule.Next;
      end;
  end;
end;

function TCustomImageList.FileLoad(ResType: TResType; const Name: string;
  MaskColor: TColor): Boolean;
begin
  Result := GetResource(ResType, Name, Width, [lrFromFile], MaskColor);
end;

procedure TCustomImageList.Change;
var
  I: Integer;
begin
  FChanged := True;
  if FUpdateCount > 0 then Exit;
  if FClients <> nil then
    for I := 0 to FClients.Count - 1 do
      TChangeLink(FClients[I]).Change;
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TCustomImageList.UnRegisterChanges(Value: TChangeLink);
var
  I: Integer;
begin
  if FClients <> nil then
    for I := 0 to FClients.Count - 1 do
      if FClients[I] = Value then
      begin
        Value.Sender := nil;
        FClients.Delete(I);
        Break;
      end;
end;

procedure TCustomImageList.RegisterChanges(Value: TChangeLink);
begin
  Value.Sender := Self;
  if FClients <> nil then FClients.Add(Value);
end;

function TCustomImageList.Equal(IL: TCustomImageList): Boolean;

  function StreamsEqual(S1, S2: TMemoryStream): Boolean;
  begin
    Result := (S1.Size = S2.Size) and CompareMem(S1.Memory, S2.Memory, S1.Size);
  end;

var
  MyImage, OtherImage: TMemoryStream;
begin
  if (IL = nil) or (Count <> IL.Count) then
  begin
    Result := False;
    Exit;
  end;
  if (Count = 0) and (IL.Count = 0) then
  begin
    Result := True;
    Exit;
  end;
  MyImage := TMemoryStream.Create;
  try
    WriteData(MyImage);
    OtherImage := TMemoryStream.Create;
    try
      IL.WriteData(OtherImage);
      Result := StreamsEqual(MyImage, OtherImage);
    finally
      OtherImage.Free;
    end;
  finally
    MyImage.Free;
  end;
end;

procedure TCustomImageList.DefineProperties(Filer: TFiler);

  function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
      Result := not (Filer.Ancestor is TCustomImageList) or
        not Equal(TCustomImageList(Filer.Ancestor))
    else
      Result := Count > 0;
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Bitmap', ReadData, WriteData, DoWrite);
end;

procedure TCustomImageList.ReadD2Stream(Stream: TStream);
var
  FullImage, Image, FullMask, Mask: TBitmap;
  I, J, Size, Pos, Count: Integer;
  SrcRect: TRect;
begin
  Stream.ReadBuffer(Size, SizeOf(Size));
  Stream.ReadBuffer(Count, SizeOf(Count));
  FullImage := TBitmap.Create;
  try
    Pos := Stream.Position;
    FullImage.LoadFromStream(Stream);
    Stream.Position := Pos + Size;
    FullMask := TBitmap.Create;
    try
      FullMask.LoadFromStream(Stream);
      Image := TBitmap.Create;
      Image.Width := Width;
      Image.Height := Height;
      Mask := TBitmap.Create;
      Mask.Monochrome := True;
      Mask.Width := Width;
      Mask.Height := Height;
      SrcRect := Rect(0, 0, Width, Height);
      BeginUpdate;
      try
        for J := 0 to (FullImage.Height div Height) - 1 do
        begin
          if Count = 0 then Break;
          for I := 0 to (FullImage.Width div Width) - 1 do
          begin
            if Count = 0 then Break;
            Image.Canvas.CopyRect(SrcRect, FullImage.Canvas,
              Bounds(I * Width, J * Height, Width, Height));
            Mask.Canvas.CopyRect(SrcRect, FullMask.Canvas,
              Bounds(I * Width, J * Height, Width, Height));
            Add(Image, Mask);
            Dec(Count);
          end;
        end;
      finally
        Image.Free;
        Mask.Free;
        EndUpdate;
      end;
    finally
      FullMask.Free;
    end;
  finally
    FullImage.Free;
  end;
end;

procedure TCustomImageList.ReadD3Stream(Stream: TStream);
var
  LAdapter: TStreamAdapter;
  LTemp: TMemoryStream;
  LRetry: Boolean;
  LValue, LBitCount: Byte;
begin
  // attempt a simple read
  LAdapter := TStreamAdapter.Create(Stream);
  try
    Handle := ImageList_Read(LAdapter);
  finally
    LAdapter.Free;
  end;

  // if we were not successful then attempt to fix up the really old ComCtl stream
  if not HandleAllocated then
  begin

    // make a temp copy of the stream
    LRetry := False;
    LTemp := TMemoryStream.Create;
    try
      Stream.Position := 0;
      LTemp.LoadFromStream(Stream);

      // find the bad value imagelist header info
      LTemp.Position := 18;
      if (LTemp.Read(LValue, 1) = 1) and (LValue = 1) then
      begin

        // find the bitcount data farther on into the BitmapInfoHeader
        LTemp.Position := 56;
        if LTemp.Read(LBitCount, 1) = 1 then
        begin

          // correct the original value
          LValue := LValue or LBitCount;

          // back to the imagelist header info and patch it
          LTemp.Position := 18;
          LRetry := LTemp.Write(LValue, 1) = 1;
        end;
      end;

      // reattempt the load
      if LRetry then
      begin
        LTemp.Position := 0;
        LAdapter := TStreamAdapter.Create(LTemp);
        try
          Handle := ImageList_Read(LAdapter);
        finally
          LAdapter.Free;
        end;
      end;

    finally
      LTemp.Free;
    end;

    // if we still didn't succeed then fail
    if not HandleAllocated then
      raise EReadError.CreateRes(@SImageReadFail);
  end;
end;

procedure TCustomImageList.ReadData(Stream: TStream);
var
  CheckInt1, CheckInt2: Integer;
  CheckByte1, CheckByte2: Byte;
  StreamPos: Integer;
begin
  FreeHandle;
  StreamPos := Stream.Position;              // check stream signature to
  Stream.Read(CheckInt1, SizeOf(CheckInt1)); // determine a Delphi 2 or Delphi
  Stream.Read(CheckInt2, SizeOf(CheckInt2)); // 3 imagelist stream.  Delphi 2
  CheckByte1 := Lo(LoWord(CheckInt1));       // streams can be read, but only
  CheckByte2 := Hi(LoWord(CheckInt1));       // Delphi 3 streams will be written
  Stream.Position := StreamPos;
  if (CheckInt1 <> CheckInt2) and (CheckByte1 = $49) and (CheckByte2 = $4C) then
    ReadD3Stream(Stream)
  else
    ReadD2Stream(Stream);
end;

const
  ComCtlVersionIE6 = $00060000;
var
  CachedComCtrlVer: Cardinal;
  ImageListWriteExProc: function(ImageList: HIMAGELIST; Flags: DWORD; Stream: IStream): HRESULT; stdcall;
  
procedure TCustomImageList.WriteData(Stream: TStream);
var
  SA: TStreamAdapter;
  ComCtrlHandle: THandle;
const
  ILP_DOWNLEVEL = 1;
begin
  if CachedComCtrlVer = 0 then
  begin
    CachedComCtrlVer := GetFileVersion(comctl32);
    if CachedComCtrlVer >= ComCtlVersionIE6 then
    begin
      ComCtrlHandle := GetModuleHandle(comctl32);
      if ComCtrlHandle <> 0 then
        ImageListWriteExProc := GetProcAddress(ComCtrlHandle, 'ImageList_WriteEx'); { Do not localize }
    end;
  end;

  SA := TStreamAdapter.Create(Stream);
  try
    { See if we should use the new API for writing image lists in the old
      format. }
    if Assigned(ImageListWriteExProc) then
    begin
      if ImageListWriteExProc(Handle, ILP_DOWNLEVEL, SA) <> S_OK then
        raise EWriteError.CreateRes(@SImageWriteFail)
    end
    else if not ImageList_Write(Handle, SA) then
        raise EWriteError.CreateRes(@SImageWriteFail);
  finally
    SA.Free;
  end;
end;
(*
var
  I: Integer;
  DIB1, DIB2: TBitmap;
  DC: HDC;
  S: TMemoryStream;

  procedure WriteDIB(BM: HBitmap);
    { The ImageList leaves its bitmap handle selected into a DC somewhere,
      so we can't select it into our own DC to copy from it.  The only safe
      operation is GetDIB (GetDIBits), which extracts the pixel bits without
      selecting the BM into a DC.  This code builds our own bitmap from
      those bits, then crops it to the minimum size before writing it out.}
  var
    BitsSize: DWORD;
    Header, Bits: PChar;
    DIBBits: Pointer;
    R: TRect;
    HeaderSize: DWORD;
    GlyphsPerRow, Rows: Integer;
  begin
    if BM = 0 then Exit;
    GetDIBSizes(BM, HeaderSize, BitsSize);
    GetMem(Header, HeaderSize + BitsSize);
    try
      Bits := Header + HeaderSize;
      GetDIB(BM, 0, Header^, Bits^);
      DIB1.Handle := CreateDIBSection(DC, PBitmapInfo(Header)^, DIB_RGB_COLORS, DIBBits, 0, 0);
      System.Move(Bits^, DIBBits^, BitsSize);
      with PBitmapInfo(Header)^.bmiHeader do
      begin
        GlyphsPerRow := biWidth div Width;
        if GlyphsPerRow = 0 then Inc(GlyphsPerRow);
        if GlyphsPerRow > Count then GlyphsPerRow := Count;
        biWidth := GlyphsPerRow * Width;
        Rows := Count div GlyphsPerRow;
        if Count > Rows * GlyphsPerRow then Inc(Rows);
        biHeight := Rows * Height;
        R := Rect(0, 0, biWidth, biHeight);
      end;
      DIB2.Handle := CreateDIBSection(DC, PBitmapInfo(Header)^, DIB_RGB_COLORS, DIBBits, 0, 0);
      DIB2.Canvas.CopyRect(R, DIB1.Canvas, R);
      DIB2.SaveToStream(S);
    finally
      FreeMem(Header);
    end;
  end;

begin
  DIB1 := nil;
  DIB2 := nil;
  DC := 0;
  S := TMemoryStream.Create;
  try
    DIB1 := TBitmap.Create;
    DIB2 := TBitmap.Create;
    DC := GetDC(0);
    WriteDIB(GetImageBitmap);
    I := S.Size;
    WriteDIB(GetMaskBitmap);
    Stream.WriteBuffer(I, sizeof(I));
    I := Count;
    Stream.WriteBuffer(I, sizeof(I));
    Stream.WriteBuffer(S.Memory^, S.Size);
  finally
    ReleaseDC(0, DC);
    DIB1.Free;
    DIB2.Free;
    S.Free;
  end;
end;
*)
procedure TCustomImageList.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TCustomImageList.EndUpdate;
begin
  if FUpdateCount > 0 then Dec(FUpdateCount);
  if FChanged then
  begin
    FChanged := False;
    Change;
  end;
end;

{ TChangeLink }

destructor TChangeLink.Destroy;
begin
  if Sender <> nil then Sender.UnRegisterChanges(Self);
  inherited Destroy;
end;

procedure TChangeLink.Change;
begin
  if Assigned(OnChange) then OnChange(Sender);
end;

end.