module Image

import public Color
import public Data.Matrix

%access public export
%default total

||| General image type
Image : (w : Nat) -> (h : Nat) -> Type -> Type
Image w h c = Matrix h w c

{- Image formats -}

RGB8Image : (w : Nat) -> (h : Nat) -> Type
RGB8Image h w = Image w h RGB8

RGBdImage : (w : Nat) -> (h : Nat) -> Type
RGBdImage h w = Matrix h w RGBd

{- Image conversions -}

Cast (RGBdImage w h) (RGB8Image w h) where
  cast [] = []
  cast (x :: xs) = (toRGB8 x) :: (cast xs)
    where
      toRGB8 : Vect w RGBd -> Vect w RGB8
      toRGB8 [] = []
      toRGB8 (y :: xs) = (cast y) :: (toRGB8 xs)
