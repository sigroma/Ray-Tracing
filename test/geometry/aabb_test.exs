defmodule RayTracing.Geometry.AABBTest do
  use ExUnit.Case

  setup do
    bbox = %RayTracing.Geometry.AABB{}
    {:ok, bbox: bbox}
  end

  test "intersect with ray", %{bbox: bbox} do
    ray = RayTracing.Linalg.Ray.create({-1, -1, -1}, {1, 1, 1}, 0)
    assert RayTracing.Geometry.Hitable.hit(bbox, ray, 0, 100) == :ok
  end

  test "not intersect", %{bbox: bbox} do
    ray = RayTracing.Linalg.Ray.create({-1, -1, -1}, {0, 1, 0}, 0)
    assert RayTracing.Geometry.Hitable.hit(bbox, ray, 0, 100) == :error
  end

  test "bounding box union", %{bbox: bbox0} do
    bbox1 = %RayTracing.Geometry.AABB{
      min: {-1, -1, -1},
      max: {2, 0.5, -0.5}}
    assert RayTracing.Geometry.AABB.union(bbox0, bbox1) ==
      %RayTracing.Geometry.AABB{
        min: {-1, -1, -1},
        max: {2, 1, 1}}
  end

  test "union with `:error`", %{bbox: bbox} do
    assert RayTracing.Geometry.AABB.union(:error, bbox) == bbox
    assert RayTracing.Geometry.AABB.union(bbox, :error) == bbox
    assert RayTracing.Geometry.AABB.union(:error, :error) == :error
  end
end
