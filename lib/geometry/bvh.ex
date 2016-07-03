defmodule RayTracing.Geometry.BVH do
  @moduledoc """
  Bounding volume hierarchy that stores geometry's bounding box in a tree to speed up hitting detection.
  """

  defstruct lnode: nil, rnode: nil, bbox: nil

  @doc """
  Creates a bvh of the specified objects.
  """
  def create(objects, t0, t1) do
    axis = :random.uniform(3) - 1
    objects = Enum.sort_by(objects, &bbox_on_axis(&1, t0, t1, axis))
    case length(objects) do
      1 -> o = hd(objects)
           %RayTracing.Geometry.BVH{lnode: o, bbox: RayTracing.Geometry.Boundable.bounding_box(o, t0, t1)}
      2 -> l = hd(objects)
           r = hd(tl(objects))
           %RayTracing.Geometry.BVH{lnode: l,
                                    rnode: r,
                                    bbox: RayTracing.Geometry.AABB.union(
                                          RayTracing.Geometry.Boundable.bounding_box(l, t0, t1),
                                          RayTracing.Geometry.Boundable.bounding_box(r, t0, t1))}
      n -> {l, r} = Enum.split(objects, trunc(n / 2))
           l = create(l, t0, t1)
           r = create(r, t0, t1)
           %RayTracing.Geometry.BVH{lnode: l,
                                    rnode: r,
                                    bbox: RayTracing.Geometry.AABB.union(
                                          RayTracing.Geometry.Boundable.bounding_box(l, t0, t1),
                                          RayTracing.Geometry.Boundable.bounding_box(r, t0, t1))}
    end
  end

  # Gets the value of the bounding box on the specified axis.
  defp bbox_on_axis(g, t0, t1, a) do
    elem(RayTracing.Geometry.Boundable.bounding_box(g, t0, t1).min, a)
  end
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.BVH do
  @doc """
  Gets the hitting info.

  Returns `{t, p, n, m}`,
  where `t` is the hitting point's parameter on ray,
        `p` is the hitting point,
        `n` is the normal,
        `m` is the material.
  """
  def hit(bvh, ray, t_min, t_max) do
    case RayTracing.Geometry.Hitable.hit(bvh.bbox, ray, t_min, t_max) do
      :ok -> first(RayTracing.Geometry.Hitable.hit(bvh.lnode, ray, t_min, t_max),
                   RayTracing.Geometry.Hitable.hit(bvh.rnode, ray, t_min, t_max))
      _ -> :error
    end
  end

  # Gets the first hitted hiting info.
  defp first(lrec, rrec) do
    case {lrec, rrec} do
      {:error, r} -> r
      {l, :error} -> l
      {{lt, _, _, _, _} = l, {rt, _, _, _, _} = r} -> if lt < rt, do: l, else: r
    end
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.BVH do
  @doc """
  Gets the bounding box of bvh.
  """
  def bounding_box(bvh, _t0, _t1) do
    bvh.bbox
  end
end
