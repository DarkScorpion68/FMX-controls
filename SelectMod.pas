unit SelectMod;

interface

uses
  System.SysUtils, System.Classes,system.Math.vectors, System.Types,System.UIConsts,System.Messaging,
  system.Rtti,fmx.platform,fmx.actnlist,system.Actions,System.RTLConsts,system.Math,
  system.UITypes, FMX.Types, fmx.menus, FMX.Controls, FMX.Objects,FMX.Graphics,
  FMX.Effects,FMX.StdCtrls,{FMX.TMSBitmap,}FMX.Layouts,FMX.ImgList,FMX.Forms;

type

  TSetSize = (ssAbs,ssSize,ssScale,ssBy,ssAbsCent, ssByCent);
  TBoxType = (cNone, cEdit, cText, cNum, cBit,cSignal,cHeader);
  TBlinkType = (blBig, blSmall, blRing);

  TBoxCon = record
    ConT: TBoxType;
    Con : TFmxObject;
  end;

  TCellPos = record
    Col,Row: SmallInt;
  end;

  TCellProp = record
    Col,Row:SmallInt;
    W,H : Single;
    Sides: TSides;
    FillColor: TAlphaColor;
    FillKind : TBrushKind;
    StrokeColor: TAlphaColor;
    StrokeThik: Single;
    Dash : TStrokeDash;
    ConT: TBoxType;
  end;


  TCellObjects = record
    Tag : SmallInt;
    Rec : TRectangle;
    Prop : TCellProp;
    R,C : Byte;
    W,H : Single;
    NumCon: Byte;
    Con : array [1..4] of TBoxCon;
  end;

  TExtForm = class(TForm)
  public
    procedure AfterConstruction; override;
  end;

  TTableObjects = array of array of TCellObjects;
  TTableGrid = record
   Ver: Single;
   Row,Col : SmallInt;
   Dash : TStrokeDash;
   Table : TTableObjects;

  end;

  TBlinkCircle = class(TCircle)
  private
    { Private declarations }
    FxFill: TBrush;
    FXStroke: TStrokeBrush;
    FxBlink  : TBlinkType;
    FInterval: SmallInt;
    FisBlinking : Boolean;
    fTimer : TTimer;
    FxCircle : TCircle;
    FxSize : Single;
    FxBlinkCount,fxBlinkNum : Byte;
    procedure SetFill(const Value: TBrush);
    procedure SetStroke(const Value: TStrokeBrush);
    procedure SetBlinking(const Value: Boolean);
    procedure SetBlinkType(const Value: TBlinkType);
  protected
    { Protected declarations }
    procedure onTimerEvent(Sender: TObject); virtual;
    procedure FillChanged(Sender: TObject); virtual;
    procedure StrokeChanged(Sender: TObject); virtual;
    procedure SetSize(const Value: Single);  virtual;
    procedure SetInterval(const Value: SmallInt);   virtual;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);overload;  override;
    constructor Create(AOwner: TComponent; avisible:boolean; aParent:TFmxObject); overload;
    destructor Destroy; override;
  published
    Property BlinkInterval : SmallInt read FInterval write FInterval;
    property isBlinking : Boolean read FisBlinking write SetBlinking;
    property SmallFill: TBrush read FxFill write SetFill;
    property SmallStroke: TStrokeBrush read FXStroke write SetStroke;
    property SmallSize : Single read FxSize write SetSize;
    Property BlinkType : TBlinkType read fxBlink write SetBlinkType;
    property BlinkCount: Byte read FxBlinkCount write FxBlinkCount;
    { Published declarations }
  end;

  TiGridPanel = class(TGridPanelLayout)
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure Resize; override;
  public
    { Public declarations }
    FCurCell, FOldCell: TCellPos;
    FTabW,FTabH :Single;
    FTable : TTableGrid;
    isEditMode: Boolean;
    isTwoColors: boolean;
    FDefCellW,FDefCellH: Single;
    FDefSColor,FDefFColor,FDefFColor1,FDefFColor2  : TAlphaColor;
    fCellMenu : TPopupmenu;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;                     //  TAlphaColor  TSide TStroke
    procedure SetBorder(col,row:SmallInt; rThick: Single; rDash: TStrokeDash= TStrokeDash.Solid;
                                rColor:TAlphaColor = claNull;rSides: TSides = [] );  // color, think, sides, sides in grid
    Procedure CreateCellRec(col,row:SmallInt;fdash:TStrokeDash;th:single;const fgrcolor: TAlphaColor = claBlack);
    procedure CreateTable(col,row:smallint; wgrid: boolean; onmoused: TMouseEvent;const th:single=1;const fgrcolor: TAlphaColor = claBlack);
    procedure SetFill(col,row:SmallInt; aColor:TAlphaColor; aKind:TBrushKind= TBrushKind.Solid);
    function GetFill(col,row:SmallInt;var aKind:TBrushKind):TAlphaColor;
    Procedure CellSetValue(col,row:SmallInt; value: string); overload;
    Procedure CellSetValue(col,row:SmallInt; value: Integer); overload;
    Procedure CellSetValue(col,row:SmallInt; value: Single); overload;
    Procedure CellgetValue(col,row:SmallInt; var value: string); overload;
    Procedure CellgetValue(col,row:SmallInt; var value: Integer); overload;
    Procedure CellgetValue(col,row:SmallInt; var value: Single); overload;

  published
    { Published declarations }
  end;


 TSelectionMod = class(TControl)
  private
    FStroke: TStrokeBrush;
    FHotColor : TStrokeBrush;
    FParentBounds: Boolean;
    FOnChange: TNotifyEvent;
    FHideSelection: Boolean;
    FMinSize: Integer;
    FOnTrack: TNotifyEvent;
    FProportional: Boolean;
    FGripSize: Single;
    FRatio: Single;
    FMove, FLeftTop, FLeftBottom, FRightTop, FRightBottom: Boolean;
    FLeftTopHot, FLeftBottomHot, FRightTopHot, FRightBottomHot: Boolean;
    FDownPos, FMovePos: TPointF;
    procedure SetStroke(const Value: TStrokeBrush);
    procedure SetHotColor(const Value : TStrokeBrush);
    procedure SetHideSelection(const Value: Boolean);
    procedure SetMinSize(const Value: Integer);
    procedure SetGripSize(const Value: Single);
    procedure DoLeftTopMove( AX, AY: Single) ;
    procedure DoLeftBottomMove( AX, AY: Single) ;
    procedure DoRightTopMove( AX, AY: Single) ;
    procedure DoRightBottomMove( AX, AY: Single) ;
    procedure ReSetInSpace(ARotationPoint, ASize: TPointF) ;
    function  GetProportionalSize(ASize : TPointF) : TPointF ;
  protected
    function GetAbsoluteRect: TRectF; override;
    procedure Paint; override;
    procedure StrokeChanged(Sender: TObject); virtual;
  public

    function PointInObjectLocal(X, Y: Single): Boolean; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseLeave; override;
  published
    property Align;
    property Anchors;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property GripSize: Single read FGripSize write SetGripSize;
    property Locked default False;
    property Height;
    property HideSelection: Boolean read FHideSelection write SetHideSelection;
    property HitTest default True;
    property HotCornerStroke : TStrokeBrush read FHotColor write SetHotColor;
    property Padding;
    property MinSize: Integer read FMinSize write SetMinSize default 15;
    property Opacity;
    property Margins;
    property ParentBounds: Boolean read FParentBounds write FParentBounds default True;
    property Proportional: Boolean read FProportional write FProportional;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Stroke: TStrokeBrush read FStroke write SetStroke;
    property Scale;
    property Size;
    property Visible default True;
    property Width;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    {Drag and Drop events}
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    {Mouse events}
    property OnClick;
    property OnDblClick;

    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;

    property OnPainting;
    property OnPaint;
    property OnResize;
    property OnTrack: TNotifyEvent read FOnTrack write FOnTrack;
  end;




  TGRectangle = class(TRectangle)
    private
      FColorMouseEnter,FColorMouseLeave,FColorMouseDown:TAlphaColor;
      FOpacityME,FOpacityML : Single;
//     FYRadius: Single;
//    FXRadius: Single;
   protected
      procedure SetXRadius(const Value: Single); override;
      procedure SetYRadius(const Value: Single); override;
      procedure DoMouseEnter; override;
      procedure DoMouseLeave; override;
      Procedure SetMouseLeave(const Value: TAlphaColor);
    public
      FGlyph : TGlyph;
      constructor Create(AOwner: TComponent); override;
       procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
       procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;

    published
      property ColorMEnter : TAlphaColor read FColorMouseEnter write FColorMouseEnter;
      property ColorMLeave : TAlphaColor read FColorMouseLeave write SetMouseLeave;
      property ColorMDown : TAlphaColor read FColorMouseDown write FColorMouseDown;
      property OpacityME : Single read FOpacityME write FOpacityME;
      property OpacityML : Single read FOpacityML write FOpacityML;
      Property Picture : TGlyph read FGlyph;

   end;


  TSelectNotify = procedure(sender: TObject; SelectMode: SmallInt) of object;
  TWinRectangle = class(TRectangle)
  private
    FStrokeLo : TStrokeBrush;
    FFillHeader: TBrush;
    FHeadSize : Single;
    FHeadBorder : Boolean;
    FExpand : Boolean;
    FNormalSize: Single;
    FStartPos: TPointF;
    FPressed: Boolean;
    fCountTick : SmallInt;
    FMoveMode : SmallInt;
    FSelectMove: TSelectNotify;
    FUseParent : Boolean;
    FFirstPaint: Boolean;
    FMovable, FResizable: Boolean;
    FShadowed, fishadow : Boolean;
    FColor1, FColor2, FColor3,FMainStroke : TAlphaColor;
    FGrip : TSizeGrip;
    FShowGrip : Boolean;
    fscalx,fscaly: single;
    FShadow : TShadowEffect;
    fShadowOff : Boolean;
    FMinWidth, FMinHeight, FMaxWidth,FMaxHeight : Single;
    { Private declarations }
    procedure SetStroke(const Value: TStrokeBrush);
    procedure SetFillHeader(const Value : TBrush);
    procedure SetExpand(Const Value: Boolean);
    procedure SetGripp(Const Value: Boolean);
    procedure SetHeadSize(const Value: Single);
    procedure SetShadow(Const Value : Boolean);
    procedure SetScaleWin(var pan:TFmxObject; x,y: single); overload;
    procedure SetScaleWin(var pan:TWinrectangle ;x,y: single); overload;
    procedure GetScaleWin(var pan:TFmxObject; var x,y: single); overload;
    procedure GetScaleWin(var pan:TWinrectangle; var x,y: single); overload;
  protected
    { Protected declarations }
    procedure StrokeChanged(Sender: TObject); virtual;
    procedure onTimerEvent(Sender: TObject); virtual;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
//    procedure onPicMouseEnter(Sender: TObject);
//    procedure onPicMouseLeave(Sender: TObject);

  public

    FmyTimer : TTimer;
 //   FHImage1,FHImage2,FHImage3,FHImage4: TTMSFMXBitmap;
    FRecB1, FRecB2,FRecB3,FRecB4 : TRectangle;
    FHText : TLabel;
    constructor Create(AOwner: TComponent); override;
    function CloneWin(const AOwner: TComponent) : TWinRectangle;
    { Public declarations }
  published
   property HeadStroke: TStrokeBrush read FStrokeLo write SetStroke;
   property HeadSFill: TBrush read FFillHeader write SetFillHeader;
   property HeadSize : Single read FHeadSize write SetHeadSize;
   property HeadBorder : Boolean read FHeadBorder write FHeadBorder;
   property isMoveble : Boolean read FMovable write FMovable;
   property isResizable : Boolean read FResizable write FResizable;
   property isShadowOff : Boolean read fShadowOff write fShadowOff;
   property isShadowed : Boolean read FShadowed write SetShadow;
   property Expand : Boolean read FExpand write SetExpand;
   property HeadText : Tlabel read FHText{ write FHtext};
   property ExpandHeight : single read FNormalSize write FNormalSize{ stored True};
