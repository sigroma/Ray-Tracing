defmodule RayTracing.Noise.Perlin do
  @moduledoc """
  Perlin noise generator.
  """
  @type vec3 :: {float, float, float}
  alias Graphmath.Vec3

  defstruct random_vec: nil, perm_x: nil, perm_y: nil, perm_z: nil

  @doc """
  Generates the noise data.
  """
  def create do
    seq = :lists.seq(0, 255)
    %RayTracing.Noise.Perlin{
      random_vec: (for k <- seq, do: {k, Vec3.create(-1 + 2 * :random.uniform,
                                                     -1 + 2 * :random.uniform,
                                                     -1 + 2 * :random.uniform) |> Vec3.normalize})
                    |> Enum.into(%{}),
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
    u0 = x - i
    u1 = u0 - 1
    v0 = y - j
    v1 = v0 - 1
    w0 = z - k
    w1 = w0 - 1

    u = u0 * u0 * (3 - 2 * u0)
    v = v0 * v0 * (3 - 2 * v0)
    w = w0 * w0 * (3 - 2 * w0)

    g000 = perlin.random_vec[perlin.perm_x[:erlang.band(i + 0, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 0, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 0, 255)])]
    g100 = perlin.random_vec[perlin.perm_x[:erlang.band(i + 1, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 0, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 0, 255)])]
    g010 = perlin.random_vec[perlin.perm_x[:erlang.band(i + 0, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 1, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 0, 255)])]
    g110 = perlin.random_vec[perlin.perm_x[:erlang.band(i + 1, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 1, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 0, 255)])]
    g001 = perlin.random_vec[perlin.perm_x[:erlang.band(i + 0, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 0, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 1, 255)])]
    g101 = perlin.random_vec[perlin.perm_x[:erlang.band(i + 1, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 0, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 1, 255)])]
    g011 = perlin.random_vec[perlin.perm_x[:erlang.band(i + 0, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 1, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 1, 255)])]
    g111 = perlin.random_vec[perlin.perm_x[:erlang.band(i + 1, 255)]
             |> :erlang.bxor(perlin.perm_y[:erlang.band(j + 1, 255)])
             |> :erlang.bxor(perlin.perm_z[:erlang.band(k + 1, 255)])]

    q000 = Vec3.dot(g000, Vec3.create(u0, v0, w0))
    q100 = Vec3.dot(g100, Vec3.create(u1, v0, w0))
    q010 = Vec3.dot(g010, Vec3.create(u0, v1, w0))
    q110 = Vec3.dot(g110, Vec3.create(u1, v1, w0))
    q001 = Vec3.dot(g001, Vec3.create(u0, v0, w1))
    q101 = Vec3.dot(g101, Vec3.create(u1, v0, w1))
    q011 = Vec3.dot(g011, Vec3.create(u0, v1, w1))
    q111 = Vec3.dot(g111, Vec3.create(u1, v1, w1))

    RayTracing.Linalg.trilinear_lerp(q000, q100, q010, q110, q001, q101, q011, q111, u, v, w)
  end

  @doc """
  Noise turbulence.
  """
  def turb(perlin, p, depth) do
    turb(perlin, p, 1, depth)
  end

  defp turb(_perlin, _p, _weight, depth) when depth <= 0 do
    0
  end

  defp turb(perlin, p, weight, depth) do
    noise(perlin, p) * weight + turb(perlin, Vec3.scale(p, 2), weight * 0.5, depth - 1)
  end
end
