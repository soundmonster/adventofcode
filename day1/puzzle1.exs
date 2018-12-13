#!/usr/bin/env elixir

# "input.txt" |> File.read! |> String.split |> Enum.map(&String.to_integer/1) |> Enum.sum |> IO.puts

"input.txt"
|> File.stream!([], :line)
|> Stream.map(&String.trim/1)
|> Stream.map(&String.to_integer/1)
|> Stream.scan(&(&1 + &2))
|> Enum.to_list
|> List.last
|> IO.inspect