//   property HeadImage1 : TTMSFMXBitmap read FHImage1{ write FHImage1};
//   property HeadImage2 : TTMSFMXBitmap read FHImage2{ write FHImage2};
//   property HeadImage3 : TTMSFMXBitmap read FHImage3{ write FHImage3};
//   property HeadImage4 : TTMSFMXBitmap read FHImage4{ write FHImage4};
   property UseParent : Boolean read FUseParent write FUseParent;
   property ShowGrip : Boolean read FShowGrip write SetGripp;
   property SMColor1 : TAlphaColor  read FColor1 write FColor1;
   property SMColor2 : TAlphaColor  read FColor2 write FColor2;
   property SMColor3 : TAlphaColor  read FColor3 write FColor3;
   property onSelectMode : TSelectNotify read FSelectMove write FSelectMove;
   property MinHeight : single read FMinHeight write FMinHeight;
   property MinWidth : single read FMinWidth write FMinWidth;
   property MaxHeight : single read FMaxHeight write FMaxHeight;
   property MaxWidth : single read FMaxWidth write FMaxWidth;


    { Published declarations }
  end;


  TChRadioButton = class(TRadioButton)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    fChecked : Boolean;
    constructor Create(AOwner: TComponent); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;
  published
    { Published declarations }
  end;

  TLGlyph = class(TGlyph)
  private
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

  TShowGrid = (gridNone,gridNormal,gridDubble);

  TGridRectangle = class(TRectangle)
  private

    FMarks: Single;
    FFrequency: Single;
    FLineFill: TStrokeBrush;
    FLineFillS: TAlphaColor;   // second line for bold lines
    FOpa : Single;
    FDubbleLine : TShowGrid;
    procedure SetOpa (const Value:single);
    Procedure SetDubbler(Const Value : TShowGrid);
    procedure SetLineFillS(const Value: TAlphaColor);
    procedure SetFrequency(const Value: Single);
    procedure SetMarks(const Value: Single);
    procedure SetLineFill(const Value: TStrokeBrush);
    procedure LineFillChanged(Sender: TObject);
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Locked;
    property OpacitySL : single read FOpa write SetOpa;
    Property GridShow : TShowGrid Read FDubbleLine write SetDubbler;
    property Frequency: Single read FFrequency write SetFrequency;
    property LineFill: TStrokeBrush read FLineFill write SetLineFill;
    property LineSColor :TAlphaColor read FLineFillS write SetLineFillS;
    property Marks: Single read FMarks write SetMarks;

  end;


  TWinExpander = class(TExpander)
  private
   FStroke : TStrokeBrush;
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

  function CRtoTag(col,row: SmallInt) : string;
  Procedure TagToCR(ts:string;var col,row: SmallInt);
  Function BorderInGrid(grC, grR, col, row: SmallInt) : TSides;

  procedure SetObjectSize(var objpar;st:TSetSize;sz : single);
  procedure SetObjectPos(var objpar;st:TSetSize;sx,sy:single);
  procedure SetObjectScale(var objpar;st:TSetSize;sz : single);
  procedure SetObjectPad(var objpar;st:TSetSize;sz : single);
  procedure SetObjectMrg(var objpar;st:TSetSize;sz : single);
  //get if a particular bit is 1
  function BitGet(const aValue: Cardinal; const Bit: Byte): Boolean;
//set a particular bit as 1
  function BitSet(const aValue: Cardinal; const Bit: Byte): Cardinal;
//set a particular bit as 0
  function BitClear(const aValue: Cardinal; const Bit: Byte): Cardinal;
//Enable o disable a bit
  function BitEnable(const aValue: Cardinal; const Bit: Byte; const Flag: Boolean): Cardinal;
  function Int2Bin(i : cardinal; n: byte) : shortstring;
  function Bin2Int(s : shortstring): Cardinal;
  function Kvin2Char( kb : byte) : ansichar;
  function Char2kvin( ch : AnsiChar;const b: byte = 0) : byte;
  function Get8RBits( tb : byte;nb:byte ) : byte;
  function Get16RBits( tb : word;nb:byte ) : word;
  function Get32RBits( tb : cardinal;nb:byte ) : cardinal;
  function Get8LBits( tb : byte;nb:byte ) : byte;
  function Get16LBits( tb : word;nb:byte ) : word;
  function Get32LBits( tb : cardinal;nb:byte ) : cardinal;
  function MakeScaleScreenshot(Sender:TControl;const dw: single = 0.0; const dh: single = 0.0): TBitmap;

  procedure Register;

  const
   BCon : TBoxCon = (ConT:cNone;
                     Con: Nil);
   // -1 set to dot                            fBDot
   // -2 set to line                           fBLine
   // -3 set to custom from data array         fBCustom
   // -4 set to defautl to rec and data array  fBDef
   fBDot    : single = -1.0;
   fBLine   : single = -2.0;
   fBCustom : single = -3.0;
   fBDef    : single = -4.0;


implementation


type
 THackControl = class(TControl);
var
 Registered : Boolean = False;

{$REGION 'implementation of Functions'}

function MakeScaleScreenshot(Sender:TControl;const dw: single = 0.0; const dh: single = 0.0): TBitmap;
var
  fScreenScale: Single;
  w, h : single;
  function GetScreenScale: Single;
  var
    ScreenService: IFMXScreenService;
  begin
    Result := 1;
    if TPlatformServices.Current.SupportsPlatformService (IFMXScreenService, IInterface(ScreenService)) then
    begin
      Result := ScreenService.GetScreenScale;
    end;
  end;
begin
  fScreenScale := GetScreenScale;
  if dw = 0.0 then w := Sender.Width*fScreenScale
  else w:= Round(dw*fScreenScale);
  if dh = 0.0 then h := Sender.Height*fScreenScale
  else h:=dh*fScreenScale;

  Result := TBitmap.Create(Round(w),Round(h));
  Result.Clear(0);
  if Result.Canvas.BeginScene then
  try
    Sender.PaintTo(Result.Canvas, RectF(0,0,w,h));
  finally
    Result.Canvas.EndScene;
  end;
end;


 //get if a particular bit is 1
function BitGet(const aValue: Cardinal; const Bit: Byte): Boolean;
begin
  Result := (aValue and (1 shl Bit)) <> 0;
end;

//set a particular bit as 1
function BitSet(const aValue: Cardinal; const Bit: Byte): Cardinal;
begin
  Result := aValue or (1 shl Bit);
end;

//set a particular bit as 0
function BitClear(const aValue: Cardinal; const Bit: Byte): Cardinal;
begin
  Result := aValue and not (1 shl Bit);
end;

//Enable o disable a bit
function BitEnable(const aValue: Cardinal; const Bit: Byte; const Flag: Boolean): Cardinal;
begin
  Result := (aValue or (1 shl Bit)) xor (Integer(not Flag) shl Bit);
end;

function Int2Bin(i : cardinal; n: byte) : shortstring;
var
 b: byte;
 c: char;
begin
result := '';
  for b := 0 to n-1 do
   if BitGet(i,b) then result := '1'+ result
   else result := '0'+result;
end;

function Bin2Int(s : shortstring): Cardinal;
var
 b,j: byte;
  i : Cardinal;
begin
  j := 0;
  result:=0;
  for b := length(s) downto 1 do
  begin
    result:= BitEnable(result,j,(s[b] = '1'));
    inc(j);
  end;
end;

function Kvin2Char( kb : byte) : ansichar;
begin
  kb := kb shr 3;
  case kb of
   1..26: result := AnsiChar(kb+96);
   27: result:= '@';
   28: result:= '_';
   29: result:= '-';
   30: result:= '.';
   31: result:= ':';
   else result:='?';
  end;
end;

function Char2kvin( ch : AnsiChar;const b: byte = 0) : byte;
begin
 case ch of
  'A'..'Z': result := Ord(ch)-64;
  'a'..'z': result := Ord(ch)-96;
  '@' : result := 27;
  '_' : result := 28;
  '-' : result := 29;
  '.' : result := 30;
  ':' : result := 31;
  else result:=0;
 end;
 result := (result shl 3) +b;
end;

function Get8RBits( tb : byte;nb:byte ) : byte;
begin
  result := tb shl (8-nb);
  result := result shr (8-nb);
end;

function Get16RBits( tb : word;nb:byte ) : word;
begin
  result := tb shl (16-nb);
  result := result shr (16-nb);
end;

function Get32RBits( tb : cardinal;nb:byte ) : cardinal;
begin
  result := tb shl (32-nb);
  result := result shr (32-nb);
end;

function Get8LBits( tb : byte;nb:byte ) : byte;
begin
  result := result shr (8-nb);
end;

function Get16LBits( tb : word;nb:byte ) : word;
begin
  result := result shr (16-nb);
end;

function Get32LBits( tb : cardinal;nb:byte ) : cardinal;
begin
  result := result shr (32-nb);
end;


procedure SetObjectSize(var objpar;st:TSetSize;sz : single);
var
  cy,cx,dx,dy:single;
  obj : TControl;
begin
  obj := TControl(objpar);
  cx := obj.Position.X + (obj.Size.Width /2);
  cy := obj.Position.Y + (obj.Size.Height /2);
  dx := obj.Size.Width;
  dy := obj.Size.Height;
//  obj.BeginUpdate;
  case st of
    ssAbs: begin
       obj.Position.X:= cx - (sz / 2);
       obj.Position.Y:= cy - (sz / 2);
       obj.Size.Width := cx;
       obj.Size.Height := cy;
    end;
    ssBy: begin
       obj.Position.X := obj.Position.X - sz;
       obj.Position.Y := obj.Position.Y - sz;
       obj.Size.Width := dx + (sz * 2);
       obj.Size.Height := dy + (sz * 2);
    end;

  end;

//  obj.EndUpdate;
end;

procedure SetObjectPos(var objpar;st:TSetSize;sx,sy:single);
var
  cy,cx,dx,dy:single;
  obj : TControl;
begin
  obj := TControl(objpar);
  cx:= obj.Position.X + (obj.Size.Width /2);
  cy:= obj.Position.Y + (obj.Size.Height /2);
  dx := obj.Size.Width;
  dy := obj.Size.Height;
  case st  of
    ssAbs:begin
      obj.Position.X := sx - (dx / 2);
      obj.Position.Y := sy - (dy / 2);
    end ;
    ssBy: begin
      obj.Position.X := obj.Position.X + sx;
      obj.Position.Y := obj.Position.Y + sy;
    end;

  end;

end;

procedure SetObjectScale(var objpar;st:TSetSize;sz : single);
var
  cy,cx,dx,dy,sx,sy:single;
  obj : THackControl;
begin
  obj := THackcontrol(objpar);
  sx:= obj.Scale.X;
  sy:= obj.Scale.Y;
  dx := obj.Size.Width;
  dy := obj.Size.Height;
  cx:= (obj.Position.X + ((dx*sx) /2));
  cy:= (obj.Position.Y + ((dy*sy) /2));
  case st of
    ssAbs: begin
      obj.Scale.X := sz;
      obj.Scale.Y := sz;
    end;
    ssAbsCent: begin
      obj.Position.X := cx - ((dx*sz) /2);
      obj.Position.Y := cy - ((dy*sz) /2);
      obj.Scale.X := sz;
      obj.Scale.Y := sz;
    end;
    ssBy: begin
      obj.Scale.X := sx+sz;
      obj.Scale.Y := sy+sz;
    end ;
    ssByCent: begin
      obj.Scale.X := sx+sz;
      obj.Scale.Y := sy+sz;
      obj.Position.X := obj.Position.X - ( (dx*sz) /2);
      obj.Position.Y := obj.Position.Y - ( (dy*sz) /2);
    end;
  end;
end;

procedure SetObjectPad(var objpar;st:TSetSize;sz : single);
var
   obj : TControl;
begin
  obj := TControl(objpar);

  case st of
    ssAbs:begin
       obj.Padding.Bottom := sz;
       obj.Padding.Left:= sz;
       obj.Padding.Right := sz;
       obj.Padding.Top := sz;
    end;
    ssBy:begin
       obj.Padding.Bottom := obj.Padding.Bottom + sz;
       obj.Padding.Left:= obj.Padding.Left + sz;
       obj.Padding.Right := obj.Padding.Right + sz;
       obj.Padding.Top := obj.Padding.Top +  sz;
    end;
  end;

end;
procedure SetObjectMrg(var objpar;st:TSetSize;sz : single);
var

  obj : TControl;
begin
  obj := TControl(objpar);

  case st of
    ssAbs:begin
       obj.Margins.Bottom := sz;
       obj.Margins.Left:= sz;
       obj.Margins.Right := sz;
       obj.Margins.Top := sz;
    end;
    ssBy:begin
       obj.Margins.Bottom := obj.Margins.Bottom + sz;
       obj.Margins.Left:= obj.Margins.Left + sz;
       obj.Margins.Right := obj.Margins.Right + sz;
       obj.Margins.Top := obj.Margins.Top +  sz;
    end;
  end;

end;


function CRtoTag(col,row: SmallInt) : string;
begin
  result:= IntToStr(col)+':'+IntToStr(row);
end;

Procedure TagToCR(ts:string;var col,row: SmallInt);
var
 i: byte;
begin
 col := -1; row:=-1;
 i:= pos(':',ts);
 if (Length(ts)<=1) or (i <=1) then Exit;

 row := StrToInt(Copy(ts,i+1,Length(ts)));
 Delete(ts,i,Length(ts));
 col := StrToInt(ts);
