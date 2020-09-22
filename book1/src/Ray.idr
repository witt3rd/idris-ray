module Ray

import public Vec3

%access public export

record Ray where
  constructor MkRay
  origin : Point3
  dir : Vec3

%name Ray ray, ray1, ray2

rayAt : (ray : Ray) -> (t : Double) -> Point3
rayAt (MkRay origin dir) t = origin + (t <# dir)
