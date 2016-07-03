defmodule RayTracing.Material.DiffuseLight do
  @doc """
  Self illumination material.
  """

  defstruct texture: nil
end

defimpl RayTracing.Material, for: RayTracing.Material.DiffuseLight do
  def scatter(_, _, _) do
    :error
  end

  def emitted(material, u, v, p) do
    RayTracing.Texture.value(material.texture, u, v, p)
  end
end