end;

{$ENDREGION}

procedure TExtForm.AfterConstruction;
begin
 Inherited;
 //
end;

{$REGION 'implementation of TBlinkCircle'}

constructor TBlinkCircle.Create(AOwner: TComponent);

begin
  inherited;
  Stroke.Color := claNull;
  Stroke.Kind := TBrushKind.None;
  Fill.Color := claCrimson;
//  Size.Width:=7;
 // Size.Height:=7;
 // Anchors := [TAnchorKind.akRight,TAnchorKind.akBottom];
  FxSize:=1.2;
  FxBlink := blRing;
  FxBlinkCount := 3;
  fxBlinkNum := 0;
  FxCircle := TCircle.Create(self);
  FxCircle.SetSubComponent(True);
  FxCircle.Stored := False;
  FxCircle.Parent := Self;
  FxCircle.Align := TAlignLayout.Client;
  FxCircle.Margins.Left := FxSize;
  FxCircle.Margins.Right := FxSize;
  FxCircle.Margins.Top := FxSize;
  FxCircle.Margins.Bottom := FxSize;
  FxCircle.Stroke.Kind := TBrushKind.None;
  FxCircle.Stroke.Color := claNull;
  FxCircle.Fill.Color := claNull;
  FxCircle.HitTest := False;
  FTimer := TTimer.Create(self);
  FTimer.SetSubComponent(true);
  FTimer.Enabled := False;
  FTimer.Interval := 400;
  FInterval := 400;
  FTimer.OnTimer :=  onTimerEvent;
  FxFill := TBrush.Create(TBrushKind.Solid, claCrimson);
  FxFill.OnChanged := FillChanged;
  FXStroke := TStrokeBrush.Create(TBrushKind.Solid, claCrimson);
  FXStroke.OnChanged := StrokeChanged;

///
end;

constructor TBlinkCircle.Create(AOwner: TComponent; avisible:boolean; aParent:TFmxObject);
begin
  inherited Create(AOwner);
  Stroke.Color := claNull;
  Stroke.Kind := TBrushKind.None;
  Fill.Color := claCrimson;
  Size.Width:=7;
  Size.Height:=7;
  FxBlink := blRing;
  FxBlinkCount := 3;
  fxBlinkNum := 0;
  //Anchors := [TAnchorKind.akRight,TAnchorKind.akBottom];
  Visible := avisible;
  Parent := aParent;
  Position.X := TControl(aParent).Size.Width - size.Width - 2;
  Position.Y := TControl(aParent).Size.Height - size.Height - 2;
  FxSize:=1.2;
  FxCircle := TCircle.Create(self);
  FxCircle.SetSubComponent(True);
  FxCircle.Stored := False;
  FxCircle.Parent := Self;
  FxCircle.Align := TAlignLayout.Client;
  FxCircle.Margins.Left := FxSize;
  FxCircle.Margins.Right := FxSize;
  FxCircle.Margins.Top := FxSize;
  FxCircle.Margins.Bottom := FxSize;
  FxCircle.Stroke.Kind := TBrushKind.None;
  FxCircle.Stroke.Color := claNull;
  FxCircle.Fill.Color := claNull;
  FxCircle.HitTest := False;
  FTimer := TTimer.Create(self);
  FTimer.SetSubComponent(true);
  FTimer.Enabled := False;
  FTimer.Interval := 400;
  FInterval := 400;
  FTimer.OnTimer :=  onTimerEvent;
  FxFill := TBrush.Create(TBrushKind.Solid, claCrimson);
  FxFill.OnChanged := FillChanged;
  FXStroke := TStrokeBrush.Create(TBrushKind.Solid, claCrimson);
  FXStroke.OnChanged := StrokeChanged;


///
end;

procedure TBlinkCircle.SetBlinkType(const Value: TBlinkType);
begin
//  SetBlinking(False);
  FxBlink := Value;
  FxCircle.Margins.Left := FxSize;
  FxCircle.Margins.Right := FxSize;
  FxCircle.Margins.Top := FxSize;
  FxCircle.Margins.Bottom := FxSize;
  Self.Fill.Kind := TBrushKind.Solid;
  if FisBlinking then
  begin
   case FxBlink of
    blBig,blsmall: begin
      FxCircle.Stroke.Kind := TBrushKind.None;
      FxCircle.Fill.Kind := TBrushKind.Solid;
    end;
    blRing: begin
      FxCircle.Stroke.Kind := TBrushKind.Solid;
      FxCircle.Fill.Kind := TBrushKind.None;
    end;
   end;
  end
  else
  begin
   case FxBlink of
    blBig,blsmall: begin
      FxCircle.Stroke.Kind := TBrushKind.None;
      FxCircle.Fill.Kind := TBrushKind.None;
    end;
    blRing: begin
      FxCircle.Stroke.Kind := TBrushKind.Solid;
      FxCircle.Fill.Kind := TBrushKind.None;
    end;
   end;
  end;
end;

procedure TBlinkCircle.onTimerEvent(Sender: TObject);
begin
 case FxBlink of
   blBig:begin
     if FxCircle.Fill.Kind = TBrushKind.None then FxCircle.Fill.Kind := TBrushKind.Solid;
     if Self.Fill.Kind = TBrushKind.None then Self.Fill.Kind := TBrushKind.Solid
     else Self.Fill.Kind := TBrushKind.None
   end;
   blSmall:begin
     if FxCircle.Fill.Kind = TBrushKind.None then FxCircle.Fill.Kind := TBrushKind.Solid
     else FxCircle.Fill.Kind := TBrushKind.None
   end;
   blRing: begin
     inc(fxBlinkNum);
     if fxBlinkNum  > FxBlinkCount then fxBlinkNum := 0;
//     if fxBlinkNum = 0 then FxCircle.Fill.Kind := TBrushKind.None;
     if fxBlinkNum = 0 then SetObjectMrg(fxcircle,ssAbs,0);
 //    if (fxBlinkNum > 0) and (fxBlinkNum  <= FxBlinkCount) then FxCircle.Stroke.Kind := TBrushKind.Solid
 //    else FxCircle.Stroke.Kind := TBrushKind.None;
     if (fxBlinkNum > 0) and (fxBlinkNum  <= FxBlinkCount) then SetObjectMrg(fxcircle,ssby,-(fxsize*fxblinknum));
   end;
 end;
// if Circle1.Fill.Color = claRed then Circle1.Fill.color := claGreen
// else Circle1.Fill.Color := claRed
end;


destructor TBlinkCircle.Destroy;
begin
///  FreeAndNil(FPath);
   FTimer.Enabled:= False;
   FTimer.Free;
   FxCircle.Free;
   FxFill.Free;
  inherited;
end;

procedure TBlinkCircle.StrokeChanged(Sender: TObject);
begin
    if  FxCircle.Stroke.Color <> FXStroke.Color then FxCircle.Stroke := FXStroke;
  //  if  self.Fill.Color <> FxFill.Color then self.Fill.Color := FxFill.Color;
     if FUpdating = 0 then
    Repaint;
end;


procedure TBlinkCircle.FillChanged(Sender: TObject);
begin
    if  FxCircle.Fill.Color <> FxFill.Color then FxCircle.Fill := FxFill;
  //  if  self.Fill.Color <> FxFill.Color then self.Fill.Color := FxFill.Color;
     if FUpdating = 0 then
    Repaint;
end;

procedure TBlinkCircle.SetSize(const Value: Single);
begin
  FxSize := Value;
  FxCircle.Margins.Left := FxSize;
  FxCircle.Margins.Right := FxSize;
  FxCircle.Margins.Top := FxSize;
  FxCircle.Margins.Bottom := FxSize;
  FillChanged(self);
end;

procedure TBlinkCircle.SetInterval(const Value: SmallInt);
begin
  finterval := value;
  ftimer.Interval := FInterval;
end;

procedure TBlinkCircle.SetBlinking(const Value: Boolean);
begin
  FisBlinking := Value;
  fxBlinkNum :=0;
  ftimer.Interval := FInterval;
  if Value then
  begin
   case FxBlink of
    blBig,blsmall: begin
      FxCircle.Stroke.Kind := TBrushKind.None;
      FxCircle.Fill.Kind := TBrushKind.Solid;
    end;
    blRing: begin
      FxCircle.Stroke.Kind := TBrushKind.Solid;
      FxCircle.Fill.Kind := TBrushKind.None;
    end;
   end;
  end;
  FTimer.Enabled:= Value;
  if not value then Self.Fill.Kind := TBrushKind.Solid;
  if not value then FxCircle.Fill.Kind := TBrushKind.None;
  if not value then FxCircle.Stroke.Kind := TBrushKind.None
end;


procedure TBlinkCircle.SetFill(const Value: TBrush);
begin
  FxFill.Assign(Value);
//  FxCircle.Fill := FxFill;
//  self.Fill.Color := FxFill.Color;
end;

procedure TBlinkCircle.SetStroke(const Value: TStrokeBrush);
begin
  FXStroke.Assign(Value);
//  FxCircle.Fill := FxFill;
//  self.Fill.Color := FxFill.Color;
end;

{$ENDREGION}


{$REGION 'implementation of TiGridPanel'}

constructor TiGridPanel.Create(AOwner: TComponent);
begin
  inherited;
  FTable.Ver := 0.01;
  FTable.Row :=0;
  FTable.Col :=0;
  FTable.Dash := TStrokeDash.Solid;
  FCurCell.Col := -1;
  FOldCell.Col := -1;
  SetLength(Ftable.Table,0,0);
  FTabW := Self.Width;
  FTabH := Self.Height;
  isEditMode := False;
  FDefCellW := 60;
  FDefCellH := 21;
  FDefSColor := claBlack;
  FDefFColor:= claNull;
  FDefFColor1:= claAliceblue;
  FDefFColor2:= claDarkgray;
  fCellMenu:= nil;
  isTwoColors:= false;
end;

destructor TiGridPanel.Destroy;
begin
///
  inherited;
end;

procedure TiGridPanel.Resize;
begin
  inherited;
//  FTabW := Self.Width;
//  FTabH := Self.Height;

 // FRecalcCellSizes := True;
end;

Function BorderInGrid(grC, grR, col, row: SmallInt) : TSides;
var
  ss: TSides;
begin

  if (col in [0..grC-2]) and (row <= grR-2)then ss := [TSide.Top, TSide.Left];
  if    (Col = grC-1) and (row <= grR-2)   then ss := [TSide.Top, TSide.Left, TSide.Right];
  if    (Col = grC-1) and (row = grR-1)    then ss := [TSide.Top,TSide.Bottom, TSide.Left,TSide.Right];
  if (col in [0..grC-2]) and (row = grR-1) then ss := [TSide.Top,TSide.Bottom, TSide.Left];
  result := ss;
end;

procedure TiGridPanel.SetBorder(col,row:SmallInt; rThick: Single; rDash: TStrokeDash= TStrokeDash.Solid;
                                rColor:TAlphaColor = claNull;rSides: TSides = [] );  // color, think, sides, sides in grid
begin
  with  FTable.Table[col,row] do
  begin
   rec.BeginUpdate;
   // -1 set to dot                            fBDot
   // -2 set to line                           fBLine
   // -3 set to custom from data array         fBCustom
   // -4 set to defautl to rec and data array  fBDef
    //    a) line
    //    b) dots
    //    c) none
    //    set to custom from parameters and to data array

    if rThick = fBDot then
    begin
      rec.Stroke.Thickness := 1;
      rec.Stroke.Dash:= TStrokeDash.Dash;
      rec.Stroke.Color := claGray;
      rec.Sides := BorderInGrid(fTable.Col,fTable.Row,col,row);
    end;

    if rThick = fBLine then
    begin
      rec.Stroke.Thickness := 1;
      rec.Stroke.Dash:= TStrokeDash.Solid;
      rec.Stroke.Color := claBlack;
      rec.Sides := BorderInGrid(fTable.Col,fTable.Row,col,row);
    end;

    if rThick = fBDef then
    begin
      Prop.StrokeThik := 1;
      if rDash = TStrokeDash.Custom then Prop.Dash := TStrokeDash.Dash
      else Prop.Dash := rDash;
      if rDash = TStrokeDash.Custom then Prop.Sides := []
      else Prop.Sides := BorderInGrid(FTable.Col,Ftable.Row,col,row);
      Prop.StrokeColor := rColor;
      rec.Stroke.Thickness := Prop.StrokeThik;
      rec.Stroke.Dash:= Prop.Dash;
      rec.Stroke.Color := Prop.StrokeColor;
      rec.Sides := Prop.Sides;
    end;

    //*** set data to array and rectangle
    if rThick >= 0.0 then
    begin
      Prop.StrokeThik := rThick;
      Prop.Dash := rDash;
      Prop.StrokeColor := rColor;
      Prop.Sides := rSides;
    end;

    if (rThick = fBCustom) or (rThick >= 0.0) then
    begin
      rec.Stroke.Thickness := Prop.StrokeThik;
      rec.Stroke.Dash:= Prop.Dash;
      rec.Stroke.Color := Prop.StrokeColor;
      rec.Sides := Prop.Sides;
    end;
    rec.EndUpdate;
  end;
  FTable.Table[col,row].Rec.Repaint;
  ///
