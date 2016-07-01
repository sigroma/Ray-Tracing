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
    Vec3.scale(Vec3.create(1, 1, 1),
               RayTracing.Noise.Perlin.noise(tex.perlin, Vec3.scale(p, tex.scale)))
  end
end
