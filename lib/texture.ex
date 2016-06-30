defprotocol RayTracing.Texture do
  @fallback_to_any true
  def value(texture, u, v, p)
end

defimpl RayTracing.Texture, for: Any do
  def value(_, _, _, _) do
    Graphmath.Vec3.create(1.0, 0.0, 1.0)
  end
end
