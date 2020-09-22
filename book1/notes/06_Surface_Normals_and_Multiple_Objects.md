# 6 Surface Normals and Multiple Objects

## 6.1 Shading with Surface Normals

### Listing 11: Rendering surface normals on a sphere

```cpp
+ double hit_sphere(const point3& center, double radius, const ray& r) {
    vec3 oc = r.origin() - center;
    auto a = dot(r.direction(), r.direction());
    auto b = 2.0 * dot(oc, r.direction());
    auto c = dot(oc, oc) - radius*radius;
    auto discriminant = b*b - 4*a*c;
+    if (discriminant < 0) {
+        return -1.0;
+    } else {
+        return (-b - sqrt(discriminant) ) / (2.0*a);
+    }
}

color ray_color(const ray& r) {
+    auto t = hit_sphere(point3(0,0,-1), 0.5, r);
+    if (t > 0.0) {
+        vec3 N = unit_vector(r.at(t) - vec3(0,0,-1));
+        return 0.5*color(N.x()+1, N.y()+1, N.z()+1);
+    }
    vec3 unit_direction = unit_vector(r.direction());
+    t = 0.5*(unit_direction.y() + 1.0);
    return (1.0-t)*color(1.0, 1.0, 1.0) + t*color(0.5, 0.7, 1.0);
}
```

We make a similar set of changes in `Main.idr`:

```idris
hitSphere : (center: Point3) -> (radius : Double) -> Ray -> Double
hitSphere center radius (MkRay origin dir) =
  let
    oc : Vec3 = origin - center
    a : Double = dot dir dir
    b : Double = 2.0 * dot oc dir
    c : Double = (dot oc oc) - (radius * radius)
    discriminant : Double = (b * b) - (4 * a * c)
  in
    if discriminant < 0 then
      -1
    else
      ((0 - b) - (sqrt discriminant)) / (2*a)

rayColor : Ray -> Color
rayColor r@(MkRay origin dir) =
  let t : Double = hitSphere [0,0,-1] 0.5 r in
  if t > 0 then
    let N : Vec3 = unitVector ((rayAt r t) - [0, 0, -1]) in
    0.5 <# [(getX N) + 1, (getY N) + 1, (getZ N) + 1]
  else
    let
      unitDir : Vec3 = unitVector dir
      t : Double = 0.5 * (getY unitDir) + 1
    in
      ((1.0 - t) <# [1, 1, 1]) + (t <# [0.5, 0.7, 1])
```

#### Image 4: A sphere colored according to its normal vectors

![A sphere colored according to its normal vectors](images/Image_04.png)

## Final Render

Our scene with multiple objects rendered with their surface normals:

![Multiple Objects](images/06_Final.png)
