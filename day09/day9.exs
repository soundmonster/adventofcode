#! /usr/bin/env elixir

defmodule Game do
  defstruct [
    :circle,
    :turn,
    :next_marble,
    :players,
    :current_player,
    :current_marble_index,
    :scores
  ]

  def new(players) when players > 0 do
    %Game{
      circle: [0],
      turn: -1,
      players: players,
      current_player: "-",
      current_marble_index: 0,
      next_marble: 1,
      scores: %{}
    }
  end

  def turn(%Game{turn: -1} = game) do
    %Game{
      game
      | circle: [0, 1],
        turn: 0,
        current_marble_index: 1,
        current_player: 1,
        next_marble: 2
    }
  end

  def turn(%Game{turn: 0, players: players} = game) do
    %Game{
      game
      | circle: [0, 2, 1],
        turn: 1,
        current_marble_index: 1,
        current_player: rem(1, players) + 1,
        next_marble: 3
    }
  end

  def turn(%Game{turn: 1, players: players} = game) do
    %Game{
      game
      | circle: [0, 2, 1, 3],
        turn: 2,
        current_marble_index: 3,
        current_player: rem(2, players) + 1,
        next_marble: 4
    }
  end

  def turn(%{next_marble: m} = game) when rem(m, 23) != 0 do
    next_marble_index =
      clockwise(
        length(game.circle),
        game.current_marble_index,
        2
      )

    circle = List.insert_at(game.circle, next_marble_index, m)
    turn = game.turn + 1
    current_player = rem(turn, game.players) + 1

    %Game{
      game
      | next_marble: m + 1,
        turn: turn,
        current_marble_index: next_marble_index,
        circle: circle,
        current_player: current_player
    }
  end

  def turn(%{next_marble: m} = game) when rem(m, 23) == 0 do
    next_marble_index =
      counterclockwise(
        length(game.circle),
        game.current_marble_index,
        7
      )

    {score_marble, circle} = List.pop_at(game.circle, next_marble_index)
    turn = game.turn + 1
    current_player = rem(turn, game.players) + 1
    scores = update_scores(game.scores, current_player, score_marble, m)

    %Game{
      game
      | next_marble: m + 1,
        turn: turn,
        current_marble_index: next_marble_index,
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
    game.circle
    |> Enum.with_index()
    |> Enum.reduce("[#{game.current_player}]", fn {marble, position}, output ->
      if position == game.current_marble_index do
        output <> " (#{marble}) "
      else
        output <> "  #{marble} "
      end
    end)
    |> IO.puts()

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
end

defmodule Day9 do
  def input do
    %{players: 435, last_marble: 71184}
  end

  def input_example_1 do
    %{players: 10, last_marble: 1618}
  end

  def puzzle1 do
    %{players: players, last_marble: last_marble} = input()

    0..last_marble
    |> Enum.reduce(Game.new(players), fn turn, game ->
      if rem(turn, 1000) == 0 do
        IO.puts("#{turn}  ")
      end

      game
      |> Game.turn()
    end)
    |> Game.high_score()

    # Stream.resource(
    #   fn -> Game.new(players) end,
    #   fn game ->
    #     game = game |> Game.turn()

    #     if rem(game.turn, 1000) == 0 do
    #       IO.puts("#{game.turn}  ")
    #     end

    #     {[game], game}
    #   end,
    #   fn _ -> :ok end
    # )
    # |> Enum.find(fn game -> Game.high_score?(game, last_marble) end)
  end

  def puzzle2 do
  end
end

Day9.puzzle1() |> IO.inspect(label: :puzzle1)
Day9.puzzle2() |> IO.inspect(label: :puzzle2)
