unit Main;

interface //#################################################################### ■

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors,
  FMX.Types3D, FMX.MaterialSources, FMX.Objects3D, FMX.Controls3D, FMX.Viewport3D,
  LUX.Marcubes.FMX;

type
  TForm1 = class(TForm)
    Viewport3D1: TViewport3D;
    Dummy1: TDummy;
    Dummy2: TDummy;
    Light1: TLight;
    Camera1: TCamera;
    Grid3D1: TGrid3D;
    StrokeCube1: TStrokeCube;
    LightMaterialSource1: TLightMaterialSource;
    ColorMaterialSource1: TColorMaterialSource;
    procedure FormCreate(Sender: TObject);
    procedure Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
  private
    { private 宣言 }
    _MouseS :TShiftState;
    _MouseP :TPointF;
    _FrameI :Integer;
  public
    { public 宣言 }
    _Marcubes :TMarcubes;
    ///// メソッド
    procedure MakeVoxels;
  end;

var
  Form1: TForm1;

implementation //############################################################### ■

{$R *.fmx}

uses System.Math;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Pãodering( const P_:TPoint3D ) :Single;
var
   X2, Y2, Z2, A :Single;
begin
     X2 := Sqr( P_.X );
     Y2 := Sqr( P_.Y );
     Z2 := Sqr( P_.Z );

     A := Abs( Sqr( ( X2 - Y2 ) / ( X2 + Y2 ) ) - 0.5 );

     Result := Sqr( Sqrt( X2 + Y2 ) - 8 - A ) + Z2 - Sqr( 2 + 3 * A );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

procedure TForm1.MakeVoxels;
var
   X, Y, Z :Integer;
   P :TPoint3D;
begin
     with _Marcubes do
     begin
          with Grids do
          begin
               //    -1   0  +1  +2  +3  +4
               //  -1 +---+---+---+---+---+
               //     |///|///|///|///|///|
               //   0 +---*---*---*---*---+
               //     |///| 1 | 2 | 3 |///|  BricsX = 3 = GridsX-1
               //  +1 +---*---*---*---*---+
               //     |///|   |   |   |///|
               //  +2 +---*---*---*---*---+
               //     |///|   |   |   |///|
               //  +3 +---*---*---*---*---+
               //     |///|///|///|///|///|
               //  +4 +---+---+---+---+---+
               //         1   2   3   4      GridsX = 4 = BricsX+1

               for Z := -1 to GridsZ do
               begin
                    P.Z := 24 * ( Z / BricsZ - 0.5 );

                    for Y := -1 to GridsY do
                    begin
                         P.Y := 24 * ( Y / BricsY - 0.5 );

                         for X := -1 to GridsX do
                         begin
                              P.X := 24 * ( X / BricsX - 0.5 );

                              Grids[ X, Y, Z ] := Pãodering( P );
                         end;
                    end;
               end;
          end;

          MakeModel;  // ポリゴンモデル生成
     end;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

procedure TForm1.FormCreate(Sender: TObject);
begin
     _Marcubes := TMarcubes.Create( Viewport3D1 );

     with _Marcubes do
     begin
          Parent       := Viewport3D1;
          HitTest      := False;
          Material     := LightMaterialSource1;
          Width        := 10;
          Height       := 10;
          Depth        := 10;
          Grids.BricsX := 100;
          Grids.BricsY := 100;
          Grids.BricsZ := 100;
     end;

     MakeVoxels;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TForm1.Viewport3D1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     _MouseS := Shift;
     _MouseP := TPointF.Create( X, Y );
end;

procedure TForm1.Viewport3D1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
   P :TPointF;
begin
     if ssLeft in _MouseS then
     begin
          P := TPointF.Create( X, Y );

          with Dummy1.RotationAngle do Y := Y + ( P.X - _MouseP.X );
          with Dummy2.RotationAngle do X := X - ( P.Y - _MouseP.Y );

          _MouseP := P;
     end;
end;

procedure TForm1.Viewport3D1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
     Viewport3D1MouseMove( Sender, Shift, X, Y );

     _MouseS := [];
end;

end. //######################################################################### ■
