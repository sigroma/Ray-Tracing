defmodule RayTracing.LinalgTest do
  use ExUnit.Case
  
  test "quadratic equation" do
    assert RayTracing.Linalg.solve_quadratic(1, 1, 1) == :error
    assert RayTracing.Linalg.solve_quadratic(2, 3, -2) == {-2.0, 0.5}
  end
end
