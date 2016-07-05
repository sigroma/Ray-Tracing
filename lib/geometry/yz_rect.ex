defmodule RayTracing.Geometry.YZRect do
  @moduledoc """
  Axis-aligned rect.
  """

  defstruct y0: 0, y1: 1, z0: 0, z1: 1, x: 0, material: nil
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.YZRect do
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
    t = (rect.x - ox) / dx
    if t < t_min or t > t_max do
      :error
    else
      y = oy + t * dy
      z = oz + t * dz
      if y < rect.y0 or y > rect.y1 or z < rect.z0 or z > rect.z1 do
        :error
      else
        p = RayTracing.Linalg.Ray.point_at(ray, t)
        uv = {(y - rect.y0) / (rect.y1 - rect.y0),
              (z - rect.z0) / (rect.z1 - rect.z0)}
        {t, p, uv, Graphmath.Vec3.create(1, 0, 0), rect.material}
      end
    end
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.YZRect do
  @doc """
  Gets the bounding box of the rect.
  """
  def bounding_box(rect, _t0, _t1) do
    %RayTracing.Geometry.AABB{
      min: Graphmath.Vec3.create(rect.x - 0.0001, rect.y0, rect.z0),
      max: Graphmath.Vec3.create(rect.x + 0.0001, rect.y1, rect.z1)}
  end
end
