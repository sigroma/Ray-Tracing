defmodule RayTracing.Geometry.XZRect do
  @moduledoc """
  Axis-aligned rect.
  """

  defstruct x0: 0, x1: 1, z0: 0, z1: 1, y: 0, material: nil
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.XZRect do
  @doc """
  Gets the hitting info.

  Returns `{t, p, uv, n, m}`,
  where `t` is the hitting point's parameter on ray,
        `p` is the hitting point,
        `uv` is the hitting point's uv,
        `n` is the normal,
        `m` is the material.
  """
  def hit(rect, ray, t_min, t_max) do
    {{ox, oy, oz}, {dx, dy, dz}, _} = ray
    t = (rect.y - oy) / dy
    if t < t_min or t > t_max do
      :error
    else
      x = ox + t * dx
      z = oz + t * dz
      if x < rect.x0 or x > rect.x1 or z < rect.z0 or z > rect.z1 do
        :error
      else
        p = RayTracing.Linalg.Ray.point_at(ray, t)
        uv = {(x - rect.x0) / (rect.x1 - rect.x0),
              (z - rect.z0) / (rect.z1 - rect.z0)}
        {t, p, uv, Graphmath.Vec3.create(0, 1, 0), rect.material}
      end
    end
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.XZRect do
  @doc """
  Gets the bounding box of the rect.
  """
  def bounding_box(rect, _t0, _t1) do
    %RayTracing.Geometry.AABB{
      min: Graphmath.Vec3.create(rect.x0, rect.y - 0.0001, rect.z0),
      max: Graphmath.Vec3.create(rect.x1, rect.y + 0.0001, rect.z1)}
  end
end
