#!/usr/bin/env elixir

defmodule Claim do
  defstruct [:id, :left, :top, :width, :height]

  def new(line) do
    IO.inspect line
    [id, left, top, width, height] = line
    |> String.split(["#", "@", ":", " ", ",", "x"])
    |> Enum.reject(& &1 == "")
    |> Enum.map(&String.to_integer/1)

    %Claim{id: id, left: left, top: top, width: width, height: height}
  end
end

# claims =
"input.txt"
|> File.read!
|> String.split("\n")
|> Enum.reject(& &1 == "")
|> Enum.map(&Claim.new/1)
|> IO.inspect

