#!/usr/bin/env elixir

defmodule Grid do
  defstruct ~w(points coords top left right bottom)a

  def new(points) do
    ps = points
    |> Enum.with_index()
    |> Enum.map(fn {coords, index} ->
      {coords, point_name(index)}
    end)

    [top: top, left: left, right: right, bottom: bottom] = bounding_box(points)

    %Grid{
      points: ps,
      coords: %{},
      top: top,
      left: left,
      right: right,
      bottom: bottom
    }
  end

  def voronoi(%Grid{} = grid) do

  end

  def closest(%Grid{} = grid, {x, y}) do

  end

  def populate_points(%Grid{points: ps, coords: coords} = grid) do
    coords = ps |> Enum.reduce(coords, fn {c, _}, acc ->
      Map.put(acc, c, "*")
    end)

    %Grid{grid | coords: coords}
  end

  def manhattan({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def point_name(int) do
    String.at("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz", int)
  end

  def bounding_box(points) do
    {xs, ys} = points |> Enum.unzip
    [
      top: Enum.min(ys),
      left: Enum.min(xs),
      right: Enum.max(xs),
      bottom: Enum.max(ys)
    ]
  end

  def print(%Grid{} = g) do
    for x <- g.left..g.right do
      for y <- g.top..g.bottom do
        Map.get(g.grid, {x,y}, ".")
      end
      |> Enum.join
    end
  end
end

defimpl Inspect, for: Grid do
  def inspect(%Grid{} = g, _opts) do
    for x <- g.left..g.right do
      for y <- g.top..g.bottom do
        Map.get(g.coords, {x,y}, ".")
      end
      |> Enum.join
    end
    |> Enum.join("\n")
  end
end

defmodule Day6 do
  def input do
    "input.txt"
    |> File.read!
    |> String.split("\n")
    |> Enum.reject(& &1 == "")
    |> Enum.map(& String.split(&1, ", "))
    |> Enum.map(fn [i, j] ->
      {String.to_integer(i), String.to_integer(j)}
    end)
  end

  def puzzle1 do
    input()
    |> Grid.new()
    |> Grid.populate_points()
    |> Grid.voronoi()
  end

  def puzzle2 do
  end
end

Day6.puzzle1() |> IO.inspect()
# Day6.puzzle2() |> IO.inspect(label: :puzzle2)
