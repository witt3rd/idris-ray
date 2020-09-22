module Util

%access public export

infinity : Double
infinity = 2e+308

degToRad : (deg : Double) -> Double
degToRad deg = deg * pi / 180.0
