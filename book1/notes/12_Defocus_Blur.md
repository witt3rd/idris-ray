# 12. Defocus Blur

## 12.1 A Thin Lens Approximation

## 12.2 Generating Sample Rays

### Listing 66: Generate random point inside unit disk

```cpp
vec3 random_in_unit_disk() {
    while (true) {
        auto p = vec3(random_double(-1,1), random_double(-1,1), 0);
        if (p.length_squared() >= 1) continue;
        return p;
    }
}
```

In `Vec3.idr`:

```idris
randomInUnitDiskR : Eff Vec3 [RND]
randomInUnitDiskR =
  let
    p : Vec3 = [!(randomDouble (-1) 1), !(randomDouble (-1) 1), 0]
    l : Double = lenSq p
  in
    if p >= 1 then randomInUnitDiskR else pure p
```

### Listing 67: Camera with adjustable depth-of-field (dof)

```cpp
class camera {
    public:
        camera(
            point3 lookfrom,
            point3 lookat,
            vec3   vup,
            double vfov, // vertical field-of-view in degrees
            double aspect_ratio,
            double aperture,
            double focus_dist
        ) {
            auto theta = degrees_to_radians(vfov);
            auto h = tan(theta/2);
            auto viewport_height = 2.0 * h;
            auto viewport_width = aspect_ratio * viewport_height;

            w = unit_vector(lookfrom - lookat);
            u = unit_vector(cross(vup, w));
            v = cross(w, u);

            origin = lookfrom;
            horizontal = focus_dist * viewport_width * u;
            vertical = focus_dist * viewport_height * v;
            lower_left_corner = origin - horizontal/2 - vertical/2 - focus_dist*w;

            lens_radius = aperture / 2;
        }


        ray get_ray(double s, double t) const {
            vec3 rd = lens_radius * random_in_unit_disk();
            vec3 offset = u * rd.x() + v * rd.y();

            return ray(
                origin + offset,
                lower_left_corner + s*horizontal + t*vertical - origin - offset
            );
        }

    private:
        point3 origin;
        point3 lower_left_corner;
        vec3 horizontal;
        vec3 vertical;
        vec3 u, v, w;
        double lens_radius;
};
```

In `Camera.idr`:

```idris
record Camera where
  constructor MkCamera
  origin : Point3
  lowerLeftCorner : Vec3
  horizontal : Vec3
  vertical : Vec3
  u, v, w : Vec3
  lensRadius : Double

newCamera : (origin : Point3) ->
            (lookAt : Point3) ->
            (vUp : Vec3) ->
            (vfov : Double) ->
            (aspectRatio : Double) ->
            (aperture : Double) ->
            (focusDist : Double) ->
            Camera
newCamera origin lookAt vUp vfov aspectRatio aperture focusDist =
  let
    theta : Double = degToRad vfov
    h : Double = tan (theta/2.0)
    viewportHeight : Double = 2.0 * h
    viewportWidth : Double = aspectRatio * viewportHeight

    w : Vec3 = unitVector (origin - lookAt)
    u : Vec3 = unitVector (cross vUp w)
    v : Vec3 = cross w u

    horizontal : Vec3 = focusDist <# (viewportWidth <# u)
    vertical : Vec3 = focusDist <# (viewportHeight <# v)
    lowerLeftCorner : Vec3 =
      origin - (0.5 <# horizontal) - (0.5 <# vertical) - (focusDist <# w)
    lensRadius : Double = aperture / 2.0
  in
    MkCamera origin lowerLeftCorner horizontal vertical u v w lensRadius

getRay : Camera -> (s : Double) -> (t : Double) -> Eff Ray [RND]
getRay (MkCamera origin lowerLeftCorner horizontal vertical u v w lensRadius) s t =
  let
    rd : Vec3 = lensRadius <# !randomInUnitDiskR
    offset : Vec3 = ((getX rd) <# u) + ((getY rd) <# v)
  in
    pure $ MkRay (origin + offset) (lowerLeftCorner + (s <# horizontal) + (t <# vertical) - origin - offset)
```

### Listing 68: Scene camera with depth-of-field

```cpp
point3 lookfrom(3,3,2);
point3 lookat(0,0,-1);
vec3 vup(0,1,0);
auto dist_to_focus = (lookfrom-lookat).length();
auto aperture = 2.0;

camera cam(lookfrom, lookat, vup, 20, aspect_ratio, aperture, dist_to_focus);
```

In `Main.idr`:

```idris
{- Camera -}
lookFrom : Point3
lookFrom = [3, 3, 2]

lookAt : Point3
lookAt = [0, 0, -1]

vUp : Vec3
vUp = [0, 1, 0]

distFocus : Double
distFocus = len (lookFrom - lookAt)

aperture : Double
aperture = 2.0

camera : Camera
camera = newCamera lookFrom lookAt vUp 20 aspectRatio aperture distFocus
```

We also need to update the call to `getRay`, since it now uses a random function:

```idris
        ray : Ray = !(getRay camera u v)
```

#### Image 20: Spheres with depth-of-field

![Spheres with depth-of-field](images/Image_20.png)
