module Main

import PPM
import Ray

{- Image -}
aspectRatio : Double
aspectRatio = 16.0 / 9.0

imageWidth : Nat
imageWidth = 400

imageHeight : Nat
imageHeight =
  let
    dw : Double = cast imageWidth
    dh : Double = dw / aspectRatio
    ih : Int = cast dh
  in
    cast ih

{- Camera -}
viewportHeight : Double
viewportHeight = 2.0

viewportWidth : Double
viewportWidth = aspectRatio * viewportHeight

focalLength : Double
focalLength = 1.0;

origin : Point3
origin = [0, 0, 0]

horizontal : Vec3
horizontal = [viewportWidth, 0, 0]

vertical : Vec3
vertical = [0, viewportHeight, 0];

lowerLeftCorner : Vec3
lowerLeftCorner = origin - (0.5 <# horizontal) - (0.5 <# vertical) - [0, 0, focalLength]

{- Helpers -}
hitSphere : (center: Point3) -> (radius : Double) -> Ray -> Double
hitSphere center radius (MkRay origin dir) =
  let
    oc : Vec3 = origin - center
    a : Double = dot dir dir
    b : Double = 2.0 * dot oc dir
    c : Double = (dot oc oc) - (radius * radius)
    discriminant : Double = (b * b) - (4 * a * c)
  in
    if discriminant < 0 then
      -1
    else
      ((0 - b) - (sqrt discriminant)) / (2*a)

rayColor : Ray -> Color
rayColor r@(MkRay origin dir) =
  let t : Double = hitSphere [0,0,-1] 0.5 r in
  if t > 0 then
    let N : Vec3 = unitVector ((rayAt r t) - [0, 0, -1]) in
    0.5 <# [(getX N) + 1, (getY N) + 1, (getZ N) + 1]
  else
    let
      unitDir : Vec3 = unitVector dir
      t : Double = 0.5 * (getY unitDir) + 1
    in
      ((1.0 - t) <# [1, 1, 1]) + (t <# [0.5, 0.7, 1])

{- Render loop -}
render : (h : Nat) -> (w : Nat) -> IO (Matrix h w RGB)
render h w = mkRows h
  where
    mkCols : (i : Nat) -> (j : Nat) -> Vect i RGB
    mkCols Z _ = Nil
    mkCols (S i) j =
      let
        i' : Nat = minus w (plus i 1)
        u : Double = (cast i') / (cast (minus w 1))
        v : Double = (cast j) / (cast (minus h 1))
        uh : Vec3 = u <# horizontal
        vv : Vec3 = v <# vertical
        r : Ray = MkRay origin (lowerLeftCorner + uh + vv - origin)
        c : Color = rayColor r
      in
        (toRGB c) :: mkCols i j

    mkRows : (j : Nat) -> IO (Matrix j w RGB)
    mkRows Z = pure (Nil)
    mkRows (S j) = do
      rows <- mkRows j
      pure ((mkCols w j) :: rows)

main : IO ()
main = do
  putStrLn "Rendring..."
  image <- render imageHeight imageWidth
  savePPM "test.ppm" image
  putStrLn "Done!"
