module Camera

import public Ray

%access public export

record Camera where
  constructor MkCamera
  origin : Point3
  lowerLeftCorner : Vec3
  horizontal : Vec3
  vertical : Vec3

newCamera : (origin : Point3) ->
            (lookAt : Point3) ->
            (vUp : Vec3) ->
            (fvof : Double) ->
            (aspectRatio : Double) ->
            Camera
newCamera origin lookAt vUp fvof aspectRatio =
  let
    theta : Double = degToRad fvof
    h : Double = tan (theta/2.0)
    viewportHeight : Double = 2.0 * h
    viewportWidth : Double = aspectRatio * viewportHeight

    w : Vec3 = unitVector (origin - lookAt)
    u : Vec3 = unitVector (cross vUp w)
    v : Vec3 = cross w u

    horizontal : Vec3 = viewportWidth <# u
    vertical : Vec3 = viewportHeight <# v
    lowerLeftCorner : Vec3 =
      origin - (0.5 <# horizontal) - (0.5 <# vertical) - w
  in
    MkCamera origin lowerLeftCorner horizontal vertical

getRay : Camera -> (u : Double) -> (v : Double) -> Ray
getRay (MkCamera origin lowerLeftCorner horizontal vertical) u v =
  let
    uh : Vec3 = u <# horizontal
    vv : Vec3 = v <# vertical
  in
    MkRay origin (lowerLeftCorner + uh + vv - origin)
