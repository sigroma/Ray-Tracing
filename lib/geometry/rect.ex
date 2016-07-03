defmodule RayTracing.Geometry.Rect do
  @moduledoc """
  Axis-aligned rect.
  """

  defstruct x0: 0, x1: 1, y0: 0, y1: 1, z: 0, material: nil
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.Rect do
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
    t = (rect.z - oz) / dz
    if t < t_min or t > t_max do
      :error
    else
      x = ox + t * dx
      y = oy + t * dy
      if x < rect.x0 or x > rect.x1 or y < rect.y0 or y > rect.y1 do
        :error
      else
        p = RayTracing.Linalg.Ray.point_at(ray, y)
        uv = {(x - rect.x0) / (rect.x1 - rect.x0),
              (y - rect.y0) / (rect.y1 - rect.y0)}
        {t, p, uv, Graphmath.Vec3.create(0, 0, 1), rect.material}
      end
    end
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.Rect do
  @doc """
  Gets the bounding box of the rect.
  """
  def bounding_box(rect, _t0, _t1) do
    %RayTracing.Geometry.AABB{
      min: Graphmath.Vec3.create(rect.x0, rect.y0, rect.z - 0.0001),
      max: Graphmath.Vec3.create(rect.x1, rect.y1, rect.z + 0.0001)}
  end
end
