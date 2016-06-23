defmodule RayTracing.Scene do
  @moduledoc """
  Descripts objects in the world.
  """
  alias Graphmath.Vec3
  alias RayTracing.Geometry.Sphere
  alias RayTracing.Geometry.MovingSphere
  alias RayTracing.Material.Lambertian
  alias RayTracing.Material.Metal
  alias RayTracing.Material.Dielectric

  defstruct camera: nil, objects: nil

  @doc """
  Generates a random world with sphere.

  Note that it's related to a specified camera.
  """
  def gen_random_objects do
    nearest_ball_position = Vec3.create(4.0, 0.2, 0.0)
    objects =
      for x <- -11..10,
          z <- -11..10,
          center = Vec3.create(x + :random.uniform, 0.2, z + :random.uniform),
          Vec3.subtract(center, nearest_ball_position) |> Vec3.length > 0.9 do
        case :random.uniform do
          r when r < 0.8 ->
            %MovingSphere{center0: center,
                          center1: Vec3.add(center, Vec3.create(0.0, 0.5*:random.uniform, 0.0)),
                          radius: 0.2,
                          material: %Lambertian{albedo: gen_random_color}}
          r when r < 0.9 ->
            %Sphere{center: center,
                    radius: 0.2,
                    material: %Metal{albedo: gen_random_color, fuzz: 0.5*:random.uniform}}
          _ ->
            %Sphere{center: center,
                    radius: 0.2,
                    material: %Dielectric{ref_idx: 1.5 + 0.3*:random.uniform}}
        end
      end
    objects = List.insert_at(objects, 0,
      %Sphere{center: Vec3.create(0.0, -1000.0, 0.0), radius: 1000.0, material: %Lambertian{albedo: {0.5, 0.5, 0.5}}})
    objects = List.insert_at(objects, 0,
      %Sphere{center: Vec3.create(0.0, 1.0, 0.0), radius: 1.0, material: %Dielectric{ref_idx: 1.5}})
    objects = List.insert_at(objects, 0,
      %Sphere{center: Vec3.create(-4.0, 1.0, 0.0), radius: 1.0, material: %Lambertian{albedo: {0.4, 0.2, 0.1}}})
    List.insert_at(objects, 0,
      %Sphere{center: Vec3.create(4.0, 1.0, 0.0), radius: 1.0, material: %Metal{albedo: {0.7, 0.6, 0.5}}})
  end

  defp gen_random_color do
    Vec3.create(:random.uniform * :random.uniform,
                :random.uniform * :random.uniform,
                :random.uniform * :random.uniform)
  end
end

defimpl RayTracing.Geometry.Hitable, for: List do
  @doc """
  Gets the hitting info of objects list.

  Returns the first hitting object's info.
  """
  def hit(objects, ray, t_min, t_max) do
    Enum.reduce(objects, :error,
      fn o, acc ->
        closet = if acc == :error, do: t_max, else: elem(acc, 0)
        case RayTracing.Geometry.Hitable.hit(o, ray, t_min, closet) do
          {_, _, _, _} = rec -> rec
          _ -> acc
        end
      end)
  end
end

defimpl RayTracing.Geometry.Boundable, for: List do
  @doc """
  Gets the bounding box of the objects list.
  """
  def bounding_box(objects, t0, t1) do
    Enum.reduce(objects, nil, &RayTracing.Geometry.AABB.union(RayTracing.Geometry.Boundable.bounding_box(&1, t0, t1), &2))
  end
end
