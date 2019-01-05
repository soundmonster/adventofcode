#!/usr/bin/env elixir

require IEx

defmodule Claim do
  defstruct [:id, :left, :top, :width, :height]

  def new(line) do
    [id, left, top, width, height] =
      line
      |> String.split(["#", "@", ":", " ", ",", "x"])
      |> Enum.reject(& &1 == "")
      |> Enum.map(&String.to_integer/1)

    %Claim{id: id, left: left, top: top, width: width, height: height}
  end

  def register_all_claims(claims) do
    Enum.reduce(claims, %{}, fn claim, register ->
      Claim.register_claim(register, claim)
    end)
  end

  def register_claim(%{} = register, %Claim{} = claim) do
    claim
    |> unfold()
    |> Enum.reduce(register, fn coord, acc -> claim_cell(acc, coord) end)
  end

  def claim_cell(%{} = register, coords) do
    Map.update(register, coords, 1, &(&1 + 1))
  end

  def filter_overlaps(%{} = register) do
    register
    |> Enum.filter(fn {_, num_claims} ->
      num_claims > 1
    end)
    |> Enum.into(%{})
  end

  def overlaps?(%{} = register, %Claim{} = claim) do
    claim
    |> unfold()
    |> Enum.map(& Map.get(register, &1))
    |> Enum.any?
  end

  def unfold(%Claim{top: top, left: left, height: height, width: width}) do
    for row <- (top)..(top + height - 1) do
      for column <- (left)..(left + width - 1) do
        {row, column}
      end
    end
    |> List.flatten
  end
end

defmodule Day3 do
  def input do
    "input.txt"
    |> File.read!
    |> String.split("\n")
    |> Enum.reject(& &1 == "")
    |> Enum.map(&Claim.new/1)
  end

  def puzzle_1 do
    input()
    |> Claim.register_all_claims()
    |> Claim.filter_overlaps()
    |> Enum.count()
  end

  def puzzle_2 do
    claims = input()
    register = claims
               |> Claim.register_all_claims()
               |> Claim.filter_overlaps()

    claims
    |> Enum.reject(& Claim.overlaps?(register, &1))
  end
end

Day3.puzzle_1 |> IO.inspect(label: :puzzle_1)
Day3.puzzle_2 |> IO.inspect(label: :puzzle_2)



