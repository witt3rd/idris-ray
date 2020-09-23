module Hit

import public HitPoint
import public Material

%access public export

data Hit : Type where
  MkHit :
    Material m =>
    (hitPoint : HitPoint) ->
    (material : m) ->
    Hit

hitPoint : Hit -> HitPoint
hitPoint (MkHit hitPoint _) = hitPoint

-- material : Hit m -> m
-- material (MkHit _ mat) = mat

%name Hit hit, hit1, hit2

newHit : Material m => Ray -> (t : Double) -> Point3 -> (outwardNormal : Vec3) -> m -> Hit
newHit ray t point outwardNormal material =
  MkHit (newHitPoint ray t point outwardNormal) material

interface Hittable a where
  hit : Ray -> (tMin : Double) -> (tMax : Double) -> a -> Maybe Hit

closestHit : Hittable a => Ray -> (tMin : Double) -> (tMax : Double) -> List a -> Maybe Hit
closestHit _ _ _ [] = Nothing
closestHit ray tMin tMax (x :: xs) =
  case hit ray tMin tMax x of
    Nothing => closestHit ray tMin tMax xs
    Just xHit =>
      case closestHit ray tMin (t (hitPoint xHit)) xs of
        Nothing => Just xHit
        Just xsHit => Just xsHit