end;

Procedure TiGridPanel.CreateCellRec(col,row:SmallInt;fdash:TStrokeDash;th:single;const fgrcolor: TAlphaColor = claBlack);
begin
  With Ftable.Table[col,row] do
  begin
    Prop.Col := Col;
    Prop.Row := Row;
    Prop.W := FDefCellW;
    Prop.H := FDefCellH;
    Prop.Sides := BorderInGrid(Ftable.Col,Ftable.Row,col,row);
    if isTwoColors then
    begin
       Prop.FillKind := TBrushKind.Solid;
       if (row mod 2)= 0 then Prop.FillColor := FDefFColor1
       else Prop.FillColor := FDefFColor2;
    end
    else
    begin
      Prop.FillColor := FDefFColor;
      Prop.FillKind := TBrushKind.None;
    end;
    Prop.StrokeThik := th;
    Prop.StrokeColor := fgrcolor;
    Prop.Dash := fdash;
    Rec:= TRectangle.Create(self);
    Rec.Align := TAlignLayout.Client;
    Rec.Corners := [];
    rec.CornerType := TCornerType.Bevel;
    rec.XRadius := 0;
    rec.YRadius := 0;
    Rec.Fill.Color := Prop.FillColor;
    Rec.Fill.Kind := Prop.FillKind;
    Rec.ClipChildren := True;
    Rec.TagString := CRtoTag(col,row);
    Rec.Stroke.Thickness := Prop.StrokeThik;
    Rec.Stroke.Dash := fdash;
    if fdash = TStrokeDash.Custom then Rec.Stroke.Kind := TBrushKind.None
    else Rec.Stroke.Kind := TBrushKind.Solid;
    Rec.Stroke.Color := fgrcolor;
    if fdash = TStrokeDash.Custom then Rec.Sides := []
                                  else Rec.Sides := Prop.Sides;
    rec.PopupMenu := fCellMenu;
    Con[1] := BCon; Con[2] := BCon;Con[3] := BCon;Con[4] := BCon;
  end;

end;

Procedure TiGridPanel.CreateTable(col,row:smallint; wgrid: boolean; onmoused: TMouseEvent;const th:single=1; const fgrcolor: TAlphaColor = claBlack);
var
i,j : Integer;
rc: TRectangle;
begin
Self.BeginUpdate;
 if Ftable.Col > 0 then
 for j := 0 to Ftable.Row-1 do
    for i := 0 to Ftable.Col-1 do
    begin
    if Ftable.Table[i,j].Rec <> Nil then
      begin
        Ftable.Table[i,j].Rec.Free;
        Ftable.Table[i,j].Rec := Nil;
      end;
    end;
 SetLength(FTable.Table,0,0);
 Self.ControlCollection.Clear;
 Self.ColumnCollection.Clear;
 Self.RowCollection.Clear;

 if col > 27 then col:= 27; if row > 250 then row:=250;

 Ftable.Row := row; FTable.Col := col;
 if wgrid then FTable.Dash := TStrokeDash.Solid
 else FTable.Dash := TStrokeDash.Custom;
 SetLength(FTable.Table,col,row);
 Self.Enabled:= False;
 for I := 0 to col-1 do begin
   Self.ColumnCollection.Insert(i);
   Self.ColumnCollection.Items[i].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
   Self.ColumnCollection.Items[i].Value := FDefCellW;
 end;
 for I := 0 to row-1 do begin
   Self.RowCollection.Insert(i);
   Self.RowCollection.Items[i].SizeStyle := TGridPanelLayout.TSizeStyle.Absolute;
   Self.RowCollection.Items[i].Value := FDefCellH;
 end;
 Self.ControlCollection.BeginUpdate;
 for j := 0 to row-1 do
    for i := 0 to col-1 do
    begin
      if wgrid then CreateCellRec(i,j,TStrokeDash.Solid,th,fgrcolor)
      else CreateCellRec(i,j,TStrokeDash.Custom,0,fgrcolor);
      Ftable.Table[i,j].Rec.OnMouseDown := onmoused;
      Ftable.Table[i,j].Con[4].Con :=  TBlinkCircle.Create(self,false,Ftable.Table[i,j].Rec);
      Ftable.Table[i,j].Con[4].ConT := TBoxType.cSignal;
      Self.ControlCollection.AddControl(Ftable.Table[i,j].Rec,i,j);
      Ftable.Table[i,j].Rec.Parent := Self;
    end;
 Self.ControlCollection.EndUpdate;
 FTabW := FDefCellW * Col;
 FTabH := FDefCellH * Row;
 Self.Size.Width := FTabW;
 Self.Size.Height := FTabH;
 Self.Enabled:= True;
 Self.EndUpdate;
 FOldCell.Col := -1;
 end;

procedure TiGridPanel.SetFill(col,row:SmallInt; aColor:TAlphaColor; aKind:TBrushKind= TBrushKind.Solid);
begin
  if aColor = claNull then FTable.Table[col,row].Rec.Fill.Kind := TBrushKind.None
  else FTable.Table[col,row].Rec.Fill.Kind := aKind;
  FTable.Table[col,row].Rec.Fill.Color:=aColor;
end;

function TiGridPanel.GetFill(col,row:SmallInt;var aKind:TBrushKind):TAlphaColor;
begin
  aKind:= FTable.Table[col,row].Rec.Fill.Kind;
  result := FTable.Table[col,row].Rec.Fill.Color
end;


Procedure TiGridPanel.CellSetValue(col,row:SmallInt; value: string);
begin
  //
end;
Procedure TiGridPanel.CellSetValue(col,row:SmallInt; value: Integer);
begin
  //
end;
Procedure TiGridPanel.CellSetValue(col,row:SmallInt; value: Single);
begin
  //
end;
Procedure TiGridPanel.CellgetValue(col,row:SmallInt; var value: string);
begin
  //
end;
Procedure TiGridPanel.CellgetValue(col,row:SmallInt; var value: Integer);
begin
  //
end;
Procedure TiGridPanel.CellgetValue(col,row:SmallInt; var value: Single);
begin
  //
end;

{$ENDREGION}

{$REGION 'implementation of TGRecxtangle'}

constructor TGRectangle.Create(AOwner: TComponent);
begin
  inherited;
  FColorMouseEnter := claDarkGray;
  FColorMouseLeave := claBeige;
  FColorMouseDown := claBlack;

  FGlyph := TGlyph.Create(self);
  FGlyph.Name := Self.Name + '_pic';
  FGlyph.SetSubComponent(true);
  FGlyph.Stored := False;
  FGlyph.Parent := Self;
  FGlyph.Align :=  TAlignLayout.Client;
  FGlyph.Margins.Top := 1;
  FGlyph.Margins.Bottom := 1;
  FGlyph.Margins.Left := 1;
  FGlyph.Margins.Right := 1;
  FOpacityME := 1;
  FOpacityML := 0.5;
  Opacity := FOpacityML;
  Fill.Color := claNull;
  Fill.Kind := TBrushKind.None;
  Stroke.Thickness := 0.5;
  Stroke.Color := FColorMouseLeave;
//  CornerType := TCornerType.Bevel;
  XRadius := 2;
  YRadius := 2;
  Size.Height := 17;
  Size.Width := 17;

end;

procedure TGRectangle.SetXRadius(const Value: Single);
var
  NewValue: Single;
begin
 if Value <> XRadius then
  begin
    inherited SetXRadius(Value);
    Repaint;
  end;
{  if csDesigning in ComponentState then
    NewValue := Min(Value, Min(Width / 2, Height / 2))
  else
    NewValue := Value;
  if not SameValue(THackRect(self).FXRadius, NewValue, TEpsilon.Vector) then
  begin
    THackRect(self).FXRadius := NewValue;
    Repaint;
  end}
end;

procedure TGRectangle.SetYRadius(const Value: Single);
var
  NewValue: Single;
begin
 if Value <> YRadius then
  begin
    inherited SetYRadius(Value);
    Repaint;
  end;
{
  if csDesigning in ComponentState then
    NewValue := Min(Value, Min(Width / 2, Height / 2))
  else
    NewValue := Value;
  if not SameValue(THackRect(self).FYRadius, NewValue, TEpsilon.Vector) then
  begin
    THackRect(self).FYRadius := NewValue;
    YRadius := NewValue;
    Repaint;
  end;}
end;


procedure TGRectangle.DoMouseEnter;
begin
inherited;
 Stroke.Color := FColorMouseEnter;
 Opacity := FOpacityME;
  //
end;
procedure TGRectangle.DoMouseLeave;
begin
inherited;
 Stroke.Color := FColorMouseLeave;
 Opacity := FOpacityML;
  //
end;

procedure TGRectangle.SetMouseLeave(const Value: TAlphaColor);
begin
  FColorMouseLeave := Value;
  Stroke.Color:= Value;
end;

procedure TGRectangle.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
 Stroke.Color := FColorMouseDown;
inherited;
  //
end;
procedure TGRectangle.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
 Stroke.Color := FColorMouseEnter;
inherited;
  //
end;

{$ENDREGION}

{$REGION 'implementation of TWinRectangle'}

procedure TWinRectangle.SetScaleWin(var pan:TFmxObject; x,y: single);
begin
 if pan is TForm then
 begin

 end
 else
 begin
 Tpanel(pan).Scale.X:= x;
 TPanel(pan).Scale.Y:= y;

 end;
end;

procedure TWinRectangle.SetScaleWin( var pan:TWinrectangle; x,y: single);
begin
 pan.Scale.X:= x;
 pan.Scale.Y:= y;
end;

procedure TWinRectangle.GetScaleWin( var pan:TFmxObject; var x,y: single);
begin
 x:= TPanel(pan).Scale.X;
 y:= TPanel(pan).Scale.Y;
end;

procedure TWinRectangle.GetScaleWin( var pan:TWinrectangle; var x,y: single);
begin
 x:= pan.Scale.X;
 y:= pan.Scale.Y;
end;

procedure TWinRectangle.SetShadow(Const Value : Boolean);
begin
 FShadowed := Value;
 FShadow.Enabled := Value;
 StrokeChanged(self);
end;

constructor TWinRectangle.Create(AOwner: TComponent);

begin
  inherited;
  FMovable := True;
  FResizable:= True;
  FShadowed:= False;
  FParent := Parent;
  AutoCapture := True;
  FHeadBorder := True;
  fShadowOff := False;
  FColor1 :=  claRed;
  FColor2 :=  claGreen;
  FColor3 :=  claYellowgreen;
  FMainStroke:= claBlack;
  fscalx := 1; fscaly := 1;
  FMinWidth :=  110;
  FMinHeight := 90;
  FMaxWidth :=  1000;
  FMaxHeight := 1000;
  FHeadSize := 25;
  FStrokelo := TStrokeBrush.Create(TBrushKind.Solid, claBlack);
  fstrokelo.Dash :=  TStrokeDash.Solid;
  FStrokelo.Thickness := 0.5;
  FFillHeader := TBrush.Create(TBrushKind.Solid,$FF424548);
  FStrokeLo.OnChanged := StrokeChanged;
  FFillHeader.OnChanged := StrokeChanged;
  FUseParent := False;
  FExpand := True;
