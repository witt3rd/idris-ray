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
record Dielectric where
  constructor MkDielectric
  refIdx : Double

scatterDielectric : Ray -> HitPoint -> Dielectric -> Eff (Maybe Scattering) [RND]
scatterDielectric (MkRay origin dir) (MkHitPoint point normal frontFace _) (MkDielectric refIdx) =
  let
    attenuation : Color = [1, 1, 1]
    etaIOverEtaT : Double = if frontFace then (1 / refIdx) else refIdx
    unitDir : Vec3 = unitVector dir
    cos_theta : Double = min (dot (-unitDir) normal) 1
    sin_theta : Double = sqrt (1 - (cos_theta * cos_theta))
  in
    if (etaIOverEtaT * sin_theta) > 1 then
      let
        reflected : Vec3 = reflect unitDir normal
        scattered : Ray = MkRay point reflected
      in
        pure $ Just (MkScattering attenuation scattered)
    else
      let
        refracted : Vec3 = refract unitDir normal etaIOverEtaT
        scattered : Ray = MkRay point refracted
      in
        pure $ Just (MkScattering attenuation scattered)

Material Dielectric where
  scatter = scatterDielectric
