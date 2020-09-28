module Main

import PPM
import Renderer
import Vec3

{- Image -}
filename : String
filename = "test.ppm"

imageWidth : Nat
imageWidth = 256

imageHeight : Nat
imageHeight = 256

{- Render -}

main : IO ()
main = do
  let rendering = render imageWidth imageHeight
  let image = cast {to=(RGB8Image imageWidth imageHeight)} rendering
  Right _ <- savePPM filename image
    | Left err => putStrLn ("Failed to save PPM: " ++ err)
  pure ()
