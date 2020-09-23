module Main

import Debug.Trace

import Camera
import Hit
import PPM
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
camera : Camera
camera = newCamera [-2, 2, 1] [0, 0, -1] [0, 1, 0] 20 aspectRatio

samplesPerPixel : Nat
samplesPerPixel = 100

maxDepth : Nat
maxDepth = 50

{- World -}
materialGround : Lambertian
materialGround = MkLambertian [0.8, 0.8, 0.0]

materialCenter : Lambertian
materialCenter = MkLambertian [0.1, 0.2, 0.5]

materialLeft : Dielectric
materialLeft = MkDielectric 1.5

materialRight : Metal
materialRight = newMetal [0.8, 0.6, 0.2] 0

world : List Sphere
world = [
    MkSphere [0, -100.5, -1] 100 materialGround
  , MkSphere [0, 0, -1] 0.5 materialCenter
  , MkSphere [-1, 0, -1] (-0.4) materialLeft
  , MkSphere [1, 0, -1] 0.5 materialRight
  ]

{- Helpers -}
rayColor : Hittable a => Ray -> List a -> (depth : Nat) -> Eff Color [RND]
rayColor _ _ Z = pure [0, 0, 0] -- ray bounce limit, no more light is gathered
rayColor ray@(MkRay origin dir) world (S depth) =
  case closestHit ray 0 infinity world of
    Just (MkHit hitPoint material) =>
      case !(scatter ray hitPoint material) of
        Just (MkScattering attenuation scattered) =>
          pure $ attenuation * !(rayColor scattered world depth)
        Nothing => pure $ [0, 0, 0]
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
