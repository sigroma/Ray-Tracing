defmodule RayTracing.Texture.NoiseTexture do
  @doc """
  Perlin noise texture.
  """

  defstruct perlin: nil, scale: 1
end

defimpl RayTracing.Texture, for: RayTracing.Texture.NoiseTexture do
  alias Graphmath.Vec3
  @doc """
  Gets the texture's color at the specified uv and position.
  """
  def value(tex, _u, _v, p) do
    {_, _, z} = p
    Vec3.scale(Vec3.create(1, 1, 1),
               #(RayTracing.Noise.Perlin.noise(tex.perlin, Vec3.scale(p, tex.scale)) + 1) * 0.5)
               #abs(RayTracing.Noise.Perlin.turb(tex.perlin, Vec3.scale(p, tex.scale), 6)))
               (:math.sin(tex.scale * z + 10 * abs(RayTracing.Noise.Perlin.turb(tex.perlin, p, 6))) + 1) * 0.5)
  end
end
