defprotocol RayTracing.Material do
  @fallback_to_any true
  def scatter(material, ray, rec)

  @fallback_to_any true
  def emitted(material, u, v, p)
end

defimpl RayTracing.Material, for: Any do
  def scatter(_, _, _) do
    :error
  end

  def emitted(_, _, _, _) do
    Vec3.create
  end
end
