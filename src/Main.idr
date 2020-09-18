module Main

import Data.Matrix
import Color
import PPM

r : Color
r = RGB 1.0 0 0

g : Color
g = RGB 0 1.0 0

b : Color
b = RGB 0 0 1.0

image :  Matrix 3 3 Color
image = [[r,g,b],[g,b,r],[b,r,g]]

main : IO ()
main = do
  savePPM "test.ppm" image
  putStrLn "Hello, world!"
