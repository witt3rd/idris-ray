module Material

import public Color
import public HitPoint

%access public export

record Scattering where
  constructor MkScattering
  attenuation : Color
  scattered : Ray

interface Material a where
  scatter : Ray -> HitPoint -> a -> Eff (Maybe Scattering) [RND]

{- Lambertian -}
record Lambertian where
  constructor MkLambertian
  albedo : Color

scatterLambertian : Ray -> HitPoint -> Lambertian -> Eff (Maybe Scattering) [RND]
scatterLambertian (MkRay origin dir) (MkHitPoint point normal _ _) (MkLambertian albedo) =
  let
    scatterDir : Vec3 = normal + !randomInUnitSphere
    scattered : Ray = MkRay point scatterDir
  in
    pure $ Just (MkScattering albedo scattered)

Material Lambertian where
  scatter = scatterLambertian

{- Metal -}
record Metal where
  constructor MkMetal
  albedo : Color
  fuzz : Double

newMetal : Color -> (fuzz : Double) -> Metal
newMetal albedo fuzz = MkMetal albedo (if fuzz < 1 then fuzz else 1)

scatterMetal : Ray -> HitPoint -> Metal -> Eff (Maybe Scattering) [RND]
scatterMetal (MkRay origin dir) (MkHitPoint point normal _ _) (MkMetal albedo fuzz) =
  let
    reflected : Vec3 = reflect (unitVector dir) normal
  in
    if dot reflected normal > 0 then
      pure $ Just (MkScattering albedo (MkRay point (reflected + (fuzz <# !randomInUnitSphere))))
    else
      pure $ Nothing

Material Metal where
  scatter = scatterMetal

{- Dielectric -}
schlick : (cosine : Double) -> (refIdx : Double) -> Double
schlick cosine refIdx =
  let
    r0 : Double = (1 - refIdx) / (1 - refIdx)
    r0' : Double = r0 * r0
  in
    r0 + ((1.0 - r0) * (pow (1.0 - cosine) 5.0))


record Dielectric where
  constructor MkDielectric
  refIdx : Double

scatterDielectric : Ray -> HitPoint -> Dielectric -> Eff (Maybe Scattering) [RND]
scatterDielectric (MkRay origin dir) (MkHitPoint point normal frontFace _) (MkDielectric refIdx) =
  if (etaIOverEtaT * sinTheta) > 1 then
    pure scatterReflect
  else
    if !randomUnitDouble < (schlick cosTheta etaIOverEtaT) then
      pure scatterReflect
    else
      pure scatterRefract      
  where
    attenuation : Color
    attenuation = [1, 1, 1]

    etaIOverEtaT : Double
    etaIOverEtaT = if frontFace then (1 / refIdx) else refIdx

    unitDir : Vec3
    unitDir = unitVector dir

    cosTheta : Double
    cosTheta = min (dot (-unitDir) normal) 1

    sinTheta : Double
    sinTheta = sqrt (1 - (cosTheta * cosTheta))

    scatterReflect : Maybe Scattering
    scatterReflect =
      let
        reflected : Vec3 = reflect unitDir normal
        scattered : Ray = MkRay point reflected
      in
        Just (MkScattering attenuation scattered)

    scatterRefract : Maybe Scattering
    scatterRefract =
      let
        refracted : Vec3 = refract unitDir normal etaIOverEtaT
        scattered : Ray = MkRay point refracted
      in
        Just (MkScattering attenuation scattered)

Material Dielectric where
  scatter = scatterDielectric
