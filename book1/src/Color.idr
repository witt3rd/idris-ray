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

cvtColor : (scale: Double) -> (color : Double) -> Bits8
cvtColor scale color =
  let
    scaled       : Double = scale * color
    gammaCorrect : Double = sqrt scaled
    clamped      : Double = clamp 0 1 gammaCorrect
    byteRange    : Double = 255.99 * clamped
  in
    fromInteger (the Integer (cast byteRange))

toRGB : Color -> (samplesPerPixel : Nat) -> RGB
toRGB color samplesPerPixel =
  let scale : Double = 1.0 / (fromInteger (toIntegerNat samplesPerPixel)) in
  map (cvtColor scale) color
