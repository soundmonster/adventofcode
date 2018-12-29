#! /usr/bin/env elixir

defmodule Game do
  defstruct [
    :circle,
    :turns_played,
    :next_marble,
    :players,
    :current_player,
    :current_marble_index,
    :scores
  ]

  def new(players) when players > 0 do
    %Game{
      circle: [0],
      turns_played: 0,
      players: players,
      current_player: 0,
      current_marble_index: 0,
      next_marble: 1,
      scores: %{}
    }
  end

  def turn(%Game{turns_played: 0, players: players} = game) do
    %Game{
      game
      | circle: [0, 1],
        turns_played: 1,
        current_marble_index: 1,
        current_player: 1,
        next_marble: 2
    }
  end

  def turn(%Game{turns_played: 1, players: players} = game) do
    %Game{
      game
      | circle: [0, 2, 1],
        turns_played: 2,
        current_marble_index: 1,
        current_player: rem(2, players),
        next_marble: 3
    }
  end

  def turn(%Game{turns_played: 2, players: players} = game) do
    %Game{
      game
      | circle: [0, 2, 1, 3],
        turns_played: 3,
        current_marble_index: 3,
        current_player: rem(3, players),
        next_marble: 4
    }
  end

  def turn(%{next_marble: m} = game) when rem(m, 23) != 0 do
    next_marble_index = rem(game.current_marble_index + 2, length(game.circle))
    {l, r} = Enum.split(game.circle, next_marble_index)
    circle = l ++ [m] ++ r
    turns_played = game.turns_played + 1

    %Game{
      game
      | next_marble: m + 1,
        turns_played: turns_played,
        current_marble_index: next_marble_index,
        circle: circle,
        current_player: rem(turns_played, game.players)
    }
  end

  def turn(%{next_marble: m} = game) when rem(m, 23) == 0 do
    # update scores
    game
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
end

defmodule Day9 do
  def input do
  end

  def puzzle1 do
    0..30
    |> Enum.reduce(Game.new(10), fn _, game ->
      game
      |> Game.inspect()
      |> Game.turn()
    end)
  end

  def puzzle2 do
  end
end

Day9.puzzle1() |> IO.inspect(label: :puzzle1)
Day9.puzzle2() |> IO.inspect(label: :puzzle2)
