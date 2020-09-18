module PPM

import Data.Matrix

import Color
import Printf

export
savePPM : (filepath : String) -> (image : Matrix n m Color) -> IO (Either FileError ())
savePPM {n = (S height)} {m = width} filename image =
  do
    Right file <- openFile filename WriteTruncate
    fPutStrLn file "P3"
    fPutStrLn file $ printf "%d %d" (cast width) ((cast height) - 1)
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

    saveRows : File -> (image : Matrix n m Color) -> IO (Either FileError ())
    saveRows file [] = pure $ Right ()
    saveRows file (row :: rows) =
      do
        saveRow file row
        saveRows file rows
