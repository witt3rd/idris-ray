module Main

import Data.Matrix

import Color
import PPM
import Printf

export
render : (h : Nat) -> (w : Nat) -> IO (Matrix h w Color)
render h w = mkRows h
  where
    mkCols : (i : Nat) -> (j : Nat) -> Vect i Color
    mkCols Z _ = Nil
    mkCols (S i) j =
      let
        i' : Nat = minus w (plus i 1)
        r : Double = (cast i') / (cast (minus w 1))
        g : Double = (cast j) / (cast (minus h 1))
        b : Double = 0.25
      in
        (RGB r g b) :: mkCols i j

    mkRows : (j : Nat) -> IO (Matrix j w Color)
    mkRows Z = pure (Nil)
    mkRows (S j) = do
      putStrLn $ printf "Scanlines remaining: %d" (cast j)
      rows <- mkRows j
      pure ((mkCols w j) :: rows)

main : IO ()
main = do
  putStrLn "generating image..."
  image <- render 255 255
  savePPM "test.ppm" image
  putStrLn "image saved"
