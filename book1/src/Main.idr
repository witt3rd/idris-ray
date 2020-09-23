module Main

import Debug.Trace

import PPM

render : (h : Nat) -> (w : Nat) -> IO (Matrix h w RGB)
render h w = sweepV h
  where
    sweepH : (i : Nat) -> (j : Nat) -> Vect i RGB
    sweepH Z _ = Nil
    sweepH (S i) j =
      let
        i' : Nat = minus w (plus i 1)
        r : Double = (cast i') / (cast (minus w 1))
        g : Double = (cast j) / (cast (minus h 1))
        b : Double = 0.25
      in
        (toRGB [r, g, b]) :: sweepH i j

    sweepV : (j : Nat) -> IO (Matrix j w RGB)
    sweepV Z = pure (Nil)
    sweepV (S j) = do
      trace ("Scanlines remaining: " ++ (show (j + 1))) $ pure ()
      rows <- sweepV j
      pure ((sweepH w j) :: rows)

main : IO ()
main = do
  putStrLn "Rendering..."
  image <- render 255 255
  savePPM "test.ppm" image
  putStrLn "Done!"
