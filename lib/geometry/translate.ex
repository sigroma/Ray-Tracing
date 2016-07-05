defmodule RayTracing.Geometry.Translate do
  @moduledoc """
  Instance of the geometry with translation.
  """

  defstruct geometry: nil, offset: Graphmath.Vec3.create
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.Translate do
  def hit(trans, ray, t_min, t_max) do
    {o, d, t} = ray
    ray = RayTracing.Linalg.Ray.create(Graphmath.Vec3.subtract(o, trans.offset), d, t)
    case RayTracing.Geometry.Hitable.hit(trans.geometry, ray, t_min, t_max) do
      {t, p, uv, n, m} -> {t, Graphmath.Vec3.add(p, trans.offset), uv, n, m}
      _ -> :error
    end
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.Translate do
  def bounding_box(trans, t0, t1) do
    bbox = RayTracing.Geometry.Boundable.bounding_box(trans.geometry, t0, t1)
    if bbox != nil do
      %RayTracing.Geometry.AABB{min: Graphmath.Vec3.add(bbox.min, trans.offset),
                                max: Graphmath.Vec3.add(bbox.max, trans.offset)}
    end
  end
end
