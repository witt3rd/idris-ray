module Render

import Debug.Trace

import public Image

%default total
%access public export

render : (w : Nat) -> (h : Nat) -> Image w h RGBd
render w h = sweepV h
  where

    sweepH : (i : Nat) -> (j : Nat) -> Vect i RGBd
    sweepH Z _ = Nil
    sweepH (S i) j = do
      let i' : Nat = minus w (i + 1)

      let r : Double = (cast i') / (cast (minus w 1))
      let g : Double = (cast j) / (cast (minus h 1))
      let b : Double = 0.25

      [r, g, b] :: (sweepH i j)

    sweepV : (j : Nat) -> Image w j RGBd
    sweepV Z = Nil
    sweepV (S j) = do
      -- _ <- trace ("Scanlines remaining: " ++ (show (j + 1))) $ pure ()
      (sweepH w j) :: (sweepV j)
