defmodule RayTracing.Noise.Perlin do
  @moduledoc """
  Perlin noise generator. Uses some hack methods.

  See `http://eastfarthing.com/blog/2015-04-21-noise/`.
  """

  defstruct random_float: nil, perm_x: nil, perm_y: nil, perm_z: nil

  @doc """
  Generates the noise data.
  """
  def create do
    seq = :lists.seq(0, 255)
    %RayTracing.Noise.Perlin{
      random_float: (for k <- seq, do: {k, :random.uniform}) |> Enum.into(%{}),
      perm_x: Enum.zip(seq, Enum.shuffle(seq)) |> Enum.into(%{}),
      perm_y: Enum.zip(seq, Enum.shuffle(seq)) |> Enum.into(%{}),
      perm_z: Enum.zip(seq, Enum.shuffle(seq)) |> Enum.into(%{})}
  end

  @doc """
  Gets the noise value.

  TODO Checks the `nil` value.
  """
  def noise(perlin, {x, y, z}) do
    i = RayTracing.Math.floor(x)
    j = RayTracing.Math.floor(y)
    k = RayTracing.Math.floor(z)
    u = x - i
    v = y - j
    w = z - k
    u = u * u * (3 - 2 * u);
    v = v * v * (3 - 2 * v);
    w = w * w * (3 - 2 * w);

    q000 = perlin.random_float[perlin.perm_x[:erlang.band(i + 0, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 0, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 0, 255)])]
    q100 = perlin.random_float[perlin.perm_x[:erlang.band(i + 1, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 0, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 0, 255)])]
    q010 = perlin.random_float[perlin.perm_x[:erlang.band(i + 0, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 1, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 0, 255)])]
    q110 = perlin.random_float[perlin.perm_x[:erlang.band(i + 1, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 1, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 0, 255)])]
    q001 = perlin.random_float[perlin.perm_x[:erlang.band(i + 0, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 0, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 1, 255)])]
    q101 = perlin.random_float[perlin.perm_x[:erlang.band(i + 1, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 0, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 1, 255)])]
    q011 = perlin.random_float[perlin.perm_x[:erlang.band(i + 0, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 1, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 1, 255)])]
    q111 = perlin.random_float[perlin.perm_x[:erlang.band(i + 1, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 1, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 1, 255)])]

    RayTracing.Linalg.trilinear_lerp(q000, q100, q010, q110, q001, q101, q011, q111, u, v, w)
  end
end
