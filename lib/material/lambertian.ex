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
    {_, p, {u, v}, n, _} = rec
    target = p |> Vec3.add(n) |> Vec3.add(Sampler.random_in_unit_sphere)
    {:ok,
     RayTracing.Texture.value(material.albedo, u, v, p),
     Ray.create(p, Vec3.subtract(target, p), Ray.time(ray))}
  end

  def emitted(_, _, _, _) do
    Vec3.create
  end
end
