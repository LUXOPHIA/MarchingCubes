﻿unit LUX.FMX.Marcubes;

interface //#################################################################### ■

uses System.Classes, System.Math.Vectors, System.Generics.Collections,
     FMX.Types3D, FMX.Controls3D, FMX.MaterialSources,
     LUX, LUX.D3, LUX.Data.Lattice.T3, LUX.Data.Lattice.T3.D3;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     TMarcubeIter  = class;
     TMarcubeGrids = class;
     TMarcubes     = class;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TVert

     TPoin = record
       Pos :TPoint3D;
       Nor :TPoint3D;
     end;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMarcubeIter

     IIterMarcube = interface( ISingleBricIterGridArray3D )
     ['{8FD59B4C-2D40-4262-A737-AD4FAC4B55E3}']
     {protected}
       ///// アクセス
       function GetKind :Byte;
     {public}
       ///// プロパティ
       property Kind :Byte read GetKind;
     end;

     //-------------------------------------------------------------------------

     TMarcubeIter = class( TSingleBricIterGridArray3D, IIterMarcube )
     private
     protected type
     protected
       ///// アクセス
       function GetKind :Byte;
     public
       ///// プロパティ
       property Kind :Byte read GetKind;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMarcubeGrids

     TMarcubeGrids = class( TSingleGridArray3D )
     private
     protected type
     protected
       ///// メソッド
       function NewBricIter :TBricIterGridArray3D<Single>; override;
     public
       ///// メソッド
       procedure ForBrics( const Proc_:TConstProc<TMarcubeIter> );
       procedure ForEdgesX( const Proc_:TConstProc<TMarcubeIter> );
       procedure ForEdgesY( const Proc_:TConstProc<TMarcubeIter> );
       procedure ForEdgesZ( const Proc_:TConstProc<TMarcubeIter> );
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMarcubes

     TMarcubes = class( TControl3D )
     private
     protected
       _Geometry :TMeshData;
       _Material :TMaterialSource;
       _Grids    :TMarcubeGrids;
       ///// アクセス
       ///// メソッド
       procedure Render; override;
     public
       constructor Create( AOwner_:TComponent ); override;
       destructor Destroy; override;
       ///// プロパティ
       property Material :TMaterialSource read _Material write _Material;
       property Grids    :TMarcubeGrids   read _Grids;
       ///// メソッド
       procedure EndUpdate; override;
       procedure MakeModel;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

    TRIAsTABLE :TArray3<Byte>;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.SysUtils, System.RTLConsts;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMarcubeIter

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

function TMarcubeIter.GetKind :Byte;
begin
     Result := 0;

     if Grids[ 0, 0, 0 ] < 0 then Result := Result or $01;
     if Grids[ 1, 0, 0 ] < 0 then Result := Result or $02;
     if Grids[ 0, 1, 0 ] < 0 then Result := Result or $04;
     if Grids[ 1, 1, 0 ] < 0 then Result := Result or $08;
     if Grids[ 0, 0, 1 ] < 0 then Result := Result or $10;
     if Grids[ 1, 0, 1 ] < 0 then Result := Result or $20;
     if Grids[ 0, 1, 1 ] < 0 then Result := Result or $40;
     if Grids[ 1, 1, 1 ] < 0 then Result := Result or $80;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMarcubeGrids

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// メソッド

function TMarcubeGrids.NewBricIter :TBricIterGridArray3D<Single>;
begin
     Result := TMarcubeIter.Create( Self );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

/////////////////////////////////////////////////////////////////////// メソッド

procedure TMarcubeGrids.ForBrics( const Proc_:TConstProc<TMarcubeIter> );
begin
     inherited ForBrics( procedure( const B_:TSingleBricIterGridArray3D )
     begin
          Proc_( B_ as TMarcubeIter );
     end );
end;

procedure TMarcubeGrids.ForEdgesX( const Proc_:TConstProc<TMarcubeIter> );
begin
     inherited ForEdgesX( procedure( const E_:TSingleBricIterGridArray3D )
     begin
          Proc_( E_ as TMarcubeIter );
     end );
end;

procedure TMarcubeGrids.ForEdgesY( const Proc_:TConstProc<TMarcubeIter> );
begin
     inherited ForEdgesY( procedure( const E_:TSingleBricIterGridArray3D )
     begin
          Proc_( E_ as TMarcubeIter );
     end );
end;

procedure TMarcubeGrids.ForEdgesZ( const Proc_:TConstProc<TMarcubeIter> );
begin
     inherited ForEdgesZ( procedure( const E_:TSingleBricIterGridArray3D )
     begin
          Proc_( E_ as TMarcubeIter );
     end );
end;

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TMarcubes

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

/////////////////////////////////////////////////////////////////////// アクセス

/////////////////////////////////////////////////////////////////////// メソッド

procedure TMarcubes.Render;
begin
     Context.SetMatrix( TMatrix3D.CreateTranslation( TPoint3D.Create( -Grids.BricsX / 2,
                                                                      -Grids.BricsY / 2,
                                                                      -Grids.BricsZ / 2 ) )
                      * TMatrix3D.CreateScaling( TPoint3D.Create( Width  / Grids.BricsX,
                                                                  Height / Grids.BricsY,
                                                                  Depth  / Grids.BricsZ ) )
                      * AbsoluteMatrix );

     Context.DrawTriangles( _Geometry.VertexBuffer,
                            _Geometry.IndexBuffer,
                            TMaterialSource.ValidMaterial( _Material ),
                            AbsoluteOpacity );
end;

//------------------------------------------------------------------------------

