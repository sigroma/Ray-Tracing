defprotocol RayTracing.Material do
  @fallback_to_any true
  def scatter(material, ray, rec)
end

defimpl RayTracing.Material, for: Any do
  def scatter(_, _, _) do
    :error
  end
end
