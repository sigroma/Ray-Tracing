defmodule RayTracing.Sampler do
  @moduledoc """
  Handles sampling.
  """
  @type vec3 :: {float, float, float}
  alias Graphmath.Vec3

  @doc """
  Gets a random position within a sphere.
  """
  @spec random_in_unit_sphere :: vec3
  def random_in_unit_sphere do
    vec = {:random.uniform, :random.uniform, :random.uniform} |> Vec3.scale(2) |> Vec3.subtract(Vec3.create(1, 1, 1))
    if Vec3.length_squared(vec) < 1.0, do: vec, else: random_in_unit_sphere
  end

  @doc """
  Gets the reflected direction of the incident direction with the specified normal.
  """
  def reflect(v, n) do
    Vec3.subtract(v, Vec3.scale(n, Vec3.dot(v, n) * 2.0))
  end

  @doc """
  Gets the refracted direction.
  """
  def refract(v, n, ni_over_nt) do
    uv = Vec3.normalize(v)
    dt = Vec3.dot(uv, n)
    discriminant = 1.0 - ni_over_nt*ni_over_nt*(1-dt*dt)
    if discriminant > 0 do
      {:ok, Vec3.subtract(uv, Vec3.scale(n, dt)) |> Vec3.scale(ni_over_nt) |> Vec3.subtract(Vec3.scale(n, :math.sqrt(discriminant)))}
    else
      # Full reflection.
      :error
    end
  end

  @doc """
  Gets the reflect probability.
  """
  def schlick(cosine, ref_idx) do
    r0 = (1 - ref_idx) / (1 + ref_idx)
    r0 = r0 * r0
    r0 + (1 - r0) * :math.pow((1 - cosine), 5)
  end
end
