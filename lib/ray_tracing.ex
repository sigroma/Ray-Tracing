defmodule RayTracing do
  use Application
  alias Imagineer.Image.PNG
  alias Graphmath.Vec3
  alias RayTracing.Film.Camera
  alias RayTracing.Scene

  def start(_type, _args) do
    # Film's width
    nx = 120
    # Film's height
    ny = 80
    # Sample rate
    ns = 400

    nsubprocess = :erlang.system_info(:logical_processors_available) * 2

    :random.seed(:erlang.system_time)

    scene = %Scene{
      camera: Camera.create(Vec3.create(13.0, 2.0, 3.0),
                            Vec3.create,
                            Vec3.create(0.0, 1.0, 0.0),
                            20.0,
                            nx / ny,
                            0.1,
                            10.0,
                            0.0,
                            1.0),
      #objects: RayTracing.Geometry.BVH.create(Scene.gen_random_objects, 0, 1)}
      objects: RayTracing.Geometry.BVH.create(Scene.gen_test_objects, 0, 1)}

    {microsec, pixels} = :timer.tc fn ->
      (for y <- ny-1..0,
           x <- 0..nx-1, do: {x, y})
        |> Enum.chunk(process_chunk_size(nsubprocess, nx, ny))
        |> Enum.map(&Task.async(fn -> partial(&1, nx, ny, ns, scene) end))
        |> Enum.map(&yield_until_finish/1)
        |> List.flatten
        |> Enum.chunk(nx)
    end

    IO.puts "Main loop took #{microsec/1000} ms."

    Imagineer.write(make_image(pixels, nx, ny), "./output.png")
    {:ok, self}
  end

  # Computes the chunk size to divide subprocess.
  # `n` must divide the product of x and y.
  defp process_chunk_size(n, x, y) when n > x * y or n < 0, do: x * y

  defp process_chunk_size(n, x, y) do
    if rem(x * y, n) == 0, do: div(x * y, n), else: process_chunk_size(n - 1, x, y)
  end

  # Waits for the async to finish.
  # Every task must be finished correctly.
  # I'm not sure this is a good style.
  defp yield_until_finish(task) do
    case Task.yield(task, 5000) do
      nil -> yield_until_finish(task)
      {:ok, res} -> res
      _ -> raise "Sub task failes."
    end
  end

  # Behaivor of the sub process, avoids nested capture.
  defp partial(l, nx, ny, ns, scene) when is_list(l) do
    :random.seed(:erlang.system_time)
    Enum.map(l, &partial(&1, nx, ny, ns, scene))
  end

  defp partial({x, y}, nx, ny, ns, scene) do
    # Samples to get antialiasing.
    {r, g, b} = (for _ <- 0..ns-1, do: {(x + :random.uniform) / nx, (y + :random.uniform) / ny})
                  |> Enum.map(&Camera.get_ray(scene.camera, &1))
                  |> Enum.map(&color(&1, scene.objects, 0))
                  |> Enum.reduce(&Vec3.add/2)
                  |> Vec3.scale(1.0 / ns)
    # Enhances pixels.
    {r, g, b} = {:math.sqrt(r), :math.sqrt(g), :math.sqrt(b)} |> Vec3.scale(255.99)
    {trunc(r), trunc(g), trunc(b)}
  end

  # Gets color from sampled ray.
  defp color(_ray, _objects, depth) when depth >= 50, do: Vec3.create

  defp color(ray, objects, depth) do
    case RayTracing.Geometry.Hitable.hit(objects, ray, 0.001, 100000) do
      {_, p, {u, v}, _, mat} = rec ->
        emitted = RayTracing.Material.emitted(mat, u, v, p)
        case RayTracing.Material.scatter(mat, ray, rec) do
          {:ok, attenuation, scatterd} -> Vec3.multiply(color(scatterd, objects, depth+1), attenuation)
            |> Vec3.add(emitted)
          _ -> emitted
        end
      _ -> Vec3.create
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
