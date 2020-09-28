module PPM

import Data.Buffer

import public Image

%access public export
%default total

||| We only support RGB8 images (3 channels, 1 byte per channel)
bytesPerPixel : Int
bytesPerPixel = 3

||| Save a an RGB8 image to a PPM file (binary) by filling an in-memory
||| buffer, then flushing it to disk
savePPM : (filename : String) -> RGB8Image w h -> IO (Either String ())
savePPM {w = width} {h = height} filename image =
  do
    -- calculate the size of the buffer to allocate
    let header : String = mkHeader height width
    let headerSize : Int = cast (length header)
    let size : Int = headerSize + ((cast (height * width)) * bytesPerPixel)

    -- allocate the buffer and write the header (ASCII) to the buffer
    Just buf <- newBuffer size | Nothing => pure (Left "Unable to allocate buffer")
    setString buf 0 header

    -- write the image data to the buffer
    setRows buf headerSize image

    -- create the file and save the buffer
    Right file <- openFile filename WriteTruncate | Left err => pure (Left (show err))
    writeBufferToFile file buf size
    closeFile file

    pure (Right ())

  where

    mkHeader : (h : Nat) -> (w : Nat) -> String
    mkHeader h w = "P6\n" ++ (show w) ++ " " ++ (show h) ++ "\n255\n"

    setBytes : Buffer -> Int -> Vect n Bits8 -> IO ()
    setBytes _ _ [] = pure ()
    setBytes buf loc (b :: bs) =
      do
        setByte buf loc b
        setBytes buf (loc + 1) bs

    setRow : Buffer -> Int -> Vect w RGB8 -> IO ()
    setRow _ _ [] = pure ()
    setRow buf loc (c :: xs) =
      do
        setBytes buf loc c
        setRow buf (loc + bytesPerPixel) xs

    setRows : Buffer -> Int -> RGB8Image w h -> IO ()
    setRows _ _ [] = pure ()
    setRows buf loc (row :: rows) =
      do
        setRow buf loc row
        setRows buf (loc + bytesPerPixel * (toIntNat width)) rows
