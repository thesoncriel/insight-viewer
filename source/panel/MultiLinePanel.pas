Unit MultiLinePanel;

Interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms, Dialogs,
  StdCtrls,ExtCtrls, WinTypes, Graphics;
Type
  THeightAlign = (taTop, taCenter, taBottom);
  TGradientStyle = (gsLeft, gsTop, gsRight, gsBottom, gsLRCenter, gsTBCenter);
  TGradientColors = 2..255;
  //TComponentState = (csLoading, csReading, csWriting, csDestroying, csDesigning, csAncestor, csUpdating, csFixups, csFreeNotification, csInline, csDesignInstance);

type
  TMultiLinePanel = class(TPanel)

  private
    FBgGradient: TBitmap;
    FMultiCanvas: TControlCanvas;
    FMultiLine : Boolean;
    FDefaultHeight: Integer;
    FOnChange: TNotifyEvent;
    FHeightAlign: THeightAlign;
    FSpaceLineFeed: Boolean;
    FBorderLineColor   : TColor;
    FBorderRound   : Byte;
    FBorderLine        : Boolean;
    FBorderLineWidth   : Integer;
    FCaptionList: TStringList;
    FDefHeight: Integer;
    FDefWidth: Integer;
    FGradientFromColor : TColor;
    FGradientToColor   : TColor;
    FGradientStyle     : TGradientStyle;
    FDisplayFormat: String;

    procedure SetMultiLine(Value: Boolean);
    procedure SetDefaultHeight(Value: Integer);
    procedure SetHeightAlign(Value: THeightAlign);
    procedure SetSpaceLineFeed(Value: Boolean);

    procedure SetBorderLineColor(Value: TColor);
    procedure SetBorderRound(const Value: Byte);
    procedure SetBorderLine(Value: Boolean);
    procedure SetBorderLineWidth(Value: Integer);
    procedure SetGradientFromColor(Value: TColor);
    procedure SetGradientToColor(Value: TColor);
    procedure SetGradientStyle(Value: TGradientStyle); virtual;
    procedure CreateGradientRect(const AWidth, AHeight: Integer; const StartColor,
      EndColor: TColor; const Colors: TGradientColors; const Style: TGradientStyle;
      const Dithered: Boolean; var Bitmap: TBitmap);
    function IsResized: Boolean;
    function IsSpecialDrawState(IgnoreDefault: Boolean = False): Boolean;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure HookResized; //override;
  published
    property DisplayFormat: String read FDisplayFormat write FDisplayFormat;
    property MultiLine: Boolean read FMultiLine write SetMultiLine  default TRUE;
    property DefaultHeight : Integer read FDefaultHeight write SetDefaultHeight default 41;
    property HeightAlign: THeightAlign read FHeightAlign write SetHeightAlign;
    property SpaceLineFeed: Boolean read FSpaceLineFeed write SetSpaceLineFeed default FALSE;

    property BorderLineColor: TColor read FBorderLineColor write SetBorderLineColor default $00733800;
    property BorderRound: Byte read FBorderRound write SetBorderRound default 5;
    property BorderLine: Boolean read FBorderLine write SetBorderLine default FALSE;
    property BorderLineWidth: Integer read FBorderLineWidth write SetBorderLineWidth;
    property GradientFromColor: TColor read FGradientFromColor write SetGradientFromColor;
    property GradientToColor: TColor read FGradientToColor write SetGradientToColor;
    property GradientStyle: TGradientStyle read FGradientStyle write SetGradientStyle default gsLeft;

  end;

procedure Register;

implementation

constructor TMultiLinePanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FBgGradient := TBitmap.Create; // background gradient
  FCaptionList := TStringList.Create;
  ControlStyle := [csAcceptsControls, csCaptureMouse, csClickEvents,
    csSetCaption, csOpaque, csDoubleClicks, csReplicatable];
  FDefHeight := 0;
  FDefWidth := 0;
  Width := 185;
  Height := 41;
  DefaultHeight := 41;
  MultiLine := TRUE;
  SpaceLineFeed := FALSE;

  FBorderLineColor   := $00733800;
  FBorderRound       := 5;
  FBorderLine        := FALSE;
  FBorderLineWidth   := 1;
  FGradientFromColor := clBtnFace;
  FGradientToColor   := clWhite;
  FGradientStyle     := gsLeft;
end;