procedure TMarcubes.MakeModel;
var
   C :TMarcubeIter;
   EsX, EsY, EsZ :TDictionary<TInteger3D,Integer>;
   Ps :TArray<TPoin>;
   AddPoin :TConstFunc<Single,Single,Single,Integer>;
   X, Y, Z, X0, X1, Y0, Y1, Z0, Z1, PsN, FsN, I, J :Integer;
   G0, G1, d :Single;
   Fs :TArray<TInteger3D>;
   FindPoin :TConstFunc<Byte,Integer>;
begin
     //          200---------201---------202
     //          /|          /|          /|
     //         / |         / |         / |
     //        /  |        /  |        /  |
     //      100---------101---------102  |
     //      /|   |      /|   |      /|   |
     //     / |  210----/-|--211----/-|--212
     //    /  |  /|    /  |  /|    /  |  /|
     //  000---------001---------002  | / |
     //   |   |/  |   |   |/  |   |   |/  |
     //   |  110------|--111------|--112  |
     //   |  /|   |   |  /|   |   |  /|   |
     //   | / |  220--|-/-|--221--|-/-|--222
     //   |/  |  /    |/  |  /    |/  |  /
     //  010---------011---------012  | /
     //   |   |/      |   |/      |   |/
     //   |  120------|--121------|--122
     //   |  /        |  /        |  /
     //   | /         | /         | /
     //   |/          |/          |/
     //  020---------021---------022

     C := TMarcubeIter.Create( _Grids );

     EsX := TDictionary<TInteger3D,Integer>.Create;
     EsY := TDictionary<TInteger3D,Integer>.Create;
     EsZ := TDictionary<TInteger3D,Integer>.Create;

     ////////// 頂点生成

     Ps := [];

     AddPoin := function ( const X_,Y_,Z_:Single ) :Integer
          var
             P :TPoin;
          begin
               with P do
               begin
                    Pos := TPoint3D.Create( X_, Y_, Z_ );
                    Nor :=          C.Grad( X_, Y_, Z_ );
               end;

               Ps := Ps + [ P ];

               Result := High( Ps );
          end;

     for Z := 0 to Grids.BricsZ do
     for Y := 0 to Grids.BricsY do
     begin
          X0 := 0;
          G0 := Grids[ X0, Y, Z ];
          for X1 := 1 to Grids.BricsX do
          begin
               G1 := Grids[ X1, Y, Z ];

               if ( G0 < 0 ) xor ( G1 < 0 ) then
               begin
                    d := G0 / ( G0 - G1 );

                    EsX.Add( TInteger3D.Create( X0, Y, Z ), AddPoin( X0 + d, Y, Z ) );
               end;

               X0 := X1;
               G0 := G1;
          end;
     end;

     for X := 0 to Grids.BricsX do
     for Z := 0 to Grids.BricsZ do
     begin
          Y0 := 0;
          G0 := Grids[ X, Y0, Z ];
          for Y1 := 1 to Grids.BricsY do
          begin
               G1 := Grids[ X, Y1, Z ];

               if ( G0 < 0 ) xor ( G1 < 0 ) then
               begin
                    d := G0 / ( G0 - G1 );

                    EsY.Add( TInteger3D.Create( X, Y0, Z ), AddPoin( X, Y0 + d, Z ) );
               end;

               Y0 := Y1;
               G0 := G1;
          end;
     end;

     for Y := 0 to Grids.BricsY do
     for X := 0 to Grids.BricsX do
     begin
          Z0 := 0;
          G0 := Grids[ X, Y, Z0 ];
          for Z1 := 1 to Grids.BricsZ do
          begin
               G1 := Grids[ X, Y, Z1 ];

               if ( G0 < 0 ) xor ( G1 < 0 ) then
               begin
                    d := G0 / ( G0 - G1 );

                    EsZ.Add( TInteger3D.Create( X, Y, Z0 ), AddPoin( X, Y, Z0 + d ) );
               end;

               Z0 := Z1;
               G0 := G1;
          end;
     end;

     PsN := Length( Ps );

     ////////// 三角面生成

     Fs := [];

     FindPoin := function ( const I_:Byte ) :Integer
          begin
               with C do
               begin
                    case I_ of
                     00: Result := EsX[ TInteger3D.Create( GX[ 0 ], GY[ 0 ], GZ[ 0 ] ) ];
                     01: Result := EsX[ TInteger3D.Create( GX[ 0 ], GY[ 1 ], GZ[ 0 ] ) ];
                     02: Result := EsX[ TInteger3D.Create( GX[ 0 ], GY[ 0 ], GZ[ 1 ] ) ];
                     03: Result := EsX[ TInteger3D.Create( GX[ 0 ], GY[ 1 ], GZ[ 1 ] ) ];

                     04: Result := EsY[ TInteger3D.Create( GX[ 0 ], GY[ 0 ], GZ[ 0 ] ) ];
                     05: Result := EsY[ TInteger3D.Create( GX[ 0 ], GY[ 0 ], GZ[ 1 ] ) ];
                     06: Result := EsY[ TInteger3D.Create( GX[ 1 ], GY[ 0 ], GZ[ 0 ] ) ];
                     07: Result := EsY[ TInteger3D.Create( GX[ 1 ], GY[ 0 ], GZ[ 1 ] ) ];

                     08: Result := EsZ[ TInteger3D.Create( GX[ 0 ], GY[ 0 ], GZ[ 0 ] ) ];
                     09: Result := EsZ[ TInteger3D.Create( GX[ 1 ], GY[ 0 ], GZ[ 0 ] ) ];
                     10: Result := EsZ[ TInteger3D.Create( GX[ 0 ], GY[ 1 ], GZ[ 0 ] ) ];
                     11: Result := EsZ[ TInteger3D.Create( GX[ 1 ], GY[ 1 ], GZ[ 0 ] ) ];

                    else Result := -1;
                    end;
               end;
          end;

     C.ForBrics( procedure
     var
        T :TArray<Byte>;
        F :TInteger3D;
     begin
          for T in TRIAsTABLE[ C.Kind ] do
          begin
               with F do
               begin
                    _1 := FindPoin( T[ 0 ] );
                    _2 := FindPoin( T[ 1 ] );
                    _3 := FindPoin( T[ 2 ] );
               end;

               Fs := Fs + [ F ];
          end;
     end );

     FsN := Length( Fs );

     //////////

     EsX.DisposeOf;
     EsY.DisposeOf;
     EsZ.DisposeOf;

     C.DisposeOf;

     ////////// ポリゴン登録

     with _Geometry do
     begin
          with VertexBuffer do
          begin
               Length := PsN{Vert};

               for I := 0 to PsN-1 do
               begin
                    with Ps[ I ] do
                    begin
                         Vertices[ I ] := Pos;
                         Normals [ I ] := Nor;
                    end;
               end;
          end;

          with IndexBuffer do
          begin
               Length := FsN{Face} * 3{Vert/Face};

               J := 0;
               for I := 0 to FsN-1 do
               begin
                    with Fs[ I ] do
                    begin
                         Indices[ J ] := _3;  Inc( J );
                         Indices[ J ] := _2;  Inc( J );
                         Indices[ J ] := _1;  Inc( J );
                    end;
               end;
          end;
     end;

     Repaint;
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TMarcubes.Create( AOwner_:TComponent );
begin
     inherited;

     _Geometry := TMeshData.Create;
     _Material := nil;
     _Grids    := TMarcubeGrids.Create;

     with _Grids do
     begin
          BricsX := 10;
          BricsY := 10;
          BricsZ := 10;
     end;
