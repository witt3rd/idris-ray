# 10. Dielectrics

## 10.1 Refraction

### Listing 51: Refraction function

```cpp
vec3 refract(const vec3& uv, const vec3& n, double etai_over_etat) {
    auto cos_theta = dot(-uv, n);
    vec3 r_out_perp =  etai_over_etat * (uv + cos_theta*n);
    vec3 r_out_parallel = -sqrt(fabs(1.0 - r_out_perp.length_squared())) * n;
    return r_out_perp + r_out_parallel;
}
```

In `Vec3.idr`,

```idris
refract :(uv : Vec3) -> (n : Vec3) -> (etaIOverEtaT : Double) -> Vec3
refract uv  n etaIOverEtaT =
  let
    cosTheta : Double = dot (-uv) n
    perp : Vec3 = etaIOverEtaT <# (uv + (cosTheta <# n))
    parallel : Vec3 = (-(sqrt (abs (1 - (lenSq perp))))) <# n
  in
    perp + parallel
```

## Listing 52: Dielectric material class that always refracts

```cpp
class dielectric : public material {
    public:
        dielectric(double ri) : ref_idx(ri) {}

        virtual bool scatter(
            const ray& r_in, const hit_record& rec, color& attenuation, ray& scattered
        ) const override {
            attenuation = color(1.0, 1.0, 1.0);
            double etai_over_etat = rec.front_face ? (1.0 / ref_idx) : ref_idx;

            vec3 unit_direction = unit_vector(r_in.direction());
            vec3 refracted = refract(unit_direction, rec.normal, etai_over_etat);
            scattered = ray(rec.p, refracted);
            return true;
        }

        double ref_idx;
};
```

Add the following definition to `Material.idr`:

```idris
{- Dielectric -}
record Dielectric where
  constructor MkDielectric
  refIdx : Double

scatterDielectric : Ray -> HitPoint -> Dielectric -> Eff (Maybe Scattering) [RND]
scatterDielectric (MkRay origin dir) (MkHitPoint point normal frontFace _) (MkDielectric refIdx) =
  let
    attenuation : Color = [1, 1, 1]
    etaIOverEtaT : Double = if frontFace then (1 / refIdx) else refIdx
    unitDir : Vec3 = unitVector dir
    refracted : Vec3 = refract unitDir normal etaIOverEtaT
    scattered : Ray = MkRay point refracted
  in
    pure $ Just (MkScattering attenuation scattered)

Material Dielectric where
  scatter = scatterDielectric
```

## Listing 53: Changing left and center spheres to glass

```cpp
auto material_ground = make_shared<lambertian>(color(0.8, 0.8, 0.0));
+ auto material_center = make_shared<dielectric>(1.5);
+ auto material_left   = make_shared<dielectric>(1.5);
auto material_right  = make_shared<metal>(color(0.8, 0.6, 0.2), 1.0);
```

Update the definitions in `Main.idr`:

```idris
materialCenter : Dielectric
materialCenter = MkDielectric 1.5

materialLeft : Dielectric
materialLeft = MkDielectric 1.5
```

[Glass sphere that always refracts](10_image_14.png)

## Listing 54: Determining if the ray can refract

if (etai_over_etat * sin_theta > 1.0) {
    // Must Reflect
    ...
} else {
    // Can Refract
    ...
}

## Listing 55: Determining if the ray can refract

double cos_theta = fmin(dot(-unit_direction, rec.normal), 1.0);
double sin_theta = sqrt(1.0 - cos_theta*cos_theta);

if (etai_over_etat * sin_theta > 1.0) {
    // Must Reflect
    ...
} else {
    // Can Refract
    ...
}

## Listing 56: Dielectric material class with reflection

class dielectric : public material {
    public:
        dielectric(double ri) : ref_idx(ri) {}

        virtual bool scatter(
            const ray& r_in, const hit_record& rec, color& attenuation, ray& scattered
        ) const override {
            attenuation = color(1.0, 1.0, 1.0);
            double etai_over_etat = rec.front_face ? (1.0 / ref_idx) : ref_idx;

            vec3 unit_direction = unit_vector(r_in.direction());

            double cos_theta = fmin(dot(-unit_direction, rec.normal), 1.0);
            double sin_theta = sqrt(1.0 - cos_theta*cos_theta);
            if (etai_over_etat * sin_theta > 1.0 ) {
                vec3 reflected = reflect(unit_direction, rec.normal);
                scattered = ray(rec.p, reflected);
                return true;
            }

            vec3 refracted = refract(unit_direction, rec.normal, etai_over_etat);
            scattered = ray(rec.p, refracted);
            return true;
        }

    public:
        double ref_idx;
};

## Listing 57: Scene with dielectric and shiny sphere

auto material_ground = make_shared<lambertian>(color(0.8, 0.8, 0.0));
auto material_center = make_shared<lambertian>(color(0.1, 0.2, 0.5));
auto material_left   = make_shared<dielectric>(1.5);
auto material_right  = make_shared<metal>(color(0.8, 0.6, 0.2), 0.0);

[Glass sphere that sometimes refracts](10_image_15.png)

## Listing 58: Schlick approximation

```cpp
double schlick(double cosine, double ref_idx) {
    auto r0 = (1-ref_idx) / (1+ref_idx);
    r0 = r0*r0;
    return r0 + (1-r0)*pow((1 - cosine),5);
}
```

```idris
```

## Listing 59: Full glass material

```cpp
class dielectric : public material {
    public:
        dielectric(double ri) : ref_idx(ri) {}

        virtual bool scatter(
            const ray& r_in, const hit_record& rec, color& attenuation, ray& scattered
        ) const override {
            attenuation = color(1.0, 1.0, 1.0);
            double etai_over_etat = rec.front_face ? (1.0 / ref_idx) : ref_idx;

            vec3 unit_direction = unit_vector(r_in.direction());
            double cos_theta = fmin(dot(-unit_direction, rec.normal), 1.0);
            double sin_theta = sqrt(1.0 - cos_theta*cos_theta);
            if (etai_over_etat * sin_theta > 1.0 ) {
                vec3 reflected = reflect(unit_direction, rec.normal);
                scattered = ray(rec.p, reflected);
                return true;
            }
            double reflect_prob = schlick(cos_theta, etai_over_etat);
            if (random_double() < reflect_prob)
            {
                vec3 reflected = reflect(unit_direction, rec.normal);
                scattered = ray(rec.p, reflected);
                return true;
            }
            vec3 refracted = refract(unit_direction, rec.normal, etai_over_etat);
            scattered = ray(rec.p, refracted);
            return true;
        }

    public:
        double ref_idx;
};
```

```idris
```

## Listing 60: Scene with hollow glass sphere

```cpp
world.add(make_shared<sphere>(point3( 0.0, -100.5, -1.0), 100.0, material_ground));
world.add(make_shared<sphere>(point3( 0.0,    0.0, -1.0),   0.5, material_center));
world.add(make_shared<sphere>(point3(-1.0,    0.0, -1.0),   0.5, material_left));
world.add(make_shared<sphere>(point3(-1.0,    0.0, -1.0),  -0.4, material_left));
world.add(make_shared<sphere>(point3( 1.0,    0.0, -1.0),   0.5, material_right));
```

```idris
```

## Final Render

A hallow glass sphere:

![A hallow glass sphere](images/10_Final.png)
