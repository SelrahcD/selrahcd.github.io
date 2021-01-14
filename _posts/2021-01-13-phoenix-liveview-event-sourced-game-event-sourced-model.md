---
layout: "post-no-feature"
title: "Building an event-sourced game with Phoenix Liveview: An event sourced model"
description: "This article covers the basis for an event sourced model with Elixir. This is the first part about the game logic of a game build on top Phoenix and Liveview."
category: articles
tags:
 - "Event sourcing"
 - Elixir
 - DoctorP
 - Liveview
 - Phoenix
published: true
comments: true
---

<div class="series">
    <p>This article is part of a series on building an event-sourced game in Elixir with Phoenix Liveview. Other articles are:</p>
    <ul>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-intro">Introduction</a></li>
        <li><a href="/articles/phoenix-liveview-event-sourced-game-architecture">Architecture</a></li>
        <li><a href="articles/phoenix-liveview-event-sourced-game-event-sourced-model">Game logic: an event sourced model</a></li>
    </ul>
</div>

This article on the series of building an event-sourced game with Elixir Phoenix and LiveView focuses on the game logic.

It would be too long and probably unclear for the reader to cover everything in one article, so I've decided to start from the beginning and rebuild everything from the start, omitting details, sometimes being a bit vague, and lying a bit about the final implementation.

In this first part about the game logic, we'll see how I built some basis for an event-sourced model.

## An event-sourced model

Before discussing the architecture of the game logic, we need to understand what event sourcing is.

As [summarized by Martin Fowler](https://martinfowler.com/eaaDev/EventSourcing.html), it means that we "Capture all changes to an application state as a sequence of events."

In an event-sourced system, when something occurs, an event, or a list of events, is produced. It differs from a more traditionally designed system where the new state is returned.

To get the current system state, we go through all past events and apply them one by one to rebuild the state incrementally.

We now have the basic understanding we'll need to continue. Still, I invite you to read Martin's article if you want to get all advantages and difficulties related to this pattern.

The game is event-sourced, which means that when something happens, events are produced and stored somewhere. Next time we want to act on the game, we'll get all events and apply them one by one to rebuild the current state before applying the action.

## Events

As we've seen, events are a big part of the design: they describe what happened during the game.

Events are designed as structures containing a map called `data` that stores all information about an event.

For instance, when a red card is dealt to a player, we need to know which card was given to whom.

To avoid duplicating the same code in each event module, I came up with a module defining a macro we can reuse:

```elixir
defmodule DoctorP.Game.Events.Event do
  defmacro __using__(_opts) do
    quote do
      defstruct data: %{}

      alias __MODULE__

      def with(data) when is_list(data) do
        data = data
               |> Enum.into(%{})

        __MODULE__.with(data)
      end

      def with(data) when is_map(data) do
        %__MODULE__{data: data}
      end
    end
  end
end
```

This macro declares the structure with the `data` map and a `with` function.
The `with` function has two clauses and can be called with a map or a keyword list to build the event with the appropriate data.

Declaring an event becomes as easy as using the module:

```elixir
defmodule DoctorP.Game.Events.DealtRedCardToPlayer, do:
  use DoctorP.Game.Events.Event
```

and were now able to create an event

```elixir
DealtRedCardToPlayer.with(player: player, card: red_card)
```

## Rebuilding the state

As explained in the first part of the article, the current state is rebuilt from all the past events.

I've created a `GameState` module that provides a `build_state` function. `build_state` takes a list of events, `history`, and rebuilds the state by calling `apply_event` function with the state and the event being applied. The `apply_event` function returns the state once the event is applied.

Here is a simplified version with the state stored in a map and coping with `GameStarted` and `PlayerJoinedTeam` events.

We'll see in another article the code as it is, which is slightly more complex.


```elixir
defmodule DoctorP.Game.States.GameState do

  def build_state(history) do
    
    defaultState = %{
      isStarted: true,
      players: []
    }

    List.foldl(history, defaultState, fn event, state ->
      apply_event(state, event)
    end)
  end

  def apply_event(state, %GameStarted{} = event) do
    %{state | isStarted: true}
  end

   def apply_event(state, %PlayerJoinedTeam{} = event) do
    %{state | players: [event.data.player | state.players]}
  end

end
```

We can now call `build_state` with a history :

```elixir

[]
|> GameState.build_state() # %{isStarted: false, players: []}

[
  %GameStarted{},
]
|> GameState.build_state() # %{isStarted: true, players: []}

[
  %GameStarted{},
  PlayerJoinedTeam.with(player: "Charles"),
]
|> GameState.build_state() # %{isStarted: true, players: ["Charles"]}

[
  %GameStarted{},
  PlayerJoinedTeam.with(player: "Charles"),
  PlayerJoinedTeam.with(player: "Paul")
]
|> GameState.build_state() # %{isStarted: true, players: ["Paul", "Charles"]}

```

## Producing events

We've just seen how we can rebuild the state from events, but where do events come?

Events are the result of actions taken on the game.

I've decided to use command objects to represent actions. Each command is an elixir structure containing the field necessary to describe the intention.

For instance, here is the module for the command allowing to add a player with a given name:

```elixir
defmodule DoctorP.Game.Commands.AddPlayer do

  defstruct player_name: nil

end
```

The command is dealt with by a `handle` function with a clause for each event. Pattern matching does its job to find the appropriate one:

```elixir
def handle(state, %AddPlayer{}) do
end

def handle(state, %MarkWordAsGuessed{}) do
end
```

Each clause body contains the game logic we want to apply based on the state and command passed as parameters. The result of the action is expressed as a list of events:

```elixir
def handle(state, %AddPlayer{player_name: name}) do
  [
    PlayerJoinedTeam.with(player: name)
  ]
end
```

As we can see, we need to build the game state prior to handling a command. For convenience, we can add a `handle_message` function to our `GameState` module, which takes the list of past events and the command. This function's job is to rebuild the state and apply the command.

```elixir
def handle_message(history, command) do
  build_state(history)
  |> handle(command)
end
```

With this in place, we have a basis for expressing our game logic with events and commands. In the next articles, we'll see how I evolved this to deal with errors, describe the game's state more clearly, and manage the timer.