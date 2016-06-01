defmodule RayTracing do
  use Application
  alias Imagineer.Image.PNG
  alias Graphmath.Vec3
  alias RayTracing.Film.Camera
  alias RayTracing.Linalg.Ray
  alias RayTracing.Scene

  def start(_type, _args) do
    # Film's width
    nx = 120
    # Film's height
    ny = 80
    # Sample rate
    ns = 10

    :random.seed(:erlang.system_time)

    scene = %Scene{
      camera: Camera.create(Vec3.create(13.0, 2.0, 3.0),
                            Vec3.create,
                            Vec3.create(0.0, 1.0, 0.0),
                            20.0,
                            nx / ny,
                            0.1,
                            10.0),
      objects: Scene.gen_random_objects}

    {microsec, pixels} = :timer.tc fn ->
      for y <- ny-1..0,
          x <- 0..nx-1 do
        # Samples filer to get antialiasing.
        # The enumerator is too slow. I'm wondering if there is any optimization.
        {r, g, b} = (for _ <- 0..ns-1, do: {(x + :random.uniform) / nx, (y + :random.uniform) / ny})
                      |> Enum.map(&Camera.get_ray(scene.camera, &1))
                      |> Enum.map(&color(&1, scene.objects, 0))
                      # There is something wrong with random in `Task`.
                      # Every `Task` shares the same seed.
                      # It's still weird even reseeded in `Task`s.
                      # And how can I take full use of the multicores?
                      #|> Enum.map(&(Task.async(fn -> color(Camera.get_ray(scene.camera, &1), scene.objects, 0) end)))
                      #|> Enum.map(&(Task.await/1))
                      |> Enum.reduce(&Vec3.add/2)
                      |> Vec3.scale(1.0 / ns)
        # Enhances pixel.
        {r, g, b} = {:math.sqrt(r), :math.sqrt(g), :math.sqrt(b)} |> Vec3.scale(255.99)
        {trunc(r), trunc(g), trunc(b)}
      end
        |> Enum.chunk(nx)
    end

    IO.puts "Main loop took #{microsec/1000} ms."

    Imagineer.write(make_image(pixels, nx, ny), "./output.png")
    {:ok, self}
  end

  # Gets color from sampled ray.
  defp color(_ray, _objects, depth) when depth >= 50, do: Vec3.create

  defp color(ray, objects, depth) do
    (with {_, _, _, mat} = rec <- RayTracing.Geometry.HitRecord.hit(objects, ray, 0.001, 100000),
          {:ok, attenuation, scatterd} <- RayTracing.Material.scatter(mat, ray, rec),
          do: Vec3.multiply(color(scatterd, objects, depth+1), attenuation))
      |> wrap_color(ray)
  end

  defp wrap_color(color, ray) do
    case color do
      {_, _, _} = col -> col
      _ ->
        # Tricky light.
        unit_direction = Ray.direction(ray) |> Vec3.normalize
        # Transforms to [0, 1].
        t = 0.5 * (elem(unit_direction, 1) + 1.0)
        Vec3.lerp(Vec3.create(1.0, 1.0, 1.0), Vec3.create(0.5, 0.7, 1.0), t)
    end
  end

  # Makes png image from the pixels.
  defp make_image(pixels, nx, ny) do
    %PNG{
      color_type: 2,
      color_format: :rgb,
      bit_depth: 8,
      interlace_method: 0,
      filter_method: :five_basics,
      width: nx,
      height: ny,
      pixels: pixels}
  end
end
