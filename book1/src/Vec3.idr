module Vec3

import public Data.Matrix.Numeric
import public Data.Vect

%access public export
%default total

infixl 5 </ -- vector / scalar division

||| 3D vector of any numeric type
Vec3 : Type
Vec3 = Vect 3 Double

||| Type synonym for 3D point of any numeric type
Point3 : Type
Point3 = Vec3

{- Accessors -}

||| Finitely bound x index
xIdx : Fin 3
xIdx = restrict 2 0

||| Finitely bound y index
yIdx : Fin 3
yIdx = restrict 2 1

||| Finitely bound z index
zIdx : Fin 3
zIdx = restrict 2 2

||| Getter for x
getX : Vec3 -> Double
getX = index xIdx

||| Getter for y
getY : Vec3 -> Double
getY = index yIdx

||| Getter for z
getZ : Vec3 -> Double
getZ = index zIdx

{- Functions -}

||| Inner (dot) product with self
squareLength : Vec3 -> Double
squareLength v = v <:> v

||| Compute the length of the vector (Pythagoras)
magnitude : Vec3 -> Double
magnitude = sqrt . squareLength

||| Vector product (i.e., vector perpendicular to two other vectors)
cross : Vec3 -> Vec3 -> Vec3
cross u v =
  let
    u0 = getX u
    u1 = getY u
    u2 = getZ u
    v0 = getX v
    v1 = getY v
    v2 = getZ v
  in
    [(u1 * v2) - (u2 * v1)
    ,(u2 * v0) - (u0 * v2)
    ,(u0 * v1) - (u1 * v0)
    ]

||| Scalar division
(</) : Vec3 -> Double -> Vec3
(</) w r = map ((1/r) *) w

||| Scale a vector to unit length
unitize : Vec3 -> Vec3
unitize v = let l = magnitude v in if l == 0.0 then v else v </ l
