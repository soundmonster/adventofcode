#! /usr/bin/env elixir

defmodule Game do
  defstruct [
    :circle,
    :turn,
    :next_marble,
    :players,
    :current_player,
    :scores
  ]

  def new(players) when players > 0 do
    %Game{
      circle: Circle.from_list([0], 0),
      turn: -1,
      players: players,
      current_player: "-",
      next_marble: 1,
      scores: %{}
    }
  end

  def turn(%Game{turn: -1} = game) do
    %Game{
      game
      | circle: game.circle |> Circle.rotate(-2) |> Circle.place(1),
        turn: 0,
        current_player: 1,
        next_marble: 2
    }
  end

  def turn(%{next_marble: m} = game) when rem(m, 23) != 0 do
    circle =
      game.circle
      |> Circle.rotate(-2)
      |> Circle.place(m)

    turn = game.turn + 1
    current_player = rem(turn, game.players) + 1

    %Game{
      game
      | next_marble: m + 1,
        turn: turn,
        circle: circle,
        current_player: current_player
    }
  end

  def turn(%{next_marble: m} = game) when rem(m, 23) == 0 do
    {score_marble, circle} =
      game.circle
      |> Circle.rotate(7)
      |> Circle.pop()

    turn = game.turn + 1
    current_player = rem(turn, game.players) + 1
    scores = update_scores(game.scores, current_player, score_marble, m)

    %Game{
      game
      | next_marble: m + 1,
        turn: turn,
        circle: circle,
        current_player: current_player,
        scores: scores
    }
  end

  def update_scores(scores, player, removed_marble, kept_marble) do
    increment = kept_marble + removed_marble
    Map.update(scores, player, increment, &(increment + &1))
  end

  def high_score(%Game{scores: scores}) do
    scores
    |> Enum.max_by(fn {_, score} -> score end)
  end

  def inspect(game) do
    ("[#{game.current_player}] " <> Circle.inspect(game.circle)) |> IO.puts()
    game
  end

  def clockwise(total, from, offset) do
    next = from + offset

    if next == total do
      next
    else
      rem(next, total)
    end
  end

  def counterclockwise(total, from, offset) do
    next = from - offset

    if next < 0 do
      total + next
    else
      next
    end
  end

  def get_winner(%Game{scores: scores}) do
    scores |> Enum.max_by(fn {_, v} -> v end)
  end
end

defmodule Circle do
  defstruct [:circle, :position]

  def new() do
    %Circle{circle: :queue.from_list([0]), position: 0}
  end

  def from_list(list, position) do
    %Circle{circle: :queue.from_list(list), position: 0}
    |> rotate(position)
  end

  def rotate(%Circle{circle: queue, position: pos}, offset) do
    %Circle{circle: rotate_queue(queue, offset), position: pos + offset}
  end

  def rotate_queue(queue, 0), do: queue

  def rotate_queue(queue, offset) when offset > 0 do
    {{:value, item}, queue} = :queue.out_r(queue)
    queue = :queue.in_r(item, queue)
    rotate_queue(queue, offset - 1)
  end

  def rotate_queue(queue, offset) when offset < 0 do
    {{:value, item}, queue} = :queue.out(queue)
    queue = :queue.in(item, queue)
    rotate_queue(queue, offset + 1)
  end

  def place(%Circle{circle: queue, position: pos}, marble) do
    %Circle{circle: :queue.in_r(marble, queue), position: pos}
  end

  def pop(%Circle{circle: queue, position: pos}) do
    {{:value, item}, queue} = :queue.out(queue)

    {item, %Circle{circle: queue, position: pos}}
  end

  def inspect(%Circle{circle: queue, position: position}) do
    total = :queue.len(queue)

    norm_pos =
      if position < 0 do
        total + rem(position, total)
      else
        rem(position, total)
      end

    s =
      queue
      |> rotate_queue(position)
      |> :queue.to_list()
      |> Enum.with_index()
      |> Enum.reduce("", fn {marble, index}, output ->
        if index == norm_pos do
          # if index == 0 do
          output <> "(#{marble})"
        else
          output <> " #{marble} "
        end
      end)

    s <> "  :: #{norm_pos} : #{position} : #{total}"
  end
end

defmodule Day9 do
  def input do
    %{players: 435, last_marble: 71184}
  end

  def input_example_1 do
    %{players: 10, last_marble: 1618}
  end

  def input_example_2 do
    %{players: 300, last_marble: 30}
  end

  def puzzle1 do
    %{players: players, last_marble: last_marble} = input_example_2()

    0..last_marble
    |> Enum.reduce(Game.new(players), fn turn, game ->
      if rem(turn, 1000) == 0 do
        IO.puts("#{turn}  ")
      end

      game
      |> Game.inspect()
      |> Game.turn()
    end)
    |> Game.high_score()
  end

  def puzzle2 do
    0..7_118_400
    |> Enum.reduce(Game.new(435), fn i, game ->
      if rem(i, 1_000_000) == 0, do: IO.puts(i)

      game
      # |> Game.inspect()
      |> Game.turn()
    end)
    |> Map.from_struct()
    |> Map.get(:scores)
    |> Map.get(280)
  end
end

Day9.puzzle1() |> IO.inspect(label: :puzzle1)
# Day9.puzzle2() |> IO.inspect(label: :puzzle2)
