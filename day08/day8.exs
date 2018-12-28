#! /usr/bin/env elixir

defmodule Tree do
  defstruct [:children, :metadata]

  def parse(input) do
    {[%Tree{} = tree], []} = input |> do_parse(1)
    tree
  end

  def do_parse(rest, 0) do
    {[], rest}
  end

  def do_parse([num_children, num_meta | rest], n) do
    {children, rest} = do_parse(rest, num_children)
    {meta, rest} = rest |> Enum.split(num_meta)
    {tail, rest} = do_parse(rest, n - 1)
    {[%Tree{children: children, metadata: meta} | tail], rest}
  end

  def agg_meta(%Tree{children: [], metadata: meta}), do: meta

  def agg_meta(%Tree{children: children, metadata: meta}) do
    meta ++ (children |> Enum.map(&agg_meta/1) |> List.flatten())
  end

  def funky_agg_meta(%Tree{children: [], metadata: meta}) do
    Enum.sum(meta)
  end

  def funky_agg_meta(%Tree{children: children, metadata: meta}) do
    for i <- meta do
      if i in 1..length(children) do
        children
        |> List.pop_at(i - 1)
        |> elem(0)
        |> funky_agg_meta
      end
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end
end

defmodule Day8 do
  def input do
    "input.txt"
    |> File.read!()
    # "2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2"
    |> String.trim()
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  def puzzle1 do
    input()
    |> Tree.parse()
    |> Tree.agg_meta()
    |> Enum.sum()
  end

  def puzzle2 do
    input()
    |> Tree.parse()
    |> Tree.funky_agg_meta()
  end
end

IO.inspect(Day8.puzzle1(), label: :puzzle1)
IO.inspect(Day8.puzzle2(), label: :puzzle2)
