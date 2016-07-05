defmodule RayTracing.Geometry.Box do
  @moduledoc """
  Axis-aligned box.
  """
  alias Graphmath.Vec3
  alias RayTracing.Geometry.XYRect
  alias RayTracing.Geometry.YZRect
  alias RayTracing.Geometry.XZRect
  alias RayTracing.Geometry.FlipNormals

  defstruct rect_list: nil, pmin: Vec3.create, pmax: Vec3.create(1, 1, 1)

  def create(pmin, pmax, material) do
    {minx, miny, minz} = pmin
    {maxx, maxy, maxz} = pmax
    %RayTracing.Geometry.Box{
      rect_list: [%XYRect{x0: minx, x1: maxx, y0: miny, y1: maxy, z: maxz, material: material},
                  %FlipNormals{geometry: %XYRect{x0: minx, x1: maxx, y0: miny, y1: maxy, z: minz, material: material}},
                  %YZRect{y0: miny, y1: maxy, z0: minz, z1: maxz, x: maxx, material: material},
                  %FlipNormals{geometry: %YZRect{y0: miny, y1: maxy, z0: minz, z1: maxz, x: minx, material: material}},
                  %XZRect{x0: minx, x1: maxx, z0: minz, z1: maxz, y: maxy, material: material},
                  %FlipNormals{geometry: %XZRect{x0: minx, x1: maxx, z0: minz, z1: maxz, y: miny, material: material}}],
      pmin: pmin,
      pmax: pmax}
  end
end

defimpl RayTracing.Geometry.Hitable, for: RayTracing.Geometry.Box do
  def hit(box, ray, t_min, t_max) do
    RayTracing.Geometry.Hitable.hit(box.rect_list, ray, t_min, t_max)
  end
end

defimpl RayTracing.Geometry.Boundable, for: RayTracing.Geometry.Box do
  def bounding_box(box, _t0, _t1) do
    %RayTracing.Geometry.AABB{min: box.pmin, max: box.pmax}
  end
end
