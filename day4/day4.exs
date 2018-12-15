#!/usr/bin/env elixir

require IEx

defmodule Shift do
  defstruct [:guard, :date, :asleep]


  def new({{:guard, id, date, _time}, events}) do
    %Shift{guard: id, date: date, asleep: unfold(events)}
  end

  def unfold([{:asleep, _, minute_from}, {:awake, _, minute_to}]) do
    for minute <- 0..59 do
      minute >= minute_from && minute < minute_to
    end
  end

  def unfold(_do_recursion_here) do
    []
  end

  def parse_line(<<"[", date :: binary - size(10), " ", time :: binary - size(5), "] Guard #", rest::binary>>) do
    id = rest |> String.split |> hd
    {:guard, id, date, time}
  end

  def parse_line(<<"[", date :: binary - size(10), " 00:", minute :: binary - size(2), "] falls asleep">>) do
    {:asleep, date, String.to_integer(minute)}
  end

  def parse_line(<<"[", date :: binary - size(10), " 00:", minute :: binary - size(2), "] wakes up">>) do
    {:awake, date, String.to_integer(minute)}
  end

  def parse_line(_) do
    :error
  end

  def chunk(log) do
    log
    |> Enum.chunk_by(fn x -> match?({:guard, _, _, _}, x) end)
    |> pairwise_fold
  end

  def pairwise_fold([first, second | rest]) do
    [{first, second}] ++ pairwise_fold(rest)
  end

  def pairwise_fold([first]) do
    [{first, nil}]
  end

  def pairwise_fold([]) do
    []
  end
end

defmodule Day4 do
  def input do
    "input.txt"
    |> File.read!
    |> String.split("\n")
    |> Enum.sort()
    |> Enum.reject(& &1 == "")
  end
end

Day4.input
  |> Enum.map(&Shift.parse_line/1)
  |> Shift.chunk()
  |> Enum.map(&Shift.new/1)
  |> IO.inspect

