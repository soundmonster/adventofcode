#!/usr/bin/env elixir

# "input.txt" |> File.read! |> String.split |> Enum.map(&String.to_integer/1) |> Enum.sum |> IO.puts

"input.txt"
|> File.stream!([], :line)
|> Stream.cycle
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Stream.scan(&(&1 + &2))
# |> Stream.map(fn x -> {x, MapSet.new([0])} end)
|> Stream.scan({0, MapSet.new()}, fn x, {prev, agg} -> {x, MapSet.put(agg, prev)} end)
|> Stream.drop_while(fn {x, agg} -> x not in agg end)
|> Stream.map(fn {x, _} -> x end)
|> Enum.take(1)
|> IO.inspect
