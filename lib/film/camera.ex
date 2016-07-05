defmodule RayTracing.Film.Camera do
  @moduledoc """
  Simple camera model with focus.
  """
  @type vec3 :: {float, float, float}
  @type ray :: {vec3, vec3, float}

  alias Graphmath.Vec3
  alias RayTracing.Linalg.Ray

  defstruct origin: {0.0, 0.0, 0.0},
            lower_left_corner: {0.0, 0.0, 0.0},
            horizontal: {0.0, 0.0, 0.0},
            vertical: {0.0, 0.0, 0.0},
            u: {0.0, 0.0, 0.0},
            v: {0.0, 0.0, 0.0},
            w: {0.0, 0.0, 0.0},
            time0: 0.0,
            time1: 1.0,
            lens_radius: 0

  @doc """
  Creates a new camera.

  `lookfrom` is the position of the lens.
  `lookat` is the camera's direction.
  `vup` is the camera's up direction.
  `vfov` is the field of view.
  """
  @spec create(vec3, vec3, vec3, float, float, float, float, float, float) :: struct
  def create(lookfrom, lookat, vup, vfov, aspect, aperture, focus_dist, t0, t1) do
    # `lens_radius` defines the exposure, but more `lens_radius` causes more fuzzy.
    # Set it to zero will degenerate the camera to the pinhole model.
    lens_radius = aperture / 2.0
    # Transforms deg to rad
    theta = vfov * :math.pi / 180
    # Uniformed half height
    half_height = :math.tan(theta / 2.0)
    half_weight = aspect * half_height

    # Orthogonalizes the local coordination.
    w = Vec3.subtract(lookfrom, lookat) |> Vec3.normalize
    u = Vec3.cross(vup, w) |> Vec3.normalize
    v = Vec3.cross(w, u)

    # The bottom-left of the film.
    lower_left_corner = lookfrom
                          |> Vec3.subtract(Vec3.scale(u, half_weight * focus_dist))
                          |> Vec3.subtract(Vec3.scale(v, half_height * focus_dist))
                          |> Vec3.subtract(Vec3.scale(w, focus_dist))

    %RayTracing.Film.Camera{origin: lookfrom,
                            lower_left_corner: lower_left_corner,
                            horizontal: Vec3.scale(u, 2 * half_weight * focus_dist),
                            vertical: Vec3.scale(v, 2 * half_height * focus_dist),
                            u: u,
                            v: v,
                            w: w,
                            time0: t0,
                            time1: t1,
                            lens_radius: lens_radius}
  end

  @doc """
  The camera of the cornell-box scene.
  """
  def create_cornell(aspect) do
    create(Vec3.create(278, 278, -800),
           Vec3.create(278, 278, 0),
           Vec3.create(0, 10, 0),
           40.0,
           aspect,
           0.0,
           10.0,
           0.0,
           1.0)
  end

  @doc """
  Gets a random ray from camera.

  Uses random samples to get depth of field.
  """
  @spec get_ray(struct, {float, float}) :: ray
  def get_ray(camera, {s, t}) do
    {x, y, _z} = Vec3.scale(random_in_unit_dist, camera.lens_radius)
    offset = Vec3.scale(camera.u, x) |> Vec3.add(Vec3.scale(camera.v, y))
    time = camera.time0 + :random.uniform * (camera.time1 - camera.time0)
    Ray.create(Vec3.add(camera.origin, offset),
               camera.lower_left_corner
                 |> Vec3.add(Vec3.scale(camera.horizontal, s))
                 |> Vec3.add(Vec3.scale(camera.vertical, t))
                 |> Vec3.subtract(camera.origin)
                 |> Vec3.subtract(offset),
               time)
  end

  # Gets a random position within uniformed dist
  @spec random_in_unit_dist :: vec3
  defp random_in_unit_dist do
    p = Vec3.scale(Vec3.create(:random.uniform, :random.uniform, 0), 2.0)
          |> Vec3.subtract(Vec3.create(1.0, 1.0, 0.0))
    if Vec3.dot(p, p) < 1.0, do: p, else: random_in_unit_dist
  end
end
