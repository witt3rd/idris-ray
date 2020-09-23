module Main

import Camera
import PPM
import Ray
import Sphere
import Util

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
origin : Point3
origin = [0, 0, 0]

camera : Camera
camera = newCamera aspectRatio origin

samplesPerPixel : Nat
samplesPerPixel = 100

{- World -}
s1 : Sphere
s1 = MkSphere [0, 0, -1] 0.5

s2 : Sphere
s2 = MkSphere [0, -100.5, -1] 100

world : List Sphere
world = [s1, s2]

{- Helpers -}
rayColor : Hittable a => Ray -> List a -> Color
rayColor ray@(MkRay origin dir) world =
  case closestHit ray 0 infinity world of
    Just (MkHit _ normal _ _) => 0.5 <# (normal + [1, 1, 1])
    Nothing =>
      let
        unitDir : Vec3 = unitVector dir
        t : Double = 0.5 * (getY unitDir) + 1
      in
        ((1.0 - t) <# [1, 1, 1]) + (t <# [0.5, 0.7, 1])

{- Render loop -}
render : (h : Nat) -> (w : Nat) -> Eff (Matrix h w RGB) [RND]
render h w = sweepV h
  where
    sample : (x : Double) -> (y : Double) -> (samples : Nat) -> Eff Color [RND]
    sample _ _ Z = pure [0, 0, 0]
    sample x y (S k) =
      let
        u : Double = (x + !randomUnitDouble) / (cast (minus w 1))
        v : Double = (y + !randomUnitDouble) / (cast (minus h 1))
        ray : Ray = getRay camera u v
        color : Color = rayColor ray world
      in
        pure $ color + !(sample x y k)

    sweepH : (i : Nat) -> (j : Nat) -> Eff (Vect i RGB) [RND]
    sweepH Z _ = pure Nil
    sweepH (S i) j =
      let
        i' : Nat = minus w (plus i 1)
        color : Color = !(sample (cast i') (cast j) samplesPerPixel)
      in
        pure $ (toRGB color samplesPerPixel) :: !(sweepH i j)

    sweepV : (j : Nat) -> Eff (Matrix j w RGB) [RND]
    sweepV Z = pure (Nil)
    sweepV (S j) = pure $ !(sweepH w j) :: !(sweepV j)

main : IO ()
main = do
  putStrLn "Rendering..."
  let image = runPure $ render imageHeight imageWidth
  savePPM "test.ppm" image
  putStrLn "Done!"
