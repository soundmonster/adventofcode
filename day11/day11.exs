#! /usr/bin/env elixir

defmodule Grid do
  def new({x_size, y_size} \\ {300, 300}, ser \\ 7857) do
    for y <- 1..y_size do
      for x <- 1..x_size do
        value_at(x, y, ser)
      end
    end
  end

  def value_at(x, y, ser \\ 7857) do
    rack_id = x + 10
    hundreds((rack_id * y + ser) * rack_id) - 5
  end

  def hundreds(x) do
    x
    |> Integer.digits()
    |> Enum.reverse()
    |> case do
      [_, _, d | rest] ->
        d

      _ ->
        0
    end
  end

  def subgrids(grid, size \\ 3) do
    for y <- 0..(length(grid) - size - 1), x <- 0..(length(hd(grid)) - size - 1) do
      {x + 1, y + 1, grid_sum(grid, x, y, size)}
    end
  end

  def all_size_subgrids(grid) do
    for size <- 1..length(grid) do
      for y <- 0..(length(grid) - size - 1),
          x <- 0..(length(hd(grid)) - size - 1) do
        {x + 1, y + 1, size, grid_sum(grid, x, y, size)}
      end

      IO.write("#{size}")
    end
  end

  def grid_sum(grid, x, y, size \\ 3) do
    grid
    |> Enum.drop(y)
    |> Enum.take(size)
    |> Enum.map(fn line ->
      line |> Enum.drop(x) |> Enum.take(size) |> Enum.sum()
    end)
    |> Enum.sum()
  end
end

defmodule Day11 do
  # def serno, do: 7857
  def serno, do: 42

  def puzzle1 do
    Grid.new({300, 300}, serno()) |> Grid.subgrids() |> Enum.max_by(fn {_, _, s} -> s end)
  end

  def puzzle2 do
    Grid.new({300, 300}, serno())
    |> Grid.all_size_subgrids()
    |> Enum.max_by(fn {_, _, s} -> s end)
  end
end

Day11.puzzle1() |> IO.inspect()
Day11.puzzle2() |> IO.inspect()
