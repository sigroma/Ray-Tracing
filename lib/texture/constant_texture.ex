defmodule RayTracing.Texture.ConstantTexture do
  @moduledoc """
  Single color texture.
  """

  defstruct color: {1.0, 1.0, 1.0}
end

defimpl RayTracing.Texture, for: RayTracing.Texture.ConstantTexture do
  @doc """
  Gets the texture's color at the specified uv and position.
  """
  def value(tex, _u, _v, _p) do
    tex.color
  end
end
