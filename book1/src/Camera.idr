module Camera

import public Ray

%access public export

record Camera where
  constructor MkCamera
  origin : Point3
  lowerLeftCorner : Vec3
  horizontal : Vec3
  vertical : Vec3

newCamera : (fvof : Double) -> (aspectRatio : Double) -> (origin : Vec3) -> Camera
newCamera fvof aspectRatio origin =
  let
    theta : Double = degToRad fvof
    h : Double = tan (theta/2.0)
    viewportHeight : Double = 2.0 * h
    viewportWidth : Double = aspectRatio * viewportHeight
    focalLength : Double = 1.0;
    horizontal : Vec3 = [viewportWidth, 0, 0]
    vertical : Vec3 = [0, viewportHeight, 0];
    lowerLeftCorner : Vec3 =
      origin - (0.5 <# horizontal) - (0.5 <# vertical) - [0, 0, focalLength]
  in
    MkCamera origin lowerLeftCorner horizontal vertical

getRay : Camera -> (u : Double) -> (v : Double) -> Ray
getRay (MkCamera origin lowerLeftCorner horizontal vertical) u v =
  let
    uh : Vec3 = u <# horizontal
    vv : Vec3 = v <# vertical
  in
    MkRay origin (lowerLeftCorner + uh + vv - origin)
