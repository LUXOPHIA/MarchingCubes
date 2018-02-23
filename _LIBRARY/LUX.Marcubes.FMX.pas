﻿unit LUX.Marcubes.FMX;

interface //#################################################################### ■

uses System.Classes, System.Math.Vectors, System.Generics.Collections,
     FMX.Types3D, FMX.Controls3D, FMX.MaterialSources,
     LUX, LUX.D3, LUX.Marcubes;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     TMarcubes = class;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TVert

     TPoin = record
       Pos :TPoint3D;
       Nor :TPoint3D;
     end;

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

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
       procedure MakeModel;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.SysUtils, System.RTLConsts;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

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

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■