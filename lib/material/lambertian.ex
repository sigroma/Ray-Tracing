defmodule RayTracing.Material.Lambertian do
  @moduledoc """
  Lambertian is a diffuse model, which reflects light with same energy in all directions.
  """

  defstruct albedo: nil
end

defimpl RayTracing.Material, for: RayTracing.Material.Lambertian do
  alias RayTracing.Sampler
  alias RayTracing.Linalg.Ray
  alias Graphmath.Vec3

  @doc """
  Scatters a new ray from hitting point.

  Returns `{:ok, attenuation, ray}`,
  where   `attenuation` is the energy attenuation of incident light,
          `ray` is the new scaterring ray.
  """
  def scatter(material, ray, rec) do
    {_, p, n, _} = rec
    target = p |> Vec3.add(n) |> Vec3.add(Sampler.random_in_unit_sphere)
    {:ok,
     RayTracing.Texture.value(material.albedo, 0, 0, p),
     Ray.create(p, Vec3.subtract(target, p), Ray.time(ray))}
  end
end
