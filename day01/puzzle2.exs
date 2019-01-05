#!/usr/bin/env elixir

"input.txt"
|> File.stream!([], :line)
|> Stream.cycle
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Stream.scan(&(&1 + &2))
|> Stream.scan({0, MapSet.new()}, fn x, {prev, agg} -> {x, MapSet.put(agg, prev)} end)
|> Stream.drop_while(fn {x, agg} -> x not in agg end)
|> Stream.map(fn {x, _} -> x end)
|> Enum.take(1)
|> IO.inspect
