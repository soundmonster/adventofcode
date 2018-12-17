#!/usr/bin/env elixir

defmodule Polymer do
  def react(polymer) do
    result = do_react(polymer)
    case length(polymer) - length(result) do
      0 ->
        result
      _ ->
        react(result)
    end
  end

  def remove_unit(polymer, char) when char >= ?A and char <= ?Z do
    polymer
    |> Enum.reject(fn c -> c == char end)
    |> Enum.reject(fn c -> c == char + 32 end)
  end

  def do_react([a, b | rest]) do
    case abs(a - b) do
      32 ->
        do_react(rest)
      _ ->
        [a | do_react([b | rest])]
    end
  end
  def do_react(other), do: other
end

defmodule Day5 do
  def input do
    "input.txt"
    |> File.read!
    |> String.trim()
    |> String.to_charlist()
  end

  def puzzle1 do
    input()
    |> Polymer.react
    |> length
  end

  def puzzle2 do
    input = input()

    ?A..?Z
    |> Enum.map(fn char -> Polymer.remove_unit(input, char) end)
    |> Enum.map(&Polymer.react/1)
    |> Enum.map(&length/1)
    |> Enum.min()
  end
end

Day5.puzzle1 |> IO.inspect(label: :puzzle1)
Day5.puzzle2 |> IO.inspect(label: :puzzle2)
