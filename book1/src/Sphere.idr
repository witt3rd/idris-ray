module Sphere

import public Hit

%access public export

record Sphere where
  constructor MkSphere
  center : Point3
  radius : Double

%name Sphere sphere, sphere1, sphere2

Hittable Sphere where
  hit ray@(MkRay origin dir) tMin tMax (MkSphere center radius) =
    let
      oc : Vec3 = origin - center
      a : Double = lenSq dir
      halfB : Double = dot oc dir
      c : Double = (lenSq oc) - (radius * radius)
      discriminant : Double = (halfB * halfB) - (a * c)
    in
      if discriminant > 0 then
        let root : Double = sqrt discriminant in
        case mkHitMaybe (((-halfB) - root) / a) of
          Just h => Just h
          Nothing => mkHitMaybe (((-halfB) + root) / a)
      else
        Nothing
    where
      mkHitMaybe : (t : Double) -> Maybe Hit
      mkHitMaybe t =
        if (t < tMax && t > tMin) then
          let
            point : Point3 = rayAt ray t
            outwardNormal : Vec3 = (1.0 / radius) <# (point - center)
          in
            Just (newHit ray t point outwardNormal)
        else
          Nothing