//  FNormalSize:= Height;
  ClipChildren := True;
  FmyTimer := TTimer.Create(self);
  FmyTimer.SetSubComponent(true);
  FmyTimer.Enabled := False;
  FmyTimer.Interval := 70;
  fCountTick := 0;
  FMoveMode := 0;
  FmyTimer.OnTimer :=  onTimerEvent;
  FFirstPaint := True;
  FShowGrip:= False;
  FGrip := TSizeGrip.Create(Self);
  FGrip.SetSubComponent(true);
  FGrip.Stored := False;
  FGrip.Parent := Self;
  FGrip.Height:=16; FGrip.Width:=16;
  FGrip.HitTest := False;
  FGrip.Locked:= True;
  FGrip.Visible:= False;
  FGrip.Anchors := [TAnchorKind.akRight,TAnchorKind.akBottom];
 { FHImage1 := TTMSFMXBitmap.Create(self);
  fhimage1.Name := self.Name+'_ima1';
  FHImage1.SetSubComponent(true);
  FHImage1.Stored := False;
  FHImage1.Parent := Self;
  FHImage1.Height:=16; FHImage1.Width:=16;
  FHImage1.Position.X:=4; FHImage1.Position.Y:= (FHeadSize - 16)/2;
  FHImage1.AspectRatio:= True; FHImage1.AutoSize:= True; FHImage1.ClipChildren:= True;
  FHImage1.Center:= True;
  FHImage1.Opacity := 0.4;
  FHImage1.OnMouseEnter := onPicMouseEnter; FHImage1.OnMouseLeave := onPicMouseLeave;
  FHImage2 := TTMSFMXBitmap.Create(self);
  fhimage2.Name := self.Name+'_ima2';
  Fhimage2.SetSubComponent(true);
  FHImage2.Stored := False;
  FHImage2.Parent := Self;
  FHImage2.Height:=16; FHImage2.Width:=16;
  FHImage2.Position.X:=24; FHImage2.Position.Y:= (FHeadSize - 16)/2;
  FHImage2.AspectRatio:= True; FHImage2.AutoSize:= True; FHImage2.ClipChildren:= True;
  FHImage2.Center:= True;
  FHImage2.Opacity := 0.4;
  FHImage2.OnMouseEnter := onPicMouseEnter; FHImage2.OnMouseLeave := onPicMouseLeave;
  FHImage3 := TTMSFMXBitmap.Create(self);
  fhimage3.Name := self.Name+'_ima3';
  FHImage3.SetSubComponent(true);
  FHImage3.Stored := False;
  FHImage3.Parent := Self;
  FHImage3.Height:=16; FHImage3.Width:=16;
  FHImage3.Position.X:=44; FHImage3.Position.Y:= (FHeadSize - 16)/2;
  FHImage3.AspectRatio:= True; FHImage3.AutoSize:= True; FHImage3.ClipChildren:= True;
  FHImage3.Center:= True;
  FHImage3.Opacity := 0.4;
  FHImage3.OnMouseEnter := onPicMouseEnter; FHImage3.OnMouseLeave := onPicMouseLeave;
  FHImage4 := TTMSFMXBitmap.Create(self);
  fhimage4.Name := self.Name+'_ima4';
  FHImage4.SetSubComponent(true);
  FHImage4.Stored := False;
  FHImage4.Parent := Self;
  FHImage4.Height:=16; FHImage4.Width:=16;
  FHImage4.Position.X:=Width-20; FHImage4.Position.Y:= (FHeadSize - 16)/2;
  FHImage4.AspectRatio:= True; FHImage4.AutoSize:= True; FHImage4.ClipChildren:= True;
  FHImage4.Center:= True;
  FHImage4.Anchors := [TAnchorKind.akRight,TAnchorKind.akTop];
  FHImage4.Opacity := 0.4;
  FHImage4.OnMouseEnter := onPicMouseEnter; FHImage4.OnMouseLeave := onPicMouseLeave; }
  FHText := TLabel.Create(Self);
  FHText.Name := self.Name + 'Head';
  FHText.SetSubComponent(true);
  FHText.Stored := False;
//  FHText.Name := Self.Name + 'Header';
  FHText.Parent := Self;
  FHText.Position.X := 64; FHText.Position.Y:= (FHeadSize - 16)/2;
  FHText.Height := 16; FHText.Width := Width-84;
  FHText.Text:= 'WinRectangle';
  FHText.Anchors := [TAnchorKind.akLeft,TAnchorKind.akTop,TAnchorKind.akRight];
  FHText.Locked:=True;
  FHText.TextSettings.HorzAlign := TTextAlign.Center;
  FHText.HitTest := False;
  FHText.ClipChildren := True;
  FShadow := TShadowEffect.Create(self);
  FShadow.SetSubComponent(true);
  FShadow.Stored := False;
  FShadow.Parent := Self;
  FShadow.Enabled := False;
  FShadow.Direction := 45;
  FShadow.Distance := 2;
  FShadow.Opacity := 0.3;
  FShadow.ShadowColor := claBlack;
  FShadow.Softness := 0.3;
  if not Registered then
  begin
//    RegisterClasses( [ TWinRectangle ] );
    Registered := True;
  end;


end;

function TWinRectangle.CloneWin(const AOwner: TComponent) : TWinRectangle;
begin
  Result := TWinRectangle(Self.Clone(AOwner));
end;

{procedure TWinRectangle.onPicMouseEnter(Sender: TObject);
begin
  if  (sender as  TTMSFMXBitmap).BitmapName = '' then exit;
  (sender as  TTMSFMXBitmap).Opacity := 1;
// if Assigned((sender as  TTMSFMXBitmap).OnMouseEnter) then (sender as  TTMSFMXBitmap).OnMouseEnter(self);
end;
procedure TWinRectangle.onPicMouseLeave(Sender: TObject);
begin
 if  (sender as  TTMSFMXBitmap).BitmapName = '' then exit;
 (sender as  TTMSFMXBitmap).Opacity := 0.4;
// if Assigned((sender as  TTMSFMXBitmap).OnMouseLeave) then (sender as  TTMSFMXBitmap).OnMouseLeave(self);
end;}

procedure TWinRectangle.SetGripp(Const Value: Boolean);
begin
 if FShowGrip = value then exit
                    else FShowGrip:= Value;
 if FShowGrip then
 begin
   FGrip.Position.Y := Self.Height - FGrip.Height-2;
   FGrip.Position.X := Self.Width - FGrip.Width-2 ;
   FGrip.BringToFront;
   FGrip.Visible:=True;
 end
 else FGrip.Visible:= False;
 StrokeChanged(self);
end;

procedure TWinRectangle.onTimerEvent(Sender: TObject);
begin
 Inc(fCountTick);
 if fCountTick >= 2 then
 begin
   FmyTimer.Enabled := False;
   if Assigned(FSelectMove) then FSelectMove(Self, FMoveMode)
   else
   begin
     FPressed := True;
     fCountTick := 0;
     if FMoveMode = 1 then  Stroke.Color := FColor1;
     if FMoveMode = 2 then  Stroke.Color := FColor2;
     if FMoveMode = 3 then  Stroke.Color := FColor3;
      Stroke.Thickness := 1.5; //0.5;
      //Stroke.Dash := TStrokeDash.DashDot;
 //     isShadowed := False;
   end;
   StrokeChanged(self);
 end;

end;

 procedure TWinRectangle.StrokeChanged(Sender: TObject);
begin
  if FUpdating = 0 then
  begin
    UpdateEffects;
    Repaint;
//    if FShadowed then (parent as TControl).Repaint;

  end;
end;

procedure TWinRectangle.SetExpand(Const Value: Boolean);
begin
 if FExpand = value then exit
                    else FExpand:= Value;
  FGrip.Visible := FExpand and FShowGrip;
  if FExpand then
  begin
   if UseParent then
     begin
       if self.parent is TForm then (self.parent as tForm).Height:= Round(FNormalSize)
       else (self.parent as tcontrol).Height:= FNormalSize
     end
    else Height:= FNormalSize;
  end
  else
  begin
   if UseParent then
   begin
     if self.parent is TForm then
     begin
       FNormalSize := (self.parent as tForm).Height;
       (self.parent as tForm).Height := Round(FHeadSize + Stroke.Thickness)
      end
     else
     begin
       FNormalSize := (self.parent as tcontrol).Height;
       (self.parent as tcontrol).Height := FHeadSize + Stroke.Thickness;
     end;
   end
   else begin
    FNormalSize := Height;
    Height := FHeadSize + Stroke.Thickness;
   end;
  end;
  if not (self.parent is TForm) then (self.parent as tcontrol).Repaint;
  StrokeChanged(self);

end;

procedure TWinRectangle.SetStroke(const Value: TStrokeBrush);
begin
  FStrokeLo.Assign(Value);
end;

procedure TWinRectangle.SetFillHeader(const Value : TBrush);
begin
  FFillHeader.Assign(Value);
end;

procedure TWinRectangle.SetHeadSize(const Value: Single);
begin
  if FHeadSize = value then exit;
  if value  > 16 then FHeadSize := Value
  else FHeadSize:=17;
  if  (FSize.Height > FHeadSize) and FExpand then FNormalSize := FSize.Height;

{  FHImage1.Position.X:=4; FHImage1.Position.Y:= (FHeadSize - 16)/2;
  FHImage2.Position.X:=24; FHImage2.Position.Y:= (FHeadSize - 16)/2;
  FHImage3.Position.X:=44; FHImage3.Position.Y:= (FHeadSize - 16)/2;
  FHImage4.Position.X:=Width-20; FHImage4.Position.Y:= (FHeadSize - 16)/2;}
  FHText.Position.X := 64; FHText.Position.Y:= (FHeadSize - 16)/2;
end;

procedure TWinRectangle.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  dx1, dx2, dy1, dy2 : single;
  fo : TFmxObject;
begin
  inherited;
//  if not HitTest then exit;
   if fShadowOff then begin
    if FShadowed then FShadow.Enabled:=False;
    StrokeChanged(self);
   end;
   if UseParent then
   begin
    if self.Parent is TPanel  then dx1:= (self.parent as TPanel).Scale.x;
    if self.Parent is TRectangle  then dx1:= (self.parent as TRectangle).Scale.x;
    if self.Parent is TForm  then dx1:= 1{(self.parent as TRectangle).Scale.x};
    if fscalx <> dx1 then
                 begin
                   fo:= self.parent;
                   GetScaleWin(fo, fscalx,fscaly);
                   SetScaleWin(fo, 1,1);
                 end;
     if self.Parent is TForm then (self.parent as tForm).BringToFront
    else (self.parent as tcontrol).BringToFront;
   end
   else
   begin
     if fscalx <> self.Scale.X then begin
                   GetScaleWin(self, fscalx,fscaly);
                   SetScaleWin(self, 1,1);
                 end;
     self.BringToFront;
   end;

  if not FExpand then
  begin
    FMoveMode:=1;
  end
  else
  begin
    dx1 := Width - 20; dx2:= width;
    dy1 := Height - 20; dy2 := Height;
    if (Y <= FHeadSize) then FMoveMode:=1
    else
      if (((X >= dx1) and (X<=dx2)) and ((y>=dy1) and (Y<=dy2)) )then
      begin
        if not (ssAlt in Shift) then FMoveMode:=2
        else FMoveMode:=3
      end
      else Exit;
  end;
  if FMoveMode = 1 then if not FMovable then Exit;
  if FMoveMode = 2 then if not FResizable then Exit;

  FMainStroke := Stroke.Color;
  FmyTimer.Enabled:=True;
//  FPressed := True;
  FStartPos := TPointF.Create(X*fscalx, Y*fscaly);
//  fishadow := FShadowed;
  if FMoveMode = 2 then  if self.Parent is TForm  then (self.parent as tForm).StartWindowResize;
  if self.Parent is TForm  then (self.parent as tForm).BringToFront;
end;
procedure TWinRectangle.MouseMove(Shift: TShiftState; X, Y: Single);
var
  MoveVector: TVector;
  dx, dy : single;
begin
 if FPressed then
  begin
    // ¬ычисл€ем локальное смещение относительно первоначальной позиции
     MoveVector := TVector.Create(X - FStartPos.X, Y - FStartPos.Y, 0);
     dx := MoveVector.X;
     dy := MoveVector.Y;
    // ¬ычисл€ем смещение в координатах формы, чтобы учесть изменение
    // координат при смещении родительских контролов
    MoveVector := self.LocalToAbsoluteVector(MoveVector);
    if self.ParentControl <> nil then
      MoveVector := self.ParentControl.AbsoluteToLocalVector(MoveVector);
    // ѕеремещаем картинку на вычисленный вектор
    // ƒл€ RAD Studio XE5
//    self.Position.Point := self.Position.Point + MoveVector.ToPointF;
    // ƒл€ новых версий
    if FMoveMode = 1 then
    begin
       if self.Parent is TForm  then (self.Parent as TfOrm).StartWindowDrag
       else
       begin
         if useparent then (self.parent as tcontrol).Position.Point := (self.parent as tcontrol).Position.Point + TPointF(MoveVector)
         else self.Position.Point := self.Position.Point + TPointF(MoveVector);
       end;
  // Repaint;

    end;
    if FMoveMode = 2 then
    begin

