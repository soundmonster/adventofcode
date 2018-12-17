#!/usr/bin/env elixir

defmodule Grid do
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
    |> Enum.unzip()
    |> Enum.map()
  end

  def puzzle2 do
  end
end

Day6.puzzle1() |> IO.inspect(label: :puzzle1)
Day6.puzzle2() |> IO.inspect(label: :puzzle2)
