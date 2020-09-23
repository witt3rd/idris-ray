module Main

import Debug.Trace

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

maxDepth : Nat
maxDepth = 50

{- World -}
s1 : Sphere
s1 = MkSphere [0, 0, -1] 0.5

s2 : Sphere
s2 = MkSphere [0, -100.5, -1] 100

world : List Sphere
world = [s1, s2]

{- Helpers -}
rayColor : Hittable a => Ray -> List a -> (depth : Nat) -> Eff Color [RND]
rayColor _ _ Z = pure [0, 0, 0] -- ray bounce limit, no more light is gathered
rayColor ray@(MkRay origin dir) world (S depth) =
  case closestHit ray 0.001 infinity world of
    Just (MkHit point normal _ _) =>
      let
        target : Point3 = point + !(randomInHemisphere normal)
      in
        pure $ 0.5 <# !(rayColor (MkRay point (target - point)) world depth)
    Nothing =>
      let
        unitDir : Vec3 = unitVector dir
        t : Double = 0.5 * (getY unitDir) + 1
      in
        pure $ ((1.0 - t) <# [1, 1, 1]) + (t <# [0.5, 0.7, 1])

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
        color : Color = !(rayColor ray world maxDepth)
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
    sweepV (S j) = do
      trace ("Scanlines remaining: " ++ (show (j + 1))) $ pure ()
      pure $ !(sweepH w j) :: !(sweepV j)

main : IO ()
main = do
  putStrLn "Rendering..."
  let image = runPure $ render imageHeight imageWidth
  savePPM "test.ppm" image
  putStrLn "Done!"