end;

destructor TMarcubes.Destroy;
begin
     _Grids   .DisposeOf;
     _Geometry.DisposeOf;

     inherited;
end;

/////////////////////////////////////////////////////////////////////// メソッド

procedure TMarcubes.EndUpdate;
begin
     inherited;

     if FUpdating = 0 then MakeModel;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

     TRIAsTABLE := [
          [                                                                                ],
          [ [ 00, 04, 08 ]                                                                 ],
          [ [ 00, 09, 06 ]                                                                 ],
          [ [ 09, 04, 08 ], [ 06, 04, 09 ]                                                 ],
          [ [ 01, 10, 04 ]                                                                 ],
          [ [ 01, 08, 00 ], [ 10, 08, 01 ]                                                 ],
          [ [ 00, 09, 06 ], [ 04, 01, 10 ]                                                 ],
          [ [ 01, 09, 06 ], [ 01, 10, 09 ], [ 10, 08, 09 ]                                 ],
          [ [ 06, 11, 01 ]                                                                 ],
          [ [ 06, 11, 01 ], [ 00, 04, 08 ]                                                 ],
          [ [ 00, 11, 01 ], [ 09, 11, 00 ]                                                 ],
          [ [ 04, 11, 01 ], [ 04, 08, 11 ], [ 08, 09, 11 ]                                 ],
          [ [ 06, 10, 04 ], [ 11, 10, 06 ]                                                 ],
          [ [ 06, 08, 00 ], [ 06, 11, 08 ], [ 11, 10, 08 ]                                 ],
          [ [ 00, 10, 04 ], [ 00, 09, 10 ], [ 09, 11, 10 ]                                 ],
          [ [ 09, 11, 08 ], [ 08, 11, 10 ]                                                 ],
          [ [ 08, 05, 02 ]                                                                 ],
          [ [ 00, 05, 02 ], [ 04, 05, 00 ]                                                 ],
          [ [ 09, 06, 00 ], [ 02, 08, 05 ]                                                 ],
          [ [ 09, 05, 02 ], [ 09, 06, 05 ], [ 06, 04, 05 ]                                 ],
          [ [ 04, 01, 10 ], [ 08, 05, 02 ]                                                 ],
          [ [ 05, 01, 10 ], [ 05, 02, 01 ], [ 02, 00, 01 ]                                 ],
          [ [ 06, 00, 09 ], [ 04, 01, 10 ], [ 02, 08, 05 ]                                 ],
          [ [ 01, 10, 05 ], [ 06, 01, 05 ], [ 06, 05, 02 ], [ 06, 02, 09 ]                 ],
          [ [ 06, 11, 01 ], [ 02, 08, 05 ]                                                 ],
          [ [ 00, 05, 02 ], [ 00, 04, 05 ], [ 01, 06, 11 ]                                 ],
          [ [ 00, 11, 01 ], [ 00, 09, 11 ], [ 02, 08, 05 ]                                 ],
          [ [ 02, 09, 11 ], [ 02, 11, 04 ], [ 02, 04, 05 ], [ 01, 04, 11 ]                 ],
          [ [ 10, 06, 11 ], [ 10, 04, 06 ], [ 08, 05, 02 ]                                 ],
          [ [ 06, 11, 10 ], [ 06, 10, 02 ], [ 06, 02, 00 ], [ 02, 10, 05 ]                 ],
          [ [ 02, 08, 05 ], [ 00, 09, 04 ], [ 09, 10, 04 ], [ 09, 11, 10 ]                 ],
          [ [ 05, 02, 09 ], [ 05, 09, 10 ], [ 10, 09, 11 ]                                 ],
          [ [ 09, 02, 07 ]                                                                 ],
          [ [ 00, 04, 08 ], [ 09, 02, 07 ]                                                 ],
          [ [ 06, 02, 07 ], [ 00, 02, 06 ]                                                 ],
          [ [ 02, 04, 08 ], [ 02, 07, 04 ], [ 07, 06, 04 ]                                 ],
          [ [ 09, 02, 07 ], [ 04, 01, 10 ]                                                 ],
          [ [ 08, 01, 10 ], [ 08, 00, 01 ], [ 09, 02, 07 ]                                 ],
          [ [ 06, 02, 07 ], [ 06, 00, 02 ], [ 04, 01, 10 ]                                 ],
          [ [ 02, 07, 06 ], [ 02, 06, 10 ], [ 02, 10, 08 ], [ 10, 06, 01 ]                 ],
          [ [ 09, 02, 07 ], [ 06, 11, 01 ]                                                 ],
          [ [ 08, 00, 04 ], [ 09, 02, 07 ], [ 01, 06, 11 ]                                 ],
          [ [ 11, 02, 07 ], [ 11, 01, 02 ], [ 01, 00, 02 ]                                 ],
          [ [ 02, 07, 11 ], [ 08, 02, 11 ], [ 08, 11, 01 ], [ 08, 01, 04 ]                 ],
          [ [ 06, 10, 04 ], [ 06, 11, 10 ], [ 07, 09, 02 ]                                 ],
          [ [ 07, 09, 02 ], [ 06, 11, 00 ], [ 11, 08, 00 ], [ 11, 10, 08 ]                 ],
          [ [ 04, 00, 02 ], [ 04, 02, 11 ], [ 04, 11, 10 ], [ 07, 11, 02 ]                 ],
          [ [ 02, 07, 11 ], [ 02, 11, 08 ], [ 08, 11, 10 ]                                 ],
          [ [ 08, 07, 09 ], [ 05, 07, 08 ]                                                 ],
          [ [ 00, 07, 09 ], [ 00, 04, 07 ], [ 04, 05, 07 ]                                 ],
          [ [ 08, 06, 00 ], [ 08, 05, 06 ], [ 05, 07, 06 ]                                 ],
          [ [ 06, 04, 07 ], [ 07, 04, 05 ]                                                 ],
          [ [ 08, 07, 09 ], [ 08, 05, 07 ], [ 10, 04, 01 ]                                 ],
          [ [ 09, 05, 07 ], [ 09, 01, 05 ], [ 09, 00, 01 ], [ 10, 05, 01 ]                 ],
          [ [ 01, 10, 04 ], [ 06, 00, 05 ], [ 06, 05, 07 ], [ 05, 00, 08 ]                 ],
          [ [ 01, 10, 05 ], [ 01, 05, 06 ], [ 06, 05, 07 ]                                 ],
          [ [ 07, 08, 05 ], [ 07, 09, 08 ], [ 06, 11, 01 ]                                 ],
          [ [ 01, 06, 11 ], [ 00, 04, 09 ], [ 04, 07, 09 ], [ 04, 05, 07 ]                 ],
          [ [ 11, 01, 00 ], [ 11, 00, 05 ], [ 11, 05, 07 ], [ 05, 00, 08 ]                 ],
          [ [ 11, 01, 04 ], [ 11, 04, 07 ], [ 07, 04, 05 ]                                 ],
          [ [ 06, 11, 04 ], [ 04, 11, 10 ], [ 07, 09, 08 ], [ 07, 08, 05 ]                 ],
          [ [ 11, 10, 00 ], [ 11, 00, 06 ], [ 10, 05, 00 ], [ 09, 00, 07 ], [ 05, 07, 00 ] ],
          [ [ 05, 07, 00 ], [ 05, 00, 08 ], [ 07, 11, 00 ], [ 04, 00, 10 ], [ 11, 10, 00 ] ],
          [ [ 05, 07, 11 ], [ 10, 05, 11 ]                                                 ],
          [ [ 10, 03, 05 ]                                                                 ],
          [ [ 08, 00, 04 ], [ 05, 10, 03 ]                                                 ],
          [ [ 00, 09, 06 ], [ 05, 10, 03 ]                                                 ],
          [ [ 04, 09, 06 ], [ 04, 08, 09 ], [ 05, 10, 03 ]                                 ],
          [ [ 03, 04, 01 ], [ 05, 04, 03 ]                                                 ],
          [ [ 08, 03, 05 ], [ 08, 00, 03 ], [ 00, 01, 03 ]                                 ],
          [ [ 04, 03, 05 ], [ 04, 01, 03 ], [ 06, 00, 09 ]                                 ],
          [ [ 06, 01, 03 ], [ 06, 03, 08 ], [ 06, 08, 09 ], [ 05, 08, 03 ]                 ],
          [ [ 01, 06, 11 ], [ 10, 03, 05 ]                                                 ],
          [ [ 00, 04, 08 ], [ 01, 06, 11 ], [ 05, 10, 03 ]                                 ],
          [ [ 11, 00, 09 ], [ 11, 01, 00 ], [ 10, 03, 05 ]                                 ],
          [ [ 05, 10, 03 ], [ 04, 08, 01 ], [ 08, 11, 01 ], [ 08, 09, 11 ]                 ],
          [ [ 03, 06, 11 ], [ 03, 05, 06 ], [ 05, 04, 06 ]                                 ],
          [ [ 08, 03, 05 ], [ 00, 03, 08 ], [ 00, 11, 03 ], [ 00, 06, 11 ]                 ],
          [ [ 00, 05, 04 ], [ 00, 11, 05 ], [ 00, 09, 11 ], [ 11, 03, 05 ]                 ],
          [ [ 03, 05, 08 ], [ 03, 08, 11 ], [ 11, 08, 09 ]                                 ],
          [ [ 10, 02, 08 ], [ 03, 02, 10 ]                                                 ],
          [ [ 10, 00, 04 ], [ 10, 03, 00 ], [ 03, 02, 00 ]                                 ],
          [ [ 02, 10, 03 ], [ 02, 08, 10 ], [ 00, 09, 06 ]                                 ],
          [ [ 09, 03, 02 ], [ 09, 04, 03 ], [ 09, 06, 04 ], [ 04, 10, 03 ]                 ],
          [ [ 04, 02, 08 ], [ 04, 01, 02 ], [ 01, 03, 02 ]                                 ],
          [ [ 00, 01, 02 ], [ 01, 03, 02 ]                                                 ],
          [ [ 09, 06, 00 ], [ 02, 08, 01 ], [ 02, 01, 03 ], [ 01, 08, 04 ]                 ],
          [ [ 09, 06, 01 ], [ 09, 01, 02 ], [ 02, 01, 03 ]                                 ],
          [ [ 10, 02, 08 ], [ 10, 03, 02 ], [ 11, 01, 06 ]                                 ],
          [ [ 06, 11, 01 ], [ 00, 04, 03 ], [ 00, 03, 02 ], [ 03, 04, 10 ]                 ],
          [ [ 08, 03, 02 ], [ 08, 10, 03 ], [ 09, 11, 00 ], [ 11, 01, 00 ]                 ],
          [ [ 03, 02, 04 ], [ 03, 04, 10 ], [ 02, 09, 04 ], [ 01, 04, 11 ], [ 09, 11, 04 ] ],
          [ [ 11, 04, 06 ], [ 11, 02, 04 ], [ 11, 03, 02 ], [ 08, 04, 02 ]                 ],
          [ [ 06, 11, 03 ], [ 06, 03, 00 ], [ 00, 03, 02 ]                                 ],
          [ [ 09, 11, 04 ], [ 09, 04, 00 ], [ 11, 03, 04 ], [ 08, 04, 02 ], [ 03, 02, 04 ] ],
          [ [ 09, 11, 03 ], [ 02, 09, 03 ]                                                 ],
          [ [ 07, 09, 02 ], [ 03, 05, 10 ]                                                 ],
          [ [ 09, 02, 07 ], [ 08, 00, 04 ], [ 03, 05, 10 ]                                 ],
          [ [ 02, 06, 00 ], [ 02, 07, 06 ], [ 03, 05, 10 ]                                 ],
          [ [ 03, 05, 10 ], [ 02, 07, 08 ], [ 07, 04, 08 ], [ 07, 06, 04 ]                 ],
          [ [ 03, 04, 01 ], [ 03, 05, 04 ], [ 02, 07, 09 ]                                 ],
          [ [ 09, 02, 07 ], [ 08, 00, 05 ], [ 00, 03, 05 ], [ 00, 01, 03 ]                 ],
          [ [ 01, 05, 04 ], [ 01, 03, 05 ], [ 00, 02, 06 ], [ 02, 07, 06 ]                 ],
          [ [ 07, 06, 08 ], [ 07, 08, 02 ], [ 06, 01, 08 ], [ 05, 08, 03 ], [ 01, 03, 08 ] ],
          [ [ 06, 11, 01 ], [ 07, 09, 02 ], [ 10, 03, 05 ]                                 ],
          [ [ 03, 05, 10 ], [ 09, 02, 07 ], [ 00, 04, 08 ], [ 01, 06, 11 ]                 ],
          [ [ 10, 03, 05 ], [ 11, 01, 07 ], [ 01, 02, 07 ], [ 01, 00, 02 ]                 ],
          [ [ 08, 01, 04 ], [ 08, 11, 01 ], [ 08, 02, 11 ], [ 07, 11, 02 ], [ 05, 10, 03 ] ],
          [ [ 09, 02, 07 ], [ 06, 11, 05 ], [ 06, 05, 04 ], [ 05, 11, 03 ]                 ],
          [ [ 00, 05, 08 ], [ 00, 03, 05 ], [ 00, 06, 03 ], [ 11, 03, 06 ], [ 09, 02, 07 ] ],
          [ [ 05, 04, 11 ], [ 05, 11, 03 ], [ 04, 00, 11 ], [ 07, 11, 02 ], [ 00, 02, 11 ] ],
          [ [ 03, 05, 08 ], [ 03, 08, 11 ], [ 02, 07, 08 ], [ 07, 11, 08 ]                 ],
          [ [ 07, 10, 03 ], [ 07, 09, 10 ], [ 09, 08, 10 ]                                 ],
          [ [ 07, 10, 03 ], [ 09, 10, 07 ], [ 09, 04, 10 ], [ 09, 00, 04 ]                 ],
          [ [ 00, 08, 10 ], [ 00, 10, 07 ], [ 00, 07, 06 ], [ 03, 07, 10 ]                 ],
          [ [ 10, 03, 07 ], [ 10, 07, 04 ], [ 04, 07, 06 ]                                 ],
          [ [ 04, 09, 08 ], [ 04, 03, 09 ], [ 04, 01, 03 ], [ 03, 07, 09 ]                 ],
          [ [ 07, 09, 00 ], [ 07, 00, 03 ], [ 03, 00, 01 ]                                 ],
          [ [ 01, 03, 08 ], [ 01, 08, 04 ], [ 03, 07, 08 ], [ 00, 08, 06 ], [ 07, 06, 08 ] ],
          [ [ 07, 06, 01 ], [ 03, 07, 01 ]                                                 ],
          [ [ 06, 11, 01 ], [ 07, 09, 03 ], [ 09, 10, 03 ], [ 09, 08, 10 ]                 ],
          [ [ 09, 03, 07 ], [ 09, 10, 03 ], [ 09, 00, 10 ], [ 04, 10, 00 ], [ 06, 11, 01 ] ],
          [ [ 01, 00, 07 ], [ 01, 07, 11 ], [ 00, 08, 07 ], [ 03, 07, 10 ], [ 08, 10, 07 ] ],
          [ [ 10, 03, 07 ], [ 10, 07, 04 ], [ 11, 01, 07 ], [ 01, 04, 07 ]                 ],
          [ [ 09, 08, 03 ], [ 09, 03, 07 ], [ 08, 04, 03 ], [ 11, 03, 06 ], [ 04, 06, 03 ] ],
          [ [ 07, 09, 00 ], [ 07, 00, 03 ], [ 06, 11, 00 ], [ 11, 03, 00 ]                 ],
          [ [ 00, 08, 04 ], [ 11, 03, 07 ]                                                 ],
          [ [ 07, 11, 03 ]                                                                 ],
          [ [ 07, 03, 11 ]                                                                 ],
          [ [ 00, 04, 08 ], [ 11, 07, 03 ]                                                 ],
          [ [ 06, 00, 09 ], [ 11, 07, 03 ]                                                 ],
          [ [ 09, 04, 08 ], [ 09, 06, 04 ], [ 11, 07, 03 ]                                 ],
          [ [ 11, 07, 03 ], [ 01, 10, 04 ]                                                 ],
          [ [ 01, 08, 00 ], [ 01, 10, 08 ], [ 03, 11, 07 ]                                 ],
          [ [ 09, 06, 00 ], [ 11, 07, 03 ], [ 04, 01, 10 ]                                 ],
          [ [ 07, 03, 11 ], [ 09, 06, 10 ], [ 09, 10, 08 ], [ 10, 06, 01 ]                 ],
          [ [ 07, 01, 06 ], [ 03, 01, 07 ]                                                 ],
          [ [ 01, 07, 03 ], [ 01, 06, 07 ], [ 00, 04, 08 ]                                 ],
          [ [ 07, 00, 09 ], [ 07, 03, 00 ], [ 03, 01, 00 ]                                 ],
          [ [ 04, 08, 09 ], [ 04, 09, 03 ], [ 04, 03, 01 ], [ 03, 09, 07 ]                 ],
          [ [ 10, 07, 03 ], [ 10, 04, 07 ], [ 04, 06, 07 ]                                 ],
          [ [ 00, 10, 08 ], [ 00, 07, 10 ], [ 00, 06, 07 ], [ 03, 10, 07 ]                 ],
          [ [ 07, 03, 10 ], [ 09, 07, 10 ], [ 09, 10, 04 ], [ 09, 04, 00 ]                 ],
          [ [ 07, 03, 10 ], [ 07, 10, 09 ], [ 09, 10, 08 ]                                 ],
          [ [ 02, 08, 05 ], [ 07, 03, 11 ]                                                 ],
          [ [ 05, 00, 04 ], [ 05, 02, 00 ], [ 07, 03, 11 ]                                 ],
          [ [ 00, 09, 06 ], [ 02, 08, 05 ], [ 11, 07, 03 ]                                 ],
          [ [ 11, 07, 03 ], [ 09, 06, 02 ], [ 06, 05, 02 ], [ 06, 04, 05 ]                 ],
          [ [ 08, 05, 02 ], [ 10, 04, 01 ], [ 07, 03, 11 ]                                 ],
          [ [ 11, 07, 03 ], [ 01, 10, 02 ], [ 01, 02, 00 ], [ 02, 10, 05 ]                 ],
          [ [ 00, 09, 06 ], [ 01, 10, 04 ], [ 02, 08, 05 ], [ 11, 07, 03 ]                 ],
          [ [ 06, 02, 09 ], [ 06, 05, 02 ], [ 06, 01, 05 ], [ 10, 05, 01 ], [ 11, 07, 03 ] ],
          [ [ 07, 01, 06 ], [ 07, 03, 01 ], [ 05, 02, 08 ]                                 ],
          [ [ 00, 04, 02 ], [ 02, 04, 05 ], [ 01, 06, 07 ], [ 01, 07, 03 ]                 ],
          [ [ 08, 05, 02 ], [ 00, 09, 03 ], [ 00, 03, 01 ], [ 03, 09, 07 ]                 ],
          [ [ 03, 01, 09 ], [ 03, 09, 07 ], [ 01, 04, 09 ], [ 02, 09, 05 ], [ 04, 05, 09 ] ],
          [ [ 02, 08, 05 ], [ 07, 03, 04 ], [ 07, 04, 06 ], [ 04, 03, 10 ]                 ],
          [ [ 02, 00, 10 ], [ 02, 10, 05 ], [ 00, 06, 10 ], [ 03, 10, 07 ], [ 06, 07, 10 ] ],
          [ [ 09, 04, 00 ], [ 09, 10, 04 ], [ 09, 07, 10 ], [ 03, 10, 07 ], [ 02, 08, 05 ] ],
          [ [ 05, 02, 09 ], [ 05, 09, 10 ], [ 07, 03, 09 ], [ 03, 10, 09 ]                 ],
          [ [ 09, 03, 11 ], [ 02, 03, 09 ]                                                 ],
          [ [ 09, 03, 11 ], [ 09, 02, 03 ], [ 08, 00, 04 ]                                 ],
          [ [ 06, 03, 11 ], [ 06, 00, 03 ], [ 00, 02, 03 ]                                 ],
          [ [ 11, 06, 04 ], [ 11, 04, 02 ], [ 11, 02, 03 ], [ 08, 02, 04 ]                 ],
          [ [ 03, 09, 02 ], [ 03, 11, 09 ], [ 01, 10, 04 ]                                 ],
          [ [ 09, 02, 11 ], [ 11, 02, 03 ], [ 08, 00, 01 ], [ 08, 01, 10 ]                 ],
          [ [ 04, 01, 10 ], [ 06, 00, 11 ], [ 00, 03, 11 ], [ 00, 02, 03 ]                 ],
          [ [ 10, 08, 06 ], [ 10, 06, 01 ], [ 08, 02, 06 ], [ 11, 06, 03 ], [ 02, 03, 06 ] ],
          [ [ 09, 01, 06 ], [ 09, 02, 01 ], [ 02, 03, 01 ]                                 ],
          [ [ 08, 00, 04 ], [ 09, 02, 06 ], [ 02, 01, 06 ], [ 02, 03, 01 ]                 ],
          [ [ 00, 02, 01 ], [ 01, 02, 03 ]                                                 ],
          [ [ 04, 08, 02 ], [ 04, 02, 01 ], [ 01, 02, 03 ]                                 ],
          [ [ 09, 02, 03 ], [ 09, 03, 04 ], [ 09, 04, 06 ], [ 04, 03, 10 ]                 ],
          [ [ 02, 03, 06 ], [ 02, 06, 09 ], [ 03, 10, 06 ], [ 00, 06, 08 ], [ 10, 08, 06 ] ],
          [ [ 10, 04, 00 ], [ 10, 00, 03 ], [ 03, 00, 02 ]                                 ],
          [ [ 10, 08, 02 ], [ 03, 10, 02 ]                                                 ],
          [ [ 03, 08, 05 ], [ 03, 11, 08 ], [ 11, 09, 08 ]                                 ],
          [ [ 00, 04, 05 ], [ 00, 05, 11 ], [ 00, 11, 09 ], [ 11, 05, 03 ]                 ],
          [ [ 08, 05, 03 ], [ 00, 08, 03 ], [ 00, 03, 11 ], [ 00, 11, 06 ]                 ],
          [ [ 03, 11, 06 ], [ 03, 06, 05 ], [ 05, 06, 04 ]                                 ],
          [ [ 04, 01, 10 ], [ 08, 05, 11 ], [ 08, 11, 09 ], [ 11, 05, 03 ]                 ],
          [ [ 11, 09, 05 ], [ 11, 05, 03 ], [ 09, 00, 05 ], [ 10, 05, 01 ], [ 00, 01, 05 ] ],
          [ [ 00, 11, 06 ], [ 00, 03, 11 ], [ 00, 08, 03 ], [ 05, 03, 08 ], [ 04, 01, 10 ] ],
          [ [ 03, 11, 06 ], [ 03, 06, 05 ], [ 01, 10, 06 ], [ 10, 05, 06 ]                 ],
          [ [ 06, 03, 01 ], [ 06, 08, 03 ], [ 06, 09, 08 ], [ 05, 03, 08 ]                 ],
          [ [ 04, 05, 09 ], [ 04, 09, 00 ], [ 05, 03, 09 ], [ 06, 09, 01 ], [ 03, 01, 09 ] ],
          [ [ 08, 05, 03 ], [ 08, 03, 00 ], [ 00, 03, 01 ]                                 ],
          [ [ 03, 01, 04 ], [ 05, 03, 04 ]                                                 ],
          [ [ 04, 06, 03 ], [ 04, 03, 10 ], [ 06, 09, 03 ], [ 05, 03, 08 ], [ 09, 08, 03 ] ],
          [ [ 00, 06, 09 ], [ 05, 03, 10 ]                                                 ],
          [ [ 10, 04, 00 ], [ 10, 00, 03 ], [ 08, 05, 00 ], [ 05, 03, 00 ]                 ],
          [ [ 10, 05, 03 ]                                                                 ],
          [ [ 05, 11, 07 ], [ 10, 11, 05 ]                                                 ],
          [ [ 05, 11, 07 ], [ 05, 10, 11 ], [ 04, 08, 00 ]                                 ],
          [ [ 11, 05, 10 ], [ 11, 07, 05 ], [ 09, 06, 00 ]                                 ],
          [ [ 07, 10, 11 ], [ 07, 05, 10 ], [ 06, 04, 09 ], [ 04, 08, 09 ]                 ],
          [ [ 11, 04, 01 ], [ 11, 07, 04 ], [ 07, 05, 04 ]                                 ],
          [ [ 11, 00, 01 ], [ 11, 05, 00 ], [ 11, 07, 05 ], [ 05, 08, 00 ]                 ],
          [ [ 00, 09, 06 ], [ 04, 01, 07 ], [ 04, 07, 05 ], [ 07, 01, 11 ]                 ],
          [ [ 07, 05, 01 ], [ 07, 01, 11 ], [ 05, 08, 01 ], [ 06, 01, 09 ], [ 08, 09, 01 ] ],
          [ [ 01, 05, 10 ], [ 01, 06, 05 ], [ 06, 07, 05 ]                                 ],
          [ [ 00, 04, 08 ], [ 01, 06, 10 ], [ 06, 05, 10 ], [ 06, 07, 05 ]                 ],
          [ [ 09, 07, 05 ], [ 09, 05, 01 ], [ 09, 01, 00 ], [ 10, 01, 05 ]                 ],
          [ [ 08, 09, 01 ], [ 08, 01, 04 ], [ 09, 07, 01 ], [ 10, 01, 05 ], [ 07, 05, 01 ] ],
          [ [ 06, 07, 04 ], [ 07, 05, 04 ]                                                 ],
          [ [ 08, 00, 06 ], [ 08, 06, 05 ], [ 05, 06, 07 ]                                 ],
          [ [ 00, 09, 07 ], [ 00, 07, 04 ], [ 04, 07, 05 ]                                 ],
          [ [ 08, 09, 07 ], [ 05, 08, 07 ]                                                 ],
          [ [ 02, 11, 07 ], [ 02, 08, 11 ], [ 08, 10, 11 ]                                 ],
          [ [ 04, 02, 00 ], [ 04, 11, 02 ], [ 04, 10, 11 ], [ 07, 02, 11 ]                 ],
          [ [ 06, 00, 09 ], [ 11, 07, 08 ], [ 11, 08, 10 ], [ 08, 07, 02 ]                 ],
          [ [ 06, 04, 02 ], [ 06, 02, 09 ], [ 04, 10, 02 ], [ 07, 02, 11 ], [ 10, 11, 02 ] ],
          [ [ 02, 11, 07 ], [ 08, 11, 02 ], [ 08, 01, 11 ], [ 08, 04, 01 ]                 ],
          [ [ 11, 07, 02 ], [ 11, 02, 01 ], [ 01, 02, 00 ]                                 ],
          [ [ 08, 07, 02 ], [ 08, 11, 07 ], [ 08, 04, 11 ], [ 01, 11, 04 ], [ 00, 09, 06 ] ],
          [ [ 11, 07, 02 ], [ 11, 02, 01 ], [ 09, 06, 02 ], [ 06, 01, 02 ]                 ],
          [ [ 02, 06, 07 ], [ 02, 10, 06 ], [ 02, 08, 10 ], [ 10, 01, 06 ]                 ],
          [ [ 06, 07, 10 ], [ 06, 10, 01 ], [ 07, 02, 10 ], [ 04, 10, 00 ], [ 02, 00, 10 ] ],
          [ [ 08, 10, 07 ], [ 08, 07, 02 ], [ 10, 01, 07 ], [ 09, 07, 00 ], [ 01, 00, 07 ] ],
          [ [ 09, 07, 02 ], [ 04, 10, 01 ]                                                 ],
          [ [ 02, 08, 04 ], [ 02, 04, 07 ], [ 07, 04, 06 ]                                 ],
          [ [ 06, 07, 02 ], [ 00, 06, 02 ]                                                 ],
          [ [ 02, 08, 04 ], [ 02, 04, 07 ], [ 00, 09, 04 ], [ 09, 07, 04 ]                 ],
          [ [ 09, 07, 02 ]                                                                 ],
          [ [ 05, 09, 02 ], [ 05, 10, 09 ], [ 10, 11, 09 ]                                 ],
          [ [ 00, 04, 08 ], [ 09, 02, 10 ], [ 09, 10, 11 ], [ 10, 02, 05 ]                 ],
          [ [ 06, 10, 11 ], [ 06, 02, 10 ], [ 06, 00, 02 ], [ 02, 05, 10 ]                 ],
          [ [ 10, 11, 02 ], [ 10, 02, 05 ], [ 11, 06, 02 ], [ 08, 02, 04 ], [ 06, 04, 02 ] ],
          [ [ 02, 11, 09 ], [ 02, 04, 11 ], [ 02, 05, 04 ], [ 01, 11, 04 ]                 ],
          [ [ 00, 01, 05 ], [ 00, 05, 08 ], [ 01, 11, 05 ], [ 02, 05, 09 ], [ 11, 09, 05 ] ],
          [ [ 00, 02, 11 ], [ 00, 11, 06 ], [ 02, 05, 11 ], [ 01, 11, 04 ], [ 05, 04, 11 ] ],
          [ [ 06, 01, 11 ], [ 02, 05, 08 ]                                                 ],
          [ [ 01, 05, 10 ], [ 06, 05, 01 ], [ 06, 02, 05 ], [ 06, 09, 02 ]                 ],
          [ [ 06, 10, 01 ], [ 06, 05, 10 ], [ 06, 09, 05 ], [ 02, 05, 09 ], [ 00, 04, 08 ] ],
          [ [ 05, 10, 01 ], [ 05, 01, 02 ], [ 02, 01, 00 ]                                 ],
          [ [ 05, 10, 01 ], [ 05, 01, 02 ], [ 04, 08, 01 ], [ 08, 02, 01 ]                 ],
          [ [ 09, 02, 05 ], [ 09, 05, 06 ], [ 06, 05, 04 ]                                 ],
          [ [ 08, 00, 06 ], [ 08, 06, 05 ], [ 09, 02, 06 ], [ 02, 05, 06 ]                 ],
          [ [ 00, 02, 05 ], [ 04, 00, 05 ]                                                 ],
          [ [ 08, 02, 05 ]                                                                 ],
          [ [ 09, 08, 11 ], [ 08, 10, 11 ]                                                 ],
          [ [ 00, 04, 10 ], [ 00, 10, 09 ], [ 09, 10, 11 ]                                 ],
          [ [ 06, 00, 08 ], [ 06, 08, 11 ], [ 11, 08, 10 ]                                 ],
          [ [ 06, 04, 10 ], [ 11, 06, 10 ]                                                 ],
          [ [ 04, 01, 11 ], [ 04, 11, 08 ], [ 08, 11, 09 ]                                 ],
          [ [ 00, 01, 11 ], [ 09, 00, 11 ]                                                 ],
          [ [ 04, 01, 11 ], [ 04, 11, 08 ], [ 06, 00, 11 ], [ 00, 08, 11 ]                 ],
          [ [ 06, 01, 11 ]                                                                 ],
          [ [ 01, 06, 09 ], [ 01, 09, 10 ], [ 10, 09, 08 ]                                 ],
          [ [ 01, 06, 09 ], [ 01, 09, 10 ], [ 00, 04, 09 ], [ 04, 10, 09 ]                 ],
          [ [ 01, 00, 08 ], [ 10, 01, 08 ]                                                 ],
          [ [ 01, 04, 10 ]                                                                 ],
          [ [ 09, 08, 04 ], [ 06, 09, 04 ]                                                 ],
          [ [ 00, 06, 09 ]                                                                 ],
          [ [ 00, 08, 04 ]                                                                 ],
          [                                                                                ] ];

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
