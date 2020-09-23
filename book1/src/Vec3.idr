module Vec3

import public Data.Vect
import public Data.Matrix.Numeric

import public Util

%access public export

{- Types -}
Vec3 : Type
Vec3 = Vect 3 Double

%name Vec3 vec, vec1, vec2

Point3 : Type
Point3 = Vec3

%name Point3 point, point1, point2

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
dot u v = sum $ zipWith (*) u v

cross : Vec3 -> Vec3 -> Vec3
cross u v =
  let
    u0 : Double = getX u
    u1 : Double = getY u
    u2 : Double = getZ u
    v0 : Double = getX v
    v1 : Double = getY v
    v2 : Double = getZ v
  in
    [u1 * v2 - u2 * v1
    ,u2 * v0 - u0 * v2
    ,u0 * v1 - u1 * v0
    ]

lenSq : Vec3 -> Double
lenSq v = dot v v

len : Vec3 -> Double
len = (sqrt . lenSq)

unitVector : Vec3 -> Vec3
unitVector v =
  let l : Double = len v in
  if l == 0.0 then v else map (/ l) v

random : Eff Vec3 [RND]
random = pure $ [!randomUnitDouble, !randomUnitDouble, !randomUnitDouble]

randomIn : (min : Double) -> (max : Double) -> Eff Vec3 [RND]
randomIn min max =
  pure $ [!(randomDouble min max), !(randomDouble min max), !(randomDouble min max)]

-- use the rejection method: pick a point in the unit cube, test that it falls in within the unit sphere
randomInUnitSphereR : Eff Vec3 [RND]
randomInUnitSphereR =
  let
    p : Vec3 = !(randomIn (-1) 1)
    l : Double = lenSq p
  in
    if p >= 1 then randomInUnitSphereR else pure p

-- pick points on the unit ball and scale them
randomInUnitSphere : Eff Vec3 [RND]
randomInUnitSphere =
  let
    a : Double = !(randomDouble 0 (2 * pi))
    z : Double = !(randomDouble (-1) 1)
    r : Double = sqrt (1 - (z * z))
    p : Vec3 = [r * (cos a), r * (sin a), z]
  in
    pure p

randomInHemisphere : (normal : Vec3) -> Eff Vec3 [RND]
randomInHemisphere normal =
  let
    inUnitSphere : Vec3 = !randomInUnitSphereR
  in
    if (dot inUnitSphere normal) > 0 then
      pure inUnitSphere
    else
      pure (-inUnitSphere)

randomInUnitDiskR : Eff Vec3 [RND]
randomInUnitDiskR =
  let
    p : Vec3 = [!(randomDouble (-1) 1), !(randomDouble (-1) 1), 0]
    l : Double = lenSq p
  in
    if p >= 1 then randomInUnitDiskR else pure p

reflect : (v : Vec3) -> (n : Vec3) -> Vec3
reflect v n = v - ((2 * (dot v n)) <# n)

refract :(uv : Vec3) -> (n : Vec3) -> (etaIOverEtaT : Double) -> Vec3
refract uv  n etaIOverEtaT =
  let
    cosTheta : Double = dot (-uv) n
    perp : Vec3 = etaIOverEtaT <# (uv + (cosTheta <# n))
    parallel : Vec3 = (-(sqrt (abs (1 - (lenSq perp))))) <# n
  in
    perp + parallel
