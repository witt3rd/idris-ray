module Main

import PPM

render : (h : Nat) -> (w : Nat) -> IO (Matrix h w (Vect 3 Double))
render h w = mkRows h
  where
    mkCols : (i : Nat) -> (j : Nat) -> Vect i (Vect 3 Double)
    mkCols Z _ = Nil
    mkCols (S i) j =
      let
        i' : Nat = minus w (plus i 1)
        r : Double = (cast i') / (cast (minus w 1))
        g : Double = (cast j) / (cast (minus h 1))
        b : Double = 0.25
      in
        [r, g, b] :: mkCols i j

    mkRows : (j : Nat) -> IO (Matrix j w (Vect 3 Double))
    mkRows Z = pure (Nil)
    mkRows (S j) = do
      rows <- mkRows j
      pure ((mkCols w j) :: rows)

main : IO ()
main = do
  putStrLn "Rendring..."
  image <- render 255 255
  savePPM "test.ppm" image
  putStrLn "Done!"
