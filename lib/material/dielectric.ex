defmodule RayTracing.Material.Dielectric do
  @moduledoc """
  Dielectric material has both reflective and refractive part.
  """

  defstruct ref_idx: 1.0
end

defimpl RayTracing.Material, for: RayTracing.Material.Dielectric do
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
    rd = Ray.direction(ray)
    reflected = Sampler.reflect(rd, n)

    {outward_normal, ni_over_nt, cosine} =
      if Vec3.dot(rd, n) > 0 do # Inside object
        cosine = Vec3.normalize(rd) |> Vec3.dot(n)
        discriminant = 1 - material.ref_idx*material.ref_idx*(1-cosine*cosine)
        cosine = if discriminant > 0, do: :math.sqrt(discriminant), else: 0
        {Vec3.subtract(Vec3.create, n), material.ref_idx, cosine}
      else # Outside
        cosine = -(Vec3.normalize(rd) |> Vec3.dot(n))
        {n, 1 / material.ref_idx, cosine}
      end

    {reflect_prob, refracted} =
      case Sampler.refract(rd, outward_normal, ni_over_nt) do
        {:ok, refracted} -> {Sampler.schlick(cosine, material.ref_idx), refracted}
        _ -> {1.0, reflected}
      end

    if :random.uniform < reflect_prob do
      {:ok, Vec3.create(1.0, 1.0, 1.0), Ray.create(p, reflected, Ray.time(ray))}
    else
      {:ok, Vec3.create(1.0, 1.0, 1.0), Ray.create(p, refracted, Ray.time(ray))}
    end
  end
end
