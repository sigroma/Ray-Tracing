defmodule RayTracing.Geometry.AABB do
  @moduledoc """
  Axis aligned bounding box.
  """

  defstruct min: {0.0, 0.0, 0.0}, max: {1.0, 1.0, 1.0}

  def union(:error, bbox) do
    bbox
  end

  def union(bbox, :error) do
    bbox
  end

  @doc """
  Union of two aabb.
  """
  @spec union(struct, struct) :: struct
  def union(bbox0, bbox1) do
    {minx0, miny0, minz0} = bbox0.min
    {minx1, miny1, minz1} = bbox1.min
    {maxx0, maxy0, maxz0} = bbox0.max
    {maxx1, maxy1, maxz1} = bbox1.max
    %RayTracing.Geometry.AABB{
      min: {min(minx0, minx1), min(miny0, miny1), min(minz0, minz1)},
      max: {max(maxx0, maxx1), max(maxy0, maxy1), max(maxz0, maxz1)}}
  end
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.AABB do
  @doc """
  Gets the hitting info.
  """
  def hit(bbox, ray, tmin, tmax) do
    {tmin, tmax} = :lists.seq(0, 2)
      |> Enum.map(&({elem(bbox.min, &1),
                     elem(bbox.max, &1),
                     elem(RayTracing.Linalg.Ray.origin(ray), &1),
                     elem(RayTracing.Linalg.Ray.direction(ray), &1)}))
      |> Enum.map(&hit_on_axis(&1, tmax))
      |> Enum.reduce({tmin, tmax},
                     fn {t0, t1}, {tmin, tmax} ->
                       {max(tmin, t0), min(tmax, t1)} end)
    if tmin < tmax, do: :ok, else: :error
  end

  # Tests intersection on a specifed axis.
  defp hit_on_axis({mina, maxa, oa, da}, tmax) do
    # Tests division by zero. If true use the max value.
    inv_d =
      try do
        1.0 / da
      rescue
        ArithmeticError -> tmax
      end
    {t0, t1} = {(mina - oa) * inv_d, (maxa - oa) * inv_d}
    if inv_d < 0.0, do: {t1, t0}, else: {t0, t1}
  end
end
