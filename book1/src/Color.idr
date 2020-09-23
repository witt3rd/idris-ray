module Color

import public Vec3
import Util

%access public export

Color : Type
Color = Vec3

%name Color color, color1, color2

RGB : Type
RGB = Vect 3 Bits8

%name RGB rgb, rgb1, rgb2

cvtColor : Double -> Bits8
cvtColor x = fromInteger (the Integer (cast (255.99 * (clamp 0 1 x))))

toRGB : Color -> (samplesPerPixel : Nat) -> RGB
toRGB color samplesPerPixel =
  let scale : Double = 1.0 / (fromInteger (toIntegerNat samplesPerPixel)) in
  map cvtColor (scale <# color)
