module PPM

import Data.Matrix

import Color
import Printf

export
savePPM : (filepath : String) -> (image : Matrix n m Color) -> IO (Either FileError ())
savePPM {n = height} {m = width} filename image =
  do
    Right file <- openFile filename WriteTruncate
    fPutStrLn file "P3"
    fPutStrLn file $ printf "%d %d" (cast width) (cast height)
    fPutStrLn file "255"
    saveRows file image
  where
    saveRow : File -> (row : Vect n Color) -> IO (Either FileError ())
    saveRow _ [] = pure $ Right ()
    saveRow file ((RGB r g b) :: xs) =
      do
        let ir : Int = cast (255.99 * r)
        let ig : Int = cast (255.99 * g)
        let ib : Int = cast (255.99 * b)
        fPutStrLn file $ printf "%d %d %d" ir ig ib
        saveRow file xs

    saveRows : File -> (image : Matrix n m Color) -> IO (Either FileError ())
    saveRows file [] = pure $ Right ()
    saveRows file (row :: rows) =
      do
        saveRow file row
        saveRows file rows

export
mkTestImage : (h : Nat) -> (w : Nat) -> Matrix h w Color
mkTestImage h w = mkRows h
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

    mkRows : (j : Nat) -> Matrix j w Color
    mkRows Z = Nil
    mkRows (S j) = (mkCols w j) :: mkRows j
