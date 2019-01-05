#!/usr/bin/env elixir

defmodule Counter do
  def count_chars(s) when is_binary(s) do
    s
    |> String.to_charlist()
    |> Enum.reduce(%{}, fn c, acc -> Map.update(acc, c, 1, &(&1 + 1)) end)
  end

  def has_score?(x, i) do
    x
    |> Enum.any?(fn {_, v} -> v == i end)
  end
end

{twos, threes} = "input.txt"
|> File.stream!([], :line)
|> Stream.map(&Counter.count_chars/1)
|> Stream.map(fn x -> {Counter.has_score?(x, 2), Counter.has_score?(x, 3)} end)
|> Stream.filter(fn {twos, threes} -> twos || threes end)
|> Enum.reduce({0,0}, fn {twos, threes}, {acc2, acc3} ->
  {
    acc2 + (twos && 1 || 0),
    acc3 + (threes && 1 || 0),
  }
end)

IO.inspect(twos * threes)
