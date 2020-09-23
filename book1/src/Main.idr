module Main

import Debug.Trace

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
rayColor : (r : Ray) -> Color
rayColor (MkRay origin dir) =
  do
    let unitDir : Vec3 = unitVector dir
    let t : Double = 0.5 * (getY unitDir) + 1
    ((1.0 - t) <# [1, 1, 1]) + (t <# [0.5, 0.7, 1])

{- Render loop -}
render : (h : Nat) -> (w : Nat) -> IO (Matrix h w RGB)
render h w = sweepV h
  where
    sweepH : (i : Nat) -> (j : Nat) -> Vect i RGB
    sweepH Z _ = Nil
    sweepH (S i) j =
      let
        i' : Nat = minus w (plus i 1)
        u : Double = (cast i') / (cast (minus w 1))
        v : Double = (cast j) / (cast (minus h 1))
        uh : Vec3 = u <# horizontal
        vv : Vec3 = v <# vertical
        r : Ray = MkRay origin (lowerLeftCorner + uh + vv - origin)
        c : Color = rayColor r
      in
        (toRGB c) :: sweepH i j

    sweepV : (j : Nat) -> IO (Matrix j w RGB)
    sweepV Z = pure (Nil)
    sweepV (S j) = do
      trace ("Scanlines remaining: " ++ (show (j + 1))) $ pure ()
      rows <- sweepV j
      pure ((sweepH w j) :: rows)

main : IO ()
main = do
  putStrLn "Rendering..."
  image <- render imageHeight imageWidth
  savePPM "test.ppm" image
  putStrLn "Done!"