//      dx := MoveVector.X;
//      dy := MoveVector.Y;
        if useparent then
        begin
            if self.Parent is TForm then
            begin
              if (self.parent as TForm).Width + dx <= FMinWidth then (self.parent as TForm).Width := Round(FMinWidth)
              else
                if (self.parent as TForm).Width + dx >= FMaxWidth then (self.parent as TForm).Width := Round(FMaxWidth)
                else (self.parent as TForm).Width := (self.parent as TForm).Width + Round(dx);
              if (self.parent as TForm).Height + dy <= FMinHeight then (self.parent as TForm).Height := Round(FMinHeight)
              else
                if (self.parent as TForm).Height + dy >= FMaxHeight then (self.parent as TForm).Height := Round(FMaxHeight)
                else begin

                       (self.parent as TForm).Height := (self.parent as TForm).Height  + Round(dy)
                     end;
                  //  repaint;
             (self.parent as TForm).Invalidate;
            end
            else
            begin
              if (self.parent as tcontrol).Width + dx <= FMinWidth then (self.parent as tcontrol).Width := FMinWidth
              else
                if (self.parent as tcontrol).Width + dx >= FMaxWidth then (self.parent as tcontrol).Width := FMaxWidth
                else (self.parent as tcontrol).Width := (self.parent as tcontrol).Width + dx;
              if (self.parent as tcontrol).Height + dy <= FMinHeight then (self.parent as tcontrol).Height := FMinHeight
              else
                if (self.parent as tcontrol).Height + dy >= FMaxHeight then (self.parent as tcontrol).Height := FMaxHeight
                else (self.parent as tcontrol).Height := (self.parent as tcontrol).Height + dy;

            end;
         Repaint
        end
        else
        begin
           if self.Height + dy <= FMinHeight then self.Height := FMinHeight
           else
             if self.Height + dy >= FMaxHeight then self.Height := FMaxHeight
             else self.Height := self.Height + dy;
           if self.Width + dx <= FMinWidth then  self.Width := FMinWidth
           else
             if self.Width + dx >= FMaxWidth then  self.Width := FMaxWidth
             else self.Width := self.Width + dx;
        end;
        FStartPos.X:=x; FStartPos.y:=y;
    end;
 Repaint;
  if self.Parent is TForm then begin end
  else (self.parent as tcontrol).Repaint;

  end;
 // StrokeChanged(self);
end;

procedure TWinRectangle.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
 fo: TFmxObject;
 dx1: single;
begin
   FmyTimer.Enabled := False;
   fCountTick := 0;
   FPressed := False;
   Stroke.Color := fMainStroke;
   Stroke.Thickness := 1;
   Stroke.Dash := TStrokeDash.Solid;
//   if FMoveMode = 2 then  if self.Parent is TForm  then (self.parent as tForm).EndUpdate;
 //  isShadowed := fishadow;
   FMoveMode := 0;
//   if UseParent then (self.parent as tcontrol).BringToFront
//   else self.BringToFront;
   if UseParent then
   begin
    if self.Parent is TPanel  then dx1:= (self.parent as TPanel).Scale.x;
    if self.Parent is TRectangle  then dx1:= (self.parent as TRectangle).Scale.x;

    if fscalx <> dx1 then begin
                   fo:= self.parent;
                   SetScaleWin(fo, fscalx,fscaly);
                 end;
    if self.Parent is TForm then (self.parent as tForm).BringToFront
    else (self.parent as tcontrol).BringToFront;
   end
   else
   begin
     if fscalx <> self.Scale.X then begin
                   SetScaleWin(self, fscalx,fscaly);
                 end;
     self.BringToFront;
   end;
   Fscalx := 1; Fscaly := 1;
     if fShadowOff then begin
    if fshadowed then FShadow.Enabled:=True;
    StrokeChanged(self);
   end;

end;

procedure TWinRectangle.Paint;
var
  R: TRectF;
  Off: Single;
  L1,L2: TPointF;
  FCornersLoc: TCorners;
  FSidesLoc: TSides;

begin


{  R := GetShapeRect;

  if Sides <> AllSides then
  begin
    Off := R.Left;
    if not(TSide.Top in FSides) then
      R.Top := R.Top - Off;
    if not(TSide.Left in FSides) then
      R.Left := R.Left - Off;
    if not(TSide.Bottom in FSides) then
      R.Bottom := R.Bottom + Off;
    if not(TSide.Right in FSides) then
      R.Right := R.Right + Off;
    Canvas.FillRect(R, XRadius, YRadius, FCorners, AbsoluteOpacity, FFill, CornerType);
    Canvas.DrawRectSides(GetShapeRect, XRadius, YRadius, FCorners,  AbsoluteOpacity, Sides, FStroke, CornerType);
  end
  else
  begin
    Canvas.FillRect(R, XRadius, YRadius, FCorners, AbsoluteOpacity, FFill, CornerType);
    Canvas.DrawRect(R, XRadius, YRadius, FCorners, AbsoluteOpacity, FStroke, CornerType);
  end; }
  inherited;
  if FHeadBorder then
  begin
     R := GetShapeRect;
     L1.Create(0,0);
     L2.Create(0,0);
     L1.X:= L1.X+(FStrokelo.Thickness/2);
     if not FExpand then L1.X := L1.X + XRadius;

     L1.Y:= FHeadSize;
     L2.X:= r.Width-(FStrokelo.Thickness/2) ;
     if not FExpand then L2.X := L2.X - XRadius;
     L2.Y:=FHeadSize;
     Canvas.DrawLine(l1,l2,AbsoluteOpacity, fstrokelo);
  end;


  R := GetShapeRect;
  if R.Bottom > FHeadSize then R.Bottom := FHeadSize;
  FSidesLoc := Sides;
  FCornersLoc := Corners;
  Off := R.Left;
  if FExpand and (TCorner.BottomLeft in FCornersLoc) then Exclude(FCornersLoc, TCorner.BottomLeft);
  if FExpand and (TCorner.BottomRight in FCornersLoc) then Exclude(FCornersLoc, TCorner.BottomRight);

  if not(TSide.Top in FSidesLoc) then R.Top := R.Top - Off;
  if not(TSide.Left in FSidesLoc)then R.Left := R.Left - Off;
  if not(TSide.Bottom in FSidesLoc) then R.Bottom := R.Bottom + Off;
  if not(TSide.Right in FSidesLoc) then R.Right := R.Right + Off;
  Canvas.FillRect(R, XRadius, YRadius, FCornersLoc, AbsoluteOpacity, FFillHeader, CornerType);
  StrokeChanged(self);

end;

{$ENDREGION}


{$REGION 'implementation of TSelectionMod'}

constructor TSelectionMod.Create(AOwner: TComponent);
begin
  inherited;
  AutoCapture := True;
  ParentBounds := True;
  FMinSize := 15;
  FGripSize := 3;
  SetAcceptsControls(False);
  FStroke := TStrokeBrush.Create(TBrushKind.Solid, $FF1072C5);
  fstroke.Dash :=  TStrokeDash.Dash;
  FHotColor := TStrokeBrush.Create(TBrushKind.Solid, claRed);
  FStroke.OnChanged := StrokeChanged;
  FHotColor.OnChanged := StrokeChanged;
end;

destructor TSelectionMod.Destroy;
begin
  inherited;
end;

procedure TSelectionMod.Paint;
var
  R: TRectF;
  Fill: TBrush;

  // sets the canvas color depending if the control is enabled and if
  // we need to draw a zone being hot or not
  procedure SelectZoneColor(HotZone: Boolean);
  begin
    if Enabled then
      if HotZone then
        Fill.Color := FHotColor.Color
      else
        Fill.Color := $FFFFFFFF
    else
      Fill.Color := claGrey;
  end;

var
  Stroke: TStrokeBrush;
begin
  if HideSelection then
    Exit;
  R := LocalRect;
  InflateRect(R, -0.5, -0.5);
