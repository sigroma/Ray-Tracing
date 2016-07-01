defmodule RayTracing.Linalg do
  @moduledoc """
  Handles problems of linear algebra.
  """

  @doc """
  Solves quadratic problem.

  Returns the two sorted real roots.
  """
  @spec solve_quadratic(float, float, float) :: {float, float} | atom
  def solve_quadratic(a, b, c) do
    discrim = b * b - 4.0 * a * c
    if discrim < 0.0 do
      :error
    else
      root_discrim = :math.sqrt(discrim)
      q = if b < 0.0, do: -0.5 * (b - root_discrim), else: -0.5 * (b + root_discrim)
      case {q / a, c / q} do
        {x, y} when x > y -> {y, x}
        {x, y} -> {x, y}
      end
    end
  end

  @doc """
  Linear interpolation.
  """
  @spec lerp(float, float, float) :: float
  def lerp(q0, q1, t) do
    t * q1 + (1 - t) * q0
  end

  @doc """
  Bilinear interpolation.
  """
  @spec bilinear_lerp(float, float, float, float, float, float) :: float
  def bilinear_lerp(q00, q10, q01, q11, tx, ty) do
    lerp(lerp(q00, q10, tx), lerp(q01, q11, tx), ty)
  end

  @doc """
  Trilinear interpolation.
  """
  @spec trilinear_lerp(float, float, float, float, float, float,
                       float, float, float, float, float) :: float
  def trilinear_lerp(q000, q100, q010, q110, q001, q101,
                     q011, q111, tx, ty, tz) do
    x00 = lerp(q000, q100, tx)
    x10 = lerp(q010, q110, tx)
    x01 = lerp(q001, q101, tx)
    x11 = lerp(q011, q111, tx)
    y0 = lerp(x00, x10, ty)
    y1 = lerp(x01, x11, ty)
    lerp(y0, y1, tz)
  end
end
