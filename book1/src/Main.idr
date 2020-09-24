module Main

import Debug.Trace

{- Image -}

imageWidth : Nat
imageWidth = 256

imageHeight : Nat
imageHeight = 256

{- Render -}

main : IO ()
main =
  do
    _ <- fPutStr stdout $ "P3\n" ++ (show imageWidth) ++ " " ++ (show imageHeight) ++ "\n255\n"
    _ <- renderRows imageHeight
    pure ()

  where

    renderCells : (i : Nat) -> (j : Nat) -> IO (Either FileError ())
    renderCells Z _ = pure (Right ())
    renderCells (S i) j = do
      let i' : Nat = minus imageWidth (i + 1)
      let r : Double = (cast i') / (cast (minus imageWidth 1))
      let g : Double = (cast j) / (cast (minus imageHeight 1))
      let b : Double = 0.25

      let ir : Int = cast (255.99 * r)
      let ig : Int = cast (255.99 * g)
      let ib : Int = cast (255.99 * b)

      _ <- fPutStrLn stdout $ (show ir) ++ " " ++ (show ig) ++ " " ++ (show ib)

      renderCells i j

    renderRows : (j : Nat) -> IO (Either FileError ())
    renderRows Z = pure (Right ())
    renderRows (S j) = do
      _ <- trace ("Scanlines remaining: " ++ (show (j + 1))) $ pure ()
      _ <- renderCells imageWidth j
      renderRows j
