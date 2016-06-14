defmodule RayTracing.Linalg.Ray do
  @moduledoc """
  Ray with origin and direction.
  """
  @type ray :: {vec3, vec3, float}
  @type vec3 :: {float, float, float}

  @doc """
  Creates an identity ray with zero origin and direction.
  """
  @spec create() :: ray
  def create() do
    {{0.0, 0.0, 0.0},
     {0.0, 0.0, 0.0},
     0.0}
  end

  @doc """
  Creates a ray with specified origin and direction.
  """
  @spec create(vec3, vec3, float) :: ray
  def create({_, _, _} = origin, {_, _, _} = direction, time) do
    {origin, direction, time}
  end

  @doc """
  Gets the orign of the ray.
  """
  @spec origin(ray) :: vec3
  def origin({{_, _, _} = origin, {_, _, _} = _direction, _time}) do
    origin
  end

  @doc """
  Gets the direction of the ray.
  """
  @spec direction(ray) :: vec3
  def direction({{_, _, _} = _origin, {_, _, _} = direction, _time}) do
    direction
  end

  @doc """
  Gets the time of the ray.
  """
  @spec time(ray) :: float
  def time({_origin, _direction, time}) do
    time
  end

  @doc """
  Gets the point of the ray with parameter.
  """
  @spec point_at(ray, float) :: vec3
  def point_at(ray, t) do
    Graphmath.Vec3.add(origin(ray), Graphmath.Vec3.scale(direction(ray), t))
  end
end
