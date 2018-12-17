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
    %Grid{grid | coords: partition(grid)}
  end

  def partition(%Grid{} = grid, extent \\ 0) do
    grid
    |> all_coordinates(extent)
    |> Enum.reduce(grid.coords, fn coord, acc ->
      Map.put(acc, coord, closest(grid, coord))
    end)
  end

  def closest(%Grid{} = grid, {x, y}) do
    grid.points
    |> Enum.map(fn {coords, name} ->
      {name, manhattan(coords, {x,y})}
    end)
    |> Enum.group_by(fn {_, distance} -> distance end, fn {name, _} -> name end)
    |> Enum.sort_by(fn {distance, _} -> distance end)
    |> hd
    |> case do
      {_distance, [name]} -> name
      _ -> "."
    end
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

  def all_coordinates(%Grid{
    top: top,
    left: left,
    right: right,
    bottom: bottom},
    extent \\ 0) do
    for i <- (left-extent)..(right+extent), j <- (top-extent)..(bottom+extent) do
      {i, j}
    end
  end

  def areas(cells) do
    cells
    |> Enum.reduce(%{}, fn {coords,_name}, acc ->
      Map.update(acc, coords, 1, &(&1 + 1))
    end)
  end

  def count_cells(cells) do
    cells
    |> Enum.group_by(fn {_, name} -> name end)
    |> Enum.map(fn {name, cells} -> {name, length(cells)} end)
    |> Enum.into(%{})
  end

  def finite_areas(%Grid{} = grid) do
    partition_fit = grid
      |> partition(0)
      |> count_cells()
    partition_loose = grid
      |> partition(1)
      |> count_cells()

    partition_fit
    |> Map.merge(partition_loose, fn _k, v1, v2 ->
      v1 == v2 && v1 || nil
    end)
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.into(%{})
  end

  def region(%Grid{} = grid, threshold \\ 10_000) do
    newcells = grid
      |> all_coordinates()
      |> Enum.reduce(grid.coords, fn coord, acc ->
        Map.put(acc, coord, remoteness(grid, coord, threshold))
      end)

    %Grid{grid | coords: newcells}
  end

  def remoteness(%Grid{points: ps}, {x,y}, threshold) do
    dist = ps
    |> Enum.map(fn {cell, _} -> cell end)
    |> Enum.map(&manhattan(&1, {x,y}))
    |> Enum.sum()

    dist < threshold && "#" || "."
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
    |> Grid.finite_areas()
    |> Enum.map(fn {_name, count} -> count end)
    |> Enum.max()
  end

  def puzzle2 do
    g = input()
    |> Grid.new()
    |> Grid.populate_points()
    |> Grid.region()

    g.coords
    |> Map.values()
    |> Enum.count(fn s -> s == "#" end)
  end
end

Day6.puzzle1() |> IO.inspect()
Day6.puzzle2() |> IO.inspect
