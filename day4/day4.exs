#!/usr/bin/env elixir

require IEx

defmodule Shift do
  defstruct [:guard, :date, :asleep]

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

  def parse_logs(input) do
    input
    |> Enum.reduce([], &do_parse_logs/2)
    |> Enum.reverse
    |> Enum.map(&minutes_to_list/1)
  end

  def aggregate_by_elf(shifts) do
    shifts
    |> Enum.group_by(fn shift -> shift.guard end, fn shift -> shift.asleep end)
    |> Enum.map(fn {guard, asleeps} ->
      {guard, Enum.reduce(asleeps, empty_minutes_list(), &sum_shifts/2)}
    end)
  end

  defp sum_shifts(left, right) do
    left
    |> Enum.zip(right)
    |> Enum.map(fn {l, r} -> l + r end)
  end

  defp do_parse_logs(line, acc) do
    case line do
      {:guard, id, date, _time} ->
        [%Shift{guard: id, date: date, asleep: empty_minutes_map()} | acc]
      {:asleep, date, from} ->
        shift = hd(acc)
        [
           %Shift{shift | date: date, asleep: set_asleep(shift.asleep, from)}
           | tl(acc)
        ]
      {:awake, date, from} ->
        shift = hd(acc)
        [
           %Shift{shift | date: date, asleep: set_awake(shift.asleep, from)}
           | tl(acc)
        ]
    end
  end

  def empty_minutes_map() do
    Enum.reduce(0..59, %{}, fn minute, map -> Map.put(map, minute, 0) end)
  end

  def empty_minutes_list() do
    List.duplicate(0, 60)
  end

  def set_asleep(minutes, from) do
    Enum.reduce(from..59, minutes, & Map.put(&2, &1, 1))
  end

  def set_awake(minutes, from) do
    Enum.reduce(from..59, minutes, & Map.put(&2, &1, 0))
  end

  def minutes_to_list(%Shift{asleep: minutes} = shift) do
    %Shift{shift | asleep: Enum.map(0..59, & Map.get(minutes, &1, 0))}
  end
end

defmodule Day4 do
  def input do
    "input.txt"
    |> File.read!
    |> String.split("\n")
    |> Enum.sort()
    |> Enum.reject(& &1 == "")
    |> Enum.map(&Shift.parse_line/1)
  end

  def puzzle1 do
    elf_stats = input()
    |> Shift.parse_logs
    |> Shift.aggregate_by_elf

    {id, asleep} = Enum.max_by(elf_stats, fn {_, arr} -> Enum.sum(arr) end)

    winner_id = String.to_integer(id)
    {_, winner_minute} = asleep
    |> Enum.with_index()
    |> Enum.max_by(fn {score, _minute} -> score end)

    IO.inspect(winner_id * winner_minute, label: :puzzle1)
  end

  def puzzle2 do
    elf_stats = input()
    |> Shift.parse_logs
    |> Shift.aggregate_by_elf

    {winner_id, winner_minute, _} = elf_stats
    |> Enum.map(fn {elf, asleep} ->
      asleep
      |> Enum.with_index()
      |> Enum.map(fn {asleep?, minute} -> {String.to_integer(elf), minute, asleep?} end)
    end)
    |> List.flatten()
    |> Enum.max_by(& elem(&1, 2))

    IO.inspect(winner_id * winner_minute, label: :puzzle1)
  end
end

Day4.puzzle1
Day4.puzzle2
