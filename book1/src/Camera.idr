module Camera

import public Ray

%access public export

record Camera where
  constructor MkCamera
  origin : Point3
  lowerLeftCorner : Vec3
  horizontal : Vec3
  vertical : Vec3
  u, v, w : Vec3
  lensRadius : Double

newCamera : (origin : Point3) ->
            (lookAt : Point3) ->
            (vUp : Vec3) ->
            (vfov : Double) ->
            (aspectRatio : Double) ->
            (aperture : Double) ->
            (focusDist : Double) ->
            Camera
newCamera origin lookAt vUp vfov aspectRatio aperture focusDist =
  let
    theta : Double = degToRad vfov
    h : Double = tan (theta/2.0)
    viewportHeight : Double = 2.0 * h
    viewportWidth : Double = aspectRatio * viewportHeight

    w : Vec3 = unitVector (origin - lookAt)
    u : Vec3 = unitVector (cross vUp w)
    v : Vec3 = cross w u

    horizontal : Vec3 = focusDist <# (viewportWidth <# u)
    vertical : Vec3 = focusDist <# (viewportHeight <# v)
    lowerLeftCorner : Vec3 =
      origin - (0.5 <# horizontal) - (0.5 <# vertical) - (focusDist <# w)
    lensRadius : Double = aperture / 2.0
  in
    MkCamera origin lowerLeftCorner horizontal vertical u v w lensRadius

getRay : Camera -> (s : Double) -> (t : Double) -> Eff Ray [RND]
getRay (MkCamera origin lowerLeftCorner horizontal vertical u v w lensRadius) s t =
  let
    rd : Vec3 = lensRadius <# !randomInUnitDiskR
    offset : Vec3 = ((getX rd) <# u) + ((getY rd) <# v)
  in
    pure $ MkRay (origin + offset) (lowerLeftCorner + (s <# horizontal) + (t <# vertical) - origin - offset)
