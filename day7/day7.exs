#!/usr/bin/env elixir

defmodule Steps do
  def parse(<<"Step ",
    first :: binary - size(1),
    " must be finished before step ",
    second :: binary - size(1),
    _rest :: binary>>) do
    {
      uppercase_to_atom(first),
      uppercase_to_atom(second)
    }
  end

  def uppercase_to_atom(s) do
    String.to_atom(s)
  end

  def create_dag(edges) do
    Enum.reduce(edges, :digraph.new(), fn {from, to}, graph ->
      :digraph.add_vertex(graph, from)
      :digraph.add_vertex(graph, to)
      :digraph.add_edge(graph, from, to)
      graph
    end)
  end

  def find_path(graph) do
    case :digraph.source_vertices(graph) do
      [] ->
        ""
      sources ->
        source = sources |> Enum.sort() |> hd
        :digraph.del_vertex(graph, source)
        "#{source}" <> find_path(graph)
    end
  end

  def plan(graph, num_workers \\ 5) do
    workers = 0..(num_workers - 1)
    |> Enum.map(fn x -> {x, :idle} end)
    |> Enum.into(%{})

    work(0, graph, workers, "")
  end

  def work(second, graph, workers, steps_done) do
    workers = Enum.map(fn
      {worker, :idle} -> {worker, :idle}
      {worker, {step, since}} -> {worker, {step, since + 1}}
    end)

    completed = workers
    |> Map.values()
    |> Enum.reject(fn x -> x == :idle end)
    |> Enum.filter(fn {step, since} ->
      since == duration(step)
    end)
    |> Enum.map(fn {step, _} -> step end)
    |> Enum.sort()

    print(second, workers, steps_done)
    work(second + 1, graph, workers, steps_done)
  end

  def print(second, workers, steps_done) do
    workers_view = workers
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.map(fn
      {_k, :idle} -> "."
      {_k, {step, _since}} -> step
    end)
    |> Enum.join(" ")

    IO.puts "#{second} #{workers_view} #{steps_done}"
  end

  def duration(step) do
    (step |> Atom.to_charlist() |> hd) - ?A + 1
  end
end

defmodule Day7 do
  def input do
    "input.txt"
    |> File.read!
    |> String.split("\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(&Steps.parse/1)
  end

  def puzzle1 do
    input()
    |> Steps.create_dag()
    |> Steps.find_path()
  end

  def puzzle2 do
    input()
    |> Steps.create_dag()
    |> Steps.plan()
  end
end

Day7.puzzle1 |> IO.puts
Day7.puzzle2 |> IO.puts
