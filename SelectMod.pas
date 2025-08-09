unit SelectMod;

interface

uses
  System.SysUtils, System.Classes,system.Math.vectors, System.Types,System.UIConsts,System.Messaging,
  system.Rtti,fmx.platform,fmx.actnlist,system.Actions,System.RTLConsts,system.Math,
  system.UITypes, FMX.Types, fmx.menus, FMX.Controls, FMX.Objects,FMX.Graphics, FMX.Ani,
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

  TFormMoveNotify = procedure(sender: TObject; const ALeft, ATop, AWidth, AHeight: Integer) of object;

  TfrmMove = class(TForm)
  private
    FOnMoveFormAfter: TFormMoveNotify;
    FOnMoveFormBefore: TFormMoveNotify;
    dSize: TSizeF;
    dpos:TPointF;
    FMoveble:Boolean;
    { Private declarations }
  protected
    procedure ConstrainedResize(var AMinWidth, AMinHeight, AMaxWidth, AMaxHeight: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBoundsF(const ALeft, ATop, AWidth, AHeight: Single); override;
    property Moveble :Boolean read FMoveble write FMoveble;
  published
    property onFormMoveBefore : TFormMoveNotify read FOnMoveFormBefore write FOnMoveFormBefore;
    property onFormMoveAfter : TFormMoveNotify read FOnMoveFormAfter write FOnMoveFormAfter;
    { Public declarations }
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
  public const
    DefaultColor = $FF1072C5;
  public type
    TGrabHandle = (None, LeftTop, RightTop, LeftBottom, RightBottom);
  private
    FParentBounds: Boolean;
    FOnChange: TNotifyEvent;
    FHideSelection: Boolean;
    FMinSize: Integer;
    FOnTrack: TNotifyEvent;
    FProportional: Boolean;
    FGripSize: Single;
    FGripSmall : Single;
    FRatio: Single;
    FActiveHandle: TGrabHandle;
    FHotHandle: TGrabHandle;
    FDownPos: TPointF;
    FShowHandles: Boolean;
    FColor: TAlphaColor;
    FStrokeFrame : TStrokeBrush;
    FGripStroke,FGripStrokeHot: TStrokeBrush;
    FGripBrush,FGripBrushHot: TBrush;
    FHandleCursor,FBackCursor : TCursor;
    FChildParent : TFmxObject;
    procedure SetHideSelection(const Value: Boolean);
    procedure SetMinSize(const Value: Integer);
    procedure SetGripSize(const Value: Single);
    procedure ResetInSpace(const ARotationPoint: TPointF; ASize: TPointF);
    function GetProportionalSize(const ASize: TPointF): TPointF;
    function GetHandleForPoint(const P: TPointF): TGrabHandle;
    procedure GetTransformLeftTop(AX, AY: Single; var NewSize: TPointF; var Pivot: TPointF);
    procedure GetTransformLeftBottom(AX, AY: Single; var NewSize: TPointF; var Pivot: TPointF);
    procedure GetTransformRightTop(AX, AY: Single; var NewSize: TPointF; var Pivot: TPointF);
    procedure GetTransformRightBottom(AX, AY: Single; var NewSize: TPointF; var Pivot: TPointF);
    procedure MoveHandle(AX, AY: Single);
    procedure SetShowHandles(const Value: Boolean);
    procedure SetColor(const Value: TAlphaColor);
    procedure SetStrokeFrame( const Value : TStrokeBrush);
    procedure SetBrushGrip(const Value: TBrush);
    procedure SetStrokeGrip(const Value: TStrokeBrush);
    procedure SetGripSmall(const Value: Single);
  protected
    function DoGetUpdateRect: TRectF; override;
    procedure Paint; override;
    ///<summary>Draw grip handle</summary>
    procedure DrawHandle(const Canvas: TCanvas; const Handle: TGrabHandle; const Rect: TRectF); virtual;
    ///<summary>Draw frame rectangle</summary>
    procedure DrawFrame(const Canvas: TCanvas; const Rect: TRectF); virtual;
  public
    function PointInObjectLocal(X, Y: Single): Boolean; override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
    procedure InChild(const chld : TControl);
    procedure OutChild;
    function WithChild : boolean;
    procedure ScaleChild(const Scaled:boolean);
    ///<summary>Grip handle where mouse is hovered</summary>
    property HotHandle: TGrabHandle read FHotHandle;
  published
    property Align;
    property Anchors;
    property ClipChildren default False;
    property ClipParent default False;
    property Cursor default crDefault;
    property CursorHandle :TCursor read FHandleCursor write FHandleCursor default crCross;
    ///<summary>Selection frame and handle's border color</summary>
    property Color: TAlphaColor read FColor write SetColor default DefaultColor;
    property DragMode default TDragMode.dmManual;
    property EnableDragHighlight default True;
    property Enabled default True;
    property GripSize: Single read FGripSize write SetGripSize;
    Property GripSizeSmall: Single read FGripSmall write SetGripSmall;
    property GripStroke : TStrokeBrush read FGripStroke write SetStrokeGrip;
    property GripBrush : TBrush read FGripBrush write SetBrushGrip;
    property GripStrokeHot : TStrokeBrush read FGripStrokeHot write FGripStrokeHot;
    property GripBrushHot : TBrush read FGripBrushHot write FGripBrushHot;

    property Locked default False;
    property Height;
    property HideSelection: Boolean read FHideSelection write SetHideSelection;
    property HitTest default True;
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
    property Scale;
    property Size;
    property StrokeFrame : TStrokeBrush read FStrokeFrame write SetStrokeFrame;
    ///<summary>Indicates visibility of handles</summary>
    property ShowHandles: Boolean read FShowHandles write SetShowHandles;
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
    property OnResized;
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


  TSelectNotify = procedure(sender: TObject; var SelectMode: SmallInt) of object;
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
    FONSelectMove: TSelectNotify;
    FOnBeginResize,FOnEndResize: TNotifyEvent;
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
    procedure DoSelectMove(var SelectMode:smallint);
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
   property onSelectMode : TSelectNotify read FOnSelectMove write FOnSelectMove;
   property onBeginResize : TNotifyEvent read FOnBeginResize write FOnBeginResize;
   property onEndResize: TNotifyEvent read FOnEndResize write FOnEndResize;
   property MinHeight : single read FMinHeight write FMinHeight;
   property MinWidth : single read FMinWidth write FMinWidth;
   property MaxHeight : single read FMaxHeight write FMaxHeight;
   property MaxWidth : single read FMaxWidth write FMaxWidth;


    { Published declarations }
  end;

  TClearRec = class(TRectangle)
  public
   constructor Create(AOwner: TComponent); override;

  end;


  TScrBar = class(TRectangle)

   private
    FStrokeLo : TStrokeBrush;
    FFillTrack: TBrush;
//    FHeadSize : Single;
    FCapture : Boolean;
    FExpand : Boolean;
    FNormalSize: Single;
    FStartPos, FStartTrack: TPointF;
    FPressed: Boolean;
    FTrackCur : TCursor;
    FDefCur: TCursor;
    fCountTick : SmallInt;
    FMoveMode : SmallInt;
    FONSelectMove: TSelectNotify;
    FOrient: TOrientation;
    FFirstPaint: Boolean;
    FMovable: Boolean;
    FColor1, FColor2, FColor3,FMainStroke : TAlphaColor;
    FTrackBar : TRectangle;
    FTrackRec : TRectF;
    FTrackSize : Single;
    //fscalx,fscaly: single;
    FValue: single;
    FMinWidth, FMinHeight, FMaxWidth,FMaxHeight : Single;
    FOnChange : TNotifyEvent;

    { Private declarations }
    procedure SetStroke(const Value: TStrokeBrush);
    procedure SetFillHeader(const Value : TBrush);
    procedure SetOrient(const Value: TOrientation);


    procedure SetScaleWin(var pan:TFmxObject; x,y: single); overload;
    procedure SetScaleWin(var pan:TScrBar ;x,y: single); overload;
    procedure GetScaleWin(var pan:TFmxObject; var x,y: single); overload;
    procedure GetScaleWin(var pan:TScrBar; var x,y: single); overload;
  protected
    { Protected declarations }
    procedure StrokeChanged(Sender: TObject); virtual;
    procedure Resize; override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure DoSelectMove(var SelectMode:smallint);
    procedure TrBarResized(Sender: TObject);
//    procedure onPicMouseEnter(Sender: TObject);
//    procedure onPicMouseLeave(Sender: TObject);

  public



    FRecB1, FRecB2,FRecB3,FRecB4 : TRectangle;

    constructor Create(AOwner: TComponent); override;

    { Public declarations }
  published
   property TrackStroke: TStrokeBrush read FStrokeLo write SetStroke;
   property TrackFill: TBrush read FFillTrack write SetFillHeader;
   property Orientation: TOrientation read FOrient write SetOrient default TOrientation.Vertical;
   property CursorTrack: TCursor read FTrackCur write FTrackCur;
   property CursorDefault: TCursor read FDefCur write FDefCur;
   property isMoveble : Boolean read FMovable write FMovable;





   property ExpandHeight : single read FNormalSize write FNormalSize{ stored True};



   property SMColor1 : TAlphaColor  read FColor1 write FColor1;
   property SMColor2 : TAlphaColor  read FColor2 write FColor2;
   property SMColor3 : TAlphaColor  read FColor3 write FColor3;
   property onSelectMode : TSelectNotify read FOnSelectMove write FOnSelectMove;
   property MinValue : single read FMinHeight write FMinHeight;
   property MaxValue : single read FMinWidth write FMinWidth;
   property MaxHeight : single read FMaxHeight write FMaxHeight;
   property MaxWidth : single read FMaxWidth write FMaxWidth;
   property TrackSize : single read FTrackSize write FTrackSize;
   property Value : single read FValue write FValue;
   property OnChange: TNotifyEvent read FOnChange write FOnChange;


    { Published declarations }
  end;
  TProcessNotify = procedure(sender: TObject; const proc: single) of object;
  TAnimModes = (amScale,amHide, amEpmty, amProteced);
  TAnimColors = (amRed, amGreen, amBlue,amBlack, amGray, amClear,amCustom);
  TlineDirect = (adUp,adDown,adLeft,adRight,adNot);
  // not(csDesigning in ComponentState)
  TAnimModesSet = set of TAnimModes;
  TAnimModesRec = record
    Modes: TAnimModesSet;
    Border: TAnimColors;

  end;
  TAnimRect = class(TRectangle)
  private
    FBou, FBouS, FBouE : TBounds;
    FResize : Boolean;
    FAnim : TRectAnimation;
    FWall : TRectangle;
    FWallFB : Boolean;
    fControl : TControl;
    fScale : Boolean;
    FProcess :Boolean;
    FBouTemp:TRectF;
    fAnimMode : TAnimModesSet;
    fAnimBorder: TAnimColors;
    FWallFill : TBrush;
    FLineDirect: TlineDirect;
    FLineMin,FLineMax:single;
    FResizeInDesign:Boolean;
    FIsOpen : Boolean;
    FOnOpenProcess,FOnOpenFinish : TProcessNotify;
    FOnStartProcess: TNotifyEvent;
    FTopControl : TControl;
    { Private declarations }
    procedure DoResized; Override;
    procedure Resize; Override;
    procedure SetBouRec( Value : TBounds);
    procedure SetBouRecS( Value : TBounds);
    procedure SetBouRecE( Value : TBounds);
    function GetBou: TBounds;
    function GetBouS: TBounds;
    function GetBouE: TBounds;
    function GetModes: TAnimModesSet;
    function  GetModeColor: TAnimColors;
    procedure SetModes( value : TAnimModesSet);
    procedure SetModeColor( value : TAnimColors);
    procedure AnimFinish(Sender: TObject);
    procedure AnimProcess(Sender: TObject);
    procedure SetBoundStart(Sender: TObject);
    procedure SetBoundEnd(Sender: TObject);
    procedure SetBoundMe(Sender: TObject);
    procedure setposition(sender:tobject);
 //   procedure RecResize(Sender: TObject);
    procedure SetWallFB(Value : Boolean);
    procedure SetSizeMax(const value: single);
    procedure SetSizeMin(const value: single);
    procedure SetLineDirect(const Value: TlineDirect);

 //   procedure SetWallFill(const Value:TBrush);
 //   function GetWallFill:TBrush;
    procedure SetAnimatic(Value:TInterpolationType);
    function GetAnimatic:TInterpolationType;


  protected
    { Protected declarations }
  public
    { Public declarations }

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure FromControl(const aCtrl : TControl; const SameSize:Boolean = True);
    procedure ToControl(const aCtrl : TControl);
    procedure Show;
    procedure Hide;
    procedure Run;
    procedure Close;


    property BouTemp : TRectF read FBouTemp write FBouTemp;
  published
//    property BouRec : TBounds read GetBou write SetBouRec;
//    property BouStart : Tbounds read GetBouS write SetBouRecS;
//    property BouEnd : Tbounds read GetBouE write SetBouRecE;
    property Animatic : TInterpolationType read GetAnimatic write SetAnimatic;
    property AnimDirect : TlineDirect read  FLineDirect write SetLineDirect;
    property SizeMin: Single read FLineMin write SetSizeMin;
    property SizeMax: Single read FLineMax write SetSizeMax;
    property BouRec : TBounds read FBou write FBou;
    property BouStart : Tbounds read FBouS write FBouS;
    property BouEnd : Tbounds read FBouE write FBouE;
    property isOpen : Boolean read FIsOpen write FIsOpen;


    property AutoResize : Boolean read FResize write FResize;
    property ResizeInDesign : Boolean read FResizeInDesign write FResizeInDesign;
    property AnimPos : TRectAnimation read FAnim write FAnim;
    property Wall : TRectangle read FWall write FWall;
    property WallFB : Boolean read FWallFB write SetWallFB default False;
    property AnimModes :  TAnimModesSet read GetModes write SetModes;
    property AnimBorder :  TAnimColors read GetModeColor write SetModeColor;
    property BodyCtrl : TControl read fControl write fControl;
    property TopControl : TControl read FTopControl write FTopControl;
    property onOpenProccess: TProcessNotify read FOnOpenProcess write FOnOpenProcess;
    property onOpenFinish: TProcessNotify read FOnOpenFinish write FOnOpenFinish;
    property onOpenStart: TNotifyEvent read FOnStartProcess write FOnStartProcess;


//    FOnOpenProcess,FOnOpenFinish : TProcessNotify;
 //   property WallFill : TBrush read FWallFill write SetWallFill;
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
  function NumberToWords(Number: Integer): string;
  function RealToWords(Num : string) : string;
  function RealMonthsBetween(EndDate,StartDate:TDateTime):integer;
  function ChangeAlpha(co : TAlphaColor; al:byte) : TAlphaColor;

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

 function ChangeAlpha(co : TAlphaColor; al:byte) : TAlphaColor;
 var
  r: TAlphaColorRec;
begin

 r.Color := co;
 r.a := al;
 result:=r.Color;

end;

function RealMonthsBetween(EndDate,StartDate: TDateTime):integer;
const
  BASE_YEAR=1990;
var
  y1,y2,m1,m2,d1,d2 : word;
  StartMonths, EndMonths:integer;
begin
  DecodeDate(StartDate,y1,m1,d1);
  DecodeDate(EndDate,y2,m2,d2);
  StartMonths:=(y1-BASE_YEAR)*12+m1;
  EndMonths:=(y2-BASE_YEAR)*12+m2;
  Result:= Abs(EndMonths-StartMonths);


//  if d2<d1 then dec(Result);
//  if Result<0 then Result:=0;
end;

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

 function NumberToWords(Number: Integer): string;
 const
  billion  = 1000000000;
  Million  = 1000000;
  Thousand = 1000;
  Hundred  = 100;
  tens :array[2..9] of string = ('kakskümmend', 'kolmkümmend', 'nelikümmend', 'viiskümmend', 'kuuskümmend', 'seitsekümmend', 'kaheksakümmend', 'üheksakümmend');
  Teens: array [10..19] of string = ('kümme','üksteist','kaksteist','kolmteist', 'neliteist', 'viisteist', 'kuusteist', 'seitseteist', 'kaheksateist', 'üheksateist');
  Units: array [1..9] of string = ('üks', 'kaks', 'kolm', 'neli', 'viis', 'kuus', 'seitse', 'kaheksa', 'üheksa');
begin
  if (Number < 0) then Result := 'minus ' else Result := '';
  Number := abs(Number); //Get number as Positive Value;

   //Billions
  if (Number >= Billion) then
  begin
    Result := Result + NumberToWords(Number div Billion) + '  miljardit ';
    Number := Number mod Billion;
  end;

  //Millions
  if (Number >= Million) then
  begin
    Result := Result + NumberToWords(Number div Million) + ' miljonit ';
    Number := Number mod Million;
  end;

  //Thousands
  if (Number >= Thousand) then
  begin
    Result := Result + NumberToWords(Number div Thousand) + ' tuhat ';
    Number := Number mod Thousand;
  end;

  //Hundreds
  if (Number >= Hundred) then
  begin
    Result := Result + NumberToWords(Number div Hundred) + 'sada';
    Number := Number mod Hundred;
  end;

  // and ...
  if (Number > 0)and(Result <> '') then
  begin
    Result := Trim(Result);
    if (Result[Length(Result)] = ',') then Delete(Result, Length(Result), 1);
    Result := Result + ' ';
  end;

  //Tens
  if (Number >= 20) then
  begin
    Result := Result + Tens[Number div 10] + ' ';
    Number := Number mod 10;
  end;
  if (Number >= 10) then
  begin
    Result := Result + Teens[Number];
    Number := 0
  end;

  //Units
  if (Number >= 1) then Result := Result + Units[Number];

  //Tidy up the result
  Result := Trim(Result);
  if (Result = '') then Result := 'null'
  else
    if (Result[Length(Result)] = ',') then
      Delete(Result, Length(Result), 1);
end;
 function RealToWords(Num : string) : string;
 var
 i,j :integer;
 f,df: Double;
 s1,s2:string;
begin
    i:=0; j:=0;
  s1:='';
  s2:='';
  if pos(',',num) <> 0 then s1:= Copy(num,1, Pos(',', num)-1)
  else if pos('.',num) <> 0 then s1:= Copy(num,1, Pos('.', num)-1)
  else s1:=num;
  if pos(',',num) <> 0 then s2:= Copy(num, Pos(',', num)+1, Length(num)-Pos(',', num)+1);
  if pos('.',num) <> 0 then s2:= Copy(num, Pos('.', num)+1, Length(num)-Pos('.', num)+1);
  if s1 <> ''  then i:= s1.ToInteger;
  if s2 <> ''  then j:= s2.ToInteger;

  Result := NumberToWords(i);
  if j > 0 then Result := Result + ' koma '+ NumberToWords(j);

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
 if not (pan is TPanel) then
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
 if Not (pan is TPanel) then
 begin
   x:= 1;
   y:= 1;

 end
 else
 begin
   x:= TPanel(pan).Scale.X;
   y:= TPanel(pan).Scale.Y;
 end;
end;

procedure TWinRectangle.GetScaleWin( var pan:TWinrectangle; var x,y: single);
begin
 x:= pan.Scale.X;
 y:= pan.Scale.Y;
end;

procedure TWinRectangle.SetShadow(Const Value : Boolean);
begin
 if FShadowed = Value then Exit;

 FShadowed := Value;
 FShadow.Enabled := Value;
 if FUpdating = 0 then
    if Owner is TForm then  (Owner as TForm).Invalidate;

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
   FNormalSize:= Height;
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
  FGrip.AutoCapture := True;
  FGrip.BringToFront;
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
  FHText.Position.X := 0; FHText.Position.Y:= (FHeadSize - 16)/2;
  FHText.Height := 16; FHText.Width := Width;
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

procedure TWinRectangle.DoSelectMove(var SelectMode: smallint);
begin
  if Assigned(FOnselectMove) then
    FOnselectMove(Self, SelectMode);
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

 if fCountTick >= 1 then
 begin
   FmyTimer.Enabled := False;
   if FMoveMode = 1 then  Stroke.Color := FColor1;
   if FMoveMode = 2 then  Stroke.Color := FColor2;
   if FMoveMode = 3 then  Stroke.Color := FColor3;
   Stroke.Thickness := 1.5;
   DoSelectMove(FMoveMode);
   FPressed := True;
   fCountTick := 0;
 {  if Assigned(FOnSelectMove) then FOnSelectMove(Self, FMoveMode)
   else
   begin
     FPressed := True;
     fCountTick := 0;
     if FMoveMode = 1 then  Stroke.Color := FColor1;
     if FMoveMode = 2 then  Stroke.Color := FColor2;
     if FMoveMode = 3 then  Stroke.Color := FColor3;
      Stroke.Thickness := 1.5; }//0.5;
      //Stroke.Dash := TStrokeDash.DashDot;
 //     isShadowed := False;
 //  end;
   StrokeChanged(self);
 end;

end;

 procedure TWinRectangle.StrokeChanged(Sender: TObject);
begin
  if FUpdating = 0 then
  begin
//   UpdateEffects;
    Repaint;
 //   exit;
    if FShadow.Enabled then
    begin
      if Owner is TForm then  (Owner as TForm).Invalidate;
    end;


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
       (self.parent as tForm).Height := Round(FHeadSize + Stroke.Thickness);
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
   //self.BringToFront;
//  if not HitTest then exit;
   if fShadowOff then begin
    if FShadowed then FShadow.Enabled:=False;
    StrokeChanged(self);
   end;
   if Button = TMouseButton.mbRight then begin

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
     if self.Parent is TCustomForm then (self.parent as tCustomForm).BringToFront
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

    if Assigned(FOnBeginResize) then
    FOnBeginResize(Self);

  FMainStroke := Stroke.Color;
  FmyTimer.Enabled:=True;
//  FPressed := True;
  FStartPos := TPointF.Create(X*fscalx, Y*fscaly);
//  fishadow := FShadowed;
//  if FMoveMode = 2 then  if (Parent is TForm) and useparent  then (self.parent as tForm).StartWindowResize;
  if self.Parent is TForm  then (self.parent as tForm).BringToFront;
  if FShowGrip then FGrip.BringToFront;

end;

procedure TWinRectangle.MouseMove(Shift: TShiftState; X, Y: Single);
var
  MoveVector: TVector;
  dx, dy : single;
  t,l,w,h:integer;
  x1,y1,w1,h1 : single;
begin
 inherited;
 if FResizable then
 begin
    x1 := Width - 20; w1:= width;
    y1 := Height - 20; h1 := Height;
    if (((X >= x1) and (X<=w1)) and ((y>=y1) and (Y<=w1)) )then
    begin
      self.Cursor:= crSizeNWSE;
    end
    else self.Cursor:= crDefault;
 end;
 if FPressed then
  begin
    (Owner as TForm).BeginUpdate;
     MoveVector := TVector.Create(X - FStartPos.X, Y - FStartPos.Y, 0);
     dx := MoveVector.X;
     dy := MoveVector.Y;

     MoveVector := self.LocalToAbsoluteVector(MoveVector);
     if self.ParentControl <> nil then
     MoveVector := self.ParentControl.AbsoluteToLocalVector(MoveVector);

//    Position.Point := self.Position.Point + MoveVector.ToPointF;

    if FMoveMode = 1 then
    begin
       if useparent then
       begin
         if Parent is TCustomForm  then
         begin
           (Parent as TCustomForm).StartWindowDrag;
         end;
         if Parent is tControl then
         begin
           (parent as tcontrol).Position.Point := (parent as tcontrol).Position.Point + TPointF(MoveVector)
         end

       end
       else
       begin
         Position.Point := Position.Point + TPointF(MoveVector);
         if Position.X < 0 then Position.X := 0;
         if Position.Y < 0 then  Position.Y:= 0;
         if Parent is TForm  then  if Position.X > ((Parent as TfOrm).Width - HeadSize) then Position.X := (Parent as TfOrm).Width - HeadSize;
         if Parent is TForm  then  if Position.Y > ((Parent as TfOrm).Height - HeadSize) then Position.Y := (Parent as TfOrm).Height - HeadSize;
         if Parent is TControl  then  if Position.X > ((Parent as TControl).Width - HeadSize) then Position.X := (Parent as TControl).Width - HeadSize;
         if Parent is TControl  then  if Position.Y > ((Parent as TControl).Height - HeadSize) then Position.Y := (Parent as TControl).Height - HeadSize;
       end;


  // Repaint;

    end;
    if FMoveMode = 2 then
    begin

//      dx := MoveVector.X;
//      dy := MoveVector.Y;
        if useparent then
        begin
            if Parent is TCustomForm then
            begin
              t:= (parent as TCustomForm).Top; l:= (parent as TCustomForm).Left;
              w := (parent as TCustomForm).Width; h:= (parent as TCustomForm).Height;

              if w + dx <= FMinWidth then w := Round(FMinWidth)
              else
                if w + dx >= FMaxWidth then w := Round(FMaxWidth)
                else w := w + Round(dx);
              if h + dy <= FMinHeight then h := Round(FMinHeight)
              else
                if h + dy >= FMaxHeight then h := Round(FMaxHeight)
                else h := h  + Round(dy);
//             (parent as TForm).BeginUpdate;
            //  Platform.SetWindowRect
             (parent as TCustomForm).SetBounds(l,t,w,h);
//             (parent as TForm).EndUpdate;
             //  repaint;
             //(parent as TForm).Invalidate;
            end
            else
            begin
              y1:= (parent as tcontrol).Position.y; x1:= (parent as tcontrol).Position.X;
              w1 := (parent as tcontrol).Width; h1:= (parent as tcontrol).Height;
              if w1 + dx <= FMinWidth then w1 := FMinWidth
              else
                if w1 + dx >= FMaxWidth then w1 := FMaxWidth
                else w1 := w1 + dx;
              if h1 + dy <= FMinHeight then h1 := FMinHeight
              else
                if h1 + dy >= FMaxHeight then h1 := FMaxHeight
                else h1 := h1 + dy;
//              (parent as tcontrol).BeginUpdate;
              (parent as tcontrol).SetBounds(x1,y1,w1,h1);
//              (parent as tcontrol).EndUpdate;
            end;
   //      Repaint
        end
        else
        begin
           y1:= Position.y; x1:= Position.X; w1 := Width; h1:= Height;
           if h1 + dy <= FMinHeight then h1 := FMinHeight
           else
             if h1 + dy >= FMaxHeight then h1 := FMaxHeight
             else h1 := h1 + dy;
           if w1 + dx <= FMinWidth then  w1 := FMinWidth
           else
             if w1 + dx >= FMaxWidth then  w1 := FMaxWidth
             else w1 := w1 + dx;
//           (Owner as TForm).BeginUpdate;
           SetBounds(x1,y1,w1,h1);
//           (Owner as TForm).EndUpdate;
 //          Repaint;
        end;
        FStartPos.X:=x; FStartPos.y:=y;
    end;
     (Owner as TForm).EndUpdate;
    StrokeChanged(self);


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
    if self.Parent is TCustomForm then (self.parent as tCustomForm).BringToFront
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
   if Assigned(FOnEndResize) then
    FOnEndResize(Self);

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
//  StrokeChanged(self);

end;

{$ENDREGION}

{$REGION 'implementation of TScrBar'}

procedure TScrBar.SetScaleWin(var pan:TFmxObject; x,y: single);
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

procedure TScrBar.SetScaleWin( var pan:TScrBar; x,y: single);
begin
 pan.Scale.X:= x;
 pan.Scale.Y:= y;
end;

procedure TScrBar.GetScaleWin( var pan:TFmxObject; var x,y: single);
begin
 x:= TPanel(pan).Scale.X;
 y:= TPanel(pan).Scale.Y;
end;

procedure TScrBar.GetScaleWin( var pan:TScrBar; var x,y: single);
begin
 x:= pan.Scale.X;
 y:= pan.Scale.Y;
end;



constructor TScrBar.Create(AOwner: TComponent);

begin
  inherited;
  FMovable := True;
   FTrackCur := crDefault;
  FCapture := False;
  FParent := Parent;
  AutoCapture := True;

  FDefCur := crDefault;
  FColor1 :=  claRed;
  FColor2 :=  claGreen;
  FColor3 :=  claYellowgreen;
  FMainStroke:= claBlack;
 // fscalx := 1; fscaly := 1;
  FMinWidth :=  110;
  FMinHeight := 90;
  FMaxWidth :=  1000;
  FMaxHeight := 1000;
//  FHeadSize := 25;
  FStrokelo := TStrokeBrush.Create(TBrushKind.Solid, claBlack);
  fstrokelo.Dash :=  TStrokeDash.Solid;
  FStrokelo.Thickness := 0.5;
  FFillTrack := TBrush.Create(TBrushKind.Solid,$FF424548);
  FStrokeLo.OnChanged := StrokeChanged;
  FFillTrack.OnChanged := StrokeChanged;

  FExpand := True;
//  FNormalSize:= Height;
  ClipChildren := True;

  fCountTick := 0;
  FMoveMode := 0;

  FFirstPaint := True;
  size.Width :=9;
  size.Height := 250;
  XRadius:= 3.0;
  YRadius:= 3.0;
  stroke.Thickness := 0.5;
  FTrackBar := TRectangle.Create(Self);
  FTrackBar.SetSubComponent(true);
   FTrackBar.Stored := False;
  FTrackBar.Parent := Self;
  FTrackBar.OnResized := TrBarResized;

//  FTrackBar.Fill.Color := $FFA1A1A1;
  FTrackBar.Fill.Color := ChangeAlpha(FFillTrack.Color,30);
//  FTrackBar.Fill.Color := $FFA1A1A1;
  FTrackBar.Stroke.Color := TAlphaColorRec.Null;
  FTrackBar.Size.Height := Self.Size.Height / 2 -(Self.Stroke.Thickness*4);
  FTrackBar.Size.Width := Self.Size.Width - (Self.Stroke.Thickness*4);
  FTrackBar.Position.X := Self.Stroke.Thickness*2;
  FTrackBar.Position.Y := Self.Stroke.Thickness*2;
  FTrackBar.XRadius := 3.0;
  FTrackBar.YRadius := 3.0;
 // FTrackBar.Align := TAlignLayout.Scale;
  FTrackBar.HitTest := False;
   //Self.AddObject(FTrackBar);
  if not Registered then
  begin
//    RegisterClasses( [ TScrBar ] );
    Registered := True;
  end;


end;

procedure TScrBar.DoSelectMove(var SelectMode: smallint);
begin
  if Assigned(FOnselectMove) then
    FOnselectMove(Self, SelectMode);
end;



{procedure TScrBar.onPicMouseEnter(Sender: TObject);
begin
  if  (sender as  TTMSFMXBitmap).BitmapName = '' then exit;
  (sender as  TTMSFMXBitmap).Opacity := 1;
// if Assigned((sender as  TTMSFMXBitmap).OnMouseEnter) then (sender as  TTMSFMXBitmap).OnMouseEnter(self);
end;
procedure TScrBar.onPicMouseLeave(Sender: TObject);
begin
 if  (sender as  TTMSFMXBitmap).BitmapName = '' then exit;
 (sender as  TTMSFMXBitmap).Opacity := 0.4;
// if Assigned((sender as  TTMSFMXBitmap).OnMouseLeave) then (sender as  TTMSFMXBitmap).OnMouseLeave(self);
end;}







 procedure TScrBar.StrokeChanged(Sender: TObject);
begin
  if FUpdating = 0 then
  begin
//   UpdateEffects;
    Repaint;
 //   exit;



  end;
end;


procedure TScrBar.TrBarResized(Sender: TObject);
begin
   FTrackRec := FTrackBar.BoundsRect;
        FTrackRec.Left := -10;
     FTrackRec.Width := self.Width+20 ;

end;

procedure TScrBar.SetStroke(const Value: TStrokeBrush);
begin
  FStrokeLo.Assign(Value);
end;

procedure TScrBar.SetFillHeader(const Value : TBrush);
begin
  FFillTrack.Assign(Value);
end;



procedure TScrBar.SetOrient(const Value: TOrientation);
begin
  if Value <> FOrient then
  begin
    FOrient := Value;
  end;
end;

procedure TScrBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  dx1, dx2, dy1, dy2 : single;
  fo : TFmxObject;
  tp : TPointF;
begin
  inherited;
   //self.BringToFront;
//  if not HitTest then exit;

   FStartPos := TPointF.Create(X, Y);
   FStartTrack := TPointF.Create(FTrackBar.Position.X,FTrackBar.Position.Y);
   tp:=TPointF.Create(X,Y);
   if PtInRect(FTrackBar.BoundsRect,tp) then begin
     self.Root.Captured := self;
     Fcapture:= True;
     FTrackBar.Fill.Color := ChangeAlpha(FTrackBar.Fill.Color,255)
   end;
   if Button = TMouseButton.mbRight then begin

   end;


//  if FMoveMode = 1 then if not FMovable then Exit;


  FMainStroke := Stroke.Color;

//  FPressed := True;
//  fishadow := FShadowed;
//  if FMoveMode = 2 then  if (Parent is TForm) and useparent  then (self.parent as tForm).StartWindowResize;



end;

procedure TScrBar.MouseMove(Shift: TShiftState; X, Y: Single);
var
  MoveVector: TVector;
  dx, dy : single;
  t,l,w,h:integer;
  x1,y1,w1,h1 : single;
  tp:TPointF;
  aTrckPos : single;
begin
 inherited;
  tp:=TPointF.Create(X,Y);
 if PtInRect({FTrackBar.BoundsRect}FTrackRec,tp) then Cursor := FTrackCur
 else Cursor := FDefCur;

  if FCapture then
  begin
//   if PtInRect(FTrackBar.BoundsRect,tp) then begin
   aTrckPos := FStartTrack.Y - ( FStartPos.y - tp.y);
//   if (aTrckPos <=  Self.Height-FTrackBar.Height) and (aTrckPos >= 0) then
//   FTrackBar.Position.Y := aTrckPos
//   else
//   begin
     if (aTrckPos >  Self.Height-FTrackBar.Height) then aTrckPos := Self.Height-FTrackBar.Height;
     if (aTrckPos < 0) then aTrckPos := 0;
     FTrackBar.Position.Y := aTrckPos;
     if not (csLoading in ComponentState) and Assigned(FOnChange) then
    FOnChange(Self);
//   end;
   FValue := FTrackBar.Position.Y;
//   end;
     FTrackRec := FTrackBar.BoundsRect;
     FTrackRec.Left := -10;
     FTrackRec.Width := self.Width+20 ;
  end;
 if FPressed then
  begin
    (Owner as TForm).BeginUpdate;
     MoveVector := TVector.Create(X - FStartPos.X, Y - FStartPos.Y, 0);
     dx := MoveVector.X;
     dy := MoveVector.Y;

     MoveVector := self.LocalToAbsoluteVector(MoveVector);
     if self.ParentControl <> nil then
     MoveVector := self.ParentControl.AbsoluteToLocalVector(MoveVector);

//    Position.Point := self.Position.Point + MoveVector.ToPointF;

    if FMoveMode = 1 then
    begin
      


  // Repaint;

    end;
    if FMoveMode = 2 then
    begin

//      dx := MoveVector.X;
//      dy := MoveVector.Y;
       
        FStartPos.X:=x; FStartPos.y:=y;
    end;
     (Owner as TForm).EndUpdate;
    StrokeChanged(self);


  end;
 // StrokeChanged(self);
end;

procedure TScrBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
 fo: TFmxObject;
 dx1: single;
begin
   FCapture:=False;
        FTrackBar.Fill.Color := ChangeAlpha(FTrackBar.Fill.Color,30) ;
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

//   Fscalx := 1; Fscaly := 1;
  inherited;
end;

procedure TScrBar.Paint;
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


  R := GetShapeRect;
 // if R.Bottom > FHeadSize then R.Bottom := FHeadSize;
  FSidesLoc := Sides;
  FCornersLoc := Corners;
  Off := R.Left;
  if FExpand and (TCorner.BottomLeft in FCornersLoc) then Exclude(FCornersLoc, TCorner.BottomLeft);
  if FExpand and (TCorner.BottomRight in FCornersLoc) then Exclude(FCornersLoc, TCorner.BottomRight);

  if not(TSide.Top in FSidesLoc) then R.Top := R.Top - Off;
  if not(TSide.Left in FSidesLoc)then R.Left := R.Left - Off;
  if not(TSide.Bottom in FSidesLoc) then R.Bottom := R.Bottom + Off;
  if not(TSide.Right in FSidesLoc) then R.Right := R.Right + Off;
 // Canvas.FillRect(R, XRadius, YRadius, FCornersLoc, AbsoluteOpacity, FFillTrack, CornerType);
//  StrokeChanged(self);

end;

procedure TScrBar.Resize;
begin
  inherited;
  if not Assigned(FTrackBar) then exit;
  FTrackBar.Size.Height := Self.Size.Height / 2 -(Self.Stroke.Thickness*4);
  FTrackBar.Size.Width := Self.Size.Width - (Self.Stroke.Thickness*4);
  FTrackBar.Position.X := Self.Stroke.Thickness*2;

end;

{$ENDREGION}


{$REGION 'implementation of TSelectionMod'}

{ TSelection }

constructor TSelectionMod.Create(AOwner: TComponent);
begin
  inherited;
  AutoCapture := True;
  ParentBounds := True;
  FColor := DefaultColor;
  FShowHandles := True;
  FMinSize := 15;
  FGripSize := 3;
  FGripSmall := 1;
  FStrokeFrame   := TStrokeBrush.Create(TBrushKind.Solid, FColor);
  FGripStroke    := TStrokeBrush.Create(TBrushKind.Solid, FColor);
  FGripStrokeHot := TStrokeBrush.Create(TBrushKind.Solid, FColor);
  FGripBrush     := TBrush.Create(TBrushKind.Solid, claWhite);
  FGripBrushHot  := TBrush.Create(TBrushKind.Solid, claRed);
  FHandleCursor := crCross;
  FBackCursor := Cursor;
  FChildParent := nil;
  SetAcceptsControls(False);
end;

destructor TSelectionMod.Destroy;
begin
  FStrokeFrame.Free;
  FGripStroke.Free;
  FGripStrokeHot.Free;
  FGripBrush.Free;
  FGripBrushHot.Free;
  inherited;
end;

function TSelectionMod.GetProportionalSize(const ASize: TPointF): TPointF;
begin
  Result := ASize;
  if FRatio * Result.Y  > Result.X  then
  begin
    if Result.X < FMinSize then
      Result.X := FMinSize;
    Result.Y := Result.X / FRatio;
    if Result.Y < FMinSize then
    begin
      Result.Y := FMinSize;
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
      Result.X := FMinSize;
      Result.Y := FMinSize / FRatio;
    end;
  end;
end;

function TSelectionMod.GetHandleForPoint(const P: TPointF): TGrabHandle;
var
  Local, R: TRectF;
begin
  Local := LocalRect;
  R := TRectF.Create(Local.Left - GripSize, Local.Top - GripSize, Local.Left + GripSize, Local.Top + GripSize);
  if R.Contains(P) then
    Exit(TGrabHandle.LeftTop);
  R := TRectF.Create(Local.Right - GripSize, Local.Top - GripSize, Local.Right + GripSize, Local.Top + GripSize);
  if R.Contains(P) then
    Exit(TGrabHandle.RightTop);
  R := TRectF.Create(Local.Right - GripSize, Local.Bottom - GripSize, Local.Right + GripSize, Local.Bottom + GripSize);
  if R.Contains(P) then
    Exit(TGrabHandle.RightBottom);
  R := TRectF.Create(Local.Left - GripSize, Local.Bottom - GripSize, Local.Left + GripSize, Local.Bottom + GripSize);
  if R.Contains(P) then
    Exit(TGrabHandle.LeftBottom);
  Result := TGrabHandle.None;
end;


procedure TSelectionMod.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  // this line may be necessary because TSelection is not a styled control;
  // must further investigate for a better fix
  if not Enabled then
    Exit;

  inherited;

  FDownPos := TPointF.Create(X, Y);
  if Button = TMouseButton.mbLeft then
  begin
    FRatio := Width / Height;
    FActiveHandle := GetHandleForPoint(FDownPos);
  end;
end;

procedure TSelectionMod.MouseMove(Shift: TShiftState; X, Y: Single);
var
  P, OldPos: TPointF;
  MoveVector: TVector;
  MovePos: TPointF;
  GrabHandle: TGrabHandle;
begin
  // this line may be necessary because TSelection is not a styled control;
  // must further investigate for a better fix
  if not Enabled then
    Exit;

  inherited;

  MovePos := TPointF.Create(X, Y);
  if not Pressed then
  begin
    // handle painting for hotspot mouse hovering
    GrabHandle := GetHandleForPoint(MovePos);
    if GrabHandle <> FHotHandle then
      Repaint;
    FHotHandle := GrabHandle;
    if FHotHandle <>  TGrabHandle.None then begin
      If  Cursor <> FHandleCursor then Cursor:= FHandleCursor;
    end
    else
    begin
      if Cursor <> FBackCursor then Cursor:= FBackCursor;
    end;

  end
  else if ssLeft in Shift then
  begin
    if FActiveHandle = TGrabHandle.None then
    begin
      MoveVector := LocalToAbsoluteVector(TVector.Create(X - FDownPos.X, Y - FDownPos.Y));
      if ParentControl <> nil then
        MoveVector := ParentControl.AbsoluteToLocalVector(MoveVector);
      Position.Point := Position.Point + TPointF(MoveVector);
      if ParentBounds then
      begin
        if Position.X < 0 then
          Position.X := 0;
        if Position.Y < 0 then
          Position.Y := 0;
        if ParentControl <> nil then
        begin
          if Position.X + Width > ParentControl.Width then
            Position.X := ParentControl.Width - Width;
          if Position.Y + Height > ParentControl.Height then
            Position.Y := ParentControl.Height - Height;
        end
        else
          if Canvas <> nil then
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
    P := LocalToAbsolute(MovePos);
    if ParentControl <> nil then
      P := ParentControl.AbsoluteToLocal(P);
    if ParentBounds then
    begin
      if P.Y < 0 then
        P.Y := 0;
      if P.X < 0 then
        P.X := 0;
      if ParentControl <> nil then
      begin
        if P.X > ParentControl.Width then
          P.X := ParentControl.Width;
        if P.Y > ParentControl.Height then
          P.Y := ParentControl.Height;
      end
      else
        if Canvas <> nil then
        begin
          if P.X > Canvas.Width then
            P.X := Canvas.Width;
          if P.Y > Canvas.Height then
            P.Y := Canvas.Height;
        end;
    end;
    MoveHandle(X, Y);
  end;
end;

function TSelectionMod.PointInObjectLocal(X, Y: Single): Boolean;
begin
  Result := inherited or (GetHandleForPoint(TPointF.Create(X, Y)) <> TGrabHandle.None);
end;

procedure TSelectionMod.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  // this line may be necessary because TSelection is not a styled control;
  // must further investigate for a better fix
  if not Enabled then
    Exit;

  inherited;

  if Assigned(FOnChange) then
    FOnChange(Self);
  FActiveHandle := TGrabHandle.None;
end;

procedure TSelectionMod.DrawFrame(const Canvas: TCanvas; const Rect: TRectF);
begin
 // Canvas.DrawDashRect(Rect, 0, 0, AllCorners, AbsoluteOpacity, FColor);
  if FStrokeFrame.Color <> FColor then  FStrokeFrame.Color := FColor;
  Canvas.DrawRect(Rect,0,0,AllCorners,AbsoluteOpacity,FStrokeFrame);
end;

procedure TSelectionMod.DrawHandle(const Canvas: TCanvas; const Handle: TGrabHandle; const Rect: TRectF);
var
  Fill: TBrush;
  Stroke: TStrokeBrush;
begin
  Fill := TBrush.Create(TBrushKind.Solid, claWhite);
  Stroke := TStrokeBrush.Create(TBrushKind.Solid, FColor);
  try
    if FHotHandle <> Handle then rect.Inflate(-FGripSmall,-FGripSmall);
    if Enabled then
      if FHotHandle = Handle then
      begin
        {Fill.Color := claRed}
        Canvas.FillEllipse(Rect, AbsoluteOpacity, FGripBrushHot);
        Canvas.DrawEllipse(Rect, AbsoluteOpacity, FGripStrokeHot);
      end
      else
      begin
        {Fill.Color := claWhite}
        Canvas.FillEllipse(Rect, AbsoluteOpacity, FGripBrush);
        Canvas.DrawEllipse(Rect, AbsoluteOpacity, FGripStroke);
      end
    else
    begin
      Fill.Color := claGrey;
      Canvas.FillEllipse(Rect, AbsoluteOpacity, Fill);
      Canvas.DrawEllipse(Rect, AbsoluteOpacity, Stroke);
    end;
  finally
    Fill.Free;
    Stroke.Free;
  end;
end;

procedure TSelectionMod.Paint;
var
  R: TRectF;
begin
  if FHideSelection then
    Exit;

  R := LocalRect;
  R.Inflate(-0.5, -0.5);
  DrawFrame(Canvas, R);

  if ShowHandles then
  begin
    R := LocalRect;

    DrawHandle(Canvas, TGrabHandle.LeftTop, TRectF.Create(R.Left - GripSize, R.Top - GripSize, R.Left + GripSize,
      R.Top + GripSize));
    DrawHandle(Canvas, TGrabHandle.RightTop, TRectF.Create(R.Right - GripSize, R.Top - GripSize, R.Right + GripSize,
      R.Top + GripSize));
    DrawHandle(Canvas, TGrabHandle.LeftBottom, TRectF.Create(R.Left - GripSize, R.Bottom - GripSize, R.Left + GripSize,
      R.Bottom + GripSize));
    DrawHandle(Canvas, TGrabHandle.RightBottom, TRectF.Create(R.Right - GripSize, R.Bottom - GripSize,
      R.Right + GripSize, R.Bottom + GripSize));
  end;
end;

function TSelectionMod.DoGetUpdateRect: TRectF;
begin
  Result := inherited;
  Result.Inflate((FGripSize + 1) * Scale.X, (FGripSize + 1) * Scale.Y);
end;


procedure TSelectionMod.ResetInSpace(const ARotationPoint: TPointF; ASize: TPointF);
var
  LLocalPos: TPointF;
  LAbsPos: TPointF;
begin
  LAbsPos := LocalToAbsolute(ARotationPoint);
  if ParentControl <> nil then
  begin
    LLocalPos := ParentControl.AbsoluteToLocal(LAbsPos);
    LLocalPos.X := LLocalPos.X - ASize.X * RotationCenter.X * Scale.X;
    LLocalPos.Y := LLocalPos.Y - ASize.Y * RotationCenter.Y * Scale.Y;
    if ParentBounds then
    begin
      if LLocalPos.X < 0 then
      begin
        ASize.X := ASize.X + LLocalPos.X;
        LLocalPos.X := 0;
      end;
      if LLocalPos.Y < 0 then
      begin
        ASize.Y := ASize.Y + LLocalPos.Y;
        LLocalPos.Y := 0;
      end;
      if LLocalPos.X + ASize.X > ParentControl.Width then
        ASize.X := ParentControl.Width - LLocalPos.X;
      if LLocalPos.Y + ASize.Y > ParentControl.Height then
        ASize.Y := ParentControl.Height - LLocalPos.Y;
    end;
  end
  else
  begin
    LLocalPos.X := LAbsPos.X - ASize.X * RotationCenter.X * Scale.X;
    LLocalPos.Y := LAbsPos.Y - ASize.Y * RotationCenter.Y * Scale.Y;
  end;
  SetBounds(LLocalPos.X, LLocalPos.Y, ASize.X, ASize.Y);
end;

procedure TSelectionMod.GetTransformLeftTop(AX, AY: Single; var NewSize: TPointF; var Pivot: TPointF);
var
  LCorrect: TPointF;
begin
  NewSize := Size.Size - TSizeF.Create(AX, AY);
  if NewSize.Y < FMinSize then
  begin
    AY := Height - FMinSize;
    NewSize.Y := FMinSize;
  end;
  if NewSize.X < FMinSize then
  begin
    AX := Width - FMinSize;
    NewSize.X := FMinSize;
  end;
  if FProportional then
  begin
    LCorrect := NewSize;
    NewSize := GetProportionalSize(NewSize);
    LCorrect := LCorrect - NewSize;
    AX := AX + LCorrect.X;
    AY := AY + LCorrect.Y;
  end;
  Pivot := TPointF.Create(Width * RotationCenter.X + AX * (1 - RotationCenter.X),
    Height * RotationCenter.Y + AY * (1 - RotationCenter.Y));
end;

procedure TSelectionMod.GetTransformLeftBottom(AX, AY: Single; var NewSize: TPointF; var Pivot: TPointF);
var
  LCorrect: TPointF;
begin
  NewSize := TPointF.Create(Width - AX, AY);
  if NewSize.Y < FMinSize then
  begin
    AY := FMinSize;
    NewSize.Y := FMinSize;
  end;
  if NewSize.X < FMinSize then
  begin
    AX := Width - FMinSize;
    NewSize.X := FMinSize;
  end;
  if FProportional then
  begin
    LCorrect := NewSize;
    NewSize := GetProportionalSize(NewSize);
    LCorrect := LCorrect - NewSize;
    AX := AX + LCorrect.X;
    AY := AY + LCorrect.Y;
  end;
  Pivot := TPointF.Create(Width * RotationCenter.X + AX * (1 - RotationCenter.X),
    Height * RotationCenter.Y + (AY - Height) * RotationCenter.Y);
end;

procedure TSelectionMod.GetTransformRightTop(AX, AY: Single; var NewSize: TPointF; var Pivot: TPointF);
var
  LCorrect: TPointF;
begin
  NewSize := TPointF.Create(AX, Height - AY);
  if NewSize.Y < FMinSize then
  begin
    AY := Height - FMinSize;
    NewSize.Y := FMinSize;
  end;
  if AX < FMinSize then
  begin
    AX := FMinSize;
    NewSize.X := FMinSize;
  end;
  if FProportional then
  begin
    LCorrect := NewSize;
    NewSize := GetProportionalSize(NewSize);
    LCorrect := LCorrect - NewSize;
    AX := AX - LCorrect.X;
    AY := AY + LCorrect.Y;
  end;
  Pivot := TPointF.Create(Width * RotationCenter.X + (AX - Width) * RotationCenter.X,
    Height * RotationCenter.Y + AY * (1 - RotationCenter.Y));
end;

procedure TSelectionMod.GetTransformRightBottom(AX, AY: Single; var NewSize: TPointF; var Pivot: TPointF);
var
  LCorrect: TPointF;
begin
  NewSize := TPointF.Create(AX, AY);
  if NewSize.Y < FMinSize then
  begin
    AY := FMinSize;
    NewSize.Y := FMinSize;
  end;
  if NewSize.X < FMinSize then
  begin
    AX := FMinSize;
    NewSize.X := FMinSize;
  end;
  if FProportional then
  begin
    LCorrect := NewSize;
    NewSize := GetProportionalSize(NewSize);
    LCorrect := LCorrect - NewSize;
    AX := AX - LCorrect.X;
    AY := AY - LCorrect.Y;
  end;
  Pivot := TPointF.Create(Width * RotationCenter.X + (AX - Width) * RotationCenter.X,
    Height * RotationCenter.Y + (AY - Height) * RotationCenter.Y);
end;

procedure TSelectionMod.MoveHandle(AX, AY: Single);
var
  NewSize, Pivot: TPointF;
begin
  case FActiveHandle of
    TSelectionMod.TGrabHandle.LeftTop: GetTransformLeftTop(AX, AY, NewSize, Pivot);
    TSelectionMod.TGrabHandle.LeftBottom: GetTransformLeftBottom(AX, AY, NewSize, Pivot);
    TSelectionMod.TGrabHandle.RightTop: GetTransformRightTop(AX, AY, NewSize, Pivot);
    TSelectionMod.TGrabHandle.RightBottom: GetTransformRightBottom(AX, AY, NewSize, Pivot);
  end;
  ResetInSpace(Pivot, NewSize);
  if Assigned(FOnTrack) then
    FOnTrack(Self);
end;



procedure TSelectionMod.DoMouseEnter;
begin
  inherited;
  FBackCursor := Cursor;
end;

procedure TSelectionMod.DoMouseLeave;
begin
  inherited;
  FHotHandle := TGrabHandle.None;
  Cursor := FBackCursor;
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

procedure TSelectionMod.SetShowHandles(const Value: Boolean);
begin
  if FShowHandles <> Value then
  begin
    FShowHandles := Value;
    Repaint;
  end;
end;

procedure TSelectionMod.SetStrokeFrame(const Value: TStrokeBrush);
begin
 if FStrokeFrame <> Value then
 begin
    FStrokeFrame := Value;
    Repaint;
 end;
end;


procedure TSelectionMod.OutChild;
begin
 if FChildParent = Nil then Exit;

 //
end;

procedure TSelectionMod.InChild(const chld: TControl);
begin
   if FChildParent <> Nil then OutChild;
   FChildParent := chld.Parent;
   chld.Visible := False;
   self.BoundsRect := chld.BoundsRect;



//
end;


procedure TSelectionMod.ScaleChild(const Scaled: boolean);
begin
 //
end;

function TSelectionMod.WithChild: boolean;
begin
 //
end;


procedure TSelectionMod.SetBrushGrip(const Value: TBrush);
begin
if FGripBrush <> Value then
 begin
  FGripBrush := Value;
    Repaint;
 end;
end;

procedure TSelectionMod.SetStrokeGrip(const Value: TStrokeBrush);
begin
if FGripStroke <> Value then
 begin
   FGripStroke := Value;
   Repaint;
 end;
end;


procedure TSelectionMod.SetColor(const Value: TAlphaColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    Repaint;
  end;
end;

procedure TSelectionMod.SetGripSize(const Value: Single);
begin
  if FGripSize <> Value then
  begin
    if Value < FGripSize then
      Repaint;
    FGripSize := Value;
    if FGripSize > 20 then
      FGripSize := 20;
    if FGripSize < 1 then
      FGripSize := 1;
    HandleSizeChanged;
    Repaint;
  end;
end;

procedure TSelectionMod.SetGripSmall(const Value: Single);
begin
 if FGripSmall <> Value then
  begin
    if FGripSmall > FGripSize  then
       FGripSmall := FGripSize
    else
      if FGripSmall < 0 then FGripSmall := 0
      else FGripSmall := Value;

    HandleSizeChanged;
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



{ TAnimRect }
{$REGION 'implementation of TAnimRect'}

procedure TAnimRect.AnimFinish(Sender: TObject);
var
 ctr:tcontrol;
 sc:single;
begin
  inherited;
 sc:=0;
 FProcess:=False;
 FIsOpen :=  not FAnim.Inverse;
 if FIsOpen then sc:=1
 else sc:=0;

  if Assigned(FOnOpenFinish) then
    FOnOpenFinish(Self, sc);

end;

procedure TAnimRect.AnimProcess(Sender: TObject);
var
 ctr:tcontrol;
 sc,sa,sb,sx:single;
 a,b,x: TRectF;
begin
FProcess:=true;
 sc:=1;
  inherited;
 sc:=0;
   x := FBou.Rect;
   a := FAnim.StartValue.Rect;
   b := FAnim.StopValue.Rect;
   case FLineDirect of
     adUp,adDown: sc:=abs( ((x.Height-a.Height)/(b.Height-a.Height)) );

     adLeft,adRight: sc:= abs(((x.Width-a.Width)/(b.Width-a.Width)) );

     adNot:begin
             sa:=a.Height*a.Width; sb:=b.Height*b.Width;sx:=x.Height*x.Width;
             sc := abs(((sx-sa)/(sb-sa)));
           end ;
   end;
   if Assigned(FOnOpenProcess) then
    FOnOpenProcess(Self, sc);

end;

procedure TAnimRect.Close;
begin
 Hide;
end;

constructor TAnimRect.Create(AOwner: TComponent);
var
 rf:TRectF;
begin
  inherited;
  rf.Left := 0;
  rf.Right := 0;
  rf.Top := 0;
  rf.Bottom := 0;
  Fprocess:=false;
  FBou := TBounds.Create(rf);
  FBouS := TBounds.Create(rf);
  FBouE := TBounds.Create(rf);
  FResize := False;
  FBou.OnChange := SetBoundMe;
  FBouS.OnChange := SetBoundStart;
  FBouE.OnChange := SetBoundEnd;
  FResizeInDesign := False;
  FisOpen := False;
  Fill.Color := TAlphaColors.White;
//  Fill.Kind := TBrushKind.None;
  Stroke.Thickness := 0.5;
//  Stroke.Kind := TBrushKind.None;

  FAnim := TRectAnimation.Create(Self);
  FAnim.Parent := Self;
//  FAnim.Name := self.Name + 'Animator';
  FAnim.SetSubComponent(true);
  FAnim.Stored := False;
  FAnim.PropertyName := 'BouRec';
  FAnim.Interpolation := TInterpolationType.Sinusoidal;
  FAnim.OnProcess := AnimProcess;
  FAnim.OnFinish := AnimFinish;
  fanim.AnimationType := TAnimationType.In;
 // FWallFill := TBrush.Create(TBrushKind.None,TAlphaColors.White ) ;
  FWall := TClearRec.Create(self);
  FWall.Parent := Self;
  Fwall.Align := TAlignLayout.Contents;
//  FWall.Name := self.Name +'Wall';
  FWall.SetSubComponent(true);
   Fwall.Stored := False;
//  FWall.HitTest := False;
   FWall.Fill.Kind := TBrushKind.Solid;
   FWall.Fill.Color := TAlphaColors.White;
    Fwall.Stroke.Thickness := 0.5;
//  FWall.Margins.Left := 3;
//  FWall.Margins.Right := 3;
//  FWall.Margins.Top := 3;
//  FWall.Margins.Bottom := 3;
//  FWall.Stored := False;
//  FWall.Locked := True;
  FWall.SendToBack;
// Fwall.OnResize := RecResize;
// Padding.Left := 4;
 // Padding.Right := 4;
 //Padding.Top := 4;
 // Padding.Bottom := 4;
  FWallFB := False;
  FLineDirect :=  adNot;
  FLineMin := -1;
  FLineMax := -1;
  fControl := Nil;
  FTopControl := Nil;
  fAnimBorder := amGray;
  FBouTemp.Empty;
  fAnimMode := [amEpmty]
// Self.OnResized := RecResize;
end;

destructor TAnimRect.Destroy;
begin
  FAnim.Free;
  FBouS.Free;
  FBouE.Free;
  FBou.Free;
  inherited;
end;


procedure TAnimRect.Resize;
var
  ar: boolean;
begin
  inherited;
  if (csReading in ComponentState) or (csLoading in ComponentState) then
   Exit;

 // if not (csLoading in ComponentState) and SizeChanged then
 ar := FResize;
 FResize := False;
 if FLineDirect = adNot then
 begin
 if BoundsRect.Left <> fbou.Left then FBou.Rect := BoundsRect;
 end
 else  FBou.Rect := BoundsRect;
 //FBou.Rect := Self.BoundsRect;

 FResize := ar;
 if FLineDirect = adNot then Exit;
 FBouTemp := FBou.Rect;
 exit;
 if FProcess then exit;


 FBouE.Rect := FBouTemp;
 (* case FLineDirect of
   adLeft: FBouE.Left := FBouE.Right - FLineMax;
   adRight: FBouE.Right := FBouE.Left + FLineMax;
   adUp: FBouE.Top := FBouE.Bottom - FLineMax  ;
   adDown: FBouE.Bottom := FBouE.Top + FLineMax ;
  end;       *)

  FBouS.Rect := FBouTemp;
 (* case FLineDirect of
   adLeft:  FBouS.Left := FBouS.Right - FLineMin ;
   adRight:  FBouS.Right := FBouS.Left + FLineMin ;
   adUp:  FBouS.Top := FBouS.Bottom - FLineMin  ;
   adDown:  FBouS.Bottom := FBouS.Top + FLineMin ;
  end;  *)
// SetSizeMin(FLineMin);
// SetSizeMax(FLineMax);


end;

procedure TAnimRect.Show;
begin
  BringToFront;
  if not Self.Visible then Self.Visible := True;
    fanim.Inverse:=false;
 SetSizeMin(FLineMin);
 SetSizeMax(FLineMax);
  if Assigned(FOnStartProcess) then
    FOnStartProcess(Self);
  FAnim.Start;
end;

procedure TAnimRect.Hide;
begin
  BringToFront;

  if not Self.Visible then Self.Visible := True;
   // fanim.AnimationType := TAnimationType.Out;
   fanim.Inverse:=true;
   SetSizeMin(FLineMin);
   SetSizeMax(FLineMax);
  if Assigned(FOnStartProcess) then
    FOnStartProcess(Self);
  FAnim.Start;
end;


procedure TAnimRect.Run;
begin
   BringToFront;
  if not Self.Visible then Self.Visible := True;
  fanim.Inverse:=   FIsOpen;
  // (BoundsRect.Width * BoundsRect.Height) > (FBouS.Rect.Width* FBouS.Rect.Height);
  SetSizeMin(FLineMin);
  SetSizeMax(FLineMax);
  if Assigned(FOnStartProcess) then
    FOnStartProcess(Self);
    FAnim.Start;
end;

procedure TAnimRect.DoResized;
begin
  inherited;
if (csReading in ComponentState) or (csLoading in ComponentState) then
  Exit;
  FBouTemp := Self.BoundsRect;
end;
(*
procedure TAnimRect.RECResize(Sender: TObject);
var
  ar: boolean;
begin
  inherited;
 ar := FResize;
 FResize := False;
 FBou.Rect := Self.BoundsRect;

 FResize := ar;
 if FLineDirect = adNot then Exit;
 FBouTemp := FBou.Rect;
 exit;
 if FProcess then exit;


 FBouE.Rect := FBouTemp;
  case FLineDirect of
   adLeft: FBouE.Left := FBouE.Right - FLineMax;
   adRight: FBouE.Right := FBouE.Left + FLineMax;
   adUp: FBouE.Top := FBouE.Bottom - FLineMax  ;
   adDown: FBouE.Bottom := FBouE.Top + FLineMax ;
  end;

  FBouS.Rect := FBouTemp;
  case FLineDirect of
   adLeft:  FBouS.Left := FBouS.Right - FLineMin ;
   adRight:  FBouS.Right := FBouS.Left + FLineMin ;
   adUp:  FBouS.Top := FBouS.Bottom - FLineMin  ;
   adDown:  FBouS.Bottom := FBouS.Top + FLineMin ;
  end;
// SetSizeMin(FLineMin);
// SetSizeMax(FLineMax);

end;   *)

procedure TAnimRect.FromControl(const aCtrl : TControl; const SameSize:Boolean = True);
var
  objrec: TRectF;
begin
  objrec := aCtrl.AbsoluteRect;
  if not SameSize then
  begin
    objrec.Width := 0.0;
    objrec.Height := 0.0;
  end;
  FBouS.Rect := objrec;
  FBou.Rect := objrec;
  if amHide in fAnimMode then self.Visible := False;

end;

function TAnimRect.GetAnimatic: TInterpolationType;
begin
 Result := FAnim.Interpolation;
end;

function TAnimRect.GetBou: TBounds;
begin
  Result := FBou;
end;

function TAnimRect.GetBouE: TBounds;
begin
  Result := FBouE;

end;

function TAnimRect.GetBouS: TBounds;
begin
   Result := FBouS;

end;

function TAnimRect.GetModeColor: TAnimColors;
begin
 result := fAnimBorder;
end;

function TAnimRect.GetModes: TAnimModesSet;
begin
 result := fAnimMode;
end;

//function TAnimRect.GetWallFill: TBrush;
//begin
 // Result := FWall.Fill;
//end;


procedure TAnimRect.SetAnimatic(Value: TInterpolationType);
begin
 FAnim.Interpolation := Value;
end;

procedure TAnimRect.SetBoundMe(Sender: TObject);
var
 l:single;
begin
if (csReading in ComponentState) or (csLoading in ComponentState) then
    Exit;
 if FResize then
  begin
   // if FLineDirect = adNot then
    BoundsRect := FBou.Rect;
  //  else FBou.Rect := BoundsRect;
   // TForm(self.Parent).Invalidate;
  end;
end;

procedure TAnimRect.SetBoundEnd(Sender: TObject);
begin
  FAnim.StopValue.Assign(FBouE);

end;



procedure TAnimRect.SetBoundStart(Sender: TObject);
begin
  FAnim.StartValue.Assign(FBouS);
end;

procedure TAnimRect.SetBouRec( Value: TBounds);
begin
  FBou.Assign(Value);
  if FResize then
  begin
    self.BoundsRect := FBou.Rect;
    TForm(self.Parent).Invalidate;
  end;
end;

procedure TAnimRect.SetBouRecE( Value: TBounds);
begin
  FBouE.Assign(Value);
end;

procedure TAnimRect.SetBouRecS( Value: TBounds);
begin
  FBouS.Assign(Value);
end;

procedure TAnimRect.SetLineDirect(const Value: TlineDirect);
begin
  if FLineDirect = Value then exit;
  FLineDirect := Value;
  SetSizeMin(FLineMin);
  SetSizeMax(FLineMax);
end;

procedure TAnimRect.SetModeColor(value: TAnimColors);
begin
   fAnimBorder := value;
   case fAnimBorder of
     amRed: FWall.Stroke.Color := TAlphaColorRec.Red ;
     amGreen: FWall.Stroke.Color := TAlphaColorRec.Green ;
     amBlue: FWall.Stroke.Color := TAlphaColorRec.Blue ;
     amBlack: FWall.Stroke.Color := TAlphaColorRec.Black ;
     amGray:FWall.Stroke.Color := TAlphaColorRec.Gray  ;
     amClear:FWall.Stroke.Color := TAlphaColorRec.Null ;
   end;
end;

procedure TAnimRect.SetModes(value: TAnimModesSet);
begin
  fAnimMode := value;
end;

procedure TAnimRect.setposition(sender: tobject);
begin
inherited
end;

procedure TAnimRect.SetSizeMax(const value: single);
begin
 if value =-1 then exit;
 // if value = FLineMax then exit;
  FLineMax := Value;
  if FLineDirect = adNot then Exit;
  FBouE.Rect := BoundsRect;
  case FLineDirect of
   adLeft: begin FBouE.Left := FBouE.Right - Value end;
   adRight: begin FBouE.Right := FBouE.Left + Value end;
   adUp: begin FBouE.Top := FBouE.Bottom - Value  end;
   adDown: begin FBouE.Bottom := FBouE.Top + Value end;
  end;
  if (not (csDesigning in ComponentState)) or FResizeInDesign then
  begin
    // maybe later
  end;

end;

procedure TAnimRect.SetSizeMin(const value: single);
begin
 if value =-1 then exit;
// if value = FLineMin then exit;
  FLineMin := Value;
  if FLineDirect = adNot then Exit;
  FBouS.Rect := BoundsRect;
  case FLineDirect of
   adLeft: begin FBouS.Left := FBouS.Right - Value end;
   adRight: begin FBouS.Right := FBouS.Left + Value end;
   adUp: begin FBouS.Top := FBouS.Bottom - Value  end;
   adDown: begin FBouS.Bottom := FBouS.Top + Value end;
  end;

  if (not (csDesigning in ComponentState))  or FResizeInDesign then
  begin
  Fbou.Assign(FBouS);
   BoundsRect := FBouS.Rect;
  end;

end;

procedure TAnimRect.SetWallFB(Value: Boolean);
begin
  if Value = FWallFB then exit;

  FWallFB := not FWallFB;
  FWall.Locked := not  FWallFB;
  FWall.HitTest := tRUE;

  if FWallFB then FWall.BringToFront
  else FWall.SendToBack;
  if Assigned(FTopControl) then
     FTopControl.BringToFront;

  if FTopControl <> Nil then
     FTopControl.BringToFront;

  If Assigned(Screen.ActiveForm) then
  Screen.ActiveForm.Focused := Nil;
  //Realign;
Repaint;
end;

//procedure TAnimRect.SetWallFill(const Value: TBrush);
//begin
// FWallFill.Assign(Value);
//end;



procedure TAnimRect.ToControl(const aCtrl: TControl);
var
  objrec: TRectF;
begin
  objrec := aCtrl.AbsoluteRect;
  FBouE.Rect := objrec;
end;

{$ENDREGION}




{ TClearRec }

constructor TClearRec.Create(AOwner: TComponent);
begin
  inherited;
  Align := TAlignLayout.Contents;
  HitTest := False;
  Locked := True;
  Fill.Color:= TAlphaColorRec.White;
  Fill.Kind := TBrushKind.None;
  Stroke.Thickness := 0.5;
  Margins.Left := 3;
  Margins.Right := 3;
  Margins.Top := 3;
  Margins.Bottom := 3;
end;




{ TfrmMove }

procedure TfrmMove.ConstrainedResize(var AMinWidth, AMinHeight, AMaxWidth,
  AMaxHeight: Single);
begin
  inherited;
 //
end;

constructor TfrmMove.Create(AOwner: TComponent);
begin

 dSize.Width:=-1;
 dSize.Height:=-1;
 dpos.X:=-1;
 dpos.Y:=-1;
 FMoveble:=True;
  inherited;
end;

procedure TfrmMove.SetBoundsF(const ALeft, ATop, AWidth, AHeight: Single);
var
 dx,dy,dw,dh:single;
 db:TRect;
begin
 // if Assigned(FOnMoveFormBefore) then  FOnMoveFormBefore(Self,Trunc(ALeft), Trunc(ATop), Trunc(AWidth),Trunc(AHeight));
 if not FMoveble then exit;

  inherited;
  if (csLoading in Self.ComponentState) then exit;
  if dpos.X = -1 then
  begin
   dpos.X := ALeft;
   dpos.Y := ATop;
   dSize.Width := AWidth;
   dSize.Height := AHeight;
  end;
  dx:= Left;
  dy:=Top;
  if (dpos.X <> ALeft) or (dpos.Y <> ATop) then
  begin
   dpos.X := ALeft;
   dpos.Y := ATop;
    if Assigned(FOnMoveFormAfter) then  FOnMoveFormAfter(Self,Trunc(ALeft), Trunc(ATop), Trunc(AWidth),Trunc(AHeight));
  end;
{   dx:=dx-aleft;
  dy:=dy-atop;
  dw:=dw-AWidth;
  dh:=dh-AHeight;    }
//  if Assigned(FOnMoveFormAfter) then  FOnMoveFormAfter(Self,Trunc(ALeft), Trunc(ATop), Trunc(AWidth),Trunc(AHeight));


//

end;

procedure Register;
begin
  RegisterComponents('Samples', [TSelectionMod,TGridRectangle,TWinRectangle,TWinExpander,TiGridPanel,TBlinkCircle,TChRadioButton,TGRectangle,TLGlyph,TScrBar,TAnimRect,TClearRec]);
//   RegisterClasses([TSelectionMod,TWinRectangle,TWinExpander]);
end;

initialization
 RegisterClasses([TSelectionMod,TfrmMove,TWinRectangle,TGridRectangle,TWinExpander,TiGridPanel,TBlinkCircle,TChRadioButton,TGRectangle,TScrBar,TAnimRect, TClearRec]);
end.



