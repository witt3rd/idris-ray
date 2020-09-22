module PPM

import Data.Buffer

import Printf
import public Color

%access public export

bytesPerPixel : Int
bytesPerPixel = 3

savePPM : (filename : String) -> (image : Matrix n m RGB) -> IO (Either String ())
savePPM {n = height} {m = width} filename image =
  do
    let header : String = mkHeader height width
    let headerSize : Int = cast (length header)
    let size : Int = headerSize + ((cast (height * width)) * bytesPerPixel)
    Just buf <- newBuffer size | Nothing => pure (Left "Unable to allocate buffer")
    setString buf 0 header
    Right file <- openFile filename WriteTruncate | Left err => pure (Left (show err))
    saveRows buf headerSize image
    writeBufferToFile file buf size
    closeFile file
    pure (Right ())
  where
    mkHeader : (h : Nat) -> (w : Nat) -> String
    mkHeader h w = printf "P6\n%d %d\n255\n" (cast w) (cast h)

    saveBytes : Buffer -> Int -> Vect n Bits8 -> IO ()
    saveBytes _ _ [] = pure ()
    saveBytes buf loc (b :: bs) =
      do
        setByte buf loc b
        saveBytes buf (loc + 1) bs

    saveRow : Buffer -> Int -> Vect n RGB -> IO ()
    saveRow _ _ [] = pure ()
    saveRow buf loc (c :: xs) =
      do
        saveBytes buf loc c
        saveRow buf (loc + bytesPerPixel) xs

    saveRows : Buffer -> Int -> Matrix n m RGB -> IO ()
    saveRows _ _ [] = pure ()
    saveRows buf loc (row :: rows) =
      do
        saveRow buf loc row
        saveRows buf (loc + bytesPerPixel * (toIntNat width)) rows
