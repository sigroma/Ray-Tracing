defmodule RayTracing.SceneTest do
  use ExUnit.Case

  test "bounding box of empty list" do
    assert RayTracing.Geometry.Boundable.bounding_box([], 0, 1) == nil
  end

  test "bounding box of list with objects" do
    objects = [%RayTracing.Geometry.Sphere{center: {0, 0, 0}, radius: 1},
               %RayTracing.Geometry.Sphere{center: {-1, 1, 2}, radius: 0.5}]
    assert RayTracing.Geometry.Boundable.bounding_box(objects, 0, 1) ==
      %RayTracing.Geometry.AABB{min: {-1.5, -1, -1}, max: {1, 1.5, 2.5}}
  end
end
