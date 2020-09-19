module Main

import Data.Matrix
import Color
import PPM

main : IO ()
main = do
  putStrLn "generating image..."
  savePPM "test.ppm" $ mkTestImage 1080 1920
  putStrLn "image saved"
