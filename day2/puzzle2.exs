#!/usr/bin/env elixir

defmodule Day2 do
  def skip_char_at(s, i) when is_binary(s) and is_integer(i) do
    String.slice(s, 0, i) <> String.slice(s, i+1, 1000)
  end

  def input do
    "input.txt"
    |> File.read!()
    |> String.split("\n")
  end

  def solution(:n_squared) do
    codes = input()
    for a <- codes, b <- codes do
      {a, b}
    end
    |> Enum.filter(fn {a, b} ->
      manhattan_distance(a, b) <= 1
    end)
    |> Enum.take(1)
  end

  def solution(:n_x_item_size) do
    codes = input()
    l = codes |> hd |> String.length()

    Stream.unfold(l-1, fn
      0 -> nil
      n -> {n, n-1}
    end)
    |> Stream.map(& solve_for_position(codes, &1))
    |> Enum.take(1)
  end

  def solve_for_position(codes, i) do
      codes
      |> Enum.sort_by(& skip_char_at(&1, i))
      |> Enum.chunk_every(2,1, :discard)
      |> Enum.filter(fn [a, b] ->
        manhattan_distance(a, b) == 1
      end)
      |> Enum.take(1)
  end

  def solution do
    solution(:n_squared)
  end

  def manhattan_distance(
    <<c1 :: binary - size(1), rest1::binary>>,
    <<c2 :: binary - size(1), rest2::binary>>) do
    (c1 == c2 && 0 || 1) + manhattan_distance(rest1, rest2)
  end

  def manhattan_distance("", ""), do: 0
end

:n_x_item_size
|> Day2.solution()
|> IO.inspect(label: :puzzle2)
