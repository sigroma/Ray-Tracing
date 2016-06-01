defprotocol RayTracing.Geometry.HitRecord do
  @fallback_to_any true
  def hit(geometry, ray, t_min, t_max)
end

defimpl RayTracing.Geometry.HitRecord, for: Any do
  def hit(_, _, _, _) do
    :error
  end
end