destructor TMultiLinePanel.Destroy;
begin
  FCaptionList.Free;
  FBgGradient.Free;
  inherited Destroy;
end;

procedure TMultiLinePanel.SetMultiLine(Value: Boolean);
begin
  if FMultiLine <> Value then
  begin
    FMultiLine := Value;
    RecreateWnd;
  end;
end;

procedure TMultiLinePanel.SetDefaultHeight(Value: Integer);
begin
  if FDefaultHeight <> Value then
  begin
    FDefaultHeight := Value;
    Height := Value;
    RecreateWnd;
  end;
end;

procedure TMultiLinePanel.SetHeightAlign(Value: THeightAlign);
begin
  if FHeightAlign <> Value then
  begin
    FHeightAlign := Value;
    RecreateWnd;
  end;
end;

procedure TMultiLinePanel.SetSpaceLineFeed(Value: Boolean);
begin
  if FSpaceLineFeed <> Value then
  begin
    FSpaceLineFeed := Value;
    RecreateWnd;
  end;
end;

procedure TMultiLinePanel.SetBorderLineColor(Value: TColor);
begin
  if FBorderLineColor <> Value then
  begin
    FBorderLineColor := Value;
    invalidate;
  end;
end;

procedure TMultiLinePanel.SetBorderRound(const Value: Byte);
begin
  if FBorderRound <> Value then
  begin
    FBorderRound := Value;
    invalidate;
  end;
end;

procedure TMultiLinePanel.SetBorderLine(Value: Boolean);
begin
  if FBorderLine <> Value then
  begin
    FBorderLine := Value;
    invalidate;
  end;
end;

procedure TMultiLinePanel.SetBorderLineWidth(Value: Integer);
begin
  if FBorderLineWidth <> Value then
  begin
    FBorderLineWidth := Value;
    invalidate;
  end;
end;

procedure TMultiLinePanel.SetGradientFromColor(Value: TColor);
begin
  if FGradientFromColor <> Value then
  begin
    FGradientFromColor := Value;
    HookResized;
    RecreateWnd;
  end;
end;

procedure TMultiLinePanel.SetGradientToColor(Value: TColor);
begin
  if FGradientToColor <> Value then
  begin
    FGradientToColor := Value;
    HookResized;
    RecreateWnd;
  end;
end;

procedure TMultiLinePanel.SetGradientStyle(Value: TGradientStyle); //virtual;
begin
  if FGradientStyle <> Value then
  begin
    FGradientStyle := Value;
    RecreateWnd;
    HookResized;
  end;
end;

procedure TMultiLinePanel.HookResized;
const
  ColSteps = 64;
  Dithering = True;
var
  Offset: Integer;
begin
  inherited;

  CreateGradientRect(Width, Height, FGradientFromColor,  FGradientToColor, ColSteps, FGradientStyle, Dithering, FBgGradient);
end;

procedure TMultiLinePanel.CreateGradientRect(const AWidth, AHeight: Integer; const StartColor,
  EndColor: TColor; const Colors: TGradientColors; const Style: TGradientStyle;
  const Dithered: Boolean; var Bitmap: TBitmap);
const
  PixelCountMax = 32768;
type
  TGradientBand = array[0..255] of TColor;
  TRGBMap = packed record
    case boolean of
      True: (RGBVal: DWord);
      False: (R, G, B, D: Byte);
  end;
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..PixelCountMax-1] of TRGBTriple;
const
  DitherDepth = 16;
var
  iLoop, xLoop, yLoop, XX, YY: Integer;
  iBndS, iBndE: Integer;
  GBand: TGradientBand;
  Row:  pRGBTripleArray;
  procedure CalculateGradientBand;
  var
    rR, rG, rB: Real;
    lCol, hCol: TRGBMap;
    iStp: Integer;
  begin
    if Style in [gsLeft, gsTop] then
    begin
      lCol.RGBVal := ColorToRGB(StartColor);
      hCol.RGBVal := ColorToRGB(EndColor);
    end
    else
    begin
      lCol.RGBVal := ColorToRGB(EndColor);
      hCol.RGBVal := ColorToRGB(StartColor);
    end;
    rR := (hCol.R - lCol.R) / (Colors - 1);
    rG := (hCol.G - lCol.G) / (Colors - 1);
    rB := (hCol.B - lCol.B) / (Colors - 1);
    for iStp := 0 to (Colors - 1) do
      GBand[iStp] := RGB(
        lCol.R + Round(rR * iStp),
        lCol.G + Round(rG * iStp),
        lCol.B + Round(rB * iStp)
        );
  end;
