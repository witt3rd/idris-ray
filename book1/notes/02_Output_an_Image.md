# Output an Image

NOTE: The source code for this chapter can be found on branch `book1_ch02`.

Before we begin, we should create an Idris package file to contain our project information and make it possible to build the project.  Create a new file in the root of your project directory called `ray.ipkg` and add the following:

```
package ray

pkgs = contrib

sourcedir = src

main = Main

executable = ray
```

Now, from this root directory on the command line, you will be able to clean and build your project using the `idris` executable:

```bash
idris --clean ray.ipkg
idris --build ray.ipkg
```

## 2.1 The PPM Image Format

### Listing 1: Creating your first image

```cpp
#include <iostream>

int main() {

    // Image

    const int image_width = 256;
    const int image_height = 256;

    // Render

    std::cout << "P3\n" << image_width << ' ' << image_height << "\n255\n";

    for (int j = image_height-1; j >= 0; --j) {
        for (int i = 0; i < image_width; ++i) {
            auto r = double(i) / (image_width-1);
            auto g = double(j) / (image_height-1);
            auto b = 0.25;

            int ir = static_cast<int>(255.999 * r);
            int ig = static_cast<int>(255.999 * g);
            int ib = static_cast<int>(255.999 * b);

            std::cout << ir << ' ' << ig << ' ' << ib << '\n';
        }
    }
}
```

Let's factor things a bit differently by separating concerns: **generating an image** and **saving an image**.

We'll use a `printf` helper from the [_Type-Driven Development with Idris_](https://www.manning.com/books/type-driven-development-with-idris) by Edwin Brady:

```idris
module Printf

%access public export

data Format = Number Format
            | Dbl Format
            | Str Format
            | Chr Format
            | Lit String Format
            | End

PrintfType : Format -> Type
PrintfType (Number fmt) = (i : Int) -> PrintfType fmt
PrintfType (Dbl fmt) = (d : Double) -> PrintfType fmt
PrintfType (Str fmt) = (str : String) -> PrintfType fmt
PrintfType (Chr fmt) = (c : Char) -> PrintfType fmt
PrintfType (Lit str fmt) = PrintfType fmt
PrintfType End = String

printfFmt : (fmt : Format) -> (acc : String) -> PrintfType fmt
printfFmt (Number fmt) acc = \i => printfFmt fmt (acc ++ show i)
printfFmt (Dbl fmt) acc = \d => printfFmt fmt (acc ++ show d)
printfFmt (Str fmt) acc = \str => printfFmt fmt (acc ++ str)
printfFmt (Chr fmt) acc = \c => printfFmt fmt (acc ++ (cast c))
printfFmt (Lit lit fmt) acc = printfFmt fmt (acc ++ lit)
printfFmt End acc = acc

toFormat : (cxs : List Char) -> Format
toFormat [] = End
toFormat ('%' :: 'd' :: chars) = Number (toFormat chars)
toFormat ('%' :: 'f' :: chars) = Dbl (toFormat chars)
toFormat ('%' :: 's' :: chars) = Str (toFormat chars)
toFormat ('%' :: 'c' :: chars) = Chr (toFormat chars)
toFormat ('%' :: chars) = Lit "%" (toFormat chars)
toFormat (c :: chars) = case toFormat chars of
                             Lit lit chars' => Lit (strCons c lit) chars'
                             fmt => Lit (strCons c "") fmt

printf : (fmt : String) -> PrintfType (toFormat $ unpack fmt)
printf fmt = printfFmt _ ""
```

To save the image, create a new file, `PPM.idr`, and let's write the image output directly to a file (instead of relying on `stdout`):

```idris
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
```

Note that this function accepts a `Matrix` of `Vect 3 Double`.

`Matrix` comes from the `contrib` library.  You can check that it is available to Idris with the command `idris --listlibs`.  Be sure to start your REPL with `idris -p contrib`.

## 2.2 Creating an Image File

To keep things cleanly separated, we've left the `savePPM` alone so that it does only what it advertises: save PPM files.  Thus, to create a sample image, we've added a `render` function `Main.idr` that recreates the image from the book:

```idris
module Main

import PPM

render : (h : Nat) -> (w : Nat) -> IO (Matrix h w (Vect 3 Double))
render h w = sweepV h
  where
    sweepH : (i : Nat) -> (j : Nat) -> Vect i (Vect 3 Double)
    sweepH Z _ = Nil
    sweepH (S i) j =
      let
        i' : Nat = minus w (plus i 1)
        r : Double = (cast i') / (cast (minus w 1))
        g : Double = (cast j) / (cast (minus h 1))
        b : Double = 0.25
      in
        [r, g, b] :: sweepH i j

    sweepV : (j : Nat) -> IO (Matrix j w (Vect 3 Double))
    sweepV Z = pure (Nil)
    sweepV (S j) = do
      rows <- sweepV j
      pure ((sweepH w j) :: rows)

    main : IO ()
    main = do
      putStrLn "Rendering..."
      image <- render 255 255
      savePPM "test.ppm" image
      putStrLn "Done!"
```

To generate an image, from the `book1/src` directory, launch the Idris REPL:

```bash
idris -p contrib Main.idr
```

and issue the `:exec` command.

Alternatively, from the `book1` directory:

```bash
idris --build ray.ipkg
./ray
```

#### Image 1: Our First Image

![Our First Image](images/Image_01.png)

## 2.3 Adding a Progress Indicator

### Listing 3: Main render loop with progress reporting
```cpp
    for (int j = image_height-1; j >= 0; --j) {
        std::cerr << "\rScanlines remaining: " << j << ' ' << std::flush;
        for (int i = 0; i < image_width; ++i) {
            auto r = double(i) / (image_width-1);
            auto g = double(j) / (image_height-1);
            auto b = 0.25;

            int ir = static_cast<int>(255.999 * r);
            int ig = static_cast<int>(255.999 * g);
            int ib = static_cast<int>(255.999 * b);

            std::cout << ir << ' ' << ig << ' ' << ib << '\n';
        }
    }

    std::cerr << "\nDone.\n";
```
