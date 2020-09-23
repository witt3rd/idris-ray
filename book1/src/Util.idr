module Util

import public Effects
import public Effect.Random

%access public export

infinity : Double
infinity = 2e+308

degToRad : (deg : Double) -> Double
degToRad deg = deg * pi / 180.0

clamp : (min : Double) -> (max : Double) -> (x : Double) -> Double
clamp min max x =
  if x < min then min
  else if x > max then max
  else x
  
RAND_MAX : Integer
RAND_MAX = 32767

randomUnitDouble : Eff Double [RND]
randomUnitDouble =
  pure $ (fromInteger !(rndInt 0 RAND_MAX)) / (1.0 + (fromInteger RAND_MAX))

randomDouble : (min : Double) -> (max : Double) -> Eff Double [RND]
randomDouble min max =
    pure $ (min + (max - min) * !randomUnitDouble)