begin
  Bitmap.Height := AHeight;
  Bitmap.Width := AWidth;

  if Bitmap.PixelFormat <> pf24bit then
    Bitmap.PixelFormat := pf24bit;

  CalculateGradientBand;

  with Bitmap.Canvas do
  begin
    Brush.Color := StartColor;
    FillRect(Bounds(0, 0, AWidth, AHeight));
    if Style in [gsLeft, gsRight] then
    begin
      for iLoop := 0 to Colors - 1 do
      begin
        iBndS := MulDiv(iLoop, AWidth, Colors);
        iBndE := MulDiv(iLoop + 1, AWidth, Colors);
        Brush.Color := GBand[iLoop];
        PatBlt(Handle, iBndS, 0, iBndE, AHeight, PATCOPY);
        if (iLoop > 0) and (Dithered) then
          for yLoop := 0 to DitherDepth - 1 do if (yLoop < AHeight)  then
            begin
            Row := Bitmap.Scanline[yLoop];
            for xLoop := 0 to AWidth div (Colors - 1) do
              begin
              XX:= iBndS + Random(xLoop);
              if (XX < AWidth) and (XX > -1) then
               with Row[XX] do
                begin
                rgbtRed := GetRValue(GBand[iLoop - 1]);
                rgbtGreen := GetGValue(GBand[iLoop - 1]);
                rgbtBlue := GetBValue(GBand[iLoop - 1]);
                end;
              end;
            end;
      end;
      for yLoop := 1 to AHeight div DitherDepth do
        CopyRect(Bounds(0, yLoop * DitherDepth, AWidth, DitherDepth),
          Bitmap.Canvas, Bounds(0, 0, AWidth, DitherDepth));
    end
    else
    begin
      for iLoop := 0 to Colors - 1 do
      begin
        iBndS := MulDiv(iLoop, AHeight, Colors);
        iBndE := MulDiv(iLoop + 1, AHeight, Colors);
        Brush.Color := GBand[iLoop];
        PatBlt(Handle, 0, iBndS, AWidth, iBndE, PATCOPY);
        if (iLoop > 0) and (Dithered) then
          for yLoop := 0 to AHeight div (Colors - 1) do
            begin
            YY:=iBndS + Random(yLoop);
            if (YY < AHeight) and (YY > -1) then
             begin
             Row := Bitmap.Scanline[YY];
             for xLoop := 0 to DitherDepth - 1 do if (xLoop < AWidth)  then with Row[xLoop] do
               begin
               rgbtRed := GetRValue(GBand[iLoop - 1]);
               rgbtGreen := GetGValue(GBand[iLoop - 1]);
               rgbtBlue := GetBValue(GBand[iLoop - 1]);
               end;
             end;
            end;
      end;
      for xLoop := 0 to AWidth div DitherDepth do
        CopyRect(Bounds(xLoop * DitherDepth, 0, DitherDepth, AHeight),
          Bitmap.Canvas, Bounds(0, 0, DitherDepth, AHeight));
    end;
  end;
end;

function TMultiLinePanel.IsSpecialDrawState(IgnoreDefault: Boolean = False): Boolean;
begin

end;

procedure Register;
begin
  RegisterComponents('Standard', [TMultiLinePanel]);
end;


function TMultiLinePanel.IsResized: Boolean;
begin
  Result := FALSE;

  if FDefWidth <> Width then
  begin
    FDefWidth := Width;
    Result := TRUE;
  end;

  if FDefHeight <> Height then
  begin
    FDefHeight := Height;
    Result := TRUE;
  end;
end;

procedure TMultiLinePanel.Paint;
const
  Alignments: array[TAlignment] of Longint = (DT_LEFT, DT_RIGHT, DT_CENTER);
var
  Rect: TRect;
  TopColor, BottomColor: TColor;
  FontHeight: Integer;
  Flags: Longint;
  pCaption: PChar;
  MaxWidth, i,
  sHeight: Integer;
  tCaption: String;
  procedure AdjustColors(Bevel: TPanelBevel);
  begin
    TopColor := clBtnHighlight;
    if Bevel = bvLowered then TopColor := clBtnShadow;
    BottomColor := clBtnShadow;
    if Bevel = bvLowered then BottomColor := clBtnHighlight;
  end;

  procedure AddCaptionList;
  begin
    FCaptionList.Add( tCaption );
    tCaption := '';
  end;
