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
end