//  Canvas.DrawDashRect(R, 0, 0, AllCorners, AbsoluteOpacity, fstroke.Color);
      Canvas.DrawRect(R, 0, 0, AllCorners, AbsoluteOpacity, fstroke, TCornerType.Round);

  { angles }
  Fill := TBrush.Create(TBrushKind.Solid, claWhite);
  Stroke := TStrokeBrush.Create(fstroke.Kind, fstroke.Color);
  try
    R := LocalRect;
    InflateRect(R, -0.5, -0.5);
    SelectZoneColor(FLeftTopHot);
    Canvas.FillEllipse(RectF(R.Left - (GripSize), R.Top - (GripSize),
      R.Left + (GripSize), R.Top + (GripSize)), AbsoluteOpacity, Fill);
    Canvas.DrawEllipse(RectF(R.Left - (GripSize), R.Top - (GripSize),
      R.Left + (GripSize), R.Top + (GripSize)), AbsoluteOpacity, Stroke);

    R := LocalRect;
    SelectZoneColor(FRightTopHot);
    Canvas.FillEllipse(RectF(R.Right - (GripSize), R.Top - (GripSize),
      R.Right + (GripSize), R.Top + (GripSize)), AbsoluteOpacity, Fill);
    Canvas.DrawEllipse(RectF(R.Right - (GripSize), R.Top - (GripSize),
      R.Right + (GripSize), R.Top + (GripSize)), AbsoluteOpacity, Stroke);

    R := LocalRect;
    SelectZoneColor(FLeftBottomHot);
    Canvas.FillEllipse(RectF(R.Left - (GripSize), R.Bottom - (GripSize),
      R.Left + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity, Fill);
    Canvas.DrawEllipse(RectF(R.Left - (GripSize), R.Bottom - (GripSize),
      R.Left + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity, Stroke);

    R := LocalRect;
    SelectZoneColor(FRightBottomHot);
    Canvas.FillEllipse(RectF(R.Right - (GripSize), R.Bottom - (GripSize),
      R.Right + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity, Fill);
    Canvas.DrawEllipse(RectF(R.Right - (GripSize), R.Bottom - (GripSize),
      R.Right + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity, Stroke);
  finally
    Fill.Free;
    Stroke.Free;
  end;
end;

procedure TSelectionMod.SetStroke(const Value: TStrokeBrush);
begin
  FStroke.Assign(Value);
end;

procedure TSelectionMod.SetHotColor(const Value : TStrokeBrush);
begin
  FHotColor.Assign(Value);
end;


procedure TSelectionMod.StrokeChanged(Sender: TObject);
begin
  if FUpdating = 0 then
    Repaint;
end;




function TSelectionMod.GetAbsoluteRect: TRectF;
begin
  Result := inherited GetAbsoluteRect;
  InflateRect(Result, (FGripSize + 4) * Scale.X, (FGripSize + 4) * Scale.Y);
end;

function TSelectionMod.GetProportionalSize(ASize: TPointF): TPointF;
begin
  Result := ASize ;
  if (FRatio * Result.Y)  > Result.X  then
  begin
    if Result.X < FMinSize then
      Result.X := FMinSize;
    Result.Y := Result.X / FRatio;
    if Result.Y < FMinSize then
    begin
      Result.Y := FMinSize ;
      Result.X := FMinSize * FRatio;
    end;
  end
  else
  begin
    if Result.Y < FMinSize then
      Result.Y := FMinSize;
    Result.X := Result.Y * FRatio;
    if Result.X < FMinSize then
    begin
      Result.X := FMinSize ;
      Result.Y := FMinSize / FRatio;
    end;
  end;
end;

procedure TSelectionMod.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  R: TRectF;
begin
  // this line may be necessary because TSelection is not a styled control;
  // must further investigate for a better fix
  if not Enabled then
    Exit;

  inherited;

  FDownPos := PointF(X, Y);
  if Button = TMouseButton.mbLeft then
  begin
    FRatio := Width / Height;
    R := LocalRect;
    R := TRectF.Create(R.Left - (GripSize), R.Top - (GripSize), R.Left + (GripSize),
      R.Top + (GripSize));
    if R.Contains(FDownPos) then
    begin
      FLeftTop := True;
      Exit;
    end;
    R := LocalRect;
    R := TRectF.Create(R.Right - (GripSize), R.Top - (GripSize), R.Right + (GripSize),
      R.Top + (GripSize));
    if R.Contains(FDownPos) then
    begin
      FRightTop := True;
      Exit;
    end;
    R := LocalRect;
    R := TRectF.Create(R.Right - (GripSize), R.Bottom - (GripSize), R.Right + (GripSize),
      R.Bottom + (GripSize));
    if R.Contains(FDownPos) then
    begin
      FRightBottom := True;
      Exit;
    end;
    R := LocalRect;
    R := TRectF.Create(R.Left - (GripSize), R.Bottom - (GripSize), R.Left + (GripSize),
      R.Bottom + (GripSize));
    if R.Contains(FDownPos) then
    begin
      FLeftBottom := True;
      Exit;
    end;
    FMove := True;
  end;
end;

procedure TSelectionMod.MouseMove(Shift: TShiftState; X, Y: Single);
var
  P, OldPos: TPointF;
  R: TRectF;
  LMoveVector: TVector;
begin
  // this line may be necessary because TSelection is not a styled control;
  // must further investigate for a better fix
  if not Enabled then
    Exit;

  inherited;

  if Shift = [] then
  begin
    // handle painting for hotspot mouse hovering
    FMovePos := PointF(X, Y);
    P := LocalToAbsolute(FMovePos);
    if Assigned(ParentControl) then
      P := ParentControl.AbsoluteToLocal(P);

    R := LocalRect;
    R := TRectF.Create(R.Left - (GripSize), R.Top - (GripSize), R.Left + (GripSize),
      R.Top + (GripSize));
    if R.Contains(FMovePos) xor FLeftTopHot then
    begin
      FLeftTopHot := not FLeftTopHot;
      Repaint;
    end;

    R := LocalRect;
    R := TRectF.Create(R.Right - (GripSize), R.Top - (GripSize), R.Right + (GripSize),
      R.Top + (GripSize));
    if R.Contains(FMovePos) xor FRightTopHot then
    begin
      FRightTopHot := not FRightTopHot;
      Repaint;
    end;

    R := LocalRect;
    R := TRectF.Create(R.Right - (GripSize), R.Bottom - (GripSize), R.Right + (GripSize),
      R.Bottom + (GripSize));
    if R.Contains(FMovePos) xor FRightBottomHot then
    begin
      FRightBottomHot := not FRightBottomHot;
      Repaint;
    end;

    R := LocalRect;
    R := TRectF.Create(R.Left - (GripSize), R.Bottom - (GripSize), R.Left + (GripSize),
      R.Bottom + (GripSize));
    if R.Contains(FMovePos) xor FLeftBottomHot then
    begin
      FLeftBottomHot := not FLeftBottomHot;
      Repaint;
    end;
  end;
  if ssLeft in Shift then
  begin
    FMovePos := PointF(X, Y);
    if FMove then
    begin
      LMoveVector := LocalToAbsoluteVector(Vector(X - FDownPos.X, Y - FDownPos.Y));
      if ParentControl <> nil then
        LMoveVector := ParentControl.AbsoluteToLocalVector(LMoveVector);
      Position.Point := Position.Point + TPointF(LMoveVector);
      if ParentBounds then
      begin
        if Position.X < 0 then
          Position.X := 0;
        if Position.Y < 0 then
          Position.Y := 0;
        if Assigned(ParentControl) then
        begin
          if Position.X + Width > ParentControl.Width then
            Position.X := ParentControl.Width - Width;
          if Position.Y + Height > ParentControl.Height then
            Position.Y := ParentControl.Height - Height;
        end
        else
          if Assigned(Canvas) then
          begin
            if Position.X + Width > Canvas.Width then
              Position.X := Canvas.Width - Width;
            if Position.Y + Height > Canvas.Height then
              Position.Y := Canvas.Height - Height;
          end;
      end;
      if Assigned(FOnTrack) then
        FOnTrack(Self);
      Exit;
    end;

    OldPos := Position.Point;
    P := LocalToAbsolute(FMovePos);
    if Assigned(ParentControl) then
      P := ParentControl.AbsoluteToLocal(P);
    if ParentBounds then
    begin
      if P.Y < 0 then
        P.Y := 0;
      if P.X < 0 then
        P.X := 0;
      if Assigned(ParentControl) then
      begin
        if P.X > ParentControl.Width then
          P.X := ParentControl.Width;
        if P.Y > ParentControl.Height then
          P.Y := ParentControl.Height;
      end
      else
        if Assigned(Canvas) then
        begin
          if P.X > Canvas.Width then
            P.X := Canvas.Width;
          if P.Y > Canvas.Height then
            P.Y := Canvas.Height;
        end;
    end;
    if FLeftTop then
      DoLeftTopMove(X,Y);
    if FLeftBottom then
      DoLeftBottomMove(X,Y);
    if FRightTop then
      DoRightTopMove(X,Y);
    if FRightBottom then
      DoRightBottomMove(X,Y);
  end;
end;

function TSelectionMod.PointInObjectLocal(X, Y: Single): Boolean;
var
  R: TRectF;
  P: TPointF;
begin
  Result := inherited PointInObjectLocal(X, Y);
  if not Result then
  begin
    P := PointF(X,Y);
    R := LocalRect;
    R := TRectF.Create(R.Left - (GripSize), R.Top - (GripSize), R.Left + (GripSize),
      R.Top + (GripSize));
    if R.Contains(P) then
    begin
      Result := True;
      Exit;
    end;
    R := LocalRect;
    R := TRectF.Create(R.Right - (GripSize), R.Top - (GripSize), R.Right + (GripSize),
      R.Top + (GripSize));
    if R.Contains(P) then
    begin
      Result := True;
      Exit;
    end;
    R := LocalRect;
    R := TRectF.Create(R.Right - (GripSize), R.Bottom - (GripSize), R.Right + (GripSize),
      R.Bottom + (GripSize));
    if R.Contains(P) then
    begin
      Result := True;
      Exit;
    end;
    R := LocalRect;
    R := TRectF.Create(R.Left - (GripSize), R.Bottom - (GripSize), R.Left + (GripSize),
      R.Bottom + (GripSize));
    if R.Contains(P) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TSelectionMod.ReSetInSpace(ARotationPoint, ASize: TPointF);
var
  LLocalPos: TPointF;
begin
  if Assigned(ParentControl) then
  begin
    LLocalPos := ParentControl.AbsoluteToLocal(ARotationPoint);
    LLocalPos.X := LLocalPos.X - ASize.X * RotationCenter.X;
    LLocalPos.Y := LLocalPos.Y - ASize.Y * RotationCenter.Y;
    if ParentBounds then
    begin
      if (LLocalPos.X < 0) then
      begin
        ASize.X := ASize.X + LLocalPos.X;
        LLocalPos.X := 0;
      end;
      if (LLocalPos.Y < 0) then
      begin
        ASize.Y := ASize.Y + LLocalPos.Y;
        LLocalPos.Y := 0;
      end;
      if (LLocalPos.X + ASize.X > ParentControl.Width) then
        ASize.X := ParentControl.Width - LLocalPos.X;
      if (LLocalPos.Y + ASize.Y > ParentControl.Height) then
        ASize.Y := ParentControl.Height - LLocalPos.Y;
    end;
  end
  else
  begin
    LLocalPos.X := ARotationPoint.X - ASize.X * RotationCenter.X;
    LLocalPos.Y := ARotationPoint.Y - ASize.Y * RotationCenter.Y;
  end;
  Width := ASize.X;
  Height := ASize.Y;
  Position.Point := LLocalPos;
end;

procedure TSelectionMod.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  // this line may be necessary because TSelection is not a styled control;
  // must further investigate for a better fix
  if not Enabled then
    Exit;

  inherited;

  if FMove or FLeftTop or FLeftBottom or FRightTop or FRightBottom then
  begin
    if Assigned(FOnChange) then
      FOnChange(Self);

    FMove := False;
    FLeftTop := False;
    FLeftBottom := False;
    FRightTop := False;
    FRightBottom := False;
  end;
end;

{procedure TSelectionMod.Paint;
var
  R: TRectF;
  Fill: TBrush;

  // sets the canvas color depending if the control is enabled and if
  // we need to draw a zone being hot or not
  procedure SelectZoneColor(HotZone: Boolean);
  begin
    if Enabled then
      if HotZone then
        Fill.Color := claRed
      else
        Fill.Color := $FFFFFFFF
    else
      Fill.Color := claGrey;
  end;

var
  Stroke: TStrokeBrush;
begin
  if FHideSelection then
    Exit;
  R := LocalRect;
  InflateRect(R, -0.5, -0.5);
  Canvas.DrawDashRect(R, 0, 0, AllCorners, AbsoluteOpacity, $FF1072C5);
 }
  { angles }
{  Fill := TBrush.Create(TBrushKind.Solid, claWhite);
  Stroke := TStrokeBrush.Create(TBrushKind.Solid, $FF1072C5);
  try
    R := LocalRect;
    InflateRect(R, -0.5, -0.5);
    SelectZoneColor(FLeftTopHot);
    Canvas.FillEllipse(RectF(R.Left - (GripSize), R.Top - (GripSize),
      R.Left + (GripSize), R.Top + (GripSize)), AbsoluteOpacity, Fill);
    Canvas.DrawEllipse(RectF(R.Left - (GripSize), R.Top - (GripSize),
      R.Left + (GripSize), R.Top + (GripSize)), AbsoluteOpacity, Stroke);

    R := LocalRect;
    SelectZoneColor(FRightTopHot);
    Canvas.FillEllipse(RectF(R.Right - (GripSize), R.Top - (GripSize),
      R.Right + (GripSize), R.Top + (GripSize)), AbsoluteOpacity, Fill);
    Canvas.DrawEllipse(RectF(R.Right - (GripSize), R.Top - (GripSize),
      R.Right + (GripSize), R.Top + (GripSize)), AbsoluteOpacity, Stroke);

    R := LocalRect;
    SelectZoneColor(FLeftBottomHot);
    Canvas.FillEllipse(RectF(R.Left - (GripSize), R.Bottom - (GripSize),
      R.Left + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity, Fill);
    Canvas.DrawEllipse(RectF(R.Left - (GripSize), R.Bottom - (GripSize),
      R.Left + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity, Stroke);

    R := LocalRect;
    SelectZoneColor(FRightBottomHot);
    Canvas.FillEllipse(RectF(R.Right - (GripSize), R.Bottom - (GripSize),
      R.Right + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity, Fill);
    Canvas.DrawEllipse(RectF(R.Right - (GripSize), R.Bottom - (GripSize),
      R.Right + (GripSize), R.Bottom + (GripSize)), AbsoluteOpacity, Stroke);
  finally
    Fill.Free;
    Stroke.Free;
  end;
end;
}
procedure TSelectionMod.DoLeftBottomMove(AX, AY: Single);
var
  LRotationPoint: TPointF;
  LSize, LOldSize, LCorrect: TPointF;
begin
  Repaint;
  LOldSize.Y := Height;
  LOldSize.X := Width;
  if AY < FMinSize then
  begin
    LSize.Y := FMinSize;
    AY := LSize.Y;
  end
  else
    LSize.Y := AY;
  if LOldSize.X - AX < FMinSize then
  begin
    LSize.X  := FMinSize;
    AX := LOldSize.X - LSize.X;
  end
  else
    LSize.X  := LOldSize.X - AX;
  if FProportional then
  begin
    if FRatio = 0 then
      FRatio := LOldSize.X/LOldSize.Y;
    LCorrect := LSize;
    LSize := GetProportionalSize(LSize);
    LCorrect.X := LCorrect.X - LSize.X;
    LCorrect.Y := LCorrect.Y - LSize.Y;
    AX := AX + LCorrect.X;
    AY := AY + LCorrect.Y;
  end;
  LRotationPoint.X := LOldSize.X * RotationCenter.X + (AX) * (1 - RotationCenter.X);
  LRotationPoint.Y := LOldSize.Y * RotationCenter.Y + (AY - LOldSize.Y) * (RotationCenter.Y);
  LRotationPoint := LocalToAbsolute(LRotationPoint);
  ReSetInSpace(LRotationPoint, LSize);
  if Assigned(FOnTrack) then
    FOnTrack(Self);
  Repaint;
end;

procedure TSelectionMod.DoLeftTopMove(AX, AY: Single);
var
  LRotationPoint : TPointF;
  LSize, LOldSize, LCorrect : TPointF;
begin
  Repaint;
  LOldSize.Y := Height;
  LOldSize.X := Width;
  if (LOldSize.Y - AY) < FMinSize then
  begin
    LSize.Y := FMinSize;
    AY := LOldSize.Y - LSize.Y;
  end
  else
    LSize.Y := LOldSize.Y - AY;
  if (LOldSize.X - AX) < FMinSize then
  begin
    LSize.X  := FMinSize;
    AX := LOldSize.X - LSize.X;
  end
  else
    LSize.X  := LOldSize.X - AX;
  if FProportional then
  begin
    if FRatio = 0 then
      FRatio := LOldSize.X/LOldSize.Y;
    LCorrect := LSize;
    LSize := GetProportionalSize(LSize);
    LCorrect.X := LCorrect.X - LSize.X;
    LCorrect.Y := LCorrect.Y - LSize.Y;
    AX := AX + LCorrect.X;
    AY := AY + LCorrect.Y;
  end;
  LRotationPoint.X := LOldSize.X * RotationCenter.X + (AX) * (1 - RotationCenter.X);
  LRotationPoint.Y := LOldSize.Y * RotationCenter.Y + (AY) * (1 - RotationCenter.Y);
  LRotationPoint := LocalToAbsolute(LRotationPoint);
  ReSetInSpace(LRotationPoint, LSize);
  if Assigned(FOnTrack) then
    FOnTrack(Self);
  Repaint;
end;

procedure TSelectionMod.DoMouseLeave;
begin
  inherited;

  FLeftTopHot := False;
  FLeftBottomHot := False;
  FRightTopHot := False;
  FRightBottomHot := False;

  Repaint;
end;

procedure TSelectionMod.DoRightBottomMove(AX, AY: Single);
var
  LRotationPoint: TPointF;
  LSize, LOldSize, LCorrect: TPointF;
begin
  Repaint;
  LOldSize.Y := Height;
  LOldSize.X := Width;
  if AY < FMinSize then
  begin
    LSize.Y := FMinSize;
    AY := LSize.Y;
  end
  else
    LSize.Y := AY;
  if AX < FMinSize then
  begin
    LSize.X  := FMinSize;
    AX := LSize.X;
  end
  else
    LSize.X  := AX;
  if FProportional then
  begin
    if FRatio = 0 then
      FRatio := LOldSize.X/LOldSize.Y;
    LCorrect := LSize;
    LSize := GetProportionalSize(LSize);
    LCorrect.X := LCorrect.X - LSize.X;
    LCorrect.Y := LCorrect.Y - LSize.Y;
    AX := AX - LCorrect.X;
    AY := AY - LCorrect.Y;
  end;
  LRotationPoint.X := LOldSize.X * RotationCenter.X + (AX - LOldSize.X) * (RotationCenter.X);
  LRotationPoint.Y := LOldSize.Y * RotationCenter.Y + (AY - LOldSize.Y) * (RotationCenter.Y);
  LRotationPoint := LocalToAbsolute(LRotationPoint);
  ReSetInSpace(LRotationPoint, LSize);
  if Assigned(FOnTrack) then
    FOnTrack(Self);
  Repaint;
end;

procedure TSelectionMod.DoRightTopMove(AX, AY: Single);
var
  LRotationPoint: TPointF;
  LSize, LOldSize, LCorrect: TPointF;
begin
  Repaint;
  LOldSize.Y := Height;
  LOldSize.X := Width;
  if (LOldSize.Y - AY) < FMinSize then
  begin
    LSize.Y := FMinSize;
    AY := LOldSize.Y - LSize.Y;
  end
  else
    LSize.Y := LOldSize.Y - AY;
  if AX  < FMinSize then
  begin
    LSize.X  := FMinSize;
    AX := LSize.X;
  end
  else
    LSize.X  := AX;
  if FProportional then
  begin
    if FRatio = 0 then
      FRatio := LOldSize.X/LOldSize.Y;
    LCorrect := LSize;
    LSize := GetProportionalSize(LSize);
    LCorrect.X := LCorrect.X - LSize.X;
    LCorrect.Y := LCorrect.Y - LSize.Y;
    AX := AX - LCorrect.X;
    AY := AY + LCorrect.Y;
  end;
  LRotationPoint.X := LOldSize.X * RotationCenter.X + (AX - LOldSize.X) * (RotationCenter.X);
  LRotationPoint.Y := LOldSize.Y * RotationCenter.Y + (AY) * (1 - RotationCenter.Y);
  LRotationPoint := LocalToAbsolute(LRotationPoint);
  ReSetInSpace(LRotationPoint, LSize);
  if Assigned(FOnTrack) then
    FOnTrack(Self);
  Repaint;
end;

procedure TSelectionMod.SetHideSelection(const Value: Boolean);
begin
  if FHideSelection <> Value then
  begin
    FHideSelection := Value;
    Repaint;
  end;
end;

procedure TSelectionMod.SetMinSize(const Value: Integer);
begin
  if FMinSize <> Value then
  begin
    FMinSize := Value;
    if FMinSize < 1 then
      FMinSize := 1;
  end;
end;

procedure TSelectionMod.SetGripSize(const Value: Single);
begin
  if FGripSize <> Value then
  begin
    FGripSize := Value;
    if FGripSize > 20 then
      FGripSize := 20;
    if FGripSize < 1 then
      FGripSize := 1;
    Repaint;
  end;
end;

{$ENDREGION}

{$REGION 'implementation of TChRadioButton'}
constructor TChRadioButton.Create(AOwner: TComponent);
begin
  inherited;
  TMessageManager.DefaultManager.Unsubscribe(TRadioButtonGroupMessage, 1,true);
end;


procedure TChRadioButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  fChecked:= IsChecked;
 
{  if Button = TMouseButton.mbLeft then
  begin
    FPressing := True;
    FIsPressed := True;
    StartTriggerAnimation(Self, 'IsPressed');
  end;}
end;

procedure TChRadioButton.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
{  if (ssLeft in Shift) and (FPressing) then
  begin
    if FIsPressed <> LocalRect.Contains(PointF(X, Y)) then
    begin
      FIsPressed := LocalRect.Contains(PointF(X, Y));
      StartTriggerAnimation(Self, 'IsPressed');
    end;
  end;}
end;


procedure TChRadioButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  if fChecked then
    begin
      if LocalRect.Contains(PointF(X, Y)) then
      begin
        IsChecked := False;
      end
    end
    else
    begin
      if LocalRect.Contains(PointF(X, Y)) then
      begin
        IsChecked :=true;
      end
    end
end;

procedure TChRadioButton.KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState);
begin
 inherited;
  if (KeyChar = ' ') {and not IsChecked} then
  begin
    Click; // Emulate mouse click to perform Action.OnExecute
    IsChecked := not IsChecked;
    KeyChar := #0;
  end;
end;

{$ENDREGION}

{ TGridRectangle }
{$REGION 'implementation of TGridRectangle'}

constructor TGridRectangle.Create(AOwner: TComponent);
begin
  inherited;
  FLineFill := TStrokeBrush.Create(TBrushKind.Solid, $FF505050);
  FLineFill.OnChanged := LineFillChanged;
  FLineFillS := $FF2882AB;

  FOpa := 0.4;
  FDubbleLine :=  gridNormal;
  FMarks := 5;
  FFrequency := 40;
  Fill.Color := TAlphaColorRec.Null;
  Fill.Kind := TBrushKind.None;
 // SetAcceptsControls(False);
end;

destructor TGridRectangle.Destroy;
begin
   FreeAndNil(FLineFill);

  inherited;
end;

procedure TGridRectangle.LineFillChanged(Sender: TObject);
begin
  Repaint;
end;

procedure TGridRectangle.Paint;
var
  X, Y,t,dx: Single;
begin
  inherited;
  if FDubbleLine = gridNone then Exit;

    X := 0;
  Y := 0;
  Canvas.Stroke.Assign(FLineFill);
  t:= canvas.Stroke.Thickness;
  while X < Width / 2 do
  begin
    if (X = 0) then
    begin
      Canvas.Stroke.Thickness := t*2;
      Canvas.Stroke.Color := FLineFill.Color
    end
    else
    begin
      if (frac(X) = 0) and (frac(X / Frequency / Marks) = 0) then
        Canvas.Stroke.Color := FLineFill.Color
      else
        Canvas.Stroke.Color := MakeColor(FLineFill.Color, FOpa);
      Canvas.Stroke.Thickness := t;
    end;

    dx:= round(Width / 2) + X + (Canvas.Stroke.Thickness / 2);
    if dx < width then Canvas.DrawLine(PointF(dx, 0+t),PointF(dx, Height-t), AbsoluteOpacity, Canvas.Stroke);

    dx:= round(Width / 2) - X + (Canvas.Stroke.Thickness / 2);
    if (X <> 0) and (dx < width) then Canvas.DrawLine(PointF(dx,0+t), PointF(dx, Height-t), AbsoluteOpacity, Canvas.Stroke);

   if FDubbleLine = gridDubble then
   begin
     if (X = 0) then
     begin
       Canvas.Stroke.Thickness := (t*2)/3;
       Canvas.Stroke.Color := FLineFillS
     end
     else
     begin
       if (frac(X) = 0) and (frac(X / Frequency / Marks) = 0) then
         Canvas.Stroke.Color := FLineFillS
       else
         Canvas.Stroke.Color := MakeColor(FLineFillS, FOpa);
       Canvas.Stroke.Thickness := t /3;
     end;

     dx:= round(Width / 2) + X + (Canvas.Stroke.Thickness / 2 * 3);
     if dx < width then Canvas.DrawLine(PointF(dx, 0+t),PointF(dx, Height-t), AbsoluteOpacity, Canvas.Stroke);

     dx:= round(Width / 2) - X + (Canvas.Stroke.Thickness / 2 * 3 );
     if (X <> 0) and (dx < width) then Canvas.DrawLine(PointF(dx,0+t), PointF(dx, Height-t), AbsoluteOpacity, Canvas.Stroke);

   end;

    X := X + FFrequency;
  end;
  while Y < Height / 2 do
  begin
    if (Y = 0) then
    begin
      Canvas.Stroke.Thickness := t*2;
      Canvas.Stroke.Color := FLineFill.Color
    end
    else
    begin
      if (frac(Y) = 0) and (frac(Y / Frequency / Marks) = 0) then
        Canvas.Stroke.Color := FLineFill.Color
      else
        Canvas.Stroke.Color := MakeColor(FLineFill.Color, FOpa);
      Canvas.Stroke.Thickness := t;
    end;

    dx := round(Height / 2) + Y + (Canvas.Stroke.Thickness / 2);
    if dx < height then Canvas.DrawLine(PointF(0+t, dx), PointF(Width-t, dx), AbsoluteOpacity, Canvas.Stroke);
    dx := round(Height / 2) - Y + (Canvas.Stroke.Thickness / 2);
    if (Y <> 0) and (dx < height) then Canvas.DrawLine(PointF(0+t, dx), PointF(Width-t, dx), AbsoluteOpacity, Canvas.Stroke);

   if FDubbleLine = gridDubble then
   begin
    if (Y = 0) then
    begin
      Canvas.Stroke.Thickness :=( t*2)/ 3;
      Canvas.Stroke.Color := FLineFillS
    end
    else
    begin
      if (frac(Y) = 0) and (frac(Y / Frequency / Marks) = 0) then
        Canvas.Stroke.Color := FLineFillS
      else
        Canvas.Stroke.Color := MakeColor(FLineFillS, FOpa);
      Canvas.Stroke.Thickness := t/3;
    end;

    dx := round(Height / 2) + Y + (Canvas.Stroke.Thickness / 2*3);
    if dx < height then Canvas.DrawLine(PointF(0+t, dx), PointF(Width-t, dx), AbsoluteOpacity, Canvas.Stroke);
    dx := round(Height / 2) - Y + (Canvas.Stroke.Thickness / 2*3);
    if (Y <> 0) and (dx < height) then Canvas.DrawLine(PointF(0+t, dx), PointF(Width-t, dx), AbsoluteOpacity, Canvas.Stroke);

   end;


    Y := Y + FFrequency;
  end;

end;

procedure TGridRectangle.SetDubbler(const Value: TShowGrid);
begin
  if FDubbleLine <> Value then
  begin
    FDubbleLine := Value;
    Repaint;
  end;
end;

procedure TGridRectangle.SetFrequency(const Value: Single);
begin
  if FFrequency <> Value then
  begin
    FFrequency := Value;
    if FFrequency < 0.05 then
      FFrequency := 0.05;
    Repaint;
  end;
end;

procedure TGridRectangle.SetLineFill(const Value: TStrokeBrush);
begin
  FLineFill.Assign(Value);
end;

procedure TGridRectangle.SetLineFillS(const Value: TAlphaColor);
begin
  if FLineFillS <> Value then
  begin
   FLineFillS := Value;
   Repaint;
  end;

end;

procedure TGridRectangle.SetMarks(const Value: Single);
begin
 if FMarks <> Value then
  begin
    FMarks := Value;
  //  if FMarks < 2 then
//      FMarks := 2;
    if FMarks < 0.05 then
      FMarks := 0.05;
    Repaint;
  end;
end;

procedure TGridRectangle.SetOpa(const Value: single);
begin
 if FOpa <> Value then
  begin
    FOpa := Value;
    if FOpa < 0.05 then
      FOpa := 0.05;
    Repaint;
  end;
end;

{$ENDREGION}


procedure Register;
begin
  RegisterComponents('Samples', [TSelectionMod,TGridRectangle,TWinRectangle,TWinExpander,TiGridPanel,TBlinkCircle,TChRadioButton,TGRectangle,TLGlyph]);
//   RegisterClasses([TSelectionMod,TWinRectangle,TWinExpander]);
end;


initialization
 RegisterClasses([TSelectionMod,TWinRectangle,TGridRectangle,TWinExpander,TiGridPanel,TBlinkCircle,TChRadioButton,TGRectangle]);
end.