begin
  Rect := GetClientRect;

  with Canvas do
  begin
    Brush.Color := Color;
    FillRect(Rect);
    Brush.Style := bsClear;
    Font := Self.Font;
    FCaptionList.Clear;
    MaxWidth := ClientWidth - 4;
    sHeight := ClientHeight;
    FontHeight := TextHeight( Caption );

    if csDesigning in ComponentState then FDefaultHeight := Height;

    if (Align = AlClient) or (Align = AlRight) or (Align = AlLeft) then FDefaultHeight := Height;

    Flags := DT_EXPANDTABS or DT_VCENTER or Alignments[Alignment];
    Flags := DrawTextBiDiModeFlags(Flags);

    BitBlt(Handle, 1, 1, Width, Height, FBgGradient.Canvas.Handle, 2, 2, SRCCOPY);

    if FBorderLine then//and  (BevelOuter = bvNone) and  (BevelInner = bvNone) then
    begin
      Pen.Width := FBorderLineWidth;
      Pen.Color := FBorderLineColor;
      Brush.Style := bsClear;
      RoundRect(0, 0, Width, Height, FBorderRound, FBorderRound);
    end
    else
    begin
      if BevelOuter <> bvNone then
      begin
        AdjustColors(BevelOuter);
        Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
      end;

      Frame3D(Canvas, Rect, Color, Color, BorderWidth);

      if BevelInner <> bvNone then
      begin
        AdjustColors(BevelInner);
        Frame3D(Canvas, Rect, TopColor, BottomColor, BevelWidth);
      end;
    end;

    if FMultiLine then
    begin
      pCaption := PChar( Caption );
      tCaption := '';

      for i := 1 to Length( Caption ) do
      begin
        if ( pCaption[ 0 ] <> #13 ) and ( pCaption[ 0 ] <> #10 ) then
        begin
          if MaxWidth < ( TextWidth( tCaption ) + TextWidth( pCaption[ 0 ] ) ) then
            AddCaptionList;
          tCaption := tCaption + pCaption[ 0 ]
        end
        else if pCaption[ 0 ] = #13 then
          AddCaptionList;
        inc( pCaption );
      end;

      if tCaption <> '' then
        AddCaptionList;

      if FCaptionList.Count <= 1 then
      begin
        ClientHeight := FDefaultHeight;
        Height       := FDefaultHeight;
      end
      else
      begin
        if FDefaultHeight < ( ( FontHeight * FCaptionList.Count ) + 6 ) then
          ClientHeight := ( ( FontHeight * FCaptionList.Count ) + 6 );
      end;

      if FCaptionList.Count > 0 then
      begin
        with Rect do
        begin
          for i := 0 to FCaptionList.Count - 1 do
          begin
            if FCaptionList.Count = 1 then
              Top := ((Bottom + Top) - FontHeight) div 2
            else
            begin
              if ClientHeight = ( ( FontHeight * FCaptionList.Count ) + 6 ) then
                Top := ( FontHeight * i ) + 3
              else
                Top := ( ClientHeight - ( FontHeight * FCaptionList.Count ) ) div 2 + ( FontHeight * i );
            end;

            Bottom := Top + FontHeight;

            case Alignments[Alignment] of
              DT_LEFT: Left := 3;
              DT_RIGHT: Right := Right - 3;
            end;

            DrawText( Handle, PChar( FCaptionList.Strings[ i ]), Length( FCaptionList.Strings[ i ] ), Rect, Flags );
          end;
        end;
      end;
    end
    else
    begin
      ClientHeight := FDefaultHeight;
      Height       := FDefaultHeight;
      with Rect do
      begin
        Top := ((Bottom + Top) - FontHeight) div 2;
        Bottom := Top + FontHeight;
      end;

      DrawText(Handle, PChar(Caption), -1, Rect, Flags);
    end;

    if sHeight <> ClientHeight then
    begin
      if      FHeightAlign = taCenter then Top := Top - (ClientHeight - sHeight) div 2
      else if FHeightAlign = taBottom then Top := Top - (ClientHeight - sHeight);
    end;
  end;
end;


end.
