module Vec3

import public Data.Vect
import public Data.Matrix.Numeric

%access public export

{- Types -}
Vec3 : Type
Vec3 = Vect 3 Double

Point3 : Type
Point3 = Vec3

{- Accessors -}
xIdx : Fin 3
xIdx = restrict 2 0

yIdx : Fin 3
yIdx = restrict 2 1

zIdx : Fin 3
zIdx = restrict 2 2

getX : Vec3 -> Double
getX = index xIdx

getY : Vec3 -> Double
getY = index yIdx

getZ : Vec3 -> Double
getZ = index zIdx

{- Functions -}
dot : Vec3 -> Vec3 -> Double
dot a b = sum $ zipWith (*) a b

lenSq : Vec3 -> Double
lenSq v = dot v v

len : Vec3 -> Double
len = (sqrt . lenSq)

unitVector : Vec3 -> Vec3
unitVector v =
  let
    l : Double = len v
  in
    if l == 0.0 then v else map (/ l) v
