module PPM

import public Data.Matrix
import public Data.Vect

import Printf

%access public export

savePPM : (filepath : String) -> (image : Matrix n m (Vect 3 Double)) -> IO (Either FileError ())
savePPM {n = height} {m = width} filename image =
  do
    Right file <- openFile filename WriteTruncate
    fPutStrLn file "P3"
    fPutStrLn file $ printf "%d %d" (cast width) (cast height)
    fPutStrLn file "255"
    saveRows file image
  where
    saveRow : File -> (row : Vect n (Vect 3 Double)) -> IO (Either FileError ())
    saveRow _ [] = pure $ Right ()
    saveRow file (color :: xs) =
      do
        let ir : Int = cast (255.99 * (index 0 color))
        let ig : Int = cast (255.99 * (index 1 color))
        let ib : Int = cast (255.99 * (index 2 color))
        fPutStrLn file $ printf "%d %d %d" ir ig ib
        saveRow file xs

    saveRows : File -> (image : Matrix n m (Vect 3 Double)) -> IO (Either FileError ())
    saveRows file [] = pure $ Right ()
    saveRows file (row :: rows) =
      do
        saveRow file row
        saveRows file rows
