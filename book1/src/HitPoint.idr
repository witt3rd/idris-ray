module HitPoint

import public Ray

%access public export

record HitPoint where
  constructor MkHitPoint
  point : Point3
  normal : Vec3
  isFront : Bool
  t : Double

%name HitPoint hitPt, hitPt1, hitPt2

newHitPoint : Ray -> (t : Double) -> Point3 -> (outwardNormal : Vec3) -> HitPoint
newHitPoint (MkRay origin dir) t point outwardNormal =
  let
    isFront : Bool = (dot dir outwardNormal) < 0
    normal : Vec3 = if isFront then outwardNormal else (-outwardNormal)
  in
    MkHitPoint point normal isFront t
