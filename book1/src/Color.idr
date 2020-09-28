module Color

import public Data.Vect

%access public export
%default total

||| General color type
Color : (ch : Nat) -> (v: Type) -> Type
Color = Vect

{- Color formats -}

||| 3-channel, 8-bits per channel
-- data RGB8 : Type where
--   rgb8 : Color 3 Bits8 -> RGB8
RGB8 : Type
RGB8 = Color 3 Bits8

||| 3-channel, double-precision fp per channel
RGBd : Type
RGBd = Color 3 Double

{- Color conversions -}

Cast RGBd RGB8 where
  cast from = map convert from
  -- cast from = rgb8 (map convert from)
  where
    convert : Double -> Bits8
    convert x = fromInteger (cast {to=Integer} (255.99 * x))
