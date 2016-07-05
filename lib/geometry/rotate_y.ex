defmodule RayTracing.Geometry.RotateY do
  @moduledoc """
  Instance of the geometry with rotation in y axis.
  """

  defstruct geometry: nil, matrix: nil

  def create(geometry, angle) do
    %RayTracing.Geometry.RotateY{geometry: geometry,
                                 matrix: make_rotate_y(angle / 180 * :math.pi)}
  end

  # Extention of `Graphmath.Mat33`
  defp make_rotate_y(theta) do
    st = :math.sin(theta)
    ct = :math.cos(theta)

    { ct, 0, -st,
      0, 1, 0,
      st, 0, ct }
  end
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.RotateY do
  alias Graphmath.Mat33
  def hit(rot, ray, t_min, t_max) do
    {o, d, t} = ray
    ray = RayTracing.Linalg.Ray.create(Mat33.apply_transpose(rot.matrix, o),
                                       Mat33.apply_transpose(rot.matrix, d),
                                       t)

    case RayTracing.Geometry.Hitable.hit(rot.geometry, ray, t_min, t_max) do
      {t, p, uv, n, m} -> {t, Mat33.apply(rot.matrix, p), uv, Mat33.apply(rot.matrix, n), m}
      _ -> :error
    end
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.RotateY do
  def bounding_box(rot, t0, t1) do
    bbox = RayTracing.Geometry.Boundable.bounding_box(rot.geometry, t0, t1)
    if bbox != nil do
      {minx, miny, minz} = bbox.min
      {maxx, maxy, maxz} = bbox.max
      rot_vert = (for x <- [minx, maxx],
                      y <- [miny, maxy],
                      z <- [minz, maxz], do: {x, y, z})
                   |> Enum.map(&Graphmath.Mat33.apply(rot.matrix, &1))
      min = Enum.reduce(rot_vert, {0, 0, 0}, fn {x, y, z}, {mx, my, mz} ->
                                               {(if x < mx, do: x, else: mx),
                                                (if y < my, do: y, else: my),
                                                (if z < mz, do: z, else: mz)}
                                             end)
      max = Enum.reduce(rot_vert, {0, 0, 0}, fn {x, y, z}, {mx, my, mz} ->
                                               {(if x > mx, do: x, else: mx),
                                                (if y > my, do: y, else: my),
                                                (if z > mz, do: z, else: mz)}
                                             end)
      %RayTracing.Geometry.AABB{min: min, max: max}
    end
  end
end
