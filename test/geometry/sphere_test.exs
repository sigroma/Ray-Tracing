defmodule RayTracing.Geometry.SphereTest do
  use ExUnit.Case
  @radius :math.sqrt(3.0)

  setup do
    sphere = %RayTracing.Geometry.Sphere{radius: @radius}
    {:ok, sphere: sphere}
  end
  
  test "intersection with imaginary root", %{sphere: sphere} do
    ray = RayTracing.Linalg.Ray.create({4.0, 4.0, 4.0}, {1.0, 1.0, 1.0})
    assert RayTracing.Geometry.HitRecord.hit(sphere, ray, 0, 100) ==
      :error
  end

  test "intersection out of range", %{sphere: sphere} do
    ray = RayTracing.Linalg.Ray.create({0.0, 0.0, 0.0}, {1.0, 1.0, 1.0})
    assert RayTracing.Geometry.HitRecord.hit(sphere, ray, 0, 0.8) ==
      :error
    assert RayTracing.Geometry.HitRecord.hit(sphere, ray, 2.0, 100) ==
      :error
  end

  test "intersection within range", %{sphere: sphere} do
    ray = RayTracing.Linalg.Ray.create({0.0, 0.0, 0.0}, {1.0, 1.0, 1.0})
    assert RayTracing.Geometry.HitRecord.hit(sphere, ray, 0, 100) ==
      {1.0, {1.0, 1.0, 1.0}, {1.0 / @radius, 1.0 / @radius, 1.0 / @radius}, nil}
  end
end
