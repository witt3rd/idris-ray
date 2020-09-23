module Hit

import public Ray

%access public export

record Hit where
  constructor MkHit
  point : Point3
  normal : Vec3
  isFront : Bool
  t : Double

%name Hit hit, hit1, hit2

newHit : Ray -> (t : Double) -> Point3 -> (outwardNormal : Vec3) -> Hit
newHit (MkRay origin dir) t point outwardNormal =
  let
    isFront : Bool = (dot dir outwardNormal) < 0
    normal : Vec3 = if isFront then outwardNormal else (-outwardNormal)
  in
    MkHit point normal isFront t

interface Hittable a where
  hit : Ray -> (tMin : Double) -> (tMax : Double) -> a -> Maybe Hit

closestHit : Hittable a => Ray -> (tMin : Double) -> (tMax : Double) -> List a -> Maybe Hit
closestHit _ _ _ [] = Nothing
closestHit ray tMin tMax (x :: xs) =
  case hit ray tMin tMax x of
    Nothing => closestHit ray tMin tMax xs
    Just xHit =>
      case closestHit ray tMin (t xHit) xs of
        Nothing => Just xHit
        Just xsHit => Just xsHit
