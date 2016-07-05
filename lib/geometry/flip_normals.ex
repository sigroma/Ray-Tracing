defmodule RayTracing.Geometry.FlipNormals do
  @moduledoc """
  Flips the hitting point's normal.
  """

  defstruct geometry: nil
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.FlipNormals do
  alias Graphmath.Vec3

  def hit(flip, ray, t_min, t_max) do
    case RayTracing.Geometry.Hitable.hit(flip.geometry, ray, t_min, t_max) do
      {t, p, uv, n, m} -> {t, p, uv, Vec3.subtract(Vec3.create, n), m}
      _ -> :error
    end
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.FlipNormals do
  def bounding_box(flip, t0, t1) do
    RayTracing.Geometry.Boundable.bounding_box(flip.geometry, t0, t1)
  end
end
