defprotocol RayTracing.Geometry.Hitable do
  @fallback_to_any true
  def hit(geometry, ray, t_min, t_max)
end

defimpl RayTracing.Geometry.Hitable, for: Any do
  def hit(_, _, _, _) do
    :error
  end
end
