defmodule RayTracing.Geometry.Sphere do
  @moduledoc """
  Sphere with center, radius and material.
  """

  defstruct center: {0.0, 0.0, 0.0}, radius: 1, material: nil
end

defimpl RayTracing.Geometry.HitRecord, for: RayTracing.Geometry.Sphere do
  alias Graphmath.Vec3
  alias RayTracing.Linalg
  alias RayTracing.Linalg.Ray

  @doc """
  Gets the hitting info.

  Returns `{t, p, n, m}`,
  where `t` is the hitting point's parameter on ray,
        `p` is the hitting point,
        `n` is the normal,
        `m` is the material.
  """
  def hit(sphere, ray, t_min, t_max) do
    # Transforms ray's origin to sphere's local coordinates.
    oc = Vec3.subtract(Ray.origin(ray), sphere.center)
    # Solves the intersection of ray and sphere.
    # (ox + t*dx)^2 + (oy + t*dy)^2 + (oz + t*dz)^2 = r^2, expand it to:
    # At^2 + Bt + C = 0, where
    # A = (dx^2 + dy^2 + dz^2),
    # B = 2 * (oxdx + oydy + ozdz),
    # C = (ox^2 + oy^2 + oz^2) - r^2.
    a = Vec3.dot(Ray.direction(ray), Ray.direction(ray))
    b = 2.0 * Vec3.dot(oc, Ray.direction(ray))
    c = Vec3.dot(oc, oc) - sphere.radius * sphere.radius

    case Linalg.solve_quadratic(a, b, c) do
      # Checks the first position
      {x, _y} when x < t_max and x > t_min ->
        p = Ray.point_at(ray, x)
        {x, p, Vec3.subtract(p, sphere.center) |> Vec3.scale(1.0 / sphere.radius), sphere.material}
      # Checks the second position
      {_x, y} when y < t_max and y > t_min ->
        p = Ray.point_at(ray, y)
        {y, p, Vec3.subtract(p, sphere.center) |> Vec3.scale(1.0 / sphere.radius), sphere.material}
      _ -> :error
    end
  end
end
