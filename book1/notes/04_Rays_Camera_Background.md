# 4. Rays, a Simple Camera, and Background

## 4.1 The `ray` Class

### Listing 8: The `ray` class

```cpp
#ifndef RAY_H
#define RAY_H

#include "vec3.h"

class ray {
    public:
        ray() {}
        ray(const point3& origin, const vec3& direction)
            : orig(origin), dir(direction)
        {}

        point3 origin() const  { return orig; }
        vec3 direction() const { return dir; }

        point3 at(double t) const {
            return orig + t*dir;
        }

    public:
        point3 orig;
        vec3 dir;
};

#endif
```

Create a new file, `Ray.idr`, with the following definition:

```idris
module Ray

import public Vec3

%access public export

record Ray where
  constructor MkRay
  origin : Point3
  dir : Vec3

%name Ray ray, ray1, ray2

rayAt : (ray : Ray) -> (t : Double) -> Point3
rayAt (MkRay origin dir) t = origin + (t <# dir)
```

## 4.2 Sending Rays Into the Scene

### Listing 9: Rendering a blue-to-white gradient

```cpp
#include "color.h"
+ #include "ray.h"
#include "vec3.h"

#include <iostream>

+ color ray_color(const ray& r) {
+     vec3 unit_direction = unit_vector(r.direction());
+     auto t = 0.5*(unit_direction.y() + 1.0);
+     return (1.0-t)*color(1.0, 1.0, 1.0) + t*color(0.5, 0.7, 1.0);
+ }

int main() {

    // Image
+     const auto aspect_ratio = 16.0 / 9.0;
+     const int image_width = 400;
+     const int image_height = static_cast<int>(image_width / aspect_ratio);
+
+     // Camera
+
+     auto viewport_height = 2.0;
+     auto viewport_width = aspect_ratio * viewport_height;
+     auto focal_length = 1.0;
+
+     auto origin = point3(0, 0, 0);
+     auto horizontal = vec3(viewport_width, 0, 0);
+     auto vertical = vec3(0, viewport_height, 0);
+     auto lower_left_corner = origin - horizontal/2 - vertical/2 - vec3(0, 0, focal_length);

    // Render

    std::cout << "P3\n" << image_width << " " << image_height << "\n255\n";

    for (int j = image_height-1; j >= 0; --j) {
        std::cerr << "\rScanlines remaining: " << j << ' ' << std::flush;
        for (int i = 0; i < image_width; ++i) {
+             auto u = double(i) / (image_width-1);
+             auto v = double(j) / (image_height-1);
+             ray r(origin, lower_left_corner + u*horizontal + v*vertical - origin);
+             color pixel_color = ray_color(r);
            write_color(std::cout, pixel_color);
        }
    }

    std::cerr << "\nDone.\n";
}
```

Let's start by importing `Ray`, adding the constants (and derived constants), and the new `rayColor` function to the top of `Main.idr`:

```idris
{- Image -}
aspectRatio : Double
aspectRatio = 16.0 / 9.0

imageWidth : Nat
imageWidth = 400

imageHeight : Nat
imageHeight =
  let
    dw : Double = cast imageWidth
    dh : Double = dw / aspectRatio
    ih : Int = cast dh
  in
    cast ih

{- Camera -}
viewportHeight : Double
viewportHeight = 2.0

viewportWidth : Double
viewportWidth = aspectRatio * viewportHeight

focalLength : Double
focalLength = 1.0;

origin : Point3
origin = [0, 0, 0]

horizontal : Vec3
horizontal = [viewportWidth, 0, 0]

vertical : Vec3
vertical = [0, viewportHeight, 0];

lowerLeftCorner : Vec3
lowerLeftCorner = origin - (0.5 <# horizontal) - (0.5 <# vertical) - [0, 0, focalLength]

{- Helpers -}
rayColor : (r : Ray) -> Color
rayColor (MkRay origin dir) =
  do
    let unitDir : Vec3 = unitVector dir
    let t : Double = 0.5 * (getY unitDir) + 1
    ((1.0 - t) <# [1, 1, 1]) + (t <# [0.5, 0.7, 1])
```

Instead of iterating across columns and rows to produce our color values, instead we will iterate across the `(u,v)` space:

```idris
let
  i' : Nat = minus w (plus i 1)
  u : Double = (cast i') / (cast (minus w 1))
  v : Double = (cast j) / (cast (minus h 1))
  uh : Vec3 = u <# horizontal
  vv : Vec3 = v <# vertical
  r : Ray = MkRay origin (lowerLeftCorner + uh + vv - origin)
  c : Color = rayColor r
in
  (toRGB c) :: mkCols i j
```

Lastly, let's update our `main` function to use the constants we defined at the top of the module:

```idris
main : IO ()
main = do
  putStrLn "Rendring..."
  image <- render imageHeight imageWidth
  savePPM "test.ppm" image
  putStrLn "Done!"
```
#### Image 2: A blue-to-white gradient depending on ray Y coordinate

![A blue-to-white gradient depending on ray Y coordinate](images/Image_02.png)
