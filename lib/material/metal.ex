defmodule RayTracing.Material.Metal do
  @moduledoc """
  Specular material, which is like lambertian but more highlight with view direction.
  """

  defstruct albedo: {1.0, 1.0, 1.0}, fuzz: 0.0
end

defimpl RayTracing.Material, for: RayTracing.Material.Metal do
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
    scattered = Sampler.reflect(Vec3.normalize(Ray.direction(ray)), n)
                 |> Vec3.add(Vec3.scale(Sampler.random_in_unit_sphere, material.fuzz))
    # Not scatter to self.
    if(Vec3.dot(scattered, n) > 0.0) do
      {:ok, material.albedo, Ray.create(p, scattered)}
    else
      # Fallback color.
      Vec3.create
    end
  end
end
