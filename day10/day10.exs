#! /usr/bin/env elixir

defmodule Sky do
  defstruct [:points, :seconds_elapsed]

  def new(s) do
    %Sky{
      points:
        s
        |> String.split("\n")
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))
        |> Enum.map(&Point.new/1),
      seconds_elapsed: 0
    }
  end

  def move(%Sky{points: points, seconds_elapsed: seconds}) do
    %Sky{
      points: points |> Enum.map(&Point.move/1),
      seconds_elapsed: seconds + 1
    }
  end

  def bounding_box(%Sky{points: points}) do
    {min_x, max_x} = points |> Enum.map(& &1.x) |> Enum.min_max()
    {min_y, max_y} = points |> Enum.map(& &1.y) |> Enum.min_max()
    {{min_x, max_x}, {min_y, max_y}}
  end

  def area({{min_x, max_x}, {min_y, max_y}}) do
    (max_x - min_x) * (max_y - min_y)
  end

  def print(%Sky{} = sky) do
    {{min_x, max_x}, {min_y, max_y}} = bounding_box(sky)

    for y <- min_y..max_y do
      for x <- min_x..max_x do
        if(point_at?(sky, {x, y})) do
          IO.write("#")
        else
          IO.write(".")
        end
      end

      IO.puts("")
    end

    sky
  end

  def point_at?(%Sky{points: points}, {x, y}) do
    points
    |> Enum.any?(fn %{x: px, y: py} -> px == x && py == y end)
  end
end

defmodule Point do
  defstruct [:x, :y, :dx, :dy]

  def new(s) do
    r = ~r/^position=\<(.*),(.*)\> velocity=\<(.*),(.*)\>$/

    [x, y, dx, dy] =
      r
      |> Regex.run(s)
      |> tl()
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    %Point{x: x, y: y, dx: dx, dy: dy}
  end

  def move(%Point{x: x, y: y, dx: dx, dy: dy} = point) do
    %Point{point | x: x + dx, y: y + dy}
  end
end

defmodule Day10 do
  def input do
    "input.txt"
    |> File.read!()
  end

  def example do
    "example.txt"
    |> File.read!()
  end

  def puzzle1 do
    converging_sky() |> Sky.print()
  end

  def puzzle2 do
    %{seconds_elapsed: res} = converging_sky()
    res
  end

  def converging_sky do
    Stream.resource(
      fn -> input() |> Sky.new() end,
      fn sky ->
        next = Sky.move(sky)
        {[next], next}
      end,
      fn _ -> :ok end
    )
    |> Stream.map(fn sky -> {sky, sky |> Sky.bounding_box() |> Sky.area()} end)
    |> Stream.chunk_every(2, 1)
    |> Stream.drop_while(fn [{_, cur}, {_, next}] ->
      cur > next
    end)
    |> Enum.take(1)
    |> hd
    |> hd
    |> elem(0)
  end
end

Day10.puzzle1()
Day10.puzzle2() |> IO.puts()
