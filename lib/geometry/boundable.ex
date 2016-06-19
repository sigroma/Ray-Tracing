defprotocol RayTracing.Geometry.Boundable do
  @fallback_to_any true
  def bounding_box(geometry, t0, t1)
end

defimpl RayTracing.Geometry.Boundable, for: Any do
  def bounding_box(_, _, _) do
    :error
  end
end
