defmodule RayTracing.Geometry.MovingSphere do
  @moduledoc """
  Sphere with movement.
  """
  alias RayTracing.Geometry.Sphere
  @type vec3 :: {float, float, float}

  defstruct center0: {0.0, 0.0, 0.0}, center1: {0.0, 0.0, 0.0},
            time0: 0.0, time1: 1.0, radius: 1, material: nil

  @doc """
  Gets the still sphere at the specified time.
  """
  @spec sphere(struct, float) :: struct
  def sphere(moving_sphere, time) do
    %Sphere{center: center(moving_sphere, time),
            radius: moving_sphere.radius,
            material: moving_sphere.material}
  end

  @doc """
  Gets the sphere's center at the specified time.
  """
  @spec center(struct, float) :: vec3
  def center(moving_sphere, time) do
    t = (time - moving_sphere.time0) / (moving_sphere.time1 - moving_sphere.time0)
    Graphmath.Vec3.lerp(moving_sphere.center0, moving_sphere.center1, t)
  end
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.MovingSphere do
  alias RayTracing.Linalg.Ray

  @doc """
  Gets the hitting info.

  Returns `{t, p, uv, n, m}`,
  where `t` is the hitting point's parameter on ray,
        `p` is the hitting point,
        `uv` is the hitting point's uv,
        `n` is the normal,
        `m` is the material.
  """
  def hit(moving_sphere, ray, t_min, t_max) do
    # Directly getting the sphere caused a performance problem. Is it a GC or memory allocation problem?
    # The code here can be optimized by directly coping the intersection detection of `sphere` instead of creating a new sphere.
    # Is there any clean method without performance degradation?
    RayTracing.Geometry.MovingSphere.sphere(moving_sphere, Ray.time(ray))
      |> RayTracing.Geometry.Hitable.hit(ray, t_min, t_max)
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.MovingSphere do
  @doc """
  Gets the bounding box of the moving sphere.
  """
  def bounding_box(moving_sphere, t0, t1) do
    RayTracing.Geometry.AABB.union(
      RayTracing.Geometry.Boundable.bounding_box(RayTracing.Geometry.MovingSphere.sphere(moving_sphere, t0), t0, t1),
      RayTracing.Geometry.Boundable.bounding_box(RayTracing.Geometry.MovingSphere.sphere(moving_sphere, t1), t0, t1))
  end
end
