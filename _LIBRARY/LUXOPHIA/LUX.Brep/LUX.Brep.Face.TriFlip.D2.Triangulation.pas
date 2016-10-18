﻿unit LUX.Brep.Face.TriFlip.D2.Triangulation;

interface //#################################################################### ■

uses LUX, LUX.D2, LUX.Brep.Face.TriFlip.D2.Delaunay;

type //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【型】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

     //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTriGenPoin

     TTriGenPoin = class( TDelaPoin2D )
     private
     protected
       _Inside :ShortInt;
     public
       ///// プロパティ
       property Inside :ShortInt read _Inside write _Inside;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTriGenFace

     TTriGenFace = class( TDelaFace2D )
     private
     protected
       _Inside :Boolean;
       ///// アクセス
       procedure SetPoin( const I_:Byte; const Poin_:TDelaPoin2D ); override;
     public
       ///// プロパティ
       property Inside :Boolean read _Inside write _Inside;
     end;

     //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTriGenModel

     TTriGenModel<_TPoin_:TTriGenPoin,constructor;
                  _TFace_:TTriGenFace,constructor> = class( TDelaunay2D<_TPoin_,_TFace_> )
     private
       _EdgePoins :array of TSingle2D;
     protected
       _Radius :Single;
     public
       /////
       constructor Create; override;
       destructor Destroy; override;
       ///// プロパティ
       property Radius :Single read _Radius write _Radius;
       ///// メソッド
       procedure MakeMesh( const Ps_:TArray<TSingle2D> );
       function InsideEdges( const P_:TSingle2D ) :Single;
       procedure PoissonSubDiv;
       procedure FairMesh;
     end;

//const //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【定数】

//var //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【変数】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

implementation //############################################################### ■

uses System.Math,
     LUX.Geometry.D2;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【レコード】

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【クラス】

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTriGenPoin

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTriGenFace

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

procedure TTriGenFace.SetPoin( const I_:Byte; const Poin_:TDelaPoin2D );
begin
     inherited;

     _Inside := Assigned( Poin[1] )
            and Assigned( Poin[2] )
            and Assigned( Poin[3] )
            and ( TTriGenModel<TTriGenPoin,TTriGenFace>( Paren ).InsideEdges( Circle.Center ) < -0.5 );
end;

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TTriGenModel

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& private

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& protected

//&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& public

constructor TTriGenModel<_TPoin_,_TFace_>.Create;
begin
     inherited;

     _Radius := 1;
end;


destructor TTriGenModel<_TPoin_,_TFace_>.Destroy;
begin

     inherited;
end;

////////////////////////////////////////////////////////////////////////////////

procedure TTriGenModel<_TPoin_,_TFace_>.MakeMesh( const Ps_:TArray<TSingle2D> );
var
   A :TSingleArea2D;
   Ps :TArray<TSingle2D>;
   Ls :array of Single;
   EL, L, Ld, T :Single;
   PsN, PsH, EsN, I, I0, I1 :Integer;
   P0, P1, P :TSingle2D;
begin
     DeleteChilds;

     A := BoundingBox( Ps_ );

     A.SizeX := A.SizeX * 2;
     A.SizeY := A.SizeY * 2;

     TTriGenPoin( AddPoin( A.Poin[ 0 ] ) ).Inside := +1;
     TTriGenPoin( AddPoin( A.Poin[ 1 ] ) ).Inside := +1;
     TTriGenPoin( AddPoin( A.Poin[ 2 ] ) ).Inside := +1;
     TTriGenPoin( AddPoin( A.Poin[ 3 ] ) ).Inside := +1;

     //////////

     Ps := Ps_ + [ Ps_[0] ];

     PsN := Length( Ps );
     PsH := High  ( Ps );

     SetLength( Ls, PsN );

     Ls[ 0 ] := 0;
     P0 := Ps[ 0 ];
     for I := 1 to PsH do
     begin
          P1 := Ps[ I ];

          Ls[ I ] := Ls[ I-1 ] + Distance( P0, P1 );

          P0 := P1;
     end;

     //////////

     EL := _Radius * Roo2(2);

     EsN := Ceil( Ls[ PsH ] / EL );

     Ld := Ls[ PsH ] / EsN;

     SetLength( _EdgePoins, EsN );

     L  := 0;
     I0 := 0;  I1 := 1;
     for I := 0 to EsN-1 do
     begin
          while Ls[ I1 ] <= L do
          begin
               I0 := I1;  Inc( I1 );
          end;

          T := ( L        - Ls[ I0 ] )
             / ( Ls[ I1 ] - Ls[ I0 ] );

          P0 := Ps[ I0 ];
          P1 := Ps[ I1 ];

          _EdgePoins[ I ] := ( P1 - P0 ) * T + P0;

          L := L + Ld;
     end;

     //////////

     for P in _EdgePoins do TTriGenPoin( AddPoin( P ) ).Inside := 0;

     PoissonSubDiv;
end;

//------------------------------------------------------------------------------

function TTriGenModel<_TPoin_,_TFace_>.InsideEdges( const P_:TSingle2D ) :Single;
var
   I :Integer;
   P0, P1, P2, V0, V1 :TSingle2D;
   A :Single;
begin
     Result := 0;

     if not Assigned( _EdgePoins ) then Exit;

     P2 := _EdgePoins[ 0 ];
     P1 := P2;
     for I := 1 to High( _EdgePoins )-1 do
     begin
          P0 := P1;  P1 := _EdgePoins[ I ];

          V0 := P0 - P_;
          V1 := P1 - P_;

          A := ArcTan2( V0.X * V1.Y - V0.Y * V1.X,
                        V0.X * V1.X + V0.Y * V1.Y );

          Result := Result + A;
     end;

     V0 := P1 - P_;
     V1 := P2 - P_;

     A := ArcTan2( V0.X * V1.Y - V0.Y * V1.X,
                   V0.X * V1.X + V0.Y * V1.Y );

     Result := Result + A;

     Result := Result / Pi2;
end;

//------------------------------------------------------------------------------

procedure TTriGenModel<_TPoin_,_TFace_>.PoissonSubDiv;
var
   I :Integer;
   F :_TFace_;
label
     FIND;
begin
     FIND:
     for I := 0 to ChildsN-1 do
     begin
          F := _TFace_( Childs[ I ] );

          if ( F.Open = 0 ) and
             ( _TPoin_( F.Poin[1] ).Inside <= 0 ) and
             ( _TPoin_( F.Poin[2] ).Inside <= 0 ) and
             ( _TPoin_( F.Poin[3] ).Inside <= 0 ) and
               F.Inside and
             ( F.Circle.Radius > _Radius ) then
          begin
               TTriGenPoin( AddPoin3( F.Circle.Center, F ) ).Inside := -1;

               goto FIND;
          end;
     end;
end;

//------------------------------------------------------------------------------

procedure TTriGenModel<_TPoin_,_TFace_>.FairMesh;
var
   I :Integer;
   F :_TFace_;
begin
     for I := ChildsN-1 downto 0 do
     begin
          F := _TFace_( Childs[ I ] );

          if not F.Inside then F.Free;
     end;

     for I := 3 downto 0 do PoinModel.Childs[ I ].Free;
end;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$【ルーチン】

//############################################################################## □

initialization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 初期化

finalization //$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 最終化

end. //######################################################################### ■
